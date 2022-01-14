//   ***** THE HUNTER *****
// 
// A BAT HUNTING GAME BY FR3D
//
//          alias 
//    Christian Wahlmann

.org 0x8000
.run 0x8000

.def screen: 0x7000
.def latch:  0x6800

        JP start_program:
        
start_program:
// install screen interrupt hook
        LD DE, main:
        CALL install_interrupt_main_loop:

// outer game loop
run_intro: 
        CALL intro:

run_new_game: CALL init0:

resume_game: LD A, 0x01
            LD (game_state:), A
            
loop1:      LD A, (game_state:)
            CP 0x01
            JR Z, loop1:
        
            OR A
            JR Z, run_intro:
        
            CP 0x02
            JR Z, hit_message_loop:
            
            CP 0x03
            JR Z, run_game_over:
        
            JR loop1:

// wait for "s"-Key
hit_message_loop: LD A, (0x68fd)
            AND 0x02
            JR NZ, hit_message_loop: 
            
            CALL init:
            JR resume_game:

            JR loop1:
            
run_game_over: CALL game_over:
            JR run_new_game:

// game state: 0 = intro, 1 = running, 2 = hit_message; 3 = game_over

game_state: defb 0x00


score:     defw 0x000f
highscore: defw 0x0000
lives:     defb 0x05

x:         defb 0x0e
r:         defb 0x01
arr_x:     defb 0x00
arr_y:     defb 0xff

// *** bat data
// 0: x, y
// 2: sprite (0-3; 0xff = dead)
// 3: type (0 = normal, 1 = evil)
// 4: delay
// 5: delay-count

max_bats:  defb 0x0a

bat_data:  defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
            defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
            defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
            defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
            defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
            defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
            defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
            defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
            defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
            defb 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
                   
spr_hunter_left: defb 0xc0, 0xcf, 0xc0
                 defb 0xac, 0xaf, 0xa9
                 defb 0xb6, 0xb5, 0xb0
                 
spr_hunter_right: defb 0xc0, 0xcf, 0xc0
                 defb 0xa6, 0xaf, 0xac
                 defb 0xb0, 0xba, 0xb9

spr_hunter_stop: defb 0xc0, 0xcf, 0xc0
                 defb 0xa6, 0xaf, 0xa9
                 defb 0xb0, 0xbf, 0xb0

spr_arr:    defb 0x1e

spr_bat_0: defb 0xd6, 0xd9
spr_bat_1: defb 0xd3, 0xd3
spr_bat_2: defb 0xd9, 0xd6
spr_bat_3: defb 0xdc, 0xdc

spr_bat_4: defb 0xb6, 0xb9
spr_bat_5: defb 0xb3, 0xb3
spr_bat_6: defb 0xb9, 0xb6
spr_bat_7: defb 0xbc, 0xbc

init0:  LD A, 0x05
        LD (lives:), A
        LD HL, 0x0000
        LD (score:), HL
init:   LD IX, bat_data:
        LD A, (max_bats:)
        LD B, A
init_lp1: LD (IX+2), 0xFF
        INC IX
        INC IX
        INC IX
        INC IX
        INC IX
        INC IX
        DEC B
        JR NZ, init_lp1:
        
        LD A, 0x10
        LD (x:), A
        LD A, 0x00
        LD (r:), A
        LD A, 0xff
        LD (arr_y:), A
        RET

// main loop
main:
        LD A, (game_state:)
        CP 0x01
        RET NZ

        CALL clear_screen:
        CALL draw:
        CALL draw_arr:
        CALL draw_bats:
        CALL draw_score:
        CALL draw_lives:
        CALL control:
        CALL move:
        CALL move_arr:
        CALL move_bats:

        LD A, (lives:)
        OR A
        RET NZ
        
        LD A, 0x03
        LD (game_state:), A
        RET

fire_pressed: defb 0x00

// A
control: LD A, (0x68fd)
        AND 0x10
        JR NZ, control_nx1:
        LD A, 0xff
        LD (r:), A
        JR control_nx3: 
        
// D
control_nx1: LD A, (0x68fd)
        AND 0x08
        JR NZ, control_nx2:
        LD A, 0x01
        LD (r:), A
        JR control_nx3: 
        
control_nx2: LD A, 0x00
        LD (r:), A
        
// SPACE
control_nx3: LD A, (0x68ef)
        AND 0x10
        JR NZ, control_nx4:
        
        LD A, (fire_pressed:)
        OR A
        RET NZ
        
        LD A, (arr_y:)
        CP 0xff
        RET NZ
        
        LD A, 0x01
        LD (fire_pressed:), A
        
        LD A, (x:)
        INC A
        LD (arr_x:), A
        LD A, 0x0c
        LD (arr_y:), A
        RET 

