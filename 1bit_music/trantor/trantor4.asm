; Trantor beeper engine
; disassembled by Oleg Origin
;
;
;   FOR REAL VZ300.
;
;   Vector Table at A500
;   IVT at A600
;   



	ORG	$8000

STARTFORSNA

;	LD	BC,0
;	CALL	7997	;pause

	; установка прерываний
	; interrupt setup
	DI
	LD	A,$C3		; установка перехода
				; installation of transition
	LD	($a6FE),A	
	LD	HL,TR_IRQ	; на процедуру прерывний
				; on interrupt procedure
	LD	($a6FF),HL

	LD	HL,$a500 ; $FD00
	LD	B,0
	LD	C,   $a6 ;  $FE
IMLOOP1	LD	(HL),C
	INC	HL
	DJNZ	IMLOOP1
	LD	(HL),C
	LD	A,    $a5 ; $FD
	LD	I,A
	IM	2
	EI

	CALL	TR_MUSX
	RET

;--------------------------------------------------------------

TR_MUS
	LD	(L_C68C),A
TR_MUSX
	DI
	CALL	SETSTART
	LD	A,(HL)
	LD	(L_C516),A
	LD	(L_C526),A
	LD	(L_C5D7),A
	INC	HL

	LD	(RESTSP1+1),SP
	LD	SP,HL
	POP	HL
	LD	(L_C623+1),HL
	POP	HL
	LD	(L_C641+1),HL
	POP	HL
	LD	(L_C661+1),HL
RESTSP1	LD	SP,$0000

	LD	A,$00
L_C3C8	EQU	$-1
	LD	(L_C449),A
	LD	(L_C498),A
	LD	(L_C580),A
	LD	(L_C59C),A
	LD	(L_C590),A
	LD	(L_C440),A
	LD	(L_C48F),A
	; в оригинале установка адреса
	; процедуры прерываний была здесь
	;
	; the original address setting
	; interrupt procedures were here
	CALL	L_C623
	CALL	L_C641
	CALL	L_C661
	LD	C,$01
	EXX
	EI
	LD	BC,$0101
	HALT
L_C3FA	CALL	C,L_C5F0
	LD	A,B
	AND	A
	JR	NZ,L_C430
L_C401	LD	HL,$0001
L_C402	EQU	$-2
L_C404	LD	A,(HL)
	OR	A
	JP	M,L_C4D1
	CALL	L_C687
	LD	(L_C439),A
	LD	D,A
	RRCA
	RRCA
	RRCA
	AND	$1F
	LD	(L_C444),A
	XOR	A
	LD	(L_C5F1),A
	INC	A
	LD	(L_C43B),A
	LD	A,(L_C440)
	OR	$18
	LD	(L_C440),A
	INC	HL
L_C429	LD	(L_C402),HL
	LD	B,$01
L_C42D	EQU	$-1
	JR	L_C435

L_C430	LD	A,$03
L_C432	DEC	A
	JR	NZ,L_C432
L_C435	DEC	D
	JR	NZ,L_C44C
	LD	D,$00
L_C439	EQU	$-1
	LD	A,$01
L_C43B	EQU	$-1
L_C43C	DEC	A
	JR	NZ,L_C43C
	LD	A,33
L_C440	EQU	$-1


	LD	A,32
	ld	($6800), A

	LD	A,$00
L_C444	EQU	$-1
L_C445	DEC	A
	JR	NZ,L_C445
	LD	A,32 ;$02
L_C449	EQU	$-1

	ld	($6800), A


L_C44C	LD	A,C
	AND	A
	JR	NZ,L_C47E
L_C450	LD	HL,$0001
L_C451	EQU	$-2
L_C453	LD	A,(HL)
	OR	A
	JP	M,L_C4B9
	CALL	L_C687
	LD	(L_C488),A
	LD	E,A
	RRCA
	RRCA
	AND	$3F
	LD	(L_C493),A
	XOR	A
	LD	(L_C60A),A
	INC	A
	LD	(L_C48A),A
	LD	A,(L_C48F)
	OR	$18
	LD	(L_C48F),A
	INC	HL
L_C477	LD	(L_C451),HL
	LD	C,$01
L_C47B	EQU	$-1
	JR	L_C483

L_C47E	LD	A,$03
L_C480	DEC	A
	JR	NZ,L_C480
