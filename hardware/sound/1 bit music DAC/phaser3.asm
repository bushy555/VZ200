;===================================
;PHASER3



;MOTBmusicData
;P3S1musicData:
;P3S2musicData:




; March of the biomech.  by AtariTufty
; Uses the Phaser3 engine.
; Works fine on real hardware, though some squealing is evident.
;
; Assemble:	SJASMPLUS
;		\vz\tasm\_utils\sjasmplus %1.asm
;		\vz\tasm\_utils\rbinary   %1.obj %1.vz
;




;
;
; 0=speaker.  
; 1=Cassette Port.  
; 2=Printer Port.
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
;	To assemble:
;			sjasmplus MUSICBOX.ASM
;

 	output "MUSICBOX.VZ"

OP_NOP		equ 	$00
OP_INCBC	equ 	$03
OP_DECBC	equ 	$0b
OP_INCSP	equ 	$33
OP_DECSP	equ 	$3b
OP_INCDE	equ 	$13
OP_DECDE	equ 	$1b
OP_DECHL	equ 	$2b
OP_ANDH		equ 	$a4
OP_XORH		equ 	$ac
OP_ORC		equ 	$b1
OP_ORH		equ 	$b4
origin		equ	$8000



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
	ld	de, 28755+32
	jr	menucon
menucas:ld	hl, CASSEINV
	ld	de, 28755+64
	jr	menucon
menuprn:ld	hl, PRINTINV
	ld	de, 28755+96
menucon:ld	bc, 12
	ldir
	ld	hl, BUSHYINV
	ld	de, 29179
	ld	bc, 5
	ldir
	

        di
scan:	call 	$2ef4		; VZ scan keyboard
	or 	a		; any key pressed?
	jr	z, scan		; back if not
	di
	cp	49		; "1 - "	SONG1	Phaser3 song1
	jr	z, m01		; 	
	cp	50		; "2 - "	SONG2	Phaser3 song2
	jr	z, m02
	cp	51		; "3 - " 	SONG3	MOTB
	jr	z, m03
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








play	di
	exx
	push hl
	push iy
	ld (stopPlayer.oldSP),sp
	exx
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (readRow.pos),de
	ld (readRow.loop),de
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (readRow.insList0),de
	ld (readRow.insList1),de
	ld (playDrumSample.drumList),hl
	ld hl,0
	ld (soundInit.ch0cnt0),hl
	ld ix,0						;ch0cnt1
	ld (readRow.ch1cnt0),hl
	ld iy,0						;ch1cnt1
	ld (soundInit.ch0add0),hl
	ld sp,hl					;ch0add1
	ld (readRow.ch1add0),hl
	ld (readRow.ch1add1),hl
	xor a
	ld (readRow.ch0int),a
	ld (readRow.ch1int),a
	ld (readRow.ch0det),a
	ld (readRow.ch1det),a
	ld (soundInit.skip),a
	ld (soundLoop.phaseSlideDivA),a
	ld (soundLoop.phaseSlideDivB),a
	ld a,64
	ld (readRow.ch0pha),a
	ld (readRow.ch1pha),a
	ld a,8
	ld (soundInit.len),a
	exx
	ld hl,0						;ch1cnt0
	ld de,0						;ch1add1
	ld bc,0						;ch1add0
	exx
readRow
.pos=$+1
	ld hl,0
.read	ld a,(hl)
	inc hl
	cp 245
	jp c,.ch0
	jr z,.setSpeed
	cp 254
	jr z,.setLoop
	cp 255
	jr z,.readLoop
	ld (.pos),hl
	sub 246
	jp playDrumSample
.setSpeed
	ld a,(hl)
	ld (soundInit.len),a
	inc hl
	jp .read
.setLoop
	ld (.loop),hl
	jp .read
.readLoop
.loop=$+1
	ld hl,0
	jp .read
.ch0mute
	ld sp,0
	ld ix,0
	ld (soundInit.ch0cnt0),sp
	ld (soundInit.ch0add0),sp
	jp .ch1
.ch1mute
	exx
	ld hl,0
	ld iy,0
	ld d,h
	ld e,h
	ld b,h
	ld c,h
	exx
	jp .ch1skip
.ch0	add a,a
	jp nc,.note0			;bit 7 is not set, it is a note
	ex de,hl				;set instrument of channel 0
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
.insList0=$+1
	ld bc,0
	add hl,bc
	ld a,(hl)
	inc hl
	ld (.ch0int),a
	ld a,(hl)
	inc hl
	ld (.ch0pha),a
	inc a
	jr z,$+4
	ld a,$0a
	xor $0a
	ld (.phasereset0),a
	ld a,(hl)
	ld (.ch0det),a
	inc hl
	ld a,(hl)				;mix mode
	inc hl
	ld (soundLoop.opA0),a
	ld (soundLoop.opA1),a
	ld (soundLoop.opA2),a
	ld (soundLoop.opA3),a
	ld c,(hl)				;volume
	inc hl
	ld b,33					;out mask
	ld a,c
	and b
	ld (soundLoop.volA0),a
	rr c
	ld a,c
	and b
	ld (soundLoop.volA1),a
	rr c
	ld a,c
	and b
	ld (soundLoop.volA2),a
	rr c
	ld a,c
	and b
	ld (soundLoop.volA3),a
	ld a,(hl)				;phase slide speed
	inc hl
	ld (soundLoop.phaseSlideSpeedA),a
	or a
	jr z,$+4
	ld a,soundLoop.phaseSlideA1-soundLoop.phaseSlideA0
	xor soundLoop.phaseSlideA1-soundLoop.phaseSlideA0
	ld (soundLoop.phaseSlideEnableA),a
	ld bc,0
	ld (soundLoop.cntA0Slide+0),bc
	ld (soundLoop.cntA0Slide+2),bc
	ld (soundLoop.cntA1Slide+0),bc
	ld (soundLoop.cntA1Slide+2),bc
	ld a,(hl)				;generator 1 slide
	inc hl
	ld c,a
	or a
	jr z,.ch0noslide0
	and $0f
	or OP_INCBC&$f0
	rl c
	jr nc,$+5
	ld (soundLoop.cntA0Slide+0),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntA0Slide+1),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntA0Slide+2),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntA0Slide+3),a
.ch0noslide0
	ld a,(hl)				;generator 2 slide
	ld c,a
	or a
	jr z,.ch0noslide1
	and $0f
	or OP_INCSP&$f0
	rl c
	jr nc,$+5
	ld (soundLoop.cntA1Slide+0),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntA1Slide+1),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntA1Slide+2),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntA1Slide+3),a
.ch0noslide1
	ex de,hl
	ld a,(hl)				;instrument always followed by a note
	inc hl
	add a,a
.note0	jp z,.ch1				;empty row, skip to the second channel
	cp 2
	jp z,.ch0mute
	ex de,hl
	ld l,a
.phasereset0=$+1
	jr $+12					;$+2 to reset, $+12 to skip
	ld ix,(soundInit.ch0cnt0)
.ch0pha=$+1
	ld a,0
	add a,ixh
	ld ixh,a
.ch0phaseresetskip
	ld h,noteTable/256
	ld c,(hl)
	inc l
	ld b,(hl)
	ld (soundInit.ch0add0),bc
.ch0int=$+1
	ld a,0
	add a,l
	ld l,a
	ld b,(hl)
	dec l
	ld c,(hl)
.ch0det=$+1
	ld hl,0
	add hl,bc
	ld sp,hl				;ch0add1
	ex de,hl
.ch1	ld a,(hl)
	inc hl
	add a,a
	jp nc,.note1
	ex de,hl				;set instrument of channel 1
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
.insList1=$+1
	ld bc,0
	add hl,bc
	ld a,(hl)
	inc hl
	ld (.ch1int),a
	ld a,(hl)
	inc hl
	ld (.ch1pha),a
	inc a
	jr z,$+4
	ld a,$0a
	xor $0a
	ld (.phasereset1),a
	ld a,(hl)
	ld (.ch1det),a
	inc hl
	ld a,(hl)				;mix mode
	inc hl
	ld (soundLoop.opB0),a
	ld (soundLoop.opB1),a
	ld (soundLoop.opB2),a
	ld (soundLoop.opB3),a
	ld c,(hl)				;volume
	inc hl
	ld b,33					;out mask
	ld a,c
	and b
	ld (soundLoop.volB0),a
	rr c
	ld a,c
	and b
	ld (soundLoop.volB1),a
	rr c
	ld a,c
	and b
	ld (soundLoop.volB2),a
	rr c
	ld a,c
	and b
	ld (soundLoop.volB3),a
	ld a,(hl)				;phase slide speed
	inc hl
	ld (soundLoop.phaseSlideSpeedB),a
	or a
	jr z,$+4
	ld a,soundLoop.phaseSlideB2-soundLoop.phaseSlideB0
	xor soundLoop.phaseSlideB2-soundLoop.phaseSlideB0
	ld (soundLoop.phaseSlideEnableB),a
	ld bc,0
	ld (soundLoop.cntB0Slide+0),bc
	ld (soundLoop.cntB0Slide+2),bc
	ld (soundLoop.cntB1Slide+0),bc
	ld (soundLoop.cntB1Slide+2),bc
	ld a,(hl)				;generator 1 slide
	inc hl
	ld c,a
	or a
	jr z,.ch1noslide0
	and $0f
	or OP_INCBC&$f0
	rl c
	jr nc,$+5
	ld (soundLoop.cntB0Slide+0),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntB0Slide+1),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntB0Slide+2),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntB0Slide+3),a
.ch1noslide0
	ld a,(hl)				;generator 2 slide
	ld c,a
	or a
	jr z,.ch1noslide1
	and $0f
	or OP_INCDE&$f0
	rl c
	jr nc,$+5
	ld (soundLoop.cntB1Slide+0),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntB1Slide+1),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntB1Slide+2),a
	rl c
	jr nc,$+5
	ld (soundLoop.cntB1Slide+3),a
.ch1noslide1
	ex de,hl
	ld a,(hl)
	inc hl
	add a,a
.note1
	jp z,.ch1skip
	cp 2
	jp z,.ch1mute
	ex de,hl
	ld l,a
.phasereset1=$+1
	jr $+2					;$+2 to reset, $+12 to skip
	ld iy,(.ch1cnt0)
.ch1pha=$+1
	ld a,0
	add a,iyh
	ld iyh,a
.ch1phaseresetskip
	ld h,noteTable/256
	ld c,(hl)
	inc l
	ld b,(hl)
	ld (.ch1add0),bc
.ch1int=$+1
	ld a,0
	add a,l
	ld l,a
	ld b,(hl)
	dec l
	ld c,(hl)
.ch1det=$+1
	ld hl,0
	add hl,bc
	ld (.ch1add1),hl
	ex de,hl
	exx
.ch1cnt0=$+1
	ld hl,0
.ch1add1=$+1
	ld de,0
.ch1add0=$+1
	ld bc,0
	exx
.ch1skip
	ld (.pos),hl
    xor a
;    in a,($fe)
;    or $e0
    inc a
    jp soundInit
;    jp z,soundInit
stopPlayer
.oldSP=$+1
	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret

soundInit
.skip=$+1
	ld d,0			;drum length to compensate
.len=$+1
	ld a,25		;speed
	sub d
	jp nc,$+5
	ld a,1
	or a
	jp nz,$+5
	ld a,1
	ld d,a
	xor a
	ld (.skip),a
.ch0cnt0=$+1
	ld hl,0
.ch0add0=$+1
	ld bc,200
soundLoopH
	ld e,64			;4*64 loop repeats, ~85 hz
soundLoop
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.opA0=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.volA0=$+1
	and 33			;7
	ld ($6800), a
	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.opB0=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.volB0=$+1
	and 33			;7
	ld ($6800), a
	exx				;4
;	nop				;4
	jr $+2			;12=152
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.opA1=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.volA1=$+1
	and 33			;7
	ld ($6800), a
	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.opB1=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.volB1=$+1
	and 33			;7
	ld ($6800), a
	exx				;4
;	nop				;4
	jr $+2			;12=152
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.opA2=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.volA2=$+1
	and 33			;7
	ld ($6800), a
	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.opB2=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.volB2=$+1
	and 33			;7
	ld ($6800), a
	exx				;4
;	nop				;4
	jr $+2			;12=152
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.opA3=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.volA3=$+1
	and 33			;7
	ld ($6800), a
	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.opB3=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.volB3=$+1
	and 33			;7
	ld ($6800), a
	exx				;4
	dec e			;4
	jr nz,soundLoop	;12=152
.phaseSlideEnableA=$+1
	jr $+2
.phaseSlideA0
.phaseSlideDivA=$+1
	ld a,0
	inc a
.phaseSlideSpeedA=$+1
	cp 1
	jr c,$+3
	xor a
	ld (.phaseSlideDivA),a
	jr c,.phaseSlideA1
	ld a,ixh
	cp h
	jr z,.phaseSlideA1
	inc h
	ld a,ixl
	ld l,a
.phaseSlideA1
.phaseSlideEnableB=$+1
	jr $+2
.phaseSlideB0
.phaseSlideDivB=$+1
	ld a,0
	inc a
.phaseSlideSpeedB=$+1
	cp 1
	jr c,$+3
	xor a
	ld (.phaseSlideDivB),a
	jr c,.phaseSlideB2
	exx
	ld a,iyh
	cp h
	jr z,.phaseSlideB1
	inc h
	ld a,iyl
	ld l,a
.phaseSlideB1
	exx
.phaseSlideB2
.cntA0Slide=$
	nop			;bc
	nop
	nop
	nop
.cntA1Slide=$
	nop			;sp
	nop
	nop
	nop
	exx
.cntB0Slide=$
	nop			;bc
	nop
	nop
	nop
.cntB1Slide=$
	nop			;de
	nop
	nop
	nop
	exx
	dec d
	jp nz,soundLoopH
	ld (soundInit.ch0cnt0),hl
	jp readRow
playDrumSample
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
.drumList=$+1
	ld bc,0
	add hl,bc
	ld a,(hl)				;length in 256-sample blocks
	ld b,a
	inc hl
	inc hl
	ld (soundInit.skip),a
	ld a,(hl)
	inc hl
	ld h,(hl)				;sample data
	ld l,a
	ld a,33
	ld (.mask),a
	ld c,0
.loop0	ld a,(hl)			;7
.mask=$+1
	and 0				;7
	sub 1				;7
	sbc a,a				;4
;	and 33			;7
	ld ($6800), a
	ld a,(.mask)		;13
	rlc a				;8
	ld (.mask),a		;13
	jr nc,$+3			;7/12
	inc hl				;6
	dec hl				;6
	inc hl				;6
	dec hl				;6
	inc hl				;6
	dec hl				;6
	inc hl				;6
	dec hl				;6
	inc hl				;6
	ld a,0				;7
	dec c				;4
	jr nz,.loop0		;7/12=105t
	dec b
	jp nz,.loop0
	jp readRow




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


