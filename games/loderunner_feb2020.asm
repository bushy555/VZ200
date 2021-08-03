;624		11pm 2/2/20
;625		5pm  3/2/20
;626		10pm 3/2/20

 Enemy_Y_offset		equ	32*24
 Player_Y_offset	equ 	32*6*8
 Princess_Y_offset	equ	32*00

	org $8000


; LEVEL 1
; 
;     4             5
; 111111121111111   5
;        233333333335    4
;        2    112   1111111211
;        2    112          2
;        2    112       4  2
; 11211111    1111111121111111
;   2                 2
;   2                 2
; 111111111211111111112
;          2          2
;        4 233333333332   4
;     2111111         11111112
;     2            4         2
; 1111111111111111111111111111
; 
; 1=BRICK
; 2=LADDER
; 3=BAR
; 4=BOX       
; 5=ESCAPE LADDER


; LEVEL 1
; 
;     4        5
; 11112111111  5
;     23333333354
;     2   112  121
;     2   112   2
;     2   112  42
; 11211   11112111
;   2         2
;   2         2
; 1111121111112
;      2      2
;    4 23333332 4
;   21111     1112
;   2      4     2
; 1111111111111111
; 
; 1=BRICK
; 2=LADDER
; 3=BAR
; 4=BOX       
; 5=ESCAPE LADDER


;============================

