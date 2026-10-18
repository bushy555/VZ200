; original with 
;	and 33			THIS BRINGS the volume up nice and loud.
;	ld ($6800), a		
;	xor 32			By XOR'ing 32, it opposes bits 5 & 0 and does the volume thing.
;	ld ($6800), a



;===================================
;PhaserX
;   FROEN_MOHAWK
;   LAST SUMMER
;   DEMO1
;   DEMO2
;
;
;PhaserX engine and above tunes by utz 09'2016 * www.irrlichtproject.de
;VZ combined MUSICBOX Version by dave. July 2023.
;
;
; Assemble:	PASMO %1.asm %1.vz
;
;
;
; 0=speaker.  
; 1=Cassette Port.  
; 2=Printer Port.
;
;
; External Speaker taken from off internal Piezo.
; Open up VZ/Laser. Drill a hoel suitable for a 3.5mm stereo socket near power switch.
; Install the stereo socket.
; May need to remove motherboard. Run two wires from the peizo to two inline 
; 0.1uf greencaps or tagulams capacitors, and then from the greencaps to the socket.
; Interestingly some 1-bit music methods do not trigger the peizo, but work fine with 
; amplified proper speakers. Wire centre of piezo to Left and Right channel, outside of
; piezo to common.                       
;                                         DISCLAIMER
;                      PLEASE NOTE : DO NOT WIRE THIS UP WITHOUT THE IN-SERIES CAPS !   
;                      YOU CAN EASILY BLOW THE GA CHIP ON A VZ300/LASER310. 
;                                     YOU HAVE BEEN WARNED.
;
;
;                        0.1uf
;          --------,------||------> 3.5mm socket "common"
; TO VZ            |
; board    ----.----------||------> 3.5mm socket. "LEFT and RIGHT"
;              |   |     0.1uf
;              |   |
;              |   |
;         ___________ <--piezo speaker.
;
;
;
;              ==========================
;
;
;
; Experimental Cassette port option.
; Plug in a stereo 3.5mm socket connected to amplified speakers. Select this option
; and music will be output to the cassette port through to your doof-doof speakers.
;                       
;  VZ cassette   
;  port socket             _____________
;               /--,--,---|3.5mm stereo |
;               \--'--'---|_______plug__|
;                 |  |  |
;                 |  |  |____common
;                 |  |_______right channel       
;                 |__________left channel
;
;
;
;              ==========================
;
;
;
; Experimental Printer Port option.
; Just connect up your VZ/Laser printer interface, then, connect up an amplified speaker
;  to D4 and ground. D4 being output data bit5, being pin 6 of the centronics plug.
;  Chose data line D4/bit5 since bit5 is the same data line on the $6800latch for the 
; internal speaker. May as well make it the same, since it just makes outputing data
; just that little bit easier.   LD ($6800), A    -->   OUT (14), A
;
; ------------   pin 1. strobe                                  pin 1 strobe
;             \  pin 2. D0
;              | pin 3. D1
;              | pin 4. D2
; 36 pin       | pin 5. D3                   0.1uf
; Centronics   | pin 6. D4              ---> -||- -->   connect to         
; Printer      | pin 7. D5                              amplified 
; Male plug    | .                                      speakers. 
; coming from  | .                                      Can add two 0.1uf caps in-line if
; VZ printer   | pin 16. SIGNAL GROUND  ---> -||- -->   you feel the need to.
;interface unit| .                           0.1uf      I haven't bothered and after all of my
;              | .                                      testing, I havent blown anything yet.
;             / 
; ------------  
;
;
;
;

mix_xor  equ $ac00
mix_or	 equ $b400
mix_and  equ $a400
fsid	 equ $4
fnoise	 equ $80
noupd1	 equ $1
noupd2	 equ $40
kick	 equ $1
hhat	 equ $80
ptnend	 equ $40
rest	 equ 0
a0	 equ $e4
ais0	 equ $f1
b0	 equ $100
c1	 equ $10f
cis1	 equ $11f
d1	 equ $130
dis1	 equ $142
e1	 equ $155
f1	 equ $169
fis1	 equ $17f
g1	 equ $196
gis1	 equ $1ae
a1	 equ $1c7
ais1	 equ $1e2
b1	 equ $1ff
c2	 equ $21d
cis2	 equ $23e
d2	 equ $260
dis2	 equ $284
e2	 equ $2aa
f2	 equ $2d3
fis2	 equ $2fe
g2	 equ $32b
gis2	 equ $35b
a2	 equ $38f
ais2	 equ $3c5
b2	 equ $3fe
c3	 equ $43b
cis3	 equ $47b
d3	 equ $4bf
dis3	 equ $508
e3	 equ $554
f3	 equ $5a5
fis3	 equ $5fb
g3	 equ $656
gis3	 equ $6b7
a3	 equ $71d
ais3	 equ $789
b3	 equ $7fc
c4	 equ $876
cis4	 equ $8f6
d4	 equ $97f
dis4	 equ $a0f
e4	 equ $aa9
f4	 equ $b4b
fis4	 equ $bf7
g4	 equ $cad
gis4	 equ $d6e
a4	 equ $e3a
ais4	 equ $f13
b4	 equ $ff8
c5	 equ $10eb
cis5	 equ $11ed
d5	 equ $12fe
dis5	 equ $141f
e5	 equ $1551
f5	 equ $1696
fis5	 equ $17ed
g5	 equ $195a
gis5	 equ $1adc
a5	 equ $1c74
ais5	 equ $1e26
b5	 equ $1ff0
c6	 equ $21d7
cis6	 equ $23da
d6	 equ $25fb
dis6	 equ $283e
e6	 equ $2aa2
f6	 equ $2d2b
fis6	 equ $2fdb
g6	 equ $32b3
gis6	 equ $35b7
a6	 equ $38e9
ais6	 equ $3c4b
b6	 equ $3fe1
c7	 equ $43ad
cis7	 equ $47b3
d7	 equ $4bf7
dis7	 equ $507b
e7	 equ $5544
f7	 equ $5a56
fis7	 equ $5fb6
g7	 equ $6567
gis7	 equ $6b6e
a7	 equ $71d1
origin	 equ $8000

equaliser equ 0
BORDER equ $14



;Assemble at $A000 for compatibility of SD Loaders on 2+2k, 6k+2k and 16+2K VZ Lasers
;Assemble at $8000 for normal $8000 loading.


; -------------------------------
; Generic .VZ snapshot header
; -------------------------------
	org 	origin - 24
	db 	$20, $20, $00, $00, $56, $5A, $44, $4F 		; generic header
	db	$53, $00, $00, $00, $00, $00, $00, $00
	db	$00, $00, $00, $00, $00, $F1
	dw	START

	org 	origin

START equ $





; -------------------------------
; Intro stuff
; -------------------------------
	di
;	call	do_intro		; Do fancy intro
	ld	a, 0
	ld	($6800), a		; MODE (0)
	ld	a, 0
	ld	(device), a		; 0=speaker.  1=cassette port.  2=Printer Port.

begin:	
cls:	
; -------------------------------
; Menu stuff
; -------------------------------
	ei
	call	$01c9			; VZ ROM CLS
	di
	ld	hl, MSG1	
	call	$28a7			; Print MENU 1, VZ ROM Print string.
	ld	hl, MSG2	
	call	$28a7			; Print MENU 2, VZ ROM Print string.


;; -------------------------------
;; SPEAKER OR CASSETTE SELECTION
;; -------------------------------
	ld	a, (device)		; MENU for INVERSE SPEAKER or CASSETTE
	cp	1
	jr	z, menucas		; CASSETT PORT
	cp	2
	jr	z, menuprn		; PRINTER PORT
	ld	hl, SPEAKINV		; SPEAKER
	ld	de, 28756+32
	jr	menucon
menucas:ld	hl, CASSEINV
	ld	de, 28756+64
	jr	menucon
menuprn:ld	hl, PRINTINV
	ld	de, 28756+96
menucon:ld	bc, 12
	ldir
	ld	hl, BUSHYINV
	ld	de, 28672+27
	ld	bc, 5
	ldir
	

        di
scan:	call 	$2ef4		; VZ scan keyboard
	or 	a		; any key pressed?
	jr	z, scan		; back if not
	di
	cp	49		; "1 - "	SONG1	
	jr	z, m01		; 	
	cp	50		; "2 - "	SONG2	
	jr	z, m02
	cp	51		; "3 - " 	SONG3	
	jr	z, m03
	cp	52		; "4 - " 	SONG4
	jr	z, m04
	cp 	81		; "Q - "   	quit
	jp 	z, quit
	cp	"X"		; "X - "   	SELECT SPEAKER
	jp	z, m23
	cp	"Y"		; "Y - "   	SELECT CASSETTE PORT
	jp	z, m24
	cp	"Z"		; "Z - "   	SELECT PRINTER PORT
	jp	z, m25
	jp 	nz, begin 
;	jp 	scan 
;	jp	begin

quit: 	ei
	call	$01c9			; ROM CLS()
	jp 	$1a19			; Jump to VZ basic

m01: 	ld 	hl, SONG1
	ld	de, SONG1INV
	jp	continue
m02: 	ld 	hl, SONG2
	ld	de, SONG2INV
	jp	continue
m03: 	ld 	hl, SONG3
	ld	de, SONG3INV
	jp	continue
m04: 	ld 	hl, SONG4
	ld	de, SONG4INV
	jp	continue
m23:	ld	a, 0			; speaker
	jr	m25a
m24:	ld	a, 1			; cassette port
	jr	m25a
m25:	ld	a, 2			; printer port
m25a:	ld	(device), a		; set speaker or cass_port.
	jp	begin


