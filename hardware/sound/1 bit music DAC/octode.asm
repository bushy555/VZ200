
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





;
;Device output:
; 	0=speaker.  
; 	1=Cassette Port.  
; 	2=Printer Port.
;
; VZ INTERNAL/EXTERNAL SPEAKER
; ============================
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
;          _____________   <--piezo speaker.
;          -------------
;
;
;
;
;
;
;
; Experimental Cassette port option.
; ==================================
; Plug in a stereo 3.5mm socket connected to amplified speakers. Select this option
; and music will be output to the cassette port through to your doof-doof speakers.
;                       
;  VZ cassette   
;  port socket             _____________
;               ,--,--,---|3.5mm stereo |
;               '--'--'---|_______plug__|
;                 |  |  |
;                 |  |   \____common         ----> to amp common.
;                 |   \_______right channel  ----> to amp right.      
;                  \__________left channel   ----> to amp left.
;
;
;
;
;
;
;
; Experimental Printer Port option.
; =================================
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
	output "octode.vz"


; octode		:   446 bytes.   $1BE.			$8000 - (8000-7b00)
; song_nightdancer:	: 11782 bytes.	$2E10.	2045. $7FD.  	$9000 - (8000-7b00)
; song_interstellar:	:  7613 bytes.	$1DC0.	1597. $63D	$9700 - (8000-7b00)
; song_psion:		: 15257 bytes.	$3C00.	2411. $96B	$A100 - (8000-7b00)
; song_spring:		: 15867 bytes.	$3E00.	2754. $AC2	$AC00 - (8000-7b00)
; song_decompressed	:					$a800 - (8000-7b00)


;==================================================================
;
;   Octode M2 by shiru & introspec
;
;==================================================================


origin equ  $7B00		
				
	org		origin - 24
	defb		'VZF1'					; file type ID
	defb		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,   0	; zero padded file name
	defb		$f1					; Binary or BASIC?
	defw		START					; start address
	org		origin
START:
begin:		
	call	$01c9			; ROM CLS()

	ld	hl, MENU1
	call	$28a7	
	ld	hl, MENU2
	call	$28a7	
	ld	hl, MENU3
	call	$28a7	
	ld	hl, MENU4
	call	$28a7	
	ld	hl, MENU5
	ld	de, 28672 + 32*15+26
	ld	bc, 6
	ldir
	di


;; -------------------------------
;; SPEAKER OR CASSETTE SELECTION
;; -------------------------------
	ld	a, (device)		; MENU for INVERSE SPEAKER or CASSETTE
	cp	1
	jr	z, menucas		; CASSETT PORT
	cp	2
	jr	z, menuprn		; PRINTER POR
	ld	hl, SPEAKINV		; SPEAKER
	ld	de, 28757+64
	ld	bc, 7
	jr	menucon
menucas:ld	hl, CASSEINV
	ld	de, 28757+96
	ld	bc, 9
	jr	menucon
menuprn:ld	hl, PRINTINV
	ld	de, 28757+128
	ld	bc, 11
menucon:ldir




;device_speaker:
;;	ld	a, 0			; 0=speaker
;;	ld	(device), a		; set speaker, cass_port, DAC on PRN port.
;	ld	hl, SPEAKINV		; SPEAKER
;;	ld	de, 28757+64
;	ld	bc, 7
;	ldir
;  	jr	scan
;device_cass:
;;	ld	a, 1			; 1=cassette port
;;	ld	(device), a		; set speaker, cass_port, DAC on PRN port.
;	ld	hl, CASSEINV
;	ld	de, 28757+96
;	ld	bc, 9
;	ldir
;	jr	scan
;device_prn:
;;	ld	a, 2			; 2=printer port
;;;	ld	(device), a		; set speaker, cass_port, DAC on PRN port.
;	ld	hl, PRINTINV
;	ld	de, 28757+128
;	ld	bc, 11
;	ldir
;
;
	di
