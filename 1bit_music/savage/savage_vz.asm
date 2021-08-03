                ORG $8000
; *****************************************************************************
; * Savage Music Player Engine
; *
; * Based on code written by Jason C Brooke for the Probe Software game,
; * Savage. Reverse engineerd in Ukraine by barmaley_m and translated to
; * English by Shiru.  Minor mods by Chris Cowley.
; *
; * Produced by Beepola v1.08.01
; ******************************************************************************
;
; VZ Conversion by dave. ~28th Aug 2019
;
 

START:


	call	$01c9		; VZ ROM CLS
	ld	hl, MSG0	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG1	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG2
	call	$28a7	
	ld	hl, MSG3
	call	$28a7	
	ld	hl, MSG4
	call	$28a7	
	ld	hl, MSG5
	call	$28a7	
	ld	hl, MSG6
	call	$28a7	
	ld	hl, MSG7
	call	$28a7	
	ld	hl, MSG8
	call	$28a7	
;	di


              PUSH  AF
              LD    HL,VECTOR_TABLE_LOC
              LD    DE,VECTOR_TABLE_LOC + 1
              LD    BC,257             ; Length of vector table = 257 bytes
              LD    (HL),$FF           ; Point vector table at address $FFFF
              LDIR
              LD    HL,$FFFF
              LD    (HL),$18           ; Copy in a JR instruction for JR FFF4
              LD    HL,$FFF4
              LD    (HL),$C3           ; Copy in a JP instruction
              INC   HL
              LD    (HL),ISR_0
              LD    A,VECTOR_TABLE_LOC / 256
              LD    I,A
              IM    2
              EI                       ; Enable IM2 routine at $F0F0
              POP   AF
              CALL  INIT_MUSIC
              CALL  PLAY_MUSIC
              IM    1
              LD    IY,$5C3A           ; Set up IY and
              LD    HL,$2758           ; HL' with sensible values for
              EXX                      ; returning to BASIC
              EI
              RET

INTVEC_ADR:   EQU   $FFF5

INIT_MUSIC:
              PUSH  BC
              PUSH  DE
              PUSH  HL
              PUSH  IX
              LD    HL,SONG_INITDATA_0
              LD    IX,CHAN_0_DATA
              LD    C,$11              ; Length of channel data
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

              POP   IX
              POP   HL
              POP   DE
              POP   BC
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
              DEFB  33         ; Channel on
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
              DEFB  33         ; Channel on
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
              DI
              EX    AF,AF'
              PUSH  AF
CONT_FLAG:
              LD    A,$FF
              OR    A
              JP    Z,END_PLAY
              PUSH  IX
              EXX
              PUSH  BC
              PUSH  DE
              PUSH  HL
              LD    A,I
              LD    H,A
              LD    A,(HL)
              LD    H,A
              LD    L,A
              INC   A
              JR    NZ,LE25A
              LD    L,$F4
LE25A:
              LD    A,(HL)
              LD    (HL),$C3
              INC   HL
              LD    (LE2AF+1),HL
              LD    (LE400+1),HL
              LD    E,(HL)
              INC   HL
              LD    D,(HL)
              PUSH  HL
              PUSH  AF
              PUSH  DE
              LD    (SAVE_SP+1),SP
              ; Set initial pattern tempo from CH0
              LD    HL,(CHAN_0_DATA)
              LD    A,(HL)                ; Pattern tempo
              INC   HL
              LD    (QNT_VAL + 2),A
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
              CALL  CHECK_KEY
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
LE2AF:        LD    (INTVEC_ADR),HL
              LD    A,(CHAN_0_DATA + CHAN_CHANNEL_ON)
              LD    (CHAN0_XOUT + 1),A
              LD    A,(CHAN_1_DATA + CHAN_CHANNEL_ON)
              LD    (CHAN1_XOUT + 1),A
              CALL  SETUP_GEN
QNT_VAL:      LD    IXL,4
ISR2_END:     EI

GENLOOP:
              EXX
              EX    AF,AF'
              DJNZ  LE2F4
              EX    DE,HL
              ADD   HL,BC
              LD    B,H
CHAN0_XOUT:   XOR   33
LE2CE:        JP    LE2FC

