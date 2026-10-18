; Continuolously looped two tunes, for a run-it-and-forget-it demo.
; Plonked together slowly and inefficiently by dave. June-July'25.
;
;
; Assemble with SJASMPLUS.	sjasmplus %1.asm
; Load the .VZ snapshot into VZEM emulator.
; Load the .WAV file into real hardware via CRUN and the cassette port.
;		
; ---------
;
; TUNE    -  NIGHT DANCER.  MR BEEP.
; PLAYER  -  OCTODE XL.  By Shiru & Introspec.
; 		assembled: 11268
; Octode beeper music engine by Shiru (shiru@mail.ru) 02'11
; Eight channels of tone, per-pattern tempo
; One channel of interrupting drums, no ROM data required
; Feel free to do whatever you want with the code, it is PD
;
; modified by introspec (zxintrospec@gmail.com) 10/2014-04/2015
; (data format changed for faster row transitions; sound
; generation is now using a crude variant of PWM.
;
;
;
; TUNE	  - LETS GO by Shiru.
; PLAYER  - SquatM by Shiru. 
; 		assembled: 13604
;SquatM by Shiru, 08'21 (minor mods for the original Squat 06'17)
;Squeeker like, just without the output value table 4 channels of tone with different duty cycle
;sample drums, non-interrupting customizeable noise percussion.
;Interrupting music data is all 16-bit words, first control then a few optional ones.
;Control word is PSSSSSSS DDDN4321, where P equ percussion,S equ speed, D equ drum, N equ noise mode, 4321 equ channels
;D triggers non-interruping sample drum
;P trigger
;if 1, channel 1 freq follows
;if 2, channel 2 freq follows
;if 3, channel 3 freq follows
;if 4, channel 4 freq follows
;if N, channel 4 mode follows, it is either $0000 (normal) or $04cb (noise)
;if P, percussion follows, LSB equ volume, MSB equ pitch
;
;
;
; Compression/Decompression.  ZX0 by einar-saukas.   
; See:	https://github.com/einar-saukas/ZX0


	output "LetsGo_NightDancer.vz"

origin equ  $7B00		
				
	org		origin - 24

	defb		'VZF1'					; file type ID
	defb		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,   0	; zero padded file name
	defb		$f1					; Binary or BASIC?
	defw		START					; start address
	
	org		origin
START:

begin:

; -------------------------------
; Intro stuff
; -------------------------------
; -------------------------------
; Menu stuff
; -------------------------------
cls:	call	$01c9			; VZ ROM CLS

	ld	hl, MSG1	
	call	$28a7		
	ld	hl, MSG3	
	call	$28a7	
	ld	hl, MSG4
	ld	de, 28672 + 32*15+26
	ld	bc, 6
	ldir








;  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
;##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
;  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
;##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
;  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  
;##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  




; OCTODE XL X4.    NIGHT DANCER.  MR BEEP.
;

;vol1234	EQU 3			; volume of channels 1-4
;vol5678	EQU 3			; volume of channels 5-8
; the sum of these volumes should not exceed ~16 (or ~8, if slowDecay=1)
;slowDecay	EQU 0
;octodeDrums	EQU 12500
;storeA		EQU 0





;==================================================================
;
;   Octode M2 by shiru & introspec
;
;==================================================================

play_nightdancer:

;vol1234: 	EQU 3
;vol5678:	EQU 3
;octodeDrums:	EQU 20000
;slowDecay:	EQU 0
;storeA:	EQU 0


vol1234:	EQU 2
vol5678:	EQU 1
octodeDrums:	EQU 12500
slowDecay:	EQU 0
storeA:		EQU 0


	di

	ld	hl, notplaying		; Display playing arrows
	ld	de, 28672+32*4
	ld	bc, 3
	ldir

	ld	hl, playing
	ld	de, 28672+32*3
	ld	bc, 3
	ldir
		
					; Decompress Night Dancer
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------
	ld	hl, song_nightdancer_compressed
	ld	de, song_nightdancer_uncompressed
	call	dzx0_standard




play:		di
		ld h,#ff		; H'=#FF is used by the sound core
		exx
		push hl
		push iy
		ld ix,vol1234*256+vol5678	; channel volumes
		ld iy,song_nightdancer
		jr readNotes_readOrder

stopPlayer:	pop iy
		pop hl
		exx

		jp 	play_letsgo


rowEnd:		
readNotes:
readNotes_ptr=$+1
		ld hl,0
		ld a,(hl)

	cp	$ff
	jr 	z,stopPlayer

		cp 10
		jp nc,readNotes_p0n
		or a
		jp z,readNotes_p0y
		dec a
		jr nz,readNotes_drum


readNotes_readOrder
	ld l,(iy)
	ld h,(iy+1)
	ld a,h
	or l
	jr nz,readNotes_setPattern
	ld l,(iy+2)
	ld h,(iy+3)
	push hl
	pop iy
	jr readNotes_readOrder
readNotes_setPattern
	ld c,(hl)
	inc hl
	ld b,(hl)

	inc hl
	ld (readNotes_ptr),hl
	ld (readNotes_speed),bc
	inc iy
	inc iy


	jr readNotes

readNotes_drum
	inc hl
	ld (readNotes_ptr),hl

		add a : add a
		add low (readNotes_drumTable-4) : ld l,a
		adc high (readNotes_drumTable-4) : sub l : ld h,a

		push de
		ld a,(hl) 
	ld 	(readNotes_drumPeriod),a 
	inc 	hl
	ld 	d,(hl) 
	inc 	hl
	ld 	e,(hl) 
	inc 	hl
	ld 	a,(hl) 
putanda1 equ $+0
putanda2 equ $+1
	and 	33
	ld 	c,a
	ld 	a,(hl) 
	add 	a 
putandb1 equ $+0
putandb2 equ $+1
	and 	33 

	ld 	(readNotes_noiseOn),a

	ld 	hl,#C0DE
readNotes_drumSeed:	EQU $-2

readNotes_drumLoop:	dec e 
	jr 	nz,readNotes_keepNoise
	ld 	a,(readNotes_noiseOn) 
putxora1 equ $+0
putxora2 equ $+1
	xor 32 
	ld (readNotes_noiseOn),a
readNotes_keepNoise:
		ld b,45
readNotes_drumPeriod:	EQU $-1

readNotes_noiseLoop:	ld a,c 



put6800a1 equ $+0
put6800a2 equ $+1
put6800a3 equ $+2
		ld	($6800),a 

		add hl,hl 
		 sbc a
		and #BD			; instead of #BD, one can use #3F or #D7
		xor l 
		 ld l,a


putandc1 equ $+0
putandc2 equ $+1
 		and 	32 
		or 0
readNotes_noiseOn:	EQU $-1
put6800b1 equ $+0
put6800b2 equ $+1
put6800b3 equ $+2
		ld	($6800),a

		djnz readNotes_noiseLoop

		ld a,c
putxorb1 equ $+0
putxorb2 equ $+1
		xor	32
		ld c,a

		dec d : jr nz,readNotes_drumLoop
		; (4+12 + 7 + (4+11 + 11+4+7+4+4 + 7+7+11+13)*B-5 + 4+7+4 + 4+12)*D = (83*B+49)*D

		ld (readNotes_drumSeed),hl	; 16

		xor a 
put6800c1 equ $+0
put6800c2 equ $+1
put6800c3 equ $+2
		ld	($6800),a

		pop de
		jp readNotes

readNotes_drumTable:
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

