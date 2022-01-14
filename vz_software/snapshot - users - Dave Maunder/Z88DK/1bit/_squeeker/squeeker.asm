;
;zcc +zx -zorg=32772 -O3 -vn -m main.c mus\huby.asm -o build\main.bin -lndos
;
;

XDEF _squeeker
_squeeker:
;test code
begin:
 	ld hl,music_data
	call play
	ret
;Squeeker beeper engine by Zilogat0r
;- original version 2000
;- size optimized version 2012
;- new data format and loader by utz 2015
play:
	ld a,(hl) ;configure global duty setting
	ld (duty + 1),a
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (mLoopVar + 1),de
	ld (seqpntr + 1),hl
	ei ;detect kempston
	halt
	in a,($1f)
	inc a
	jr nz,_skip
	ld (maskKempston + 1),a
_skip:
	di
	exx
	push hl ;preserve HL' for return to BASIC
	ld (oldSP + 1),sp
;******************************************************************
rdseq:
seqpntr: ;seqpntr equ $+1
	ld sp,0
	xor a
	pop de ;pattern pointer to DE
	or d
	ld (seqpntr + 1),sp
	jr nz,rdptn0
	;jp exit ;uncomment to disable looping
mLoopVar: ;mLoopVar=$+1
	ld sp,0 ;get loop point
	jr rdseq+3
;******************************************************************
rdptn0:
	; ld a,(de) ;read pattern duty
	; ld (duty),a
	; inc de
	ld (patpntr + 1),de
rdptn:
	in a,($1f) ;read joystick
maskKempston: ;maskKempston equ $+1
	and $1f
	ld c,a
	in a,($fe) ;read kbd
	cpl
	or c
	and $1f
	jp nz,exit
patpntr: ;patpntr equ $+1 ;fetch pointer to pattern data
	ld sp,0
	pop af
	jr z,setAll ;$40
	jr c,set123 ;$01
	jp pe,set12 ;$04
	jp m,set1 ;$80
	jp setNone ;$00
setAll:
	pop hl
	ld (rowBuffer+12),hl
	ld (rowBuffer+14),hl
set123:
	pop hl
	ld (rowBuffer+8),hl
	ld (rowBuffer+10),hl
set12:
	pop hl
	ld (rowBuffer+4),hl
	ld (rowBuffer+6),hl
set1:
	pop hl
	ld (rowBuffer),hl
	ld (rowBuffer+2),hl
setNone:
	or a
	jr z,rdseq
	ld (patpntr + 1),sp
	ld h,a ;set speed
	ld l,0
;******************************************************************
mxb:
	exx
	xor a
	ld bc,$0400
	ld sp,rowBuffer
mxa:
	rl c
	pop de
	pop hl
	add hl,de
	push hl
	pop hl
duty: ;duty equ $+1
	ld a,40 ;duty
	add a,h
	djnz mxa
	ld a,32
	adc a,c
	ld (26624), a
	exx
	dec hl
	ld a,h
	or l
	jr nz,mxb
	jp rdptn
;******************************************************************
rowBuffer: ;stack buffer for current row
	defs 16
;******************************************************************
exit:
oldSP: ;oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************
;compiled music data
music_data:
	defb 32
	defw loop
;defw pattern1
loop:
	defw pattern1
	defw pattern1
	defw pattern2
	defw pattern2
	defw pattern1
	defw pattern1
	defw pattern2
	defw pattern2
	defw pattern1
	defw pattern1
	defw pattern1
	defw pattern1
	defw pattern2
	defw pattern2
	defw pattern2
	defw pattern2

	defw 0
	defw loop

.pattern1
defw $240,$0,$0,$469,$8d3
defw $280,$0
defw $204,$0,$0
defw $200
defw $204,$4f4,$9e8
defw $280,$0
defw $204,$0,$0
defw $200
defw $204,$469,$8d3
defw $280,$0
defw $204,$0,$0
defw $200
defw $204,$5e4,$bc8
defw $280,$0
defw $204,$0,$0
defw $200
defw $204,$7dd,$fba
defw $280,$0
defw $204,$0,$0
defw $200
defw $204,$5e4,$bc8
defw $280,$0
defw $204,$0,$0
defw $200
defw 0
.pattern2
defw $240,$0,$0,$7dd,$469
defw $200
defw $200
defw $204,$0,$0
defw $204,$8d3,$4f4
defw $200
defw $200
defw $204,$0,$0
defw $204,$9e8,$469
defw $200
defw $200
defw $204,$0,$0
defw $204,$bc8,$5e4
defw $200
defw $200
defw 0