;readRow		--> 	casreadRow
;soundInit	--> 	cassoundInit
;soundLoop	--> 	cassoundLoop
;soundLoopH	--> 	cassoundLoopH
;PlayDrumSample	--> 	casPlayDrumSample
;stopPlayer	--> 	casstopPlayer


	di
	exx
	push hl
	push iy
	ld (casstopPlayer.casoldSP),sp
	exx
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (casreadRow.caspos),de
	ld (casreadRow.casloop),de
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (casreadRow.casinsList0),de
	ld (casreadRow.casinsList1),de
	ld (casPlayDrumSample.casdrumList),hl
	ld hl,0
	ld (cassoundInit.casch0cnt0),hl
	ld ix,0						;ch0cnt1
	ld (casreadRow.casch1cnt0),hl
	ld iy,0						;ch1cnt1
	ld (cassoundInit.casch0add0),hl
	ld sp,hl					;ch0add1
	ld (casreadRow.casch1add0),hl
	ld (casreadRow.casch1add1),hl
	xor a
	ld (casreadRow.casch0int),a
	ld (casreadRow.casch1int),a
	ld (casreadRow.casch0det),a
	ld (casreadRow.casch1det),a
	ld (cassoundInit.casskip),a
	ld (cassoundLoop.casphaseSlideDivA),a
	ld (cassoundLoop.casphaseSlideDivB),a
	ld a,64
	ld (casreadRow.casch0pha),a
	ld (casreadRow.casch1pha),a
	ld a,8
	ld (cassoundInit.caslen),a
	exx
	ld hl,0						;ch1cnt0
	ld de,0						;ch1add1
	ld bc,0						;ch1add0
	exx


casreadRow
.caspos=$+1
	ld hl,0
.casread	ld a,(hl)
	inc hl
	cp 245
	jp c,.casch0
	jr z,.cassetSpeed
	cp 254
	jr z,.cassetLoop
	cp 255
	jr z,.casreadLoop
	ld (.caspos),hl
	sub 246
	jp casPlayDrumSample
.cassetSpeed
	ld a,(hl)
	ld (cassoundInit.caslen),a
	inc hl
	jp .casread
.cassetLoop
	ld (.casloop),hl
	jp .casread
.casreadLoop
.casloop=$+1
	ld hl,0
	jp .casread
.casch0mute
	ld sp,0
	ld ix,0
	ld (cassoundInit.casch0cnt0),sp
	ld (cassoundInit.casch0add0),sp
	jp .casch1
.casch1mute
	exx
	ld hl,0
	ld iy,0
	ld d,h
	ld e,h
	ld b,h
	ld c,h
	exx
	jp .casch1skip
.casch0	add a,a
	jp nc,.casnote0			;bit 7 is not set, it is a note
	ex de,hl				;set instrument of channel 0
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
.casinsList0=$+1
	ld bc,0
	add hl,bc
	ld a,(hl)
	inc hl
	ld (.casch0int),a
	ld a,(hl)
	inc hl
	ld (.casch0pha),a
	inc a
	jr z,$+4
	ld a,$0a
	xor $0a
	ld (.casphasereset0),a
	ld a,(hl)
	ld (.casch0det),a
	inc hl
	ld a,(hl)				;mix mode
	inc hl
	ld (cassoundLoop.casopA0),a
	ld (cassoundLoop.casopA1),a
	ld (cassoundLoop.casopA2),a
	ld (cassoundLoop.casopA3),a
	ld c,(hl)				;volume
	inc hl
	ld b,33					;out mask
	ld a,c
	and b
	ld (cassoundLoop.casvolA0),a
	rr c
	ld a,c
	and b
	ld (cassoundLoop.casvolA1),a
	rr c
	ld a,c
	and b
	ld (cassoundLoop.casvolA2),a
	rr c
	ld a,c
	and b
	ld (cassoundLoop.casvolA3),a
	ld a,(hl)				;phase slide speed
	inc hl
	ld (cassoundLoop.casphaseSlideSpeedA),a
	or a
	jr z,$+4
	ld a,cassoundLoop.casphaseSlideA1-cassoundLoop.casphaseSlideA0
	xor cassoundLoop.casphaseSlideA1-cassoundLoop.casphaseSlideA0
	ld (cassoundLoop.casphaseSlideEnableA),a
	ld bc,0
	ld (cassoundLoop.cascntA0Slide+0),bc
	ld (cassoundLoop.cascntA0Slide+2),bc
	ld (cassoundLoop.cascntA1Slide+0),bc
	ld (cassoundLoop.cascntA1Slide+2),bc
	ld a,(hl)				;generator 1 slide
	inc hl
	ld c,a
	or a
	jr z,.casch0noslide0
	and $0f
	or OP_INCBC&$f0
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntA0Slide+0),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntA0Slide+1),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntA0Slide+2),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntA0Slide+3),a
.casch0noslide0
	ld a,(hl)				;generator 2 slide
	ld c,a
	or a
	jr z,.casch0noslide1
	and $0f
	or OP_INCSP&$f0
	rl c

	jr nc,$+5
	ld (cassoundLoop.cascntA1Slide+0),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntA1Slide+1),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntA1Slide+2),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntA1Slide+3),a
.casch0noslide1
	ex de,hl
	ld a,(hl)				;instrument always followed by a note
	inc hl
	add a,a
.casnote0	jp z,.casch1				;empty row, skip to the second channel
	cp 2
	jp z,.casch0mute
	ex de,hl
	ld l,a
.casphasereset0=$+1
	jr $+12					;$+2 to reset, $+12 to skip
	ld ix,(cassoundInit.casch0cnt0)
.casch0pha=$+1
	ld a,0
	add a,ixh
	ld ixh,a
.casch0phaseresetskip
	ld h,noteTable/256
	ld c,(hl)
	inc l
	ld b,(hl)
	ld (cassoundInit.casch0add0),bc
.casch0int=$+1
	ld a,0
	add a,l
	ld l,a
	ld b,(hl)
	dec l
	ld c,(hl)
.casch0det=$+1
	ld hl,0
	add hl,bc
	ld sp,hl				;ch0add1
	ex de,hl
.casch1	ld a,(hl)
	inc hl
	add a,a
	jp nc,.casnote1
	ex de,hl				;set instrument of channel 1
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
.casinsList1=$+1
	ld bc,0
	add hl,bc
	ld a,(hl)
	inc hl
	ld (.casch1int),a
	ld a,(hl)
	inc hl
	ld (.casch1pha),a
	inc a
	jr z,$+4
	ld a,$0a
	xor $0a
	ld (.casphasereset1),a
	ld a,(hl)
	ld (.casch1det),a
	inc hl
	ld a,(hl)				;mix mode
	inc hl
	ld (cassoundLoop.casopB0),a
	ld (cassoundLoop.casopB1),a
	ld (cassoundLoop.casopB2),a
	ld (cassoundLoop.casopB3),a
	ld c,(hl)				;volume
	inc hl
	ld b,6					;out mask
	ld a,c
	and b
	ld (cassoundLoop.casvolB0),a
	rr c
	ld a,c
	and b
	ld (cassoundLoop.casvolB1),a

	rr c
	ld a,c
	and b
	ld (cassoundLoop.casvolB2),a
	rr c
	ld a,c
	and b
	ld (cassoundLoop.casvolB3),a
	ld a,(hl)				;phase slide speed
	inc hl
	ld (cassoundLoop.casphaseSlideSpeedB),a
	or a
	jr z,$+4
	ld a,cassoundLoop.casphaseSlideB2-cassoundLoop.casphaseSlideB0
	xor cassoundLoop.casphaseSlideB2-cassoundLoop.casphaseSlideB0
	ld (cassoundLoop.casphaseSlideEnableB),a
	ld bc,0
	ld (cassoundLoop.cascntB0Slide+0),bc
	ld (cassoundLoop.cascntB0Slide+2),bc
	ld (cassoundLoop.cascntB1Slide+0),bc
	ld (cassoundLoop.cascntB1Slide+2),bc
	ld a,(hl)				;generator 1 slide
	inc hl
	ld c,a
	or a
	jr z,.casch1noslide0
	and $0f
	or OP_INCBC&$f0
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntB0Slide+0),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntB0Slide+1),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntB0Slide+2),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntB0Slide+3),a
.casch1noslide0
	ld a,(hl)				;generator 2 slide
	ld c,a
	or a
	jr z,.casch1noslide1
	and $0f
	or OP_INCDE&$f0
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntB1Slide+0),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntB1Slide+1),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntB1Slide+2),a
	rl c
	jr nc,$+5
	ld (cassoundLoop.cascntB1Slide+3),a
.casch1noslide1
	ex de,hl
	ld a,(hl)
	inc hl
	add a,a
.casnote1
	jp z,.casch1skip
	cp 2
	jp z,.casch1mute
	ex de,hl
	ld l,a
.casphasereset1=$+1
	jr $+2					;$+2 to reset, $+12 to skip
	ld iy,(.casch1cnt0)
.casch1pha=$+1
	ld a,0
	add a,iyh
	ld iyh,a
.casch1phaseresetskip
	ld h,noteTable/256
	ld c,(hl)
	inc l
	ld b,(hl)
	ld (.casch1add0),bc
.casch1int=$+1
	ld a,0
	add a,l
	ld l,a
	ld b,(hl)
	dec l
	ld c,(hl)
.casch1det=$+1
	ld hl,0
	add hl,bc
	ld (.casch1add1),hl
	ex de,hl
	exx
.casch1cnt0=$+1
	ld hl,0
.casch1add1=$+1
	ld de,0
.casch1add0=$+1
	ld bc,0
	exx
.casch1skip
	ld (.caspos),hl
    xor a
;    in a,($fe)
;    or $e0
    inc a
    jp cassoundInit
;    jp z,cassoundInit
casstopPlayer
.casoldSP=$+1
	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret



cassoundInit
.casskip=$+1
	ld d,0			;drum length to compensate
.caslen=$+1
	ld a,25		;speed
	sub d
	jp nc,$+5
	ld a,1
	or a
	jp nz,$+5
	ld a,1
	ld d,a
	xor a
	ld (.casskip),a
.casch0cnt0=$+1
	ld hl,0
.casch0add0=$+1
	ld bc,200
cassoundLoopH
	ld e,64			;4*64 loop repeats, ~85 hz
cassoundLoop
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.casopA0=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.casvolA0=$+1
	and 6			;7
	ld ($6800), a
	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.casopB0=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.casvolB0=$+1
	and 6			;7
	ld ($6800), a
	exx				;4
;	nop				;4
	jr $+2			;12=152
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.casopA1=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.casvolA1=$+1
	and 6			;7
	ld ($6800), a
	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.casopB1=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.casvolB1=$+1
	and 6			;7
	ld ($6800), a
	exx				;4
;	nop				;4
	jr $+2			;12=152
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.casopA2=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.casvolA2=$+1
	and 6			;7
	ld ($6800), a
	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.casopB2=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.casvolB2=$+1
	and 6			;7
	ld ($6800), a
	exx				;4
;	nop				;4
	jr $+2			;12=152
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.casopA3=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.casvolA3=$+1
	and 6			;7
	ld ($6800), a
	exx				;4




	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.casopB3=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.casvolB3=$+1
	and 6			;7
	ld ($6800), a
	exx				;4
	dec e			;4
	jr nz,cassoundLoop	;12=152
.casphaseSlideEnableA=$+1
	jr $+2
.casphaseSlideA0
.casphaseSlideDivA=$+1
	ld a,0
	inc a
.casphaseSlideSpeedA=$+1
	cp 1
	jr c,$+3
	xor a
	ld (.casphaseSlideDivA),a
	jr c,.casphaseSlideA1
	ld a,ixh
	cp h
	jr z,.casphaseSlideA1
	inc h
	ld a,ixl
	ld l,a
.casphaseSlideA1
.casphaseSlideEnableB=$+1
	jr $+2
.casphaseSlideB0
.casphaseSlideDivB=$+1
	ld a,0
	inc a
.casphaseSlideSpeedB=$+1
	cp 1
	jr c,$+3
	xor a
	ld (.casphaseSlideDivB),a
	jr c,.casphaseSlideB2
	exx
	ld a,iyh
	cp h
	jr z,.casphaseSlideB1
	inc h
	ld a,iyl
	ld l,a


.casphaseSlideB1
	exx
.casphaseSlideB2
.cascntA0Slide=$
	nop			;bc
	nop
	nop
	nop
.cascntA1Slide=$
	nop			;sp
	nop
	nop
	nop
	exx
.cascntB0Slide=$
	nop			;bc
	nop
	nop
	nop
.cascntB1Slide=$
	nop			;de
	nop
	nop
	nop
	exx
	dec d
	jp nz,cassoundLoopH
	ld (cassoundInit.casch0cnt0),hl
	jp casreadRow
casPlayDrumSample
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
.casdrumList=$+1
	ld bc,0
	add hl,bc
	ld a,(hl)				;length in 256-sample blocks
	ld b,a
	inc hl
	inc hl
	ld (cassoundInit.casskip),a
	ld a,(hl)
	inc hl
	ld h,(hl)				;sample data
	ld l,a
	ld a,6
	ld (.casmask),a
	ld c,0
.casloop0	ld a,(hl)			;7
.casmask=$+1
	and 0				;7
	sub 1				;7
	sbc a,a				;4
;	and 6			;7
	ld ($6800), a
	ld a,(.casmask)		;13
	rlc a				;8
	ld (.casmask),a		;13
	jr nc,$+3			;7/12
	inc hl				;6
	dec hl				;6
	inc hl				;6
	dec hl				;6
	inc hl				;6
	dec hl				;6
	inc hl				;6
	dec hl				;6
	inc hl				;6
	ld a,0				;7
	dec c				;4
	jr nz,.casloop0		;7/12=105t
	dec b
	jp nz,.casloop0
	jp casreadRow






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




;readRow	--> 	prnreadRow
;soundInit	--> 	prnsoundInit
;soundLoop	--> 	prnsoundLoop
;soundLoopH	--> 	prnsoundLoopH
;PlayDrumSample	--> 	prnPlayDrumSample
;stopPlayer	--> 	prnstopPlayer


	di
	exx
	push hl
	push iy
	ld (prnstopPlayer.prnoldSP),sp
	exx
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (prnreadRow.prnpos),de
	ld (prnreadRow.prnloop),de
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (prnreadRow.prninsList0),de
	ld (prnreadRow.prninsList1),de
	ld (prnPlayDrumSample.prndrumList),hl
	ld hl,0
	ld (prnsoundInit.prnch0cnt0),hl
	ld ix,0						;ch0cnt1
	ld (prnreadRow.prnch1cnt0),hl
	ld iy,0						;ch1cnt1
	ld (prnsoundInit.prnch0add0),hl
	ld sp,hl					;ch0add1
	ld (prnreadRow.prnch1add0),hl
	ld (prnreadRow.prnch1add1),hl
	xor a
	ld (prnreadRow.prnch0int),a
	ld (prnreadRow.prnch1int),a
	ld (prnreadRow.prnch0det),a
	ld (prnreadRow.prnch1det),a
	ld (prnsoundInit.prnskip),a
	ld (prnsoundLoop.prnphaseSlideDivA),a
	ld (prnsoundLoop.prnphaseSlideDivB),a
	ld a,64
	ld (prnreadRow.prnch0pha),a
	ld (prnreadRow.prnch1pha),a
	ld a,8
	ld (prnsoundInit.prnlen),a
	exx
	ld hl,0						;ch1cnt0
	ld de,0						;ch1add1
	ld bc,0						;ch1add0
	exx