readNotes_noLoop:
readNotes_p0n	ld (soundLoop_frq0),a
	ld a,#84
readNotes_p0y	ld (soundLoop_off0),a

	ld c,#84		; #DD+#84 = ADD IXH

	inc hl
	ld a,(hl)
	or a
	jr z,readNotes_p1y
	ld (soundLoop_frq1),a
	ld a,c
readNotes_p1y	ld (soundLoop_off1),a
	inc hl
	ld a,(hl)
	or a
	jr z,readNotes_p2y
	ld (soundLoop_frq2),a
	ld a,c
readNotes_p2y	ld (soundLoop_off2),a
	inc hl
	ld a,(hl)
	or a
	jr z,readNotes_p3y
	ld (soundLoop_frq3),a
	ld a,c
readNotes_p3y	ld (soundLoop_off3),a
	inc hl
	inc c		; #DD+#85 = ADD IXL
	ld a,(hl)
	or a
	jr z,readNotes_p4y
	ld (soundLoop_frq4),a
	ld a,c
readNotes_p4y	ld (soundLoop_off4),a
	inc hl
	ld a,(hl)
	or a
	jr z,readNotes_p5y
	ld (soundLoop_frq5),a
	ld a,c
readNotes_p5y	ld (soundLoop_off5),a
	inc hl
	ld a,(hl)
	or a
	jr z,readNotes_p6y
	ld (soundLoop_frq6),a
	ld a,c
readNotes_p6y	ld (soundLoop_off6),a
	inc hl
	ld a,(hl)
	or a
	jr z,readNotes_p7y
	ld (soundLoop_frq7),a
	ld a,c
readNotes_p7y	ld (soundLoop_off7),a
	inc hl
	ld (readNotes_ptr),hl

readNotes_speed=$+1
		ld hl,0
readNotes_prevBC=$+1
		ld bc,0

	IF storeA=1
readNotes_prevVol=$+1
		ld a,0
	ELSE
		xor a
	ENDIF

soundLoop:	dec b 
	 	jr nz,soundLoop_lc0
soundLoop_frq0=$+1
		ld b,0
soundLoop_off0=$+1
		add ixh			; 4+7+7+8=26t
soundLoop_lb0	dec c 
	 	jr nz,soundLoop_lc1
soundLoop_frq1=$+1
		ld c,0
soundLoop_off1=$+1
		add ixh			; 4+7+7+8=26t
soundLoop_lb1	dec d 
	 	jr nz,soundLoop_lc2
soundLoop_frq2=$+1
		ld d,0
soundLoop_off2=$+1
		add ixh			; 4+7+7+8=26t
soundLoop_lb2	dec e 
	 	jr nz,soundLoop_lc3
soundLoop_frq3=$+1
		ld e,0
soundLoop_off3=$+1
		add ixh			; 4+7+7+8=26t
soundLoop_lb3	exx			; 4t
		dec b 
	 	jr nz,soundLoop_lc4
soundLoop_frq4=$+1
		ld b,0
soundLoop_off4=$+1
		add ixl			; 4+7+7+8=26t
soundLoop_lb4	dec c 
	 	jr nz,soundLoop_lc5
soundLoop_frq5=$+1
		ld c,0
soundLoop_off5=$+1
		add ixl			; 4+7+7+8=26t
soundLoop_lb5	dec d 
	 	jr nz,soundLoop_lc6
soundLoop_frq6=$+1
		ld d,0
soundLoop_off6=$+1
		add ixl			; 4+7+7+8=26t
soundLoop_lb6	dec e 
		 jr nz,soundLoop_lc7
soundLoop_frq7=$+1
		ld e,0
soundLoop_off7=$+1
		add ixl			; 4+7+7+8=26t
soundLoop_lb7	add h
		sbc h
		ld l,a
		sbc a
		nop
putandd1 equ $+0
putandd2 equ $+1
		and 	32
put6800d1 equ $+0
put6800d2 equ $+1
put6800d3 equ $+2
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
		ld (readNotes_prevVol),a
	ENDIF

		xor 	a
put6800e1 equ $+0
put6800e2 equ $+1
put6800e3 equ $+2
		ld	($6800),a

	
		ld (readNotes_prevBC),bc
		jp rowEnd

soundLoop_lc0		jp soundLoop_lb0			; 4+12+10=26t
soundLoop_lc1		jp soundLoop_lb1			; 4+12+10=26t
soundLoop_lc2		jp soundLoop_lb2			; 4+12+10=26t
soundLoop_lc3		jp soundLoop_lb3			; 4+12+10=26t
soundLoop_lc4		jp soundLoop_lb4			; 4+12+10=26t
soundLoop_lc5		jp soundLoop_lb5			; 4+12+10=26t
soundLoop_lc6		jp soundLoop_lb6			; 4+12+10=26t
soundLoop_lc7		jp soundLoop_lb7			; 4+12+10=26t

		;ENDMODULE




;1 A		10 j 		19 s
;2 B		11 k 		20 t
;3 C		12 l 		21 u
;4 D		13 m 		22 v
;5 E		14 n  		23 w
;6 F		15 o    	24 x
;7 G		16 p    	25 y
;8 h		17 q		26 z
;9 i		18 r
		

;-----------------------------------------------------			
; Inverse menu items.
; destination.
; Length, title.
;---------------------------------------------------			


;                12345678901234567890123456789012

MSG1: 	db	"## THE NIGHT DANCER / LETS GO ##"
	db	"      MISTER BEEP      SHIRU",0

MSG3:	db	$d
	db	$d, "    NIGHT DANCER"
	db	$d, "    LETS GO"
	db	$d,0 

MSG4:	db	111,"BUSHY",0

playing		db "-->",0		; cool arrow!
notplaying	db 96,96,96,0		; no cool arrow.
device		db 0			; 0=speaker.  1=Cassette Port.  2=Printer Port.



