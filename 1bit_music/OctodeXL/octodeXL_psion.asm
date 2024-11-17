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

		;MODULE OctodeXL

	output "psion.obj"


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

vol1234: 	EQU 3
vol5678:	EQU 3
octodeDrums:	EQU 20000
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


; PSIONIC ACTIVITY MUSIC DATA.   Mr Beep.  For Octode XL.  X4.
;
; ===========================================================================================
musicdata:
LOOPM:
 defw 	PAT01	; 08205h
 defw  	PAT05	; 08A82h
 defw  	PAT10	; 093B2h
 defw 	PAT06	; 08c57h
 defw 	PAT07	; 08D61h
 defw 	PAT08	; 08E6Eh
 defw 	PAT12	; 0964Ah
 defw 	PAT02	; 0841Dh
 defw 	PAT09	; 0918Dh
 defw  	PAT04	; 08861h
 defw 	PAT03	; 0863Eh
 defw 	PAT11	; 0943Bh
 defw 	PAT13	; 0975Bh
 defw 	PAT14	; 0996Dh
 defw 	PAT15	; 09b92h
 defw 	PAT16	; 09dBAh
 defw 	PAT16	; 09dBAh
 defw 	PAT17	; 09fDFh
 defw 	PAT16	; 09dBAh
 defw 	PAT18	; 0a201h
 defw 	PAT19	; 0a40dh
 defw 	PAT20	; 0A61Ch
 defw 	PAT29	; 0B921h
 defw 	PAT21	; 0A82Ah
 defw 	PAT30	; 0BB2Fh
 defw 	PAT22	; 0AA46h
 defw 	PAT23	; 0AC60h
 defw	PAT24	; 0AE7Dh
 defw 	PAT26	; 0B2CBh
 defw 	PAT25	; 0B0A4h
 defw 	PAT27	; 0B4F4h
 defw 	PAT13	; 0975Bh
 defw 	PAT11	; 0943Bh
 defw 	PAT28	; 0b71Dh
 defw 	00000h
 defw 	LOOPM		; 0BDh,081h



; PATTERNS IN SEQUENTIAL ORDER; used to work out the above pattern order.
; defw 	08205h  1
; defw 	0841Dh 2
; defw 	0863Eh 3
; defw  	08861h 4
; defw  	08A82h 5
; defw 	08c57h 6
; defw 	08D61h 7
; defw 	08E6Eh 8
; defw 	0918Dh 9
; defw  	093B2h 10
; defw 	0943Bh 11
; defw 	0964Ah 12
; defw 	0975Bh 13
; defw 	0996Dh 14
; defw 	09b92h 15
; defw 	09 defb Ah  16	0 9 d B A h 
; defw 	09fDFh 17
; defw 	0a201h 18
; defw 	0a40dh 19
; defw 	0A61Ch 20
; defw 	0A82Ah 21
; defw 	0AA46h 22
; defw 	0AC60h 23
; defw 	0AE7Dh 24
; defw 	0B0A4h 25
; defw 	0B2CBh 26
; defw 	0B4F4h 27
; defw 	0b71Dh 28
; defw 	0B921h 29
; defw 	0BB2Fh 30
 


PAT01:
 defw 	$0667
 defb  004h,030h,02Fh,073h,072h,073h
 defb 	 000h,000h,000h,030h,02Fh,073h,072h,073h
 defb 	 000h,000h,000h,039h,038h,073h,072h,073h
 defb 	 000h,000h,000h,039h,038h,073h,072h,073h
 defb 	 000h,000h,000h,04Dh,04Ch,073h,072h,073h
 defb 	 000h,000h,000h,04Dh,04Ch,073h,072h,073h
 defb 	 000h,000h,000h,033h,032h,073h,072h,073h
 defb 	 000h,000h,000h,033h,032h,073h,072h,073h
 defb 	 000h,000h,000h,040h,03Fh,073h,072h,073h
 defb 	 000h,000h,000h,040h,03Fh,073h,072h,073h
 defb 	 000h,000h,000h,04Dh,04Ch,073h,072h,073h
 defb 	 000h,000h,000h,04Dh,04Ch,073h,072h,073h
 defb 	 000h,000h,000h,030h,02Fh,073h,072h,073h
 defb 	 000h,000h,000h,030h,02Fh,073h,072h,073h
 defb 	 000h,000h,000h,039h,038h,073h,072h,073h
 defb 	 000h,000h,000h,039h,038h,073h,072h,073h
 defb 	 000h,000h,000h,04Dh,04Ch,073h,072h,073h
 defb 	 000h,000h,000h,04Dh,04Ch,073h,072h,073h
 defb 	 000h,000h,000h,033h,032h,073h,072h,073h
 defb 	 000h,000h,000h,033h,032h,073h,072h,073h
 defb 	 000h,000h,000h,040h,03Fh,073h,072h,073h
 defb 	 000h,000h,000h,040h,03Fh,073h,072h,073h
 defb 	 000h,000h,000h,003h,04Dh,04Ch,073h,072h
 defb 	 073h,000h,000h,000h,003h,04Dh,04Ch,073h
 defb 	 072h,073h,000h,000h,000h,004h,040h,03Fh
 defb 	 081h,080h,081h,000h,000h,000h,040h,03Fh
 defb 	 081h,080h,081h,000h,000h,000h,003h,000h
 defb 	 000h,081h,000h,000h,000h,000h,000h,003h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,040h,03Fh,081h,080h,081h,000h,000h
 defb 	 000h,040h,03Fh,081h,080h,081h,000h,000h
 defb 	 000h,000h,000h,081h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,004h,030h,02Fh,0ADh,0ACh,0ADh,000h
 defb 	 000h,000h,030h,02Fh,0ADh,0ACh,0ADh,000h
 defb 	 000h,000h,039h,038h,0ADh,0ACh,0ADh,000h
 defb 	 000h,000h,004h,039h,038h,0ADh,0ACh,0ADh
 defb 	 000h,000h,000h,04Dh,04Ch,0ADh,0ACh,0ADh
 defb 	 000h,000h,000h,04Dh,04Ch,0ADh,0ACh,0ADh
 defb 	 000h,000h,000h,004h,033h,032h,0ADh,0ACh
 defb 	 0ADh,000h,000h,000h,033h,032h,0ADh,0ACh
 defb 	 0ADh,000h,000h,000h,040h,03Fh,0ADh,0ACh
 defb 	 0ADh,000h,000h,000h,004h,040h,03Fh,0ADh
 defb 	 0ACh,0ADh,000h,000h,000h,04Dh,04Ch,0ADh
 defb 	 0ACh,0ADh,000h,000h,000h,003h,04Dh,04Ch
 defb 	 0ADh,0ACh,0ADh,000h,000h,000h,004h,030h
 defb 	 02Fh,09Ah,099h,09Ah,000h,000h,000h,030h
 defb 	 02Fh,09Ah,099h,09Ah,000h,000h,000h,003h
 defb 	 039h,038h,09Ah,099h,09Ah,000h,000h,000h
 defb 	 003h,039h,038h,09Ah,099h,09Ah,000h,000h
 defb 	 000h,004h,04Dh,04Ch,09Ah,099h,09Ah,000h
 defb 	 000h,000h,04Dh,04Ch,09Ah,099h,09Ah,000h
 defb 	 000h,000h,004h,033h,032h,09Ah,099h,09Ah
 defb 	 000h,000h,000h,033h,032h,09Ah,099h,09Ah
 defb 	 000h,000h,000h,004h,040h,03Fh,081h,080h
 defb 	 081h,000h,000h,000h,040h,03Fh,081h,080h
 defb 	 081h,000h,000h,000h,003h,04Dh,04Ch,081h
 defb 	 000h,000h,000h,000h,000h,003h,04Dh,04Ch
 defb 	 000h,000h,000h,000h,000h,000h,004h,039h
 defb 	 038h,073h,072h,073h,000h,000h,000h,039h
 defb 	 038h,073h,072h,073h,000h,000h,000h,039h
 defb 	 038h,073h,072h,073h,000h,000h,000h,039h
 defb 	 000h,000h,072h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,001h


PAT02:
 defw 	$077c
 defb   004h,073h,072h,04Dh,039h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,073h,072h,000h,000h
 defb 	 000h,000h,000h,000h,073h,072h,04Dh,039h
 defb 	 000h,000h,000h,000h,003h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,073h,072h
 defb 	 000h,000h,000h,000h,000h,000h,000h,072h
 defb 	 04Dh,039h,000h,000h,000h,000h,004h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 073h,072h,000h,000h,000h,000h,000h,000h
 defb 	 000h,072h,04Dh,039h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 003h,04Dh,039h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,004h,081h,080h,056h,040h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,081h,080h,000h,000h,000h
 defb 	 000h,000h,000h,081h,080h,056h,040h,000h
 defb 	 000h,000h,000h,003h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,004h,081h,080h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,056h
 defb 	 040h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,081h,080h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 056h,040h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,003h,056h
 defb 	 040h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,056h
 defb 	 040h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 0ADh,0ACh,056h,039h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,0ADh,0ACh,000h,000h,000h,000h,000h
 defb 	 000h,0ADh,0ACh,056h,030h,000h,000h,000h
 defb 	 000h,003h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,0ADh,0ACh,000h,000h,000h
 defb 	 000h,000h,000h,000h,0ACh,056h,039h,000h
 defb 	 000h,000h,000h,004h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,004h,0ADh,0ACh,000h
 defb 	 000h,000h,000h,000h,000h,000h,0ACh,056h
 defb 	 030h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,003h,056h,039h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,004h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 091h,090h,039h,048h,000h,000h,000h,000h
 defb 	 000h,000h,039h,048h,000h,000h,000h,000h
 defb 	 003h,091h,090h,039h,048h,000h,000h,000h
 defb 	 000h,004h,081h,080h,033h,040h,000h,000h
 defb 	 000h,000h,000h,000h,033h,040h,000h,000h
 defb 	 000h,000h,003h,081h,080h,033h,040h,000h
 defb 	 000h,000h,000h,004h,073h,072h,030h,039h
 defb 	 000h,000h,000h,000h,073h,072h,030h,039h
 defb 	 000h,000h,000h,000h,073h,072h,030h,039h
 defb 	 000h,000h,000h,000h,073h,072h,000h,039h
 defb 	 000h,000h,000h,000h,073h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,003h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,003h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,003h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,003h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 001h

PAT03:
 defw  $077C
 defb  007h,004h,073h,072h,04Dh,039h
 defb 	 026h,04Ch,000h,000h,000h,000h,000h,000h
 defb 	 026h,04Ch,000h,000h,004h,073h,072h,000h
 defb 	 000h,026h,04Ch,000h,000h,073h,072h,04Dh
 defb 	 039h,026h,04Ch,000h,000h,003h,000h,000h
 defb 	 000h,000h,030h,02Fh,000h,000h,004h,073h
 defb 	 072h,000h,000h,000h,000h,000h,000h,000h
 defb 	 072h,04Dh,039h,02Bh,02Ah,000h,000h,004h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,073h,072h,000h,000h,026h,04Dh,000h
 defb 	 000h,000h,072h,04Dh,039h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,02Bh,02Ah,000h
 defb 	 000h,000h,000h,000h,000h,026h,026h,000h
 defb 	 000h,003h,04Dh,039h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,026h,04Dh
 defb 	 000h,000h,000h,000h,000h,000h,039h,039h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,081h,080h,056h,033h,033h
 defb 	 032h,000h,000h,000h,000h,000h,000h,033h
 defb 	 032h,000h,000h,004h,081h,080h,000h,000h
 defb 	 033h,032h,000h,000h,081h,080h,056h,033h
 defb 	 033h,032h,000h,000h,003h,000h,000h,000h
 defb 	 000h,030h,02Fh,000h,000h,004h,081h,080h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 056h,033h,02Bh,02Ah,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,004h,081h
 defb 	 080h,000h,000h,026h,026h,000h,000h,000h
 defb 	 000h,056h,033h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,02Bh,02Ah,000h,000h,000h
 defb 	 000h,000h,000h,030h,02Fh,000h,000h,003h
 defb 	 056h,033h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,033h,032h,000h,000h
 defb 	 056h,033h,000h,000h,039h,038h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,0ADh,0ACh,056h,039h,000h,000h,038h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,004h,0ADh,0ACh,000h,000h,000h,04Ch
 defb 	 04Dh,000h,0ADh,0ACh,056h,030h,000h,000h
 defb 	 02Fh,000h,003h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,0ADh,0ACh,000h,000h
 defb 	 000h,04Ch,04Dh,000h,000h,0ACh,056h,039h
 defb 	 000h,000h,038h,000h,004h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,0ADh,0ACh
 defb 	 000h,000h,000h,04Ch,04Dh,000h,000h,0ACh
 defb 	 056h,030h,000h,000h,02Fh,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,04Ch,04Dh,000h,003h,056h
 defb 	 039h,000h,000h,000h,000h,038h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,091h,090h,039h,030h,02Fh,026h,000h
 defb 	 000h,000h,000h,039h,030h,02Fh,026h,000h
 defb 	 000h,003h,091h,090h,039h,030h,02Fh,026h
 defb 	 000h,000h,004h,081h,080h,040h,033h,032h
 defb 	 02Ah,000h,000h,000h,000h,040h,033h,032h
 defb 	 02Ah,000h,000h,003h,081h,080h,040h,033h
 defb 	 032h,02Ah,000h,000h,004h,073h,072h,030h
 defb 	 039h,038h,02Fh,073h,000h,073h,072h,030h
 defb 	 039h,038h,02Fh,073h,000h,073h,072h,030h
 defb 	 039h,038h,02Fh,073h,000h,073h,072h,000h
 defb 	 039h,038h,000h,073h,000h,003h,073h,072h
 defb 	 000h,000h,000h,000h,000h,000h,003h,073h
 defb 	 000h,000h,000h,000h,000h,000h,000h,003h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 003h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,003h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,003h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,001h

