; ============================================================================
;  VZ200 / VZ300  4-channel Amiga .MOD player   (MODPLAY)
; ============================================================================
;  DAC     : 8-bit resistor DAC on the printer port, I/O port 14 (0Eh)
;  Mixer   : 4 voices, nearest-neighbour, fixed-time loop, ~5.4 kHz output
;  Plays   : 31-instrument "M.K." / "M!K!" / "4CHN" / "FLT4" modules and
;            15-instrument Soundtracker modules (auto-detected)
;  Honours : sample number, period (pitch), loops, sample default volume,
;            Cxx (set volume), Axy / 5xy / 6xy (volume slide, per tick),
;            0xy arpeggio, 3xx / 5xy notes (pitch change WITHOUT restart),
;            Fxx (speed / tempo), Bxx (position jump), Dxx (pattern break)
;  Ignores : vibrato, pitch slides, E-effects, finetune
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

;  ================
;	VZ HEADER
;  ================
				;      ==========================================
 origin equ  $7B00		; <==  ONLY THING NEED TO CHANGE.  $7B00 or $8000
				;      ==========================================

	org		origin - 24

	defb		'VZF1'					; file type ID
	defb		"FILE",0,0,0,0,0,0,0,0,0,0,0,0,   0	; zero padded file name
	defb		$f1					; Binary or BASIC?
	defw		STARTORG				; start address
	
	org		origin
STARTORG:



; ---------------------------------------------------------------------------
;  CALIBRATION  (computed outside the assembler - pasmo is only 16 bit)
; ---------------------------------------------------------------------------
;  Measured in a cycle-accurate Z80 emulator:
;    mix_loop = 658 T per output sample (no wrap), ~669 T on average with loop
;    wraps (~50 T each)  ->  ~5.35 kHz output on a 3.579545 MHz VZ200.
;
;  Decoding a row and the per-tick updates pause the output (the DAC just
;  holds its last value).  Left alone that makes the tempo drag and every
;  sustained note go flat.  So the player tallies the time it spends (see
;  "Row-time accounting") and
;    - shortens the row's last tick by that many samples      (tempo), and
;    - picks one of 5 step tables (ktab) built for increasing overhead (pitch).
;
;  CPU     = 3579545 Hz (VZ200)
;  K(f)    = round(3546895 * 256 * 668.8 / CPU / (1 - f)),  f = 0.8 2.3 3.9 5.5 7.5 %
;            (8.8 fixed-point step = K / period;  3546895 = Amiga PAL clock)
;  RATE5   = 5 * CPU / 668.8      (samples per row = RATE5 * speed / (2 * BPM))
;
;  For a 3546895 Hz machine (VZ300): use 256 * 668.8 / (1 - f) for K
;  (ktab levels 172594 175243 178161 181178 185095; STEP_K = level 0) and
;  RATE5 = 26517.
; ---------------------------------------------------------------------------
STEP_K_H        EQU     002h
STEP_K_M        EQU     09Ch
STEP_K_L        EQU     00Bh
RATE5           EQU     26761
GAP_SAMPLES     EQU     0

DAC_PORT        EQU     14              ; printer data port (decimal 14)
MIN_PERIOD      EQU     100             ; clamp: keeps step < 8 samples/output
FAST_MIN_LOOP   EQU     8               ; shorter loops are played once, not looped
DEF_SPEED       EQU     6

; ---------------------------------------------------------------------------
;  Row-time accounting.  Decoding a row and the per-tick updates pause the
;  output, so the player adds up what it spends (in 1/256 output samples) and
;  shortens the row's last tick by that many samples - this keeps the tempo
;  right however busy the row is.  Costs were measured in the emulator.
; ---------------------------------------------------------------------------
ROW_U           EQU     1889
TB0_U           EQU     111
NOTE_U          EQU     788
DIV_U           EQU     1019
INS_U           EQU     228
CVOL_U          EQU     147
ARP_U           EQU     337
ARP_T           EQU     209
TICKB_U         EQU     191
SLIDE_U         EQU     184
SLIDE_T         EQU     251
F_U             EQU     2136
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
ST_STEP         EQU     7               ; 3 words: base step, +x step, +y step
ST_ARPF         EQU     13              ; non-zero while an arpeggio is running
ST_NOTE         EQU     14              ; index in the 36-note period table, 0FFh = none
STAB_SZ         EQU     72              ; one step table = 36 words
STAB_LEVELS     EQU     5               ; step tables for 5 levels of row overhead

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
                call    build_stab

                ; ---- silence all voices, full volume ----
                ld      ix,voice_tab
                ld      b,4
