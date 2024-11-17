; OCTODE XL M4.    INTERSTELLAR DRIFT.  MR BEEP.
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

	output "inter.obj"

		ORG	#8000

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

vol1234:	EQU 4
vol5678:	EQU 2
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



; INTERSTELLAR DRIFT.  Mr Beep.  For Octode XL.  M4.
;
; ============================================================
musicdata:
MLOOP:

 defw  PAT01	;    081E1h
 defw  PAT02	;    08401h
 defw  PAT03	;    08621h
 defw  PAT06	;    08c81h
 defw  PAT06	;    08c81h
 defw  PAT04	;    08841h
 defw  PAT05	;    08a61h
 defw  PAT07	;    08eA1h
 defw  PAT08	;    090BFh
 defw  PAT09	;    092E0h
 defw  PAT10	;    094E4h
 defw  PAT11	;    09704h
 defw  PAT13	;    09B4Dh
 defw  PAT11	;    09704h
 defw  PAT12	;    09928h
 defw  PAT14	;    09D72h
 defw  00000	;    00000h
 defw  MLOOP 


;	Pattern sequence in order
; defw   081E1h 1
; defw   08401h 2
; defw   08621h 3
; defw   08841h 4
; defw   08a61h 5
; defw   08c81h 6
; defw   08eA1h 7
; defw   090BFh 8
; defw   092E0h 9
; defw   094E4h 10
; defw   09704h 11
; defw   09928h 12
; defw   09B4Dh 13
; defw   09D72h 14
; defw   00000h 



PAT01:
 defw	$07F5
 defb 	008h,0CEh
 defb    0CEh,0CEh,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,0CEh
 defb    0CEh,0CEh,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,009h
 defb    0E7h,0E7h,0E7h,000h,000h,000h,000h,000h
 defb    0CEh,0CEh,0CEh,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    0E7h,0E7h,0E7h,000h,000h,000h,000h,000h
 defb    008h,0CEh,0CEh,0CEh,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,008h,0CEh,0CEh,0CEh,000h,000h,000h
 defb    000h,000h,0ADh,0ADh,0ADh,000h,000h,000h
 defb    000h,000h,009h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,0ADh,0ADh,0ADh,000h,000h
 defb    000h,000h,000h,0CEh,0CEh,0CEh,000h,000h
 defb    000h,000h,000h,0E7h,0E7h,0E7h,000h,000h
 defb    000h,000h,000h,008h,0CEh,0CEh,0CEh,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,0CEh,0CEh,0CEh,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,009h,0E7h,0E7h,0E7h
 defb    000h,000h,000h,000h,000h,0CEh,0CEh,0CEh
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,008h,0E7h,0E7h
 defb    0E7h,000h,000h,000h,000h,000h,008h,0CEh
 defb    0CEh,0CEh,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,008h
 defb    0CEh,0CEh,0CEh,000h,000h,000h,000h,000h
 defb    09Ah,09Ah,09Ah,000h,000h,000h,000h,000h
 defb    009h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,008h,0ADh,0ADh,0ADh,000h,000h,000h
 defb    000h,000h,09Ah,09Ah,09Ah,000h,000h,000h
 defb    000h,000h,008h,089h,089h,089h,000h,000h
 defb    000h,000h,000h,008h,0CEh,0CFh,0CEh,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,0CEh,0CFh,0CEh,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,009h,0E7h,0E8h,0E7h
 defb    000h,000h,000h,000h,000h,0CEh,0CFh,0CEh
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,0E7h,0E8h,0E7h
 defb    000h,000h,000h,000h,000h,008h,0CEh,0CFh
 defb    0CEh,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,008h,0CEh
 defb    0CFh,0CEh,000h,000h,000h,000h,000h,0ADh
 defb    0AEh,0ADh,000h,000h,000h,000h,000h,009h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    0ADh,0AEh,0ADh,000h,000h,000h,000h,000h
 defb    0CEh,0CFh,0CEh,000h,000h,000h,000h,000h
 defb    008h,0E7h,0E8h,0E7h,000h,000h,000h,000h
 defb    000h,008h,0CEh,0CFh,0CEh,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,0CEh,0CFh,0CEh,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,009h,0E7h,0E8h,0E7h,000h,000h
 defb    000h,000h,000h,0CEh,0CFh,0CEh,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,008h,0E7h,0E8h,0E7h,000h
 defb    000h,000h,000h,000h,008h,0CEh,0CFh,0CEh
 defb    000h,000h,000h,000h,000h,009h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,009h,0CEh
 defb    0CFh,0CEh,000h,000h,000h,000h,000h,009h
 defb    09Ah,09Bh,09Ah,000h,000h,000h,000h,000h
 defb    009h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,0ADh,0AEh,0ADh,000h,000h,000h,000h
 defb    000h,009h,09Ah,09Bh,09Ah,000h,000h,000h
 defb    000h,000h,009h,089h,08Ah,089h,000h,000h
 defb    000h,000h,000h,001h

PAT02:
 defw   007F5h
 defb   008h,0CEh
 defb    0CEh,0CEh,056h,057h,000h,000h,000h,000h
 defb    000h,000h,056h,057h,000h,000h,000h,0CEh
 defb    0CEh,0CEh,056h,057h,056h,000h,000h,000h
 defb    000h,000h,056h,057h,056h,000h,000h,009h
 defb    0E7h,0E7h,0E7h,056h,057h,056h,057h,000h
 defb    0CEh,0CEh,0CEh,056h,057h,056h,057h,000h
 defb    000h,000h,000h,056h,057h,056h,057h,000h
 defb    0E7h,0E7h,0E7h,056h,057h,056h,057h,000h
 defb    008h,0CEh,0CEh,0CEh,056h,057h,056h,057h
 defb    000h,000h,000h,000h,056h,057h,056h,057h
 defb    000h,008h,0CEh,0CEh,0CEh,056h,057h,056h
 defb    057h,000h,0ADh,0ADh,0ADh,056h,057h,056h
 defb    057h,000h,009h,000h,000h,000h,056h,057h
 defb    056h,057h,000h,0ADh,0ADh,0ADh,056h,057h
 defb    056h,057h,000h,0CEh,0CEh,0CEh,056h,057h
 defb    056h,057h,000h,0E7h,0E7h,0E7h,056h,057h
 defb    056h,057h,000h,008h,0CEh,0CEh,0CEh,05Bh
 defb    05Ch,056h,057h,000h,000h,000h,000h,05Bh
 defb    05Ch,056h,057h,000h,0CEh,0CEh,0CEh,05Bh
 defb    05Ch,05Bh,057h,000h,000h,000h,000h,05Bh
 defb    05Ch,05Bh,057h,000h,009h,0E7h,0E7h,0E7h
 defb    05Bh,05Ch,05Bh,05Ch,000h,0CEh,0CEh,0CEh
 defb    05Bh,05Ch,05Bh,05Ch,000h,000h,000h,000h
 defb    05Bh,05Ch,05Bh,05Ch,000h,008h,0E7h,0E7h
 defb    0E7h,05Bh,05Ch,05Bh,05Ch,000h,008h,0CEh
 defb    0CEh,0CEh,05Bh,05Ch,05Bh,05Ch,000h,000h
 defb    000h,000h,05Bh,05Ch,05Bh,05Ch,000h,008h
 defb    0CEh,0CEh,0CEh,05Bh,05Ch,05Bh,05Ch,000h
 defb    09Ah,09Ah,09Ah,05Bh,05Ch,05Bh,05Ch,000h
 defb    009h,000h,000h,000h,073h,074h,05Bh,05Ch
 defb    000h,008h,0ADh,0ADh,0ADh,073h,074h,05Bh
 defb    05Ch,000h,09Ah,09Ah,09Ah,073h,074h,073h
 defb    05Ch,000h,008h,089h,089h,089h,073h,074h
 defb    073h,05Ch,000h,008h,0CEh,0CFh,0CEh,067h
 defb    068h,073h,074h,000h,000h,000h,000h,067h
 defb    068h,073h,074h,000h,0CEh,0CFh,0CEh,067h
 defb    068h,067h,074h,000h,000h,000h,000h,067h
 defb    068h,067h,074h,000h,009h,0E7h,0E8h,0E7h
 defb    067h,068h,067h,068h,000h,0CEh,0CFh,0CEh
 defb    067h,068h,067h,068h,000h,000h,000h,000h
 defb    067h,068h,067h,068h,000h,0E7h,0E8h,0E7h
 defb    067h,068h,067h,068h,000h,008h,0CEh,0CFh
 defb    0CEh,067h,068h,067h,068h,000h,000h,000h
 defb    000h,067h,068h,067h,068h,000h,008h,0CEh
 defb    0CFh,0CEh,067h,068h,067h,068h,000h,0ADh
 defb    0AEh,0ADh,067h,068h,067h,068h,000h,009h
 defb    000h,000h,000h,067h,000h,067h,068h,000h
 defb    0ADh,0AEh,0ADh,000h,000h,067h,068h,000h
 defb    0CEh,0CFh,0CEh,000h,000h,067h,068h,000h
 defb    008h,0E7h,0E8h,0E7h,000h,000h,067h,000h
 defb    000h,008h,081h,082h,081h,05Bh,05Ch,000h
 defb    000h,000h,000h,000h,000h,05Bh,05Ch,000h
 defb    000h,000h,081h,082h,081h,05Bh,05Ch,05Bh
 defb    000h,000h,000h,000h,000h,05Bh,05Ch,05Bh
 defb    000h,000h,009h,089h,08Ah,089h,05Bh,05Ch
 defb    05Bh,05Ch,000h,081h,082h,081h,05Bh,05Ch
 defb    05Bh,05Ch,000h,000h,000h,000h,05Bh,05Ch
 defb    05Bh,05Ch,000h,008h,081h,082h,081h,05Bh
 defb    05Ch,05Bh,05Ch,000h,008h,073h,074h,073h
 defb    04Dh,04Eh,05Bh,05Ch,000h,009h,000h,000h
 defb    000h,04Dh,04Eh,05Bh,05Ch,000h,009h,089h
 defb    08Ah,089h,04Dh,04Eh,04Dh,05Ch,000h,009h
 defb    073h,074h,073h,04Dh,04Eh,04Dh,05Ch,000h
 defb    009h,000h,000h,000h,044h,045h,04Dh,04Eh
 defb    000h,089h,08Ah,089h,044h,045h,04Dh,04Eh
 defb    000h,009h,073h,074h,073h,044h,045h,044h
 defb    04Eh,000h,009h,089h,08Ah,089h,044h,045h
 defb    044h,04Eh,000h,001h