control_nx4: XOR A
        LD (fire_pressed:), A 
        RET 

// move
move_delay: defb 0x04

move:   LD A, (move_delay:)
        DEC A
        LD (move_delay:), A
        OR A
        RET NZ
        
        LD A, 0x04
        LD (move_delay:), A

        LD A, (r:)
        LD B, A
        LD A, (x:)
        ADD A, B
        LD (x:), A
        
        CP 0xff
        JR NZ, move_nx1:
        
        LD A, 0x00
        LD (r:), A
        LD A, 0x00
        LD (x:), A
        RET
        
move_nx1: CP 0x1e
        RET C
        LD A, 0x00
        LD (r:), A
        LD A, 0x1d
        LD (x:), A
        RET
        
// draw
draw:    LD A, (x:)
         LD L, A
         LD H, 0x00
         
         LD DE, 0x0180
         ADD HL, DE
                 
         LD DE, screen:
         ADD HL, DE
         
         LD C, 0x03
         LD A, (r:)
         CP 0x01
         JR NZ, draw_nx1:
         LD DE, spr_hunter_right:
         JR draw_lo1:

draw_nx1: CP 0xff
         JR NZ, draw_nx2:
         LD DE, spr_hunter_left:
         JR draw_lo1:
         
draw_nx2: LD DE, spr_hunter_stop:

draw_lo1: LD B, 0x03 
draw_lo2: LD A, (DE)
         LD (HL), A
         INC HL
         INC DE
         DEC B
         JR NZ, draw_lo2:
         PUSH DE
         LD DE, 0x001d
         ADD HL, DE
         POP DE
         DEC C
         JR NZ, draw_lo1:
         RET

bat_delay: defb 0x04

move_bats: LD IX, bat_data:
        LD A, (max_bats:)
        LD B, A
move_bats_lp1: PUSH BC
        LD A, (IX+2)
        CP 0xff
        JR NZ, move_bats_nx1:

        CALL random:
        LD A, (randomnumber_l:)
        OR A
        CALL Z, new_bat:
        JR move_bats_nx2:  
        
move_bats_nx1: CALL move_bat:

move_bats_nx2: POP BC
        INC IX
        INC IX
        INC IX
        INC IX
        INC IX
        INC IX
        DEC B       
        JR NZ, move_bats_lp1:
        RET 

// *** new bat
new_bat: CALL random:
        LD A, (randomnumber_l:)
        AND 0x1f
        LD (IX+0), A
        
        CALL random:
        LD A, (randomnumber_l:)
        AND 0x07
        LD (IX+1), A
        XOR A
        LD (IX+2), A
        LD (IX+3), A
        CALL random:
        LD A, (randomnumber_l:)
        AND 0x07
        ADD A, 0x02
        LD (IX+4), A
        LD (IX+5), A
        RET     

// *** move bat
bat_y_moves:       defb 0xff, 0xff, 0x00, 0x01
bat_evil_y_moves:  defb 0xff, 0xff, 0x01, 0x02

// bat delay 
move_bat: LD A, (IX+5)
        DEC A
        LD (IX+5), A
        OR A
        RET NZ
        LD A, (IX+4)
        LD (IX+5), A

// select sprite
        CALL random:
        LD A, (randomnumber_l:)
        AND 0x03
        LD (IX+2), A
        
        CALL random:
        LD A, (randomnumber_l:)
        CP 0xfd
        JR C, move_bat_n0:

        LD A, (IX+3)        
        XOR 0x01
        LD (IX+3), A
        
// move x
move_bat_n0: CALL random:
        LD D, (IX+0)
        LD A, (randomnumber_l:)
        AND 0x01
        ADD A, A
        SUB 0x01
        ADD A, D
        CP 0xff
        JR NZ, move_bat_n1:
        LD A, 0x00
move_bat_n1: CP 0x1f
        JR NZ, move_bat_n2:
        LD A, 0x1e
move_bat_n2: LD (IX+0), A
        
// move y
        LD HL, bat_y_moves:
        LD A, (IX+3)
        OR A
        JR Z, move_bat_n2a:
        INC HL
        INC HL
        INC HL
        INC HL
move_bat_n2a: CALL random:
        LD A, (randomnumber_l:)
        AND 0x03
        LD E, A
        LD D, 0x00
        ADD HL, DE
        LD A, (HL)
        LD D, (IX+1)
        ADD A, D
        CP 0xfe
        JR C, move_bat_n3:
        LD A, 0x00