continue:    
; ----------------------------------------------------
; Display inverse MENU of selection song title stuff
; ----------------------------------------------------
	push	hl		
	push	de		
	pop	hl
	ld	e, (hl)		
	inc	hl
	ld	d, (hl)		; de equ dest
	inc	hl
	ld	b, 0
	ld	c, (hl)		; get length
	inc	hl
	ldir			; and display INVERSE text.
	pop	hl	
	di


;; ----------------------------------------------------
;; You can choose only one. Choose wisely.
;; ----------------------------------------------------
	ld	a, (device)
	cp	1
	jp	z, cassette_port_player		; if set to 1, goto cassette_port_player
	cp	2
	jp	z, printer_port_player		; if set to 2, goto printer_port_player



; ----------------------------------------------------
; INTERNAL VZ/LASER SPEAKER
; ----------------------------------------------------



	di
;	exx
	push hl			;preserve HL' for return to BASIC
	ld (spkoldSP),sp
;	ld hl,musicData
	ld (spkseqpntr),hl
	ld iyl,0		;timer lo
;*******************************************************************************
spkrdseq
spkseqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (spkseqpntr),sp
	jr nz,spkrdptn0
	jp spkexit			;uncomment to disable looping	

;*******************************************************************************
spkexit
spkoldSP equ $+1
	ld sp,0
	pop hl
;	exx
	ei
	jp	begin

;*******************************************************************************
spkrdptn0	ld (spkptnpntr),de
spkreadPtn
;	in a,($fe)		;read kbd
;	cpl
;	and $1f
;	jr nz,spkexit






;#############################################
;
;
;  MODE(0) Graphical equaliser Routine.
; 	- grabs A, H, D, E
; 	- skips regs L, B, C --- but uses them in routine. 
;
; using	: A
; 	: H
; 	: L
; 	: E
; 	: D
; 	: 
; 	: 
; 	: IXH
; 	: IXL
; 	: IYL
;
;##############################################


	if equaliser = 1		;all the channels has the same volume

	push	hl
	push	de
	push	de
	push	hl
	push	hl



; l
; bc
;USED		; A, H, D, E	for fake values for bars
; NOT USED	; L, B, C


	ld 	hl, 28672+160+96	; CLEAR BITS SCREEN	
	ld	bc, 255
l0:	ld	(hl), 32
	inc	hl
	djnz	l0




	ld	c, a				; Do  reg A
	srl	a
	srl	a
	srl	a
	srl	a
	srl	a
	inc	a
	ld	b ,a
	ld	a, 143
	ld 	hl, 28672+160+320	; Offset position of colour 143
l1:	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	ld	de, 65501		; Add 65536-35 : Line above bottom right.
	add 	hl, de
	djnz	l1


	pop	hl				; Do reg H
	ld	a, h
	srl	a
	srl	a
	srl	a
	srl	a
	srl	a
	inc	a
	ld	b ,a
	ld 	hl, 28672+164+320	; Offset position of colour 159
	ld	a, 159
l2:	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	ld	de, 65501
	add 	hl, de
	djnz	l2


	pop	hl				; DO 	L
	ld	a, l
	srl	a
	srl	a
	srl	a
	srl	a
	srl	a
	inc	a
	ld	b, a
	ld 	hl, 28672+168+320	; Offset position of colour 159+16
	ld	a, 159+16
l3:	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	ld	de, 65501 	
	add 	hl, de
	djnz	l3


	pop	de				; DO 	 D
	ld	a, d
	srl	a
	srl	a
	srl	a
	srl	a
	srl	a
	inc	a
	ld	b, a
	ld 	hl, 28672+172+320
	ld	a, 159+32
l4:	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	ld	de, 65501 	;inc 29
	add 	hl, de
	djnz	l4

	pop	de				; DO reg E
	ld	a, e
	srl	a
	srl	a
	srl	a
	srl	a
	srl	a
	inc	a
	ld	b, a
	ld 	hl, 28672+176+320
	ld	a, 159+48
l5:	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	ld	de, 65501 	
	add 	hl, de
	djnz	l5


	ld	a, ixh				; DO IXH
	srl	a
	srl	a
	srl	a
	srl	a
	srl	a
	inc	a
	ld	b, a
	ld 	hl, 28672+180+320
	ld	a, 159+64
l6:	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	ld	de, 65501 	
	add 	hl, de
	djnz	l6

	ld	a, ixl				; DO IXL
	srl	a
	srl	a
	srl	a
	srl	a
	srl	a
	inc	a
	ld	b, a
	ld 	hl, 28672+184+320
	ld	a, 159+64+16
l7:	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	ld	de, 65501 	
	add 	hl, de
	djnz	l7

	ld	a, iyh				; DO IYH
	srl	a
	srl	a
	srl	a
	srl	a
	srl	a
	inc	a
	ld	b, a
	ld	a, 159+64+32
	ld 	hl, 28672+188+320
l8:	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	ld	de, 65501 
	add 	hl, de
	djnz	l8

	pop	hl

here:
	endif


spkptnpntr equ $+1
	ld sp,0	
	pop af			;speed + drums
	jp z,spkrdseq
	jp c,spkdrum1
	jp m,spkdrum2
	ex af,af'
spkdrumret	pop af			;flags + mix_method (xor = $ac, or = $b4, and = a4)
	ld (spkmixMethod),a
	jr c,spknoUpdateCh1
	exx
	ld a,$9f		;sbc a,a
	jp pe,spksetSid
	ld a,$97		;sub a,a
spksetSid ld (spksid),a
	ld hl,$04cb		;rlc h
	jp m,spksetNoise
	ld hl,$0
spksetNoise
	ld (spknoise),hl
	pop bc			;dutymod/duty 1
	ld a,b
	ld (spkdutymod1),a
	pop de			;freq1
	ld hl,0			;reset ch1 accu
	exx
spknoUpdateCh1
	jr z,spknoUpdateCh2
	pop hl			;dutymod 2a/b
	ld a,h
	ld (spkdutymod2a),a
	ld a,l
	ld (spkdutymod2b),a
	pop bc			;duty 2a/b
	pop de			;freq 2a
	pop hl			;freq 2b
	ld (spkfreq2b),hl
	pop ix			;phase 2b
	ld hl,0			;reset ch2a accu
spknoUpdateCh2
	ld (spkptnpntr),sp
spkfreq2b equ $+1
	ld sp,0
	

;*******************************************************************************	
spkplayNote
	exx			;4
	add hl,de		;11
spksid	sbc a,a			;4	;replace with sub a for no sid
	ld b,a			;4	;temp
	add a,c			;4	;c = duty
	ld c,a			;4
	ld a,b			;4
spkdutymod1 equ $+1
	and $0			;7
	xor c			;4
	ld c,a			;4
	cp h			;4
	sbc a,a			;4
spknoise	ds 2			;8	;replace with rlc h for noise
	exx			;4
	add hl,de		;11
;	out ($fe),a		;11___104
;	and 33
;	ld ($6800), a

	and 33		
	ld ($6800), a		
	xor 32		
	ld ($6800), a


	sbc a,a			;4
spkdutymod2a equ $+1
	and $0			;7
	xor b			;4
	ld b,a			;4
	cp h			;4
	sbc a,a			;4
	ld iyh,a		;8
	add ix,sp		;15
	sbc a,a			;4
spkdutymod2b equ $+1
	and $0			;7
	xor c			;4
	ld c,a			;4
	cp ixh			;8
	sbc a,a			;4
spkmixMethod equ $+1	
	and iyh			;8
	dec iyl			;8
	jr nz,spkskipTimerHi	;12
	ex af,af'
	dec a
	jp z,spkreadPtn
	ex af,af'
spkskipTimerHi	
;	out ($fe),a		;11___120
;	and 33
;	ld ($6800), a

	and 33		
	ld ($6800), a		
	xor 32		
	ld ($6800), a


	jr spkplayNote		;12
				;224


;*******************************************************************************
spkdrum2	ld (spkrestoreHL),hl
	ld (spkrestoreBC),bc
	ex af,af'
	ld hl,hat1
	ld b,hat1end-hat1
	jr spkdrentry
spkdrum1	ld (spkrestoreHL),hl
	ld (spkrestoreBC),bc
	ex af,af'
	ld hl,kick1		;10
	ld b,kick1end-kick1	;7
spkdrentry	xor a			;4
spk_s2	
;	xor BORDER		;7
	ld c,(hl)		;7
	inc hl			;6
spk_s1	
;	out ($fe),a		;11
;	and 33
;	ld ($6800), a

	and 33
	ld ($6800), a		
	xor 32
	ld ($6800), a


	dec c			;4
	jr nz,spk_s1		;12/7    
	djnz spk_s2		;13/8
	ld iyl,$7 ; $11		;7	;correct tempo
spkrestoreHL equ $+1
	ld hl,0
spkrestoreBC equ $+1
	ld bc,0
	jp spkdrumret		;10









; ######################################################################
; ######################################################################
; ######################################################################
;
cassette_port_player:			; CASSETTE PORT PLAYER.
; =====================
;
; Two seperate players, one dedicated for speaker and this one dedicated for cassette port.
; seems like a total waste of space, and yes it is. But, the player slows down too much plonking 
; in a register to vary the differing XOR 32 for speaker and XOR 6 for cassette port.
; Slow downs makes the sound sound even more worserer!  
;

	di
;	exx
	push hl			;preserve HL' for return to BASIC
	ld (cassoldSP),sp
;	ld hl,cassmusicData			
	ld (cassseqpntr),hl
	ld iyl,0		;timer lo
