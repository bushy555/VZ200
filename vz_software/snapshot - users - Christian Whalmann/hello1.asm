	org $8000


screen equ $7000
intadr equ $787d
latch  equ $6800

; install screen interrupt hook
        DI
        CALL init
        LD HL, intadr
        LD (HL), $c3
        INC HL
        LD DE, main
        LD (HL), E
        INC HL
        LD (HL), D
        OR A
        LD ($78de), A
        EI
    	; and then do nothing ;-)
wait   
		JR wait

x      db  64
y      db  61
dx     db  2
dy     db  -10

ball0	db %01111111, %01010101 	; db  0q1333, 0q1111
	db %11111100, %11010101		; db  0q3330, 0q3111
	db %01111111, %01010101		; db  0q1333, 0q1111
	db %00000000, %00000000		; db  0,0

ball1  	db %01011111, %11010101		; db  0q1133, 0q3111
	db %01111111, %00110101		; db  0q1333, 0q0311
	db %01011111, %11010101		; db  0q1133, 0q3111
	db %00000000, %00000000		; db  0,0

ball2  	db %01010111, %11110101		; db  0q1113, 0q3311
	db %01011111, %11001101		; db  0q1133, 0q3031
	db %01010111, %11110101		; db  0q1113, 0q3311
	db %00000000, %00000000		; db  0,0

ball3  	db %01010101, %11111101		; db  0q1111, 0q3331
	db %01010111, %11110011		; db  0q1113, 0q3303
	db %01010101, %11111101		; db  0q1111, 0q3331
	db %00000000, %00000000		; db  0,0

; init
		; set gfx
init	LD A, $08
		LD (latch), A
		LD C, $01
		CALL clear_screen
		RET

; main loop
main 	DI
        PUSH HL
        PUSH DE
        PUSH BC
        PUSH AF

        CALL undraw
        CALL move
        CALL draw

exit   POP AF
        POP BC
        POP DE
        POP HL
        EI
        RETI

; move
move    LD A, (x)
         LD B, A
		 LD A, (dx)
		 ADD A, B
		 LD (x), A
		 OR A
		 JR Z, move_n1
		 CP $7c
		 JR C, move_n2
move_n1 LD A, (dx)
		 XOR $ff
		 INC A
		 LD (dx), A

move_n2 LD A, (y)
         LD B, A
		 LD A, (dy)
		 ADD A, B
		 LD (y), A
		 CP $3d
		 JR C, move_n3

		 LD (y), A
		 LD A, (dy)
         XOR $ff
		 INC A
		 JR move_n4

move_n3 LD A, (dy)
		 INC A

move_n4 LD (dy), A
		 RET

; undraw
undraw  CALL pos
		 LD A, $55
		 LD DE, $001f
		 LD (HL), A
		 INC HL
		 LD (HL), A
		 ADD HL, DE
		 LD (HL), A
		 INC HL
		 LD (HL), A
		 ADD HL, DE
		 LD (HL), A
		 INC HL
		 LD (HL), A
		 RET

; draw
draw    CALL pos
		 LD DE, $001f

		 LD A, (BC)
		 LD (HL), A
		 INC HL
		 INC BC

		 LD A, (BC)
		 LD (HL), A
		 ADD HL, DE
		 INC BC

		 LD A, (BC)
		 LD (HL), A
		 INC HL
		 INC BC

		 LD A, (BC)
		 LD (HL), A
		 ADD HL, DE
		 INC BC

		 LD A, (BC)
		 LD (HL), A
		 INC HL
		 INC BC

		 LD A, (BC)
		 LD (HL), A

		 RET

; pos
pos     LD A, (y)
		 LD L, A
		 LD H, $00
		 ADD HL, HL
		 ADD HL, HL
		 ADD HL, HL
		 ADD HL, HL
		 ADD HL, HL
		 LD DE, screen
		 LD A, (x)
		 LD E, A
		 SRA E
		 SRA E
		 ADD HL, DE
		 PUSH HL

		 LD A, (x)
		 AND $03
		 LD L, A
		 LD H, $00
		 ADD HL, HL
		 ADD HL, HL
		 ADD HL, HL
		 LD DE, ball0
		 ADD HL, DE
		 LD C, L
		 LD B, H
		 POP HL
		 RET

; fill screen with color C
clear_screen LD A, C
			  SLA C
			  SLA C
			  OR C
			  SLA C
			  SLA C
			  OR C
			  SLA C
  			  SLA C
  			  OR C
  			  LD HL, screen
  			  LD BC, $0800
  			  LD D, A
clr_loop1	  LD (HL), D
			  INC HL
			  DEC BC
			  LD A, B
			  OR C
			  JR NZ, clr_loop1
			  RET