; музыка из Dark Fusion
; music of Dark Fusion
; disassembled by Oleg Origin

	ORG	$8000
	
START
	DI
	LD	SP,0
	LD	HL,65024
	LD	BC,253
IMTAB1	LD	(HL),C
	INC	HL
	DJNZ	IMTAB1
	LD	(HL),C
	LD	A,195
	LD	(65021),A
	LD	HL,MUSINTR
	LD	(65022),HL
	LD	A,254
	LD	I,A
	IM	2

MUSREP	CALL	MUSPLAY
	JR	MUSREP

;------------------------------------------------------

MUSPLAY	LD	HL,MUSINTR
	LD	(65022),HL
	LD	(L_8BA8+1),SP

;------------------------------------------------------
; в оригинальном коде здесь, видимо, была ошибка:
; "LD BC,$1AFF", то есть 26 проходов цикла, в то время
; как для копирования всех значений нужно вдвое меньше;
; совершенно случайно лишние проходы "копировали" байты
; в область ПЗУ, но также могли быть запорченными байты
; в области кода игры
;
; the original code here, apparently, was a mistake:
; "LD BC, $ 1AFF", i.e. passes 26 cycles, while
; how to copy all the values ​​you need half;
; accidentally superfluous passages "copied" bytes
; ROM region, but could also be a corrupt bytes
; in the game code
;------------------------------------------------------

	LD	HL,LAB_36340
	LD	BC,$0DFF	; ($FF will be ignored)
MUSISET	LD	E,(HL)		; get dest address
	INC	HL
	LD	D,(HL)
	INC	HL
	LDI			; (HL)->(DE) and ++-
	DJNZ	MUSISET

	EI
	HALT
	JP	PTNINIT

MUSMC1	LD	A,6		; SMC
	DEC	A
	LD	(MUSMC1+1),A
	RET	NZ
MUSMC3	LD	A,7
	LD	(MUSMC1+1),A

MUS_L1	EXX
	LD	A,(HL)
	INC	HL
	EXX
	AND	A
	RET	Z
	LD	HL,L_87F9
	CP	25
	JP	C,L_8999
	LD	(MUSMC34+1),A
	LD	(L_8B32),A
	LD	B,A
	SRL	B
	SRL	B
	SUB	B
	LD	(MUSMC37+1),A
	LD	A,0
	LD	(MUSMC38+1),A
	LD	A,32
	LD	(MUSMC36+1),A
	XOR	A
	LD	(L_8A48),A
	LD	A,(BASMOD1+1)
	LD	(L_8A6D),A
	RET

MUSMC4	LD	A,1		; SMC
	DEC	A
	LD	(MUSMC4+1),A
	JP	Z,MUSMC5
L_87A1	EXX
MUSMC7	LD	HL,L_8F58	; SMC
	EXX
	JP	MUS_L1

MUSMC5	LD	HL,L_8E5E	; SMC
L_87AC	LD	A,(HL)
	INC	HL
	LD	(MUSMC4+1),A
	LD	C,(HL)
	INC	HL
	LD	(MUSMC5+1),HL
	LD	B,0
	LD	HL,L_8F1C
	ADD	HL,BC
	LD	(MUSMC7+1),HL
	JP	L_87A1	

MLAB_2	EXX
	LD	A,(HL)
	INC	HL
	LD	(BASMOD1+1),A
	LD	A,(HL)
	INC	HL
	LD	(MUSMC23+1),A
	EXX
	JP	MUS_L1

MLAB_1	EXX
	LD	A,(HL)
	INC	HL
	EXX
	LD	(MUSMC3+1),A
	LD	(MUSMC1+1),A
	JP	MUS_L1

L_87DE	LD	A,0		; SMC
	AND	A
	JP	Z,L_87F3
	LD	HL,L_87DE+1
	DEC	(HL)
	EXX
	JR	Z,L_87EE
	DEC	HL
	EXX
	RET

L_87EE	INC	HL
	EXX
	JP	MUS_L1

L_87F3	EXX
	LD	A,(HL)
	LD	(L_87DE+1),A
	DEC	HL
