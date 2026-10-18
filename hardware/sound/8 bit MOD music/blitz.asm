; ============================================================================
;  VZ200 / VZ300  4-channel Amiga .MOD player   (MODPLAY)
; ============================================================================
;  DAC     : 8-bit resistor DAC on the printer port, I/O port 14 (0Eh)
;  Mixer   : 4 voices, nearest-neighbour, fixed-time loop, ~5.4 kHz output
;  Plays   : 31-instrument "M.K." / "M!K!" / "4CHN" / "FLT4" modules and
;            15-instrument Soundtracker modules (auto-detected)
;  Honours : sample number, period (pitch), loops, sample default volume,
;            Cxx (set volume), Axy / 5xy / 6xy (volume slide, per tick),
;            3xx / 5xy notes (change pitch WITHOUT restarting the sample),
;            Fxx (speed / tempo), Bxx (position jump), Dxx (pattern break)
;  Ignores : arpeggio, vibrato, pitch slides, E-effects, finetune
;
;  Assemble: pasmo --bin modplay.asm modplay.bin modplay.sym
;            (put your module beside this file as  song.mod)
;  Load at 8000h, run at 8000h.  Needs RAM from 8000h to the end of the
;  module (code is ~2.5K, so a 9K module ends near 0B000h).
;
;  Everything below that depends on the CPU clock and on the exact length of
;  the mixer loop is in the CALIBRATION block.  If you change the mixer
;  code, re-measure the loop time and recompute those constants.
; ============================================================================

                ORG     08000h

; ---------------------------------------------------------------------------
;  CALIBRATION  (computed outside the assembler - pasmo is only 16 bit)
; ---------------------------------------------------------------------------
;  Measured in a cycle-accurate Z80 emulator:
;    mix_loop = 658 T per output sample with no wrap, ~669 T on average
;    (a loop wrap costs ~50 T extra).  Row decoding and the volume-slide
;    tick updates pause the output for ~3-6k T per row (the DAC just holds
;    its last value).
;
;  CPU      = 3579545 Hz (VZ200)            -> RATE = CPU / 668.8 = 5352 Hz
;  STEP_K   = round(3546895 * 256 * T_STEP / CPU), T_STEP = 675
;             (8.8 fixed-point step = STEP_K / period; 3546895 is the Amiga
;              PAL clock that MOD periods are defined against.  T_STEP is a
;              little above the loop time to cancel the pause at each row,
;              so notes are within about +/-10 cents of true pitch)
;  RATE5    = 5 * RATE         (samples per row = RATE5 * speed / (2 * BPM))
;  GAP      = output samples' worth of time lost to row decoding
;
;  For a 3546895 Hz machine (VZ300) use instead:
;      STEP_K = 172800 (02 A3 00h)   RATE5 = 26517
; ---------------------------------------------------------------------------
STEP_K_H        EQU     002h
STEP_K_M        EQU     09Ch
STEP_K_L        EQU     0D8h
RATE5           EQU     26761
GAP_SAMPLES     EQU     6

DAC_PORT        EQU     14              ; printer data port (decimal 14)
MIN_PERIOD      EQU     100             ; clamp: keeps step < 8 samples/output
FAST_MIN_LOOP   EQU     8               ; shorter loops are played once, not looped
DEF_SPEED       EQU     6
DEF_BPM         EQU     125
SIL_NEND        EQU     0-(silence+1)   ; -(end) of the 1-byte silence cell

; descriptor field offsets (see voice_tab)
D_P             EQU     0
D_F             EQU     2
D_S             EQU     4
D_I             EQU     6
D_N             EQU     8
D_W             EQU     10
D_ST            EQU     12
D_SLOW          EQU     14
D_VO            EQU     16              ; 'or n'  operand: volume table low byte
D_VD            EQU     18              ; 'ld d,n' operand: volume table page
VD_SIZE         EQU     20
INST_SIZE       EQU     16              ; instrument table entry size

; voice state block (per voice, in RAM)
ST_LSTART       EQU     0
ST_LLEN         EQU     2
ST_INSTR        EQU     4
ST_VOL          EQU     5               ; current volume 0..64
ST_SLIDE        EQU     6               ; volume slide per tick (signed)

; ============================================================================
start:
                di
                ld      sp,stack_top
                ld      a,128
                out     (DAC_PORT),a
                call    init
song_forever:
                call    play_song
                jr      song_forever