move_bat_n3: CP 0x0d
        JR C, move_bat_n4:
        LD A, 0x0c
move_bat_n4: LD (IX+1), A
        RET

draw_bats: LD IX, bat_data:
        LD A, (max_bats:)
        LD B, A
draw_bats_lp1: PUSH BC
        LD A, (IX+2)
        CP 0xff
        JR Z, draw_bats_nx1:
                    
        CALL draw_bat:

draw_bats_nx1: POP BC
        INC IX
        INC IX
        INC IX
        INC IX
        INC IX
        INC IX
        DEC B       
        JR NZ, draw_bats_lp1:
        RET 
                
get_ready_text: defs "OUCH! SHE BIT YOU!"
                defb 0x00
                defs "PRESS <S> WHEN READY"             
                defb 0x00
                
draw_bat: LD L, (IX+1)
        LD H, 0x00
        ADD HL, HL
        ADD HL, HL
        ADD HL, HL
        ADD HL, HL
        ADD HL, HL
        LD E, (IX+0)
        LD D, 0x00
        ADD HL, DE
        LD DE, screen:
        ADD HL, DE
        
        PUSH HL
        LD A, (IX+3)
        ADD A, A
        ADD A, A
        ADD A, (IX+2)
        ADD A, A
        LD E, A
        LD D, 0x00
        LD HL, spr_bat_0:
        ADD HL, DE
        LD E, L
        LD D, H
        POP HL
        
// check collision

// Arr
        LD A, (spr_arr:)
        LD B, (HL)
        CP B
        JR Z, draw_bat_nx1:
        INC HL
        LD B, (HL)
        DEC HL
        CP B
        JR Z, draw_bat_nx1:

// hunter
        LD A, (IX+3)
        OR A
        JR Z, draw_bat_nx2:
        LD A, 0xcf
        LD B, (HL)
        CP B
        JR Z, draw_bat_nxb1:
        INC HL
        LD B, (HL)
        DEC HL
        CP B
        JR NZ, draw_bat_nx2:
        
// hit hunter
draw_bat_nxb1: LD (IX+2), 0xff
        LD A, (lives:)
        OR A
        JR Z, draw_bat_nx2:
        DEC A
        LD (lives:), A
        OR A
        RET Z
        
        LD BC, 0x0107
        LD DE, get_ready_text:
        CALL print_at: 
        LD BC, 0x0126
        CALL print_at:
        LD A, 0x02
        LD (game_state:), A
        RET
                        
// hit arr
draw_bat_nx1: LD (IX+2), 0xff
        LD A, 0xff
        LD (arr_y:), A
        
        LD HL, (score:)
        
        LD A, (IX+3)
        OR A
        JR NZ, got_evil_bat:

        INC HL
        LD (score:), HL
        RET
        
got_evil_bat: LD DE, 0x0005
        ADD HL, DE
        LD (score:), HL
        RET
        
draw_bat_nx2: LD A, (DE)
        LD (HL), A
        INC HL
        INC DE
        LD A, (DE)
        LD (HL), A
        RET     

move_arr: LD A, (arr_y:)
        CP 0xff
        RET Z
        DEC A
        LD (arr_y:), A
        RET

draw_arr: LD A, (arr_y:)
        CP 0xff
        RET Z
        LD L, A
        LD H, 0x00
        ADD HL, HL
        ADD HL, HL
        ADD HL, HL
        ADD HL, HL
        ADD HL, HL
        LD A, (arr_x:)
        LD E, A
        LD D, 0x00
        ADD HL, DE
        LD DE, screen:
        ADD HL, DE
        LD A, (spr_arr:)
        LD (HL), A
        RET
        
// fill screen
clear_screen: LD HL, screen:
              LD BC, 0x01e0
clr_loop1:    LD (HL), 0x80
              INC HL
              DEC BC
              LD A, B
              OR C
              JR NZ, clr_loop1:
              LD B, 0x20
clr_loop2:    LD (HL), 0x20
              INC HL
              DEC B
              JR NZ, clr_loop2:
              RET
        
score_msg: defs "SCORE: "
        defb 0x00

// inputs: BC - screen pos
draw_score: LD BC, 0x01e2
draw_score_at: LD DE, score_msg:
        CALL print_at:
        
        LD HL, screen:
        ADD HL, BC
        LD D, H
        LD E, L 
        LD HL, (score:)
        LD B, 0x05
        INC DE
        INC DE
        INC DE
        INC DE
        INC DE
        LD A, 0x30
        LD (DE), A
        DEC DE