in_sv:          push    bc
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      de,ST_NOTE
                add     hl,de
                ld      (hl),0FFh
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

; ---------------------------------------------------------------------------
;  build_stab : STAB_LEVELS step tables (8.8 steps for the 36 standard periods).
;  Level n assumes the row spends a larger share of its time decoding (the
;  output holds still meanwhile), so its steps are scaled up to compensate.
; ---------------------------------------------------------------------------
build_stab:
                ld      hl,stab
                ld      (bs_dst),hl
                ld      hl,ktab
                ld      (bs_k),hl
                xor     a
                ld      (s_lvl),a
bs_lvl:         xor     a
                ld      (s_u),a
bs1:            ld      a,(s_u)
                add     a,a
                ld      l,a
                ld      h,ptab >> 8
                ld      e,(hl)
                inc     hl
                ld      d,(hl)                  ; DE = period
                ld      hl,(bs_k)
                ld      a,(hl)
                inc     hl
                ld      c,(hl)
                inc     hl
                ld      b,(hl)                  ; A:C:B = K for this level
                call    div24                   ; C:B = step
                ld      hl,(bs_dst)
                ld      (hl),b
                inc     hl
                ld      (hl),c
                inc     hl
                ld      (bs_dst),hl
                ld      a,(s_u)
                inc     a
                ld      (s_u),a
                cp      36
                jr      nz,bs1
                ld      hl,(bs_k)
                inc     hl
                inc     hl
                inc     hl
                ld      (bs_k),hl
                ld      a,(s_lvl)
                inc     a
                ld      (s_lvl),a
                cp      STAB_LEVELS
                jr      nz,bs_lvl
                ret

; ---------------------------------------------------------------------------
;  select_level : pick the step table from last row's overhead tally (ovh):
;  level n if overhead > n/64 of the row (1.6%, 3.1%, 4.7%, 6.3%)
; ---------------------------------------------------------------------------
select_level:
                ld      hl,(row_samples)
                ld      b,6
slv1:            srl     h
                rr      l
                djnz    slv1
                ld      (s_t1),hl               ; t1 = row / 64
                ld      hl,(ovh)
                ld      e,h
                ld      d,0                     ; DE = overhead in samples
                ld      hl,(s_t1)
                ld      c,0
                ld      b,4
slv2:            push    hl
                or      a
                sbc     hl,de                   ; threshold - overhead
                pop     hl
                jr      nc,slv3                  ; overhead not above threshold
                inc     c
                push    de
                ld      de,(s_t1)
                add     hl,de
                pop     de
                djnz    slv2
slv3:            ld      a,c
                add     a,a
                ld      l,a
                ld      h,0
                ld      de,stab_addr
                add     hl,de
                ld      e,(hl)
                inc     hl
                ld      d,(hl)
                ld      (stab_cur),de
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
                call    select_level
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
                ld      hl,ROW_U
                ld      (ovh),hl
                xor     a
                ld      (dirty),a
                ld      (tick_mask),a
                inc     a
                ld      (vbit),a
                ld      ix,voice_tab
                ld      b,4
pr_loop:        push    bc
                call    process_voice
                ld      hl,vbit
                rlc     (hl)
                ld      bc,VD_SIZE
                add     ix,bc
                pop     bc
                djnz    pr_loop
                ld      a,(dirty)
                or      a
                ret     z
                ld      de,F_U
                call    add_ovh
                jp      calc_row_samples

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
                ld      l,(ix+D_ST)             ; arpeggio: remember whether the
                ld      h,(ix+D_ST+1)           ; previous row had one, clear it
                ld      de,ST_ARPF
                add     hl,de
                ld      a,(hl)
                ld      (tmp_prevarp),a
                ld      (hl),0
                xor     a
                ld      (tmp_arp),a

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
                ld      de,INS_U
                call    add_ovh
pv_fx:
                ; ---- effects: 0 (arpeggio), B, C, D, F, volume slides A/5/6 ----
                ld      a,(tmp2)
                and     00Fh
                jr      nz,pv_fx2
                ld      a,(tmp3)                ; 0xy
                ld      (tmp_arp),a
                jp      pv_note
