XDEF _nplip
_nplip:

 
START:          DI
                EXX         ; Preserve HL' for return to BASIC
                PUSH  HL
                CALL  MAKE_VECTOR_TABLE
                IM    2
                LD    A,VECTOR_TABLE_LOC / 256
                LD    I,A
                LD    HL,MUSICDATA     ; Start of music data
                LD   (MUSICSP+1),SP
                CALL  PLAYMUSIC
EXIT:           DI
                IM    1
MUSICSP:        LD    SP,0
                POP   HL    ; Restore HL'
                EXX
                EI
                RET

; ** Creates a vector table of 257 0xFF bytes at the location specified
; ** by VECTOR_TABLE_LOC
MAKE_VECTOR_TABLE:
                LD    HL,VECTOR_TABLE_LOC
                LD    DE,VECTOR_TABLE_LOC + 1
                LD    BC,$2121
                LD    (HL),$FF
                LDIR

; ** Sets up everything for our IM2 service routine. Specifically, copies a JR
; ** instruction to $FFFF and a JP $F0FF to $FFF4
INIT_ISR:
                LD    HL,$FFFF
                LD    (HL),$18               ; Copies in our JR for JR FFF4
                LD     HL,$FFF4
                LD    (HL),$C3               ; JP (jump address filled-in
                                             ; during player initialization)
                RET


INTJUMP        EQU $FFF5
NL              EQU  49                ; NL = NOTETABLE LENGTH
JSR             EQU  00*2+NL           ; JSR = 40
JMP             EQU  01*2+NL           ; JMP = 42
JSRS            EQU  02*2+NL           ; JSRS = 44
FOR             EQU  03*2+NL           ; Beepola doesn't use FOR/NEXT loop
NEXT            EQU  04*2+NL           ; but you can hand optimise your data
SDRUM           EQU  05*2+NL           ; SDRUM = SET DRUM    = 50
PBEND           EQU  06*2+NL           ; Pitch Bend/Glissando
TRANS           EQU  07*2+NL           ; Transpose (in semitones, not used by Beepola)

GOSUB           EQU  00*2+128          ; GOSUB for drum patterns
GOTO            EQU  01*2+128          ; GOTO/FOR/NEXT for drum loops aren't
FORD            EQU  02*2+128          ; used by Beepola, but you can use them
NEXD            EQU  03*2+128          ; by hand to make your data slightly smaller
RTSD            EQU  04*2+128          ; RETURN from SUB (Drum pattern)
ENDX            EQU  05*2+128          ; END

RTS             EQU  255                ; ReTurn from Subroutine

TOM2            EQU  00
BASS            EQU  32
SNARE           EQU  64
TOM1            EQU  96

YES             EQU  $000               ; NOP
NO              EQU  $0AF               ; XOR A

DATATABLE:
NOTES:          DEFW   000
               DEFW   948,894,844,798
               DEFW   752,710,670,633
               DEFW   597,564,532,502

               DEFW   474,447,422,399
               DEFW   376,355,335,316
               DEFW   299,282,266,251

               DEFW   237,224,211,199
               DEFW   188,178,168,158
               DEFW   149,141,133,126

               DEFW   118,112,106,100
               DEFW   094,089,084,079
               DEFW   075,070,067,063

CODES:          DEFW   JSR_
               DEFW   JMP_
               DEFW   JSRS_
               DEFW   FOR_
               DEFW   NEXT_
               DEFW   SDRUM_
               DEFW   PBEND_
               DEFW   TRANS_

DRUMCODE:       DEFW   GOSUB_
               DEFW   GOTO_
               DEFW   FORD_
               DEFW   NEXD_
               DEFW   GETDR_STK
               DEFW   END_

DRUMJPS:        DEFW   TOM2_
               DEFW   SNARE_
               DEFW   BASS_
               DEFW   TOM1_

STACKPOS:       DEFW   STACKSTR
LOOPPOS:        DEFW   LOOPSTR
DRUMSTK:        DEFW   DRUM_STK
DRUMLOOP:       DEFW   DRUM_LOOP

MUSICVARS:      DEFW   STACKSTR
               DEFW   LOOPSTR
               DEFW   DRUM_STK
               DEFW   DRUM_LOOP

DRUMNUM:        DEFB   0
DRUMCOUNT:      DEFB   0
DRUMPOS:        DEFW   0
OLDNOTE:        DEFW   0
ENDNOTE:        DEFW   0