prnreadRow
.prnpos=$+1
	ld hl,0
.prnread	ld a,(hl)
	inc hl
	cp 245
	jp c,.prnch0
	jr z,.prnsetSpeed
	cp 254
	jr z,.prnsetLoop
	cp 255
	jr z,.prnreadLoop
	ld (.prnpos),hl
	sub 246
	jp prnPlayDrumSample
.prnsetSpeed
	ld a,(hl)
	ld (prnsoundInit.prnlen),a
	inc hl
	jp .prnread
.prnsetLoop
	ld (.prnloop),hl
	jp .prnread
.prnreadLoop
.prnloop=$+1
	ld hl,0
	jp .prnread
.prnch0mute
	ld sp,0
	ld ix,0
	ld (prnsoundInit.prnch0cnt0),sp
	ld (prnsoundInit.prnch0add0),sp
	jp .prnch1
.prnch1mute
	exx
	ld hl,0
	ld iy,0
	ld d,h
	ld e,h
	ld b,h
	ld c,h
	exx
	jp .prnch1skip
.prnch0	add a,a
	jp nc,.prnnote0			;bit 7 is not set, it is a note
	ex de,hl				;set instrument of channel 0
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
.prninsList0=$+1
	ld bc,0
	add hl,bc
	ld a,(hl)
	inc hl
	ld (.prnch0int),a
	ld a,(hl)
	inc hl
	ld (.prnch0pha),a
	inc a
	jr z,$+4
	ld a,$0a
	xor $0a
	ld (.prnphasereset0),a
	ld a,(hl)
	ld (.prnch0det),a
	inc hl
	ld a,(hl)				;mix mode
	inc hl
	ld (prnsoundLoop.prnopA0),a
	ld (prnsoundLoop.prnopA1),a
	ld (prnsoundLoop.prnopA2),a
	ld (prnsoundLoop.prnopA3),a
	ld c,(hl)				;volume
	inc hl
	ld b,33					;out mask
	ld a,c
	and b
	ld (prnsoundLoop.prnvolA0),a
	rr c
	ld a,c
	and b
	ld (prnsoundLoop.prnvolA1),a
	rr c
	ld a,c
	and b
	ld (prnsoundLoop.prnvolA2),a
	rr c
	ld a,c
	and b
	ld (prnsoundLoop.prnvolA3),a
	ld a,(hl)				;phase slide speed
	inc hl
	ld (prnsoundLoop.prnphaseSlideSpeedA),a
	or a
	jr z,$+4
	ld a,prnsoundLoop.prnphaseSlideA1-prnsoundLoop.prnphaseSlideA0
	xor prnsoundLoop.prnphaseSlideA1-prnsoundLoop.prnphaseSlideA0
	ld (prnsoundLoop.prnphaseSlideEnableA),a
	ld bc,0
	ld (prnsoundLoop.prncntA0Slide+0),bc
	ld (prnsoundLoop.prncntA0Slide+2),bc
	ld (prnsoundLoop.prncntA1Slide+0),bc
	ld (prnsoundLoop.prncntA1Slide+2),bc
	ld a,(hl)				;generator 1 slide
	inc hl
	ld c,a
	or a
	jr z,.prnch0noslide0
	and $0f
	or OP_INCBC&$f0
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntA0Slide+0),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntA0Slide+1),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntA0Slide+2),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntA0Slide+3),a
.prnch0noslide0
	ld a,(hl)				;generator 2 slide
	ld c,a
	or a
	jr z,.prnch0noslide1
	and $0f
	or OP_INCSP&$f0
	rl c

	jr nc,$+5
	ld (prnsoundLoop.prncntA1Slide+0),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntA1Slide+1),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntA1Slide+2),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntA1Slide+3),a
.prnch0noslide1
	ex de,hl
	ld a,(hl)				;instrument always followed by a note
	inc hl
	add a,a
.prnnote0	jp z,.prnch1				;empty row, skip to the second channel
	cp 2
	jp z,.prnch0mute
	ex de,hl
	ld l,a
.prnphasereset0=$+1
	jr $+12					;$+2 to reset, $+12 to skip
	ld ix,(prnsoundInit.prnch0cnt0)
.prnch0pha=$+1
	ld a,0
	add a,ixh
	ld ixh,a
.prnch0phaseresetskip
	ld h,noteTable/256
	ld c,(hl)
	inc l
	ld b,(hl)
	ld (prnsoundInit.prnch0add0),bc
.prnch0int=$+1
	ld a,0
	add a,l
	ld l,a
	ld b,(hl)
	dec l
	ld c,(hl)
.prnch0det=$+1
	ld hl,0
	add hl,bc
	ld sp,hl				;ch0add1
	ex de,hl
.prnch1	ld a,(hl)
	inc hl
	add a,a
	jp nc,.prnnote1
	ex de,hl				;set instrument of channel 1
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
.prninsList1=$+1
	ld bc,0
	add hl,bc
	ld a,(hl)
	inc hl
	ld (.prnch1int),a
	ld a,(hl)
	inc hl
	ld (.prnch1pha),a
	inc a
	jr z,$+4
	ld a,$0a
	xor $0a
	ld (.prnphasereset1),a
	ld a,(hl)
	ld (.prnch1det),a
	inc hl
	ld a,(hl)				;mix mode
	inc hl
	ld (prnsoundLoop.prnopB0),a
	ld (prnsoundLoop.prnopB1),a
	ld (prnsoundLoop.prnopB2),a
	ld (prnsoundLoop.prnopB3),a
	ld c,(hl)				;volume
	inc hl
	ld b,33					;out mask
	ld a,c
	and b
	ld (prnsoundLoop.prnvolB0),a
	rr c
	ld a,c
	and b
	ld (prnsoundLoop.prnvolB1),a

	rr c
	ld a,c
	and b
	ld (prnsoundLoop.prnvolB2),a
	rr c
	ld a,c
	and b
	ld (prnsoundLoop.prnvolB3),a
	ld a,(hl)				;phase slide speed
	inc hl
	ld (prnsoundLoop.prnphaseSlideSpeedB),a
	or a
	jr z,$+4
	ld a,prnsoundLoop.prnphaseSlideB2-prnsoundLoop.prnphaseSlideB0
	xor prnsoundLoop.prnphaseSlideB2-prnsoundLoop.prnphaseSlideB0
	ld (prnsoundLoop.prnphaseSlideEnableB),a
	ld bc,0
	ld (prnsoundLoop.prncntB0Slide+0),bc
	ld (prnsoundLoop.prncntB0Slide+2),bc
	ld (prnsoundLoop.prncntB1Slide+0),bc
	ld (prnsoundLoop.prncntB1Slide+2),bc
	ld a,(hl)				;generator 1 slide
	inc hl
	ld c,a
	or a
	jr z,.prnch1noslide0
	and $0f
	or OP_INCBC&$f0
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntB0Slide+0),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntB0Slide+1),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntB0Slide+2),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntB0Slide+3),a
.prnch1noslide0
	ld a,(hl)				;generator 2 slide
	ld c,a
	or a
	jr z,.prnch1noslide1
	and $0f
	or OP_INCDE&$f0
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntB1Slide+0),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntB1Slide+1),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntB1Slide+2),a
	rl c
	jr nc,$+5
	ld (prnsoundLoop.prncntB1Slide+3),a
.prnch1noslide1
	ex de,hl
	ld a,(hl)
	inc hl
	add a,a
.prnnote1
	jp z,.prnch1skip
	cp 2
	jp z,.prnch1mute
	ex de,hl
	ld l,a
.prnphasereset1=$+1
	jr $+2					;$+2 to reset, $+12 to skip
	ld iy,(.prnch1cnt0)
.prnch1pha=$+1
	ld a,0
	add a,iyh
	ld iyh,a
.prnch1phaseresetskip
	ld h,noteTable/256
	ld c,(hl)
	inc l
	ld b,(hl)
	ld (.prnch1add0),bc
.prnch1int=$+1
	ld a,0
	add a,l
	ld l,a
	ld b,(hl)
	dec l
	ld c,(hl)
.prnch1det=$+1
	ld hl,0
	add hl,bc
	ld (.prnch1add1),hl
	ex de,hl
	exx
.prnch1cnt0=$+1
	ld hl,0
.prnch1add1=$+1
	ld de,0
.prnch1add0=$+1
	ld bc,0
	exx
.prnch1skip
	ld (.prnpos),hl
    xor a
;    in a,($fe)
;    or $e0
    inc a
    jp prnsoundInit
;    jp z,prnsoundInit
prnstopPlayer
.prnoldSP=$+1
	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret



prnsoundInit
.prnskip=$+1
	ld d,0			;drum length to compensate
.prnlen=$+1
	ld a,25		;speed
	sub d
	jp nc,$+5
	ld a,1
	or a
	jp nz,$+5
	ld a,1
	ld d,a
	xor a
	ld (.prnskip),a
.prnch0cnt0=$+1
	ld hl,0
.prnch0add0=$+1
	ld bc,200
prnsoundLoopH
	ld e,64			;4*64 loop repeats, ~85 hz
prnsoundLoop
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.prnopA0=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.prnvolA0=$+1
;	and 33			;7
;	ld ($6800), a
	out	(14), a

	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.prnopB0=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.prnvolB0=$+1
;	and33			;7
;	ld ($6800), a
	out	(14), a
	exx				;4
;	nop				;4
	jr $+2			;12=152
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.prnopA1=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.prnvolA1=$+1
;	and 33			;7
;	ld ($6800), a
	out	(14), a
	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.prnopB1=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.prnvolB1=$+1
;	and 33			;7
;	ld ($6800), a
	out	(14), a

	exx				;4
;	nop				;4
	jr $+2			;12=152
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.prnopA2=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.prnvolA2=$+1
;	and 33			;7
;	ld ($6800), a
	out	(14), a
	exx				;4
	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.prnopB2=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.prnvolB2=$+1
;	and 33			;7
;	ld ($6800), a
	out	(14), a
	exx				;4
;	nop				;4
	jr $+2			;12=152
	add hl,bc		;11
	ld a,h			;4
	add ix,sp		;15
.prnopA3=$+1
	xor ixh			;8
	rla				;4
	sbc a,a			;4
.prnvolA3=$+1
;	and 33			;7
;	ld ($6800), a
	out	(14), a
	exx				;4




	add hl,bc		;11
	ld a,h			;4
	add iy,de		;15
.prnopB3=$+1
	xor iyh			;8
	rla				;4
	sbc a,a			;4
.prnvolB3=$+1
;	and 33			;7
;	ld ($6800), a
	out	(14), a

	exx				;4
	dec e			;4
	jr nz,prnsoundLoop	;12=152
.prnphaseSlideEnableA=$+1
	jr $+2
.prnphaseSlideA0
.prnphaseSlideDivA=$+1
	ld a,0
	inc a
.prnphaseSlideSpeedA=$+1
	cp 1
	jr c,$+3
	xor a
	ld (.prnphaseSlideDivA),a
	jr c,.prnphaseSlideA1
	ld a,ixh
	cp h
	jr z,.prnphaseSlideA1
	inc h
	ld a,ixl
	ld l,a
.prnphaseSlideA1
.prnphaseSlideEnableB=$+1
	jr $+2
.prnphaseSlideB0
.prnphaseSlideDivB=$+1
	ld a,0
	inc a
.prnphaseSlideSpeedB=$+1
	cp 1
	jr c,$+3
	xor a
	ld (.prnphaseSlideDivB),a
	jr c,.prnphaseSlideB2
	exx
	ld a,iyh
	cp h
	jr z,.prnphaseSlideB1
	inc h
	ld a,iyl
	ld l,a


.prnphaseSlideB1
	exx
.prnphaseSlideB2
.prncntA0Slide=$
	nop			;bc
	nop
	nop
	nop
.prncntA1Slide=$
	nop			;sp
	nop
	nop
	nop
	exx
.prncntB0Slide=$
	nop			;bc
	nop
	nop
	nop
.prncntB1Slide=$
	nop			;de
	nop
	nop
	nop
	exx
	dec d
	jp nz,prnsoundLoopH
	ld (prnsoundInit.prnch0cnt0),hl
	jp prnreadRow
prnPlayDrumSample
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
.prndrumList=$+1
	ld bc,0
	add hl,bc
	ld a,(hl)				;length in 256-sample blocks
	ld b,a
	inc hl
	inc hl
	ld (prnsoundInit.prnskip),a
	ld a,(hl)
	inc hl
	ld h,(hl)				;sample data
	ld l,a
	ld a,255
	ld (.prnmask),a
	ld c,0
.prnloop0	ld a,(hl)			;7
.prnmask=$+1
	and 0				;7
	sub 1				;7
	sbc a,a				;4
;	and 33			;7
;	ld ($6800), a
	out	(14), a


	ld a,(.prnmask)		;13
	rlc a				;8
	ld (.prnmask),a		;13
	jr nc,$+3			;7/12
	inc hl				;6
	dec hl				;6
	inc hl				;6
	dec hl				;6
	inc hl				;6
	dec hl				;6
	inc hl				;6
	dec hl				;6
	inc hl				;6
	ld a,0				;7
	dec c				;4
	jr nz,.prnloop0		;7/12=105t
	dec b
	jp nz,.prnloop0
	jp prnreadRow























;-------------------------------------------
do_intro:
;
;                      THIS	 	72x20
;                       IS 	 	28x20
;                     TRITONE 		128x20
;
;-------------------------------------------
	ld	a, 24
	ld	($6800), a		; mode(1):COLOR,1

	ld	hl, $7000		; Do cyan background
	ld	a, $55
	ld	(hl), a
	ld	de, $7001
	ld	bc, 2048
	ldir

	call delay_long

;	ld	hl, THIS		; THIS
	ld	de, $7026
	ld	b, 20
l1a:	push	bc
	ld	bc, 18
	ldir
	ld	bc, 32-18		; add overrun offset
	ex	de, hl
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	l1a

	call delay_long

;	ld	hl, IS			; IS
	ld	de, $7000+717
	ld	b, 20
l1b:	push	bc
	ld	bc, 7
	ldir
	ld	bc, 32-7		; add overrun offset
	ex	de, hl
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	l1b

	call delay_long

;	ld	hl, TRITONE		; TRITONE
	ld	de, $7000+1376
	ld	b, 20
l1c:	push	bc
	ld	bc, 32
	ldir
;	ld	bc, 0
;	ex	de, hl
;	add	hl, bc
;	ex	de, hl
	pop	bc
	djnz	l1c

	call delay_long
	call delay_long
	call delay_long

	ret