;*******************************************************************************
cassrdseq
cassseqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (cassseqpntr),sp
	jr nz,cassrdptn0
	jp cassexit		;uncomment to disable looping	

;*******************************************************************************
cassexit
cassoldSP equ $+1
	ld sp,0
	pop hl
;	exx
	ei
	jp	begin		

;*******************************************************************************
cassrdptn0	ld (cassptnpntr),de
cassreadPtn
;	in a,($fe)		;read kbd
;	cpl
;	and $1f
;	jr nz,exit

	ld 	a, (0x68EF)			; 	M key = menu
	and	$20
	jr 	nz, cassnot_m
	jp	begin	

cassnot_m:


cassptnpntr equ $+1
	ld sp,0	
	pop af			;speed + drums
	jr z,cassrdseq
	jp c,cassdrum1		
	jp m,cassdrum2
	ex af,af'
cassdrumret	pop af			;flags + mix_method (xor = $ac, or = $b4, and = a4)
	ld (cassmixMethod),a
	jr c,cassnoUpdateCh1
	exx
	ld a,$9f		;sbc a,a
	jp pe,casssetSid
	ld a,$97		;sub a,a
casssetSid	ld (casssid),a
	ld hl,$04cb		;rlc h
	jp m,casssetNoise
	ld hl,$0
casssetNoise
	ld (cassnoise),hl
	pop bc			;dutymod/duty 1
	ld a,b
	ld (cassdutymod1),a
	pop de			;freq1
	ld hl,0			;reset ch1 accu
	exx
cassnoUpdateCh1
	jr z,cassnoUpdateCh2
	pop hl			;dutymod 2a/b
	ld a,h
	ld (cassdutymod2a),a
	ld a,l
	ld (cassdutymod2b),a
	pop bc			;duty 2a/b
	pop de			;freq 2a
	pop hl			;freq 2b
	ld (cassfreq2b),hl
	pop ix			;phase 2b
	ld hl,0			;reset ch2a accu
cassnoUpdateCh2
	ld (cassptnpntr),sp
cassfreq2b equ $+1
	ld sp,0
	

;*******************************************************************************	
cassplayNote
	exx			;4
	add hl,de		;11
casssid	sbc a,a			;4	;replace with sub a for no sid
	ld b,a			;4	;temp
	add a,c			;4	;c = duty
	ld c,a			;4
	ld a,b			;4
cassdutymod1 equ $+1
	and $0			;7
	xor c			;4
	ld c,a			;4
	cp h			;4
	sbc a,a			;4
cassnoise	ds 2			;8	;replace with rlc h for noise
	exx			;4
	add hl,de		;11
;	out ($fe),a		;11___104
	and 6
	ld ($6800), a
	sbc a,a			;4
cassdutymod2a equ $+1
	and $0			;7
	xor b			;4
	ld b,a			;4
	cp h			;4
	sbc a,a			;4
	ld iyh,a		;8
	add ix,sp		;15
	sbc a,a			;4
cassdutymod2b equ $+1
	and $0			;7
	xor c			;4
	ld c,a			;4
	cp ixh			;8
	sbc a,a			;4
cassmixMethod equ $+1	
	and iyh			;8
	dec iyl			;8
	jr nz,cassskipTimerHi	;12
	ex af,af'
	dec a
	jp z,cassreadPtn
	ex af,af'
cassskipTimerHi	
;	out ($fe),a		;11___120
	and 6
	ld ($6800), a
	jr cassplayNote		;12
				;224


;*******************************************************************************
cassdrum2	ld (cassrestoreHL),hl
	ld (cassrestoreBC),bc
	ex af,af'
	ld hl,hat1
	ld b,hat1end-hat1
	jr cassdrentry
cassdrum1	ld (cassrestoreHL),hl
	ld (cassrestoreBC),bc
	ex af,af'
	ld hl,kick1		;10
	ld b,kick1end-kick1	;7
cassdrentry	xor a			;4
cass_s2	
;	xor BORDER		;7
	ld c,(hl)		;7
	inc hl			;6
cass_s1	
;	out ($fe),a		;11
	and 6
	ld ($6800), a
	dec c			;4
	jr nz,cass_s1		;12/7    
	djnz cass_s2		;13/8
	ld iyl,$11		;7	;correct tempo
cassrestoreHL equ $+1
	ld hl,0
cassrestoreBC equ $+1
	ld bc,0
	jp cassdrumret		;10






; ######################################################################
; ######################################################################
; ######################################################################
;
; ---------------------------------------------------------------------
printer_port_player:				; PRINTER PORT PLAYER.
; ---------------------------------------------------------------------
;
; An experimental printer port 1-bit player.Possibly a first for the VZ!
; Using OUT(14), A
;

	di
;	exx
	push hl			;preserve HL' for return to BASIC
	ld (prnoldSP),sp
;	ld hl,prnmusicData	; <------FIX
	ld (prnseqpntr),hl
	ld iyl,0		;timer lo
;*******************************************************************************
prnrdseq
prnseqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (prnseqpntr),sp
	jr nz,prnrdptn0
	jp prnexit		;uncomment to disable looping	

;*******************************************************************************
prnexit
prnoldSP equ $+1
	ld sp,0
	pop hl
;	exx
	ei
	jp	begin

;*******************************************************************************
prnrdptn0	ld (prnptnpntr),de
prnreadPtn
;	in a,($fe)		;read kbd
;	cpl
;	and $1f
;	jr nz,prnexit

	ld 	a, (0x68EF)			; 	M key = menu
	and	$20
	jr 	nz, prnnot_m
	jp	begin	

prnnot_m:


prnptnpntr equ $+1
	ld sp,0	
	pop af			;speed + drums
	jr z,prnrdseq
	jp c,prndrum1
	jp m,prndrum2
	ex af,af'
prndrumret	pop af			;flags + mix_method (xor = $ac, or = $b4, and = a4)
	ld (prnmixMethod),a
	jr c,prnnoUpdateCh1
	exx
	ld a,$9f		;sbc a,a
	jp pe,prnsetSid
	ld a,$97		;sub a,a
prnsetSid	ld (prnsid),a
	ld hl,$04cb		;rlc h
	jp m,prnsetNoise
	ld hl,$0
prnsetNoise
	ld (prnnoise),hl
	pop bc			;dutymod/duty 1
	ld a,b
	ld (prndutymod1),a
	pop de			;freq1
	ld hl,0			;reset ch1 accu
	exx
prnnoUpdateCh1
	jr z,prnnoUpdateCh2
	pop hl			;dutymod 2a/b
	ld a,h
	ld (prndutymod2a),a
	ld a,l
	ld (prndutymod2b),a
	pop bc			;duty 2a/b
	pop de			;freq 2a
	pop hl			;freq 2b
	ld (prnfreq2b),hl
	pop ix			;phase 2b
	ld hl,0			;reset ch2a accu
prnnoUpdateCh2
	ld (prnptnpntr),sp
prnfreq2b equ $+1
	ld sp,0
	

;*******************************************************************************	
prnplayNote
	exx			;4
	add hl,de		;11
prnsid	sbc a,a			;4	;replace with sub a for no sid
	ld b,a			;4	;temp
	add a,c			;4	;c = duty
	ld c,a			;4
	ld a,b			;4
prndutymod1 equ $+1
	and $0			;7
	xor c			;4
	ld c,a			;4
	cp h			;4
	sbc a,a			;4
prnnoise	ds 2			;8	;replace with rlc h for noise
	exx			;4
	add hl,de		;11
	out (14),a		;11___104
	sbc a,a			;4
prndutymod2a equ $+1
	and $0			;7
	xor b			;4
	ld b,a			;4
	cp h			;4
	sbc a,a			;4
	ld iyh,a		;8
	add ix,sp		;15
	sbc a,a			;4
prndutymod2b equ $+1
	and $0			;7
	xor c			;4
	ld c,a			;4
	cp ixh			;8
	sbc a,a			;4
prnmixMethod equ $+1	
	and iyh			;8
	dec iyl			;8
	jr nz,prnskipTimerHi	;12
	ex af,af'
	dec a
	jp z,prnreadPtn
	ex af,af'
prnskipTimerHi	
	out (14),a		;11___120
	jr prnplayNote		;12
				;224


;*******************************************************************************
prndrum2	ld (prnrestoreHL),hl
	ld (prnrestoreBC),bc
	ex af,af'
	ld hl,hat1
	ld b,hat1end-hat1
	jr prndrentry
prndrum1	ld (prnrestoreHL),hl
	ld (prnrestoreBC),bc
	ex af,af'
	ld hl,kick1		;10
	ld b,kick1end-kick1	;7
prndrentry	xor a			;4
prn_s2	
;	xor BORDER		;7
	ld c,(hl)		;7
	inc hl			;6
prn_s1	
	out (14),a		;11
	dec c			;4
	jr nz,prn_s1		;12/7    
	djnz prn_s2		;13/8
	ld iyl,$11		;7	;correct tempo
prnrestoreHL equ $+1
	ld hl,0
prnrestoreBC equ $+1
	ld bc,0
	jp prndrumret		;10












SPEAKINV db 19,16,05,01,11,05,18,"     "		; SPEAKER
CASSEINV db 03,01,19,19,05,20,20,32,16,15,18,20		; CASSETT PORT
PRINTINV db 16,18,09,14,20,05,18,32,16,15,18,20		; PRINTER PORT
BUSHYINV db "BUSHY"

;1 A		10 j 		19 s
;2 B		11 k 		20 t
;3 C		12 l 		21 u
;4 D		13 m 		22 v
;5 E		14 n  		23 w
;6 F		15 o    	24 x
;7 G		16 p    	25 y
;8 h		17 q		26 z
;9 i		18 r
		