; ============================================================================
;  init : parse header, build instrument table, pre-scale sample data
; ============================================================================
init:
                ; ---- module long enough for a 31-instrument header? ----
                ld      hl,MOD_END-MOD_START
                ld      de,1084
                or      a
                sbc     hl,de
                jr      c,init_15
                ; ---- look for a known 4-channel tag at offset 1080 ----
                ld      hl,MOD_START+1080
                ld      de,tag_mk
                call    cmp4
                jr      z,init_31
                ld      de,tag_mk2
                call    cmp4
                jr      z,init_31
                ld      de,tag_4chn
                call    cmp4
                jr      z,init_31
                ld      de,tag_flt4
                call    cmp4
                jr      z,init_31
init_15:
                ld      hl,MOD_START+470
                ld      (p_songlen),hl
                ld      hl,MOD_START+472
                ld      (p_order),hl
                ld      hl,MOD_START+600
                ld      (p_patdata),hl
                ld      a,15
                jr      init_hdr
init_31:
                ld      hl,MOD_START+950
                ld      (p_songlen),hl
                ld      hl,MOD_START+952
                ld      (p_order),hl
                ld      hl,MOD_START+1084
                ld      (p_patdata),hl
                ld      a,31
init_hdr:
                ld      (num_instr),a

                ; ---- song length, clamped to 1..128 ----
                ld      hl,(p_songlen)
                ld      a,(hl)
                or      a
                jr      nz,sl1
                inc     a
sl1:            cp      129
                jr      c,sl2
                ld      a,128
sl2:            ld      (songlen),a

                ; ---- where does sample data start? ----
                ; normal rule: highest pattern in all 128 order slots, +1
                ld      hl,(p_order)
                ld      b,128
                call    find_max
                call    data_base
                jr      nc,db_ok
                ; inconsistent (junk in unused slots?): only look at songlen
                ld      hl,(p_order)
                ld      a,(songlen)
                ld      b,a
                call    find_max
                call    data_base
                jr      nc,db_ok
                ld      hl,MOD_END              ; no usable sample data
db_ok:          ld      (running),hl

                ; ---- instrument table + volume pre-scaling ----
                ld      iy,MOD_START+20
                ld      ix,inst_table
                ld      a,(num_instr)
                ld      b,a
in_loop:
                push    bc
                ld      hl,(running)
                ld      (ix+0),l                ; start
                ld      (ix+1),h
                ld      b,(iy+22)               ; length in words, BIG-ENDIAN
                ld      c,(iy+23)
                sla     c
                rl      b                       ; BC = length in bytes
                push    hl                      ; (stack) start
                add     hl,bc
                jr      nc,in_l1
                ld      hl,MOD_END
in_l1:          ld      (running),hl            ; next sample starts here
                ld      de,MOD_END
                call    min_hl_de               ; HL = end clamped to file end
                pop     de                      ; DE = start
                push    hl
                or      a
                sbc     hl,de
                pop     hl
                jr      nc,in_l2
                ld      h,d                     ; end < start -> empty sample
                ld      l,e
in_l2:          ld      (ix+2),l                ; end (default end limit)
                ld      (ix+3),h
                xor     a
                ld      (ix+4),a                ; no loop by default
                ld      (ix+5),a
                ld      (ix+6),a
                ld      (ix+7),a
                ld      a,(iy+25)               ; default volume (clamped)
                cp      65
                jr      c,in_v1
                ld      a,64
in_v1:          ld      (ix+8),a
                call    scale_sample            ; DE=start HL=end

                ; ---- loop info (all BIG-ENDIAN words) ----
                ld      b,(iy+28)
                ld      c,(iy+29)
                ld      a,b
                or      a
                jr      nz,lp_yes
                ld      a,c
                cp      2                       ; 0 or 1 word = no loop
                jr      c,lp_done
lp_yes:         sla     c
                rl      b                       ; BC = loop length bytes
                push    bc
                ld      b,(iy+26)
                ld      c,(iy+27)
                sla     c
                rl      b                       ; BC = loop offset bytes
                ld      l,(ix+0)
                ld      h,(ix+1)
                add     hl,bc                   ; HL = loop start address
                pop     de                      ; DE = loop length
                jr      c,lp_done
                push    hl
                ld      c,(ix+2)
                ld      b,(ix+3)
                or      a
                sbc     hl,bc
                pop     hl
                jr      nc,lp_done              ; loop starts at/after the end
                push    hl                      ; (stack) loop start
                add     hl,de                   ; HL = loop end
                jr      nc,lp_c1
                ld      hl,0FFFFh
