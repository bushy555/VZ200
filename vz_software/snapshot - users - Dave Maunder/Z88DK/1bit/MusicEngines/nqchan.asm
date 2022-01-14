XDEF _nqchan
_nqchan:



OP_NOP:         EQU   $00                 ; NOP opcode (used for CHECK_KEMPSTON)
OP_ORC:         EQU   $b1                 ; OR C opcode (used in CHECK_KEMPSTON)

                LD    HL,MUSICDATA
                CALL  QCHAN_PLAY
                RET

QCHAN_PLAY:
                DI
                LD    A,(HL)
                INC   HL
                LD    (CH0_VOL + 1),A
                LD    A,(HL)
                INC   HL
                LD    (CH1_VOL + 1),A
                LD    A,(HL)
                INC   HL
                LD    (CH2_VOL + 1),A
                LD    A,(HL)
                INC   HL
                LD    (CH3_VOL + 1),A
                LD    (ORDER_PTR + 1),HL
                LD    HL,0
                LD    (FRQ0 + 1),HL
                LD    (FRQ1 + 1),HL
                LD    (FRQ2 + 1),HL
                LD    (FRQ3 + 1),HL
                LD    A,L
                LD    (VOL0 + 1),A
                LD    (VOL1 + 1),A
                LD    (VOL2 + 1),A
                LD    (VOL3 + 1),A
                LD    (FRAME_CNT + 1),A

                IN    A,($1F)
                AND   $1F
                LD    A,OP_NOP
                JR    NZ,SET_KEMPSTON     ; Jump if Kempston not present
                LD    A,OP_ORC
SET_KEMPSTON:   LD    (CHECK_KEMPSTON),A
                EXX
                PUSH  HL
                PUSH  IY
                LD    (OLD_SP + 1),SP
                JR    NEXT_POSITION
READ_LOOP:
MUSIC_PTR:      LD    DE,0                ; 
READ_ROW:       LD    A,(DE)
                CP    128
                JP    NZ,READ_NOTES
NEXT_POSITION:
ORDER_PTR:      LD    HL,0                ; 
                LD    E,(HL)
                INC   HL
                LD    D,(HL)
                INC   HL
                LD    A,D
                OR    E
                JR    Z,ORDER_LOOP
                LD    (ORDER_PTR + 1),HL
                LD    A,(DE)
                LD    (FRAME_MAX + 1),A
                INC   DE
                LD    A,(DE)
                LD    (CH0_DECAY + 1),A
                INC   DE
                LD    A,(DE)
                LD    (CH1_DECAY + 1),A
                INC   DE
                LD    A,(DE)
                LD    (CH2_DECAY + 1),A
                INC   DE
                LD    A,(DE)
                LD    (CH3_DECAY + 1),A
                INC   DE
                JP    READ_ROW

ORDER_LOOP:     LD    E,(HL)
                INC   HL
                LD    D,(HL)
                LD    (ORDER_PTR+1),DE
                JP    NEXT_POSITION
READ_NOTES:
                LD    H,FREQ_TABLE / 256
                INC   DE
                OR    A
                JR    Z,NO_NOTE0
                LD    L,A
                LD    C,(HL)
                INC   L
                LD    B,(HL)
                LD    (FRQ0 + 1),BC
CH0_VOL:
                LD    A,$21
                LD    (VOL0 + 1),A
NO_NOTE0:
                LD    A,(DE)
                INC   DE
                OR    A
                JR    Z,NO_NOTE1
                LD    L,A
                LD    C,(HL)
                INC   L
                LD    B,(HL)
                LD    (FRQ1 + 1),BC
FRQ1:           LD    SP,0
CH1_VOL:        LD    A,$21
                LD    (VOL1 + 1),A
NO_NOTE1:       LD    A,(DE)
                INC   DE
                OR    A
                JR    Z,NO_NOTE2
                LD    L,A
                LD    C,(HL)
                INC   L
                LD    B,(HL)
                LD    (FRQ2 + 1),BC
                EXX
FRQ2:           LD    DE,0
                EXX
CH2_VOL:        LD    A,$21
                LD    (VOL2 + 1),A