pv_fx2:         cp      00Ch
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
                ld      a,c
                or      a
                jp      z,pv_note
                call    mark_tick
                ld      de,SLIDE_U
                call    add_ovh
                jp      pv_note
fx_c:           ld      a,(tmp3)
                cp      65
                jr      c,fc1
                ld      a,64
fc1:            call    set_volume
                ld      de,CVOL_U
                call    add_ovh
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
                jr      z,pv_post               ; no note on this channel
                ld      a,d
                or      a
                jr      nz,pv_pok
                ld      a,e
                cp      MIN_PERIOD
                jr      nc,pv_pok
                ld      e,MIN_PERIOD
pv_pok:
                call    find_note               ; standard note? A = index/0FFh
                ld      (tmp_note),a
                cp      0FFh
                jr      z,pv_div
                add     a,a                     ; table lookup: step = stab[idx]
                ld      e,a
                ld      d,0
                ld      hl,(stab_cur)
                add     hl,de
                ld      b,(hl)
                inc     hl
                ld      c,(hl)
                jr      pv_have
pv_div:         ld      a,STEP_K_H              ; odd period: step = K / period
                ld      c,STEP_K_M
                ld      b,STEP_K_L
                call    div24                   ; quotient in C(hi):B(lo)
                ld      de,DIV_U
                call    add_ovh
pv_have:
                ld      de,NOTE_U
                call    add_ovh
                ld      l,(ix+D_ST)             ; remember the base step
                ld      h,(ix+D_ST+1)
                ld      de,ST_STEP
                add     hl,de
                ld      (hl),b
                inc     hl
                ld      (hl),c
                inc     hl
                inc     hl
                inc     hl
                inc     hl
                inc     hl
                inc     hl                      ; -> ST_NOTE
                ld      a,(tmp_note)
                ld      (hl),a
                call    patch_step
                ld      a,(tmp2)                ; tone portamento (3xx / 5xy):
                and     00Fh                    ; new pitch, but the sample
                cp      3                       ; keeps playing - no restart
                jr      z,pv_post
                cp      5
                jr      z,pv_post
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      de,ST_INSTR
                add     hl,de
                ld      a,(hl)                  ; remembered instrument
                or      a
                jr      z,pv_sil
                call    trigger
                jr      pv_post
pv_sil:         call    silence_voice

; ---- arpeggio set-up / restore (runs after the note, if any) ----
pv_post:
                ld      a,(tmp_prevarp)
                ld      b,a
                ld      a,(tmp_arp)
                or      b
                ret     z                       ; no arpeggio now or before
                ld      l,(ix+D_ST)             ; tick 0 always plays the base
                ld      h,(ix+D_ST+1)           ; pitch
                ld      de,ST_STEP
                add     hl,de
                ld      b,(hl)
                inc     hl
                ld      c,(hl)
                call    patch_step
                ld      a,(tmp_arp)
                or      a
                ret     z
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      de,ST_STEP
                add     hl,de
                push    hl
                pop     iy                      ; IY -> base, +x, +y, flag
                ld      a,(iy+7)                ; note index (ST_NOTE)
                cp      0FFh
                jr      z,pa_ratio
                ld      c,a                     ; standard note: walk the table
                ld      a,(tmp_arp)
                rrca
                rrca
                rrca
                rrca
                and     00Fh                    ; x semitones
                call    stab_get
                ld      (iy+2),l
                ld      (iy+3),h
                ld      a,(tmp_arp)
                and     00Fh                    ; y semitones
                call    stab_get
                ld      (iy+4),l
                ld      (iy+5),h
                jr      pa_done
pa_ratio:       ld      e,(iy+0)                ; odd period: scale the step
                ld      d,(iy+1)
                ld      a,(tmp_arp)
                rrca
                rrca
                rrca
                rrca
                and     00Fh
                call    ratio_step
                ld      (iy+2),l
                ld      (iy+3),h
                ld      a,(tmp_arp)
                and     00Fh
                call    ratio_step
                ld      (iy+4),l
                ld      (iy+5),h
pa_done:
                ld      (iy+6),1                ; arpeggio running
                call    mark_tick
                ld      de,ARP_U
                jp      add_ovh