PAT03:
 defw	$07f5
 defb    008h,0CEh
 defb    0CEh,0CEh,056h,057h,000h,000h,000h,000h
 defb    000h,000h,056h,057h,000h,000h,000h,0CEh
 defb    0CEh,0CEh,056h,057h,056h,000h,000h,000h
 defb    000h,000h,056h,057h,056h,000h,000h,009h
 defb    0E7h,0E7h,0E7h,056h,057h,056h,057h,000h
 defb    0CEh,0CEh,0CEh,056h,057h,056h,057h,000h
 defb    000h,000h,000h,056h,057h,056h,057h,000h
 defb    008h,0E7h,0E7h,0E7h,056h,057h,056h,057h
 defb    000h,008h,0CEh,0CEh,0CEh,056h,057h,056h
 defb    057h,000h,000h,000h,000h,056h,057h,056h
 defb    057h,000h,008h,0CEh,0CEh,0CEh,056h,057h
 defb    056h,057h,000h,0ADh,0ADh,0ADh,056h,057h
 defb    056h,057h,000h,009h,000h,000h,000h,056h
 defb    057h,056h,057h,000h,0ADh,0ADh,0ADh,056h
 defb    057h,056h,057h,000h,0CEh,0CEh,0CEh,056h
 defb    057h,056h,057h,000h,0E7h,0E7h,0E7h,056h
 defb    057h,056h,057h,000h,008h,0CEh,0CEh,0CEh
 defb    05Bh,05Ch,056h,057h,000h,000h,000h,000h
 defb    05Bh,05Ch,056h,057h,000h,0CEh,0CEh,0CEh
 defb    05Bh,05Ch,05Bh,057h,000h,000h,000h,000h
 defb    05Bh,05Ch,05Bh,057h,000h,009h,0E7h,0E7h
 defb    0E7h,05Bh,05Ch,05Bh,05Ch,000h,0CEh,0CEh
 defb    0CEh,05Bh,05Ch,05Bh,05Ch,000h,000h,000h
 defb    000h,05Bh,05Ch,05Bh,05Ch,000h,0E7h,0E7h
 defb    0E7h,05Bh,05Ch,05Bh,05Ch,000h,008h,0CEh
 defb    0CEh,0CEh,05Bh,05Ch,05Bh,05Ch,000h,000h
 defb    000h,000h,05Bh,05Ch,05Bh,05Ch,000h,008h
 defb    0CEh,0CEh,0CEh,05Bh,05Ch,05Bh,05Ch,000h
 defb    09Ah,09Ah,09Ah,05Bh,05Ch,05Bh,05Ch,000h
 defb    009h,000h,000h,000h,073h,074h,05Bh,05Ch
 defb    000h,008h,0ADh,0ADh,0ADh,073h,074h,05Bh
 defb    05Ch,000h,09Ah,09Ah,09Ah,073h,074h,073h
 defb    05Ch,000h,008h,089h,089h,089h,073h,074h
 defb    073h,05Ch,000h,008h,0CEh,0CFh,0CEh,067h
 defb    068h,073h,074h,000h,000h,000h,000h,067h
 defb    068h,073h,074h,000h,0CEh,0CFh,0CEh,067h
 defb    068h,067h,074h,000h,000h,000h,000h,067h
 defb    068h,067h,074h,000h,009h,0E7h,0E8h,0E7h
 defb    067h,068h,067h,068h,000h,0CEh,0CFh,0CEh
 defb    067h,068h,067h,068h,000h,000h,000h,000h
 defb    067h,068h,067h,068h,000h,008h,0E7h,0E8h
 defb    0E7h,067h,068h,067h,068h,000h,008h,0CEh
 defb    0CFh,0CEh,067h,068h,067h,068h,000h,000h
 defb    000h,000h,067h,068h,067h,068h,000h,008h
 defb    0CEh,0CFh,0CEh,067h,068h,067h,068h,000h
 defb    0ADh,0AEh,0ADh,067h,068h,067h,068h,000h
 defb    009h,000h,000h,000h,067h,000h,067h,068h
 defb    000h,0ADh,0AEh,0ADh,000h,000h,067h,068h
 defb    000h,0CEh,0CFh,0CEh,000h,000h,067h,068h
 defb    000h,0E7h,0E8h,0E7h,000h,000h,067h,000h
 defb    000h,008h,081h,082h,081h,05Bh,05Ch,000h
 defb    000h,000h,000h,000h,000h,05Bh,05Ch,000h
 defb    000h,000h,081h,082h,081h,05Bh,05Ch,05Bh
 defb    000h,000h,000h,000h,000h,05Bh,05Ch,05Bh
 defb    000h,000h,009h,089h,08Ah,089h,05Bh,05Ch
 defb    05Bh,05Ch,000h,081h,082h,081h,05Bh,05Ch
 defb    05Bh,05Ch,000h,000h,000h,000h,05Bh,05Ch
 defb    05Bh,05Ch,000h,008h,081h,082h,081h,05Bh
 defb    05Ch,05Bh,05Ch,000h,008h,073h,074h,073h
 defb    056h,057h,05Bh,05Ch,000h,009h,000h,000h
 defb    000h,056h,057h,05Bh,05Ch,000h,009h,089h
 defb    08Ah,089h,056h,057h,056h,05Ch,000h,009h
 defb    073h,074h,073h,056h,057h,056h,05Ch,000h
 defb    009h,000h,000h,000h,073h,074h,056h,057h
 defb    000h,089h,08Ah,089h,073h,074h,056h,057h
 defb    000h,009h,073h,074h,073h,073h,074h,073h
 defb    057h,000h,009h,089h,08Ah,089h,073h,074h
 defb    073h,057h,000h,001h

