
XDEF _s64
_s64:



STARTICUS:
		di
		push	af
		ex	af, af'
		push	af
		push	bc
		push	de
		push	hl
		exx
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		ld	hl, VECTOR_TABLE_LOC  
		ld	a, h
		ld	i, a
		im	2

		dec	a
		ld	l, a
		ld	h, a
		ld	(hl), $C9	; RET

		ld	hl, VECTOR_TABLE_LOC
b000:		ld	(hl), a
		inc	l
		jr	nz, b000
		inc	h
		ld	(hl), a

		call	INIT_MUSIC
		call	PLAY_MUSIC
		im	1
		pop	iy		; this may be a slightly more reliable option (HL' is saved internally)
		pop	ix
		pop	hl
		pop	de
		pop	bc
		exx
		pop	hl
		pop	de
		pop	bc
		pop	af
		ex	af, af'
		pop	af
		ei
		ret


INIT_MUSIC:   LD    HL,SONG_INITDATA_0
              LD    IX,CHAN_0_DATA
              LD    BC,$11              ; Length of channel data
LE4BB:
              LD    A,(HL)
              LD    (IX + CHAN_ENDPOS),A
              INC   HL
              LD    A,(HL)
              LD    (IX + CHAN_SONGLOOPPOS),A
              INC   HL
              LD    E,(HL)
              INC   HL
              LD    D,(HL)
              INC   HL
              LD    (IX + CHAN_NOTE_LEN_REMAIN),1
              LD    (IX + CHAN_TRANSPOSE),B
              LD    (IX + CHAN_SKEW_XORING),B
              LD    (IX + CHAN_ORN_BASE),B
              LD    (IX + CHAN_CURPOS),B
              LD    (IX + CHAN_PATT_TBL_ADR),E
              LD    (IX + CHAN_PATT_TBL_ADR + 1),D
              LD    A,(DE)
              LD    (IX + CHAN_DATA),A
              INC   DE                  ; relocatable
              LD    A,(DE)
              LD    (IX + 1),A
              BIT   7,(IX + CHAN_NOTE_LEN_TOTAL)
              ADD   IX,BC
              JR    Z,LE4BB

              LD    E,(HL)
              INC   HL
              LD    D,(HL)
              INC   HL
              LD    (LD_HL_ORNOFF + 1),DE
              LD    E,(HL)
              INC   HL
              LD    D,(HL)
              INC   HL
              LD    (LD_HL_ORNDAT + 1),DE

              LD    A,$FF
              LD    (CONT_FLAG + 1),A
              RET

; Reserve 17 bytes for our Channel 0 (tone) status structure
CHAN_0_DATA:  DEFW  $0000	; Pattern pointer (CHAN_DATA)
              DEFW  $0000       ; Pattern Table Address (CHAN_PATT_TBL_ADR)
              DEFB  $00,$00,$00 ; CHAN_CURPOS, CHAN_ENDPOS, CHAN_SONGLOOPPOS
              DEFB  $00         ; CHAN_TRANSPOSE
              DEFB  $00,$00     ; CHAN_NOTE_LEN_REMAIN, CHAN_NOTE_LEN_TOTAL
              DEFB  $00         ; CHAN_GENFX
              DEFB  $00         ; CHAN_SKEW_PARAM
              DEFB  $10         ; Channel on
              DEFB  $00         ; CHAN_ORN_BASE
              DEFB  $00         ; CHAN_ORN_COUNT
              DEFB  $00         ; Note
              DEFB  $00         ; CHAN_SKEW_XORING

; Reserve 17 bytes for our Channel 1 (tone) status structure
CHAN_1_DATA:  DEFW  $0000	; Pattern pointer (CHAN_DATA)
              DEFW  $0000       ; Pattern Table Address (CHAN_PATT_TBL_ADR)
              DEFB  $00,$00,$00 ; CHAN_CURPOS, CHAN_ENDPOS, CHAN_SONGLOOPPOS
              DEFB  $00         ; CHAN_TRANSPOSE
              DEFB  $00,$00     ; CHAN_NOTE_LEN_REMAIN, CHAN_NOTE_LEN_TOTAL
              DEFB  $00         ; CHAN_GENFX
              DEFB  $00         ; CHAN_SKEW_PARAM
              DEFB  $10         ; Channel on
              DEFB  $00         ; CHAN_ORN_BASE
              DEFB  $00         ; CHAN_ORN_COUNT
              DEFB  $00         ; Note
              DEFB  $00         ; CHAN_SKEW_XORING

; Reserve bytes for percussion channel status
PATDRUM_PTR:      DEFW  $0000       ; Percussion pattern pointer
LISTDRUM_AD:      DEFW  $0000       ; Percussion pattern table address
CURPOS_DRUM:      DEFW  $0000
DRUM_SONGLOOPPOS: DEFB  $00
                  DEFB  $00
PATDRUM_CNT_QTS:  DEFB  $00
              DEFB  $FF
              DEFB  $00

CHAN_DATA:               EQU  0
CHAN_PATT_TBL_ADR:       EQU  2
CHAN_CURPOS:             EQU  4
CHAN_ENDPOS:             EQU  5
CHAN_SONGLOOPPOS:        EQU  6
CHAN_TRANSPOSE:          EQU  7
CHAN_NOTE_LEN_REMAIN:    EQU  8
CHAN_NOTE_LEN_TOTAL:     EQU  9
CHAN_GENFX:              EQU  10
CHAN_SKEW_PARAM:         EQU  11
CHAN_CHANNEL_ON:         EQU  12
CHAN_ORN_BASE:           EQU  13
CHAN_ORN_COUNT:          EQU  14
CHAN_NOTE:               EQU  15
CHAN_SKEW_XORING:        EQU  16

FREQ_TABLE:
              DEFW  $D8D8,$CC00,$00C0,$B6B5,$ACAB,$A2A1,$9998,$9090,$8888,$8180,$7979,$7372
              DEFW  $6C6C,$6666,$6060,$5B5A,$5655,$5151,$4D4C,$4848,$4444,$4040,$3D3C,$3939
              DEFW  $3636,$3333,$3030,$2E2D,$2B2B,$2928,$2626,$2424,$2222,$2020,$1F1E,$1D1C
              DEFW  $1B1B,$1A19,$1818,$1716,$1615,$1414,$1313,$1212,$1111,$1010,$0F0F,$0F0E
              DEFW  $0E0D,$0D0C,$0C0C,$0C0B,$0B0A,$0A0A,$0A09,$0909,$0908,$0808,$0807,$0707

PLAY_MUSIC:
CONT_FLAG:	ld	a, $FF
		or	a
		ret	z
		ld	a, i
		ld	h, a
		ld	a, (hl)
		ld	l, a
		ld	h, a
		ld	(hl), $C3
		inc	hl
		ld	(LE2AF+1), hl
		ld	(LE400+1), hl

              LD    (SAVE_SP+1),SP
              ; Set initial pattern tempo from CH0
              LD    HL,(CHAN_0_DATA)
              LD    A,(HL)                ; Pattern tempo
              INC   HL
              LD    (QNT_VAL_1 + 2),A
              LD    (QNT_VAL_2 + 2),A
              LD    (CHAN_0_DATA),HL

              ; Skip tempo byte in CH2
              LD    HL,(CHAN_1_DATA)
              INC   HL
              LD    (CHAN_1_DATA),HL

              JR    NEXTQUANT

ISR_2:
              DEC   IXL
              JR    Z,NEXTQUANT_CHK
              LD    SP,(SAVE_SP+1)
              PUSH  IX
              CALL  SETUP_GEN
              POP   IX
              JR    ISR2_END

NEXTQUANT_CHK:



loops2:	ld 	a, ($68ef)	; press <space> to continue
		and	$10
		jp 	z,  KEY_PRESSED

NEXTQUANT:
              CALL  PATSTEP_DRUMS
              LD    HL,CHAN_0_DATA + CHAN_NOTE_LEN_REMAIN
              DEC   (HL)
LE28B:        LD    IX,CHAN_0_DATA
              CALL  Z,PATTERN_STEP
              LD    HL,CHAN_1_DATA + CHAN_NOTE_LEN_REMAIN
              DEC   (HL)
SAVE_SP:      LD    SP,$0000
              LD    IX,CHAN_1_DATA
              CALL  Z,PATTERN_STEP
              LD    HL,CHAN_0_DATA + CHAN_ORN_BASE
LE2A3:        LD    A,(CHAN_1_DATA + CHAN_ORN_BASE)
              OR    (HL)
              LD    HL,ISR_1
              JR    Z,LE2AF
              LD    HL,ISR_2
LE2AF:        LD    (0),HL ;LD    (INTVEC_ADR),HL
              LD    A,(CHAN_0_DATA + CHAN_CHANNEL_ON)
		ld	iyl, a
              LD    A,(CHAN_1_DATA + CHAN_CHANNEL_ON)
		ld	iyh, a
              CALL  SETUP_GEN
QNT_VAL_1:	ld	ixl, 4

ISR2_END:     EI



; =====================================================================================================================
;
;  this version of the core has equal channel volumes and no discretization noise, yet it sounds somewhat unbalanced
;
;					default version			"slower" version
;  (*) discretization frequency:	3500000/128 ~ 27.3kHz		3500000/136 ~ 25.7kHz
;  (*) relative channel durations:	64 / 64				72 / 64
;  (*) relative channel volumes:	1:1				1:64/72 = 1:0.889
;
; =====================================================================================================================

PreMainLoop:	;out (254), a		; 11t
		ld ($6800), a

;
;  there are three paths through the first half of the new main loop:
;  (1) -> (2)		->	4+4+8 + 4+11+4+8+10 = 53t	(output changes)
;  (1) -> (3) -> (4)	->	4+4+13 + 4+7 + 5+4+12 = 53t	(output stays the same)
;  (1) -> (3) -> (5)	->	4+4+13 + 4+12 + 4+4+4+4 = 53t	(special fx for channel 1)
;

MainLoopPt1:	exx			; 4t			(1)
		ex	af, af'		; 4t
		djnz	ContChannel1	; 13t/8t

		ex	de, hl		; 4t			(2)
		add	hl, bc		; 11t
		ld	b, h		; 4t
		xor	iyl		; 8t
		jp	MainLoopPt2	; 10t

ContChannel1:	rlca			; 4t			(3)
		jr	c, FXChannel1	; 12t/7t

		ret	c		; 5t (wasted tacts)	(4)
		rrca			; 4t
		jr	MainLoopPt2	; 12t

FXChannel1:	ccf			; 4t			(5)
		rra			; 4t
		ld	h, l		; 4t
		ld	l, b		; 4t

;
;  there are also three paths through the second half of the loop:
;  (6) -> (7)		->	(11+4+4+8 + 4+11+4+8+10) + 11 = 75t / 64t	(output changes)
;  (6) -> (8) -> (10)	->	(11+4+4+13 + 4+4+12 + 12) + 11 = 75t / 64t	(output stays the same)
;  (6) -> (8) -> (9)	->	11+4+4+13 + 4+4+7 + 6+12+10 = 75t		(special fx for channel 2)
;

MainLoopPt2:	
		ld ($6800), a
;		out	(254), a	;			(6)
		exx
		ex	af, af'
		djnz	ContChannel2

		ex	de, hl		;			(7)
		add	hl, bc
		ld	b, h
		xor	iyh
		jp	PreMainLoop

ContChannel2:	rlca			;			(8)
		rrca
		jr	nc, NoFXChannel2

		dec	hl		;			(9)
		jr	c000
c000:		jp	MainLoopPt1

NoFXChannel2:	jr	PreMainLoop	;			(10)


; =====================================================================================================================
;
;  interrupt handler is also modified to run a bit faster
;

ISR_1:		dec	ixl
		ei
		ret	nz

		push	af
		push	hl

		xor	a
		in	a, (254)
		cpl
		and	31
		jp	nz, KEY_PRESSED

		ld	hl, PATDRUM_CNT_QTS
		dec	(hl)
		call	z, PATSTEP_DRUMBEAT

		ld	hl, CHAN_0_DATA + CHAN_NOTE_LEN_REMAIN
		dec	(hl)
		jp	z, LE28B

		ld	hl, CHAN_1_DATA + CHAN_NOTE_LEN_REMAIN
		dec	(hl)
		jp	z, SAVE_SP

QNT_VAL_2:	ld	ixl, 4		

		pop	hl
		pop	af
ISR_0:		ei
		ret


TBL_FUNC_OFFSETS:
		defb	FUNC_80_REST-$		; Func $80 - Rest
		defb	FUNC_81_GLIS-$		; Func $81 - Glissando
		defb	FUNC_82_PATTERN_END-$	; Func $82 - End of pattern
		defb	FUNC_83_SONG_END-$	; Func $83 - End of song
		defb	FUNC_84_TRANSPOSE-$	; Func $84 - Set transpose
		defb	FUNC_85_SKEW-$		; Func $85 - Set Skew
		defb	FUNC_86_GENFX-$		; Func $86 - GenFX
		defb	FUNC_87_SKEW_XOR-$	; Func $87 - Set Skew XOR


FUNC_83_SONG_END:
              SUB   A
              LD    (CONT_FLAG + 1),A
KEY_PRESSED:
              LD    SP,(SAVE_SP + 1)
		ret


FUNC_82_PATTERN_END:
              LD    A,(IX + CHAN_CURPOS)  ; Get current position within song
              ADD   A,2
              CP    (IX + CHAN_ENDPOS)    ; Are we at the end of the song
              JR    NZ,LE352
              LD    A,(IX + CHAN_SONGLOOPPOS) ; Yes - Jump back to the loop start
LE352:        LD    (IX + CHAN_CURPOS),A
              LD    L,(IX + CHAN_PATT_TBL_ADR)
              LD    H,(IX + CHAN_PATT_TBL_ADR + 1)
              LD    C,A
              ADD   HL,BC
              LD    E,(HL)
              INC   HL                    ; relocatable
              LD    D,(HL)
              ; DE = address of next pattern
              LD    A,(DE)
              LD    (QNT_VAL_1 + 2),A
              LD    (QNT_VAL_2 + 2),A
              INC   DE
              JR    PATSTEP_LOOP

FUNC_86_GENFX:
              LD    (IX + CHAN_CHANNEL_ON),$21	;$90
              JR    PATSTEP_LOOP

FUNC_85_SKEW:
              LD    A,(DE)
              INC   DE
              LD    (IX + CHAN_SKEW_PARAM),A
              JR    PATSTEP_LOOP

FUNC_87_SKEW_XOR:
              LD    A,(DE)
              INC   DE
              LD    (IX + CHAN_SKEW_XORING),A
              JR    PATSTEP_LOOP

FUNC_84_TRANSPOSE:
              LD    A,(DE)
              INC   DE
              LD    (IX + CHAN_TRANSPOSE),A
              JR    PATSTEP_LOOP

FUNC_81_GLIS:
              LD    A,(DE)
              INC   DE
              LD    (IX + CHAN_GENFX),A
              JR    PATSTEP_LOOP

; *****************************************************************************
; * PATTERN_STEP
; *
; * Read the next value (a note, an effect, a note_len cmd, or an arpeggio)
; * from the pattern
; *****************************************************************************
PATTERN_STEP:
              LD    B,0
              LD    (IX + CHAN_GENFX),B
              LD    (IX + CHAN_CHANNEL_ON),$21	;$10
              LD    E,(IX + CHAN_DATA)
              LD    D,(IX + CHAN_DATA + 1)
PATSTEP_LOOP:
              LD    A,(DE)
              INC   DE
              CP    $C0
              JR    C,PLAY_NOTE    ; Is less than $C0 (note or effect)
              ADD   A,$20
              JR    C,SET_NOTELEN  ; Is E0 to FF (set note length)
              ADD   A,$20          ; Else is an arpeggio (C0 - DF)
              LD    C,A
LD_HL_ORNOFF: LD    HL,ORN_OFFSETS
              ADD   HL,BC
              LD    A,(HL)
              LD    (IX + CHAN_ORN_BASE),A
              JR    PATSTEP_LOOP

; *****************************************************************************
; * SET_NOTELEN
; *
; * Set the length of all following notes in the channel
; *****************************************************************************
SET_NOTELEN:  INC   A
              LD    (IX + CHAN_NOTE_LEN_TOTAL),A
              JR    PATSTEP_LOOP

PLAY_NOTE:
              OR    A
              JP    P,SIMPLE_NOTE                ; Value $00 - $7F are notes
              LD    C,A                          ; $80 - $BF are effects
              LD    HL,TBL_FUNC_OFFSETS - $80
              ADD   HL,BC
              LD    C,(HL)
              ADD   HL,BC
              JP    (HL)                         ; execute effect function

FUNC_80_REST:                                    ; On entry B=0
              LD    (IX + CHAN_CHANNEL_ON),B     ; Silence this channel

SIMPLE_NOTE:  LD    (IX + CHAN_NOTE),A
              LD    (IX + CHAN_ORN_COUNT),B      ; B = 0
              LD    A,(IX + CHAN_NOTE_LEN_TOTAL)
              LD    (IX + CHAN_NOTE_LEN_REMAIN),A
              LD    (IX + CHAN_DATA + 1),D
              LD    (IX + CHAN_DATA),E
              RET

SETUP_GEN:
              LD    IX,CHAN_0_DATA
              CALL  SETUP_GEN_CHAN
              EXX
              EX    AF,AF'
              LD    IX,CHAN_1_DATA
SETUP_GEN_CHAN:
              LD     A,(IX + CHAN_SKEW_PARAM)
              XOR    (IX + CHAN_SKEW_XORING)
              LD     (IX + CHAN_SKEW_PARAM),A    ; Store the xored value
              SUB    A
              LD     D,A
              LD     E,(IX + CHAN_ORN_BASE)
LD_HL_ORNDAT: LD     HL,ORNAMENTS_DATA
              ADD    HL,DE
              LD     E,(IX + CHAN_ORN_COUNT)
              ADD    HL,DE
              LD     A,(HL)
              OR     A
              JP     P, LE40A                    ; 00-7F = note offset
              INC    A
              JR     NZ,LE405                    ; 80-FE = note offset + reset
              LD     HL,ISR_1                    ; FF - end ornament, no need for ISR2
LE400:        LD     (0),HL ;LD     (INTVEC_ADR),HL
              JR     LE40E
LE405:        DEC    A
              AND    $7F
              LD     E,$FF                       ; Restart ornament
LE40A:        INC    E
              LD     (IX + CHAN_ORN_COUNT),E     ; Incremement the ornament counter
LE40E:        LD     H,D                         ; d = 0
              ADD    A,(IX + CHAN_NOTE)
              ADD    A,(IX + CHAN_TRANSPOSE)
              ADD    A,A
              LD     HL,FREQ_TABLE
              LD     E,A
              ADD    HL,DE
              LD     E,(HL)                      ; NoteFrq1 into E
              INC    HL
              LD     C,(HL)                      ; NoteFrq2 into C
              LD     A,(IX + CHAN_SKEW_PARAM)
              OR     A
              LD     L,D                         ; d=0
              JR     Z,NO_SKEW

              ADD    A,A
              LD     H,A
              JR     NC,LE42A
              ADD    HL,DE
LE42A:
              ADD    HL,HL
              JR     NC,LE42E
              ADD    HL,DE
LE42E:
              ADD    HL,HL
              JR     NC,LE432
              ADD    HL,DE
LE432:
              ADD    HL,HL
              JR     NC,LE436
              ADD    HL,DE
LE436:
              ADD    HL,HL
              JR     NC,LE43A
              ADD    HL,DE
LE43A:
              ADD    HL,HL
              JR     NC,LE43E
              ADD    HL,DE
LE43E:
              ADD    HL,HL
              JR     NC,LE442
              ADD    HL,DE
LE442:
              ADD    HL,HL
              JR     NC,LE446
              ADD    HL,DE
LE446:
              LD     L,H
NO_SKEW:
              LD     A,C         ; C = initial phase1 period
              ADD    A,L         ; L = skew value
              LD     H,A         ; store skewed phase1 in H
              LD     A,E         ; E = initial phase2 period
              SUB    L
              LD     L,D         ; initialise fractional period to 0
              LD     E,D         ; initialise fractional period to 0
              LD     D,A         ; skewed phase2 period
              LD     C,(IX + CHAN_GENFX)
LE452:
;              LD     A,BORDER_CLR
              LD     B,H         ; init counter with phase1
              RET

; ************************************************************************
; * PATSTEP_DRUMS
; *
; * Percussion
; ************************************************************************
PATSTEP_DRUMS:
              LD    HL,PATDRUM_CNT_QTS
              DEC   (HL)
              RET   NZ
PATSTEP_DRUMBEAT:
              LD    HL,(PATDRUM_PTR)
              LD    A,(HL)
              INC   HL
              OR    A
              JR    NZ,LE483     ; Jump if not end of pattern
              PUSH  BC
              PUSH  DE
              LD    B,A          ; A = 0 at this point
              LD    HL,(CURPOS_DRUM)
              LD    A,L
              ADD   A,2
              CP    H
              JR    NZ,LE472      ; jump if not end of song
              LD    A,(DRUM_SONGLOOPPOS)
LE472:
              LD    (CURPOS_DRUM),A
              LD    C,A
              LD    HL,(LISTDRUM_AD)
              ADD   HL,BC        ; here B=0
              LD    E,(HL)
              INC   HL            ; relocatable
              LD    D,(HL)
              EX    DE,HL
              LD    A,(HL)
              INC   HL
              OR    A
              POP   DE
              POP   BC
LE483:
              LD    (PATDRUM_PTR),HL
              JP    M,PLAYNOISE
              LD    (PATDRUM_CNT_QTS),A
              RET

PLAYNOISE:    LD    HL,PATDRUM_CNT_QTS
              LD    B,(HL)       ; here (HL) = 0
              INC   (HL)
              PUSH  BC
              PUSH  DE
              LD    C,A
              LD    HL,NOISE_OFFSETS - $80
              ADD   HL,BC
              LD    C,(HL)
              ADD   HL,BC
              LD    A,(LE452 + 1)
              JP    (HL)

NOISE_OFFSETS:
              DEFB  $0F,$13,$17,$07,$1
NOISE_01:     LD    BC,$E01F
              JR    LEA24
NOISE_07:     LD    BC,$C0A1
              JR    LEA24
NOISE_OF:     LD    BC,$200F
              JR    LEA24
NOISE_13:     LD    BC,$CF3F
              JR    LEA24
NOISE_17:     LD    BC,$283F
LEA24:        LD    HL,$014A
              JR    LEA30

LEA29:        LD    E,8

LEA2B:
              DEC   H			; 4+12=16
              JR    NZ,LEA3E

              XOR   $21	;$10			; 7+11+4+8+4+4+4+4+4+4+4+12-5=65
LEA30:        ld	($6800), a		;OUT   ($FE),A
              LD    E,A
              LD    A,R
              XOR   L
              RLCA
              LD    L,A
              AND   C
              INC   A
              LD    H,A
              LD    A,E
              JR    LEA41
LEA3E:        
              DEC   E			; 4+16=16
              JR    NZ,LEA2B

LEA41:
              DJNZ  LEA29		; 13
              POP   DE
              POP   BC
              RET

; ************************************************************************
; * Song data...
; ************************************************************************
VECTOR_TABLE_LOC:    EQU $FE00
BORDER_CLR:          EQU $0


; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SONG_INITDATA_0:
              ; *** Channel 1 ***
              DEFB  42  ; song end
              DEFB  26  ; loop
              DEFW  C1_PATTERNS
              ; *** Channel 2 ***
              DEFB  42  ; song end
              DEFB  26  ; loop
              DEFW  C2_PATTERNS
              ; *** Percussion ***
              DEFB  42  ; song end
              DEFB  26  ; loop
              DEFW  PERC_PATTERNS
              DEFW  ORN_OFFSETS
              DEFW  ORNAMENTS_DATA

ORN_OFFSETS:  DEFB  $00

ORNAMENTS_DATA:
              DEFB  $80       ; Ornament 0 (no arpeggio)

C1_PATTERNS:  DEFW      PAT1_0
              DEFW      PAT1_0
              DEFW      PAT1_0
              DEFW      PAT1_0
              DEFW      PAT1_1
              DEFW      PAT1_2
              DEFW      PAT1_1
              DEFW      PAT1_2
              DEFW      PAT1_0
              DEFW      PAT1_0
              DEFW      PAT1_1
              DEFW      PAT1_3
              DEFW      PAT1_4
              DEFW      PAT1_5
              DEFW      PAT1_5
              DEFW      PAT1_7
              DEFW      PAT1_8
              DEFW      PAT1_9
              DEFW      PAT1_11
              DEFW      PAT1_9
              DEFW      PAT1_10

PAT1_0:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$00   ; Skew
        DEFB $E0,$04
           DEFB $85,$A0   ; Skew
        DEFB $1A
           DEFB $85,$00   ; Skew
        DEFB $0E
        DEFB $0D
           DEFB $85,$00   ; Skew
           DEFB $87,$F0   ; SkewXOR
        DEFB $1F
        DEFB $09
        DEFB $23
        DEFB $0B
        DEFB $26
        DEFB $07
        DEFB $2A
        DEFB $09
        DEFB $2D
           DEFB $85,$00   ; Skew
           DEFB $87,$00   ; SkewXOR
        DEFB $06
        DEFB $07
        DEFB $09
        DEFB $82   ; End of Pattern
PAT1_1:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$00   ; Skew
        DEFB $E0,$0B
        DEFB $0B
        DEFB $80
           DEFB $85,$00   ; Skew
           DEFB $87,$A0   ; SkewXOR
        DEFB $19
        DEFB $80
        DEFB $0B
        DEFB $80
        DEFB $1A
        DEFB $80
        DEFB $0B
        DEFB $80
        DEFB $19
        DEFB $80
        DEFB $E2,$0B
        DEFB $82   ; End of Pattern
PAT1_2:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$00   ; Skew
        DEFB $E0,$09
        DEFB $09
        DEFB $15
        DEFB $1A
        DEFB $80
        DEFB $09
        DEFB $80
        DEFB $09
           DEFB $85,$E0   ; Skew
        DEFB $E3,$2A
        DEFB $28
        DEFB $82   ; End of Pattern
PAT1_3:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$00   ; Skew
        DEFB $E0,$09
        DEFB $09
        DEFB $E1,$80
        DEFB $E0,$80
        DEFB $09
        DEFB $80
        DEFB $09
        DEFB $82   ; End of Pattern
PAT1_4:
        DEFB 2    ; Pattern Tempo
           DEFB $85,$00   ; Skew
        DEFB $F1,$06
           DEFB $86       ; Phase effect
           DEFB $81,$09   ; Glissando
        DEFB $E7,$11
        DEFB $82   ; End of Pattern
PAT1_5:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$00   ; Skew
        DEFB $E1,$0B
        DEFB $E0,$80
        DEFB $E1,$09
        DEFB $E0,$80
        DEFB $E1,$0B
        DEFB $10
        DEFB $E0,$80
        DEFB $E2,$0E
        DEFB $E1,$10
        DEFB $E3,$0B
        DEFB $E2,$09
        DEFB $E1,$0B
        DEFB $E4,$80
        DEFB $E1,$09
        DEFB $82   ; End of Pattern
PAT1_7:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$00   ; Skew
           DEFB $87,$00   ; SkewXOR
        DEFB $E0,$04
        DEFB $80
        DEFB $0E
        DEFB $0D
        DEFB $80
        DEFB $09
        DEFB $80
        DEFB $0B
        DEFB $80
        DEFB $07
        DEFB $80
        DEFB $09
        DEFB $80
        DEFB $06
        DEFB $07
        DEFB $09
        DEFB $04
        DEFB $80
        DEFB $0E
        DEFB $0D
        DEFB $80
        DEFB $09
        DEFB $80
        DEFB $0B
        DEFB $80
        DEFB $07
        DEFB $80
        DEFB $09
        DEFB $80
        DEFB $06
        DEFB $07
        DEFB $09
        DEFB $82   ; End of Pattern
PAT1_8:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$00   ; Skew
        DEFB $E1,$0B
        DEFB $E0,$80
        DEFB $E1,$09
        DEFB $E0,$80
        DEFB $E1,$0B
        DEFB $10
        DEFB $E0,$80
        DEFB $E2,$0E
        DEFB $E1,$10
        DEFB $E3,$0B
        DEFB $E2,$09
        DEFB $E1,$0B
        DEFB $E4,$80
           DEFB $86       ; Phase effect
           DEFB $81,$FF   ; Glissando
        DEFB $E1,$06
        DEFB $82   ; End of Pattern
PAT1_9:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$04
        DEFB $10
        DEFB $E0,$04
        DEFB $10
        DEFB $80
        DEFB $11
        DEFB $E1,$12
        DEFB $E0,$80
        DEFB $10
        DEFB $E1,$80
        DEFB $17
        DEFB $0B
        DEFB $17
        DEFB $01
        DEFB $0D
        DEFB $02
        DEFB $0E
        DEFB $03
        DEFB $0F
        DEFB $82   ; End of Pattern
PAT1_10:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$04
        DEFB $10
        DEFB $E0,$04
        DEFB $10
        DEFB $80
        DEFB $11
        DEFB $E1,$12
        DEFB $E0,$80
        DEFB $10
        DEFB $E1,$80
        DEFB $17
        DEFB $E3,$04
        DEFB $06
        DEFB $E0,$0B
        DEFB $E3,$0B
        DEFB $E2,$80
        DEFB $82   ; End of Pattern
PAT1_11:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$04
        DEFB $10
        DEFB $E0,$04
        DEFB $10
        DEFB $80
        DEFB $11
        DEFB $E1,$12
        DEFB $E0,$80
        DEFB $10
        DEFB $E1,$80
        DEFB $17
        DEFB $E3,$04
        DEFB $06
        DEFB $E4,$0B
        DEFB $E2,$80
        DEFB $82   ; End of Pattern

C2_PATTERNS:  DEFW      PAT2_0
              DEFW      PAT2_0
              DEFW      PAT2_0
              DEFW      PAT2_0
              DEFW      PAT2_1
              DEFW      PAT2_2
              DEFW      PAT2_1
              DEFW      PAT2_2
              DEFW      PAT2_0
              DEFW      PAT2_0
              DEFW      PAT2_1
              DEFW      PAT2_3
              DEFW      PAT2_4
              DEFW      PAT2_5
              DEFW      PAT2_6
              DEFW      PAT2_7
              DEFW      PAT2_8
              DEFW      PAT2_9
              DEFW      PAT2_9
              DEFW      PAT2_9
              DEFW      PAT2_9

PAT2_0:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$F0   ; Skew
        DEFB $E0,$1E
        DEFB $1F
        DEFB $21
        DEFB $23
        DEFB $25
        DEFB $26
        DEFB $28
        DEFB $2A
        DEFB $2B
        DEFB $2D
        DEFB $2F
        DEFB $31
        DEFB $32
        DEFB $34
        DEFB $36
        DEFB $37
        DEFB $82   ; End of Pattern
PAT2_1:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$B0   ; Skew
        DEFB $E0,$1E
        DEFB $E1,$1E
        DEFB $E0,$1C
        DEFB $80
        DEFB $1E
        DEFB $80
        DEFB $21
        DEFB $80
        DEFB $1E
        DEFB $80
        DEFB $1C
        DEFB $80
        DEFB $E2,$1E
        DEFB $82   ; End of Pattern
PAT2_2:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$90   ; Skew
        DEFB $E0,$1E
        DEFB $1E
        DEFB $80
        DEFB $1E
        DEFB $80
        DEFB $1E
        DEFB $80
        DEFB $1E
        DEFB $09
        DEFB $E6,$80
        DEFB $82   ; End of Pattern
PAT2_3:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$90   ; Skew
        DEFB $E0,$26
        DEFB $23
        DEFB $21
        DEFB $1E
        DEFB $1C
        DEFB $1A
        DEFB $17
        DEFB $15
        DEFB $82   ; End of Pattern
PAT2_4:
        DEFB 2    ; Pattern Tempo
           DEFB $85,$A0   ; Skew
           DEFB $87,$00   ; SkewXOR
        DEFB $E0,$36
        DEFB $3B
        DEFB $3A
        DEFB $36
        DEFB $33
        DEFB $31
        DEFB $2F
        DEFB $2E
        DEFB $2A
        DEFB $27
        DEFB $25
        DEFB $23
        DEFB $22
        DEFB $1E
        DEFB $1B
           DEFB $85,$00   ; Skew
        DEFB $E2,$12
        DEFB $E7,$80
        DEFB $82   ; End of Pattern
PAT2_5:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$0A   ; Skew
        DEFB $E2,$2A
        DEFB $28
        DEFB $E1,$26
        DEFB $E2,$28
        DEFB $26
        DEFB $E1,$23
        DEFB $E3,$26
        DEFB $E2,$21
        DEFB $E1,$23
        DEFB $E4,$80
        DEFB $E1,$21
        DEFB $82   ; End of Pattern
PAT2_6:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$2A
        DEFB $E0,$80
        DEFB $E2,$28
        DEFB $E1,$26
        DEFB $E2,$28
        DEFB $26
        DEFB $E1,$23
        DEFB $E3,$26
        DEFB $E2,$21
        DEFB $E1,$23
        DEFB $E4,$80
        DEFB $E1,$21
        DEFB $82   ; End of Pattern
PAT2_7:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$90   ; Skew
        DEFB $E3,$28
        DEFB $E1,$28
        DEFB $26
        DEFB $2A
        DEFB $28
        DEFB $E3,$28
        DEFB $E2,$28
        DEFB $26
        DEFB $E1,$26
        DEFB $E2,$28
        DEFB $E4,$80
        DEFB $82   ; End of Pattern
PAT2_8:
        DEFB 6    ; Pattern Tempo
           DEFB $85,$0A   ; Skew
        DEFB $E2,$2A
        DEFB $28
        DEFB $E1,$26
        DEFB $E2,$28
        DEFB $26
        DEFB $E1,$23
        DEFB $E3,$26
        DEFB $E2,$21
        DEFB $E1,$23
        DEFB $E6,$80
        DEFB $82   ; End of Pattern
PAT2_9:
        DEFB 6    ; Pattern Tempo
        DEFB $E3,$80
        DEFB $E1,$1C
        DEFB $1A
        DEFB $E2,$1E
        DEFB $E1,$1C
        DEFB $E6,$80
        DEFB $E1,$1A
        DEFB $17
        DEFB $E2,$15
        DEFB $E1,$17
        DEFB $E2,$80
        DEFB $82   ; End of Pattern
PERC_PATTERNS:
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM0
              DEFW      DRM3
              DEFW      DRM4
              DEFW      DRM5
              DEFW      DRM6
              DEFW      DRM7
              DEFW      DRM8
              DEFW      DRM9
              DEFW      DRM9
              DEFW      DRM9
              DEFW      DRM10

DRM0:
        DEFB $10
        DEFB $00   ; End of pattern
DRM3:
        DEFB $08
        DEFB $00   ; End of pattern
DRM4:
        DEFB $1A
        DEFB $00   ; End of pattern
DRM5:
        DEFB $19
        DEFB $83
        DEFB $01
        DEFB $83
        DEFB $84
        DEFB $83
        DEFB $80
        DEFB $80
        DEFB $00   ; End of pattern
DRM6:
        DEFB $19
        DEFB $83
        DEFB $01
        DEFB $84
        DEFB $83
        DEFB $01
        DEFB $84
        DEFB $01
        DEFB $00   ; End of pattern
DRM7:
        DEFB $80
        DEFB $80
        DEFB $81
        DEFB $84
        DEFB $80
        DEFB $80
        DEFB $82
        DEFB $83
        DEFB $80
        DEFB $80
        DEFB $81
        DEFB $84
        DEFB $80
        DEFB $80
        DEFB $82
        DEFB $83
        DEFB $80
        DEFB $80
        DEFB $81
        DEFB $84
        DEFB $80
        DEFB $80
        DEFB $82
        DEFB $83
        DEFB $80
        DEFB $80
        DEFB $81
        DEFB $84
        DEFB $80
        DEFB $84
        DEFB $84
        DEFB $84
        DEFB $00   ; End of pattern
DRM8:
        DEFB $80
        DEFB $80
        DEFB $81
        DEFB $84
        DEFB $80
        DEFB $80
        DEFB $82
        DEFB $83
        DEFB $80
        DEFB $80
        DEFB $81
        DEFB $84
        DEFB $80
        DEFB $80
        DEFB $82
        DEFB $83
        DEFB $80
        DEFB $80
        DEFB $81
        DEFB $84
        DEFB $80
        DEFB $80
        DEFB $82
        DEFB $83
        DEFB $01
        DEFB $83
        DEFB $01
        DEFB $83
        DEFB $84
        DEFB $83
        DEFB $80
        DEFB $80
        DEFB $00   ; End of pattern
DRM9:
        DEFB $84
        DEFB $83
        DEFB $82
        DEFB $82
        DEFB $80
        DEFB $81
        DEFB $80
        DEFB $83
        DEFB $80
        DEFB $82
        DEFB $82
        DEFB $81
        DEFB $80
        DEFB $81
        DEFB $80
        DEFB $81
        DEFB $84
        DEFB $83
        DEFB $82
        DEFB $82
        DEFB $80
        DEFB $81
        DEFB $80
        DEFB $83
        DEFB $80
        DEFB $01
        DEFB $82
        DEFB $01
        DEFB $80
        DEFB $82
        DEFB $80
        DEFB $80
        DEFB $00   ; End of pattern
DRM10:
        DEFB $84
        DEFB $83
        DEFB $82
        DEFB $82
        DEFB $80
        DEFB $81
        DEFB $80
        DEFB $83
        DEFB $80
        DEFB $82
        DEFB $82
        DEFB $81
        DEFB $80
        DEFB $81
        DEFB $80
        DEFB $81
        DEFB $84
        DEFB $83
        DEFB $82
        DEFB $82
        DEFB $80
        DEFB $81
        DEFB $80
        DEFB $83
        DEFB $81
        DEFB $81
        DEFB $06
        DEFB $00   ; End of pattern
			