L_87F9	EXX
	RET

	;--------------------

	DW	L_87DE
	DW	MLAB_1
	DW	MUSMC4
	DW	MLAB_2

	;--------------------

L_8803	LD	HL,L_8E44
	DEC	(HL)
	RET	NZ
	LD	(HL),2
L_880A	EXX
	INC	D
	LD	A,D
	CP	E
	EXX
	JR	Z,L_8827
	LD	(MUSMC31+1),A
	LD	(L_8B31),A
	SRL	A
	SRL	A
	INC	A
	SUB	$0A
	LD	(MUSMC33+1),A
	LD	A,$0A
	LD	(MUSMC32+1),A
	RET

L_8827	LD	A,13
	DEC	A
	LD	(L_8827+1),A
	JR	Z,MUSMC9
L_882F	EXX
MUSMC8	LD	DE,L_8E32
	EXX
	JP	L_880A

MUSMC9	LD	HL,L_8E79	; SMC
L_883A	LD	A,(HL)
	INC	HL
	LD	(L_8827+1),A
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	(MUSMC9+1),HL
	LD	(MUSMC8+1),DE
	JR	L_882F

MUSMC10	LD	A,13		; SMC
	DEC	A
	LD	(MUSMC10+1),A
	RET	NZ
MUSMC11	LD	A,$2A
	LD	(MUSMC10+1),A
L_8858	EXX
	LD	A,(BC)
	INC	BC
	EXX
	AND	A
	RET	Z
	CP	25
	LD	HL,L_894B
	JP	C,L_8999
	LD	(MUSMC27+1),A
	LD	(L_8B30),A
	DEC	A
	LD	(MUSMC26+1),A
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	SUB	2
	OR	1
	LD	(MUSMC25+1),A
	XOR	A
	LD	(L_8E43),A
	LD	(MUSMC29+1),A
MUSMC12	LD	HL,0
	LD	DE,L_8E1B
	LD	C,4
	LDIR
MUSMC13	LD	A,$C9		; code of RET
	LD	(L_8ADC),A
	LD	HL,L_8E32
	LD	DE,L_8E1F
	LD	BC,$0011
	LDIR
	LD	HL,L_8E20
	LD	(L_8E30),HL
	LD	A,32
	LD	(MUSMC28+1),A
	LD	A,0
	LD	(MUSMC24+1),A
	XOR	A
	LD	(L_8A6E),A
	LD	A,(L_8E1F)
	JP	L_8A93

L_88BA	LD	A,1		; SMC
	DEC	A
	LD	(L_88BA+1),A
	JP	Z,MUSMC15
L_88C3	EXX
MUSMC14	LD	BC,L_8E9D
	EXX
	JP	L_8858

MUSMC15	LD	HL,L_8E47
L_88CE	LD	A,(HL)
	INC	HL
	CP	253
	JP	Z,L_8BA6
	LD	(L_88BA+1),A

L_88D8	LD	C,(HL)
	INC	HL
	LD	(MUSMC15+1),HL
	LD	B,0
	LD	HL,L_8E9D
	ADD	HL,BC
	LD	(MUSMC14+1),HL
	JP	L_88C3

L_88E9	EXX
	LD	A,(BC)
	INC	BC
	EXX
	LD	DE,L_8E32
	LD	C,A
	LD	B,0
	LD	HL,L_915A
	ADD	HL,BC
	LDI
	LD	BC,$04FF
L_88FC	LDI
	LDI
	DEC	HL
	LDI
	LDI
	DJNZ	L_88FC
	JP	L_8858

L_890A	EXX
	LD	A,(BC)
	INC	BC
	EXX
	LD	C,A
	LD	B,0
	LD	HL,L_9181
	ADD	HL,BC
	LD	(MUSMC12+1),HL
	XOR	A
	JR	L_891D

L_891B	LD	A,$C9		; code of RET
L_891D	LD	(MUSMC13+1),A
	JP	L_8858

L_8923	EXX
	LD	A,(BC)
	INC	BC
	EXX
	LD	(MUSMC11+1),A
	LD	(MUSMC10+1),A
	JP	L_8858