ISR_0:        EI
              RET           ;

ISR_1:
              DEC   IXL
              JR    Z,ISR1_PROC_QNT
              EI
              RET
ISR1_PROC_QNT:
              PUSH  HL
              PUSH  AF
              CALL  CHECK_KEY
              CALL  PATSTEP_DRUMS
              LD    HL,CHAN_0_DATA + CHAN_NOTE_LEN_REMAIN
              DEC   (HL)
              JR    Z,LE28B
              LD    HL,CHAN_1_DATA + CHAN_NOTE_LEN_REMAIN
              DEC   (HL)
              JR    Z,SAVE_SP
              LD    A,(QNT_VAL + 2)
              LD    IXL,A
              POP   AF
              POP   HL
              EI
              RET

LE2F4:        RLCA
              RRCA
              JR    NC,LE2CE
              ADD   A,$80
              LD    H,L
              LD    L,B
LE2FC:        ;OUT   ($FE),A
	; and 33
		ld (26624), a
              EXX
              EX    AF,AF'
              DJNZ  LE30C
              EX    DE,HL
              ADD   HL,BC
              LD    B,H
CHAN1_XOUT:   ;XOR   $10
		xor 33
LE307:        	
	;and 33
		ld (26624), a
		;OUT   ($FE),A
JP_GENLOOP:   JP    GENLOOP

LE30C:        RLCA
              RRCA
              JR    NC,LE307
              DEC   HL
              JP    JP_GENLOOP

CHECK_KEY:
              SUB   A
              IN    A,($FE)
              CPL
              AND   $1F
              JR    NZ,KEY_PRESSED
              IN    A,($1F)             ; Read kempston
              AND   0
              RET   Z
              JR    KEY_PRESSED

TBL_FUNC_OFFSETS:
              DEFB  $9E                 ; Func $80 - Rest
              DEFB  $5E                 ; Func $81 - Glissando
              DEFB  $20                 ; Func $82 - End of pattern
              DEFB  $05                 ; Func $83 - End of song
              DEFB  $54                 ; Func $84 - Set transpose
              DEFB  $45                 ; Func $85 - Set Skew
              DEFB  $3E                 ; Func $86 - GenFX
              DEFB  $4A                 ; Func $87 - Set Skew XOR

FUNC_83_SONG_END:
              SUB   A
              LD    (CONT_FLAG + 1),A
KEY_PRESSED:
              LD    SP,(SAVE_SP + 1)
              EX    AF,AF'
              POP   DE
              POP   AF
              POP   HL
              LD    (HL),D
              DEC   HL
              LD    (HL),E
              DEC   HL
              LD    (HL),A
              POP   HL
              POP   DE
              POP   BC
              EXX
              POP   IX
END_PLAY:     POP   AF
              EX    AF,AF'
              RET

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
              LD    (QNT_VAL + 2),A
              INC   DE
              JR    PATSTEP_LOOP

FUNC_86_GENFX:
              LD    (IX + CHAN_CHANNEL_ON),$90
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
              LD    (IX + CHAN_CHANNEL_ON),33;$10
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
LE400:        LD     (INTVEC_ADR),HL
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
              LD     A,BORDER_CLR
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
LEA2B:        DEC   H
              JR    NZ,LEA3E
              ;XOR   $10
		xor 33
LEA30:        ;OUT   ($FE),A
		;and 33
		ld (26624), a
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
LEA3E:        DEC   E
              JR    NZ,LEA2B
LEA41:        DJNZ  LEA29
              POP   DE
              POP   BC
              RET


MSG0 db $0d,"SAVAGE ENGINE.",0
MSG1 db $0d,$0d,"BASED ON CODE WRITTEN",0
MSG2 db $0d,"BY JASON BROOKE.",0
MSG3 db $0d,"REVERSED ENGINEERED BY",0
MSG4 db $0d,"BARMALEY-M AND TRANSLATED",0
MSG5 db $0d,"BY SHIRU. MINOR MODS BY",0
MSG6 db $0d,"CHRIS COWLEY (BEEPOLA FAME)",0
MSG7 db $0d,"VZ CONVERSION BY BUSHY.",0
MSG8 db $0d,"AUG2019",0


