; OCTODE XL X2.    SPRING IS COMING.  MR BEEP.
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

		;MODULE OctodeXL

	output "spring.obj"

		ORG	#8000

begin:		ld	hl, musicdata
		call	play
		ld	hl, (end)	; funny test to identify sna
		ld	de, 65536-#C0DE
		add	hl, de
		ld	a, h
		or	l
		jr	z, begin
		ret

vol1234: 	EQU 1
vol5678:	EQU 1
octodeDrums:	EQU 12500
slowDecay:	EQU 0
storeA:		EQU 0





play:
		ei
		halt			; must ensure that test is done during the border
		in a,(#1f)
		inc a
		jr nz,haveKempston
		ld (maskKempston),a
haveKempston:
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

rowEnd:		in a,(#1f)
		and #1f
maskKempston:	EQU $-1
		ld c,a
		in a,(#fe)
		cpl
		or c
		and #1f
		jr nz,stopPlayer

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
	and 33
	 ld c,a
	ld a,(hl) 
	 add a 
	 and 33 
	 ld (.noiseOn),a

		ld hl,#C0DE
.drumSeed:	EQU $-2

.drumLoop:	dec e 
	 jr nz,.keepNoise
		ld a,(.noiseOn) 
	 xor 32 : ld (.noiseOn),a
.keepNoise:
		ld b,45
.drumPeriod:	EQU $-1

.noiseLoop:	ld a,c 
		; out (254),a
		ld	($6800),a 

		add hl,hl 
		 sbc a
		and #BD			; instead of #BD, one can use #3F or #D7
		xor l 
		 ld l,a


;		and 16 
		and 32 
		or 0
.noiseOn:	EQU $-1
		ld	($6800),a
;		out (254),a

		djnz .noiseLoop

		ld a,c
		xor 32	;16
		ld c,a

		dec d : jr nz,.drumLoop
		; (4+12 + 7 + (4+11 + 11+4+7+4+4 + 7+7+11+13)*B-5 + 4+7+4 + 4+12)*D = (83*B+49)*D

		ld (.drumSeed),hl	; 16

		xor a 
;	 out (254),a
		ld	($6800),a

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
		and 32;16			; 4+4+4 + 4+4+7=27t

;		out (254),a		; 11t
		ld	($6800),a


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
;		out (254),a
		ld	($6800),a

	
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


; SPRING IS COMING.  Mr Beep.  For Octode XL.  X2.
;
; ============================================================
musicdata:
MLOOP:
 defw   PAT02	;  0841Ch
 defw   PAT01	;  08219h  
 defw   PAT02	;  0841Ch  
 defw   PAT03	;  0861Fh
 defw   PAT04	;  0882Dh 
 defw   PAT05	;  08A3Fh  
 defw   PAT04	;  0882Dh  
 defw   PAT05	;  08A3Fh 
 defw   PAT06	;  08c52h 
 defw   PAT07	;  08E64h 
 defw   PAT06	;  08C52h 
 defw   PAT08	;  0907Ah
 defw   PAT09	;  09290h 
 defw   PAT10	;  094A2h 
 defw   PAT09	;  09290h 
 defw   PAT11	;       096B8h 
 defw   PAT14	;  	 09cF1h 
 defw   PAT15	;         09EF5h 
 defw   PAT12	;          098CEh 
 defw   PAT13	;          09ADDh 
 defw   PAT23	;  	 0AF5Ch 
 defw   PAT18	;         0A51Ch 
 defw   PAT19	;          0A722h 
 defw   PAT20	;          0A92Ah 
 defw   PAT21	;  	 0AB38h 
 defw   PAT22	;         0AD47h 
 defw   PAT16	;          0A0F8h 
 defw   PAT17	;          0A30Ah 
 defw   PAT16	;  	 0A0F8h 
 defw   PAT17	;         0A30Ah 
 defw   PAT27	;          0B77Ah 
 defw   PAT24	;          0B160h 
 defw   PAT25	;  	 0B364h 
 defw   PAT24	;         0B160h 
 defw   PAT26	;          0B56Bh 
 defw   PAT28	;          0B97Eh 
 defw   PAT29	;  	 0BB90h 
 defw   PAT28	;         0B97Eh 
 defw   PAT29	;          0BB90h 
 defw   PAT28	;          0B97Eh 
 defw   PAT29	;  	 0BB90h 
 defw   PAT28	;         0B97Eh 
 defw   PAT29	;          0BB90h 
 defw   PAT30	;          0BDA7h 
 defw   00000h
 defw   MLOOP	; 081BDh



; PATTERN ORDER IN SEQUENCE TO WORK OUT THE ABOVE 
; defw   08219h 1
; defw   0841Ch 2
; defw   0861Fh 3
; defw   0882Dh 4
; defw   08A3Fh 5
; defw   08c52h 6
; defw   08E64h 7
; defw   0907Ah 8
; defw   09290h 9
; defw   094A2h 10
; defw   096B8h 11
; defw   098CEh 12
; defw   09ADDh 13
; defw   09cF1h 14
; defw   09EF5h 15
; defw   0A0F8h 16
; defw   0A30Ah 17
; defw   0A51Ch 18
; defw   0A722h 19
; defw   0A92Ah 20
; defw   0AB38h 21
; defw   0AD47h 22
; defw   0AF5Ch 23
; defw   0B160h 24
; defw   0B364h 25
; defw   0B56Bh 26
; defw   0B77Ah 27
; defw   0B97Eh 28
; defw   0BB90h 29
; defw   0BDA7h 30


PAT01:
 defw   003FBh
 defb    0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 0ACh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 0ACh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 048h, 055h, 047h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 001h

PAT02:
 defw    003FBh
 defb    091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 048h, 039h, 047h, 038h
 defb    090h, 091h, 090h, 091h, 000h, 000h, 000h, 000h
 defb    090h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh
 defb    0C1h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    0C1h, 001h

PAT03:
 defw    003FBh
 defb   0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 0ACh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 0ACh, 004h, 0DAh, 0DBh, 0DAh
 defb    056h, 036h, 055h, 035h, 0DBh, 0DAh, 0DBh, 0DAh
 defb    000h, 000h, 000h, 000h, 0DBh, 0DAh, 0DBh, 0DAh
 defb    056h, 036h, 055h, 035h, 0DBh, 0DAh, 0DBh, 0DAh
 defb    000h, 000h, 000h, 000h, 0DBh, 004h, 0DAh, 0DBh
 defb    0DAh, 056h, 036h, 055h, 035h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 036h, 055h, 035h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 036h, 055h, 035h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 000h, 000h, 000h, 000h, 0DBh, 004h, 0DAh
 defb    0DBh, 0DAh, 056h, 036h, 055h, 035h, 0DBh, 0DAh
 defb    0DBh, 0DAh, 000h, 000h, 000h, 000h, 0DBh, 0DAh
 defb    0DBh, 0DAh, 056h, 036h, 055h, 035h, 0DBh, 0DAh
 defb    0DBh, 0DAh, 000h, 000h, 000h, 000h, 0DBh, 004h
 defb    0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h, 0DBh
 defb    0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h, 0DBh
 defb    0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h, 0DBh
 defb    0DAh, 0DBh, 0DAh, 000h, 000h, 000h, 000h, 0DBh
 defb    004h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h
 defb    0DBh, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h, 000h
 defb    0DBh, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h
 defb    0DBh, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h, 000h
 defb    0DBh, 003h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h
 defb    035h, 0DBh, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h
 defb    035h, 0DBh, 003h, 0DAh, 0DBh, 0DAh, 056h, 036h
 defb    055h, 035h, 0DBh, 0DAh, 0DBh, 0DAh, 000h, 000h
 defb    000h, 000h, 0DBh, 003h, 0DAh, 0DBh, 0DAh, 056h
 defb    036h, 055h, 035h, 0DBh, 0DAh, 0DBh, 0DAh, 000h
 defb    000h, 000h, 000h, 0DBh, 003h, 0DAh, 0DBh, 0DAh
 defb    056h, 036h, 055h, 035h, 0DBh, 0DAh, 0DBh, 0DAh
 defb    000h, 000h, 000h, 000h, 0DBh, 003h, 0DAh, 0DBh
 defb    0DAh, 056h, 036h, 055h, 035h, 0DBh, 0DAh, 0DBh
 defb    0DAh, 056h, 036h, 055h, 035h, 0DBh, 003h, 0DAh
 defb    0DBh, 0DAh, 056h, 036h, 055h, 035h, 0DBh, 0DAh
 defb    0DBh, 0DAh, 000h, 000h, 000h, 000h, 0DBh, 001h

PAT04:
 defw    003FBh
 defb   004h, 091h, 090h, 091h, 048h, 039h
 defb    030h, 090h, 000h, 091h, 090h, 091h, 000h, 000h
 defb    000h, 090h, 000h, 091h, 090h, 091h, 048h, 039h
 defb    030h, 090h, 000h, 091h, 090h, 091h, 000h, 000h
 defb    000h, 090h, 000h, 091h, 000h, 000h, 048h, 039h
 defb    030h, 000h, 000h, 000h, 000h, 000h, 048h, 039h
 defb    030h, 000h, 000h, 091h, 090h, 091h, 048h, 039h
 defb    030h, 090h, 000h, 091h, 090h, 091h, 000h, 000h
 defb    000h, 090h, 000h, 003h, 091h, 090h, 091h, 048h
 defb    039h, 030h, 090h, 000h, 091h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 091h, 000h, 000h, 048h
 defb    039h, 030h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 091h, 090h, 091h, 048h
 defb    039h, 030h, 090h, 000h, 091h, 090h, 091h, 048h
 defb    039h, 030h, 090h, 000h, 091h, 090h, 091h, 048h
 defb    039h, 030h, 090h, 000h, 091h, 090h, 091h, 000h
 defb    000h, 000h, 090h, 000h, 004h, 091h, 090h, 091h
 defb    048h, 039h, 030h, 090h, 000h, 091h, 090h, 091h
 defb    000h, 000h, 000h, 090h, 000h, 0C2h, 0C1h, 0C2h
 defb    048h, 039h, 030h, 0C1h, 000h, 0C2h, 0C1h, 0C2h
 defb    000h, 000h, 000h, 0C1h, 000h, 004h, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 030h, 0ACh, 000h, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 030h, 0ACh, 000h, 0C2h, 0C1h
 defb    0C2h, 048h, 039h, 030h, 0C1h, 000h, 0C2h, 0C1h
 defb    0C2h, 000h, 000h, 000h, 0C1h, 000h, 003h, 091h
 defb    090h, 091h, 048h, 039h, 030h, 090h, 000h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 090h, 000h, 004h
 defb    091h, 000h, 000h, 048h, 039h, 030h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    091h, 090h, 091h, 048h, 039h, 030h, 090h, 000h
 defb    091h, 090h, 091h, 048h, 039h, 030h, 090h, 000h
 defb    081h, 080h, 081h, 048h, 039h, 030h, 080h, 000h
 defb    081h, 080h, 081h, 000h, 000h, 000h, 080h, 000h
 defb    004h, 0C2h, 0C1h, 0C2h, 048h, 040h, 039h, 0C1h
 defb    000h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 0C1h
 defb    000h, 0C2h, 0C1h, 0C2h, 048h, 040h, 039h, 0C1h
 defb    000h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 0C1h
 defb    000h, 0C2h, 000h, 000h, 048h, 040h, 039h, 000h
 defb    000h, 000h, 000h, 000h, 048h, 040h, 039h, 000h
 defb    000h, 0C2h, 0C1h, 0C2h, 048h, 040h, 039h, 0C1h
 defb    000h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 0C1h
 defb    000h, 003h, 0C2h, 0C1h, 0C2h, 048h, 040h, 030h
 defb    0C1h, 000h, 0C2h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 048h, 040h, 030h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 0C2h, 0C1h, 0C2h, 048h, 040h, 030h
 defb    0C1h, 000h, 0C2h, 0C1h, 0C2h, 048h, 040h, 030h
 defb    0C1h, 000h, 004h, 0C2h, 0C1h, 0C2h, 048h, 040h
 defb    030h, 0C1h, 000h, 0C2h, 0C1h, 0C2h, 000h, 000h
 defb    000h, 0C1h, 000h, 004h, 0C2h, 0C1h, 0C2h, 04Dh
 defb    040h, 039h, 0C1h, 000h, 0C2h, 0C1h, 0C2h, 000h
 defb    000h, 000h, 0C1h, 000h, 081h, 080h, 081h, 04Dh
 defb    040h, 039h, 080h, 000h, 081h, 080h, 081h, 000h
 defb    000h, 000h, 080h, 000h, 004h, 073h, 072h, 073h
 defb    04Dh, 040h, 039h, 072h, 000h, 073h, 072h, 073h
 defb    04Dh, 040h, 039h, 072h, 000h, 081h, 080h, 081h
 defb    04Dh, 040h, 039h, 080h, 000h, 081h, 080h, 081h
 defb    000h, 000h, 039h, 080h, 000h, 003h, 0C2h, 0C1h
 defb    0C2h, 04Dh, 040h, 030h, 0C1h, 000h, 0C2h, 0C1h
 defb    0C2h, 000h, 000h, 000h, 0C1h, 000h, 004h, 0C2h
 defb    000h, 000h, 04Dh, 040h, 030h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 003h
 defb    0C2h, 0C1h, 0C2h, 04Dh, 040h, 030h, 0C1h, 000h
 defb    0C2h, 0C1h, 0C2h, 04Dh, 040h, 030h, 0C1h, 000h
 defb    003h, 0B7h, 0B6h, 0B7h, 04Dh, 040h, 030h, 0B6h
 defb    000h, 0B7h, 0B6h, 0B7h, 000h, 000h, 000h, 0B6h
 defb    000h, 001h

PAT05:
 defw    03FBh
 defb    004h, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 02Bh, 0ADh, 000h, 0ADh, 0ACh, 0ADh
 defb    000h, 000h, 000h, 0ADh, 000h, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 02Bh, 0ADh, 000h, 0ADh, 0ACh, 0ADh
 defb    000h, 000h, 000h, 0ADh, 000h, 0ADh, 000h, 000h
 defb    048h, 039h, 02Bh, 000h, 000h, 000h, 000h, 000h
 defb    048h, 039h, 02Bh, 000h, 000h, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 02Bh, 0ADh, 000h, 0ADh, 0ACh, 0ADh
 defb    000h, 000h, 000h, 0ADh, 000h, 003h, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 02Bh, 0ADh, 000h, 0ADh, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 048h, 039h, 02Bh, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 02Bh, 0ADh, 000h, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 02Bh, 0ADh, 000h, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 02Bh, 0ADh, 000h, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 0ADh, 000h, 004h, 0ADh
 defb    0ACh, 0ADh, 048h, 039h, 02Bh, 0ADh, 000h, 0ADh
 defb    0ACh, 0ADh, 000h, 000h, 000h, 0ADh, 000h, 073h
 defb    072h, 073h, 048h, 039h, 02Bh, 073h, 000h, 073h
 defb    072h, 073h, 000h, 000h, 000h, 073h, 000h, 004h
 defb    061h, 060h, 061h, 048h, 039h, 02Bh, 061h, 000h
 defb    061h, 060h, 061h, 048h, 039h, 02Bh, 061h, 000h
 defb    073h, 072h, 073h, 048h, 039h, 02Bh, 073h, 000h
 defb    073h, 072h, 073h, 000h, 000h, 000h, 073h, 000h
 defb    003h, 056h, 055h, 056h, 048h, 039h, 030h, 056h
 defb    000h, 056h, 055h, 056h, 000h, 000h, 000h, 056h
 defb    000h, 004h, 056h, 000h, 000h, 048h, 039h, 030h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 056h, 055h, 056h, 048h, 039h, 030h
 defb    056h, 000h, 056h, 055h, 056h, 048h, 039h, 030h
 defb    056h, 000h, 061h, 060h, 061h, 048h, 039h, 030h
 defb    061h, 000h, 061h, 060h, 061h, 000h, 000h, 000h
 defb    061h, 000h, 004h, 06Dh, 06Ch, 06Dh, 056h, 048h
 defb    036h, 06Dh, 000h, 06Dh, 06Ch, 06Dh, 000h, 000h
 defb    000h, 06Dh, 000h, 06Dh, 06Ch, 06Dh, 056h, 048h
 defb    036h, 06Dh, 000h, 06Dh, 06Ch, 06Dh, 000h, 000h
 defb    000h, 06Dh, 000h, 06Dh, 000h, 000h, 056h, 048h
 defb    036h, 000h, 000h, 000h, 000h, 000h, 056h, 048h
 defb    036h, 000h, 000h, 06Dh, 06Ch, 06Dh, 056h, 048h
 defb    036h, 06Dh, 000h, 06Dh, 06Ch, 06Dh, 000h, 000h
 defb    000h, 06Dh, 000h, 003h, 06Dh, 06Ch, 06Dh, 056h
 defb    048h, 036h, 06Dh, 000h, 06Dh, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 056h
 defb    048h, 036h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 06Dh, 06Ch, 06Dh, 056h
 defb    048h, 036h, 06Dh, 000h, 06Dh, 06Ch, 06Dh, 056h
 defb    048h, 036h, 06Dh, 000h, 004h, 06Dh, 06Ch, 06Dh
 defb    056h, 048h, 036h, 06Dh, 000h, 06Dh, 06Ch, 06Dh
 defb    000h, 000h, 000h, 06Dh, 000h, 004h, 06Dh, 06Ch
 defb    06Dh, 056h, 048h, 036h, 06Dh, 000h, 06Dh, 06Ch
 defb    06Dh, 000h, 000h, 000h, 06Dh, 000h, 003h, 091h
 defb    090h, 091h, 056h, 048h, 036h, 091h, 000h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 091h, 000h, 003h
 defb    081h, 080h, 081h, 056h, 048h, 036h, 081h, 000h
 defb    081h, 080h, 081h, 056h, 048h, 036h, 081h, 000h
 defb    003h, 091h, 090h, 091h, 056h, 048h, 036h, 091h
 defb    000h, 091h, 090h, 091h, 000h, 000h, 000h, 091h
 defb    000h, 003h, 06Dh, 06Ch, 06Dh, 056h, 048h, 039h
 defb    06Dh, 000h, 06Dh, 06Ch, 06Dh, 000h, 000h, 000h
 defb    06Dh, 000h, 06Dh, 000h, 000h, 056h, 048h, 039h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 003h, 0C2h, 0C1h, 0C2h, 056h, 048h
 defb    039h, 0C2h, 000h, 0C2h, 0C1h, 0C2h, 056h, 048h
 defb    039h, 0C2h, 000h, 003h, 0ADh, 0ACh, 0ADh, 056h
 defb    048h, 039h, 0ADh, 000h, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 0ADh, 000h, 001h

PAT06:
 defw    03FBh
 defb    004h
 defb    091h, 090h, 091h, 048h, 039h, 04Dh, 04Ch, 091h
 defb    091h, 090h, 091h, 000h, 000h, 048h, 047h, 091h
 defb    091h, 090h, 091h, 048h, 039h, 048h, 047h, 091h
 defb    091h, 090h, 091h, 000h, 000h, 048h, 047h, 091h
 defb    004h, 091h, 000h, 000h, 048h, 039h, 048h, 047h
 defb    091h, 000h, 000h, 000h, 048h, 039h, 048h, 047h
 defb    000h, 091h, 090h, 091h, 048h, 039h, 048h, 047h
 defb    091h, 091h, 090h, 091h, 000h, 000h, 048h, 047h
 defb    091h, 003h, 091h, 090h, 091h, 048h, 039h, 048h
 defb    047h, 091h, 091h, 000h, 000h, 000h, 000h, 048h
 defb    000h, 091h, 004h, 000h, 000h, 000h, 048h, 039h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 091h, 090h, 091h, 048h, 039h
 defb    091h, 000h, 091h, 091h, 090h, 091h, 048h, 039h
 defb    091h, 000h, 091h, 004h, 091h, 090h, 091h, 048h
 defb    039h, 091h, 000h, 091h, 091h, 090h, 091h, 000h
 defb    000h, 091h, 000h, 091h, 004h, 091h, 090h, 091h
 defb    048h, 039h, 091h, 000h, 091h, 091h, 090h, 091h
 defb    000h, 000h, 091h, 000h, 091h, 0C2h, 0C1h, 0C2h
 defb    048h, 039h, 0C2h, 000h, 0C2h, 0C2h, 0C1h, 0C2h
 defb    000h, 000h, 0C2h, 000h, 0C2h, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 040h, 03Fh, 0ADh, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 039h, 038h, 0ADh, 0C2h, 0C1h, 0C2h
 defb    0C2h, 039h, 039h, 038h, 0C2h, 0C2h, 0C1h, 0C2h
 defb    0C2h, 000h, 039h, 038h, 0C2h, 003h, 091h, 090h
 defb    091h, 048h, 039h, 048h, 047h, 091h, 091h, 090h
 defb    091h, 000h, 000h, 048h, 047h, 091h, 091h, 000h
 defb    000h, 048h, 039h, 048h, 047h, 091h, 000h, 000h
 defb    000h, 000h, 000h, 048h, 047h, 000h, 091h, 090h
 defb    091h, 048h, 039h, 040h, 03Fh, 091h, 091h, 090h
 defb    091h, 048h, 039h, 040h, 03Fh, 091h, 081h, 080h
 defb    081h, 048h, 039h, 040h, 03Fh, 081h, 081h, 080h
 defb    081h, 000h, 000h, 040h, 03Fh, 081h, 004h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 040h, 03Fh, 061h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 040h, 03Fh, 061h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 040h, 03Fh, 000h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 040h, 03Fh, 000h, 004h
 defb    0C2h, 000h, 000h, 048h, 040h, 040h, 000h, 02Bh
 defb    000h, 000h, 000h, 048h, 040h, 000h, 000h, 02Bh
 defb    0C2h, 0C1h, 0C2h, 048h, 040h, 0C2h, 000h, 000h
 defb    0C2h, 0C1h, 0C2h, 000h, 000h, 0C2h, 000h, 000h
 defb    003h, 0C2h, 0C1h, 0C2h, 048h, 040h, 0C2h, 000h
 defb    030h, 0C2h, 000h, 000h, 000h, 0C2h, 0C2h, 000h
 defb    030h, 004h, 000h, 000h, 000h, 048h, 040h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 0C2h, 0C1h, 0C2h, 048h, 040h, 0C2h
 defb    000h, 02Bh, 0C2h, 0C1h, 0C2h, 048h, 040h, 0C2h
 defb    000h, 02Bh, 0C2h, 0C1h, 0C2h, 048h, 040h, 0C2h
 defb    000h, 000h, 0C2h, 0C1h, 0C2h, 000h, 000h, 0C2h
 defb    000h, 000h, 004h, 0C2h, 0C1h, 0C2h, 04Dh, 040h
 defb    0C2h, 000h, 039h, 0C2h, 0C1h, 0C2h, 000h, 000h
 defb    0C2h, 000h, 039h, 081h, 080h, 081h, 04Dh, 040h
 defb    081h, 000h, 000h, 081h, 080h, 081h, 000h, 000h
 defb    081h, 000h, 000h, 073h, 072h, 073h, 04Dh, 040h
 defb    048h, 047h, 030h, 073h, 072h, 073h, 04Dh, 040h
 defb    048h, 047h, 030h, 081h, 080h, 081h, 081h, 040h
 defb    048h, 047h, 000h, 081h, 080h, 081h, 081h, 000h
 defb    048h, 047h, 000h, 003h, 0C2h, 0C1h, 0C2h, 04Dh
 defb    040h, 040h, 03Fh, 040h, 0C2h, 0C1h, 0C2h, 000h
 defb    000h, 040h, 03Fh, 040h, 0C2h, 000h, 000h, 04Dh
 defb    040h, 040h, 03Fh, 000h, 000h, 000h, 000h, 000h
 defb    000h, 040h, 03Fh, 000h, 003h, 0C2h, 0C1h, 0C2h
 defb    04Dh, 040h, 048h, 047h, 039h, 0C2h, 0C1h, 0C2h
 defb    04Dh, 040h, 048h, 047h, 039h, 003h, 0B7h, 0B6h
 defb    0B7h, 04Dh, 040h, 048h, 047h, 0B7h, 0B7h, 0B6h
 defb    0B7h, 000h, 000h, 048h, 047h, 0B7h, 001h

PAT07:
 defw    03FBh
 defb    003h, 004h, 0ADh, 0ACh, 0ADh, 048h, 039h, 040h
 defb    03Fh, 0ADh, 0ADh, 0ACh, 0ADh, 000h, 000h, 039h
 defb    038h, 0ADh, 0ADh, 0ACh, 0ADh, 048h, 039h, 039h
 defb    038h, 0ADh, 0ADh, 0ACh, 0ADh, 000h, 000h, 039h
 defb    038h, 0ADh, 0ADh, 000h, 000h, 048h, 039h, 039h
 defb    038h, 0ADh, 000h, 000h, 000h, 048h, 039h, 039h
 defb    000h, 000h, 0ADh, 0ACh, 0ADh, 048h, 039h, 000h
 defb    000h, 0ADh, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 0ADh, 003h, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    040h, 03Fh, 0ADh, 0ADh, 000h, 000h, 000h, 000h
 defb    039h, 038h, 0ADh, 000h, 000h, 000h, 048h, 039h
 defb    039h, 038h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    039h, 038h, 000h, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    039h, 038h, 0ADh, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    039h, 000h, 0ADh, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    000h, 000h, 0ADh, 0ADh, 0ACh, 0ADh, 000h, 000h
 defb    000h, 000h, 0ADh, 004h, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 040h, 03Fh, 0ADh, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 039h, 038h, 0ADh, 073h, 072h, 073h, 048h
 defb    039h, 039h, 038h, 073h, 073h, 072h, 073h, 000h
 defb    000h, 039h, 038h, 073h, 004h, 061h, 060h, 061h
 defb    048h, 039h, 040h, 03Fh, 061h, 061h, 060h, 061h
 defb    048h, 039h, 040h, 03Fh, 061h, 073h, 072h, 073h
 defb    048h, 039h, 040h, 03Fh, 073h, 073h, 072h, 073h
 defb    000h, 000h, 040h, 03Fh, 073h, 003h, 056h, 055h
 defb    056h, 048h, 039h, 048h, 047h, 056h, 056h, 055h
 defb    056h, 000h, 000h, 048h, 047h, 056h, 004h, 056h
 defb    000h, 000h, 048h, 039h, 048h, 000h, 056h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 056h
 defb    055h, 056h, 048h, 039h, 048h, 047h, 056h, 056h
 defb    055h, 056h, 048h, 039h, 048h, 047h, 056h, 061h
 defb    060h, 061h, 048h, 039h, 048h, 047h, 061h, 061h
 defb    060h, 061h, 000h, 000h, 048h, 047h, 061h, 004h
 defb    06Dh, 06Ch, 06Dh, 056h, 048h, 048h, 047h, 061h
 defb    06Dh, 06Ch, 06Dh, 000h, 000h, 048h, 047h, 061h
 defb    06Dh, 06Ch, 06Dh, 056h, 048h, 048h, 047h, 000h
 defb    06Dh, 06Ch, 06Dh, 000h, 000h, 048h, 047h, 000h
 defb    06Dh, 000h, 000h, 056h, 048h, 048h, 047h, 02Bh
 defb    000h, 000h, 000h, 056h, 048h, 048h, 047h, 02Bh
 defb    06Dh, 06Ch, 06Dh, 06Dh, 048h, 048h, 047h, 000h
 defb    06Dh, 06Ch, 06Dh, 06Dh, 000h, 048h, 000h, 000h
 defb    003h, 06Dh, 06Ch, 06Dh, 056h, 048h, 000h, 000h
 defb    030h, 06Dh, 000h, 000h, 000h, 06Dh, 000h, 000h
 defb    030h, 004h, 000h, 000h, 000h, 056h, 048h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 003h, 06Dh, 06Ch, 06Dh, 056h, 048h
 defb    06Dh, 000h, 02Bh, 06Dh, 06Ch, 06Dh, 056h, 048h
 defb    06Dh, 000h, 02Bh, 003h, 06Dh, 06Ch, 06Dh, 056h
 defb    048h, 06Dh, 000h, 000h, 06Dh, 06Ch, 06Dh, 000h
 defb    000h, 06Dh, 000h, 000h, 003h, 06Dh, 06Ch, 06Dh
 defb    056h, 048h, 06Dh, 000h, 039h, 06Dh, 06Ch, 06Dh
 defb    000h, 000h, 06Dh, 000h, 039h, 003h, 091h, 090h
 defb    091h, 056h, 048h, 091h, 000h, 000h, 091h, 090h
 defb    091h, 000h, 000h, 091h, 000h, 000h, 003h, 081h
 defb    080h, 081h, 056h, 048h, 081h, 000h, 030h, 081h
 defb    080h, 081h, 056h, 048h, 081h, 000h, 030h, 003h
 defb    091h, 090h, 091h, 056h, 048h, 091h, 000h, 000h
 defb    091h, 090h, 091h, 000h, 000h, 091h, 000h, 000h
 defb    003h, 06Dh, 06Ch, 06Dh, 056h, 048h, 06Dh, 000h
 defb    040h, 06Dh, 06Ch, 06Dh, 000h, 000h, 06Dh, 000h
 defb    040h, 003h, 06Dh, 000h, 000h, 056h, 048h, 06Dh
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 003h, 0C2h, 0C1h, 0C2h, 056h, 048h
 defb    0C2h, 000h, 039h, 0C2h, 0C1h, 0C2h, 056h, 048h
 defb    0C2h, 000h, 039h, 003h, 0ADh, 0ACh, 0ADh, 056h
 defb    048h, 0ADh, 000h, 000h, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 0ADh, 000h, 000h, 001h

PAT08:
 defw    03FBh
 defb    004h
 defb    0ADh, 0ACh, 0ADh, 048h, 039h, 040h, 03Fh, 0ADh
 defb    0ADh, 0ACh, 0ADh, 000h, 000h, 039h, 038h, 0ADh
 defb    0ADh, 0ACh, 0ADh, 048h, 039h, 039h, 038h, 0ADh
 defb    0ADh, 0ACh, 0ADh, 000h, 000h, 039h, 038h, 0ADh
 defb    0ADh, 000h, 000h, 048h, 039h, 039h, 038h, 0ADh
 defb    000h, 000h, 000h, 048h, 039h, 039h, 000h, 000h
 defb    0ADh, 0ACh, 0ADh, 048h, 039h, 000h, 000h, 0ADh
 defb    0ADh, 0ACh, 0ADh, 000h, 000h, 000h, 000h, 0ADh
 defb    003h, 0ADh, 0ACh, 0ADh, 048h, 039h, 040h, 03Fh
 defb    0ADh, 0ADh, 000h, 000h, 000h, 000h, 039h, 038h
 defb    0ADh, 000h, 000h, 000h, 048h, 039h, 039h, 038h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 039h, 038h
 defb    000h, 0ADh, 0ACh, 0ADh, 048h, 039h, 039h, 038h
 defb    0ADh, 0ADh, 0ACh, 0ADh, 048h, 039h, 039h, 000h
 defb    0ADh, 0ADh, 0ACh, 0ADh, 048h, 039h, 000h, 000h
 defb    0ADh, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h, 000h
 defb    0ADh, 004h, 0ADh, 0ACh, 0ADh, 048h, 039h, 040h
 defb    03Fh, 0ADh, 0ADh, 0ACh, 0ADh, 000h, 000h, 039h
 defb    038h, 0ADh, 073h, 072h, 073h, 048h, 039h, 039h
 defb    038h, 073h, 073h, 072h, 073h, 000h, 000h, 039h
 defb    038h, 073h, 004h, 061h, 060h, 061h, 048h, 039h
 defb    040h, 03Fh, 061h, 061h, 060h, 061h, 048h, 039h
 defb    040h, 03Fh, 061h, 073h, 072h, 073h, 048h, 039h
 defb    040h, 03Fh, 073h, 073h, 072h, 073h, 000h, 000h
 defb    040h, 03Fh, 073h, 003h, 056h, 055h, 056h, 048h
 defb    039h, 039h, 038h, 056h, 056h, 055h, 056h, 000h
 defb    000h, 039h, 038h, 056h, 004h, 056h, 000h, 000h
 defb    048h, 039h, 039h, 000h, 056h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 056h, 055h, 056h
 defb    048h, 039h, 036h, 035h, 056h, 056h, 055h, 056h
 defb    048h, 039h, 036h, 035h, 056h, 061h, 060h, 061h
 defb    048h, 039h, 036h, 035h, 061h, 061h, 060h, 061h
 defb    000h, 000h, 036h, 035h, 061h, 004h, 06Dh, 06Ch
 defb    06Dh, 056h, 048h, 036h, 035h, 061h, 06Dh, 06Ch
 defb    06Dh, 000h, 000h, 036h, 035h, 061h, 06Dh, 06Ch
 defb    06Dh, 056h, 048h, 036h, 035h, 000h, 06Dh, 06Ch
 defb    06Dh, 000h, 000h, 036h, 035h, 000h, 06Dh, 000h
 defb    000h, 056h, 048h, 036h, 035h, 02Bh, 000h, 000h
 defb    000h, 056h, 048h, 036h, 035h, 02Bh, 06Dh, 06Ch
 defb    06Dh, 06Dh, 048h, 036h, 035h, 000h, 06Dh, 06Ch
 defb    06Dh, 06Dh, 000h, 036h, 000h, 000h, 003h, 06Dh
 defb    06Ch, 06Dh, 056h, 048h, 000h, 000h, 030h, 06Dh
 defb    000h, 000h, 000h, 06Dh, 000h, 000h, 030h, 004h
 defb    000h, 000h, 000h, 056h, 048h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    003h, 06Dh, 06Ch, 06Dh, 056h, 048h, 06Dh, 000h
 defb    02Bh, 06Dh, 06Ch, 06Dh, 056h, 048h, 06Dh, 000h
 defb    02Bh, 003h, 06Dh, 06Ch, 06Dh, 056h, 048h, 06Dh
 defb    000h, 000h, 06Dh, 06Ch, 06Dh, 000h, 000h, 06Dh
 defb    000h, 000h, 003h, 06Dh, 06Ch, 06Dh, 056h, 048h
 defb    06Dh, 000h, 039h, 06Dh, 06Ch, 06Dh, 000h, 000h
 defb    06Dh, 000h, 039h, 003h, 091h, 090h, 091h, 056h
 defb    048h, 091h, 000h, 000h, 091h, 090h, 091h, 000h
 defb    000h, 091h, 000h, 000h, 003h, 081h, 080h, 081h
 defb    056h, 048h, 081h, 000h, 030h, 081h, 080h, 081h
 defb    056h, 048h, 081h, 000h, 030h, 003h, 091h, 090h
 defb    091h, 056h, 048h, 091h, 000h, 000h, 091h, 090h
 defb    091h, 000h, 000h, 091h, 000h, 000h, 003h, 06Dh
 defb    06Ch, 06Dh, 056h, 048h, 06Dh, 000h, 040h, 06Dh
 defb    06Ch, 06Dh, 000h, 000h, 06Dh, 000h, 040h, 003h
 defb    06Dh, 000h, 000h, 056h, 048h, 06Dh, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    003h, 0C2h, 0C1h, 0C2h, 056h, 048h, 0C2h, 000h
 defb    039h, 0C2h, 0C1h, 0C2h, 056h, 048h, 0C2h, 000h
 defb    039h, 003h, 0ADh, 0ACh, 0ADh, 056h, 048h, 0ADh
 defb    000h, 000h, 0ADh, 0ACh, 0ADh, 000h, 000h, 0ADh
 defb    000h, 000h, 001h

PAT09:
 defw    03FBh
 defb    004h, 091h, 090h
 defb    091h, 048h, 039h, 04Dh, 04Ch, 039h, 091h, 090h
 defb    091h, 000h, 000h, 048h, 047h, 039h, 091h, 090h
 defb    091h, 048h, 039h, 048h, 047h, 039h, 091h, 090h
 defb    091h, 000h, 000h, 048h, 047h, 039h, 004h, 091h
 defb    000h, 000h, 048h, 039h, 048h, 047h, 039h, 000h
 defb    000h, 000h, 048h, 039h, 048h, 047h, 039h, 091h
 defb    090h, 091h, 091h, 039h, 048h, 047h, 039h, 091h
 defb    090h, 091h, 091h, 000h, 048h, 047h, 039h, 003h
 defb    091h, 090h, 091h, 048h, 039h, 048h, 047h, 000h
 defb    091h, 000h, 000h, 000h, 000h, 048h, 000h, 000h
 defb    004h, 000h, 000h, 000h, 048h, 039h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 091h, 090h, 091h, 048h, 039h, 091h, 000h
 defb    000h, 091h, 090h, 091h, 048h, 039h, 091h, 000h
 defb    000h, 004h, 091h, 090h, 091h, 048h, 039h, 091h
 defb    000h, 000h, 091h, 090h, 091h, 000h, 000h, 091h
 defb    000h, 000h, 004h, 091h, 090h, 091h, 048h, 039h
 defb    091h, 000h, 000h, 091h, 090h, 091h, 000h, 000h
 defb    091h, 000h, 000h, 0C2h, 0C1h, 0C2h, 048h, 039h
 defb    0C2h, 000h, 000h, 0C2h, 0C1h, 0C2h, 000h, 000h
 defb    0C2h, 000h, 000h, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    040h, 03Fh, 048h, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    039h, 038h, 040h, 0C2h, 0C1h, 0C2h, 0C2h, 039h
 defb    039h, 038h, 040h, 0C2h, 0C1h, 0C2h, 0C2h, 000h
 defb    039h, 038h, 040h, 003h, 091h, 090h, 091h, 048h
 defb    039h, 048h, 047h, 039h, 091h, 090h, 091h, 000h
 defb    000h, 048h, 047h, 039h, 091h, 000h, 000h, 048h
 defb    039h, 048h, 047h, 039h, 000h, 000h, 000h, 000h
 defb    000h, 048h, 047h, 039h, 091h, 090h, 091h, 048h
 defb    039h, 040h, 03Fh, 030h, 091h, 090h, 091h, 048h
 defb    039h, 040h, 03Fh, 030h, 081h, 080h, 081h, 081h
 defb    039h, 040h, 03Fh, 030h, 081h, 080h, 081h, 081h
 defb    000h, 040h, 03Fh, 030h, 004h, 0C2h, 0C1h, 0C2h
 defb    048h, 040h, 040h, 03Fh, 061h, 0C2h, 0C1h, 0C2h
 defb    000h, 000h, 040h, 03Fh, 061h, 0C2h, 0C1h, 0C2h
 defb    048h, 040h, 040h, 03Fh, 000h, 0C2h, 0C1h, 0C2h
 defb    000h, 000h, 040h, 03Fh, 000h, 004h, 0C2h, 000h
 defb    000h, 048h, 040h, 040h, 000h, 02Bh, 000h, 000h
 defb    000h, 048h, 040h, 000h, 000h, 02Bh, 0C2h, 0C1h
 defb    0C2h, 048h, 040h, 0C2h, 000h, 000h, 0C2h, 0C1h
 defb    0C2h, 000h, 000h, 0C2h, 000h, 000h, 003h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 0C2h, 000h, 030h, 0C2h
 defb    000h, 000h, 000h, 0C2h, 0C2h, 000h, 030h, 004h
 defb    000h, 000h, 000h, 048h, 040h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    0C2h, 0C1h, 0C2h, 048h, 040h, 0C2h, 000h, 02Bh
 defb    0C2h, 0C1h, 0C2h, 048h, 040h, 0C2h, 000h, 02Bh
 defb    0C2h, 0C1h, 0C2h, 048h, 040h, 0C2h, 000h, 000h
 defb    0C2h, 0C1h, 0C2h, 000h, 000h, 0C2h, 000h, 000h
 defb    004h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 0C2h, 000h
 defb    039h, 0C2h, 0C1h, 0C2h, 000h, 000h, 0C2h, 000h
 defb    039h, 081h, 080h, 081h, 04Dh, 040h, 081h, 000h
 defb    000h, 081h, 080h, 081h, 000h, 000h, 081h, 000h
 defb    000h, 073h, 072h, 073h, 04Dh, 040h, 048h, 047h
 defb    030h, 073h, 072h, 073h, 04Dh, 040h, 048h, 047h
 defb    030h, 081h, 080h, 081h, 04Dh, 040h, 048h, 047h
 defb    081h, 081h, 080h, 081h, 000h, 000h, 048h, 047h
 defb    081h, 003h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 040h
 defb    03Fh, 040h, 0C2h, 0C1h, 0C2h, 000h, 000h, 040h
 defb    03Fh, 040h, 0C2h, 000h, 000h, 04Dh, 040h, 040h
 defb    03Fh, 0C2h, 000h, 000h, 000h, 000h, 000h, 040h
 defb    03Fh, 0C2h, 003h, 0C2h, 0C1h, 0C2h, 04Dh, 040h
 defb    048h, 047h, 039h, 0C2h, 0C1h, 0C2h, 04Dh, 040h
 defb    048h, 047h, 039h, 003h, 0B7h, 0B6h, 0B7h, 04Dh
 defb    040h, 048h, 047h, 0B7h, 0B7h, 0B6h, 0B7h, 000h
 defb    000h, 048h, 047h, 0B7h, 001h

PAT10:
 defw    03FBh
 defb    004h
 defb    0ADh, 0ACh, 0ADh, 048h, 039h, 040h, 03Fh, 030h
 defb    0ADh, 0ACh, 0ADh, 000h, 000h, 039h, 038h, 02Bh
 defb    0ADh, 0ACh, 0ADh, 048h, 039h, 039h, 038h, 02Bh
 defb    0ADh, 0ACh, 0ADh, 000h, 000h, 039h, 038h, 02Bh
 defb    0ADh, 000h, 000h, 048h, 039h, 039h, 038h, 02Bh
 defb    000h, 000h, 000h, 048h, 039h, 039h, 000h, 000h
 defb    0ADh, 0ACh, 0ADh, 048h, 039h, 000h, 000h, 0ADh
 defb    0ADh, 0ACh, 0ADh, 000h, 000h, 000h, 000h, 0ADh
 defb    003h, 0ADh, 0ACh, 0ADh, 048h, 039h, 040h, 03Fh
 defb    030h, 0ADh, 000h, 000h, 000h, 000h, 039h, 038h
 defb    02Bh, 000h, 000h, 000h, 048h, 039h, 039h, 038h
 defb    02Bh, 000h, 000h, 000h, 000h, 000h, 039h, 038h
 defb    02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 039h, 0ADh
 defb    02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 039h, 0ADh
 defb    000h, 0ADh, 0ACh, 0ADh, 048h, 039h, 000h, 0ADh
 defb    000h, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h, 0ADh
 defb    000h, 004h, 0ADh, 0ACh, 0ADh, 048h, 039h, 040h
 defb    03Fh, 030h, 0ADh, 0ACh, 0ADh, 000h, 000h, 039h
 defb    038h, 02Bh, 073h, 072h, 073h, 048h, 039h, 039h
 defb    038h, 02Bh, 073h, 072h, 073h, 000h, 000h, 039h
 defb    038h, 02Bh, 004h, 061h, 060h, 061h, 048h, 039h
 defb    040h, 03Fh, 030h, 061h, 060h, 061h, 048h, 039h
 defb    040h, 03Fh, 030h, 073h, 072h, 073h, 073h, 039h
 defb    040h, 03Fh, 030h, 073h, 072h, 073h, 073h, 000h
 defb    040h, 03Fh, 030h, 003h, 056h, 055h, 056h, 048h
 defb    039h, 048h, 047h, 036h, 056h, 055h, 056h, 000h
 defb    000h, 048h, 047h, 036h, 004h, 056h, 000h, 000h
 defb    048h, 039h, 048h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 056h, 055h, 056h
 defb    048h, 039h, 048h, 047h, 036h, 056h, 055h, 056h
 defb    048h, 039h, 048h, 047h, 036h, 061h, 060h, 061h
 defb    061h, 039h, 048h, 047h, 036h, 061h, 060h, 061h
 defb    061h, 000h, 048h, 047h, 036h, 004h, 06Dh, 06Ch
 defb    06Dh, 056h, 048h, 048h, 047h, 061h, 06Dh, 06Ch
 defb    06Dh, 000h, 000h, 048h, 047h, 061h, 06Dh, 06Ch
 defb    06Dh, 056h, 048h, 048h, 047h, 06Dh, 06Dh, 06Ch
 defb    06Dh, 000h, 000h, 048h, 047h, 06Dh, 06Dh, 000h
 defb    000h, 056h, 048h, 048h, 047h, 02Bh, 000h, 000h
 defb    000h, 056h, 048h, 048h, 047h, 02Bh, 06Dh, 06Ch
 defb    06Dh, 056h, 048h, 048h, 047h, 06Dh, 06Dh, 06Ch
 defb    06Dh, 000h, 000h, 048h, 000h, 06Dh, 003h, 06Dh
 defb    06Ch, 06Dh, 056h, 048h, 000h, 000h, 030h, 06Dh
 defb    000h, 000h, 000h, 06Dh, 000h, 000h, 030h, 004h
 defb    000h, 000h, 000h, 056h, 048h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    003h, 06Dh, 06Ch, 06Dh, 056h, 048h, 06Dh, 000h
 defb    02Bh, 06Dh, 06Ch, 06Dh, 056h, 048h, 06Dh, 000h
 defb    02Bh, 003h, 06Dh, 06Ch, 06Dh, 056h, 048h, 06Dh
 defb    000h, 000h, 06Dh, 06Ch, 06Dh, 000h, 000h, 06Dh
 defb    000h, 000h, 003h, 06Dh, 06Ch, 06Dh, 056h, 048h
 defb    06Dh, 000h, 039h, 06Dh, 06Ch, 06Dh, 000h, 000h
 defb    06Dh, 000h, 039h, 003h, 091h, 090h, 091h, 056h
 defb    048h, 091h, 000h, 000h, 091h, 090h, 091h, 000h
 defb    000h, 091h, 000h, 000h, 003h, 081h, 080h, 081h
 defb    056h, 048h, 081h, 000h, 030h, 081h, 080h, 081h
 defb    056h, 048h, 081h, 000h, 030h, 003h, 091h, 090h
 defb    091h, 056h, 048h, 091h, 000h, 000h, 091h, 090h
 defb    091h, 000h, 000h, 091h, 000h, 000h, 003h, 06Dh
 defb    06Ch, 06Dh, 056h, 048h, 06Dh, 000h, 040h, 06Dh
 defb    06Ch, 06Dh, 000h, 000h, 06Dh, 000h, 040h, 003h
 defb    06Dh, 000h, 000h, 056h, 048h, 06Dh, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    003h, 0C2h, 0C1h, 0C2h, 056h, 048h, 0C2h, 000h
 defb    039h, 0C2h, 0C1h, 0C2h, 056h, 048h, 0C2h, 000h
 defb    039h, 003h, 0ADh, 0ACh, 0ADh, 056h, 048h, 0ADh
 defb    000h, 000h, 0ADh, 0ACh, 0ADh, 000h, 000h, 0ADh
 defb    000h, 000h, 001h

PAT11:
 defw    03FBh
 defb    004h, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 040h, 03Fh, 030h, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 039h, 038h, 02Bh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 039h, 038h, 02Bh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 039h, 038h, 02Bh, 0ADh, 000h
 defb    000h, 048h, 039h, 039h, 038h, 02Bh, 000h, 000h
 defb    000h, 048h, 039h, 039h, 000h, 000h, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 000h, 0ADh, 000h, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 0ADh, 000h, 003h, 0ADh
 defb    0ACh, 0ADh, 048h, 039h, 040h, 03Fh, 030h, 0ADh
 defb    000h, 000h, 000h, 0ADh, 039h, 038h, 02Bh, 000h
 defb    000h, 000h, 048h, 039h, 039h, 038h, 02Bh, 000h
 defb    000h, 000h, 000h, 000h, 039h, 038h, 02Bh, 0ADh
 defb    0ACh, 0ADh, 048h, 039h, 039h, 0ADh, 02Bh, 0ADh
 defb    0ACh, 0ADh, 048h, 039h, 039h, 0ADh, 000h, 0ADh
 defb    0ACh, 0ADh, 048h, 039h, 000h, 0ADh, 000h, 0ADh
 defb    0ACh, 0ADh, 000h, 000h, 000h, 0ADh, 000h, 004h
 defb    0ADh, 0ACh, 0ADh, 048h, 039h, 040h, 03Fh, 030h
 defb    0ADh, 0ACh, 0ADh, 000h, 000h, 039h, 038h, 02Bh
 defb    073h, 072h, 073h, 048h, 039h, 039h, 038h, 02Bh
 defb    073h, 072h, 073h, 000h, 000h, 039h, 038h, 02Bh
 defb    004h, 061h, 060h, 061h, 048h, 039h, 040h, 03Fh
 defb    026h, 061h, 060h, 061h, 048h, 039h, 040h, 03Fh
 defb    026h, 073h, 072h, 073h, 073h, 039h, 040h, 03Fh
 defb    026h, 073h, 072h, 073h, 073h, 000h, 040h, 03Fh
 defb    026h, 003h, 056h, 055h, 056h, 048h, 039h, 039h
 defb    038h, 024h, 056h, 055h, 056h, 056h, 000h, 039h
 defb    038h, 024h, 004h, 056h, 000h, 000h, 048h, 039h
 defb    039h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 056h, 055h, 056h, 048h, 039h
 defb    036h, 035h, 02Bh, 056h, 055h, 056h, 048h, 039h
 defb    036h, 035h, 02Bh, 061h, 060h, 061h, 061h, 039h
 defb    036h, 035h, 02Bh, 061h, 060h, 061h, 061h, 000h
 defb    036h, 035h, 02Bh, 004h, 06Dh, 06Ch, 06Dh, 056h
 defb    048h, 036h, 035h, 061h, 06Dh, 06Ch, 06Dh, 06Dh
 defb    000h, 036h, 035h, 061h, 06Dh, 06Ch, 06Dh, 056h
 defb    048h, 036h, 035h, 000h, 06Dh, 06Ch, 06Dh, 06Dh
 defb    000h, 036h, 035h, 000h, 06Dh, 000h, 000h, 056h
 defb    048h, 036h, 035h, 02Bh, 000h, 000h, 000h, 056h
 defb    048h, 036h, 035h, 02Bh, 06Dh, 06Ch, 06Dh, 06Dh
 defb    048h, 036h, 035h, 000h, 06Dh, 06Ch, 06Dh, 06Dh
 defb    000h, 036h, 000h, 000h, 003h, 06Dh, 06Ch, 06Dh
 defb    056h, 048h, 000h, 000h, 030h, 06Dh, 000h, 000h
 defb    000h, 000h, 000h, 000h, 030h, 004h, 000h, 000h
 defb    000h, 056h, 048h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 003h, 06Dh
 defb    06Ch, 06Dh, 056h, 048h, 06Dh, 000h, 02Bh, 06Dh
 defb    06Ch, 06Dh, 056h, 048h, 06Dh, 000h, 02Bh, 003h
 defb    06Dh, 06Ch, 06Dh, 056h, 048h, 06Dh, 000h, 000h
 defb    06Dh, 06Ch, 06Dh, 000h, 000h, 06Dh, 000h, 000h
 defb    003h, 06Dh, 06Ch, 06Dh, 056h, 048h, 06Dh, 000h
 defb    039h, 06Dh, 06Ch, 06Dh, 000h, 000h, 06Dh, 000h
 defb    039h, 003h, 091h, 090h, 091h, 056h, 048h, 091h
 defb    000h, 000h, 091h, 090h, 091h, 000h, 000h, 091h
 defb    000h, 000h, 003h, 081h, 080h, 081h, 056h, 048h
 defb    081h, 000h, 030h, 081h, 080h, 081h, 056h, 048h
 defb    081h, 000h, 030h, 003h, 091h, 090h, 091h, 056h
 defb    048h, 091h, 000h, 000h, 091h, 090h, 091h, 000h
 defb    000h, 091h, 000h, 000h, 003h, 06Dh, 06Ch, 06Dh
 defb    056h, 048h, 06Dh, 000h, 040h, 06Dh, 06Ch, 06Dh
 defb    000h, 000h, 06Dh, 000h, 040h, 003h, 06Dh, 000h
 defb    000h, 056h, 048h, 06Dh, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 003h, 0C2h
 defb    0C1h, 0C2h, 056h, 048h, 0C2h, 000h, 039h, 0C2h
 defb    0C1h, 0C2h, 056h, 048h, 0C2h, 000h, 039h, 003h
 defb    0ADh, 0ACh, 0ADh, 056h, 048h, 0ADh, 000h, 000h
 defb    0ADh, 0ACh, 0ADh, 000h, 000h, 0ADh, 000h, 000h
 defb    001h

PAT12:
 defw    03FBh
 defb    004h, 091h, 090h, 091h, 048h
 defb    039h, 047h, 038h, 039h, 091h, 090h, 091h, 000h
 defb    000h, 000h, 000h, 039h, 091h, 090h, 091h, 048h
 defb    039h, 047h, 038h, 039h, 091h, 090h, 091h, 000h
 defb    000h, 000h, 000h, 039h, 091h, 090h, 091h, 048h
 defb    039h, 047h, 038h, 039h, 091h, 090h, 091h, 048h
 defb    039h, 047h, 038h, 039h, 091h, 090h, 091h, 048h
 defb    039h, 047h, 038h, 039h, 091h, 090h, 091h, 000h
 defb    000h, 000h, 000h, 039h, 004h, 091h, 090h, 091h
 defb    048h, 039h, 047h, 038h, 039h, 091h, 090h, 091h
 defb    000h, 000h, 000h, 000h, 039h, 091h, 090h, 091h
 defb    048h, 039h, 047h, 038h, 039h, 091h, 090h, 091h
 defb    000h, 000h, 000h, 000h, 039h, 091h, 090h, 091h
 defb    048h, 039h, 047h, 038h, 039h, 091h, 090h, 091h
 defb    048h, 039h, 047h, 038h, 039h, 091h, 090h, 091h
 defb    048h, 039h, 047h, 038h, 039h, 091h, 090h, 091h
 defb    000h, 000h, 000h, 000h, 039h, 004h, 091h, 090h
 defb    091h, 048h, 039h, 047h, 038h, 024h, 091h, 090h
 defb    091h, 000h, 000h, 000h, 000h, 024h, 091h, 090h
 defb    091h, 048h, 039h, 047h, 038h, 024h, 091h, 090h
 defb    091h, 000h, 000h, 000h, 000h, 024h, 091h, 090h
 defb    091h, 048h, 039h, 047h, 038h, 024h, 091h, 090h
 defb    091h, 048h, 039h, 047h, 038h, 024h, 091h, 090h
 defb    091h, 048h, 039h, 047h, 038h, 024h, 091h, 090h
 defb    091h, 000h, 000h, 000h, 000h, 024h, 004h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 024h, 004h
 defb    091h, 090h, 091h, 048h, 039h, 047h, 038h, 024h
 defb    091h, 090h, 091h, 048h, 039h, 047h, 038h, 024h
 defb    091h, 090h, 091h, 048h, 039h, 047h, 038h, 024h
 defb    091h, 090h, 091h, 000h, 000h, 000h, 000h, 024h
 defb    004h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    026h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    024h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    024h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    024h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    024h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    024h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h, 03Fh
 defb    024h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 000h
 defb    024h, 004h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h
 defb    03Fh, 024h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 024h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h
 defb    03Fh, 024h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 024h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h
 defb    03Fh, 024h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h
 defb    03Fh, 024h, 0C2h, 0C1h, 0C2h, 048h, 040h, 047h
 defb    03Fh, 024h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 024h, 004h, 0C2h, 0C1h, 0C2h, 04Dh, 040h
 defb    04Ch, 03Fh, 026h, 0C2h, 0C1h, 0C2h, 000h, 000h
 defb    000h, 000h, 026h, 0C2h, 0C1h, 0C2h, 04Dh, 040h
 defb    04Ch, 03Fh, 026h, 0C2h, 0C1h, 0C2h, 000h, 000h
 defb    000h, 000h, 026h, 0C2h, 0C1h, 0C2h, 04Dh, 040h
 defb    04Ch, 03Fh, 026h, 0C2h, 0C1h, 0C2h, 04Dh, 040h
 defb    04Ch, 03Fh, 026h, 004h, 0C2h, 0C1h, 0C2h, 04Dh
 defb    040h, 04Ch, 03Fh, 026h, 0C2h, 0C1h, 0C2h, 000h
 defb    000h, 000h, 000h, 026h, 004h, 0C2h, 0C1h, 0C2h
 defb    04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h, 0C1h, 0C2h
 defb    000h, 000h, 000h, 000h, 026h, 0C2h, 0C1h, 0C2h
 defb    04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h, 0C1h, 0C2h
 defb    000h, 000h, 000h, 000h, 026h, 004h, 0C2h, 0C1h
 defb    0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h, 0C1h
 defb    0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 004h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 026h, 001h

PAT13:
 defw    03FBh
 defb    004h, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    047h, 038h, 02Bh, 0ADh, 0ACh, 0ADh, 000h, 000h
 defb    000h, 000h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    047h, 038h, 026h, 0ADh, 0ACh, 0ADh, 000h, 000h
 defb    000h, 000h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    047h, 038h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    047h, 038h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h
 defb    047h, 038h, 026h, 0ADh, 0ACh, 0ADh, 000h, 000h
 defb    000h, 000h, 026h, 004h, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 026h, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 026h, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 026h, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 026h, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 026h, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 026h, 0ADh, 0ACh, 0ADh, 048h
 defb    039h, 047h, 038h, 026h, 0ADh, 0ACh, 0ADh, 000h
 defb    000h, 000h, 000h, 026h, 004h, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 047h, 038h, 02Bh, 0ADh, 0ACh, 0ADh
 defb    000h, 000h, 000h, 000h, 02Bh, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 047h, 038h, 02Bh, 0ADh, 0ACh, 0ADh
 defb    000h, 000h, 000h, 000h, 02Bh, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 047h, 038h, 02Bh, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 047h, 038h, 02Bh, 0ADh, 0ACh, 0ADh
 defb    048h, 039h, 047h, 038h, 02Bh, 0ADh, 0ACh, 0ADh
 defb    000h, 000h, 000h, 000h, 02Bh, 004h, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 02Bh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 02Bh, 0ADh, 0ACh
 defb    0ADh, 048h, 039h, 047h, 038h, 02Bh, 0ADh, 0ACh
 defb    0ADh, 000h, 000h, 000h, 000h, 02Bh, 004h, 0ADh
 defb    0ACh, 0ADh, 048h, 039h, 047h, 038h, 02Bh, 0ADh
 defb    0ACh, 0ADh, 048h, 039h, 047h, 038h, 02Bh, 004h
 defb    0ADh, 0ACh, 0ADh, 048h, 039h, 047h, 038h, 02Bh
 defb    0ADh, 0ACh, 0ADh, 000h, 000h, 000h, 000h, 02Bh
 defb    004h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h
 defb    030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h, 000h
 defb    030h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h
 defb    030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h, 000h
 defb    030h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h
 defb    030h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h
 defb    030h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h
 defb    030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h, 000h
 defb    030h, 004h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h
 defb    035h, 030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 030h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h
 defb    035h, 030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 030h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h
 defb    035h, 030h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h
 defb    035h, 030h, 004h, 0DAh, 0DBh, 0DAh, 056h, 036h
 defb    055h, 035h, 030h, 0DAh, 0DBh, 0DAh, 000h, 000h
 defb    000h, 000h, 030h, 003h, 0DAh, 0DBh, 0DAh, 056h
 defb    036h, 055h, 035h, 036h, 0DAh, 0DBh, 0DAh, 000h
 defb    000h, 000h, 000h, 036h, 003h, 0DAh, 0DBh, 0DAh
 defb    056h, 036h, 055h, 035h, 036h, 0DAh, 0DBh, 0DAh
 defb    000h, 000h, 000h, 000h, 036h, 003h, 0DAh, 0DBh
 defb    0DAh, 056h, 036h, 055h, 035h, 036h, 0DAh, 0DBh
 defb    0DAh, 056h, 036h, 055h, 035h, 036h, 003h, 0DAh
 defb    0DBh, 0DAh, 056h, 036h, 055h, 035h, 036h, 0DAh
 defb    0DBh, 0DAh, 000h, 000h, 000h, 000h, 036h, 003h
 defb    0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h, 036h
 defb    0DAh, 0DBh, 0DAh, 000h, 000h, 000h, 000h, 036h
 defb    003h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h, 035h
 defb    036h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h, 000h
 defb    036h, 003h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h
 defb    035h, 036h, 0DAh, 0DBh, 0DAh, 056h, 036h, 055h
 defb    035h, 036h, 003h, 0DAh, 0DBh, 0DAh, 056h, 036h
 defb    055h, 035h, 036h, 0DAh, 0DBh, 0DAh, 000h, 000h
 defb    000h, 000h, 036h, 001h

PAT14:
 defw	 003FBh
 defb 	 004h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 039h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 039h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 048h, 039h, 047h, 038h, 024h, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 024h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 024h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 024h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 024h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 024h, 0C2h
 defb    0C1h, 0C2h, 048h, 040h, 047h, 03Fh, 024h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 024h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 026h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 026h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 026h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 026h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 026h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 04Dh, 040h, 04Ch, 03Fh, 026h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 026h, 001h

PAT15:
 defw    03FBh
 DEFB 	 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 026h, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 026h, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 026h, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 026h, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 026h, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 026h, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 048h, 039h, 047h
 defb    038h, 02Bh, 0ADh, 0ACh, 0ADh, 000h, 000h, 000h
 defb    000h, 02Bh, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 030h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 030h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 036h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 036h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 036h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 036h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 036h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 056h, 048h, 055h
 defb    047h, 036h, 0DAh, 0DBh, 0DAh, 000h, 000h, 000h
 defb    000h, 036h, 001h

PAT16:
 defw    003FBh
 defb    004h, 091h, 090h
 defb    091h, 048h, 03Dh, 048h, 047h, 091h, 091h, 090h
 defb    091h, 000h, 000h, 048h, 047h, 091h, 091h, 090h
 defb    091h, 048h, 03Dh, 000h, 000h, 051h, 091h, 090h
 defb    091h, 000h, 000h, 000h, 000h, 051h, 091h, 000h
 defb    091h, 048h, 03Dh, 040h, 03Fh, 000h, 000h, 000h
 defb    000h, 048h, 03Dh, 040h, 03Fh, 000h, 091h, 090h
 defb    091h, 091h, 03Dh, 000h, 000h, 048h, 091h, 090h
 defb    091h, 091h, 000h, 000h, 000h, 048h, 003h, 091h
 defb    090h, 091h, 048h, 03Dh, 03Dh, 03Ch, 000h, 091h
 defb    000h, 091h, 000h, 000h, 03Dh, 03Ch, 000h, 000h
 defb    000h, 000h, 048h, 03Dh, 000h, 000h, 040h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 040h, 091h
 defb    090h, 091h, 048h, 03Dh, 048h, 047h, 091h, 091h
 defb    090h, 091h, 048h, 03Dh, 048h, 047h, 091h, 091h
 defb    090h, 091h, 048h, 03Dh, 000h, 000h, 03Dh, 091h
 defb    090h, 091h, 000h, 000h, 000h, 000h, 03Dh, 004h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 030h, 000h
 defb    091h, 090h, 091h, 000h, 000h, 030h, 030h, 000h
 defb    0C2h, 0C1h, 0C2h, 048h, 03Dh, 030h, 0C2h, 048h
 defb    0C2h, 0C1h, 0C2h, 000h, 000h, 030h, 0C2h, 048h
 defb    004h, 0A3h, 0A2h, 0A3h, 048h, 03Dh, 030h, 0A3h
 defb    000h, 0A3h, 0A2h, 0A3h, 048h, 03Dh, 000h, 0A3h
 defb    000h, 0C2h, 0C1h, 0C2h, 048h, 03Dh, 000h, 0C2h
 defb    030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h, 0C2h
 defb    030h, 003h, 091h, 090h, 091h, 048h, 03Dh, 036h
 defb    035h, 091h, 091h, 090h, 091h, 000h, 000h, 036h
 defb    035h, 091h, 004h, 091h, 000h, 091h, 048h, 03Dh
 defb    000h, 000h, 091h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 091h, 091h, 090h, 091h, 048h, 03Dh
 defb    036h, 035h, 091h, 091h, 090h, 091h, 048h, 03Dh
 defb    036h, 035h, 091h, 07Ah, 079h, 07Ah, 07Ah, 03Dh
 defb    036h, 035h, 036h, 07Ah, 079h, 07Ah, 07Ah, 000h
 defb    036h, 035h, 036h, 004h, 0B7h, 0B6h, 0B7h, 05Bh
 defb    048h, 036h, 035h, 0B7h, 0B7h, 0B6h, 0B7h, 000h
 defb    000h, 000h, 000h, 0B7h, 0B7h, 0B6h, 0B7h, 05Bh
 defb    048h, 000h, 0B7h, 036h, 0B7h, 0B6h, 0B7h, 000h
 defb    000h, 000h, 0B7h, 036h, 0B7h, 000h, 0B7h, 05Bh
 defb    048h, 03Dh, 03Ch, 036h, 000h, 000h, 000h, 05Bh
 defb    048h, 03Dh, 03Ch, 036h, 0B7h, 0B6h, 0B7h, 05Bh
 defb    048h, 000h, 000h, 0B7h, 0B7h, 0B6h, 0B7h, 000h
 defb    000h, 000h, 000h, 0B7h, 003h, 0B7h, 0B6h, 0B7h
 defb    05Bh, 048h, 03Dh, 03Ch, 0B7h, 0B7h, 000h, 0B7h
 defb    000h, 000h, 03Dh, 03Ch, 0B7h, 000h, 000h, 000h
 defb    05Bh, 048h, 03Dh, 03Ch, 03Dh, 000h, 000h, 000h
 defb    000h, 000h, 03Dh, 03Ch, 03Dh, 0B7h, 0B6h, 0B7h
 defb    05Bh, 048h, 03Dh, 0B7h, 000h, 0B7h, 0B6h, 0B7h
 defb    05Bh, 048h, 000h, 0B7h, 000h, 004h, 0B7h, 0B6h
 defb    0B7h, 05Bh, 048h, 000h, 0B7h, 03Dh, 0B7h, 0B6h
 defb    0B7h, 000h, 000h, 000h, 0B7h, 03Dh, 004h, 0B7h
 defb    0B6h, 0B7h, 05Bh, 048h, 040h, 03Fh, 03Dh, 0B7h
 defb    0B6h, 0B7h, 000h, 000h, 040h, 03Fh, 03Dh, 07Ah
 defb    079h, 07Ah, 05Bh, 048h, 040h, 03Fh, 07Ah, 07Ah
 defb    079h, 07Ah, 000h, 000h, 040h, 03Fh, 07Ah, 004h
 defb    06Dh, 06Ch, 06Dh, 05Bh, 048h, 048h, 047h, 06Dh
 defb    06Dh, 06Ch, 06Dh, 05Bh, 048h, 048h, 047h, 06Dh
 defb    07Ah, 079h, 07Ah, 05Bh, 048h, 048h, 047h, 040h
 defb    07Ah, 079h, 07Ah, 000h, 000h, 048h, 047h, 040h
 defb    003h, 0B7h, 0B6h, 0B7h, 05Bh, 048h, 048h, 0B7h
 defb    040h, 0B7h, 0B6h, 0B7h, 000h, 000h, 000h, 0B7h
 defb    040h, 004h, 0B7h, 000h, 0B7h, 05Bh, 048h, 000h
 defb    0B7h, 048h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 048h, 003h, 0B7h, 0B6h, 0B7h, 05Bh, 048h
 defb    000h, 0B7h, 048h, 0B7h, 0B6h, 0B7h, 05Bh, 048h
 defb    000h, 0B7h, 048h, 003h, 091h, 0A2h, 0A3h, 05Bh
 defb    048h, 000h, 0A3h, 048h, 091h, 0A2h, 0A3h, 000h
 defb    000h, 000h, 0A3h, 000h, 001h

PAT17:
 defw    03FBh
 defb	 004h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 051h, 050h, 0A3h
 defb    0A3h, 0A2h, 0A3h, 000h, 000h, 051h, 050h, 0A3h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 000h, 000h, 051h
 defb    0A3h, 0A2h, 0A3h, 000h, 000h, 000h, 000h, 051h
 defb    0A3h, 000h, 0A3h, 051h, 040h, 040h, 03Fh, 000h
 defb    000h, 000h, 000h, 051h, 040h, 040h, 03Fh, 000h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 0A3h, 000h, 051h
 defb    0A3h, 0A2h, 0A3h, 000h, 000h, 0A3h, 000h, 051h
 defb    003h, 0A3h, 0A2h, 0A3h, 051h, 040h, 03Dh, 03Ch
 defb    000h, 0A3h, 000h, 0A3h, 000h, 000h, 03Dh, 03Ch
 defb    000h, 000h, 000h, 000h, 051h, 040h, 000h, 000h
 defb    040h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    040h, 0A3h, 0A2h, 0A3h, 051h, 040h, 036h, 035h
 defb    0A3h, 0A3h, 0A2h, 0A3h, 051h, 040h, 036h, 035h
 defb    0A3h, 0A3h, 0A2h, 0A3h, 051h, 040h, 000h, 0A3h
 defb    03Dh, 0A3h, 0A2h, 0A3h, 000h, 000h, 000h, 0A3h
 defb    03Dh, 004h, 0A3h, 0A2h, 0A3h, 051h, 040h, 051h
 defb    051h, 0A3h, 0A3h, 0A2h, 0A3h, 000h, 000h, 051h
 defb    051h, 0A3h, 06Dh, 06Ch, 06Dh, 051h, 040h, 051h
 defb    06Dh, 036h, 06Dh, 06Ch, 06Dh, 000h, 000h, 051h
 defb    06Dh, 036h, 004h, 0C2h, 0C1h, 0C2h, 051h, 040h
 defb    051h, 0C2h, 000h, 0C2h, 0C1h, 0C2h, 051h, 040h
 defb    000h, 0C2h, 000h, 06Dh, 06Ch, 06Dh, 051h, 040h
 defb    000h, 06Dh, 051h, 06Dh, 06Ch, 06Dh, 000h, 000h
 defb    000h, 06Dh, 051h, 003h, 0A3h, 0A2h, 0A3h, 051h
 defb    040h, 030h, 02Fh, 0A3h, 0A3h, 0A2h, 0A3h, 000h
 defb    000h, 030h, 02Fh, 0A3h, 004h, 0A3h, 000h, 0A3h
 defb    051h, 040h, 000h, 000h, 0A3h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 0A3h, 0A3h, 0A2h, 0A3h
 defb    051h, 040h, 030h, 02Fh, 0A3h, 0A3h, 0A2h, 0A3h
 defb    051h, 040h, 030h, 02Fh, 0A3h, 091h, 090h, 091h
 defb    091h, 040h, 030h, 02Fh, 030h, 091h, 090h, 091h
 defb    091h, 000h, 030h, 02Fh, 030h, 004h, 06Dh, 06Ch
 defb    06Dh, 036h, 048h, 030h, 06Dh, 000h, 06Dh, 06Ch
 defb    06Dh, 000h, 000h, 000h, 06Dh, 000h, 06Dh, 06Ch
 defb    06Dh, 036h, 048h, 000h, 06Dh, 030h, 06Dh, 06Ch
 defb    06Dh, 000h, 000h, 000h, 06Dh, 030h, 06Dh, 000h
 defb    06Dh, 036h, 048h, 03Dh, 03Ch, 030h, 000h, 000h
 defb    000h, 036h, 048h, 03Dh, 03Ch, 030h, 06Dh, 06Ch
 defb    06Dh, 036h, 048h, 000h, 000h, 06Dh, 06Dh, 06Ch
 defb    06Dh, 000h, 000h, 000h, 000h, 06Dh, 003h, 06Dh
 defb    06Ch, 06Dh, 036h, 048h, 03Dh, 03Ch, 06Dh, 06Dh
 defb    000h, 06Dh, 000h, 000h, 03Dh, 03Ch, 06Dh, 000h
 defb    000h, 000h, 036h, 048h, 03Dh, 03Ch, 03Dh, 000h
 defb    000h, 000h, 000h, 000h, 03Dh, 03Ch, 03Dh, 06Dh
 defb    06Ch, 06Dh, 036h, 048h, 03Dh, 06Dh, 000h, 06Dh
 defb    06Ch, 06Dh, 036h, 048h, 000h, 06Dh, 000h, 004h
 defb    06Dh, 06Ch, 06Dh, 036h, 048h, 000h, 06Dh, 03Dh
 defb    06Dh, 06Ch, 06Dh, 000h, 000h, 000h, 06Dh, 03Dh
 defb    004h, 0C2h, 0C1h, 0C2h, 040h, 030h, 040h, 03Fh
 defb    0C2h, 0C2h, 0C1h, 0C2h, 000h, 000h, 040h, 03Fh
 defb    0C2h, 0C2h, 0C1h, 0C2h, 040h, 030h, 040h, 03Fh
 defb    0C2h, 0C2h, 0C1h, 0C2h, 000h, 000h, 040h, 03Fh
 defb    0C2h, 004h, 0C2h, 000h, 0C2h, 040h, 030h, 048h
 defb    047h, 03Dh, 000h, 000h, 000h, 040h, 030h, 048h
 defb    047h, 03Dh, 0C2h, 0C1h, 0C2h, 0C2h, 030h, 048h
 defb    047h, 040h, 0C2h, 0C1h, 0C2h, 0C2h, 000h, 048h
 defb    047h, 040h, 003h, 0C2h, 0C1h, 0C2h, 040h, 030h
 defb    048h, 047h, 040h, 0C2h, 000h, 0C2h, 000h, 000h
 defb    000h, 0C2h, 040h, 004h, 000h, 000h, 000h, 040h
 defb    030h, 000h, 000h, 048h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 048h, 003h, 0C2h, 0C1h, 0C2h
 defb    040h, 030h, 000h, 0C2h, 048h, 0C2h, 0C1h, 0C2h
 defb    040h, 030h, 000h, 0C2h, 048h, 003h, 0A3h, 0A2h
 defb    0A3h, 040h, 030h, 000h, 0A3h, 048h, 0A3h, 0A2h
 defb    0A3h, 000h, 000h, 000h, 0A3h, 000h, 001h

PAT18:
 defw    03FBh
 defb    004h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 091h, 090h, 091h, 090h, 048h, 03Dh
 defb    03Ch, 048h, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h
 defb    03Dh, 05Bh, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h
 defb    036h, 051h, 003h, 0A3h, 0A2h, 0A3h, 0A2h, 051h
 defb    040h, 036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h, 051h
 defb    040h, 036h, 051h, 003h, 0A3h, 0A2h, 0A3h, 0A2h
 defb    051h, 040h, 036h, 051h, 0A3h, 0A2h, 0A3h, 0A2h
 defb    051h, 040h, 036h, 051h, 001h

PAT19:
 defw    03FBh
 defb    004h
 defb    091h, 090h, 091h, 048h, 03Dh, 048h, 047h, 000h
 defb    091h, 090h, 091h, 048h, 03Dh, 048h, 047h, 000h
 defb    091h, 090h, 091h, 048h, 03Dh, 000h, 000h, 051h
 defb    091h, 090h, 091h, 048h, 03Dh, 000h, 000h, 051h
 defb    091h, 090h, 091h, 048h, 03Dh, 040h, 03Fh, 000h
 defb    091h, 090h, 091h, 048h, 03Dh, 040h, 03Fh, 000h
 defb    091h, 000h, 091h, 048h, 000h, 000h, 000h, 048h
 defb    000h, 000h, 091h, 000h, 000h, 000h, 000h, 048h
 defb    091h, 091h, 091h, 048h, 03Dh, 03Dh, 03Ch, 000h
 defb    091h, 091h, 091h, 048h, 03Dh, 03Dh, 03Ch, 000h
 defb    091h, 091h, 091h, 048h, 03Dh, 000h, 000h, 040h
 defb    091h, 091h, 091h, 048h, 03Dh, 000h, 000h, 040h
 defb    091h, 091h, 091h, 048h, 03Dh, 048h, 047h, 000h
 defb    091h, 091h, 091h, 048h, 03Dh, 048h, 047h, 000h
 defb    091h, 000h, 091h, 048h, 000h, 000h, 000h, 03Dh
 defb    000h, 000h, 091h, 000h, 000h, 000h, 000h, 03Dh
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 030h, 000h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 030h, 000h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 030h, 048h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 030h, 048h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 000h, 000h
 defb    091h, 090h, 091h, 048h, 03Dh, 000h, 000h, 000h
 defb    091h, 000h, 091h, 048h, 000h, 000h, 000h, 030h
 defb    000h, 000h, 091h, 000h, 000h, 000h, 000h, 030h
 defb    091h, 091h, 091h, 048h, 03Dh, 036h, 035h, 030h
 defb    091h, 091h, 091h, 048h, 03Dh, 036h, 035h, 030h
 defb    091h, 091h, 091h, 048h, 03Dh, 000h, 000h, 030h
 defb    091h, 091h, 091h, 048h, 03Dh, 000h, 000h, 030h
 defb    091h, 091h, 091h, 048h, 03Dh, 036h, 035h, 000h
 defb    091h, 091h, 091h, 048h, 03Dh, 036h, 035h, 000h
 defb    091h, 000h, 091h, 048h, 000h, 036h, 035h, 036h
 defb    000h, 000h, 091h, 000h, 000h, 036h, 035h, 036h
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 036h, 000h, 000h
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 036h, 000h, 000h
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 000h, 000h, 036h
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 000h, 000h, 036h
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 03Dh, 03Ch, 036h
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 03Dh, 03Ch, 036h
 defb    0B7h, 000h, 0B7h, 05Bh, 000h, 000h, 000h, 036h
 defb    000h, 000h, 0B7h, 000h, 000h, 000h, 000h, 036h
 defb    0B7h, 0B7h, 0B7h, 05Bh, 048h, 03Dh, 03Ch, 000h
 defb    0B7h, 0B7h, 0B7h, 05Bh, 048h, 03Dh, 03Ch, 000h
 defb    0B7h, 0B7h, 0B7h, 05Bh, 048h, 03Dh, 03Ch, 03Dh
 defb    0B7h, 0B7h, 0B7h, 05Bh, 048h, 03Dh, 03Ch, 03Dh
 defb    0B7h, 0B7h, 0B7h, 05Bh, 048h, 03Dh, 000h, 000h
 defb    0B7h, 0B7h, 0B7h, 05Bh, 048h, 000h, 000h, 000h
 defb    0B7h, 000h, 0B7h, 05Bh, 000h, 000h, 000h, 03Dh
 defb    000h, 000h, 0B7h, 000h, 000h, 000h, 000h, 03Dh
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 040h, 03Fh, 03Dh
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 040h, 03Fh, 03Dh
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 040h, 03Fh, 03Dh
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 040h, 03Fh, 000h
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 048h, 047h, 000h
 defb    0B7h, 0B6h, 0B7h, 05Bh, 048h, 048h, 047h, 000h
 defb    0B7h, 000h, 0B7h, 05Bh, 000h, 048h, 047h, 040h
 defb    000h, 000h, 0B7h, 000h, 000h, 048h, 047h, 040h
 defb    003h, 0B7h, 0B7h, 0B7h, 05Bh, 048h, 048h, 000h
 defb    040h, 0B7h, 0B7h, 0B7h, 05Bh, 048h, 000h, 000h
 defb    040h, 003h, 0B7h, 0B7h, 0B7h, 05Bh, 048h, 000h
 defb    000h, 048h, 0B7h, 0B7h, 0B7h, 05Bh, 048h, 000h
 defb    000h, 048h, 003h, 0B7h, 0B7h, 0B7h, 05Bh, 048h
 defb    000h, 000h, 048h, 0B7h, 0B7h, 0B7h, 05Bh, 048h
 defb    000h, 000h, 048h, 003h, 0B7h, 000h, 0B7h, 05Bh
 defb    000h, 000h, 000h, 048h, 000h, 000h, 0B7h, 000h
 defb    000h, 000h, 000h, 000h, 001h

PAT20:
 defw    03FBh
 defb    004h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 051h, 050h, 000h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 051h, 050h, 000h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 000h, 000h, 051h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 000h, 000h, 051h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 040h, 03Fh, 000h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 040h, 03Fh, 000h
 defb    0A3h, 000h, 0A3h, 051h, 000h, 000h, 000h, 051h
 defb    000h, 000h, 0A3h, 000h, 000h, 000h, 000h, 051h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 03Dh, 03Ch, 000h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 03Dh, 03Ch, 000h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 000h, 000h, 040h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 000h, 000h, 040h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 036h, 035h, 000h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 036h, 035h, 000h
 defb    0A3h, 000h, 0A3h, 051h, 000h, 000h, 000h, 03Dh
 defb    000h, 000h, 0A3h, 000h, 000h, 000h, 000h, 03Dh
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 051h, 051h, 000h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 051h, 051h, 000h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 051h, 051h, 036h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 051h, 051h, 036h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 051h, 000h, 000h
 defb    0A3h, 0A2h, 0A3h, 051h, 040h, 000h, 000h, 000h
 defb    0A3h, 000h, 0A3h, 051h, 000h, 000h, 000h, 051h
 defb    000h, 000h, 0A3h, 000h, 000h, 000h, 000h, 051h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 030h, 030h, 051h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 030h, 030h, 051h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 000h, 000h, 051h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 000h, 000h, 051h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 030h, 030h, 000h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 030h, 030h, 000h
 defb    0A3h, 000h, 0A3h, 051h, 000h, 030h, 030h, 030h
 defb    000h, 000h, 0A3h, 000h, 000h, 030h, 030h, 030h
 defb    003h, 06Dh, 06Ch, 06Dh, 036h, 048h, 030h, 000h
 defb    000h, 06Dh, 06Ch, 06Dh, 036h, 048h, 030h, 000h
 defb    000h, 003h, 06Dh, 06Ch, 06Dh, 036h, 048h, 000h
 defb    000h, 030h, 06Dh, 06Ch, 06Dh, 036h, 048h, 000h
 defb    000h, 030h, 06Dh, 06Ch, 06Dh, 036h, 048h, 03Dh
 defb    03Ch, 030h, 06Dh, 06Ch, 06Dh, 036h, 048h, 03Dh
 defb    03Ch, 030h, 003h, 06Dh, 000h, 06Dh, 036h, 000h
 defb    000h, 000h, 030h, 000h, 000h, 06Dh, 000h, 000h
 defb    000h, 000h, 030h, 003h, 06Dh, 06Dh, 06Dh, 036h
 defb    048h, 03Dh, 03Ch, 000h, 06Dh, 06Dh, 06Dh, 036h
 defb    048h, 03Dh, 03Ch, 000h, 06Dh, 06Dh, 06Dh, 036h
 defb    048h, 03Dh, 03Ch, 03Dh, 06Dh, 06Dh, 06Dh, 036h
 defb    048h, 03Dh, 03Ch, 03Dh, 003h, 06Dh, 06Dh, 06Dh
 defb    036h, 048h, 03Dh, 000h, 000h, 06Dh, 06Dh, 06Dh
 defb    036h, 048h, 000h, 000h, 000h, 003h, 06Dh, 000h
 defb    06Dh, 036h, 000h, 000h, 000h, 03Dh, 000h, 000h
 defb    06Dh, 000h, 000h, 000h, 000h, 03Dh, 0C2h, 0C1h
 defb    0C2h, 040h, 030h, 040h, 03Fh, 03Dh, 0C2h, 0C1h
 defb    0C2h, 040h, 030h, 040h, 03Fh, 03Dh, 003h, 0C2h
 defb    0C1h, 0C2h, 040h, 030h, 040h, 03Fh, 03Dh, 0C2h
 defb    0C1h, 0C2h, 040h, 030h, 040h, 03Fh, 000h, 003h
 defb    0C2h, 0C1h, 0C2h, 040h, 030h, 048h, 047h, 000h
 defb    0C2h, 0C1h, 0C2h, 040h, 030h, 048h, 047h, 000h
 defb    0C2h, 000h, 0C2h, 040h, 000h, 048h, 047h, 040h
 defb    000h, 000h, 0C2h, 000h, 000h, 048h, 047h, 040h
 defb    003h, 0C2h, 0C2h, 0C2h, 040h, 030h, 048h, 000h
 defb    040h, 0C2h, 0C2h, 0C2h, 040h, 030h, 000h, 000h
 defb    040h, 0C2h, 0C2h, 0C2h, 040h, 030h, 000h, 000h
 defb    048h, 0C2h, 0C2h, 0C2h, 040h, 030h, 000h, 000h
 defb    048h, 003h, 0C2h, 0C2h, 0C2h, 040h, 030h, 000h
 defb    000h, 048h, 0C2h, 0C2h, 0C2h, 040h, 030h, 000h
 defb    000h, 048h, 0C2h, 000h, 0C2h, 040h, 000h, 000h
 defb    000h, 048h, 000h, 000h, 0C2h, 000h, 000h, 000h
 defb    000h, 000h, 001h

PAT21:
 defw    03FBh
 defb    004h, 091h, 090h
 defb    091h, 048h, 03Dh, 048h, 047h, 000h, 091h, 090h
 defb    091h, 048h, 03Dh, 048h, 047h, 000h, 091h, 090h
 defb    091h, 048h, 03Dh, 000h, 000h, 051h, 091h, 090h
 defb    091h, 048h, 03Dh, 000h, 000h, 051h, 091h, 090h
 defb    091h, 048h, 03Dh, 040h, 03Fh, 000h, 091h, 090h
 defb    091h, 048h, 03Dh, 040h, 03Fh, 000h, 091h, 000h
 defb    091h, 048h, 000h, 000h, 000h, 048h, 000h, 000h
 defb    091h, 000h, 000h, 000h, 000h, 048h, 004h, 091h
 defb    091h, 091h, 048h, 03Dh, 03Dh, 03Ch, 000h, 091h
 defb    091h, 091h, 048h, 03Dh, 03Dh, 03Ch, 000h, 091h
 defb    091h, 091h, 048h, 03Dh, 000h, 000h, 040h, 091h
 defb    091h, 091h, 048h, 03Dh, 000h, 000h, 040h, 091h
 defb    091h, 091h, 048h, 03Dh, 048h, 047h, 000h, 091h
 defb    091h, 091h, 048h, 03Dh, 048h, 047h, 000h, 091h
 defb    000h, 091h, 048h, 000h, 000h, 000h, 03Dh, 000h
 defb    000h, 091h, 000h, 000h, 000h, 000h, 03Dh, 004h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 030h, 000h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 030h, 000h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 030h, 048h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 030h, 048h
 defb    091h, 090h, 091h, 048h, 03Dh, 030h, 000h, 000h
 defb    091h, 090h, 091h, 048h, 03Dh, 000h, 000h, 000h
 defb    091h, 000h, 091h, 048h, 000h, 000h, 000h, 030h
 defb    000h, 000h, 091h, 000h, 000h, 000h, 000h, 030h
 defb    004h, 091h, 091h, 091h, 048h, 03Dh, 036h, 035h
 defb    030h, 091h, 091h, 091h, 048h, 03Dh, 036h, 035h
 defb    030h, 091h, 091h, 091h, 048h, 03Dh, 000h, 000h
 defb    030h, 091h, 091h, 091h, 048h, 03Dh, 000h, 000h
 defb    030h, 004h, 091h, 091h, 091h, 048h, 03Dh, 036h
 defb    035h, 000h, 091h, 091h, 091h, 048h, 03Dh, 036h
 defb    035h, 000h, 091h, 000h, 091h, 048h, 000h, 036h
 defb    035h, 036h, 000h, 000h, 091h, 000h, 000h, 036h
 defb    035h, 036h, 004h, 0B7h, 0B6h, 0B7h, 05Bh, 048h
 defb    036h, 000h, 000h, 0B7h, 0B6h, 0B7h, 05Bh, 048h
 defb    036h, 000h, 000h, 0B7h, 0B6h, 0B7h, 05Bh, 048h
 defb    000h, 000h, 036h, 0B7h, 0B6h, 0B7h, 05Bh, 048h
 defb    000h, 000h, 036h, 0B7h, 0B6h, 0B7h, 05Bh, 048h
 defb    03Dh, 03Ch, 036h, 0B7h, 0B6h, 0B7h, 05Bh, 048h
 defb    03Dh, 03Ch, 036h, 0B7h, 000h, 0B7h, 05Bh, 000h
 defb    000h, 000h, 036h, 000h, 000h, 0B7h, 000h, 000h
 defb    000h, 000h, 036h, 004h, 0B7h, 0B7h, 0B7h, 05Bh
 defb    048h, 03Dh, 03Ch, 000h, 0B7h, 0B7h, 0B7h, 05Bh
 defb    048h, 03Dh, 03Ch, 000h, 0B7h, 0B7h, 0B7h, 05Bh
 defb    048h, 03Dh, 03Ch, 03Dh, 0B7h, 0B7h, 0B7h, 05Bh
 defb    048h, 03Dh, 03Ch, 03Dh, 0B7h, 0B7h, 0B7h, 05Bh
 defb    048h, 03Dh, 000h, 000h, 0B7h, 0B7h, 0B7h, 05Bh
 defb    048h, 000h, 000h, 000h, 0B7h, 000h, 0B7h, 05Bh
 defb    000h, 000h, 000h, 03Dh, 000h, 000h, 0B7h, 000h
 defb    000h, 000h, 000h, 03Dh, 004h, 0B7h, 0B6h, 0B7h
 defb    05Bh, 048h, 040h, 03Fh, 03Dh, 0B7h, 0B6h, 0B7h
 defb    05Bh, 048h, 040h, 03Fh, 03Dh, 0B7h, 0B6h, 0B7h
 defb    05Bh, 048h, 040h, 03Fh, 03Dh, 0B7h, 0B6h, 0B7h
 defb    05Bh, 048h, 040h, 03Fh, 000h, 0B7h, 0B6h, 0B7h
 defb    05Bh, 048h, 048h, 047h, 000h, 0B7h, 0B6h, 0B7h
 defb    05Bh, 048h, 048h, 047h, 000h, 004h, 0B7h, 000h
 defb    0B7h, 05Bh, 000h, 048h, 047h, 040h, 000h, 000h
 defb    0B7h, 000h, 000h, 048h, 047h, 040h, 004h, 0B7h
 defb    0B7h, 0B7h, 05Bh, 048h, 048h, 000h, 040h, 0B7h
 defb    0B7h, 0B7h, 05Bh, 048h, 000h, 000h, 040h, 0B7h
 defb    0B7h, 0B7h, 05Bh, 048h, 000h, 000h, 048h, 0B7h
 defb    0B7h, 0B7h, 05Bh, 048h, 000h, 000h, 048h, 004h
 defb    0B7h, 0B7h, 0B7h, 05Bh, 048h, 000h, 000h, 048h
 defb    0B7h, 0B7h, 0B7h, 05Bh, 048h, 000h, 000h, 048h
 defb    004h, 0B7h, 000h, 0B7h, 05Bh, 000h, 000h, 000h
 defb    048h, 000h, 000h, 0B7h, 000h, 000h, 000h, 000h
 defb    000h, 001h

PAT22:
 defw    03FBh
 defb    004h, 0A3h, 0A2h, 0A3h
 defb    051h, 040h, 051h, 050h, 000h, 0A3h, 0A2h, 0A3h
 defb    051h, 040h, 051h, 050h, 000h, 0A3h, 0A2h, 0A3h
 defb    051h, 040h, 000h, 000h, 051h, 0A3h, 0A2h, 0A3h
 defb    051h, 040h, 000h, 000h, 051h, 0A3h, 0A2h, 0A3h
 defb    051h, 040h, 040h, 03Fh, 000h, 0A3h, 0A2h, 0A3h
 defb    051h, 040h, 040h, 03Fh, 000h, 0A3h, 000h, 0A3h
 defb    051h, 000h, 000h, 000h, 051h, 000h, 000h, 0A3h
 defb    000h, 000h, 000h, 000h, 051h, 004h, 0A3h, 0A3h
 defb    0A3h, 051h, 040h, 03Dh, 03Ch, 000h, 0A3h, 0A3h
 defb    0A3h, 051h, 040h, 03Dh, 03Ch, 000h, 0A3h, 0A3h
 defb    0A3h, 051h, 040h, 000h, 000h, 040h, 0A3h, 0A3h
 defb    0A3h, 051h, 040h, 000h, 000h, 040h, 0A3h, 0A3h
 defb    0A3h, 051h, 040h, 036h, 035h, 000h, 0A3h, 0A3h
 defb    0A3h, 051h, 040h, 036h, 035h, 000h, 0A3h, 000h
 defb    0A3h, 051h, 000h, 000h, 000h, 03Dh, 000h, 000h
 defb    0A3h, 000h, 000h, 000h, 000h, 03Dh, 004h, 0A3h
 defb    0A2h, 0A3h, 051h, 040h, 051h, 051h, 000h, 0A3h
 defb    0A2h, 0A3h, 051h, 040h, 051h, 051h, 000h, 0A3h
 defb    0A2h, 0A3h, 051h, 040h, 051h, 051h, 036h, 0A3h
 defb    0A2h, 0A3h, 051h, 040h, 051h, 051h, 036h, 0A3h
 defb    0A2h, 0A3h, 051h, 040h, 051h, 000h, 000h, 0A3h
 defb    0A2h, 0A3h, 051h, 040h, 000h, 000h, 000h, 0A3h
 defb    000h, 0A3h, 051h, 000h, 000h, 000h, 051h, 000h
 defb    000h, 0A3h, 000h, 000h, 000h, 000h, 051h, 004h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 030h, 030h, 051h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 030h, 030h, 051h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 000h, 000h, 051h
 defb    0A3h, 0A3h, 0A3h, 051h, 040h, 000h, 000h, 051h
 defb    004h, 0A3h, 0A3h, 0A3h, 051h, 040h, 030h, 030h
 defb    000h, 0A3h, 0A3h, 0A3h, 051h, 040h, 030h, 030h
 defb    000h, 0A3h, 000h, 0A3h, 051h, 000h, 030h, 030h
 defb    030h, 000h, 000h, 0A3h, 000h, 000h, 030h, 030h
 defb    030h, 004h, 06Dh, 06Ch, 06Dh, 036h, 048h, 030h
 defb    000h, 000h, 06Dh, 06Ch, 06Dh, 036h, 048h, 030h
 defb    000h, 000h, 003h, 06Dh, 06Ch, 06Dh, 036h, 048h
 defb    000h, 000h, 030h, 06Dh, 06Ch, 06Dh, 036h, 048h
 defb    000h, 000h, 030h, 06Dh, 06Ch, 06Dh, 036h, 048h
 defb    03Dh, 03Ch, 030h, 06Dh, 06Ch, 06Dh, 036h, 048h
 defb    03Dh, 03Ch, 030h, 003h, 06Dh, 000h, 06Dh, 036h
 defb    000h, 000h, 000h, 030h, 000h, 000h, 06Dh, 000h
 defb    000h, 000h, 000h, 030h, 004h, 06Dh, 06Dh, 06Dh
 defb    036h, 048h, 03Dh, 03Ch, 000h, 06Dh, 06Dh, 06Dh
 defb    036h, 048h, 03Dh, 03Ch, 000h, 06Dh, 06Dh, 06Dh
 defb    036h, 048h, 03Dh, 03Ch, 03Dh, 06Dh, 06Dh, 06Dh
 defb    036h, 048h, 03Dh, 03Ch, 03Dh, 003h, 06Dh, 06Dh
 defb    06Dh, 036h, 048h, 03Dh, 000h, 000h, 06Dh, 06Dh
 defb    06Dh, 036h, 048h, 000h, 000h, 000h, 003h, 06Dh
 defb    000h, 06Dh, 036h, 000h, 000h, 000h, 03Dh, 000h
 defb    000h, 06Dh, 000h, 000h, 000h, 000h, 03Dh, 004h
 defb    0C2h, 0C1h, 0C2h, 040h, 030h, 040h, 03Fh, 03Dh
 defb    0C2h, 0C1h, 0C2h, 040h, 030h, 040h, 03Fh, 03Dh
 defb    003h, 0C2h, 0C1h, 0C2h, 040h, 030h, 040h, 03Fh
 defb    03Dh, 0C2h, 0C1h, 0C2h, 040h, 030h, 040h, 03Fh
 defb    000h, 003h, 0C2h, 0C1h, 0C2h, 040h, 030h, 048h
 defb    047h, 000h, 0C2h, 0C1h, 0C2h, 040h, 030h, 048h
 defb    047h, 000h, 0C2h, 000h, 0C2h, 040h, 000h, 048h
 defb    047h, 040h, 000h, 000h, 0C2h, 000h, 000h, 048h
 defb    047h, 040h, 003h, 0C2h, 0C2h, 0C2h, 040h, 030h
 defb    048h, 000h, 040h, 0C2h, 0C2h, 0C2h, 040h, 030h
 defb    000h, 000h, 040h, 003h, 0C2h, 0C2h, 0C2h, 040h
 defb    030h, 000h, 000h, 048h, 0C2h, 0C2h, 0C2h, 040h
 defb    030h, 000h, 000h, 048h, 003h, 0C2h, 0C2h, 0C2h
 defb    040h, 030h, 000h, 000h, 048h, 0C2h, 0C2h, 0C2h
 defb    040h, 030h, 000h, 000h, 048h, 003h, 0C2h, 000h
 defb    0C2h, 040h, 000h, 000h, 000h, 048h, 000h, 000h
 defb    0C2h, 000h, 000h, 000h, 000h, 000h, 001h

PAT23:
 defw    03FBh
 defb	004h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 04Dh, 040h, 04Ch
 defb    03Fh, 030h, 0C2h, 0C1h, 0C2h, 000h, 000h, 000h
 defb    000h, 030h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    061h, 000h, 0C2h, 000h, 0C2h, 061h, 04Dh, 000h
 defb    000h, 000h, 0C2h, 000h, 000h, 061h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 001h

PAT24:
 defw    03FBh
 defb    004h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 000h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 000h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 000h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 04Dh, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 061h, 060h
 defb    061h, 0C2h, 0C1h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 030h, 030h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 030h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 081h, 080h
 defb    081h, 081h, 082h, 033h, 033h, 033h, 001h

PAT25:
 defw    03FBh
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    000h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    000h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    000h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    033h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h
 defb    039h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    039h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    039h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    039h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    040h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    048h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    048h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    048h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    048h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    048h, 003h, 091h, 092h, 091h, 091h, 090h, 048h
 defb    048h, 048h, 091h, 092h, 091h, 091h, 090h, 048h
 defb    048h, 048h, 003h, 091h, 092h, 091h, 091h, 090h
 defb    048h, 048h, 048h, 091h, 092h, 091h, 091h, 090h
 defb    048h, 048h, 048h, 003h, 091h, 092h, 091h, 091h
 defb    090h, 048h, 048h, 048h, 091h, 092h, 091h, 091h
 defb    090h, 048h, 048h, 048h, 003h, 091h, 092h, 091h
 defb    091h, 090h, 048h, 048h, 048h, 091h, 092h, 091h
 defb    091h, 090h, 048h, 048h, 048h, 001h

PAT26:
 defw    03FBh
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 000h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 000h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 000h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 033h, 033h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 033h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    073h, 072h, 073h, 0E7h, 0E6h, 039h, 039h, 039h
 defb    003h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    039h, 091h, 092h, 091h, 091h, 090h, 040h, 040h
 defb    039h, 003h, 091h, 092h, 091h, 091h, 090h, 040h
 defb    040h, 039h, 091h, 092h, 091h, 091h, 090h, 040h
 defb    040h, 040h, 091h, 092h, 091h, 091h, 090h, 040h
 defb    040h, 040h, 091h, 092h, 091h, 091h, 090h, 040h
 defb    040h, 040h, 003h, 091h, 092h, 091h, 091h, 090h
 defb    040h, 040h, 040h, 091h, 092h, 091h, 091h, 090h
 defb    040h, 040h, 040h, 003h, 091h, 092h, 091h, 091h
 defb    090h, 040h, 040h, 040h, 091h, 092h, 091h, 091h
 defb    090h, 040h, 040h, 040h, 091h, 092h, 091h, 091h
 defb    090h, 040h, 040h, 040h, 091h, 092h, 091h, 091h
 defb    090h, 040h, 040h, 040h, 003h, 091h, 092h, 091h
 defb    091h, 090h, 040h, 040h, 040h, 091h, 092h, 091h
 defb    091h, 090h, 040h, 040h, 040h, 003h, 091h, 092h
 defb    091h, 091h, 090h, 040h, 040h, 040h, 091h, 092h
 defb    091h, 091h, 090h, 040h, 040h, 040h, 091h, 092h
 defb    091h, 091h, 090h, 048h, 048h, 040h, 091h, 092h
 defb    091h, 091h, 090h, 048h, 048h, 040h, 003h, 091h
 defb    092h, 091h, 091h, 090h, 048h, 048h, 040h, 091h
 defb    092h, 091h, 091h, 090h, 048h, 048h, 048h, 003h
 defb    091h, 092h, 091h, 091h, 090h, 048h, 048h, 048h
 defb    091h, 092h, 091h, 091h, 090h, 048h, 048h, 048h
 defb    091h, 092h, 091h, 091h, 090h, 048h, 048h, 048h
 defb    091h, 092h, 091h, 091h, 090h, 048h, 048h, 048h
 defb    003h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    048h, 091h, 092h, 091h, 091h, 090h, 048h, 048h
 defb    048h, 003h, 091h, 092h, 091h, 091h, 090h, 048h
 defb    048h, 048h, 091h, 092h, 091h, 091h, 090h, 048h
 defb    048h, 048h, 003h, 091h, 092h, 091h, 091h, 090h
 defb    048h, 048h, 048h, 091h, 092h, 091h, 091h, 090h
 defb    048h, 048h, 048h, 003h, 091h, 092h, 091h, 091h
 defb    090h, 048h, 048h, 048h, 091h, 092h, 091h, 091h
 defb    090h, 048h, 048h, 048h, 001h

PAT27:
 defw    06F7h
 defb    004h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    091h, 090h, 091h, 090h, 048h, 03Dh, 03Ch, 048h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0DAh, 0DBh, 0DAh, 0DBh, 036h, 06Dh, 048h, 036h
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0B7h, 0B6h, 0B7h, 0B6h, 05Bh, 048h, 03Dh, 05Bh
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    0A3h, 0A2h, 0A3h, 0A2h, 051h, 040h, 036h, 051h
 defb    001h

PAT28:
 defw    003FBh
 defb    004h, 0C2h, 0C1h, 0C2h, 061h
 defb    04Dh, 04Dh, 04Ch, 04Dh, 0C2h, 0C1h, 0C2h, 061h
 defb    04Dh, 000h, 000h, 000h, 0C2h, 0C1h, 0C2h, 061h
 defb    04Dh, 04Dh, 04Ch, 04Dh, 0C2h, 000h, 0C2h, 000h
 defb    0C2h, 000h, 000h, 000h, 004h, 000h, 000h, 000h
 defb    000h, 0C2h, 04Dh, 04Ch, 04Dh, 000h, 000h, 000h
 defb    000h, 0C2h, 04Dh, 04Ch, 04Dh, 0C2h, 0C1h, 0C2h
 defb    061h, 04Dh, 04Dh, 0C2h, 04Dh, 0C2h, 0C1h, 0C2h
 defb    061h, 04Dh, 000h, 0C2h, 000h, 003h, 0C2h, 0C1h
 defb    0C2h, 061h, 04Dh, 04Dh, 04Ch, 04Dh, 0C2h, 000h
 defb    0C2h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 0C2h, 000h, 04Dh, 04Ch, 04Dh, 000h, 000h
 defb    000h, 0C2h, 000h, 000h, 000h, 000h, 0C2h, 0C1h
 defb    0C2h, 061h, 04Dh, 04Dh, 04Ch, 04Dh, 0C2h, 0C1h
 defb    0C2h, 000h, 000h, 04Dh, 04Ch, 04Dh, 0C2h, 0C1h
 defb    0C2h, 061h, 04Dh, 04Dh, 0C2h, 04Dh, 0C2h, 0C1h
 defb    0C2h, 061h, 04Dh, 000h, 0C2h, 000h, 004h, 0C2h
 defb    0C1h, 0C2h, 061h, 04Dh, 040h, 03Fh, 040h, 0C2h
 defb    0C1h, 0C2h, 000h, 000h, 000h, 000h, 000h, 081h
 defb    080h, 081h, 0C2h, 000h, 040h, 03Fh, 040h, 081h
 defb    080h, 081h, 0C2h, 000h, 000h, 000h, 000h, 004h
 defb    073h, 072h, 073h, 061h, 04Dh, 040h, 03Fh, 040h
 defb    073h, 072h, 073h, 000h, 000h, 040h, 03Fh, 040h
 defb    081h, 080h, 081h, 061h, 04Dh, 040h, 081h, 040h
 defb    081h, 080h, 081h, 061h, 04Dh, 000h, 081h, 000h
 defb    003h, 0C2h, 0C1h, 0C2h, 0C2h, 04Dh, 040h, 03Fh
 defb    040h, 0C2h, 0C1h, 0C2h, 0C2h, 000h, 000h, 000h
 defb    000h, 004h, 0C2h, 000h, 0C2h, 0C2h, 000h, 040h
 defb    03Fh, 040h, 000h, 000h, 000h, 0C2h, 000h, 000h
 defb    000h, 000h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    03Fh, 040h, 0C2h, 0C1h, 0C2h, 061h, 04Dh, 040h
 defb    03Fh, 040h, 0ADh, 0ACh, 0ADh, 0ADh, 000h, 040h
 defb    000h, 040h, 0ADh, 0ACh, 0ADh, 0ADh, 000h, 000h
 defb    000h, 000h, 004h, 081h, 080h, 081h, 056h, 033h
 defb    040h, 03Fh, 040h, 081h, 080h, 081h, 056h, 033h
 defb    000h, 000h, 000h, 081h, 080h, 081h, 056h, 033h
 defb    040h, 03Fh, 040h, 081h, 000h, 081h, 000h, 000h
 defb    000h, 000h, 000h, 004h, 000h, 000h, 000h, 081h
 defb    000h, 040h, 03Fh, 040h, 000h, 000h, 000h, 081h
 defb    000h, 040h, 03Fh, 040h, 081h, 080h, 081h, 056h
 defb    033h, 040h, 081h, 040h, 081h, 080h, 081h, 056h
 defb    033h, 000h, 081h, 000h, 003h, 081h, 080h, 081h
 defb    056h, 033h, 040h, 03Fh, 040h, 081h, 000h, 081h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    081h, 000h, 040h, 03Fh, 040h, 000h, 000h, 000h
 defb    081h, 000h, 000h, 000h, 000h, 081h, 080h, 081h
 defb    056h, 033h, 040h, 03Fh, 040h, 081h, 080h, 081h
 defb    000h, 000h, 040h, 03Fh, 040h, 004h, 081h, 080h
 defb    081h, 056h, 033h, 040h, 081h, 040h, 081h, 080h
 defb    081h, 056h, 033h, 000h, 081h, 000h, 004h, 081h
 defb    080h, 081h, 056h, 033h, 033h, 032h, 033h, 081h
 defb    080h, 081h, 000h, 000h, 000h, 000h, 000h, 0ADh
 defb    0ACh, 0ADh, 0ADh, 000h, 033h, 032h, 033h, 0ADh
 defb    0ACh, 0ADh, 0ADh, 000h, 000h, 000h, 000h, 004h
 defb    09Ah, 099h, 09Ah, 056h, 033h, 033h, 032h, 033h
 defb    09Ah, 099h, 09Ah, 000h, 000h, 033h, 032h, 033h
 defb    0ADh, 0ACh, 0ADh, 056h, 033h, 033h, 0ADh, 033h
 defb    0ADh, 0ACh, 0ADh, 056h, 033h, 000h, 0ADh, 000h
 defb    003h, 081h, 080h, 081h, 081h, 033h, 033h, 032h
 defb    033h, 081h, 080h, 081h, 081h, 000h, 000h, 000h
 defb    000h, 004h, 081h, 000h, 081h, 081h, 000h, 033h
 defb    032h, 033h, 000h, 000h, 000h, 081h, 000h, 000h
 defb    000h, 000h, 081h, 080h, 081h, 056h, 033h, 033h
 defb    032h, 033h, 081h, 080h, 081h, 056h, 033h, 033h
 defb    032h, 033h, 07Ah, 079h, 07Ah, 07Ah, 000h, 033h
 defb    000h, 033h, 07Ah, 079h, 07Ah, 07Ah, 000h, 000h
 defb    000h, 000h, 001h

PAT29:
 defw    03FBh
 defb    004h, 073h, 072h
 defb    073h, 04Dh, 039h, 033h, 032h, 033h, 073h, 072h
 defb    073h, 04Dh, 039h, 000h, 000h, 000h, 073h, 072h
 defb    073h, 04Dh, 039h, 033h, 032h, 033h, 073h, 072h
 defb    073h, 000h, 000h, 000h, 000h, 000h, 004h, 000h
 defb    000h, 000h, 000h, 073h, 033h, 032h, 033h, 000h
 defb    000h, 000h, 000h, 073h, 033h, 032h, 033h, 073h
 defb    072h, 073h, 04Dh, 039h, 033h, 073h, 033h, 073h
 defb    072h, 073h, 04Dh, 039h, 000h, 073h, 000h, 003h
 defb    073h, 072h, 073h, 04Dh, 039h, 033h, 032h, 033h
 defb    073h, 072h, 073h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 073h, 000h, 033h, 032h, 033h
 defb    000h, 000h, 000h, 073h, 000h, 000h, 000h, 000h
 defb    073h, 072h, 073h, 04Dh, 039h, 033h, 032h, 033h
 defb    073h, 072h, 073h, 000h, 000h, 033h, 032h, 033h
 defb    073h, 072h, 073h, 04Dh, 039h, 033h, 073h, 033h
 defb    073h, 072h, 073h, 04Dh, 039h, 000h, 073h, 000h
 defb    004h, 073h, 072h, 073h, 04Dh, 039h, 039h, 038h
 defb    039h, 073h, 072h, 073h, 000h, 000h, 000h, 000h
 defb    000h, 09Ah, 099h, 09Ah, 09Ah, 000h, 039h, 038h
 defb    039h, 09Ah, 099h, 09Ah, 09Ah, 000h, 000h, 000h
 defb    000h, 004h, 081h, 080h, 081h, 04Dh, 039h, 039h
 defb    038h, 039h, 081h, 080h, 081h, 000h, 000h, 039h
 defb    038h, 039h, 09Ah, 099h, 09Ah, 04Dh, 039h, 039h
 defb    09Ah, 039h, 09Ah, 099h, 09Ah, 04Dh, 039h, 000h
 defb    09Ah, 000h, 003h, 073h, 072h, 073h, 073h, 039h
 defb    039h, 038h, 039h, 073h, 072h, 073h, 073h, 000h
 defb    000h, 000h, 000h, 004h, 073h, 072h, 073h, 073h
 defb    000h, 039h, 038h, 039h, 000h, 000h, 000h, 073h
 defb    000h, 000h, 000h, 000h, 004h, 073h, 072h, 073h
 defb    04Dh, 039h, 039h, 038h, 039h, 073h, 072h, 073h
 defb    04Dh, 039h, 039h, 038h, 039h, 081h, 080h, 081h
 defb    081h, 000h, 039h, 000h, 039h, 081h, 080h, 081h
 defb    081h, 000h, 000h, 000h, 000h, 004h, 091h, 090h
 defb    091h, 061h, 048h, 040h, 03Fh, 040h, 091h, 090h
 defb    091h, 061h, 048h, 000h, 000h, 000h, 091h, 090h
 defb    091h, 091h, 048h, 040h, 03Fh, 040h, 091h, 090h
 defb    091h, 091h, 000h, 000h, 000h, 000h, 004h, 000h
 defb    000h, 000h, 091h, 000h, 040h, 03Fh, 040h, 000h
 defb    000h, 000h, 091h, 000h, 040h, 03Fh, 040h, 091h
 defb    091h, 091h, 061h, 048h, 040h, 091h, 040h, 091h
 defb    091h, 091h, 061h, 048h, 000h, 091h, 000h, 003h
 defb    091h, 091h, 091h, 061h, 048h, 040h, 03Fh, 040h
 defb    091h, 091h, 091h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 091h, 000h, 040h, 03Fh, 040h
 defb    000h, 000h, 000h, 091h, 000h, 000h, 000h, 000h
 defb    004h, 091h, 091h, 091h, 061h, 048h, 040h, 03Fh
 defb    040h, 091h, 091h, 091h, 000h, 000h, 040h, 03Fh
 defb    040h, 004h, 091h, 091h, 091h, 061h, 048h, 040h
 defb    091h, 040h, 091h, 091h, 091h, 061h, 048h, 000h
 defb    091h, 000h, 004h, 091h, 091h, 091h, 061h, 048h
 defb    048h, 047h, 048h, 091h, 091h, 091h, 000h, 000h
 defb    000h, 000h, 000h, 003h, 0C2h, 0C1h, 0C2h, 0C2h
 defb    000h, 048h, 047h, 048h, 0C2h, 0C1h, 0C2h, 0C2h
 defb    000h, 000h, 000h, 000h, 003h, 0ADh, 0ACh, 0ADh
 defb    061h, 048h, 048h, 047h, 048h, 0ADh, 0ACh, 0ADh
 defb    000h, 000h, 048h, 047h, 048h, 0C2h, 0C1h, 0C2h
 defb    061h, 048h, 048h, 0C2h, 048h, 0C2h, 0C1h, 0C2h
 defb    061h, 048h, 000h, 0C2h, 000h, 003h, 091h, 090h
 defb    091h, 091h, 048h, 048h, 047h, 048h, 091h, 090h
 defb    091h, 091h, 000h, 000h, 000h, 000h, 003h, 091h
 defb    090h, 091h, 091h, 000h, 048h, 047h, 048h, 000h
 defb    000h, 000h, 091h, 000h, 000h, 000h, 000h, 003h
 defb    091h, 090h, 091h, 061h, 048h, 048h, 047h, 048h
 defb    091h, 090h, 091h, 061h, 048h, 048h, 047h, 048h
 defb    003h, 09Ah, 099h, 09Ah, 09Ah, 000h, 048h, 000h
 defb    048h, 09Ah, 099h, 09Ah, 09Ah, 000h, 000h, 000h
 defb    000h, 001h

PAT30:
 defw    03FBh
 defb    004h, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 000h, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 000h, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 04Dh, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 000h, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 04Dh, 000h, 061h, 060h, 061h
 defb    0C2h, 0C1h, 04Dh, 000h, 000h, 061h, 060h, 061h
 defb    0C2h, 0C1h, 000h, 000h, 000h, 061h, 000h, 000h
 defb    0C2h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
 defb    000h, 000h, 000h, 000h, 000h, 001h

ENDSAMPLE:
 defw    0C0DEh
 defb    000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h




end:		dw	#C0DE