lp_c1:          ld      e,(ix+2)
                ld      d,(ix+3)
                call    min_hl_de               ; clamp loop end to sample end
                pop     de                      ; DE = loop start
                push    hl                      ; (stack) loop end
                or      a
                sbc     hl,de                   ; HL = loop length
                ld      a,h
                or      a
                jr      nz,lp_ok
                ld      a,l
                cp      FAST_MIN_LOOP           ; tiny loops (silent tails) play once
                jr      c,lp_bad
lp_ok:          ld      (ix+6),l
                ld      (ix+7),h
                ld      (ix+4),e
                ld      (ix+5),d
                pop     hl
                ld      (ix+2),l                ; end limit = loop end
                ld      (ix+3),h
                jr      lp_done
lp_bad:         pop     hl
lp_done:
                ld      bc,30
                add     iy,bc
                ld      bc,INST_SIZE
                add     ix,bc
                pop     bc
                dec     b
                jp      nz,in_loop

                call    build_voltab

                ; ---- silence all voices, full volume ----
                ld      ix,voice_tab
                ld      b,4
in_sv:          push    bc
                call    silence_voice
                ld      a,64
                call    set_volume
                ld      bc,VD_SIZE
                add     ix,bc
                pop     bc
                djnz    in_sv
                ret

tag_mk:         DEFM    "M.K."
tag_mk2:        DEFM    "M!K!"
tag_4chn:       DEFM    "4CHN"
tag_flt4:       DEFM    "FLT4"

; HL,DE -> 4 byte strings.  Z if equal.  Preserves HL,DE.
cmp4:           push    hl
                push    de
                ld      b,4
c4:             ld      a,(de)
                cp      (hl)
                jr      nz,c4x
                inc     hl
                inc     de
                djnz    c4
c4x:            pop     de
                pop     hl
                ret

; HL = order table, B = count (>=1)  ->  C = highest pattern number
find_max:       ld      c,0
fm1:            ld      a,(hl)
                cp      c
                jr      c,fm2
                ld      c,a
fm2:            inc     hl
                djnz    fm1
                ret

; C = highest pattern -> HL = first sample byte.  Carry set if impossible.
data_base:      ld      a,c
                cp      63
                jr      nc,db_bad
                inc     a
                ld      h,a
                ld      l,0
                add     hl,hl
                add     hl,hl                   ; (c+1) * 1024
                ld      de,(p_patdata)
                add     hl,de
                jr      c,db_bad
                ex      de,hl                   ; DE = base
                ld      hl,MOD_END
                or      a
                sbc     hl,de                   ; carry if base > MOD_END
                ex      de,hl                   ; HL = base (flags kept)
                ret
db_bad:         scf
                ret

; HL = min(HL,DE)
min_hl_de:      ld      a,h
                cp      d
                jr      c,mn_ok
                jr      nz,mn_de
                ld      a,l
                cp      e
                jr      c,mn_ok
mn_de:          ex      de,hl
mn_ok:          ret

; ---------------------------------------------------------------------------
;  scale_sample : DE = start, HL = end
;  Rewrites signed 8-bit data in place as unsigned 0..63 centred on 32:
;  u = (s + 128) >> 2.  Volume is applied later, per voice, by table lookup.
; ---------------------------------------------------------------------------
scale_sample:
                or      a
                sbc     hl,de
                ret     z
                ld      b,h
                ld      c,l                     ; BC = count
                ex      de,hl                   ; HL = start
sc_fast:        ld      a,(hl)
                xor     080h
                srl     a
                srl     a
                ld      (hl),a
                inc     hl
                dec     bc
                ld      a,b
                or      c
                jr      nz,sc_fast
                ret

; ---------------------------------------------------------------------------
;  build_voltab : 17 volume tables of 64 bytes at voltab (256-byte aligned).
;  table[level][u] = 32 + (u-32)*vol/64, vol = min(64, level*4)
; ---------------------------------------------------------------------------
build_voltab:
                ld      hl,voltab
                xor     a
                ld      (s_lvl),a
bv_lvl:         ld      a,(s_lvl)
                add     a,a
                add     a,a
                cp      65
                jr      c,bv_v
                ld      a,64
bv_v:           ld      (s_vol),a
                xor     a
                ld      (s_u),a