PAT04:
 defw	$07f5
 defb      008h,0CEh
 defb    0CFh,0CEh,033h,034h,000h,044h,02Bh,000h
 defb    000h,000h,000h,000h,039h,044h,02Bh,0CEh
 defb    0CFh,0CEh,022h,023h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,033h,044h,02Bh,009h
 defb    0E7h,0E8h,0E7h,026h,027h,000h,044h,02Bh
 defb    0CEh,0CFh,0CEh,000h,000h,022h,000h,000h
 defb    000h,000h,000h,02Bh,02Ch,000h,044h,02Bh
 defb    0E7h,0E8h,0E7h,026h,027h,000h,044h,02Bh
 defb    008h,0CEh,0CFh,0CEh,000h,000h,02Bh,000h
 defb    000h,000h,000h,000h,026h,027h,000h,04Dh
 defb    02Dh,008h,0CEh,0CFh,0CEh,02Bh,02Ch,000h
 defb    04Dh,02Dh,0ADh,0AEh,0ADh,000h,000h,026h
 defb    000h,000h,009h,000h,000h,000h,02Dh,02Eh
 defb    000h,04Dh,02Dh,0ADh,0AEh,0ADh,000h,000h
 defb    02Bh,000h,000h,0CEh,0CFh,0CEh,039h,03Ah
 defb    000h,000h,000h,0E7h,0E8h,0E7h,044h,045h
 defb    000h,000h,000h,008h,089h,08Ah,089h,000h
 defb    000h,039h,039h,04Dh,000h,000h,000h,000h
 defb    000h,044h,039h,04Dh,089h,08Ah,089h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,039h,04Dh,009h,09Ah,09Bh,09Ah
 defb    000h,000h,000h,039h,04Dh,089h,08Ah,089h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,039h,04Dh,008h,09Ah,09Bh
 defb    09Ah,000h,000h,000h,039h,04Dh,008h,089h
 defb    08Ah,089h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,044h,05Bh,008h
 defb    089h,08Ah,089h,000h,000h,000h,044h,05Bh
 defb    073h,074h,073h,000h,000h,000h,000h,000h
 defb    009h,000h,000h,000h,000h,000h,000h,044h
 defb    05Bh,008h,073h,074h,073h,000h,000h,000h
 defb    000h,000h,089h,08Ah,089h,000h,000h,000h
 defb    000h,000h,008h,09Ah,09Bh,09Ah,000h,000h
 defb    000h,000h,000h,008h,081h,082h,081h,033h
 defb    034h,000h,033h,056h,000h,000h,000h,000h
 defb    000h,040h,033h,056h,081h,082h,081h,022h
 defb    023h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,033h,033h,056h,009h,089h,08Ah,089h
 defb    026h,027h,000h,033h,056h,081h,082h,081h
 defb    000h,000h,022h,000h,000h,000h,000h,000h
 defb    02Bh,02Ch,000h,033h,056h,089h,08Ah,089h
 defb    026h,027h,000h,033h,056h,008h,081h,082h
 defb    081h,000h,000h,02Bh,000h,000h,000h,000h
 defb    000h,026h,027h,000h,02Bh,04Dh,008h,089h
 defb    08Ah,089h,02Bh,02Ch,000h,02Bh,04Dh,081h
 defb    082h,081h,000h,000h,026h,000h,000h,009h
 defb    000h,000h,000h,02Dh,02Eh,000h,02Bh,04Dh
 defb    089h,08Ah,089h,000h,000h,02Bh,000h,000h
 defb    081h,082h,081h,02Bh,02Ch,000h,000h,000h
 defb    008h,073h,074h,073h,022h,023h,000h,000h
 defb    000h,008h,0ADh,0AEh,0ADh,000h,000h,02Bh
 defb    02Bh,022h,000h,000h,000h,000h,000h,022h
 defb    000h,000h,0ADh,0AEh,0ADh,000h,000h,000h
 defb    02Bh,022h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,009h,0B7h,0B8h,0B7h,000h,000h
 defb    000h,02Bh,022h,0ADh,0AEh,0ADh,026h,027h
 defb    000h,02Bh,022h,000h,000h,000h,02Bh,02Ch
 defb    000h,000h,000h,008h,0E7h,0E8h,0E7h,026h
 defb    027h,000h,039h,022h,008h,000h,000h,000h
 defb    000h,000h,026h,000h,000h,009h,0E7h,0E8h
 defb    0E7h,000h,000h,02Bh,039h,026h,009h,000h
 defb    000h,000h,000h,000h,026h,039h,026h,009h
 defb    073h,074h,073h,000h,000h,000h,000h,000h
 defb    009h,089h,08Ah,089h,000h,000h,000h,039h
 defb    026h,073h,074h,073h,000h,000h,000h,000h
 defb    000h,009h,089h,08Ah,089h,000h,000h,000h
 defb    039h,026h,009h,073h,074h,073h,000h,000h
 defb    000h,000h,000h,001h

PAT05:
 defw	$07f5
 defb      008h,0CEh
 defb    0CFh,0CEh,033h,034h,000h,044h,02Bh,000h
 defb    000h,000h,000h,000h,039h,044h,02Bh,0CEh
 defb    0CFh,0CEh,022h,023h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,033h,044h,02Bh,009h
 defb    0E7h,0E8h,0E7h,026h,027h,000h,044h,02Bh
 defb    0CEh,0CFh,0CEh,000h,000h,022h,000h,000h
 defb    000h,000h,000h,02Bh,02Ch,000h,044h,02Bh
 defb    008h,0E7h,0E8h,0E7h,026h,027h,000h,044h
 defb    02Bh,008h,0CEh,0CFh,0CEh,000h,000h,02Bh
 defb    000h,000h,000h,000h,000h,026h,027h,000h
 defb    04Dh,02Dh,008h,0CEh,0CFh,0CEh,02Bh,02Ch
 defb    000h,04Dh,02Dh,0ADh,0AEh,0ADh,000h,000h
 defb    026h,000h,000h,009h,000h,000h,000h,02Dh
 defb    02Eh,000h,04Dh,02Dh,0ADh,0AEh,0ADh,000h
 defb    000h,02Bh,000h,000h,0CEh,0CFh,0CEh,039h
 defb    03Ah,000h,000h,000h,0E7h,0E8h,0E7h,044h
 defb    045h,000h,000h,000h,008h,089h,08Ah,089h
 defb    000h,000h,039h,039h,04Dh,000h,000h,000h
 defb    000h,000h,044h,039h,04Dh,089h,08Ah,089h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,039h,04Dh,009h,09Ah,09Bh
 defb    09Ah,000h,000h,000h,039h,04Dh,089h,08Ah
 defb    089h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,039h,04Dh,09Ah,09Bh
 defb    09Ah,000h,000h,000h,039h,04Dh,008h,089h
 defb    08Ah,089h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,044h,05Bh,008h
 defb    089h,08Ah,089h,000h,000h,000h,044h,05Bh
 defb    073h,074h,073h,000h,000h,000h,000h,000h
 defb    009h,000h,000h,000h,000h,000h,000h,044h
 defb    05Bh,008h,073h,074h,073h,000h,000h,000h
 defb    000h,000h,089h,08Ah,089h,000h,000h,000h
 defb    000h,000h,008h,09Ah,09Bh,09Ah,000h,000h
 defb    000h,000h,000h,008h,081h,082h,081h,033h
 defb    034h,000h,033h,056h,000h,000h,000h,000h
 defb    000h,040h,033h,056h,081h,082h,081h,022h
 defb    023h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,033h,033h,056h,009h,089h,08Ah,089h
 defb    026h,027h,000h,033h,056h,081h,082h,081h
 defb    000h,000h,022h,000h,000h,000h,000h,000h
 defb    02Bh,02Ch,000h,033h,056h,008h,089h,08Ah
 defb    089h,026h,027h,000h,033h,056h,008h,081h
 defb    082h,081h,000h,000h,02Bh,000h,000h,000h
 defb    000h,000h,026h,027h,000h,02Bh,04Dh,008h
 defb    089h,08Ah,089h,02Bh,02Ch,000h,02Bh,04Dh
 defb    081h,082h,081h,000h,000h,026h,000h,000h
 defb    009h,000h,000h,000h,02Dh,02Eh,000h,02Bh
 defb    04Dh,089h,08Ah,089h,000h,000h,02Bh,000h
 defb    000h,081h,082h,081h,02Bh,02Ch,000h,000h
 defb    000h,073h,074h,073h,022h,023h,000h,000h
 defb    000h,008h,0ADh,0AEh,0ADh,000h,000h,02Bh
 defb    02Bh,022h,000h,000h,000h,000h,000h,022h
 defb    000h,000h,0ADh,0AEh,0ADh,000h,000h,000h
 defb    02Bh,022h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,009h,0B7h,0B8h,0B7h,000h,000h
 defb    000h,02Bh,022h,0ADh,0AEh,0ADh,020h,021h
 defb    000h,02Bh,022h,000h,000h,000h,022h,023h
 defb    000h,000h,000h,008h,0E7h,0E8h,0E7h,026h
 defb    027h,000h,039h,022h,008h,000h,000h,000h
 defb    000h,000h,020h,000h,000h,009h,0E7h,0E8h
 defb    0E7h,000h,000h,022h,039h,026h,009h,000h
 defb    000h,000h,000h,000h,026h,039h,026h,009h
 defb    073h,074h,073h,000h,000h,000h,000h,000h
 defb    009h,089h,08Ah,089h,000h,000h,000h,039h
 defb    026h,073h,074h,073h,000h,000h,000h,000h
 defb    000h,009h,089h,08Ah,089h,000h,000h,000h
 defb    039h,026h,009h,073h,074h,073h,000h,000h
 defb    000h,000h,000h,001h