MUSMC16	LD	A,3
	AND	A
	JP	Z,L_8945
	LD	HL,MUSMC16+1
	DEC	(HL)
	EXX
	JR	Z,L_8940
	DEC	BC
	EXX
	RET

L_8940	INC	BC
	EXX
	JP	L_8858

L_8945	EXX
	LD	A,(BC)
	LD	(MUSMC16+1),A
	DEC	BC
L_894B	EXX
	RET

	;--------------------

	DW	MUSMC16
	DW	L_8923
	DW	L_88BA
	DW	L_88E9
	DW	L_890A
	DW	L_891B

	;--------------------

L_8959	LD	A,13
	DEC	A
	LD	(L_8959+1),A
	RET	NZ

MUSMC17	LD	HL,L_8E85
L_8963	; pattern setting for drums
	LD	A,(HL)
	INC	HL
	CP	$FE
	JR	Z,L_8992
	CP	$FC		; marker of drumset pointer
	JR	Z,L_8987
	LD	(L_8959+1),A
	LD	C,(HL)
	INC	HL
	LD	(MUSMC17+1),HL
	LD	B,0
MUSMC18	LD	HL,DRUM_PATTERNS
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	(MUSMC19+1),A
	LD	(MUSMC2+1),A
	LD	(PTNPLAY+1),HL
	RET

L_8987	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(MUSMC18+1),DE
	JP	L_8963

L_8992	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	L_8963

L_8999	LD	E,A
	SLA	E
	LD	D,0
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	JP	(HL)

PTNINIT
	; pattern settings for each channel
	LD	HL,L_8E45
	CALL	L_88CE
	LD	HL,L_8E56
	CALL	L_87AC
	LD	HL,L_8E76
	CALL	L_883A
	LD	HL,L_8E7C
	CALL	L_8963
	JP	PTNPLAY

L_89BF
	;---------------------------------------------
	; в оригинале в этом месте летящие звёзды,
	; мигающая строка и опрос клавиатуры (2 call)
	;
	; in the original at this point flying stars,
	; flashing string and keyboard poll (2 CALLs)
	;---------------------------------------------
	CALL	MUSMC10		; call lead processing
	CALL	MUSMC1		; call bass processing
	CALL	L_8803		; call portamento
	CALL	L_8A48		; call bass squeeze
	CALL	L_8A6E		; lead chan some modify
	CALL	L_8ADC

MUSMC2	LD	A,6
	LD	C,0
	DEC	A
	JP	Z,L_89E5
	LD	(MUSMC2+1),A
	JP	MUSMC21

L_89E5	LD	(MUSMC22+1),A
MUSMC19	LD	A,7
	LD	(MUSMC2+1),A
MUSMC20	LD	HL,0		; SMC (drums data)
L_89F0	LD	A,(HL)
	DEC	A
	JP	NZ,L_8A01
	CALL	L_8959
PTNPLAY	LD	HL,0		; SMC (drums data)
	LD	(MUSMC20+1),HL
	JP	L_89F0

L_8A01	INC	HL
	LD	(MUSMC20+1),HL
	INC	A
	BIT	5,A
	JR	Z,L_8A16
	AND	$7F
	EX	AF,AF'
	LD	A,1
	LD	(MUSMC2+1),A
	LD	(MUSMC21+1),A
	EX	AF,AF'
L_8A16	LD	D,A
	AND	7
	LD	B,A
	LD	A,D
	SRL	A
	SRL	A
	SRL	A
	DEC	B
	DEC	B
	JP	Z,DRMBAS
	DEC	B
	JP	Z,DRMSNR
	DEC	B
	JP	Z,DRMHAT
MUSMC21	LD	A,0		; SMC
	AND	A
	JR	Z,MUSMC22
	LD	HL,MUSMC2+1
	DEC	(HL)
	LD	HL,MUSMC21+1
	DEC	(HL)
MUSMC22	LD	A,0		; SMC
	DEC	A
	JP	Z,MUSMC39
	DEC	A
	JP	Z,MUSMC41
	JP	L_8B33

