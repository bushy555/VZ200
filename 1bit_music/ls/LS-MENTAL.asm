; -------------------------------
; Lyndon Sharp.  LS-ENGINE
;
; SONG : MENTAL
; ---------------------------------

#define TI82				; select target platform here
#define defb .db
#define defw .dw
#define db  .db
#define dw  .dw
#define end .end
#define org .org
#define DEFB .db
#define DEFW .dw
#define DB  .db
#define DW  .dw
#define END .end
#define ORG .org
#define equ .equ
#define EQU .equ

	ORG	$8000




;Lyndon Sharp Beeper music engine
;Two channels of tone, no volume or timbre control, non-interrupting drums
;Originally written by Lyndon Sharp circa 1989
;Reverse-engineered from Zanthrax game and modified in 2011-12 by Shiru
;Modifications are:
; minor optimizations
; drum numbers changed
; notes shifted one semitone down
; TI modifications by utz 2012


begin

	
cls:	ei
	call	$01c9		; VZ ROM CLS
	ld	hl, MSG1	; Print MENU
	call	$28a7		; VZ ROM Print string.




;		ld	hl, 26624
;		ld	a, 8
;		ld	(hl), a
;		di
;		ld	bc, 2048
;		ld	hl, mental
;		ld	de, 28672
;		ldir



	ld hl,music_Data

;	ld a,%00010000			;+ set interrupts to fastest mode
;	out (4),a
	call play

	ei
;	ld a,%00010110			;+ set interrupts back to normal
;	out (4),a
	ret

play
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (ch0ptr),de
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (ch0loop),de
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (ch1ptr),de
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (ch1loop),de
	inc hl
	ld a,(hl)
	ld (speed),a

	xor a

playSong
	call playRow

;	ld a,%10111111		;7	+ new keyhandler
;	ld a,%10111111		;7
;	out (1),a		;11
;	in a,(1)		;11	read keyboard
;	nop			;4
;	bit 6,a			;8

;	ret z			;11/5 52/46+7

	jr playSong

playRow
	di
;	ld ix,$3333		;enable both tone channels (it is mask to xor with output) +
	ld ix,$2121		;enable both tone channels (it is mask to xor with output) +
;	ld ix,$2020		;enable both tone channels (it is mask to xor with output) +

	ld d,0
ch0ptr EQU $+1
	ld hl,0			;read byte from first channel pointer
	ld c,(hl)
	ld a,c
	cp $ff
	jr nz,noLoop

ch0loop EQU $+1
	ld hl,0
	ld (ch0ptr),hl
ch1loop EQU $+1
	ld hl,0
	ld (ch1ptr),hl
	jr playRow

noLoop
	and	$3f

	jr nz,noMute0			;if it is zero, mute the channel -> ???
	db $DD, $6a			; opcode for : 	ld ixl,d

noMute0
	inc	hl			;increase pointer
	ld 	(ch0ptr),hl			;store pointer
	ld 	e,a				;read divider from note table
	ld 	hl,noteDivTable
	add 	hl,de
	ld 	a,(hl)
	ld 	(ch0div),a			;set divider
ch1ptr EQU $+1
	ld 	hl,0				;the same for second channel
	ld 	b,(hl)
	ld 	a,b
	and	$3f			; +???
	jr 	nz,noMute1
	db 	$DD, $62		;	opcode for ld ixh,d


noMute1
	inc	hl
	ld 	(ch1ptr),hl
	ld 	e,a
	ld 	hl,noteDivTable
	add	hl,de
	ld 	a,(hl)
	ld 	(ch1div),a
	ld 	a,b			;now use note values to get drum number, four bits, lower always 0
	rlca			;two top bits of note of second channel are top bits of the number
	rlca
	rl 	c			;and two top bits of note of first channel are lower bits
	rla
	add 	a,a
	and	$0f			;now there is drum number in A
	ld 	e,a
	ld 	hl,drumTable		;read drum parameters pointer from drum table
	add	hl,de
	ld 	a,(hl)
	inc	hl
	ld 	h,(hl)
	ld 	l,a
	ld 	(drumPtr),hl
	ld 	a,$10
	ld 	(drumParam0),a
	ld 	a,$29
	ld 	(drumParam1),a
	ld 	l,a
	xor	a
	ex 	af,af'
	xor	a
	ld 	h,32
	ld 	de, $2121 ;$0101 ; $2121	;3333
	exx
	ld 	b,a