STACKSTR:       DEFS   2*16,0
LOOPSTR:        DEFS   1*16,0
DRUM_STK:       DEFS   2*16,0
DRUM_LOOP:      DEFS   1*16,0

PLAYMUSIC:
               LD   A,(HL)
               LD   (KEYCHECK),A    ; whether to test for keypress or not
               LD   (KEYCHECK2),A   ; whether to test for keypress or not
               INC  HL

MUSIC:          DI
               PUSH HL
               LD   HL,TIMER_INT
               LD   (INTJUMP),HL    ; Setup interrupt routine to point to TIMER_INT
               LD   HL,MUSICVARS
               LD   DE,STACKPOS
               LD   BC,8
               LDIR
               POP  HL
               XOR  A
               LD   (DRUMNUM),A
               LD   (TRANSPK+1),A
               INC  A
               LD   (DRUMCOUNT),A

INTERP:         LD   A,(HL)              ; get the note/code
               INC  HL
               CP   RTS                 ; Is it an RTS
               RET  Z                   ; exit if so
               CP   JSR                 ; is it less than JSR (i.e. Is it a note value)
               EXX
               LD   HL,DATATABLE
               JR   C,IS_NOTE           ; It's a note rather than a code

               ADD  A,49
               LD   D,0
               LD   E,A
               ADD  HL,DE
               LD   A,(HL)
               INC  HL
               LD   H,(HL)
               LD   L,A
               CALL JPHL
               JR   INTERP

IS_NOTE:        OR   A
               JR   Z,IS_REST
TRANSPK:        ADD  A,0
               ADD  A,A
               LD   HL,DATATABLE
               LD   D,0
               LD   E,A
               ADD  HL,DE
               LD   C,(HL)
               INC  HL
               LD   B,(HL)
               LD   (OLDNOTE),BC
               EXX
               LD   A,(HL)
               INC  HL
               EXX
               DEC  A
               LD   L,A
               EI
               CALL BUZZ
               INC  HL
               JR   IS_R

IS_REST:        EXX
               LD   A,(HL)
               INC  HL
               EXX
               LD   L,A
IS_R:           CALL RESTLP
               DI
               EXX
               JR   INTERP

RESTLP:         EI
               XOR  A
               IN   A,(254)
               CPL
KEYCHECK:       NOP                ;  XOR A or NOP
               AND  %00011111
               JR   Z,RESTLP
               JP   EXIT


;		ld 	a, ($68fd)			; ======   VZ press <s> to continue   ======
;		and	$02
;		jr 	z, STOP_PLAYER



BUZZ:           EI
               XOR  A
               EX   AF,AF'
               LD   D,B
               LD   E,C
               DEC  DE
               LD   (BUZZ1+1),BC
               LD   (BUZZ3+1),DE
               SRL  D
               RR   E

BUZZ0:          DEC  BC
               LD   A,B
               OR   C
               JP   NZ,BUZZ2

BUZZ1:          LD   BC,0
               EX   AF,AF'
		LD 	A, $21
		LD	($6800), A

               EX   AF,AF'
               JP   BUZZ2

BUZZ2:          DEC  DE
               LD   A,D
               OR   E
               JP   NZ,BUZZ0

BUZZ3:          LD   DE,0
               EX   AF,AF'
		LD	A, $21
		LD	($6800), A
               EX   AF,AF'
               JP   BUZZ0

TIMER_INT:
               PUSH AF
               XOR  A                   ; test for keypress
               IN   A,(254)
               CPL
KEYCHECK2:      NOP                      ; NOP or XOR A
               AND  %00011111
               JP   NZ,EXIT

               LD   A,(DRUMNUM)
               OR   A
               JR   Z,NODRUMS
               LD   A,(DRUMCOUNT)
               DEC  A
               LD   (DRUMCOUNT),A
               JR   NZ,NODRUMS

               POP  AF
               LD   IX,DRUMS
               PUSH IX
RUPT:           EI
               RETI

NODRUMS:        DEC  L
               JR   NZ,NO_ESCAPE

               POP  AF
NO_ESCAPE:      POP  AF
               EI
               RETI

DRUMS:          PUSH AF
               PUSH BC
               PUSH DE
               DEC  L
               JR   NZ,DRUMS0
               INC  L

DRUMS0:         PUSH HL
               LD   HL,DRUM_INT
               LD   (INTJUMP),HL
               EI
               LD   HL,(DRUMPOS)

INTERP_D:       LD   A,(HL)
               INC  HL
               OR   A
               JP   P,IS_DRUM

