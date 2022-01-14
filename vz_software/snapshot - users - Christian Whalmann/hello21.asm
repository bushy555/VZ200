	org $8000


screen equ $7000
intadr equ $787d

        DI
        LD HL, intadr
        LD (HL), $c3
        INC HL
        LD DE, intloop
        LD (HL), E
        INC HL
        LD (HL), D
        OR A
        LD ($78de), A
        EI
wait   JR wait

intloop DI
        PUSH HL
        PUSH DE
        PUSH BC
        PUSH AF

        LD A, (count1)
        DEC A
        LD (count1), A
        OR A
        JR NZ, next0
        LD A, $04
        LD (count1), A

        CALL textscroll
        CALL colorlines

next0  LD A, (count2)
        DEC A
        LD (count2), A
        OR A
        JR NZ, next01
        LD A, $02
        LD (count2), A

        CALL sinus

next01 LD A, (count3)
        DEC A
        LD (count3), A
        OR A
        JR NZ, exit
        LD A, $04
        LD (count3), A

        CALL sound

exit   POP AF
        POP BC
        POP DE
        POP HL
        EI
        RETI

txt    db "***** HELLO WORLD!!! ******      WELCOME TO A DEMO MADE BY C.WHALMAN AND MODDED BY BUSHY. 1 BIT MUSIC MADE BY UTZ......              "
        db $00
txtptr dw txt
count1  db $01
count2  db $02
count3  db $03

textscroll LD HL, (txtptr)
	LD IX, (txtptr)
        LD DE, screen
        LD B, $40

        INC HL
        LD A, (HL)
        OR A
        JR NZ, next1

        LD HL, txt
next1  LD (txtptr), HL

loop1  	LD A, (HL)
        LD (DE), A
        INC DE
        INC HL

        LD A, (HL)
        OR A
        JR NZ, next2

        LD HL, txt

next2  DEC B
        JR NZ, loop1

        RET

color  db $8f
colorlines LD HL, screen
            LD DE, $0020
            ADD HL, DE
            LD B, $08
loop_col1  LD C, $20
            LD A, (color)
loop_col2  LD (HL), A
            INC HL
            DEC C
            JR NZ, loop_col2

            ADD A, $10
            CP 7; 17; $1f; 255; 31; 8; $0f + 32; $0F
            JR NZ, next_col1

            LD A, $8f 

next_col1    LD (color), A
            DEC B
            JR NZ, loop_col1
            RET

sin_start0 db $0c
            db $0b, $0b
            db $0a, $0a, $0a
sin_start1 db $09, $09, $09, $09, $09
            db $0a, $0a, $0a
            db $0b, $0b
            db $0c
            db $0d, $0d
            db $0e, $0e, $0e
            db $0f, $0f, $0f, $0f, $0f
            db $0e, $0e, $0e
            db $0d, $0d
            db $ff

sina       dw sin_start0
sinb       dw sin_start1

sinus      LD HL, $7120
            LD DE, $7121
            LD C, $e0
sinus_l1   LD A, (DE)
            LD (HL), A
            INC HL
            INC DE
            DEC C
            JR NZ, sinus_l1

            LD HL, $713f
            LD DE, $0020
            LD C, $07
sinus_l2   LD (HL), $20
            ADD HL, DE
            DEC C
            JR NZ, sinus_l2

            LD HL, (sina)
            INC HL
            LD A, (HL)
            CP $ff
            JR NZ, sinus_n1
            LD HL, sin_start0
            LD A, (HL)
sinus_n1   LD (sina), HL
            CALL sin_pos

;	LD ix, (txtptr)
            LD (HL), $2a
;            LD (HL), a


            LD HL, (sinb)
            INC HL
            LD A, (HL)
            CP $ff
            JR NZ, sinus_n2
            LD HL, sin_start0
            LD A, (HL)
sinus_n2   LD (sinb), HL
            CALL sin_pos
            LD (HL), $2e


            RET

sin_pos    LD L, A
            LD H, $00
            ADD HL, HL
            ADD HL, HL
            ADD HL, HL
            ADD HL, HL
            ADD HL, HL
            LD DE, $701f
            ADD HL, DE
            RET

snd_ptr    dw $0000
sound      LD HL, (snd_ptr)
            LD A, (HL)
            INC HL
            LD (snd_ptr), HL
            LD L, A
            LD H, $00
            INC HL
            LD BC, $0008
            CALL $345c
            RET