PAT06:
 defw	$07f5
 defb	008h,0CEh
 defb    0CFh,0CEh,000h,045h,02Ch,022h,02Bh,000h
 defb    000h,000h,000h,045h,02Ch,022h,02Bh,0CEh
 defb    0CFh,0CEh,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,045h,02Ch,022h,02Bh,009h
 defb    0E7h,0E8h,0E7h,000h,045h,02Ch,022h,02Bh
 defb    0CEh,0CFh,0CEh,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,045h,02Ch,022h,02Bh
 defb    0E7h,0E8h,0E7h,000h,045h,02Ch,022h,02Bh
 defb    008h,0CEh,0CFh,0CEh,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,04Eh,02Eh,026h
 defb    02Dh,008h,0CEh,0CFh,0CEh,000h,04Eh,02Eh
 defb    026h,02Dh,0ADh,0AEh,0ADh,000h,000h,000h
 defb    000h,000h,009h,000h,000h,000h,000h,04Eh
 defb    02Eh,026h,02Dh,0ADh,0AEh,0ADh,000h,000h
 defb    000h,000h,000h,0CEh,0CFh,0CEh,000h,000h
 defb    000h,000h,000h,0E7h,0E8h,0E7h,000h,000h
 defb    000h,000h,000h,008h,089h,08Ah,089h,000h
 defb    01Dh,04Eh,039h,026h,000h,000h,000h,000h
 defb    01Dh,04Eh,039h,026h,089h,08Ah,089h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    01Dh,04Eh,039h,026h,009h,09Ah,09Bh,09Ah
 defb    000h,01Dh,04Eh,039h,026h,089h,08Ah,089h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,01Dh,04Eh,039h,026h,008h,09Ah,09Bh
 defb    09Ah,000h,01Dh,04Eh,039h,026h,008h,089h
 defb    08Ah,089h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,022h,05Bh,044h,02Dh,008h
 defb    089h,08Ah,089h,000h,022h,05Bh,044h,02Dh
 defb    073h,074h,073h,000h,000h,000h,000h,000h
 defb    009h,000h,000h,000h,000h,022h,05Bh,044h
 defb    02Dh,008h,073h,074h,073h,000h,000h,000h
 defb    000h,000h,089h,08Ah,089h,000h,000h,000h
 defb    000h,000h,008h,09Ah,09Bh,09Ah,000h,000h
 defb    000h,000h,000h,008h,081h,082h,081h,000h
 defb    01Ah,057h,033h,02Bh,000h,000h,000h,000h
 defb    01Ah,057h,033h,02Bh,081h,082h,081h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    01Ah,057h,033h,02Bh,009h,089h,08Ah,089h
 defb    000h,01Ah,057h,033h,02Bh,081h,082h,081h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,01Ah,057h,033h,02Bh,089h,08Ah,089h
 defb    000h,01Ah,057h,033h,02Bh,008h,081h,082h
 defb    081h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,057h,04Eh,02Bh,026h,008h,089h
 defb    08Ah,089h,000h,057h,04Eh,02Bh,026h,081h
 defb    082h,081h,000h,000h,000h,000h,000h,009h
 defb    000h,000h,000h,000h,057h,04Eh,02Bh,026h
 defb    089h,08Ah,089h,000h,000h,000h,000h,000h
 defb    081h,082h,081h,000h,000h,000h,000h,000h
 defb    008h,073h,074h,073h,000h,000h,000h,000h
 defb    000h,008h,0ADh,0AEh,0ADh,000h,057h,045h
 defb    02Bh,022h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,0ADh,0AEh,0ADh,000h,057h,045h
 defb    02Bh,022h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,009h,0B7h,0B8h,0B7h,000h,057h
 defb    045h,02Bh,022h,0ADh,0AEh,0ADh,000h,057h
 defb    045h,02Bh,022h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,008h,0E7h,0E8h,0E7h,000h
 defb    074h,045h,039h,022h,008h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,009h,0E7h,0E8h
 defb    0E7h,000h,074h,04Eh,039h,026h,009h,000h
 defb    000h,000h,000h,074h,04Eh,039h,026h,009h
 defb    073h,074h,073h,000h,000h,000h,000h,000h
 defb    009h,089h,08Ah,089h,000h,074h,04Eh,039h
 defb    026h,073h,074h,073h,000h,000h,000h,000h
 defb    000h,009h,089h,08Ah,089h,000h,074h,04Eh
 defb    039h,026h,009h,073h,074h,073h,000h,000h
 defb    000h,000h,000h,001h