PAT04:
 defw 	$077c
 defb  004h,073h
 defb 	 072h,04Dh,039h,026h,04Ch,000h,000h,000h
 defb 	 000h,000h,000h,026h,04Ch,000h,000h,004h
 defb 	 073h,072h,000h,000h,026h,04Ch,000h,000h
 defb 	 073h,072h,04Dh,039h,026h,04Ch,000h,000h
 defb 	 003h,000h,000h,000h,000h,030h,02Fh,000h
 defb 	 000h,004h,073h,072h,000h,000h,000h,000h
 defb 	 000h,000h,000h,072h,04Dh,039h,02Bh,02Ah
 defb 	 000h,000h,004h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,073h,072h,000h,000h
 defb 	 026h,04Dh,000h,000h,000h,072h,04Dh,039h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 02Bh,02Ah,000h,000h,000h,000h,000h,000h
 defb 	 026h,026h,000h,000h,003h,04Dh,039h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,026h,04Dh,000h,000h,000h,000h,000h
 defb 	 000h,039h,039h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,081h,080h
 defb 	 056h,040h,033h,032h,000h,000h,000h,000h
 defb 	 000h,000h,033h,032h,000h,000h,004h,081h
 defb 	 080h,000h,000h,033h,032h,000h,000h,081h
 defb 	 080h,056h,040h,033h,032h,000h,000h,003h
 defb 	 000h,000h,000h,000h,030h,02Fh,000h,000h
 defb 	 004h,081h,080h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,056h,040h,02Bh,02Ah,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,004h,081h,080h,000h,000h,026h,026h
 defb 	 000h,000h,000h,000h,056h,040h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,02Bh,02Ah
 defb 	 000h,000h,000h,000h,000h,000h,030h,02Fh
 defb 	 000h,000h,003h,056h,040h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,033h
 defb 	 032h,000h,000h,056h,040h,000h,000h,039h
 defb 	 038h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,0ADh,0ACh,056h,039h
 defb 	 000h,000h,038h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,004h,0ADh,0ACh,000h
 defb 	 000h,000h,04Ch,04Dh,000h,0ADh,0ACh,056h
 defb 	 030h,000h,000h,02Fh,000h,003h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,004h,0ADh
 defb 	 0ACh,000h,000h,000h,04Ch,04Dh,000h,000h
 defb 	 0ACh,056h,039h,000h,000h,038h,000h,004h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,0ADh,0ACh,000h,000h,000h,04Ch,04Dh
 defb 	 000h,000h,0ACh,056h,030h,000h,000h,02Fh
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,04Ch,04Dh
 defb 	 000h,003h,056h,039h,000h,000h,000h,000h
 defb 	 038h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,091h,090h,039h,048h
 defb 	 047h,038h,000h,000h,000h,000h,039h,048h
 defb 	 047h,038h,000h,000h,003h,091h,090h,039h
 defb 	 048h,047h,038h,000h,000h,004h,081h,080h
 defb 	 033h,040h,03Fh,032h,000h,000h,000h,000h
 defb 	 033h,040h,03Fh,032h,000h,000h,003h,081h
 defb 	 080h,033h,040h,03Fh,032h,000h,000h,004h
 defb 	 073h,072h,030h,039h,038h,02Fh,000h,000h
 defb 	 073h,072h,030h,039h,038h,02Fh,000h,000h
 defb 	 073h,072h,030h,039h,038h,02Fh,000h,000h
 defb 	 073h,072h,000h,039h,000h,02Fh,000h,000h
 defb 	 073h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 003h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,003h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,003h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,003h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,001h

PAT05:
 defw 	$0667
 defb  	004h
 defb 	 030h,02Fh,073h,072h,073h,000h,000h,000h
 defb 	 030h,02Fh,073h,072h,073h,000h,000h,000h
 defb 	 039h,038h,073h,072h,073h,000h,000h,000h
 defb 	 039h,038h,073h,072h,073h,000h,000h,000h
 defb 	 04Dh,04Ch,073h,072h,073h,000h,000h,000h
 defb 	 04Dh,04Ch,073h,072h,073h,000h,000h,000h
 defb 	 033h,032h,073h,072h,073h,000h,000h,000h
 defb 	 033h,032h,073h,072h,073h,000h,000h,000h
 defb 	 040h,03Fh,073h,072h,073h,000h,000h,000h
 defb 	 040h,03Fh,073h,072h,073h,000h,000h,000h
 defb 	 04Dh,04Ch,073h,072h,073h,000h,000h,000h
 defb 	 04Dh,04Ch,073h,072h,073h,000h,000h,000h
 defb 	 030h,02Fh,073h,072h,073h,000h,000h,000h
 defb 	 030h,02Fh,073h,072h,073h,000h,000h,000h
 defb 	 039h,038h,073h,072h,073h,000h,000h,000h
 defb 	 039h,038h,073h,072h,073h,000h,000h,000h
 defb 	 04Dh,04Ch,073h,072h,073h,000h,000h,000h
 defb 	 04Dh,04Ch,073h,072h,073h,000h,000h,000h
 defb 	 033h,032h,073h,072h,073h,000h,000h,000h
 defb 	 033h,032h,073h,072h,073h,000h,000h,000h
 defb 	 040h,03Fh,073h,072h,073h,000h,000h,000h
 defb 	 040h,03Fh,073h,072h,073h,000h,000h,000h
 defb 	 003h,04Dh,04Ch,073h,072h,073h,000h,000h
 defb 	 000h,003h,04Dh,04Ch,073h,072h,073h,000h
 defb 	 000h,000h,004h,040h,03Fh,081h,080h,081h
 defb 	 000h,000h,000h,040h,03Fh,081h,080h,081h
 defb 	 000h,000h,000h,003h,000h,000h,081h,000h
 defb 	 000h,000h,000h,000h,003h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,040h,03Fh
 defb 	 081h,080h,081h,000h,000h,000h,040h,03Fh
 defb 	 081h,080h,081h,000h,000h,000h,000h,000h
 defb 	 081h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,004h,030h
 defb 	 02Fh,0ADh,0ACh,0ADh,000h,000h,000h,030h
 defb 	 02Fh,0ADh,0ACh,0ADh,000h,000h,000h,039h
 defb 	 038h,0ADh,0ACh,0ADh,000h,000h,000h,004h
 defb 	 039h,038h,0ADh,0ACh,0ADh,000h,000h,000h
 defb 	 04Dh,04Ch,0ADh,0ACh,0ADh,000h,000h,000h
 defb 	 04Dh,04Ch,0ADh,0ACh,0ADh,000h,000h,000h
 defb 	 004h,033h,032h,0ADh,0ACh,0ADh,000h,000h
 defb 	 000h,033h,032h,0ADh,0ACh,0ADh,000h,000h
 defb 	 000h,040h,03Fh,0ADh,0ACh,0ADh,000h,000h
 defb 	 000h,004h,040h,03Fh,0ADh,0ACh,0ADh,000h
 defb 	 000h,000h,04Dh,04Ch,0ADh,0ACh,0ADh,000h
 defb 	 000h,000h,003h,04Dh,04Ch,0ADh,0ACh,0ADh
 defb 	 000h,000h,000h,004h,030h,02Fh,09Ah,099h
 defb 	 09Ah,000h,000h,000h,030h,02Fh,09Ah,099h
 defb 	 09Ah,000h,000h,000h,003h,039h,038h,09Ah
 defb 	 099h,09Ah,000h,000h,000h,003h,039h,038h
 defb 	 09Ah,099h,09Ah,000h,000h,000h,004h,04Dh
 defb 	 04Ch,09Ah,099h,09Ah,000h,000h,000h,04Dh
 defb 	 04Ch,09Ah,099h,09Ah,000h,000h,000h,004h
 defb 	 033h,032h,09Ah,099h,09Ah,000h,000h,000h
 defb 	 033h,032h,09Ah,099h,09Ah,000h,000h,000h
 defb 	 004h,039h,038h,091h,090h,091h,000h,039h
 defb 	 000h,039h,038h,091h,090h,091h,000h,039h
 defb 	 000h,048h,030h,091h,000h,000h,000h,039h
 defb 	 000h,000h,030h,000h,000h,000h,000h,000h
 defb 	 000h,001h

PAT06:
 defw 	$077c
 defb  	 004h,039h,038h,073h
 defb 	 072h,073h,04Dh,04Ch,000h,039h,038h,073h
 defb 	 072h,073h,04Dh,04Ch,000h,039h,038h,073h
 defb 	 072h,073h,04Dh,04Ch,000h,039h,038h,073h
 defb 	 072h,073h,04Dh,04Ch,000h,039h,038h,073h
 defb 	 072h,073h,04Dh,04Ch,000h,039h,038h,073h
 defb 	 072h,073h,04Dh,04Ch,000h,004h,039h,038h
 defb 	 073h,072h,073h,04Dh,04Ch,000h,039h,038h
 defb 	 073h,072h,073h,04Dh,04Ch,000h,004h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,000h,000h,039h
 defb 	 000h,073h,072h,073h,000h,000h,000h,004h
 defb 	 040h,03Fh,0ADh,0ACh,0ADh,039h,038h,000h
 defb 	 040h,03Fh,0ADh,0ACh,0ADh,039h,038h,000h
 defb 	 040h,03Fh,0ADh,0ACh,0ADh,039h,038h,000h
 defb 	 040h,03Fh,0ADh,0ACh,0ADh,039h,038h,000h
 defb 	 040h,03Fh,09Ah,099h,09Ah,039h,038h,000h
 defb 	 040h,03Fh,09Ah,099h,09Ah,039h,038h,000h
 defb 	 004h,040h,03Fh,09Ah,099h,09Ah,039h,000h
 defb 	 000h,040h,000h,09Ah,099h,09Ah,000h,000h
 defb 	 000h,004h,056h,055h,081h,080h,081h,044h
 defb 	 043h,000h,056h,055h,081h,080h,081h,044h
 defb 	 043h,000h,056h,055h,081h,080h,081h,044h
 defb 	 043h,000h,056h,055h,081h,080h,081h,044h
 defb 	 043h,000h,004h,056h,055h,073h,072h,073h
 defb 	 044h,043h,000h,056h,055h,073h,072h,073h
 defb 	 044h,043h,000h,056h,055h,073h,072h,073h
 defb 	 044h,000h,000h,056h,000h,073h,072h,073h
 defb 	 000h,000h,000h,001h

PAT07:
 defw 	$077c
 defb  	 004h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,01Ch,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,026h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,01Ch,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,004h
 defb 	 039h,038h,073h,072h,073h,04Dh,04Ch,026h
 defb 	 039h,038h,073h,072h,073h,04Dh,04Ch,000h
 defb 	 003h,039h,038h,073h,072h,073h,04Dh,04Ch
 defb 	 01Ch,039h,038h,073h,072h,073h,04Dh,04Ch
 defb 	 000h,039h,038h,073h,072h,073h,04Dh,04Ch
 defb 	 026h,039h,038h,073h,072h,073h,04Dh,04Ch
 defb 	 000h,039h,038h,073h,072h,073h,04Dh,04Ch
 defb 	 01Ch,039h,038h,073h,072h,073h,04Dh,04Ch
 defb 	 000h,039h,038h,073h,072h,073h,04Dh,000h
 defb 	 026h,039h,000h,073h,072h,073h,000h,000h
 defb 	 000h,004h,040h,03Fh,0ADh,0ACh,0ADh,039h
 defb 	 038h,01Ch,040h,03Fh,0ADh,0ACh,0ADh,039h
 defb 	 038h,000h,040h,03Fh,0ADh,0ACh,0ADh,039h
 defb 	 038h,026h,040h,03Fh,0ADh,0ACh,0ADh,039h
 defb 	 038h,000h,040h,03Fh,09Ah,099h,09Ah,039h
 defb 	 038h,01Ch,040h,03Fh,09Ah,099h,09Ah,039h
 defb 	 038h,000h,004h,040h,03Fh,09Ah,099h,09Ah
 defb 	 039h,000h,026h,040h,000h,09Ah,099h,09Ah
 defb 	 000h,000h,000h,003h,056h,055h,081h,080h
 defb 	 081h,044h,043h,019h,056h,055h,081h,080h
 defb 	 081h,044h,043h,000h,004h,056h,055h,081h
 defb 	 080h,081h,044h,043h,020h,056h,055h,081h
 defb 	 080h,081h,044h,043h,000h,003h,056h,055h
 defb 	 073h,072h,073h,044h,043h,019h,056h,055h
 defb 	 073h,072h,073h,044h,043h,000h,003h,056h
 defb 	 055h,073h,072h,073h,044h,000h,020h,003h
 defb 	 056h,000h,073h,072h,073h,000h,000h,000h
 defb 	 001h

PAT08:
 defw 	$077c
 defb  	 004h,039h,038h,073h,072h
 defb 	 073h,04Dh,04Ch,000h,039h,038h,073h,072h
 defb 	 073h,04Dh,04Ch,000h,039h,038h,073h,072h
 defb 	 073h,04Dh,04Ch,000h,039h,038h,073h,072h
 defb 	 073h,04Dh,04Ch,000h,003h,039h,038h,073h
 defb 	 072h,073h,04Dh,04Ch,000h,039h,038h,073h
 defb 	 072h,073h,04Dh,04Ch,000h,004h,039h,038h
 defb 	 073h,072h,073h,04Dh,04Ch,000h,039h,038h
 defb 	 073h,072h,073h,04Dh,04Ch,000h,004h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,039h
 defb 	 038h,073h,072h,073h,04Dh,04Ch,000h,003h
 defb 	 039h,038h,073h,072h,073h,04Dh,04Ch,000h
 defb 	 039h,038h,073h,072h,073h,04Dh,04Ch,000h
 defb 	 039h,038h,073h,072h,073h,04Dh,000h,000h
 defb 	 039h,000h,073h,072h,073h,000h,000h,000h
 defb 	 004h,040h,03Fh,0ADh,0ACh,0ADh,039h,038h
 defb 	 000h,040h,03Fh,0ADh,0ACh,0ADh,039h,038h
 defb 	 000h,040h,03Fh,0ADh,0ACh,0ADh,039h,038h
 defb 	 000h,040h,03Fh,0ADh,0ACh,0ADh,039h,038h
 defb 	 000h,003h,040h,03Fh,09Ah,099h,09Ah,039h
 defb 	 038h,000h,040h,03Fh,09Ah,099h,09Ah,039h
 defb 	 038h,000h,004h,040h,03Fh,09Ah,099h,09Ah
 defb 	 039h,000h,000h,040h,000h,09Ah,099h,09Ah
 defb 	 000h,000h,000h,004h,056h,055h,081h,080h
 defb 	 081h,044h,043h,000h,056h,055h,081h,080h
 defb 	 081h,044h,043h,000h,003h,056h,055h,081h
 defb 	 080h,081h,044h,043h,000h,056h,055h,081h
 defb 	 080h,081h,044h,043h,000h,003h,056h,055h
 defb 	 073h,072h,073h,044h,043h,000h,056h,055h
 defb 	 073h,072h,073h,044h,043h,000h,003h,056h
 defb 	 055h,073h,072h,073h,044h,000h,000h,056h
 defb 	 000h,073h,072h,073h,000h,000h,000h,001h


PAT09:
 defw 	$077c
 defb  	 004h,073h,072h,04Dh,039h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,073h,072h,000h,000h
 defb 	 000h,000h,000h,000h,073h,072h,04Dh,039h
 defb 	 000h,000h,000h,000h,003h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,073h,072h
 defb 	 000h,000h,000h,000h,000h,000h,000h,072h
 defb 	 04Dh,039h,000h,000h,000h,000h,004h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 073h,072h,000h,000h,000h,000h,000h,000h
 defb 	 000h,072h,04Dh,039h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 003h,04Dh,039h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,004h,081h,080h,056h,033h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,081h,080h,000h,000h,000h
 defb 	 000h,000h,000h,081h,080h,056h,033h,000h
 defb 	 000h,000h,000h,003h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,004h,081h,080h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,056h
 defb 	 033h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,081h,080h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 056h,033h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,003h,056h
 defb 	 033h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,056h
 defb 	 033h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,001h