IS_CODE:        AND  127
               EX   DE,HL
               ADD  A,114
               CALL TABJUMP
               JR   INTERP_D

IS_DRUM:        LD   C,A
               AND  31
               DEC  A
               LD   (DRUMCOUNT),A
               LD   A,C
               RLCA
               RLCA
               RLCA
               AND  3
               ADD  A,A
               LD   (DRUMPOS),HL

               ADD  A,126

TABJUMP:        LD   HL,DATATABLE
               PUSH DE
               LD   E,A
               LD   D,0
               ADD  HL,DE
               LD   A,(HL)
               INC  HL
               LD   H,(HL)
               LD   L,A
               POP  DE
JPHL:           JP   (HL)

DRUM_INT:       LD   HL,TIMER_INT
               LD   (INTJUMP),HL
               POP  IX
               POP  HL
               POP  DE
               POP  BC
               JP   NODRUMS

TOM2_:          LD   C,0
TOM2_0:         LD   B,C
a1:             DJNZ a1
               LD   A,$21
		LD	($6800), A
               INC  C
               INC  C
               LD   B,C
a2:             DJNZ a2
		LD 	A, $21
		LD	($6800), A
               JR   TOM2_0

BASS_:          LD   C,%00111111
BASS_0:         LD   B,C
a3:             DJNZ a3
               LD   	A,$21
		LD	($6800), A
               LD   A,C
               RRCA
               LD   C,A
               LD   B,A
a4:             DJNZ a4
		LD	A, $21
		LD	($6800), A
               JR   BASS_0

SNARE_:         LD   HL,3864
SNARE_0:        LD   B,(HL)
a5:             DJNZ a5
		LD	A, $21
		LD	($6800), A
               INC  HL
               LD   B,(HL)
a6:             DJNZ a6
		LD	A, $21
		LD	($6800), A
               INC  HL
               JR   SNARE_0

TOM1_:          LD   C,0
TOM1_0:         LD   B,C
a7:             DJNZ a7
		LD	A, $21
		LD	($6800), A
               LD   A,C
               ADD  A,4
               LD   C,A
               LD   B,A
a8:             DJNZ a8
		LD	A, $21
		LD	($6800), A
               JR   TOM1_0

GOSUB_:         EX   DE,HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)
               INC  HL
               EX   DE,HL
               JR   PUTDR_STK

GOTO_:          EX   DE,HL
               LD   A,(HL)
               INC  HL
               LD   H,(HL)
               LD   L,A
               RET

FORD_:          LD   A,(DE)
               INC  DE
               LD   HL,(DRUMLOOP)
               LD   (HL),A
               INC  L
               LD   (DRUMLOOP),HL
               LD   L,E
               LD   H,D
               JR   PUTDR_STK

NEXD_:          LD   HL,(DRUMLOOP)
               DEC  HL
               DEC  (HL)
               JR   NZ,NEXD_0

               LD   (DRUMLOOP),HL
               PUSH DE
               CALL GETDR_STK
               POP  HL
               RET

NEXD_0:         EX   DE,HL
               CALL GETDR_STK
               LD   E,L
               LD   D,H

PUTDR_STK:      PUSH HL
               LD   HL,(DRUMSTK)
               LD   (HL),E
               INC  L
               LD   (HL),D
               INC  L
               LD   (DRUMSTK),HL
               POP  HL
               RET

GETDR_STK:      LD   HL,(DRUMSTK)
               DEC  L
               LD   D,(HL)
               DEC  L
               LD   E,(HL)
               LD   (DRUMSTK),HL
               EX   DE,HL
               RET

END_:           XOR  A
               LD   (DRUMNUM),A
               EX   DE,HL
               RET

JSR_:           EXX
               LD   A,(HL)
               INC  HL
               PUSH HL
               LD   H,(HL)
               LD   L,A
               CALL INTERP
               POP  HL
               INC  HL
               RET

JMP_:           EXX
               LD   A,(HL)
               INC  HL
               LD   H,(HL)
               LD   L,A
               RET

JSRS_:          EXX
JSRS_0:         LD   A,(HL)
               INC  HL
               CP   RTS
               RET  Z
               LD   E,A
               LD   D,(HL)
               INC  HL
               PUSH HL
               EX   DE,HL
               CALL INTERP
               POP  HL
               JR   JSRS_0