scan:	call 	$2ef4		; VZ scan keyboard
	di
	or 	a		; any key pressed?
	jr	z, scan		; back if not
	cp	"1"		; "1 - "   	SELECT The Night Dancer
	jp	z, mbdance
	cp	"2"		; "2 - "   	SELECT Interstellar
	jp	z, mbinter
	cp	"3"		; "3 - "   	SELECT PSION
	jp	z, mbpsion
	cp	"4"		; "4 - "   	SELECT Spring is coming
	jp	z, mbspring
	cp	"X"
	jp	z, menua
	cp	"Y"
	jp	z, menub
	cp	"Z"
	jp	z, menuc	;	jr	z, device_prn
	cp	"Q"
	jr	z, quit
	jr	scan


quit: 	ei
	call	$01c9			; ROM CLS()
	jp 	$1a19			; Jump to VZ basic


menua:	ld	a, 0
	ld	(device), a




;%%%%%%%%%%%%%%%%%%%%%%%
;			 Self modify program for output device.
;							e6,21		and 33
;							ee,20		xor 32
;							32,00,68	ld ($6800), a
;
;							00,00		nop/nop
;							e6,04		and 4
;							32,00,068	ld ($6800), a
;
;							e6,21		and 33
;							ee,20		xor 32
;							d3,0e		out(14), a


;------------------------------
;device1a	and 32	/    and 6  /     and 32
;device2a	and 32	/    and 6  /     and 32
;device3a	xor 32	/    xor 4  /     xor 32
;device4a	ld $6800,a / ld $6800,a / out 14,a
;device5a	and 32	/    and 6  /     and 32
;device6a	ld $6800,a / ld $6800,a / out 14,a
;device7a	xor 32	/    xor 4  /     xor 32
;device8a	ld $6800,a / ld $6800,a / out 14,a
;device9a	and32-ld $6800,a / and6-ld $6800,a / and6-out 14,a
;device10a	ld $6800,a / ld $6800,a / out 14,a
;------------------------------

	ld	a, $e6
	ld	(device1a), a			; SPEAKER 1. AND 33.
	ld	a, $21
	ld	(device1b), a

	ld	a, $e6
	ld	(device2a), a			; SPEAKER 1. AND 33.
	ld	a, $21
	ld	(device2b), a

	ld	a, $ee
	ld	(device3a), a			; SPEAKER 1. XOR 32.
	ld	a, $20
	ld	(device3b), a

	ld	a, $32
	ld	(device4a), a			; SPEAKER 1. LD 6800,A.
	ld	a, $00
	ld	(device4b), a
	ld	a, $68
	ld	(device4c), a

	ld	a, $e6
	ld	(device5a), a			; SPEAKER 1. AND 33.
	ld	a, $21
	ld	(device5b), a

	ld	a, $32
	ld	(device6a), a			; SPEAKER 1. LD 6800,A.
	ld	a, $00
	ld	(device6b), a
	ld	a, $68
	ld	(device6c), a

	ld	a, $ee
	ld	(device7a), a			; SPEAKER 1. XOR 32.
	ld	a, $20
	ld	(device7b), a

	ld	a, $32
	ld	(device8a), a			; SPEAKER 1. LD 6800,A.
	ld	a, $00
	ld	(device8b), a
	ld	a, $68
	ld	(device8c), a

	ld	a, $e6
	ld	(device9a), a			; SPEAKER 1. LD 6800,A.
	ld	a, $21
	ld	(device9b), a
	ld	a, $32
	ld	(device9c), a			; SPEAKER 1. LD 6800,A.
	ld	a, $00
	ld	(device9d), a
	ld	a, $68
	ld	(device9e), a

	ld	a, $32
	ld	(device10a), a			; SPEAKER 1. LD 6800,A.
	ld	a, $00
	ld	(device10b), a
	ld	a, $68
	ld	(device10c), a

	jp	begin	




	


;------------------------------
;device1a	and 32	/    and 6  /     and 32
;device2a	and 32	/    and 6  /     and 32
;device3a	xor 32	/    xor 4  /     xor 32
;device4a	ld $6800,a / ld $6800,a / out 14,a
;device5a	and 32	/    and 6  /     and 32
;device6a	ld $6800,a / ld $6800,a / out 14,a
;device7a	xor 32	/    xor 4  /     xor 32
;device8a	ld $6800,a / ld $6800,a / out 14,a
;device9a	and32-ld $6800,a / and6-ld $6800,a / and6-out 14,a
;device10a	ld $6800,a / ld $6800,a / out 14,a
;------------------------------