; ---------------------------------------------------------
; NIGHT DANCER. Mr Beep. 2015. octode XL engine.  (M2)
; ---------------------------------------------------------
song_nightdancer_compressed:
; night dancer zx0
;

   defb 78,62,168,94,172,65,170,253,15,123,174,152,176,248,144,34
   defb 241,182,245,184,181,178,5,187,33,189,58,191,83,193,112,195
   defb 142,197,154,199,83,193,200,203,56,170,201,209,254,213,180,200
   defb 185,83,230,205,243,207,251,209,255,211,247,6,194,195,0,0
   defb 235,252,194,152,240,151,97,98,206,224,192,69,125,240,137,163
   defb 164,124,192,137,81,82,34,81,0,65,72,146,218,219,150,218
   defb 36,109,110,161,109,85,246,240,37,122,123,242,192,36,61,62
   defb 137,61,0,83,216,241,192,17,180,1,181,251,4,226,120,48
   defb 49,74,54,88,146,32,33,158,48,190,34,36,37,74,32,0
   defb 165,49,255,207,190,248,222,124,82,59,40,41,206,232,188,36
   defb 53,226,174,48,49,74,40,95,122,164,81,255,190,122,230,190
   defb 132,32,248,207,188,165,49,251,204,163,222,222,120,87,229,239
   defb 118,222,241,240,221,242,206,160,36,54,55,165,40,250,20,109
   defb 239,208,190,126,157,190,104,36,2,151,55,255,207,190,222,225
   defb 124,72,239,43,44,206,188,160,40,215,22,137,61,62,41,43
   defb 126,157,240,255,232,190,126,155,190,104,40,119,28,45,61,135
   defb 244,115,26,116,242,247,223,240,3,221,205,238,116,245,198,117
   defb 62,121,190,1,245,223,52,182,245,223,112,116,121,190,21,211
   defb 134,247,238,220,220,48,104,61,190,87,229,207,188,117,253,214
   defb 170,53,48,156,125,190,31,207,241,239,54,247,239,240,1,245
   defb 239,49,140,139,194,97,181,254,226,141,241,54,0,38,97,98
   defb 97,137,32,32,163,0,82,140,166,48,138,194,36,10,194,90
   defb 97,40,32,40,97,161,48,165,194,254,253,223,190,43,64,191
   defb 254,190,168,124,32,43,72,185,254,124,238,241,4,188,142,81
   defb 40,254,255,188,77,214,241,140,143,163,72,139,170,189,163,163
   defb 167,40,91,143,81,138,122,81,164,81,255,190,211,154,190,32
   defb 74,81,63,141,190,252,143,124,249,207,190,253,223,190,60,58
   defb 184,109,125,147,54,54,191,241,4,188,238,209,204,186,217,244
   defb 155,218,219,218,235,207,121,218,223,241,244,46,161,109,22,53
   defb 34,143,109,72,105,36,162,218,130,40,150,218,138,109,36,10
   defb 109,40,54,105,218,127,253,223,138,190,64,54,241,227,4,188
   defb 127,110,56,255,123,56,179,172,232,233,186,255,81,43,43,219
   defb 188,245,75,241,40,140,173,122,97,61,106,223,122,169,122,43
   defb 155,61,62,61,234,211,240,0,53,42,140,48,104,122,160,43
   defb 165,122,162,61,135,48,221,253,242,182,61,23,45,30,30,132
   defb 240,222,106,145,36,183,72,240,104,61,237,152,141,238,33,198
   defb 80,215,74,87,77,198,77,36,66,104,61,222,7,124,115,141
   defb 78,198,136,64,150,32,32,33,0,32,20,162,81,37,40,40
   defb 136,40,0,2,130,0,141,64,215,243,216,116,232,198,61,221
   defb 175,122,8,43,77,141,176,42,198,72,34,36,36,67,99,178
   defb 172,190,81,244,248,194,198,136,86,144,43,43,163,97,222,183
   defb 240,187,109,218,101,106,174,109,222,211,198,162,129,36,64,64
   defb 49,152,174,190,48,98,229,240,113,255,174,233,224,161,61,185
   defb 9,190,126,249,190,126,224,247,4,188,143,122,231,194,122,226
   defb 109,157,110,54,63,241,249,225,241,122,104,86,182,87,62,255
   defb 241,249,241,98,100,63,54,43,222,157,240,251,170,204,232,222
   defb 109,111,9,188,127,21,187,142,204,188,247,222,207,238,186,248
   defb 231,118,115,220,254,241,20,135,109,131,120,146,122,139,81,82
   defb 47,236,241,241,249,241,237,116,81,63,157,222,156,240,127,118
   defb 233,233,224,97,233,191,9,15,249,139,190,86,216,225,246,243
   defb 238,183,188,246,63,241,222,247,188,255,190,208,232,122,109,206
   defb 198,135,194,168,190,129,137,130,64,163,129,206,241,232,143,129
   defb 222,231,240,62,232,204,250,222,109,28,145,232,60,35,207,230
   defb 239,54,228,201,9,226,104,109,222,236,135,218,129,186,210,192
   defb 84,93,222,102,222,243,238,183,186,242,63,241,222,247,188,48
   defb 222,61,190,116,35,110,87,175,249,222,240,214,136,243,92,250
   defb 241,225,191,9,74,0,212,51,122,191,190,193,225,163,229,4
   defb 206,238,188,193,119,222,159,222,186,116,93,242,255,120,152,121
   defb 170,240,118,250,186,4,78,118,29,168,240,64,137,65,32,163
   defb 64,218,241,242,136,72,154,73,36,72,60,241,120,112,147,64
   defb 40,241,240,151,182,203,225,132,168,190,109,215,220,164,97,234
   defb 124,129,49,232,212,194,125,188,253,205,186,211,200,119,0,225
   defb 240,98,97,48,68,104,109,253,73,240,229,192,215,205,138,240
   defb 86,55,161,255,240,209,241,95,22,216,240,128,86,43,70,143
   defb 97,49,222,240,208,79,32,104,81,207,129,240,242,209,112,56
   defb 240,34,81,40,4,104,86,248,113,240,95,113,144,240,162,109
   defb 33,110,54,104,129,136,130,64,51,241,219,241,240,130,240,33
   defb 129,64,26,86,63,113,240,29,148,0,56,16,253,240,127,224
   defb 208,249,241,192,245,17,35,192,73,250,21,119,74,120,240,95
   defb 113,144,240,163,109,48,250,117,189,234,240,238,208,240,86,130
   defb 0,133,0,164,0,40,0,10,0,65,47,9,238,95,204,212
   defb 139,230,9,147,238,82,242,117,34,210,140,32,24,114,240,239
   defb 115,96,81,198,1,206,125,241,75,238,25,220,193,221,178,95
   defb 32,76,8,244,239,219,6,9,77,4,227,202,243,239,184,79
   defb 81,239,19,160,17,19,206,86,172,125,192,245,124,247,192,117
   defb 246,161,9,95,124,121,188,49,60,160,7,180,91,64,138,240
   defb 0,51,224,208,124,209,240,238,224,190,23,7,191,64,230,137
   defb 240,184,0,190,162,86,130,43,142,86,206,127,125,240,60,190
   defb 208,63,172,124,162,81,130,40,143,81,240,59,224,64,136,142
   defb 174,72,72,72,240,40,0,211,204,197,243,199,240,184,224,190
   defb 91,81,110,195,40,240,126,125,190,40,81,160,40,163,81,159
   defb 206,255,207,240,190,40,72,174,36,240,43,0,234,223,122,72
   defb 62,239,240,62,222,13,145,146,145,64,197,181,120,33,240,162
   defb 0,104,72,73,72,151,54,54,184,224,190,92,82,205,185,61
   defb 240,248,125,190,162,72,130,36,142,72,206,127,125,240,60,190
   defb 207,238,243,190,238,250,124,81,59,241,4,138,238,0,116,60
   defb 122,6,219,184,43,240,172,0,35,116,20,243,195,240,184,224
   defb 190,93,127,196,207,138,238,0,226,188,138,97,48,10,97,60
   defb 204,255,123,239,188,165,43,187,109,243,54,202,238,0,213,141
   defb 102,238,175,222,238,59,222,76,206,17,10,64,40,32,40,64
   defb 160,32,163,64,206,240,224,225,190,127,24,88,88,254,22,188
   defb 40,72,160,36,163,72,207,204,121,250,239,188,43,93,252,242
   defb 238,244,19,232,206,81,161,40,162,81,129,40,26,9,64,180
   defb 4,144,204,40,9,0,105,9,2,210,4,202,87,211,223,200
   defb 90,9,0,211,202,0,164,9,11,4,73,200,2,144,9,53
   defb 36,152,10,9,16,125,171,77,150,164,9,247,238,245,220,55
   defb 148,83,150,61,223,77,148,165,9,211,198,81,31,205,73,196
   defb 0,40,61,160,30,162,61,130,30,143,61,240,58,224,225,9
   defb 190,55,214,211,215,83,74,164,48,63,171,238,167,0,82,4
   defb 125,238,185,0,202,223,174,247,116,174,227,204,111,172,238,123
   defb 220,16,34,102,154,0,48,74,48,14,248,252,183,240,238,248
   defb 192,23,95,77,240,59,248,213,128,105,218,207,143,240,49,83
   defb 8,53,243,101,240,148,192,215,91,206,240,128,1,45,145,202
   defb 128,145,90,72,31,240,57,192,77,124,179,240,224,128,18,157
   defb 122,124,109,240,243,216,95,113,240,57,192,29,0,223,254,94
   defb 239,238,188,111,9,186,63,239,120,63,239,118,127,203,148,56
   defb 240,247,186,125,179,238,193,9,78,117,170,105,64,195,26,64
   defb 160,98,243,240,184,224,192,93,124,105,240,239,250,128,85,213
   defb 214,147,104,42,72,134,219,168,72,110,60,240,232,193,72,67
   defb 95,105,240,59,224,213,128,117,117,157,138,104,61,161,146,170
   defb 61,73,15,240,58,193,61,16,215,105,206,240,250,189,4,126
   defb 91,9,128,124,53,116,167,138,226,48,161,123,170,48,62,15
   defb 240,56,191,129,48,9,127,92,83,200,255,90,251,207,122,170
   defb 127,152,207,118,239,195,116,248,148,240,247,186,125,173,238,241
   defb 251,48,140,68,102,129,130,129,11,51,138,240,0,38,64,65
   defb 64,137,43,43,122,224,225,9,190,32,174,64,51,51,32,4
   defb 238,41,0,237,204,254,178,171,238,41,0,255,202,119,223,238
   defb 221,138,116,103,62,145,240,43,0,138,186,103,61,238,237,220
   defb 48,196,68,49,29,222,90,9,16,124,171,71,220,105,9,61
   defb 238,252,220,71,218,113,28,220,241,223,29,218,165,9,209,29
   defb 30,64,93,17,128,32,209,24,34,13,17,199,36,80,122,66
   defb 98,225,240,18,138,109,110,67,214,192,232,86,241,87,24,132
   defb 218,219,7,253,48,240,225,192,110,81,241,129,82,137,194,195
   defb 1,254,112,240,69,207,240,150,240,138,129,130,6,37,218,219
   defb 29,192,0,44,9,211,254,249,222,12,247,240,222,188,238,29
   defb 35,240,68,115,50,132,240,74,109,86,149,97,164,86,41,218
   defb 4,161,97,86,149,109,164,97,40,194,1,41,0,80,245,254
   defb 86,8,1,245,7,255,213,85,96

