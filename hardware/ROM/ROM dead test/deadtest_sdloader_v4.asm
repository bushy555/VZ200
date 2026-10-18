;
; Copyright (C) 2024 Rhys Weatherley
;
; Permission is hereby granted, free of charge, to any person obtaining a
; copy of this software and associated documentation files (the "Software"),
; to deal in the Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute, sublicense,
; and/or sell copies of the Software, and to permit persons to whom the
; Software is furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included
; in all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
; DEALINGS IN THE SOFTWARE.
;
;
; VZ200/VZ300 DEAD TEST  -  cartridge / SD-loader EEPROM version
;
; Based on "deadtest.asm" by Rhys Weatherley; original licence reproduced above.
; v3: VSYNC frequency measured by polling; VZ200/VZ300 detection by two probes.
; v4: memory layout detection.  Port $37 bits 1+2 are toggled to find out which
;     2K pages between $7800 and $FFFF are fixed RAM (internal: 6116 on a
;     VZ200) and which are bank switched (BennVenn SD loader SRAM), and how
;     many independent banks there are.  Every bank state is then tested.
;
; Ported to run as a cartridge image at $4000, i.e. burned into the 28C64
; (EEPROM) of the BennVenn SD loader in place of VZDOS.
;
;   * The VZ system ROM stays in place at $0000-$3FFF.  After its own start-up
;     it looks for the signature  AA 55 E7 18  at $4000 and jumps to $4004.
;   * No ROM routines are used.  Everything (screen, beep, keyboard, stack,
;     scratch) lives in video RAM exactly like the original.
;   * The VSYNC interrupt test hooks the RAM vector at $787D (the VZ ROM's
;     RST 38H goes there).  If that RAM cannot hold the hook, the test is
;     skipped and the screen keeps showing ???.
;   * New: the loader's RAM map is detected the same way VZDOS does it
;     (OUT (3AH),1 and probe $9100; if nothing answers -> OUT (3AH),0), so
;     the whole $7800-$FFFF range is tested on both VZ200 and VZ300.
;   * CTRL+BREAK restarts the test (soft restart at $4004).
;
; Assemble:  z80asm -o deadtest_sdloader.bin deadtest_sdloader.asm
; (output is padded to 8192 bytes with $FF for the 28C64)
;


    org 0x4000

;
; Address of the screen buffer in RAM.
;
vz_screen: equ 0x7000

;
; Scratch area for global variables (second half of video RAM).
;
scratch:             equ 0x7200
key_name:            equ scratch
highest_good:        equ scratch+64
ram_size:            equ scratch+64+8
interrupt_counter:   equ scratch+64+10
page_class:         equ scratch+96      ; 17 bytes: banks found per 2K page
fixed_pages:        equ scratch+120
banked_pages:       equ scratch+121
bank_count:         equ scratch+122
machine:            equ scratch+123     ; 0 = VZ200, 1 = VZ300
bank_result:        equ scratch+124     ; 0 = not tested, 1 = OK, 2 = BAD
pd_started:         equ scratch+125
cl_left:            equ scratch+126
cl_cnt:             equ scratch+127

;
; Cartridge signature checked by the VZ system ROM.
;
    defb 0xaa,0x55,0xe7,0x18

;
; Entry point ($4004).  Also the target for "restart test".
;
entry:
    di                  ; Disable interrupts until we are ready for them.
    xor a
    ld  (0x6800),a      ; Set the video to text mode with a green background.
    jp  start

;
; IRQ handler for the VSYNC interrupt.  Reached via the VZ ROM's RST 38H
; and the RAM vector at $787D.
;
vsync_isr:
;
; Save the registers we will be using.
;
    push af
    push de
    push hl
;
; Count the number of interrupts that we have seen.
;
    ld  hl,(interrupt_counter)
    inc hl
    ld  (interrupt_counter),hl
;
; The interrupt is caused by VSYNC which is now low.  We need to wait
; for it to go high again before returning.  Otherwise we immediately
; end up back here.
;
    ld  hl,0x68fe
    ld  de,0
wait_for_vsync_high:
    dec de
    ld  a,d
    or  e
    jr  z,vsync_int_fail
    bit 7,(hl)
    jr  z,wait_for_vsync_high
;
; Pop the saved registers and return from the interrupt.
;
    pop hl
    pop de
    pop af
    ei
    reti
;
; We timed out waiting for VSYNC to go high again.  Disable interrupts
; and return with an error state in "interrupt_counter".
;
vsync_int_fail:
    ld  hl,0xffff
    ld  (interrupt_counter),hl
    pop hl
    pop de
    pop af
    di
    reti


; Start of the dead test.
;
start:
;
; Set the stack to start at the end of video RAM.  We haven't tested
; program RAM yet, so we cannot use it for stack or scratch.
;
    ld  sp,0x7800
;
; Copy the initial test screen from ROM to video RAM.  We also fill up the
; rest of video RAM so that we can check if we can read it back later.
;
    ld  hl,test_screen
    ld  de,vz_screen
    ld  ix,vz_screen+2047
    ld  bc,0x0200
copy_test_screen:
    ld  a,(hl)
    cp  0x80
    jr  nc,copy_test_screen_2
    and 0x3f     ; Convert ASCII into inverse characters for the screen.
copy_test_screen_2:
    ld  (de),a
    ld  (ix+0),a
    inc hl
    inc de
    dec ix
    dec bc
    ld  a,b
    or  c
    jr  nz,copy_test_screen
    ld  bc,0x0200