PAT10:
 defw 	$077c
 defb  	 004h,073h,072h,04Dh,039h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,073h,072h,000h,000h
 defb 	 000h,000h,000h,000h,073h,072h,04Dh,039h
 defb 	 000h,000h,000h,000h,003h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,073h,072h
 defb 	 000h,000h,000h,000h,000h,000h,000h,072h
 defb 	 04Dh,039h,000h,000h,000h,000h,004h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 073h,072h,000h,000h,000h,000h,000h,000h
 defb 	 000h,072h,04Dh,039h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 003h,04Dh,039h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,004h,081h,080h,056h,033h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,081h,080h,000h,000h,000h
 defb 	 000h,000h,000h,081h,080h,056h,033h,000h
 defb 	 000h,000h,000h,003h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,004h,081h,080h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,056h
 defb 	 033h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,081h,080h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 056h,033h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,003h,056h
 defb 	 033h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,056h
 defb 	 033h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 0ADh,0ACh,056h,030h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,0ADh,0ACh,000h,000h,000h,000h,000h
 defb 	 000h,0ADh,0ACh,056h,039h,000h,000h,000h
 defb 	 000h,003h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,0ADh,0ACh,000h,000h,000h
 defb 	 000h,000h,000h,000h,0ACh,056h,030h,000h
 defb 	 000h,000h,000h,004h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,004h,0ADh,0ACh,000h
 defb 	 000h,000h,000h,000h,000h,000h,0ACh,056h
 defb 	 039h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,003h,056h,039h
 defb 	 000h,030h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,004h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 091h,090h,039h,030h,000h,000h,000h,000h
 defb 	 091h,090h,039h,030h,000h,000h,000h,000h
 defb 	 003h,091h,090h,039h,030h,000h,000h,000h
 defb 	 000h,004h,081h,080h,040h,033h,000h,000h
 defb 	 000h,000h,081h,080h,040h,033h,000h,000h
 defb 	 000h,000h,003h,081h,080h,040h,033h,000h
 defb 	 000h,000h,000h,004h,073h,072h,030h,039h
 defb 	 000h,000h,000h,000h,073h,072h,030h,039h
 defb 	 000h,000h,000h,000h,003h,073h,072h,030h
 defb 	 039h,000h,000h,000h,000h,003h,073h,072h
 defb 	 000h,039h,000h,000h,000h,000h,003h,073h
 defb 	 072h,000h,000h,000h,000h,000h,000h,003h
 defb 	 073h,072h,000h,000h,000h,000h,000h,000h
 defb 	 003h,073h,000h,000h,000h,000h,000h,000h
 defb 	 000h,003h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,003h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,003h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,001h

PAT11:
 defw 	$077c
 defb  	 004h
 defb 	 040h,056h,081h,080h,081h,000h,033h,000h
 defb 	 040h,056h,081h,080h,081h,000h,033h,000h
 defb 	 040h,056h,081h,080h,081h,000h,033h,000h
 defb 	 040h,056h,081h,080h,081h,000h,033h,000h
 defb 	 040h,056h,081h,080h,081h,000h,033h,000h
 defb 	 040h,056h,081h,080h,081h,000h,033h,000h
 defb 	 004h,040h,056h,081h,080h,081h,000h,033h
 defb 	 000h,040h,056h,081h,080h,081h,000h,033h
 defb 	 000h,003h,040h,056h,081h,080h,081h,000h
 defb 	 033h,000h,040h,056h,081h,080h,081h,000h
 defb 	 033h,000h,003h,040h,056h,081h,080h,081h
 defb 	 000h,033h,000h,040h,056h,081h,080h,081h
 defb 	 000h,033h,000h,003h,040h,056h,081h,080h
 defb 	 081h,000h,033h,000h,040h,056h,081h,080h
 defb 	 081h,000h,033h,000h,003h,040h,056h,081h
 defb 	 080h,081h,000h,033h,000h,040h,056h,081h
 defb 	 080h,081h,000h,033h,000h,001h

PAT12:
 defw 	$077c
 defb  	 004h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,026h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,024h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,026h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,024h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,024h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,026h
 defb 	 000h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 000h,091h,090h,091h,048h,047h,000h,039h
 defb 	 000h,091h,090h,091h,048h,047h,000h,030h
 defb 	 000h,091h,090h,091h,048h,047h,000h,026h
 defb 	 000h,091h,090h,091h,048h,047h,000h,039h
 defb 	 000h,091h,090h,091h,048h,047h,000h,030h
 defb 	 000h,091h,090h,091h,048h,047h,000h,024h
 defb 	 000h,091h,090h,091h,048h,047h,000h,039h
 defb 	 000h,091h,090h,091h,048h,047h,000h,030h
 defb 	 000h,091h,090h,091h,048h,047h,000h,026h
 defb 	 000h,091h,090h,091h,048h,047h,000h,039h
 defb 	 000h,091h,090h,091h,048h,047h,000h,030h
 defb 	 000h,091h,090h,091h,048h,047h,000h,024h
 defb 	 000h,091h,090h,091h,048h,047h,000h,039h
 defb 	 000h,091h,090h,091h,048h,047h,000h,024h
 defb 	 000h,091h,090h,091h,048h,047h,000h,026h
 defb 	 000h,091h,090h,091h,048h,047h,000h,030h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,030h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,024h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,030h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,020h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,030h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,024h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,030h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,020h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,020h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,024h
 defb 	 000h,0ADh,0ACh,0ADh,056h,055h,000h,026h
 defb 	 000h,003h,09Ah,099h,09Ah,04Dh,04Ch,000h
 defb 	 039h,000h,09Ah,099h,09Ah,04Dh,04Ch,000h
 defb 	 030h,000h,003h,09Ah,099h,09Ah,04Dh,04Ch
 defb 	 000h,024h,000h,09Ah,099h,09Ah,04Dh,04Ch
 defb 	 000h,039h,000h,003h,09Ah,099h,09Ah,04Dh
 defb 	 04Ch,000h,030h,000h,003h,09Ah,099h,09Ah
 defb 	 04Dh,04Ch,000h,020h,000h,003h,09Ah,099h
 defb 	 09Ah,04Dh,04Ch,000h,039h,000h,003h,09Ah
 defb 	 099h,09Ah,04Dh,04Ch,000h,030h,000h,09Ah
 defb 	 099h,09Ah,04Dh,04Ch,000h,024h,000h,003h
 defb 	 09Ah,099h,09Ah,04Dh,04Ch,000h,039h,000h
 defb 	 09Ah,099h,09Ah,04Dh,04Ch,000h,030h,000h
 defb 	 003h,09Ah,099h,09Ah,04Dh,04Ch,000h,020h
 defb 	 000h,09Ah,099h,09Ah,04Dh,04Ch,000h,039h
 defb 	 000h,003h,09Ah,099h,09Ah,04Dh,04Ch,000h
 defb 	 024h,000h,003h,09Ah,099h,09Ah,04Dh,04Ch
 defb 	 000h,026h,000h,003h,09Ah,099h,09Ah,04Dh
 defb 	 04Ch,000h,030h,000h,001h

PAT13:
 defw 	$077c
 defb  	 004h
 defb 	 039h,038h,073h,072h,073h,04Dh,04Ch,01Ch
 defb 	 039h,038h,073h,072h,073h,04Dh,04Ch,000h
 defb 	 039h,038h,073h,072h,073h,04Dh,04Ch,026h
 defb 	 039h,038h,073h,072h,073h,04Dh,04Ch,000h
 defb 	 003h,039h,038h,073h,072h,073h,04Dh,04Ch
 defb 	 01Ch,039h,038h,073h,072h,073h,04Dh,04Ch
 defb 	 000h,004h,039h,038h,073h,072h,073h,04Dh
 defb 	 04Ch,026h,039h,038h,073h,072h,073h,04Dh
 defb 	 04Ch,000h,004h,039h,038h,073h,072h,073h
 defb 	 04Dh,04Ch,01Ch,039h,038h,073h,072h,073h
 defb 	 04Dh,04Ch,000h,039h,038h,073h,072h,073h
 defb 	 04Dh,04Ch,026h,039h,038h,073h,072h,073h
 defb 	 04Dh,04Ch,000h,003h,039h,038h,073h,072h
 defb 	 073h,04Dh,04Ch,01Ch,039h,038h,073h,072h
 defb 	 073h,04Dh,04Ch,000h,039h,038h,073h,072h
 defb 	 073h,04Dh,000h,026h,039h,000h,073h,072h
 defb 	 073h,000h,000h,000h,004h,040h,03Fh,0ADh
 defb 	 0ACh,0ADh,039h,038h,01Ch,040h,03Fh,0ADh
 defb 	 0ACh,0ADh,039h,038h,000h,040h,03Fh,0ADh
 defb 	 0ACh,0ADh,039h,038h,026h,040h,03Fh,0ADh
 defb 	 0ACh,0ADh,039h,038h,000h,003h,040h,03Fh
 defb 	 09Ah,099h,09Ah,039h,038h,01Ch,040h,03Fh
 defb 	 09Ah,099h,09Ah,039h,038h,000h,004h,040h
 defb 	 03Fh,09Ah,099h,09Ah,039h,000h,026h,040h
 defb 	 000h,09Ah,099h,09Ah,000h,000h,000h,004h
 defb 	 056h,055h,081h,080h,081h,044h,043h,019h
 defb 	 056h,055h,081h,080h,081h,044h,043h,000h
 defb 	 003h,056h,055h,081h,080h,081h,044h,043h
 defb 	 020h,056h,055h,081h,080h,081h,044h,043h
 defb 	 000h,003h,056h,055h,073h,072h,073h,044h
 defb 	 043h,019h,003h,056h,055h,073h,072h,073h
 defb 	 044h,043h,000h,003h,056h,055h,073h,072h
 defb 	 073h,044h,000h,020h,003h,056h,000h,073h
 defb 	 072h,073h,000h,000h,000h,001h

PAT14:
 defw 	$077c
 defb 	 004h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 039h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 030h,0E7h,0E7h,0E7h,073h,072h,000h,026h
 defb 	 026h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 039h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 030h,0E7h,0E7h,0E7h,073h,072h,000h,024h
 defb 	 024h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 039h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 030h,0E7h,0E7h,0E7h,073h,072h,000h,026h
 defb 	 026h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 039h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 030h,0E7h,0E7h,0E7h,073h,072h,000h,024h
 defb 	 024h,0E7h,0E7h,0E7h,073h,072h,000h,039h
 defb 	 039h,0E7h,0E7h,0E7h,073h,072h,000h,024h
 defb 	 024h,0E7h,0E7h,0E7h,073h,072h,000h,026h
 defb 	 026h,0E7h,0E7h,0E7h,073h,072h,000h,030h
 defb 	 030h,091h,090h,091h,048h,047h,000h,039h
 defb 	 039h,091h,090h,091h,048h,047h,000h,030h
 defb 	 030h,091h,090h,091h,048h,047h,000h,026h
 defb 	 026h,091h,090h,091h,048h,047h,000h,039h
 defb 	 039h,091h,090h,091h,048h,047h,000h,030h
 defb 	 030h,091h,090h,091h,048h,047h,000h,024h
 defb 	 024h,091h,090h,091h,048h,047h,000h,039h
 defb 	 039h,091h,090h,091h,048h,047h,000h,030h
 defb 	 030h,091h,090h,091h,048h,047h,000h,026h
 defb 	 026h,091h,090h,091h,048h,047h,000h,039h
 defb 	 039h,091h,090h,091h,048h,047h,000h,030h
 defb 	 030h,091h,090h,091h,048h,047h,000h,024h
 defb 	 024h,091h,090h,091h,048h,047h,000h,039h
 defb 	 039h,091h,090h,091h,048h,047h,000h,024h
 defb 	 024h,091h,090h,091h,048h,047h,000h,026h
 defb 	 026h,091h,090h,091h,048h,047h,000h,030h
 defb 	 030h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 039h,0ADh,0ACh,0ADh,056h,055h,000h,030h
 defb 	 030h,0ADh,0ACh,0ADh,056h,055h,000h,024h
 defb 	 024h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 039h,0ADh,0ACh,0ADh,056h,055h,000h,030h
 defb 	 030h,0ADh,0ACh,0ADh,056h,055h,000h,020h
 defb 	 020h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 039h,0ADh,0ACh,0ADh,056h,055h,000h,030h
 defb 	 030h,0ADh,0ACh,0ADh,056h,055h,000h,024h
 defb 	 024h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 039h,0ADh,0ACh,0ADh,056h,055h,000h,030h
 defb 	 030h,0ADh,0ACh,0ADh,056h,055h,000h,020h
 defb 	 020h,0ADh,0ACh,0ADh,056h,055h,000h,039h
 defb 	 039h,0ADh,0ACh,0ADh,056h,055h,000h,020h
 defb 	 020h,0ADh,0ACh,0ADh,056h,055h,000h,024h
 defb 	 024h,0ADh,0ACh,0ADh,056h,055h,000h,026h
 defb 	 026h,09Ah,099h,09Ah,04Dh,04Ch,000h,039h
 defb 	 039h,09Ah,099h,09Ah,04Dh,04Ch,000h,030h
 defb 	 030h,008h,09Ah,099h,09Ah,04Dh,04Ch,000h
 defb 	 024h,024h,008h,09Ah,099h,09Ah,04Dh,04Ch
 defb 	 000h,039h,039h,007h,09Ah,099h,09Ah,04Dh
 defb 	 04Ch,000h,030h,030h,007h,09Ah,099h,09Ah
 defb 	 04Dh,04Ch,000h,020h,020h,006h,09Ah,099h
 defb 	 09Ah,04Dh,04Ch,000h,039h,039h,006h,09Ah
 defb 	 099h,09Ah,04Dh,04Ch,000h,030h,030h,005h
 defb 	 09Ah,099h,09Ah,04Dh,04Ch,000h,024h,024h
 defb 	 005h,09Ah,099h,09Ah,04Dh,04Ch,000h,039h
 defb 	 039h,004h,09Ah,099h,09Ah,04Dh,04Ch,000h
 defb 	 030h,030h,004h,09Ah,099h,09Ah,04Dh,04Ch
 defb 	 000h,020h,020h,003h,09Ah,099h,09Ah,04Dh
 defb 	 04Ch,000h,039h,039h,003h,09Ah,099h,09Ah
 defb 	 04Dh,04Ch,000h,024h,024h,002h,09Ah,099h
 defb 	 09Ah,04Dh,04Ch,000h,026h,026h,002h,09Ah
 defb 	 099h,09Ah,04Dh,04Ch,000h,030h,030h,001h