PAT07:
 defw	$07f5
 defb	008h,0CEh
 defb    0CFh,0CEh,033h,034h,000h,022h,023h,000h
 defb    000h,000h,000h,000h,039h,026h,000h,0CEh
 defb    0CFh,0CEh,022h,023h,000h,033h,034h,000h
 defb    000h,000h,000h,000h,033h,022h,000h,009h
 defb    0E7h,0E8h,0E7h,026h,027h,000h,022h,023h
 defb    0CEh,0CFh,0CEh,000h,000h,022h,033h,000h
 defb    000h,000h,000h,02Bh,02Ch,000h,033h,034h
 defb    008h,0E7h,0E8h,0E7h,026h,027h,000h,022h
 defb    000h,0CEh,0CFh,0CEh,000h,000h,02Bh,022h
 defb    023h,000h,000h,000h,026h,027h,000h,033h
 defb    000h,008h,0CEh,0CFh,0CEh,02Bh,02Ch,000h
 defb    033h,034h,0ADh,0AEh,0ADh,000h,000h,026h
 defb    022h,000h,009h,000h,000h,000h,02Dh,02Eh
 defb    000h,022h,023h,0ADh,0AEh,0ADh,000h,000h
 defb    02Bh,033h,000h,0CEh,0CFh,0CEh,02Bh,02Ch
 defb    000h,033h,034h,0E7h,0E8h,0E7h,02Dh,02Eh
 defb    000h,022h,000h,008h,089h,08Ah,089h,000h
 defb    000h,02Bh,02Dh,02Eh,000h,000h,000h,000h
 defb    000h,02Dh,033h,000h,089h,08Ah,089h,000h
 defb    000h,000h,044h,045h,000h,000h,000h,000h
 defb    000h,000h,02Dh,000h,009h,09Ah,09Bh,09Ah
 defb    000h,000h,000h,02Dh,02Eh,089h,08Ah,089h
 defb    000h,000h,000h,044h,000h,000h,000h,000h
 defb    000h,000h,000h,044h,045h,008h,09Ah,09Bh
 defb    09Ah,000h,000h,000h,02Dh,000h,089h,08Ah
 defb    089h,000h,000h,000h,02Dh,02Eh,000h,000h
 defb    000h,000h,000h,000h,044h,000h,008h,089h
 defb    08Ah,089h,000h,000h,000h,044h,045h,073h
 defb    074h,073h,000h,000h,000h,02Dh,000h,009h
 defb    000h,000h,000h,000h,000h,000h,02Dh,02Eh
 defb    008h,073h,074h,073h,000h,000h,000h,044h
 defb    000h,089h,08Ah,089h,000h,000h,000h,044h
 defb    045h,09Ah,09Bh,09Ah,000h,000h,000h,02Dh
 defb    000h,008h,081h,082h,081h,033h,034h,000h
 defb    02Bh,02Ch,000h,000h,000h,000h,000h,040h
 defb    044h,000h,081h,082h,081h,022h,023h,000h
 defb    040h,041h,000h,000h,000h,000h,000h,033h
 defb    02Bh,000h,009h,089h,08Ah,089h,026h,027h
 defb    000h,02Bh,02Ch,081h,082h,081h,000h,000h
 defb    022h,040h,000h,000h,000h,000h,02Bh,02Ch
 defb    000h,040h,041h,008h,089h,08Ah,089h,026h
 defb    027h,000h,02Bh,000h,081h,082h,081h,000h
 defb    000h,02Bh,02Bh,02Ch,000h,000h,000h,026h
 defb    027h,000h,040h,000h,008h,089h,08Ah,089h
 defb    02Bh,02Ch,000h,040h,041h,081h,082h,081h
 defb    000h,000h,026h,02Bh,000h,009h,000h,000h
 defb    000h,02Dh,02Eh,000h,02Bh,02Ch,089h,08Ah
 defb    089h,000h,000h,02Bh,040h,000h,081h,082h
 defb    081h,02Bh,02Ch,000h,040h,041h,008h,073h
 defb    074h,073h,022h,023h,000h,02Bh,000h,008h
 defb    0ADh,0AEh,0ADh,000h,000h,02Bh,022h,023h
 defb    000h,000h,000h,000h,000h,022h,026h,000h
 defb    0ADh,0AEh,0ADh,000h,000h,000h,02Bh,02Ch
 defb    000h,000h,000h,000h,000h,000h,022h,000h
 defb    009h,0B7h,0B8h,0B7h,000h,000h,000h,022h
 defb    023h,0ADh,0AEh,0ADh,026h,027h,000h,02Bh
 defb    000h,000h,000h,000h,02Bh,02Ch,000h,02Bh
 defb    02Ch,008h,0E7h,0E8h,0E7h,026h,027h,000h
 defb    022h,000h,008h,000h,000h,000h,000h,000h
 defb    026h,026h,027h,009h,0E7h,0E8h,0E7h,000h
 defb    000h,02Bh,02Bh,000h,009h,000h,000h,000h
 defb    000h,000h,026h,039h,03Ah,009h,073h,074h
 defb    073h,000h,000h,000h,026h,000h,009h,089h
 defb    08Ah,089h,000h,000h,000h,026h,027h,073h
 defb    074h,073h,000h,000h,000h,039h,000h,009h
 defb    089h,08Ah,089h,000h,000h,000h,039h,03Ah
 defb    009h,073h,074h,073h,000h,000h,000h,026h
 defb    000h,001h

PAT08:
 defw	$07f5
 defb	008h,0CEh,0CFh,0CEh
 defb    033h,034h,000h,022h,023h,000h,000h,000h
 defb    000h,000h,039h,026h,000h,0CEh,0CFh,0CEh
 defb    022h,023h,000h,033h,034h,000h,000h,000h
 defb    000h,000h,033h,022h,000h,009h,0E7h,0E8h
 defb    0E7h,026h,027h,000h,022h,023h,0CEh,0CFh
 defb    0CEh,000h,000h,022h,033h,000h,000h,000h
 defb    000h,02Bh,02Ch,000h,033h,034h,008h,0E7h
 defb    0E8h,0E7h,026h,027h,000h,022h,000h,0CEh
 defb    0CFh,0CEh,000h,000h,02Bh,022h,023h,000h
 defb    000h,000h,026h,027h,000h,033h,000h,008h
 defb    0CEh,0CFh,0CEh,02Bh,02Ch,000h,033h,034h
 defb    0ADh,0AEh,0ADh,000h,000h,026h,022h,000h
 defb    009h,000h,000h,000h,02Dh,02Eh,000h,022h
 defb    023h,0ADh,0AEh,0ADh,000h,000h,02Bh,033h
 defb    000h,0CEh,0CFh,0CEh,02Bh,02Ch,000h,033h
 defb    034h,008h,0E7h,0E8h,0E7h,02Dh,02Eh,000h
 defb    022h,000h,008h,089h,08Ah,089h,000h,000h
 defb    02Bh,02Dh,02Eh,000h,000h,000h,000h,000h
 defb    02Dh,033h,000h,089h,08Ah,089h,000h,000h
 defb    000h,044h,045h,000h,000h,000h,000h,000h
 defb    000h,02Dh,000h,009h,09Ah,09Bh,09Ah,000h
 defb    000h,000h,02Dh,02Eh,089h,08Ah,089h,000h
 defb    000h,000h,044h,000h,000h,000h,000h,000h
 defb    000h,000h,044h,045h,008h,09Ah,09Bh,09Ah
 defb    000h,000h,000h,02Dh,000h,089h,08Ah,089h
 defb    000h,000h,000h,02Dh,02Eh,008h,000h,000h
 defb    000h,000h,000h,000h,044h,000h,008h,089h
 defb    08Ah,089h,000h,000h,000h,044h,045h,073h
 defb    074h,073h,000h,000h,000h,02Dh,000h,009h
 defb    000h,000h,000h,000h,000h,000h,02Dh,02Eh
 defb    008h,073h,074h,073h,000h,000h,000h,044h
 defb    000h,089h,08Ah,089h,000h,000h,000h,044h
 defb    045h,09Ah,09Bh,09Ah,000h,000h,000h,02Dh
 defb    000h,008h,081h,082h,081h,033h,034h,000h
 defb    02Bh,02Ch,000h,000h,000h,000h,000h,040h
 defb    044h,000h,081h,082h,081h,022h,023h,000h
 defb    040h,041h,000h,000h,000h,000h,000h,033h
 defb    02Bh,000h,009h,089h,08Ah,089h,026h,027h
 defb    000h,02Bh,02Ch,081h,082h,081h,000h,000h
 defb    022h,040h,000h,000h,000h,000h,02Bh,02Ch
 defb    000h,040h,041h,008h,089h,08Ah,089h,026h
 defb    027h,000h,02Bh,000h,081h,082h,081h,000h
 defb    000h,02Bh,02Bh,02Ch,000h,000h,000h,026h
 defb    027h,000h,040h,000h,008h,089h,08Ah,089h
 defb    02Bh,02Ch,000h,040h,041h,081h,082h,081h
 defb    000h,000h,026h,02Bh,000h,009h,000h,000h
 defb    000h,02Dh,02Eh,000h,02Bh,02Ch,089h,08Ah
 defb    089h,000h,000h,02Bh,040h,000h,081h,082h
 defb    081h,02Bh,02Ch,000h,040h,041h,008h,073h
 defb    074h,073h,022h,023h,000h,02Bh,000h,008h
 defb    0ADh,0AEh,0ADh,000h,000h,02Bh,022h,023h
 defb    000h,000h,000h,000h,000h,022h,026h,000h
 defb    008h,0ADh,0AEh,0ADh,000h,000h,000h,02Bh
 defb    02Ch,000h,000h,000h,000h,000h,000h,022h
 defb    000h,009h,0B7h,0B8h,0B7h,000h,000h,000h
 defb    022h,023h,008h,0ADh,0AEh,0ADh,020h,021h
 defb    000h,02Bh,000h,000h,000h,000h,022h,023h
 defb    000h,02Bh,02Ch,008h,0E7h,0E8h,0E7h,026h
 defb    027h,000h,022h,000h,000h,000h,000h,000h
 defb    000h,020h,026h,027h,009h,0E7h,0E8h,0E7h
 defb    000h,000h,022h,02Bh,000h,009h,000h,000h
 defb    000h,000h,000h,026h,039h,03Ah,009h,073h
 defb    074h,073h,000h,000h,000h,026h,000h,009h
 defb    089h,08Ah,089h,000h,000h,000h,026h,027h
 defb    073h,074h,073h,000h,000h,000h,039h,000h
 defb    009h,089h,08Ah,089h,000h,000h,000h,039h
 defb    03Ah,009h,073h,074h,073h,000h,000h,000h
 defb    026h,000h,001h