L_8A48	DB	$00		; SMC NOP/RET
	LD	HL,L_8A6D
	DEC	(HL)
	RET	NZ
BASMOD1	LD	(HL),1		; SMC
	LD	HL,MUSMC37+1
	LD	A,(HL)
MUSMC23	LD	C,$07
	SUB	C
	JR	Z,L_8A63
	JR	C,L_8A63
	LD	(HL),A
	LD	HL,MUSMC38+1
	LD	A,(HL)
	ADD	A,C
	LD	(HL),A
	RET

L_8A63	XOR	A
	LD	(MUSMC36+1),A
	LD	A,$C9		; code of RET
	LD	(L_8A48),A
	RET

	;--------------------

L_8A6D	DB	$01		; some variable for bass

	;--------------------

L_8A6E	DB	$C9		; SMC NOP/RET
	LD	HL,(L_8E30)
	LD	A,(HL)
	AND	A
	JR	NZ,L_8A86
MUSMC24	LD	A,4
	DEC	A
	JP	Z,L_8AD3
	LD	(MUSMC24+1),A
	LD	DE,$0004
	ADD	HL,DE
	LD	(L_8E30),HL
L_8A86	INC	HL
	DEC	(HL)
	RET	NZ
	INC	HL
	LD	A,(HL)
	DEC	HL
	LD	(HL),A
	DEC	HL
	DEC	(HL)
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
L_8A93	LD	HL,L_8E43
	LD	D,A
	ADD	A,(HL)
	CP	$18
	RET	NC
	LD	(HL),A
	LD	A,D
	AND	A
	RET	Z
	JP	P,L_8AA4
	NEG
L_8AA4	LD	B,A
	XOR	A
MUSMC25	LD	C,0
L_8AA8	ADD	A,C
	DJNZ	L_8AA8
	BIT	5,D
	LD	HL,MUSMC29+1
	JR	Z,L_8ABE
	LD	B,A
	LD	A,(HL)
	SUB	B
	JP	Z,L_8ACF
	JP	NC,MUSMC26
	JP	L_8ACF

L_8ABE	ADD	A,(HL)
MUSMC26	LD	B,0
	CP	B
	JP	C,L_8AC7
	LD	A,B
	DEC	A
L_8AC7	LD	(HL),A
	LD	C,A
	LD	A,B
	SUB	C
	LD	(MUSMC30+1),A
	RET

L_8ACF	XOR	A
	LD	(MUSMC28+1),A
L_8AD3	LD	A,$C9
	LD	(L_8A6E),A
	LD	(L_8ADC),A
	RET

L_8ADC	RET			; SMC NOP/RET

	LD	HL,L_8E1B
	LD	A,(HL)
	AND	A
	JP	Z,L_8AE7
	DEC	(HL)
	RET

L_8AE7	LD	HL,L_8E1C
	DEC	(HL)
	JP	NZ,L_8B03
	INC	HL
	LD	A,(HL)
	AND	A
	JR	NZ,L_8AFA
	LD	A,$C9
	LD	(L_8ADC),A
	JR	L_8B03

L_8AFA	DEC	HL
	LD	(HL),A
	LD	HL,L_8E1E
	LD	A,(HL)
	NEG
	LD	(HL),A
L_8B03	LD	A,(L_8E1E)
	LD	HL,MUSMC27+1
	ADD	A,(HL)
	LD	(HL),A
	LD	(L_8B30),A
	DEC	A
	LD	(MUSMC26+1),A
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	SUB	2
	OR	1
	LD	(MUSMC25+1),A
	LD	C,A
	LD	A,(L_8E43)
	LD	B,A
	XOR	A
L_8B27	ADD	A,C
	DJNZ	L_8B27
	LD	HL,MUSMC29+1
	JP	MUSMC26

L_8B30	INC	DE
L_8B31	LD	E,L
L_8B32	RET	NZ
L_8B33	LD	A,(L_8B30)
	LD	L,A
	LD	A,(L_8B31)
	LD	D,A
	LD	A,(L_8B32)
	LD	E,A
	LD	C,0

	;--- main sound loop ----------