PAT15:
 defw 	$077c
 defb  	 004h,073h,072h,000h,000h,073h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,073h,072h,039h,030h
 defb 	 073h,000h,000h,000h,073h,072h,039h,030h
 defb 	 073h,000h,000h,000h,003h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,039h
 defb 	 030h,000h,000h,000h,000h,073h,072h,000h
 defb 	 000h,073h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,073h,072h
 defb 	 039h,030h,073h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,004h,073h
 defb 	 072h,000h,000h,073h,000h,000h,000h,073h
 defb 	 072h,039h,033h,073h,000h,000h,000h,003h
 defb 	 000h,000h,039h,033h,000h,000h,000h,000h
 defb 	 004h,073h,072h,039h,033h,073h,000h,000h
 defb 	 000h,073h,072h,039h,030h,073h,000h,000h
 defb 	 000h,073h,072h,000h,000h,073h,000h,000h
 defb 	 000h,004h,0C2h,0C1h,000h,000h,0C2h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,0C2h,0C1h,04Dh,030h,0C2h
 defb 	 000h,000h,000h,0C2h,0C1h,04Dh,030h,0C2h
 defb 	 000h,000h,000h,003h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,04Dh,030h
 defb 	 000h,000h,000h,000h,0C2h,0C1h,000h,000h
 defb 	 0C2h,000h,000h,000h,004h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,0C2h,0C1h
 defb 	 04Dh,030h,0C2h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,004h,0C2h
 defb 	 0C1h,000h,000h,0C2h,000h,000h,000h,0C2h
 defb 	 0C1h,061h,033h,0C2h,000h,000h,000h,003h
 defb 	 000h,000h,061h,033h,000h,000h,000h,000h
 defb 	 004h,0C2h,0C1h,061h,033h,0C2h,000h,000h
 defb 	 000h,004h,0C2h,0C1h,04Dh,030h,0C2h,000h
 defb 	 000h,000h,0C2h,0C1h,000h,000h,0C2h,000h
 defb 	 000h,000h,004h,081h,080h,000h,000h,081h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,081h,080h,040h,033h
 defb 	 081h,000h,000h,000h,081h,080h,040h,033h
 defb 	 081h,000h,000h,000h,003h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,040h
 defb 	 033h,000h,000h,000h,000h,081h,080h,000h
 defb 	 000h,081h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,081h,080h
 defb 	 040h,033h,081h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,004h,081h
 defb 	 080h,000h,000h,081h,000h,000h,000h,081h
 defb 	 080h,056h,039h,081h,000h,000h,000h,003h
 defb 	 000h,000h,056h,039h,000h,000h,000h,000h
 defb 	 004h,081h,080h,056h,039h,081h,000h,000h
 defb 	 000h,081h,080h,040h,033h,081h,000h,000h
 defb 	 000h,081h,080h,000h,000h,081h,000h,000h
 defb 	 000h,004h,0ADh,0ACh,000h,000h,0ADh,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,0ADh,0ACh,056h,039h,0ADh
 defb 	 000h,000h,000h,0ADh,0ACh,056h,039h,0ADh
 defb 	 000h,000h,000h,003h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,056h,039h
 defb 	 000h,000h,000h,000h,0ADh,0ACh,000h,000h
 defb 	 0ADh,000h,000h,000h,004h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,0ADh,0ACh
 defb 	 056h,039h,0ADh,000h,000h,000h,003h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,003h
 defb 	 0ADh,0ACh,000h,000h,0ADh,000h,000h,000h
 defb 	 003h,0ADh,0ACh,056h,040h,0ADh,000h,000h
 defb 	 000h,003h,000h,000h,056h,040h,000h,000h
 defb 	 000h,000h,0ADh,0ACh,056h,040h,0ADh,000h
 defb 	 000h,000h,003h,0ADh,0ACh,056h,039h,0ADh
 defb 	 000h,000h,000h,003h,0ADh,0ACh,000h,000h
 defb 	 0ADh,000h,000h,000h,001h

PAT16:
 defw 	$077c
 defb  	 004h
 defb 	 073h,072h,000h,000h,073h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,073h,072h,039h,030h,073h,000h,000h
 defb 	 000h,073h,072h,039h,030h,073h,000h,000h
 defb 	 000h,003h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,039h,030h,000h,000h
 defb 	 000h,000h,073h,072h,000h,000h,073h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,073h,072h,039h,030h,073h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,073h,072h,000h,000h
 defb 	 073h,000h,000h,000h,073h,072h,039h,033h
 defb 	 073h,000h,000h,000h,003h,000h,000h,039h
 defb 	 033h,000h,000h,000h,000h,004h,073h,072h
 defb 	 039h,033h,073h,000h,000h,000h,073h,072h
 defb 	 039h,030h,073h,000h,000h,000h,073h,072h
 defb 	 000h,000h,073h,000h,000h,000h,004h,0C2h
 defb 	 0C1h,000h,000h,0C2h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 0C2h,0C1h,04Dh,030h,0C2h,000h,000h,000h
 defb 	 0C2h,0C1h,04Dh,030h,0C2h,000h,000h,000h
 defb 	 003h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,04Dh,030h,000h,000h,000h
 defb 	 000h,0C2h,0C1h,000h,000h,0C2h,000h,000h
 defb 	 000h,004h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,0C2h,0C1h,04Dh,030h,0C2h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,0C2h,0C1h,000h,000h
 defb 	 0C2h,000h,000h,000h,0C2h,0C1h,061h,033h
 defb 	 0C2h,000h,000h,000h,003h,000h,000h,061h
 defb 	 033h,000h,000h,000h,000h,004h,0C2h,0C1h
 defb 	 061h,033h,0C2h,000h,000h,000h,004h,0C2h
 defb 	 0C1h,04Dh,030h,0C2h,000h,000h,000h,0C2h
 defb 	 0C1h,000h,000h,0C2h,000h,000h,000h,004h
 defb 	 081h,080h,000h,000h,081h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,081h,080h,040h,033h,081h,000h,000h
 defb 	 000h,081h,080h,040h,033h,081h,000h,000h
 defb 	 000h,003h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,040h,033h,000h,000h
 defb 	 000h,000h,081h,080h,000h,000h,081h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,081h,080h,040h,033h,081h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,004h,081h,080h,000h,000h
 defb 	 081h,000h,000h,000h,081h,080h,056h,039h
 defb 	 081h,000h,000h,000h,003h,000h,000h,056h
 defb 	 039h,000h,000h,000h,000h,004h,081h,080h
 defb 	 056h,039h,081h,000h,000h,000h,081h,080h
 defb 	 040h,033h,081h,000h,000h,000h,081h,080h
 defb 	 000h,000h,081h,000h,000h,000h,004h,0ADh
 defb 	 0ACh,000h,000h,0ADh,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 0ADh,0ACh,056h,039h,0ADh,000h,000h,000h
 defb 	 0ADh,0ACh,056h,039h,0ADh,000h,000h,000h
 defb 	 003h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,003h,000h,000h,056h,039h,000h,000h
 defb 	 000h,000h,003h,0ADh,0ACh,000h,000h,0ADh
 defb 	 000h,000h,000h,003h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,003h,0ADh,0ACh,056h
 defb 	 039h,0ADh,000h,000h,000h,003h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,003h,0ADh
 defb 	 0ACh,000h,000h,0ADh,000h,000h,000h,003h
 defb 	 0ADh,0ACh,056h,040h,0ADh,000h,000h,000h
 defb 	 003h,000h,000h,056h,040h,000h,000h,000h
 defb 	 000h,003h,0ADh,0ACh,056h,040h,0ADh,000h
 defb 	 000h,000h,003h,0ADh,0ACh,056h,039h,0ADh
 defb 	 000h,000h,000h,003h,0ADh,0ACh,000h,000h
 defb 	 0ADh,000h,000h,000h,001h

PAT17:
 defw 	$077c
 defb  	 004h
 defb 	 073h,072h,000h,000h,073h,026h,026h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,073h,072h,039h,030h,073h,039h,039h
 defb 	 000h,073h,072h,039h,030h,073h,000h,000h
 defb 	 026h,003h,000h,000h,000h,000h,000h,030h
 defb 	 030h,000h,000h,000h,039h,030h,000h,000h
 defb 	 000h,039h,073h,072h,000h,000h,073h,02Bh
 defb 	 02Bh,000h,000h,000h,000h,000h,000h,026h
 defb 	 026h,030h,004h,073h,072h,039h,030h,073h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,02Bh,004h,073h,072h,000h,000h
 defb 	 073h,026h,026h,026h,073h,072h,039h,033h
 defb 	 073h,000h,000h,026h,003h,000h,000h,039h
 defb 	 033h,000h,02Bh,02Bh,000h,004h,073h,072h
 defb 	 039h,033h,073h,000h,000h,026h,073h,072h
 defb 	 039h,030h,073h,030h,030h,000h,073h,072h
 defb 	 000h,000h,073h,000h,000h,02Bh,004h,0C2h
 defb 	 0C1h,000h,000h,0C2h,02Bh,02Bh,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,030h,004h
 defb 	 0C2h,0C1h,04Dh,030h,0C2h,026h,026h,000h
 defb 	 0C2h,0C1h,04Dh,030h,0C2h,030h,030h,02Bh
 defb 	 003h,000h,000h,000h,000h,000h,030h,030h
 defb 	 000h,000h,000h,04Dh,030h,000h,030h,000h
 defb 	 026h,0C2h,0C1h,000h,000h,0C2h,04Dh,030h
 defb 	 030h,004h,000h,000h,000h,000h,000h,04Dh
 defb 	 030h,030h,004h,0C2h,0C1h,04Dh,030h,0C2h
 defb 	 04Dh,030h,030h,000h,000h,000h,000h,000h
 defb 	 04Dh,030h,000h,004h,0C2h,0C1h,000h,000h
 defb 	 0C2h,04Dh,030h,030h,0C2h,0C1h,061h,033h
 defb 	 0C2h,056h,033h,033h,003h,000h,000h,061h
 defb 	 033h,000h,056h,033h,033h,004h,0C2h,0C1h
 defb 	 061h,033h,0C2h,056h,033h,033h,004h,0C2h
 defb 	 0C1h,04Dh,030h,0C2h,04Dh,030h,030h,0C2h
 defb 	 0C1h,000h,000h,0C2h,04Dh,030h,000h,004h
 defb 	 081h,080h,000h,000h,081h,02Bh,02Bh,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 004h,081h,080h,040h,033h,081h,040h,040h
 defb 	 000h,081h,080h,040h,033h,081h,000h,000h
 defb 	 02Bh,003h,000h,000h,000h,000h,000h,033h
 defb 	 033h,000h,000h,000h,040h,033h,000h,000h
 defb 	 000h,040h,081h,080h,000h,000h,081h,030h
 defb 	 030h,000h,000h,000h,000h,000h,000h,02Bh
 defb 	 02Bh,033h,004h,081h,080h,040h,033h,081h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,030h,004h,081h,080h,000h,000h
 defb 	 081h,02Bh,02Bh,02Bh,081h,080h,056h,039h
 defb 	 081h,000h,000h,02Bh,003h,000h,000h,056h
 defb 	 039h,000h,030h,030h,000h,004h,081h,080h
 defb 	 056h,039h,081h,000h,000h,02Bh,081h,080h
 defb 	 040h,033h,081h,033h,033h,000h,081h,080h
 defb 	 000h,000h,081h,039h,039h,030h,004h,0ADh
 defb 	 0ACh,000h,000h,0ADh,039h,039h,000h,000h
 defb 	 000h,000h,000h,000h,039h,039h,033h,004h
 defb 	 0ADh,0ACh,056h,039h,0ADh,039h,039h,039h
 defb 	 0ADh,0ACh,056h,039h,0ADh,039h,000h,039h
 defb 	 003h,000h,000h,000h,000h,000h,000h,000h
 defb 	 039h,000h,000h,056h,039h,000h,000h,000h
 defb 	 000h,0ADh,0ACh,000h,000h,0ADh,039h,038h
 defb 	 039h,004h,000h,000h,000h,000h,000h,039h
 defb 	 038h,039h,004h,0ADh,0ACh,056h,039h,0ADh
 defb 	 030h,02Fh,030h,003h,000h,000h,000h,000h
 defb 	 000h,000h,000h,039h,003h,0ADh,0ACh,000h
 defb 	 000h,0ADh,030h,02Fh,030h,003h,0ADh,0ACh
 defb 	 056h,040h,0ADh,033h,032h,033h,003h,000h
 defb 	 000h,056h,040h,000h,000h,000h,030h,0ADh
 defb 	 0ACh,056h,040h,0ADh,033h,032h,033h,003h
 defb 	 0ADh,0ACh,056h,039h,0ADh,040h,03Fh,040h
 defb 	 003h,0ADh,0ACh,000h,000h,0ADh,000h,000h
 defb 	 033h,001h