delay_long:
	push	bc
	push	hl
	push	de
        LD     	ix, $2500
delayb:	ld	b, $25
delayc:	djnz	delayc
	DEC	IX 	
        LD     	A,ixh            
        OR     	ixl               
        JR     	NZ, delayb
	pop	de
	pop	hl
	pop	bc
	ret



drumSettings
	db 	$01,$01	;tone,highest
	db 	$01,$02
	db 	$01,$04
	db 	$01,$08
	db 	$01,$20
	db 	$20,$04
	db 	$40,$04
	db 	$40,$08	;lowest
	db 	$04,$80	;special
	db 	$08,$80
	db 	$10,$80
	db 	$10,$02
	db 	$20,$02
	db 	$40,$02
	db 	$16,$01	;noise,highest
	db 	$16,$02
	db 	$16,$04
	db 	$16,$08
	db 	$16,$10
	db 	$00,$01
	db 	$00,$02
	db 	$00,$04
	db 	$00,$08
	db 	$00,$10


SPEAKINV db 19,16,05,01,11,05,18,"     ",00		; SPEAKER
CASSEINV db 03,01,19,19,05,20,20,32,16,15,18,20,00	; CASSETT PORT
PRINTINV db 16,18,09,14,20,05,18,32,16,15,18,20,00	; PRINTER PORT
BUSHYINV db "BUSHY",0

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
SONG1INV	dw 28672+99			; SONG#1
		db 06,19,15,14,07,"#",49
SONG2INV	dw 28672+131			; SONG#2
		db 06,19,15,14,07,"#",50
SONG3INV  	dw 28675+128+32			; MOTB
		db 04,13,15,20,02

;                   12345678901234567890123456789012
MSG1: 	db	   "PHASER3 MUSIC BOX! "
	db 	$d
	db	$d,"SELECT:  "
	db 	$d,"1. SONG#1       X: SPEAKER"
	db 	$d,"2. SONG#2       Y: CASSETT PORT",0
                                 
MSG2:	db	$d,"3. MOTB         Z: PRINTER PORT" 
	db 	$d,"                Q: QUIT"
	db	$d,"      "
	db	$d,0

device		db 0			; 0=speaker.  1=Cassette Port.  2=Printer Port.
outdevice	db 33




	align 256

noteTable
	dw $0000,$0000
	dw $0030,$0033,$0036,$003a,$003d,$0041,$0045,$0049,$004d,$0052,$0057,$005c
	dw $0061,$0067,$006d,$0074,$007b,$0082,$008a,$0092,$009b,$00a4,$00ae,$00b8
	dw $00c3,$00cf,$00db,$00e9,$00f6,$0105,$0115,$0125,$0137,$0149,$015d,$0171
	dw $0187,$019f,$01b7,$01d2,$01ed,$020b,$022a,$024b,$026e,$0293,$02ba,$02e3
	dw $030f,$033e,$036f,$03a4,$03db,$0416,$0454,$0496,$04dc,$0526,$0574,$05c7
	dw $061f,$067c,$06df,$0748,$07b7,$082c,$08a8,$092c,$09b8,$0a4c,$0ae9,$0b8f
	dw $0c3f,$0cf9,$0dbf,$0e90,$0f6e,$1059,$1151,$1259,$1370,$1498,$15d2,$171e
	dw $187e,$19f3,$1b7e,$1d20,$1edc,$20b2,$22a3,$24b3,$26e1,$2931,$2ba4,$2e3c
	dw $30fc,$33e6,$36fc,$3a41,$3db8,$4164,$4547,$4966,$4dc3,$5263,$5748,$5c79
	dw $61f9,$67cc,$6df8,$7483,$7b71,$82c8,$8a8f,$92cc,$9b86,$a4c6,$ae91,$b8f3



; ========================================================
; PHASER3 SONG1
; ========================================================


 align 256
SONG1:
 dw P3S1sequence
 dw P3S1insList
P3S1drums
 dw 4,P3S1drum0
 dw 4,P3S1drum1
 dw 4,P3S1drum2
 dw 4,P3S1drum3
 dw 4,P3S1drum4
 dw 4,P3S1drum5
 dw 4,P3S1drum6
 dw 4,P3S1drum7
P3S1drum0
P3S1drum1
P3S1drum2
P3S1drum3
P3S1drum4
P3S1drum5
P3S1drum6
P3S1drum7
P3S1insList
 db 0,255,4,172,240,0,0,0
P3S1sequence
 db $f5,7
 db 128,35,128,1
 db 0,0
 db 54,0
 db 0,0
 db 35,0
 db 0,0
 db 0,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 35,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 35,0
 db 0,0
 db 50,0
 db 0,0
 db 35,0
 db 0,0
 db 49,0
 db 0,0
 db 35,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 31,0
 db 0,0
 db 54,0
 db 0,0
 db 31,0
 db 0,0
 db 0,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 31,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 31,0
 db 0,0
 db 49,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 31,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 28,0
 db 0,0
 db 54,0
 db 0,0
 db 28,0
 db 0,0
 db 0,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 28,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 28,0
 db 0,0
 db 50,0
 db 0,0
 db 28,0
 db 0,0
 db 49,0
 db 0,0
 db 28,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 31,0
 db 0,0
 db 50,0
 db 0,0
 db 31,0
 db 0,0
 db 0,0
 db 0,0
 db 49,0
 db 0,0
 db 0,0
 db 0,0
 db 50,0
 db 0,0
 db 0,0
 db 0,0
 db 33,0
 db 0,0
 db 50,0
 db 0,0
 db 33,0
 db 0,0
 db 0,0
 db 0,0
 db 49,45
 db 0,40
 db 0,37
 db 0,35
 db 50,33
 db 0,28
 db 0,25
 db 0,23
 db 35,35
 db 0,1
 db 54,35
 db 0,1
 db 35,35
 db 0,1
 db 0,35
 db 0,1
 db 50,35
 db 0,1
 db 0,35
 db 0,1
 db 35,35
 db 0,1
 db 50,35
 db 0,1
 db 0,35
 db 0,1
 db 35,35
 db 0,1
 db 50,35
 db 0,1
 db 35,35
 db 0,1
 db 49,35
 db 0,1
 db 35,35
 db 0,1
 db 50,35
 db 0,1
 db 0,35
 db 0,1
 db 31,31
 db 0,1
 db 54,31
 db 0,1
 db 31,31
 db 0,1
 db 0,31
 db 0,1
 db 50,31
 db 0,1
 db 0,31
 db 0,1
 db 31,31
 db 0,1
 db 50,31
 db 0,1
 db 0,31
 db 0,1
 db 31,31
 db 0,1
 db 49,31
 db 0,1
 db 50,31
 db 0,1
 db 0,43
 db 0,38
 db 31,35
 db 0,33
 db 0,31
 db 0,26
 db 0,23
 db 0,21
 db 28,28
 db 0,1
 db 54,28
 db 0,1
 db 28,28
 db 0,1
 db 0,28
 db 0,1
 db 50,28
 db 0,1
 db 0,28
 db 0,1
 db 28,28
 db 0,1
 db 50,28
 db 0,1
 db 0,28
 db 0,1
 db 28,28
 db 0,1
 db 50,28
 db 0,1
 db 28,28
 db 0,1
 db 49,28
 db 0,1
 db 28,28
 db 0,1
 db 50,28
 db 0,1
 db 0,28
 db 0,1
 db 31,31
 db 0,1
 db 50,31
 db 0,1
 db 31,31
 db 0,1
 db 0,31
 db 0,1
 db 49,31
 db 0,1
 db 0,31
 db 0,1
 db 50,31
 db 0,1
 db 0,31
 db 0,1
 db 33,33
 db 0,1
 db 0,33
 db 0,1
 db 49,33
 db 0,1
 db 50,33
 db 0,1
 db 0,33
 db 0,1
 db 49,33
 db 47,1
 db 45,33
 db 42,1
 db 1,33
 db 0,1
 db 50,35
 db 1,1
 db 50,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,47
 db 1,1
 db 0,35
 db 0,1
 db 54,35
 db 1,1
 db 54,47
 db 1,1
 db 0,35
 db 0,1
 db 54,35
 db 1,1
 db 54,47
 db 1,1
 db 52,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,47
 db 1,1
 db 0,35
 db 0,1
 db 54,35
 db 1,1
 db 54,47
 db 1,1
 db 0,35
 db 0,1
 db 54,35
 db 1,1
 db 54,47
 db 1,1
 db 52,35
 db 1,1
 db 0,47
 db 0,1
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 52,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 52,31
 db 1,0
 db 0,43
 db 0,0
 db 50,28
 db 1,0
 db 50,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,40
 db 1,0
 db 0,28
 db 0,0
 db 54,28
 db 1,0
 db 54,40
 db 1,0
 db 0,28
 db 0,0
 db 54,28
 db 1,0
 db 54,40
 db 1,0
 db 52,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,40
 db 1,0
 db 0,28
 db 0,0
 db 54,28
 db 1,0
 db 54,40
 db 1,0
 db 0,28
 db 0,0
 db 54,28
 db 1,0
 db 54,40
 db 1,0
 db 52,28
 db 1,0
 db 0,40
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 52,31
 db 1,0
 db 0,43
 db 0,0
 db 50,33
 db 1,0
 db 50,33
 db 1,0
 db 0,45
 db 0,0
 db 50,33
 db 1,0
 db 50,33
 db 1,0
 db 0,45
 db 0,0
 db 50,33
 db 1,0
 db 50,45
 db 1,0
 db 0,33
 db 0,0
 db 54,33
 db 1,0
 db 54,45
 db 1,0
 db 0,33
 db 0,0
 db 54,33
 db 1,0
 db 54,45
 db 1,0
 db 52,33
 db 1,0
 db 0,45
 db 0,0
 db 47,35
 db 1,0
 db 47,35
 db 1,0
 db 0,1
 db 0,0
 db 47,35
 db 1,0
 db 47,35
 db 1,0
 db 0,1
 db 0,0
 db 47,35
 db 1,0
 db 47,35
 db 1,0
 db 0,62
 db 0,1
 db 0,61
 db 0,1
 db 62,59
 db 1,1
 db 61,54
 db 1,1
 db 59,62
 db 1,1
 db 54,61
 db 1,1
 db 62,59
 db 1,1
 db 61,54
 db 1,1
 db 47,35
 db 1,0
 db 47,35
 db 1,0
 db 0,1
 db 0,0
 db 47,35
 db 1,0
 db 47,35
 db 1,0
 db 0,1
 db 0,0
 db 47,35
 db 1,0
 db 47,35
 db 1,0
 db 0,1
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 35,35
 db 0,1
 db 54,35
 db 0,1
 db 35,35
 db 0,1
 db 0,35
 db 0,1
 db 50,35
 db 0,1
 db 0,35
 db 0,1
 db 35,35
 db 0,1
 db 50,35
 db 0,1
 db 0,35
 db 0,1
 db 35,35
 db 0,1
 db 50,35
 db 0,1
 db 35,35
 db 0,1
 db 49,35
 db 0,1
 db 35,35
 db 0,1
 db 50,35
 db 0,1
 db 0,35
 db 0,1
 db 31,31
 db 0,1
 db 54,31
 db 0,1
 db 31,31
 db 0,1
 db 0,31
 db 0,1
 db 50,31
 db 0,1
 db 0,31
 db 0,1
 db 31,31
 db 0,1
 db 50,31
 db 0,1
 db 0,31
 db 0,1
 db 31,31
 db 0,1
 db 49,31
 db 0,1
 db 50,31
 db 0,1
 db 0,31
 db 0,1
 db 31,31
 db 0,1
 db 0,31
 db 0,1
 db 0,31
 db 0,1
 db 28,28
 db 0,1
 db 54,28
 db 0,1
 db 28,28
 db 0,1
 db 0,28
 db 0,1
 db 50,28
 db 0,1
 db 0,28
 db 0,1
 db 28,28
 db 0,1
 db 50,28
 db 0,1
 db 0,28
 db 0,1
 db 28,28
 db 0,1
 db 50,28
 db 0,1
 db 28,28
 db 0,1
 db 49,28
 db 0,1
 db 28,28
 db 0,1
 db 50,28
 db 0,1
 db 0,28
 db 0,1
 db 31,31
 db 0,1
 db 50,31
 db 0,1
 db 31,31
 db 0,1
 db 0,31
 db 0,1
 db 49,31
 db 0,1
 db 0,31
 db 0,1
 db 50,31
 db 0,1
 db 0,31
 db 0,1
 db 33,33
 db 0,1
 db 50,33
 db 0,1
 db 33,33
 db 0,1
 db 0,33
 db 0,1
 db 49,45
 db 0,40
 db 0,37
 db 0,35
 db 50,33
 db 0,28
 db 0,25
 db 0,23
 db 35,35
 db 0,1
 db 54,35
 db 0,1
 db 35,47
 db 0,1
 db 0,35
 db 0,1
 db 50,35
 db 0,1
 db 0,47
 db 0,1
 db 35,35
 db 0,1
 db 50,47
 db 0,1
 db 0,35
 db 0,1
 db 35,35
 db 0,1
 db 50,47
 db 0,1
 db 35,35
 db 0,1
 db 49,35
 db 0,1
 db 35,47
 db 0,1
 db 50,35
 db 0,1
 db 0,47
 db 0,1
 db 31,31
 db 0,1
 db 54,31
 db 0,1
 db 31,43
 db 0,1
 db 0,31
 db 0,1
 db 50,31
 db 0,1
 db 0,43
 db 0,1
 db 31,31
 db 0,1
 db 50,43
 db 0,1
 db 0,31
 db 0,1
 db 31,31
 db 0,1
 db 49,43
 db 0,1
 db 50,31
 db 0,1
 db 0,43
 db 0,38
 db 31,35
 db 0,33
 db 0,31
 db 0,26
 db 0,23
 db 0,21
 db 28,28
 db 0,1
 db 54,28
 db 0,1
 db 28,40
 db 0,1
 db 0,28
 db 0,1
 db 50,28
 db 0,1
 db 0,40
 db 0,1
 db 28,28
 db 0,1
 db 50,40
 db 0,1
 db 0,28
 db 0,1
 db 28,28
 db 0,1
 db 50,40
 db 0,1
 db 28,28
 db 0,1
 db 49,28
 db 0,1
 db 28,40
 db 0,1
 db 50,28
 db 0,1
 db 0,40
 db 0,1
 db 31,31
 db 0,1
 db 50,31
 db 0,1
 db 31,43
 db 0,1
 db 0,31
 db 0,1
 db 49,31
 db 0,1
 db 0,43
 db 0,1
 db 50,31
 db 0,1
 db 0,43
 db 0,1
 db 33,33
 db 0,1
 db 50,33
 db 0,1
 db 1,33
 db 0,1
 db 0,33
 db 0,1
 db 49,45
 db 0,42
 db 0,40
 db 0,37
 db 50,33
 db 0,30
 db 0,28
 db 0,25
 db 50,35
 db 1,1
 db 50,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,47
 db 1,1
 db 0,35
 db 0,1
 db 54,35
 db 1,1
 db 54,47
 db 1,1
 db 0,35
 db 0,1
 db 54,35
 db 1,1
 db 54,47
 db 1,1
 db 52,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,35
 db 1,1
 db 0,47
 db 0,1
 db 50,35
 db 1,1
 db 50,47
 db 1,1
 db 0,35
 db 0,1
 db 54,35
 db 1,1
 db 54,47
 db 1,1
 db 0,35
 db 0,1
 db 54,35
 db 1,1
 db 54,47
 db 1,1
 db 52,35
 db 1,1
 db 0,47
 db 0,1
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 52,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 52,31
 db 1,0
 db 0,43
 db 0,0
 db 50,28
 db 1,0
 db 50,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,40
 db 1,0
 db 0,28
 db 0,0
 db 54,28
 db 1,0
 db 54,40
 db 1,0
 db 0,28
 db 0,0
 db 54,28
 db 1,0
 db 54,40
 db 1,0
 db 52,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,28
 db 1,0
 db 0,40
 db 0,0
 db 50,28
 db 1,0
 db 50,40
 db 1,0
 db 0,28
 db 0,0
 db 54,28
 db 1,0
 db 54,40
 db 1,0
 db 0,28
 db 0,0
 db 54,28
 db 1,0
 db 54,40
 db 1,0
 db 52,28
 db 1,0
 db 0,40
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,31
 db 1,0
 db 0,43
 db 0,0
 db 50,31
 db 1,0
 db 50,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 0,31
 db 0,0
 db 54,31
 db 1,0
 db 54,43
 db 1,0
 db 52,31
 db 1,0
 db 0,43
 db 0,0
 db 50,33
 db 1,0
 db 50,33
 db 1,0
 db 0,45
 db 0,0
 db 50,33
 db 1,0
 db 50,33
 db 1,0
 db 0,45
 db 0,0
 db 50,33
 db 1,0
 db 50,45
 db 1,0
 db 0,33
 db 0,0
 db 54,33
 db 1,0
 db 54,45
 db 1,0
 db 0,33
 db 0,0
 db 54,33
 db 1,0
 db 54,45
 db 1,0
 db 52,33
 db 1,0
 db 0,45
 db 0,0
 db 55,31
 db 1,0
 db 50,31
 db 1,0
 db 59,43
 db 55,0
 db 50,31
 db 50,0
 db 55,31
 db 59,0
 db 50,43
 db 50,0
 db 59,31
 db 55,0
 db 50,43
 db 50,0
 db 55,31
 db 59,0
 db 50,31
 db 50,0
 db 59,43
 db 55,0
 db 50,31
 db 50,0
 db 55,31
 db 59,0
 db 50,43
 db 50,0
 db 59,31
 db 55,0
 db 50,43
 db 50,0
 db 54,33
 db 1,0
 db 50,33
 db 1,0
 db 57,45
 db 54,0
 db 50,33
 db 50,0
 db 54,33
 db 57,0
 db 50,45
 db 50,0
 db 57,33
 db 54,0
 db 50,45
 db 50,0
 db 54,33
 db 57,0
 db 50,33
 db 50,0
 db 57,45
 db 54,0
 db 50,33
 db 50,0
 db 54,33
 db 57,0
 db 50,45
 db 50,0
 db 57,33
 db 54,0
 db 50,45
 db 50,0
 db 67,31
 db 1,0
 db 50,31
 db 1,0
 db 59,43
 db 67,0
 db 50,31
 db 50,0
 db 67,31
 db 59,0
 db 50,43
 db 50,0
 db 59,31
 db 67,0
 db 50,43
 db 50,0
 db 67,31
 db 59,0
 db 50,31
 db 50,0
 db 59,43
 db 67,0
 db 50,31
 db 50,0
 db 67,31
 db 59,0
 db 50,43
 db 50,0
 db 59,31
 db 67,0
 db 50,43
 db 50,0
 db 66,28
 db 1,0
 db 50,28
 db 1,0
 db 57,40
 db 66,0
 db 50,28
 db 50,0
 db 66,28
 db 57,0
 db 50,40
 db 50,0
 db 57,28
 db 66,0
 db 50,40
 db 50,0
 db 66,30
 db 57,0
 db 50,30
 db 50,0
 db 57,42
 db 66,0
 db 50,30
 db 50,0
 db 66,30
 db 57,0
 db 50,42
 db 50,0
 db 57,30
 db 66,0
 db 50,42
 db 50,0
 db 67,31
 db 1,0
 db 50,31
 db 1,0
 db 71,43
 db 67,0
 db 50,31
 db 50,0
 db 67,31
 db 71,0
 db 50,43
 db 50,0
 db 71,31
 db 67,0
 db 50,43
 db 50,0
 db 67,31
 db 71,0
 db 50,31
 db 50,0
 db 71,43
 db 67,0
 db 50,31
 db 50,0
 db 67,31
 db 71,0
 db 50,43
 db 50,0
 db 71,31
 db 67,0
 db 50,43
 db 50,0
 db 66,33
 db 1,0
 db 50,33
 db 1,0
 db 69,45
 db 66,0
 db 50,33
 db 50,0
 db 66,33
 db 69,0
 db 50,45
 db 50,0
 db 69,33
 db 66,0
 db 50,45
 db 50,0
 db 66,33
 db 69,0
 db 50,33
 db 50,0
 db 69,45
 db 66,0
 db 50,33
 db 50,0
 db 66,33
 db 69,0
 db 50,45
 db 50,0
 db 69,33
 db 66,0
 db 50,45
 db 50,0
 db 71,35
 db 1,0
 db 71,35
 db 1,0
 db 0,1
 db 0,0
 db 71,35
 db 1,0
 db 71,35
 db 1,0
 db 0,1
 db 0,0
 db 71,35
 db 1,0
 db 71,35
 db 1,0
 db 0,1
 db 0,0
 db 71,0
 db 1,0
 db 71,0
 db 1,0
 db 0,0
 db 0,0
 db 71,0
 db 1,0
 db 0,0
 db 0,0
 db 71,0
 db 1,0
 db 71,0
 db 1,0
 db 47,35
 db 1,0
 db 47,35
 db 1,0
 db 0,1
 db 0,0
 db 47,35
 db 1,0
 db 47,35
 db 1,0
 db 0,1
 db 0,0
 db 47,35
 db 1,0
 db 47,35
 db 1,0
 db 0,1
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 47,35
 db 47,0
 db 47,0
 db 47,0
 db 47,0
 db 47,0
 db 47,0
 db 0,0
 db 1,1
 db $fe,$01,$01,$ff
 db $ff