L_C483	DEC	E
	JP	NZ,L_C3FA
	LD	E,$00
L_C488	EQU	$-1
	LD	A,$01
L_C48A	EQU	$-1
L_C48B	DEC	A
	JR	NZ,L_C48B
	LD	A,32
L_C48F	EQU	$-1

	LD	A,32
	ld	($6800), A


	LD	A,$00
L_C493	EQU	$-1
L_C494	DEC	A
	JR	NZ,L_C494
	LD	A,0;$01
L_C498	EQU	$-1

	ld	($6800), A


	JP	L_C3FA

TR_IRQ	PUSH	AF
	PUSH	HL
	PUSH	DE
	DEC	C
	DEC	B
	EXX
	DEC	C
	CALL	Z,TR_DRUM	; ударные
				; drums

;---------------------------------------
;	LD	(TRSMC1+1),BC
;	в оригинале здесь вызов меню
;	here in the original call to menu
;TRSMC1	LD	BC,$0000
;---------------------------------------

	EXX
	POP	DE
	POP	HL
	POP	AF
	SCF
	EI
	RET

L_C4B9	INC	HL
	PUSH	HL
	AND	$7F
	CALL	L_C5E6
	JP	L_C533
	JP	L_C4FB
	JP	L_C4E9
	JP	L_C523
	JP	L_C54A
	POP	HL
	RET

L_C4D1	INC	HL
	PUSH	HL
	AND	$7F
	CALL	L_C5E6
	JP	L_C53A
	JP	L_C507
	JP	L_C4F2
	JP	L_C513
	JP	L_C541
	POP	HL
	RET

L_C4E9	POP	HL
	LD	A,(HL)
	LD	(L_C610),A
	INC	HL
	JP	L_C453

L_C4F2	POP	HL
	LD	A,(HL)
	LD	(L_C5F8),A
	INC	HL
	JP	L_C404

L_C4FB	POP	HL
	LD	A,(L_C48F)
	AND	$07
	LD	(L_C48F),A
	JP	L_C477

L_C507	POP	HL
	LD	A,(L_C440)
	AND	$07
	LD	(L_C440),A
	JP	L_C429

L_C513	POP	HL
	PUSH	BC
	LD	B,$01
L_C516	EQU	$-1
	XOR	A
L_C518	ADD	A,(HL)
	DJNZ	L_C518
	LD	(L_C42D),A
	INC	HL
	POP	BC
	JP	L_C404

L_C523	POP	HL
	PUSH	BC
	LD	B,$01
L_C526	EQU	$-1
	XOR	A
L_C528	ADD	A,(HL)
	DJNZ	L_C528
	LD	(L_C47B),A
	INC	HL
	POP	BC
	JP	L_C453

L_C533	POP	HL
	CALL	L_C641
	JP	L_C450

L_C53A	POP	HL
	CALL	L_C623
	JP	L_C401

L_C541	POP	HL
	LD	A,(HL)
	INC	HL
	LD	(L_C68C),A
	JP	L_C404

L_C54A	POP	HL
	LD	A,(HL)
	INC	HL
	LD	(L_C68C),A
	JP	L_C453

;------------Drumset-------------------

TR_DRUM	LD	C,$01		; (SMC)
L_C555	LD	HL,$0001			; DJM
L_C556	EQU	$-2
	LD	A,(HL)
	INC	HL
	LD	(L_C556),HL
	AND	$7F
	CALL	L_C5E6
	JP	L_C5A6
	RET

	NOP
	NOP
	JP	L_C596
	JP	L_C5D3
	JP	L_C57A
	RET

	NOP
	NOP
	JP	L_C587
	JP	L_C5AB
L_C57A	LD	B,$80
L_C57C	LD	A,(HL)
	AND	33
	OR	$00
L_C580	EQU	$-1

	ld	($6800), A


	DEC	L
	DJNZ	L_C57C
	RET

L_C587	LD	HL,$005C
L_C58A	LD	A,(HL)
	OR	A
	RET	Z
	AND	33
	OR	$00
L_C590	EQU	$-1

	ld	($6800), A


	INC	HL
	JR	L_C58A

L_C596	LD	B,$20
L_C598	LD	A,(HL)
	AND	33
	OR	$00
L_C59C	EQU	$-1

	ld	($6800), A