;-------------------------------------
; Inverse menu items.
; destination.
; Length, title.
;----------------			
SONG1INV	dw 28672+98		  	         ; SONG 1. FROEN MOHAWK
		db 12,06,18,15,05,14,32,13,15,08,01,23,11
SONG2INV	dw 28672+130			         ; SONG 2. LAST SUMME
		db 11,12,01,19,20,32,19,21,13,13,05,18
SONG3INV  	dw 28674+128+32			         ; SONG 3. PHASERX DEMO 2
		db 13,16,08,01,19,05,18,24,32,04,05,13,15,49
SONG4INV  	dw 28674+128+64			         ; SONG 4. PHASERX DEMO 2
		db 13,16,08,01,19,05,18,24,32,04,05,13,15,50


MSG1: 	db	    "PHASER-X MUSIC BOX! "
	db 	$d
	db	$d, "SELECT:          Q: QUIT "
	db 	$d, "1 FROEN MOHAWK   X: SPEAKER"
	db 	$d, "2 LAST SUMMER    Y: CASSETT PORT",0
MSG2:	db	    "3 PHASERX DEMO1  Z: PRINTER PORT" 
	db	$d, "4 PHASERX DEMO2"
	db	$d, "         ",0


device		db 0			; 0=speaker.  1=Cassette Port.  2=Printer Port.
outdevice	db 33


; 
; 
; 
; 




;*******************************************************************************

;IF ((LOW($)) != 0)
;    org 256*(1+(HIGH($)))
;
;ENDIF




	
kick1					;27*16*4 + 27*32*4 + 27*64*4 + 27*128*4 + 27*256*4 = 53568, + 20*33 = 53568 -> -239 loops -> AF' = $11
	ds 4,$10
	ds 4,$20
	ds 4,$40
	ds 4,$80
	ds 4,0
kick1end

hat1	db 16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3,16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3
	db 12,8,1,24,6,7,4,9,18,12,8,3,11,7,5,8,3,17,9,15,22,6,5,8,11,13,4,8,12,9,2,4,7,8,12,6,7,4,19,22,1,9,6,27,4,3,11
	db 5,8,14,2,11,13,5,9,2,17,10,3,7,19,4,3,8,2,9,11,4,17,6,4,9,14,2,22,8,4,19,2,3,5,11,1,16,20,4,7
	db 8,9,4,12,2,8,14,3,7,7,13,9,15,1,8,4,17,3,22,4,8,11,4,21,9,6,12,4,3,8,7,17,5,9,2,11,17,4,9,3,2
	db 22,4,7,3,8,9,4,11,8,5,9,2,6,2,8,8,3,11,5,3,9,6,7,4,8
hat1end







;IF ((LOW($)) != 0)
;    org 256*(1+(HIGH($)))
;
;ENDIF



; ============================================================
FROENmusicData:
SONG1:
; ============================================================

froenloop
	dw song1_Patterns_intro
	dw song1_Patterns_ptn3old
	dw song1_Patterns_ptn3oldB
	dw song1_Patterns_ptn3
	dw song1_Patterns_ptn3b
	dw song1_Patterns_ptn4a
	dw song1_Patterns_ptn7a
	dw song1_Patterns_ptn9
	dw song1_Patterns_ptn11
	dw song1_Patterns_trans9
	dw song1_Patterns_ptn40
	dw song1_Patterns_ptn50
	dw song1_Patterns_ptn5z
	dw song1_Patterns_ptn60
	dw song1_Patterns_ptn6b
	dw song1_Patterns_ptn60
	dw song1_Patterns_ptn6a
	dw song1_Patterns_ptn70
	dw song1_Patterns_ptn7a
	dw song1_Patterns_ptny
	dw 0


song1_Patterns_intro

	dw $780, $ac00, $80, 0, $2000, $1010, a3, a3+1, 0
	dw $700, $ac01, $2000, $1010, b3, b3+1, 0
	dw $700, $ac01, $2000, $1010, c4, c4+1, 0
	dw $700, $ac01, $2000, $1010, d4, d4+1, 0
	db $40



song1_Patterns_ptn3old

	dw $601, $ac04, $10, e3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $10, f3, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $10, g3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $10, f3, $8000, $1020, gis2, gis1+1, 0
	dw $601, $ac45
	dw $601, $ac04, $10, e3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $10, d3, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $10, c3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac45
	dw $680, $ac45
	dw $601, $ac05, $8000, $1020, f2, f1+1, 0
	dw $600, $ac45
	dw $601, $ac45
	dw $601, $ac05, $8000, $1020, f2, f1+1, 0
	dw $600, $ac05, $8000, $1020, f2, f1+1, 0
	dw $601, $ac45
	dw $601, $ac04, $10, d3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac05, $8000, $1020, e2, e1+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $600, $ac05, $8000, $1020, e2, e1+1, 0
	dw $680, $ac45
	db $40



song1_Patterns_ptn3oldB

	dw $601, $ac04, $10, e3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $10, f3, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $10, g3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $601, $ac04, $10, f3, $8000, $1020, gis2, gis1+1, 0
	dw $600, $ac45
	dw $601, $ac04, $10, e3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $10, d3, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $10, c3, $8000, $1020, f2, f1+1, 0
	dw $601, $ac45
	dw $680, $ac45
	dw $601, $ac05, $8000, $1020, f2, f1+1, 0
	dw $600, $ac45
	dw $601, $ac45
	dw $601, $ac05, $8000, $1020, f2, f1+1, 0
	dw $600, $ac05, $8000, $1020, f2, f1+1, 0
	dw $601, $ac45
	dw $601, $ac05, $8000, $1020, f2, f1+1, 0
	dw $600, $ac05, $8000, $1020, e2, e1+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $600, $ac05, $8000, $1020, e2, e1+1, 0
	dw $680, $ac45
	db $40



song1_Patterns_ptn3

	dw $601, $ac04, $3010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $3010, c4
	dw $600, $ac44, $3010, e4
	dw $601, $ac44, $3010, c4
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $3010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $3010, c4
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, e4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $3010, c4
	dw $680, $ac04, $3010, f4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac44, $3010, c4
	dw $601, $ac04, $3010, g4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $3010, c4
	dw $600, $ac44, $3010, g4
	dw $601, $ac44, $3010, c4
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $3010, g4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $3010, c4
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, g4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $3010, c4
	dw $680, $ac04, $3010, f4, $8000, $1020, gis2, gis1+1, 0
	dw $601, $ac44, $3010, c4
	dw $601, $ac04, $3010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $3010, d4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $3010, c4, $8000, $1020, f2, f1+1, 0
	dw $600, $ac45
	dw $680, $ac45
	dw $601, $ac05, $8000, $1020, f2, f1+1, 0
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, f2, f1+1, 0
	dw $600, $ac05, $8000, $1020, f2, f1+1, 0
	dw $601, $ac45
	dw $601, $ac04, $3010, d4, $8000, $1020, f2, f1+1, 0
	dw $680, $ac05, $8000, $1020, e2, e1+1, 0
	dw $601, $ac45
	dw $601, $ac05, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $600, $ac05, $8000, $1020, e2, e1+1, 0
	dw $680, $ac45
	db $40



song1_Patterns_ptn3b

	dw $601, $ac04, $3010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $3010, c4
	dw $600, $ac44, $3010, e4
	dw $601, $ac44, $3010, c4
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $3010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $3010, c4
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, e4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $3010, c4
	dw $680, $ac04, $3010, f4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac44, $3010, c4
	dw $601, $ac04, $3010, g4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $3010, c4
	dw $600, $ac44, $3010, g4
	dw $601, $ac44, $3010, c4
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $3010, g4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $3010, c4
	dw $680, $ac04, $3010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $3010, g4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $3010, c4
	dw $601, $ac04, $3010, f4, $8000, $1020, gis2, gis1+1, 0
	dw $600, $ac44, $3010, c4
	dw $601, $ac04, $3010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $3010, d4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $3010, c4, $8000, $1020, f2, f1+1, 0
	dw $601, $ac45
	dw $680, $ac45
	dw $601, $ac05, $8000, $1020, f2, f1+1, 0
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, f2, f1+1, 0
	dw $600, $ac05, $8000, $1020, f2, f1+1, 0
	dw $601, $ac45
	dw $601, $ac05, $8000, $1020, f2, f1+1, 0
	dw $680, $ac05, $8000, $1020, e2, e1+1, 0
	dw $601, $ac45
	dw $601, $ac05, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $600, $ac05, $8000, $1020, e2, e1+1, 0
	dw $680, $ac45
	db $40



song1_Patterns_ptn4a

	dw $601, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $2010, ais2, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $2010, a2
	dw $680, $ac04, $2010, gis2, $8000, $1020, gis2, gis1+1, 0
	dw $600, $ac45
	dw $601, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $2010, ais2, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $2010, gis2, $8000, $1020, gis2, gis1+1, 0
	dw $600, $ac45
	db $40