bv_u:           ld      a,(s_u)
                sub     32
                jr      c,bv_neg
                call    mulvol                  ; DE = t * vol
                call    shr6                    ; A = DE >> 6
                add     a,32
                jr      bv_store
bv_neg:         neg                             ; |t|
                call    mulvol
                ld      a,e
                add     a,63
                ld      e,a
                ld      a,d
                adc     a,0
                ld      d,a                     ; DE = m + 63 (round up)
                call    shr6
                ld      c,a
                ld      a,32
                sub     c
bv_store:       ld      (hl),a
                inc     hl
                ld      a,(s_u)
                inc     a
                ld      (s_u),a
                cp      64
                jr      nz,bv_u
                ld      a,(s_lvl)
                inc     a
                ld      (s_lvl),a
                cp      17
                jr      nz,bv_lvl
                ret

; A = x (0..32), (s_vol) = v  ->  DE = x * v      (preserves HL)
mulvol:         push    hl
                ld      e,a
                ld      d,0
                ld      a,(s_vol)
                ld      c,a
                ld      hl,0
                ld      b,8
mv1:            add     hl,hl
                rl      c
                jr      nc,mv2
                add     hl,de
mv2:            djnz    mv1
                ex      de,hl
                pop     hl
                ret

; A = DE >> 6  (DE < 16384)
shr6:           ld      a,e
                rlca
                rlca
                and     3
                ld      e,a
                ld      a,d
                add     a,a
                add     a,a
                or      e
                ret

; ============================================================================
;  play_song : play the order list once, from order 0
; ============================================================================
play_song:
                ld      a,DEF_SPEED
                ld      (speed),a
                ld      a,DEF_BPM
                ld      (bpm),a
                call    calc_row_samples
                xor     a
                ld      (cur_order),a
                ld      (cur_row),a
ps_loop:
                ld      a,0FFh
                ld      (jump_to),a
                ld      (brk_row),a
                call    process_row
                call    play_row

                ; ---- work out the next order / row ----
                ld      a,(jump_to)
                ld      b,a
                ld      a,(brk_row)
                ld      c,a
                and     b
                cp      0FFh
                jr      z,ps_normal
                ; Bxx and/or Dxx on this row
                ld      a,(cur_order)
                inc     a
                ld      d,a                     ; default: next order
                ld      a,b
                cp      0FFh
                jr      z,ps_f1
                ld      d,a                     ; Bxx target
ps_f1:          ld      a,c
                cp      0FFh
                jr      nz,ps_f2
                xor     a
ps_f2:          cp      64
                jr      c,ps_f3
                xor     a
ps_f3:          ld      (cur_row),a
                ld      a,d
                ld      (cur_order),a
                jr      ps_check
ps_normal:
                ld      a,(cur_row)
                inc     a
                cp      64
                jr      c,ps_n1
                xor     a
                ld      (cur_row),a
                ld      a,(cur_order)
                inc     a
                ld      (cur_order),a
                jr      ps_check
ps_n1:          ld      (cur_row),a
ps_check:
                ld      a,(cur_order)
                ld      hl,songlen
                cp      (hl)
                jp      c,ps_loop               ; order < songlen: keep going
                ret

; ============================================================================
;  process_row : decode one row (4 notes) and patch the 4 voices
; ============================================================================
process_row:
                ld      hl,(p_order)
                ld      a,(cur_order)
                ld      e,a
                ld      d,0
                add     hl,de
                ld      a,(hl)                  ; pattern number
                ld      h,a
                ld      l,0
                add     hl,hl
                add     hl,hl                   ; pattern * 1024
                push    hl
                ld      a,(cur_row)
                ld      l,a
                ld      h,0
                add     hl,hl
                add     hl,hl
                add     hl,hl
                add     hl,hl                   ; row * 16
                pop     de
                add     hl,de
                ld      de,(p_patdata)
                add     hl,de
                ld      (patptr),hl
                xor     a
                ld      (dirty),a
                ld      ix,voice_tab
                ld      b,4
pr_loop:        push    bc
                call    process_voice
                ld      bc,VD_SIZE
                add     ix,bc
                pop     bc
                djnz    pr_loop
                ld      a,(dirty)
                or      a
                call    nz,calc_row_samples
                ret