NO_NOTE2:       LD    A,(DE)
                INC   DE
                OR    A
                JR    Z,NO_NOTE3
                LD    L,A
                LD    C,(HL)
                INC   L
                LD    B,(HL)
                LD    (FRQ3 + 1),BC
                EXX
FRQ3:           LD    BC,0
                EXX
CH3_VOL:        LD    A,$21
                LD    (VOL3 + 1),A
NO_NOTE3:       LD    (MUSIC_PTR + 1),DE
                LD    A,(DE)
                CP    129
                JR    C,NO_DRUM
                INC   DE
                LD    (MUSIC_PTR + 1),DE
                LD    B,128
                SUB   B
                ADD   A,A
                LD    C,A
                LD    E,A
                LD    L,A
                LD    H,A

DRUM_1:         DEC   C
                JR    NZ,DRUM_2
                LD    C,E
                AND   $21
		LD	($6800), A
DRUM_2:         LD    A,L
                ADD   A,11
                XOR   H
                LD    L,A
                LD    A,H
                ADD   A,12
                XOR   L
                LD    H,A
                DJNZ  DRUM_1

NO_DRUM:        XOR   A
FRQ0:           LD    DE,0
SOUND_LOOP_RPT: EX    AF,AF'
PREV_CNT1:      LD    HL,0
                LD    C,64
                                    ; T-States...
SOUND_LOOP:     ADD   IX,DE         ; 15
                SBC   A,A           ;  4
VOL0:           AND   0             ;  7
                LD    B,A           ;  4
                ADD   HL,SP         ; 11
                SBC   A,A           ;  4
VOL1:           AND   0             ;  7
                OR    B             ;  4
                LD    B,A           ;  4
                EXX                 ;  4
                ADD   IY,DE         ; 15
                SBC   A,A           ;  4
VOL2:           AND   0             ;  7
                EXX                 ;  4
                OR    B             ;  4
                LD    B,A           ;  4
                EXX                 ;  4
                ADD   HL,BC         ; 11
                SBC   A,A           ;  4
VOL3:           AND   0             ;  7
                EXX                 ;  4
                OR    B             ;  4
                JR    Z,NO_OUT      ;7/12
                LD    B,A           ;  4
                LD    A,$21          ;  7
		LD	($6800), A	; 13
                LD    A,B           ;  4
SND_DELAY:      DJNZ  SND_DELAY     ;~
                CPL                 ;  4
NO_OUT:         ADD   A,$21          ;  7
                LD    B,A           ;  4
                XOR   A             ;  4
		LD	($6800), A	; 13
SND_DELAY2:     DJNZ  SND_DELAY2    ;~
                DEC   C             ;  4
                JP    NZ,SOUND_LOOP ; 10 = ~404Ts

                LD    (PREV_CNT1 + 1),HL
FRAME_CNT:      LD    A,0
                LD    C,A
CH0_DECAY:      AND   0
                JR    NZ,CH0_DSKIP
                LD    HL,VOL0 + 1
                OR    (HL)
                JR    Z,CH0_DSKIP
                DEC   (HL)
CH0_DSKIP:      LD    A,C
CH1_DECAY:      AND   0
                JR    NZ,CH1_DSKIP
                LD    HL,VOL1 + 1
                OR    (HL)
                JR    Z,CH1_DSKIP
                DEC   (HL)
CH1_DSKIP:      LD    A,C
CH2_DECAY:      AND   0
                JR    NZ,CH2_DSKIP
                LD    HL,VOL2 + 1
                OR    (HL)
                JR    Z,CH2_DSKIP
                DEC   (HL)
CH2_DSKIP:      LD    A,C
CH3_DECAY:      AND   0
                JR    NZ,CH3_DSKIP
                LD    HL,VOL3 + 1
                OR    (HL)
                JR    Z,CH3_DSKIP
                DEC   (HL)
CH3_DSKIP:      LD    HL,FRAME_CNT + 1
                INC   (HL)
                EX    AF,AF'
                INC   A