; ========================================================
; PHASER3 SONG2
; ========================================================

 align 256
SONG2:
 dw P3S2sequence
 dw P3S2insList
P3S2drums
 dw 4,P3S2drum0
 dw 4,P3S2drum1
 dw 4,P3S2drum2
 dw 4,P3S2drum3
 dw 4,P3S2drum4
 dw 4,P3S2drum5
 dw 4,P3S2drum6
 dw 4,P3S2drum7
P3S2drum0
P3S2drum1
P3S2drum2
P3S2drum3
P3S2drum4
P3S2drum5
P3S2drum6
P3S2drum7
P3S2insList
 db 0,255,4,172,240,0,0,0
P3S2sequence
 db $f5,18
 db 128,33,0
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 33,0
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 33,0
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 33,0
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 33,0
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 33,0
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 33,0
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 33,0
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 33,0
 db 28,128,28
 db 33,1
 db 28,28
 db 31,1
 db 26,26
 db 31,1
 db 26,26
 db 33,1
 db 28,28
 db 33,1
 db 28,28
 db 31,1
 db 26,26
 db 31,1
 db 26,26
 db 33,1
 db 28,28
 db 33,1
 db 28,28
 db 31,1
 db 26,26
 db 31,1
 db 26,26
 db 33,1
 db 28,28
 db 33,1
 db 28,28
 db 31,1
 db 26,26
 db 31,1
 db 26,26
 db 33,1
 db 28,28
 db 33,1
 db 28,28
 db 31,1
 db 26,26
 db 31,1
 db 26,26
 db 33,1
 db 28,28
 db 33,1
 db 28,28
 db 31,1
 db 26,26
 db 31,1
 db 26,26
 db 33,1
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 33,0
 db 28,0
 db 33,0
 db 28,0
 db 31,0
 db 26,0
 db 31,0
 db 26,0
 db 45,21
 db 43,0
 db 40,33
 db 38,1
 db 40,21
 db 0,0
 db 0,33
 db 0,1
 db 0,0
 db 38,0
 db 35,33
 db 33,1
 db 40,21
 db 38,0
 db 35,33
 db 33,1
 db 26,21
 db 28,0
 db 31,33
 db 33,1
 db 28,21
 db 0,0
 db 0,33
 db 0,1
 db 0,0
 db 0,0
 db 0,33
 db 0,1
 db 0,21
 db 45,0
 db 43,33
 db 40,1
 db 40,16
 db 0,0
 db 0,28
 db 0,1
 db 0,16
 db 0,0
 db 0,28
 db 0,1
 db 0,0
 db 0,0
 db 0,28
 db 0,1
 db 45,16
 db 0,0
 db 0,28
 db 40,1
 db 0,16
 db 0,0
 db 40,28
 db 0,1
 db 1,16
 db 40,0
 db 0,28
 db 1,1
 db 40,0
 db 0,0
 db 1,28
 db 40,1
 db 1,16
 db 40,0
 db 0,28
 db 0,1
 db 31,19
 db 35,0
 db 38,31
 db 40,1
 db 38,19
 db 0,0
 db 0,31
 db 0,1
 db 0,0
 db 0,0
 db 0,31
 db 0,1
 db 31,19
 db 35,0
 db 38,31
 db 43,1
 db 47,19
 db 45,0
 db 43,31
 db 45,1
 db 47,19
 db 0,0
 db 0,31
 db 0,1
 db 0,0
 db 0,0
 db 0,31
 db 0,1
 db 0,19
 db 40,0
 db 38,31
 db 40,1
 db 38,14
 db 0,0
 db 0,26
 db 0,1
 db 0,14
 db 0,0
 db 0,26
 db 0,1
 db 0,0
 db 0,0
 db 0,26
 db 0,1
 db 45,14
 db 0,0
 db 42,26
 db 0,1
 db 0,14
 db 0,0
 db 0,26
 db 0,1
 db 0,14
 db 0,0
 db 0,26
 db 0,1
 db 42,0
 db 0,0
 db 1,26
 db 42,1
 db 0,14
 db 1,0
 db 42,26
 db 0,1
 db 45,21
 db 43,0
 db 40,33
 db 38,1
 db 40,21
 db 0,0
 db 0,33
 db 0,1
 db 0,0
 db 38,0
 db 35,33
 db 33,1
 db 40,21
 db 38,0
 db 35,33
 db 33,1
 db 26,21
 db 28,0
 db 31,33
 db 33,1
 db 28,21
 db 0,0
 db 0,33
 db 0,1
 db 0,0
 db 0,0
 db 0,33
 db 0,1
 db 0,21
 db 45,0
 db 43,33
 db 40,1
 db 40,16
 db 0,0
 db 0,28
 db 0,1
 db 0,16
 db 0,0
 db 0,28
 db 0,1
 db 0,0
 db 0,0
 db 0,28
 db 0,1
 db 45,16
 db 0,0
 db 0,28
 db 40,1
 db 0,16
 db 0,0
 db 40,28
 db 0,1
 db 1,16
 db 40,0
 db 0,28
 db 1,1
 db 40,0
 db 0,0
 db 1,28
 db 40,1
 db 1,16
 db 40,0
 db 0,28
 db 0,1
 db 31,19
 db 35,0
 db 38,31
 db 40,1
 db 38,19
 db 0,0
 db 0,31
 db 0,1
 db 0,0
 db 0,0
 db 0,31
 db 0,1
 db 31,19
 db 35,0
 db 38,31
 db 43,1
 db 47,19
 db 45,0
 db 43,31
 db 45,1
 db 47,19
 db 0,0
 db 0,31
 db 0,1
 db 0,0
 db 0,0
 db 0,31
 db 0,1
 db 0,19
 db 40,0
 db 38,31
 db 40,1
 db 38,14
 db 0,0
 db 0,26
 db 0,1
 db 0,14
 db 0,0
 db 0,26
 db 0,1
 db 0,0
 db 0,0
 db 0,26
 db 0,1
 db 45,14
 db 0,0
 db 42,26
 db 0,1
 db 0,14
 db 0,0
 db 0,26
 db 0,1
 db 0,14
 db 0,0
 db 0,26
 db 0,1
 db 42,42
 db 0,1
 db 1,0
 db 42,42
 db 0,1
 db 1,0
 db 42,42
 db 0,1
 db 33,21
 db 0,0
 db 0,0
 db 1,1
 db 21,21
 db 0,1
 db 1,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 38,21
 db 0,1
 db 33,21
 db 0,0
 db 0,0
 db 1,1
 db 21,21
 db 0,1
 db 1,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 0,26
 db 0,0
 db 33,21
 db 0,0
 db 0,0
 db 1,1
 db 21,21
 db 0,1
 db 1,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 38,21
 db 0,1
 db 33,21
 db 0,0
 db 0,0
 db 1,1
 db 33,21
 db 30,1
 db 26,21
 db 28,1
 db 33,21
 db 0,1
 db 1,21
 db 33,1
 db 0,21
 db 1,1
 db 33,26
 db 0,0
 db 33,21
 db 0,0
 db 0,0
 db 1,1
 db 21,21
 db 0,1
 db 1,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 38,21
 db 0,1
 db 33,21
 db 0,0
 db 0,0
 db 1,1
 db 21,21
 db 0,1
 db 1,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 0,21
 db 0,1
 db 33,21
 db 0,0
 db 0,0
 db 1,1
 db 21,0
 db 0,0
 db 1,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 38,0
 db 0,0
 db 33,0
 db 0,0
 db 0,0
 db 1,0
 db 21,0
 db 0,0
 db 1,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 38,21
 db 40,0
 db 1,1
 db 40,21
 db 0,0
 db 1,1
 db 40,21
 db 1,1
 db 40,21
 db 0,0
 db 1,1
 db 0,0
 db 40,0
 db 38,0
 db 35,21
 db 33,0
 db 35,16
 db 0,0
 db 1,1
 db 35,16
 db 0,0
 db 1,1
 db 35,16
 db 1,1
 db 28,16
 db 0,0
 db 1,1
 db 28,0
 db 0,0
 db 1,0
 db 35,16
 db 0,0
 db 38,19
 db 0,0
 db 1,1
 db 38,19
 db 0,0
 db 1,1
 db 38,19
 db 1,1
 db 38,19
 db 0,0
 db 1,1
 db 0,0
 db 38,0
 db 35,0
 db 33,19
 db 30,0
 db 33,14
 db 0,0
 db 1,1
 db 33,14
 db 0,0
 db 1,1
 db 33,14
 db 1,1
 db 30,14
 db 0,0
 db 1,1
 db 30,14
 db 0,0
 db 1,1
 db 30,14
 db 0,0
 db 38,21
 db 40,0
 db 1,1
 db 40,33
 db 0,0
 db 1,1
 db 40,21
 db 1,1
 db 40,33
 db 0,0
 db 1,1
 db 0,0
 db 40,0
 db 38,0
 db 35,21
 db 33,0
 db 35,16
 db 0,0
 db 1,1
 db 35,28
 db 0,0
 db 1,1
 db 35,16
 db 1,1
 db 28,28
 db 0,0
 db 1,1
 db 28,0
 db 0,0
 db 1,0
 db 35,16
 db 0,0
 db 38,19
 db 0,0
 db 1,1
 db 38,31
 db 0,0
 db 1,1
 db 38,19
 db 1,1
 db 38,31
 db 0,0
 db 1,1
 db 0,0
 db 38,0
 db 35,0
 db 33,19
 db 30,0
 db 33,14
 db 0,0
 db 1,1
 db 33,26
 db 0,0
 db 1,1
 db 33,14
 db 1,1
 db 30,26
 db 0,0
 db 1,1
 db 30,0
 db 0,0
 db 1,0
 db 30,14
 db 0,0
 db 33,21
 db 35,0
 db 38,1
 db 40,33
 db 35,0
 db 38,1
 db 40,21
 db 42,1
 db 38,33
 db 40,0
 db 42,1
 db 45,0
 db 42,0
 db 45,0
 db 47,21
 db 50,0
 db 35,16
 db 0,0
 db 35,1
 db 35,28
 db 0,0
 db 35,1
 db 35,16
 db 1,1
 db 28,28
 db 0,0
 db 1,1
 db 28,0
 db 0,0
 db 1,0
 db 35,16
 db 0,0
 db 50,19
 db 47,0
 db 45,1
 db 43,31
 db 47,0
 db 45,1
 db 43,19
 db 40,1
 db 45,31
 db 43,0
 db 40,1
 db 38,0
 db 38,0
 db 35,0
 db 33,19
 db 30,0
 db 33,14
 db 0,0
 db 1,1
 db 33,26
 db 0,0
 db 1,1
 db 33,14
 db 1,1
 db 30,26
 db 0,0
 db 1,1
 db 30,0
 db 0,0
 db 1,0
 db 30,14
 db 0,0
 db 33,21
 db 35,0
 db 38,1
 db 40,33
 db 35,0
 db 38,1
 db 40,21
 db 42,1
 db 38,33
 db 40,0
 db 42,1
 db 45,0
 db 42,0
 db 45,0
 db 47,21
 db 50,0
 db 35,16
 db 0,0
 db 35,1
 db 35,28
 db 0,0
 db 35,1
 db 35,16
 db 1,1
 db 28,28
 db 0,0
 db 1,1
 db 28,0
 db 0,0
 db 1,0
 db 35,16
 db 0,0
 db 50,19
 db 47,0
 db 45,1
 db 43,31
 db 47,0
 db 45,1
 db 43,19
 db 40,1
 db 45,31
 db 43,0
 db 40,1
 db 38,0
 db 38,0
 db 35,0
 db 33,19
 db 30,0
 db 33,14
 db 0,0
 db 1,1
 db 33,26
 db 0,0
 db 1,1
 db 33,14
 db 1,1
 db 30,26
 db 0,0
 db 1,1
 db 30,0
 db 0,0
 db 1,0
 db 30,14
 db 0,0
 db 33,21
 db 1,0
 db 0,0
 db 33,0
 db 1,0
 db 0,0
 db 33,0
 db 1,0
 db 33,1
 db 0,0
 db 1,0
 db 33,0
 db 0,0
 db 1,0
 db 33,0
 db 1,0
 db 21,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 0,0
 db 1,0
 db $fe,$01,$01,$ff
 db $ff