; ************************************************************************
; * Song data...
; ************************************************************************
VECTOR_TABLE_LOC:    EQU $FE00
BORDER_CLR:          EQU $0

SONG_INITDATA_0:
              ; *** Channel 1 ***
              DEFB  46  ; song end
              DEFB  14  ; loop
              DEFW  C1_PATTERNS
              ; *** Channel 2 ***
              DEFB  46  ; song end
              DEFB  14  ; loop
              DEFW  C2_PATTERNS
              ; *** Percussion ***
              DEFB  46  ; song end
              DEFB  14  ; loop
              DEFW  PERC_PATTERNS
              DEFW  ORN_OFFSETS
              DEFW  ORNAMENTS_DATA

ORN_OFFSETS:  DEFB  $00

ORNAMENTS_DATA:
              DEFB  $80       ; Ornament 0 (no arpeggio)

C1_PATTERNS:  DEFW      PAT1_0
              DEFW      PAT1_1
              DEFW      PAT1_2
              DEFW      PAT1_3
              DEFW      PAT1_0
              DEFW      PAT1_1
              DEFW      PAT1_4
              DEFW      PAT1_5
              DEFW      PAT1_5
              DEFW      PAT1_6
              DEFW      PAT1_7
              DEFW      PAT1_6
              DEFW      PAT1_8
              DEFW      PAT1_6
              DEFW      PAT1_7
              DEFW      PAT1_6
              DEFW      PAT1_8
              DEFW      PAT1_12
              DEFW      PAT1_13
              DEFW      PAT1_12
              DEFW      PAT1_14
              DEFW      PAT1_15
              DEFW      PAT1_16

PAT1_0:
        DEFB 3    ; Pattern Tempo
        DEFB $E0,$1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $82   ; End of Pattern
PAT1_1:
        DEFB 3    ; Pattern Tempo
        DEFB $E0,$1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $82   ; End of Pattern
PAT1_2:
        DEFB 3    ; Pattern Tempo
        DEFB $E0,$1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $E3,$1B
        DEFB $E7,$1C
        DEFB $82   ; End of Pattern
PAT1_3:
        DEFB 6    ; Pattern Tempo
        DEFB $FB,$80
        DEFB $82   ; End of Pattern
PAT1_4:
        DEFB 3    ; Pattern Tempo
        DEFB $E0,$1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $1D
        DEFB $1F
        DEFB $E3,$12
        DEFB $E7,$13
        DEFB $EF,$1F
        DEFB $1F
        DEFB $EB,$1F
        DEFB $E3,$15
        DEFB $E7,$1D
        DEFB $82   ; End of Pattern
PAT1_5:
        DEFB 6    ; Pattern Tempo
        DEFB $E3,$16
        DEFB $11
        DEFB $16
        DEFB $E2,$19
        DEFB $E0,$18
        DEFB $82   ; End of Pattern
PAT1_6:
        DEFB 6    ; Pattern Tempo
        DEFB $E3,$16
        DEFB $11
        DEFB $16
        DEFB $1A
        DEFB $1B
        DEFB $1A
        DEFB $18
        DEFB $0F
        DEFB $82   ; End of Pattern
PAT1_7:
        DEFB 6    ; Pattern Tempo
        DEFB $E3,$11
        DEFB $13
        DEFB $15
        DEFB $11
        DEFB $16
        DEFB $18
        DEFB $1A
        DEFB $16
        DEFB $82   ; End of Pattern
PAT1_8:
        DEFB 6    ; Pattern Tempo
        DEFB $E3,$11
        DEFB $13
        DEFB $15
        DEFB $11
        DEFB $16
        DEFB $11
        DEFB $E7,$16
        DEFB $82   ; End of Pattern
PAT1_12:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$1A
        DEFB $E3,$1A
        DEFB $E1,$1B
        DEFB $E3,$1A
        DEFB $E2,$1D
        DEFB $E0,$1B
        DEFB $E1,$1A
        DEFB $E3,$1A
        DEFB $E1,$1F
        DEFB $1F
        DEFB $1D
        DEFB $E3,$1D
        DEFB $82   ; End of Pattern