FRAME_MAX:      CP    20
                JP    C,SOUND_LOOP_RPT
                IN    A,($1F)             ; Read Kempston port
                LD    C,A                 ; Store Kempston state
                XOR   A

		ld 	a, ($68fd)			; ======   VZ press <s> to continue   ======
		and	$02
		jr 	z, STOP_MUSIC


;                IN    A,($FE)             ; Read Keyboard
;                CPL
CHECK_KEMPSTON: OR    C                   ; NOPped out if no Kempston present
;                AND   $1F
;                JR    NZ,STOP_MUSIC
                JP    READ_LOOP

STOP_MUSIC:
OLD_SP:         LD    SP,0
                POP   IY
                POP   HL
                EXX
                EI
                RET

; The line below is to align FREQ_TABLE on a page boundary. If you assembler
; emits an error, try replacing the '%' with whatever it's MODULO operator
; is. Alternatively some assemblers offer an ALIGN directive.
	;       DEFS (-$) % 256           ; Page align FREQ_TABLE
 ;               DEFS (-$) MOD 256           ; Page align FREQ_TABLE
	 
FREQ_TABLE:
	              DEFW 0
	              DEFW 247,262,277,294,311,330,349,370,392,416,440,467
	              DEFW 494,524,555,588,623,660,699,741,785,832,881,934
	              DEFW 989,1048,1110,1176,1246,1320,1399,1482,1570,1664,1763,1868
	              DEFW 1979,2096,2221,2353,2493,2641,2798,2965,3141,3328,3526,3736
	              DEFW 3958,4193,4442,4707,4987,5283,5597,5930,6283,6656,7052,7472
	              DEFW 0

; ************************************************************************
; * Song data...
; ************************************************************************
BORDER_CLR:          EQU $0

; *** DATA ***
; *** DATA ***
MUSICDATA:

; *** Volumes ***
                     DEFB  $0F,$0F,$0F,$0F
; *** Song layout ***
LOOPSTART:            DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT1
                      DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT1
                      DEFW      PAT2
                      DEFW      PAT2
                      DEFW      PAT3
                      DEFW      PAT3
                      DEFW      PAT2
                      DEFW      PAT2
                      DEFW      PAT3
                      DEFW      PAT3
                      DEFW      PAT4
                      DEFW      PAT4
                      DEFW      PAT3
                      DEFW      PAT3
                      DEFW      PAT4
                      DEFW      PAT4
                      DEFW      PAT3
                      DEFW      PAT3
                      DEFW      PAT5
                      DEFW      PAT5
                      DEFW      PAT6
                      DEFW      $0000
                      DEFW      LOOPSTART

; *** Patterns ***
PAT0:             DEFB 15             ; Pattern tempo
                     DEFB 15,15,15,15        ; Decays
                     DEFB 50,50,0,0,129
                     DEFB 0,0,0,0
                     DEFB 54,50,0,0
                     DEFB 0,0,0,0
                     DEFB 58,50,0,0,130
                     DEFB 0,0,0,0
                     DEFB 34,50,0,0
                     DEFB 0,0,0,0
                     DEFB 50,34,0,0,129
                     DEFB 36,0,0,0
                     DEFB 54,34,0,0,129
                     DEFB 36,0,0,0
                     DEFB 58,34,0,0,130
                     DEFB 36,0,0,0
                     DEFB 58,34,0,0
                     DEFB 36,0,0,0
                     DEFB $80             ; Pattern end

PAT1:             DEFB 15             ; Pattern tempo
                     DEFB 15,15,15,15        ; Decays
                     DEFB 26,54,0,0,129
                     DEFB 0,0,0,0
                     DEFB 30,54,0,0
                     DEFB 0,0,0,0
                     DEFB 34,54,0,0,130
                     DEFB 0,0,0,0
                     DEFB 36,54,0,0
                     DEFB 0,0,0,0
                     DEFB 36,36,0,0,129
                     DEFB 0,0,0,0
                     DEFB 36,36,0,0,129
                     DEFB 0,0,0,0
                     DEFB 34,36,0,0,130
                     DEFB 0,0,0,0
                     DEFB 30,36,0,0
                     DEFB 0,0,0,0
                     DEFB $80             ; Pattern end