menub:
	ld	a, 1
	ld	(device), a

	ld	a, $e6
	ld	(device1a), a			; CASS. AND 6.
	ld	a, $06
	ld	(device1b), a

	ld	a, $e6
	ld	(device2a), a			; CASS. AND 6.
	ld	a, $06
	ld	(device2b), a

	ld	a, $ee
	ld	(device3a), a			; CASS. XOR 32.
	ld	a, $04
	ld	(device3b), a

	ld	a, $32
	ld	(device4a), a			; CASS. LD 6800,A.
	ld	a, $00
	ld	(device4b), a
	ld	a, $68
	ld	(device4c), a

	ld	a, $e6
	ld	(device5a), a			; CASS. AND 6.
	ld	a, $06
	ld	(device5b), a

	ld	a, $32
	ld	(device6a), a			; CASS. LD 6800,A.
	ld	a, $00
	ld	(device6b), a
	ld	a, $68
	ld	(device6c), a

	ld	a, $ee
	ld	(device7a), a			; CASS. XOR 4.
	ld	a, $04
	ld	(device7b), a

	ld	a, $32
	ld	(device8a), a			; CASS. LD 6800,A.
	ld	a, $00
	ld	(device8b), a
	ld	a, $68
	ld	(device8c), a

	ld	a, $e6
	ld	(device9a), a			; CASS. AND 6.
	ld	a, $06
	ld	(device9b), a
	ld	a, $32
	ld	(device9c), a			; CASS. LD 6800,A.
	ld	a, $00
	ld	(device9d), a
	ld	a, $68
	ld	(device9e), a

	ld	a, $32
	ld	(device10a), a			; CASS. LD 6800,A.
	ld	a, $00
	ld	(device10b), a
	ld	a, $68
	ld	(device10c), a
	jp	begin


	
menuc:	ld	a, 2
	ld	(device), a

;------------------------------
;device1a	and 32	/    and 6  /     and 32
;device2a	and 32	/    and 6  /     and 32
;device3a	xor 32	/    xor 4  /     xor 32
;device4a	ld $6800,a / ld $6800,a / out 14,a
;device5a	and 32	/    and 6  /     and 32
;device6a	ld $6800,a / ld $6800,a / out 14,a
;device7a	xor 32	/    xor 4  /     xor 32
;device8a	ld $6800,a / ld $6800,a / out 14,a
;device9a	and32-ld $6800,a / and6-ld $6800,a / and6-out 14,a
;device10a	ld $6800,a / ld $6800,a / out 14,a
;------------------------------

	ld	a, $e6
	ld	(device1a), a			; PRN. AND 6.
	ld	a, $06
	ld	(device1b), a

	ld	a, $e6
	ld	(device2a), a			; PRN. AND 6.
	ld	a, $06
	ld	(device2b), a

	ld	a, $ee
	ld	(device3a), a			; PRN. XOR 4.
	ld	a, $04
	ld	(device3b), a

	ld	a, $00
	ld	(device4a), a			; PRN. OUT 14,A.
	ld	a, $d3
	ld	(device4b), a
	ld	a, $0e
	ld	(device4c), a

	ld	a, $e6
	ld	(device5a), a			; PRN. AND 6.
	ld	a, $06
	ld	(device5b), a

	ld	a, $00
	ld	(device6a), a			; PRN. OUT 14,A.
	ld	a, $d3
	ld	(device6b), a
	ld	a, $0e
	ld	(device6c), a

	ld	a, $ee
	ld	(device7a), a			; PRN. XOR 4.
	ld	a, $04
	ld	(device7b), a

	ld	a, $00
	ld	(device8a), a			; PRN. OUT 14,A.
	ld	a, $d3
	ld	(device8b), a
	ld	a, $0e
	ld	(device8c), a


	ld	a, $e6
	ld	(device9a), a			; PRN. AND 06.
	ld	a, $06
	ld	(device9b), a
	ld	a, $00
	ld	(device9c), a			; PRN. OUT 14,A.
	ld	a, $d3
	ld	(device9d), a
	ld	a, $0e
	ld	(device9e), a

	ld	a, $00
	ld	(device10a), a			; PRN. OUT 14,A.
	ld	a, $d3
	ld	(device10b), a
	ld	a, $0e
	ld	(device10c), a

	jp	begin