copy_test_screen_3:
    ld  a,(hl)
    ld  (de),a
    ld  (ix+0),a
    inc hl
    inc de
    dec ix
    dec bc
    ld  a,b
    or  c
    jr  nz,copy_test_screen_3

;
; Beep the speaker.  If nothing is displayed on the screen, then this
; will at least tell us that code is running out of ROM.
;
; This code is based on the sound output routine in the VZ ROM's at 0x345c.
;
    ld  hl,259          ; Pitch (middle C).
    ld  de,87           ; Duration (1/3rd of a second).
beep_loop:
    ld  a,0x01           ; Speaker A on, Speaker B off.
    ld  (0x6800),a
    ld  b,h
    ld  c,l
click_delay_1:
    dec bc
    ld  a,b
    or  c
    jr  nz,click_delay_1
;
    ld  a,0x20           ; Speaker B on, Speaker A off.
    ld  (0x6800),a
    ld  b,h
    ld  c,l
click_delay_2:
    dec bc
    ld  a,b
    or  c
    jr  nz,click_delay_2
    dec de
    ld  a,d
    or  e
    jr  nz,beep_loop
;
; Make sure both sides of the speaker are off at the end.
;
    ld  a,0
    ld  (0x6800),a

;
; Test that we can read back what we just put in video RAM.
;
    ld  de,test_screen
    ld  hl,vz_screen
    ld  ix,vz_screen+2047
    ld  bc,0x0200
compare_test_screen:
    ld  a,(de)
    cp  0x80
    jr  nc,compare_test_screen_2
    and 0x3f     ; Convert ASCII into inverse characters for the screen.
compare_test_screen_2:
    cp  (hl)
    jr  nz,video_ram_failed
    cp  (ix+0)
    jr  nz,video_ram_failed
    inc hl
    inc de
    dec ix
    dec bc
    ld  a,b
    or  c
    jr  nz,compare_test_screen
    ld  bc,0x0200
compare_test_screen_3:
    ld  a,(de)
    cp  (hl)
    jr  nz,video_ram_failed
    cp  (ix+0)
    jr  nz,video_ram_failed
    inc hl
    inc de
    dec ix
    dec bc
    ld  a,b
    or  c
    jr  nz,compare_test_screen_3
    ld  ix,vz_screen+3*32+27
    ld  (ix+0),0x20        ; ' '
    ld  (ix+1),0x0f      ; 'O'
    ld  (ix+2),0x0b      ; 'K'
    jp  video_ram_done
;
video_ram_failed:
;
; Fill the text screen buffer in video RAM with the character set,
; forwards in the top half of the screen and in reverse in the bottom
; half of the screen.  Hopefully this will reveal which bytes or address
; lines are bad.
;
; To be done in the future: Maybe switch to graphics mode so that any
; bad blocks in the rest of video RAM are also visible on-screen.
;
    ld  hl,vz_screen
    ld  ix,vz_screen+511
    ld  a,0
video_ram_fill:
    ld  (hl),a
    ld  (ix+0),a
    inc hl
    dec ix
    inc a
    jr  nz,video_ram_fill
;
; Write "VRAM BAD" into the top-left corner of the screen.
;
    ld  ix,vz_screen
    ld  (ix+0),0x56        ; 'V'
    ld  (ix+1),0x52      ; 'R'
    ld  (ix+2),0x41      ; 'A'
    ld  (ix+3),0x4d      ; 'M'
    ld  (ix+4),0x60      ; ' '
    ld  (ix+5),0x42      ; 'B'
    ld  (ix+6),0x41      ; 'A'
    ld  (ix+7),0x44      ; 'D'
    ld  (ix+8),0x60      ; ' '
;
; Switch back and forth between the green and orange background colors to
; indicate that something is wrong with VRAM.  Beeping whenever the screen
; has an orange background color.  No other tests are possible.
;
video_blink_background:
    ld  hl,259          ; Pitch (middle C).
    ld  de,87           ; Duration (1/3rd of a second).
vram_fail1_beep_loop:
    ld  a,0x11           ; Speaker A on, Speaker B off, orange background.
    ld  (0x6800),a
    ld  b,h
    ld  c,l
vram_fail1_click_delay_1:
    dec bc
    ld  a,b
    or  c
    jr  nz,vram_fail1_click_delay_1
;
    ld  a,0x30           ; Speaker B on, Speaker A off, orange background.
    ld  (0x6800),a
    ld  b,h
    ld  c,l
vram_fail1_click_delay_2:
    dec bc
    ld  a,b
    or  c
    jr  nz,vram_fail1_click_delay_2
    dec de
    ld  a,d
    or  e
    jr  nz,vram_fail1_beep_loop
;
; Switch to a green background.  We do the same beep loop but this time
; we don't actually beep the speaker.  This keeps the same timing as above.
;
    ld  hl,259          ; Pitch (middle C).
    ld  de,87           ; Duration (1/3rd of a second).
vram_fail2_beep_loop:
    ld  a,0x00           ; Speaker A off, Speaker B off, green background.
    ld  (0x6800),a
    ld  b,h
    ld  c,l
vram_fail2_click_delay_1:
    dec bc
    ld  a,b
    or  c
    jr  nz,vram_fail2_click_delay_1
;
    ld  a,0x00           ; Speaker B off, Speaker A off, green background.
    ld  (0x6800),a
    ld  b,h
    ld  c,l
vram_fail2_click_delay_2:
    dec bc
    ld  a,b
    or  c
    jr  nz,vram_fail2_click_delay_2
    dec de
    ld  a,d
    or  e
    jr  nz,vram_fail2_beep_loop