L_8B41	DEC	L
	JP	NZ,L_8B56

MUSMC27	LD	L,$5B
MUSMC28	LD	A,32
				; lead channel
	ld 	(26624), a
MUSMC29	LD	B,$12
	DJNZ	$
	XOR	A
	ld 	(26624), a
MUSMC30	LD	B,$4D
	DJNZ	$

L_8B56	DEC	D
	JP	NZ,L_8B6B

MUSMC31	LD	D,$5D
	LD	A,32
;	OUT	($FE),A		; portamento channel
	ld 	(26624), a
MUSMC32	LD	B,$0A
	DJNZ	$
	XOR	A
	ld 	(26624), a
MUSMC33	LD	B,$0E
	DJNZ	$
L_8B6B	DEC	E
	JP	NZ,L_8B8F

MUSMC34	LD	E,$C0
MUSMC35	LD	A,2
	INC	A
	AND	$03
	LD	(MUSMC35+1),A
	JP	NZ,L_8B8F

MUSMC36	LD	A,32
				; bass channel
	ld 	(26624), a
MUSMC37	LD	B,$82
L_8B82	DB	$00
	DB	$00
	DJNZ	L_8B82
	XOR	A
	ld 	(26624), a
MUSMC38	LD	B,$0F
L_8B8B	DB	$00
	DB	$00
	DJNZ	L_8B8B

L_8B8F	LD	A,C
	AND	A
	JP	Z,L_8B41

	;--- end of main sound loop ---

	LD	A,L
	LD	(L_8B30),A
	LD	A,D
	LD	(L_8B31),A
	LD	A,E
	LD	(L_8B32),A
	JP	L_89BF

MUSINTR	INC	C
	EI
	RET

L_8BA6	LD	B,0
L_8BA8	LD	SP,0	; SMC
	DI
	RET

;---------------DRUM MACHINE------------------

	;--- snare drum

DRMSNR	LD	(MUSMC6+1),A
	LD	A,1
	LD	(MUSMC22+1),A
	LD	IX,DRUMSAMPLE_1
	LD	D,$FF
MUSMC6	LD	B,8		; SMC
DRMSNR1	LD	A,33
	BIT	5,(IX+0)
	JR	NZ,DRMSNR2
	RES	5,A
DRMSNR2	
				; sound of snare drum
	ld 	(26624), a
	RLC	(IX+0)
	DJNZ	DRMSNR1

	INC	IX
	DEC	D
	JR	Z,DRMSNR3
	LD	A,C
	AND	A
	JP	Z,MUSMC6
	LD	A,D
	LD	(MUSMC39+1),A
	JP	L_89BF

DRMSNR3	XOR	A
	LD	(MUSMC22+1),A
	JP	L_8B33

MUSMC39	LD	A,$42
	LD	D,A
	JP	MUSMC6

	;--- bass drum

DRMBAS	LD	(MUSMC40+1),A
	LD	A,32
	LD	(MUSMC22+1),A
	LD	IX,DRUMSAMPLE_2
	LD	D,$70
MUSMC40	LD	B,$08
L_8C18	LD	A,32
	BIT	5,(IX+$00)
	JR	NZ,L_8C22
	RES	5,A
L_8C22	
					; sound of bass drum
	ld 	(26624), a
	RLC	(IX+$00)
	DB	$00
	DJNZ	L_8C18
	INC	IX
	DEC	D
	JR	Z,L_8C3C
	LD	A,C
	AND	A
	JP	Z,MUSMC40
	LD	A,D
	LD	(MUSMC41+1),A
	JP	L_89BF

L_8C3C	XOR	A
	LD	(MUSMC22+1),A
	JP	L_8B33

MUSMC41	LD	A,32
	LD	D,A
	JP	MUSMC40

	;--- hi-hat section