PAT18:
 defw 	$077c
 defb  	 004h,073h,072h,000h
 defb 	 000h,073h,026h,026h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,073h,072h,000h
 defb 	 000h,073h,039h,039h,000h,073h,072h,000h
 defb 	 000h,073h,000h,000h,026h,004h,000h,000h
 defb 	 000h,000h,000h,030h,030h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,039h,073h,072h
 defb 	 000h,000h,073h,02Bh,02Bh,000h,000h,000h
 defb 	 000h,000h,000h,026h,026h,030h,004h,073h
 defb 	 072h,000h,000h,073h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,02Bh,073h
 defb 	 072h,000h,000h,073h,026h,026h,026h,073h
 defb 	 072h,000h,000h,073h,000h,000h,026h,004h
 defb 	 000h,000h,000h,000h,000h,02Bh,02Bh,000h
 defb 	 073h,072h,000h,000h,073h,000h,000h,026h
 defb 	 004h,073h,072h,000h,000h,073h,030h,030h
 defb 	 000h,073h,072h,000h,000h,073h,000h,000h
 defb 	 02Bh,004h,0C2h,0C1h,000h,000h,0C2h,02Bh
 defb 	 02Bh,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,030h,0C2h,0C1h,000h,000h,0C2h,026h
 defb 	 026h,000h,0C2h,0C1h,000h,000h,0C2h,030h
 defb 	 030h,02Bh,004h,000h,000h,000h,000h,000h
 defb 	 030h,030h,000h,000h,000h,000h,000h,000h
 defb 	 030h,000h,026h,0C2h,0C1h,000h,000h,0C2h
 defb 	 04Dh,030h,030h,000h,000h,000h,000h,000h
 defb 	 04Dh,030h,030h,004h,0C2h,0C1h,000h,000h
 defb 	 0C2h,04Dh,030h,030h,000h,000h,000h,000h
 defb 	 000h,04Dh,030h,000h,0C2h,0C1h,000h,000h
 defb 	 0C2h,04Dh,030h,030h,004h,0C2h,0C1h,000h
 defb 	 000h,0C2h,056h,033h,033h,004h,000h,000h
 defb 	 000h,000h,000h,056h,033h,033h,0C2h,0C1h
 defb 	 000h,000h,0C2h,056h,033h,033h,004h,0C2h
 defb 	 0C1h,000h,000h,0C2h,04Dh,030h,030h,0C2h
 defb 	 0C1h,000h,000h,0C2h,04Dh,030h,000h,004h
 defb 	 081h,080h,000h,000h,081h,02Bh,02Bh,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 081h,080h,000h,000h,081h,040h,040h,000h
 defb 	 081h,080h,000h,000h,081h,000h,000h,02Bh
 defb 	 004h,000h,000h,000h,000h,000h,033h,033h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 040h,081h,080h,000h,000h,081h,030h,030h
 defb 	 000h,000h,000h,000h,000h,000h,02Bh,02Bh
 defb 	 033h,004h,081h,080h,000h,000h,081h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,030h,081h,080h,000h,000h,081h,02Bh
 defb 	 02Bh,02Bh,004h,081h,080h,000h,000h,081h
 defb 	 000h,000h,02Bh,004h,000h,000h,000h,000h
 defb 	 000h,030h,030h,000h,004h,081h,080h,000h
 defb 	 000h,081h,000h,000h,02Bh,004h,081h,080h
 defb 	 000h,000h,081h,033h,033h,000h,004h,081h
 defb 	 080h,000h,000h,081h,039h,039h,030h,004h
 defb 	 0ADh,0ACh,000h,000h,0ADh,039h,039h,000h
 defb 	 000h,000h,000h,000h,000h,039h,039h,033h
 defb 	 0ADh,0ACh,000h,000h,0ADh,039h,039h,039h
 defb 	 0ADh,0ACh,000h,000h,0ADh,039h,000h,039h
 defb 	 004h,000h,000h,000h,000h,000h,000h,000h
 defb 	 039h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,003h,0ADh,0ACh,000h,000h,0ADh,039h
 defb 	 038h,039h,003h,000h,000h,000h,000h,000h
 defb 	 039h,038h,039h,003h,0ADh,0ACh,000h,000h
 defb 	 0ADh,030h,02Fh,030h,003h,000h,000h,000h
 defb 	 000h,000h,000h,000h,039h,003h,0ADh,0ACh
 defb 	 000h,000h,0ADh,030h,02Fh,030h,003h,0ADh
 defb 	 0ACh,000h,000h,0ADh,033h,032h,033h,003h
 defb 	 000h,000h,000h,000h,000h,000h,000h,030h
 defb 	 003h,0ADh,0ACh,000h,000h,0ADh,033h,032h
 defb 	 033h,003h,0ADh,0ACh,000h,000h,0ADh,040h
 defb 	 03Fh,040h,003h,0ADh,0ACh,000h,000h,0ADh
 defb 	 000h,000h,033h,001h

PAT19:
 defw 	$077c
 defb  	 004h,0E7h
 defb 	 0E7h,0E8h,0E8h,030h,02Fh,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,039h,038h,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,04Dh,04Ch,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,033h,032h,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,040h,03Fh,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,04Dh,04Ch,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,030h,02Fh,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,039h,038h,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,04Dh,04Ch,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,033h,032h,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,040h,03Fh,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,04Dh,04Ch,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,030h,02Fh,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,039h,038h,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,033h,032h,073h,072h,0E7h
 defb 	 0E7h,0E8h,0E8h,040h,03Fh,073h,072h,0CEh
 defb 	 0CEh,0CFh,0CFh,030h,02Fh,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,039h,038h,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,04Dh,04Ch,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,033h,032h,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,040h,03Fh,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,04Dh,04Ch,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,030h,02Fh,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,039h,038h,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,04Dh,04Ch,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,033h,032h,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,040h,03Fh,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,04Dh,04Ch,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,030h,02Fh,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,039h,038h,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,033h,032h,067h,066h,0CEh
 defb 	 0CEh,0CFh,0CFh,040h,03Fh,067h,066h,0C2h
 defb 	 0C2h,0C1h,0C1h,030h,02Fh,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,039h,038h,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,04Dh,04Ch,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,033h,032h,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,040h,03Fh,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,04Dh,04Ch,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,030h,02Fh,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,039h,038h,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,04Dh,04Ch,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,033h,032h,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,040h,03Fh,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,04Dh,04Ch,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,030h,02Fh,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,039h,038h,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,033h,032h,061h,060h,0C2h
 defb 	 0C2h,0C1h,0C1h,040h,03Fh,061h,060h,0ADh
 defb 	 0ADh,0ACh,0ACh,030h,02Fh,056h,055h,0ADh
 defb 	 0ADh,0ACh,0ACh,039h,038h,056h,055h,0ADh
 defb 	 0ADh,0ACh,0ACh,04Dh,04Ch,056h,055h,0ADh
 defb 	 0ADh,0ACh,0ACh,033h,032h,056h,055h,0ADh
 defb 	 0ADh,0ACh,0ACh,040h,03Fh,056h,055h,0ADh
 defb 	 0ADh,0ACh,0ACh,04Dh,04Ch,056h,055h,0ADh
 defb 	 0ADh,0ACh,0ACh,030h,02Fh,056h,055h,0ADh
 defb 	 0ADh,0ACh,0ACh,039h,038h,056h,055h,003h
 defb 	 0ADh,0ADh,0ACh,0ACh,04Dh,04Ch,056h,055h
 defb 	 003h,0ADh,0ADh,0ACh,0ACh,033h,032h,056h
 defb 	 055h,003h,0ADh,0ADh,0ACh,0ACh,040h,03Fh
 defb 	 056h,055h,003h,0ADh,0ADh,0ACh,0ACh,04Dh
 defb 	 04Ch,056h,055h,003h,0ADh,0ADh,0ACh,0ACh
 defb 	 030h,02Fh,056h,055h,003h,0ADh,0ADh,0ACh
 defb 	 0ACh,033h,032h,056h,055h,003h,0ADh,0ADh
 defb 	 0ACh,0ACh,039h,038h,056h,055h,003h,0ADh
 defb 	 0ADh,0ACh,0ACh,040h,03Fh,056h,055h,001h


PAT20:
 defw 	$077c
 defb  	 004h,0E7h,0E7h,0E8h,0E8h,030h
 defb 	 02Fh,073h,072h,0E7h,0E7h,0E8h,0E8h,039h
 defb 	 038h,073h,072h,0E7h,0E7h,0E8h,0E8h,04Dh
 defb 	 04Ch,073h,072h,0E7h,0E7h,0E8h,0E8h,033h
 defb 	 032h,073h,072h,0E7h,0E7h,0E8h,0E8h,040h
 defb 	 03Fh,073h,072h,0E7h,0E7h,0E8h,0E8h,04Dh
 defb 	 04Ch,073h,072h,0E7h,0E7h,0E8h,0E8h,030h
 defb 	 02Fh,073h,072h,0E7h,0E7h,0E8h,0E8h,039h
 defb 	 038h,073h,072h,0E7h,0E7h,0E8h,0E8h,04Dh
 defb 	 04Ch,073h,072h,0E7h,0E7h,0E8h,0E8h,033h
 defb 	 032h,073h,072h,0E7h,0E7h,0E8h,0E8h,040h
 defb 	 03Fh,073h,072h,0E7h,0E7h,0E8h,0E8h,04Dh
 defb 	 04Ch,073h,072h,0E7h,0E7h,0E8h,0E8h,030h
 defb 	 02Fh,073h,072h,0E7h,0E7h,0E8h,0E8h,039h
 defb 	 038h,073h,072h,0E7h,0E7h,0E8h,0E8h,033h
 defb 	 032h,073h,072h,0E7h,0E7h,0E8h,0E8h,040h
 defb 	 03Fh,073h,072h,0CEh,0CEh,0CFh,0CFh,030h
 defb 	 02Fh,067h,066h,0CEh,0CEh,0CFh,0CFh,039h
 defb 	 038h,067h,066h,0CEh,0CEh,0CFh,0CFh,04Dh
 defb 	 04Ch,067h,066h,0CEh,0CEh,0CFh,0CFh,033h
 defb 	 032h,067h,066h,0CEh,0CEh,0CFh,0CFh,040h
 defb 	 03Fh,067h,066h,0CEh,0CEh,0CFh,0CFh,04Dh
 defb 	 04Ch,067h,066h,0CEh,0CEh,0CFh,0CFh,030h
 defb 	 02Fh,067h,066h,0CEh,0CEh,0CFh,0CFh,039h
 defb 	 038h,067h,066h,0CEh,0CEh,0CFh,0CFh,04Dh
 defb 	 04Ch,067h,066h,0CEh,0CEh,0CFh,0CFh,033h
 defb 	 032h,067h,066h,0CEh,0CEh,0CFh,0CFh,040h
 defb 	 03Fh,067h,066h,0CEh,0CEh,0CFh,0CFh,04Dh
 defb 	 04Ch,067h,066h,0CEh,0CEh,0CFh,0CFh,030h
 defb 	 02Fh,067h,066h,0CEh,0CEh,0CFh,0CFh,039h
 defb 	 038h,067h,066h,0CEh,0CEh,0CFh,0CFh,033h
 defb 	 032h,067h,066h,0CEh,0CEh,0CFh,0CFh,040h
 defb 	 03Fh,067h,066h,0C2h,0C2h,0C1h,0C1h,030h
 defb 	 02Fh,061h,060h,0C2h,0C2h,0C1h,0C1h,039h
 defb 	 038h,061h,060h,0C2h,0C2h,0C1h,0C1h,04Dh
 defb 	 04Ch,061h,060h,0C2h,0C2h,0C1h,0C1h,033h
 defb 	 032h,061h,060h,0C2h,0C2h,0C1h,0C1h,040h
 defb 	 03Fh,061h,060h,0C2h,0C2h,0C1h,0C1h,04Dh
 defb 	 04Ch,061h,060h,0C2h,0C2h,0C1h,0C1h,030h
 defb 	 02Fh,061h,060h,0C2h,0C2h,0C1h,0C1h,039h
 defb 	 038h,061h,060h,0C2h,0C2h,0C1h,0C1h,04Dh
 defb 	 04Ch,061h,060h,0C2h,0C2h,0C1h,0C1h,033h
 defb 	 032h,061h,060h,0C2h,0C2h,0C1h,0C1h,040h
 defb 	 03Fh,061h,060h,0C2h,0C2h,0C1h,0C1h,04Dh
 defb 	 04Ch,061h,060h,0C2h,0C2h,0C1h,0C1h,030h
 defb 	 02Fh,061h,060h,0C2h,0C2h,0C1h,0C1h,039h
 defb 	 038h,061h,060h,0C2h,0C2h,0C1h,0C1h,033h
 defb 	 032h,061h,060h,0C2h,0C2h,0C1h,0C1h,040h
 defb 	 03Fh,061h,060h,002h,091h,091h,090h,090h
 defb 	 030h,02Fh,048h,047h,002h,091h,091h,090h
 defb 	 090h,039h,038h,048h,047h,091h,091h,090h
 defb 	 090h,04Dh,04Ch,048h,047h,003h,091h,091h
 defb 	 090h,090h,033h,032h,048h,047h,003h,091h
 defb 	 091h,090h,090h,040h,03Fh,048h,047h,091h
 defb 	 091h,090h,090h,04Dh,04Ch,048h,047h,004h
 defb 	 091h,091h,090h,090h,030h,02Fh,048h,047h
 defb 	 004h,091h,091h,090h,090h,039h,038h,048h
 defb 	 047h,091h,091h,090h,090h,04Dh,04Ch,048h
 defb 	 047h,005h,091h,091h,090h,090h,033h,032h
 defb 	 048h,047h,005h,091h,091h,090h,090h,040h
 defb 	 03Fh,048h,047h,091h,091h,090h,090h,04Dh
 defb 	 04Ch,048h,047h,006h,091h,091h,090h,090h
 defb 	 030h,02Fh,048h,047h,091h,091h,090h,090h
 defb 	 033h,032h,048h,047h,007h,091h,091h,090h
 defb 	 090h,039h,038h,048h,047h,007h,091h,091h
 defb 	 090h,090h,040h,03Fh,048h,047h,001h

PAT21:
 defw 	$077c
 defb  	004h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,039h,04Dh
 defb 	 000h,000h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,039h,04Dh
 defb 	 000h,000h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,039h,04Dh
 defb 	 000h,000h,040h,04Dh,03Fh,04Ch,000h,000h
 defb 	 000h,000h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,040h,04Dh
 defb 	 000h,000h,040h,04Dh,03Fh,04Ch,000h,000h
 defb 	 000h,000h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,040h,04Dh
 defb 	 000h,000h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,039h,04Dh
 defb 	 000h,000h,033h,04Dh,032h,04Ch,000h,000h
 defb 	 000h,000h,033h,04Dh,032h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,039h,04Dh
 defb 	 000h,000h,033h,04Dh,032h,04Ch,000h,000h
 defb 	 000h,000h,033h,04Dh,032h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,033h,04Dh
 defb 	 000h,000h,033h,04Dh,032h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,033h,04Dh
 defb 	 000h,000h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,033h,04Dh,032h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,039h,04Dh
 defb 	 000h,000h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 000h,000h,033h,04Dh,032h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,039h,04Dh
 defb 	 000h,000h,033h,04Dh,032h,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,033h,04Dh
 defb 	 000h,000h,061h,040h,060h,03Fh,000h,000h
 defb 	 000h,000h,061h,040h,060h,03Fh,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,033h,04Dh
 defb 	 000h,000h,061h,040h,060h,03Fh,000h,000h
 defb 	 000h,000h,061h,040h,060h,03Fh,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,061h,040h
 defb 	 000h,000h,061h,040h,060h,03Fh,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,061h,040h
 defb 	 000h,000h,061h,04Dh,060h,04Ch,000h,000h
 defb 	 000h,000h,061h,040h,060h,03Fh,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,061h,04Dh
 defb 	 000h,000h,061h,04Dh,060h,04Ch,000h,000h
 defb 	 000h,000h,061h,040h,060h,03Fh,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,061h,04Dh
 defb 	 000h,000h,061h,040h,060h,03Fh,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,061h,040h
 defb 	 000h,000h,003h,056h,039h,055h,038h,000h
 defb 	 000h,000h,000h,003h,056h,039h,055h,038h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 061h,040h,000h,000h,003h,056h,039h,055h
 defb 	 038h,000h,000h,000h,000h,003h,056h,039h
 defb 	 055h,038h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,056h,039h,000h,000h,003h,056h
 defb 	 039h,055h,038h,000h,000h,000h,000h,003h
 defb 	 000h,000h,000h,000h,056h,039h,000h,000h
 defb 	 056h,04Dh,055h,04Ch,000h,000h,000h,000h
 defb 	 003h,056h,039h,055h,038h,000h,000h,000h
 defb 	 000h,003h,000h,000h,000h,000h,056h,04Dh
 defb 	 000h,000h,056h,04Dh,055h,04Ch,000h,000h
 defb 	 000h,000h,003h,056h,039h,055h,038h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,056h
 defb 	 04Dh,000h,000h,003h,056h,039h,055h,038h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 056h,039h,000h,000h,001h