FOR_:           EXX
               LD   A,(HL)
               INC  HL
               EXX
               LD   HL,(LOOPPOS)
               LD   (HL),A
               INC  L
               LD   (LOOPPOS),HL
               EXX
               LD   E,L
               LD   D,H

PUTSTACK:       PUSH HL
               LD   HL,(STACKPOS)
               LD   (HL),E
               INC  L
               LD   (HL),D
               INC  L
               LD   (STACKPOS),HL
               POP  HL
               RET

GETSTACK:       LD   HL,(STACKPOS)
               DEC  L
               LD   D,(HL)
               DEC  L
               LD   E,(HL)
               LD   (STACKPOS),HL
               EX   DE,HL
               RET

NEXT_:          LD   HL,(LOOPPOS)
               DEC  L
               DEC  (HL)
               JR   Z,MOVEON
               EXX
               CALL GETSTACK
               LD   E,L
               LD   D,H
               JR   PUTSTACK

MOVEON:         LD   (LOOPPOS),HL
               CALL GETSTACK
               EXX
               RET

SDRUM_:         EXX
               LD   A,(HL)
               INC  HL
               LD   (DRUMCOUNT),A
               LD   E,(HL)
               INC  HL
               LD   D,(HL)
               INC  HL
               LD   (DRUMPOS),DE
               LD   A,255
               LD   (DRUMNUM),A
               RET

PBEND_:         EXX
               LD   A,(HL)
               INC  HL
               LD   C,(HL)
               INC  HL
               LD   B,(HL)
               INC  HL
               PUSH BC
               EXX
               POP  BC
               ADD  A,A
               LD   E,A
               LD   D,0
               LD   HL,DATATABLE
               ADD  HL,DE
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   (ENDNOTE),DE

PBEND_LP:       PUSH BC
               LD   HL,(OLDNOTE)
               LD   A,C
               OR   A
               JP   P,POSCHECK
NEGCHECK:       ADD  A,L
               LD   L,A
               LD   A,H
               CCF
               SBC  A,0
               LD   H,A
               XOR  A
               LD   (CARRY),A

DO16CP:         LD   C,L
               LD   B,H
               LD   HL,(ENDNOTE)
               SBC  HL,BC
CARRY:          CCF
               JR   C,NOTEND_N
               LD   BC,(ENDNOTE)
NOTEND_N:       LD   (OLDNOTE),BC
               LD   L,1
               CALL BUZZ
		LD	A, $21
		LD	($6800), A
               DI
               POP  BC
               DJNZ PBEND_LP
               EXX
               RET

POSCHECK:       ADD  A,L
               LD   L,A
               LD   A,H
               ADC  A,0
               LD   H,A
               LD   A,$03F
               LD   (CARRY),A
               JR   DO16CP

TRANS_:         EXX
               LD   A,(HL)
               INC  HL
               LD   (TRANSPK+1),A
               RET


; ************************************************************************
; * Song data...
; ************************************************************************
VECTOR_TABLE_LOC    EQU $FE00
BORDER_CLR          EQU $0

; *** DATA ***
MUSICDATA:        DEFB YES  ; Exit player on keypress

; Beepola uses JSR to jump to individual pattern subroutines rather than the
; slightly shorter JSRS (which takes a list of WORD addresses, terminated by
; a single $FF). This is because we can't be sure that a pattern address
; won't end up as $xxFF. A bit of hand-optimisation of this output (also
; utilising FOR/NEXT and JMP) should yield much smaller music data.

LOOPSTARTPOS:    DEFB JSR
               DEFW PAT0
               DEFB JSR
               DEFW PAT0
               DEFB JSR
               DEFW PAT1
               DEFB JSR
               DEFW PAT1
               DEFB JSR
               DEFW PAT0
               DEFB JSR
               DEFW PAT0
               DEFB JSR
               DEFW PAT1
               DEFB JSR
               DEFW PAT1
               DEFB JSR
               DEFW PAT2
               DEFB JSR
               DEFW PAT2
               DEFB JSR
               DEFW PAT3
               DEFB JSR
               DEFW PAT3
               DEFB JSR
               DEFW PAT2
               DEFB JSR
               DEFW PAT2
               DEFB JSR
               DEFW PAT3
               DEFB JSR
               DEFW PAT3
               DEFB JSR
               DEFW PAT4
               DEFB JSR
               DEFW PAT4
               DEFB JSR
               DEFW PAT3
               DEFB JSR
               DEFW PAT3
               DEFB JSR
               DEFW PAT4
               DEFB JSR
               DEFW PAT4
               DEFB JSR
               DEFW PAT3
               DEFB JSR
               DEFW PAT3
               DEFB JSR
               DEFW PAT5
               DEFB JSR
               DEFW PAT5
               DEFB JSR
               DEFW PAT6
               DEFB JMP
               DEFW LOOPSTARTPOS