song1_Patterns_ptn7a

	dw $600, $ac00, $80, rest, $4000, $1020, a2, a0+1, 0
	dw $600, $ac01, $4000, $1020, a2, a0+1, 0
	dw $680, $ac01, $4000, $1020, a2, a0+1, 0
	dw $600, $ac41
	dw $600, $ac41
	dw $600, $ac41
	dw $680, $ac01, $4000, $1020, a2, a0+1, 0
	dw $600, $ac01, $4000, $1020, a2, a0+1, 0
	dw $600, $ac01, $4000, $1020, a2, a0+1, 0
	dw $600, $ac41
	dw $680, $ac01, $4000, $1020, a2, a0+1, 0
	dw $600, $ac01, $4000, $1020, a2, a0+1, 0
	dw $600, $ac01, $4000, $1020, a2, a0+1, 0
	dw $600, $ac41
	dw $680, $ac01, $4000, $1020, ais2, ais0+1, 0
	dw $600, $ac41
	dw $600, $ac01, $2000, $820, a2, a0+1, 0
	dw $600, $ac01, $2000, $820, a2, a0+1, 0
	dw $680, $ac01, $2000, $820, a2, a0+1, 0
	dw $600, $ac41
	dw $600, $ac41
	dw $600, $ac41
	dw $680, $ac01, $2000, $820, a2, a0+1, 0
	dw $600, $ac01, $2000, $820, a2, a0+1, 0
	dw $600, $ac01, $2000, $820, a2, a0+1, 0
	dw $600, $ac41
	dw $680, $ac01, $2000, $820, a2, a0+1, 0
	dw $600, $ac01, $2000, $820, a2, a0+1, 0
	dw $600, $ac01, $2000, $820, a2, a0+1, 0
	dw $600, $ac41
	dw $680, $ac01, $2000, $820, gis2, gis1+1, 0
	dw $600, $ac41
	dw $600, $ac01, $1000, $420, a2, a0+1, 0
	dw $600, $ac01, $1000, $420, a2, a0+1, 0
	dw $680, $ac01, $1000, $420, a2, a0+1, 0
	dw $600, $ac41
	dw $600, $ac41
	dw $600, $ac41
	dw $680, $ac01, $1000, $420, a2, a0+1, 0
	dw $600, $ac01, $1000, $420, a2, a0+1, 0
	dw $600, $ac01, $1000, $420, a2, a0+1, 0
	dw $600, $ac41
	dw $680, $ac01, $1000, $420, a2, a0+1, 0
	dw $600, $ac01, $1000, $420, a2, a0+1, 0
	dw $600, $ac01, $1000, $420, a2, a0+1, 0
	dw $600, $ac41
	dw $680, $ac01, $1000, $420, a2, a0+1, 0
	dw $600, $ac41
	dw $600, $ac01, $800, $210, f2, f1+1, 0
	dw $600, $ac41
	dw $680, $ac41
	dw $600, $ac01, $800, $210, f2, f1+1, 0
	dw $600, $ac41
	dw $600, $ac41
	dw $680, $ac01, $800, $210, f2, f1+1, 0
	dw $600, $ac01, $800, $210, f2, f1+1, 0
	dw $600, $ac41
	dw $600, $ac01, $800, $210, f2, f1+1, 0
	dw $680, $ac01, $800, $210, e2, e1+1, 0
	dw $600, $ac41
	dw $600, $ac01, $800, $210, e2, e1+1, 0
	dw $600, $ac41
	dw $680, $ac01, $800, $210, e2, e1+1, 0
	dw $600, $ac41
	db $40



song1_Patterns_ptn9

	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $601, $ac45
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $600, $ac45
	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $601, $ac45
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $600, $ac45
	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $601, $ac45
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $601, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	db $40



song1_Patterns_ptn11

	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, b3
	dw $600, $ac44, $8010, c4
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, c4
	dw $600, $ac44, $8010, d4
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, e4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $8010, d4
	dw $680, $ac04, $8010, c4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac44, $8010, b3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, b3
	dw $600, $ac44, $8010, c4
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	db $40



song1_Patterns_trans9

	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	db $40



song1_Patterns_ptn40

	dw $601, $ac04, $2010, a2, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, gis2, gis1+1, 0
	dw $600, $ac45
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $600, $ac05, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac05, $8000, $1020, gis2, gis1+1, 0
	dw $600, $ac45
	db $40



song1_Patterns_ptn50

	dw $601, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $600, $ac44, $8010, d4
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, e4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac44, $8010, a3
	dw $601, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $600, $ac44, $8010, d4
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, e4, $8000, $1020, gis2, gis1+1, 0
	dw $600, $ac44, $8010, a3
	dw $601, $ac04, $8010, b3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, f2, f1+1, 0
	dw $680, $ac04, $8010, d4, $8000, $1020, f2, f1+1, 0
	dw $600, $ac44, $8010, a3
	dw $600, $ac44, $8010, c4
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, b3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, f2, f1+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, f2, f1+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, f2, f1+1, 0
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, e4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac44, $8010, a3
	dw $601, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $680, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, e2, e1, 0
	dw $600, $ac45
	db $40



song1_Patterns_ptn5z

	dw $601, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $600, $ac44, $8010, d4
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, e4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac44, $8010, a3
	dw $601, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $600, $ac44, $8010, d4
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, e4, $8000, $1020, gis2, gis1+1, 0
	dw $600, $ac44, $8010, a3
	dw $601, $ac04, $8010, b3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, f2, f1+1, 0
	dw $680, $ac04, $8010, d4, $8000, $1020, f2, f1+1, 0
	dw $600, $ac44, $8010, a3
	dw $600, $ac44, $8010, c4
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, b3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, f2, f1+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, f2, f1+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, f2, f1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, f2, f1+1, 0
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, e4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac44, $8010, a3
	dw $601, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $680, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, e2, e1+1, 0
	dw $601, $ac45
	dw $601, $ac04, $8010, b3, $8000, $1020, e2, e1, 0
	dw $601, $ac45
	db $40



song1_Patterns_ptn60:

	dw $601, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $601, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $680, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $601, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, b3, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, gis2, $8000, $1020, gis2, gis1+1, 0
	dw $601, $ac45
	db $40



song1_Patterns_ptn6b

	dw $601, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $601, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $680, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $601, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, c4
	dw $600, $ac44, $8010, c4
	dw $601, $ac44, $8010, c4
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, c4
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $601, $ac44, $8010, c4
	dw $680, $ac04, $8010, c4, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac44, $8010, c4
	dw $601, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, e4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $600, $ac44, $8010, d4
	dw $601, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, b3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac44, $8010, a3
	dw $680, $ac04, $8010, c4, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, d4, $8000, $1020, a2, a0+1, 0
	dw $680, $ac44, $8010, a3
	dw $601, $ac04, $8010, e4, $8000, $1020, gis2, gis1+1, 0
	dw $601, $ac44, $8010, a3
	db $40



song1_Patterns_ptn6a

	dw $601, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $601, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $680, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $601, $ac04, $8010, e4, $8000, $1020, e2, e1+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $600, $ac04, $8010, d4, $8000, $1020, d2, d1+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, d4, $8000, $1020, d2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, a3, $8000, $1020, ais2, ais0+1, 0
	dw $680, $ac45
	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $600, $ac45
	dw $601, $ac45
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac45
	dw $680, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $600, $ac04, $8010, a3, $8000, $1020, a2, a0+1, 0
	dw $601, $ac45
	dw $680, $ac04, $8010, ais2, $8000, $1020, gis2, gis1+1, 0
	dw $601, $ac44, $8010, b2
	db $40



song1_Patterns_ptn70

	dw $600, $ac00, $80, rest, $1080, $2020, a2, a1+1, 0
	dw $600, $ac01, $1080, $2020, a2, a1+1, 0
	dw $680, $ac01, $1080, $2020, a2, a1+1, 0
	dw $600, $ac41
	dw $600, $ac41
	dw $600, $ac41
	dw $680, $ac01, $1080, $2020, a2, a1+1, 0
	dw $600, $ac01, $1080, $2020, a2, a1+1, 0
	dw $600, $ac01, $1080, $2020, a2, a1+1, 0
	dw $600, $ac41
	dw $680, $ac01, $1080, $2020, a2, a1+1, 0
	dw $600, $ac01, $1080, $2020, a2, a1+1, 0
	dw $600, $ac01, $1080, $2020, a2, a1+1, 0
	dw $600, $ac41
	dw $680, $ac01, $1080, $2020, ais2, ais1+1, 0
	dw $600, $ac41
	dw $600, $ac01, $8080, $2010, a2, a1+1, 0
	dw $600, $ac01, $8080, $2010, a2, a1+1, 0
	dw $680, $ac01, $8080, $2010, a2, a1+1, 0
	dw $600, $ac41
	dw $600, $ac41
	dw $600, $ac41
	dw $680, $ac01, $8080, $2010, a2, a1+1, 0
	dw $600, $ac01, $8080, $2010, a2, a1+1, 0
	dw $600, $ac01, $8080, $2010, a2, a1+1, 0
	dw $600, $ac41
	dw $680, $ac01, $8080, $2010, a2, a1+1, 0
	dw $600, $ac01, $8080, $2010, a2, a1+1, 0
	dw $600, $ac01, $8080, $2010, a2, a1+1, 0
	dw $600, $ac41
	dw $680, $ac01, $8080, $2010, gis2, gis1+1, 0
	dw $600, $ac41
	dw $600, $ac01, $8080, $4010, a2, a0+1, 0
	dw $600, $ac01, $8080, $4010, a2, a0+1, 0
	dw $680, $ac01, $8080, $4010, a2, a0+1, 0
	dw $600, $ac41
	dw $600, $ac41
	dw $600, $ac41
	dw $680, $ac01, $8080, $4010, a2, a0+1, 0
	dw $600, $ac01, $8080, $4010, a2, a0+1, 0
	dw $600, $ac01, $8080, $4010, a2, a0+1, 0
	dw $600, $ac41
	dw $680, $ac01, $8080, $4010, a2, a0+1, 0
	dw $600, $ac01, $8080, $4010, a2, a0+1, 0
	dw $600, $ac01, $8080, $4010, a2, a0+1, 0
	dw $600, $ac41
	dw $680, $ac01, $8080, $4010, a2, a0+1, 0
	dw $600, $ac41
	dw $600, $ac01, $8080, $2010, f2, f1+1, 0
	dw $600, $ac41
	dw $680, $ac41
	dw $600, $ac01, $8080, $2010, f2, f1+1, 0
	dw $600, $ac41
	dw $600, $ac41
	dw $680, $ac01, $8080, $2010, f2, f1+1, 0
	dw $600, $ac01, $8080, $2010, f2, f1+1, 0
	dw $600, $ac41
	dw $600, $ac01, $8080, $2010, f2, f1+1, 0
	dw $680, $ac01, $8080, $2010, e2, e1+1, 0
	dw $600, $ac41
	dw $600, $ac01, $8080, $2010, e2, e1+1, 0
	dw $600, $ac41
	dw $680, $ac01, $8080, $2010, e2, e1+1, 0
	dw $600, $ac41
	db $40