L_C59F	DEC	A
	JR	NZ,L_C59F
	DEC	L
	DJNZ	L_C598
	RET

L_C5A6	CALL	L_C661
	JR	L_C555

L_C5AB	LD	HL,(L_C556)
	LD	A,(HL)
	INC	HL
	LD	(L_C556),HL
	LD	B,$1E
	LD	L,A
	RRCA
	LD	H,A
L_C5B8	LD	A,(L_C3C8)

	ld	($6800), A


	DEC	L
	LD	A,L
L_C5BF	DEC	A
	JR	NZ,L_C5BF
	LD	A,(L_C3C8)
	OR	32

	ld	($6800), A


	LD	A,$04
	ADD	A,H
	LD	H,A
L_C5CD	DEC	A
	JR	NZ,L_C5CD
	DJNZ	L_C5B8
	RET

L_C5D3	LD	HL,(L_C556)
	LD	B,$01
L_C5D7	EQU	$-1
	XOR	A
L_C5D9	ADD	A,(HL)
	DJNZ	L_C5D9
	LD	(TR_DRUM+1),A
	INC	HL
	LD	(L_C556),HL
	JP	TR_DRUM

L_C5E6	LD	L,A
	ADD	A,A
	ADD	A,L
	POP	HL
	ADD	A,L
	LD	L,A
	JR	NC,L_C5EF
	INC	H
L_C5EF	JP	(HL)
;
L_C5F0	LD	A,$00
L_C5F1	EQU	$-1
	INC	A
	LD	(L_C5F1),A
	PUSH	HL
	CP	$02
L_C5F8	EQU	$-1
	JR	C,L_C609
	XOR	A
	LD	(L_C5F1),A
	LD	HL,L_C444
	DEC	(HL)
	JR	Z,L_C608
	LD	HL,L_C43B
L_C608	INC	(HL)
L_C609	LD	A,$00
L_C60A	EQU	$-1
	INC	A
	LD	(L_C60A),A
	CP	$04
L_C610	EQU	$-1
	JR	C,L_C621
	XOR	A
	LD	(L_C60A),A
	LD	HL,L_C493
	DEC	(HL)
	JR	Z,L_C620
	LD	HL,L_C48A
L_C620	INC	(HL)
L_C621	POP	HL
	RET

L_C623	LD	HL,0		; (SMC) chan 1 pat addr
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(L_C623+1),HL
	LD	(L_C402),DE
	LD	A,D		; конец паттернов для канала?
				; the end of the pattern for the channel?
	OR	E
	RET	NZ
	CALL	SETSTART	; переход на начало трека
				; the transition to the beginning of the track
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(L_C623+1),DE
	JR	L_C623

L_C641	LD	HL,0		; (SMC) chan 1 pat addr
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(L_C641+1),HL
	LD	(L_C451),DE
	LD	A,D		; конец паттернов для канала?
				; the end of the pattern for the channel?
	OR	E
	RET	NZ
	CALL	SETSTART	; переход на начало трека
				; the transition to the beginning of the track
	INC	HL
	INC	HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(L_C641+1),DE
	JR	L_C641

L_C661	LD	HL,0		; (SMC) drm chan pat addr
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(L_C661+1),HL
	LD	(L_C556),DE
	LD	A,D		; конец паттернов для канала?
				; the end of the pattern for the channel?
	OR	E
	RET	NZ
	CALL	SETSTART	; переход на начало трека
				; the transition to the beginning of the track
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(L_C661+1),DE
	JR	L_C661

SETSTART
	LD	HL,TR_DATA_START
	RET

L_C687	PUSH	HL
	LD	HL,TR_NOTETABLE
	ADD	A,$00
L_C68C	EQU	$-1
	ADD	A,L
	LD	L,A
	JR	NC,L_C692
	INC	H
L_C692	LD	A,(HL)
	POP	HL
	RET

;--------------------------------------------------

TR_NOTETABLE

	DB	$EE, $E1, $D4, $C8, $BD, $B2, $A8, $9F
        DB	$96, $8E, $86, $7E, $77, $70, $6A, $64
        DB	$5E, $59, $54, $4F, $4B, $47, $43, $3F
	DB	$3B, $38, $35, $32, $2F, $2C, $2A, $27
	DB	$25, $23, $21, $1F, $1D, $1C, $1A, $19
	DB	$17, $16, $15, $13, $12, $11, $10, $0F
	DB	$0E, $0E, $0D, $0C, $0B, $0B, $0A, $09
	DB	$09, $08, $08, $07