drumPtr EQU $+1
	ld 	hl,0
	ld 	e,$01
	exx
speed EQU $+1
	ld 	c,7
loop0
	ld 	b,0
ploop1
	ex 	af,af'
	dec	l
	jr 	nz,$+3
	xor	a
	push 	af			; +

	xor	32
	ld	(26624), a
;	nop
	nop

	pop af

	dec	d
	jr 	nz,delay0
ch0div EQU $+1
	ld 	d,0
	db 	$dd, $ad		; opcode for XOR IXL
drumParam0 EQU $+1
	ld 	l,0
delay0ret
	exx
	ld 	c,a
	ld 	a,b
	push af			;+
	
;	xor	32
	xor	32

;	and 33
	ld	(26624), a
	nop
;	nop
;	nop

	pop af

	dec	e
	jr 	nz,delay1
	ld 	a,(hl)
	or 	a
	jp 	z,delay2
	ld 	e,a
	ld 	a,b
	xor	33		; +
	inc	hl
delay2ret
	ld 	b,a
	ld 	a,c
	exx
	ex 	af,af'
	dec	h
	jr 	nz,$+3		; +
	xor	a

	push af

;	xor	32
	xor	32

;	and 33				; TIMING
	ld 	(26624), a
	nop
;	nop
;	nop

	pop 	af

	dec	e

	jr 	nz,delay3
ch1div EQU $+1
	ld 	e,$9d

	db 	$dd, $ac		; opcode for  xor ixh



drumParam1 EQU $+1
	ld	h,017H
delay3ret
	djnz 	ploop1
	push 	af
	ld 	a,(drumParam0)
	dec	a
	ld 	(drumParam0),a
	ld 	a,(drumParam1)
	sub	3
	ld 	(drumParam1),a
	pop	af
	dec	c
	jp 	nz,loop0

	exx
	ei
	ret

delay0	xor	0
	jp	delay0ret

delay1	ld 	(0),hl
delay2	ld 	r,a
	jr 	delay2ret

delay3	xor	0
	jp 	delay3ret


MSG1 	db	"LS-ENGINE BEEPER TUNE ENGINE"
	db 	$0d, "SONG: MENTAL."
	db	$0d, "WRITTEN BY UTZ."
	db 	$0d, "VZ CONVERSION BY BUSHY."
	db	00



drumTable
	dw drum0
	dw drum1
	dw drum2
	dw drum3
	dw drum4
	dw drum5
	dw drum6
	dw drum7

drum0
	db $00
drum1
	db $05,$05,$0e,$0e,$17,$17,$2a,$17
	db $2a,$17,$2a,$17,$2a,$17,$17,$0e
	db $0e,$04,$04,$00
drum2
	db $11,$08,$18,$06,$20,$09,$25,$0c
	db $2a,$0a,$2e,$08,$32,$0a,$37,$0d
	db $3d,$0b,$42,$09,$4c,$0b,$52,$0e
	db $5a,$0c,$62,$0a,$69,$0c,$70,$0e
	db $7b,$10,$89,$11,$96,$13,$9c,$15
	db $70,$12,$12,$72,$72,$0c,$55,$0c
	db $7a,$0b,$6d,$0b,$71,$0a,$74,$0a
	db $77,$09,$7c,$06
drum3
	db $05,$0a,$0f,$14,$1b,$20,$1b,$1e
	db $10,$14,$17,$1a,$1d,$20,$2a,$36
	db $42,$4f,$5c,$4f
drum4
	db $47,$41,$0f,$0f,$09,$0c,$01,$0d
	db $03,$05,$0e,$0c,$09,$06,$09,$0a
	db $0e,$0f,$01,$0c,$04,$0e,$08,$09
	db $06,$0b,$02,$02,$05,$06,$0c,$0b
	db $00
drum5
	db $0b,$06,$0d,$0a,$0f,$0e,$11,$12
	db $13,$16,$15,$1a,$17,$1e,$19,$22
	db $1b,$26,$1d,$00
drum6
	db $11,$05,$17,$05,$20,$05,$23,$05
	db $2a,$05,$2d,$05,$30,$05,$34,$05
	db $3f,$05,$42,$05,$4c,$05,$52,$05
	db $5f,$05,$65,$05,$69,$05,$6e,$05
	db $7b,$05,$7f,$05,$84,$05,$9f,$05
	db $65,$0f,$67,$19,$69,$23,$6b,$2d
	db $6d,$37,$6f,$41,$71,$4b,$73,$55
	db $75,$5f,$77