; -----------------------------------------------------------------------------
; ZX0 decoder by Einar Saukas & Urusergi
; "Standard" version (68 bytes only)
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

dzx0_standard:
        ld      bc, $ffff               ; preserve default offset 1
        push    bc
        inc     bc
        ld      a, $80
dzx0s_literals:
        call    dzx0s_elias             ; obtain length
        ldir                            ; copy literals
        add     a, a                    ; copy from last offset or new offset?
        jr      c, dzx0s_new_offset
        call    dzx0s_elias             ; obtain length
dzx0s_copy:
        ex      (sp), hl                ; preserve source, restore offset
        push    hl                      ; preserve offset
        add     hl, de                  ; calculate destination - offset
        ldir                            ; copy from offset
        pop     hl                      ; restore offset
        ex      (sp), hl                ; preserve offset, restore source
        add     a, a                    ; copy from literals or new offset?
        jr      nc, dzx0s_literals
dzx0s_new_offset:
        pop     bc                      ; discard last offset
        ld      c, $fe                  ; prepare negative offset
        call    dzx0s_elias_loop        ; obtain offset MSB
        inc     c
        ret     z                       ; check end marker
        ld      b, c
        ld      c, (hl)                 ; obtain offset LSB
        inc     hl
        rr      b                       ; last offset bit becomes first length bit
        rr      c
        push    bc                      ; preserve new offset
        ld      bc, 1                   ; obtain length
        call    nc, dzx0s_elias_backtrack
        inc     bc
        jr      dzx0s_copy
dzx0s_elias:
        inc     c                       ; interlaced Elias gamma coding
dzx0s_elias_loop:
        add     a, a
        jr      nz, dzx0s_elias_skip
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
dzx0s_elias_skip:
        ret     c
dzx0s_elias_backtrack:
        add     a, a
        rl      c
        rl      b
        jr      dzx0s_elias_loop
; -----------------------------------------------------------------------------












;Squeeker like, just without the output value table
;4 channels of tone with different duty cycle
;sample drums, non-interrupting
;customizeable noise percussion, interrupting

;music data is all 16-bit words, first control then a few optional ones

;control word is PSSSSSSS DDDN4321, where P equ percussion,S equ speed, D equ drum, N equ noise mode, 4321 equ channels
;D triggers non-interruping sample drum
;P trigger
;if 1, channel 1 freq follows
;if 2, channel 2 freq follows
;if 3, channel 3 freq follows
;if 4, channel 4 freq follows
;if N, channel 4 mode follows, it is either $0000 (normal) or $04cb (noise)
;if P, percussion follows, LSB equ volume, MSB equ pitch


RLC_H equ $04cb			;to enable noise mode
NOP_2 equ $0000			;to disable noise mode
RLC_HL equ $06cb		;to enable sample reading
ADD_IX_IX equ $29dd		;to disable sample reading


play_letsgo:



;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

	ld	hl, compressed_letsgo
	ld	de, uncompressed_letsgo
	call	dzx0_standard



	ld	hl, notplaying		; Display playing arrows
	ld	de, 28672+32*3
	ld	bc, 3
	ldir

	ld	hl, playing
	ld	de, 28672+32*4
	ld	bc, 3
	ldir


	ld	hl, song_letsgo
	di
	
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (pattern_ptr),de
	
	ld e,(hl)
	inc hl
	ld d,(hl)
	
	ld (loop_ptr),de

	dec hl
	ld (sample_list),hl
	
	ld hl,ADD_IX_IX
	ld (sample_read),hl
	ld hl,NOP_2					;normal mode
	ld (noise_mode),hl
	
	ld ix,0						;needs to be 0 to skip sample reading

	ld c,0
	exx
	ld de,$0808					;sample bit counter and reload value

play_loop

pattern_ptr equ $+1
	ld sp,0
	
return_loop

	pop bc						;control word
								;B equ duration of the row (0 equ loop)
								;C equ flags DDDN4321 (Drum, Noise, 1-4 channel update)
	ld a,b
	or a
	jp nz,no_loop
	
loop_ptr equ $+1
	ld sp,0
	jp 	play_nightdancer		; End song. JUMP to Night Dancer.

no_loop

	ld a,c
	
	rra
	jr nc,skip_note_0
	
	pop hl
	ld (ch0_add),hl
	
skip_note_0

	rra
	jr nc,skip_note_1

	pop hl
	ld (ch1_add),hl
	
skip_note_1

	rra
	jr nc,skip_note_2
	
	pop hl
	ld (ch2_add),hl
	
skip_note_2

	rra
	jr nc,skip_note_3
	
	pop hl
	ld (ch3_add),hl
	
skip_note_3

	rra
	jr nc,skip_mode_change
	
	pop hl						;nop:nop or rlc h
	ld (noise_mode),hl

skip_mode_change

	and 7
	jp z,skip_drum
	