; ========================================================
; SONG3 MOTB
; ========================================================

 align 256
SONG3:
 dw motbsequence
 dw motbinsList
motbdrums
 dw 2,motbdrum0
 dw 4,motbdrum1
 dw 1,motbdrum2
 dw 16,motbdrum3
 dw 11,motbdrum4
 dw 12,motbdrum5
 dw 12,motbdrum6
 dw 14,motbdrum7
motbdrum0
 db $00,$00,$00,$00,$00,$00,$00,$08,$7e,$7f,$ff,$ff,$ff,$ff,$8f,$03
 db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$70,$fe,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$47,$00,$00,$00
 db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
motbdrum1
 db $00,$00,$f8,$ff,$ff,$0f,$00,$00,$00,$00,$00,$00,$c0,$ff,$ff,$ff
 db $ff,$ff,$04,$00,$00,$00,$00,$f0,$ff,$ff,$ff,$7f,$2b,$09,$00,$00
 db $00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$17,$00,$00,$00,$00,$00,$00
 db $7e,$fc,$ff,$fd,$4f,$01,$00,$00,$00,$00,$00,$40,$52,$e6,$bf,$fb
 db $df,$26,$00,$00,$00,$00,$00,$00,$80,$e8,$ff,$fd,$cf,$6e,$00,$00
 db $00,$00,$00,$00,$00,$00,$69,$d3,$36,$2f,$00,$00,$00,$04,$00,$00
 db $00,$00,$00,$bc,$3c,$d8,$16,$9a,$00,$00,$00,$00,$00,$00,$00,$01
 db $22,$c9,$c4,$43,$10,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00
motbdrum2
 db $84,$02,$aa,$84,$52,$55,$2a,$a0,$10,$0a,$29,$00,$02,$54,$02,$05
 db $04,$00,$80,$00,$82,$60,$04,$28,$00,$50,$08,$54,$80,$00,$04,$00
motbdrum3
 db $00,$38,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$e0,$ff,$03
 db $e0,$83,$1f,$60,$00,$0c,$00,$0c,$00,$fe,$81,$ff,$8f,$ff,$ff,$f1
 db $ff,$3f,$fe,$ff,$3f,$00,$fe,$ff,$00,$00,$07,$00,$00,$00,$00,$00
 db $00,$00,$fc,$1f,$00,$00,$00,$fc,$ff,$7f,$00,$00,$fc,$ff,$ff,$ff
 db $7f,$00,$fe,$ff,$ff,$ff,$ff,$0f,$00,$00,$00,$f8,$ff,$ff,$ff,$01
 db $00,$00,$00,$00,$00,$e0,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$80
 db $ff,$ff,$ff,$ff,$ff,$ff,$0f,$00,$00,$00,$00,$00,$fe,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$3f,$00,$00,$00,$00,$00,$00,$e0,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00
 db $00,$00,$00,$00,$00,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$07
 db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fc,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 db $00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$0f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fc,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 db $00,$00,$00,$00,$00,$00,$00,$00,$fc,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
motbdrum4
 db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fe,$ff,$ff,$0f,$c0
 db $ff,$ff,$07,$00,$f8,$ff,$ff,$7f,$80,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$00,$ff,$ff,$1f,$00,$00,$80,$ff,$01,$00
 db $00,$f8,$01,$00,$00,$00,$ff,$1f,$00,$e0,$ff,$1f,$00,$00,$fe,$ff
 db $ff,$01,$00,$f8,$ff,$00,$ff,$1f,$f8,$ff,$ff,$03,$e0,$ff,$7f,$00
 db $f0,$ff,$cf,$01,$c0,$01,$f8,$07,$00,$00,$e0,$1f,$00,$00,$80,$f3
 db $ff,$0f,$00,$fe,$ff,$01,$00,$c0,$ff,$ff,$ff,$1f,$00,$e0,$ff,$ff
 db $03,$f0,$ff,$ff,$ff,$c1,$ff,$ff,$ff,$00,$ff,$ff,$1f,$00,$fc,$9f
 db $7f,$00,$fc,$01,$c0,$01,$00,$00,$38,$f8,$ff,$00,$e0,$ff,$1f,$00
 db $00,$f0,$0f,$fc,$ff,$0f,$00,$fe,$ff,$3f,$c0,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$7f,$fc,$ff,$ff,$0f,$c0,$ff,$c1,$3f,$00,$07,$00,$ff,$00
 db $00,$80,$1f,$fc,$0f,$00,$fe,$ff,$01,$00,$00,$fe,$c1,$ff,$ff,$00
 db $e0,$ff,$1f,$80,$ff,$ff,$83,$ff,$ff,$ff,$ff,$ff,$3f,$fe,$ff,$ff
 db $07,$00,$ff,$ff,$03,$80,$ff,$03,$00,$00,$00,$c0,$c1,$ff,$01,$c0
 db $ff,$1f,$00,$00,$00,$00,$fc,$ff,$03,$80,$ff,$3f,$00,$fe,$ff,$01
 db $f8,$ff,$07,$e0,$ff,$1f,$80,$ff,$7f,$00,$f0,$ff,$01,$c0,$ff,$07
 db $00,$f8,$3f,$00,$00,$ff,$e0,$7f,$00,$f0,$ff,$03,$00,$00,$c0,$c1
 db $ff,$3f,$00,$f8,$ff,$07,$fc,$ff,$00,$e0,$ff,$0f,$80,$ff,$3f,$00
 db $fe,$ff,$01,$c0,$ff,$07,$00,$ff,$1f,$00,$fc,$7f,$00,$00,$f0,$0f
 db $fe,$3f,$00,$f8,$ff,$00,$00,$00,$00,$fc,$ff,$03,$80,$ff,$0f,$80
 db $ff,$0f,$c0,$ff,$3f,$00,$f8,$ff,$00,$fc,$ff,$03,$80,$ff,$0f,$00
 db $fe,$3f,$00,$f0,$ff,$01,$00,$00,$00,$e0,$ff,$03,$e0,$ff,$0f,$00
motbdrum5
 db $c7,$3f,$c7,$07,$c7,$00,$f8,$00,$f8,$e0,$e0,$e0,$03,$ff,$1f,$1f
 db $00,$7c,$7c,$1c,$00,$00,$00,$00,$70,$fe,$ff,$7f,$00,$70,$3e,$00
 db $00,$fe,$ff,$c7,$07,$38,$00,$f8,$ff,$ff,$ff,$07,$3f,$1f,$00,$00
 db $e0,$ff,$e3,$1f,$00,$00,$fc,$ff,$ff,$83,$9f,$1f,$00,$00,$fc,$ff
 db $03,$00,$00,$00,$fe,$ff,$0f,$f0,$3f,$00,$00,$fe,$ff,$3f,$00,$00
 db $00,$f8,$ff,$00,$1f,$1f,$00,$e0,$ff,$ff,$00,$00,$00,$00,$9f,$03
 db $7c,$7c,$00,$80,$ff,$ff,$03,$00,$00,$70,$7e,$00,$8e,$0f,$00,$f0
 db $ff,$3f,$00,$c0,$c1,$c7,$07,$38,$38,$00,$c0,$ff,$e7,$e0,$00,$07
 db $f8,$1f,$fc,$1c,$00,$e0,$ff,$83,$83,$1f,$9c,$ff,$8f,$8f,$03,$00
 db $fe,$7f,$70,$8e,$81,$c1,$0f,$30,$3e,$00,$f8,$ff,$c7,$39,$06,$c7
 db $3f,$ff,$38,$00,$f8,$ff,$e0,$18,$1f,$ff,$1f,$1f,$03,$80,$ff,$1f
 db $9c,$ff,$63,$70,$7c,$0c,$00,$f0,$ff,$81,$71,$0e,$ce,$ff,$31,$00
 db $f0,$ff,$c1,$f9,$39,$06,$f8,$38,$00,$f8,$ff,$00,$f8,$1f,$07,$1f
 db $1f,$00,$fc,$1f,$e0,$9f,$83,$e3,$ff,$03,$f0,$ff,$03,$8c,$73,$70
 db $7e,$0e,$80,$ff,$01,$30,$3e,$ce,$f1,$3f,$00,$f8,$ff,$c1,$00,$38
 db $ff,$c7,$00,$f8,$ff,$00,$07,$00,$fc,$ff,$00,$e0,$7f,$9c,$1f,$00
 db $80,$ff,$03,$f0,$7f,$00,$0c,$00,$f0,$ff,$01,$c0,$ff,$0f,$3e,$00
 db $c0,$ff,$01,$c0,$3f,$00,$3f,$c0,$c0,$ff,$00,$e0,$1f,$1f,$1f,$00
 db $e0,$ff,$00,$fc,$1f,$9c,$1f,$60,$e0,$73,$00,$fc,$0f,$80,$0f,$70
 db $f0,$71,$00,$fe,$0f,$ce,$0f,$3e,$fe,$39,$00,$fe,$07,$c0,$00,$38
 db $ff,$1f,$00,$ff,$07,$e0,$00,$1f,$ff,$1c,$00,$ff,$83,$ff,$83,$83
 db $7f,$0c,$80,$ff,$83,$f3,$81,$81,$ff,$0f,$c0,$ff,$01,$ce,$c1,$01
 db $3e,$06,$c0,$ff,$01,$c7,$c0,$00,$3f,$07,$e0,$ff,$e0,$ff,$03,$03
 db $ff,$1f,$e0,$ff,$03,$80,$83,$9f,$7f,$0c,$80,$ff,$73,$8e,$81,$0f
motbdrum6
 db $00,$00,$ff,$3f,$f8,$07,$e7,$e7,$f8,$00,$1c,$1c,$1c,$e3,$03,$83
 db $63,$9c,$83,$1f,$0c,$80,$83,$03,$0c,$fe,$8f,$0f,$8e,$81,$c1,$31
 db $00,$30,$00,$06,$3e,$c6,$c7,$07,$00,$c0,$c7,$c7,$3f,$18,$00,$00
 db $07,$e0,$e0,$03,$1f,$fc,$e0,$03,$1c,$60,$00,$1c,$8c,$73,$00,$00
 db $00,$8e,$ff,$71,$fe,$01,$00,$00,$00,$30,$30,$fe,$3f,$3e,$00,$00
 db $00,$00,$07,$38,$00,$00,$00,$18,$ff,$ff,$1f,$1f,$fc,$00,$00,$00
 db $7c,$fc,$63,$f0,$0f,$00,$00,$00,$00,$00,$f0,$ff,$ff,$3f,$00,$00
 db $00,$00,$c0,$07,$38,$c0,$01,$3e,$f8,$07,$07,$c0,$00,$00,$00,$00
 db $07,$00,$00,$00,$00,$00,$00,$00,$00,$e0,$ff,$ff,$ff,$ff,$7f,$00
 db $00,$00,$00,$f0,$ff,$ff,$3f,$00,$00,$00,$00,$00,$00,$00,$00,$c0
 db $ff,$ff,$ff,$ff,$1f,$00,$00,$00,$00,$ff,$ff,$ff,$1f,$00,$00,$00
 db $80,$e3,$ff,$ff,$03,$00,$00,$80,$ff,$ff,$ff,$ff,$3f,$00,$00,$00
 db $00,$fe,$ff,$ff,$3f,$00,$00,$00,$00,$ff,$ff,$ff,$07,$00,$00,$00
 db $ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$fc,$ff,$ff,$ff,$0f,$00,$00
 db $00,$80,$ff,$ff,$3f,$00,$00,$00,$f0,$ff,$ff,$ff,$ff,$07,$00,$00
 db $00,$c0,$ff,$ff,$ff,$ff,$07,$00,$00,$00,$fc,$ff,$ff,$03,$00,$00
 db $00,$fc,$ff,$ff,$ff,$ff,$03,$00,$00,$00,$f0,$ff,$ff,$ff,$ff,$01
 db $00,$00,$00,$f8,$ff,$ff,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$00
 db $00,$00,$00,$e0,$ff,$ff,$ff,$ff,$03,$00,$00,$00,$f0,$ff,$ff,$01
 db $00,$00,$00,$fe,$ff,$ff,$ff,$ff,$01,$00,$00,$00,$c0,$ff,$ff,$ff
 db $ff,$07,$00,$00,$00,$e0,$ff,$ff,$00,$00,$00,$80,$ff,$ff,$ff,$ff
 db $7f,$00,$00,$00,$00,$80,$ff,$ff,$ff,$ff,$0f,$00,$00,$00,$c0,$ff
 db $ff,$07,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$e0,$ff
 db $ff,$ff,$ff,$03,$00,$00,$00,$80,$ff,$ff,$0f,$00,$00,$00,$fe,$ff