drum7
	db $00

noteDivTable
	db $00	;no div for mute, shifts all the notes one semitone down compared to the original
	db $fa,$eb,$de,$d2,$c6,$bb,$b0,$a6
	db $9d,$94,$8c,$84,$7c,$75,$6f,$69
	db $63,$5d,$58,$53,$4e,$4a,$46,$42
	db $3e,$3b,$37,$34,$31,$2e,$2c,$29
	db $27,$25,$23,$21,$1f,$1d,$1c,$1a
	db $19,$17,$16,$15,$14,$12

;compiled music data
; MENTAL - by UTZ
;

music_Data
	dw ptr1,loop1
	dw ptr2,loop2
	db $06
ptr1
	db $18, $1b, $1f, $22, $18, $1b, $1f, $22, $18, $1b
	db $1f
	db $22
	db $18
	db $1b
	db $1f
	db $22
	db $1b
	db $1f
	db $22
	db $26
	db $1b
	db $1f
	db $22
	db $26
	db $1b
	db $1f
	db $22
	db $26
	db $1b
	db $1f
	db $22
	db $26
	db $1f
	db $22
	db $26
	db $29
	db $1f
	db $22
	db $26
	db $29
	db $1f
	db $22
	db $26
	db $29
	db $1f
	db $22
	db $26
	db $29
	db $1d
	db $24
	db $27
	db $2b
	db $1d
	db $24
	db $27
	db $2b
	db $1d
	db $20
	db $24
	db $2b
	db $1d
	db $24
	db $20
	db $1d
loop1
	db $9a
	db $1f
	db $22
	db $26
	db $1a
	db $1f
	db $a2
	db $26
	db $9a
	db $1f
	db $a2
	db $a6
	db $1a
	db $9f
	db $22
	db $a6
	db $9b
	db $1f
	db $22
	db $26
	db $1b
	db $1f
	db $a2
	db $26
	db $9b
	db $1f
	db $a2
	db $a6
	db $1b
	db $9f
	db $22
	db $26
	db $98
	db $1f
	db $a2
	db $a6
	db $18
	db $1f
	db $a2
	db $26
	db $18
	db $1f
	db $a2
	db $a6
	db $18
	db $9f
	db $22
	db $26
	db $16
	db $1f
	db $22
	db $26
	db $16
	db $1f
	db $22
	db $26
	db $15
	db $1f
	db $22
	db $26
	db $15
	db $1d
	db $22
	db $26
	db $9a
	db $1f
	db $22
	db $26
	db $1a
	db $1f
	db $a2
	db $26
	db $9a
	db $1f
	db $a2
	db $a6
	db $1a
	db $9f
	db $22
	db $a6
	db $9b
	db $1f
	db $22
	db $26
	db $1b
	db $1f
	db $a2
	db $26
	db $9b
	db $1f
	db $a2
	db $a6
	db $1b
	db $9f
	db $22
	db $26
	db $98
	db $1f
	db $a2
	db $a6
	db $18
	db $1f
	db $a2
	db $26
	db $18
	db $1f
	db $a2
	db $a6
	db $18
	db $9f
	db $22
	db $26
	db $16
	db $1f
	db $22
	db $26
	db $16
	db $1f
	db $22
	db $26
	db $15
	db $1f
	db $22
	db $26
	db $15
	db $1d
	db $22
	db $26
	db $8e
	db $8e
	db $8e
	db $8e
	db $16
	db $16
	db $0c
	db $0c
	db $8e
	db $8e
	db $8e
	db $8e
	db $1a
	db $1a
	db $18
	db $18
	db $8e
	db $0e
	db $0e
	db $0e
	db $16
	db $16
	db $8c
	db $0c
	db $8e
	db $8e
	db $8e
	db $8e
	db $18
	db $18
	db $1b
	db $1b
	db $8e
	db $0e
	db $8e
	db $8e
	db $16
	db $16
	db $0c
	db $0c
	db $8e
	db $8e
	db $8e
	db $8e
	db $1a
	db $1a
	db $18
	db $18
	db $8e
	db $0e
	db $0e
	db $0e
	db $16
	db $16
	db $8c
	db $0c
	db $8e
	db $8e
	db $8e
	db $8e
	db $26
	db $26
	db $24
	db $24
	db $1a
	db $1a
	db $21
	db $21
	db $1a
	db $1a
	db $26
	db $26
	db $1a
	db $1a
	db $24
	db $24
	db $1a
	db $1a
	db $21
	db $21
	db $1a
	db $1a
	db $21
	db $1f
	db $1d
	db $1c
	db $00
	db $1d
	db $1d
	db $00
	db $1d
	db $1c
	db $1d
	db $1c
	db $9a
	db $18
	db $9a
	db $9a
	db $21
	db $a1
	db $9a
	db $1a
	db $26
	db $26
	db $1a
	db $1a
	db $24
	db $24
	db $1a
	db $1a
	db $21
	db $21
	db $1a
	db $1a
	db $21
	db $1f
	db $1d
	db $1c
	db $00
	db $1d
	db $1d
	db $00
	db $1d
	db $1c
	db $1d
	db $1c
	db $1a
	db $18
	db $1a
	db $1a
	db $21
	db $21
	db $1a
	db $1a
	db $26
	db $26
	db $1a
	db $1a
	db $24
	db $24
	db $1a
	db $1a
	db $21
	db $21
	db $1a
	db $1a
	db $21
	db $1f
	db $1d
	db $1c
	db $00
	db $1d
	db $1d
	db $00
	db $1d
	db $1c
	db $1d
	db $1c
	db $1a
	db $18
	db $9a
	db $9a
	db $21
	db $a1
	db $9a
	db $1a
	db $26
	db $26
	db $1a
	db $1a
	db $24
	db $24
	db $1a
	db $1a
	db $21
	db $21
	db $1a
	db $1a
	db $21
	db $1f
	db $1d
	db $1c
	db $00
	db $1d
	db $1d
	db $00
	db $1d
	db $1c
	db $1d
	db $1c
	db $9a
	db $98
	db $15
	db $15
	db $21
	db $95
	db $15
	db $1a
	db $26
	db $26
	db $9a
	db $9a
	db $24
	db $a4
	db $1a
	db $1a
	db $a1
	db $21
	db $9a
	db $9a
	db $21
	db $9f
	db $1d
	db $1c
	db $00
	db $1d
	db $9d
	db $80
	db $1d
	db $9c
	db $9d
	db $1c
	db $9a
	db $18
	db $95
	db $95
	db $21
	db $95
	db $15
	db $1a
	db $26
	db $26
	db $9a
	db $9a
	db $24
	db $a4
	db $1a
	db $1a
	db $a1
	db $21
	db $9a
	db $9a
	db $21
	db $9f
	db $1d
	db $1c
	db $00
	db $1d
	db $9d
	db $80
	db $1d
	db $9c
	db $9d
	db $1c
	db $9a
	db $18
	db $9a
	db $9a
	db $21
	db $a1
	db $1a
	db $1a
	db $26
	db $26
	db $9a
	db $9a
	db $24
	db $a4
	db $1a
	db $1a
	db $a1
	db $21
	db $9a
	db $9a
	db $21
	db $9f
	db $1d
	db $1c
	db $00
	db $1d
	db $9d
	db $80
	db $1d
	db $9c
	db $9d
	db $1c
	db $9a
	db $18
	db $9a
	db $9a
	db $21
	db $a1
	db $1a
	db $1a
	db $26
	db $26
	db $9a
	db $9a
	db $24
	db $a4
	db $1a
	db $1a
	db $a1
	db $21
	db $9a
	db $9a
	db $21
	db $9f
	db $1d
	db $1c
	db $00
	db $1d
	db $9d
	db $80
	db $1d
	db $9c
	db $9d
	db $1c
	db $9a
	db $18
	db $ff
ptr2
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $02
	db $03
	db $04
	db $05
	db $06
loop2
	db $87
	db $07
	db $07
	db $07
	db $c7
	db $07
	db $87
	db $07
	db $87
	db $07
	db $87
	db $87
	db $c7
	db $87
	db $13
	db $93
	db $87
	db $07
	db $07
	db $07
	db $c7
	db $07
	db $87
	db $07
	db $87
	db $07
	db $87
	db $87
	db $c7
	db $87
	db $07
	db $07
	db $85
	db $05
	db $85
	db $85
	db $c5
	db $05
	db $85
	db $05
	db $05
	db $05
	db $85
	db $85
	db $c5
	db $85
	db $05
	db $05
	db $c5
	db $c5
	db $c5
	db $c5
	db $c5
	db $c5
	db $c5
	db $c5
	db $45
	db $45
	db $45
	db $45
	db $45
	db $45
	db $45
	db $45
	db $87
	db $07
	db $07
	db $07
	db $c7
	db $07
	db $87
	db $07
	db $87
	db $07
	db $87
	db $87
	db $c7
	db $87
	db $13
	db $93
	db $87
	db $07
	db $07
	db $07
	db $c7
	db $07
	db $87
	db $07
	db $87
	db $07
	db $87
	db $87
	db $c7
	db $87
	db $07
	db $07
	db $8c
	db $0c
	db $8c
	db $8c
	db $cc
	db $0c
	db $8c
	db $0c
	db $0c
	db $0c
	db $8c
	db $8c
	db $cc
	db $8c
	db $0c
	db $0c
	db $ce
	db $ce
	db $ce
	db $ce
	db $ce
	db $ce
	db $ce
	db $ce
	db $4e
	db $4e
	db $4e
	db $4e
	db $4e
	db $4e
	db $4e
	db $4e
	db $87
	db $87
	db $87
	db $87
	db $d3
	db $13
	db $13
	db $d3
	db $87
	db $87
	db $87
	db $87
	db $d3
	db $d3
	db $d3
	db $d3
	db $87
	db $07
	db $07
	db $07
	db $d3
	db $13
	db $93
	db $13
	db $87
	db $87
	db $87
	db $87
	db 219
	db $1b
	db $de
	db $de
	db $87
	db $07
	db $87
	db $87
	db $d3
	db $13
	db $13
	db $d3
	db $87
	db $87
	db $87
	db $87
	db $d3
	db $d3
	db $d3
	db $d3
	db $87
	db $07
	db $07
	db $07
	db $d3
	db $13
	db $93
	db $13
	db $87
	db $87
	db $87
	db $87
	db $dd
	db $1d
	db $dc
	db $dc
	db $4e
	db $4e
	db $00
	db $0e
	db $4e
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $0e
	db $0e
	db $00
	db $0e
	db $0e
	db $00
	db $00
	db $00
	db $00
	db $00
	db $80
	db $00
	db $8e
	db $8e
	db $00
	db $8e
	db $8e
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $0e
	db $0e
	db $00
	db $0e
	db $0e
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $ca
	db $ca
	db $00
	db $ca
	db $ca
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $0a
	db $0a
	db $00
	db $0a
	db $0a
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $0c
	db $0c
	db $00
	db $0c
	db $0c
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db $0c
	db $0c
	db $00
	db $0c
	db $0c
	db $00
	db $00
	db $00
	db $00
	db $00
	db $80
	db $80
	db $4e
	db $4e
	db $00
	db $8e
	db $ce
	db $00
	db $ce
	db $0e
	db $82
	db $82
	db $0e
	db $8e
	db $c2
	db $02
	db $8e
	db $0e
	db $82
	db $82
	db $0e
	db $8e
	db $c2
	db $02
	db $ce
	db $ce
	db $82
	db $82
	db $0e
	db $8e
	db $82
	db $02
	db $8e
	db $0e
	db $8e
	db $8e
	db $00
	db $8e
	db $c2
	db $02
	db $ce
	db $0e
	db $82
	db $82
	db $0e
	db $8e
	db $c2
	db $02
	db $8e
	db $0e
	db $82
	db $82
	db $0e
	db $8e
	db $c2
	db $02
	db $ce
	db $ce
	db $82
	db $82
	db $0e
	db $8e
	db $82
	db $02
	db $8e
	db $0e
	db $8a
	db $8a
	db $00
	db $8a
	db $ca
	db $00
	db $d6
	db $16
	db $8a
	db $8a
	db $16
	db $96
	db $ca
	db $0a
	db $96
	db $16
	db $8a
	db $8a
	db $16
	db $96
	db $ca
	db $0a
	db $d6
	db $d6
	db $8a
	db $8a
	db $16
	db $96
	db $8a
	db $0a
	db $96
	db $16
	db $8c
	db $8c
	db $00
	db $8c
	db $cc
	db $00
	db $d3
	db $13
	db $87
	db $87
	db $13
	db $93
	db $c7
	db $07
	db $93
	db $13
	db $87
	db $87
	db $13
	db $93
	db $cc
	db $0c
	db $c0
	db $cc
	db $8c
	db $80
	db $00
	db $80
	db $80
	db $00
	db $80
	db $00
	db $ff

mental
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$015,$055,$040,$000,$055,$055,$041,$055,$055,$055,$055,$005,$055,$040,$005
 db  $055,$005,$055,$055,$055,$054,$000,$001,$055,$050,$000,$015,$050,$000,$000,$000
 db  $000,$01F,$0FF,$040,$000,$07F,$0FF,$041,$0FF,$0FF,$0FF,$0FD,$007,$0FF,$040,$007
 db  $0FD,$007,$0FF,$0FF,$0FF,$0F4,$000,$001,$0FF,$0D0,$000,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0FF,$0D0,$001,$0FF,$0FF,$041,$0FF,$0FF,$0FF,$0FD,$007,$0FF,$0D0,$007
 db  $0FD,$007,$0FF,$0FF,$0FF,$0F4,$000,$007,$0FF,$0F4,$000,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0FF,$0D0,$001,$0FF,$0FF,$041,$0FF,$0FF,$0FF,$0FD,$007,$0FF,$0D0,$007
 db  $0FD,$007,$0FF,$0FF,$0FF,$0F4,$000,$007,$0FF,$0F4,$000,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F7,$0D0,$001,$0F7,$0FF,$041,$0FD,$055,$055,$055,$007,$0FF,$0F4,$007
 db  $0FD,$005,$055,$07F,$055,$054,$000,$007,$0F7,$0F4,$000,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F7,$0F4,$007,$0F7,$0FF,$041,$0FD,$000,$000,$000,$007,$0FF,$0F4,$007
 db  $0FD,$000,$000,$07F,$040,$000,$000,$01F,$0F7,$0FD,$000,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F5,$0F4,$007,$0D7,$0FF,$041,$0FD,$000,$000,$000,$007,$0FD,$0FD,$007
 db  $0FD,$000,$000,$07F,$040,$000,$000,$01F,$0D1,$0FD,$000,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F5,$0F4,$007,$0D7,$0FF,$041,$0FD,$055,$055,$054,$007,$0FD,$07D,$007
 db  $0FD,$000,$000,$07F,$040,$000,$000,$07F,$0D1,$0FD,$000,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F5,$0F4,$007,$0D7,$0FF,$041,$0FF,$0FF,$0FF,$0F4,$007,$0FD,$07F,$047
 db  $0FD,$000,$000,$07F,$040,$000,$000,$07F,$041,$0FF,$040,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F5,$0FD,$01F,$0D7,$0FF,$041,$0FF,$0FF,$0FF,$0F4,$007,$0FD,$01F,$047
 db  $0FD,$000,$000,$07F,$040,$000,$000,$07F,$041,$0FF,$040,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F4,$07D,$01F,$047,$0FF,$041,$0FF,$0FF,$0FF,$0F4,$007,$0FD,$01F,$0D7
 db  $0FD,$000,$000,$07F,$040,$000,$001,$0FD,$000,$07F,$040,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F4,$07D,$01F,$047,$0FF,$041,$0FD,$055,$055,$054,$007,$0FD,$007,$0D7
 db  $0FD,$000,$000,$07F,$040,$000,$001,$0FD,$055,$07F,$040,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F4,$07F,$07F,$041,$0FF,$041,$0FD,$000,$000,$000,$007,$0FD,$007,$0F7
 db  $0FD,$000,$000,$07F,$040,$000,$001,$0FF,$0FF,$0FF,$0D0,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F4,$07F,$07F,$041,$0FF,$041,$0FD,$000,$000,$000,$007,$0FD,$001,$0F7
 db  $0FD,$000,$000,$07F,$040,$000,$007,$0FF,$0FF,$0FF,$0D0,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F4,$01F,$0FD,$001,$0FF,$041,$0FD,$000,$000,$000,$007,$0FD,$001,$0FF
 db  $0FD,$000,$000,$07F,$040,$000,$007,$0FF,$0FF,$0FF,$0D0,$01F,$0D0,$000,$000,$000
 db  $000,$01F,$0F4,$01F,$0FD,$001,$0FF,$041,$0FD,$055,$055,$055,$007,$0FD,$000,$07F
 db  $0FD,$000,$000,$07F,$040,$000,$01F,$0F5,$055,$05F,$0F4,$01F,$0D5,$055,$055,$040
 db  $000,$01F,$0F4,$01F,$0FD,$001,$0FF,$041,$0FF,$0FF,$0FF,$0FD,$007,$0FD,$000,$07F
 db  $0FD,$000,$000,$07F,$040,$000,$01F,$0D0,$000,$01F,$0F4,$01F,$0FF,$0FF,$0FF,$040
 db  $000,$01F,$0F4,$01F,$0FD,$001,$0FF,$041,$0FF,$0FF,$0FF,$0FD,$007,$0FD,$000,$01F
 db  $0FD,$000,$000,$07F,$040,$000,$01F,$0D0,$000,$007,$0F4,$01F,$0FF,$0FF,$0FF,$040
 db  $000,$01F,$0F4,$007,$0F4,$001,$0FF,$041,$0FF,$0FF,$0FF,$0FD,$007,$0FD,$000,$01F
 db  $0FD,$000,$000,$07F,$040,$000,$07F,$040,$000,$007,$0FD,$01F,$0FF,$0FF,$0FF,$040
 db  $000,$015,$054,$005,$054,$001,$055,$041,$055,$055,$055,$055,$005,$055,$000,$005
 db  $055,$000,$000,$055,$040,$000,$055,$040,$000,$001,$055,$015,$055,$055,$055,$040
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$015,$000,$000,$000,$000,$000,$054,$000,$055,$055,$055,$055,$055,$054,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01D,$000,$000,$000,$000,$000,$074,$000,$075,$0FF,$0FF,$0D7,$0FF,$0F4,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01D,$000,$000,$000,$000,$000,$074,$000,$075,$055,$0D5,$055,$055,$0D0,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01D,$055,$005,$040,$015,$000,$074,$000,$074,$001,$0D0,$000,$007,$0D0,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01D,$0FF,$047,$040,$01D,$000,$074,$000,$074,$001,$0D0,$000,$007,$040,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01F,$057,$041,$0D0,$074,$000,$074,$000,$074,$001,$0D0,$000,$01D,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01D,$045,$0D1,$0D0,$074,$000,$074,$000,$074,$001,$0D0,$000,$07D,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01D,$001,$0D1,$0F4,$074,$000,$074,$000,$074,$001,$0D0,$000,$074,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01D,$001,$0D0,$075,$0D0,$000,$074,$000,$074,$001,$0D0,$001,$0D0,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01D,$005,$0D0,$07D,$0D0,$000,$074,$000,$074,$001,$0D0,$007,$0D0,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01F,$057,$040,$07F,$0D0,$000,$01D,$055,$0F4,$001,$0D0,$007,$055,$055,$050
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$01D,$07F,$040,$01F,$040,$000,$017,$0FF,$050,$001,$0D0,$01F,$0FF,$0F5,$0D0
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$015,$055,$000,$01F,$040,$000,$005,$055,$040,$001,$050,$015,$055,$055,$050
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$001,$05D,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$001,$0F5,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$001,$050,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$015,$055,$040,$000,$000,$000,$000,$000,$054,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01F,$0FF,$0D0,$000,$000,$000,$000,$000,$074,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01D,$055,$0F4,$000,$000,$000,$000,$000,$074,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01D,$000,$074,$015,$001,$050,$015,$040,$075,$054,$015,$000,$054,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01D,$000,$074,$01D,$001,$0D0,$07F,$0D0,$077,$0FD,$01D,$000,$074,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01D,$055,$0D4,$01D,$001,$0D1,$0D5,$074,$075,$05F,$047,$041,$0D0,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01F,$0FF,$0D4,$01D,$001,$0D1,$0D4,$054,$075,$007,$047,$041,$0D0,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01D,$055,$07D,$01D,$001,$0D1,$0FD,$040,$074,$007,$047,$0D1,$0D0,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01D,$000,$01D,$01D,$001,$0D0,$057,$0D4,$074,$007,$041,$0D7,$040,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01D,$000,$01D,$01D,$005,$0D1,$051,$074,$074,$007,$041,$0F7,$040,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01D,$055,$07D,$01F,$057,$0D1,$0F5,$074,$074,$007,$041,$0FF,$041,$050
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$01F,$0FF,$0F4,$017,$0F5,$0D0,$07F,$0D0,$074,$007,$040,$07D,$001,$0D0
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$015,$055,$050,$005,$055,$050,$015,$040,$054,$005,$040,$07D,$001,$050
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$005,$074,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$007,$0D4,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$005,$040,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 db  $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 

end