PAT22:
 defw 	$077c
 defb  	 004h
 defb 	 039h,04Dh,038h,04Ch,000h,000h,0E7h,0E8h
 defb 	 039h,04Dh,038h,04Ch,000h,000h,0E7h,0E8h
 defb 	 000h,000h,000h,000h,039h,04Dh,0E7h,0E8h
 defb 	 039h,04Dh,038h,04Ch,000h,000h,0E7h,0E8h
 defb 	 004h,039h,04Dh,038h,04Ch,000h,000h,0E7h
 defb 	 0E8h,000h,000h,000h,000h,039h,04Dh,0E7h
 defb 	 0E8h,039h,04Dh,038h,04Ch,000h,000h,0E7h
 defb 	 0E8h,000h,000h,000h,000h,039h,04Dh,0E7h
 defb 	 0E8h,004h,040h,04Dh,03Fh,04Ch,000h,000h
 defb 	 0E7h,0E8h,039h,04Dh,038h,04Ch,000h,000h
 defb 	 0E7h,0E8h,000h,000h,000h,000h,040h,04Dh
 defb 	 0E7h,0E8h,040h,04Dh,03Fh,04Ch,000h,000h
 defb 	 0E7h,0E8h,004h,039h,04Dh,038h,04Ch,000h
 defb 	 000h,0E7h,0E8h,000h,000h,000h,000h,040h
 defb 	 04Dh,0E7h,0E8h,004h,039h,04Dh,038h,04Ch
 defb 	 000h,000h,0E7h,0E8h,000h,000h,000h,000h
 defb 	 039h,04Dh,0E7h,0E8h,004h,033h,04Dh,032h
 defb 	 04Ch,000h,000h,0CEh,0CFh,033h,04Dh,032h
 defb 	 04Ch,000h,000h,0CEh,0CFh,000h,000h,000h
 defb 	 000h,039h,04Dh,0CEh,0CFh,033h,04Dh,032h
 defb 	 04Ch,000h,000h,0CEh,0CFh,004h,033h,04Dh
 defb 	 032h,04Ch,000h,000h,0CEh,0CFh,000h,000h
 defb 	 000h,000h,033h,04Dh,0CEh,0CFh,033h,04Dh
 defb 	 032h,04Ch,000h,000h,0CEh,0CFh,000h,000h
 defb 	 000h,000h,033h,04Dh,0CEh,0CFh,004h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,0CEh,0CFh,033h
 defb 	 04Dh,032h,04Ch,000h,000h,0CEh,0CFh,000h
 defb 	 000h,000h,000h,039h,04Dh,0CEh,0CFh,039h
 defb 	 04Dh,038h,04Ch,000h,000h,0CEh,0CFh,004h
 defb 	 033h,04Dh,032h,04Ch,000h,000h,0CEh,0CFh
 defb 	 004h,000h,000h,000h,000h,039h,04Dh,0CEh
 defb 	 0CFh,033h,04Dh,032h,04Ch,000h,000h,0CEh
 defb 	 0CFh,004h,000h,000h,000h,000h,033h,04Dh
 defb 	 0CEh,0CFh,004h,061h,040h,060h,03Fh,000h
 defb 	 000h,0C2h,0C1h,061h,040h,060h,03Fh,000h
 defb 	 000h,0C2h,0C1h,000h,000h,000h,000h,033h
 defb 	 04Dh,0C2h,0C1h,061h,040h,060h,03Fh,000h
 defb 	 000h,0C2h,0C1h,004h,061h,040h,060h,03Fh
 defb 	 000h,000h,0C2h,0C1h,000h,000h,000h,000h
 defb 	 061h,040h,0C2h,0C1h,061h,040h,060h,03Fh
 defb 	 000h,000h,0C2h,0C1h,000h,000h,000h,000h
 defb 	 061h,040h,0C2h,0C1h,004h,061h,04Dh,060h
 defb 	 04Ch,000h,000h,0C2h,0C1h,061h,040h,060h
 defb 	 03Fh,000h,000h,0C2h,0C1h,000h,000h,000h
 defb 	 000h,061h,04Dh,0C2h,0C1h,061h,04Dh,060h
 defb 	 04Ch,000h,000h,0C2h,0C1h,004h,061h,040h
 defb 	 060h,03Fh,000h,000h,0C2h,0C1h,000h,000h
 defb 	 000h,000h,061h,04Dh,0C2h,0C1h,004h,061h
 defb 	 040h,060h,03Fh,000h,000h,0C2h,0C1h,000h
 defb 	 000h,000h,000h,061h,040h,0C2h,0C1h,003h
 defb 	 048h,030h,047h,02Fh,000h,000h,091h,090h
 defb 	 048h,030h,047h,02Fh,000h,000h,091h,090h
 defb 	 000h,000h,000h,000h,061h,040h,091h,090h
 defb 	 003h,048h,030h,047h,02Fh,000h,000h,091h
 defb 	 090h,048h,030h,047h,02Fh,000h,000h,091h
 defb 	 090h,000h,000h,000h,000h,048h,030h,091h
 defb 	 090h,003h,048h,030h,047h,02Fh,000h,000h
 defb 	 091h,090h,000h,000h,000h,000h,048h,030h
 defb 	 091h,090h,048h,039h,047h,038h,000h,000h
 defb 	 091h,090h,003h,048h,030h,047h,02Fh,000h
 defb 	 000h,091h,090h,000h,000h,000h,000h,048h
 defb 	 039h,091h,090h,003h,048h,039h,047h,038h
 defb 	 000h,000h,091h,090h,003h,048h,030h,047h
 defb 	 02Fh,000h,000h,091h,090h,003h,000h,000h
 defb 	 000h,000h,048h,039h,091h,090h,003h,048h
 defb 	 030h,047h,02Fh,000h,000h,091h,090h,003h
 defb 	 000h,000h,000h,000h,048h,030h,091h,090h
 defb 	 001h

PAT23:
 defw 	$077c
 defb  	 004h,0E7h,0E8h,0E7h,0E8h
 defb 	 000h,000h,000h,000h,0E7h,0E8h,0E7h,0E8h
 defb 	 000h,000h,000h,000h,073h,072h,073h,072h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,004h,061h,04Dh,000h
 defb 	 000h,000h,000h,000h,000h,073h,072h,073h
 defb 	 072h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,061h,04Dh,000h
 defb 	 000h,000h,000h,000h,000h,004h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,061h,04Dh
 defb 	 000h,000h,000h,000h,000h,000h,081h,080h
 defb 	 081h,080h,000h,000h,000h,000h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,004h,061h
 defb 	 04Dh,000h,000h,000h,000h,000h,000h,073h
 defb 	 072h,073h,072h,000h,000h,000h,000h,004h
 defb 	 081h,080h,081h,080h,000h,000h,000h,000h
 defb 	 081h,000h,081h,000h,000h,000h,000h,000h
 defb 	 004h,0E7h,0E8h,0E7h,0E8h,000h,000h,000h
 defb 	 000h,0E7h,0E8h,0E7h,0E8h,000h,000h,000h
 defb 	 000h,073h,072h,073h,072h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,004h,061h,048h,000h,000h,000h,000h
 defb 	 000h,000h,073h,072h,073h,072h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,004h,061h,048h,000h,000h,000h
 defb 	 000h,000h,000h,004h,073h,072h,073h,072h
 defb 	 000h,000h,000h,000h,061h,048h,000h,000h
 defb 	 000h,000h,000h,000h,004h,081h,080h,081h
 defb 	 080h,000h,000h,000h,000h,073h,072h,073h
 defb 	 072h,000h,000h,000h,000h,004h,061h,048h
 defb 	 000h,000h,000h,000h,000h,000h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,061h,060h
 defb 	 061h,060h,000h,000h,000h,000h,061h,000h
 defb 	 061h,000h,000h,000h,000h,000h,004h,09Ah
 defb 	 099h,09Ah,099h,000h,000h,000h,000h,09Ah
 defb 	 099h,09Ah,099h,000h,000h,000h,000h,04Dh
 defb 	 04Ch,04Dh,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 03Dh,033h,000h,000h,000h,000h,000h,000h
 defb 	 04Dh,04Ch,04Dh,04Ch,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 03Dh,033h,000h,000h,000h,000h,000h,000h
 defb 	 004h,04Dh,04Ch,04Dh,04Ch,000h,000h,000h
 defb 	 000h,03Dh,033h,000h,000h,000h,000h,000h
 defb 	 000h,056h,055h,056h,055h,000h,000h,000h
 defb 	 000h,04Dh,04Ch,04Dh,04Ch,000h,000h,000h
 defb 	 000h,004h,03Dh,033h,000h,000h,000h,000h
 defb 	 000h,000h,056h,055h,056h,055h,000h,000h
 defb 	 000h,000h,004h,04Dh,04Ch,04Dh,04Ch,000h
 defb 	 000h,000h,000h,04Dh,000h,04Dh,000h,000h
 defb 	 000h,000h,000h,004h,091h,090h,091h,090h
 defb 	 000h,000h,000h,000h,091h,090h,091h,090h
 defb 	 000h,000h,000h,000h,048h,047h,048h,047h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,004h,039h,030h,000h
 defb 	 000h,000h,000h,000h,000h,048h,047h,048h
 defb 	 047h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,004h,039h,030h
 defb 	 000h,000h,000h,000h,000h,000h,004h,048h
 defb 	 047h,048h,047h,000h,000h,000h,000h,039h
 defb 	 030h,000h,000h,000h,000h,000h,000h,004h
 defb 	 04Dh,04Ch,04Dh,04Ch,000h,000h,000h,000h
 defb 	 048h,047h,048h,047h,000h,000h,000h,000h
 defb 	 004h,039h,030h,000h,000h,000h,000h,000h
 defb 	 000h,004h,048h,047h,048h,047h,000h,000h
 defb 	 000h,000h,04Dh,04Ch,04Dh,04Ch,000h,000h
 defb 	 000h,000h,039h,030h,000h,000h,000h,000h
 defb 	 000h,000h,001h

PAT24:
 defw 	$077c
 defb 	 004h,0E7h,0E8h
 defb 	 0E7h,0E8h,000h,000h,000h,000h,0E7h,0E8h
 defb 	 0E7h,0E8h,000h,000h,000h,000h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,003h,061h
 defb 	 04Dh,000h,000h,000h,000h,000h,000h,073h
 defb 	 072h,073h,072h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,061h
 defb 	 04Dh,000h,000h,000h,000h,000h,000h,004h
 defb 	 073h,072h,073h,072h,000h,000h,000h,000h
 defb 	 061h,04Dh,000h,000h,000h,000h,000h,000h
 defb 	 081h,080h,081h,080h,000h,000h,000h,000h
 defb 	 073h,072h,073h,072h,000h,000h,000h,000h
 defb 	 003h,061h,04Dh,000h,000h,000h,000h,000h
 defb 	 000h,073h,072h,073h,072h,000h,000h,000h
 defb 	 000h,004h,081h,080h,081h,080h,000h,000h
 defb 	 000h,000h,081h,000h,081h,000h,000h,000h
 defb 	 000h,000h,004h,0E7h,0E8h,0E7h,0E8h,000h
 defb 	 000h,000h,000h,0E7h,0E8h,0E7h,0E8h,000h
 defb 	 000h,000h,000h,073h,072h,073h,072h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,003h,061h,048h,000h,000h
 defb 	 000h,000h,000h,000h,073h,072h,073h,072h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,004h,061h,048h,000h
 defb 	 000h,000h,000h,000h,000h,004h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,061h,048h
 defb 	 000h,000h,000h,000h,000h,000h,004h,081h
 defb 	 080h,081h,080h,000h,000h,000h,000h,073h
 defb 	 072h,073h,072h,000h,000h,000h,000h,003h
 defb 	 061h,048h,000h,000h,000h,000h,000h,000h
 defb 	 073h,072h,073h,072h,000h,000h,000h,000h
 defb 	 061h,060h,061h,060h,000h,000h,000h,000h
 defb 	 061h,000h,061h,000h,000h,000h,000h,000h
 defb 	 004h,09Ah,099h,09Ah,099h,000h,000h,000h
 defb 	 000h,09Ah,099h,09Ah,099h,000h,000h,000h
 defb 	 000h,04Dh,04Ch,04Dh,04Ch,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,003h,03Dh,033h,000h,000h,000h,000h
 defb 	 000h,000h,04Dh,04Ch,04Dh,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,03Dh,033h,000h,000h,000h,000h
 defb 	 000h,000h,004h,04Dh,04Ch,04Dh,04Ch,000h
 defb 	 000h,000h,000h,03Dh,033h,000h,000h,000h
 defb 	 000h,000h,000h,056h,055h,056h,055h,000h
 defb 	 000h,000h,000h,04Dh,04Ch,04Dh,04Ch,000h
 defb 	 000h,000h,000h,003h,03Dh,033h,000h,000h
 defb 	 000h,000h,000h,000h,056h,055h,056h,055h
 defb 	 000h,000h,000h,000h,004h,04Dh,04Ch,04Dh
 defb 	 04Ch,000h,000h,000h,000h,04Dh,000h,04Dh
 defb 	 000h,000h,000h,000h,000h,004h,091h,090h
 defb 	 091h,090h,000h,000h,000h,000h,091h,090h
 defb 	 091h,090h,000h,000h,000h,000h,048h,047h
 defb 	 048h,047h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,003h,039h
 defb 	 030h,000h,000h,000h,000h,000h,000h,048h
 defb 	 047h,048h,047h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,004h
 defb 	 039h,030h,000h,000h,000h,000h,000h,000h
 defb 	 004h,048h,047h,048h,047h,000h,000h,000h
 defb 	 000h,003h,039h,030h,000h,000h,000h,000h
 defb 	 000h,000h,003h,04Dh,04Ch,04Dh,04Ch,000h
 defb 	 000h,000h,000h,003h,048h,047h,048h,047h
 defb 	 000h,000h,000h,000h,003h,039h,030h,000h
 defb 	 000h,000h,000h,000h,000h,048h,047h,048h
 defb 	 047h,000h,000h,000h,000h,003h,04Dh,04Ch
 defb 	 04Dh,04Ch,000h,000h,000h,000h,003h,039h
 defb 	 030h,000h,000h,000h,000h,000h,000h,001h