PAT09:
 defw	$07f5
 defb	008h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,000h
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,000h
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,000h
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,000h
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,000h
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,000h
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,09Ah,000h
 defb    000h,000h,000h,04Dh,040h,033h,081h,082h
 defb    000h,000h,000h,040h,033h,056h,081h,000h
 defb    000h,000h,000h,040h,033h,056h,081h,082h
 defb    000h,000h,000h,040h,033h,056h,081h,000h
 defb    000h,000h,000h,040h,033h,056h,081h,082h
 defb    000h,000h,000h,040h,033h,056h,081h,082h
 defb    000h,000h,000h,040h,033h,056h,081h,000h
 defb    000h,000h,000h,040h,033h,056h,081h,082h
 defb    000h,000h,000h,040h,033h,056h,081h,000h
 defb    000h,000h,000h,040h,033h,056h,081h,082h
 defb    000h,000h,000h,040h,033h,056h,081h,082h
 defb    000h,000h,000h,040h,033h,056h,081h,000h
 defb    000h,000h,000h,040h,033h,056h,081h,082h
 defb    000h,000h,000h,040h,033h,056h,081h,000h
 defb    000h,000h,000h,040h,033h,056h,073h,074h
 defb    000h,000h,000h,040h,033h,056h,073h,000h
 defb    000h,000h,000h,040h,033h,056h,0CEh,0CFh
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,000h
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,0CFh
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,000h
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,0CFh
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,0CFh
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,000h
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,0CFh
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,000h
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,0CFh
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,0CFh
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,000h
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,0CFh
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,000h
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,0CFh
 defb    000h,000h,000h,033h,02Bh,044h,0CEh,000h
 defb    000h,000h,000h,033h,02Bh,044h,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,067h,067h
 defb    000h,000h,000h,039h,02Dh,04Dh,067h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,001h

PAT10:
 defw	$07f5
 defb	008h,09Ah,09Bh,000h,000h,000h,04Dh
 defb    040h,033h,09Ah,000h,000h,000h,000h,04Dh
 defb    040h,033h,09Ah,09Bh,000h,000h,000h,04Dh
 defb    040h,033h,09Ah,000h,000h,000h,000h,04Dh
 defb    040h,033h,008h,09Ah,09Bh,000h,000h,000h
 defb    04Dh,040h,033h,09Ah,09Bh,000h,000h,000h
 defb    04Dh,040h,033h,09Ah,000h,000h,000h,000h
 defb    04Dh,040h,033h,09Ah,09Bh,000h,000h,000h
 defb    04Dh,040h,033h,008h,09Ah,000h,000h,000h
 defb    000h,04Dh,040h,033h,09Ah,09Bh,000h,000h
 defb    000h,04Dh,040h,033h,09Ah,09Bh,000h,000h
 defb    000h,04Dh,040h,033h,009h,09Ah,000h,000h
 defb    000h,000h,04Dh,040h,033h,008h,09Ah,09Bh
 defb    000h,000h,000h,04Dh,040h,033h,009h,09Ah
 defb    000h,000h,000h,000h,04Dh,040h,033h,008h
 defb    09Ah,09Bh,000h,000h,000h,04Dh,040h,033h
 defb    09Ah,000h,000h,000h,000h,04Dh,040h,033h
 defb    008h,081h,082h,000h,000h,000h,040h,033h
 defb    056h,081h,000h,000h,000h,000h,040h,033h
 defb    056h,081h,082h,000h,000h,000h,040h,033h
 defb    056h,081h,000h,000h,000h,000h,040h,033h
 defb    056h,008h,081h,082h,000h,000h,000h,040h
 defb    033h,056h,081h,082h,000h,000h,000h,040h
 defb    033h,056h,081h,000h,000h,000h,000h,040h
 defb    033h,056h,081h,082h,000h,000h,000h,040h
 defb    033h,056h,008h,081h,000h,000h,000h,000h
 defb    040h,033h,056h,081h,082h,000h,000h,000h
 defb    040h,033h,056h,081h,082h,000h,000h,000h
 defb    040h,033h,056h,009h,081h,000h,000h,000h
 defb    000h,040h,033h,056h,008h,081h,082h,000h
 defb    000h,000h,040h,033h,056h,009h,081h,000h
 defb    000h,000h,000h,040h,033h,056h,073h,074h
 defb    000h,000h,000h,040h,033h,056h,073h,000h
 defb    000h,000h,000h,040h,033h,056h,008h,0CEh
 defb    0CFh,000h,000h,000h,033h,02Bh,044h,0CEh
 defb    000h,000h,000h,000h,033h,02Bh,044h,0CEh
 defb    0CFh,000h,000h,000h,033h,02Bh,044h,0CEh
 defb    000h,000h,000h,000h,033h,02Bh,044h,008h
 defb    0CEh,0CFh,000h,000h,000h,033h,02Bh,044h
 defb    0CEh,0CFh,000h,000h,000h,033h,02Bh,044h
 defb    0CEh,000h,000h,000h,000h,033h,02Bh,044h
 defb    0CEh,0CFh,000h,000h,000h,033h,02Bh,044h
 defb    008h,0CEh,000h,000h,000h,000h,033h,02Bh
 defb    044h,0CEh,0CFh,000h,000h,000h,033h,02Bh
 defb    044h,0CEh,0CFh,000h,000h,000h,033h,02Bh
 defb    044h,009h,0CEh,000h,000h,000h,000h,033h
 defb    02Bh,044h,008h,0CEh,0CFh,000h,000h,000h
 defb    033h,02Bh,044h,009h,0CEh,000h,000h,000h
 defb    000h,033h,02Bh,044h,008h,0CEh,0CFh,000h
 defb    000h,000h,033h,02Bh,044h,0CEh,000h,000h
 defb    000h,000h,033h,02Bh,044h,008h,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,073h
 defb    000h,000h,000h,039h,02Dh,04Dh,073h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,008h,073h
 defb    073h,000h,000h,000h,039h,02Dh,04Dh,073h
 defb    073h,000h,000h,000h,039h,02Dh,04Dh,073h
 defb    000h,000h,000h,000h,039h,02Dh,04Dh,073h
 defb    073h,000h,000h,000h,039h,02Dh,04Dh,008h
 defb    073h,000h,000h,000h,000h,039h,02Dh,04Dh
 defb    073h,073h,000h,000h,000h,039h,02Dh,04Dh
 defb    009h,073h,073h,000h,000h,000h,039h,02Dh
 defb    04Dh,009h,073h,000h,000h,000h,000h,039h
 defb    02Dh,04Dh,008h,067h,067h,000h,000h,000h
 defb    039h,02Dh,04Dh,009h,067h,000h,000h,000h
 defb    000h,039h,02Dh,04Dh,009h,073h,073h,000h
 defb    000h,000h,039h,02Dh,04Dh,009h,073h,000h
 defb    000h,000h,000h,039h,02Dh,04Dh,001h