sample_list equ $+1
	ld hl,0						;sample_list-2
	add a,a
	add a,l
	ld l,a
	ld a,(hl)
	inc l
	ld h,(hl)
	ld l,a
	ld (sample_ptr),hl
	ld hl,RLC_HL
	ld (sample_read),hl

skip_drum

	bit 7,b						;check percussion flag
	jp z,skip_percussion

	res 7,b						;clear percussion flag

	ld (noise_bc),bc
	ld (noise_de),de

	pop hl						;read percussion parameters

	ld a,l						;noise volume
	ld (noise_volume),a
	ld b,h						;noise pitch
	ld c,h
	ld de,$2174					;utz's rand seed			
	exx
	ld bc,429					;noise duration, takes as long as inner sound loop

noise_loop

	exx							;4
	dec c						;4
	jr nz,noise_skip			;7/12
	ld c,b						;4
	add hl,de					;11
	rlc h						;8		utz's noise generator idea
	inc d						;4		improves randomness
	jp noise_next				;10
	
noise_skip

	jr $+2						;12
	jr $+2						;12
	nop							;4
	nop							;4
	
noise_next

	ld a,h						;4
	
noise_volume equ $+1
	cp $80						;7
	sbc a,a						;4


	and 	33
	xor	32
	ld	($6800), a

	exx							;4

	dec bc						;6
	ld a,b						;4
	or c						;4
	jp nz,noise_loop			;10 equ 106t

	exx

noise_bc equ $+1
	ld bc,0
noise_de equ $+1
	ld de,0



skip_percussion

	ld (pattern_ptr),sp

sample_ptr equ $+1
	ld hl,0

sound_loop0

	ld c,64						;internal loop runs 64 times

sound_loop

sample_read equ $
	rlc (hl)					;15 	rotate sample bits in place, rl (hl) or add ix,ix (dummy operation)
	sbc a,a						;4		sbc a,a to make bit into 0 or 255, or xor a to keep it 0

	dec e						;4--+	count bits
	jp z,sample_cycle			;10 |
	jp sample_next				;10

sample_cycle

	ld e,d						;4	|	reload counter
	inc hl						;6--+	advance pointer --24t

sample_next

	exx							;4		squeeker type unrolled code
	ld b,a						;4		sample mask
	xor a						;4
	
	ld sp,sound_list			;10
		
	pop de						;10		ch0_acc
	pop hl						;10		ch0_add
	add hl,de					;11
	rla							;4
	ld (ch0_acc),hl				;16
						
	pop de						;10		ch1_acc
	pop hl						;10		ch1_add
	add hl,de					;11
	rla							;4
	ld (ch1_acc),hl				;16
	
	pop de						;10		ch2_acc
	pop hl						;10		ch2_add
	add hl,de					;11
	rla							;4
	ld (ch2_acc),hl				;16

	pop de						;10		ch3_acc
	pop hl						;10		ch3_add
	add hl,de					;11
	
noise_mode equ $
	ds 2,0						;8		rlc h for noise effects

	rla							;4
	ld (ch3_acc),hl				;16

	add a,c						;4		no table like in Squeeker, channels summed as is, for uneven 'volume'
	add a,$ff					;7
	sbc a,$ff					;7
	ld c,a						;4
	sbc a,a						;4

	or b						;4		mix sample

	and 	33
	xor	32
	ld	($6800), a
	exx							;4
	dec 	c						;4
	jp 	nz,sound_loop			;10 equ 336t
	dec 	hl						;last byte of a 64 byte sample packet is $80 means it was the last packet
	ld 	a,(hl)
	inc 	hl
	cp 	$80
	jr 	nz,sample_no_stop
	ld 	hl,ADD_IX_IX
	ld 	(sample_read),hl			;disable sample reading
sample_no_stop
	djnz 	sound_loop0
	ld 	(sample_ptr),hl
	jp 	play_loop
	