PAT25:
 defw 	$077c
 defb  	 004h,0E7h,0E8h,0E7h,0E8h,030h
 defb 	 030h,000h,000h,0E7h,0E8h,0E7h,0E8h,000h
 defb 	 000h,000h,000h,004h,073h,072h,073h,072h
 defb 	 039h,039h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,003h,061h,04Dh,000h
 defb 	 000h,04Dh,04Dh,000h,000h,004h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,033h,033h,000h,000h,004h,061h
 defb 	 04Dh,000h,000h,040h,040h,000h,000h,004h
 defb 	 073h,072h,073h,072h,000h,000h,000h,000h
 defb 	 061h,04Dh,000h,000h,04Dh,04Dh,000h,000h
 defb 	 081h,080h,081h,080h,000h,000h,000h,000h
 defb 	 073h,072h,073h,072h,030h,030h,000h,000h
 defb 	 003h,061h,04Dh,000h,000h,039h,039h,000h
 defb 	 000h,073h,072h,073h,072h,000h,000h,000h
 defb 	 000h,081h,080h,081h,080h,04Dh,04Dh,000h
 defb 	 000h,004h,081h,000h,081h,000h,000h,000h
 defb 	 000h,000h,004h,0E7h,0E8h,0E7h,0E8h,030h
 defb 	 030h,000h,000h,0E7h,0E8h,0E7h,0E8h,000h
 defb 	 000h,000h,000h,004h,073h,072h,073h,072h
 defb 	 039h,039h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,003h,061h,048h,000h
 defb 	 000h,048h,048h,000h,000h,004h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,04Dh,04Dh,000h,000h,061h,048h
 defb 	 000h,000h,048h,048h,000h,000h,004h,073h
 defb 	 072h,073h,072h,000h,000h,000h,000h,061h
 defb 	 048h,000h,000h,048h,048h,000h,000h,081h
 defb 	 080h,081h,080h,040h,040h,000h,000h,073h
 defb 	 072h,073h,072h,000h,000h,000h,000h,003h
 defb 	 061h,048h,000h,000h,039h,039h,000h,000h
 defb 	 073h,072h,073h,072h,000h,000h,000h,000h
 defb 	 061h,060h,061h,060h,030h,030h,000h,000h
 defb 	 061h,000h,061h,000h,000h,000h,000h,000h
 defb 	 004h,09Ah,099h,09Ah,099h,033h,033h,000h
 defb 	 000h,09Ah,099h,09Ah,099h,000h,000h,000h
 defb 	 000h,004h,04Dh,04Ch,04Dh,04Ch,03Dh,03Dh
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,003h,03Dh,033h,000h,000h,04Dh
 defb 	 04Dh,000h,000h,004h,04Dh,04Ch,04Dh,04Ch
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 033h,033h,000h,000h,004h,03Dh,033h,000h
 defb 	 000h,03Dh,03Dh,000h,000h,004h,04Dh,04Ch
 defb 	 04Dh,04Ch,000h,000h,000h,000h,03Dh,033h
 defb 	 000h,000h,04Dh,04Dh,000h,000h,056h,055h
 defb 	 056h,055h,000h,000h,000h,000h,04Dh,04Ch
 defb 	 04Dh,04Ch,03Dh,03Dh,000h,000h,003h,03Dh
 defb 	 033h,000h,000h,039h,039h,000h,000h,056h
 defb 	 055h,056h,055h,000h,000h,000h,000h,04Dh
 defb 	 04Ch,04Dh,04Ch,033h,033h,000h,000h,004h
 defb 	 04Dh,000h,04Dh,000h,000h,000h,000h,000h
 defb 	 004h,091h,090h,091h,090h,048h,048h,000h
 defb 	 000h,091h,090h,091h,090h,000h,000h,000h
 defb 	 000h,004h,048h,047h,048h,047h,04Dh,04Dh
 defb 	 000h,000h,004h,000h,000h,000h,000h,048h
 defb 	 048h,000h,000h,003h,039h,030h,000h,000h
 defb 	 000h,000h,000h,000h,004h,048h,047h,048h
 defb 	 047h,048h,048h,000h,000h,000h,000h,000h
 defb 	 000h,040h,040h,000h,000h,004h,039h,030h
 defb 	 000h,000h,039h,039h,000h,000h,003h,048h
 defb 	 047h,048h,047h,000h,000h,000h,000h,003h
 defb 	 039h,030h,000h,000h,039h,039h,000h,000h
 defb 	 003h,04Dh,04Ch,04Dh,04Ch,033h,033h,000h
 defb 	 000h,003h,048h,047h,048h,047h,030h,030h
 defb 	 000h,000h,004h,039h,030h,000h,000h,000h
 defb 	 000h,000h,000h,004h,048h,047h,048h,047h
 defb 	 02Bh,02Bh,000h,000h,003h,04Dh,04Ch,04Dh
 defb 	 04Ch,030h,030h,000h,000h,003h,039h,030h
 defb 	 000h,000h,033h,033h,000h,000h,001h

PAT26:
 defw 	$077c
 defb  	 004h,0E7h,0E8h,0E7h,0E8h,030h,030h
 defb 	 02Fh,000h,0E7h,0E8h,0E7h,0E8h,000h,000h
 defb 	 000h,033h,004h,073h,072h,073h,072h,039h
 defb 	 039h,038h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,030h,003h,061h,04Dh,04Dh,000h
 defb 	 04Dh,04Dh,04Ch,000h,004h,073h,072h,073h
 defb 	 072h,000h,000h,000h,039h,000h,000h,000h
 defb 	 000h,033h,033h,032h,000h,004h,061h,04Dh
 defb 	 04Dh,000h,040h,040h,03Fh,04Dh,004h,073h
 defb 	 072h,073h,072h,000h,000h,000h,000h,061h
 defb 	 04Dh,04Dh,000h,04Dh,04Dh,04Ch,033h,081h
 defb 	 080h,081h,080h,000h,000h,000h,040h,073h
 defb 	 072h,073h,072h,030h,030h,02Fh,000h,003h
 defb 	 061h,04Dh,04Dh,000h,039h,039h,038h,04Dh
 defb 	 073h,072h,073h,072h,000h,000h,000h,000h
 defb 	 081h,080h,081h,080h,04Dh,04Dh,04Ch,030h
 defb 	 004h,081h,000h,081h,000h,000h,000h,000h
 defb 	 039h,004h,0E7h,0E8h,0E7h,0E8h,030h,030h
 defb 	 02Fh,000h,0E7h,0E8h,0E7h,0E8h,000h,000h
 defb 	 000h,04Dh,004h,073h,072h,073h,072h,039h
 defb 	 039h,038h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,030h,003h,061h,048h,048h,000h
 defb 	 048h,048h,047h,000h,004h,073h,072h,073h
 defb 	 072h,000h,000h,000h,039h,000h,000h,000h
 defb 	 000h,04Dh,04Dh,04Ch,000h,061h,048h,048h
 defb 	 000h,048h,048h,047h,048h,004h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,061h,048h
 defb 	 048h,000h,048h,048h,047h,04Dh,081h,080h
 defb 	 081h,080h,040h,040h,03Fh,048h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,003h,061h
 defb 	 048h,048h,000h,039h,039h,038h,048h,073h
 defb 	 072h,073h,072h,000h,000h,000h,040h,061h
 defb 	 060h,061h,060h,030h,030h,02Fh,000h,061h
 defb 	 000h,061h,000h,000h,000h,000h,039h,004h
 defb 	 09Ah,099h,09Ah,099h,033h,033h,032h,000h
 defb 	 09Ah,099h,09Ah,099h,000h,000h,000h,030h
 defb 	 004h,04Dh,04Ch,04Dh,04Ch,03Dh,03Dh,03Ch
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 033h,003h,03Dh,033h,033h,000h,04Dh,04Dh
 defb 	 04Ch,000h,004h,04Dh,04Ch,04Dh,04Ch,000h
 defb 	 000h,000h,03Dh,000h,000h,000h,000h,033h
 defb 	 033h,032h,000h,004h,03Dh,033h,033h,000h
 defb 	 03Dh,03Dh,03Ch,04Dh,004h,04Dh,04Ch,04Dh
 defb 	 04Ch,000h,000h,000h,000h,03Dh,033h,033h
 defb 	 000h,04Dh,04Dh,04Ch,033h,056h,055h,056h
 defb 	 055h,000h,000h,000h,03Dh,04Dh,04Ch,04Dh
 defb 	 04Ch,03Dh,03Dh,03Ch,000h,003h,03Dh,033h
 defb 	 033h,000h,039h,039h,038h,04Dh,056h,055h
 defb 	 056h,055h,000h,000h,000h,000h,04Dh,04Ch
 defb 	 04Dh,04Ch,033h,033h,032h,03Dh,004h,04Dh
 defb 	 000h,04Dh,000h,000h,000h,000h,039h,004h
 defb 	 091h,090h,091h,090h,048h,048h,047h,000h
 defb 	 091h,090h,091h,090h,000h,000h,000h,033h
 defb 	 004h,048h,047h,048h,047h,04Dh,04Dh,04Ch
 defb 	 000h,004h,000h,000h,000h,000h,048h,048h
 defb 	 048h,048h,003h,039h,030h,030h,000h,000h
 defb 	 000h,000h,000h,004h,048h,047h,048h,047h
 defb 	 048h,048h,047h,04Dh,000h,000h,000h,000h
 defb 	 040h,040h,040h,048h,004h,039h,030h,030h
 defb 	 000h,039h,039h,038h,000h,003h,048h,047h
 defb 	 048h,047h,000h,000h,000h,048h,003h,039h
 defb 	 030h,030h,000h,039h,039h,038h,040h,003h
 defb 	 04Dh,04Ch,04Dh,04Ch,033h,033h,032h,039h
 defb 	 003h,048h,047h,048h,047h,030h,030h,02Fh
 defb 	 000h,004h,039h,030h,030h,000h,000h,000h
 defb 	 000h,039h,004h,048h,047h,048h,047h,02Bh
 defb 	 02Bh,02Ah,033h,003h,04Dh,04Ch,04Dh,04Ch
 defb 	 030h,030h,02Fh,030h,003h,039h,030h,030h
 defb 	 000h,033h,033h,032h,000h,001h

PAT27:
 defw 	$077c
 defb 	 004h,0E7h,0E8h,0E7h,0E8h,030h,030h,000h
 defb 	 000h,0E7h,0E8h,0E7h,0E8h,000h,000h,000h
 defb 	 000h,004h,073h,072h,073h,072h,039h,039h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,003h,061h,04Dh,000h,000h,04Dh
 defb 	 04Dh,000h,000h,004h,073h,072h,073h,072h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 033h,033h,000h,000h,004h,061h,04Dh,000h
 defb 	 000h,040h,040h,000h,000h,004h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,061h,04Dh
 defb 	 000h,000h,04Dh,04Dh,000h,000h,081h,080h
 defb 	 081h,080h,000h,000h,000h,000h,073h,072h
 defb 	 073h,072h,030h,030h,000h,000h,003h,061h
 defb 	 04Dh,000h,000h,039h,039h,000h,000h,073h
 defb 	 072h,073h,072h,000h,000h,000h,000h,081h
 defb 	 080h,081h,080h,04Dh,04Dh,000h,000h,004h
 defb 	 081h,000h,081h,000h,000h,000h,000h,000h
 defb 	 004h,0E7h,0E8h,0E7h,0E8h,030h,030h,000h
 defb 	 000h,0E7h,0E8h,0E7h,0E8h,000h,000h,000h
 defb 	 000h,004h,073h,072h,073h,072h,039h,039h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,003h,061h,048h,000h,000h,048h
 defb 	 048h,000h,000h,004h,073h,072h,073h,072h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 04Dh,04Dh,000h,000h,061h,048h,000h,000h
 defb 	 048h,048h,000h,000h,004h,073h,072h,073h
 defb 	 072h,000h,000h,000h,000h,061h,048h,000h
 defb 	 000h,048h,048h,000h,000h,081h,080h,081h
 defb 	 080h,040h,040h,000h,000h,073h,072h,073h
 defb 	 072h,000h,000h,000h,000h,003h,061h,048h
 defb 	 000h,000h,039h,039h,000h,000h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,061h,060h
 defb 	 061h,060h,030h,030h,000h,000h,061h,000h
 defb 	 061h,000h,000h,000h,000h,000h,004h,09Ah
 defb 	 099h,09Ah,099h,033h,033h,000h,000h,09Ah
 defb 	 099h,09Ah,099h,000h,000h,000h,000h,004h
 defb 	 04Dh,04Ch,04Dh,04Ch,03Dh,03Dh,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 003h,03Dh,033h,000h,000h,04Dh,04Dh,000h
 defb 	 000h,004h,04Dh,04Ch,04Dh,04Ch,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,033h,033h
 defb 	 000h,000h,004h,03Dh,033h,000h,000h,03Dh
 defb 	 03Dh,000h,000h,004h,04Dh,04Ch,04Dh,04Ch
 defb 	 000h,000h,000h,000h,03Dh,033h,000h,000h
 defb 	 04Dh,04Dh,000h,000h,056h,055h,056h,055h
 defb 	 000h,000h,000h,000h,04Dh,04Ch,04Dh,04Ch
 defb 	 03Dh,03Dh,000h,000h,003h,03Dh,033h,000h
 defb 	 000h,039h,039h,000h,000h,056h,055h,056h
 defb 	 055h,000h,000h,000h,000h,04Dh,04Ch,04Dh
 defb 	 04Ch,033h,033h,000h,000h,004h,04Dh,000h
 defb 	 04Dh,000h,000h,000h,000h,000h,003h,091h
 defb 	 090h,091h,090h,048h,048h,000h,000h,003h
 defb 	 091h,090h,091h,090h,000h,000h,000h,000h
 defb 	 003h,048h,047h,048h,047h,04Dh,04Dh,000h
 defb 	 000h,003h,000h,000h,000h,000h,048h,048h
 defb 	 000h,000h,003h,039h,030h,000h,000h,000h
 defb 	 000h,000h,000h,003h,048h,047h,048h,047h
 defb 	 048h,048h,000h,000h,003h,000h,000h,000h
 defb 	 000h,040h,040h,000h,000h,003h,039h,030h
 defb 	 000h,000h,039h,039h,000h,000h,003h,048h
 defb 	 047h,048h,047h,000h,000h,000h,000h,003h
 defb 	 039h,030h,000h,000h,039h,039h,000h,000h
 defb 	 003h,04Dh,04Ch,04Dh,04Ch,033h,033h,000h
 defb 	 000h,003h,048h,047h,048h,047h,030h,030h
 defb 	 000h,000h,003h,039h,030h,000h,000h,000h
 defb 	 000h,000h,000h,003h,048h,047h,048h,047h
 defb 	 02Bh,02Bh,000h,000h,003h,04Dh,04Ch,04Dh
 defb 	 04Ch,030h,030h,000h,000h,003h,039h,030h
 defb 	 000h,000h,033h,033h,000h,000h,001h