motbdrum7
 db $07,$f8,$00,$3f,$ff,$e0,$18,$07,$18,$f8,$00,$00,$ff,$e0,$ff,$7f
 db $00,$00,$80,$03,$00,$fc,$0f,$80,$03,$f0,$ff,$7f,$00,$00,$c0,$ff
 db $ff,$c1,$cf,$01,$f8,$ff,$ff,$ff,$3f,$00,$00,$c0,$ff,$00,$ff,$00
 db $e0,$ff,$1f,$ff,$ff,$00,$00,$fc,$ff,$83,$7f,$00,$80,$ff,$ff,$ff
 db $0f,$00,$70,$fe,$0f,$f0,$3f,$00,$c0,$ff,$ff,$ff,$07,$00,$c6,$ff
 db $00,$ff,$00,$00,$ff,$ff,$ff,$1f,$00,$00,$fc,$03,$ff,$03,$00,$fc
 db $ff,$ff,$7f,$00,$00,$fc,$8f,$ff,$03,$00,$f0,$ff,$ff,$0f,$00,$00
 db $fe,$ff,$3f,$00,$00,$f8,$ff,$ff,$07,$00,$00,$f8,$1f,$00,$00,$e0
 db $ff,$ff,$ff,$00,$00,$ff,$03,$7c,$00,$e0,$ff,$ff,$0f,$80,$ff,$03
 db $70,$00,$fe,$ff,$0f,$00,$c0,$ff,$01,$30,$00,$fe,$ff,$07,$00,$c0
 db $3f,$00,$3f,$00,$ff,$ff,$e7,$07,$f8,$03,$e0,$03,$fc,$ff,$1f,$1c
 db $80,$7f,$80,$7f,$80,$ff,$ff,$03,$00,$fe,$01,$fe,$01,$fe,$ff,$3f
 db $00,$f0,$07,$c0,$07,$c0,$ff,$ff,$07,$c0,$3f,$e0,$1f,$00,$ff,$ff
 db $ff,$00,$ff,$00,$1f,$80,$ff,$ff,$7f,$80,$7f,$80,$7f,$80,$ff,$ff
 db $0f,$80,$7f,$80,$0f,$c0,$ff,$ff,$0f,$f8,$3f,$c0,$07,$f8,$3f,$ff
 db $07,$f8,$07,$f8,$07,$f8,$1f,$ff,$03,$fc,$00,$fc,$80,$ff,$e3,$7f
 db $80,$7f,$f0,$0f,$80,$7f,$fc,$0f,$f0,$0f,$f0,$01,$f0,$cf,$ff,$01
 db $fe,$c1,$3f,$c0,$3f,$f8,$3f,$c0,$07,$f8,$07,$f8,$07,$ff,$00,$ff
 db $00,$ff,$00,$1f,$e0,$1f,$e0,$1f,$fc,$03,$fc,$83,$7f,$80,$7f,$80
 db $0f,$f0,$0f,$f0,$01,$f0,$01,$fe,$01,$3e,$c0,$3f,$c0,$07,$f8,$07
 db $f8,$00,$ff,$00,$1f,$e0,$1f,$fc,$03,$fc,$00,$7c,$80,$7f,$e0,$1f
 db $f0,$03,$fc,$03,$7c,$80,$7f,$f0,$0f,$f0,$01,$fe,$01,$3e,$f0,$07
 db $f8,$07,$f8,$01,$3e,$c0,$07,$f8,$07,$f8,$00,$1f,$e0,$07,$fc,$1f
 db $fc,$03,$7f,$e0,$03,$7c,$1c,$e0,$03,$7c,$f0,$0f,$7c,$7e,$f0,$0f
 db $7e,$f0,$0f,$3e,$30,$c0,$0f,$3e,$c0,$07,$3e,$f8,$c0,$07,$ff,$c0
 db $07,$18,$f8,$e0,$1f,$fc,$e0,$03,$fc,$e0,$80,$1f,$7c,$e0,$1f,$7c
 db $f0,$83,$0f,$7c,$80,$0f,$7e,$f0,$81,$3f,$3e,$c0,$0f,$f0,$c1,$c1
 db $3f,$f8,$c1,$3f,$f8,$c0,$07,$3f,$f8,$00,$1f,$e0,$e0,$03,$1f,$fc
motbinsList
 db 0,64,1,172,240,0,0,0
 db 0,8,0,172,240,1,0,0
 db 0,8,0,172,48,1,0,0
 db 0,64,1,172,240,0,139,139
 db 0,255,4,172,240,0,0,0
 db 0,255,4,172,240,0,0,0