; ---------------------------------------------------------------------------
;  process_voice : IX = voice descriptor, (patptr) = this voice's note cell
; ---------------------------------------------------------------------------
process_voice:
                ld      hl,(patptr)
                ld      a,(hl)
                ld      (tmp0),a
                inc     hl
                ld      a,(hl)
                ld      (tmp1),a
                inc     hl
                ld      a,(hl)
                ld      (tmp2),a
                inc     hl
                ld      a,(hl)
                ld      (tmp3),a
                inc     hl
                ld      (patptr),hl

                ; no volume slide unless this row asks for one
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      de,ST_SLIDE
                add     hl,de
                ld      (hl),0

                ; ---- instrument number = (b0 & F0) | (b2 >> 4) ----
                ld      a,(tmp0)
                and     0F0h
                ld      c,a
                ld      a,(tmp2)
                rrca
                rrca
                rrca
                rrca
                and     00Fh
                or      c
                jr      z,pv_fx
                ld      c,a
                ld      a,(num_instr)
                cp      c
                jr      c,pv_fx                 ; invalid number: ignore
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      de,ST_INSTR
                add     hl,de
                ld      (hl),c                  ; remember instrument
                ld      a,c
                call    inst_ptr
                ld      a,(iy+8)                ; sample number resets volume
                call    set_volume
pv_fx:
                ; ---- effects: B, C, D, F, and volume slides A / 5 / 6 ----
                ld      a,(tmp2)
                and     00Fh
                cp      00Ch
                jr      z,fx_c
                cp      00Bh
                jr      z,fx_b
                cp      00Dh
                jr      z,fx_d
                cp      00Fh
                jr      z,fx_f
                cp      00Ah
                jr      z,fx_slide
                cp      005h
                jr      z,fx_slide
                cp      006h
                jr      nz,pv_note
fx_slide:       ld      a,(tmp3)                ; x = up, y = down
                rrca
                rrca
                rrca
                rrca
                and     00Fh
                jr      nz,fs1
                ld      a,(tmp3)
                and     00Fh
                neg
fs1:            ld      c,a
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      de,ST_SLIDE
                add     hl,de
                ld      (hl),c
                jr      pv_note
fx_c:           ld      a,(tmp3)
                cp      65
                jr      c,fc1
                ld      a,64
fc1:            call    set_volume
                jr      pv_note
fx_f:           ld      a,(tmp3)                ; Fxx
                or      a
                jr      z,pv_note
                cp      32
                jr      nc,fx_tempo
                ld      (speed),a
                jr      fx_dirty
fx_tempo:       ld      (bpm),a
fx_dirty:       ld      a,1
                ld      (dirty),a
                jr      pv_note
fx_b:           ld      a,(tmp3)
                ld      (jump_to),a
                jr      pv_note
fx_d:           ld      a,(tmp3)                ; BCD row
                ld      b,a
                and     0F0h
                rrca
                rrca
                rrca
                rrca
                ld      c,a                     ; tens
                add     a,a
                add     a,a
                add     a,c
                add     a,a                     ; tens*10
                ld      c,a
                ld      a,b
                and     00Fh
                add     a,c
                ld      (brk_row),a
pv_note:
                ; ---- period -> new note ----
                ld      a,(tmp0)
                and     00Fh
                ld      d,a
                ld      a,(tmp1)
                ld      e,a
                or      d
                ret     z                       ; no note on this channel
                ld      a,d
                or      a
                jr      nz,pv_pok
                ld      a,e
                cp      MIN_PERIOD
                jr      nc,pv_pok
                ld      e,MIN_PERIOD
pv_pok:
                ld      a,STEP_K_H              ; step = K / period  (8.8)
                ld      c,STEP_K_M
                ld      b,STEP_K_L
                call    div24                   ; quotient in C(hi):B(lo)
                ld      l,(ix+D_S)
                ld      h,(ix+D_S+1)
                inc     hl
                ld      (hl),b                  ; step fraction
                ld      l,(ix+D_I)
                ld      h,(ix+D_I+1)
                inc     hl
                ld      (hl),c                  ; step integer
                ld      a,(tmp2)                ; tone portamento (3xx / 5xy):
                and     00Fh                    ; new pitch, but the sample
                cp      3                       ; keeps playing - no restart
                ret     z
                cp      5
                ret     z
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      de,ST_INSTR
                add     hl,de
                ld      a,(hl)                  ; remembered instrument
                or      a
                jp      z,silence_voice
                ; fall through