PAT11:
 defw	$07f5
 defb      008h,09Ah,09Bh,09Ah,040h,000h,04Dh
 defb    040h,040h,09Ah,000h,000h,040h,044h,000h
 defb    000h,040h,008h,09Ah,09Bh,09Ah,044h,044h
 defb    000h,000h,044h,09Ah,000h,000h,044h,040h
 defb    04Dh,040h,044h,009h,09Ah,09Bh,09Ah,040h
 defb    040h,000h,000h,040h,008h,09Ah,09Bh,09Ah
 defb    040h,044h,000h,000h,040h,09Ah,000h,000h
 defb    039h,044h,04Dh,040h,039h,008h,09Ah,09Bh
 defb    09Ah,033h,000h,000h,000h,033h,008h,09Ah
 defb    000h,000h,000h,039h,000h,000h,000h,09Ah
 defb    09Bh,09Ah,033h,000h,04Dh,040h,033h,09Ah
 defb    09Bh,09Ah,039h,000h,000h,000h,039h,09Ah
 defb    000h,000h,039h,033h,000h,000h,039h,009h
 defb    09Ah,09Bh,09Ah,033h,033h,04Dh,040h,033h
 defb    09Ah,000h,000h,033h,039h,000h,000h,033h
 defb    09Ah,09Bh,09Ah,02Dh,039h,04Dh,040h,02Dh
 defb    09Ah,000h,000h,02Dh,033h,000h,000h,02Dh
 defb    008h,081h,081h,081h,02Bh,033h,040h,033h
 defb    02Bh,081h,000h,000h,02Bh,02Dh,000h,000h
 defb    02Bh,008h,081h,081h,081h,02Bh,02Dh,000h
 defb    000h,02Bh,081h,000h,000h,02Bh,02Bh,040h
 defb    033h,000h,009h,081h,081h,081h,000h,02Bh
 defb    000h,000h,000h,008h,081h,081h,081h,000h
 defb    02Bh,000h,000h,000h,081h,000h,000h,000h
 defb    000h,040h,033h,000h,081h,081h,081h,026h
 defb    000h,000h,000h,026h,008h,081h,000h,000h
 defb    02Dh,000h,000h,000h,02Dh,081h,081h,081h
 defb    02Bh,000h,040h,033h,02Bh,081h,081h,081h
 defb    033h,026h,000h,000h,033h,081h,000h,000h
 defb    02Dh,02Dh,000h,000h,02Dh,009h,081h,081h
 defb    081h,039h,02Bh,040h,033h,039h,081h,000h
 defb    000h,033h,033h,000h,000h,033h,073h,074h
 defb    073h,040h,02Dh,040h,033h,040h,073h,000h
 defb    000h,039h,039h,000h,000h,039h,008h,0CEh
 defb    0CFh,0CEh,044h,033h,033h,02Bh,044h,0CEh
 defb    000h,000h,044h,040h,000h,000h,044h,008h
 defb    0CEh,0CFh,0CEh,067h,039h,000h,000h,067h
 defb    0CEh,000h,000h,067h,044h,033h,02Bh,067h
 defb    009h,0CEh,0CFh,0CEh,033h,044h,000h,000h
 defb    033h,008h,0CEh,0CFh,0CEh,033h,067h,000h
 defb    000h,033h,0CEh,000h,000h,067h,067h,033h
 defb    02Bh,067h,008h,0CEh,0CFh,0CEh,04Dh,000h
 defb    000h,000h,04Dh,008h,0CEh,000h,000h,000h
 defb    067h,000h,000h,000h,0CEh,0CFh,0CEh,04Dh
 defb    000h,033h,02Bh,04Dh,0CEh,0CFh,0CEh,056h
 defb    000h,000h,000h,056h,0CEh,000h,000h,056h
 defb    04Dh,000h,000h,056h,009h,0CEh,0CFh,0CEh
 defb    04Dh,000h,033h,02Bh,04Dh,0CEh,000h,000h
 defb    04Dh,056h,000h,000h,04Dh,0CEh,0CFh,0CEh
 defb    056h,056h,033h,02Bh,056h,008h,0CEh,000h
 defb    000h,056h,04Dh,000h,000h,056h,008h,073h
 defb    073h,073h,044h,04Dh,039h,02Dh,044h,073h
 defb    000h,000h,044h,056h,000h,000h,044h,008h
 defb    073h,073h,073h,067h,056h,000h,000h,067h
 defb    008h,073h,000h,000h,067h,044h,039h,02Dh
 defb    067h,009h,073h,073h,073h,033h,044h,000h
 defb    000h,033h,008h,073h,073h,073h,033h,067h
 defb    000h,000h,033h,008h,073h,000h,000h,067h
 defb    067h,039h,02Dh,067h,073h,073h,073h,04Dh
 defb    000h,000h,000h,04Dh,008h,073h,000h,000h
 defb    000h,067h,000h,000h,000h,073h,073h,073h
 defb    04Dh,000h,039h,02Dh,04Dh,009h,073h,073h
 defb    073h,056h,000h,000h,000h,056h,009h,073h
 defb    000h,000h,056h,04Dh,000h,000h,056h,067h
 defb    067h,067h,04Dh,000h,039h,02Bh,04Dh,009h
 defb    067h,000h,000h,04Dh,056h,000h,000h,04Dh
 defb    009h,073h,073h,073h,056h,056h,039h,02Dh
 defb    056h,009h,073h,000h,000h,056h,04Dh,000h
 defb    000h,056h,001h

PAT12:
 defw	$07f5
 defb	008h,09Ah,09Bh
 defb    09Ah,040h,000h,04Dh,040h,040h,09Ah,000h
 defb    000h,040h,044h,000h,000h,040h,008h,09Ah
 defb    09Bh,09Ah,044h,044h,000h,000h,044h,09Ah
 defb    000h,000h,044h,040h,04Dh,040h,044h,009h
 defb    09Ah,09Bh,09Ah,040h,040h,000h,000h,040h
 defb    008h,09Ah,09Bh,09Ah,040h,044h,000h,000h
 defb    040h,09Ah,000h,000h,039h,044h,04Dh,040h
 defb    039h,008h,09Ah,09Bh,09Ah,033h,000h,000h
 defb    000h,033h,008h,09Ah,000h,000h,000h,039h
 defb    000h,000h,000h,09Ah,09Bh,09Ah,033h,000h
 defb    04Dh,040h,033h,09Ah,09Bh,09Ah,039h,000h
 defb    000h,000h,039h,09Ah,000h,000h,039h,033h
 defb    000h,000h,039h,009h,09Ah,09Bh,09Ah,033h
 defb    033h,04Dh,040h,033h,09Ah,000h,000h,033h
 defb    039h,000h,000h,033h,09Ah,09Bh,09Ah,02Dh
 defb    039h,04Dh,040h,02Dh,008h,09Ah,000h,000h
 defb    02Dh,033h,000h,000h,02Dh,008h,081h,081h
 defb    081h,02Bh,033h,040h,033h,02Bh,081h,000h
 defb    000h,02Bh,02Dh,000h,000h,02Bh,008h,081h
 defb    081h,081h,02Bh,02Dh,000h,000h,02Bh,081h
 defb    000h,000h,02Bh,02Bh,040h,033h,000h,009h
 defb    081h,081h,081h,000h,02Bh,000h,000h,000h
 defb    008h,081h,081h,081h,000h,02Bh,000h,000h
 defb    000h,081h,000h,000h,000h,000h,040h,033h
 defb    000h,081h,081h,081h,026h,000h,000h,000h
 defb    026h,008h,081h,000h,000h,02Dh,000h,000h
 defb    000h,02Dh,081h,081h,081h,02Bh,000h,040h
 defb    033h,02Bh,081h,081h,081h,033h,026h,000h
 defb    000h,033h,081h,000h,000h,02Dh,02Dh,000h
 defb    000h,02Dh,009h,081h,081h,081h,039h,02Bh
 defb    040h,033h,039h,081h,000h,000h,033h,033h
 defb    000h,000h,033h,073h,074h,073h,040h,02Dh
 defb    040h,033h,040h,073h,000h,000h,039h,039h
 defb    000h,000h,039h,008h,0CEh,0CFh,0CEh,044h
 defb    033h,033h,02Bh,044h,0CEh,000h,000h,044h
 defb    040h,000h,000h,044h,008h,0CEh,0CFh,0CEh
 defb    044h,039h,000h,000h,044h,0CEh,000h,000h
 defb    044h,044h,033h,02Bh,000h,009h,0CEh,0CFh
 defb    0CEh,000h,044h,000h,000h,000h,008h,0CEh
 defb    0CFh,0CEh,000h,044h,000h,000h,000h,0CEh
 defb    000h,000h,04Dh,044h,033h,02Bh,04Dh,008h
 defb    0CEh,0CFh,0CEh,04Dh,000h,000h,000h,04Dh
 defb    008h,0CEh,000h,000h,04Dh,000h,000h,000h
 defb    04Dh,0CEh,0CFh,0CEh,04Dh,04Dh,033h,02Bh
 defb    000h,0CEh,0CFh,0CEh,000h,04Dh,000h,000h
 defb    000h,0CEh,000h,000h,000h,04Dh,000h,000h
 defb    000h,009h,0CEh,0CFh,0CEh,056h,04Dh,033h
 defb    02Bh,056h,0CEh,000h,000h,056h,000h,000h
 defb    000h,056h,0E7h,0E8h,0E7h,056h,000h,033h
 defb    02Bh,056h,008h,0E7h,000h,000h,056h,056h
 defb    000h,000h,056h,008h,0CEh,0CEh,0CEh,067h
 defb    056h,033h,02Bh,067h,0CEh,000h,000h,067h
 defb    056h,000h,000h,067h,008h,0CEh,0CEh,0CEh
 defb    067h,056h,000h,000h,067h,008h,0CEh,000h
 defb    000h,067h,067h,033h,02Bh,000h,009h,0CEh
 defb    0CEh,0CEh,000h,067h,000h,000h,000h,008h
 defb    0CEh,0CEh,0CEh,000h,067h,000h,000h,000h
 defb    008h,0CEh,000h,000h,000h,067h,033h,02Bh
 defb    000h,0CEh,0CEh,0CEh,000h,000h,000h,000h
 defb    000h,008h,0CEh,000h,000h,000h,000h,000h
 defb    000h,000h,0CEh,0CEh,0CEh,000h,000h,033h
 defb    02Dh,000h,009h,0CEh,0CEh,0CEh,000h,000h
 defb    000h,000h,000h,009h,0CEh,000h,000h,000h
 defb    000h,000h,000h,000h,0CEh,0CEh,0CEh,000h
 defb    000h,033h,02Bh,000h,009h,0CEh,000h,000h
 defb    000h,000h,000h,000h,000h,009h,0E7h,0E7h
 defb    0E7h,000h,000h,033h,02Dh,000h,009h,0E7h
 defb    000h,000h,000h,000h,000h,000h,000h,001h