TR_DATA_START

	DB	3	; tempo (actual 3)
	DW	CH1PAT	; addr of channel 1 pattern list
	DW	CH2PAT	; addr of channel 2 pattern list
	DW	CHDPAT	; addr of drum pattern list

CH1PAT	DW P_C7F8, P_CA95, P_C801, P_C801
	DW P_C830, P_C830, P_C801, P_C801
	DW P_C830, P_C830, P_C801, P_C801
	DW P_C830, P_C830, P_C801, P_C801
	DW P_C830, P_C830, P_C85F, P_C85F
	DW P_C884, P_C884, P_C85F, P_C85F
	DW P_C884, P_C884, P_CA9C, P_C85F
	DW P_C85F, P_C884, P_C884, P_C85F
	DW P_C85F, P_C884, P_C884, P_CA99
	DW P_C85F, P_C85F, P_C884, P_C884
	DW P_C85F, P_C85F, P_C884, P_C884
	DW P_CA9C, P_C884, P_C884, P_C8A9
	DW P_C8A9, P_C884, P_C884, P_C8A9
	DW P_C8A9, P_C884, P_C884, P_C8A9
	DW P_C8A9, P_C884, P_C884, P_C8A9
	DW P_C8A9

	DW $0000	; end of patterns for channel 1


CH2PAT	DW P_C8CE, P_C8CE, P_C913, P_C913
	DW P_CA95, P_C954, P_C954, P_C990
	DW P_C990, P_C990, P_C990, P_CA9C
	DW P_C990, P_C990, P_C990, P_C990
	DW P_CA99, P_C9C9, P_C9C9, P_CA9C
	DW P_CA4E, P_CA99

	DW $0000	; end of patterns for channel 2

CHDPAT	DW P_CA8E, P_CA95, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT, DRMPAT, DRMPAT
	DW DRMPAT, DRMPAT

	DW $0000	; end of patterns for drum channel

;--------------------------------------------------
; Patterns Data
; 0..59 = Note
; 128 = End of Pattern
; 129 = Note Off
; 130 = Set Volume Fading
; 131 = Set Note Length
; 132 = Set Global Tone Shift
;--------------------------------------------------

P_C7F8	DB 130, 6, 131, 64, 9, 9, 9, 9
	DB 128

P_C801	DB 130, 1, 131, 2, 9, 131, 1
	DB 24, 129, 28, 129, 24, 129, 131, 2
	DB 9, 131, 1, 24, 129, 28, 129, 24
	DB 129, 131, 2, 9, 131, 1, 24, 129
	DB 28, 129, 24, 129, 131, 2, 19, 131
	DB 1, 24, 129, 28, 129, 24, 129, 128

P_C830	DB 130, 1, 131, 2, 0, 131, 1, 28
	DB 129, 31, 129, 28, 129, 131, 2, 0
	DB 131, 1, 28, 129, 31, 129, 28, 129
	DB 131, 2, 0, 131, 1, 28, 129, 31
	DB 129, 28, 129, 131, 2, 23, 131, 1
	DB 28, 129, 31, 129, 28, 129, 128
	
P_C85F	DB 130
	DB 1, 131, 1, 9, 129, 9, 129, 9
	DB 129, 9, 129, 9, 129, 9, 129, 9
	DB 129, 9, 129, 9, 129, 9, 129, 9
	DB 129, 9, 129, 9, 129, 9, 129, 9
	DB 129, 7, 129, 128

P_C884	DB 130, 1, 131, 1
	DB 0, 129, 0, 129, 0, 129, 0, 129
	DB 0, 129, 0, 129, 0, 129, 0, 129
	DB 0, 129, 0, 129, 0, 129, 0, 129
	DB 0, 129, 0, 129, 0, 129, 11, 129
	DB 128

P_C8A9	DB 130, 1, 131, 1, 5, 129, 5
	DB 129, 5, 129, 5, 129, 5, 129, 5
	DB 129, 5, 129, 5, 129, 5, 129, 5
	DB 129, 5, 129, 5, 129, 5, 129, 5
	DB 129, 5, 129, 4, 129, 128