; DE = cost in 1/256 samples -> added to the row's overhead tally
add_ovh:        ld      hl,(ovh)
                add     hl,de
                ld      (ovh),hl
                ret

; this voice needs per-tick work (slide / arpeggio)
mark_tick:      ld      a,(vbit)
                ld      hl,tick_mask
                or      (hl)
                ld      (hl),a
                ret

; A = semitones, C = note index  ->  HL = stab[min(C+A,35)]
stab_get:
                add     a,c
                cp      36
                jr      c,sg1
                ld      a,35
sg1:            add     a,a
                ld      e,a
                ld      d,0
                ld      hl,(stab_cur)
                add     hl,de
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a
                ret

; DE = period -> A = index in ptab (0..35), or 0FFh.  Binary search on the
; descending table.  Preserves DE.
find_note:
                ld      c,0                     ; lo
                ld      b,35                    ; hi
fn1:            ld      a,b
                cp      c
                jr      c,fn_none               ; hi < lo
                add     a,c
                srl     a                       ; mid
                ld      (fn_mid),a
                add     a,a
                ld      l,a
                ld      h,ptab >> 8
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a                     ; HL = ptab[mid]
                or      a
                sbc     hl,de
                jr      z,fn_found
                ld      a,(fn_mid)
                jr      c,fn_above              ; entry < period -> go lower
                inc     a                       ; entry > period -> go higher
                ld      c,a
                jr      fn1
fn_above:       or      a
                jr      z,fn_none
                dec     a
                ld      b,a
                jr      fn1
fn_found:       ld      a,(fn_mid)
                ret
fn_none:        ld      a,0FFh
                ret

; B = step fraction, C = step integer  ->  patch the voice's mixer operands
patch_step:
                ld      l,(ix+D_S)
                ld      h,(ix+D_S+1)
                inc     hl
                ld      (hl),b
                ld      l,(ix+D_I)
                ld      h,(ix+D_I+1)
                inc     hl
                ld      (hl),c
                ret

; A = semitones (0..15), DE = base step  ->  HL = step * 2^(A/12), capped
ratio_step:
                push    de
                add     a,a
                ld      c,a
                ld      b,0
                ld      hl,ratio_tab
                add     hl,bc
                ld      c,(hl)
                inc     hl
                ld      b,(hl)                  ; BC = ratio (8.8)
                call    mul16                   ; A:H:L = DE * BC
                cp      010h
                jr      c,rs_ok
                ld      hl,00FFFh               ; cap at 15.99 samples/step
                pop     de
                ret
rs_ok:          ld      l,h                     ; (product >> 8)
                ld      h,a
                pop     de
                ret

; DE * BC (16 x 16 -> 24 bit) in A:H:L.  Clobbers BC and the shadow B.
mul16:
                ld      hl,0
                xor     a
                exx
                ld      b,16
                exx
m16:            add     hl,hl
                rla
                sla     c
                rl      b
                jr      nc,m16n
                add     hl,de
                adc     a,0
m16n:           exx
                dec     b
                exx
                jp      nz,m16
                ret

ratio_tab:      ; 256 * 2^(n/12), n = 0..15
                DEFW    256,271,287,304,323,342,362,384
                DEFW    406,431,456,483,512,542,575,609

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
                ld      a,(speed)               ; every tick boundary costs a bit
                dec     a
                jr      z,pl_nb
                ld      b,a
                ld      hl,(ovh)
                ld      de,TB0_U
pl_ab:          add     hl,de
                djnz    pl_ab
                ld      (ovh),hl
pl_nb:          ld      hl,(row_samples)
                ld      (rem),hl
                ld      a,(speed)
                ld      (ticks_left),a
                xor     a
                ld      (tick_no),a
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
                ld      a,(tick_no)
                inc     a
                ld      (tick_no),a
                call    do_tick
                jr      pl_tick
pl_last:        ld      hl,(ovh)                ; last tick absorbs the row's
                ld      l,h                     ; overhead (whole samples)
                ld      h,0
                ld      de,(rem)
                ex      de,hl
                or      a
                sbc     hl,de
                jr      c,pl_min
                ld      a,h
                or      l
                jr      nz,pl_go
pl_min:         ld      hl,1
pl_go:          ld      b,h
                ld      c,l