motbsequence
 db $f5,4
 db $f5,11
 db 128,4,129,16
 db 0,0
 db 0,1
 db 4,16
 db 0,0
 db 0,1
 db 4,16
 db 0,0
 db 0,1
 db 4,16
 db 0,0
 db 0,1
 db 5,17
 db 0,1
 db 5,17
 db 0,1
 db 4,130,16
 db 0,0
 db 0,0
 db 4,16
 db 0,0
 db 0,0
 db 4,16
 db 0,0
 db 0,0
 db 4,16
 db 0,0
 db 0,0
 db 133,14,16
 db 0,0
 db 0,0
 db 0,0
 db 128,4,128,1
 db 0,0
 db 1,0
 db 4,0
 db 0,0
 db 1,0
 db 4,0
 db 0,0
 db 1,0
 db 4,0
 db 0,0
 db 1,0
 db 5,0
 db 1,0
 db 5,0
 db 1,0
 db 4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 0,0
 db 1,1
 db 4,16
 db 0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 250,133,14,17
 db 0,1
 db 250,0,17
 db 0,1
 db 246,128,4,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 1,1
 db 247,5,17
 db 1,1
 db 5,17
 db 1,1
 db 246,4,130,16
 db 0,0
 db 0,0
 db 4,16
 db 247,0,0
 db 0,0
 db 4,16
 db 0,0
 db 246,0,0
 db 4,16
 db 0,0
 db 0,0
 db 247,133,14,16
 db 0,0
 db 0,0
 db 0,0
 db 246,128,4,128,1
 db 0,0
 db 1,0
 db 4,0
 db 247,0,0
 db 1,0
 db 4,0
 db 0,0
 db 246,1,0
 db 4,0
 db 0,0
 db 1,0
 db 247,5,0
 db 1,0
 db 5,0
 db 1,0
 db 246,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 247,4,128,28
 db 1,29
 db 247,4,33
 db 1,35
 db 246,5,133,36
 db 0,0
 db 0,0
 db 17,0
 db 247,0,0
 db 0,0
 db 5,0
 db 0,0
 db 246,0,0
 db 17,0
 db 0,0
 db 0,0
 db 247,17,0
 db 0,0
 db 17,35
 db 0,0
 db 246,5,128,33
 db 0,1
 db 0,0
 db 5,0
 db 247,0,0
 db 0,0
 db 5,0
 db 0,0
 db 246,0,0
 db 5,0
 db 0,0
 db 0,0
 db 247,133,14,33
 db 0,35
 db 0,33
 db 0,32
 db 246,128,4,0
 db 0,0
 db 130,4,0
 db 128,4,0
 db 247,0,0
 db 130,4,0
 db 128,4,0
 db 0,0
 db 246,130,4,0
 db 128,4,0
 db 0,0
 db 130,4,0
 db 247,128,5,0
 db 1,0
 db 5,29
 db 1,0
 db 246,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 133,14,128,28
 db 0,29
 db 247,0,33
 db 247,0,35
 db 246,128,5,133,36
 db 0,0
 db 0,0
 db 0,0
 db 247,0,0
 db 0,0
 db 0,0
 db 0,0
 db 246,0,0
 db 0,0
 db 0,0
 db 0,0
 db 247,5,0
 db 1,0
 db 5,35
 db 1,0
 db 246,5,128,33
 db 0,1
 db 0,0
 db 5,0
 db 247,0,0
 db 0,0
 db 5,0
 db 0,0
 db 246,0,0
 db 5,0
 db 0,0
 db 0,0
 db 247,133,14,33
 db 0,35
 db 0,33
 db 0,32
 db 246,128,4,0
 db 0,0
 db 130,4,0
 db 128,4,0
 db 247,0,0
 db 130,4,0
 db 128,4,0
 db 0,0
 db 246,130,4,0
 db 128,4,0
 db 0,0
 db 130,4,0
 db 247,128,5,131,32
 db 1,0
 db 5,0
 db 1,0
 db 246,4,0
 db 0,0
 db 1,0
 db 4,0
 db 247,0,0
 db 1,0
 db 4,0
 db 0,0
 db 246,1,0
 db 4,0
 db 0,0
 db 246,1,0
 db 250,133,14,0
 db 246,0,0
 db 250,0,0
 db 246,0,0
 db 246,128,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 1,1
 db 247,5,17
 db 1,1
 db 5,17
 db 1,1
 db 246,4,130,16
 db 0,0
 db 0,0
 db 4,16
 db 247,0,0
 db 0,0
 db 4,16
 db 0,0
 db 246,0,0
 db 4,16
 db 0,0
 db 0,0
 db 247,133,14,16
 db 0,0
 db 0,0
 db 0,0
 db 246,128,4,128,1
 db 0,0
 db 1,0
 db 4,0
 db 247,0,0
 db 1,0
 db 4,0
 db 0,0
 db 246,1,0
 db 4,0
 db 0,0
 db 1,0
 db 247,5,0
 db 1,0
 db 5,0
 db 1,0
 db 246,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 1,1
 db 247,4,128,28
 db 1,0
 db 247,4,131,33
 db 247,1,0
 db 246,7,128,35
 db 0,0
 db 7,0
 db 0,0
 db 247,7,0
 db 0,0
 db 7,0
 db 0,0
 db 246,7,0
 db 0,0
 db 7,0
 db 0,0
 db 247,7,0
 db 0,0
 db 7,0
 db 0,0
 db 246,133,36,17
 db 0,0
 db 0,17
 db 0,0
 db 247,0,17
 db 0,0
 db 0,5
 db 0,0
 db 246,0,5
 db 0,0
 db 0,5
 db 0,0
 db 247,131,36,5
 db 0,0
 db 0,5
 db 0,0
 db 246,133,38,5
 db 0,0
 db 0,5
 db 0,0
 db 247,0,5
 db 0,0
 db 0,5
 db 0,0
 db 246,36,17
 db 0,0
 db 0,5
 db 0,0
 db 247,0,17
 db 0,0
 db 0,5
 db 0,0
 db 246,128,35,4
 db 0,0
 db 0,0
 db 0,0
 db 247,0,0
 db 0,0
 db 0,0
 db 0,0
 db 246,0,0
 db 0,0
 db 0,0
 db 246,0,0
 db 247,0,0
 db 247,0,0
 db 247,0,0
 db 247,0,0
 db 246,7,35
 db 0,0
 db 7,0
 db 0,0
 db 247,7,0
 db 0,0
 db 7,0
 db 0,0
 db 246,7,0
 db 0,0
 db 7,0
 db 0,0
 db 247,7,0
 db 0,0
 db 7,0
 db 0,0
 db 246,133,36,17
 db 0,0
 db 0,17
 db 0,0
 db 247,0,17
 db 0,0
 db 0,5
 db 0,0
 db 246,0,17
 db 0,0
 db 0,5
 db 0,0
 db 247,131,36,17
 db 0,0
 db 0,5
 db 0,0
 db 246,133,38,17
 db 0,0
 db 0,0
 db 0,0
 db 247,0,17
 db 0,0
 db 0,5
 db 0,0
 db 246,41,17
 db 0,0
 db 0,17
 db 0,0
 db 247,0,17
 db 0,0
 db 0,17
 db 0,0
 db 246,40,16
 db 0,0
 db 0,0
 db 0,0
 db 247,0,0
 db 0,0
 db 0,0
 db 246,0,0
 db 246,0,16
 db 0,0
 db 0,16
 db 246,131,40,0
 db 247,0,16
 db 247,0,0
 db 247,0,16
 db 247,0,0
 db 246,128,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 1,1
 db 247,5,17
 db 1,1
 db 5,17
 db 1,1
 db 246,4,130,16
 db 0,0
 db 0,0
 db 4,16
 db 247,0,0
 db 0,0
 db 4,16
 db 0,0
 db 246,0,0
 db 4,16
 db 0,0
 db 0,0
 db 247,133,14,16
 db 0,0
 db 0,0
 db 0,0
 db 246,128,4,128,1
 db 0,0
 db 1,0
 db 4,0
 db 247,0,0
 db 1,0
 db 4,0
 db 0,0
 db 246,1,0
 db 4,0
 db 0,0
 db 1,0
 db 247,5,0
 db 1,0
 db 5,0
 db 1,0
 db 246,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 247,4,16
 db 1,130,16
 db 247,4,129,16
 db 1,130,16
 db $f5,6
 db 246,4,133,40
 db 0,41
 db 0,45
 db 0,47
 db 0,48
 db 130,4,47
 db 128,4,45
 db 0,41
 db 247,0,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db 246,0,40
 db 130,4,41
 db 128,4,45
 db 0,47
 db 0,48
 db 0,47
 db 0,45
 db 130,4,41
 db 247,128,4,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db $f5,12
 db 246,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 1,1
 db 247,5,17
 db 1,1
 db 247,5,17
 db 247,1,1
 db $f5,6
 db 246,4,133,40
 db 0,41
 db 0,45
 db 0,47
 db 0,48
 db 130,4,47
 db 128,4,45
 db 0,41
 db 247,0,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db 246,0,40
 db 130,4,41
 db 128,4,44
 db 0,45
 db 0,47
 db 0,45
 db 0,44
 db 130,4,41
 db 247,128,4,40
 db 0,41
 db 0,44
 db 130,4,45
 db 128,4,47
 db 0,45
 db 0,44
 db 0,41
 db $f5,12
 db 246,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 247,4,16
 db 1,130,16
 db 247,4,129,16
 db 1,130,16
 db $f5,6
 db 246,4,133,40
 db 0,41
 db 0,45
 db 0,47
 db 0,48
 db 130,4,47
 db 128,4,45
 db 0,41
 db 247,0,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db 246,0,40
 db 130,4,41
 db 128,4,45
 db 0,47
 db 0,48
 db 0,47
 db 0,45
 db 130,4,41
 db 247,128,4,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db $f5,12
 db 246,4,129,16
 db 0,0
 db 248,1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 248,4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 248,0,0
 db 1,1
 db 247,5,17
 db 1,1
 db 248,5,17
 db 1,1
 db $f5,6
 db 246,4,133,40
 db 129,16,41
 db 133,4,45
 db 129,16,47
 db 248,128,16,48
 db 129,16,47
 db 128,4,45
 db 129,16,41
 db 247,133,4,40
 db 129,16,41
 db 128,16,45
 db 129,16,47
 db 248,128,4,48
 db 129,16,47
 db 133,4,45
 db 129,16,41
 db 246,128,16,132,40
 db 129,16,41
 db 128,4,44
 db 129,16,45
 db 248,133,4,47
 db 129,16,45
 db 128,16,44
 db 129,16,41
 db 247,128,4,40
 db 129,16,41
 db 133,4,44
 db 129,16,45
 db 248,128,4,47
 db 129,16,45
 db 248,133,4,44
 db 129,16,41
 db $f5,12
 db 246,128,4,129,16
 db 129,16,0
 db 130,16,1
 db 128,4,16
 db 247,129,16,0
 db 130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 128,4,16
 db 129,16,0
 db 130,16,1
 db 247,128,5,17
 db 129,17,1
 db 128,5,17
 db 129,17,1
 db 246,128,4,130,16
 db 129,16,0
 db 130,16,0
 db 128,4,16
 db 247,129,16,0
 db 130,16,0
 db 128,4,16
 db 129,16,0
 db 246,130,16,0
 db 128,4,16
 db 129,16,0
 db 130,16,0
 db 247,133,14,16
 db 0,0
 db 0,0
 db 0,0
 db 246,128,4,16
 db 129,16,0
 db 130,16,0
 db 128,4,16
 db 247,129,16,0
 db 130,16,0
 db 128,4,16
 db 129,16,0
 db 246,130,16,0
 db 128,4,16
 db 129,16,0
 db 130,16,0
 db 247,128,5,129,17
 db 129,17,1
 db 247,128,5,17
 db 129,17,1
 db 246,128,4,16
 db 129,16,0
 db 130,16,1
 db 128,4,16
 db 247,129,16,0
 db 130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 247,128,4,128,28
 db 247,1,29
 db 247,4,33
 db 247,1,35
 db 246,5,133,36
 db 0,0
 db 0,0
 db 17,0
 db 247,0,0
 db 0,0
 db 5,0
 db 0,0
 db 246,0,0
 db 17,0
 db 0,0
 db 0,0
 db 247,17,0
 db 0,0
 db 17,35
 db 0,0
 db 246,5,128,33
 db 0,1
 db 0,0
 db 5,0
 db 247,0,0
 db 0,0
 db 5,0
 db 0,0
 db 246,0,0
 db 5,0
 db 0,0
 db 0,0
 db 247,133,14,33
 db 0,35
 db 0,33
 db 0,32
 db 246,128,4,0
 db 0,0
 db 130,4,0
 db 128,4,0
 db 247,0,0
 db 130,4,0
 db 128,4,0
 db 0,0
 db 246,130,4,0
 db 128,4,0
 db 0,0
 db 130,4,0
 db 247,128,5,0
 db 1,0
 db 5,29
 db 1,0
 db 246,4,129,16
 db 129,16,0
 db 130,16,1
 db 128,4,16
 db 247,129,16,0
 db 130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 133,14,128,28
 db 0,29
 db 247,0,33
 db 247,0,35
 db 246,128,5,133,36
 db 0,0
 db 0,0
 db 0,0
 db 247,0,0
 db 0,0
 db 0,0
 db 0,0
 db 246,0,0
 db 0,0
 db 0,0
 db 0,0
 db 247,5,0
 db 1,0
 db 5,35
 db 1,0
 db 246,5,128,33
 db 0,1
 db 0,0
 db 5,0
 db 247,0,0
 db 0,0
 db 5,0
 db 0,0
 db 246,0,0
 db 5,0
 db 0,0
 db 0,0
 db 247,133,14,33
 db 0,35
 db 0,33
 db 0,32
 db 246,128,4,0
 db 0,0
 db 130,4,0
 db 128,4,0
 db 247,0,0
 db 130,4,0
 db 128,4,0
 db 0,0
 db 246,130,4,0
 db 128,4,0
 db 0,0
 db 130,4,0
 db 247,128,5,131,32
 db 1,0
 db 5,0
 db 1,0
 db 246,4,0
 db 0,0
 db 1,0
 db 4,0
 db 247,0,0
 db 1,0
 db 4,0
 db 0,0
 db 246,1,0
 db 4,0
 db 0,0
 db 246,1,0
 db 250,133,14,0
 db 246,0,0
 db 250,0,0
 db 246,0,0
 db 246,128,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 1,1
 db 247,5,17
 db 1,1
 db 5,17
 db 1,1
 db 246,4,130,16
 db 0,0
 db 0,0
 db 4,16
 db 247,0,0
 db 0,0
 db 4,16
 db 0,0
 db 246,0,0
 db 4,16
 db 0,0
 db 0,0
 db 247,133,14,16
 db 0,0
 db 0,0
 db 0,0
 db 246,128,4,16
 db 129,16,0
 db 130,16,0
 db 128,4,16
 db 247,129,16,0
 db 130,16,0
 db 128,4,16
 db 129,16,0
 db 246,130,16,0
 db 128,4,16
 db 129,16,0
 db 130,16,0
 db 247,128,5,16
 db 129,17,0
 db 128,5,0
 db 129,17,0
 db 246,128,4,129,16
 db 129,16,0
 db 130,16,1
 db 128,4,16
 db 247,129,16,0
 db 130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 128,4,16
 db 129,16,0
 db 130,16,1
 db 247,128,4,128,28
 db 129,1,0
 db 247,128,4,131,33
 db 247,129,1,0
 db 246,128,7,128,35
 db 0,0
 db 7,0
 db 0,0
 db 247,7,0
 db 0,0
 db 7,0
 db 0,0
 db 246,7,0
 db 0,0
 db 7,0
 db 0,0
 db 247,7,0
 db 0,0
 db 7,0
 db 0,0
 db 246,133,36,17
 db 0,0
 db 0,17
 db 0,0
 db 247,0,17
 db 0,0
 db 0,5
 db 0,0
 db 246,0,5
 db 0,0
 db 0,5
 db 0,0
 db 247,131,36,5
 db 0,0
 db 0,5
 db 0,0
 db 246,133,38,5
 db 0,0
 db 0,5
 db 0,0
 db 247,0,5
 db 0,0
 db 0,5
 db 0,0
 db 246,36,17
 db 0,0
 db 0,5
 db 0,0
 db 247,0,17
 db 0,0
 db 0,5
 db 0,0
 db 246,128,35,4
 db 0,0
 db 0,0
 db 0,0
 db 247,0,0
 db 0,0
 db 0,0
 db 0,0
 db 246,0,0
 db 0,0
 db 0,0
 db 246,0,0
 db 247,0,0
 db 247,0,0
 db 247,0,0
 db 247,0,0
 db 246,7,35
 db 0,0
 db 7,0
 db 0,0
 db 247,7,0
 db 0,0
 db 7,0
 db 0,0
 db 246,7,0
 db 0,0
 db 7,0
 db 0,0
 db 247,7,0
 db 0,0
 db 7,0
 db 0,0
 db 246,133,36,17
 db 0,0
 db 0,17
 db 0,0
 db 247,0,17
 db 0,0
 db 0,5
 db 0,0
 db 246,0,17
 db 0,0
 db 0,5
 db 0,0
 db 247,131,36,17
 db 0,0
 db 0,5
 db 0,0
 db 246,133,38,17
 db 0,0
 db 0,0
 db 0,0
 db 247,0,17
 db 0,0
 db 0,5
 db 0,0
 db 246,41,17
 db 0,0
 db 0,17
 db 0,0
 db 247,0,17
 db 0,0
 db 0,17
 db 0,0
 db 246,40,16
 db 0,0
 db 0,0
 db 0,0
 db 247,0,0
 db 0,0
 db 0,0
 db 246,0,0
 db 246,0,16
 db 0,0
 db 0,16
 db 246,131,40,0
 db 247,0,16
 db 247,0,0
 db 247,0,16
 db 247,0,0
 db 246,128,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 1,1
 db 247,5,17
 db 1,1
 db 5,17
 db 1,1
 db 246,4,130,16
 db 0,0
 db 0,0
 db 4,16
 db 247,0,0
 db 0,0
 db 4,16
 db 0,0
 db 246,0,0
 db 4,16
 db 0,0
 db 0,0
 db 247,133,14,16
 db 0,0
 db 0,0
 db 0,0
 db 246,128,4,128,1
 db 0,0
 db 1,0
 db 4,0
 db 247,0,0
 db 1,0
 db 4,0
 db 0,0
 db 246,1,0
 db 4,0
 db 0,0
 db 1,0
 db 247,5,0
 db 1,0
 db 5,0
 db 1,0
 db 246,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 247,4,16
 db 1,130,16
 db 247,4,129,16
 db 1,130,16
 db $f5,6
 db 246,4,133,40
 db 0,41
 db 0,45
 db 0,47
 db 0,48
 db 130,4,47
 db 128,4,45
 db 0,41
 db 247,0,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db 246,0,40
 db 130,4,41
 db 128,4,45
 db 0,47
 db 0,48
 db 0,47
 db 0,45
 db 130,4,41
 db 247,128,4,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db $f5,12
 db 246,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 1,1
 db 247,5,17
 db 1,1
 db 247,5,17
 db 247,1,1
 db $f5,6
 db 246,4,133,40
 db 0,41
 db 0,45
 db 0,47
 db 0,48
 db 130,4,47
 db 128,4,45
 db 0,41
 db 247,0,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db 246,0,40
 db 130,4,41
 db 128,4,44
 db 0,45
 db 0,47
 db 0,45
 db 0,44
 db 130,4,41
 db 247,128,4,40
 db 0,41
 db 0,44
 db 130,4,45
 db 128,4,47
 db 0,45
 db 0,44
 db 0,41
 db $f5,12
 db 246,4,129,16
 db 0,0
 db 1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 0,0
 db 246,1,1
 db 247,4,16
 db 247,1,130,16
 db 247,4,129,16
 db 247,1,130,16
 db $f5,6
 db 246,4,133,40
 db 0,41
 db 0,45
 db 0,47
 db 0,48
 db 130,4,47
 db 128,4,45
 db 0,41
 db 247,0,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db 246,0,40
 db 130,4,41
 db 128,4,45
 db 0,47
 db 0,48
 db 0,47
 db 0,45
 db 130,4,41
 db 247,128,4,40
 db 0,41
 db 0,45
 db 130,4,47
 db 128,4,48
 db 0,47
 db 0,45
 db 0,41
 db $f5,12
 db 246,4,129,16
 db 0,0
 db 248,1,1
 db 4,16
 db 247,0,0
 db 1,1
 db 248,4,16
 db 0,0
 db 246,1,1
 db 4,16
 db 248,0,0
 db 1,1
 db 247,5,17
 db 1,1
 db 248,5,17
 db 1,1
 db $f5,6
 db 246,4,133,40
 db 129,16,41
 db 133,4,45
 db 129,16,47
 db 248,128,16,48
 db 129,16,47
 db 128,4,45
 db 129,16,41
 db 247,133,4,40
 db 129,16,41
 db 128,16,45
 db 129,16,47
 db 248,128,4,48
 db 129,16,47
 db 133,4,45
 db 129,16,41
 db 246,128,16,132,40
 db 129,16,41
 db 128,4,44
 db 129,16,45
 db 248,133,4,47
 db 129,16,45
 db 128,16,44
 db 129,16,41
 db 247,128,4,40
 db 129,16,41
 db 133,4,44
 db 129,16,45
 db 247,128,4,47
 db 129,16,45
 db 247,133,4,44
 db 129,16,41
 db $f5,12
 db 246,128,4,129,16
 db 129,16,0
 db 130,16,1
 db 128,4,16
 db 247,129,16,0
 db 130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 250,128,5,17
 db 129,17,1
 db 250,128,5,17
 db 129,17,1
 db 246,128,4,130,16
 db 129,16,0
 db 130,16,0
 db 128,4,16
 db 247,129,16,0
 db 130,16,0
 db 128,4,16
 db 129,16,0
 db 246,130,16,0
 db 128,4,16
 db 129,16,0
 db 130,16,0
 db 247,133,14,16
 db 0,0
 db 0,0
 db 0,0
 db 246,128,4,16
 db 129,16,0
 db 130,16,0
 db 128,4,16
 db 247,129,16,0
 db 130,16,0
 db 128,4,16
 db 129,16,0
 db 246,130,16,0
 db 128,4,16
 db 129,16,0
 db 130,16,0
 db 247,128,5,129,17
 db 129,17,1
 db 247,128,5,17
 db 129,17,1
 db 246,128,4,16
 db 129,16,0
 db 130,16,1
 db 128,4,16
 db 247,129,16,0
 db 130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 247,133,14,130,16
 db 0,0
 db 0,0
 db 0,0
 db 251,128,4,129,16
 db 129,16,0
 db 130,16,0
 db 128,4,16
 db 252,129,16,1
 db 130,16,0
 db 128,4,16
 db 129,16,0
 db 253,130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 250,128,5,17
 db 129,17,1
 db 250,128,5,17
 db 129,17,1
 db 246,128,4,130,16
 db 129,16,0
 db 130,16,0
 db 128,4,16
 db 247,129,16,0
 db 130,16,0
 db 128,4,16
 db 129,16,0
 db 246,130,16,0
 db 128,4,16
 db 129,16,0
 db 130,16,0
 db 247,133,14,16
 db 0,0
 db 0,0
 db 0,0
 db 246,128,4,16
 db 129,16,0
 db 130,16,0
 db 128,4,16
 db 247,129,16,0
 db 130,16,0
 db 128,4,16
 db 129,16,0
 db 246,130,16,0
 db 128,4,16
 db 129,16,0
 db 130,16,0
 db 247,128,5,129,17
 db 129,17,1
 db 247,128,5,17
 db 129,17,1
 db 246,128,4,16
 db 129,16,0
 db 130,16,1
 db 128,4,16
 db 247,129,16,0
 db 130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 128,4,16
 db 129,16,0
 db 246,130,16,1
 db 247,133,14,131,28
 db 247,0,0
 db 247,0,0
 db 247,0,0
 db 249,1,1
 db 1,1
 db 1,1
 db $fe
 db 1,1
 db $ff




end