compressed_letsgo:
; ZX0 compressed raw bin of LetsGo song data assembled.
;
   defb  26,31,8,3,1,0,96,25,8,0,159,8,4,8,244,169
   defb  9,186,6,2,25,229,8,27,5,191,188,229,200,17,143,55
   defb  7,144,23,196,32,88,144,205,0,142,155,1,200,4,126,33
   defb  200,71,106,233,52,33,162,9,43,104,245,229,200,90,13,96
   defb  255,19,12,17,6,237,253,228,154,104,2,204,129,110,207,208
   defb  92,124,4,91,196,92,152,227,247,35,12,254,236,252,166,12
   defb  220,12,35,188,224,232,253,237,229,102,132,149,45,164,105,105
   defb  69,26,105,90,40,26,37,70,145,41,164,69,245,200,228,144
   defb  241,32,19,92,244,41,105,15,145,144,200,184,40,144,74,41
   defb  83,92,132,41,41,26,37,70,145,41,161,229,31,33,213,200
   defb  176,237,148,0,181,64,148,124,85,249,145,200,11,72,194,144
   defb  134,196,176,1,220,8,47,20,252,10,47,143,12,4,177,222
   defb  199,16,157,3,233,28,13,213,250,213,132,143,125,196,187,163
   defb  172,159,196,181,223,196,177,135,136,250,247,196,45,95,28,251
   defb  193,233,23,222,192,168,250,176,9,126,217,177,159,175,181,218
   defb  172,15,127,178,233,4,141,127,236,221,216,244,180,136,80,157
   defb  0,2,255,176,229,237,245,144,255,200,164,248,228,160,105,163
   defb  247,188,225,169,188,223,156,135,112,231,13,72,127,180,188,167
   defb  3,119,148,135,40,253,157,229,164,220,144,228,164,166,15,129
   defb  162,201,220,221,224,114,52,68,88,144,220,12,243,229,52,98
   defb  220,12,20,247,188,242,168,52,88,129,220,12,34,35,12,82
   defb  36,35,12,34,35,12,82,37,220,12,61,92,239,136,164,228
   defb  36,248,249,108,114,45,33,55,3,34,205,0,72,132,155,1
   defb  62,173,196,127,181,196,124,177,96,96,98,205,0,18,33,205
   defb  0,34,155,1,82,36,205,0,34,205,0,18,32,155,1,72
   defb  144,55,3,241,165,218,164,155,71,225,249,180,223,160,223,180
   defb  161,151,180,229,153,104,165,0,252,57,181,113,80,254,224,176
   defb  31,149,247,229,156,157,236,156,120,151,20,253,224,156,201,196
   defb  217,200,57,200,49,136,65,17,6,74,132,88,132,8,3,34
   defb  17,6,74,132,6,32,8,3,74,132,22,133,132,137,8,3
   defb  74,132,70,129,132,168,77,129,8,3,34,132,1,67,199,249
   defb  132,98,8,3,67,242,208,20,31,153,223,180,249,222,180,153
   defb  158,79,104,23,223,209,140,218,180,78,198,204,27,67,99,220
   defb  233,212,66,246,168,133,220,231,96,222,68,116,70,53,47,134
   defb  61,228,78,124,99,16,1,0,189,220,225,88,237,143,109,134
   defb  164,250,217,233,142,245,241,63,244,232,175,71,236,254,165,168
   defb  179,12,32,59,168,134,124,32,38,134,250,168,45,120,120,34
   defb  8,23,30,165,158,39,124,14,188,254,209,236,156,79,157,16
   defb  233,244,14,49,246,40,240,74,140,221,244,222,152,33,25,8
   defb  183,3,120,223,149,229,251,221,236,111,177,160,158,108,204,119
   defb  137,253,204,176,188,71,144,231,228,198,53,24,78,144,229,92
   defb  184,38,144,231,232,241,36,159,16,144,55,104,62,144,159,103
   defb  229,216,92,253,134,134,233,148,166,79,145,162,161,162,247,36
   defb  150,200,36,46,134,245,229,210,220,129,5,104,5,90,5,22
   defb  132,5,104,5,26,5,22,138,5,14,6,128,103,162,5,146
   defb  140,145,5,161,5,26,5,41,44,41,5,34,220,12,26,7
   defb  72,132,220,12,136,220,12,105,7,63,204,219,176,71,206,144
   defb  148,105,14,214,220,94,92,91,38,142,144,232,127,36,25,100
   defb  247,144,214,233,220,95,229,221,92,127,221,233,148,105,79,164
   defb  220,104,220,125,36,229,92,137,46,134,61,32,197,235,112,205
   defb  8,184,98,155,1,8,144,55,3,136,155,1,15,236,240,165
   defb  199,184,225,169,124,223,105,124,250,168,45,125,120,215,220,254
   defb  140,165,159,103,124,110,140,188,195,184,98,155,1,83,246,164
   defb  241,133,141,173,44,218,244,47,112,137,185,205,0,8,146,155
   defb  1,32,55,3,8,129,155,1,243,144,8,184,95,145,150,92
   defb  227,38,144,159,232,36,195,184,88,151,155,1,106,8,23,112
   defb  135,184,218,148,79,112,215,184,253,148,36,195,184,93,221,180
   defb  122,220,205,104,230,41,5,40,205,107,155,9,184,98,205,1
   defb  3,252,236,165,49,184,253,169,124,214,220,104,205,160,5,164
   defb  205,164,5,165,205,253,165,124,187,140,188,13,184,137,205,1
   defb  78,164,105,45,194,184,29,218,244,47,112,136,185,230,0,10
   defb  2,113,138,20,134,79,213,223,228,245,29,20,167,34,13,200
   defb  125,184,104,2,117,220,244,101,116,193,241,128,97,44,171,3
   defb  110,243,229,172,160,233,90,106,79,182,70,252,92,74,117,52
   defb  125,148,239,197,34,88,14,225,142,18,4,76,22,188,93,24
   defb  176,208,143,32,221,167,237,12,16,151,148,214,192,150,44,145
   defb  37,185,45,128,12,71,101,149,192,247,128,212,0,92,23,236
   defb  117,35,212,189,244,192,254,237,192,133,69,105,44,224,128,104
   defb  45,71,240,1,192,112,93,204,218,193,104,26,104,126,224,159
   defb  12,192,161,69,90,44,117,67,76,31,128,165,13,117,2,193
   defb  145,237,98,47,134,48,61,140,74,52,147,1,208,229,38,88
   defb  159,107,204,250,212,10,6,243,71,160,197,164,160,42,105,39
   defb  111,32,72,74,43,69,207,173,164,71,214,72,217,64,144,66
   defb  133,128,26,16,0,164,134,221,189,145,140,185,64,160,74,128
   defb  87,211,65,221,23,232,197,223,76,233,119,228,79,221,208,231
   defb  164,219,212,71,129,164,41,42,241,72,137,32,5,74,43,69
   defb  222,141,164,17,202,209,52,173,209,74,109,64,214,188,104,209
   defb  26,104,254,208,164,125,212,188,231,164,137,128,9,74,11,22
   defb  128,74,98,16,11,82,197,15,189,76,233,30,156,226,32,204
   defb  157,2,71,208,170,238,209,24,229,64,13,212,166,14,170,35
   defb  220,134,128,151,66,30,52,33,25,8,116,73,196,192,207,100
   defb  237,254,204,249,200,104,14,127,172,93,76,226,145,68,19,68
   defb  246,200,135,46,248,116,28,99,47,18,65,218,224,6,87,252
   defb  140,197,12,148,246,140,130,3,134,79,36,110,14,72,253,51
   defb  16,197,140,120,24,127,192,7,165,101,108,247,229,48,31,196
   defb  93,194,48,133,5,165,5,105,5,26,5,86,133,7,165,7
   defb  105,7,26,7,67,193,140,223,48,133,140,216,49,33,205,0
   defb  110,6,164,9,245,229,24,0,160,9,167,111,223,225,48,133
   defb  196,184,71,136,246,200,135,6,145,144,164,46,104,39,10,11
   defb  19,250,233,32,47,18,145,11,161,11,48,229,65,144,95,33
   defb  23,88,197,42,64,13,10,6,107,104,231,233,144,255,237,229
   defb  241,200,104,14,122,32,135,13,144,144,40,46,31,32,10,15
   defb  22,149,15,164,15,104,15,40,79,113,62,68,196,105,2,247
   defb  204,241,144,47,44,204,40,66,117,116,228,161,15,105,15,90
   defb  15,70,144,15,240,144,127,200,28,180,41,15,90,13,22,149
   defb  13,164,13,105,13,15,140,7,31,180,215,140,87,228,74,11
   defb  70,148,11,245,196,220,48,40,11,90,11,86,144,11,233,229
   defb  10,218,45,39,92,118,149,48,74,9,86,145,9,165,9,57
   defb  140,93,253,48,140,117,116,228,164,7,105,7,90,7,70,145
   defb  7,161,7,105,7,90,7,70,145,7,161,5,105,5,90,5
   defb  70,144,5,228,144,93,92,228,40,3,90,3,86,145,3,161
   defb  3,228,144,10,78,70,36,45,8,186,8,232,238,204,248,236
   defb  113,2,152,121,232,249,249,240,171,236,220,210,220,189,12,184
   defb  165,72,208,94,116,32,0,0,166,1,156,1,20,152,120,250
   defb  70,24,84,129,123,225,165,180,184,250,89,192,13,127,245,200
   defb  127,181,168,211,32,208,73,56,195,120,250,180,133,30,112,95
   defb  180,250,197,181,175,117,52,229,244,108,83,152,127,224,233,92
   defb  10,233,89,135,244,225,212,165,13,76,255,200,165,84,157,116
   defb  253,249,229,144,167,9,216,181,172,86,159,133,4,207,184,102
   defb  164,157,41,154,168,137,121,200,254,185,45,160,107,5,69,55
   defb  4,126,196,28,109,11,205,140,157,204,245,180,79,20,122,176
   defb  135,93,232,180,35,118,184,31,185,156,76,233,41,77,12,221
   defb  176,167,161,119,180,220,200,223,92,209,233,8,33,250,188,129
   defb  121,120,136,208,10,15,209,117,196,161,15,250,188,14,29,161
   defb  185,131,222,192,135,131,117,196,253,121,80,221,185,193,200,247
   defb  200,39,120,68,60,120,218,200,37,113,82,176,104,141,124,201
   defb  84,161,97,9,105,162,115,176,215,36,105,7,119,233,101,192
   defb  167,139,241,180,87,224,117,63,44,156,108,5,85,147,216,94
   defb  33,33,135,8,252,218,185,85,161,217,169,217,168,254,177,197
   defb  189,214,4,92,53,124,200,134,112,33,205,0,252,241,112,252
   defb  65,173,199,112,243,205,217,112,127,232,242,188,112,31,156,205
   defb  112,247,237,180,161,35,205,112,247,80,60,253,149,199,112,221
   defb  181,200,252,200,216,112,148,155,1,243,197,112,124,237,223,112
   defb  185,103,40,33,108,223,208,61,108,151,176,242,200,124,127,161
   defb  228,205,100,243,233,100,119,183,204,97,213,131,100,64,36,40
   defb  199,25,200,253,100,124,185,232,100,8,31,177,242,125,193,100
   defb  127,212,24,212,105,132,126,241,112,127,176,49,100,253,205,25
   defb  223,180,232,252,188,219,100,67,99,220,55,100,250,236,181,35
   defb  127,236,223,124,84,167,220,48,104,243,32,225,235,204,184,69
   defb  4,205,108,233,185,77,254,197,220,129,76,244,189,185,177,220
   defb  220,46,79,40,48,125,164,0,152,120,144,23,9,255,229,73
   defb  201,215,204,7,60,199,192,192,173,200,1,223,112,109,68,40
   defb  169,105,127,217,143,173,185,128,1,233,120,69,136,68,19,55
   defb  188,209,206,208,180,250,200,40,244,205,3,144,116,63,176,180
   defb  167,132,167,113,41,230,169,112,191,8,52,110,176,24,55,181
   defb  20,223,44,17,67,180,14,156,208,249,180,200,136,142,134,62
   defb  169,228,110,43,140,49,55,168,246,89,181,172,127,137,221,114
   defb  172,129,3,164,3,41,133,254,5,196,180,44,63,180,176,167
   defb  41,255,233,236,255,233,201,109,109,253,45,104,174,132,200,110
   defb  67,24,57,28,173,10,8,180,59,168,61,144,20,135,92,97
   defb  208,185,35,156,160,5,254,109,185,76,116,62,236,217,157,12
   defb  138,176,5,41,65,255,240,217,66,180,78,172,251,216,32,138
   defb  188,33,95,253,152,120,128,208,10,46,67,40,74,14,208,211
   defb  180,189,156,200,143,34,134,236,217,196,40,7,61,80,221,185
   defb  168,200,7,26,7,90,7,13,9,180,49,82,156,62,196,191
   defb  36,229,180,167,37,121,137,176,199,28,214,228,121,200,175,136
   defb  204,215,36,125,117,0,135,64,67,180,55,192,104,7,43,42
   defb  249,184,232,208,89,0,210,192,29,95,172,64,103,152,67,180
   defb  210,104,107,140,79,212,65,58,144,73,93,244,248,32,180,239
   defb  168,216,207,112,233,184,33,243,241,112,116,127,64,112,200,112
   defb  41,1,227,24,29,224,208,211,180,189,156,200,207,113,236,110
   defb  35,156,104,3,61,80,137,23,9,160,3,104,3,167,65,25
   defb  236,208,147,180,242,172,113,147,3,233,180,37,252,140,151,112
   defb  250,185,104,8,114,108,41,3,227,28,72,24,119,193,66,180
   defb  77,143,184,204,115,101,244,176,18,32,29,79,212,42,100,5
   defb  23,208,105,143,180,217,55,100,208,189,94,24,151,73,125,236
   defb  8,180,59,168,198,245,212,88,132,205,1,255,201,176,29,212
   defb  127,24,29,212,208,195,180,61,144,177,4,223,212,236,110,163
   defb  156,49,154,212,160,107,172,67,232,199,216,104,160,106,161,35
   defb  179,1,22,121,32,155,1,254,192,241,191,110,197,132,173,90
   defb  62,129,200,166,70,1,134,52,250,236,34,187,167,44,65,253
   defb  105,208,105,13,160,162,174,247,7,224,154,92,79,178,103,148
   defb  255,212,156,202,125,65,196,10,58,44,8,221,107,153,180,127
   defb  229,204,226,208,141,2,208,111,152,236,171,69,47,85,72,116
   defb  152,208,10,23,117,81,151,128,141,243,200,10,82,197,133,131
   defb  255,236,249,233,176,5,105,143,244,217,250,236,173,11,117,73
   defb  36,166,41,134,15,159,131,197,85,28,136,105,15,161,171,184
   defb  154,24,161,11,250,100,141,127,212,18,253,151,137,120,196,142
   defb  25,8,173,157,3,81,32,196,119,184,213,83,76,160,129,125
   defb  217,253,184,164,104,143,119,176,213,18,200,26,43,29,253,229
   defb  168,223,172,168,167,7,63,168,172,119,164,99,17,8,135,84
   defb  28,184,220,160,253,232,220,156,216,96,133,0,0,10,1,115
   defb  100,31,141,53,104,127,216,37,108,24,132,220,12,213,19,252
   defb  92,129,108,247,217,196,245,164,167,143,243,112,108,92,60,221
   defb  129,223,108,228,205,108,245,237,69,150,8,134,171,189,27,84
   defb  105,139,213,22,25,134,154,151,139,85,29,48,201,100,52,73
   defb  64,51,100,88,144,205,0,243,229,100,136,155,1,19,199,205
   defb  204,98,205,0,72,148,155,1,242,209,96,31,233,55,96,199
   defb  181,204,88,144,205,0,213,23,48,93,244,192,28,240,119,184
   defb  198,196,125,156,105,143,199,196,127,208,218,156,43,113,150,188
   defb  32,205,0,34,155,1,95,164,243,212,124,140,101,180,137,205
   defb  0,119,136,51,72,124,233,216,72,133,132,1,209,36,36,199
   defb  172,90,132,22,239,9,228,105,30,168,32,8,3,74,132,6
   defb  157,132,81,113,88,160,15,115,148,247,24,84,88,96,126,24
   defb  180,129,78,200,134,43,181,19,69,198,108,135,3,55,88,155
   defb  236,167,138,172,35,167,6,63,208,249,222,228,161,159,71,200
   defb  7,160,145,35,106,70,240,35,148,250,228,14,121,201,135,116
   defb  11,78,121,157,224,141,52,10,81,97,80,231,220,127,53,189
   defb  80,174,149,188,98,25,8,242,124,57,165,7,120,137,55,7
   defb  34,207,6,76,93,201,81,102,48,36,208,10,223,112,84,152
   defb  48,168,200,10,1,160,130,164,1,207,16,53,169,93,44,209
   defb  124,184,249,24,192,175,34,128,209,102,20,226,15,184,181,130
   defb  30,156,135,35,234,108,8,134,15,159,75,112,107,10,28,92
   defb  239,180,216,111,136,108,41,47,198,88,117,89,224,167,2,84
   defb  88,108,125,165,231,193,208,117,189,77,176,255,76,233,218,160
   defb  6,119,49,232,156,135,107,23,154,160,34,6,156,43,127,92
   defb  64,125,233,81,97,140,253,185,68,248,233,68,113,253,92,164
   defb  199,96,55,140,53,77,204,199,204,231,232,36,80,165,5,105
   defb  5,105,5,26,5,1,165,5,160,5,127,108,34,80,146,99
   defb  138,5,136,10,5,22,129,5,62,108,150,40,157,47,9,8
   defb  192,76,36,115,80,136,220,12,105,7,62,229,236,127,76,245
   defb  233,160,161,135,204,61,1,215,224,61,84,43,61,27,223,164
   defb  233,55,84,212,237,61,245,72,164,35,98,43,16,82,255,139
   defb  164,28,51,84,245,233,80,198,28,49,160,21,198,164,9,55
   defb  3,152,21,11,71,177,180,31,240,24,168,98,55,3,32,148
   defb  47,18,60,19,236,181,39,67,152,205,88,236,180,102,168,129
   defb  136,136,155,1,19,241,181,77,154,168,40,7,67,152,223,213
   defb  65,29,168,127,169,237,220,165,197,96,168,127,156,198,161,168
   defb  7,84,103,116,24,168,24,136,155,1,149,102,14,237,164,19
   defb  4,199,168,93,156,144,199,85,168,88,144,55,3,34,205,1
   defb  34,47,18,82,9,155,3,39,18,79,181,61,84,39,96,243
   defb  255,241,76,161,155,241,213,199,164,241,173,137,150,164,37,155
   defb  3,63,104,95,112,225,121,28,167,45,16,205,229,169,2,232
   defb  26,139,116,137,197,54,24,41,130,198,204,95,236,105,6,235
   defb  233,166,165,173,70,166,162,226,10,212,152,174,247,184,25,124
   defb  227,184,63,27,73,84,166,78,12,221,28,168,25,102,176,152
   defb  74,250,47,27,208,74,107,205,25,176,160,66,113,31,124,241
   defb  40,62,180,228,137,8,110,235,233,90,235,204,70,250,180,229
   defb  52,26,34,90,18,109,205,86,93,33,1,246,251,252,12,177
   defb  228,57,9,232,172,236,121,17,208,98,249,7,74,12,98,241
   defb  7,18,133,233,161,225,105,217,117,15,108,208,115,2,236,90
   defb  9,69,164,9,31,144,90,189,29,86,149,103,203,4,24,167
   defb  61,188,134,228,238,185,168,228,27,184,146,176,216,45,28,136
   defb  254,1,244,252,93,85,86
	
		