DRMHAT	LD	E,A
L_8C4A	LD	D,50		; hi-hat length
L_8C4C	LD	HL,DRUMSAMPLE_0
	INC	(HL)
	INC	(HL)
	INC	(HL)
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
	SUB	$8D
	LD	(HL),A
	ADD	A,B
	INC	HL
	RLCA
	RRC	(HL)
	ADD	A,(HL)
	LD	(HL),A
	AND	33
	JR	Z,L_8C73
	LD	A,33
	SUB	E
	LD	B,A
	DJNZ	$
	LD	A,32
				; sound of hi-hat
	ld 	(26624), a
	LD	B,E
	DJNZ	$
	XOR	A
	ld 	(26624), a
L_8C73	DEC	D
	JR	NZ,L_8C4C
	LD	A,C
	AND	A
	JP	NZ,L_89BF
	DEC	E
	JR	NZ,L_8C4A
	JP	L_8B33

;--- Digital Drum Samples

DRUMSAMPLE_0
	DB	0,0,0
DRUMSAMPLE_1
	; snare drum
	DB	$FF,$00,$00,$00,$0F
	DB	$FF,$FF,$FF,$EF,$FF
	DB	$FF,$FF,$BE,$36,$10
	DB	0,0,0,0,0
	DB	0,0,0,0,0
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$F8,$78,$80
	DB	0,0,0,0,0
	DB	0,0,0,0
	DB	$C0,$E1
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$BE,$F3,$9E,$70,$C0
	DB	0,0,0,0,0,0
	DB	$01,$9E,$FF,$3F
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF
	DB	$FB,$FF,$3F
	DB	$38,$F0,$03,$80
	DB	0,0,0,0,0,0
	DB	$C6,$DB,$9D
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FE,$07,$70,$60
	DB	0,0,0,1,0,0
	DB	$08,$80,$77,$DF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FE,$FF
	DB	$F8,$A3,$CE,$1C,$64,$02
	DB	$20,$00,$0E
	DB	0,0
	DB	$3F,$18,$8F,$9F
	DB	$FF,$FF,$DF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$EF,$FF,$FF,$EF,$FF
	DB	$3F,$FC,$9C,$38,$CE
	DB	0,3,0,0,0
	DB	$C4,$7F,$01
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF
	DB	$3E,$40,$98,$10,$C0
	DB	$1F,$80,$00,$FF,$00
	DB	$1F,$FF,$7F
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF
	DB	$B8,$77,$7E,$FC,$FE
	DB	$7F,$E7,$6F,$DE,$FF
	DB	$FE,$07,$F9,$FF,$3B
	DB	$3F,$3F,$FE,$DF
	DB	$FF,$FF,$EF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$03,$FE,$FF,$33,$A7
	DB	$FF,$9F,$FF,$EF
	DB	$FF,$FF,$FF,$FF,$FF
DRUMSAMPLE_2
	; bass drum
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$F3,$F8,$30,$FF,$DE
	DB	$00,$FF,$81
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF
	DB	$F4,$3B,$80
	DB	0,0,0,0,0
	DB	$3C
	DB	0,0,0,0
	DB	$1B
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$E0
	DB	0,0,0,0,0
	DB	0,0,0,0,0
	DB	0,0,0,0,0,0,0
	DB	$7F
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF,$FF,$FF
	DB	$FF,$FF,$FF
	DB	$FD,$7E,$03
	DB	0,0,0,0

;--- Init Data --------------------------------

LAB_36340
	DW	MUSMC27+1
	DB	91		; some tone correction
	DW	MUSMC29+1
	DB	18		; some tone correction
	DW	MUSMC30+1
	DB	77		; some tone correction
	DW	MUSMC28+1
	DB	0		; border color
	DW	L_8ADC
	DB	201
	DW	MUSMC13+1
	DB	201
	DW	L_8A48
	DB	201
	DW	L_8A6E
	DB	201
	DW	MUSMC16+1
	DB	0
	DW	L_87DE+1
	DB	0
	DW	MUSMC22+1
	DB	0
	DW	MUSMC21+1
	DB	0
	DW	L_8E44
	DB	2		; init.pos of portamento

;--- Music Data -------------------------------

L_8E1B	DB	0
L_8E1C	DB	0,0
L_8E1E	DB	0
L_8E1F	DB	0
L_8E20	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L_8E30	DB	0,0
L_8E32	DB	1, 19, 5, 5
	DB	1, 4, 2, 2, 255, 30
	DB	5, 5, 0, 19, 3, 3, 255
