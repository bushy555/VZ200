; Octode beeper music engine by Shiru (shiru@mail.ru) 02'11
; Eight channels of tone,  per-pattern tempo
; One channel of interrupting drums,  no ROM data required
; Feel free to do whatever you want with the code,  it is PD
;
; modified by introspec (zxintrospec@gmail.com) 10/2014-04/2015
; (data format changed for faster row transitions; sound
; generation is now using a crude variant of PWM.

;vol1234	EQU 3			; volume of channels 1-4
;vol5678	EQU 3			; volume of channels 5-8
; the sum of these volumes should not exceed ~16 (or ~8,  if slowDecay equ 1)
;slowDecay	EQU 0
;octodeDrums	EQU 12500
;storeA		EQU 0





;vol1234	EQU 3			; volume of channels 1-4
;vol5678	EQU 3			; volume of channels 5-8
; the sum of these volumes should not exceed ~16 (or ~8,  if slowDecay equ 1)
;slowDecay	EQU 0
;octodeDrums	EQU 12500
;storeA		EQU 0

		;MODULE OctodeXL


	output 	"pp.obj"



		ORG	#8000

begin:		ld	hl, musicdata
		call	play
		jp	begin
		ret

vol1234: 	EQU 1
vol5678:	EQU 1
octodeDrums:	EQU 12500
slowDecay:	EQU 0
storeA:		EQU 0

		;MODULE OctodeXL

play:
;		ei
;		halt			; must ensure that test is done during the border
;		in 	a, (#1f)
;		inc 	a
;		jr 	nz, haveKempston
;		ld 	(maskKempston), a
;haveKempston:
		di
		ld 	h, #ff		; H' equ #FF is used by the sound core
		exx
		push 	hl
		push 	iy
		ld 	ix, vol1234*256+vol5678	; channel volumes
		ld 	iy, musicdata
		jr 	readNotes.readOrder

stopPlayer:	pop 	iy
		pop 	hl
		exx
		ei
		ret

rowEnd:		;in 	a, (#1f)
		;and 	#1f
maskKempston:	;EQU 	$-1
		;ld 	c, a
		;in 	a, (#fe)
		;cpl
		;or c
		;and #1f
		;jr nz, stopPlayer
		jp stopPlayer

readNotes:
.ptr equ $+1
	ld 	hl, 0
	ld 	a, (hl)
	cp 	10
	jp 	nc, .p0n
	or 	a
	jp 	z, .p0y
	dec 	a
	jr 	nz, .drum

.readOrder
	ld 	l, (iy)
	ld 	h, (iy+1)
	ld 	a, h
	or 	l
	jr 	nz, .setPattern
	ld 	l, (iy+2)
	ld 	h, (iy+3)
	push 	hl
	pop 	iy
	jr 	.readOrder
.setPattern
	ld 	c, (hl)
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(.ptr), hl
	ld 	(.speed), bc
	inc 	iy
	inc 	iy
	jr 	readNotes

.drum	inc 	hl
	ld 	(.ptr), hl
	add 	a 
	add 	a
	add 	low (.drumTable-4) 
	ld 	l, a
	adc 	high (.drumTable-4) 
	sub 	l 
	ld 	h, a
	push 	de
	ld 	a, (hl) 
	ld 	(.drumPeriod), a 
	inc 	hl
	ld 	d, (hl) 
	inc 	hl
	ld 	e, (hl) 
	inc 	hl
	ld 	a, (hl) 
	and 	32
	ld 	c, a
	ld 	a, (hl) 
	add 	a 
	and 	32
	ld 	(.noiseOn), a

		ld hl, #C0DE
.drumSeed:	EQU $-2

.drumLoop:
	dec 	e 
	jr 	nz, .keepNoise
	ld 	a, (.noiseOn) 
	xor 	32
	ld 	(.noiseOn), a
.keepNoise:
	ld 	b, 45
.drumPeriod:	EQU $-1

.noiseLoop:	
	ld 	a, c 
	out 	(14), a
;	out 	(254), a
;	ld	($6800),  a
	add 	hl, hl 
	sbc 	a
	and 	#BD			; instead of #BD,  one can use #3F or #D7
	xor 	l 
	ld 	l, a
	and 	32 
	or 	0
.noiseOn:	EQU $-1
	out 	(14), a
;	out 	(254), a
;	ld	($6800),  a
	djnz 	.noiseLoop
	ld 	a, c
	xor 	32
	ld 	c, a
	dec 	d 
	jr 	nz, .drumLoop
	; (4+12 + 7 + (4+11 + 11+4+7+4+4 + 7+7+11+13)*B-5 + 4+7+4 + 4+12)*D  equ  (83*B+49)*D
	ld 	(.drumSeed), hl	; 16
	xor 	a
	out 	(14), a
;	out 	(254), a
;	ld	($6800), a
	pop 	de
	jp 	readNotes

.drumTable:
	; table of period numbers for required duration in t-states
	;
	;  duration	1	2	3	4	6	8	10	12	14	16	24	32
	;
	;   12500	150	75	50	37	25	18	14	12	10	9	6	4
	;   15000	180	90	60	45	30	22      17	14	12	11	7	5
	;   17500	210	105	70	52	35	26	20	17	14	12	8	6
	;   20000	240	120	80	60	40	30	24	19	17	14	9	7
	;
	; for each drum one must specify 4 parameters:
	; period of tone,  number of half-tones,  noise reset counter,  starting beeper state

	IF octodeDrums equ 12500
	db	25, 6,  1, 16
	db	10, 14,  3, 0
	db	150, 1,  1, 16
	db	75, 2,  3, 16
	db	50, 3,  5, 0
	db	37, 4,  5, 16
	db	75, 2,  3, 0
	db	4, 32,  33, 0
	ENDIF

	IF octodeDrums equ 20000
	db	24, 10,  1, 16
	db	14, 16,  2, 16+8
	db	120, 2,  1, 16
	db	120, 2,  3, 16
	db	80, 3,  5, 0
	db	60, 4,  5, 16
	db	120, 2,  3, 0
	db	7, 32,  33, 0
	ENDIF

.noLoop:
.p0n	ld (soundLoop.frq0), a
	ld a, #84
.p0y	ld (soundLoop.off0), a
	ld c, #84		; #DD+#84  equ  ADD IXH
	inc hl
	ld a, (hl)
	or a
	jr z, .p1y
	ld (soundLoop.frq1), a
	ld a, c
.p1y	ld (soundLoop.off1), a
	inc hl
	ld a, (hl)
	or a
	jr z, .p2y
	ld (soundLoop.frq2), a
	ld a, c
.p2y	ld (soundLoop.off2), a
	inc hl
	ld a, (hl)
	or a
	jr z, .p3y
	ld (soundLoop.frq3), a
	ld a, c
.p3y	ld (soundLoop.off3), a
	inc hl
	inc c		; #DD+#85  equ  ADD IXL
	ld a, (hl)
	or a
	jr z, .p4y
	ld (soundLoop.frq4), a
	ld a, c
.p4y	ld (soundLoop.off4), a
	inc hl
	ld a, (hl)
	or a
	jr z, .p5y
	ld (soundLoop.frq5), a
	ld a, c
.p5y	ld (soundLoop.off5), a
	inc hl
	ld a, (hl)
	or a
	jr z, .p6y
	ld (soundLoop.frq6), a
	ld a, c
.p6y	ld (soundLoop.off6), a
	inc hl
	ld a, (hl)
	or a
	jr z, .p7y
	ld (soundLoop.frq7), a
	ld a, c
.p7y	ld (soundLoop.off7), a
	inc hl
	ld (.ptr), hl
.speed equ $+1:	ld hl, 0
.prevBC equ $+1:	ld bc, 0

	IF storeA equ 1
.prevVol equ $+1
		ld a, 0
	ELSE
		xor a
	ENDIF

soundLoop:	dec b 
		jr nz, .lc0
.frq0 equ $+1:	ld b, 0
.off0 equ $+1:	add ixh			; 4+7+7+8 equ 26t
.lb0		dec c 
		jr nz, .lc1
.frq1 equ $+1:	ld c, 0
.off1 equ $+1:	add ixh			; 4+7+7+8 equ 26t
.lb1		dec d 
		jr nz, .lc2
.frq2 equ $+1:	ld d, 0
.off2 equ $+1:	add ixh			; 4+7+7+8 equ 26t
.lb2		dec e 
		jr nz, .lc3
.frq3 equ $+1:	ld e, 0
.off3 equ $+1:	add ixh			; 4+7+7+8 equ 26t
.lb3		exx			; 4t
		dec b 
		jr nz, .lc4
.frq4 equ $+1:	ld b, 0
.off4 equ $+1:	add ixl			; 4+7+7+8 equ 26t
.lb4		dec c 
		jr nz, .lc5
.frq5 equ $+1:	ld c, 0
.off5 equ $+1:	add ixl			; 4+7+7+8 equ 26t
.lb5		dec d 
		jr nz, .lc6
.frq6 equ $+1:	ld d, 0
.off6 equ $+1:	add ixl			; 4+7+7+8 equ 26t
.lb6		dec e 
		jr nz, .lc7
.frq7 equ $+1:	ld e, 0
.off7 equ $+1:	add ixl			; 4+7+7+8 equ 26t
.lb7		add h
		sbc h
		ld l, a
		sbc a
		nop
		and 16			; 4+4+4 + 4+4+7 equ 27t
		out 	(14), a
;		out 	(254), a		; 11t
;		ld	($6800),  a

		ld a, l			; 4t

	IF slowDecay equ 1
		nop
		nop
	ELSE
		add h
		sbc h			; 4+4 equ 8t
	ENDIF

		exx			; 4t
		dec l			; 4t

		jp nz, soundLoop		; 26*4+4+26*4+27+11+4+8+4+4+10 equ 280t
		dec h
		jr nz, soundLoop

	IF storeA equ 1
		ld (readNotes.prevVol), a
	ENDIF

		xor 	a
		out 	(14), a
;		out 	(254), a
;		ld	($6800),  a
	
		ld (readNotes.prevBC), bc
		jp rowEnd

.lc0		jp .lb0			; 4+12+10 equ 26t
.lc1		jp .lb1			; 4+12+10 equ 26t
.lc2		jp .lb2			; 4+12+10 equ 26t
.lc3		jp .lb3			; 4+12+10 equ 26t
.lc4		jp .lb4			; 4+12+10 equ 26t
.lc5		jp .lb5			; 4+12+10 equ 26t
.lc6		jp .lb6			; 4+12+10 equ 26t
.lc7		jp .lb7			; 4+12+10 equ 26t

		;ENDMODULE






musicdata:
module
loop
	dw p00
	dw p00
	dw p01
	dw p01
	dw 0
	dw loop
p00
	dw #03fb
	db #02,#61,#60,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #61,#60,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #05,#30,#2f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #30,#2f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#61,#60,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#61,#60,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #05,#30,#2f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #30,#2f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#91,#90,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #91,#90,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #05,#48,#47,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #48,#47,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#91,#90,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#91,#90,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #05,#48,#47,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #48,#47,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#81,#80,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #81,#80,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #05,#40,#3f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #40,#3f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#81,#80,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#81,#80,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #05,#40,#3f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #40,#3f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#61,#60,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#61,#60,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #05,#30,#2f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#30,#2f,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#61,#60,#00,#00,#00,#00,#00,#00
	db     #61,#60,#00,#00,#00,#00,#00,#00
	db     #61,#60,#00,#00,#00,#00,#00,#00
	db     #61,#60,#00,#00,#00,#00,#00,#00
	db #05,#00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #01
p01
	dw #03fb
	db #02,#61,#60,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #61,#60,#00,#00,#00,#00,#00,#00
	db     #61,#60,#00,#00,#00,#00,#00,#00
	db #05,#00,#00,#30,#26,#40,#18,#30,#00
	db     #00,#00,#00,#00,#00,#18,#30,#00
	db #02,#00,#00,#30,#26,#40,#15,#2b,#00
	db     #00,#00,#30,#26,#40,#15,#2b,#00
	db     #00,#00,#00,#00,#00,#15,#2b,#00
	db     #00,#00,#00,#00,#00,#15,#2b,#00
	db #02,#00,#00,#30,#26,#40,#18,#30,#00
	db     #00,#00,#30,#26,#40,#18,#30,#00
	db #05,#00,#00,#00,#00,#00,#18,#30,#00
	db     #00,#00,#00,#00,#00,#18,#30,#00
	db     #61,#60,#00,#00,#00,#18,#30,#00
	db     #00,#00,#00,#00,#00,#18,#30,#00
	db #02,#91,#90,#00,#00,#00,#1c,#39,#00
	db     #00,#00,#00,#00,#00,#1c,#39,#00
	db     #91,#90,#00,#00,#00,#1c,#39,#00
	db     #91,#90,#00,#00,#00,#1c,#39,#00
	db #05,#00,#00,#48,#1c,#30,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#00,#00,#48,#1c,#30,#00,#00,#00
	db     #00,#00,#48,#1c,#30,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#00,#00,#48,#1c,#30,#00,#00,#00
	db     #00,#00,#48,#1c,#30,#00,#00,#00
	db #05,#00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#91,#90,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#81,#80,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #81,#80,#00,#00,#00,#00,#00,#00
	db     #81,#80,#00,#00,#00,#00,#00,#00
	db #05,#00,#00,#40,#19,#2b,#19,#33,#00
	db     #00,#00,#00,#00,#00,#19,#33,#00
	db #02,#00,#00,#40,#19,#2b,#18,#30,#00
	db     #00,#00,#40,#19,#2b,#18,#30,#00
	db     #00,#00,#00,#00,#00,#18,#30,#00
	db     #00,#00,#00,#00,#00,#18,#30,#00
	db #02,#00,#00,#40,#19,#2b,#15,#2b,#00
	db     #00,#00,#40,#19,#2b,#15,#2b,#00
	db #05,#00,#00,#00,#00,#00,#15,#2b,#00
	db     #00,#00,#00,#00,#00,#15,#2b,#00
	db #02,#81,#80,#00,#00,#00,#15,#2b,#00
	db     #00,#00,#00,#00,#00,#15,#2b,#00
	db #02,#61,#60,#00,#00,#00,#18,#30,#00
	db     #00,#00,#00,#00,#00,#18,#30,#00
	db     #61,#60,#00,#00,#00,#18,#30,#00
	db     #61,#60,#00,#00,#00,#18,#30,#00
	db #05,#00,#00,#30,#26,#40,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#00,#00,#30,#26,#40,#00,#00,#00
	db     #00,#00,#30,#26,#40,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #02,#00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #05,#00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db     #00,#00,#00,#00,#00,#00,#00,#00
	db #01