PAT1_13:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$1B
        DEFB $E3,$1B
        DEFB $E1,$1A
        DEFB $E3,$1B
        DEFB $E2,$1B
        DEFB $E0,$18
        DEFB $E1,$1A
        DEFB $E3,$1A
        DEFB $E1,$1B
        DEFB $1B
        DEFB $18
        DEFB $E3,$1A
        DEFB $82   ; End of Pattern
PAT1_14:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$1F
        DEFB $E3,$1F
        DEFB $E1,$1F
        DEFB $1D
        DEFB $E3,$1B
        DEFB $E1,$1D
        DEFB $EF,$1D
        DEFB $82   ; End of Pattern
PAT1_15:
        DEFB 6    ; Pattern Tempo
        DEFB $E3,$16
        DEFB $E2,$1B
        DEFB $E0,$1D
        DEFB $E7,$1F
        DEFB $E2,$1D
        DEFB $E0,$1B
        DEFB $E1,$1A
        DEFB $1D
        DEFB $E3,$1B
        DEFB $16
        DEFB $82   ; End of Pattern
PAT1_16:
        DEFB 6    ; Pattern Tempo
        DEFB $E3,$16
        DEFB $E2,$1B
        DEFB $E0,$1D
        DEFB $E3,$1F
        DEFB $1F
        DEFB $E7,$1F
        DEFB $1F
        DEFB $E3,$1D
        DEFB $82   ; End of Pattern

C2_PATTERNS:  DEFW      PAT2_0
              DEFW      PAT2_1
              DEFW      PAT2_2
              DEFW      PAT2_3
              DEFW      PAT2_0
              DEFW      PAT2_1
              DEFW      PAT2_4
              DEFW      PAT2_5
              DEFW      PAT2_5
              DEFW      PAT2_6
              DEFW      PAT2_7
              DEFW      PAT2_6
              DEFW      PAT2_8
              DEFW      PAT2_6
              DEFW      PAT2_7
              DEFW      PAT2_6
              DEFW      PAT2_8
              DEFW      PAT2_12
              DEFW      PAT2_13
              DEFW      PAT2_12
              DEFW      PAT2_14
              DEFW      PAT2_15
              DEFW      PAT2_16

PAT2_0:
        DEFB 3    ; Pattern Tempo
        DEFB $E7,$11
        DEFB $16
        DEFB $82   ; End of Pattern
PAT2_1:
        DEFB 3    ; Pattern Tempo
        DEFB $E7,$18
        DEFB $E3,$16
        DEFB $18
        DEFB $E7,$1D
        DEFB $1F
        DEFB $82   ; End of Pattern
PAT2_2:
        DEFB 3    ; Pattern Tempo
        DEFB $EB,$80
        DEFB $E3,$20
        DEFB $E7,$21
        DEFB $82   ; End of Pattern
PAT2_3:
        DEFB 6    ; Pattern Tempo
        DEFB $FB,$80
        DEFB $82   ; End of Pattern
PAT2_4:
        DEFB 3    ; Pattern Tempo
        DEFB $EB,$80
        DEFB $E3,$23
        DEFB $E7,$24
        DEFB $EF,$24
        DEFB $24
        DEFB $EB,$24
        DEFB $E3,$21
        DEFB $E7,$22
        DEFB $82   ; End of Pattern
PAT2_5:
        DEFB 6    ; Pattern Tempo
        DEFB $EF,$80
        DEFB $82   ; End of Pattern
PAT2_6:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$1D
        DEFB $E7,$22
        DEFB $E1,$1D
        DEFB $E2,$26
        DEFB $E0,$24
        DEFB $E1,$22
        DEFB $ED,$1F
        DEFB $82   ; End of Pattern
PAT2_7:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$24
        DEFB $E3,$24
        DEFB $E1,$22
        DEFB $E2,$21
        DEFB $E0,$22
        DEFB $E1,$21
        DEFB $1F
        DEFB $1D
        DEFB $E7,$1A
        DEFB $E1,$1A
        DEFB $1B
        DEFB $1C
        DEFB $82   ; End of Pattern
PAT2_8:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$24
        DEFB $E3,$24
        DEFB $E1,$22
        DEFB $21
        DEFB $E3,$1D
        DEFB $E1,$24
        DEFB $EF,$22
        DEFB $82   ; End of Pattern