; vz level       16X10
;
;                      0 +0000  0*7(32
; 11112111111  5       1 +0224  1*7*32
;     23333333354      2 +0448  2*7*32
; 11211   11112111     3 +0672  3*7*32
;   2         2        4 +0896  4*7*32
; 1111121111112        5 +1120  5*7*32
;    4 23333332 4      6 +1344  6*7*32
;   21111     1112     7 +1568  7*7*32
;   2      4     2     8 +1792  8*7*32
; 1111111111111111     9 +                1824


; 00-06		0
; 07-13		224
; 14-20		448
; 21-27		672
; 28-34		896
; 35-41		1120
; 42-48		1344
; 49-55		1568
; 56-62		1792
;



; 00 11112111111  5
; 01     23333333354
; 02     2   112  42
; 03 11211   11112111
; 04   2         2
; 05 1111121111112
; 06    4 23333332 4
; 07   21111     1112
; 08   2      4     2
; 09 1111111111111111


; 00-05		0
; 06-11		224
; 12-17		448
; 18-23		672
; 24-29		896
; 30-35		1120
; 36-41		1344
; 42-47		1568
; 48-53		1792
; 54-59 
 

;brick. 11x. 7000 + 00*32 + 00.
;brick. 02x. 7000 + 02*32 + 09.
;brick. 03x. 7000 + 02*32 + 14.
;brick. 05x. 7000 + 03*32 + 00.
;brick. 08x. 7000 + 03*32 + 08.
;brick. 13x. 7000 + 05*32 + 00.
;brick. 05x. 7000 + 07*32 + 03.
;brick. 04x. 7000 + 07*32 + 13.
;brick. 16x. 7000 + 09*32 + 00.
;bar.   08x. 7000 + 01*32 + 06.
;bar.   06x. 7000 + 06*32 + 07.
;ladder.01x. 7000 + 00*32 + 05.
;ladder.01x. 7000 + 01*32 + 05.
;ladder.01x. 7000 + 02*32 + 05.
;ladder.01x. 7000 + 02*32 + 11.
;ladder.01x. 7000 + 02*32 + 15.
;ladder.01x. 7000 + 03*32 + 03.
;ladder.01x. 7000 + 03*32 + 13.
;ladder.01x. 7000 + 04*32 + 03.
;ladder.01x. 7000 + 04*32 + 13.
;ladder.01x. 7000 + 05*32 + 13.
;ladder.01x. 7000 + 05*32 + 06.
;ladder.01x. 7000 + 06*32 + 06.
;ladder.01x. 7000 + 06*32 + 13.
;ladder.01x. 7000 + 07*32 + 03.
;ladder.01x. 7000 + 08*32 + 03.
;ladder.01x. 7000 + 07*32 + 16.
;ladder.01x. 7000 + 08*32 + 16.









; 8x6 pixel sprites.
; 2-BYTE WIDTH


; 1: BLANK
; 2: SOLID CONCRETE
; 3: NORMAL BRICK
; 4: LADDER
; 5: PRINCESS
; 6: BOX
; 7: RUNNER LEFT 1
; 8: RUNNER LEFT 2
; 9: RUNNER RIGHT 1
; 10: RUNNER RIGHT 2



; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISABLE INTERRUPTS. MODE 1
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	DI
	ld 	a, 8
	ld 	($6800), a


; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPLAY TITLE
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ld	hl, title
	ld	de, $7000
	ld	bc, 2048
	ldir


; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; PRESS SPACE BAR
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
pressspace:ld 	a, ($68ef)	; press <space> to continue
	and	$10
	jr 	nz, pressspace
	di


; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; CLS
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ld	hl, $7000		; CLS 
	ld	de, $7001               ; $00: Green   $AA: Blue
	ld	(hl), 00; $ff           ; $85: Yellow  $FF: RED
	ld	bc, 2048
	ldir

; ============================================
;
; LL      EEEEE  VV  VV  EEEEE  LL          11
; LL      EEEEE  VV  VV  EEEEE  LL        1111
; LL      EE     VV  VV  EE     LL          11
; LL      EEEEE  VV  VV  EEEEE  LL          11
; LL      EEEEE  VV  VV  EEEEE  LL          11
; LL      EE     VV  VV  EE     LL          11
; LLLLLL  EEEEE   VVVV   EEEEE  LLLLLL    111111
; LLLLLL  EEEEE    VV    EEEEE  LLLLLL    111111
;
; ============================================


;brick. 11x. 7000 + 00*32 + 00.
;brick. 02x. 7000 + 02*32 + 09.
;brick. 03x. 7000 + 02*32 + 14.
;brick. 05x. 7000 + 03*32 + 00.
;brick. 08x. 7000 + 03*32 + 08.
;brick. 13x. 7000 + 05*32 + 00.
;brick. 05x. 7000 + 07*32 + 03.
;brick. 04x. 7000 + 07*32 + 13.
;brick. 16x. 7000 + 09*32 + 00.
;bar.   08x. 7000 + 01*32 + 06.
;bar.   06x. 7000 + 06*32 + 07.
;ladder.01x. 7000 + 00*32 + 05.
;ladder.01x. 7000 + 01*32 + 05.
;ladder.01x. 7000 + 02*32 + 05.
;ladder.01x. 7000 + 02*32 + 11.
;ladder.01x. 7000 + 02*32 + 15.
;ladder.01x. 7000 + 03*32 + 03.
;ladder.01x. 7000 + 03*32 + 13.
;ladder.01x. 7000 + 04*32 + 03.
;ladder.01x. 7000 + 04*32 + 13.
;ladder.01x. 7000 + 05*32 + 13.
;ladder.01x. 7000 + 05*32 + 06.
;ladder.01x. 7000 + 06*32 + 06.
;ladder.01x. 7000 + 06*32 + 13.
;ladder.01x. 7000 + 07*32 + 03.
;ladder.01x. 7000 + 08*32 + 03.
;ladder.01x. 7000 + 07*32 + 16.
;ladder.01x. 7000 + 08*32 + 16.


; 00 11112111111  5
; 01     23333333151
; 02     2   112  42
; 03 11211   11112111
; 04   2         2
; 05 1111121111112
; 06    4 23333332 4
; 07   21111     1112
; 08   2      4     2
; 09 1111111111111111


; 00-05		0
; 06-11		224
; 12-17		448
; 18-23		672
; 24-29		896
; 30-35		1120
; 36-41		1344
; 42-47		1568
; 48-53		1792
; 54-59 

; ====================
;
; BRICKS
;
; ====================


	ld	b, 11				; BRICK @ 0
	ld	hl, $7000 + 00*32*6 + 00
loopb0: push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb0


	ld	b, 04				; BRICK @ 1
	ld	hl, $7000 + 01*32*6 + 24
loopb1: push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb1


	ld	b, 02				; BRICK @ 2
	ld	hl, $7000 + 02*32*6 + 16
loopb2: push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb2

	ld	b, 05				; BRICK @ 3 #1
	ld	hl, $7000 + 03*32*6 + 00
loopb31:push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb31

	ld	b, 08				; BRICK @ 3 #2
	ld	hl, $7000 + 03*32*6 + 16
loopb32:push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb32

	ld	b, 12				; BRICK @ 5
	ld	hl, $7000 + 05*32*6 + 00
loopb4: push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb4

	ld	b, 04				; BRICK @ 7
	ld	hl, $7000 + 07*32*6 + 06
loopb5: push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb5

	ld	b, 03				; BRICK @ 7
	ld	hl, $7000 + 07*32*6 + 24
loopb6: push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb6

	ld	b, 16				; BRICK 9
	ld	hl, $7000 + 09*32*6 + 00
loopb7: push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb7




; ====================
;
; BARS
;
; ====================



	ld	b, 08				; BAR 1
	ld	hl, $7000 + 01*32*6 + 10
loopb10: push	hl
	pop	iy
	ld	ix, bar
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb10
Hi 
	ld	b, 06				; BAR 2
	ld	hl, $7000 + 06*32*6 + 12
loopb11: push	hl
	pop	iy
	ld	ix, bar
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loopb11




; ====================
;
; LADDER
;
; ====================


	ld	iy, $7000 + 01*32*06 + 08	;  LADDER 1
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 01*32*06 + 28	;  LADDER 1
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 02*32*06 + 08	;  LADDER 2
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 02*32*06 + 20	;  LADDER 2
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 02*32*06 + 28	;  LADDER 2
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 03*32*06 + 04	;  LADDER 3
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 03*32*06 + 24	;  LADDER 3
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 04*32*06 + 04	;  LADDER 4
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 04*32*06 + 24	;  LADDER 4
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 05*32*06 + 10	;  LADDER 5
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 05*32*06 + 24	;  LADDER 5
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 06*32*06 + 10	;  LADDER 6
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 06*32*06 + 24	;  LADDER 6
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 07*32*06 + 06	;  LADDER 7
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 07*32*06 + 30	;  LADDER 7
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 08*32*06 + 06	;  LADDER 8
	ld	ix, ladder2
	call 	sprite_display
	ld	iy, $7000 + 08*32*06 + 30	;  LADDER 8
	ld	ix, ladder2
	call 	sprite_display




; 00 11112111111  5
; 01     23333333354
; 02     2   112  42
; 03 11211   11112111
; 04   2         2
; 05 1111121111112
; 06    4 23333332 4
; 07   21111     1112
; 08   2      4     2
; 09 1111111111111111



;	jp down_here

; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; BOXES
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

	ld	iy, $7000 + 00*32*06 + 26	;  BOX 1
	ld	ix, box
	call 	sprite_display
	ld	iy, $7000 + 02*32*06 + 26	;  BOX 2
	ld	ix, box
	call 	sprite_display
	ld	iy, $7000 + 06*32*06 + 08	;  BOX 3
	ld	ix, box
	call 	sprite_display
	ld	iy, $7000 + 06*32*06 + 28	;  BOX 4
	ld	ix, box
	call 	sprite_display
	ld	iy, $7000 + 08*32*06 + 18	;  BOX 2
	ld	ix, box
	call 	sprite_display



	ld	iy, $7000 + 02*32*06 + 02	;  ENEMY 1
	ld	ix, ENEMY_RUNNING_LEFT_1
	call 	sprite_display
	ld	iy, $7000 + 02*32*06 + 22	;  ENEMY 2
	ld	ix, ENEMY_RUNNING_LEFT_1
	call 	sprite_display
	ld	iy, $7000 + 06*32*06 + 26	;  ENEMY 3
	ld	ix, ENEMY_RUNNING_LEFT_1
	call 	sprite_display





	jp down_here

;[DJM]

; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPLAY ONE LINE OF BRICKS  @0*32
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ld	b, 11
	ld	hl, $7000 
loop1:	push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loop1


; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPAY ONE LINE OF BRICKS @32*32
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ld	b, 16
	ld	hl, $7000 + 32*32	; 32 WIDE X 32 LINES DOWN.
loop1a3:push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loop1a3


; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPLAY ONE LINE OF BRICKS @46*32
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ld	b, 16
	ld	hl, $7000 + (32*46) 
loop1a:	push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loop1a



; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPAY ONE LINE OF BRICKS @bottom-line
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ld	b, 16
	ld	hl, $7000 + 1856 +32
loop1a2:push	hl
	pop	iy
	ld	ix, brick
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loop1a2



; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPLAY TOP BAR 
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ld	b, 6
	ld	hl, $7000+(32*6)+1
loop1b:	push	hl
	pop	iy
	ld	ix, bar
	call 	sprite_display
	push	hl
	pop	iy
	ld	de, 16
	add	iy, de
	ld	ix, bar
	call 	sprite_display
	inc	hl
	inc	hl
	djnz	loop1b

; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPLAY LADDER
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

	ld	b, 9
	ld	iy, $7000+ 160; 320 ;516; 704 ; (32*46) - (4*6*32)
loop1c:	ld	ix, ladder2
	call 	sprite_display
	ld	de, 64 			; 	(32*6) - 1
	add	iy, de
	djnz	loop1c


down_here:



; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPLAY STANDING STILL PRINCESS CHICK
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ld	ix, chick
	ld	iy, $7000 +  Princess_Y_offset + 08
	call 	sprite_display


	jp	down_here2 

; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPLAY STANDING STILL ENEMY
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ld	ix, ENEMY_STAND_STILL
	ld	iy, $7000 + (32*58) + 8
	call 	sprite_display
	ld	ix, ENEMY_STAND_STILL
	ld	iy, $7000 + 1664 + 20
	call 	sprite_display



; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPLAY RUNNER STANDING STILL
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; DISPLAY RUNNER
	ld	ix, PLAYER_STAND_STILL
	ld	iy, $7000 + (32*58) + 16
	call 	sprite_display



down_here2:


;PLAYER_RUNNING_LEFT_5R1
;PLAYER_RUNNING_LEFT_4R2
;PLAYER_RUNNING_LEFT_3R3
;PLAYER_RUNNING_LEFT_2R4
;PLAYER_RUNNING_LEFT_1R1
;PLAYER_RUNNING_LEFT_1
;PLAYER_RUNNING_LEFT_1L2
;PLAYER_RUNNING_LEFT_2L3
;PLAYER_RUNNING_LEFT_3L4
;PLAYER_RUNNING_LEFT_4L1
;PLAYER_RUNNING_LEFT_5L2
;PLAYER_RUNNING_LEFT_6L3
;PLAYER_RUNNING_LEFT_7L4
;





anim:
;	ld	ix, PLAYER_RUNNING_LEFT_1
;	ld	iy, $7000 + Player_Y_offset + 14
;	call	sprite_display_delay
;	ld	ix, PLAYER_RUNNING_LEFT_2
;	ld	iy, $7000 + Player_Y_offset + 14
;	call	sprite_display_delay
;	ld	ix, PLAYER_RUNNING_LEFT_3
;	ld	iy, $7000 + Player_Y_offset + 14
;	call	sprite_display_delay

; 22-->20

	ld	ix, PLAYER_RUNNING_LEFT_5R1
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R1
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4R2
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R2
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R3 
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R3
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R4
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R4
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R1
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R1
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4L1
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 22
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 22
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank


; 20-->18

	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4L1
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	call 	delay

	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 20
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 20
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank



; 18-->16

	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4L1
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 18
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 18
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank


; 16-->14
	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4L1
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 16
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 16
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank


; 14-->12


	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L1
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 14
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 14
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank



; 12-->10

	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4L1
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 12
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 12
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank

; 10-->8

	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	call 	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4L1
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 10
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 10
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
; 8-->6



	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4L1
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 8
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 8
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank



; 6-->4



	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4L1
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 6
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 6
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank


; 4-->2

	ld	ix, PLAYER_RUNNING_LEFT_1
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_1L2
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1L2
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_2L3
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2L3
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_3L4
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3L4
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_5R4	
	ld	iy, $7000 + Player_Y_offset + 2
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5R4
	ld	iy, $7000 + Enemy_Y_offset + 2
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_4L1
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4L1
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_4R1
	ld	iy, $7000 + Player_Y_offset + 2
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_4R1
	ld	iy, $7000 + Enemy_Y_offset + 2
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_5L2
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_5L2
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_3R2
	ld	iy, $7000 + Player_Y_offset + 2
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_3R2
	ld	iy, $7000 + Enemy_Y_offset + 2
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_6L3
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_6L3
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_2R3
	ld	iy, $7000 + Player_Y_offset + 2
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_2R3
	ld	iy, $7000 + Enemy_Y_offset + 2
	call	sprite_display_blank
	ld	ix, PLAYER_RUNNING_LEFT_7L4
	ld	iy, $7000 + Player_Y_offset + 4
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_7L4
	ld	iy, $7000 + Enemy_Y_offset + 4
	call	sprite_display_blank
	call	delay
	ld	ix, PLAYER_RUNNING_LEFT_1R4
	ld	iy, $7000 + Player_Y_offset + 2
	call	sprite_display_blank
	ld	ix, ENEMY_RUNNING_LEFT_1R4
	ld	iy, $7000 + Enemy_Y_offset + 2
	call	sprite_display_blank
	call	delay

	ld	ix, blank
	ld	iy, $7000 + Player_Y_offset + 2
	call	sprite_display_blank
	ld	ix, blank
	ld	iy, $7000 + Enemy_Y_offset + 2
	call	sprite_display_blank


;	ld	ix, PLAYER_RUNNING_LEFT_8
;	ld	iy, $7000 + Player_Y_offset + 14
;	call	sprite_display_delay
	jp 	anim

	

jumpo0:	jp	jumpo0







	ld	de, $7000 + (32 * 48)
	ld	b, 16

loops1:	ld	hl, brick
	push	de
	push	bc
	push	de
	pop	ix
	ldi
	ldi
	ex	de, hl
	ld	bc, 30
	add	hl, bc
	ex	de, hl
	ldi
	ldi
	ex	de, hl
	ld	bc, 30
	add	hl, bc
	ex	de, hl
	ldi
	ldi
	ex	de, hl
	ld	bc, 30
	add	hl, bc
	ex	de, hl
	ldi
	ldi
	ex	de, hl
	ld	bc, 30
	add	hl, bc
	ex	de, hl
	ldi
	ldi
	ex	de, hl
	ld	bc, 30
	add	hl, bc
	ex	de, hl
	ldi
	ldi
	pop	bc
	pop	de
	inc	de
	inc	de
	djnz	loops1




jumpo:	jp	jumpo



sprite_display_delay:




	call	delay
	
sprite_display_blank:
	push	ix
	push	iy
	ld	ix, blank
	inc	iy
	call	sprite_display
	pop	iy
	pop	ix



;pressspace2:ld 	a, ($68ef)	; press <space> to continue
;	and	$10
;	jr 	nz, pressspace2



sprite_display:
;; --------------------------------------
;; input : IX = Source : sprite name of source.
;;	 : IY = destination : top left position of sprite	
;;       
;; Display : 8-pixel wide by 6 high sprite.   (2 bytes wide)
;; 
;; 
	ld	a, (ix)	; row 1	
	ld	(iy), a
	inc	ix
	ld	a, (ix)
	ld	(iy+1), a
	inc	ix
	ld	a, (ix)	; row 2
	ld	(iy+32), a
	inc	ix
	ld	a, (ix)
	ld	(iy+33), a
	inc	ix
	ld	a, (ix)	; row 3
	ld	(iy+64), a
	inc	ix
	ld	a, (ix)
	ld	(iy+65), a
	inc	ix
	ld	a, (ix)	; row 4
	ld	(iy+96), a
	inc	ix
	ld	a, (ix)
	ld	(iy+97), a
	inc	ix
	ld	de, 128
	add	iy, de
	ld	a, (ix)	; row 5
	ld	(iy), a
	inc	ix
	ld	a, (ix)
	ld	(iy+1), a
	inc	ix
	ld	a, (ix)	; row 6
	ld	(iy+32), a
	inc	ix
	ld	a, (ix)
	ld	(iy+33), a
	ret

delay:	push	bc
	ld	b, 90
delaya:	push	bc
	call	delayb
	pop	bc
	djnz	delaya
	pop	bc
	ret
delayb:	ld	b, $ff
delayba:djnz	delayba
	ret


delay2:	push	bc
	ld	b, 128
delay2a:push	bc
	call	delay2b
	pop	bc
	djnz	delay2a
	pop	bc
	ret
delay2b:ld	b, $ff
delay2ba:djnz	delay2ba
	ret


delay3:	push	bc
	ld	b, 192
delay3a:push	bc
	call	delay3b
	pop	bc
	djnz	delay3a
	pop	bc
	ret
delay3b:ld	b, $ff
delay3ba:djnz	delay3ba
	ret

; ==============================================================================

blank: 	defb   $00, $00; /* ........ */	   // 00000000 00000000		// BLANK	         (1)
  	defb   $00, $00; /* ........ */	   // 00000000 00000000
  	defb   $00, $00; /* ........ */	   // 00000000 00000000
  	defb   $00, $00; /* ........ */	   // 00000000 00000000
  	defb   $00, $00; /* ........ */	   // 00000000 00000000
  	defb   $00, $00; /* ........ */	   // 00000000 00000000

solid:	defb   $AA, $AA; /* ######## */	   // 10101010 10101010		// SOLID CONCRETE	 (2)
	defb   $AA, $AA; /* ######## */	   // 10101010 10101010
	defb   $AA, $AA; /* ######## */	   // 10101010 10101010
	defb   $AA, $AA; /* ######## */	   // 10101010 10101010
	defb   $AA, $AA; /* ######## */	   // 10101010 10101010
	defb   $00, $00; /* ........ */	   // 00000000 00000000

brick: 	defb   $AA, $A2; /* ######.# */    // 10101010 10100010		// NORMAL BRICK WALL	 (2)
	defb   $AA, $A2; /* ######.# */    // 10101010 10100010
	defb   $00, $00; /* ........ */    // 00000000 00000000
	defb   $A2, $AA; /* ###.#### */    // 10100010 10101010
	defb   $A2, $AA; /* ###.#### */    // 10100010 10101010
	defb   $00, $00; /* ........ */	   // 00000000 00000000

ladder2:defb   $04, $10; /* ..#..#.. */,   // 00000100 00010000	        // YELLOW LADDER	(4)
	defb   $05, $50; /* ..####.. */,   // 00000101 01010000
	defb   $04, $10; /* ..#..#.. */,   // 00000100 00010000
	defb   $04, $10; /* ..#..#.. */,   // 00000100 00010000
	defb   $05, $50; /* ..####.. */,   // 00000101 01010000
	defb   $04, $10; /* ..#..#.. */,   // 00000100 00010000


ladder1:defb   %00010100, %0000010100	; /* .#....#. */,   // 00000100 00010000	        // YELLOW LADDER	(4)
	defb   %00010101, %0101010100	; /* .######. */,   // 00000101 01010000
	defb   %00010100, %0000010100	; /* .#....#. */,   // 00000100 00010000
 	defb   %00010100, %0000010100	; /* .#....#. */,   // 00000100 00010000
	defb   %00010101, %0101010100	; /* .######. */,   // 00000101 01010000
	defb   %00010100, %0000010100	; /* .#....#. */,   // 00000100 00010000

chick: 	defb   %00000001, %01000000	; /* ...YY... */,   // 00000001 01000000            // PRINCESS	(5)
 	defb   %00000001, %01000000	; /* ...YY... */,   // 00000001 01000000
	defb   %00000111, %11010000	; /* ..YRRY.. */,   // 00000101 01010000
	defb   %00000011, %11000000	; /* ...RR... */,   // 00000001 01000000
	defb   %00001111, %11110000	; /* ..RRRR.. */,   // 00001111 11110000
	defb   %00000010, %10000000	; /* ...BB... */,   // 00010000 00000100

box:	defb   %00000000, %00000000	; /* ........ */,	// 00000000 00000000		// BOX (6)
	defb   %00000000, %00000000	; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000	; /* ..RRRR.. */,	// 00000011 11000000
	defb   %00001111, %11000000	; /* ..YYYY.. */,	// 00000101 01010000
	defb   %00000101, %01000000	; /* ..RRRR... */,	// 00000011 11000000
	defb   %00001111, %11000000	; /* ..YYYY.. */,	// 00000000 00000000

bar:	defb   $55, $55; /* YYYYYYYY */,	// 01010101 01010101
	defb   $00, $00; /* ........ */,	// 00000000 00000000		// BOX (6)
	defb   $00, $00; /* ........ */,	// 00000000 00000000
	defb   $00, $00; /* ........ */,	// 00000000 00000000
	defb   $00, $00; /* ........ */,	// 00000000 00000000
	defb   $00, $00; /* ........ */,	// 00000000 00000000



; %000000001111000000
; %000000111111000000
; %000000111111000000
; %000000001111000000
; %000000111111110000
; %000011001111001100
; %001100001111000011
; %110000111111000000
; %000000001111110000
; %000000001111001100
; %000000001111000000


; SHIFT RIGHT 5 pixel
PLAYER_RUNNING_LEFT_5R1:
	defb   %00000000, %00000001 	;// $00, $00; /* .......Y */, 	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000010 	;// $00, $02; /* .......B */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
PLAYER_RUNNING_LEFT_5R2:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
PLAYER_RUNNING_LEFT_5R3:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
PLAYER_RUNNING_LEFT_5R4:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000001   	;// $00, $01; /* .......Y */,	// 00000000 00000000

; SHIFT RIGHT 4 pixel
PLAYER_RUNNING_LEFT_4R1:
	defb   %00000000, %00000101 	;// $00, $00; /* ......YY */,	// 00000000 00000000
	defb   %00000000, %00000010 	;// $00, $00; /* .......B */,	// 00000000 00000000
	defb   %00000000, %00001000 	;// $00, $00; /* ......B. */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000001 	;// $00, $00; /* .......Y */,	// 00000000 00000000
	defb   %00000000, %00000001 	;// $00, $00; /* .......Y */,	// 00000000 00000000
PLAYER_RUNNING_LEFT_4R2:
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
	defb   %00000000, %00000010 	;// $00, $02; /* .......B */,	// 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 01000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000100
PLAYER_RUNNING_LEFT_4R3:
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 10100000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */,	// 00000001 00010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00010000
PLAYER_RUNNING_LEFT_4R4:
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
	defb   %00000000, %00000010 	;// $00, $02; /* .......B */,	// 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */,	// 00000001 00000100
	defb   %00000000, %00000100 	;// $00, $04; /* ......Y. */,	// 00000000 00000100

; SHIFT RIGHT 3 pixel 
PLAYER_RUNNING_LEFT_3R1:
	defb   %00000000, %00000101 	;// $00, $05; /* ......YY */, 	// 00000001 01000101		// RUNNER LEFT 1 (7)
	defb   %00000000, %00001010 	;// $00, $0A; /* ......BB */,	// 00000010 00001010
	defb   %00000000, %00100010 	;// $080 $00; /* .....B.B */,	// 00001000 10000010
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */,	// 00000000 01010000
	defb   %00000000, %00000100 	;// $00, $04; /* ......Y. */,	// 00000001 00000101
	defb   %00000000, %00000100 	;// $00, $04; /* ......Y. */,	// 00000001 00000000
PLAYER_RUNNING_LEFT_3R2:
	defb   %00000000, %00000101 	;// $00, $05; /* ......YY */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000010 	;// $00, $02; /* .......B */,	// 00000010 10100000
	defb   %00000000, %00001010 	;// $00, $0A; /* ......BB */,	// 00000010 10001000
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */,	// 00000000 01010000
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */,	// 00000001 01000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000100
PLAYER_RUNNING_LEFT_3R3:
	defb   %00000000, %00000101 	;// $00, $05; /* ......YY */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000010 	;// $00, $02; /* .......B */,	// 00000010 10000000
	defb   %00000000, %00000010 	;// $00, $02; /* .......B */,	// 00000000 10100000
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */,	// 00000000 01010000
	defb   %00000000, %00000100 	;// $00, $04; /* ......Y. */,	// 00000001 00010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00010000
PLAYER_RUNNING_LEFT_3R4:
	defb   %00000000, %00000101 	;// $00, $05; /* ......YY */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000010 	;// $00, $02; /* .......B */,	// 00000010 10100000
	defb   %00000000, %00001010 	;// $00, $0A; /* ......BB */,	// 00000010 10001000
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */,	// 00000000 01010000
	defb   %00000000, %00000100 	;// $00, $04; /* ......Y. */,	// 00000001 00000100
	defb   %00000000, %00010000 	;// $00, $10; /* .....Y.. */,	// 00000000 00010000

; SHIFT RIGHT 2 pixel
PLAYER_RUNNING_LEFT_2R1:
	defb   %00000000, %00010100 	;// $00, $14; /* .....YY. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00101010 	;// $00, $2A; /* .....BBB */,	// 00000010 10101000
	defb   %00000000, %10001000 	;// $00, $88; /* ....B.B. */,	// 00001000 10000010
	defb   %00000000, %00000101 	;// $00, $05; /* ......YY */,	// 00000000 01010000
	defb   %00000000, %00010000 	;// $00, $10; /* .....Y.. */,	// 00000001 00000101
	defb   %00000000, %00010000 	;// $00, $10; /* .....Y.. */,	// 00000001 00000000
PLAYER_RUNNING_LEFT_2R2:
	defb   %00000000, %00010100 	;// $00, $14; /* .....YY. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00001010 	;// $00, $0A; /* ......BB */,	// 00000010 10100000
	defb   %00000000, %00101000 	;// $00, $28; /* .....BB. */,	// 00000010 10001000
	defb   %00000000, %00000101 	;// $00, $05; /* ......YY */,	// 00000000 01010000
	defb   %00000000, %00000100 	;// $00, $04; /* ......Y. */,	// 00000001 01000100
	defb   %00000000, %00000001 	;// $00, $01; /* .......Y */,	// 00000000 00000100
PLAYER_RUNNING_LEFT_2R3:
	defb   %00000000, %00010100 	;// $00, $14; /* .....YY. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00001000 	;// $00, $08; /* ......B. */,	// 00000010 10000000
	defb   %00000000, %00001010 	;// $00, $0A; /* ......BB */,	// 00000000 10100000
	defb   %00000000, %00000101 	;// $00, $05; /* ......YY */,	// 00000000 01010000
	defb   %00000000, %00010001 	;// $00, $11; /* .....Y.Y */,	// 00000001 00010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00010000
PLAYER_RUNNING_LEFT_2R4:
	defb   %00000000, %00010100 	;// $00, $14; /* .....YY. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00001010 	;// $00, $0A; /* ......BB */,	// 00000010 10100000
	defb   %00000000, %00101000 	;// $00, $28; /* .....BB. */,	// 00000010 10001000
	defb   %00000000, %00000101 	;// $00, $05; /* ......YY */,	// 00000000 01010000
	defb   %00000000, %00010000 	;// $00, $10; /* .....Y.. */,	// 00000001 00000100
	defb   %00000000, %01000000 	;// $00, $40; /* ....Y... */,	// 00000100 00000000

; SHIFT RIGHT 1 pixel  
PLAYER_RUNNING_LEFT_1R1:
	defb   %00000000, %01010000 	;// $00, $50; /* ....YY.. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %10101010 	;// $00, $AA; /* ....BBBB */,	// 00000010 10101000
	defb   %00000010, %00100000 	;// $02, $20; /* ...B.B.. */,	// 00001000 10000010
	defb   %00000000, %00010100 	;// $00, $14; /* .....YY. */,	// 00000000 01010000
	defb   %00000000, %01000001 	;// $00, $41; /* ....Y..Y */,	// 00000001 00000101
	defb   %00000000, %01000000 	;// $00, $40; /* ....Y... */,	// 00000001 00000000
PLAYER_RUNNING_LEFT_1R2:
        defb   %00000000, %01010000     ;// $00, $50; /* ....YY.. */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %00101000     ;// $00, $28; /* .....BB. */,    // 00000010 10100000
        defb   %00000000, %10100010     ;// $00, $A2; /* ....BB.B */,    // 00000010 10001000
        defb   %00000000, %00010100     ;// $00, $14; /* .....YY. */,    // 00000000 01010000
        defb   %00000000, %00010001     ;// $00, $11; /* .....Y.Y */,    // 00000001 01000100
        defb   %00000000, %00000100     ;// $00, $04; /* ......Y. */,    // 00000000 00000100
PLAYER_RUNNING_LEFT_1R3:
        defb   %00000000, %01010000     ;// $00, $50; /* ....YY.. */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %00100000     ;// $00, $20; /* .....B.. */,    // 00000010 10000000
        defb   %00000000, %00101000     ;// $00, $28; /* .....BB. */,    // 00000000 10100000
        defb   %00000000, %00010100     ;// $00, $14; /* .....YY. */,    // 00000000 01010000
        defb   %00000000, %01000100     ;// $00, $44; /* ....Y.Y. */,    // 00000001 00010000
        defb   %00000000, %00000001     ;// $00, $01; /* .......Y */,    // 00000000 00010000
PLAYER_RUNNING_LEFT_1R4:
        defb   %00000000, %01010000     ;// $00, $50; /* ....YY.. */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %00101000     ;// $00, $28; /* .....BB. */,    // 00000010 10100000
        defb   %00000000, %10100010     ;// $00, $A2; /* ....BB.B */,    // 00000010 10001000
        defb   %00000000, %00010100     ;// $00, $14; /* .....YY. */,    // 00000000 01010000
        defb   %00000000, %01000001     ;// $00, $41; /* ....Y..Y */,    // 00000001 00000100
        defb   %00000001, %00000000     ;// $01, $00; /* ...Y.... */,    // 00000100 00000000

; DEAD SET SMACK MIDDLE; [DJM]
PLAYER_RUNNING_LEFT_1:
        defb   %00000001, %01000000     ;// $00, $00; /* ...YY... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000010, %10101000     ;// $00, $00; /* ...BBBB. */,    // 00000010 10101000
        defb   %00001000, %10000010     ;// $00, $00; /* ..B.B..B */,    // 00001000 10000010
        defb   %00000000, %01010000     ;// $00, $00; /* ....YY.. */,    // 00000000 01010000
        defb   %00000001, %00000101     ;// $00, $00; /* ...Y..YY */,    // 00000001 00000101
        defb   %00000001, %00000000     ;// $00, $00; /* ...Y.... */,    // 00000001 00000000
PLAYER_RUNNING_LEFT_2:
        defb   %00000001, %01000000     ;// $00, $00; /* ...YY... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %10100000     ;// $00, $00; /* ....BB.. */,    // 00000010 10100000
        defb   %00000010, %10001000     ;// $00, $00; /* ...BB.B. */,    // 00000010 10001000
        defb   %00000000, %01010000     ;// $00, $00; /* ....YY.. */,    // 00000000 01010000
        defb   %00000000, %01000100     ;// $00, $00; /* ....Y.Y. */,    // 00000001 01000100
        defb   %00000000, %00010000     ;// $00, $00; /* .....Y.. */,    // 00000000 00000100
PLAYER_RUNNING_LEFT_3:
        defb   %00000001, %01000000     ;// $00, $00; /* ...YY... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %10000000     ;// $00, $00; /* ....B... */,    // 00000010 10000000
        defb   %00000000, %10100000     ;// $00, $00; /* ....BB.. */,    // 00000000 10100000
        defb   %00000000, %01010000     ;// $00, $00; /* ....YY.. */,    // 00000000 01010000
        defb   %00000001, %00010000     ;// $00, $00; /* ...Y.Y.. */,    // 00000001 00010000
        defb   %00000000, %00000100     ;// $00, $00; /* ......Y. */,    // 00000000 00010000
PLAYER_RUNNING_LEFT_4:
        defb   %00000001, %01000000     ;// $00, $00; /* ...YY... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %10100000     ;// $00, $00; /* ....BB.. */,    // 00000010 10100000
        defb   %00000010, %10001000     ;// $00, $00; /* ...BB.B. */,    // 00000010 10001000
        defb   %00000000, %01010000     ;// $00, $00; /* ....YY.. */,    // 00000000 01010000
        defb   %00000001, %00000100     ;// $00, $00; /* ...Y..Y. */,    // 00000001 00000100
        defb   %00000100, %00000000     ;// $00, $00; /* ..Y..... */,    // 00000100 00000000

; SHIFT LEFT 1 PIXEL
PLAYER_RUNNING_LEFT_1L1:
        defb   %00000101, %00000000     ;// $00, $00; /* ..YY.... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00001010, %10100000     ;// $00, $00; /* ..BBBB.. */,    // 00000010 10101000
        defb   %00100010, %00001000     ;// $00, $00; /* .B.B..B. */,    // 00001000 10000010
        defb   %00000001, %01000000     ;// $00, $00; /* ...YY... */,    // 00000000 01010000
        defb   %00000100, %00010100     ;// $00, $00; /* ..Y..YY. */,    // 00000001 00000101
        defb   %00000100, %00000000     ;// $00, $00; /* ..Y..... */,    // 00000001 00000000
PLAYER_RUNNING_LEFT_1L2:
        defb   %00000101, %00000000     ;// $00, $00; /* ..YY.... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000010, %10000000     ;// $00, $00; /* ...BB... */,    // 00000010 10100000
        defb   %00001010, %00100000     ;// $00, $00; /* ..BB.B.. */,    // 00000010 10001000
        defb   %00000001, %01000000     ;// $00, $00; /* ...YY... */,    // 00000000 01010000
        defb   %00000001, %00010000     ;// $00, $00; /* ...Y.Y.. */,    // 00000001 01000100
        defb   %00000000, %01000000     ;// $00, $00; /* ....Y... */,    // 00000000 00000100
PLAYER_RUNNING_LEFT_1L3:
        defb   %00000101, %00000000     ;// $00, $00; /* ..YY.... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000010, %00000000     ;// $00, $00; /* ...B.... */,    // 00000010 10000000
        defb   %00000010, %10000000     ;// $00, $00; /* ...BB... */,    // 00000000 10100000
        defb   %00000001, %01000000     ;// $00, $00; /* ...YY... */,    // 00000000 01010000
        defb   %00000100, %01000000     ;// $00, $00; /* ..Y.Y... */,    // 00000001 00010000
        defb   %00000000, %00010000     ;// $00, $00; /* .....Y.. */,    // 00000000 00010000
PLAYER_RUNNING_LEFT_1L4:
        defb   %00000101, %00000000     ;// $00, $00; /* ..YY.... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000010, %10000000     ;// $00, $00; /* ...BB... */,    // 00000010 10100000
        defb   %00001010, %00100000     ;// $00, $00; /* ..BB.B.. */,    // 00000010 10001000
        defb   %00000001, %01000000     ;// $00, $00; /* ...YY... */,    // 00000000 01010000
        defb   %00000100, %00010000     ;// $00, $00; /* ..Y..Y.. */,    // 00000001 00000100
        defb   %00010000, %00000000     ;// $00, $00; /* .Y...... */,    // 00000100 00000000

; SHIFT LEFT 2 PIXEL
PLAYER_RUNNING_LEFT_2L1:
        defb   %00010100, %00000000     ;// $00, $00; /* .YY..... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00101010, %10000000     ;// $00, $00; /* .BBBB... */,    // 00000010 10101000
        defb   %10001000, %00100000     ;// $00, $00; /* B.B..B.. */,    // 00001000 10000010
        defb   %00000101, %00000000     ;// $00, $00; /* ..YY.... */,    // 00000000 01010000
        defb   %00010000, %01010000     ;// $00, $00; /* .Y..YY.. */,    // 00000001 00000101
        defb   %00010000, %00000000     ;// $00, $00; /* .Y...... */,    // 00000001 00000000
PLAYER_RUNNING_LEFT_2L2:
        defb   %00010100, %00000000     ;// $00, $00; /* .YY..... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00001010, %00000000     ;// $00, $00; /* ..BB.... */,    // 00000010 10100000
        defb   %00101000, %10000000     ;// $00, $00; /* .BB.B... */,    // 00000010 10001000
        defb   %00000101, %00000000     ;// $00, $00; /* ..YY.... */,    // 00000000 01010000
        defb   %00000100, %01000000     ;// $00, $00; /* ..Y.Y... */,    // 00000001 01000100
        defb   %00000001, %00000000     ;// $00, $00; /* ...Y.... */,    // 00000000 00000100
PLAYER_RUNNING_LEFT_2L3:
        defb   %00010100, %00000000     ;// $00, $00; /* .YY..... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00001000, %00000000     ;// $00, $00; /* ..B..... */,    // 00000010 10000000
        defb   %00001010, %00000000     ;// $00, $00; /* ..BB.... */,    // 00000000 10100000
        defb   %00000101, %00000000     ;// $00, $00; /* ..YY.... */,    // 00000000 01010000
        defb   %00010001, %00000000     ;// $00, $00; /* .Y.Y.... */,    // 00000001 00010000
        defb   %00000000, %01000000     ;// $00, $00; /* ....Y... */,    // 00000000 00010000
PLAYER_RUNNING_LEFT_2L4:
        defb   %00010100, %00000000     ;// $00, $00; /* .YY..... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00001010, %00000000     ;// $00, $00; /* ..BB.... */,    // 00000010 10100000
        defb   %00101000, %10000000     ;// $00, $00; /* .BB.B... */,    // 00000010 10001000
        defb   %00000101, %00000000     ;// $00, $00; /* ..YY.... */,    // 00000000 01010000
        defb   %00010000, %01000000     ;// $00, $00; /* .Y..Y... */,    // 00000001 00000100
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000100 00000000

; SHIFT LEFT 3 PIXEL
PLAYER_RUNNING_LEFT_3L1:
        defb   %01010000, %00000000     ;// $00, $00; /* YY...... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %10101010, %00000000     ;// $00, $00; /* BBBB.... */,    // 00000010 10101000
        defb   %00100000, %10000000     ;// $00, $00; /* .B..B... */,    // 00001000 10000010
        defb   %00010100, %00000000     ;// $00, $00; /* .YY..... */,    // 00000000 01010000
        defb   %01000001, %01000000     ;// $00, $00; /* Y..YY... */,    // 00000001 00000101
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000001 00000000
PLAYER_RUNNING_LEFT_3L2:
        defb   %01010000, %00000000     ;// $00, $00; /* YY...... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00101000, %00000000     ;// $00, $00; /* .BB..... */,    // 00000010 10100000
        defb   %10100010, %00000000     ;// $00, $00; /* BB.B.... */,    // 00000010 10001000
        defb   %00010100, %00000000     ;// $00, $00; /* .YY..... */,    // 00000000 01010000
        defb   %00010001, %00000000     ;// $00, $00; /* .Y.Y.... */,    // 00000001 01000100
        defb   %00000100, %00000000     ;// $00, $00; /* ..Y..... */,    // 00000000 00000100
PLAYER_RUNNING_LEFT_3L3:
        defb   %01010000, %00000000     ;// $00, $00; /* YY...... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000010 10000000
        defb   %00101000, %00000000     ;// $00, $00; /* .BB..... */,    // 00000000 10100000
        defb   %00010100, %00000000     ;// $00, $00; /* .YY..... */,    // 00000000 01010000
        defb   %01000100, %00000000     ;// $00, $00; /* Y.Y..... */,    // 00000001 00010000
        defb   %00000001, %00000000     ;// $00, $00; /* ...Y.... */,    // 00000000 00010000
PLAYER_RUNNING_LEFT_3L4:
        defb   %01010000, %00000000     ;// $00, $00; /* YY...... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00101000, %00000000     ;// $00, $00; /* .BB..... */,    // 00000010 10100000
        defb   %10100010, %00000000     ;// $00, $00; /* BB.B.... */,    // 00000010 10001000
        defb   %00010100, %00000000     ;// $00, $00; /* .YY..... */,    // 00000000 01010000
        defb   %01000001, %00000000     ;// $00, $00; /* Y..Y.... */,    // 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000100 00000000


; SHIFT LEFT 4 PIXEL
PLAYER_RUNNING_LEFT_4L1:
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %10101000, %00000000     ;// $00, $00; /* BBB..... */,    // 00000010 10101000
        defb   %10000010, %00000000     ;// $00, $00; /* B..B.... */,    // 00001000 10000010
        defb   %01010000, %00000000     ;// $00, $00; /* YY...... */,    // 00000000 01010000
        defb   %00000101, %00000000     ;// $00, $00; /* ..YY.... */,    // 00000001 00000101
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000000
PLAYER_RUNNING_LEFT_4L2:
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %10100000, %00000000     ;// $00, $00; /* BB...... */,    // 00000010 10100000
        defb   %10001000, %00000000     ;// $00, $00; /* B.B..... */,    // 00000010 10001000
        defb   %01010000, %00000000     ;// $00, $00; /* YY...... */,    // 00000000 01010000
        defb   %01000100, %00000000     ;// $00, $00; /* Y.Y..... */,    // 00000001 01000100
        defb   %00010000, %00000000     ;// $00, $00; /* .Y...... */,    // 00000000 00000100
PLAYER_RUNNING_LEFT_4L3:
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000010 10000000
        defb   %10100000, %00000000     ;// $00, $00; /* BB...... */,    // 00000000 10100000
        defb   %01010000, %00000000     ;// $00, $00; /* YY...... */,    // 00000000 01010000
        defb   %00010000, %00000000     ;// $00, $00; /* .Y...... */,    // 00000001 00010000
        defb   %00000100, %00000000     ;// $00, $00; /* ..Y..... */,    // 00000000 00010000
PLAYER_RUNNING_LEFT_4L4:
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %10100000, %00000000     ;// $00, $00; /* BB...... */,    // 00000010 10100000
        defb   %10001000, %00000000     ;// $00, $00; /* B.B..... */,    // 00000010 10001000
        defb   %01010000, %00000000     ;// $00, $00; /* YY...... */,    // 00000000 01010000
        defb   %00000100, %00000000     ;// $00, $00; /* ..Y..... */,    // 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000100 00000000


; SHIFT LEFT 5 PIXEL
PLAYER_RUNNING_LEFT_5L1:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
        defb   %10100000, %00000000     ;// $00, $00; /* BB...... */,    // 00000010 10101000
        defb   %00001000, %00000000     ;// $00, $00; /* ..B..... */,    // 00001000 10000010
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000000 01010000
        defb   %00010100, %00000000     ;// $00, $00; /* .YY..... */,    // 00000001 00000101
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000000
PLAYER_RUNNING_LEFT_5L2:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000010 10100000
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000010 10001000
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000000 01010000
        defb   %00010000, %00000000     ;// $00, $00; /* .Y...... */,    // 00000001 01000100
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000000 00000100
PLAYER_RUNNING_LEFT_5L3:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10000000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000000 10100000
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000000 01010000
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000001 00010000
        defb   %00010000, %00000000     ;// $00, $00; /* .Y...... */,    // 00000000 00010000
PLAYER_RUNNING_LEFT_5L4:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000010 10100000
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000010 10001000
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000000 01010000
        defb   %00010000, %00000000     ;// $00, $00; /* .Y...... */,    // 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000100 00000000

; SHIFT LEFT 6 PIXEL
PLAYER_RUNNING_LEFT_6L1:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000010 10101000
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00001000 10000010
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
        defb   %01010000, %00000000     ;// $00, $00; /* YY...... */,    // 00000001 00000101
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000000
PLAYER_RUNNING_LEFT_6L2:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000001 01000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000100
PLAYER_RUNNING_LEFT_6L3:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 10100000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00010000
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000000 00010000
PLAYER_RUNNING_LEFT_6L4:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000100 00000000


; SHIFT LEFT 7 PIXEL
PLAYER_RUNNING_LEFT_7L1:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10101000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00001000 10000010
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
        defb   %01000000, %00000000     ;// $00, $00; /* Y....... */,    // 00000001 00000101
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000000
PLAYER_RUNNING_LEFT_7L2:
	defb   %00000000, %00000000 	;// $01, $40; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $A0; /* ........ */,	// 00000010 10100000
	defb   %00000000, %00000000 	;// $02, $88; /* ........ */,	// 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $50; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $44; /* ........ */,	// 00000001 01000100
	defb   %00000000, %00000000 	;// $00, $04; /* ........ */,	// 00000000 00000100
PLAYER_RUNNING_LEFT_7L3:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 10100000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00010000
PLAYER_RUNNING_LEFT_7L4:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000100 00000000

;============================ ORIGINAL WORKING =================================

PLAYER_RUNNING_LEFT_1_orig:
	defb   $01, $40; /* ...YY... */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   $02, $A8; /* ...BBBB. */,	// 00000010 10101000
	defb   $08, $82; /* ..B.B..B */,	// 00001000 10000010
	defb   $00, $50; /* ....YY.. */,	// 00000000 01010000
	defb   $01, $05; /* ...Y..YY */,	// 00000001 00000101
	defb   $01, $00; /* ...Y.... */,	// 00000001 00000000
PLAYER_RUNNING_LEFT_2_orig:
	defb   $01, $40; /* ...YY... */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   $00, $A0; /* ....BB.. */,	// 00000010 10100000
	defb   $02, $88; /* ...BB.B. */,	// 00000010 10001000
	defb   $00, $50; /* ....YY.. */,	// 00000000 01010000
	defb   $00, $44; /* ....Y.Y. */,	// 00000001 01000100
	defb   $00, $04; /* .....Y.. */,	// 00000000 00000100
PLAYER_RUNNING_LEFT_3_orig:
	defb   $01, $40; /* ...YY... */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   $00, $80; /* ....B... */,	// 00000010 10000000
	defb   $00, $A0; /* ....BB.. */,	// 00000000 10100000
	defb   $00, $50; /* ....YY.. */,	// 00000000 01010000
	defb   $01, $10; /* ...Y.Y.. */,	// 00000001 00010000
	defb   $00, $10; /* ......Y. */,	// 00000000 00010000
PLAYER_RUNNING_LEFT_4_orig:
	defb   $01, $40; /* ...YY... */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   $00, $A0; /* ....BB.. */,	// 00000010 10100000
	defb   $02, $88; /* ...BB.B. */,	// 00000010 10001000
	defb   $00, $50; /* ....YY.. */,	// 00000000 01010000
	defb   $01, $04; /* ...Y..Y. */,	// 00000001 00000100
	defb   $04, $00; /* ..Y..... */,	// 00000100 00000000

;============================================================================

	defb   $00, $00; /* ...##... */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ...####. */,	// 00000000 00000000
	defb   $00, $00; /* ..#.#..# */,	// 00000000 00000000
	defb   $00, $00; /* ....##.. */,	// 00000000 00000000
	defb   $00, $00; /* ...#..## */,	// 00000000 00000000
	defb   $00, $00; /* ...#.... */,	// 00000000 00000000

	defb   $00, $00; /* ....##.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ....#### */,	// 00000000 00000000
	defb   $00, $00; /* ...#.#.. */,	// 00000000 00000000
	defb   $00, $00; /* .....##. */,	// 00000000 00000000
	defb   $00, $00; /* ....#..# */,	// 00000000 00000000
	defb   $00, $00; /* ....#... */,	// 00000000 00000000

	defb   $00, $00; /* ..##.... */,	// 00000000 00000000		// RUNNER LEFT 2 (8)
	defb   $00, $00; /* ..###... */,	// 00000000 00000000
	defb   $00, $00; /* .##.#... */,	// 00000000 00000000
	defb   $00, $00; /* ...##... */,	// 00000000 00000000
	defb   $00, $00; /* ..#..#.. */,	// 00000000 00000000
	defb   $00, $00; /* ...#..#. */,	// 00000000 00000000


;======================================================================

PLAYER_RUNNING_RIGHT_1:
	defb   $00, $00; /* .YY..... */, 	// 00101000 00000000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* BB...... */,	// 10100000 00000000
	defb   $00, $00; /* BB...... */,	// 10100000 00000000
	defb   $00, $00; /* YY...... */,	// 01010000 00000000
	defb   $00, $00; /* YY...... */,	// 01010000 00000000
	defb   $00, $00; /* Y....... */,	// 01000000 00000000
PLAYER_RUNNING_RIGHT_2:
	defb   $00, $00; /* ..YY.... */, 	// 00000101 00000000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* .BB..... */,	// 00101000 00000000
	defb   $00, $00; /* .BBB.... */,	// 00101010 00000000
	defb   $00, $00; /* .YYY.... */,	// 01010101 00000000
	defb   $00, $00; /* YYYY.... */,	// 01010101 00000000
	defb   $00, $00; /* .Y...... */,	// 00010000 00000000
PLAYER_RUNNING_RIGHT_3:
	defb   $00, $00; /* ...YY... */, 	// 00000001 01000000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* ..BB.... */,	// 00001010 00000000
	defb   $00, $00; /* .BBBY... */,	// 00101010 01000000
	defb   $00, $00; /* ..YYY... */,	// 00000101 01000000
	defb   $00, $00; /* .Y..Y... */,	// 00010000 01000000
	defb   $00, $00; /* .Y...... */,	// 00010000 00000000
PLAYER_RUNNING_RIGHT_4:
	defb   $00, $00; /* ....YY.. */, 	// 00000000 01010000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* ..BBB... */,	// 00001010 10000000
	defb   $00, $00; /* .B..BB.. */,	// 00100000 10100000
	defb   $00, $00; /* ...YY... */,	// 00000001 01000000
	defb   $00, $00; /* .YY..Y.. */,	// 00010100 00010000
	defb   $00, $00; /* .....Y.. */,	// 00000000 00010000
PLAYER_RUNNING_RIGHT_5:
	defb   $00, $00; /* .....YY. */, 	// 00000000 00010100		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* ....BB.. */,	// 00000000 10100000
	defb   $00, $00; /* ...BBBY. */,	// 00000010 10100100
	defb   $00, $00; /* ....YYY. */,	// 00000000 01010100
	defb   $00, $00; /* ...Y..Y. */,	// 00000001 00000100
	defb   $00, $00; /* ...Y.... */,	// 00000001 00000000
PLAYER_RUNNING_RIGHT_6:
	defb   $00, $00; /* ......YY */, 	// 00000000 00000101		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* .....BB. */,	// 00000000 00101000
	defb   $00, $00; /* .....BBB */,	// 00000000 00101010
	defb   $00, $00; /* .....YYY */,	// 00000000 00010101
	defb   $00, $00; /* ....YYYY */,	// 00000000 01010101
	defb   $00, $00; /* .....Y.. */,	// 00000000 00010000
PLAYER_RUNNING_RIGHT_7:
	defb   $00, $00; /* .......Y */, 	// 00000000 00000001		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ......BB */,	// 00000000 00001010
	defb   $00, $00; /* .....BB. */,	// 00000000 00101000
	defb   $00, $00; /* .....YY. */,	// 00000000 00010100
	defb   $00, $00; /* .....YY. */,	// 00000000 00010100
	defb   $00, $00; /* .....Y.. */,	// 00000000 00010000
PLAYER_RUNNING_RIGHT_8:
	defb   $00, $00; /* ........ */, 	// 00000000 00000000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* .......B */,	// 00000000 00000010
	defb   $00, $00; /* ......BB */,	// 00000000 00001010
	defb   $00, $00; /* ......YY */,	// 00000000 00000101
	defb   $00, $00; /* ......YY */,	// 00000000 00000101
	defb   $00, $00; /* .......Y */,	// 00000000 00000001


PLAYER_STAND_STILL:
	defb   $00, $00; /* ..YY.... */, 	// 00000101 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..BBBB.. */,	// 00001010 10100000
	defb   $00, $00; /* ..BBBB.. */,	// 00001010 10100000
	defb   $00, $00; /* ..BYYB.. */,	// 00001001 01100000
	defb   $00, $00; /* ...YY... */,	// 00000001 01000000
	defb   $00, $00; /* ...YY... */,	// 00000001 01000000
ENEMY_STAND_STILL:
	defb   $00, $00; /* ...YY... */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..RRRR.. */,	// 00001111 11110000
	defb   $00, $00; /* ..RRRR.. */,	// 00001111 11110000
	defb   $00, $00; /* ..RYYR.. */,	// 00001101 01110000
	defb   $00, $00; /* ...YY... */,	// 00000001 01000000
	defb   $00, $00; /* ...YY... */,	// 00000001 01000000
PLAYER_BAR_LEFT_1:
	defb   $00, $00; /* .B.YYB.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..BBBB.. */,	// 00000000 00000000
	defb   $00, $00; /* ..BBB... */,	// 00000000 00000000
	defb   $00, $00; /* ...BB... */,	// 00000000 00000000
	defb   $00, $00; /* ....YY.. */,	// 00000000 00000000
	defb   $00, $00; /* ....YY.. */,	// 00000000 00000000
PLAYER_BAR_LEFT_2:
	defb   $00, $00; /* .BYY.B.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..BBBB.. */,	// 00000000 00000000
	defb   $00, $00; /* ...BBB.. */,	// 00000000 00000000
	defb   $00, $00; /* ...BB... */,	// 00000000 00000000
	defb   $00, $00; /* ....YY.. */,	// 00000000 00000000
	defb   $00, $00; /* ....YY.. */,	// 00000000 00000000
PLAYER_BAR_RIGHT_1:
	defb   $00, $00; /* .B.YYB.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..BBBB.. */,	// 00000000 00000000
	defb   $00, $00; /* ..BBB... */,	// 00000000 00000000
	defb   $00, $00; /* ...BB... */,	// 00000000 00000000
	defb   $00, $00; /* ..YY.... */,	// 00000000 00000000
	defb   $00, $00; /* ..YY.... */,	// 00000000 00000000
PLAYER_BAR_RIGHT_2:
	defb   $00, $00; /* .BYY.B.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..BBBB.. */,	// 00000000 00000000
	defb   $00, $00; /* ...BBB.. */,	// 00000000 00000000
	defb   $00, $00; /* ...BB... */,	// 00000000 00000000
	defb   $00, $00; /* ..YY.... */,	// 00000000 00000000
	defb   $00, $00; /* ..YY.... */,	// 00000000 00000000
ENEMY_BAR_LEFT_1:
	defb   $00, $00; /* .R.YYR.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..RRRR.. */,	// 00000000 00000000
	defb   $00, $00; /* ..RRR... */,	// 00000000 00000000
	defb   $00, $00; /* ...RR... */,	// 00000000 00000000
	defb   $00, $00; /* ....YY.. */,	// 00000000 00000000
	defb   $00, $00; /* ....YY.. */,	// 00000000 00000000
ENEMY_BAR_LEFT_2:
	defb   $00, $00; /* .RYY.R.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..RRRR.. */,	// 00000000 00000000
	defb   $00, $00; /* ...RRR.. */,	// 00000000 00000000
	defb   $00, $00; /* ...RR... */,	// 00000000 00000000
	defb   $00, $00; /* ....YY.. */,	// 00000000 00000000
	defb   $00, $00; /* ....YY.. */,	// 00000000 00000000
ENEMY_BAR_RIGHT_1:
	defb   $00, $00; /* .R.YYR.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..RRRR.. */,	// 00000000 00000000
	defb   $00, $00; /* ..RRR... */,	// 00000000 00000000
	defb   $00, $00; /* ...RR... */,	// 00000000 00000000
	defb   $00, $00; /* ..YY.... */,	// 00000000 00000000
	defb   $00, $00; /* ..YY.... */,	// 00000000 00000000
ENEMY_BAR_RIGHT_2:
	defb   $00, $00; /* .RYY.R.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..RRRR.. */,	// 00000000 00000000
	defb   $00, $00; /* ...RRR.. */,	// 00000000 00000000
	defb   $00, $00; /* ...RR... */,	// 00000000 00000000
	defb   $00, $00; /* ..YY.... */,	// 00000000 00000000
	defb   $00, $00; /* ..YY.... */,	// 00000000 00000000

; ==============================================================

;ENEMY_RUNNING_LEFT===========================================================
xENEMY_RUNNING_LEFT_1:    
	defb   $00, $00; /* .....YY. */, 	// 00000000 00010100		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ......RR */,	// 00000000 00001111
	defb   $00, $00; /* ......RR */,	// 00000000 00001111
	defb   $00, $00; /* ......YY */,	// 00000000 00000101
	defb   $00, $00; /* ......YY */,	// 00000000 00000101
	defb   $00, $00; /* .......Y */,	// 00000000 00000001
xENEMY_RUNNING_LEFT_2:
	defb   $00, $00; /* ....YY.. */, 	// 00000000 01010000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* .....RR. */,	// 00000000 00111100
	defb   $00, $00; /* ....RRR. */,	// 00000000 11111100
	defb   $00, $00; /* ....YYY. */,	// 00000000 01010100
	defb   $00, $00; /* ....YYYY */,	// 00000000 01010101
	defb   $00, $00; /* ......Y. */,	// 00000000 00000100
xENEMY_RUNNING_LEFT_3:
	defb   $00, $00; /* ...YY... */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ....RR.. */,	// 00000000 11110000
	defb   $00, $00; /* ...YRRR. */,	// 00000001 11111100
	defb   $00, $00; /* ...YYY.. */,	// 00000001 01010000
	defb   $00, $00; /* ...Y..Y. */,	// 00000001 00000100
	defb   $00, $00; /* ......Y. */,	// 00000000 00000100
xENEMY_RUNNING_LEFT_4:
	defb   $00, $00; /* ..YY.... */, 	// 00000101 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ...RRR.. */,	// 00000011 11110000
	defb   $00, $00; /* ..RR..R. */,	// 00001010 00001000
	defb   $00, $00; /* ...YY... */,	// 00000001 01000000
	defb   $00, $00; /* ..Y..YY. */,	// 00000100 00010100
	defb   $00, $00; /* ..Y..... */,	// 00000100 00000000
xENEMY_RUNNING_LEFT_5:
	defb   $00, $00; /* .YY..... */, 	// 00010100 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..RR.... */,	// 00001111 00000000
	defb   $00, $00; /* .YRRR... */,	// 00011111 11000000
	defb   $00, $00; /* .YYY.... */,	// 00010101 00000000
	defb   $00, $00; /* .Y..Y... */,	// 00010001 00000000
	defb   $00, $00; /* ....Y... */,	// 00000001 00000000
xENEMY_RUNNING_LEFT_6:
	defb   $00, $00; /* YY...... */, 	// 01010000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* .RR..... */,	// 00111100 00000000
	defb   $00, $00; /* RRR..... */,	// 11111100 00000000
	defb   $00, $00; /* YYY..... */,	// 01010100 00000000
	defb   $00, $00; /* YYYY.... */,	// 01010101 00000000
	defb   $00, $00; /* ..Y..... */,	// 00000100 00000000
xENEMY_RUNNING_LEFT_7:
	defb   $00, $00; /* Y....... */, 	// 01000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* RR...... */,	// 11110000 00000000
	defb   $00, $00; /* .RR..... */,	// 00111100 00000000
	defb   $00, $00; /* .YY..... */,	// 00010100 00000000
	defb   $00, $00; /* .YY..... */,	// 00010100 00000000
	defb   $00, $00; /* ..Y..... */,	// 00000100 00000000
xENEMY_RUNNING_LEFT_8:
	defb   $00, $00; /* ........ */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* R....... */,	// 11000000 00000000
	defb   $00, $00; /* RR...... */,	// 11110000 00000000
	defb   $00, $00; /* YY...... */,	// 01010000 00000000
	defb   $00, $00; /* YY...... */,	// 01010000 00000000
	defb   $00, $00; /* .Y...... */,	// 00010000 00000000


; 5x6 ENEMY_RUNNING_RIGHT======================================================


ENEMY_RUNNING_RIGHT_1:
	defb   $00, $00; /* .YY..... */, 	// 00010100 00000000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* RR...... */,	// 11110000 00000000
	defb   $00, $00; /* RR...... */,	// 11110000 00000000
	defb   $00, $00; /* YY...... */,	// 01010000 00000000
	defb   $00, $00; /* YY...... */,	// 01010000 00000000
	defb   $00, $00; /* Y....... */,	// 01000000 00000000
ENEMY_RUNNING_RIGHT_2:
	defb   $00, $00; /* ..YY.... */, 	// 00000101 00000000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* .RR..... */,	// 00111100 00000000
	defb   $00, $00; /* .RRR.... */,	// 00111111 00000000
	defb   $00, $00; /* .YYY.... */,	// 00010101 00000000
	defb   $00, $00; /* YYYY.... */,	// 00000000 00000000
	defb   $00, $00; /* .Y...... */,	// 00010000 00000000
ENEMY_RUNNING_RIGHT_3:
	defb   $00, $00; /* ...YY... */, 	// 00000001 01000000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* ..RR.... */,	// 00001111 00000000
	defb   $00, $00; /* .RRRY... */,	// 00111111 01000000
	defb   $00, $00; /* ..YYY... */,	// 00000101 01000000
	defb   $00, $00; /* .Y..Y... */,	// 00010000 01000000
	defb   $00, $00; /* .Y...... */,	// 00010000 00000000
ENEMY_RUNNING_RIGHT_4:
	defb   $00, $00; /* ....YY.. */, 	// 00000000 01010000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* ..RRR... */,	// 00001111 11000000
	defb   $00, $00; /* .R..RR... */,	// 00110000 11110000
	defb   $00, $00; /* ...YY... */,	// 00000001 01000000
	defb   $00, $00; /* .YY..Y.. */,	// 00010100 00010000
	defb   $00, $00; /* .....Y.. */,	// 00000000 00010000
ENEMY_RUNNING_RIGHT_5:
	defb   $00, $00; /* .....YY. */, 	// 00000000 00010100		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* ....RR.. */,	// 00000000 11110000
	defb   $00, $00; /* ...RRRY. */,	// 00000011 11110100
	defb   $00, $00; /* ....YYY. */,	// 00000000 01010100
	defb   $00, $00; /* ...Y..Y. */,	// 00000001 00000100
	defb   $00, $00; /* ...Y.... */,	// 00000001 00000000
ENEMY_RUNNING_RIGHT_6:
	defb   $00, $00; /* ......YY */, 	// 00000000 00000101		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* .....RR. */,	// 00000000 00111100
	defb   $00, $00; /* .....RRR */,	// 00000000 00111111
	defb   $00, $00; /* .....YYY */,	// 00000000 00010101
	defb   $00, $00; /* ....YYYY */,	// 00000000 01010101
	defb   $00, $00; /* .....Y.. */,	// 00000000 00010000
ENEMY_RUNNING_RIGHT_7:
	defb   $00, $00; /* .......Y */, 	// 00000000 00000001		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ......RR */,	// 00000000 00001111
	defb   $00, $00; /* .....RR. */,	// 00000000 00111100
	defb   $00, $00; /* .....YY. */,	// 00000000 00010100
	defb   $00, $00; /* .....YY. */,	// 00000000 00010100
	defb   $00, $00; /* .....Y.. */,	// 00000000 00010000
ENEMY_RUNNING_RIGHT_8:
	defb   $00, $00; /* ........ */, 	// 00000000 00000000		// RUNNER RIGHT 1 (7)
	defb   $00, $00; /* .......R */,	// 00000000 00000011
	defb   $00, $00; /* ......RR */,	// 00000000 00001111
	defb   $00, $00; /* ......YY */,	// 00000000 00000101
	defb   $00, $00; /* ......YY */,	// 00000000 00000101
	defb   $00, $00; /* .......Y */,	// 00000000 00000001

; ===============================================================================
; ===============================================================================
; ===============================================================================
; ===============================================================================
; ENEMY RUNNING LEFT

; SHIFT RIGHT 5 pixel
ENEMY_RUNNING_LEFT_5R1:
	defb   %00000000, %00000011 	;// $00, $00; /* .......R */, 	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000011 	;// $00, $02; /* .......R */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
ENEMY_RUNNING_LEFT_5R2:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
ENEMY_RUNNING_LEFT_5R3:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
ENEMY_RUNNING_LEFT_5R4:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000010   	;// $00, $01; /* .......B */,	// 00000000 00000000

; SHIFT RIGHT 4 pixel
ENEMY_RUNNING_LEFT_4R1:
	defb   %00000000, %00001111 	;// $00, $00; /* ......RR */,	// 00000000 00000000
	defb   %00000000, %00000011 	;// $00, $00; /* .......R */,	// 00000000 00000000
	defb   %00000000, %00001100 	;// $00, $00; /* ......R. */,	// 00000000 00000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000000
	defb   %00000000, %00000010 	;// $00, $00; /* .......B */,	// 00000000 00000000
	defb   %00000000, %00000010 	;// $00, $00; /* .......B */,	// 00000000 00000000
ENEMY_RUNNING_LEFT_4R2:
	defb   %00000000, %00000011 	;// $00, $01; /* .......R */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
	defb   %00000000, %00000011 	;// $00, $02; /* .......R */,	// 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 01000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000100
ENEMY_RUNNING_LEFT_4R3:
	defb   %00000000, %00000011 	;// $00, $01; /* .......R */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 10100000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000010 	;// $00, $01; /* .......B */,	// 00000001 00010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00010000
ENEMY_RUNNING_LEFT_4R4:
	defb   %00000000, %00000011 	;// $00, $01; /* .......R */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
	defb   %00000000, %00000011 	;// $00, $02; /* .......R */,	// 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000010 	;// $00, $01; /* .......B */,	// 00000001 00000100
	defb   %00000000, %00001000 	;// $00, $04; /* ......B. */,	// 00000000 00000100

; SHIFT RIGHT 3 pixel 
ENEMY_RUNNING_LEFT_3R1:
	defb   %00000000, %00001111 	;// $00, $05; /* ......RR */, 	// 00000001 01000101		// RUNNER LEFT 1 (7)
	defb   %00000000, %00001111 	;// $00, $0A; /* ......RR */,	// 00000010 00001010
	defb   %00000000, %00110011 	;// $080 $00; /* .....R.R */,	// 00001000 10000010
	defb   %00000000, %00000010 	;// $00, $01; /* .......B */,	// 00000000 01010000
	defb   %00000000, %00001000 	;// $00, $04; /* ......B. */,	// 00000001 00000101
	defb   %00000000, %00001000 	;// $00, $04; /* ......B. */,	// 00000001 00000000
ENEMY_RUNNING_LEFT_3R2:
	defb   %00000000, %00001111 	;// $00, $05; /* ......RR */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000011 	;// $00, $02; /* .......R */,	// 00000010 10100000
	defb   %00000000, %00001111 	;// $00, $0A; /* ......RR */,	// 00000010 10001000
	defb   %00000000, %00000010 	;// $00, $01; /* .......B */,	// 00000000 01010000
	defb   %00000000, %00000010 	;// $00, $01; /* .......B */,	// 00000001 01000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000100
ENEMY_RUNNING_LEFT_3R3:
	defb   %00000000, %00001111 	;// $00, $05; /* ......RR */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000011 	;// $00, $02; /* .......R */,	// 00000010 10000000
	defb   %00000000, %00000011 	;// $00, $02; /* .......R */,	// 00000000 10100000
	defb   %00000000, %00000010 	;// $00, $01; /* .......B */,	// 00000000 01010000
	defb   %00000000, %00001000 	;// $00, $04; /* ......B. */,	// 00000001 00010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00010000
ENEMY_RUNNING_LEFT_3R4:
	defb   %00000000, %00001111 	;// $00, $05; /* ......RR */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000011 	;// $00, $02; /* .......R */,	// 00000010 10100000
	defb   %00000000, %00001111 	;// $00, $0A; /* ......RR */,	// 00000010 10001000
	defb   %00000000, %00000010 	;// $00, $01; /* .......B */,	// 00000000 01010000
	defb   %00000000, %00001000 	;// $00, $04; /* ......B. */,	// 00000001 00000100
	defb   %00000000, %00100000 	;// $00, $10; /* .....B.. */,	// 00000000 00010000

; SHIFT RIGHT 2 pixel
ENEMY_RUNNING_LEFT_2R1:
	defb   %00000000, %00010100 	;// $00, $14; /* .....RR. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00101010 	;// $00, $2A; /* .....RRR */,	// 00000010 10101000
	defb   %00000000, %10001000 	;// $00, $88; /* ....R.R. */,	// 00001000 10000010
	defb   %00000000, %00001010 	;// $00, $05; /* ......BB */,	// 00000000 01010000
	defb   %00000000, %00100000 	;// $00, $10; /* .....B.. */,	// 00000001 00000101
	defb   %00000000, %00100000 	;// $00, $10; /* .....B.. */,	// 00000001 00000000
ENEMY_RUNNING_LEFT_2R2:
	defb   %00000000, %00111100 	;// $00, $14; /* .....RR. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00001111 	;// $00, $0A; /* ......RR */,	// 00000010 10100000
	defb   %00000000, %00111100 	;// $00, $28; /* .....RR. */,	// 00000010 10001000
	defb   %00000000, %00001010 	;// $00, $05; /* ......BB */,	// 00000000 01010000
	defb   %00000000, %00001000 	;// $00, $04; /* ......B. */,	// 00000001 01000100
	defb   %00000000, %00000010 	;// $00, $01; /* .......B */,	// 00000000 00000100
ENEMY_RUNNING_LEFT_2R3:
	defb   %00000000, %00111100 	;// $00, $14; /* .....RR. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00001100 	;// $00, $08; /* ......R. */,	// 00000010 10000000
	defb   %00000000, %00001111 	;// $00, $0A; /* ......RR */,	// 00000000 10100000
	defb   %00000000, %00001010 	;// $00, $05; /* ......BB */,	// 00000000 01010000
	defb   %00000000, %00100010 	;// $00, $11; /* .....B.B */,	// 00000001 00010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00010000
ENEMY_RUNNING_LEFT_2R4:
	defb   %00000000, %00111100 	;// $00, $14; /* .....RR. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00001111 	;// $00, $0A; /* ......RR */,	// 00000010 10100000
	defb   %00000000, %00111100 	;// $00, $28; /* .....RR. */,	// 00000010 10001000
	defb   %00000000, %00001010 	;// $00, $05; /* ......BB */,	// 00000000 01010000
	defb   %00000000, %00100000 	;// $00, $10; /* .....B.. */,	// 00000001 00000100
	defb   %00000000, %10000000 	;// $00, $40; /* ....B... */,	// 00000100 00000000

; SHIFT RIGHT 1 pixel  
ENEMY_RUNNING_LEFT_1R1:
	defb   %00000000, %11110000 	;// $00, $50; /* ....RR.. */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %11111111 	;// $00, $AA; /* ....RRRR */,	// 00000010 10101000
	defb   %00000011, %00110000 	;// $02, $20; /* ...R.R.. */,	// 00001000 10000010
	defb   %00000000, %00010100 	;// $00, $14; /* .....BB. */,	// 00000000 01010000
	defb   %00000000, %10000010 	;// $00, $41; /* ....B..B */,	// 00000001 00000101
	defb   %00000000, %10000000 	;// $00, $40; /* ....B... */,	// 00000001 00000000
ENEMY_RUNNING_LEFT_1R2:
        defb   %00000000, %11110000     ;// $00, $50; /* ....RR.. */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %00111100     ;// $00, $28; /* .....RR. */,    // 00000010 10100000
        defb   %00000000, %11110011     ;// $00, $A2; /* ....RR.R */,    // 00000010 10001000
        defb   %00000000, %00101000     ;// $00, $14; /* .....BB. */,    // 00000000 01010000
        defb   %00000000, %00100010     ;// $00, $11; /* .....B.B */,    // 00000001 01000100
        defb   %00000000, %00001000     ;// $00, $04; /* ......B. */,    // 00000000 00000100
ENEMY_RUNNING_LEFT_1R3:
        defb   %00000000, %11110000     ;// $00, $50; /* ....RR.. */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %00110000     ;// $00, $20; /* .....R.. */,    // 00000010 10000000
        defb   %00000000, %00111100     ;// $00, $28; /* .....RR. */,    // 00000000 10100000
        defb   %00000000, %00010100     ;// $00, $14; /* .....BB. */,    // 00000000 01010000
        defb   %00000000, %10001000     ;// $00, $44; /* ....B.B. */,    // 00000001 00010000
        defb   %00000000, %00000010     ;// $00, $01; /* .......B */,    // 00000000 00010000
ENEMY_RUNNING_LEFT_1R4:
        defb   %00000000, %11110000     ;// $00, $50; /* ....RR.. */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %00111100     ;// $00, $28; /* .....RR. */,    // 00000010 10100000
        defb   %00000000, %11110011     ;// $00, $A2; /* ....RR.R */,    // 00000010 10001000
        defb   %00000000, %00101000     ;// $00, $14; /* .....BB. */,    // 00000000 01010000
        defb   %00000000, %10000010     ;// $00, $41; /* ....B..B */,    // 00000001 00000100
        defb   %00000010, %00000000     ;// $01, $00; /* ...B.... */,    // 00000100 00000000

; DEAD SET SMACK MIDDLE;   
ENEMY_RUNNING_LEFT_1:
        defb   %00000011, %11000000     ;// $00, $00; /* ...RR... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000011, %11111100     ;// $00, $00; /* ...RRRR. */,    // 00000010 10101000
        defb   %00001100, %11000011     ;// $00, $00; /* ..R.R..R */,    // 00001000 10000010
        defb   %00000000, %10100000     ;// $00, $00; /* ....BB.. */,    // 00000000 01010000
        defb   %00000010, %00001010     ;// $00, $00; /* ...B..BB */,    // 00000001 00000101
        defb   %00000010, %00000000     ;// $00, $00; /* ...B.... */,    // 00000001 00000000
ENEMY_RUNNING_LEFT_2:
        defb   %00000001, %01000000     ;// $00, $00; /* ...RR... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %10100000     ;// $00, $00; /* ....RR.. */,    // 00000010 10100000
        defb   %00000010, %10001000     ;// $00, $00; /* ...RR.R. */,    // 00000010 10001000
        defb   %00000000, %10100000     ;// $00, $00; /* ....BB.. */,    // 00000000 01010000
        defb   %00000000, %10001000     ;// $00, $00; /* ....B.B. */,    // 00000001 01000100
        defb   %00000000, %00100000     ;// $00, $00; /* .....B.. */,    // 00000000 00000100
ENEMY_RUNNING_LEFT_3:
        defb   %00000011, %11000000     ;// $00, $00; /* ...RR... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %11000000     ;// $00, $00; /* ....R... */,    // 00000010 10000000
        defb   %00000000, %11110000     ;// $00, $00; /* ....RR.. */,    // 00000000 10100000
        defb   %00000000, %10100000     ;// $00, $00; /* ....BB.. */,    // 00000000 01010000
        defb   %00000001, %00100000     ;// $00, $00; /* ...B.B.. */,    // 00000001 00010000
        defb   %00000000, %00001000     ;// $00, $00; /* ......B. */,    // 00000000 00010000
ENEMY_RUNNING_LEFT_4:
        defb   %00000011, %11000000     ;// $00, $00; /* ...RR... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000000, %11110000     ;// $00, $00; /* ....RR.. */,    // 00000010 10100000
        defb   %00000011, %11001100     ;// $00, $00; /* ...RR.R. */,    // 00000010 10001000
        defb   %00000000, %10100000     ;// $00, $00; /* ....BB.. */,    // 00000000 01010000
        defb   %00000010, %00001000     ;// $00, $00; /* ...B..B. */,    // 00000001 00000100
        defb   %00001000, %00000000     ;// $00, $00; /* ..B..... */,    // 00000100 00000000

; SHIFT LEFT 1 PIXEL		
ENEMY_RUNNING_LEFT_1L1:	
        defb   %00001111, %00000000     ;// $00, $00; /* ..RR.... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00001111, %11110000     ;// $00, $00; /* ..RRRR.. */,    // 00000010 10101000
        defb   %00110011, %00001100     ;// $00, $00; /* .R.R..R. */,    // 00001000 10000010
        defb   %00000010, %10000000     ;// $00, $00; /* ...BB... */,    // 00000000 01010000
        defb   %00001000, %00101000     ;// $00, $00; /* ..B..BB. */,    // 00000001 00000101
        defb   %00001000, %00000000     ;// $00, $00; /* ..B..... */,    // 00000001 00000000
ENEMY_RUNNING_LEFT_1L2:
        defb   %00001111, %00000000     ;// $00, $00; /* ..RR.... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000011, %11000000     ;// $00, $00; /* ...RR... */,    // 00000010 10100000
        defb   %00001111, %00110000     ;// $00, $00; /* ..RR.R.. */,    // 00000010 10001000
        defb   %00000010, %10000000     ;// $00, $00; /* ...BB... */,    // 00000000 01010000
        defb   %00000010, %00100000     ;// $00, $00; /* ...B.B.. */,    // 00000001 01000100
        defb   %00000000, %10000000     ;// $00, $00; /* ....B... */,    // 00000000 00000100
ENEMY_RUNNING_LEFT_1L3:
        defb   %00001111, %00000000     ;// $00, $00; /* ..RR.... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000011, %00000000     ;// $00, $00; /* ...R.... */,    // 00000010 10000000
        defb   %00000011, %11000000     ;// $00, $00; /* ...RR... */,    // 00000000 10100000
        defb   %00000010, %10000000     ;// $00, $00; /* ...BB... */,    // 00000000 01010000
        defb   %00000100, %10000000     ;// $00, $00; /* ..B.B... */,    // 00000001 00010000
        defb   %00000000, %00100000     ;// $00, $00; /* .....B.. */,    // 00000000 00010000
ENEMY_RUNNING_LEFT_1L4:
        defb   %00001111, %00000000     ;// $00, $00; /* ..RR.... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00000011, %11000000     ;// $00, $00; /* ...RR... */,    // 00000010 10100000
        defb   %00001111, %00110000     ;// $00, $00; /* ..RR.R.. */,    // 00000010 10001000
        defb   %00000010, %10000000     ;// $00, $00; /* ...BB... */,    // 00000000 01010000
        defb   %00001000, %00100000     ;// $00, $00; /* ..B..B.. */,    // 00000001 00000100
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000100 00000000

; SHIFT LEFT 2 PIXEL
ENEMY_RUNNING_LEFT_2L1:
        defb   %00111100, %00000000     ;// $00, $00; /* .RR..... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00111111, %11000000     ;// $00, $00; /* .RRRR... */,    // 00000010 10101000
        defb   %11001100, %00110000     ;// $00, $00; /* R.R..R.. */,    // 00001000 10000010
        defb   %00001010, %00000000     ;// $00, $00; /* ..BB.... */,    // 00000000 01010000
        defb   %00100000, %10100000     ;// $00, $00; /* .B..BB.. */,    // 00000001 00000101
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000001 00000000
ENEMY_RUNNING_LEFT_2L2:
        defb   %00111100, %00000000     ;// $00, $00; /* .RR..... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00001111, %00000000     ;// $00, $00; /* ..RR.... */,    // 00000010 10100000
        defb   %00111100, %11000000     ;// $00, $00; /* .RR.R... */,    // 00000010 10001000
        defb   %00001010, %00000000     ;// $00, $00; /* ..BB.... */,    // 00000000 01010000
        defb   %00001000, %10000000     ;// $00, $00; /* ..B.B... */,    // 00000001 01000100
        defb   %00000010, %00000000     ;// $00, $00; /* ...B.... */,    // 00000000 00000100
ENEMY_RUNNING_LEFT_2L3:
        defb   %00111100, %00000000     ;// $00, $00; /* .RR..... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00001100, %00000000     ;// $00, $00; /* ..R..... */,    // 00000010 10000000
        defb   %00001111, %00000000     ;// $00, $00; /* ..RR.... */,    // 00000000 10100000
        defb   %00001010, %00000000     ;// $00, $00; /* ..BB.... */,    // 00000000 01010000
        defb   %00100010, %00000000     ;// $00, $00; /* .B.B.... */,    // 00000001 00010000
        defb   %00000000, %10000000     ;// $00, $00; /* ....B... */,    // 00000000 00010000
ENEMY_RUNNING_LEFT_2L4:
        defb   %00111100, %00000000     ;// $00, $00; /* .RR..... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00001111, %00000000     ;// $00, $00; /* ..RR.... */,    // 00000010 10100000
        defb   %00111100, %11000000     ;// $00, $00; /* .RR.R... */,    // 00000010 10001000
        defb   %00001010, %00000000     ;// $00, $00; /* ..BB.... */,    // 00000000 01010000
        defb   %00100000, %10000000     ;// $00, $00; /* .B..B... */,    // 00000001 00000100
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000100 00000000
;====================================================================================================== DONE BELOW RED - DJM  . DM 
; SHIFT LEFT 3 PIXEL
ENEMY_RUNNING_LEFT_3L1:
        defb   %11110000, %00000000     ;// $00, $00; /* RR...... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %11111111, %00000000     ;// $00, $00; /* RRRR.... */,    // 00000010 10101000
        defb   %00110000, %11000000     ;// $00, $00; /* .R..R... */,    // 00001000 10000010
        defb   %00101000, %00000000     ;// $00, $00; /* .BB..... */,    // 00000000 01010000
        defb   %10000010, %10000000     ;// $00, $00; /* B..BB... */,    // 00000001 00000101
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000001 00000000
ENEMY_RUNNING_LEFT_3L2:
        defb   %11110000, %00000000     ;// $00, $00; /* RR...... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00111100, %00000000     ;// $00, $00; /* .RR..... */,    // 00000010 10100000
        defb   %11110011, %00000000     ;// $00, $00; /* RR.R.... */,    // 00000010 10001000
        defb   %00101000, %00000000     ;// $00, $00; /* .BB..... */,    // 00000000 01010000
        defb   %00100010, %00000000     ;// $00, $00; /* .B.B.... */,    // 00000001 01000100
        defb   %00001000, %00000000     ;// $00, $00; /* ..B..... */,    // 00000000 00000100
ENEMY_RUNNING_LEFT_3L3:
        defb   %11110000, %00000000     ;// $00, $00; /* RR...... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00110000, %00000000     ;// $00, $00; /* .R...... */,    // 00000010 10000000
        defb   %00111100, %00000000     ;// $00, $00; /* .RR..... */,    // 00000000 10100000
        defb   %00101000, %00000000     ;// $00, $00; /* .BB..... */,    // 00000000 01010000
        defb   %10001000, %00000000     ;// $00, $00; /* B.B..... */,    // 00000001 00010000
        defb   %00000010, %00000000     ;// $00, $00; /* ...B.... */,    // 00000000 00010000
ENEMY_RUNNING_LEFT_3L4:
        defb   %11110000, %00000000     ;// $00, $00; /* RR...... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %00111100, %00000000     ;// $00, $00; /* .RR..... */,    // 00000010 10100000
        defb   %11110011, %00000000     ;// $00, $00; /* RR.R.... */,    // 00000010 10001000
        defb   %00101000, %00000000     ;// $00, $00; /* .BB..... */,    // 00000000 01010000
        defb   %10000010, %00000000     ;// $00, $00; /* B..B.... */,    // 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	 // 00000100 00000000


; SHIFT LEFT 4 PIXEL
ENEMY_RUNNING_LEFT_4L1:
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %11111100, %00000000     ;// $00, $00; /* RRR..... */,    // 00000010 10101000
        defb   %11000011, %00000000     ;// $00, $00; /* R..R.... */,    // 00001000 10000010
        defb   %10100000, %00000000     ;// $00, $00; /* BB...... */,    // 00000000 01010000
        defb   %00001010, %00000000     ;// $00, $00; /* ..BB.... */,    // 00000001 00000101
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000000
ENEMY_RUNNING_LEFT_4L2:
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %11110000, %00000000     ;// $00, $00; /* RR...... */,    // 00000010 10100000
        defb   %11001100, %00000000     ;// $00, $00; /* R.R..... */,    // 00000010 10001000
        defb   %10100000, %00000000     ;// $00, $00; /* BB...... */,    // 00000000 01010000
        defb   %10001000, %00000000     ;// $00, $00; /* B.B..... */,    // 00000001 01000100
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000000 00000100
ENEMY_RUNNING_LEFT_4L3:
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000010 10000000
        defb   %11110000, %00000000     ;// $00, $00; /* RR...... */,    // 00000000 10100000
        defb   %10100000, %00000000     ;// $00, $00; /* BB...... */,    // 00000000 01010000
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000001 00010000
        defb   %00001000, %00000000     ;// $00, $00; /* ..B..... */,    // 00000000 00010000
ENEMY_RUNNING_LEFT_4L4:
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000001 01000000            // RUNNER LEFT 1 (7)
        defb   %11110000, %00000000     ;// $00, $00; /* RR...... */,    // 00000010 10100000
        defb   %11001100, %00000000     ;// $00, $00; /* R.R..... */,    // 00000010 10001000
        defb   %10100000, %00000000     ;// $00, $00; /* BB...... */,    // 00000000 01010000
        defb   %00001000, %00000000     ;// $00, $00; /* ..B..... */,    // 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000100 00000000


; SHIFT LEFT 5 PIXEL
ENEMY_RUNNING_LEFT_5L1:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
        defb   %11110000, %00000000     ;// $00, $00; /* RR...... */,    // 00000010 10101000
        defb   %00001100, %00000000     ;// $00, $00; /* ..R..... */,    // 00001000 10000010
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000000 01010000
        defb   %00101000, %00000000     ;// $00, $00; /* .BB..... */,    // 00000001 00000101
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000000
ENEMY_RUNNING_LEFT_5L2:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000010 10100000
        defb   %00110000, %00000000     ;// $00, $00; /* .R...... */,    // 00000010 10001000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000000 01010000
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000001 01000100
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000000 00000100
ENEMY_RUNNING_LEFT_5L3:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10000000
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000000 10100000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000000 01010000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000001 00010000
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000000 00010000
ENEMY_RUNNING_LEFT_5L4:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000010 10100000
        defb   %00110000, %00000000     ;// $00, $00; /* .R...... */,    // 00000010 10001000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000000 01010000
        defb   %00100000, %00000000     ;// $00, $00; /* .B...... */,    // 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000100 00000000

; SHIFT LEFT 6 PIXEL
ENEMY_RUNNING_LEFT_6L1:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000010 10101000
        defb   %00110000, %00000000     ;// $00, $00; /* .R...... */,    // 00001000 10000010
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
        defb   %10100000, %00000000     ;// $00, $00; /* BB...... */,    // 00000001 00000101
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000000
ENEMY_RUNNING_LEFT_6L2:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000001 01000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00000100
ENEMY_RUNNING_LEFT_6L3:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 10100000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00010000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000000 00010000
ENEMY_RUNNING_LEFT_6L4:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000100 00000000


; SHIFT LEFT 7 PIXEL
ENEMY_RUNNING_LEFT_7L1:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10101000
        defb   %11000000, %00000000     ;// $00, $00; /* R....... */,    // 00001000 10000010
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
        defb   %10000000, %00000000     ;// $00, $00; /* B....... */,    // 00000001 00000101
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000000
ENEMY_RUNNING_LEFT_7L2:
	defb   %00000000, %00000000 	;// $01, $40; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $A0; /* ........ */,	// 00000010 10100000
	defb   %00000000, %00000000 	;// $02, $88; /* ........ */,	// 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $50; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $44; /* ........ */,	// 00000001 01000100
	defb   %00000000, %00000000 	;// $00, $04; /* ........ */,	// 00000000 00000100
ENEMY_RUNNING_LEFT_7L3:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10000000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 10100000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 00010000
ENEMY_RUNNING_LEFT_7L4:
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */, 	// 00000001 01000000		// RUNNER LEFT 1 (7)
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10100000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000010 10001000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000000 01010000
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000001 00000100
	defb   %00000000, %00000000 	;// $00, $00; /* ........ */,	// 00000100 00000000



;JUNKER STUFF BELOW

	defb   $00, $00; /* .##..... */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* .####... */,	// 00000000 00000000
	defb   $00, $00; /* #.#..#.. */,	// 00000000 00000000
	defb   $00, $00; /* ..##.... */,	// 00000000 00000000
	defb   $00, $00; /* .#..##.. */,	// 00000000 00000000
	defb   $00, $00; /* .#...... */,	// 00000000 00000000

	defb   $00, $00; /* ..##.... */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ..####.. */,	// 00000000 00000000
	defb   $00, $00; /* .#.#..#. */,	// 00000000 00000000
	defb   $00, $00; /* ...##... */,	// 00000000 00000000
	defb   $00, $00; /* ..#..##. */,	// 00000000 00000000
	defb   $00, $00; /* ..#..... */,	// 00000000 00000000


; 6x7 sprite
	defb   $00, $00; /* ..YY.... */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ...YYY.. */,	// 00000000 00000000
	defb   $00, $00; /* .YYB..Y. */,	// 00000000 00000000
	defb   $00, $00; /* ...BB... */,	// 00000000 00000000
	defb   $00, $00; /* ..B..BB. */,	// 00000000 00000000
	defb   $00, $00; /* ..B..... */,	// 00000000 00000000

	defb   $00, $00; /* ...##... */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ...####. */,	// 00000000 00000000
	defb   $00, $00; /* ..#.#..# */,	// 00000000 00000000
	defb   $00, $00; /* ....##.. */,	// 00000000 00000000
	defb   $00, $00; /* ...#..## */,	// 00000000 00000000
	defb   $00, $00; /* ...#.... */,	// 00000000 00000000

	defb   $00, $00; /* ....##.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ....#### */,	// 00000000 00000000
	defb   $00, $00; /* ...#.#.. */,	// 00000000 00000000
	defb   $00, $00; /* .....##. */,	// 00000000 00000000
	defb   $00, $00; /* ....#..# */,	// 00000000 00000000
	defb   $00, $00; /* ....#... */,	// 00000000 00000000

	defb   $00, $00; /* ..##.... */,	// 00000000 00000000		// RUNNER LEFT 2 (8)
	defb   $00, $00; /* ..###... */,	// 00000000 00000000
	defb   $00, $00; /* .##.#... */,	// 00000000 00000000
	defb   $00, $00; /* ...##... */,	// 00000000 00000000
	defb   $00, $00; /* ..#..#.. */,	// 00000000 00000000
	defb   $00, $00; /* ...#..#. */,	// 00000000 00000000



	defb   $00, $00; /* ....##.. */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ....###. */,	// 00000000 00000000
	defb   $00, $00; /* ...#.#.. */,	// 00000000 00000000
	defb   $00, $00; /* .....##. */,	// 00000000 00000000
	defb   $00, $00; /* ....#..# */,	// 00000000 00000000
	defb   $00, $00; /* ....#... */,	// 00000000 00000000

	defb   $00, $00; /* ......## */, 	// 00000000 00000000		// RUNNER LEFT 1 (7)
	defb   $00, $00; /* ......## */,	// 00000000 00000000
	defb   $00, $00; /* .....#.# */,	// 00000000 00000000
	defb   $00, $00; /* .......# */,	// 00000000 00000000
	defb   $00, $00; /* ......#. */,	// 00000000 00000000
	defb   $00, $00; /* ......#. */,	// 00000000 00000000

	defb   $00, $00; /* ..##.... */,	// 00000000 00000000		// RUNNER LEFT 2 (8)
	defb   $00, $00; /* ..###... */,	// 00000000 00000000
	defb   $00, $00; /* .##.#... */,	// 00000000 00000000
	defb   $00, $00; /* ...##... */,	// 00000000 00000000
	defb   $00, $00; /* ..#..#.. */,	// 00000000 00000000
	defb   $00, $00; /* ...#..#. */,	// 00000000 00000000

	defb   $00, $00; /* ....##.. */,	// 00000000 00000000		// RUNNER RIGHT 1 (9)
	defb   $00, $00; /* ..####.. */,	// 00000000 00000000
	defb   $00, $00; /* .#..#.#. */,	// 00000000 00000000
	defb   $00, $00; /* ...##... */,	// 00000000 00000000
	defb   $00, $00; /* .##..#.. */,	// 00000000 00000000
	defb   $00, $00; /* .....#.. */,	// 00000000 00000000

	defb   $00, $00; /* ....##.. */,	// 00000000 00000000		// RUNNER RIGHT 2 (10)
	defb   $00, $00; /* ...###.. */,	// 00000000 00000000
	defb   $00, $00; /* ..#.###. */,	// 00000000 00000000
	defb   $00, $00; /* ...##... */,	// 00000000 00000000
	defb   $00, $00; /* ..#..#.. */,	// 00000000 00000000
	defb   $00, $00; /* .#..#... */,	// 00000000 00000000











title: defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$079,$0E7,$09E,$079
defb $0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$08E,$038,$0E3,$08E,$038,$0E3
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0DE,$079,$0E7,$09E
defb $079,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$078,$0E3,$08E,$038,$0E3,$08E,$038
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0F7,$09E,$079,$0E7
defb $09E,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$038,$0E3,$08E,$038,$0E3,$08E
defb $0EA,$0AB,$0A5,$056,$0AA,$0EA,$0AE,$0AA,$0EA,$0AE,$0AA,$0BA,$0A9,$0AA,$0AE,$0AA
defb $0EB,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E3,$08E,$038,$0E3,$08E,$038,$0E3
defb $0EA,$0AB,$0A7,$0F6,$0AA,$0EA,$0AE,$0AA,$0EA,$0AE,$0AA,$0BA,$0AB,$0AA,$0A6,$0AA
defb $069,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$078,$0E3,$08E,$038,$0E3,$08E,$038
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$09E,$079,$0E7
defb $09E,$079,$0E7,$09E,$079,$055,$09E,$079,$0E7,$08E,$038,$0E3,$0AA,$038,$0E3,$08E
defb $0EA,$0EA,$0A5,$056,$0BA,$0AB,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA,$0EA,$0AB,$0AA,$0BA
defb $0AB,$09E,$079,$0E7,$09E,$07D,$0E7,$09E,$079,$0E3,$08E,$038,$096,$08E,$038,$0E3
defb $0EA,$0EA,$0A7,$0F6,$0BA,$0AB,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA,$0EA,$0A9,$0AA,$09A
defb $0A9,$0E7,$09E,$079,$0E5,$07D,$079,$0E7,$09E,$038,$0E3,$08A,$096,$0A3,$08E,$038
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0DE,$079,$0E7
defb $09E,$079,$0E7,$09E,$077,$0FF,$0DE,$079,$0E7,$08E,$038,$0E9,$055,$068,$0E3,$08E
defb $0FF,$0FF,$0FF,$0D7,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0F7,$09E,$079
defb $0E7,$09E,$079,$0E7,$097,$0FF,$0D7,$09E,$078,$0E3,$08E,$039,$055,$06E,$038,$0E3
defb $0FF,$0FD,$055,$0F7,$0FF,$0FF,$0F5,$055,$0FF,$0FD,$0AA,$0AA,$0BF,$0FA,$0AA,$0AA
defb $0A9,$0E7,$09E,$079,$0E7,$0FF,$0D9,$0E7,$09E,$038,$0E3,$089,$055,$063,$08E,$038
defb $0FF,$0FD,$055,$0F7,$0FF,$0FF,$055,$055,$05F,$0FD,$06A,$0AA,$0AF,$0FA,$0AA,$0AA
defb $0AA,$079,$0E7,$09E,$057,$0FF,$0DE,$079,$0E7,$08E,$038,$0A9,$055,$068,$0E3,$08E
defb $0FF,$0FD,$055,$0D7,$0FF,$0FD,$055,$055,$05F,$0FD,$06A,$0AA,$0AB,$0FA,$0AA,$0AA
defb $0AB,$09E,$079,$0E7,$07F,$0D5,$057,$09E,$078,$0E3,$08E,$095,$06A,$0AE,$038,$0E3
defb $0FF,$0F5,$057,$0F7,$0FF,$0F5,$055,$055,$057,$0F5,$06A,$0AA,$0AB,$0EA,$0AA,$0AA
defb $0A9,$0E7,$09E,$055,$07F,$0D5,$059,$0E7,$09E,$038,$0AA,$095,$06A,$0A3,$08E,$038
defb $0FF,$0F5,$057,$0F7,$0FF,$0D5,$05F,$0D5,$057,$0F5,$05B,$0FA,$0AB,$0EA,$0A9,$0E7
defb $09E,$079,$0E7,$07F,$0D7,$0FF,$0DE,$079,$0E7,$08E,$095,$069,$055,$068,$0E3,$08E
defb $0FF,$0F5,$057,$057,$0FF,$055,$07F,$0F5,$057,$0F5,$05B,$0FA,$0AB,$0EA,$0AE,$079
defb $0E7,$09E,$075,$07F,$0D7,$0FF,$0D5,$05E,$078,$0EA,$095,$069,$055,$06A,$0A8,$0E3
defb $0FF,$0D5,$05F,$0F7,$0FF,$055,$07F,$0F5,$057,$0D5,$05F,$0FA,$0AB,$0AA,$0B7,$09E
defb $079,$0E7,$097,$0FD,$07F,$0D5,$07F,$0D7,$09E,$039,$056,$095,$06A,$095,$06E,$038
defb $0FF,$0D5,$05F,$0F7,$0FD,$055,$0FF,$0F5,$057,$0D5,$05F,$0FA,$0AB,$0AA,$0AA,$0AA
defb $09E,$079,$0E7,$0FD,$07F,$0D7,$07F,$0D9,$0E7,$089,$056,$095,$06E,$095,$063,$08E
defb $0FF,$0D5,$05D,$057,$0FD,$055,$0FF,$0F5,$057,$0D5,$05F,$0FA,$0AB,$0AA,$0AA,$0AA
defb $0E7,$09E,$075,$055,$06A,$099,$0D5,$05E,$078,$0EA,$0AA,$095,$063,$0AA,$0A8,$0E3
defb $0FF,$0D5,$05F,$0F7,$0FD,$055,$0FF,$0F5,$057,$0D5,$05F,$0FA,$0AB,$0AA,$0AA,$0AA
defb $079,$0E7,$09E,$079,$06A,$096,$079,$0E7,$09E,$038,$0E3,$095,$068,$0E3,$08E,$038
defb $0FF,$055,$07F,$0F7,$0F5,$057,$0FF,$0D5,$05F,$055,$07F,$0EA,$0AE,$0AA,$0AA,$0AB
defb $09E,$079,$0E7,$09E,$06A,$0A9,$09E,$079,$0E7,$08E,$038,$095,$056,$038,$0E3,$08E
defb $0FF,$055,$075,$057,$0F5,$057,$0FF,$0D5,$05F,$055,$07F,$0EA,$0AE,$0AA,$09E,$079
defb $0E7,$09E,$075,$055,$06A,$0A9,$067,$09E,$079,$0EA,$0AA,$095,$056,$08E,$038,$0E3
defb $0FF,$055,$077,$0F7,$0F5,$057,$0FF,$055,$05F,$055,$07F,$0EA,$0AE,$0AA,$0E7,$09E
defb $079,$0E7,$096,$0AA,$0A9,$06A,$099,$0E7,$09E,$039,$055,$056,$095,$063,$08E,$038
defb $0FF,$055,$07F,$0FF,$0F5,$057,$0FF,$055,$07F,$055,$07F,$06A,$0BE,$0AA,$079,$0E7
defb $09E,$079,$0E6,$0AA,$0A9,$06A,$09E,$079,$0E7,$089,$055,$056,$095,$068,$0E3,$08E
defb $0FD,$055,$055,$057,$0F5,$055,$0FD,$055,$0FD,$055,$0FD,$05A,$0BA,$0AB,$0DE,$079
defb $0E7,$09E,$075,$055,$055,$06A,$097,$09E,$079,$0EA,$0AA,$0AA,$095,$06E,$038,$0E3
defb $0FD,$055,$055,$057,$0F5,$055,$055,$055,$0FD,$055,$055,$05A,$0FA,$0AA,$0AA,$0AA
defb $079,$0E7,$09E,$079,$0E7,$06A,$099,$0E7,$09E,$038,$0E3,$08E,$095,$063,$08E,$038
defb $0FD,$055,$055,$057,$0FD,$055,$055,$057,$0FD,$055,$055,$057,$0FA,$0AA,$0AA,$0AB
defb $09E,$079,$0E7,$09E,$079,$06A,$09E,$079,$0E7,$08E,$038,$0E3,$095,$068,$0E3,$08E
defb $0F5,$055,$055,$05F,$0FF,$055,$055,$07F,$0F5,$055,$055,$05F,$0EA,$0AA,$0AA,$0A9
defb $0E7,$09E,$079,$0E7,$09E,$06A,$097,$09E,$079,$0E3,$08E,$038,$095,$06E,$038,$0E3
defb $0F5,$055,$055,$05F,$0FF,$0D5,$057,$0FF,$0F5,$055,$055,$0FF,$0EA,$0AA,$0AA,$0AE
defb $079,$0E7,$09E,$079,$0E7,$055,$059,$0E7,$09E,$078,$0E3,$08E,$0AA,$0A3,$08E,$038
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FE,$079,$0E7
defb $09E,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$08E,$038,$0E3,$08E,$038,$0E3,$08E
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$09E,$079
defb $0E7,$09E,$07D,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E3
defb $0FF,$0FF,$0F5,$057,$0FF,$0FF,$0FF,$0D5,$055,$055,$07F,$0D5,$05F,$0FF,$0AA,$09E
defb $0A9,$0E7,$09E,$0A9,$0EA,$09E,$079,$0C0,$01C,$000,$000,$000,$040,$000,$000,$038
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FF,$0D5,$055,$055,$05F,$0D5,$05F,$0FF,$0AA,$0A6
defb $0AA,$079,$0E6,$0AA,$06A,$0A7,$09E,$040,$024,$000,$000,$000,$080,$000,$000,$00E
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FF,$0D5,$055,$055,$05F,$0D5,$05F,$0FF,$0AA,$0BA
defb $0AA,$09E,$07E,$0AB,$0AA,$0A9,$0E7,$080,$038,$000,$000,$000,$0C0,$000,$000,$007
defb $0FF,$0FF,$0F5,$057,$0FF,$0FF,$0FF,$055,$055,$055,$05F,$055,$07F,$0FE,$0AA,$09A
defb $0AA,$0A7,$09A,$0A9,$0AA,$0AA,$079,$000,$090,$000,$000,$002,$000,$000,$000,$009
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FF,$055,$07F,$0D5,$05F,$055,$07F,$0FE,$0AA,$0EA
defb $0AA,$0B9,$0FA,$0AE,$0AA,$0AB,$09E,$000,$0E0,$002,$079,$0E7,$000,$039,$0C0,$00E
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FF,$055,$07F,$0D5,$05F,$055,$07F,$0FE,$0AA,$07A
defb $0AA,$09E,$07A,$0A7,$0AA,$0A9,$0E7,$000,$070,$003,$09E,$079,$000,$01E,$040,$007
defb $0FF,$0FF,$0F5,$057,$0FF,$0FF,$0FD,$055,$0FF,$055,$07D,$055,$0FF,$0FA,$0AB,$0AA
defb $0AA,$0A7,$0AA,$0BA,$0AA,$0AA,$078,$003,$080,$009,$0E7,$09C,$000,$0B7,$000,$039
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FD,$055,$055,$055,$07D,$055,$0FF,$0FA,$0A9,$0EA
defb $0AA,$0A9,$0EA,$09E,$0AA,$0AA,$09C,$001,$0C0,$000,$000,$024,$000,$000,$000,$01E
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FD,$055,$055,$055,$0FD,$055,$0FF,$0FA,$0AA,$06A
defb $0AA,$0AA,$06A,$0A6,$0AA,$0AA,$0A4,$002,$040,$000,$000,$038,$000,$000,$000,$0E7
defb $0FF,$0FF,$0F5,$057,$0FF,$0FF,$0FD,$055,$055,$057,$0FD,$055,$0FF,$0FA,$0AB,$0AA
defb $0BA,$0AB,$0AA,$0BA,$0AB,$0AA,$0B8,$003,$080,$000,$000,$01C,$000,$000,$002,$079
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0F5,$055,$055,$07F,$0F5,$057,$0FF,$0DA,$0A9,$0AA
defb $09E,$0A9,$0AA,$09A,$0A9,$0EA,$090,$009,$000,$000,$000,$0E0,$000,$000,$027,$09E
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0F5,$057,$0D5,$05F,$0F5,$057,$0FF,$0D6,$0AE,$0AA
defb $0E6,$0AA,$0AA,$0EA,$0AE,$06A,$0A0,$00E,$000,$027,$09E,$070,$003,$080,$009,$0E7
defb $0FF,$0FF,$0F5,$057,$0FF,$0FF,$0F5,$057,$0D5,$05F,$0F5,$057,$0FF,$0D5,$0A7,$0AA
defb $07A,$0AA,$0AA,$07A,$0A7,$0AA,$0A8,$007,$000,$039,$0E7,$090,$001,$0C0,$00E,$079
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0F5,$057,$0D5,$057,$0F5,$057,$0FF,$055,$0B9,$0AA
defb $09E,$0AA,$0AA,$09A,$0A9,$0EA,$0A8,$009,$000,$01E,$079,$0F0,$002,$040,$003,$09E
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0D5,$05F,$0D5,$057,$0F5,$057,$0FD,$055,$09E,$0A9
defb $0E7,$0AA,$0A9,$0EA,$09E,$07A,$0AA,$01C,$000,$0E7,$09E,$040,$007,$080,$001,$0E7
defb $0FF,$0FF,$0F5,$057,$0FF,$0FF,$0D5,$05F,$0D5,$057,$0F5,$055,$055,$055,$0E6,$0AA
defb $079,$0EA,$0AA,$06A,$0A7,$09E,$0AA,$024,$000,$000,$000,$080,$009,$0C0,$002,$079
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0D5,$05F,$0D5,$057,$0F5,$055,$055,$056,$07A,$0AB
defb $09E,$06A,$0AB,$0AA,$0B9,$0E6,$0AA,$0B8,$000,$000,$000,$0C0,$00E,$040,$003,$09E
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$055,$07F,$0D5,$057,$0FD,$055,$055,$05F,$09A,$0A9
defb $0E7,$0AA,$0A9,$0AA,$09E,$07A,$0AA,$090,$000,$000,$002,$000,$027,$080,$001,$0E7
defb $0FF,$0FF,$0F5,$057,$0FF,$0FF,$055,$07F,$0D5,$057,$0FF,$055,$055,$0F9,$0EA,$0AE
defb $079,$0EA,$0AE,$0AA,$0E7,$09E,$0AA,$0E0,$000,$000,$003,$000,$039,$0C0,$002,$079
defb $0FF,$0FF,$0F7,$0F7,$0D5,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0DE,$079,$0E7
defb $09E,$079,$0E7,$09E,$079,$0E7,$09F,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E
defb $0FF,$0FF,$0F7,$0F7,$0EA,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0F7,$09E,$079
defb $0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E7,$09E,$079,$0E7
defb $0FF,$0FF,$0F5,$057,$0D5,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FD
defb $0FF,$0FF,$0F7,$0F7,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FE,$0AB,$0AA,$0EA,$0AB,$0AA,$0BA,$0AA,$0EA,$0AE,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA
defb $0EA,$0AB,$0AA,$0BA,$0AA,$0EA,$0AE,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA,$0EA,$0AF,$0FF
defb $0FE,$0AB,$0AA,$0EA,$0AB,$0AA,$0BA,$0AA,$0EA,$0AE,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA
defb $0EA,$0AB,$0AA,$0BA,$0AA,$0EA,$0AE,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA,$0EA,$0AF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FE,$0EA,$0AE,$0AA,$0EA,$0AE,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA,$0EA,$0AB,$0AA,$0BA
defb $0AA,$0EA,$0AE,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA,$0EA,$0AB,$0AA,$0BA,$0AA,$0EF,$0FF
defb $0FE,$0EA,$0AE,$0AA,$0EA,$0AE,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA,$0EA,$0AB,$0AA,$0BA
defb $0AA,$0EA,$0AE,$0AA,$0BA,$0AB,$0AA,$0AE,$0AA,$0EA,$0AB,$0AA,$0BA,$0AA,$0EF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
defb $0FF
 ; ---------------------------------------------------------