;variables in the sound_list can't be reordered because of stack-based fetching

sound_list

ch0_add		dw 0
ch0_acc		dw 0
ch1_add		dw 0
ch1_acc		dw 0
ch2_add		dw 0
ch2_acc		dw 0
ch3_add		dw 0
ch3_acc		dw 0


;compiled music data

	align 2

song_letsgo
	dw .pattern
	dw .loop
;sample data

.sample_list
	dw .sample_1
	dw .sample_2
	dw .sample_3
	dw .sample_4
	dw .sample_5
	dw .sample_6
	dw .sample_7
;	align 256

	align 64/8

.sample_1:
	db 0,0,8,79,255,255,242,0
	db 0,0,0,0,31,255,255,255
	db 255,255,255,232,0,0,0,128
.sample_2:
	db 0,0,0,0,0,0,31,255
	db 249,64,0,0,7,255,255,0
	db 0,0,63,255,248,128,0,7
	db 255,255,255,224,0,0,158,15
	db 255,247,224,0,0,0,223,255
	db 224,0,0,38,207,255,224,0
	db 0,1,247,251,143,253,192,0
	db 0,15,255,191,208,0,0,128
.sample_3:
	db 35,105,159,243,210,148,228,128
.sample_4:
	db 128,128,60,1,224,15,0,240
	db 7,128,28,1,192,30,0,32
	db 3,0,8,0,0,0,0,128