draw_score_lp1: PUSH DE
        PUSH BC
        CALL div_by_ten:
        POP BC
        POP DE
        ADD A, 0x30
        LD (DE), A
        DEC DE
        DJNZ draw_score_lp1:
        RET

highscore_msg: defs "HIGHSCORE: "
        defb 0x00
        
// inputs: BC - screen pos
draw_highscore_at: LD DE, highscore_msg:
        CALL print_at:
        
        LD HL, screen:
        ADD HL, BC
        LD D, H
        LD E, L 
        LD HL, (highscore:)
        LD B, 0x05
        INC DE
        INC DE
        INC DE
        INC DE
        INC DE
        LD A, 0x30
        LD (DE), A
        DEC DE
draw_highscore_lp1: PUSH DE
        PUSH BC
        CALL div_by_ten:
        POP BC
        POP DE
        ADD A, 0x30
        LD (DE), A
        DEC DE
        DJNZ draw_score_lp1:
        RET
        
// lives
draw_lives: LD HL, screen:
        LD DE, 0x01f6
        ADD HL, DE
        LD A, (lives:)
draw_lives_lp2: LD (HL), 0x2a
        INC HL
        DEC A
        JR NZ, draw_lives_lp2: 
        RET

intro_logo: defb 0x3c, 0x3e, 0x38, 0x3a, 0x30, 0x3a, 0x3e, 0x3c, 0x38, 0x00, 0x2a, 0x20, 0x2a, 0x2a, 0x20, 0x2a, 0x2b, 0x20, 0x2a, 0x2c, 0x2e, 0x28, 0x2e, 0x2c, 0x28, 0x2e, 0x2d, 0x20
            defb 0x30, 0x3a, 0x30, 0x3e, 0x3c, 0x3a, 0x3e, 0x38, 0x30, 0x00, 0x2e, 0x2c, 0x2a, 0x2a, 0x20, 0x2a, 0x2a, 0x29, 0x2a, 0x20, 0x2a, 0x20, 0x2e, 0x28, 0x20, 0x2e, 0x2c, 0x2a
            defb 0x30, 0x38, 0x30, 0x38, 0x30, 0x38, 0x3c, 0x3c, 0x38, 0x00, 0x28, 0x20, 0x28, 0x2c, 0x2c, 0x28, 0x28, 0x20, 0x28, 0x20, 0x28, 0x20, 0x2c, 0x2c, 0x28, 0x28, 0x20, 0x28

intro_text: defs "A BAT HUNTING GAME BY ** FR3D **"
            defb 0x00
            defs "PRESS <S> TO START"
            defb 0x00

intro:  LD HL, screen:
        LD BC, 0x0200
intro_lp1: LD (HL), 0x80
        INC HL
        DEC BC
        LD A, B
        OR C
        JR NZ, intro_lp1:
        
        LD HL, screen:
        LD DE, 0x0082
        ADD HL, DE
        LD DE, intro_logo:
        LD B, 0x03
intro_lp2: LD C, 0x1c
intro_lp3: LD A, (DE)
        ADD A, 0x80
        LD (HL), A
        INC HL
        INC DE
        DEC C
        JR NZ, intro_lp3:
        PUSH DE
        LD DE, 0x0004
        ADD HL, DE
        POP DE
        DEC B
        JR NZ, intro_lp2:
        
        LD BC, 0x00e0
        LD DE, intro_text:
        CALL print_at:

        LD BC, 0x01c7
        CALL print_at:
         
// wait for "s"-Key
intro_nx1: LD A, (0x68fd)
        AND 0x02
        JR NZ, intro_nx1:
        LD (0x7000), A
        RET
        
game_over_logo: defb 0x4e, 0x4c, 0x48, 0x4e, 0x4c, 0x4a, 0x4e, 0x4e, 0x4a, 0x4e, 0x4c, 0x48, 0x40, 0x4e, 0x4c, 0x4a, 0x4a, 0x40, 0x4a, 0x4e, 0x4c, 0x48, 0x4e, 0x4d, 0x40
                defb 0x4a, 0x44, 0x4a, 0x4b, 0x43, 0x4a, 0x4a, 0x48, 0x4a, 0x4e, 0x48, 0x40, 0x40, 0x4a, 0x40, 0x4a, 0x4a, 0x45, 0x48, 0x4e, 0x48, 0x40, 0x4e, 0x4c, 0x4a
                defb 0x4c, 0x4c, 0x48, 0x48, 0x40, 0x48, 0x48, 0x40, 0x48, 0x4c, 0x4c, 0x48, 0x40, 0x4c, 0x4c, 0x48, 0x4c, 0x4c, 0x40, 0x4c, 0x4c, 0x48, 0x48, 0x40, 0x48