PAT13:
 defw	$07f5
 defb    008h,09Ah,09Bh,09Ah,040h,000h
 defb    04Dh,040h,040h,09Ah,000h,000h,040h,044h
 defb    000h,000h,040h,008h,09Ah,09Bh,09Ah,044h
 defb    044h,000h,000h,044h,09Ah,000h,000h,044h
 defb    040h,04Dh,040h,044h,009h,09Ah,09Bh,09Ah
 defb    040h,040h,000h,000h,040h,008h,09Ah,09Bh
 defb    09Ah,040h,044h,000h,000h,040h,09Ah,000h
 defb    000h,039h,044h,04Dh,040h,039h,008h,09Ah
 defb    09Bh,09Ah,033h,000h,000h,000h,033h,008h
 defb    09Ah,000h,000h,000h,039h,000h,000h,000h
 defb    09Ah,09Bh,09Ah,033h,000h,04Dh,040h,033h
 defb    09Ah,09Bh,09Ah,039h,000h,000h,000h,039h
 defb    09Ah,000h,000h,039h,033h,000h,000h,039h
 defb    009h,09Ah,09Bh,09Ah,033h,033h,04Dh,040h
 defb    033h,09Ah,000h,000h,033h,039h,000h,000h
 defb    033h,09Ah,09Bh,09Ah,02Dh,039h,04Dh,040h
 defb    02Dh,008h,09Ah,000h,000h,02Dh,033h,000h
 defb    000h,02Dh,008h,081h,081h,081h,02Bh,033h
 defb    040h,033h,02Bh,081h,000h,000h,02Bh,02Dh
 defb    000h,000h,02Bh,008h,081h,081h,081h,02Bh
 defb    02Dh,000h,000h,02Bh,081h,000h,000h,02Bh
 defb    02Bh,040h,033h,000h,009h,081h,081h,081h
 defb    000h,02Bh,000h,000h,000h,008h,081h,081h
 defb    081h,000h,02Bh,000h,000h,000h,081h,000h
 defb    000h,000h,000h,040h,033h,000h,081h,081h
 defb    081h,026h,000h,000h,000h,026h,008h,081h
 defb    000h,000h,02Dh,000h,000h,000h,02Dh,081h
 defb    081h,081h,02Bh,000h,040h,033h,02Bh,081h
 defb    081h,081h,033h,026h,000h,000h,033h,081h
 defb    000h,000h,02Dh,02Dh,000h,000h,02Dh,009h
 defb    081h,081h,081h,039h,02Bh,040h,033h,039h
 defb    081h,000h,000h,033h,033h,000h,000h,033h
 defb    073h,074h,073h,040h,02Dh,040h,033h,040h
 defb    073h,000h,000h,039h,039h,000h,000h,039h
 defb    008h,0CEh,0CFh,0CEh,044h,033h,033h,02Bh
 defb    044h,0CEh,000h,000h,044h,040h,000h,000h
 defb    044h,008h,0CEh,0CFh,0CEh,044h,039h,000h
 defb    000h,044h,0CEh,000h,000h,044h,044h,033h
 defb    02Bh,000h,009h,0CEh,0CFh,0CEh,000h,044h
 defb    000h,000h,000h,008h,0CEh,0CFh,0CEh,000h
 defb    044h,000h,000h,000h,0CEh,000h,000h,040h
 defb    044h,033h,02Bh,040h,008h,0CEh,0CFh,0CEh
 defb    040h,000h,000h,000h,040h,008h,0CEh,000h
 defb    000h,040h,000h,000h,000h,040h,0CEh,0CFh
 defb    0CEh,040h,040h,033h,02Bh,000h,0CEh,0CFh
 defb    0CEh,000h,040h,000h,000h,000h,0CEh,000h
 defb    000h,000h,040h,000h,000h,000h,009h,0CEh
 defb    0CFh,0CEh,039h,040h,033h,02Bh,039h,0CEh
 defb    000h,000h,039h,000h,000h,000h,039h,0E7h
 defb    0E8h,0E7h,039h,000h,033h,02Bh,039h,008h
 defb    0E7h,000h,000h,039h,039h,000h,000h,039h
 defb    008h,0CEh,0CEh,0CEh,044h,039h,033h,02Bh
 defb    044h,0CEh,000h,000h,040h,039h,000h,000h
 defb    040h,008h,0CEh,0CEh,0CEh,044h,039h,000h
 defb    000h,044h,008h,0CEh,000h,000h,044h,044h
 defb    033h,02Bh,044h,009h,0CEh,0CEh,0CEh,044h
 defb    040h,000h,000h,044h,008h,0CEh,0CEh,0CEh
 defb    000h,044h,000h,000h,044h,008h,0CEh,000h
 defb    000h,000h,044h,033h,02Bh,000h,0CEh,0CEh
 defb    0CEh,000h,044h,000h,000h,000h,008h,0CEh
 defb    000h,000h,000h,044h,000h,000h,000h,0CEh
 defb    0CEh,0CEh,000h,000h,033h,02Dh,000h,009h
 defb    0CEh,0CEh,0CEh,000h,000h,000h,000h,000h
 defb    009h,0CEh,000h,000h,000h,000h,000h,000h
 defb    000h,0CEh,0CEh,0CEh,000h,000h,033h,02Bh
 defb    000h,009h,0CEh,000h,000h,000h,000h,000h
 defb    000h,000h,009h,0E7h,0E7h,0E7h,000h,000h
 defb    033h,02Dh,000h,009h,0E7h,000h,000h,000h
 defb    000h,000h,000h,000h,001h

PAT14:
 defw	$07f5
 defb    008h
 defb    0CEh,0CFh,0CEh,000h,000h,033h,022h,000h
 defb    0CEh,0CFh,000h,000h,000h,000h,000h,000h
 defb    008h,0CEh,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,033h,022h
 defb    000h,009h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,008h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    033h,022h,000h,008h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,008h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,033h,022h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,009h,000h,000h
 defb    000h,000h,000h,033h,026h,000h,000h,000h
 defb    000h,000h,000h,033h,026h,000h,000h,000h
 defb    000h,000h,000h,033h,022h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,000h,000h
 defb    000h,000h,000h,000h,000h,000h,001h

ENDSAMPLE:
 defw	$C0DE
 defb 	 000h,001h
 defw	$C0DE
 defb   000h,000h,000h




end:		dw	#C0DE