mbdance:ld	hl, song_nightdancer_compressed
	ld	de, SONG1INV
	jr	play0

mbinter:ld	hl, song_interstellar_compressed	
	ld	de, SONG2INV
	jr	play0

mbpsion:ld	hl, song_psion_compressed
	ld	de, SONG3INV
	jr	play0

mbspring:ld	hl, song_spring_compressed
	ld	de, SONG4INV
	jr	play0
	

play0:	
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

	ld	de, song_decompressed
	call	dzx0_standard
	call	play
	jp	scan





; Night Dancer
;===============
vol1234:	EQU 2
vol5678:	EQU 1
octodeDrums:	EQU 12500
slowDecay:	EQU 0
storeA:		EQU 0

;or
;vol1234	EQU 3			; volume of channels 1-4
;vol5678	EQU 3			; volume of channels 5-8
; the sum of these volumes should not exceed ~16 (or ~8, if slowDecay=1)
;slowDecay	EQU 0
;octodeDrums	EQU 12500
;storeA		EQU 0


play:	di
	ld 	h,$ff		; H'=$FF is used by the sound core
	exx
	push 	hl
	push 	iy
	ld 	ix,vol1234*256+vol5678	; channel volumes
	ld 	iy,song_decompressed
	jp 	readNotes_readOrder

stopPlayer:	
	pop 	iy
	pop 	hl
	exx
	ei
	ret

rowEnd:		
readNotes:
readNotes_ptr=$+1
	ld 	hl,0
	ld 	a,(hl)
	cp 	10
	jp 	nc,readNotes_p0n
	or 	a
	jp 	z,readNotes_p0y
	dec 	a
	jr 	nz,readNotes_drum

readNotes_readOrder
	ld 	l,(iy)
	ld 	h,(iy+1)
	ld 	a,h
	or 	l
	jr 	nz,readNotes_setPattern
	ld 	l,(iy+2)
	ld 	h,(iy+3)
	push 	hl
	pop 	iy
	jr 	readNotes_readOrder
readNotes_setPattern
	ld 	c,(hl)
	inc 	hl
	ld 	b,(hl)
	inc 	hl
	ld 	(readNotes_ptr),hl
	ld 	(readNotes_speed),bc
	inc 	iy
	inc 	iy
	jr 	readNotes

readNotes_drum	inc 	hl
	ld 	(readNotes_ptr),hl
	add 	a 
	add 	a
	add 	low (readNotes_drumTable-4) 
	ld 	l,a
	adc 	high (readNotes_drumTable-4) 
	sub 	l 
	ld 	h,a
	push 	de
	ld 	a,(hl) 
	ld 	(readNotes_drumPeriod),a 
	inc 	hl
	ld 	d,(hl) 
	inc 	hl
	ld 	e,(hl) 
	inc 	hl
	ld 	a,(hl) 

device1a	equ $ + 0
device1b	equ $ + 1
	and 	32
	ld 	c,a
	ld 	a,(hl) 
	add 	a 
device2a	equ $ + 0
device2b	equ $ + 1
	and 	32
	ld 	(readNotes_noiseOn),a
	ld 	hl,$C0DE
readNotes_drumSeed:	EQU $-2

readNotes_drumLoop:	dec e 
	jr 	nz,readNotes_keepNoise
	ld 	a,(readNotes_noiseOn) 
device3a	equ $ + 0
device3b	equ $ + 1
	xor 	32 

	ld 	(readNotes_noiseOn),a
readNotes_keepNoise:
	ld 	b,45