song1_Patterns_ptny

	dw $1800, $ac00, $10, e1, 0, $8080, 0, 0, 0
	dw $901, $ac04, $1010, a4, $8000, $1020, a2, a0+1, 0
	dw $300, $ac44, $1010, e4
	dw $300, $ac44, $1010, c4
	dw $300, $ac44, $1010, a3
	dw $300, $ac44, $1010, rest
	dw $300, $ac45
	dw $300, $ac05, $8000, $1020, rest, a0+1, 0
	dw $300, $ac45
	dw $300, $ac05, $8000, $1020, rest, rest, 0
	dw $300, $ac45
	dw $8000, $ac45
	db $40






;IF ((LOW($)) != 0)
;    org 256*(1+(HIGH($)))
;ENDIF


; ===============================================================================
; Last Summer
SONG2:
; ===============================================================================


	dw SONG2_Patterns_pattern00
	dw SONG2_Patterns_blk0
	dw SONG2_Patterns_blk24
	dw SONG2_Patterns_blk1
	dw SONG2_Patterns_blk2
	dw SONG2_Patterns_blk4
	dw SONG2_Patterns_blk6
	dw SONG2_Patterns_blk23
	dw SONG2_Patterns_blk3
	dw SONG2_Patterns_blk5
	dw SONG2_Patterns_blk7
	dw SONG2_Patterns_blk8
	dw SONG2_Patterns_blk9
	dw SONG2_Patterns_blk10
SONG2loop:
	dw SONG2_Patterns_blk11
	dw SONG2_Patterns_blk12
	dw SONG2_Patterns_blk11
	dw SONG2_Patterns_blk13
	dw SONG2_Patterns_blk14
	dw SONG2_Patterns_blk15
	dw SONG2_Patterns_blk18
	dw SONG2_Patterns_blk19
	dw SONG2_Patterns_blk20
	dw SONG2_Patterns_blk20
	dw SONG2_Patterns_blk20
	dw SONG2_Patterns_blk21
	dw SONG2_Patterns_blk22
	dw 0


SONG2_Patterns_pattern00

	dw $800, $ac04, $80, b3, 0, $8080, 0, 0, 0
	dw $800, $ac44, $80, a3
	dw $800, $ac44, $80, g3
	dw $800, $ac44, $80, a3
	dw $800, $ac44, $80, g3
	dw $800, $ac44, $80, d3
	db $40



SONG2_Patterns_blk0

	dw $401, $ac04, $4010, e2, $4010, $1080, e1, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac80, $4040, gis4, $4010, $1080, e2, e1+1, $400
	dw $400, $acc0, $4020, gis4
	dw $400, $acc0, $4010, gis4
	dw $400, $acc1
	dw $400, $acc0, $4008, gis4
	dw $400, $ac40, $4008, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e2, $4010, $1080, e1, e1+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, e2, $4010, $1080, e1, e1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	db $40



SONG2_Patterns_blk24

	dw $401, $ac04, $4010, e2, $4010, $1080, e1, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac80, $4040, gis4, $4010, $1080, e2, e1+1, $400
	dw $400, $acc0, $4020, gis4
	dw $400, $acc0, $4010, gis4
	dw $400, $acc1
	dw $400, $acc0, $4008, gis4
	dw $400, $ac40, $4008, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e2, $4010, $1080, e1, e1+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, e2, $4010, $1080, e1, e1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	db $40



SONG2_Patterns_blk1

	dw $401, $ac04, $4080, a2, $4010, $1080, a1, a1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4080, rest
	dw $400, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $401, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac80, $40, gis4, $4010, $1080, a1, a1+1, $400
	dw $400, $acc0, $20, gis4
	dw $400, $acc0, $10, gis4
	dw $400, $acc1
	dw $400, $acc0, $8, gis4
	dw $400, $ac40, $8, rest
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $480, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $400, $ac45
	dw $400, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $400, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $400, $ac45
	db $40



SONG2_Patterns_blk2

	dw $401, $ac04, $4080, a2, $4010, $1080, a1, a1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4080, rest
	dw $400, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4080, a1, $4010, $1080, a1, a1+1, $400
	dw $401, $ac04, $4080, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac80, $4040, gis4, $4010, $1080, a1, a1+1, $400
	dw $400, $acc0, $4020, gis4
	dw $400, $acc0, $4010, gis4
	dw $400, $acc1
	dw $400, $acc0, $4008, gis4
	dw $400, $ac40, $4008, rest
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $400, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, a1, $4010, $1080, a1, a1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, a1+1, $400
	dw $401, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, b1, $4010, $1080, b1, b1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, b1+1, $400
	dw $400, $ac04, $4010, b1, $4010, $1080, b1, b1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, b1+1, $400
	dw $401, $ac04, $4010, b1, $4010, $1080, b1, b1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, b1+1, $400
	dw $401, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, b2, $4010, $1080, b1, b1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, a2, $4010, $1080, a1, a1+1, $400
	dw $401, $ac45
	dw $401, $ac04, $4010, g2, $4010, $1080, g1, g1+1, $400
	dw $401, $ac45
	db $40



SONG2_Patterns_blk4

	dw $401, $ac04, $8040, e1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, e4, e3+1, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, a4, a3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac84, $8040, gis4, $2040, $1010, a4, a3+1, $400
	dw $400, $acc4, $8020, gis4
	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	db $40



SONG2_Patterns_blk6

	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, fis4, fis3+2, $400
	dw $401, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, e4, e3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, g1
	dw $400, $ac45
	dw $401, $b404, $8040, fis3, $2040, $c0f0, e2, fis3, $400
	dw $400, $b445
	dw $401, $b404, $8040, g3, $2040, $c0f0, g2, g3, $400
	dw $400, $b445
	dw $401, $b480, $8040, gis4, $2040, $c0f0, b2, b3, $400
	dw $400, $b4c0, $8020, gis4
	dw $401, $b404, $8040, g3, $2040, $c0f0, a2, g3, $400
	dw $401, $b445
	dw $401, $b404, $8040, fis3, $2040, $c0f0, g2, fis3, $400
	dw $400, $b445
	db $40



SONG2_Patterns_blk23

	dw $401, $ac04, $8040, e1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, e4, e3+1, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, a4, a3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac84, $8040, gis4, $2040, $1010, a4, a3+1, $400
	dw $400, $acc4, $8020, gis4
	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+1, $400
	dw $401, $ac45
	dw $401, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	db $40



SONG2_Patterns_blk3

	dw $401, $ac04, $8020, e1, $2040, $1010, g4, g3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8020, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, g1
	dw $400, $ac45
	dw $401, $b404, $8040, fis3, $2040, $c0f0, e2, fis3, $400
	dw $400, $b445
	dw $401, $b404, $8040, g3, $2040, $c0f0, g2, g3, $400
	dw $400, $b445
	dw $401, $b480, $8040, gis4, $2040, $c0f0, b2, b3, $400
	dw $401, $b4c0, $8020, gis4
	dw $401, $b404, $8040, g3, $2040, $c0f0, a2, g3, $400
	dw $400, $b445
	dw $401, $b404, $8040, fis3, $2040, $c0f0, g2, fis3, $400
	dw $400, $b445
	db $40



SONG2_Patterns_blk5

	dw $401, $ac04, $8040, a1, $2040, $1010, c5, c4+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac04, $8040, a1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, a1, $2040, $1010, a4, a3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $401, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $400, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac84, $8040, gis4, $2040, $1010, a4, a3+1, $400
	dw $400, $acc4, $8020, gis4
	dw $401, $ac04, $8040, a1, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	db $40



SONG2_Patterns_blk7

	dw $401, $ac04, $8040, a1, $2040, $1010, c5, c4+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $401, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac44, $8040, a1
	dw $400, $ac45
	dw $401, $ac04, $8040, g1, $2040, $1010, e5, e4, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, fis3, $2040, $1010, d5, d4, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, g3, $2040, $1010, c5, c4, $400
	dw $400, $ac45
	dw $401, $ac80, $8040, gis4, $2040, $1010, d5, d4, $400
	dw $400, $acc0, $8020, gis4
	dw $401, $ac04, $8040, g3, $2040, $1010, c5, c4, $400
	dw $401, $ac45
	dw $401, $ac04, $8040, fis3, $2040, $1010, d4, d3, $400
	dw $400, $ac45
	db $40



SONG2_Patterns_blk8

	dw $401, $ac04, $8040, e1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, a4, a3+1, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+2, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $480, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac84, $8040, gis4, $2040, $1010, a4, a3+1, $400
	dw $400, $acc4, $8020, gis4
	dw $401, $ac04, $8040, e1, $2040, $1010, g4, g3+1, $400
	dw $400, $ac45
	dw $401, $ac05, $2040, $1010, fis4, fis3+1, $400
	dw $400, $ac45
	db $40