PAT28:
 defw 	$077c
 defb  	 004h,0E7h,0E8h,0E7h,0E8h,030h,030h
 defb 	 02Fh,000h,0E7h,0E8h,0E7h,0E8h,000h,000h
 defb 	 000h,033h,004h,073h,072h,073h,072h,039h
 defb 	 039h,038h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,030h,003h,061h,04Dh,04Dh,000h
 defb 	 04Dh,04Dh,04Ch,000h,004h,073h,072h,073h
 defb 	 072h,000h,000h,000h,039h,000h,000h,000h
 defb 	 000h,033h,033h,032h,000h,004h,061h,04Dh
 defb 	 04Dh,000h,040h,040h,03Fh,04Dh,004h,073h
 defb 	 072h,073h,072h,000h,000h,000h,000h,061h
 defb 	 04Dh,04Dh,000h,04Dh,04Dh,04Ch,033h,081h
 defb 	 080h,081h,080h,000h,000h,000h,040h,073h
 defb 	 072h,073h,072h,030h,030h,02Fh,000h,003h
 defb 	 061h,04Dh,04Dh,000h,039h,039h,038h,04Dh
 defb 	 073h,072h,073h,072h,000h,000h,000h,000h
 defb 	 081h,080h,081h,080h,04Dh,04Dh,04Ch,030h
 defb 	 004h,081h,000h,081h,000h,000h,000h,000h
 defb 	 039h,004h,0E7h,0E8h,0E7h,0E8h,030h,030h
 defb 	 02Fh,000h,0E7h,0E8h,0E7h,0E8h,000h,000h
 defb 	 000h,04Dh,004h,073h,072h,073h,072h,039h
 defb 	 039h,038h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,030h,003h,061h,048h,048h,000h
 defb 	 048h,048h,047h,000h,004h,073h,072h,073h
 defb 	 072h,000h,000h,000h,039h,000h,000h,000h
 defb 	 000h,04Dh,04Dh,04Ch,000h,061h,048h,048h
 defb 	 000h,048h,048h,047h,048h,004h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,061h,048h
 defb 	 048h,000h,048h,048h,047h,04Dh,081h,080h
 defb 	 081h,080h,040h,040h,03Fh,048h,073h,072h
 defb 	 073h,072h,000h,000h,000h,000h,003h,061h
 defb 	 048h,048h,000h,039h,039h,038h,048h,073h
 defb 	 072h,073h,072h,000h,000h,000h,040h,061h
 defb 	 060h,061h,060h,030h,030h,02Fh,000h,061h
 defb 	 000h,061h,000h,000h,000h,000h,039h,004h
 defb 	 09Ah,099h,09Ah,099h,033h,033h,032h,000h
 defb 	 09Ah,099h,09Ah,099h,000h,000h,000h,030h
 defb 	 004h,04Dh,04Ch,04Dh,04Ch,03Dh,03Dh,03Ch
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 033h,003h,03Dh,033h,033h,000h,04Dh,04Dh
 defb 	 04Ch,000h,004h,04Dh,04Ch,04Dh,04Ch,000h
 defb 	 000h,000h,03Dh,000h,000h,000h,000h,033h
 defb 	 033h,032h,000h,004h,03Dh,033h,033h,000h
 defb 	 03Dh,03Dh,03Ch,04Dh,004h,04Dh,04Ch,04Dh
 defb 	 04Ch,000h,000h,000h,000h,03Dh,033h,033h
 defb 	 000h,04Dh,04Dh,04Ch,033h,056h,055h,056h
 defb 	 055h,000h,000h,000h,03Dh,04Dh,04Ch,04Dh
 defb 	 04Ch,03Dh,03Dh,03Ch,000h,003h,03Dh,033h
 defb 	 033h,000h,039h,039h,038h,04Dh,056h,055h
 defb 	 056h,055h,000h,000h,000h,000h,04Dh,04Ch
 defb 	 04Dh,04Ch,033h,033h,032h,03Dh,004h,04Dh
 defb 	 000h,04Dh,000h,000h,000h,000h,039h,003h
 defb 	 091h,090h,091h,090h,048h,048h,047h,000h
 defb 	 003h,091h,090h,091h,090h,000h,000h,000h
 defb 	 033h,003h,048h,047h,048h,047h,04Dh,04Dh
 defb 	 04Ch,000h,003h,000h,000h,000h,000h,048h
 defb 	 048h,048h,048h,003h,039h,030h,030h,000h
 defb 	 000h,000h,000h,000h,003h,048h,047h,048h
 defb 	 047h,048h,048h,047h,04Dh,003h,000h,000h
 defb 	 000h,000h,040h,040h,040h,048h,003h,039h
 defb 	 030h,030h,000h,039h,039h,038h,000h,003h
 defb 	 048h,047h,048h,047h,000h,000h,000h,048h
 defb 	 003h,039h,030h,030h,000h,039h,039h,038h
 defb 	 040h,003h,04Dh,04Ch,04Dh,04Ch,033h,033h
 defb 	 032h,039h,003h,048h,047h,048h,047h,030h
 defb 	 030h,02Fh,000h,003h,039h,030h,030h,000h
 defb 	 000h,000h,000h,039h,003h,048h,047h,048h
 defb 	 047h,02Bh,02Bh,02Ah,033h,003h,04Dh,04Ch
 defb 	 04Dh,04Ch,030h,030h,02Fh,030h,003h,039h
 defb 	 030h,030h,000h,033h,033h,032h,000h,001h



PAT29:
 defw 	$077c
 defb  	 004h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,026h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,030h,000h,0E7h,0E7h,0E7h,073h,072h
 defb 	 039h,000h,000h,0E7h,0E7h,0E7h,073h,072h
 defb 	 000h,000h,000h,0E7h,0E7h,0E7h,073h,072h
 defb 	 000h,000h,000h,0E7h,0E7h,0E7h,073h,072h
 defb 	 000h,000h,000h,0E7h,0E7h,0E7h,073h,072h
 defb 	 000h,000h,000h,0E7h,0E7h,0E7h,073h,072h
 defb 	 000h,000h,000h,0E7h,0E7h,0E7h,073h,072h
 defb 	 000h,000h,000h,0E7h,0E7h,0E7h,073h,000h
 defb 	 000h,000h,000h,0E7h,0E7h,0E7h,000h,000h
 defb 	 000h,000h,000h,0E7h,0E7h,000h,000h,000h
 defb 	 000h,000h,000h,0E7h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,001h

PAT30:
 defw 	$077c
 defb  	 004h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,039h,04Dh,000h,000h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,039h,04Dh,000h,000h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,039h,04Dh,000h,000h,040h
 defb 	 04Dh,03Fh,04Ch,000h,000h,000h,000h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,040h,04Dh,000h,000h,040h
 defb 	 04Dh,03Fh,04Ch,000h,000h,000h,000h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,040h,04Dh,000h,000h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,039h,04Dh,000h,000h,033h
 defb 	 04Dh,032h,04Ch,000h,000h,000h,000h,033h
 defb 	 04Dh,032h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,039h,04Dh,000h,000h,033h
 defb 	 04Dh,032h,04Ch,000h,000h,000h,000h,033h
 defb 	 04Dh,032h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,033h,04Dh,000h,000h,033h
 defb 	 04Dh,032h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,033h,04Dh,000h,000h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,033h
 defb 	 04Dh,032h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,039h,04Dh,000h,000h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,000h,000h,033h
 defb 	 04Dh,032h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,039h,04Dh,000h,000h,033h
 defb 	 04Dh,032h,04Ch,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,033h,04Dh,000h,000h,061h
 defb 	 040h,060h,03Fh,000h,000h,000h,000h,061h
 defb 	 040h,060h,03Fh,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,033h,04Dh,000h,000h,061h
 defb 	 040h,060h,03Fh,000h,000h,000h,000h,061h
 defb 	 040h,060h,03Fh,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,061h,040h,000h,000h,061h
 defb 	 040h,060h,03Fh,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,061h,040h,000h,000h,061h
 defb 	 04Dh,060h,04Ch,000h,000h,000h,000h,061h
 defb 	 040h,060h,03Fh,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,061h,04Dh,000h,000h,061h
 defb 	 04Dh,060h,04Ch,000h,000h,000h,000h,061h
 defb 	 040h,060h,03Fh,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,061h,04Dh,000h,000h,061h
 defb 	 040h,060h,03Fh,000h,000h,000h,000h,000h
 defb 	 000h,000h,000h,061h,040h,000h,000h,003h
 defb 	 056h,039h,055h,038h,000h,000h,000h,000h
 defb 	 003h,056h,039h,055h,038h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,061h,040h,000h
 defb 	 000h,003h,056h,039h,055h,038h,000h,000h
 defb 	 000h,000h,003h,056h,039h,055h,038h,000h
 defb 	 000h,000h,000h,000h,000h,000h,000h,056h
 defb 	 039h,000h,000h,003h,056h,039h,055h,038h
 defb 	 000h,000h,000h,000h,003h,000h,000h,000h
 defb 	 000h,056h,039h,000h,000h,056h,04Dh,055h
 defb 	 04Ch,000h,000h,000h,000h,003h,056h,039h
 defb 	 055h,038h,000h,000h,000h,000h,003h,000h
 defb 	 000h,000h,000h,056h,04Dh,000h,000h,056h
 defb 	 04Dh,055h,04Ch,000h,000h,000h,000h,003h
 defb 	 056h,039h,055h,038h,000h,000h,000h,000h
 defb 	 000h,000h,000h,000h,056h,04Dh,000h,000h
 defb 	 003h,056h,033h,055h,032h,000h,000h,000h
 defb 	 000h,000h,000h,000h,000h,056h,033h,000h
 defb 	 000h,001h

PAT31:
 defw 	$077c
 defb  	 004h,039h,04Dh,038h
 defb 	 04Ch,000h,000h,0E7h,0E8h,039h,04Dh,038h
 defb 	 04Ch,000h,000h,0E7h,0E8h,000h,000h,000h
 defb 	 000h,039h,04Dh,0E7h,0E8h,039h,04Dh,038h
 defb 	 04Ch,000h,000h,0E7h,0E8h,004h,039h,04Dh
 defb 	 038h,04Ch,000h,000h,0E7h,0E8h,000h,000h
 defb 	 000h,000h,039h,04Dh,0E7h,0E8h,039h,04Dh
 defb 	 038h,04Ch,000h,000h,0E7h,0E8h,000h,000h
 defb 	 000h,000h,039h,04Dh,0E7h,0E8h,004h,040h
 defb 	 04Dh,03Fh,04Ch,000h,000h,0E7h,0E8h,039h
 defb 	 04Dh,038h,04Ch,000h,000h,0E7h,0E8h,000h
 defb 	 000h,000h,000h,040h,04Dh,0E7h,0E8h,040h
 defb 	 04Dh,03Fh,04Ch,000h,000h,0E7h,0E8h,004h
 defb 	 039h,04Dh,038h,04Ch,000h,000h,0E7h,0E8h
 defb 	 000h,000h,000h,000h,040h,04Dh,0E7h,0E8h
 defb 	 004h,039h,04Dh,038h,04Ch,000h,000h,0E7h
 defb 	 0E8h,000h,000h,000h,000h,039h,04Dh,0E7h
 defb 	 0E8h,004h,033h,04Dh,032h,04Ch,000h,000h
 defb 	 0CEh,0CFh,033h,04Dh,032h,04Ch,000h,000h
 defb 	 0CEh,0CFh,000h,000h,000h,000h,039h,04Dh
 defb 	 0CEh,0CFh,033h,04Dh,032h,04Ch,000h,000h
 defb 	 0CEh,0CFh,004h,033h,04Dh,032h,04Ch,000h
 defb 	 000h,0CEh,0CFh,000h,000h,000h,000h,033h
 defb 	 04Dh,0CEh,0CFh,033h,04Dh,032h,04Ch,000h
 defb 	 000h,0CEh,0CFh,000h,000h,000h,000h,033h
 defb 	 04Dh,0CEh,0CFh,004h,039h,04Dh,038h,04Ch
 defb 	 000h,000h,0CEh,0CFh,033h,04Dh,032h,04Ch
 defb 	 000h,000h,0CEh,0CFh,000h,000h,000h,000h
 defb 	 039h,04Dh,0CEh,0CFh,039h,04Dh,038h,04Ch
 defb 	 000h,000h,0CEh,0CFh,004h,033h,04Dh,032h
 defb 	 04Ch,000h,000h,0CEh,0CFh,004h,000h,000h
 defb 	 000h,000h,039h,04Dh,0CEh,0CFh,033h,04Dh
 defb 	 032h,04Ch,000h,000h,0CEh,0CFh,004h,000h
 defb 	 000h,000h,000h,033h,04Dh,0CEh,0CFh,004h
 defb 	 061h,040h,060h,03Fh,000h,000h,0C2h,0C1h
 defb 	 061h,040h,060h,03Fh,000h,000h,0C2h,0C1h
 defb 	 000h,000h,000h,000h,033h,04Dh,0C2h,0C1h
 defb 	 061h,040h,060h,03Fh,000h,000h,0C2h,0C1h
 defb 	 004h,061h,040h,060h,03Fh,000h,000h,0C2h
 defb 	 0C1h,000h,000h,000h,000h,061h,040h,0C2h
 defb 	 0C1h,061h,040h,060h,03Fh,000h,000h,0C2h
 defb 	 0C1h,000h,000h,000h,000h,061h,040h,0C2h
 defb 	 0C1h,004h,061h,04Dh,060h,04Ch,000h,000h
 defb 	 0C2h,0C1h,061h,040h,060h,03Fh,000h,000h
 defb 	 0C2h,0C1h,000h,000h,000h,000h,061h,04Dh
 defb 	 0C2h,0C1h,061h,04Dh,060h,04Ch,000h,000h
 defb 	 0C2h,0C1h,004h,061h,040h,060h,03Fh,000h
 defb 	 000h,0C2h,0C1h,000h,000h,000h,000h,061h
 defb 	 04Dh,0C2h,0C1h,004h,061h,040h,060h,03Fh
 defb 	 000h,000h,0C2h,0C1h,000h,000h,000h,000h
 defb 	 061h,040h,0C2h,0C1h,003h,048h,030h,047h
 defb 	 02Fh,000h,000h,091h,090h,048h,030h,047h
 defb 	 02Fh,000h,000h,091h,090h,000h,000h,000h
 defb 	 000h,061h,040h,091h,090h,003h,048h,030h
 defb 	 047h,02Fh,000h,000h,091h,090h,048h,030h
 defb 	 047h,02Fh,000h,000h,091h,090h,000h,000h
 defb 	 000h,000h,048h,030h,091h,090h,003h,048h
 defb 	 030h,047h,02Fh,000h,000h,091h,090h,000h
 defb 	 000h,000h,000h,048h,030h,091h,090h,048h
 defb 	 039h,047h,038h,000h,000h,091h,090h,003h
 defb 	 048h,030h,047h,02Fh,000h,000h,091h,090h
 defb 	 000h,000h,000h,000h,048h,039h,091h,090h
 defb 	 003h,048h,039h,047h,038h,000h,000h,091h
 defb 	 090h,003h,048h,030h,047h,02Fh,000h,000h
 defb 	 091h,090h,003h,000h,000h,000h,000h,048h
 defb 	 039h,091h,090h,003h,048h,033h,047h,032h
 defb 	 000h,000h,091h,090h,003h,000h,000h,000h
 defb 	 000h,048h,033h,091h,090h,001h


ENDSAMPLE:
 defw 	$077c
 defw	$C0DE
 defb 	 000h,000h,000h,000h,000h,000h,000h,000h






end:		dw	#C0DE