beat_highscore_msg: defs "!!! NEW HIGHSCORE !!!"
                    defb 0x00
                
game_over_text: defs "PRESS <S> FOR START"
                defb 0x00
                defs "OR <I> FOR INTRO"
                defb 0x00

game_over: LD HL, screen:
        LD BC, 0x0200
game_over_lp1: LD (HL), 0x80
        INC HL
        DEC BC
        LD A, B
        OR C
        JR NZ, game_over_lp1:
        
        LD HL, screen:
        LD DE, 0x0044
        ADD HL, DE
        LD DE, game_over_logo:
        LD B, 0x03
game_over_lp2: LD C, 0x19
game_over_lp3: LD A, (DE)
        ADD A, 0x80
        LD (HL), A
        INC HL
        INC DE
        DEC C
        JR NZ, game_over_lp3:
        PUSH DE
        LD DE, 0x0007
        ADD HL, DE
        POP DE
        DEC B
        JR NZ, game_over_lp2:

        LD HL, (score:)
        LD D, H
        LD E, L
        LD HL, (highscore:)
        CCF
        SBC HL, DE
        JR NC, game_over_nx1:
        
// new highscore!
        LD H, D
        LD L, E
        LD (highscore:), HL
        // show text
        LD BC, 0x00e5
        LD DE, beat_highscore_msg:
        CALL print_at: 

game_over_nx1: LD BC, 0x0129
        CALL draw_score_at:
                
        LD BC, 0x0147
        CALL draw_highscore_at:

        LD BC, 0x01a6
        LD DE, game_over_text:
        CALL print_at: 
        LD BC, 0x01c8
        CALL print_at:
         
        // check "s"-Key
game_over_lp4: LD A, (0x68fd)
        AND 0x02
        RET Z
        // check "i"-Key
        LD A, (0x68bf)
        AND 0x08
        JR NZ, game_over_lp4:
        JP intro:

// print text at DE on screen at BC
print_at: LD HL, screen:
        ADD HL, BC
print_at_lp4: LD A, (DE)
        INC DE
        OR A
        RET Z
        LD (HL), A
        INC HL
        INC BC
        JR print_at_lp4:

.def interrupt_pointer: 0x787d

; install interrupt main loop
; input: DE pointer to main loop
 
install_interrupt_main_loop:
        DI
        
        LD HL, user_main_loop_call:
        INC HL
        LD (HL), E
        INC HL
        LD (HL), D
         
        LD HL, interrupt_pointer:
        LD (HL), 0xc3
        INC HL
        LD DE, interrupt_loop:
        LD (HL), E
        INC HL
        LD (HL), D

        EI
        RET

interrupt_loop:
        DI
user_main_loop_call:
        CALL user_dummy_main_loop:
                        
        POP HL  // do not return do basic routines!!
        POP HL
        POP DE
        POP BC
        POP AF
        EI
        RETI

user_dummy_main_loop:
        RET


; random numnber generator
; input: -
; output: a random number in zahl_h / zahl_l 

randomnumber_h:   defb 0x00
randomnumber_l:   defb 0x00

random: PUSH HL
        PUSH DE
        
        LD HL, (randomnumber_h:)
        LD D, H
        LD E, L

        ADD HL, HL
        ADD HL, HL
        ADD HL, DE

        ADD HL, HL
        ADD HL, HL
        ADD HL, DE
        ADD HL, HL

        ADD HL, HL
        ADD HL, DE
        ADD HL, HL
        ADD HL, DE

        ADD HL, HL
        ADD HL, HL
        ADD HL, HL
        ADD HL, DE

        LD DE, 0x2517
        ADD HL, DE
        LD (randomnumber_h:), HL
        
        POP DE
        POP HL
        RET

; 16 by 8 division
; Inputs:
;     HL is the numerator
;     C is the denominator
; Outputs:
;     A is the remainder
;     B is 0
;     C is not changed
;     DE is not changed
;     HL is the quotient
;
div_by_ten: LD C, 0x0a
divide:
        LD B, 0x10
        XOR A
  
divide_loop_1: 
        ADD HL, HL
        RLA
        CP C
        JR C, divide_next_1:
           
        INC HL
        SUB C
        
divide_next_1: 
        DJNZ divide_loop_1:
        RET