readNotes_drumPeriod:	EQU $-1

readNotes_noiseLoop:	ld a,c 

device4a	equ $ + 0
device4b	equ $ + 1
device4c	equ $ + 2
	ld	($6800),a 


	add 	hl,hl 
	sbc 	a
	and 	$BD			; instead of $BD, one can use $3F or $D7
	xor 	l 
	ld 	l,a
device5a	equ $ + 0
device5b	equ $ + 1
	and 	32 
	or 	0
readNotes_noiseOn:	EQU $-1

device6a	equ $ + 0
device6b	equ $ + 1
device6c	equ $ + 2
	ld	($6800),a


	djnz 	readNotes_noiseLoop
	ld 	a,c
device7a	equ $ + 0
device7b	equ $ + 1
	xor 	32
	ld 	c,a
	dec 	d 
	jr 	nz,readNotes_drumLoop		; (4+12 + 7 + (4+11 + 11+4+7+4+4 + 7+7+11+13)*B-5 + 4+7+4 + 4+12)*D = (83*B+49)*D
	ld 	(readNotes_drumSeed),hl	; 16
	xor 	a 
device8a	equ $ + 0
device8b	equ $ + 1
device8c	equ $ + 2
	ld	($6800),a


	pop 	de
	jp 	readNotes

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
	ld a,$84
readNotes_p0y	ld (soundLoop_off0),a
	ld c,$84		; $DD+$84 = ADD IXH
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
	inc c		; $DD+$85 = ADD IXL
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
soundLoop_lb0		dec c 
	 	jr nz,soundLoop_lc1
soundLoop_frq1=$+1
		ld c,0
soundLoop_off1=$+1
		add ixh			; 4+7+7+8=26t
soundLoop_lb1		dec d 
	 	jr nz,soundLoop_lc2
soundLoop_frq2=$+1
		ld d,0
soundLoop_off2=$+1
		add ixh			; 4+7+7+8=26t
soundLoop_lb2		dec e 
	 	jr nz,soundLoop_lc3
soundLoop_frq3=$+1
		ld e,0
soundLoop_off3=$+1
		add ixh			; 4+7+7+8=26t
soundLoop_lb3		exx			; 4t
		dec b 
	 	jr nz,soundLoop_lc4
soundLoop_frq4=$+1
		ld b,0
soundLoop_off4=$+1
		add ixl			; 4+7+7+8=26t
soundLoop_lb4		dec c 
	 	jr nz,soundLoop_lc5
soundLoop_frq5=$+1
		ld c,0
soundLoop_off5=$+1
		add ixl			; 4+7+7+8=26t
soundLoop_lb5		dec d 
	 	jr nz,soundLoop_lc6
soundLoop_frq6=$+1
		ld d,0
soundLoop_off6=$+1
		add ixl			; 4+7+7+8=26t
soundLoop_lb6		dec e 
		jr nz,soundLoop_lc7
soundLoop_frq7=$+1
		ld e,0
soundLoop_off7=$+1
		add ixl			; 4+7+7+8=26t
soundLoop_lb7		add h
		sbc h
		ld l,a
		sbc a
		nop

device9a	equ $ + 0
device9b	equ $ + 1
device9c	equ $ + 2
device9d	equ $ + 3
device9e	equ $ + 4
		and 32    			; 4+4+4 + 4+4+7=27t
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
		dec 	l			; 4t
		jp 	nz,soundLoop		; 26*4+4+26*4+27+11+4+8+4+4+10=280t
		dec 	h
		jr 	nz,soundLoop

	IF storeA=1
		ld (readNotes_prevVol),a
	ENDIF

		xor 	a
device10a	equ $ + 0
device10b	equ $ + 1
device10c	equ $ + 2
		ld	($6800),a

		ld 	(readNotes_prevBC),bc
		jp 	rowEnd

soundLoop_lc0		jp 	soundLoop_lb0			; 4+12+10=26t
soundLoop_lc1		jp 	soundLoop_lb1			; 4+12+10=26t
soundLoop_lc2		jp 	soundLoop_lb2			; 4+12+10=26t
soundLoop_lc3		jp 	soundLoop_lb3			; 4+12+10=26t
soundLoop_lc4		jp 	soundLoop_lb4			; 4+12+10=26t
soundLoop_lc5		jp 	soundLoop_lb5			; 4+12+10=26t
soundLoop_lc6		jp 	soundLoop_lb6			; 4+12+10=26t
soundLoop_lc7		jp 	soundLoop_lb7			; 4+12+10=26t

		;ENDMODULE





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
;    destination.
;    Length, song_title.
;------------------------			
SONG1INV dw 28672+128+2						; destination		
	 db 12							; title length.
	 db 14,09,07,08,20,32,04,01,14,03,05,18			; NIGHT DANCER
SONG2INV dw 28672+128+32+2
	 db 12  
	 db 09,14,20,05,18,19,20,05,12,12,01,18			; INTERSTELLAR
SONG3INV dw 28672+128+64+2
	 db 14
	 db 16,19,09,15,14,32,01,03,20,09,22,09,20,25		; PSION ACTIVITY
SONG4INV dw 28672+128+96+2
	 db 16
	 db 19,16,18,09,14,07,32,09,19,32,03,15,13,09,14,07	; SPRING IS COMING

; -----------------------------------------------------------------------------

;                12345678901234567890123456789012
MENU1:	db	"  # #  OCTODE XL MUSIC BOX  # #",$d
	db	"       -------------------     ",0
MENU2:	db	$D,$D," SELECT : ",0

MENU3:	db	$D,"1.NIGHT DANCER     X:SPEAKER"
	db	$D,"2.INTERSTELLAR     Y:CASS PORT"
	db	$D,"3.PSION ACTIVITY   Z:PRNTER PORT"
	db	   "4.SPRING IS COMING",0
;                   12345678901234567890123456789012

MENU4:	db	$d,$d,0

MENU5:	db	111,"BUSHY",0

BUSHYINV:	db	111,"BUSHY",0

SPEAKINV db 19,16,05,01,11,05,18			; SPEAKER
CASSEINV db 03,01,19,19,32,16,15,18,20 			; CASS PORT
PRINTINV db 16,18,14,20,05,18,32,16,15,18,20 		; PRNTER PORT

device		db 0			; 0=speaker.  1=Cassette Port.  2=Printer Port.
outdevice	db 33

; -----------------------------------------------------------------------------

	

; octode		:   446 bytes.   $1BE.			$8000
; song_nightdancer:	: 11782 bytes.	$2E10.	2045. $7FD.  	$9000
; song_interstellar:	:  7613 bytes.	$1DC0.	1597. $63D	$9700
; song_psion:		: 15257 bytes.	$3C00.	2411. $96B	$A100
; song_spring:		: 15867 bytes.	$3E00.	2754. $AC2	$AC00
; song_decompressed	:					$B800




; ---------------------------------------------------------
; NIGHT DANCER. Mr Beep. 2015. 	Mr Beep.   For Octode XL.  (M2)
; ---------------------------------------------------------
song_nightdancer_compressed:
	incbin	"mbdance.bin.zx0"		;	org is set at $a800 within mbdance.asm


; ---------------------------------------------------------
; INTERSTELLAR MUSIC DATA.   Mr Beep.  For Octode XL.  X4.
; ---------------------------------------------------------
song_interstellar_compressed:
	incbin	"mbinter.bin.zx0"		;	org is set at $a800 within mbinter.asm


; ---------------------------------------------------------
; PSIONIC ACTIVITY MUSIC DATA.   Mr Beep.  For Octode XL.  X4.
; ---------------------------------------------------------
song_psion_compressed:
	incbin	"mbpsion.bin.zx0"		;	org is set at $a800 within mbpsion.asm


; ---------------------------------------------------------
; SPRING IS COMING MUSIC DATA. 	Mr Beep.  For Octode XL.  X2.
; ---------------------------------------------------------
song_spring_compressed:
	incbin	"mbspring.bin.zx0"		;	org is set at $a800 within mbspring.asm



	org 	$a800
song_decompressed equ $