L_8E43	DB	0
L_8E44	DB	1
L_8E45	DB	1,0
L_8E47	DB	2
	DB	9, 1, 35, 2, 42, 2
	DB	80, 1, 42, 22, 115, 1
	DB	120, 253
L_8E56	DB	1, 0
	DB	4, 6, 1, 33, 1, 60
L_8E5E	DB	4, 6, 1, 33, 1, 60
	DB	4, 6, 1, 33, 1, 60
	DB	4, 87
	DB	2, 111, 3, 168, 4, 87
	DB	10, 204, 1, 238
L_8E76	DB	18,50,142
L_8E79	DB	255
	DB	50,147
L_8E7C	DB	252		; marker of drumset pointer
	DW	DRUM_PATTERNS
	DB	3, 28, 1
	DB	43, 14, 0
L_8E85	DB	4, 71, 4, 89, 26
	DB	110, 4, 133, 2, 165, 4
	DB	193, 2, 225
	DB	252		; marker of drumset pointer
	DW	DRMPAT2
L_8E96	DB	3, 32, 1, 64
	DB	254		; marker
	DW	L_8E96
L_8E9D	DB	4, 0, 2, 42, 1
	DB	26, 2, 7, 3, 5, 0	; leads...
	DB	70, 1, 25, 77, 1, 25
	DB	5, 4, 92, 1, 51, 5
	DB	0, 77, 1, 25, 4, 13
	DB	4, 0, 70, 1, 25, 3
	DB	4, 0, 2, 6, 1, 128
	DB	3, 4, 13, 77, 94, 77
	DB	70, 0, 77, 0, 95, 0
	DB	0, 103, 117, 103, 96, 103
	DB	116, 103, 116, 139, 0, 139
	DB	0, 153, 139, 0, 0, 139
	DB	117, 103, 96, 77, 73, 70
	DB	1, 31, 3, 4, 13, 77
	DB	94, 77, 70, 0, 77, 0
	DB	95, 0, 0, 103, 117, 103
	DB	96, 103, 117, 103, 117, 139
	DB	0, 139, 0, 153, 139, 0
	DB	0, 139, 117, 96, 103, 117
	DB	96, 3, 2, 6, 1, 16
	DB	3, 4, 26, 6
L_8F18	DB	70, 1, 67, 3
L_8F1C	DB	4, 1, 7, 2
	DB	7, 3, 255, 0, 255, 255
	DB	130, 255, 255, 146, 255, 130
	DB	110, 212, 255, 0, 255, 255
	DB	130, 255, 255, 146, 255, 255
	DB	130, 255, 212, 190, 3, 212
	DB	0, 212, 212, 110, 212, 212
	DB	123, 212, 110, 93, 179, 212
	DB	0, 212, 212, 110, 212, 212
	DB	123, 212, 212, 110, 212, 179
	DB	163, 3
L_8F58	DB	192, 0, 192, 192
	DB	99, 192, 192, 110, 192, 99
	DB	84, 161, 192, 0, 192, 192
	DB	99, 192, 192, 110, 192, 192
	DB	99, 192, 161, 146, 3, 2
	DB	6, 4, 1, 10, 255, 1
	DB	5, 255, 1, 7, 147, 131
	DB	255, 1, 5, 255, 1, 5
	DB	195, 175, 147, 131, 3, 4
	DB	1, 6, 212, 0, 212, 212
	DB	106, 119, 106, 212, 1, 2
	DB	212, 212, 106, 0, 119, 106
	DB	193, 0, 193, 193, 98, 109
	DB	98, 193, 1, 2, 193, 193
	DB	98, 0, 109, 98, 4, 1
	DB	12, 255, 1, 5, 255, 1
	DB	7, 147, 131, 255, 1, 5
	DB	255, 1, 5, 195, 175, 147
	DB	131, 3, 4, 1, 6, 212
	DB	0, 212, 212, 106, 119, 106
	DB	212, 1, 2, 212, 212, 106
	DB	0, 119, 106, 193, 0, 193
	DB	193, 98, 109, 98, 193, 1
	DB	2, 193, 193, 98, 0, 109
	DB	98, 3, 2, 6, 4, 1
	DB	9, 255, 0, 255, 255, 130
	DB	255, 0, 255, 1, 6, 146
	DB	130, 255, 0, 255, 255, 130
	DB	255, 0, 212, 0, 212, 110
	DB	212, 192, 192, 99, 192, 3
	DB	255, 1,	5, 3