PAT2:             DEFB 15             ; Pattern tempo
                     DEFB 15,15,15,15        ; Decays
                     DEFB 50,26,0,0,129
                     DEFB 0,0,0,0
                     DEFB 50,26,0,0
                     DEFB 0,0,0,0
                     DEFB 54,26,0,0,130
                     DEFB 58,0,0,0
                     DEFB 60,26,0,0
                     DEFB 0,0,0,0
                     DEFB 50,30,0,0,129
                     DEFB 0,0,0,0
                     DEFB 50,30,0,0,129
                     DEFB 0,0,0,0
                     DEFB 54,30,0,0,130
                     DEFB 58,0,0,0
                     DEFB 60,30,0,0,130
                     DEFB 0,0,0,0
                     DEFB $80             ; Pattern end

PAT3:             DEFB 15             ; Pattern tempo
                     DEFB 15,15,15,15        ; Decays
                     DEFB 50,60,0,0,129
                     DEFB 0,0,0,0
                     DEFB 50,60,0,0
                     DEFB 0,0,0,0
                     DEFB 54,60,0,0,130
                     DEFB 58,0,0,0
                     DEFB 60,60,0,0
                     DEFB 0,0,0,0
                     DEFB 50,64,0,0,129
                     DEFB 0,0,0,0
                     DEFB 50,64,0,0,129
                     DEFB 0,0,0,0
                     DEFB 54,64,0,0,130
                     DEFB 58,0,0,0
                     DEFB 60,64,0,0,130
                     DEFB 0,0,0,0
                     DEFB $80             ; Pattern end

PAT4:             DEFB 15             ; Pattern tempo
                     DEFB 15,15,15,15        ; Decays
                     DEFB 54,64,0,0,129
                     DEFB 0,0,0,0
                     DEFB 54,64,0,0
                     DEFB 0,0,0,0
                     DEFB 58,64,0,0,130
                     DEFB 62,0,0,0
                     DEFB 64,64,0,0
                     DEFB 0,0,0,0
                     DEFB 54,68,0,0,129
                     DEFB 0,0,0,0
                     DEFB 54,68,0,0,129
                     DEFB 0,0,0,0
                     DEFB 58,68,0,0,130
                     DEFB 62,0,0,0
                     DEFB 64,68,0,0,130
                     DEFB 0,0,0,0
                     DEFB $80             ; Pattern end

PAT5:             DEFB 15             ; Pattern tempo
                     DEFB 15,15,15,15        ; Decays
                     DEFB 34,58,0,0,132
                     DEFB 0,0,0,0
                     DEFB 34,58,0,0,130
                     DEFB 0,0,0,0
                     DEFB 34,58,0,0,132
                     DEFB 36,60,0,0,130
                     DEFB 40,60,0,0,132
                     DEFB 0,0,0,0,130
                     DEFB 34,58,0,0,132
                     DEFB 0,0,0,0,130
                     DEFB 34,58,0,0,132
                     DEFB 0,0,0,0,130
                     DEFB 34,58,0,0,132
                     DEFB 36,60,0,0,132
                     DEFB 40,60,0,0,132
                     DEFB 0,0,0,0,132
                     DEFB $80             ; Pattern end

PAT6:             DEFB 15             ; Pattern tempo
                     DEFB 15,15,15,15        ; Decays
                     DEFB 26,34,0,0,132
                     DEFB 0,0,0,0
                     DEFB 26,34,0,0,132
                     DEFB 0,0,0,0
                     DEFB 30,36,0,0,132
                     DEFB 30,36,0,0,130
                     DEFB 0,0,0,0,132
                     DEFB 0,0,0,0,130
                     DEFB 0,0,0,0,132
                     DEFB 0,0,0,0,130
                     DEFB 0,0,0,0
                     DEFB 0,0,0,0
                     DEFB 26,34,0,0,132
                     DEFB 26,34,0,0,132
                     DEFB 0,0,0,0
                     DEFB 0,0,0,0,132
                     DEFB $80             ; Pattern end

