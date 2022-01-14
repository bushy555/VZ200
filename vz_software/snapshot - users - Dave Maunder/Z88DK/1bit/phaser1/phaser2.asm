

;Phaser - ZX Spectrum beeper engine
;by utz 08'2014
;
; BUILD WITH :  zcc +vz -zorg=32768 -O3 -vn -m anteat.c anteat.asm -o anteat.vz -create-app -lndos
;
XDEF _phaser1
_phaser1:
; *****************************************************************************
; * Phaser1 Engine, with synthesised drums
; *
; * Original code by Shiru - http://shiru.untergrund.net/
;******************************************************************************
defc BORDER_COL = $00
START:
LD HL,MUSICDATA ; <- Pointer to Music Data. Change
; this to play a different song
LD A,(HL) ; Get the loop start pointer
LD (PATTERN_LOOP_BEGIN),A
INC HL
LD A,(HL) ; Get the song end pointer
LD (PATTERN_LOOP_END),A
INC HL
LD E,(HL)
INC HL
LD D,(HL)
INC HL
LD (INSTRUM_TBL),HL
LD (CURRENT_INST),HL
ADD HL,DE
LD (PATTERN_ADDR),HL
XOR A
LD (PATTERN_PTR),A ; Set the pattern pointer to zero
LD H,A
LD L,A
LD (NOTE_PTR),HL ; Set the note offset (within this pattern) to 0
PLAYER:
DI
PUSH IY
LD A,BORDER_COL
LD H,$00
LD L,A
LD (CNT_1A),HL
LD (CNT_1B),HL
LD (DIV_1A),HL
LD (DIV_1B),HL
LD (CNT_2),HL
LD (DIV_2),HL
LD A,3; LD A,BORDER_COL
LD (OUT_1),A
LD A,4; LD A,BORDER_COL
LD (OUT_2),A
JR MAIN_LOOP
; ********************************************************************************************************
; * NEXT_PATTERN
; *
; * Select the next pattern in sequence (and handle looping if we've reached PATTERN_LOOP_END
; * Execution falls through to PLAYNOTE to play the first note from our next pattern
; ********************************************************************************************************
NEXT_PATTERN:
LD A,(PATTERN_PTR)
INC A
INC A
DEFB $FE ; CP n
PATTERN_LOOP_END: DEFB 0
JR NZ,NO_PATTERN_LOOP
; Handle Pattern Looping at and of song
DEFB $3E ; LD A,n
PATTERN_LOOP_BEGIN: DEFB 0
NO_PATTERN_LOOP: LD (PATTERN_PTR),A
LD HL,$0000
LD (NOTE_PTR),HL ; Start of pattern (NOTE_PTR = 0)
MAIN_LOOP:
LD IYL,0 ; Set channel = 0
READ_LOOP:
LD HL,(PATTERN_ADDR)
LD A,(PATTERN_PTR)
LD E,A
LD D,0
ADD HL,DE
LD E,(HL)
INC HL
LD D,(HL) ; Now DE = Start of Pattern data
LD HL,(NOTE_PTR)
INC HL ; Increment the note pointer and...
LD (NOTE_PTR),HL ; ..store it
DEC HL
ADD HL,DE ; Now HL = address of note data
LD A,(HL)
OR A
JR Z,NEXT_PATTERN ; select next pattern
BIT 7,A
JP Z,RENDER ; Play the currently defined note(S) and drum
LD IYH,A
AND $3F
CP $3C
JP NC,OTHER ; Other parameters
ADD A,A
LD B,0
LD C,A
LD HL,FREQ_TABLE
ADD HL,BC
LD E,(HL)
INC HL
LD D,(HL)
LD A,IYL ; IYL = 0 for channel 1, or = 1 for channel 2
OR A
JR NZ,SET_NOTE2
LD (DIV_1A),DE
EX DE,HL
DEFB $DD,$21 ; LD IX,nn
CURRENT_INST:
DEFW $0000
LD A,(IX+$00)
OR A
JR Z,L809B ; Original code jumps into byte 2 of the DJNZ (invalid opcode FD)
LD B,A
L8098: ADD HL,HL
DJNZ L8098
L809B: LD E,(IX+$01)
LD D,(IX+$02)
ADD HL,DE
LD (DIV_1B),HL
LD IYL,1 ; Set channel = 1
LD A,IYH
AND $40
JR Z,READ_LOOP ; No phase reset
LD HL,OUT_1 ; Reset phaser
RES 4,(HL)
LD HL,$0000
LD (CNT_1A),HL
LD H,(IX+$03)
LD (CNT_1B),HL
JR READ_LOOP
SET_NOTE2:
LD (DIV_2),DE
LD A,IYH
LD HL,OUT_2
RES 4,(HL)
LD HL,$0000
LD (CNT_2),HL
JP READ_LOOP
SET_STOP:
LD HL,$0000
LD A,IYL
OR A
JR NZ,SET_STOP2
; Stop channel 1 note
LD (DIV_1A),HL
LD (DIV_1B),HL
LD HL,OUT_1
RES 4,(HL)
LD IYL,1
JP READ_LOOP
SET_STOP2:
; Stop channel 2 note
LD (DIV_2),HL
LD HL,OUT_2
RES 4,(HL)
JP READ_LOOP
OTHER: CP $3C
JR Z,SET_STOP ; Stop note
CP $3E
JR Z,SKIP_CH1 ; No changes to channel 1
INC HL ; Instrument change
LD L,(HL)
LD H,$00
ADD HL,HL
LD DE,(NOTE_PTR)
INC DE
LD (NOTE_PTR),DE ; Increment the note pointer
DEFB $01; LD BC,nn
INSTRUM_TBL:
DEFW $0000
ADD HL,BC
LD (CURRENT_INST),HL
JP READ_LOOP
SKIP_CH1:
LD IYL,$01
JP READ_LOOP
EXIT_PLAYER:
LD HL,$2758
EXX
POP IY
EI
RET
RENDER:
AND $7F; L813A
CP $76
JP NC,DRUMS
LD D,A
EXX
DEFB $21; LD HL,nn
CNT_1A: DEFW $0000
DEFB $DD,$21 ; LD IX,nn
CNT_1B: DEFW $0000
DEFB $01; LD BC,nn
DIV_1A: DEFW $0000
DEFB $11; LD DE,nn
DIV_1B: DEFW $0000
DEFB $3E; LD A,n
OUT_1: DEFB $0
EXX
EX AF,AF'
DEFB $21; LD HL,nn
CNT_2: DEFW $0000
DEFB $01; LD BC,nn
DIV_2: DEFW $0000
DEFB $3E; LD A,n
OUT_2: DEFB $00
PLAY_NOTE:
; Read keyboard
LD E,A
XOR A
IN A,($FE)
OR $E0
INC A
PLAYER_WAIT_KEY:
JR NZ,EXIT_PLAYER
LD A,E
LD E,0
L8168: EXX
EX AF,AF'
ADD HL,BC
ld	(26624), a
JR C,L8171
JR L8173
;L8171: XOR $10
L8171: XOR 33
L8173: ADD IX,DE
JR C,L8179
JR L817B
;L8179: XOR $10
L8179: XOR 33
L817B: EX AF,AF'
	ld (26624), a
EXX
ADD HL,BC
JR C,L8184
JR L8186
;L8184: XOR $10
L8184: XOR 33
L8186: NOP
JP L818A
L818A: EXX
EX AF,AF'
ADD HL,BC
	ld (26624), a
JR C,L8193
JR L8195
;L8193: XOR $10
L8193: XOR 33
L8195: ADD IX,DE
JR C,L819B
JR L819D
;L819B: XOR $10
L819B: XOR 33
L819D: EX AF,AF'
ld (26624), a
EXX
ADD HL,BC
JR C,L81A6
JR L81A8
;L81A6: XOR $10
L81A6: XOR 33
L81A8: NOP
JP L81AC
L81AC: EXX
EX AF,AF'
ADD HL,BC
ld (26624), a
JR C,L81B5
JR L81B7
;L81B5: XOR $10
L81B5: XOR 33
L81B7: ADD IX,DE
JR C,L81BD
JR L81BF
;L81BD: XOR $10
L81BD: XOR 33
L81BF: EX AF,AF'
ld (26624), a
EXX
ADD HL,BC
JR C,L81C8
JR L81CA
;L81C8: XOR $10
L81C8: XOR 33
L81CA: NOP
JP L81CE
L81CE: EXX
EX AF,AF'
ADD HL,BC
	ld (26624), a
JR C,L81D7
JR L81D9
;L81D7: XOR $10
L81D7: XOR 33
L81D9: ADD IX,DE
JR C,L81DF
JR L81E1
;L81DF: XOR $10
L81DF: XOR 33
L81E1: EX AF,AF'
ld (26624), a
EXX
ADD HL,BC
JR C,L81EA
JR L81EC
;L81EA: XOR $10
L81EA: XOR 33
L81EC: DEC E
JP NZ,L8168
EXX
EX AF,AF'
ADD HL,BC
ld (26624), a
JR C,L81F9
JR L81FB
;L81F9: XOR $10
L81F9: XOR 33
L81FB: ADD IX,DE
JR C,L8201
JR L8203
;L8201: XOR $10
L8201: XOR 33
L8203: EX AF,AF'
ld (26624), a
EXX
ADD HL,BC
JR C,L820C
JR L820E
;L820C: XOR $10
L820C: XOR 33
L820E: DEC D
JP NZ,PLAY_NOTE
LD (CNT_2),HL
LD (OUT_2),A
EXX
EX AF,AF'
LD (CNT_1A),HL
LD (CNT_1B),IX
LD (OUT_1),A
JP MAIN_LOOP
; ************************************************************
; * DRUMS - Synthesised
; ************************************************************
DRUMS:
ADD A,A; On entry A=$75+Drum number (i.e. $76 to $7E)
LD B,0
LD C,A
LD HL,DRUM_TABLE - 236
ADD HL,BC
LD E,(HL)
INC HL
LD D,(HL)
EX DE,HL
JP (HL)
DRUM_TONE1: LD L,16
JR DRUM_TONE
DRUM_TONE2: LD L,12
JR DRUM_TONE
DRUM_TONE3: LD L,8
JR DRUM_TONE
DRUM_TONE4: LD L,6
JR DRUM_TONE
DRUM_TONE5: LD L,4
JR DRUM_TONE
DRUM_TONE6: LD L,2
DRUM_TONE:
LD DE,3700
LD BC,$0101
LD A,3;LD A,BORDER_COL
DT_LOOP0: ld (26624), a
DEC B
JR NZ,DT_LOOP1
XOR 16
LD B,C
EX AF,AF'
LD A,C
ADD A,L
LD C,A
EX AF,AF'
DT_LOOP1: DEC E
JR NZ,DT_LOOP0
DEC D
JR NZ,DT_LOOP0
JP MAIN_LOOP
DRUM_NOISE1: LD DE,2480
LD IXL,1
JR DRUM_NOISE
DRUM_NOISE2: LD DE,1070
LD IXL,10
JR DRUM_NOISE
DRUM_NOISE3: LD DE,365
LD IXL,101
DRUM_NOISE:
LD H,D
LD L,E
LD A,4;LD A,BORDER_COL
LD C,A
DN_LOOP0: LD A,(HL)
AND 16
OR C
ld (26624), a
LD B,IXL
DN_LOOP1: DJNZ DN_LOOP1
INC HL
DEC E
JR NZ,DN_LOOP0
DEC D
JR NZ,DN_LOOP0
JP MAIN_LOOP






PATTERN_ADDR: DEFW $0000
PATTERN_PTR: DEFB 0
NOTE_PTR: DEFW $0000
; **************************************************************
; * Frequency Table
; **************************************************************
FREQ_TABLE:
DEFW 178,189,200,212,225,238,252,267,283,300,318,337
DEFW 357,378,401,425,450,477,505,535,567,601,637,675
DEFW 715,757,802,850,901,954,1011,1071,1135,1202,1274,1350
DEFW 1430,1515,1605,1701,1802,1909,2023,2143,2270,2405,2548,2700
DEFW 2860,3030,3211,3402,3604,3818,4046,4286,4541,4811,5097,5400
; *****************************************************************
; * Synth Drum Lookup Table
; *****************************************************************
DRUM_TABLE:
DEFW DRUM_TONE1,DRUM_TONE2,DRUM_TONE3,DRUM_TONE4,DRUM_TONE5,DRUM_TONE6
DEFW DRUM_NOISE1,DRUM_NOISE2,DRUM_NOISE3






smpData:defb $02,$02,$02,$02,$00,$00,$02,$00,$0e,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$08,$10,$10,$10
	defb $18,$70,$70,$70,$70,$70,$70,$70,$74,$70,$50,$50,$d8,$d0,$d0,$d0,$d4,$d0,$d0,$d0,$d0,$d0,$d0,$d0
	defb $d4,$d1,$d1,$d1,$5d,$41,$41,$41,$41,$41,$41,$41,$4d,$41,$41,$41,$49,$41,$41,$41,$47,$41,$41,$60
	defb $6c,$22,$20,$20,$2e,$22,$20,$20,$22,$22,$22,$22,$26,$32,$32,$32,$36,$32,$32,$32,$36,$b2,$b2,$b2
	defb $b2,$b2,$32,$32,$3e,$32,$32,$b2,$b2,$b2,$b2,$b2,$be,$12,$12,$11,$17,$13,$93,$93,$97,$83,$83,$c3
	defb $cb,$c3,$c3,$c3,$cb,$c3,$c1,$c1,$c9,$c1,$c1,$c1,$c5,$c1,$c1,$c1,$41,$41,$41,$41,$4d,$41,$41,$41
	defb $41,$40,$40,$40,$6c,$60,$70,$70,$78,$70,$70,$70,$7c,$70,$70,$70,$74,$70,$70,$70,$70,$70,$70,$70
	defb $34,$30,$30,$30,$38,$30,$30,$30,$38,$30,$30,$b0,$b8,$b0,$b0,$b0,$a4,$a0,$a0,$a0,$84,$80,$80,$80
	defb $8c,$80,$80,$80,$8c,$82,$82,$82,$8c,$80,$82,$82,$8e,$83,$81,$83,$8f,$83,$83,$83,$87,$83,$83,$83
	defb $87,$d3,$d3,$d3,$d7,$d3,$d3,$53,$53,$53,$73,$73,$77,$73,$73,$73,$7b,$73,$73,$73,$73,$73,$73,$73
	defb $73,$73,$73,$73,$77,$73,$73,$73,$7d,$73,$73,$71,$6d,$61,$60,$60,$6c,$62,$62,$62,$62,$60,$60,$60
	defb $64,$60,$60,$20,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$04,$00,$90,$90
	defb $1c,$10,$10,$10,$90,$90,$90,$90,$18,$10,$10,$10,$90,$90,$90,$10,$1c,$10,$10,$10,$1c,$30,$30,$30
	defb $34,$b0,$b0,$b0,$34,$30,$f0,$f0,$f4,$f0,$e0,$e0,$e4,$e0,$e0,$60,$68,$e0,$e0,$e0,$e0,$e2,$e2,$e2
	defb $e6,$e0,$e2,$e0,$e6,$e3,$e3,$e3,$e3,$61,$63,$e3,$e7,$e3,$43,$43,$4f,$41,$41,$41,$43,$53,$53,$53
	defb $57,$53,$53,$53,$57,$53,$53,$53,$13,$13,$13,$13,$17,$13,$13,$13,$1b,$13,$13,$11,$19,$13,$13,$11
	defb $11,$11,$13,$11,$11,$11,$11,$13,$1b,$33,$33,$a1,$a3,$a1,$a1,$a1,$21,$21,$a1,$a1,$a9,$a0,$a0,$a0
	defb $a0,$a0,$20,$20,$28,$20,$a0,$a0,$a0,$20,$20,$a0,$e0,$e0,$60,$e0,$e0,$e0,$e0,$e0,$e8,$60,$60,$70
	defb $78,$f0,$f0,$f0,$d8,$50,$50,$50,$58,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$58,$50,$50,$50
	defb $50,$50,$50,$50,$50,$50,$50,$50,$5c,$50,$50,$50,$54,$40,$42,$40,$00,$02,$00,$00,$00,$00,$20,$20
	defb $20,$22,$22,$22,$22,$22,$20,$22,$2a,$20,$22,$22,$22,$20,$22,$22,$26,$22,$20,$22,$26,$22,$20,$22
	defb $22,$22,$a2,$b2,$b8,$b0,$b0,$b2,$b2,$b2,$b2,$32,$32,$b2,$b0,$b2,$b0,$b0,$32,$90,$90,$92,$52,$51
	defb $51,$51,$d1,$d1,$d9,$d1,$51,$51,$51,$51,$53,$d1,$d9,$51,$51,$d3,$d3,$51,$41,$c1,$c1,$c1,$c1,$c1
	defb $c9,$c1,$c1,$c1,$41,$41,$c1,$c1,$c9,$c1,$c1,$41,$c9,$c1,$c1,$61,$69,$e1,$e1,$e1,$61,$61,$61,$61
	defb $61,$61,$61,$61,$29,$21,$21,$21,$25,$31,$31,$31,$35,$31,$31,$31,$39,$b1,$b1,$31,$31,$31,$31,$31
	defb $31,$b1,$32,$30,$b0,$b0,$30,$30,$34,$30,$32,$32,$14,$10,$10,$10,$10,$10,$10,$10,$10,$90,$92,$12
	defb $10,$92,$82,$02,$00,$00,$00,$02,$8a,$02,$02,$02,$ce,$40,$40,$40,$40,$42,$40,$42,$4a,$c2,$c2,$42
	defb $40,$40,$40,$40,$48,$c2,$42,$42,$48,$40,$60,$60,$ea,$62,$62,$e2,$ea,$60,$70,$70,$70,$70,$f0,$f0
	defb $70,$70,$72,$70,$7a,$72,$70,$70,$f0,$f0,$70,$f0,$f0,$70,$70,$f0,$f2,$70,$f0,$b0,$3c,$30,$30,$30
	defb $34,$30,$30,$30,$30,$b0,$b0,$30,$b0,$90,$10,$00,$00,$00,$00,$80,$82,$02,$00,$00,$00,$00,$00,$00
	defb $00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	defb $00,$00,$00,$00,$00,$50,$50,$50,$58,$72,$70,$70,$70,$70,$70,$70,$70,$70,$70,$72,$7a,$72,$72,$70
	defb $f8,$f0,$f0,$f2,$7a,$70,$70,$70,$f0,$f0,$f0,$70,$70,$70,$72,$f2,$f0,$70,$70,$f2,$f2,$f0,$f0,$e0
	defb $e8,$e2,$60,$60,$e0,$e0,$e2,$e2,$ea,$c0,$c2,$c2,$c2,$42,$00,$82,$82,$82,$80,$82,$80,$80,$80,$80
	defb $80,$80,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$10,$10,$10,$10,$10,$10
	defb $18,$10,$10,$10,$12,$10,$10,$10,$10,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$70
	defb $70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60
	defb $68,$60,$60,$60,$60,$60,$60,$60,$68,$60,$60,$c0,$c8,$c0,$c0,$c0,$c0,$40,$40,$40,$40,$c0,$c0,$40
	defb $40,$42,$40,$c2,$c8,$c0,$40,$42,$c2,$c2,$10,$10,$98,$90,$92,$92,$12,$12,$10,$10,$10,$10,$10,$10
	defb $9a,$92,$90,$90,$98,$90,$90,$90,$12,$12,$92,$90,$b0,$b0,$30,$30,$38,$30,$30,$30,$38,$30,$30,$30
	defb $3a,$30,$32,$30,$30,$30,$20,$22,$20,$a0,$a0,$20,$28,$a0,$a2,$a2,$a0,$20,$20,$20,$20,$60,$60,$60
	defb $60,$60,$62,$60,$68,$e0,$e0,$e0,$e0,$e0,$60,$60,$60,$60,$e0,$e0,$40,$40,$40,$40,$40,$40,$40,$40
	defb $48,$40,$40,$40,$58,$50,$50,$50,$58,$50,$d0,$d0,$50,$50,$50,$50
	
	

MUSICDATA:
 defw sequence
 defb 1
 defw 2
 defb 0
 defb 0
 defw 1
 defb 128
 defb 0
 defw 2
 defb 128
 defb 0
 defw 1
 defb 0
 defb 0
 defw 0
 defb 2
 defb 1
 defw 2
 defb 0
 defb 0
 defw 1
 defb 8
 defb 0
 defw 0
 defb 8
sequence: defb $fd,0
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 133
 defb 20
 defb 145
 defb 20
 defb 133
 defb 20
 defb 145
 defb 20
 defb 135
 defb 20
 defb 147
 defb 20
 defb 135
 defb 20
 defb 147
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 133
 defb 20
 defb 145
 defb 20
 defb 133
 defb 20
 defb 145
 defb 20
 defb 135
 defb 20
 defb 147
 defb 20
 defb 135
 defb 20
 defb 147
 defb 16
 defb 118
 defb $fe
 defb 1
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 133
 defb 16
 defb 120
 defb 145
 defb 16
 defb 118
 defb 133
 defb 16
 defb 120
 defb 145
 defb 16
 defb 118
 defb 135
 defb 16
 defb 120
 defb 147
 defb 16
 defb 118
 defb 135
 defb 16
 defb 120
 defb 147
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 133
 defb 16
 defb 120
 defb 145
 defb 16
 defb 118
 defb 133
 defb 16
 defb 120
 defb 145
 defb 16
 defb 118
 defb 135
 defb 12
 defb 122
 defb $fe
 defb 1
 defb 122
 defb 147
 defb 16
 defb 123
 defb 135
 defb 16
 defb 124
 defb 147
 defb 16
 defb 118
 defb $fd,2
 defb 216
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 125
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 125
 defb 154
 defb 201
 defb 16
 defb 121
 defb 152
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 125
 defb $fe
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fd,0
 defb 156
 defb 199
 defb 16
 defb 121
 defb 154
 defb 211
 defb 16
 defb 125
 defb $fd,8
 defb 144
 defb 199
 defb 16
 defb 121
 defb 142
 defb 211
 defb 16
 defb 118
 defb $fd,4
 defb 228
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 125
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 125
 defb 166
 defb 201
 defb 16
 defb 121
 defb 164
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 125
 defb $fe
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fd,6
 defb 220
 defb 199
 defb 16
 defb 119
 defb $fd,8
 defb 144
 defb 211
 defb 16
 defb 125
 defb $fd,6
 defb 159
 defb 199
 defb 16
 defb 119
 defb $fd,8
 defb 147
 defb 211
 defb 16
 defb 118
 defb $fd,2
 defb 216
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 125
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 125
 defb 154
 defb 201
 defb 16
 defb 121
 defb 152
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 125
 defb $fe
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fd,0
 defb 156
 defb 199
 defb 16
 defb 121
 defb 154
 defb 211
 defb 16
 defb 125
 defb $fd,8
 defb 144
 defb 199
 defb 16
 defb 121
 defb 142
 defb 211
 defb 16
 defb 118
 defb $fd,4
 defb 228
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 125
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 125
 defb 166
 defb 201
 defb 16
 defb 121
 defb 164
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 197
 defb 16
 defb 121
 defb $fd,14
 defb 220
 defb 209
 defb 16
 defb 125
 defb 154
 defb 197
 defb 16
 defb 121
 defb 152
 defb 209
 defb 12
 defb 119
 defb $fe
 defb 1
 defb 119
 defb $fd,12
 defb 208
 defb 211
 defb 16
 defb 120
 defb $fe
 defb 16
 defb 125
 defb 147
 defb 215
 defb 16
 defb 120
 defb $fe
 defb 16
 defb 118
 defb 152
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb 154
 defb 201
 defb 16
 defb 120
 defb 151
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb 147
 defb 199
 defb 16
 defb 120
 defb 151
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb 215
 defb 199
 defb 16
 defb 118
 defb $fe
 defb 211
 defb 16
 defb 118
 defb 149
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb 147
 defb 197
 defb 16
 defb 120
 defb 149
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb 152
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb 154
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb 152
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 12
 defb 119
 defb $fe
 defb 1
 defb 119
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 119
 defb $fe
 defb 211
 defb 12
 defb $fc
 defb 4
 defb 118
 defb $fd,10
 defb 215
 defb 201
 defb 4
 defb 152
 defb 12
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 119
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 119
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 119
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 119
 defb 154
 defb 201
 defb 16
 defb 120
 defb 151
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb 144
 defb 199
 defb 4
 defb 147
 defb 12
 defb 120
 defb 151
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb 215
 defb 199
 defb 16
 defb 118
 defb $fe
 defb 211
 defb 16
 defb 118
 defb 149
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 119
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 119
 defb 147
 defb 197
 defb 16
 defb 120
 defb 149
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 119
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 119
 defb 151
 defb 197
 defb 4
 defb 152
 defb 12
 defb 118
 defb $fe
 defb 209
 defb 16
 defb 118
 defb 154
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb 152
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 12
 defb 122
 defb $fe
 defb 1
 defb 122
 defb $fe
 defb 211
 defb 12
 defb 124
 defb $fe
 defb 1
 defb 123
 defb $fe
 defb 199
 defb 12
 defb 124
 defb $fe
 defb 1
 defb 124
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fd,0
 defb 137
 defb $fc
 defb $fe
 defb $fe
 defb $fe
 defb $fe
 defb $fe
 defb $fe
 defb $fe
 defb 117
 defb 39
 defb $fc
 defb 20
 defb $fc,$fc,$ff,117
 defb 0