; ---------------------------------------------------------------------------
;  trigger : IX = voice descriptor, A = instrument 1..31
; ---------------------------------------------------------------------------
trigger:
                call    inst_ptr
                ld      e,(iy+0)                ; start
                ld      d,(iy+1)
                ld      c,(iy+2)                ; end limit
                ld      b,(iy+3)
                ld      a,e
                cp      c
                jr      nz,tr_ok
                ld      a,d
                cp      b
                jp      z,silence_voice         ; empty instrument
tr_ok:
                ld      l,(ix+D_P)              ; position = start
                ld      h,(ix+D_P+1)
                inc     hl
                ld      (hl),e
                inc     hl
                ld      (hl),d
                ld      l,(ix+D_F)              ; fraction = 0
                ld      h,(ix+D_F+1)
                inc     hl
                ld      (hl),0
                ld      hl,0                    ; negated end
                or      a
                sbc     hl,bc
                ex      de,hl
                ld      l,(ix+D_N)
                ld      h,(ix+D_N+1)
                inc     hl
                ld      (hl),e
                inc     hl
                ld      (hl),d
                ld      l,(ix+D_ST)             ; state: loop start / length
                ld      h,(ix+D_ST+1)
                ld      a,(iy+4)
                ld      (hl),a
                inc     hl
                ld      a,(iy+5)
                ld      (hl),a
                inc     hl
                ld      a,(iy+6)
                ld      (hl),a
                inc     hl
                ld      a,(iy+7)
                ld      (hl),a
                ld      l,(ix+D_W)              ; choose wrap handler
                ld      h,(ix+D_W+1)
                ld      a,(iy+6)
                or      (iy+7)
                jr      nz,tr_fast              ; looped sample
                ld      (hl),0C3h               ; JP oneshot
                inc     hl
                ld      a,(ix+D_SLOW)
                ld      (hl),a
                inc     hl
                ld      a,(ix+D_SLOW+1)
                ld      (hl),a
                ret
tr_fast:        ld      (hl),011h               ; LD DE,loop_start
                inc     hl
                ld      a,(iy+4)
                ld      (hl),a
                inc     hl
                ld      a,(iy+5)
                ld      (hl),a
                ret

; ---------------------------------------------------------------------------
;  silence_voice : IX = voice descriptor.  Voice reads the silence cell.
; ---------------------------------------------------------------------------
silence_voice:
                ld      l,(ix+D_P)
                ld      h,(ix+D_P+1)
                inc     hl
                ld      (hl),silence & 0FFh
                inc     hl
                ld      (hl),silence >> 8
                ld      l,(ix+D_S)
                ld      h,(ix+D_S+1)
                inc     hl
                ld      (hl),0
                ld      l,(ix+D_I)
                ld      h,(ix+D_I+1)
                inc     hl
                ld      (hl),0
                ld      l,(ix+D_N)
                ld      h,(ix+D_N+1)
                inc     hl
                ld      (hl),SIL_NEND & 0FFh
                inc     hl
                ld      (hl),SIL_NEND >> 8
                ret

; ---------------------------------------------------------------------------
;  div24 : A:C:B (24 bit) / DE (16 bit, < 32768)  ->  quotient in A:C:B
;  Clobbers HL and the shadow B register.
; ---------------------------------------------------------------------------
div24:
                ld      hl,0
                exx
                ld      b,24
                exx
dv_loop:        sla     b
                rl      c
                rla
                adc     hl,hl
                and     a
                sbc     hl,de
                jr      nc,dv_one
                add     hl,de
                jr      dv_next
dv_one:         inc     b
dv_next:        exx
                dec     b
                exx
                jp      nz,dv_loop
                ret

; ---------------------------------------------------------------------------
;  calc_row_samples : row_samples = RATE5*speed / (2*bpm) - GAP
; ---------------------------------------------------------------------------
calc_row_samples:
                ld      a,(bpm)
                ld      e,a
                ld      d,0
                sla     e
                rl      d                       ; DE = 2 * bpm
                push    de
                xor     a
                ld      hl,0
                ld      de,RATE5
                ld      a,(speed)
                ld      b,a
                xor     a
crs1:           add     hl,de
                adc     a,0
                djnz    crs1                    ; A:HL = RATE5 * speed
                ld      c,h
                ld      b,l                     ; A:C:B
                pop     de
                call    div24                   ; C:B = samples per row
                ld      h,c
                ld      l,b
                ld      de,GAP_SAMPLES
                or      a
                sbc     hl,de
                jr      c,crs2
                ld      a,h
                or      l
                jr      nz,crs3
