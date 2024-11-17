; OCTODE XL X4.    PSIONIC ACTIVIY.  MR BEEP.
;
; Assemble wit SJASMPLUS.	\vz\tasm\_utils\sjasmplus %1.asm
;				\vz\tasm\_utils\rbinary %1.obj %1.vz
;
; Octode beeper music engine by Shiru (shiru@mail.ru) 02'11
; Eight channels of tone, per-pattern tempo
; One channel of interrupting drums, no ROM data required
; Feel free to do whatever you want with the code, it is PD
;
; modified by introspec (zxintrospec@gmail.com) 10/2014-04/2015
; (data format changed for faster row transitions; sound
; generation is now using a crude variant of PWM.

;vol1234	EQU 3			; volume of channels 1-4
;vol5678	EQU 3			; volume of channels 5-8
; the sum of these volumes should not exceed ~16 (or ~8, if slowDecay=1)
;slowDecay	EQU 0
;octodeDrums	EQU 12500
;storeA		EQU 0

;	MODULE OctodeXL

	output "dance.obj"




;==================================================================
;
;   Octode M2 by shiru & introspec
;
;==================================================================

;	MODULE	VER_M2
;	ORG	#8000		; ZX speccy
	ORG	#8000		; VZ
;	ORG	$100		; Microbee .COM CPM




begin:		ld	hl, musicdata
		call	play
		ld	hl, (end)	; funny test to identify sna
		ld	de, 65536-#C0DE
		add	hl, de
		ld	a, h
		or	l
		jr	z, begin
		ret

vol1234:	EQU 2
vol5678:	EQU 1
octodeDrums:	EQU 12500
slowDecay:	EQU 0
storeA:		EQU 0







play:
		di
		ld h,#ff		; H'=#FF is used by the sound core
		exx
		push hl
		push iy
		ld ix,vol1234*256+vol5678	; channel volumes
		ld iy,musicdata
		jr readNotes.readOrder

stopPlayer:	pop iy
		pop hl
		exx
		ei
		ret

rowEnd:		

readNotes:
.ptr=$+1
		ld hl,0
		ld a,(hl)
		cp 10
		jp nc,.p0n
		or a
		jp z,.p0y
		dec a
		jr nz,.drum

.readOrder
	ld l,(iy)
	ld h,(iy+1)
	ld a,h
	or l
	jr nz,.setPattern
	ld l,(iy+2)
	ld h,(iy+3)
	push hl
	pop iy
	jr .readOrder
.setPattern
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld (.ptr),hl
	ld (.speed),bc
	inc iy
	inc iy
	jr readNotes

.drum
	inc hl
	ld (.ptr),hl

		add a : add a
		add low (.drumTable-4) : ld l,a
		adc high (.drumTable-4) : sub l : ld h,a

		push de
		ld a,(hl) 
	 ld (.drumPeriod),a 
	 inc hl
	ld d,(hl) 
	 inc hl
	ld e,(hl) 
	 inc hl
	ld a,(hl) 
	and 32
	 ld c,a
	ld a,(hl) 
	 add a 
	 and 32
	 ld (.noiseOn),a

		ld hl,#C0DE
.drumSeed:	EQU $-2

.drumLoop:	dec e 
	 jr nz,.keepNoise
		ld a,(.noiseOn) 
	xor 	32 
	ld 	(.noiseOn),a
.keepNoise:
		ld b,45
.drumPeriod:	EQU $-1

.noiseLoop:	ld a,c 
; 	out (254),a
	ld	($6800),a 

;	xor	64
;	out	(2), a		; microbee


		add hl,hl 
		 sbc a
		and #BD			; instead of #BD, one can use #3F or #D7
		xor l 
		 ld l,a


;	and 	16 
	and 	32 
;	and	64
		or 0
.noiseOn:	EQU $-1
	ld	($6800),a
;	out 	(254),a
;	xor	64
;	out	(2), a

		djnz .noiseLoop

		ld a,c
		xor 32;64	;16
		ld c,a

		dec d : jr nz,.drumLoop
		; (4+12 + 7 + (4+11 + 11+4+7+4+4 + 7+7+11+13)*B-5 + 4+7+4 + 4+12)*D = (83*B+49)*D

		ld (.drumSeed),hl	; 16

	xor 	a 
;	out 	(254),a
	ld	($6800),a
;	xor	64
;	out	(2), a


		pop de
		jp readNotes

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
	; period of tone, number of half-tones, noise reset counter, starting beeper state

	IF octodeDrums=12500
	db	25,6, 1,16
	db	10,14, 3,0
	db	150,1, 1,16
	db	75,2, 3,16
	db	50,3, 5,0
	db	37,4, 5,16
	db	75,2, 3,0
	db	4,32, 33,0
	ENDIF

	IF octodeDrums=20000
	db	24,10, 1,16
	db	14,16, 2,16+8
	db	120,2, 1,16
	db	120,2, 3,16
	db	80,3, 5,0
	db	60,4, 5,16
	db	120,2, 3,0
	db	7,32, 33,0
	ENDIF

.noLoop:
.p0n	ld (soundLoop.frq0),a
	ld a,#84
.p0y	ld (soundLoop.off0),a

	ld c,#84		; #DD+#84 = ADD IXH

	inc hl
	ld a,(hl)
	or a
	jr z,.p1y
	ld (soundLoop.frq1),a
	ld a,c
.p1y	ld (soundLoop.off1),a
	inc hl
	ld a,(hl)
	or a
	jr z,.p2y
	ld (soundLoop.frq2),a
	ld a,c
.p2y	ld (soundLoop.off2),a
	inc hl
	ld a,(hl)
	or a
	jr z,.p3y
	ld (soundLoop.frq3),a
	ld a,c
.p3y	ld (soundLoop.off3),a
	inc hl

		inc c		; #DD+#85 = ADD IXL

	ld a,(hl)
	or a
	jr z,.p4y
	ld (soundLoop.frq4),a
	ld a,c
.p4y	ld (soundLoop.off4),a
	inc hl
	ld a,(hl)
	or a
	jr z,.p5y
	ld (soundLoop.frq5),a
	ld a,c
.p5y	ld (soundLoop.off5),a
	inc hl
	ld a,(hl)
	or a
	jr z,.p6y
	ld (soundLoop.frq6),a
	ld a,c
.p6y	ld (soundLoop.off6),a
	inc hl
	ld a,(hl)
	or a
	jr z,.p7y
	ld (soundLoop.frq7),a
	ld a,c
.p7y	ld (soundLoop.off7),a
	inc hl
	ld (.ptr),hl

.speed=$+1
		ld hl,0
.prevBC=$+1
		ld bc,0

	IF storeA=1
.prevVol=$+1
		ld a,0
	ELSE
		xor a
	ENDIF

soundLoop:
		dec b 
	 jr nz,.lc0
.frq0=$+1
		ld b,0
.off0=$+1
		add ixh			; 4+7+7+8=26t
.lb0

		dec c 
	 jr nz,.lc1
.frq1=$+1
		ld c,0
.off1=$+1
		add ixh			; 4+7+7+8=26t
.lb1

		dec d 
	 jr nz,.lc2
.frq2=$+1
		ld d,0
.off2=$+1
		add ixh			; 4+7+7+8=26t
.lb2

		dec e 
	 	jr nz,.lc3
.frq3=$+1
		ld e,0
.off3=$+1
		add ixh			; 4+7+7+8=26t
.lb3

		exx			; 4t

		dec b 
	 	jr nz,.lc4
.frq4=$+1
		ld b,0
.off4=$+1
		add ixl			; 4+7+7+8=26t
.lb4

		dec c 
	 	jr nz,.lc5
.frq5=$+1
		ld c,0
.off5=$+1
		add ixl			; 4+7+7+8=26t
.lb5

		dec d 
	 	jr nz,.lc6
.frq6=$+1
		ld d,0
.off6=$+1
		add ixl			; 4+7+7+8=26t
.lb6

		dec e 
		 jr nz,.lc7
.frq7=$+1
		ld e,0
.off7=$+1
		add ixl			; 4+7+7+8=26t
.lb7

		add h
		sbc h
		ld l,a
		sbc a
		nop
		and 32    ;64;32;16			; 4+4+4 + 4+4+7=27t

;	out 	(254),a		; 11t
	ld	($6800),a
;	xor	64
;	out	(2), a


		ld a,l			; 4t

	IF slowDecay=1
		nop
		nop
	ELSE
		add h
		sbc h			; 4+4=8t
	ENDIF

		exx			; 4t

		dec l			; 4t

		jp nz,soundLoop		; 26*4+4+26*4+27+11+4+8+4+4+10=280t
		dec h
		jr nz,soundLoop

	IF storeA=1
		ld (readNotes.prevVol),a
	ENDIF

		xor a
;	out 	(254),a
	ld	($6800),a
;	xor	64
;	out	(2), a


	
		ld (readNotes.prevBC),bc
		jp rowEnd

.lc0		jp .lb0			; 4+12+10=26t
.lc1		jp .lb1			; 4+12+10=26t
.lc2		jp .lb2			; 4+12+10=26t
.lc3		jp .lb3			; 4+12+10=26t
.lc4		jp .lb4			; 4+12+10=26t
.lc5		jp .lb5			; 4+12+10=26t
.lc6		jp .lb6			; 4+12+10=26t
.lc7		jp .lb7			; 4+12+10=26t

		;ENDMODULE






; ---------------------------------------------------------
; NIGHT DANCER. Mr Beep. 2015. octode XL engine.  (M2)
; ---------------------------------------------------------
musicdata:
MLOOP:
 defw	PAT01	;	081FFh
 defw	PAT03	;	0861Fh
 defw	PAT02	;	08402h
 defw	PAT02	;	08402h
 defw	PAT04	;	0883Ch
 defw	PAT05	;	08a59h
 defw	PAT04	;	0883Ch
 defw	PAT05	;	08a59h
 defw	PAT08	;	090B2h
 defw	PAT09	;	092B6h
 defw	PAT06	;	08c76h
 defw	PAT10	;	094C6h
 defw	PAT11	;	096E2h
 defw	PAT12	;	098FBh
 defw	PAT13	;	09b14h
 defw	PAT14	;	09d31h
 defw	PAT15	;	09f4Fh
 defw	PAT16	;	0a15Bh
 defw	PAT13	;	09b14h
 defw	PAT18	;	0a589h
 defw	PAT13	;	09b14h
 defw	PAT17	;	0a36Bh
 defw	PAT06	;	08c76h
 defw	PAT07	;	08e96h
 defw	PAT06	;	08c76h
 defw	PAT10	;	094C6h
 defw	PAT08	;	090B2h
 defw	PAT19	;	0a7A7h
 defw	PAT20	;	0a9B4h
 defw	PAT21	;	0abBCh
 defw	PAT22	;	0adC0h
 defw	00000	; 	00000h
 defw	MLOOP	;	081BDh


; sequence order to work out the above pattern addressing.
; defw	081FFh 1
; defw	08402h 2
; defw	0861Fh 3
; defw	0883Ch 4
; defw	08a59h 5
; defw	08c76h 6
; defw	08e96h 7
; defw	090B2h 8
; defw	092B6h 9
; defw	094C6h 10
; defw	096E2h 11
; defw	098FBh 12
; defw	09b14h 13
; defw	09d31h 14
; defw	09f4Fh 15
; defw	0a15Bh 16
; defw	0a36Bh 17
; defw	0a589h 18
; defw	0a7A7h 19
; defw	0a9B4h 20
; defw	0abBCh 21
; defw	0adC0h 22

PAT01:
 defw 	06F7h
 defb 	0C2h, 0C3h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 061h, 062h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 061h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 0C3h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 061h, 062h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 061h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 0C3h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 061h, 062h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 061h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 0C3h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 061h, 062h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 061h, 062h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0A3h, 0A4h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0A3h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 052h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0A3h, 0A4h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0A3h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 052h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0A3h, 0A4h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0A3h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 052h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0A3h, 0A4h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0A3h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 052h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 0dbh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 06Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 0dbh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 06Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 0dbh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 06Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 0dbh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 06Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 06Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 07Ah, 07Bh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 07Ah, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 03Dh, 03Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 03Dh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 07Ah, 07Bh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 07Ah, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 03Dh, 03Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 03Dh, 03Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 0dbh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 06Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 0dbh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 06Eh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 06Dh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 001h

PAT02:
 defw	$06f7
 defb   004h
 defb 	 0C2h, 0C3h, 000h, 000h, 030h, 031h, 000h, 000h
 defb 	 0C2h, 000h, 000h, 000h, 036h, 000h, 000h, 000h
 defb 	 061h, 062h, 000h, 000h, 020h, 021h, 000h, 000h
 defb 	 061h, 000h, 000h, 000h, 030h, 000h, 000h, 000h
 defb 	 004h, 0C2h, 0C3h, 000h, 000h, 024h, 025h, 000h
 defb 	 000h, 0C2h, 000h, 000h, 000h, 020h, 000h, 000h
 defb 	 000h, 061h, 062h, 000h, 000h, 020h, 021h, 000h
 defb 	 000h, 061h, 000h, 000h, 000h, 030h, 031h, 000h
 defb 	 000h, 004h, 0C2h, 0C3h, 000h, 000h, 020h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 030h, 031h
 defb 	 000h, 000h, 061h, 062h, 000h, 000h, 020h, 021h
 defb 	 000h, 000h, 061h, 000h, 000h, 000h, 030h, 000h
 defb 	 000h, 000h, 004h, 0C2h, 0C3h, 000h, 000h, 024h
 defb 	 025h, 000h, 000h, 0C2h, 000h, 000h, 000h, 020h
 defb 	 000h, 000h, 000h, 061h, 062h, 000h, 000h, 028h
 defb 	 029h, 000h, 000h, 004h, 061h, 000h, 000h, 000h
 defb 	 024h, 000h, 000h, 000h, 004h, 0A3h, 0A4h, 000h
 defb 	 000h, 030h, 031h, 000h, 000h, 0A3h, 000h, 000h
 defb 	 000h, 028h, 000h, 000h, 000h, 051h, 052h, 000h
 defb 	 000h, 020h, 021h, 000h, 000h, 051h, 000h, 000h
 defb 	 000h, 030h, 000h, 000h, 000h, 004h, 0A3h, 0A4h
 defb 	 000h, 000h, 024h, 025h, 000h, 000h, 0A3h, 000h
 defb 	 000h, 000h, 020h, 000h, 000h, 000h, 051h, 052h
 defb 	 000h, 000h, 020h, 021h, 000h, 000h, 004h, 051h
 defb 	 000h, 000h, 000h, 030h, 031h, 000h, 000h, 004h
 defb 	 0A3h, 0A4h, 000h, 000h, 020h, 000h, 000h, 000h
 defb 	 0A3h, 000h, 000h, 000h, 030h, 031h, 000h, 000h
 defb 	 004h, 051h, 052h, 000h, 000h, 020h, 021h, 000h
 defb 	 000h, 051h, 000h, 000h, 000h, 030h, 000h, 000h
 defb 	 000h, 004h, 0A3h, 0A4h, 000h, 000h, 024h, 025h
 defb 	 000h, 000h, 004h, 0A3h, 000h, 000h, 000h, 020h
 defb 	 000h, 000h, 000h, 051h, 052h, 000h, 000h, 028h
 defb 	 029h, 000h, 000h, 051h, 000h, 000h, 000h, 024h
 defb 	 000h, 000h, 000h, 004h, 0DAh, 0dbh, 000h, 000h
 defb 	 036h, 037h, 000h, 000h, 0DAh, 000h, 000h, 000h
 defb 	 028h, 000h, 000h, 000h, 06Dh, 06Eh, 000h, 000h
 defb 	 024h, 025h, 000h, 000h, 06Dh, 000h, 000h, 000h
 defb 	 036h, 000h, 000h, 000h, 004h, 0DAh, 0dbh, 000h
 defb 	 000h, 028h, 029h, 000h, 000h, 0DAh, 000h, 000h
 defb 	 000h, 024h, 000h, 000h, 000h, 06Dh, 06Eh, 000h
 defb 	 000h, 024h, 025h, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 036h, 037h, 000h, 000h, 004h, 0DAh, 0dbh
 defb 	 000h, 000h, 024h, 000h, 000h, 000h, 0DAh, 000h
 defb 	 000h, 000h, 036h, 037h, 000h, 000h, 06Dh, 06Eh
 defb 	 000h, 000h, 024h, 025h, 000h, 000h, 06Dh, 000h
 defb 	 000h, 000h, 036h, 000h, 000h, 000h, 004h, 0DAh
 defb 	 0dbh, 000h, 000h, 028h, 029h, 000h, 000h, 0DAh
 defb 	 000h, 000h, 000h, 024h, 000h, 000h, 000h, 06Dh
 defb 	 06Eh, 000h, 000h, 02Bh, 02Ch, 000h, 000h, 004h
 defb 	 06Dh, 000h, 000h, 000h, 028h, 000h, 000h, 000h
 defb 	 004h, 07Ah, 07Bh, 000h, 000h, 03Dh, 03Eh, 000h
 defb 	 000h, 07Ah, 000h, 000h, 000h, 02Bh, 000h, 000h
 defb 	 000h, 03Dh, 03Eh, 000h, 000h, 028h, 029h, 000h
 defb 	 000h, 03Dh, 000h, 000h, 000h, 03Dh, 000h, 000h
 defb 	 000h, 004h, 07Ah, 07Bh, 000h, 000h, 02Bh, 02Ch
 defb 	 000h, 000h, 07Ah, 000h, 000h, 000h, 028h, 000h
 defb 	 000h, 000h, 03Dh, 03Eh, 000h, 000h, 030h, 031h
 defb 	 000h, 000h, 004h, 03Dh, 000h, 000h, 000h, 036h
 defb 	 037h, 000h, 000h, 004h, 0DAh, 0dbh, 000h, 000h
 defb 	 030h, 000h, 000h, 000h, 004h, 0DAh, 000h, 000h
 defb 	 000h, 036h, 037h, 000h, 000h, 06Dh, 06Eh, 000h
 defb 	 000h, 024h, 025h, 000h, 000h, 004h, 06Dh, 000h
 defb 	 000h, 000h, 036h, 000h, 000h, 000h, 004h, 0DAh
 defb 	 0dbh, 000h, 000h, 028h, 029h, 000h, 000h, 0DAh
 defb 	 000h, 000h, 000h, 024h, 000h, 000h, 000h, 004h
 defb 	 06Dh, 06Eh, 000h, 000h, 02Bh, 02Ch, 000h, 000h
 defb 	 004h, 06Dh, 000h, 000h, 000h, 028h, 000h, 000h
 defb 	 000h, 001h

PAT03:
 defw 	006F7h
 defb   004h, 0C2h, 0C3h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 061h, 062h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 004h, 0C2h, 0C3h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 0C2h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 061h, 062h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 061h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 004h, 0C2h
 defb 	 0C3h, 000h, 000h, 000h, 000h, 000h, 000h, 0C2h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 061h
 defb 	 062h, 000h, 000h, 000h, 000h, 000h, 000h, 061h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 004h
 defb 	 0C2h, 0C3h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 0C2h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 004h, 061h, 062h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 061h, 062h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 004h, 0A3h, 0A4h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0A3h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 051h, 052h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 051h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 004h, 0A3h, 0A4h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 0A3h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 051h, 052h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 051h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 004h, 0A3h, 0A4h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0A3h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 052h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 051h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 004h, 0A3h, 0A4h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 0A3h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 004h, 051h, 052h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 004h, 051h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 004h
 defb 	 0DAh, 0dbh, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 0DAh, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 06Dh, 06Eh, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 06Dh, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 004h, 0DAh, 0dbh, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 0DAh, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 06Dh, 06Eh, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 06Dh, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 004h, 0DAh, 0dbh, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 06Dh, 06Eh, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 004h, 06Dh, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 004h, 0DAh, 0dbh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 004h, 06Dh, 06Eh, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 06Dh, 06Eh, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 004h, 07Ah, 07Bh
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 07Ah, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 03Dh, 03Eh
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 03Dh, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 004h, 07Ah
 defb 	 07Bh, 000h, 000h, 000h, 000h, 000h, 000h, 07Ah
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 03Dh
 defb 	 03Eh, 000h, 000h, 000h, 000h, 000h, 000h, 004h
 defb 	 03Dh, 03Eh, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 004h, 0DAh, 0dbh, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 004h, 0DAh, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 06Dh, 06Eh, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 004h, 06Dh, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 004h, 0DAh, 0dbh, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 0DAh, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 004h, 06Dh, 06Eh, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 004h, 06Dh, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 001h

PAT04:
 defw 	006F7h
 defb 	 004h, 0C2h, 0C3h, 0C2h, 061h, 030h, 030h
 defb 	 030h, 030h, 0C2h, 000h, 0C2h, 061h, 036h, 000h
 defb 	 030h, 030h, 061h, 062h, 061h, 061h, 020h, 020h
 defb 	 030h, 030h, 061h, 000h, 061h, 061h, 030h, 000h
 defb 	 000h, 030h, 004h, 0C2h, 0C3h, 0C2h, 000h, 024h
 defb 	 024h, 000h, 000h, 0C2h, 000h, 0C2h, 000h, 020h
 defb 	 000h, 000h, 000h, 061h, 062h, 061h, 000h, 020h
 defb 	 020h, 000h, 000h, 061h, 000h, 061h, 000h, 030h
 defb 	 030h, 000h, 000h, 004h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 020h, 000h, 000h, 000h, 0C2h, 000h, 0C2h, 000h
 defb 	 030h, 030h, 000h, 000h, 061h, 062h, 061h, 040h
 defb 	 020h, 020h, 020h, 020h, 061h, 000h, 061h, 000h
 defb 	 030h, 000h, 000h, 020h, 004h, 0C2h, 0C3h, 0C2h
 defb 	 048h, 024h, 024h, 024h, 024h, 0C2h, 000h, 0C2h
 defb 	 000h, 020h, 000h, 024h, 024h, 004h, 061h, 062h
 defb 	 061h, 051h, 028h, 028h, 028h, 028h, 061h, 000h
 defb 	 061h, 000h, 024h, 000h, 028h, 028h, 004h, 0A3h
 defb 	 0A4h, 0A3h, 048h, 030h, 030h, 024h, 024h, 0A3h
 defb 	 000h, 0A3h, 000h, 028h, 000h, 024h, 024h, 051h
 defb 	 052h, 051h, 040h, 020h, 020h, 020h, 020h, 051h
 defb 	 000h, 051h, 000h, 030h, 000h, 000h, 020h, 004h
 defb 	 0A3h, 0A4h, 0A3h, 048h, 024h, 024h, 024h, 024h
 defb 	 0A3h, 000h, 0A3h, 000h, 020h, 000h, 024h, 024h
 defb 	 051h, 052h, 051h, 051h, 020h, 020h, 028h, 028h
 defb 	 051h, 000h, 051h, 000h, 030h, 030h, 028h, 028h
 defb 	 004h, 0A3h, 0A4h, 0A3h, 048h, 020h, 000h, 024h
 defb 	 024h, 0A3h, 000h, 0A3h, 000h, 030h, 030h, 024h
 defb 	 024h, 051h, 052h, 051h, 051h, 020h, 020h, 028h
 defb 	 028h, 051h, 000h, 051h, 000h, 030h, 000h, 028h
 defb 	 028h, 004h, 0A3h, 0A4h, 0A3h, 06Dh, 024h, 024h
 defb 	 036h, 036h, 0A3h, 000h, 0A3h, 000h, 020h, 000h
 defb 	 036h, 036h, 004h, 051h, 052h, 051h, 051h, 028h
 defb 	 028h, 028h, 028h, 004h, 051h, 000h, 051h, 000h
 defb 	 024h, 000h, 028h, 028h, 004h, 0DAh, 0dbh, 0DAh
 defb 	 048h, 036h, 036h, 024h, 024h, 0DAh, 000h, 0DAh
 defb 	 048h, 028h, 000h, 024h, 024h, 06Dh, 06Eh, 06Dh
 defb 	 048h, 024h, 024h, 024h, 024h, 06Dh, 000h, 06Dh
 defb 	 048h, 036h, 000h, 000h, 024h, 004h, 0DAh, 0dbh
 defb 	 0DAh, 000h, 028h, 028h, 000h, 000h, 0DAh, 000h
 defb 	 0DAh, 000h, 024h, 000h, 000h, 000h, 06Dh, 06Eh
 defb 	 06Dh, 000h, 024h, 024h, 000h, 000h, 06Dh, 000h
 defb 	 06Dh, 000h, 036h, 036h, 000h, 000h, 004h, 0DAh
 defb 	 0dbh, 0DAh, 000h, 024h, 000h, 000h, 000h, 0DAh
 defb 	 000h, 0DAh, 000h, 036h, 036h, 000h, 000h, 06Dh
 defb 	 06Eh, 06Dh, 040h, 024h, 024h, 020h, 020h, 004h
 defb 	 06Dh, 000h, 06Dh, 000h, 036h, 000h, 000h, 020h
 defb 	 004h, 0DAh, 0dbh, 0DAh, 048h, 028h, 028h, 024h
 defb 	 024h, 0DAh, 000h, 0DAh, 000h, 024h, 000h, 024h
 defb 	 024h, 004h, 06Dh, 06Eh, 06Dh, 051h, 02Bh, 02Bh
 defb 	 028h, 028h, 06Dh, 000h, 06Dh, 000h, 028h, 000h
 defb 	 028h, 028h, 004h, 07Ah, 07Bh, 07Ah, 061h, 03Dh
 defb 	 03Dh, 030h, 030h, 07Ah, 000h, 07Ah, 061h, 02Bh
 defb 	 000h, 030h, 030h, 03Dh, 03Eh, 03Dh, 061h, 028h
 defb 	 028h, 030h, 030h, 03Dh, 000h, 03Dh, 061h, 03Dh
 defb 	 000h, 000h, 030h, 004h, 07Ah, 07Bh, 07Ah, 000h
 defb 	 02Bh, 02Bh, 000h, 000h, 07Ah, 000h, 07Ah, 000h
 defb 	 028h, 000h, 000h, 000h, 03Dh, 03Eh, 03Dh, 000h
 defb 	 030h, 030h, 000h, 000h, 004h, 03Dh, 000h, 03Dh
 defb 	 000h, 036h, 036h, 000h, 000h, 004h, 0DAh, 0dbh
 defb 	 0DAh, 03Dh, 030h, 000h, 01Eh, 01Eh, 004h, 0DAh
 defb 	 000h, 0DAh, 000h, 036h, 036h, 000h, 000h, 06Dh
 defb 	 06Eh, 06Dh, 040h, 024h, 024h, 020h, 020h, 004h
 defb 	 06Dh, 000h, 06Dh, 048h, 036h, 000h, 024h, 024h
 defb 	 004h, 0DAh, 0dbh, 0DAh, 000h, 028h, 028h, 000h
 defb 	 000h, 0DAh, 000h, 0DAh, 048h, 024h, 000h, 024h
 defb 	 024h, 004h, 06Dh, 06Eh, 06Dh, 03Dh, 02Bh, 02Bh
 defb 	 01Eh, 01Eh, 004h, 06Dh, 000h, 06Dh, 000h, 028h
 defb 	 000h, 000h, 000h, 001h

PAT05:
 defw 	006F7h
 defb  004h, 0C2h
 defb 	 0C3h, 0C2h, 061h, 030h, 030h, 030h, 030h, 0C2h
 defb 	 000h, 0C2h, 061h, 036h, 000h, 030h, 030h, 061h
 defb 	 062h, 061h, 061h, 020h, 020h, 030h, 030h, 061h
 defb 	 000h, 061h, 061h, 030h, 000h, 000h, 030h, 004h
 defb 	 0C2h, 0C3h, 0C2h, 000h, 024h, 024h, 000h, 000h
 defb 	 0C2h, 000h, 0C2h, 000h, 020h, 000h, 000h, 000h
 defb 	 061h, 062h, 061h, 000h, 020h, 020h, 000h, 000h
 defb 	 061h, 000h, 061h, 000h, 030h, 030h, 000h, 000h
 defb 	 004h, 0C2h, 0C3h, 0C2h, 000h, 020h, 000h, 000h
 defb 	 000h, 0C2h, 000h, 0C2h, 000h, 030h, 030h, 000h
 defb 	 000h, 061h, 062h, 061h, 040h, 020h, 020h, 020h
 defb 	 020h, 061h, 000h, 061h, 000h, 030h, 000h, 000h
 defb 	 020h, 004h, 0C2h, 0C3h, 0C2h, 048h, 024h, 024h
 defb 	 024h, 024h, 0C2h, 000h, 0C2h, 000h, 020h, 000h
 defb 	 024h, 024h, 004h, 061h, 062h, 061h, 051h, 028h
 defb 	 028h, 028h, 028h, 061h, 000h, 061h, 000h, 024h
 defb 	 000h, 028h, 028h, 004h, 0A3h, 0A4h, 0A3h, 048h
 defb 	 030h, 030h, 024h, 024h, 0A3h, 000h, 0A3h, 000h
 defb 	 028h, 000h, 024h, 024h, 051h, 052h, 051h, 051h
 defb 	 020h, 020h, 028h, 028h, 051h, 000h, 051h, 000h
 defb 	 030h, 000h, 028h, 028h, 004h, 0A3h, 0A4h, 0A3h
 defb 	 06Dh, 024h, 024h, 036h, 036h, 0A3h, 000h, 0A3h
 defb 	 000h, 020h, 000h, 036h, 036h, 051h, 052h, 051h
 defb 	 051h, 020h, 020h, 028h, 028h, 051h, 000h, 051h
 defb 	 000h, 030h, 030h, 028h, 028h, 004h, 0A3h, 0A4h
 defb 	 0A3h, 048h, 020h, 000h, 024h, 024h, 0A3h, 000h
 defb 	 0A3h, 000h, 030h, 030h, 024h, 024h, 051h, 052h
 defb 	 051h, 040h, 020h, 020h, 020h, 020h, 051h, 000h
 defb 	 051h, 000h, 030h, 000h, 000h, 020h, 004h, 0A3h
 defb 	 0A4h, 0A3h, 03Dh, 024h, 024h, 01Eh, 01Eh, 0A3h
 defb 	 000h, 0A3h, 000h, 020h, 000h, 000h, 01Eh, 004h
 defb 	 051h, 052h, 051h, 040h, 028h, 028h, 020h, 020h
 defb 	 004h, 051h, 000h, 051h, 000h, 024h, 000h, 000h
 defb 	 020h, 004h, 0DAh, 0dbh, 0DAh, 048h, 036h, 036h
 defb 	 024h, 024h, 0DAh, 000h, 0DAh, 048h, 028h, 000h
 defb 	 024h, 024h, 06Dh, 06Eh, 06Dh, 048h, 024h, 024h
 defb 	 024h, 024h, 06Dh, 000h, 06Dh, 048h, 036h, 000h
 defb 	 000h, 024h, 004h, 0DAh, 0dbh, 0DAh, 000h, 028h
 defb 	 028h, 000h, 000h, 0DAh, 000h, 0DAh, 000h, 024h
 defb 	 000h, 000h, 000h, 06Dh, 06Eh, 06Dh, 000h, 024h
 defb 	 024h, 000h, 000h, 06Dh, 000h, 06Dh, 000h, 036h
 defb 	 036h, 000h, 000h, 004h, 0DAh, 0dbh, 0DAh, 000h
 defb 	 024h, 000h, 000h, 000h, 0DAh, 000h, 0DAh, 000h
 defb 	 036h, 036h, 000h, 000h, 06Dh, 06Eh, 06Dh, 051h
 defb 	 024h, 024h, 028h, 028h, 004h, 06Dh, 000h, 06Dh
 defb 	 000h, 036h, 000h, 028h, 000h, 004h, 0DAh, 0dbh
 defb 	 0DAh, 048h, 028h, 028h, 024h, 024h, 0DAh, 000h
 defb 	 0DAh, 000h, 024h, 000h, 024h, 000h, 004h, 06Dh
 defb 	 06Eh, 06Dh, 040h, 02Bh, 02Bh, 020h, 020h, 06Dh
 defb 	 000h, 06Dh, 000h, 028h, 000h, 000h, 000h, 004h
 defb 	 07Ah, 07Bh, 07Ah, 03Dh, 03Dh, 03Dh, 01Eh, 01Eh
 defb 	 07Ah, 000h, 07Ah, 000h, 02Bh, 000h, 000h, 000h
 defb 	 03Dh, 03Eh, 03Dh, 040h, 028h, 028h, 020h, 020h
 defb 	 03Dh, 000h, 03Dh, 048h, 03Dh, 000h, 024h, 024h
 defb 	 004h, 07Ah, 07Bh, 07Ah, 000h, 02Bh, 02Bh, 000h
 defb 	 000h, 07Ah, 000h, 07Ah, 048h, 028h, 000h, 024h
 defb 	 024h, 03Dh, 03Eh, 03Dh, 051h, 030h, 030h, 028h
 defb 	 028h, 004h, 03Dh, 000h, 03Dh, 000h, 036h, 036h
 defb 	 000h, 000h, 004h, 0DAh, 0dbh, 0DAh, 056h, 030h
 defb 	 000h, 02Bh, 02Bh, 004h, 0DAh, 000h, 0DAh, 000h
 defb 	 036h, 036h, 000h, 000h, 06Dh, 06Eh, 06Dh, 061h
 defb 	 024h, 024h, 030h, 030h, 004h, 06Dh, 000h, 06Dh
 defb 	 06Dh, 036h, 000h, 036h, 036h, 004h, 0DAh, 0dbh
 defb 	 0DAh, 000h, 028h, 028h, 000h, 000h, 0DAh, 000h
 defb 	 0DAh, 06Dh, 024h, 000h, 036h, 036h, 004h, 06Dh
 defb 	 06Eh, 06Dh, 081h, 02Bh, 02Bh, 040h, 040h, 004h
 defb 	 06Dh, 000h, 06Dh, 000h, 028h, 000h, 000h, 000h
 defb 	 001h

PAT06:
 defw 	006F7h
 defb 	  004h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 03Dh, 030h, 062h, 030h, 000h, 000h, 07Ah, 061h
 defb 	 03Dh, 030h, 062h, 030h, 03Dh, 03Eh, 03Dh, 061h
 defb 	 000h, 000h, 062h, 030h, 000h, 000h, 03Dh, 061h
 defb 	 03Dh, 030h, 062h, 030h, 009h, 07Ah, 07Bh, 07Ah
 defb 	 061h, 03Dh, 030h, 062h, 030h, 000h, 000h, 07Ah
 defb 	 061h, 000h, 000h, 062h, 030h, 03Dh, 03Eh, 03Dh
 defb 	 061h, 03Dh, 030h, 062h, 030h, 004h, 000h, 000h
 defb 	 03Dh, 061h, 03Dh, 030h, 062h, 030h, 004h, 07Ah
 defb 	 07Bh, 07Ah, 061h, 000h, 000h, 062h, 030h, 000h
 defb 	 000h, 07Ah, 061h, 03Dh, 030h, 062h, 030h, 03Dh
 defb 	 03Eh, 03Dh, 06Dh, 03Dh, 030h, 06Eh, 036h, 000h
 defb 	 000h, 03Dh, 06Dh, 000h, 000h, 06Eh, 036h, 009h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 03Dh, 030h, 062h, 030h
 defb 	 000h, 000h, 07Ah, 061h, 000h, 000h, 062h, 030h
 defb 	 03Dh, 03Eh, 03Dh, 056h, 03Dh, 030h, 057h, 02Bh
 defb 	 000h, 000h, 03Dh, 056h, 000h, 000h, 057h, 02Bh
 defb 	 004h, 0DAh, 0dbh, 0DAh, 056h, 036h, 02Bh, 057h
 defb 	 02Bh, 000h, 000h, 0DAh, 056h, 036h, 02Bh, 057h
 defb 	 02Bh, 004h, 06Dh, 06Eh, 06Dh, 056h, 000h, 000h
 defb 	 057h, 02Bh, 000h, 000h, 06Dh, 056h, 036h, 02Bh
 defb 	 057h, 02Bh, 009h, 0DAh, 0dbh, 0DAh, 056h, 036h
 defb 	 02Bh, 057h, 02Bh, 004h, 000h, 000h, 0DAh, 056h
 defb 	 000h, 000h, 057h, 02Bh, 06Dh, 06Eh, 06Dh, 056h
 defb 	 036h, 02Bh, 057h, 02Bh, 004h, 000h, 000h, 06Dh
 defb 	 056h, 036h, 02Bh, 057h, 02Bh, 004h, 0DAh, 0dbh
 defb 	 0DAh, 056h, 000h, 000h, 057h, 02Bh, 000h, 000h
 defb 	 0DAh, 056h, 036h, 02Bh, 057h, 02Bh, 06Dh, 06Eh
 defb 	 06Dh, 061h, 036h, 02Bh, 062h, 030h, 000h, 000h
 defb 	 06Dh, 061h, 000h, 000h, 062h, 030h, 009h, 0DAh
 defb 	 0dbh, 0DAh, 056h, 036h, 02Bh, 057h, 02Bh, 000h
 defb 	 000h, 0DAh, 056h, 000h, 000h, 057h, 02Bh, 06Dh
 defb 	 06Eh, 06Dh, 051h, 036h, 02Bh, 052h, 028h, 000h
 defb 	 000h, 06Dh, 051h, 000h, 000h, 052h, 028h, 004h
 defb 	 0C2h, 0C3h, 0C2h, 051h, 051h, 040h, 052h, 028h
 defb 	 000h, 000h, 0C2h, 051h, 051h, 040h, 052h, 028h
 defb 	 061h, 062h, 061h, 051h, 000h, 000h, 052h, 028h
 defb 	 000h, 000h, 061h, 051h, 051h, 040h, 052h, 028h
 defb 	 009h, 0C2h, 0C3h, 0C2h, 051h, 051h, 040h, 052h
 defb 	 028h, 000h, 000h, 0C2h, 051h, 000h, 000h, 052h
 defb 	 028h, 061h, 062h, 061h, 056h, 051h, 040h, 057h
 defb 	 02Bh, 004h, 000h, 000h, 061h, 056h, 051h, 040h
 defb 	 057h, 02Bh, 004h, 0C2h, 0C3h, 0C2h, 056h, 000h
 defb 	 000h, 057h, 02Bh, 000h, 000h, 0C2h, 056h, 051h
 defb 	 040h, 057h, 02Bh, 061h, 062h, 061h, 056h, 051h
 defb 	 040h, 057h, 02Bh, 000h, 000h, 061h, 056h, 000h
 defb 	 000h, 057h, 02Bh, 009h, 0C2h, 0C3h, 0C2h, 06Dh
 defb 	 051h, 040h, 06Eh, 036h, 000h, 000h, 0C2h, 06Dh
 defb 	 000h, 000h, 06Eh, 036h, 061h, 062h, 061h, 081h
 defb 	 051h, 040h, 082h, 040h, 000h, 000h, 061h, 081h
 defb 	 000h, 000h, 082h, 040h, 004h, 0DAh, 0dbh, 0DAh
 defb 	 081h, 036h, 02Bh, 082h, 040h, 000h, 000h, 0DAh
 defb 	 081h, 036h, 02Bh, 082h, 040h, 004h, 06Dh, 06Eh
 defb 	 06Dh, 081h, 000h, 000h, 082h, 040h, 000h, 000h
 defb 	 06Dh, 081h, 036h, 02Bh, 082h, 040h, 009h, 0DAh
 defb 	 0dbh, 0DAh, 056h, 036h, 02Bh, 057h, 02Bh, 004h
 defb 	 000h, 000h, 0DAh, 056h, 000h, 000h, 057h, 02Bh
 defb 	 06Dh, 06Eh, 06Dh, 056h, 036h, 02Bh, 057h, 02Bh
 defb 	 004h, 000h, 000h, 06Dh, 056h, 036h, 02Bh, 057h
 defb 	 02Bh, 004h, 0DAh, 0dbh, 0DAh, 056h, 000h, 000h
 defb 	 057h, 02Bh, 009h, 000h, 000h, 0DAh, 056h, 036h
 defb 	 02Bh, 057h, 02Bh, 009h, 06Dh, 06Eh, 06Dh, 061h
 defb 	 036h, 02Bh, 062h, 030h, 009h, 000h, 000h, 06Dh
 defb 	 061h, 000h, 000h, 062h, 030h, 009h, 0DAh, 0dbh
 defb 	 0DAh, 06Dh, 036h, 02Bh, 06Eh, 036h, 000h, 000h
 defb 	 0DAh, 06Dh, 000h, 000h, 06Eh, 036h, 009h, 06Dh
 defb 	 06Eh, 06Dh, 061h, 036h, 02Bh, 062h, 030h, 009h
 defb 	 000h, 000h, 06Dh, 061h, 000h, 000h, 062h, 030h
 defb 	 001h

PAT07:
 defw 	06F7h
 defb 	 004h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 03Dh, 030h, 062h, 030h, 000h, 000h, 07Ah, 061h
 defb 	 03Dh, 030h, 062h, 030h, 03Dh, 03Eh, 03Dh, 061h
 defb 	 000h, 000h, 062h, 030h, 000h, 000h, 03Dh, 061h
 defb 	 03Dh, 030h, 062h, 030h, 009h, 07Ah, 07Bh, 07Ah
 defb 	 061h, 03Dh, 030h, 062h, 030h, 000h, 000h, 07Ah
 defb 	 061h, 000h, 000h, 062h, 030h, 03Dh, 03Eh, 03Dh
 defb 	 061h, 03Dh, 030h, 062h, 030h, 004h, 000h, 000h
 defb 	 03Dh, 061h, 03Dh, 030h, 062h, 030h, 004h, 07Ah
 defb 	 07Bh, 07Ah, 061h, 000h, 000h, 062h, 030h, 000h
 defb 	 000h, 07Ah, 061h, 03Dh, 030h, 062h, 030h, 03Dh
 defb 	 03Eh, 03Dh, 06Dh, 03Dh, 030h, 06Eh, 036h, 000h
 defb 	 000h, 03Dh, 06Dh, 000h, 000h, 06Eh, 036h, 009h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 03Dh, 030h, 062h, 030h
 defb 	 000h, 000h, 07Ah, 061h, 000h, 000h, 062h, 030h
 defb 	 03Dh, 03Eh, 03Dh, 056h, 03Dh, 030h, 057h, 02Bh
 defb 	 000h, 000h, 03Dh, 056h, 000h, 000h, 057h, 02Bh
 defb 	 004h, 0DAh, 0dbh, 0DAh, 056h, 036h, 02Bh, 057h
 defb 	 02Bh, 000h, 000h, 0DAh, 056h, 036h, 02Bh, 057h
 defb 	 02Bh, 004h, 06Dh, 06Eh, 06Dh, 056h, 000h, 000h
 defb 	 057h, 02Bh, 000h, 000h, 06Dh, 056h, 036h, 02Bh
 defb 	 057h, 02Bh, 009h, 0DAh, 0dbh, 0DAh, 056h, 036h
 defb 	 02Bh, 057h, 02Bh, 004h, 000h, 000h, 0DAh, 056h
 defb 	 000h, 000h, 057h, 02Bh, 06Dh, 06Eh, 06Dh, 061h
 defb 	 036h, 02Bh, 062h, 030h, 004h, 000h, 000h, 06Dh
 defb 	 061h, 036h, 02Bh, 062h, 030h, 004h, 0DAh, 0dbh
 defb 	 0DAh, 061h, 000h, 000h, 062h, 030h, 000h, 000h
 defb 	 0DAh, 061h, 036h, 02Bh, 062h, 030h, 06Dh, 06Eh
 defb 	 06Dh, 061h, 036h, 02Bh, 062h, 030h, 000h, 000h
 defb 	 06Dh, 061h, 000h, 000h, 062h, 030h, 009h, 0DAh
 defb 	 0dbh, 0DAh, 06Dh, 036h, 02Bh, 06Eh, 036h, 000h
 defb 	 000h, 0DAh, 06Dh, 000h, 000h, 06Eh, 036h, 06Dh
 defb 	 06Eh, 06Dh, 061h, 036h, 02Bh, 062h, 030h, 000h
 defb 	 000h, 06Dh, 061h, 000h, 000h, 062h, 030h, 004h
 defb 	 0C2h, 0C3h, 0C2h, 061h, 040h, 028h, 062h, 030h
 defb 	 000h, 000h, 0C2h, 061h, 040h, 028h, 062h, 030h
 defb 	 061h, 062h, 061h, 061h, 000h, 000h, 062h, 030h
 defb 	 000h, 000h, 061h, 061h, 040h, 028h, 062h, 030h
 defb 	 009h, 0C2h, 0C3h, 0C2h, 061h, 040h, 028h, 000h
 defb 	 030h, 000h, 000h, 0C2h, 000h, 000h, 000h, 000h
 defb 	 030h, 061h, 062h, 061h, 000h, 040h, 028h, 000h
 defb 	 000h, 004h, 000h, 000h, 061h, 000h, 040h, 028h
 defb 	 000h, 000h, 004h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 0C2h, 000h, 040h
 defb 	 028h, 000h, 000h, 004h, 061h, 062h, 061h, 000h
 defb 	 040h, 028h, 000h, 000h, 000h, 000h, 061h, 000h
 defb 	 000h, 000h, 000h, 000h, 009h, 0C2h, 0C3h, 0C2h
 defb 	 000h, 040h, 028h, 000h, 000h, 004h, 000h, 000h
 defb 	 0C2h, 000h, 000h, 000h, 000h, 000h, 061h, 062h
 defb 	 061h, 000h, 040h, 028h, 000h, 000h, 004h, 000h
 defb 	 000h, 061h, 000h, 000h, 000h, 000h, 000h, 004h
 defb 	 0C2h, 0C3h, 0C2h, 000h, 040h, 028h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 040h, 028h, 000h, 000h
 defb 	 061h, 062h, 061h, 040h, 000h, 000h, 041h, 020h
 defb 	 000h, 000h, 061h, 040h, 040h, 028h, 041h, 020h
 defb 	 0C2h, 0C3h, 0C2h, 048h, 040h, 028h, 049h, 024h
 defb 	 000h, 000h, 0C2h, 048h, 000h, 000h, 049h, 024h
 defb 	 061h, 062h, 061h, 051h, 040h, 028h, 052h, 028h
 defb 	 000h, 000h, 061h, 051h, 040h, 028h, 052h, 028h
 defb 	 0C2h, 0C3h, 0C2h, 056h, 000h, 000h, 057h, 02Bh
 defb 	 000h, 000h, 0C2h, 056h, 040h, 028h, 057h, 02Bh
 defb 	 009h, 061h, 062h, 061h, 06Dh, 040h, 028h, 06Eh
 defb 	 036h, 000h, 000h, 061h, 06Dh, 000h, 000h, 06Eh
 defb 	 036h, 009h, 0C2h, 0C3h, 0C2h, 081h, 040h, 028h
 defb 	 082h, 040h, 000h, 000h, 0C2h, 081h, 000h, 000h
 defb 	 082h, 040h, 009h, 061h, 062h, 061h, 06Dh, 040h
 defb 	 028h, 06Eh, 036h, 009h, 000h, 000h, 061h, 06Dh
 defb 	 000h, 000h, 06Eh, 036h, 001h

PAT08:
 defw 	006F7h
 defb 	 004h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 000h, 000h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 000h, 000h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 000h, 000h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 061h, 030h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 061h, 030h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 061h, 030h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 061h, 030h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 061h, 030h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 061h, 030h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 061h, 030h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 06Dh, 061h, 030h, 06Eh, 036h
 defb 	 07Ah, 07Bh, 07Ah, 06Dh, 061h, 030h, 06Eh, 036h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 061h, 030h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 06Dh, 036h, 062h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 056h, 06Dh, 036h, 057h, 02Bh
 defb 	 07Ah, 07Bh, 07Ah, 056h, 061h, 030h, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 061h, 030h, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 061h, 056h, 02Bh, 062h, 030h
 defb 	 0DAh, 0dbh, 0DAh, 061h, 056h, 02Bh, 062h, 030h
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 061h, 030h, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 051h, 061h, 030h, 052h, 028h
 defb 	 0DAh, 0dbh, 0DAh, 051h, 056h, 02Bh, 052h, 028h
 defb 	 0C2h, 0C3h, 0C2h, 051h, 056h, 02Bh, 052h, 028h
 defb 	 0C2h, 0C3h, 0C2h, 051h, 051h, 028h, 052h, 028h
 defb 	 0C2h, 0C3h, 0C2h, 051h, 051h, 028h, 052h, 028h
 defb 	 0C2h, 0C3h, 0C2h, 051h, 051h, 028h, 052h, 028h
 defb 	 0C2h, 0C3h, 0C2h, 051h, 051h, 028h, 052h, 028h
 defb 	 0C2h, 0C3h, 0C2h, 051h, 051h, 028h, 052h, 028h
 defb 	 0C2h, 0C3h, 0C2h, 056h, 051h, 028h, 057h, 02Bh
 defb 	 0C2h, 0C3h, 0C2h, 056h, 051h, 028h, 057h, 02Bh
 defb 	 0C2h, 0C3h, 0C2h, 056h, 051h, 028h, 057h, 02Bh
 defb 	 0C2h, 0C3h, 0C2h, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0C2h, 0C3h, 0C2h, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0C2h, 0C3h, 0C2h, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0C2h, 0C3h, 0C2h, 06Dh, 056h, 02Bh, 06Eh, 036h
 defb 	 0C2h, 0C3h, 0C2h, 06Dh, 056h, 02Bh, 06Eh, 036h
 defb 	 0C2h, 0C3h, 0C2h, 081h, 056h, 02Bh, 082h, 040h
 defb 	 0C2h, 0C3h, 0C2h, 081h, 06Dh, 036h, 082h, 040h
 defb 	 0DAh, 0dbh, 0DAh, 081h, 06Dh, 036h, 082h, 040h
 defb 	 0DAh, 0dbh, 0DAh, 081h, 081h, 040h, 082h, 040h
 defb 	 0DAh, 0dbh, 0DAh, 081h, 081h, 040h, 082h, 040h
 defb 	 0DAh, 0dbh, 0DAh, 081h, 081h, 040h, 082h, 040h
 defb 	 0DAh, 0dbh, 0DAh, 056h, 081h, 040h, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 081h, 040h, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 081h, 040h, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 056h, 056h, 02Bh, 057h, 02Bh
 defb 	 0DAh, 0dbh, 0DAh, 061h, 056h, 02Bh, 062h, 030h
 defb 	 0DAh, 0dbh, 0DAh, 061h, 056h, 02Bh, 062h, 030h
 defb 	 0DAh, 0dbh, 0DAh, 06Dh, 056h, 02Bh, 06Eh, 036h
 defb 	 0DAh, 0dbh, 0DAh, 06Dh, 061h, 030h, 06Eh, 036h
 defb 	 0DAh, 0dbh, 0DAh, 061h, 061h, 030h, 062h, 030h
 defb 	 0DAh, 0dbh, 0DAh, 061h, 06Dh, 036h, 062h, 030h
 defb 	 001h

PAT09:
 defw 	006F7h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 000h
 defb 	 000h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 000h
 defb 	 000h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 000h
 defb 	 000h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 061h
 defb 	 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 061h
 defb 	 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 061h
 defb 	 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 061h
 defb 	 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 061h
 defb 	 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 061h
 defb 	 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 061h
 defb 	 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 06Dh, 061h
 defb 	 030h, 06Eh, 036h, 07Ah, 07Bh, 07Ah, 06Dh, 061h
 defb 	 030h, 06Eh, 036h, 07Ah, 07Bh, 07Ah, 061h, 061h
 defb 	 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h, 06Dh
 defb 	 036h, 062h, 030h, 07Ah, 07Bh, 07Ah, 056h, 06Dh
 defb 	 036h, 057h, 02Bh, 07Ah, 07Bh, 07Ah, 056h, 061h
 defb 	 030h, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h, 061h
 defb 	 030h, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h, 056h
 defb 	 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h, 056h
 defb 	 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h, 056h
 defb 	 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h, 056h
 defb 	 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h, 056h
 defb 	 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 061h, 056h
 defb 	 02Bh, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h, 056h
 defb 	 02Bh, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h, 056h
 defb 	 02Bh, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h, 061h
 defb 	 030h, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h, 061h
 defb 	 030h, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h, 061h
 defb 	 030h, 062h, 030h, 0DAh, 0dbh, 0DAh, 06Dh, 061h
 defb 	 030h, 06Eh, 036h, 0DAh, 0dbh, 0DAh, 06Dh, 061h
 defb 	 030h, 06Eh, 036h, 0DAh, 0dbh, 0DAh, 061h, 061h
 defb 	 030h, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h, 06Dh
 defb 	 036h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h, 06Dh
 defb 	 036h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h, 061h
 defb 	 030h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h, 061h
 defb 	 030h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h, 061h
 defb 	 030h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h, 061h
 defb 	 030h, 000h, 030h, 0C2h, 0C3h, 0C2h, 000h, 061h
 defb 	 030h, 000h, 030h, 0C2h, 0C3h, 0C2h, 000h, 061h
 defb 	 030h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h, 061h
 defb 	 030h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 030h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 009h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 000h, 000h, 000h, 000h, 009h, 0C2h, 0C3h, 0C2h
 defb 	 000h, 000h, 000h, 000h, 000h, 0C2h, 0C3h, 0C2h
 defb 	 040h, 000h, 000h, 041h, 020h, 009h, 0C2h, 0C3h
 defb 	 0C2h, 040h, 000h, 000h, 041h, 020h, 009h, 0C2h
 defb 	 0C3h, 0C2h, 048h, 000h, 000h, 049h, 024h, 0C2h
 defb 	 0C3h, 0C2h, 048h, 040h, 020h, 049h, 024h, 009h
 defb 	 0C2h, 0C3h, 0C2h, 051h, 040h, 020h, 052h, 028h
 defb 	 009h, 0C2h, 0C3h, 0C2h, 051h, 048h, 024h, 052h
 defb 	 028h, 0C2h, 0C3h, 0C2h, 056h, 048h, 024h, 057h
 defb 	 02Bh, 009h, 0C2h, 0C3h, 0C2h, 056h, 051h, 028h
 defb 	 057h, 02Bh, 009h, 0C2h, 0C3h, 0C2h, 06Dh, 051h
 defb 	 028h, 06Eh, 036h, 009h, 0C2h, 0C3h, 0C2h, 06Dh
 defb 	 056h, 02Bh, 06Eh, 036h, 009h, 0C2h, 0C3h, 0C2h
 defb 	 081h, 056h, 02Bh, 082h, 040h, 009h, 0C2h, 0C3h
 defb 	 0C2h, 081h, 06Dh, 036h, 082h, 040h, 009h, 0C2h
 defb 	 0C3h, 0C2h, 06Dh, 06Dh, 036h, 06Eh, 036h, 009h
 defb 	 0C2h, 0C3h, 0C2h, 06Dh, 081h, 040h, 06Eh, 036h
 defb 	 001h

PAT10:
 defw 	006F7h
 defb 	 004h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 03Dh, 030h, 062h, 030h, 000h, 000h, 07Ah, 061h
 defb 	 03Dh, 030h, 062h, 030h, 03Dh, 03Eh, 03Dh, 061h
 defb 	 000h, 000h, 062h, 030h, 000h, 000h, 03Dh, 061h
 defb 	 03Dh, 030h, 062h, 030h, 009h, 07Ah, 07Bh, 07Ah
 defb 	 061h, 03Dh, 030h, 062h, 030h, 000h, 000h, 07Ah
 defb 	 061h, 000h, 000h, 062h, 030h, 03Dh, 03Eh, 03Dh
 defb 	 061h, 03Dh, 030h, 062h, 030h, 004h, 000h, 000h
 defb 	 03Dh, 061h, 03Dh, 030h, 062h, 030h, 004h, 07Ah
 defb 	 07Bh, 07Ah, 061h, 000h, 000h, 062h, 030h, 000h
 defb 	 000h, 07Ah, 061h, 03Dh, 030h, 062h, 030h, 03Dh
 defb 	 03Eh, 03Dh, 06Dh, 03Dh, 030h, 06Eh, 036h, 000h
 defb 	 000h, 03Dh, 06Dh, 000h, 000h, 06Eh, 036h, 009h
 defb 	 07Ah, 07Bh, 07Ah, 061h, 03Dh, 030h, 062h, 030h
 defb 	 000h, 000h, 07Ah, 061h, 000h, 000h, 062h, 030h
 defb 	 03Dh, 03Eh, 03Dh, 056h, 03Dh, 030h, 057h, 02Bh
 defb 	 000h, 000h, 03Dh, 056h, 000h, 000h, 057h, 02Bh
 defb 	 004h, 0DAh, 0dbh, 0DAh, 056h, 036h, 02Bh, 057h
 defb 	 02Bh, 000h, 000h, 0DAh, 056h, 036h, 02Bh, 057h
 defb 	 02Bh, 004h, 06Dh, 06Eh, 06Dh, 056h, 000h, 000h
 defb 	 057h, 02Bh, 000h, 000h, 06Dh, 056h, 036h, 02Bh
 defb 	 057h, 02Bh, 009h, 0DAh, 0dbh, 0DAh, 056h, 036h
 defb 	 02Bh, 057h, 02Bh, 004h, 000h, 000h, 0DAh, 056h
 defb 	 000h, 000h, 057h, 02Bh, 06Dh, 06Eh, 06Dh, 061h
 defb 	 036h, 02Bh, 062h, 030h, 004h, 000h, 000h, 06Dh
 defb 	 061h, 036h, 02Bh, 062h, 030h, 004h, 0DAh, 0dbh
 defb 	 0DAh, 061h, 000h, 000h, 062h, 030h, 000h, 000h
 defb 	 0DAh, 061h, 036h, 02Bh, 062h, 030h, 06Dh, 06Eh
 defb 	 06Dh, 061h, 036h, 02Bh, 062h, 030h, 000h, 000h
 defb 	 06Dh, 061h, 000h, 000h, 062h, 030h, 009h, 0DAh
 defb 	 0dbh, 0DAh, 06Dh, 036h, 02Bh, 06Eh, 036h, 000h
 defb 	 000h, 0DAh, 06Dh, 000h, 000h, 06Eh, 036h, 06Dh
 defb 	 06Eh, 06Dh, 061h, 036h, 02Bh, 062h, 030h, 000h
 defb 	 000h, 06Dh, 061h, 000h, 000h, 062h, 030h, 004h
 defb 	 0C2h, 0C3h, 0C2h, 061h, 040h, 028h, 062h, 030h
 defb 	 000h, 000h, 0C2h, 061h, 040h, 028h, 062h, 030h
 defb 	 061h, 062h, 061h, 061h, 000h, 000h, 062h, 030h
 defb 	 000h, 000h, 061h, 061h, 040h, 028h, 062h, 030h
 defb 	 009h, 0C2h, 0C3h, 0C2h, 061h, 040h, 028h, 000h
 defb 	 030h, 000h, 000h, 0C2h, 000h, 000h, 000h, 000h
 defb 	 030h, 061h, 062h, 061h, 000h, 040h, 028h, 000h
 defb 	 000h, 004h, 000h, 000h, 061h, 000h, 040h, 028h
 defb 	 000h, 000h, 004h, 0C2h, 0C3h, 0C2h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 0C2h, 000h, 040h
 defb 	 028h, 000h, 000h, 004h, 061h, 062h, 061h, 000h
 defb 	 040h, 028h, 000h, 000h, 000h, 000h, 061h, 000h
 defb 	 000h, 000h, 000h, 000h, 009h, 0C2h, 0C3h, 0C2h
 defb 	 000h, 040h, 028h, 000h, 000h, 004h, 000h, 000h
 defb 	 0C2h, 000h, 000h, 000h, 000h, 000h, 061h, 062h
 defb 	 061h, 000h, 040h, 028h, 000h, 000h, 004h, 000h
 defb 	 000h, 061h, 000h, 000h, 000h, 000h, 000h, 004h
 defb 	 0C2h, 0C3h, 0C2h, 000h, 040h, 028h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 040h, 028h, 000h, 000h
 defb 	 061h, 062h, 061h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 061h, 000h, 040h, 028h, 000h, 000h
 defb 	 0C2h, 0C3h, 0C2h, 000h, 040h, 028h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 061h, 062h, 061h, 000h, 040h, 028h, 000h, 000h
 defb 	 000h, 000h, 061h, 000h, 040h, 028h, 000h, 000h
 defb 	 0C2h, 0C3h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 040h, 028h, 000h, 000h
 defb 	 009h, 061h, 062h, 061h, 000h, 040h, 028h, 000h
 defb 	 000h, 000h, 000h, 061h, 000h, 000h, 000h, 000h
 defb 	 000h, 009h, 0C2h, 0C3h, 0C2h, 000h, 040h, 028h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 000h, 000h, 000h
 defb 	 000h, 000h, 009h, 061h, 062h, 061h, 000h, 040h
 defb 	 028h, 000h, 000h, 009h, 000h, 000h, 061h, 000h
 defb 	 000h, 000h, 000h, 000h, 001h

PAT11:
 defw 	006F7h
 defb    004h
 defb 	 0C2h, 0C3h, 0C2h, 061h, 030h, 030h, 030h, 040h
 defb 	 0C2h, 0C3h, 0C2h, 061h, 030h, 000h, 030h, 040h
 defb 	 061h, 062h, 061h, 061h, 036h, 036h, 030h, 040h
 defb 	 061h, 062h, 061h, 061h, 036h, 000h, 030h, 040h
 defb 	 004h, 0C2h, 0C3h, 0C2h, 061h, 030h, 030h, 030h
 defb 	 040h, 0C2h, 0C3h, 0C2h, 061h, 030h, 000h, 030h
 defb 	 040h, 061h, 062h, 061h, 056h, 040h, 040h, 02Bh
 defb 	 040h, 061h, 062h, 061h, 056h, 040h, 000h, 02Bh
 defb 	 040h, 004h, 0C2h, 0C3h, 0C2h, 056h, 030h, 030h
 defb 	 02Bh, 040h, 0C2h, 0C3h, 0C2h, 056h, 030h, 000h
 defb 	 02Bh, 040h, 061h, 062h, 061h, 056h, 036h, 036h
 defb 	 02Bh, 040h, 061h, 062h, 061h, 056h, 036h, 000h
 defb 	 02Bh, 040h, 004h, 0C2h, 0C3h, 0C2h, 051h, 030h
 defb 	 030h, 028h, 040h, 0C2h, 0C3h, 0C2h, 051h, 030h
 defb 	 000h, 028h, 040h, 061h, 062h, 061h, 051h, 040h
 defb 	 040h, 028h, 040h, 061h, 062h, 061h, 051h, 040h
 defb 	 000h, 028h, 040h, 004h, 0DAh, 0dbh, 0DAh, 056h
 defb 	 048h, 048h, 02Bh, 048h, 0DAh, 0dbh, 0DAh, 056h
 defb 	 048h, 000h, 02Bh, 048h, 06Dh, 06Eh, 06Dh, 056h
 defb 	 051h, 051h, 02Bh, 048h, 06Dh, 06Eh, 06Dh, 056h
 defb 	 051h, 000h, 02Bh, 048h, 004h, 0DAh, 0dbh, 0DAh
 defb 	 056h, 048h, 048h, 02Bh, 048h, 0DAh, 0dbh, 0DAh
 defb 	 056h, 048h, 000h, 02Bh, 048h, 06Dh, 06Eh, 06Dh
 defb 	 051h, 061h, 061h, 028h, 048h, 06Dh, 06Eh, 06Dh
 defb 	 051h, 061h, 000h, 028h, 048h, 004h, 0DAh, 0dbh
 defb 	 0DAh, 051h, 048h, 048h, 028h, 048h, 0DAh, 0dbh
 defb 	 0DAh, 051h, 048h, 000h, 028h, 048h, 06Dh, 06Eh
 defb 	 06Dh, 051h, 051h, 051h, 028h, 048h, 06Dh, 06Eh
 defb 	 06Dh, 051h, 051h, 000h, 028h, 048h, 004h, 0DAh
 defb 	 0dbh, 0DAh, 048h, 048h, 048h, 024h, 048h, 0DAh
 defb 	 0dbh, 0DAh, 048h, 048h, 000h, 024h, 048h, 004h
 defb 	 06Dh, 06Eh, 06Dh, 048h, 061h, 061h, 024h, 048h
 defb 	 06Dh, 06Eh, 06Dh, 048h, 061h, 000h, 024h, 048h
 defb 	 004h, 091h, 092h, 091h, 040h, 030h, 030h, 020h
 defb 	 03Dh, 091h, 092h, 091h, 040h, 030h, 000h, 020h
 defb 	 03Dh, 048h, 049h, 048h, 040h, 036h, 036h, 020h
 defb 	 03Dh, 048h, 049h, 048h, 040h, 036h, 000h, 020h
 defb 	 03Dh, 004h, 091h, 092h, 091h, 040h, 030h, 030h
 defb 	 020h, 03Dh, 091h, 092h, 091h, 040h, 030h, 000h
 defb 	 020h, 03Dh, 048h, 049h, 048h, 048h, 03Dh, 03Dh
 defb 	 024h, 03Dh, 048h, 049h, 048h, 048h, 03Dh, 000h
 defb 	 024h, 03Dh, 004h, 091h, 092h, 091h, 048h, 030h
 defb 	 030h, 024h, 03Dh, 091h, 092h, 091h, 048h, 030h
 defb 	 000h, 024h, 03Dh, 048h, 049h, 048h, 048h, 036h
 defb 	 036h, 024h, 03Dh, 048h, 049h, 048h, 048h, 036h
 defb 	 000h, 024h, 03Dh, 004h, 091h, 092h, 091h, 051h
 defb 	 030h, 030h, 028h, 03Dh, 091h, 092h, 091h, 051h
 defb 	 030h, 000h, 028h, 03Dh, 048h, 049h, 048h, 051h
 defb 	 03Dh, 03Dh, 028h, 03Dh, 004h, 048h, 049h, 048h
 defb 	 051h, 03Dh, 000h, 028h, 03Dh, 004h, 07Ah, 07Bh
 defb 	 07Ah, 056h, 028h, 028h, 02Bh, 030h, 07Ah, 07Bh
 defb 	 07Ah, 056h, 028h, 000h, 02Bh, 030h, 03Dh, 03Eh
 defb 	 03Dh, 056h, 02Bh, 02Bh, 02Bh, 030h, 03Dh, 03Eh
 defb 	 03Dh, 056h, 02Bh, 000h, 02Bh, 030h, 004h, 07Ah
 defb 	 07Bh, 07Ah, 056h, 028h, 028h, 02Bh, 030h, 07Ah
 defb 	 07Bh, 07Ah, 056h, 028h, 000h, 02Bh, 030h, 03Dh
 defb 	 03Eh, 03Dh, 061h, 030h, 030h, 030h, 030h, 004h
 defb 	 03Dh, 03Eh, 03Dh, 061h, 030h, 000h, 030h, 030h
 defb 	 004h, 07Ah, 07Bh, 07Ah, 061h, 028h, 028h, 030h
 defb 	 030h, 07Ah, 07Bh, 07Ah, 061h, 028h, 000h, 030h
 defb 	 030h, 004h, 03Dh, 03Eh, 03Dh, 061h, 02Bh, 02Bh
 defb 	 030h, 030h, 03Dh, 03Eh, 03Dh, 061h, 02Bh, 000h
 defb 	 030h, 030h, 004h, 07Ah, 07Bh, 07Ah, 06Dh, 030h
 defb 	 030h, 036h, 030h, 004h, 07Ah, 07Bh, 07Ah, 06Dh
 defb 	 030h, 000h, 036h, 030h, 03Dh, 03Eh, 03Dh, 06Dh
 defb 	 036h, 036h, 036h, 030h, 004h, 03Dh, 03Eh, 03Dh
 defb 	 06Dh, 036h, 000h, 036h, 030h, 001h

PAT12:
 defw 	006F7h
 defb 	 004h, 0C2h, 0C3h, 0C2h, 061h, 030h, 030h, 030h
 defb 	 040h, 0C2h, 0C3h, 0C2h, 061h, 030h, 000h, 030h
 defb 	 040h, 061h, 062h, 061h, 061h, 036h, 036h, 030h
 defb 	 040h, 061h, 062h, 061h, 061h, 036h, 000h, 030h
 defb 	 040h, 004h, 0C2h, 0C3h, 0C2h, 061h, 030h, 030h
 defb 	 030h, 040h, 0C2h, 0C3h, 0C2h, 061h, 030h, 000h
 defb 	 030h, 040h, 061h, 062h, 061h, 056h, 040h, 040h
 defb 	 02Bh, 040h, 061h, 062h, 061h, 056h, 040h, 000h
 defb 	 02Bh, 040h, 004h, 0C2h, 0C3h, 0C2h, 056h, 030h
 defb 	 030h, 02Bh, 040h, 0C2h, 0C3h, 0C2h, 056h, 030h
 defb 	 000h, 02Bh, 040h, 061h, 062h, 061h, 056h, 036h
 defb 	 036h, 02Bh, 040h, 061h, 062h, 061h, 056h, 036h
 defb 	 000h, 02Bh, 040h, 004h, 0C2h, 0C3h, 0C2h, 051h
 defb 	 030h, 030h, 028h, 040h, 0C2h, 0C3h, 0C2h, 051h
 defb 	 030h, 000h, 028h, 040h, 061h, 062h, 061h, 051h
 defb 	 040h, 040h, 028h, 040h, 061h, 062h, 061h, 051h
 defb 	 040h, 000h, 028h, 040h, 004h, 0DAh, 0dbh, 0DAh
 defb 	 056h, 048h, 048h, 02Bh, 048h, 0DAh, 0dbh, 0DAh
 defb 	 056h, 048h, 000h, 02Bh, 048h, 06Dh, 06Eh, 06Dh
 defb 	 056h, 051h, 051h, 02Bh, 048h, 06Dh, 06Eh, 06Dh
 defb 	 056h, 051h, 000h, 02Bh, 048h, 004h, 0DAh, 0dbh
 defb 	 0DAh, 056h, 048h, 048h, 02Bh, 048h, 0DAh, 0dbh
 defb 	 0DAh, 056h, 048h, 000h, 02Bh, 048h, 06Dh, 06Eh
 defb 	 06Dh, 051h, 061h, 061h, 028h, 048h, 06Dh, 06Eh
 defb 	 06Dh, 051h, 061h, 000h, 028h, 048h, 004h, 0DAh
 defb 	 0dbh, 0DAh, 051h, 048h, 048h, 028h, 048h, 0DAh
 defb 	 0dbh, 0DAh, 051h, 048h, 000h, 028h, 048h, 06Dh
 defb 	 06Eh, 06Dh, 051h, 051h, 051h, 028h, 048h, 06Dh
 defb 	 06Eh, 06Dh, 051h, 051h, 000h, 028h, 048h, 004h
 defb 	 0DAh, 0dbh, 0DAh, 048h, 048h, 048h, 024h, 048h
 defb 	 0DAh, 0dbh, 0DAh, 048h, 048h, 000h, 024h, 048h
 defb 	 004h, 06Dh, 06Eh, 06Dh, 048h, 061h, 061h, 024h
 defb 	 048h, 06Dh, 06Eh, 06Dh, 048h, 061h, 000h, 024h
 defb 	 048h, 004h, 091h, 092h, 091h, 040h, 030h, 030h
 defb 	 020h, 03Dh, 091h, 092h, 091h, 040h, 030h, 000h
 defb 	 020h, 03Dh, 048h, 049h, 048h, 040h, 036h, 036h
 defb 	 020h, 03Dh, 048h, 049h, 048h, 040h, 036h, 000h
 defb 	 020h, 03Dh, 004h, 091h, 092h, 091h, 040h, 030h
 defb 	 030h, 020h, 03Dh, 091h, 092h, 091h, 040h, 030h
 defb 	 000h, 020h, 03Dh, 048h, 049h, 048h, 048h, 03Dh
 defb 	 03Dh, 024h, 03Dh, 048h, 049h, 048h, 048h, 03Dh
 defb 	 000h, 024h, 03Dh, 004h, 091h, 092h, 091h, 048h
 defb 	 030h, 030h, 024h, 03Dh, 091h, 092h, 091h, 048h
 defb 	 030h, 000h, 024h, 03Dh, 048h, 049h, 048h, 048h
 defb 	 036h, 036h, 024h, 03Dh, 048h, 049h, 048h, 048h
 defb 	 036h, 000h, 024h, 03Dh, 004h, 091h, 092h, 091h
 defb 	 051h, 030h, 030h, 028h, 03Dh, 091h, 092h, 091h
 defb 	 051h, 030h, 000h, 028h, 03Dh, 048h, 049h, 048h
 defb 	 051h, 03Dh, 03Dh, 028h, 03Dh, 004h, 048h, 049h
 defb 	 048h, 051h, 03Dh, 000h, 028h, 03Dh, 004h, 07Ah
 defb 	 07Bh, 07Ah, 040h, 028h, 028h, 020h, 030h, 07Ah
 defb 	 07Bh, 07Ah, 040h, 028h, 000h, 020h, 030h, 03Dh
 defb 	 03Eh, 03Dh, 040h, 02Bh, 02Bh, 020h, 030h, 03Dh
 defb 	 03Eh, 03Dh, 040h, 02Bh, 000h, 020h, 030h, 004h
 defb 	 07Ah, 07Bh, 07Ah, 040h, 028h, 028h, 020h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 040h, 028h, 000h, 020h, 030h
 defb 	 03Dh, 03Eh, 03Dh, 048h, 030h, 030h, 024h, 030h
 defb 	 004h, 03Dh, 03Eh, 03Dh, 048h, 030h, 000h, 024h
 defb 	 030h, 004h, 07Ah, 07Bh, 07Ah, 048h, 028h, 028h
 defb 	 024h, 030h, 07Ah, 07Bh, 07Ah, 048h, 028h, 000h
 defb 	 024h, 030h, 004h, 03Dh, 03Eh, 03Dh, 048h, 02Bh
 defb 	 02Bh, 024h, 030h, 03Dh, 03Eh, 03Dh, 048h, 02Bh
 defb 	 000h, 024h, 030h, 004h, 07Ah, 07Bh, 07Ah, 051h
 defb 	 030h, 030h, 028h, 030h, 004h, 07Ah, 07Bh, 07Ah
 defb 	 051h, 030h, 000h, 028h, 030h, 03Dh, 03Eh, 03Dh
 defb 	 051h, 036h, 036h, 028h, 030h, 004h, 03Dh, 03Eh
 defb 	 03Dh, 051h, 036h, 000h, 028h, 030h, 001h

PAT13:
 defw 	006F7h
 defb 	 004h, 0C2h, 0C3h, 0C2h, 061h, 030h, 030h
 defb 	 030h, 040h, 0C2h, 0C3h, 0C2h, 061h, 030h, 000h
 defb 	 030h, 040h, 061h, 062h, 061h, 061h, 036h, 036h
 defb 	 030h, 040h, 061h, 062h, 061h, 061h, 036h, 000h
 defb 	 030h, 040h, 009h, 0C2h, 0C3h, 0C2h, 061h, 030h
 defb 	 030h, 030h, 040h, 0C2h, 0C3h, 0C2h, 061h, 030h
 defb 	 000h, 030h, 040h, 061h, 062h, 061h, 056h, 040h
 defb 	 040h, 02Bh, 040h, 004h, 061h, 062h, 061h, 056h
 defb 	 040h, 000h, 02Bh, 040h, 004h, 0C2h, 0C3h, 0C2h
 defb 	 056h, 030h, 030h, 02Bh, 040h, 0C2h, 0C3h, 0C2h
 defb 	 056h, 030h, 000h, 02Bh, 040h, 061h, 062h, 061h
 defb 	 056h, 036h, 036h, 02Bh, 040h, 061h, 062h, 061h
 defb 	 056h, 036h, 000h, 02Bh, 040h, 009h, 0C2h, 0C3h
 defb 	 0C2h, 051h, 030h, 030h, 028h, 040h, 0C2h, 0C3h
 defb 	 0C2h, 051h, 030h, 000h, 028h, 040h, 061h, 062h
 defb 	 061h, 051h, 040h, 040h, 028h, 040h, 061h, 062h
 defb 	 061h, 051h, 040h, 000h, 028h, 040h, 004h, 0DAh
 defb 	 0dbh, 0DAh, 056h, 048h, 048h, 02Bh, 048h, 0DAh
 defb 	 0dbh, 0DAh, 056h, 048h, 000h, 02Bh, 048h, 06Dh
 defb 	 06Eh, 06Dh, 056h, 051h, 051h, 02Bh, 048h, 06Dh
 defb 	 06Eh, 06Dh, 056h, 051h, 000h, 02Bh, 048h, 009h
 defb 	 0DAh, 0dbh, 0DAh, 056h, 048h, 048h, 02Bh, 048h
 defb 	 0DAh, 0dbh, 0DAh, 056h, 048h, 000h, 02Bh, 048h
 defb 	 06Dh, 06Eh, 06Dh, 051h, 061h, 061h, 028h, 048h
 defb 	 004h, 06Dh, 06Eh, 06Dh, 051h, 061h, 000h, 028h
 defb 	 048h, 004h, 0DAh, 0dbh, 0DAh, 051h, 048h, 048h
 defb 	 028h, 048h, 0DAh, 0dbh, 0DAh, 051h, 048h, 000h
 defb 	 028h, 048h, 004h, 06Dh, 06Eh, 06Dh, 051h, 051h
 defb 	 051h, 028h, 048h, 06Dh, 06Eh, 06Dh, 051h, 051h
 defb 	 000h, 028h, 048h, 009h, 0DAh, 0dbh, 0DAh, 048h
 defb 	 048h, 048h, 024h, 048h, 0DAh, 0dbh, 0DAh, 048h
 defb 	 048h, 000h, 024h, 048h, 06Dh, 06Eh, 06Dh, 048h
 defb 	 061h, 061h, 024h, 048h, 06Dh, 06Eh, 06Dh, 048h
 defb 	 061h, 000h, 024h, 048h, 004h, 091h, 092h, 091h
 defb 	 040h, 030h, 030h, 020h, 03Dh, 091h, 092h, 091h
 defb 	 040h, 030h, 000h, 020h, 03Dh, 048h, 049h, 048h
 defb 	 040h, 036h, 036h, 020h, 03Dh, 048h, 049h, 048h
 defb 	 040h, 036h, 000h, 020h, 03Dh, 009h, 091h, 092h
 defb 	 091h, 040h, 030h, 030h, 020h, 03Dh, 091h, 092h
 defb 	 091h, 040h, 030h, 000h, 020h, 03Dh, 048h, 049h
 defb 	 048h, 048h, 03Dh, 03Dh, 024h, 03Dh, 004h, 048h
 defb 	 049h, 048h, 048h, 03Dh, 000h, 024h, 03Dh, 004h
 defb 	 091h, 092h, 091h, 048h, 030h, 030h, 024h, 03Dh
 defb 	 091h, 092h, 091h, 048h, 030h, 000h, 024h, 03Dh
 defb 	 048h, 049h, 048h, 048h, 036h, 036h, 024h, 03Dh
 defb 	 048h, 049h, 048h, 048h, 036h, 000h, 024h, 03Dh
 defb 	 009h, 091h, 092h, 091h, 051h, 030h, 030h, 028h
 defb 	 03Dh, 091h, 092h, 091h, 051h, 030h, 000h, 028h
 defb 	 03Dh, 048h, 049h, 048h, 051h, 03Dh, 03Dh, 028h
 defb 	 03Dh, 048h, 049h, 048h, 051h, 03Dh, 000h, 028h
 defb 	 03Dh, 004h, 07Ah, 07Bh, 07Ah, 056h, 028h, 028h
 defb 	 02Bh, 030h, 07Ah, 07Bh, 07Ah, 056h, 028h, 000h
 defb 	 02Bh, 030h, 03Dh, 03Eh, 03Dh, 056h, 02Bh, 02Bh
 defb 	 02Bh, 030h, 03Dh, 03Eh, 03Dh, 056h, 02Bh, 000h
 defb 	 02Bh, 030h, 009h, 07Ah, 07Bh, 07Ah, 056h, 028h
 defb 	 028h, 02Bh, 030h, 07Ah, 07Bh, 07Ah, 056h, 028h
 defb 	 000h, 02Bh, 030h, 03Dh, 03Eh, 03Dh, 061h, 030h
 defb 	 030h, 030h, 030h, 004h, 03Dh, 03Eh, 03Dh, 061h
 defb 	 030h, 000h, 030h, 030h, 004h, 07Ah, 07Bh, 07Ah
 defb 	 061h, 028h, 028h, 030h, 030h, 009h, 07Ah, 07Bh
 defb 	 07Ah, 061h, 028h, 000h, 030h, 030h, 009h, 03Dh
 defb 	 03Eh, 03Dh, 061h, 02Bh, 02Bh, 030h, 030h, 009h
 defb 	 03Dh, 03Eh, 03Dh, 061h, 02Bh, 000h, 030h, 030h
 defb 	 009h, 07Ah, 07Bh, 07Ah, 06Dh, 030h, 030h, 036h
 defb 	 030h, 07Ah, 07Bh, 07Ah, 06Dh, 030h, 000h, 036h
 defb 	 030h, 009h, 03Dh, 03Eh, 03Dh, 06Dh, 036h, 036h
 defb 	 036h, 030h, 009h, 03Dh, 03Eh, 03Dh, 06Dh, 036h
 defb 	 000h, 036h, 030h, 001h

PAT14:
 defw 	006F7h
 defb 	 004h, 0C2h
 defb 	 0C3h, 0C2h, 061h, 030h, 030h, 030h, 040h, 0C2h
 defb 	 0C3h, 0C2h, 061h, 030h, 000h, 030h, 040h, 061h
 defb 	 062h, 061h, 061h, 036h, 036h, 030h, 040h, 061h
 defb 	 062h, 061h, 061h, 036h, 000h, 030h, 040h, 009h
 defb 	 0C2h, 0C3h, 0C2h, 061h, 030h, 030h, 030h, 040h
 defb 	 0C2h, 0C3h, 0C2h, 061h, 030h, 000h, 030h, 040h
 defb 	 061h, 062h, 061h, 056h, 040h, 040h, 02Bh, 040h
 defb 	 004h, 061h, 062h, 061h, 056h, 040h, 000h, 02Bh
 defb 	 040h, 004h, 0C2h, 0C3h, 0C2h, 056h, 030h, 030h
 defb 	 02Bh, 040h, 0C2h, 0C3h, 0C2h, 056h, 030h, 000h
 defb 	 02Bh, 040h, 061h, 062h, 061h, 056h, 036h, 036h
 defb 	 02Bh, 040h, 061h, 062h, 061h, 056h, 036h, 000h
 defb 	 02Bh, 040h, 009h, 0C2h, 0C3h, 0C2h, 051h, 030h
 defb 	 030h, 028h, 040h, 0C2h, 0C3h, 0C2h, 051h, 030h
 defb 	 000h, 028h, 040h, 061h, 062h, 061h, 051h, 040h
 defb 	 040h, 028h, 040h, 061h, 062h, 061h, 051h, 040h
 defb 	 000h, 028h, 040h, 004h, 0DAh, 0dbh, 0DAh, 056h
 defb 	 048h, 048h, 02Bh, 048h, 0DAh, 0dbh, 0DAh, 056h
 defb 	 048h, 000h, 02Bh, 048h, 06Dh, 06Eh, 06Dh, 056h
 defb 	 051h, 051h, 02Bh, 048h, 06Dh, 06Eh, 06Dh, 056h
 defb 	 051h, 000h, 02Bh, 048h, 009h, 0DAh, 0dbh, 0DAh
 defb 	 056h, 048h, 048h, 02Bh, 048h, 0DAh, 0dbh, 0DAh
 defb 	 056h, 048h, 000h, 02Bh, 048h, 06Dh, 06Eh, 06Dh
 defb 	 051h, 061h, 061h, 028h, 048h, 004h, 06Dh, 06Eh
 defb 	 06Dh, 051h, 061h, 000h, 028h, 048h, 004h, 0DAh
 defb 	 0dbh, 0DAh, 051h, 048h, 048h, 028h, 048h, 0DAh
 defb 	 0dbh, 0DAh, 051h, 048h, 000h, 028h, 048h, 004h
 defb 	 06Dh, 06Eh, 06Dh, 051h, 051h, 051h, 028h, 048h
 defb 	 06Dh, 06Eh, 06Dh, 051h, 051h, 000h, 028h, 048h
 defb 	 009h, 0DAh, 0dbh, 0DAh, 048h, 048h, 048h, 024h
 defb 	 048h, 004h, 0DAh, 0dbh, 0DAh, 048h, 048h, 000h
 defb 	 024h, 048h, 06Dh, 06Eh, 06Dh, 048h, 061h, 061h
 defb 	 024h, 048h, 06Dh, 06Eh, 06Dh, 048h, 061h, 000h
 defb 	 024h, 048h, 004h, 091h, 092h, 091h, 040h, 030h
 defb 	 030h, 020h, 03Dh, 091h, 092h, 091h, 040h, 030h
 defb 	 000h, 020h, 03Dh, 048h, 049h, 048h, 040h, 036h
 defb 	 036h, 020h, 03Dh, 048h, 049h, 048h, 040h, 036h
 defb 	 000h, 020h, 03Dh, 009h, 091h, 092h, 091h, 040h
 defb 	 030h, 030h, 020h, 03Dh, 091h, 092h, 091h, 040h
 defb 	 030h, 000h, 020h, 03Dh, 048h, 049h, 048h, 048h
 defb 	 03Dh, 03Dh, 024h, 03Dh, 004h, 048h, 049h, 048h
 defb 	 048h, 03Dh, 000h, 024h, 03Dh, 004h, 091h, 092h
 defb 	 091h, 048h, 030h, 030h, 024h, 03Dh, 091h, 092h
 defb 	 091h, 048h, 030h, 000h, 024h, 03Dh, 048h, 049h
 defb 	 048h, 048h, 036h, 036h, 024h, 03Dh, 048h, 049h
 defb 	 048h, 048h, 036h, 000h, 024h, 03Dh, 009h, 091h
 defb 	 092h, 091h, 051h, 030h, 030h, 028h, 03Dh, 091h
 defb 	 092h, 091h, 051h, 030h, 000h, 028h, 03Dh, 048h
 defb 	 049h, 048h, 051h, 03Dh, 03Dh, 028h, 03Dh, 048h
 defb 	 049h, 048h, 051h, 03Dh, 000h, 028h, 03Dh, 004h
 defb 	 07Ah, 07Bh, 07Ah, 03Dh, 028h, 028h, 01Eh, 030h
 defb 	 07Ah, 07Bh, 07Ah, 03Dh, 028h, 000h, 01Eh, 030h
 defb 	 03Dh, 03Eh, 03Dh, 03Dh, 02Bh, 02Bh, 01Eh, 030h
 defb 	 03Dh, 03Eh, 03Dh, 03Dh, 02Bh, 000h, 01Eh, 030h
 defb 	 009h, 07Ah, 07Bh, 07Ah, 03Dh, 028h, 028h, 01Eh
 defb 	 030h, 07Ah, 07Bh, 07Ah, 03Dh, 028h, 000h, 01Eh
 defb 	 030h, 03Dh, 03Eh, 03Dh, 040h, 030h, 030h, 020h
 defb 	 030h, 004h, 03Dh, 03Eh, 03Dh, 040h, 030h, 000h
 defb 	 020h, 030h, 004h, 07Ah, 07Bh, 07Ah, 040h, 028h
 defb 	 028h, 020h, 030h, 009h, 07Ah, 07Bh, 07Ah, 040h
 defb 	 028h, 000h, 020h, 030h, 009h, 03Dh, 03Eh, 03Dh
 defb 	 040h, 02Bh, 02Bh, 020h, 030h, 009h, 03Dh, 03Eh
 defb 	 03Dh, 040h, 02Bh, 000h, 020h, 030h, 009h, 07Ah
 defb 	 07Bh, 07Ah, 048h, 030h, 030h, 024h, 030h, 07Ah
 defb 	 07Bh, 07Ah, 048h, 030h, 000h, 024h, 030h, 009h
 defb 	 03Dh, 03Eh, 03Dh, 048h, 036h, 036h, 024h, 030h
 defb 	 009h, 03Dh, 03Eh, 03Dh, 048h, 036h, 000h, 024h
 defb 	 030h, 001h

PAT15:
 defw 	006F7h
 defb 	 004h, 0C2h, 000h, 000h
 defb 	 000h, 030h, 030h, 000h, 000h, 0C2h, 000h, 000h
 defb 	 000h, 030h, 000h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 036h, 036h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 036h, 000h, 000h, 000h, 0C2h, 000h, 000h
 defb 	 000h, 030h, 030h, 000h, 000h, 0C2h, 000h, 000h
 defb 	 000h, 030h, 000h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 040h, 040h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 040h, 000h, 000h, 000h, 0C2h, 000h, 000h
 defb 	 000h, 030h, 030h, 000h, 000h, 0C2h, 000h, 000h
 defb 	 000h, 030h, 000h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 036h, 036h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 036h, 000h, 000h, 000h, 0C2h, 000h, 000h
 defb 	 000h, 030h, 030h, 000h, 000h, 0C2h, 000h, 000h
 defb 	 000h, 030h, 000h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 040h, 040h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 040h, 000h, 000h, 000h, 0DAh, 000h, 000h
 defb 	 000h, 048h, 048h, 000h, 000h, 0DAh, 000h, 000h
 defb 	 000h, 048h, 000h, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 051h, 051h, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 051h, 000h, 000h, 000h, 0DAh, 000h, 000h
 defb 	 000h, 048h, 048h, 000h, 000h, 0DAh, 000h, 000h
 defb 	 000h, 048h, 000h, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 061h, 061h, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 061h, 000h, 000h, 000h, 0DAh, 000h, 000h
 defb 	 000h, 048h, 048h, 000h, 000h, 0DAh, 000h, 000h
 defb 	 000h, 048h, 000h, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 051h, 051h, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 051h, 000h, 000h, 000h, 0DAh, 000h, 000h
 defb 	 000h, 048h, 048h, 000h, 000h, 0DAh, 000h, 000h
 defb 	 000h, 048h, 000h, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 061h, 061h, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 061h, 000h, 000h, 000h, 091h, 000h, 000h
 defb 	 000h, 030h, 030h, 000h, 000h, 091h, 000h, 000h
 defb 	 000h, 030h, 000h, 000h, 000h, 048h, 000h, 000h
 defb 	 000h, 036h, 036h, 000h, 000h, 048h, 000h, 000h
 defb 	 000h, 036h, 000h, 000h, 000h, 091h, 000h, 000h
 defb 	 000h, 030h, 030h, 000h, 000h, 091h, 000h, 000h
 defb 	 000h, 030h, 000h, 000h, 000h, 048h, 000h, 000h
 defb 	 000h, 03Dh, 03Dh, 000h, 000h, 048h, 000h, 000h
 defb 	 000h, 03Dh, 000h, 000h, 000h, 091h, 000h, 000h
 defb 	 000h, 030h, 030h, 000h, 000h, 091h, 000h, 000h
 defb 	 000h, 030h, 000h, 000h, 000h, 048h, 000h, 000h
 defb 	 000h, 036h, 036h, 000h, 000h, 048h, 000h, 000h
 defb 	 000h, 036h, 000h, 000h, 000h, 091h, 000h, 000h
 defb 	 000h, 030h, 030h, 000h, 000h, 091h, 000h, 000h
 defb 	 000h, 030h, 000h, 000h, 000h, 048h, 000h, 000h
 defb 	 000h, 03Dh, 03Dh, 000h, 000h, 048h, 000h, 000h
 defb 	 000h, 03Dh, 000h, 000h, 000h, 07Ah, 000h, 000h
 defb 	 000h, 028h, 028h, 000h, 000h, 07Ah, 000h, 000h
 defb 	 000h, 028h, 000h, 000h, 000h, 03Dh, 000h, 000h
 defb 	 000h, 02Bh, 02Bh, 000h, 000h, 03Dh, 000h, 000h
 defb 	 000h, 02Bh, 000h, 000h, 000h, 07Ah, 000h, 000h
 defb 	 000h, 028h, 028h, 000h, 000h, 07Ah, 000h, 000h
 defb 	 000h, 028h, 000h, 000h, 000h, 03Dh, 000h, 000h
 defb 	 000h, 030h, 030h, 000h, 000h, 004h, 03Dh, 000h
 defb 	 000h, 000h, 030h, 000h, 000h, 000h, 004h, 07Ah
 defb 	 000h, 000h, 000h, 028h, 028h, 000h, 000h, 009h
 defb 	 07Ah, 000h, 000h, 000h, 028h, 000h, 000h, 000h
 defb 	 009h, 03Dh, 000h, 000h, 000h, 02Bh, 02Bh, 000h
 defb 	 000h, 009h, 03Dh, 000h, 000h, 000h, 02Bh, 000h
 defb 	 000h, 000h, 009h, 07Ah, 000h, 000h, 000h, 030h
 defb 	 030h, 000h, 000h, 07Ah, 000h, 000h, 000h, 030h
 defb 	 000h, 000h, 000h, 009h, 03Dh, 000h, 000h, 000h
 defb 	 036h, 036h, 000h, 000h, 009h, 03Dh, 000h, 000h
 defb 	 000h, 036h, 000h, 000h, 000h, 001h

PAT16:
 defw 	006F7h
 defb 	 004h, 0C2h, 0C3h, 000h, 000h, 030h, 030h, 000h
 defb 	 040h, 0C2h, 0C3h, 000h, 000h, 030h, 000h, 000h
 defb 	 040h, 061h, 062h, 000h, 000h, 036h, 036h, 000h
 defb 	 040h, 061h, 062h, 000h, 000h, 036h, 000h, 000h
 defb 	 040h, 0C2h, 0C3h, 000h, 000h, 030h, 030h, 000h
 defb 	 040h, 0C2h, 0C3h, 000h, 000h, 030h, 000h, 000h
 defb 	 040h, 061h, 062h, 000h, 000h, 040h, 040h, 000h
 defb 	 040h, 061h, 062h, 000h, 000h, 040h, 000h, 000h
 defb 	 040h, 0C2h, 0C3h, 000h, 000h, 030h, 030h, 000h
 defb 	 040h, 0C2h, 0C3h, 000h, 000h, 030h, 000h, 000h
 defb 	 040h, 061h, 062h, 000h, 000h, 036h, 036h, 000h
 defb 	 040h, 061h, 062h, 000h, 000h, 036h, 000h, 000h
 defb 	 040h, 0C2h, 0C3h, 000h, 000h, 030h, 030h, 000h
 defb 	 040h, 0C2h, 0C3h, 000h, 000h, 030h, 000h, 000h
 defb 	 040h, 061h, 062h, 000h, 000h, 040h, 040h, 000h
 defb 	 040h, 061h, 062h, 000h, 000h, 040h, 000h, 000h
 defb 	 040h, 0DAh, 0dbh, 000h, 000h, 048h, 048h, 000h
 defb 	 048h, 0DAh, 0dbh, 000h, 000h, 048h, 000h, 000h
 defb 	 048h, 06Dh, 06Eh, 000h, 000h, 051h, 051h, 000h
 defb 	 048h, 06Dh, 06Eh, 000h, 000h, 051h, 000h, 000h
 defb 	 048h, 0DAh, 0dbh, 000h, 000h, 048h, 048h, 000h
 defb 	 048h, 0DAh, 0dbh, 000h, 000h, 048h, 000h, 000h
 defb 	 048h, 06Dh, 06Eh, 000h, 000h, 061h, 061h, 000h
 defb 	 048h, 06Dh, 06Eh, 000h, 000h, 061h, 000h, 000h
 defb 	 048h, 0DAh, 0dbh, 000h, 000h, 048h, 048h, 000h
 defb 	 048h, 0DAh, 0dbh, 000h, 000h, 048h, 000h, 000h
 defb 	 048h, 06Dh, 06Eh, 000h, 000h, 051h, 051h, 000h
 defb 	 048h, 06Dh, 06Eh, 000h, 000h, 051h, 000h, 000h
 defb 	 048h, 0DAh, 0dbh, 000h, 000h, 048h, 048h, 000h
 defb 	 048h, 0DAh, 0dbh, 000h, 000h, 048h, 000h, 000h
 defb 	 048h, 06Dh, 06Eh, 000h, 000h, 061h, 061h, 000h
 defb 	 048h, 06Dh, 06Eh, 000h, 000h, 061h, 000h, 000h
 defb 	 048h, 091h, 092h, 000h, 000h, 030h, 030h, 000h
 defb 	 03Dh, 091h, 092h, 000h, 000h, 030h, 000h, 000h
 defb 	 03Dh, 048h, 049h, 000h, 000h, 036h, 036h, 000h
 defb 	 03Dh, 048h, 049h, 000h, 000h, 036h, 000h, 000h
 defb 	 03Dh, 091h, 092h, 000h, 000h, 030h, 030h, 000h
 defb 	 03Dh, 091h, 092h, 000h, 000h, 030h, 000h, 000h
 defb 	 03Dh, 048h, 049h, 000h, 000h, 03Dh, 03Dh, 000h
 defb 	 03Dh, 048h, 049h, 000h, 000h, 03Dh, 000h, 000h
 defb 	 03Dh, 004h, 091h, 092h, 000h, 000h, 030h, 030h
 defb 	 000h, 03Dh, 091h, 092h, 000h, 000h, 030h, 000h
 defb 	 000h, 03Dh, 048h, 049h, 000h, 000h, 036h, 036h
 defb 	 000h, 03Dh, 048h, 049h, 000h, 000h, 036h, 000h
 defb 	 000h, 03Dh, 009h, 091h, 092h, 000h, 000h, 030h
 defb 	 030h, 000h, 03Dh, 091h, 092h, 000h, 000h, 030h
 defb 	 000h, 000h, 03Dh, 048h, 049h, 000h, 000h, 03Dh
 defb 	 03Dh, 000h, 03Dh, 048h, 049h, 000h, 000h, 03Dh
 defb 	 000h, 000h, 03Dh, 004h, 07Ah, 07Bh, 000h, 000h
 defb 	 028h, 028h, 000h, 030h, 07Ah, 07Bh, 000h, 000h
 defb 	 028h, 000h, 000h, 030h, 03Dh, 03Eh, 000h, 000h
 defb 	 02Bh, 02Bh, 000h, 030h, 03Dh, 03Eh, 000h, 000h
 defb 	 02Bh, 000h, 000h, 030h, 009h, 07Ah, 07Bh, 000h
 defb 	 000h, 028h, 028h, 000h, 030h, 07Ah, 07Bh, 000h
 defb 	 000h, 028h, 000h, 000h, 030h, 03Dh, 03Eh, 000h
 defb 	 000h, 030h, 030h, 000h, 030h, 004h, 03Dh, 03Eh
 defb 	 000h, 000h, 030h, 000h, 000h, 030h, 004h, 07Ah
 defb 	 07Bh, 000h, 000h, 028h, 028h, 000h, 030h, 009h
 defb 	 07Ah, 07Bh, 000h, 000h, 028h, 000h, 000h, 030h
 defb 	 009h, 03Dh, 03Eh, 000h, 000h, 02Bh, 02Bh, 000h
 defb 	 030h, 009h, 03Dh, 03Eh, 000h, 000h, 02Bh, 000h
 defb 	 000h, 030h, 009h, 07Ah, 07Bh, 000h, 000h, 030h
 defb 	 030h, 000h, 030h, 07Ah, 07Bh, 000h, 000h, 030h
 defb 	 000h, 000h, 030h, 009h, 03Dh, 03Eh, 000h, 000h
 defb 	 036h, 036h, 000h, 030h, 009h, 03Dh, 03Eh, 000h
 defb 	 000h, 036h, 000h, 000h, 030h, 001h

PAT17:
 defw 	006F7h
 defb 	 004h, 0C2h, 0C3h, 0C2h, 061h, 030h, 030h, 030h
 defb 	 040h, 0C2h, 0C3h, 0C2h, 061h, 030h, 000h, 030h
 defb 	 040h, 061h, 062h, 061h, 061h, 036h, 036h, 030h
 defb 	 040h, 061h, 062h, 061h, 061h, 036h, 000h, 030h
 defb 	 040h, 009h, 0C2h, 0C3h, 0C2h, 061h, 030h, 030h
 defb 	 030h, 040h, 0C2h, 0C3h, 0C2h, 061h, 030h, 000h
 defb 	 030h, 040h, 061h, 062h, 061h, 056h, 040h, 040h
 defb 	 02Bh, 040h, 004h, 061h, 062h, 061h, 056h, 040h
 defb 	 000h, 02Bh, 040h, 004h, 0C2h, 0C3h, 0C2h, 056h
 defb 	 030h, 030h, 02Bh, 040h, 0C2h, 0C3h, 0C2h, 056h
 defb 	 030h, 000h, 02Bh, 040h, 061h, 062h, 061h, 056h
 defb 	 036h, 036h, 02Bh, 040h, 061h, 062h, 061h, 056h
 defb 	 036h, 000h, 02Bh, 040h, 009h, 0C2h, 0C3h, 0C2h
 defb 	 051h, 030h, 030h, 028h, 040h, 0C2h, 0C3h, 0C2h
 defb 	 051h, 030h, 000h, 028h, 040h, 061h, 062h, 061h
 defb 	 051h, 040h, 040h, 028h, 040h, 061h, 062h, 061h
 defb 	 051h, 040h, 000h, 028h, 040h, 004h, 0DAh, 0dbh
 defb 	 0DAh, 056h, 048h, 048h, 02Bh, 048h, 0DAh, 0dbh
 defb 	 0DAh, 056h, 048h, 000h, 02Bh, 048h, 06Dh, 06Eh
 defb 	 06Dh, 056h, 051h, 051h, 02Bh, 048h, 06Dh, 06Eh
 defb 	 06Dh, 056h, 051h, 000h, 02Bh, 048h, 009h, 0DAh
 defb 	 0dbh, 0DAh, 056h, 048h, 048h, 02Bh, 048h, 0DAh
 defb 	 0dbh, 0DAh, 056h, 048h, 000h, 02Bh, 048h, 06Dh
 defb 	 06Eh, 06Dh, 051h, 061h, 061h, 028h, 048h, 004h
 defb 	 06Dh, 06Eh, 06Dh, 051h, 061h, 000h, 028h, 048h
 defb 	 004h, 0DAh, 0dbh, 0DAh, 051h, 048h, 048h, 028h
 defb 	 048h, 0DAh, 0dbh, 0DAh, 051h, 048h, 000h, 028h
 defb 	 048h, 004h, 06Dh, 06Eh, 06Dh, 051h, 051h, 051h
 defb 	 028h, 048h, 06Dh, 06Eh, 06Dh, 051h, 051h, 000h
 defb 	 028h, 048h, 009h, 0DAh, 0dbh, 0DAh, 048h, 048h
 defb 	 048h, 024h, 048h, 004h, 0DAh, 0dbh, 0DAh, 048h
 defb 	 048h, 000h, 024h, 048h, 06Dh, 06Eh, 06Dh, 048h
 defb 	 061h, 061h, 024h, 048h, 06Dh, 06Eh, 06Dh, 048h
 defb 	 061h, 000h, 024h, 048h, 004h, 091h, 092h, 091h
 defb 	 040h, 030h, 030h, 020h, 03Dh, 091h, 092h, 091h
 defb 	 040h, 030h, 000h, 020h, 03Dh, 048h, 049h, 048h
 defb 	 040h, 036h, 036h, 020h, 03Dh, 048h, 049h, 048h
 defb 	 040h, 036h, 000h, 020h, 03Dh, 009h, 091h, 092h
 defb 	 091h, 040h, 030h, 030h, 020h, 03Dh, 091h, 092h
 defb 	 091h, 040h, 030h, 000h, 020h, 03Dh, 048h, 049h
 defb 	 048h, 048h, 03Dh, 03Dh, 024h, 03Dh, 004h, 048h
 defb 	 049h, 048h, 048h, 03Dh, 000h, 024h, 03Dh, 004h
 defb 	 091h, 092h, 091h, 048h, 030h, 030h, 024h, 03Dh
 defb 	 091h, 092h, 091h, 048h, 030h, 000h, 024h, 03Dh
 defb 	 048h, 049h, 048h, 048h, 036h, 036h, 024h, 03Dh
 defb 	 048h, 049h, 048h, 048h, 036h, 000h, 024h, 03Dh
 defb 	 009h, 091h, 092h, 091h, 051h, 030h, 030h, 028h
 defb 	 03Dh, 091h, 092h, 091h, 051h, 030h, 000h, 028h
 defb 	 03Dh, 048h, 049h, 048h, 051h, 03Dh, 03Dh, 028h
 defb 	 03Dh, 048h, 049h, 048h, 051h, 03Dh, 000h, 028h
 defb 	 03Dh, 004h, 081h, 082h, 081h, 03Dh, 028h, 028h
 defb 	 01Eh, 033h, 081h, 082h, 081h, 03Dh, 028h, 000h
 defb 	 01Eh, 033h, 040h, 041h, 040h, 03Dh, 02Bh, 02Bh
 defb 	 01Eh, 033h, 040h, 041h, 040h, 03Dh, 02Bh, 000h
 defb 	 01Eh, 033h, 009h, 081h, 082h, 081h, 03Dh, 028h
 defb 	 028h, 01Eh, 033h, 081h, 082h, 081h, 03Dh, 028h
 defb 	 000h, 01Eh, 033h, 040h, 041h, 040h, 040h, 033h
 defb 	 033h, 020h, 033h, 004h, 040h, 041h, 040h, 040h
 defb 	 033h, 000h, 020h, 033h, 004h, 081h, 082h, 081h
 defb 	 040h, 030h, 030h, 020h, 033h, 009h, 081h, 082h
 defb 	 081h, 040h, 030h, 000h, 020h, 033h, 009h, 040h
 defb 	 041h, 040h, 040h, 02Bh, 02Bh, 020h, 033h, 009h
 defb 	 040h, 041h, 040h, 040h, 02Bh, 000h, 020h, 033h
 defb 	 009h, 081h, 082h, 081h, 067h, 028h, 028h, 033h
 defb 	 033h, 081h, 082h, 081h, 067h, 028h, 000h, 033h
 defb 	 033h, 009h, 040h, 041h, 040h, 067h, 02Bh, 02Bh
 defb 	 033h, 033h, 009h, 040h, 041h, 040h, 067h, 02Bh
 defb 	 000h, 033h, 033h, 001h

PAT18:
 defw 	006F7h
 defb 	 004h, 0C2h
 defb 	 0C3h, 0C2h, 061h, 030h, 030h, 030h, 040h, 0C2h
 defb 	 0C3h, 0C2h, 061h, 030h, 000h, 030h, 040h, 061h
 defb 	 062h, 061h, 061h, 036h, 036h, 030h, 040h, 061h
 defb 	 062h, 061h, 061h, 036h, 000h, 030h, 040h, 009h
 defb 	 0C2h, 0C3h, 0C2h, 061h, 030h, 030h, 030h, 040h
 defb 	 0C2h, 0C3h, 0C2h, 061h, 030h, 000h, 030h, 040h
 defb 	 061h, 062h, 061h, 056h, 040h, 040h, 02Bh, 040h
 defb 	 004h, 061h, 062h, 061h, 056h, 040h, 000h, 02Bh
 defb 	 040h, 004h, 0C2h, 0C3h, 0C2h, 056h, 030h, 030h
 defb 	 02Bh, 040h, 0C2h, 0C3h, 0C2h, 056h, 030h, 000h
 defb 	 02Bh, 040h, 061h, 062h, 061h, 056h, 036h, 036h
 defb 	 02Bh, 040h, 061h, 062h, 061h, 056h, 036h, 000h
 defb 	 02Bh, 040h, 009h, 0C2h, 0C3h, 0C2h, 051h, 030h
 defb 	 030h, 028h, 040h, 0C2h, 0C3h, 0C2h, 051h, 030h
 defb 	 000h, 028h, 040h, 061h, 062h, 061h, 051h, 040h
 defb 	 040h, 028h, 040h, 061h, 062h, 061h, 051h, 040h
 defb 	 000h, 028h, 040h, 004h, 0DAh, 0dbh, 0DAh, 056h
 defb 	 048h, 048h, 02Bh, 048h, 0DAh, 0dbh, 0DAh, 056h
 defb 	 048h, 000h, 02Bh, 048h, 06Dh, 06Eh, 06Dh, 056h
 defb 	 051h, 051h, 02Bh, 048h, 06Dh, 06Eh, 06Dh, 056h
 defb 	 051h, 000h, 02Bh, 048h, 009h, 0DAh, 0dbh, 0DAh
 defb 	 056h, 048h, 048h, 02Bh, 048h, 0DAh, 0dbh, 0DAh
 defb 	 056h, 048h, 000h, 02Bh, 048h, 06Dh, 06Eh, 06Dh
 defb 	 051h, 061h, 061h, 028h, 048h, 004h, 06Dh, 06Eh
 defb 	 06Dh, 051h, 061h, 000h, 028h, 048h, 004h, 0DAh
 defb 	 0dbh, 0DAh, 051h, 048h, 048h, 028h, 048h, 0DAh
 defb 	 0dbh, 0DAh, 051h, 048h, 000h, 028h, 048h, 004h
 defb 	 06Dh, 06Eh, 06Dh, 051h, 051h, 051h, 028h, 048h
 defb 	 06Dh, 06Eh, 06Dh, 051h, 051h, 000h, 028h, 048h
 defb 	 009h, 0DAh, 0dbh, 0DAh, 048h, 048h, 048h, 024h
 defb 	 048h, 004h, 0DAh, 0dbh, 0DAh, 048h, 048h, 000h
 defb 	 024h, 048h, 06Dh, 06Eh, 06Dh, 048h, 061h, 061h
 defb 	 024h, 048h, 06Dh, 06Eh, 06Dh, 048h, 061h, 000h
 defb 	 024h, 048h, 004h, 091h, 092h, 091h, 040h, 030h
 defb 	 030h, 020h, 03Dh, 091h, 092h, 091h, 040h, 030h
 defb 	 000h, 020h, 03Dh, 048h, 049h, 048h, 040h, 036h
 defb 	 036h, 020h, 03Dh, 048h, 049h, 048h, 040h, 036h
 defb 	 000h, 020h, 03Dh, 009h, 091h, 092h, 091h, 040h
 defb 	 030h, 030h, 020h, 03Dh, 091h, 092h, 091h, 040h
 defb 	 030h, 000h, 020h, 03Dh, 048h, 049h, 048h, 048h
 defb 	 03Dh, 03Dh, 024h, 03Dh, 004h, 048h, 049h, 048h
 defb 	 048h, 03Dh, 000h, 024h, 03Dh, 004h, 091h, 092h
 defb 	 091h, 048h, 030h, 030h, 024h, 03Dh, 091h, 092h
 defb 	 091h, 048h, 030h, 000h, 024h, 03Dh, 048h, 049h
 defb 	 048h, 048h, 036h, 036h, 024h, 03Dh, 048h, 049h
 defb 	 048h, 048h, 036h, 000h, 024h, 03Dh, 009h, 091h
 defb 	 092h, 091h, 051h, 030h, 030h, 028h, 03Dh, 091h
 defb 	 092h, 091h, 051h, 030h, 000h, 028h, 03Dh, 048h
 defb 	 049h, 048h, 051h, 03Dh, 03Dh, 028h, 03Dh, 048h
 defb 	 049h, 048h, 051h, 03Dh, 000h, 028h, 03Dh, 004h
 defb 	 07Ah, 07Bh, 07Ah, 040h, 028h, 028h, 020h, 030h
 defb 	 07Ah, 07Bh, 07Ah, 040h, 028h, 000h, 020h, 030h
 defb 	 03Dh, 03Eh, 03Dh, 040h, 02Bh, 02Bh, 020h, 030h
 defb 	 03Dh, 03Eh, 03Dh, 040h, 02Bh, 000h, 020h, 030h
 defb 	 009h, 07Ah, 07Bh, 07Ah, 040h, 028h, 028h, 020h
 defb 	 030h, 07Ah, 07Bh, 07Ah, 040h, 028h, 000h, 020h
 defb 	 030h, 03Dh, 03Eh, 03Dh, 048h, 030h, 030h, 024h
 defb 	 030h, 004h, 03Dh, 03Eh, 03Dh, 048h, 030h, 000h
 defb 	 024h, 030h, 004h, 07Ah, 07Bh, 07Ah, 048h, 028h
 defb 	 028h, 024h, 030h, 009h, 07Ah, 07Bh, 07Ah, 048h
 defb 	 028h, 000h, 024h, 030h, 009h, 03Dh, 03Eh, 03Dh
 defb 	 048h, 02Bh, 02Bh, 024h, 030h, 009h, 03Dh, 03Eh
 defb 	 03Dh, 048h, 02Bh, 000h, 024h, 030h, 009h, 07Ah
 defb 	 07Bh, 07Ah, 051h, 030h, 030h, 028h, 030h, 07Ah
 defb 	 07Bh, 07Ah, 051h, 030h, 000h, 028h, 030h, 009h
 defb 	 03Dh, 03Eh, 03Dh, 051h, 036h, 036h, 028h, 030h
 defb 	 009h, 03Dh, 03Eh, 03Dh, 051h, 036h, 000h, 028h
 defb 	 030h, 001h

PAT19:
 defw 	006F7h
 defb 	  07Ah, 07Bh, 07Ah, 061h
 defb 	 000h, 000h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 000h, 000h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 000h, 000h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 061h, 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 061h, 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 061h, 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 061h, 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 061h, 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 061h, 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 061h, 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 06Dh
 defb 	 061h, 030h, 06Eh, 036h, 07Ah, 07Bh, 07Ah, 06Dh
 defb 	 061h, 030h, 06Eh, 036h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 061h, 030h, 062h, 030h, 07Ah, 07Bh, 07Ah, 061h
 defb 	 06Dh, 036h, 062h, 030h, 07Ah, 07Bh, 07Ah, 056h
 defb 	 06Dh, 036h, 057h, 02Bh, 07Ah, 07Bh, 07Ah, 056h
 defb 	 061h, 030h, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h
 defb 	 061h, 030h, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h
 defb 	 056h, 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h
 defb 	 056h, 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h
 defb 	 056h, 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h
 defb 	 056h, 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 056h
 defb 	 056h, 02Bh, 057h, 02Bh, 0DAh, 0dbh, 0DAh, 061h
 defb 	 056h, 02Bh, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h
 defb 	 056h, 02Bh, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h
 defb 	 056h, 02Bh, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h
 defb 	 061h, 030h, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h
 defb 	 061h, 030h, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h
 defb 	 061h, 030h, 062h, 030h, 0DAh, 0dbh, 0DAh, 06Dh
 defb 	 061h, 030h, 06Eh, 036h, 0DAh, 0dbh, 0DAh, 06Dh
 defb 	 061h, 030h, 06Eh, 036h, 0DAh, 0dbh, 0DAh, 061h
 defb 	 061h, 030h, 062h, 030h, 0DAh, 0dbh, 0DAh, 061h
 defb 	 06Dh, 036h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h
 defb 	 06Dh, 036h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h
 defb 	 061h, 030h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h
 defb 	 061h, 030h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h
 defb 	 061h, 030h, 062h, 030h, 0C2h, 0C3h, 0C2h, 061h
 defb 	 061h, 030h, 000h, 030h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 061h, 030h, 000h, 030h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 061h, 030h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 061h, 030h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 000h, 030h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 000h, 000h, 000h, 000h, 0C2h, 0C3h, 0C2h, 000h
 defb 	 000h, 000h, 000h, 000h, 009h, 0C2h, 0C3h, 0C2h
 defb 	 000h, 000h, 000h, 000h, 000h, 009h, 0C2h, 0C3h
 defb 	 0C2h, 000h, 000h, 000h, 000h, 000h, 0C2h, 0C3h
 defb 	 0C2h, 040h, 000h, 000h, 041h, 020h, 009h, 0C2h
 defb 	 0C3h, 0C2h, 040h, 000h, 000h, 041h, 020h, 009h
 defb 	 0C2h, 0C3h, 0C2h, 048h, 000h, 000h, 049h, 024h
 defb 	 0C2h, 0C3h, 0C2h, 048h, 040h, 020h, 049h, 024h
 defb 	 009h, 0C2h, 0C3h, 0C2h, 051h, 040h, 020h, 052h
 defb 	 028h, 009h, 0C2h, 0C3h, 0C2h, 051h, 048h, 024h
 defb 	 052h, 028h, 0C2h, 0C3h, 0C2h, 056h, 048h, 024h
 defb 	 057h, 02Bh, 009h, 0C2h, 0C3h, 0C2h, 056h, 051h
 defb 	 028h, 057h, 02Bh, 009h, 0C2h, 0C3h, 0C2h, 06Dh
 defb 	 051h, 028h, 06Eh, 036h, 0C2h, 0C3h, 0C2h, 06Dh
 defb 	 056h, 02Bh, 06Eh, 036h, 009h, 0C2h, 0C3h, 0C2h
 defb 	 081h, 056h, 02Bh, 082h, 040h, 0C2h, 0C3h, 0C2h
 defb 	 081h, 06Dh, 036h, 082h, 040h, 009h, 0C2h, 0C3h
 defb 	 0C2h, 06Dh, 06Dh, 036h, 06Eh, 036h, 0C2h, 0C3h
 defb 	 0C2h, 06Dh, 081h, 040h, 06Eh, 036h, 001h

PAT20:
 defw 	006F7h
 defb  004h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 06Dh, 000h, 000h
 defb 	 06Eh, 000h, 07Ah, 07Bh, 000h, 06Dh, 000h, 000h
 defb 	 06Eh, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 07Ah, 07Bh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 07Ah, 07Bh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 0DAh, 0dbh, 000h, 061h, 000h, 000h
 defb 	 062h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 051h, 000h, 000h
 defb 	 052h, 000h, 0DAh, 0dbh, 000h, 051h, 000h, 000h
 defb 	 052h, 000h, 0C2h, 0C3h, 000h, 051h, 000h, 000h
 defb 	 052h, 000h, 0C2h, 0C3h, 000h, 051h, 000h, 000h
 defb 	 052h, 000h, 0C2h, 0C3h, 000h, 051h, 000h, 000h
 defb 	 052h, 000h, 0C2h, 0C3h, 000h, 051h, 000h, 000h
 defb 	 052h, 000h, 0C2h, 0C3h, 000h, 051h, 000h, 000h
 defb 	 052h, 000h, 0C2h, 0C3h, 000h, 051h, 000h, 000h
 defb 	 052h, 000h, 0C2h, 0C3h, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0C2h, 0C3h, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0C2h, 0C3h, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0C2h, 0C3h, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0C2h, 0C3h, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0C2h, 0C3h, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0C2h, 0C3h, 000h, 06Dh, 000h, 000h
 defb 	 06Eh, 000h, 0C2h, 0C3h, 000h, 06Dh, 000h, 000h
 defb 	 06Eh, 000h, 0C2h, 0C3h, 000h, 081h, 000h, 000h
 defb 	 082h, 000h, 0C2h, 0C3h, 000h, 081h, 000h, 000h
 defb 	 082h, 000h, 0DAh, 0dbh, 000h, 081h, 000h, 000h
 defb 	 082h, 000h, 0DAh, 0dbh, 000h, 081h, 000h, 000h
 defb 	 082h, 000h, 0DAh, 0dbh, 000h, 081h, 000h, 000h
 defb 	 082h, 000h, 0DAh, 0dbh, 000h, 081h, 000h, 000h
 defb 	 082h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 0DAh, 0dbh, 000h, 056h, 000h, 000h
 defb 	 057h, 000h, 009h, 0DAh, 0dbh, 000h, 061h, 000h
 defb 	 000h, 062h, 000h, 0DAh, 0dbh, 000h, 061h, 000h
 defb 	 000h, 062h, 000h, 009h, 0DAh, 0dbh, 000h, 06Dh
 defb 	 000h, 000h, 06Eh, 000h, 0DAh, 0dbh, 000h, 06Dh
 defb 	 000h, 000h, 06Eh, 000h, 009h, 0DAh, 0dbh, 000h
 defb 	 061h, 000h, 000h, 062h, 000h, 009h, 0DAh, 0dbh
 defb 	 000h, 061h, 000h, 000h, 062h, 000h, 001h

PAT21:
 defw 	006F7h
 defb  004h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 056h, 000h, 000h
 defb 	 000h, 000h, 07Ah, 000h, 000h, 056h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 056h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 056h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 056h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 056h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 056h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 056h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 06Dh, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0DAh, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 061h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 001h

PAT22:
 defw 	006F7h
 defb  000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb 	 000h, 000h, 000h, 000h, 000h, 001h

PAT23:
 defw 	0c0DEh
 defb 	 000h, 001h, 0DEh, 0C0h, 000h, 000h, 000h, 000h


end:		dw	#C0DE