SONG2_Patterns_blk9

	dw $401, $ac04, $8040, e1, $2040, $1010, b4, b3+1, $400
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $401, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $acc0, $8040, gis4
	dw $400, $acc0, $8020, gis4
	dw $400, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac44, $8040, e1
	dw $400, $ac45
	dw $401, $ac04, $8040, g1, $2040, $1010, e5, e4, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, fis3, $2040, $1010, d5, d4, $400
	dw $400, $ac45
	dw $401, $ac04, $8040, g3, $2040, $1010, c5, c4, $400
	dw $400, $ac45
	dw $401, $ac80, $8040, gis4, $2040, $1010, d5, d4, $400
	dw $400, $acc0, $8020, gis4
	dw $401, $ac04, $8040, g3, $2040, $1010, c5, c4, $400
	dw $401, $ac45
	dw $401, $ac04, $8040, fis3, $2040, $1010, d4, d3, $400
	dw $400, $ac45
	db $40



SONG2_Patterns_blk10

	dw $401, $a480, $60, gis4, $400, $808, e3, e3+1, 0
	dw $400, $a4c0, $40, gis4
	dw $400, $a4c0, $20, gis4
	dw $400, $a4c0, $10, gis4
	dw $400, $a4c1
	dw $400, $a4c0, $8, gis4
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c0, $4, gis4
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a481, $400, $808, b3, b3+1, 0
	dw $400, $a4c0, $2, gis4
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c0, $1, gis4
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c0, $1, rest
	dw $400, $a4c1
	dw $400, $a481, $400, $808, ais3, ais3+1, 0
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a481, $400, $808, fis3, fis3+1, 0
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	dw $400, $a4c1
	db $40



SONG2_Patterns_blk11

	dw $401, $a404, $8020, e1, $4040, $1008, e4, e3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, b1, $4040, $1008, b4, b3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, ais1, $4040, $1008, ais4, ais3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, fis1, $4040, $1008, fis4, fis3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	db $40



SONG2_Patterns_blk12

	dw $401, $a404, $8020, g1, $4040, $1008, g4, g3+1, 0
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a405, $4040, $1008, fis4, fis3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, g4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a4, a3+1, 0
	dw $401, $a445
	dw $401, $a405, $4040, $1008, g4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, fis4, fis3+1, 0
	dw $400, $a445
	db $40



SONG2_Patterns_blk13

	dw $401, $a404, $8020, g1, $4040, $1008, b4, g3+1, 0
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a4, fis3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, b4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, c5, a3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, b4, g3+1, 0
	dw $401, $a445
	dw $401, $a405, $4040, $1008, a4, fis3+1, 0
	dw $400, $a445
	db $40



SONG2_Patterns_blk14

	dw $401, $a404, $8020, e1, $4040, $1008, g4, e4+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, b1, $4040, $1008, b4, g4+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, ais1, $4040, $1008, ais4, fis4+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, fis1, $4040, $1008, fis4, dis4+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	db $40



SONG2_Patterns_blk15

	dw $401, $a404, $8020, g1, $4040, $1008, g4, e4+1, 0
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a4, fis3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, b4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, c5, a3+1, 0
	dw $401, $a445
	dw $401, $a405, $4040, $1008, b4, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a4, fis3+1, 0
	dw $400, $a445
	db $40



SONG2_Patterns_blk18

	dw $401, $a404, $8020, e1, $4040, $1008, e5, e3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, b1, $4040, $1008, b5, b3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, ais1, $4040, $1008, ais5, ais3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a404, $8020, fis1, $4040, $1008, fis5, fis3+1, 0
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $400, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	db $40



SONG2_Patterns_blk19

	dw $401, $a404, $8020, g1, $4040, $1008, g5, b3+1, 0
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $401, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a445
	dw $400, $a445
	dw $401, $a405, $4040, $1008, fis5, fis3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, g5, g3+1, 0
	dw $400, $a445
	dw $401, $a405, $4040, $1008, a5, a3+1, 0
	dw $401, $a445
	dw $401, $a404, $8020, fis1, $4040, $1008, g5, g3+1, 0
	dw $400, $a445
	dw $401, $a404, $8020, f1, $4040, $1008, fis5, fis3+1, 0
	dw $400, $a445
	db $40



SONG2_Patterns_blk20

	dw $401, $ac04, $4010, e2, $4010, $1080, e3, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac80, $4040, gis4, $4010, $1080, e2, e1+1, $400
	dw $400, $acc0, $4020, gis4
	dw $400, $acc0, $4010, gis4
	dw $400, $acc1
	dw $400, $acc0, $4008, gis4
	dw $400, $ac40, $4008, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	db $40



SONG2_Patterns_blk21

	dw $401, $ac04, $4010, e2, $4010, $1080, e3, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac44, $4010, rest
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $400, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $400, $ac04, $4010, rest, $4010, $1080, rest, e1+1, $400
	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, $400
	dw $401, $ac44, $4010, rest
	dw $401, $a404, $4010, b1, $4040, $1008, b5, b3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, a1, $4040, $1008, a5, a3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, g1, $4040, $1008, g5, g3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, a1, $4040, $1008, a5, a3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, g1, $4040, $1008, g5, g3+1, $400
	dw $400, $a445
	dw $400, $a404, $4010, d1, $4040, $1008, d5, d3+1, $400
	dw $400, $a445
	db $40



SONG2_Patterns_blk22

	dw $401, $ac04, $4010, e1, $4010, $1080, e1, e1+1, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac04, $4010, rest, $4010, $1080, e1, rest, 0
	dw $400, $ac05, $4010, $1080, rest, rest, 0
	dw $400, $ac45
	dw $400, $ac45
	dw $400, $ac45
	dw $401, $ac45
	dw $401, $ac45
	dw $401, $a4c0, $60, gis4
	dw $400, $a4c0, $40, gis4
	dw $400, $a4c0, $20, gis4
	dw $400, $a4c1
	dw $400, $a4c0, $10, gis4
	dw $400, $a4c1
	dw $400, $a4c0, $8, gis4
	dw $400, $a4c0, $4, gis4
	dw $400, $a4c0, $2, gis4
	dw $400, $a4c0, $1, gis4
	dw $400, $a4c0, $1, rest
	dw $400, $a4c1
	db $40








;IF ((LOW($)) != 0)
;    org 256*(1+(HIGH($)))
;ENDIF


; ===========================================================
DEMOmusicdata:
SONG3:
; ===========================================================



songmusicData


	dw SONG3_Patterns_ptn1
	dw SONG3_Patterns_ptn1
	dw SONG3_Patterns_ptn1
	dw SONG3_Patterns_ptn1
	dw SONG3_Patterns_ptn2
	dw SONG3_Patterns_ptn2
	dw SONG3_Patterns_ptn2
	dw SONG3_Patterns_ptn2
	dw SONG3_Patterns_ptn3
	dw SONG3_Patterns_ptn3
	dw SONG3_Patterns_ptn3
	dw SONG3_Patterns_ptn3a
SONG3loop
	dw SONG3_Patterns_ptn4
	dw SONG3_Patterns_ptn4
	dw SONG3_Patterns_ptn4
	dw SONG3_Patterns_ptn4a
	dw SONG3_Patterns_ptn5
	dw SONG3_Patterns_ptn5
	dw SONG3_Patterns_ptn5
	dw SONG3_Patterns_ptn5a
	dw 0


SONG3_Patterns_ptn1

	dw $600, $b400, $80, 0, 0, $2020, a1, a1+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, e2, e2+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, d2, d2+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, a1, a1+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, e2, e2+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, d2, d2+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, a1, a1+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, c2, c2+1, 0
	dw $600, $b441
	db $40



SONG3_Patterns_ptn2

	dw $600, $b404, $4010, a1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, c3, c3+1, 0
	dw $600, $b445
	db $40



SONG3_Patterns_ptn3

	dw $600, $b404, $8020, f1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, c3, c3+1, 0
	dw $600, $b445
	db $40



SONG3_Patterns_ptn3a

	dw $600, $b404, $8020, f1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b444, $8020, fis1
	dw $600, $b404, $8020, g1, $10, $2020, c3, c3+1, 0
	dw $600, $b444, $8020, gis1
	db $40



SONG3_Patterns_ptn4

	dw $601, $b404, $4010, a1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, e3, e3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, a2, a2+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, d3, d3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, c3, c3+1, 0
	dw $680, $b445
	db $40



SONG3_Patterns_ptn4a

	dw $601, $b404, $4010, a1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, e3, e3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, a2, a2+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, d3, d3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b444, $4010, gis1
	dw $680, $b404, $4010, g1, $10, $2020, c3, c3+1, 0
	dw $680, $b444, $4010, fis1
	db $40



SONG3_Patterns_ptn5

	dw $601, $b404, $8020, f1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, e3, e3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, a2, a2+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, d3, d3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, c3, c3+1, 0
	dw $680, $b445
	db $40



SONG3_Patterns_ptn5a

	dw $601, $ac04, $8020, f1, $10, $2020, a2, a2+1, $1000
	dw $600, $ac45
	dw $680, $ac05, $10, $2020, e3, e3+1, $1000
	dw $680, $ac45
	dw $601, $ac05, $10, $2020, d3, d3+1, $1000
	dw $600, $ac45
	dw $680, $ac05, $10, $2020, a2, a2+1, $1000
	dw $680, $ac45
	dw $601, $ac05, $10, $2020, e3, e3+1, $1000
	dw $600, $ac45
	dw $680, $ac05, $10, $2020, d3, d3+1, $1000
	dw $680, $ac45
	dw $601, $ac05, $10, $2020, a2, a2+1, $1000
	dw $600, $ac44, $8020, fis1
	dw $680, $ac04, $8020, g1, $10, $2020, c3, c3+1, $1000
	dw $680, $ac44, $8020, gis1
	db $40