;
; No more tests are possible if video RAM is bad.  Go around again.
;
    jr  video_blink_background
;
video_ram_done:

;
; Zero all of video RAM except the first 512 bytes for the text screen buffer.
; This clears our stack space and scratch memory.
;
    ld  hl,vz_screen+512
    ld  de,vz_screen+513
    ld  bc,0x05ff
    ld  (hl),0
    ldir

;
; Check that the VSYNC signal is being delivered regularly via I/O lines.
;
    ld  hl,0x68fe
    ld  b,5                 ; Look for 5 pulses and then stop.
wait_for_vsync:
    ld  de,0
wait_for_vsync_1:           ; Wait for a rising edge.
    dec de
    ld  a,d
    or  e
    jr  z,wait_for_vsync_timeout
    bit 7,(hl)
    jr  z,wait_for_vsync_1
    ld  de,0
wait_for_vsync_2:           ; Wait for a falling edge.
    dec de
    ld  a,d
    or  e
    jr  z,wait_for_vsync_timeout
    bit 7,(hl)
    jr  nz,wait_for_vsync_2
    djnz wait_for_vsync
;
; We appear to have regular pulses on the VSYNC line.
;
    ld  ix,vz_screen+4*32+27
    ld  (ix+0),0x20        ; ' '
    ld  (ix+1),0x0f      ; 'O'
    ld  (ix+2),0x0b      ; 'K'
    jr  test_vsync_int

;
; If we timeout waiting for VSYNC to transition, then we don't have VSYNC.
; Show both VSYNC POLL and VSYNC INTERRUPT as BAD.
;
wait_for_vsync_timeout:
    ld  ix,vz_screen+4*32+27
    ld  (ix+0),0x42        ; 'B'
    ld  (ix+1),0x41      ; 'A'
    ld  (ix+2),0x44      ; 'D'
    ld  hl,s_f_bad
    call set_freq_text
    ld  hl,s_i_bad
    call set_irq_text
    jp  test_ram

;

;
; Check that the VSYNC signal is being delivered via the IRQ vector.
;
test_vsync_int:
    ld  hl,0
    ld  (interrupt_counter),hl
;
; Hook our handler into the RAM interrupt vector at $787D (the VZ ROM's
; RST 38H jumps there) and read it back.  If the vector cannot be stored,
; skip this test and leave the result as ??? on the screen.
;
    ld  a,0xc3              ; JP opcode
    ld  (0x787d),a
    ld  hl,vsync_isr
    ld  (0x787e),hl
    ld  a,(0x787d)
    cp  0xc3
    jp  nz,hook_failed
    ld  hl,(0x787e)
    ld  de,vsync_isr
    or  a
    sbc hl,de
    jp  nz,hook_failed
;
; Enable interrupt mode 1 and turn on interrupts for VSYNC.
;
    im  1
    ei
;
; Wait for some time for interrupts to arrive.  If none arrive, or they
; are too far apart, then VSYNC interrupts are not working correctly.
;
    ld  b,2
wait_for_vsync_int_1:
    ld  de,0
wait_for_vsync_int_2:
    dec de
    ld  a,d
    or  e
    jr  nz,wait_for_vsync_int_2
    djnz wait_for_vsync_int_1
;
; Disable interrupts - we don't need them for the remaining tests.
;
    di
;
; So, what happened?
;
    ld  hl,(interrupt_counter)
    ld  a,h
    or  l
    jr  z,vsync_int_bad     ; No interrupts occurred at all.
    ld  a,h
    cp  0xff
    jr  z,vsync_int_bad     ; Interrupt pulses were too wide for a VSYNC signal.
    ld  hl,s_i_ok
    jr  irq_text_set
vsync_int_bad:
    ld  hl,s_i_bad
    jr  irq_text_set
;
; The RAM vector at $787D could not be written/read back: report it.
;
hook_failed:
    ld  hl,s_i_nohook
irq_text_set:
    call set_irq_text