.sample_5:
	db 0,84,45,120,1,254,128,191
	db 224,3,248,0,255,0,47,232
	db 11,254,0,127,160,11,248,0
	db 138,0,2,104,0,10,0,0
	db 48,0,26,0,2,64,0,64
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,128
.sample_6:
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,6,0
	db 0,0,255,0,0,3,248,0
	db 0,63,224,0,0,255,0,0
	db 7,252,0,0,63,232,0,0
	db 127,160,0,0,255,208,0,3
	db 254,0,0,31,251,128,0,127
	db 255,0,0,254,180,0,1,255
	db 224,0,7,239,192,0,31,246
	db 0,0,127,218,0,0,252,248
	db 0,1,247,224,0,15,223,192
	db 0,31,246,0,0,255,250,0
	db 0,253,224,0,7,255,32,0
	db 15,255,128,0,63,248,0,0
	db 255,200,0,3,255,128,0,15
	db 252,0,0,63,252,0,0,255
	db 224,0,3,255,0,0,15,111
	db 0,0,17,252,0,0,1,248
	db 0,0,1,232,0,0,11,224
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,3,255,253,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,32,0,0
	db 0,0,0,0,1,0,0,0
	db 4,0,8,130,137,10,0,0
	db 1,1,2,1,0,130,200,4
	db 1,18,192,120,24,118,78,248
	db 48,204,193,102,64,97,192,136
	db 16,160,128,97,0,19,152,236
	db 193,192,2,0,0,2,148,57
	db 116,56,129,167,149,0,64,132
	db 0,0,136,72,32,0,65,4
	db 0,176,1,64,16,0,32,64
	db 0,0,9,193,0,132,0,136
	db 20,84,0,8,0,18,0,0
	db 0,0,0,128,0,0,0,6
	db 23,32,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,128
.sample_7:
	db 0,0,0,0,0,0,39,248
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,120,0
	db 0,31,192,0,0,255,0,0
	db 0,254,0,0,0,127,0,0
	db 0,127,0,0,0,63,128,0
	db 0,15,128,0,0,7,224,0
	db 0,3,240,0,0,1,248,0
	db 0,0,252,0,0,0,254,0
	db 0,0,127,0,0,0,63,0
	db 0,0,63,0,0,0,15,192
	db 0,0,15,128,0,0,15,192
	db 32,0,15,128,0,0,7,192
	db 0,0,7,192,0,0,7,192
	db 0,0,7,129,0,0,7,192
	db 0,0,15,128,0,0,31,0
	db 0,0,31,0,0,0,31,0
	db 0,0,63,0,0,0,126,0
	db 0,0,252,0,0,0,248,0
	db 0,3,224,0,0,15,128,0
	db 0,63,0,0,0,248,0,0
	db 3,224,0,0,31,0,0,0
	db 254,0,0,3,240,0,0,15
	db 128,0,0,126,0,0,1,240
	db 0,0,15,192,0,0,127,0
	db 0,1,252,0,0,15,224,0
	db 0,127,0,0,1,254,0,0
	db 15,224,0,0,127,128,0,0
	db 254,0,0,7,248,0,0,63
	db 192,0,0,255,0,0,1,252
	db 0,0,7,240,0,0,31,224
	db 0,0,127,0,0,0,254,0
	db 0,1,250,0,0,3,248,0
	db 0,7,240,0,0,7,240,0
	db 0,15,192,0,0,7,192,0
	db 0,7,192,0,0,3,224,0
	db 0,1,248,0,0,0,255,0
	db 0,0,63,0,0,0,15,224
	db 0,0,1,252,0,0,0,127
	db 0,0,0,7,224,0,0,0
	db 254,0,0,0,15,192,0,0
	db 0,254,0,0,0,15,224,0
	db 0,0,255,0,0,0,3,240
	db 0,0,0,63,128,0,0,0
	db 255,0,0,0,7,248,0,0
	db 0,31,192,0,0,0,127,192
	db 0,0,0,255,0,0,0,1
	db 252,0,0,0,7,240,0,0
	db 0,15,224,0,0,0,31,192
	db 0,0,0,63,128,0,0,0
	db 63,0,0,0,0,127,0,0
	db 0,0,255,0,0,0,0,252
	db 0,0,0,0,252,0,0,0
	db 0,252,0,0,0,0,248,0
	db 0,0,0,120,0,0,0,0
	db 120,0,0,0,0,48,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,128

.loop:
	dw $80f,$0,$0,$0,$0
	dw $800
	dw $800
	dw $800
	dw 0

.pattern
uncompressed_letsgo:


	org $A800

song_nightdancer:
song_nightdancer_uncompressed:


