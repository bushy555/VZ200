;
;
;      TTTTT  H   H  III   SSSS     III   SSSS    
;        T    H   H   I   S          I   S                           
;        T    HHHHH   I    SSS       I    SSS                         
;        T    H   H   I       S      I       S                                                    
;        T    H   H  III  SSSS      III  SSSS
;
;
;
;    TTTTT RRRR  III        TTTTT  OOO  N   N EEEEE     11
;      T   R   R  I           T   O   O NN  N E        111             
;      T   RRRR   I  ===      T   O   O N N N EEEE       1       
;      T   R  R   I           T   O   O N  NN E          1     
;      T   R   R III          T    OOO  N   N EEEEE    1111                
;
;                    VZ Laser Tritone Musicbox. Dave. June2023
;
;
;Tritone v2 beeper music engine by Shiru (shiru@mail.ru) 03'11
;Three channels of tone, per-pattern tempo
;One channel of interrupting drums
;Feel free to do whatever you want with the code, it is PD
;
;
;
; Assemble with PASMO:	    pasmo --alocal %1.asm %1.vz
;
;
;
;
;	TRITONE #1 MUSICBOX
;       ===================
;     	airwolf.asm	; SONG1		46 k
;     	brink.asm	; SONG2		90 k
;     	dark.asm	; SONG3		67 k
;     	fotb.asm	; SONG4		54 k
;     	journey.asm	; SONG6		26 k
;     	pop.asm		; SONG9		16 k
;     	rr.asm		; SONG10	18 k 
;     	trice.asm	; SONG13	17 k
;   	freeze.asm	; SONG17	19 k.   353k total.
;
;
;	TRITONE #2 MUSICBOX
;       ===================
;	bourras.asm	; SONG5		094 k
;     	mada.asm	; SONG7		101 k
;     	mon.asm		; SONG8		103 k
;     	super.asm	; SONG11	031 k
;     	test.asm	; SONG12	003 k
;
;
;	TRITONE #3 MUSICBOX
;       ===================
;     	veeb.asm	; SONG15	025 k
;   	INVASION.ASM	; SONG18	087 k
;   	squeaktrum.asm	; SONG19	042 k
;   	247.asm		; SONG20  	093 k
;



NO_VOLUME 	equ  	$01		;define this if you want to have the same volume for all the channels
OP_NOP		equ  	$00
OP_SCF		equ  	$37
OP_ORC		equ  	$b1
BORDER_COL     	EQU  	$00		; ex zx code left as is
MASK1		equ	$21		; PLAY12
MASK2		equ	$2101
MASK3		equ	$2001




;Assemble at $A000 for compatibility of SD Loaders on 2+2k, 6k+2k and 16+2K VZ Lasers
;Assemble at $8000 for normal $8000 loading.

Origin		equ  $7B00

; -------------------------------
; Generic .VZ snapshot header
; -------------------------------
	org 	Origin - 24
	db 	$20, $20, $00, $00, $56, $5A, $44, $4F 		; generic header
	db	$53, $00, $00, $00, $00, $00, $00, $00
	db	$00, $00, $00, $00, $00, $F1
	dw	START

	org 	Origin
START equ $

; -------------------------------
; Intro stuff
; -------------------------------
	di
	call	do_intro		; Do fancy intro
	ld	a, 0
	ld	($6800), a		; MODE (0)
	ld	a, 0
	ld	(device), a	; 0 equ speaker. 1 equ cassette port.

begin:	
cls:	
; -------------------------------
; Menu stuff
; -------------------------------

	ei
	call	$01c9		; VZ ROM CLS
	di
	ld	hl, MSG1	
	call	$28a7		; Print MENU 1, VZ ROM Print string.
	ld	hl, MSG2	
	call	$28a7		; Print MENU 2, VZ ROM Print string.
	ld	hl, MSG3
	call	$28a7		; Print MENU 3, VZ ROM Print string.
;	ld	hl, MSG4
;	call	$28a7		; Print MENU 3, VZ ROM Print string.


;; -------------------------------
;; SPEAKER OR CASSETTE SELECTION
;; -------------------------------
	ld	a, (device)		; MENU for INVERSE SPEAKER or CASSETTE
	cp	1
	jr	z, menucas		; CASSETT PORT
	cp	2
	jr	z, menuprn		; PRINTER PORT
	ld	hl, SPEAKINV		; SPEAKER
	ld	de, 28755+32+96+64
	jr	menucon
menucas:ld	hl, CASSEINV
	ld	de, 28755+64+96+64
	jr	menucon
menuprn:ld	hl, PRINTINV
	ld	de, 28755+96+96+64
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

	cp	49		; "1 - "	AIRWOLF  SONG1
	jr	z, m1		; 	
	cp	50		; "2 - "	BRINK - MLADY  SONG2
	jr	z, m2
	cp	51		; "3 - " 	DARK	SONG3
	jr	z, m3
	cp	52		; "4 - " 	FOTB	SONG4
	jr	z, m4
	cp	53		; "5 - "	Journey SONG6
	jr	z, m6
	cp	54		; "6 - " 	pop	SONG9
	jr	z, m9
	cp	55		; "7 - " 	rr	SONG10
	jr	z, m10
	cp	56		; "8 - " 	Trice 	SONG13
	jr	z, m13
	cp	57		; "9 - " 	FREEZE	SONG17
	jp	z, m17
;	cp	58		; "A - " 	
;	jp	z, m10
;	cp	59		; "B - "	SUPER
;	jp	z, m11
;	cp	60		; "C - "	
;	jp	z, m12
;	cp	61		; "D - "	TRIFIQUE
;	jp	z, m13
;	cp	62		; "E - "	VEEB
;	jp	z, m14
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
	call	$01c9	
	jp 	$1a19			; Jump to VZ basic
	
m1: 	ld 	hl, SONG1		; Pick whichever key stroke, to then display.
	ld	de, SONG1INV
	jp 	continue
m2: 	ld 	hl, SONG2
	ld	de, SONG2INV
	jp 	continue
m3: 	ld 	hl, SONG3
	ld	de, SONG3INV
	jp 	continue
m4: 	ld 	hl, SONG4
	ld	de, SONG4INV
	jp 	continue
m6: 	ld 	hl, SONG6
	ld	de, SONG6INV
	jp	continue
m9: 	ld 	hl, SONG9
	ld	de, SONG9INV
	jp	continue
m10: 	ld 	hl, SONG10
	ld	de, SONG10INV
	jp	continue
m11: 	;ld 	hl, SONG11
	;ld	de, SONG11INV
	;jp	continue
m12: 	;ld 	hl, SONG12
	;ld	de, SONG12INV
	;jp	continue
m13: 	ld 	hl, SONG13
	ld	de, SONG13INV
	jp	continue
m17: 	ld 	hl, SONG17
	ld	de, SONG17INV
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
	ld 	(.nppos),hl
	ld 	c, 32
	push 	iy
	exx
	push 	hl
	ld 	(.prevSP),sp
	xor 	a
	ld 	h,a
	ld 	l,h
	ld 	(.cnt0),hl
	ld 	(.cnt1),hl
	ld 	(.cnt2),hl
	ld 	(.duty0),a
	ld 	(.duty1),a
	ld 	(.duty2),a
	ld 	(.skipDrum),a
	
;	in 	a,($1f)
;;	and 	$1f
;	ld 	a,OP_NOP
;	jr 	nz,$+4
;	ld 	a,OP_ORC
;	ld 	(.checkKempston),a
	jp 	nextPos

nextRow
.nrpos 	equ 	$+1
	ld 	hl,0
	ld 	a,(hl)
	inc 	hl
	cp 	2
	jr 	c,.ch0
	cp 	128
	jr 	c,drumSound
	cp 	255
	jp 	z,nextPos
.ch0	ld 	d,1
	cp 	d
	jr 	z,.ch1
	or 	a
	jr 	nz,.ch0note
	ld 	b,a
	ld 	c,a
	jr 	.ch0set
.ch0note
	ld 	e,a
	and 	$0f
	ld 	b,a
	ld 	c,(hl)
	inc 	hl
	ld 	a,e
	and 	$f0
.ch0set	ld 	(.duty0),a
	ld 	(.cnt0),bc
.ch1	ld 	a,(hl)
	inc 	hl
	cp 	d
	jr 	z,.ch2
	or 	a
	jr 	nz,.ch1note
	ld 	b,a
	ld 	c,a
	jr 	.ch1set
.ch1note
	ld 	e,a
	and 	$0f
	ld 	b,a
	ld 	c,(hl)
	inc 	hl
	ld 	a,e
	and 	$f0
.ch1set	ld 	(.duty1),a
	ld 	(.cnt1),bc
.ch2	ld 	a,(hl)
	inc	hl
	cp 	d
	jr 	z,.skip
	or 	a
	jr 	nz,.ch2note
	ld 	b,a
	ld 	c,a
	jr 	.ch2set
.ch2note
	ld 	e,a
	and 	$0f
	ld 	b,a
	ld 	c,(hl)
	inc 	hl
	ld 	a,e
	and 	$f0
.ch2set	ld 	(.duty2),a
	ld 	(.cnt2),bc
.skip	ld 	(.nrpos),hl
.skipDrum 	equ $
	scf
	jp 	nc,playRow
	ld 	a,OP_NOP
	ld 	(.skipDrum),a
	ld 	hl,(.speed)
	ld 	de,-150
	add 	hl,de
	ex 	de,hl
	jr 	c,$+5
	ld 	de,257
	ld 	a,d
	or 	a
	jr 	nz,$+3
	inc 	d
	ld 	a,e
	or 	a
	jr 	nz,$+3
	inc 	e
	jP 	.drum
drumSound
	ld 	(.nrpos),hl
	add 	a,a
	ld 	ixl,a
	ld 	ixh,0
	ld 	bc,drumSettings-4
	add 	ix,bc
	cp 	14*2
	ld 	a,OP_SCF
	ld 	(.skipDrum),a
	jr 	nc,drumNoise

drumTone
	ld 	bc,2
	ld 	a,b
	ld 	de, $2001	; MASK2	; $2000	; DJM
	ld 	l,(ix)
.l01	bit 	0,b
	jr 	z,.l11
	dec 	e
	jr 	nz,.l11
	ld 	e,l
;	exa
	ex 	af,af'
	ld 	a,l
	add 	a,(ix+1)
	ld 	l,a
;	exa
	ex 	af,af'
	xor 	d
.l11	ld 	($6800), a
	djnz 	.l01
	dec 	c
	jr 	nz,.l01
	jp 	nextRow
drumNoise
	ld 	b,0
	ld 	h,b
	ld 	l,h
	ld 	de, $2001	; 	MASK3	; $2000	; DJM
.l02	ld 	a,(hl)
	and 	d
	ld 	($6800), a
	and 	(ix)
	dec 	e
	ld 	($6800), a
	jr 	nz,.l12
	ld 	e,(ix+1)
	inc 	hl
.l12	djnz 	.l02
	jp 	nextRow

nextPos
.nppos 	equ 	$+1
	ld 	hl,0
.read	ld 	e,(hl)
	inc 	hl
	ld 	d,(hl)
	inc 	hl
	ld 	a,d
	or 	e
	jr 	z,orderLoop
	ld 	(.nppos),hl
	ex 	de,hl
	ld 	c,(hl)
	inc 	hl
	ld 	b,(hl)
	inc 	hl
	ld 	(.nrpos),hl
	ld 	(.speed),bc
	jp 	nextRow
orderLoop
	ld 	e,(hl)
	inc	hl
	ld 	d,(hl)
	ex 	de,hl
	jr 	.read
playRow
.speed 	equ 	$+1
	ld 	de,0
.drum
.cnt0 	equ 	$+1
	ld 	bc,0
.prevHL equ 	$+1
	ld 	hl,0
	exx
.cnt1 	equ 	$+1
	ld 	de,0
.cnt2 	equ 	$+1
	ld 	sp,0
	exx
soundLoop
	if NO_VOLUME = 1		;all the channels has the same volume
	
	add 	hl,bc	;11
	ld 	a,h		;4
.duty0 	equ 	$+1
	cp 	128		;7
	sbc 	a,a		;4
	exx			;4
	and 	c		;4
	ld 	($6800), a	;11
	add 	ix,de	;15
	ld 	a,ixh	;8
.duty1 	equ 	$+1
	cp 	128		;7
	sbc 	a,a		;4
	and 	c		;4
	ld 	($6800), a	;11
	add 	hl,sp	;11
	ld 	a,h		;4
.duty2 	equ 	$+1
	cp 	128		;7
	sbc 	a,a		;4
	and 	c		;4
	exx			;4
	dec 	e		;4
	ld 	($6800), a	;11
	jr 	nz,soundLoop	;10=153t
	dec 	d		;4
	jr 	nz,soundLoop	;10
	
	else				; all the channels has different volume

	add 	hl,bc	;11
	ld 	a,h		;4
	exx			;4
.duty0 	equ 	$+1
	cp 	128		;7
	sbc 	a,a		;4
	and 	c		;4
	add 	ix,de	;15
	ld 	($6800), a	;11
	ld 	a,ixh	;8
.duty1 	equ 	$+1
	cp 	128		;7
	sbc 	a,a		;4
	and 	c		;4
	ld 	($6800), a	;11
	add 	hl,sp	;11
	ld 	a,h		;4
.duty2 	equ 	$+1
	cp 	128		;7
	sbc 	a,a		;4
	and 	c		;4
	exx			;4
	dec 	e		;4
	ld 	($6800), a	;11
	jr 	nz,soundLoop	;10=153t
	dec 	d		;4
	jr 	nz,soundLoop	;10
	
	endif
;	xor 	a
;	ld 	($6800), a
	ld 	(.prevHL),hl
;keyM:	ld 	a, (0x68EF)			; M - MENU
;	and	$20
;	jr 	nz, key_m_cont
;	jp	begin				
;key_m_cont:


; ZX CODE
;	in 	a,($1f)
;	and 	$1f			
;	ld 	c,a
;	in 	a,($fe)
;	cpl
;.checkKempston equ $
;	or 	c
;	and 	$1f
;	jp 	z,nextRow
	jp 	nextRow

stopPlayer
.prevSP equ 	$+1
	ld 	sp,0
	pop 	hl
	exx
	pop 	iy
	ei
	ret



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

cplay
	di
	ld (.cnppos),hl
	ld c,6
	push iy
	exx
	push hl
	ld (.cprevSP),sp
	xor a				; a equ 0, or 2, or 4, or 6 ???
	ld h,a
	ld l,h
	ld (.ccnt0),hl
	ld (.ccnt1),hl
	ld (.ccnt2),hl
	ld (.cduty0),a
	ld (.cduty1),a
	ld (.cduty2),a
	ld (.cskipDrum),a
;	in a,($1f)
;;	and $1f
;	ld a,OP_NOP
;	jr nz,$+4
;	ld a,OP_ORC
;	ld (.checkKempston),a
	jp cnextPos

cnextRow
.cnrpos equ $+1
	ld hl,0
	ld a,(hl)
	inc hl
	cp 2
	jr c,.cch0
	cp 128
	jr c,cdrumSound
	cp 255
	jp z,cnextPos

.cch0
	ld d,1
	cp d
	jr z,.cch1
	or a
	jr nz,.cch0note
	ld b,a
	ld c,a
	jr .cch0set
.cch0note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
.cch0set
	ld (.cduty0),a
	ld (.ccnt0),bc
.cch1
	ld a,(hl)
	inc hl
	cp d
	jr z,.cch2
	or a
	jr nz,.cch1note
	ld b,a
	ld c,a
	jr .cch1set
.cch1note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
.cch1set
	ld (.cduty1),a
	ld (.ccnt1),bc
.cch2					
	ld a,(hl)
	inc hl
	cp d
	jr z,.cskip
	or a
	jr nz,.cch2note
	ld b,a
	ld c,a
	jr .cch2set
.cch2note				
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
.cch2set
	ld (.cduty2),a
	ld (.ccnt2),bc

.cskip
	ld (.cnrpos),hl
.cskipDrum equ $
	scf
	jp nc,cplayRow
	ld a,OP_NOP
	ld (.cskipDrum),a

	ld hl,(.cspeed)
	ld de,-150
	add hl,de
	ex de,hl
	jr c,$+5
	ld de,257
	ld a,d
	or a
	jr nz,$+3
	inc d
	ld a,e
	or a
	jr nz,$+3
	inc e
	jP .cdrum

cdrumSound
	ld (.cnrpos),hl

	add a,a
	ld ixl,a
	ld ixh,0
	ld bc,drumSettings-4
	add ix,bc
	cp 14*2
	ld a,OP_SCF
	ld (.cskipDrum),a
	jr nc,cdrumNoise

cdrumTone
	ld bc,2
	ld a,b
	ld de,$0602	; DJM. $0600 - $2100
	ld l,(ix)
.cl01
	bit 0,b
	jr z,.cl11
	dec e
	jr nz,.cl11
	ld e,l
;	exa
	ex af,af'
;	exx
	ld a,l
	add a,(ix+1)
	ld l,a
;	exa
	ex af,af'
;	exx
	xor d
.cl11
	xor	6
	ld ($6800), a
	djnz .cl01
	dec c
	jr nz,.cl01

	jp cnextRow

cdrumNoise
	ld b,0
	ld h,b
	ld l,h
	ld de,$0602	; DJM. $0600 - $2100
.cl02
	ld a,(hl)
	and d
	xor	6
	ld ($6800), a
	and (ix)
	dec e
	ld ($6800), a
	jr nz,.cl12
	ld e,(ix+1)
	inc hl
.cl12
	djnz .cl02

	jp cnextRow

cnextPos
.cnppos equ $+1
	ld hl,0
.cread
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,d
	or e
	jr z,corderLoop
	ld (.cnppos),hl
	ex de,hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld (.cnrpos),hl
	ld (.cspeed),bc
	jp cnextRow

corderLoop
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	jr .cread

cplayRow
.cspeed equ $+1
	ld de,0
.cdrum
.ccnt0 equ $+1
	ld bc,0
.cprevHL equ $+1
	ld hl,0
	exx
.ccnt1 equ $+1
	ld de,0
.ccnt2 equ $+1
	ld sp,0
	exx


csoundLoop

	add hl,bc	;11
	ld a,h		;4
	exx			;4
.cduty0 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	add ix,de	;15
	xor	6
	ld ($6800), a	;11
	ld a,ixh	;8
.cduty1 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	ld ($6800), a	;11
	add hl,sp	;11
	ld a,h		;4
.cduty2 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	exx			;4
	dec e		;4
	ld ($6800), a	;11
	jr nz,csoundLoop	;10 equ 153t
	dec d		;4
	jr nz,csoundLoop	;10
	
	xor a
	ld ($6800), a

	ld (.cprevHL),hl

;	in a,($1f)
;	and $1f
;	ld c,a
;	in a,($fe)
;	cpl
;.checkKempston equ $
;	or c
;	and $1f
;	jp z,cnextRow
	jp cnextRow

cstopPlayer
.cprevSP equ $+1
	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret



; ######################################################################
; ######################################################################
; ######################################################################
;
; ---------------------------------------------------------------------
printer_port_player:				; PRINTER PORT PLAYER.
; ---------------------------------------------------------------------
;
; An experimental printer port 1-bit player.Possibly a first for the VZ!
;

	di
	ld (.pnppos),hl
	ld c,33
	push iy
	exx
	push hl
	ld (.pprevSP),sp
	xor a
	ld h,a
	ld l,h
	ld (.pcnt0),hl
	ld (.pcnt1),hl
	ld (.pcnt2),hl
	ld (.pduty0),a
	ld (.pduty1),a
	ld (.pduty2),a
	ld (.pskipDrum),a
;	in a,($1f)
;;	and $1f
;	ld a,OP_NOP
;	jr nz,$+4
;	ld a,OP_ORC
;	ld (.pcheckKempston),a
	jp pnextPos
pnextRow
.pnrpos equ $+1
	ld hl,0
	ld a,(hl)
	inc hl
	cp 2
	jr c,.pch0
	cp 128
	jr c,pdrumSound
	cp 255
	jp z,pnextPos
.pch0	ld d,1
	cp d
	jr z,.pch1
	or a
	jr nz,.pch0note
	ld b,a
	ld c,a
	jr .pch0set
.pch0note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
.pch0set	ld (.pduty0),a
	ld (.pcnt0),bc
.pch1	ld a,(hl)
	inc hl
	cp d
	jr z,.pch2
	or a
	jr nz,.pch1note
	ld b,a
	ld c,a
	jr .pch1set
.pch1note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
.pch1set	ld (.pduty1),a
	ld (.pcnt1),bc
.pch2	ld a,(hl)
	inc hl
	cp d
	jr z,.pskip
	or a
	jr nz,.pch2note
	ld b,a
	ld c,a
	jr .pch2set
.pch2note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
.pch2set	ld (.pduty2),a
	ld (.pcnt2),bc
.pskip	ld (.pnrpos),hl
.pskipDrum equ $
	scf
	jp nc,pplayRow
	ld a,OP_NOP
	ld (.pskipDrum),a
	ld hl,(.pspeed)
	ld de,-150
	add hl,de
	ex de,hl
	jr c,$+5
	ld de,257
	ld a,d
	or a
	jr nz,$+3
	inc d
	ld a,e
	or a
	jr nz,$+3
	inc e
	jP .pdrum
pdrumSound
	ld (.pnrpos),hl
	add a,a
	ld ixl,a
	ld ixh,0
	ld bc,drumSettings-4    
	add ix,bc
	cp 14*2
	ld a,OP_SCF
	ld (.pskipDrum),a
	jr nc,pdrumNoise
pdrumTone
	ld bc,2
	ld a,b
	ld de,$2100	; DJM
	ld l,(ix)
.pl01	bit 0,b
	jr z,.pl11
	dec e
	jr nz,.pl11
	ld e,l
;	exa
	ex af,af'
	ld a,l
	add a,(ix+1)
	ld l,a
;	exa
	ex af,af'
	xor d
.pl11	out	(14), a
	djnz .pl01
	dec c
	jr nz,.pl01
	jp pnextRow
pdrumNoise
	ld b,0
	ld h,b
	ld l,h
	ld de,$2100	; DJM
.pl02	ld a,(hl)
	and d
	out	(14), a
	and (ix)
	dec e
	out	(14), a
	jr nz,.pl12
	ld e,(ix+1)
	inc hl
.pl12	djnz .pl02
	jp pnextRow
pnextPos
.pnppos equ $+1
	ld hl,0
.pread	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,d
	or e
	jr z,porderLoop
	ld (.pnppos),hl
	ex de,hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld (.pnrpos),hl
	ld (.pspeed),bc
	jp pnextRow
porderLoop
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	jr .pread
pplayRow
.pspeed equ $+1
	ld de,0
.pdrum
.pcnt0 equ $+1
	ld bc,0
.pprevHL equ $+1
	ld hl,0
	exx
.pcnt1 equ $+1
	ld de,0
.pcnt2 equ $+1
	ld sp,0
	exx


psoundLoop
	if NO_VOLUME = 1		;all the channels has the same volume
	
	add hl,bc	;11
	ld a,h		;4
.pduty0 equ $+1
	cp 128		;7
	sbc a,a		;4
	exx			;4
	and c		;4
	out	(14), a	;11
	add ix,de	;15
	ld a,ixh	;8
.pduty1 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	out	(14), a	;11
	add hl,sp	;11
	ld a,h		;4
.pduty2 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	exx			;4
	dec e		;4
	out	(14), a	;11
	jr nz,psoundLoop	;10=153t
	dec d		;4
	jr nz,psoundLoop	;10
	
	else				; all the channels has different volume

	add hl,bc	;11
	ld a,h		;4
	exx			;4
.pduty0 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	add 	ix,de	;15
	out	(14), a	;11
	ld a,ixh	;8
.pduty1 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	out	(14), a	;11
	add hl,sp	;11
	ld a,h		;4
.pduty2 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	exx			;4
	dec e		;4
	out	(14), a	;11
	jr nz,psoundLoop	;10=153t
	dec d		;4
	jr nz,psoundLoop	;10
	
	endif

;	xor a
;	out	(14), a
	ld (.pprevHL),hl
;	in a,($1f)
;	and $1f			
;	ld c,a
;	in a,($fe)
;	cpl
;.pcheckKempston equ $
;	or c
;	and $1f
;	jp z,pnextRow
	jp pnextRow
pstopPlayer
.pprevSP equ $+1
	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret



do_intro:
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
		


SONG1INV	dw 28672+99
		db 07, 01,09,18,23,15,12,06			; AIRWOLF
SONG2INV     	dw 28672+131
		db 05, 02,18,09,14,11				; BRINK
SONG3INV     	dw 28675+128+32
		db 04, 04,01,18,11				; DARK
SONG4INV     	dw 28675+128+64
		db 23, 06,12,09,07,08,20,32,15,06,32,20,08,05,32,02,21,13,02,12,05,02,05,05 ; FLIGHT OF THE BUMBLEBEE
SONG6INV     	dw 28675+128+96
		db 07, 10,15,21,18,14,05,25			; JOURNEY
SONG9INV     	dw 28675+128+128
		db 03, 16,15,16					; POP
SONG10INV    	dw 28675+128+128+32
		db 02, 18,18					; RR 
SONG13INV  	dw 28675+128+128+64
		db 05, 20,18,09,03,05				; TRICE
SONG17INV    	dw 28675+128+128+96
		db 06, 06,18,05,05,26,05			; FREEZE


;                   12345678901234567890123456789012

MSG1: 	db	    "THIS IS VTECH TRITONE1 !"
	DB	$d
	db 	$d, "SELECT:      "
	db 	$d," 1 AIRWOLF    "
	db 	$d," 2 BRINK MLADY",0
MSG2:	db 	$d," 3 DARK LIGHT "
	db	$d," 4 FLIGHT OF THE BUMBLEBEE" 
	db 	$d," 5 JOURNEY    "
	db 	$d," 6 POP          X: SPEAKER     " ,0
MSG3:	db 	$d," 7 RR           Y: CASSETT PORT" 
	db 	$d," 8 TRICE        Z: PRINTER PORT"
        db      $d," 9 FREEZE       Q: QUIT"
        db      $d,"   ",0

device	db 0
outdevice		db 33



   include   "airwolf.asm"	; SONG1
   include   "brink.asm"	; SONG2
   include   "dark.asm"		; SONG3
   include   "fotb.asm"		; SONG4
   include   "journey.asm"	; SONG6
   include   "pop.asm"		; SONG9
   include   "rr.asm"		; SONG10
   include   "trice.asm"	; SONG13
   include   "freeze.asm"	; SONG17