PAT2_12:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$1D
        DEFB $E3,$1D
        DEFB $E1,$1F
        DEFB $E3,$1D
        DEFB $E2,$22
        DEFB $E0,$24
        DEFB $E1,$29
        DEFB $E3,$29
        DEFB $E1,$2B
        DEFB $29
        DEFB $26
        DEFB $E3,$22
        DEFB $82   ; End of Pattern
PAT2_13:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$1F
        DEFB $E3,$1F
        DEFB $E1,$1D
        DEFB $E3,$1F
        DEFB $E2,$1F
        DEFB $E0,$24
        DEFB $E1,$29
        DEFB $E3,$29
        DEFB $E1,$2B
        DEFB $29
        DEFB $26
        DEFB $E3,$22
        DEFB $82   ; End of Pattern
PAT2_14:
        DEFB 6    ; Pattern Tempo
        DEFB $E1,$1B
        DEFB $E3,$24
        DEFB $E1,$22
        DEFB $21
        DEFB $E3,$1D
        DEFB $E1,$21
        DEFB $EF,$22
        DEFB $82   ; End of Pattern
PAT2_15:
        DEFB 6    ; Pattern Tempo
        DEFB $E3,$22
        DEFB $E2,$27
        DEFB $E0,$29
        DEFB $E7,$22
        DEFB $E2,$21
        DEFB $E0,$1F
        DEFB $E1,$1D
        DEFB $21
        DEFB $E3,$1F
        DEFB $1B
        DEFB $82   ; End of Pattern
PAT2_16:
        DEFB 6    ; Pattern Tempo
        DEFB $E3,$22
        DEFB $E2,$27
        DEFB $E0,$29
        DEFB $E3,$24
        DEFB $22
        DEFB $E7,$24
        DEFB $E5,$24
        DEFB $E1,$21
        DEFB $E3,$22
        DEFB $82   ; End of Pattern
PERC_PATTERNS:
              DEFW      DRM0
              DEFW      DRM1
              DEFW      DRM2
              DEFW      DRM3
              DEFW      DRM0
              DEFW      DRM1
              DEFW      DRM4
              DEFW      DRM5
              DEFW      DRM5
              DEFW      DRM6
              DEFW      DRM6
              DEFW      DRM6
              DEFW      DRM6
              DEFW      DRM9
              DEFW      DRM10
              DEFW      DRM9
              DEFW      DRM11
              DEFW      DRM12
              DEFW      DRM12
              DEFW      DRM12
              DEFW      DRM14
              DEFW      DRM15
              DEFW      DRM16

DRM0:
        DEFB $10
        DEFB $00   ; End of pattern
DRM1:
        DEFB $20
        DEFB $00   ; End of pattern
DRM2:
        DEFB $18
        DEFB $00   ; End of pattern
DRM3:
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $80
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $80
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $80
        DEFB $07
        DEFB $00   ; End of pattern
DRM4:
        DEFB $18
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $03
        DEFB $81
        DEFB $03
        DEFB $81
        DEFB $03
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $80
        DEFB $03
        DEFB $81
        DEFB $03
        DEFB $80
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $80
        DEFB $0F
        DEFB $00   ; End of pattern
DRM5:
        DEFB $10
        DEFB $00   ; End of pattern
DRM6:
        DEFB $20
        DEFB $00   ; End of pattern
DRM9:
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $00   ; End of pattern
DRM10:
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $00   ; End of pattern
DRM11:
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $07
        DEFB $00   ; End of pattern
DRM12:
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $80
        DEFB $05
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $80
        DEFB $05
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $00   ; End of pattern
DRM14:
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $03
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $07
        DEFB $00   ; End of pattern
DRM15:
        DEFB $0A
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $0B
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $00   ; End of pattern
DRM16:
        DEFB $0A
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $80
        DEFB $01
        DEFB $81
        DEFB $81
        DEFB $81
        DEFB $01
        DEFB $81
        DEFB $01
        DEFB $80
        DEFB $07
        DEFB $80
        DEFB $03
        DEFB $00   ; End of pattern