; Pattern data...
PAT0:
               DEFB SDRUM
               DEFB 1 ; number of frames before 1st drum
               DEFW DRUMPAT0
               DEFB 22,12
               DEFB 24,12
               DEFB 26,12
               DEFB 14,12
               DEFB 22,6
               DEFB 15,6
               DEFB 24,6
               DEFB 15,6
               DEFB 26,6
               DEFB 15,6
               DEFB 26,6
               DEFB 15,6
               DEFB RTS

DRUMPAT0:       DEFB 56
               DEFB 88
               DEFB 44
               DEFB 44
               DEFB 88
               DEFB ENDX

PAT1:              DEFB SDRUM
               DEFB 1 ; number of frames before 1st drum
               DEFW DRUMPAT1
               DEFB 10,12
               DEFB 12,12
               DEFB 14,12
               DEFB 15,12
               DEFB 15,12
               DEFB 15,12
               DEFB 14,12
               DEFB 12,12
               DEFB RTS

DRUMPAT1:      DEFB 56
               DEFB 88
               DEFB 44
               DEFB 44
               DEFB 88
               DEFB ENDX

PAT2:          DEFB SDRUM
               DEFB 1 ; number of frames before 1st drum
               DEFW DRUMPAT2
               DEFB 22,12
               DEFB 22,12
               DEFB 24,6
               DEFB 26,6
               DEFB 27,12
               DEFB 22,12
               DEFB 22,12
               DEFB 24,6
               DEFB 26,6
               DEFB 27,12
               DEFB RTS

DRUMPAT2:      DEFB 56
               DEFB 88
               DEFB 44
               DEFB 44
               DEFB 76
               DEFB 76
               DEFB ENDX

PAT3:         DEFB SDRUM
               DEFB 1 ; number of frames before 1st drum
               DEFW DRUMPAT3
               DEFB 22,12
               DEFB 22,12
               DEFB 24,6
               DEFB 26,6
               DEFB 27,12
               DEFB 22,12
               DEFB 22,12
               DEFB 24,6
               DEFB 26,6
               DEFB 27,12
               DEFB RTS

DRUMPAT3:       DEFB 56
               DEFB 88
               DEFB 44
               DEFB 44
               DEFB 76
               DEFB 76
               DEFB ENDX

PAT4:       DEFB SDRUM
               DEFB 1 ; number of frames before 1st drum
               DEFW DRUMPAT4
               DEFB 24,12
               DEFB 24,12
               DEFB 26,6
               DEFB 28,6
               DEFB 29,12
               DEFB 24,12
               DEFB 24,12
               DEFB 26,6
               DEFB 28,6
               DEFB 29,12
               DEFB RTS

DRUMPAT4:     DEFB 56
               DEFB 88
               DEFB 44
               DEFB 44
               DEFB 76
               DEFB 76
               DEFB ENDX

PAT5:        DEFB SDRUM
               DEFB 1 ; number of frames before 1st drum
               DEFW DRUMPAT5
               DEFB 14,12
               DEFB 14,12
               DEFB 14,6
               DEFB 15,6
               DEFB 17,12
               DEFB 14,12
               DEFB 14,12
               DEFB 14,6
               DEFB 15,6
               DEFB 17,12
               DEFB RTS

DRUMPAT5:      DEFB 12
               DEFB 76
               DEFB 6
               DEFB 70
               DEFB 6
               DEFB 70
               DEFB 6
               DEFB 70
               DEFB 6
               DEFB 70
               DEFB 6
               DEFB 6
               DEFB 6
               DEFB 6
               DEFB ENDX

PAT6:      DEFB SDRUM
               DEFB 1 ; number of frames before 1st drum
               DEFW DRUMPAT6
               DEFB 10,12
               DEFB 10,12
               DEFB 12,6
               DEFB 12,42
               DEFB 10,6
               DEFB 10,18
               DEFB RTS

DRUMPAT6:     DEFB 12
               DEFB 12
               DEFB 6
               DEFB 70
               DEFB 6
               DEFB 70
               DEFB 6
               DEFB 82
               DEFB 6
               DEFB 12
               DEFB 6
               DEFB ENDX