crs2:           ld      hl,1
crs3:           ld      (row_samples),hl
                ld      c,h                     ; tick_len = row_samples / speed
                ld      b,l
                ld      a,(speed)
                ld      e,a
                ld      d,0
                xor     a
                call    div24                  ; A:C:B = 0:rowH:rowL / speed
                ld      h,c                     ; quotient: C = high, B = low
                ld      l,b
                ld      a,h
                or      l
                jr      nz,crs4
                inc     l
crs4:           ld      (tick_len),hl
                ret

; ============================================================================
;  play_row : mix one row as `speed` ticks; volume slides run between ticks
; ============================================================================
play_row:
                ld      hl,(row_samples)
                ld      (rem),hl
                ld      a,(speed)
                ld      (ticks_left),a
pl_tick:        ld      a,(ticks_left)
                cp      1
                jr      z,pl_last
                dec     a
                ld      (ticks_left),a
                ld      bc,(tick_len)
                ld      hl,(rem)
                or      a
                sbc     hl,bc
                ld      (rem),hl
                call    mix_n
                call    do_tick
                jr      pl_tick
pl_last:        ld      bc,(rem)
mix_n:          push    bc                      ; BC = samples to mix
                exx
                pop     bc                      ; -> shadow counter B'C'
                exx
                jp      mix_loop

; ---------------------------------------------------------------------------
;  do_tick : apply per-tick volume slides
; ---------------------------------------------------------------------------
do_tick:
                ld      ix,voice_tab
                ld      b,4
dt_loop:        push    bc
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                push    hl
                ld      de,ST_SLIDE
                add     hl,de
                ld      a,(hl)
                pop     hl
                or      a
                jr      z,dt_next
                ld      c,a                     ; delta (signed)
                ld      de,ST_VOL
                add     hl,de
                ld      l,(hl)                  ; current volume
                ld      h,0
                ld      a,c
                add     a,a
                sbc     a,a
                ld      d,a
                ld      e,c                     ; DE = sign-extended delta
                add     hl,de
                bit     7,h
                jr      z,dt_pos
                ld      hl,0
dt_pos:         ld      a,l
                cp      65
                jr      c,dt_ok
                ld      a,64
dt_ok:          call    set_volume
dt_next:        ld      bc,VD_SIZE
                add     ix,bc
                pop     bc
                djnz    dt_loop
                ret

; ---------------------------------------------------------------------------
;  set_volume : IX = voice descriptor, A = volume 0..64.  Remembers it and
;  points the voice's table lookup at the right 64-byte volume table.
; ---------------------------------------------------------------------------
set_volume:
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      de,ST_VOL
                add     hl,de
                ld      (hl),a
                add     a,2
                rrca
                rrca
                and     03Fh                    ; level = (vol+2)/4 = 0..16
                ld      c,a
                and     3
                rrca
                rrca
                ld      e,a                     ; (level & 3) * 64
                ld      a,c
                srl     a
                srl     a
                add     a,voltab >> 8
                ld      d,a                     ; table page
                ld      l,(ix+D_VO)
                ld      h,(ix+D_VO+1)
                inc     hl
                ld      (hl),e
                ld      l,(ix+D_VD)
                ld      h,(ix+D_VD+1)
                inc     hl
                ld      (hl),d
                ret

; A = instrument 1..31  ->  IY = its instrument table entry
inst_ptr:       dec     a
                ld      l,a
                ld      h,0
                add     hl,hl
                add     hl,hl
                add     hl,hl
                add     hl,hl
                ld      de,inst_table
                add     hl,de
                push    hl
                pop     iy
                ret

; ============================================================================
;  mix_loop : one pass = one DAC sample.  B' = sample counter (BC' 16 bit).
;  Registers: B = running sum, HL = pointer, A/DE = scratch.
;  The operands of the instructions labelled v?p/v?f/v?s/v?i/v?n are
;  self-modified: position, fraction, step (frac,int) and -end address.
; ============================================================================
VOICE           MACRO   vp,vf,vs,vi,vn,vw,vx,vo,vd
                LOCAL   skp
vp:             ld      hl,0                    ; position (address)
                ld      a,(hl)                  ; sample 0..63
vo:             or      0                       ; + volume table (64 byte stride)
                ld      e,a