mix_n:          push    bc                      ; BC = samples to mix
                exx
                pop     bc                      ; -> shadow counter B'C'
                exx
                jp      mix_loop

; ---------------------------------------------------------------------------
;  do_tick : per-tick updates (tick_no = 1,2,..): volume slide, arpeggio
; ---------------------------------------------------------------------------
do_tick:
                ld      a,(tick_mask)
                or      a
                ret     z                       ; nothing to do this row
                ld      (tmask_w),a
                ld      de,TICKB_U
                call    add_ovh
                ld      ix,voice_tab
                ld      b,4
dt_loop:        push    bc
                ld      a,(tmask_w)
                rrca
                ld      (tmask_w),a
                call    c,tick_voice
                ld      bc,VD_SIZE
                add     ix,bc
                pop     bc
                djnz    dt_loop
                ret

tick_voice:
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                push    hl
                ld      de,ST_SLIDE
                add     hl,de
                ld      a,(hl)
                pop     hl
                or      a
                jr      z,tv_arp
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
                jr      z,tv_pos
                ld      hl,0
tv_pos:         ld      a,l
                cp      65
                jr      c,tv_ok
                ld      a,64
tv_ok:          call    set_volume
                ld      de,SLIDE_T
                call    add_ovh
tv_arp:         ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      de,ST_ARPF
                add     hl,de
                ld      a,(hl)
                or      a
                ret     z                       ; no arpeggio on this voice
                ld      a,(tick_no)             ; tick 0 base, 1 +x, 2 +y, 3 base..
tv_m3:          sub     3
                jr      nc,tv_m3
                add     a,3
                add     a,a
                ld      e,a
                ld      d,0
                ld      l,(ix+D_ST)
                ld      h,(ix+D_ST+1)
                ld      bc,ST_STEP
                add     hl,bc
                add     hl,de
                ld      b,(hl)
                inc     hl
                ld      c,(hl)
                call    patch_step
                ld      de,ARP_T
                jp      add_ovh

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
tick_no:        DEFB    0
s_t1:          DEFW    0
bs_dst:         DEFW    0
bs_k:           DEFW    0
tmp_note:       DEFB    0FFh
fn_mid:         DEFB    0
tick_mask:      DEFB    0
tmask_w:        DEFB    0
vbit:           DEFB    1
tmp_arp:        DEFB    0
tmp_prevarp:    DEFB    0
p_songlen:      DEFW    0
p_order:        DEFW    0
p_patdata:      DEFW    0
running:        DEFW    0
patptr:         DEFW    0
row_samples:    DEFW    1
tick_len:       DEFW    1
rem:            DEFW    0
ovh:            DEFW    0
st0:            DEFS    15
st1:            DEFS    15
st2:            DEFS    15
st3:            DEFS    15
silence:        DEFB    32                      ; unsigned centre (4 x 32 = 128)
inst_table:     DEFS    31*INST_SIZE            ; start,end limit,loop start,loop len,volume
                DEFS    128
stack_top:
                DEFS    (0-$) & 0FFh            ; align to a 256 byte page
ptab:           ; the 36 standard Amiga periods (finetune 0), C-1 .. B-3
                DEFW    856,808,762,720,678,640,604,570,538,508,480,453
                DEFW    428,404,381,360,339,320,302,285,269,254,240,226
                DEFW    214,202,190,180,170,160,151,143,135,127,120,113
stab:           DEFS    STAB_SZ*STAB_LEVELS     ; 8.8 steps per level (built at init)
stab_addr:      DEFW    stab,stab+STAB_SZ,stab+2*STAB_SZ,stab+3*STAB_SZ,stab+4*STAB_SZ
stab_cur:       DEFW    stab
ktab:           ; step constants K for each level (24 bit, high byte first)
                DEFB    002h,09Ch,00Bh        ; level 0: 171019
                DEFB    002h,0A6h,04Dh        ; level 1: 173645
                DEFB    002h,0B1h,098h        ; level 2: 176536
                DEFB    002h,0BDh,045h        ; level 3: 179525
                DEFB    002h,0CCh,06Fh        ; level 4: 183407
                DEFS    (0-$) & 0FFh
voltab:         DEFS    17*64                   ; volume tables (built at init)

MOD_START:
                INCBIN  "song.mod"
MOD_END:

                END     start