P_C8CE	DB 130, 1, 131, 1
	DB 24, 129, 24, 129, 21, 129
	DB 21, 129, 16, 129, 16, 129, 24, 129
	DB 24, 129, 21, 129, 21, 129, 16, 129
	DB 16, 129, 23, 129, 23, 129, 19, 129
	DB 19, 129, 14, 129, 14, 129, 23, 129
	DB 23, 129, 19, 129, 19, 129, 14, 129
	DB 14, 129, 21, 129, 21, 129, 17, 129
	DB 17, 129, 12, 129, 12, 129, 17, 129
	DB 17, 129, 128

P_C913	DB 12, 129, 12, 129, 9
	DB 129, 9, 129, 4, 129, 4, 129, 12
	DB 129, 12, 129, 9, 129, 9, 129, 4
	DB 129, 4, 129, 11, 129, 11, 129, 7
	DB 129, 7, 129, 2, 129, 2, 129, 11
	DB 129, 11, 129, 7, 129, 7, 129, 2
	DB 129, 2, 129, 9, 129, 9, 129, 5
	DB 129, 5, 129, 0, 129, 0, 129, 5
	DB 129, 5, 129, 128

P_C954	DB 130, 2, 131, 28
	DB 4, 131, 4, 7, 131, 28, 9, 131
	DB 4, 11, 131, 26, 12, 131, 1, 13
	DB 14, 15, 16, 17, 18, 131, 32, 19
	DB 130, 3, 131, 28, 24, 131, 4, 23
	DB 131, 28, 19, 131, 4, 21, 131, 52
	DB 16, 131, 1, 15, 14, 13, 12, 11
	DB 10, 9, 8, 7, 6, 5, 4, 128

P_C990	DB 130, 1, 131, 11, 16, 131, 1, 129
	DB 131, 7, 9, 131, 1, 129, 131, 3
	DB 9, 131, 1, 129, 131, 11, 16, 131
	DB 1, 129, 131, 7, 9, 131, 1, 129
	DB 131, 7, 9, 131, 1, 129, 131, 3
	DB 9, 131, 1, 129, 131, 3, 12, 131
	DB 1, 129, 131, 3, 14, 131, 1, 129
	DB 128

P_C9C9	DB 130, 1, 131, 1, 21, 129, 21
	DB 129, 21, 129, 21, 129, 21, 129, 21
	DB 129, 19, 129, 19, 129, 19, 129, 19
	DB 129, 19, 129, 19, 129, 21, 129, 21
	DB 129, 21, 129, 21, 129, 21, 129, 21
	DB 129, 19, 129, 19, 129, 19, 129, 19
	DB 129, 21, 129, 21, 129, 21, 129, 21
	DB 129, 19, 129, 19, 129, 21, 129, 21
	DB 129, 22, 129, 22, 129, 21, 129, 21
	DB 129, 21, 129, 21, 129, 21, 129, 21
	DB 129, 19, 129, 19, 129, 19, 129, 19
	DB 129, 19, 129, 19, 129, 21, 129, 21
	DB 129, 21, 129, 21, 129, 21, 129, 21
	DB 129, 19, 129, 19, 129, 19, 129, 19
	DB 129, 21, 129, 21, 129, 21, 129, 21
	DB 129, 19, 129, 19, 129, 21, 129, 21
	DB 129, 22, 129, 22, 129, 128

P_CA4E	DB 130, 5
	DB 131, 60, 19, 131, 4, 20, 131, 60
	DB 21, 131, 4, 20, 131, 60, 19, 131
	DB 4, 20, 131, 60, 21, 131, 4, 20
	DB 131, 60, 19, 131, 4, 18, 131, 60
	DB 17, 131, 4, 18, 131, 60, 19, 131
	DB 4, 18, 131, 60, 17, 131, 4, 18
	DB 128

;-------Drum Pattern Data-----------

DRMPAT	DB 131, 4, 135, 30, 130, 134
	DB 135, 30, 130, 134, 130, 134
	DB 128

;-------Special Patterns------------

P_CA8E	DB 131, 64, 129, 129	; Empty Patterns
	DB 129, 129, 128	; (used for drums begin)
P_CA95	DB 131, 8, 129, 128	; Short Empty (for pause)
P_CA99	DB 132, 0, 128		; Set Tone Shift = 0
P_CA9C	DB 132, 1, 128		; Set Tone Shift + 1