vd:             ld      d,0                     ; volume table page
                ld      a,(de)                  ; scaled sample
                add     a,b
                ld      b,a                     ; sum += sample
vf:             ld      a,0                     ; fraction
vs:             add     a,0                     ; + step fraction
                ld      (vf+1),a
                ld      a,l
vi:             adc     a,0                     ; + step integer + carry
                ld      l,a
                jr      nc,skp
                inc     h
skp:            ld      (vp+1),hl
vn:             ld      de,0                    ; -end
                add     hl,de
                jp      c,vw                    ; position >= end : wrap
vx:
                ENDM

mix_loop:
                ld      b,0
                VOICE   v0p,v0f,v0s,v0i,v0n,v0w,v0x,v0o,v0d
                VOICE   v1p,v1f,v1s,v1i,v1n,v1w,v1x,v1o,v1d
                VOICE   v2p,v2f,v2s,v2i,v2n,v2w,v2x,v2o,v2d
                VOICE   v3p,v3f,v3s,v3i,v3n,v3w,v3x,v3o,v3d
                ld      a,b
                out     (DAC_PORT),a
                exx
                dec     bc
                ld      a,b
                or      c
                exx
                jp      nz,mix_loop
                ret

; ---------------------------------------------------------------------------
;  Wrap handlers.  HL = (position - end), i.e. how far past the end we are.
;  First instruction is patched by trigger:
;     LD DE,loop_start   -> looped sample (loop >= FAST_MIN_LOOP bytes, which
;                           is longer than any step, so one subtraction is
;                           enough: new position = loop start + overshoot)
;     JP slow            -> one-shot sample finished: voice goes silent
; ---------------------------------------------------------------------------
WRAP            MACRO   vw,vp,vs,vi,vn,vx,slow
vw:             ld      de,0
                add     hl,de
                ld      (vp+1),hl
                jp      vx
slow:           ld      hl,silence              ; one-shot finished: go silent
                ld      (vp+1),hl
                xor     a
                ld      (vs+1),a
                ld      (vi+1),a
                ld      hl,SIL_NEND
                ld      (vn+1),hl
                jp      vx
                ENDM

                WRAP    v0w,v0p,v0s,v0i,v0n,v0x,v0slow
                WRAP    v1w,v1p,v1s,v1i,v1n,v1x,v1slow
                WRAP    v2w,v2p,v2s,v2i,v2n,v2x,v2slow
                WRAP    v3w,v3p,v3s,v3i,v3n,v3x,v3slow

voice_tab:
                DEFW    v0p,v0f,v0s,v0i,v0n,v0w,st0,v0slow,v0o,v0d
                DEFW    v1p,v1f,v1s,v1i,v1n,v1w,st1,v1slow,v1o,v1d
                DEFW    v2p,v2f,v2s,v2i,v2n,v2w,st2,v2slow,v2o,v2d
                DEFW    v3p,v3f,v3s,v3i,v3n,v3w,st3,v3slow,v3o,v3d

; ============================================================================
;  Variables
; ============================================================================
songlen:        DEFB    0
num_instr:      DEFB    0
speed:          DEFB    DEF_SPEED
bpm:            DEFB    DEF_BPM
cur_order:      DEFB    0
cur_row:        DEFB    0
jump_to:        DEFB    0FFh
brk_row:        DEFB    0FFh
dirty:          DEFB    0
tmp0:           DEFB    0
tmp1:           DEFB    0
tmp2:           DEFB    0
tmp3:           DEFB    0
s_vol:          DEFB    0
s_lvl:          DEFB    0
s_u:            DEFB    0
ticks_left:     DEFB    0
p_songlen:      DEFW    0
p_order:        DEFW    0
p_patdata:      DEFW    0
running:        DEFW    0
patptr:         DEFW    0
row_samples:    DEFW    1
tick_len:       DEFW    1
rem:            DEFW    0
st0:            DEFS    7
st1:            DEFS    7
st2:            DEFS    7
st3:            DEFS    7
silence:        DEFB    32                      ; unsigned centre (4 x 32 = 128)
inst_table:     DEFS    31*INST_SIZE            ; start,end limit,loop start,loop len,volume
                DEFS    128
stack_top:
                DEFS    (0-$) & 0FFh            ; align to a 256 byte page
voltab:         DEFS    17*64                   ; volume tables (built at init)

MOD_START:
                INCBIN  "song.mod"
MOD_END:

                END     start