DRUM_PATTERNS
	DB	7			; 1st byte is speed
	DB	66, 0, 0, 66, 67, 0
	DB	0, 66, 0, 66, 67, 0
	DB	66, 0, 0, 66, 67, 0
	DB	0, 66, 0, 66, 67, 66
	DB	67, 67, 1		; 1=ptn end

	DB	14
	DB	66, 0, 66, 0, 66, 0	; first drm ptn
	DB	66, 0, 66, 0, 66, 0	; (in song)
	DB	66, 1

	DB	7
	DB	66, 0, 0, 0, 66, 0
	DB	0, 0, 66, 0, 0, 0
	DB	66, 0, 0, 0, 66, 0
	DB	0, 0, 66, 0, 67, 67
	DB	67, 67, 1

	DB	6
	DB	76, 44, 44, 44, 76, 44
	DB	44, 44, 44, 76, 44, 44
	DB	76, 44, 44, 44, 1

	DB	6, 204, 66
	DB	44, 44, 44, 76, 44, 44
	DB	44, 44, 76, 44, 44, 76
	DB	172, 66, 44, 172, 66, 1

	DB	6, 172, 66, 44, 44, 44
	DB	172, 67, 44, 44, 44, 44
	DB	76, 44, 44, 172, 67, 172
	DB	66, 44, 172, 66, 1

	DB	6
	DB	194, 27, 172, 27, 172, 27
	DB	155, 66, 172, 67, 172, 11
	DB	44, 172, 11, 172, 11, 172
	DB	66, 172, 27, 194, 27, 172
	DB	67, 44, 172, 26, 172, 26
	DB	1

	DB	6
	DB	194, 27, 172, 27, 44, 139
	DB	66, 172, 67, 44, 44, 44
	DB	172, 27, 172, 27, 44, 194
	DB	44, 172, 67, 44, 172, 11
	DB	172, 11, 1

	DB	6
	DB	194, 27, 172, 27, 172, 11
	DB	155, 66, 172, 67, 172, 11
	DB	44, 172, 11, 172, 27, 172
	DB	27, 44, 194, 11, 172, 67
	DB	172, 11, 172, 26, 172, 11
	DB	1

DRMPAT2	DB	6, 194, 11, 172, 11
	DB	172, 11, 194, 44, 172, 67
	DB	44, 139, 44, 172, 11, 172
	DB	11, 172, 66, 172, 27, 194
	DB	27, 172, 67, 44, 172, 67
	DB	172, 67, 1

	DB	6, 194, 51
	DB	172, 51, 172, 35, 163, 66
	DB	172, 67, 172, 27, 44, 172
	DB	27, 172, 11, 172, 66, 172
	DB	11, 194, 11, 172, 67, 44
	DB	172, 34, 172, 34, 1

	DB	6
	DB	194, 67, 172, 27, 172, 67
	DB	155, 66, 172, 67, 172, 11
	DB	172, 67, 172, 11, 172, 67
	DB	194, 67, 172, 67, 194, 67
	DB	172, 67, 172, 67, 172, 67
	DB	172, 67, 172, 67, 0, 0
	DB	0, 0, 0, 0, 0, 1

L_915A
	DB	1, 19, 5, 1, 4, 2	; leads...
	DB	255, 30, 5, 0, 19, 3
	DB	255, 7, 7, 5, 255, 0
	DB	0, 0, 0, 0, 0, 0
	DB	0, 0, 1, 22, 25, 1
	DB	0,0,0,0,0,0,0,0,0
L_9181
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0

;-----------------------------