;IF ((LOW($)) != 0)
;    org 256*(1+(HIGH($)))
;ENDIF


; ======================================================
;PHASER X DEMO 1
DEMOmusicdata2:
SONG4:
; ======================================================


	dw SONG4ptn1
	dw SONG4ptn1
SONG4loop:
	dw SONG4ptn2
	dw SONG4ptn2
	dw SONG4ptn2
	dw SONG4ptn2a
	dw SONG4ptn3
	dw SONG4ptn3
	dw SONG4ptn2
	dw SONG4ptn2a
	dw SONG4ptn4
	dw SONG4ptn3
	dw SONG4ptn2
	dw SONG4ptn2a
	dw SONG4ptn5a
	dw SONG4ptn5
	dw SONG4ptn5
	dw SONG4ptn6
	dw SONG4ptn5
	dw SONG4ptn5
	dw SONG4ptn5
	dw SONG4ptn7
	dw SONG4ptn5a
	dw SONG4ptn5
	dw SONG4ptn5
	dw SONG4ptn6
	dw SONG4ptn5a
	dw SONG4ptn5
	dw SONG4ptn5a
	dw SONG4ptn8
	dw 0
	
	;speed+drums, method+flags, [dutymod/duty1, freq1], [dutymod2a/b, duty2a/b, freq2a, freq2b, phase2b]

SONG4ptn1
	dw $1000|kick,mix_xor|fsid,	$0080,c2,	0,0,rest,rest,0
	dw $0800,mix_xor|fsid|noupd2,	$0080,rest
	dw $0800,mix_xor|fsid|noupd2,	$0080,dis2
	dw $0800,mix_xor|fsid|noupd2,	$0080,e2
	dw $0800,mix_xor|fsid|noupd2,	$0080,f2
	
	dw $1000|hhat,mix_xor|fsid,	$0080,c2,	0,0,rest,rest,0
	dw $0800,mix_xor|fsid|noupd2,	$0080,rest
	dw $0800,mix_xor|fsid|noupd2,	$0080,dis2
	dw $0800,mix_xor|fsid|noupd2,	$0080,e2
	dw $0800,mix_xor|fsid|noupd2,	$0080,f2
	
	db ptnend



SONG4ptn2
	dw $1000|kick,mix_and|fsid,		$0080,c2,	$00c0,$4010,c3,c2+8,$4000
	dw $0800|kick,mix_and|fsid|noupd2,	$0080,rest
	dw $0800|hhat,mix_and|fsid,		$0080,dis2,	$00c0,$4010,dis3,dis2+8,$4000
	dw $0800,mix_and|fsid,			$0080,e2,	$00c0,$4010,e3,e2+8,$4000
	dw $0800|hhat,mix_and|fsid,		$0080,f2,	$00c0,$4010,f3,f2+8,$4000
	
	dw $1000|kick,mix_and|fsid,		$0080,c2,	$00c0,$4010,c3,c2+8,$4000
	dw $0800|kick,mix_and|fsid|noupd2,	$0080,rest
	dw $0800|hhat,mix_and|fsid,		$0080,dis2,	$00c0,$4010,dis3,dis2+8,$4000
	dw $0800,mix_and|fsid,			$0080,e2,	$00c0,$4010,e3,e2+8,$4000
	dw $0800|hhat,mix_and|fsid,		$0080,f2,	$00c0,$4010,f3,f2+8,$4000
	
	db ptnend
	
SONG4ptn2a
	dw $1000|kick,mix_and|fsid,		$0080,c2,	$00c0,$4010,c3,c2+8,$4000
	dw $0800|kick,mix_and|fsid|noupd2,	$0080,rest
	dw $0800|hhat,mix_and|fsid,		$0080,dis2,	$00c0,$4010,dis3,dis2+8,$4000
	dw $0800,mix_and|fsid,			$0080,e2,	$00c0,$4010,e3,e2+8,$4000
	dw $0800|hhat,mix_and|fsid,		$0080,f2,	$00c0,$4010,f3,f2+8,$4000
	
	dw $1000|kick,mix_and|fsid,		$0080,c2,	$00c0,$4010,c3,c2+8,$4000
	dw $0800|kick,mix_and|fsid|noupd2,	$0080,rest
	dw $0800|hhat,mix_and|fsid,		$0080,dis2,	$00c0,$4010,dis3,dis2+8,$4000
	dw $0800|hhat,mix_and|fsid,		$0080,e2,	$00c0,$4010,e3,e2+8,$4000
	dw $0800|hhat,mix_and|fsid,		$0080,f2,	$00c0,$4010,f3,f2+8,$4000
	
	db ptnend
	
SONG4ptn3
	dw $1000|kick,mix_and|fsid,		$0080,f2,	$00c0,$4010,f3,f2+8,$4000
	dw $0800|kick,mix_and|fsid|noupd2,	$0080,rest
	dw $0800|hhat,mix_and|fsid,		$0080,gis2,	$00c0,$4010,gis3,gis2+8,$4000
	dw $0800,mix_and|fsid,			$0080,ais2,	$00c0,$4010,ais3,ais2+8,$4000
	dw $0800|hhat,mix_and|fsid,		$0080,b2,	$00c0,$4010,b3,b2+8,$4000
	
	dw $1000|kick,mix_and|fsid,		$0080,f2,	$00c0,$4010,f3,f2+8,$4000
	dw $0800|kick,mix_and|fsid|noupd2,	$0080,rest
	dw $0800|hhat,mix_and|fsid,		$0080,gis2,	$00c0,$4010,gis3,gis2+8,$4000
	dw $0800,mix_and|fsid,			$0080,ais2,	$00c0,$4010,ais3,ais2+8,$4000
	dw $0800|hhat,mix_and|fsid,		$0080,b2,	$00c0,$4010,b3,b2+8,$4000
	
	db ptnend
	
SONG4ptn4
	dw $1000|kick,mix_and|fsid,		$0080,g2,	$00c0,$4010,g3,g2+8,$4000
	dw $0800|kick,mix_and|fsid|noupd2,	$0080,rest
	dw $0800|hhat,mix_and|fsid,		$0080,b2,	$00c0,$4010,b3,b2+8,$4000
	dw $0800,mix_and|fsid,			$0080,c3,	$00c0,$4010,c4,c3+8,$4000
	dw $0800|hhat,mix_and|fsid,		$0080,d3,	$00c0,$4010,d4,d3+8,$4000
	
	dw $1000|kick,mix_and|fsid,		$0080,g2,	$00c0,$4010,g3,g2+8,$4000
	dw $0800|kick,mix_and|fsid|noupd2,	$0080,rest
	dw $0800|hhat,mix_and|fsid,		$0080,b2,	$00c0,$4010,b3,b2+8,$4000
	dw $0800,mix_and|fsid,			$0080,c3,	$00c0,$4010,c4,c3+8,$4000
	dw $0800|hhat,mix_and|fsid,		$0080,d3,	$00c0,$4010,d4,d3+8,$4000
	
	db ptnend

SONG4ptn5
	dw $1000|kick,mix_and,			0,rest,		$00c0,$4010,c3,c2+8,$4000
	dw $0800|kick,mix_and|noupd1|noupd2
	dw $1000|hhat,mix_and|noupd1|noupd2
	dw $0800|hhat,mix_and|noupd1|noupd2
	
	db ptnend
	
SONG4ptn5a
	dw $0800|kick,mix_and|fnoise,		$0040,$2174,	$00c0,$4010,c3,c2+8,$4000
	dw $0800,mix_and|fnoise|noupd2,		$0020,$2174
	dw $0800|kick,mix_and|fnoise|noupd2,	$0010,$2174
	dw $0400|hhat,mix_and|fnoise|noupd2,	$0008,$2174
	dw $0c00,mix_and|noupd2,		0,rest
	dw $0800|hhat,mix_and|noupd1|noupd2
	
	db ptnend
	
SONG4ptn6
	dw $1000|kick,mix_and,			0,rest,		$00c0,$4010,c3,c2+8,$4000
	dw $0800|kick,mix_and|noupd1,				$00c0,$4010,dis3,dis2+8,$4000
	dw $1000|hhat,mix_and|noupd1|noupd2
	dw $0800|hhat,mix_and|noupd1|noupd2
	
	db ptnend
	
SONG4ptn7
	dw $1000|kick,mix_and,			0,rest,		$00c0,$4010,c3,c2+8,$4000
	dw $0800|kick,mix_and|noupd1,				$00c0,$4010,g3,g2+8,$4000
	dw $0800|hhat,mix_and|noupd1|noupd2
	dw $0800|hhat,mix_and|noupd1|noupd2
	dw $0800|hhat,mix_and|noupd1|noupd2
	
	db ptnend
	
SONG4ptn8
	dw $0800|kick,mix_and|fnoise,		$0040,$2174,	$00c0,$4010,c3,c2+8,$4000
	dw $0800,mix_and|fnoise|noupd2,		$0020,$2174
	dw $0800|kick,mix_xor|fnoise,		$0010,$2174,	$00c0,$4010,b3,b3+8,$4000
	dw $0800|hhat,mix_xor|fnoise|noupd2,	$0040,$2174
	dw $0800|hhat,mix_xor|fnoise|noupd2,	$0020,$2174
	dw $0400|hhat,mix_xor|fnoise|noupd2,	$0040,$2174
	dw $0400|hhat,mix_xor|fnoise|noupd2,	$0020,$2174
	
	db ptnend
	
