;
;--------------------------------
; BUZZKICK
; ------------------------------

;#define defb db
;#define defw dw
;#define db  db
;#define dw  dw
;#define end end
;#define org org
;#define DEFB db
;#define DEFW dw
;#define DB  db
;#define DW  dw
;#define END end
;#define ORG org
;#define equ equ
;#define EQU equ



	ORG	$8000


	;test code

begin

	ld hl,musicdata1
	ld hl,musicdata2
	call play
	ret



	;engine code

play

	di

	ld (drumList+1),hl

	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a

	xor a
	ld (songSpeedComp+1),a
	ld (ch1out+1),a
	ld (ch2out+1),a

	ld a,128
	ld (ch1freq+1),a
	ld (ch2freq+1),a
	ld a,1
	ld (ch1delay1+1),a
	ld (ch2delay1+1),a
	ld a,16
	ld (ch1delay2+1),a
	ld (ch2delay2+1),a

	exx
	ld d,a
	ld e,a
	ld b,a
	ld c,a
	push hl
	exx

readRow

	ld c,(hl)
	inc hl

	bit 7,c
	jr z,noSpeed

	ld a,(hl)
	inc hl
	or a
	jr nz,noLoop

	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	jr readRow

noLoop

	ld (songSpeed+1),a

noSpeed

	bit 6,c
	jr z,noSustain1

	ld a,(hl)
	inc hl
	exx
	ld d,a
	ld e,a
	exx

noSustain1

	bit 5,c
	jr z,noSustain2

	ld a,(hl)
	inc hl
	exx
	ld b,a
	ld c,a
	exx

noSustain2

	bit 4,c
	jr z,noNote1

	ld a,(hl)
	ld d,a
	inc hl
	or a
	jr z,$+4
;	ld a,$18
	ld	a, 32
	ld (ch1out+1),a
	jr z,noNote1

	ld a,d
	ld (ch1freq+1),a
	srl a
	srl a
	ld (ch1delay2+1),a
	ld a,1
	ld (ch1delay1+1),a

	exx
	ld e,d
	exx

noNote1

	bit 3,c
	jr z,noNote2

	ld a,(hl)
	ld e,a
	inc hl
	or a
	jr z,$+4
;	ld a,$18
	ld	a, 32

	ld (ch2out+1),a
	jr z,noNote2

	ld a,e
	ld (ch2freq+1),a
	srl a
	srl a
	srl a
	ld (ch2delay2+1),a
	ld a,1
	ld (ch2delay1+1),a

	exx
	ld c,b
	exx

noNote2

	ld a,c
	and 7
	jr z,noDrum

playDrum

	push hl

	add a,a
	add a,a
	ld c,a
	ld b,0
drumList:
	ld hl,0
	add hl,bc

	ld a,(hl)				;length in 256-sample blocks
	ld b,a
	inc hl
	inc hl

	add a,a
	add a,a
	ld (songSpeedComp+1),a

	ld a,(hl)
	inc hl
	ld h,(hl)				;sample data
	ld l,a

	ld a,1
	ld (mask+1),a

	ld c,0
loop0
	ld a,(hl)				;7
mask:
	and 0					;7
	sub 1					;7
	sbc a,a					;4
;	and $18					;7
	and 33
;	out ($fe),a				;11
	ld	(26624), a
	ld a,(mask+1)			;13
	rlc a					;8
	ld (mask+1),a			;13
	jr nc,$+3				;7/12
	inc hl					;6

	jr $+2					;12
	jr $+2					;12
	jr $+2					;12
	jr $+2					;12
	nop						;4
	nop						;4
	ld a,0					;7

	dec c					;4
	jr nz,loop0			;7/12=168t
	djnz loop0

	pop hl

noDrum

songSpeed:
	ld a,0
	ld b,a
songSpeedComp:
	sub 0
	jr nc,$+3
	xor a
	ld c,a

	ld a,(songSpeedComp+1)
	sub b
	jr nc,$+3
	xor a
	ld (songSpeedComp+1),a

	ld a,c
	or a
	jp z,readRow

	ld c,a
	ld b,64

soundLoop

	ld a,3				;7
	dec a				;4
	jr nz,$-1			;7/12=50t
	jr $+2				;12

	dec d				;4
	jp nz,ch2			;10

ch1freq:
	ld d,0				;7

ch1delay1:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12

ch1out:
	ld a,0				;7
;	out ($fe),a			;11
	and 33
	ld	(26624), a

ch1delay2:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12

;	out ($fe),a			;11

	and 33
	ld	(26624), a

ch2

	ld a,3				;7
	dec a				;4
	jr nz,$-1			;7/12=50t
	jr $+2				;12

	dec e				;4
	jp nz,loop			;10

ch2freq:
	ld e,0				;7

ch2delay1:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12

ch2out:
	ld a,0				;7
;	out ($fe),a			;11
	and 33
	ld	(26624), a

ch2delay2:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12

;	out ($fe),a			;11
	and 33
	ld	(26624), a

loop

	dec b				;4
	jr nz,soundLoop		;7/12=168t

	ld b,64

envelopeDown

	exx

	dec e
	jp nz,noEnv1
	ld e,d

	ld hl,ch1delay2+1
	dec (hl)
	jr z,$+5
	ld hl,ch1delay1+1
	inc (hl)

noEnv1

	dec c
	jp nz,noEnv2
	ld c,b

	ld hl,ch2delay2+1
	dec (hl)
	jr z,$+5
	ld hl,ch2delay1+1
	inc (hl)

noEnv2

	exx

	dec c
	jp nz,soundLoop

	xor a
;	in a,($fe)
;	cpl
;	and $1f
;	jp z,readRow

	jp	readRow

	pop hl
	exx
	ei
	ret




musicdata1:

speed equ $c00
db 	$c0
seq
	dw ptn0
	dw ptn0
	dw ptn1
	dw ptn2
	dw ptn1
	dw ptn3
	dw ptn4
	dw ptn5
	dw ptn4
	dw ptn6
	dw ptn7
	dw ptn7
	dw ptn8
	dw ptn13
	dw ptn9
	dw ptn10
	dw ptn11
	dw ptn13
	dw ptn9
	dw ptn10
	dw ptn11
	dw ptn12
	dw ptn14
	dw ptn14
	dw 0

ptn0
	db $5,$31
	db $5,$31
	db $11,$31
	db $14,$31
	db $31,$31
	db $31,$31
	db $f,$31
	db $f,$31
	db $5,$31
	db $5,$31
	db $11,$31
	db $14,$31
	db $31,$31
	db $31,$31
	db $f,$31
	db $f,$31
	db 0

ptn1
	db $5,$e4
	db $5,$22
	db $11,$20
	db $14,$df
	db $31,$9f
	db $31,$1f
	db $f,$b1
	db $f,$b1
	db $5,$f1
	db $5,$31
	db $11,$31
	db $14,$f1
	db $31,$b1
	db $31,$31
	db $f,$18
	db $f,$9b
	db 0

ptn2
	db $5,$dd
	db $5,$1b
	db $11,$1d
	db $14,$e0
	db $31,$a0
	db $31,$20
	db $f,$f1
	db $f,$f1
	db $5,$f1
	db $5,$31
	db $11,$31
	db $14,$f1
	db $31,$b1
	db $31,$31
	db $f,$f1
	db $f,$31
	db 0

ptn3
	db $5,$dd
	db $5,$1b
	db $11,$1d
	db $14,$dd
	db $31,$9d
	db $31,$1d
	db $f,$f1
	db $f,$f1
	db $5,$f1
	db $5,$31
	db $11,$31
	db $14,$f1
	db $31,$b1
	db $31,$31
	db $f,$f1
	db $f,$31
	db 0

ptn4
	db $a,$e2
	db $a,$20
	db $16,$22
	db $19,$e5
	db $31,$a5
	db $31,$25
	db $14,$b1
	db $14,$b1
	db $a,$f1
	db $a,$31
	db $16,$31
	db $19,$e4
	db $31,$a7
	db $31,$25
	db $14,$24
	db $14,$a2
	db 0

ptn5
	db $5,$e4
	db $5,$22
	db $11,$24
	db $14,$dd
	db $31,$9d
	db $31,$1d
	db $f,$f1
	db $f,$f1
	db $5,$f1
	db $5,$31
	db $11,$31
	db $14,$f1
	db $31,$b1
	db $31,$31
	db $f,$f1
	db $f,$31
	db 0

ptn6
	db $8c,$e4
	db $10c,$24
	db $18c,$24
	db $b1,$31
	db $b1,$31
	db $b1,$b1
	db $a,$e2
	db $a,$31
	db $8,$e0
	db $8,$31
	db $7,$df
	db $7,$31
	db 0

ptn7
	db $5,$f1
	db $5,$31
	db $11,$31
	db $14,$f1
	db $31,$b1
	db $31,$31
	db $f,$b1
	db $f,$b1
	db $5,$f1
	db $5,$31
	db $11,$31
	db $14,$f1
	db $31,$b1
	db $31,$31
	db $f,$31
	db $f,$b1
	db 0

ptn8
	db $7,$f1
	db $7,$31
	db $13,$31
	db $16,$f1
	db $31,$b1
	db $31,$31
	db $11,$b1
	db $11,$b1
	db $7,$f1
	db $7,$31
	db $13,$31
	db $16,$f1
	db $31,$b1
	db $31,$31
	db $11,$31
	db $11,$b1
	db 0

ptn9
	db $7,$e6
	db $7,$24
	db $13,$26
	db $16,$e9
	db $31,$a9
	db $31,$29
	db $11,$a9
	db $11,$a9
	db $7,$f1
	db $7,$31
	db $13,$31
	db $16,$e6
	db $31,$a9
	db $31,$26
	db $11,$29
	db $11,$a6
	db 0

ptn10
	db $7,$eb
	db $7,$2b
	db $13,$2b
	db $16,$eb
	db $31,$b1
	db $31,$31
	db $11,$f1
	db $11,$f1
	db $7,$f1
	db $7,$31
	db $13,$26
	db $16,$f1
	db $31,$a4
	db $31,$31
	db $11,$df
	db $11,$31
	db 0

ptn11
	db $7,$e6
	db $7,$27
	db $13,$26
	db $16,$df
	db $31,$9f
	db $31,$1f
	db $11,$9f
	db $11,$9f
	db $7,$f1
	db $7,$31
	db $13,$31
	db $16,$f1
	db $31,$a6
	db $31,$31
	db $11,$26
	db $11,$a7
	db 0

ptn12
	db $1a,$e6
	db $1a,$26
	db $18,$24
	db $18,$24
	db $16,$22
	db $16,$22
	db $15,$21
	db $15,$21
	db $e,$26
	db $e,$26
	db $c,$24
	db $c,$24
	db $a,$22
	db $a,$22
	db $9,$21
	db $9,$21
	db 0

ptn13
	db $7,$f1
	db $7,$31
	db $13,$31
	db $16,$f1
	db $31,$b1
	db $31,$31
	db $11,$f1
	db $11,$f1
	db $7,$f1
	db $7,$31
	db $13,$31
	db $16,$f1
	db $31,$b1
	db $31,$31
	db $11,$f1
	db $11,$31
	db 0

ptn14
	db $1a,$26
	db $18,$24
	db $16,$22
	db $15,$21
	db $e,$26
	db $c,$24
	db $a,$22
	db $9,$21
	db 0




musicdata2
	dw $0944
	dw p2
	db $01,$02
	db $03,$04
	db $05,$06
	db $07,$08
	db $09,$0a
	db $0b,$0c
	db $01,$0d
	db $0e,$0f
	db $01,$02
	db $03,$04
	db $05,$06
	db $07,$10
	db $09,$11
	db $0b,$12
	db $05,$13
	db $14,$15
	db $16,$17
	db $18,$19
	db $1a,$17
	db $1b,$1c
	db $1d,$1e
	db $1f,$20
	db $1d,$1e
	db $21,$20
	db $16,$17
	db $18,$1c
	db $1a,$17
	db $1b,$22
	db $23,$24
	db $25,$24
	db $23,$26
	db $27,$28
	db $16,$17
	db $18,$19
	db $1a,$17
	db $1b,$1c
	db $1d,$1e
	db $1f,$20
	db $1d,$1e
	db $21,$20
	db $16,$17
	db $18,$1c
	db $1a,$17
	db $1b,$22
	db $29
p2:	db $28
	db $2a,$28
	db $29,$2b
	db $2c,$2d
	db $00
p3:	db $e2,$00,$e2,$00,$e2,$00,$e2,$00
	db $00,$00,$38,$38,$32,$32,$2c,$2c
	db $2c,$00,$e2,$00,$e2,$00,$e2,$00
	db $38,$38,$38,$38,$3c,$3c,$38,$38
	db $97,$00,$97,$00,$97,$00,$97,$00
	db $38,$38,$3c,$3c,$00,$00,$00,$00
	db $2c,$00,$97,$00,$97,$00,$97,$00
	db $43,$43,$3c,$3c,$00,$00,$4b,$4b
	db $a9,$00,$a9,$00,$a9,$00,$a9,$00
	db $4b,$4b,$54,$54,$4b,$4b,$43,$43
	db $2c,$00,$a9,$00,$a9,$00,$a9,$00
	db $4b,$4b,$4b,$4b,$54,$54,$4b,$4b
	db $4b,$4b,$59,$00,$59,$00,$59,$00
	db $2c,$00,$ca,$00,$b3,$00,$b3,$00
	db $54,$00,$54,$00,$4b,$00,$4b,$00
	db $38,$38,$32,$32,$00,$00,$3c,$3c
	db $3c,$3c,$43,$43,$4b,$4b,$54,$54
	db $65,$65,$59,$59,$00,$00,$4b,$4b
	db $4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b
	db $2c,$00,$97,$00,$2c,$00,$2c,$00
	db $4b,$4b,$4b,$4b,$00,$00,$00,$00
	db $a9,$00,$a9,$a9,$54,$00,$54,$54
	db $43,$43,$38,$38,$32,$32,$43,$43
	db $2c,$00,$a9,$a9,$54,$00,$54,$54
	db $38,$38,$32,$32,$38,$38,$32,$32
	db $97,$00,$97,$97,$4b,$00,$4b,$4b
	db $2c,$00,$97,$97,$2c,$00,$2c,$4b
	db $38,$38,$32,$32,$43,$43,$38,$38
	db $86,$00,$86,$86,$43,$00,$43,$43
	db $3c,$3c,$38,$38,$32,$32,$3c,$3c
	db $2c,$00,$86,$86,$43,$00,$43,$43
	db $38,$38,$32,$32,$3c,$3c,$38,$38
	db $2c,$00,$86,$86,$2c,$00,$2c,$43
	db $38,$38,$32,$32,$43,$43,$3c,$3c
	db $ca,$00,$ca,$ca,$65,$00,$65,$65
	db $43,$00,$43,$00,$43,$00,$43,$00
	db $2c,$00,$ca,$ca,$65,$00,$65,$65
	db $3c,$00,$3c,$00,$3c,$00,$3c,$00
	db $2c,$00,$ca,$ca,$65,$00,$65,$00
	db $38,$00,$38,$00,$38,$00,$38,$00
	db $e2,$00,$e2,$e2,$71,$00,$71,$71
	db $2c,$00,$e2,$e2,$71,$00,$71,$71
	db $38,$38,$38,$38,$38,$38,$38,$38
	db $2c,$e2,$e2,$e2,$e2,$00,$00,$00
	db $38,$38,$38,$38,$38,$00,$00,$00



end