;
; Measure the VSYNC frequency by polling bit 7 of $68FE (no interrupts, so
; no dependence on how long the system ROM's IRQ path takes).  One frame is
; measured from a falling edge to the next falling edge with a 45 T-state
; loop: 50Hz = about 1590 loops, 60Hz = about 1325 loops.
;
measure_freq:
    ld  hl,0x68fe
    ld  de,0
mf_align1:                  ; Leave the low phase if we are in it.
    dec de
    ld  a,d
    or  e
    jr  z,mf_fail
    bit 7,(hl)
    jr  z,mf_align1
    ld  de,0
mf_align2:                  ; Wait for the falling edge.
    dec de
    ld  a,d
    or  e
    jr  z,mf_fail
    bit 7,(hl)
    jr  nz,mf_align2
    ld  bc,0
mf_low:                     ; Count the low phase ...
    inc bc
    ld  a,b
    or  c
    jr  z,mf_fail
    bit 7,(hl)
    jr  z,mf_low
mf_high:                    ; ... and the high phase up to the next falling edge.
    inc bc
    ld  a,b
    or  c
    jr  z,mf_fail
    bit 7,(hl)
    jr  nz,mf_high
    push bc
    pop hl                  ; HL = loops per frame
    ld  de,1150
    or  a
    sbc hl,de
    jr  c,mf_fail           ; Faster than 60Hz: not plausible.
    add hl,de
    ld  de,1458
    or  a
    sbc hl,de
    jr  c,mf_60hz           ; Below 1458 loops: 60Hz.
    ld  de,343
    or  a
    sbc hl,de
    jr  nc,mf_fail          ; 1801 loops or more: slower than 50Hz.
    ld  hl,s_f_50
    jr  mf_show
mf_60hz:
    ld  hl,s_f_60
    jr  mf_show
mf_fail:
    ld  hl,s_f_fail
mf_show:
    call set_freq_text
    jp  test_ram

set_freq_text:
    ld  de,vz_screen+5*32+13
    jr  put_str
set_irq_text:
    ld  de,vz_screen+5*32+22
;
; Copy the zero-terminated ASCII string at HL to the screen at DE.
;
put_str:
    ld  a,(hl)
    or  a
    ret z
    and 0x3f
    ld  (de),a
    inc hl
    inc de
    jr  put_str

;
; Print HL (0..999) as decimal without leading zeros at DE (DE advances).
;
put_dec:
    xor a
    ld  (pd_started),a
    ld  bc,-100
    call pd_digit
    ld  bc,-10
    call pd_digit
    ld  a,l
    add a,0x30
    ld  (de),a
    inc de
    ret
pd_digit:
    ld  a,0x2f
pd_loop:
    inc a
    add hl,bc
    jr  c,pd_loop
    sbc hl,bc
    cp  0x30
    jr  nz,pd_emit
    ld  c,a
    ld  a,(pd_started)
    or  a
    ret z                   ; suppress leading zero
    ld  a,c
pd_emit:
    ld  (de),a
    inc de
    ld  a,1
    ld  (pd_started),a
    ret

s_int200:   defb "VZ200 INTERNAL RAM ",0
s_int300:   defb "VZ300 INTERNAL RAM ",0
s_fixed:    defb "FIXED RAM ",0
s_nobank_int: defb "RAM FIXED, NO BANKING SEEN",0
s_loader:   defb "LOADER RAM ",0
s_nobank:   defb "NO LOADER BANKING FOUND",0
s_k:        defb "K",0
s_k_sp:     defb "K ",0
s_kx:       defb "K X",0
s_eq:       defb " = ",0
s_x6116:    defb "X6116",0
s_4116:     defb "4116",0
s_bt_none:  defb "BANK TEST: NOT RUN",0
s_bt_ok:    defb "BANK TEST: ALL BANKS OK",0
s_bt_bad:   defb "BANK TEST: BAD",0
s_f_50:     defb "50HZ",0
s_f_60:     defb "60HZ",0
s_f_fail:   defb "??HZ",0
s_f_bad:    defb "BAD ",0
s_i_ok:     defb "OK    ",0
s_i_bad:    defb "BAD   ",0
s_i_nohook: defb "NOHOOK",0

;
; Test the RAM and figure out how much RAM we have.
;
; First find out how the SD loader maps its SRAM (same probe as VZDOS):
; port 3AH = 1 selects the VZ300 map (loader RAM from $B800, the machine
; has its own RAM up to $B7FF), port 3AH = 0 the VZ200 map (loader RAM from
; $9000).  We try the VZ300 map and probe $9100: if it does not behave like
; RAM, we are on a VZ200 and switch back to the VZ200 map.
;
test_ram:
;
; Probe whether $9100 is RAM with the loader port 3AH set to 1 and to 0.
; On a VZ200 (6K internal RAM, 6116 chips, up to $8FFF) the loader can supply
; that RAM in only one of the two settings.  If $9100 is RAM in BOTH settings
; then the machine has its own RAM there (VZ300, 4116 DRAM).
; B = result for 3AH=1, C = result for 3AH=0.
;
    ld  a,1
    out (0x3a),a
    call probe_9100
    ld  b,a
    xor a
    out (0x3a),a
    call probe_9100
    ld  c,a
;
; Leave the loader in a setting that provides RAM: 1 unless only 0 works.
;
    ld  a,1
    out (0x3a),a            ; VZDOS' own choice when RAM answers with 1
    ld  a,b
    or  a
    jr  nz,map_selected
    xor a
    out (0x3a),a            ; only 0 worked (or nothing did): use 0
map_selected:
    ld  a,b
    and c
    ld  (machine),a         ; 1 = $9100 is RAM in both settings
;
; Work out which RAM is fixed and which is bank switched.
; Port $37 selects the SRAM banks of the SD loader (bits 1 and 2).
;
    ld  c,0x37
    ld  e,0
    call classify_banks
    jp  map_done

;
; Returns A=1 if $9100/$9101 behave like RAM, else A=0.
;
probe_9100:
    ld  hl,0x9100
    ld  (hl),0x55
    inc hl
    ld  (hl),0xaa
    dec hl
    ld  a,(hl)
    cp  0x55
    jr  nz,probe_no
    inc hl
    ld  a,(hl)
    cp  0xaa
    jr  nz,probe_no
    ld  (hl),0x55
    dec hl
    ld  (hl),0xaa
    ld  a,(hl)
    cp  0xaa
    jr  nz,probe_no
    inc hl
    ld  a,(hl)
    cp  0x55
    jr  nz,probe_no
    ld  a,1
    ret
probe_no:
    xor a
    ret

map_done:
;
; Fill RAM between $7800 and $FFFF with pseudorandom data.
;
; Data is copied from "test_data" 256 bytes at a time.  For each new page,
; the starting position in "test_data" is shifted up by 1.  This seeks to
; avoid correlation between the same bytes on different pages in case there
; is address aliasing going on.
;
    call fill_ram

;
; Read back the data and compare with the original.  We do this bit by bit
; so that we can figure out which bits are working and which ones are not.
; D = bit number, E = bit mask.  highest_good[bit] receives the number of
; good pages starting at $7800; ram_size the maximum over all bits.
;
    ld  hl,0
    ld  (ram_size),hl
    ld  d,0
    ld  e,1
test_bit_loop:
    call check_bit          ; A = number of good 256-byte pages for mask E.
    ld  c,a
    ld  hl,highest_good
    ld  a,l
    add a,d
    ld  l,a                 ; highest_good+bit (no carry: low byte is $40).
    ld  (hl),c
    ld  a,(ram_size)
    cp  c
    jr  nc,test_bit_next
    ld  a,c
    ld  (ram_size),a
test_bit_next:
    inc d
    sla e
    jr  nz,test_bit_loop
    jp  report_ram

;
; Compare RAM $7800-$FFFF against the test data for the single bit(s) in E.
; Returns A = number of good pages before the first mismatch ($88 = all).
; Preserves D and E.
;
check_bit:
    ld  ix,0x7800
    ld  hl,test_data
    ld  c,0x78
check_next_page:
    push hl
    ld  b,0
check_page:
    ld  a,(ix+0)
    xor (hl)
    and e
    jr  nz,check_failed
    inc hl
    inc ix
    djnz check_page
    pop hl
    inc hl
    inc c
    jr  nz,check_next_page
    jr  check_done          ; C wrapped to 0: everything is good.
check_failed:
    pop hl
;
; C is now the highest page that is good on this bit.  If C is still
; $78 then the bit is completely dead across the entire memory range.
;
check_done:
    ld  a,c
    sub 0x78
    ret

;
; Fill RAM from $7800 to $FFFF with the test data.  Clobbers A,B,C,HL,IX.
;
fill_ram:
    ld  ix,0x7800
    ld  hl,test_data
    ld  c,0x78
fill_next_page:
    push hl
    ld  b,0
fill_page:
    ld  a,(hl)
    ld  (ix+0),a
    inc hl
    inc ix
    djnz fill_page
    pop hl
    inc hl                  ; Shift the data by one for the next page.
    inc c
    jr  nz,fill_next_page
    ret

;
; Find out which 2K pages between $7800 and $FFFF are real RAM and in how
; many independent banks.  In: C = port, E = base value.  The four bank
; states are base+0, +2, +4, +6 (port bits 1 and 2).
; Result: page_class[0..16] = number of independent memories seen (0 = no
; RAM, 1 = one memory (fixed), 2..4 = bank switched).
;
classify_banks:
    ld  ix,page_class
    ld  hl,0x7900           ; probe 256 bytes into each 2K page
    ld  a,17
    ld  (cl_left),a
cl_page:
    ld  d,0
    ld  b,0xa5
cl_write:
    ld  a,d
    add a,a
    or  e
    out (c),a
    ld  (hl),b
    ld  a,b
    add a,0x3b
    ld  b,a
    inc d
    ld  a,d
    cp  4
    jr  nz,cl_write
    xor a
    ld  (cl_cnt),a
    ld  d,0
    ld  b,0xa5
cl_read:
    ld  a,d
    add a,a
    or  e
    out (c),a
    ld  a,(hl)
    cp  b
    jr  nz,cl_noinc
    ld  a,(cl_cnt)
    inc a
    ld  (cl_cnt),a
cl_noinc:
    ld  a,b
    add a,0x3b
    ld  b,a
    inc d
    ld  a,d
    cp  4
    jr  nz,cl_read
    ld  a,(cl_cnt)
    ld  (ix+0),a
    inc ix
    push de
    ld  de,0x0800
    add hl,de
    pop de
    ld  a,(cl_left)
    dec a
    ld  (cl_left),a
    jr  nz,cl_page
    ld  a,e
    out (c),a               ; back to the base state
    ret

;
; Test every other bank state with the same data.  Sets bank_result.
;
bank_tests:
    xor a
    ld  (bank_result),a
    ld  hl,page_class
    ld  b,17
    ld  d,0
bt_scan:
    ld  a,(hl)
    cp  d
    jr  c,bt_scan_next
    ld  d,a
bt_scan_next:
    inc hl
    djnz bt_scan
    ld  a,d
    ld  (bank_count),a
    cp  2
    ret c                   ; no bank switching found: nothing to test
    ld  d,1
    ld  c,1                 ; C = 1 (OK) until a bank fails
bt_loop:
    ld  a,d
    add a,a
    out (0x37),a
    push de
    push bc
    call fill_ram
    pop bc
    pop de
    push bc
    push de
    ld  d,0
    ld  e,0xff
    call check_bit
    pop de
    pop bc
    ld  hl,ram_size
    cp  (hl)
    jr  nc,bt_ok
    ld  c,2
bt_ok:
    inc d
    ld  a,d
    cp  4
    jr  nz,bt_loop
    xor a
    out (0x37),a
    ld  a,c
    ld  (bank_result),a
    ret

;
; Summarise the memory layout on lines 2, 11 and 13.
;
show_summary:
    ld  hl,page_class
    ld  b,0                 ; B = number of fixed pages from $7800
sum_fixed:
    ld  a,(hl)
    cp  1
    jr  nz,sum_fixed_done
    inc b
    inc hl
    ld  a,b
    cp  17
    jr  nz,sum_fixed
sum_fixed_done:
    ld  a,b
    ld  (fixed_pages),a
    ld  hl,page_class
    ld  b,17
    ld  c,0                 ; C = number of bank switched pages
sum_banked:
    ld  a,(hl)
    cp  2
    jr  c,sum_banked_next
    inc c
sum_banked_next:
    inc hl
    djnz sum_banked
    ld  a,c
    ld  (banked_pages),a
;
; Line 2: fixed (internal) RAM.
;
    ld  de,vz_screen+2*32+2
    ld  a,(banked_pages)
    or  a
    jr  z,sum_nobank
    ld  a,(fixed_pages)
    cp  4
    jr  c,sum_vz200
    cp  8
    jr  z,sum_vz300
    ld  hl,s_fixed
    call put_str
    jr  sum_fixed_kb
sum_vz200:
    ld  hl,s_int200
    call put_str
    call put_fixed_kb
    ld  hl,s_k_sp
    call put_str
    ld  a,(fixed_pages)
    ld  l,a
    ld  h,0
    call put_dec
    ld  hl,s_x6116
    call put_str
    jr  sum_loader
sum_vz300:
    ld  hl,s_int300
    call put_str
    call put_fixed_kb
    ld  hl,s_k_sp
    call put_str
    ld  hl,s_4116
    call put_str
    jr  sum_loader
sum_fixed_kb:
    call put_fixed_kb
    ld  hl,s_k
    call put_str
    jr  sum_loader
sum_nobank:
    ld  hl,s_nobank_int
    call put_str
;
; Line 11: bank switched loader RAM.
;
sum_loader:
    ld  de,vz_screen+11*32+2
    ld  a,(banked_pages)
    or  a
    jr  nz,sum_have_banks
    ld  hl,s_nobank
    call put_str
    jr  sum_banktest
sum_have_banks:
    ld  hl,s_loader
    call put_str
    ld  a,(banked_pages)
    add a,a
    ld  l,a
    ld  h,0
    push hl
    call put_dec
    ld  hl,s_kx
    call put_str
    ld  a,(bank_count)
    ld  l,a
    ld  h,0
    call put_dec
    ld  hl,s_eq
    call put_str
    pop hl                  ; HL = KB per bank
    ld  a,(bank_count)
    ld  b,a
    ld  a,b
    dec b
    jr  z,sum_total_put     ; (cannot happen: banks >= 2 here)
    push de
    ld  d,h
    ld  e,l
sum_mul:
    add hl,de
    djnz sum_mul
    pop de
sum_total_put:
    call put_dec
    ld  hl,s_k
    call put_str
;
; Line 13: bank test result.
;
sum_banktest:
    ld  de,vz_screen+13*32+2
    ld  a,(bank_result)
    ld  hl,s_bt_none
    or  a
    jr  z,sum_bt_put
    ld  hl,s_bt_ok
    cp  1
    jr  z,sum_bt_put
    ld  hl,s_bt_bad
sum_bt_put:
    jp  put_str

put_fixed_kb:
    ld  a,(fixed_pages)
    add a,a
    ld  l,a
    ld  h,0
    jp  put_dec

;
; Report which bits are alive or dead.  A bit is good only if it is
; good for as many pages as the best bit.
;
report_ram:
    ld  iy,ram_report_pos
    ld  hl,highest_good
    ld  b,8
report_loop:
    ld  e,(iy+0)
    ld  d,(iy+1)
    inc iy
    inc iy
    push de
    pop ix                  ; IX = screen position of this bit's result.
    ld  a,(hl)
    inc hl
    or  a
    jr  z,report_bad
    push hl
    ld  hl,ram_size
    cp  (hl)
    pop hl
    jr  c,report_bad
    ld  (ix+0),0x20         ; ' '
    ld  (ix+1),0x0f         ; 'O'
    ld  (ix+2),0x0b         ; 'K'
    jr  report_next
report_bad:
    ld  (ix+0),0x42         ; 'B'
    ld  (ix+1),0x41         ; 'A'
    ld  (ix+2),0x44         ; 'D'
report_next:
    djnz report_loop

;
; Report the size of the RAM that tested good.
;
    ld  a,(ram_size)
    and 0xfc
    srl a
    ld  e,a
    ld  d,0
    ld  ix,ram_sizes
    add ix,de
    ld  iy,vz_screen+6*32+27
    ld  (iy+0),0x20
    ld  a,(ix+0)
    ld  (iy+1),a
    ld  a,(ix+1)
    ld  (iy+2),a

;
; Test the other RAM banks and show the memory layout.
;
    call bank_tests
    call show_summary

;
; Loop forever until the device is powered off while waiting for keys.
;
; If the user presses a key, then print that key to the screen.
; If the user presses CTRL+BREAK, then restart the tests.
;
    ld  de,0xffff                ; Previous key and CTRL/SHIFT flags.
key_loop:
;
; Get the key that is pressed on the keyboard.
;
;   A   - ASCII code of the base key or 0 if none pressed.
;   B   - Bit 0 is non-zero if CTRL is pressed.  Bit 1 is non-zero for SHIFT.
;
; This routine isn't very space-efficient, but it is easy to understand.
;
    ld  b,0
    ld  a,(0x68fd)               ; Is CTRL pressed?
    bit 2,a
    jr  nz,get_key_no_ctrl
    set 0,b
get_key_no_ctrl:
    ld  a,(0x68fb)               ; Is SHIFT pressed?
    bit 2,a
    jr  nz,get_key_no_shift
    set 1,b
get_key_no_shift:
    ld  a,(0x68fe)               ; Row 1 of the keyboard.
    bit 0,a
    jp  z,key_T
    bit 1,a
    jp  z,key_W
    bit 3,a
    jp  z,key_E
    bit 4,a
    jp  z,key_Q
    bit 5,a
    jp  z,key_R
    ld  a,(0x68fd)               ; Row 2 of the keyboard.
    bit 0,a
    jp  z,key_G
    bit 1,a
    jp  z,key_S
    bit 3,a
    jp  z,key_D
    bit 4,a
    jp  z,key_A
    bit 5,a
    jp  z,key_F
    ld  a,(0x68fb)               ; Row 3 of the keyboard.
    bit 0,a
    jp  z,key_B
    bit 1,a
    jp  z,key_X
    bit 3,a
    jp  z,key_C
    bit 4,a
    jp  z,key_Z
    bit 5,a
    jp  z,key_V
    ld  a,(0x68f7)               ; Row 4 of the keyboard.
    bit 0,a
    jp  z,key_5
    bit 1,a
    jp  z,key_2
    bit 3,a
    jp  z,key_3
    bit 4,a
    jp  z,key_1
    bit 5,a
    jp  z,key_4
    ld  a,(0x68ef)               ; Row 5 of the keyboard.
    bit 0,a
    jp  z,key_N
    bit 1,a
    jp  z,key_dot
    bit 3,a
    jp  z,key_comma
    bit 4,a
    jp  z,key_space
    bit 5,a
    jp  z,key_M
    ld  a,(0x68df)               ; Row 6 of the keyboard.
    bit 0,a
    jp  z,key_6
    bit 1,a
    jp  z,key_9
    bit 2,a
    jp  z,key_minus
    bit 3,a
    jp  z,key_8
    bit 4,a
    jp  z,key_0
    bit 5,a
    jp  z,key_7
    ld  a,(0x68bf)               ; Row 7 of the keyboard.
    bit 0,a
    jp  z,key_Y
    bit 1,a
    jp  z,key_O
    bit 2,a
    jp  z,key_return
    bit 3,a
    jp  z,key_I
    bit 4,a
    jp  z,key_P
    bit 5,a
    jp  z,key_U
    ld  a,(0x687f)               ; Row 8 of the keyboard.
    bit 0,a
    jp  z,key_H
    bit 1,a
    jp  z,key_L
    bit 2,a
    jp  z,key_colon
    bit 3,a
    jp  z,key_K
    bit 4,a
    jp  z,key_semi
    bit 5,a
    jp  z,key_J
    xor a
    jp  got_key
key_T:
    ld  a,'T'
    jp  got_key
key_W:
    ld  a,'W'
    jp  got_key
key_E:
    ld  a,'E'
    jp  got_key
key_Q:
    ld  a,'Q'
    jp  got_key
key_R:
    ld  a,'R'
    jp  got_key
key_G:
    ld  a,'G'
    jp  got_key
key_S:
    ld  a,'S'
    jp  got_key
key_D:
    ld  a,'D'
    jp  got_key
key_A:
    ld  a,'A'
    jp  got_key
key_F:
    ld  a,'F'
    jp  got_key
key_B:
    ld  a,'B'
    jp  got_key
key_X:
    ld  a,'X'
    jp  got_key
key_C:
    ld  a,'C'
    jp  got_key
key_Z:
    ld  a,'Z'
    jp  got_key
key_V:
    ld  a,'V'
    jp  got_key
key_5:
    ld  a,'5'
    jp  got_key
key_2:
    ld  a,'2'
    jp  got_key
key_3:
    ld  a,'3'
    jp  got_key
key_1:
    ld  a,'1'
    jp  got_key
key_4:
    ld  a,'4'
    jp  got_key
key_N:
    ld  a,'N'
    jp  got_key
key_dot:
    ld  a,'.'
    jp  got_key
key_comma:
    ld  a,','
    jp  got_key
key_space:
    ld  a,' '
    jp  got_key
key_M:
    ld  a,'M'
    jp  got_key
key_6:
    ld  a,'6'
    jp  got_key
key_9:
    ld  a,'9'
    jp  got_key
key_minus:
    ld  a,'-'
    jp  got_key
key_8:
    ld  a,'8'
    jp  got_key
key_0:
    ld  a,'0'
    jp  got_key
key_7:
    ld  a,'7'
    jp  got_key
key_Y:
    ld  a,'Y'
    jp  got_key
key_O:
    ld  a,'O'
    jp  got_key
key_return:
    ld  a,0x0d
    jp  got_key
key_I:
    ld  a,'I'
    jp  got_key
key_P:
    ld  a,'P'
    jp  got_key
key_U:
    ld  a,'U'
    jp  got_key
key_H:
    ld  a,'H'
    jp  got_key
key_L:
    ld  a,'L'
    jp  got_key
key_colon:
    ld  a,':'
    jp  got_key
key_K:
    ld  a,'K'
    jp  got_key
key_semi:
    ld  a,';'
    jp  got_key
key_J:
    ld  a,'J'
;
; We now have a key.
;
got_key:
    cp  d               ; Is this the same key as last time?
    jr  nz,print_key
    ld  l,a
    ld  a,b
    cp  e
    jp  z,key_loop      ; Yes, then nothing to do - go back for another key.
    ld  a,l
print_key:
    ld  d,a             ; Save the key that was just pressed / released in DE.
    ld  e,b
    ld  ix,key_name     ; Point to the buffer to fill with the name.
    cp  '-'             ; Is the key CTRL+BREAK?
    jr  nz,not_break
    bit 0,b
    jp  z,not_break
restart:                ; If it is, then restart the test.
    ld  a,(0x68df)       ; Wait for the BREAK key to be released,
    bit 2,a             ; or we might get stuck in a loop restarting
    jr  z,restart       ; the dead test over and over and over.
    jp  entry
not_break:
;
; Output the base key name.
;
    or  a
    jr  z,no_base_char
    cp  0x0d
    jr  nz,not_return
    call copy_string
    defb  "NRUTER",0      ; "RETURN" backwards.
    jr  no_base_char
not_return:
    cp  ' '
    jr  nz,not_space
    call copy_string
    defb  "ECAPS",0       ; "SPACE" backwards.
    jr  no_base_char
not_space:
    and 0x3f             ; Convert from ASCII into a graphic character.
    ld  (ix+0),a
    inc ix
no_base_char:
    bit 1,b
    jr  z,no_shift
    call copy_string
    defb  "+TFIHS",0      ; "SHIFT+" backwards.
no_shift:
    bit 0,b
    jr  z,pad
    call copy_string
    defb  "+LRTC",0       ; "CTRL+" backwards.
;
; Pad the name to the maximum possible size: "CTRL+SHIFT+RETURN".
;
pad:
    ld  b,17
    ld  a,' '
pad_loop:
    ld  (ix+0),a
    inc ix
    djnz pad_loop
;
; Show the name of the key on the screen.
;
    ld  ix,key_name
    ld  hl,vz_screen+12*32+29
    ld  b,17
show_key_name_loop:
    ld  a,(ix+0)
    ld  (hl),a
    inc ix
    dec hl
    djnz show_key_name_loop
;
; Got around again for the next key.
;
    jp  key_loop

;
; Copy a string to (IX) that is pointed to by the return address.
;
copy_string:
    pop hl
copy_string_loop:
    ld  a,(hl)
    inc hl
    and 0x3f
    jr  z,end_copy_string
    ld  (ix+0),a
    inc ix
    jr  copy_string_loop
end_copy_string:
    push hl
    ret


;
; Initial test screen image with a blue border and black background.
;
test_screen:
    defb  0xae                     ; Line 0
    defs  30,0xac
    defb  0xad
    defb  0xaa                     ; Line 1
    defb  "    VZ200/VZ300 DEAD TEST     "
    defb  0xa5
    defb  0xaa                     ; Line 2
    defb  "                              "
    defb  0xa5
    defb  0xaa                     ; Line 3
    defb  " VIDEO RAM                ??? "
    defb  0xa5
    defb  0xaa                     ; Line 4
    defb  " VSYNC SIGNAL             ??? "
    defb  0xa5
    defb  0xaa                     ; Line 5
    defb  " VSYNC FREQ ???? IRQ ??????   "
    defb  0xa5
    defb  0xaa                     ; Line 6
    defb  " RAM SIZE (KB)            ??? "
    defb  0xa5
    defb  0xaa                     ; Line 7
    defb  " RAM D0   ???    RAM D4   ??? "
    defb  0xa5
    defb  0xaa                     ; Line 8
    defb  " RAM D1   ???    RAM D5   ??? "
    defb  0xa5
    defb  0xaa                     ; Line 9
    defb  " RAM D2   ???    RAM D6   ??? "
    defb  0xa5
    defb  0xaa                     ; Line 10
    defb  " RAM D3   ???    RAM D7   ??? "
    defb  0xa5
    defb  0xaa                     ; Line 11
    defb  "                              "
    defb  0xa5
    defb  0xaa                     ; Line 12
    defb  " KEY                      ??? "
    defb  0xa5
    defb  0xaa                     ; Line 13
    defb  "                              "
    defb  0xa5
    defb  0xaa                     ; Line 14
    defb  0x20,0x20,0x20
    defb  0x8f,0x8f,0x8f             ; Show all text colours in a row.
    defb  0x9f,0x9f,0x9f
    defb  0xaf,0xaf,0xaf
    defb  0xbf,0xbf,0xbf
    defb  0xcf,0xcf,0xcf
    defb  0xdf,0xdf,0xdf
    defb  0xef,0xef,0xef
    defb  0xff,0xff,0xff
    defb  0x20,0x20,0x20
    defb  0xa5
    defb  0xab                     ; Line 15
    defs  30,0xa3
    defb  0xa7

;
; Random-ish data for testing RAM contents.
;
test_data:
    ;
    ; 256 bytes from the AES S-box.
    ;
    defb 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76
    defb 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0
    defb 0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15
    defb 0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75
    defb 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84
    defb 0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf
    defb 0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8
    defb 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2
    defb 0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73
    defb 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb
    defb 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79
    defb 0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08
    defb 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a
    defb 0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e
    defb 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf
    defb 0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
    ;
    ; 256 bytes from the AES inverse S-box.
    ;
    defb 0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb
    defb 0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb
    defb 0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e
    defb 0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25
    defb 0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92
    defb 0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84
    defb 0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06
    defb 0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b
    defb 0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73
    defb 0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e
    defb 0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b
    defb 0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4
    defb 0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f
    defb 0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef
    defb 0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61
    defb 0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d 

;
; Strings for showing the RAM size.
;
ram_sizes:
    defb  " 0 1 2 3 4 5 6 7"
    defb  " 8 9101112131415"
    defb  "1617181920212223"
    defb  "2425262728293031"
    defb  "323334"

;
; Screen addresses of the per-bit RAM results (D0..D7).
;
ram_report_pos:
    defw vz_screen+7*32+11
    defw vz_screen+8*32+11
    defw vz_screen+9*32+11
    defw vz_screen+10*32+11
    defw vz_screen+7*32+27
    defw vz_screen+8*32+27
    defw vz_screen+9*32+27
    defw vz_screen+10*32+27

code_end:

