; = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
;               
; B O U N C Y  B A L L 
;
;   - Original concept flogged from Simon of the MC10 list. 
;   - Nov 2016 started in C with asm. Partial release in Jan 2017.
;   - Nov 2019 Full release --- 100% asm.
;   - Assemble with PASMO (pasmo.speccy.org)
;   - Works on VZEM emulator.
;   - As of yet untested on real hardware.
;   - 27k in size.
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
;
;
; CONTROLS
; --------
;    <space>  = reset
;    m        = left
;    ,        = right
;
;
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = 
;  TO DO:
;  x -gameover - scrolly sideways - XOR.  GAMEOVER on top; scrolly behind GAMEOVER.
;  x -winner gameover.
;  x -fix boxes.
;  x -intro music.
;  x -intro music to auto go from screen one to screen two.
;  x -fix scoring - actual getting/winning of 10x boxes.
;    -screen compression using ZX7.
;    -add <space> to GAMEOVER to restart game.
;    -fix boxes in background to restart game.
;    -add TRANTOR music in background of game play.
;    -change dumb scoring bars to digits.
;
; 0000 - 3FFF   ROM. Cool stuff in here.
; 6800 - 6FFF	Latch latch. Copy of $6800 at $783B.
; 7000 - 77FF	VIDEO.
; 7800 - B7FF	VZ300 16k RAM.
; 7800 - 7FFF   <space>.
; 8000 - E7D7  	Bouncy.
; F000 - F7FF	Screen buffer.




OP_NOP		EQU $00		; music
OP_SCF		EQU $37		; music
OP_ORC		EQU $b1		; music
buffer		EQU $F000	; SET SCREEN BUFFER  * * * 
clear_ball	EQU $00


	ORG $8000	

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Start:
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
intro:	ld	a, 0
	ld	(score), a
	ld	(song), a
	ld	hl, 0
	ld	(screenx), hl
	ld	(bally), hl
	ld	(offsety), hl
	ld	(iscroll), hl
	ld 	a,8			; mode (1)
	ld 	($6800),a
	di
 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;Intro Screen with cool slidey.  
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

slide_intro:	
	ld	hl, 255
	ld	de, buffer
	ld	bc, 2048
loop00:	ldi				; ~20% quicker than LDIR
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
    	jp 	pe, loop00		
	ld	de, 0
	ld	b, 32			
si1:	inc	de
	ld	hl, intro_screen
	add	hl, de
	push	de
	push	bc
	ld	b, 0
	ld	de, buffer
	ld	a, (iscroll)
	inc	a
	ld	(iscroll), a
	ld	a,  64
si2: 	push	af
	ld	a, (iscroll)
	ld	c, a
	pop	af
	push	hl
	LD 	hl,$6800
sync2:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,sync2
	pop	hl
	ldir
	dec	a
	jr	nz, si2
	ld	hl, buffer
	ld	de, $7000
	ld	bc, 2048
loop01:	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
    	jp 	pe, loop01
 	pop	bc
	pop	de
	djnz	si1	




; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   DO first screen MUSIC
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	call 	phaser_music

	ld	de, 0
	ld	bc, 0
	ld	hl, 0

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   DO "Display KEYS" screen.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	ld	a, 1
	ld	(song), a

	ld	hl, keys		; display "keys" screen
	ld	de, $7000
	ld	bc, 2048
	ldir

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   DO second screen MUSIC
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	call 	phaser_music




; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   Start of main game loop. Good luck in reading this. It is mish-mashed to attempt to get some speed.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   Read keyboard
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	call 	score_timer			; display score for first time, to set it up.


loop1:	di	
	ld	bc, 0
	ld	de, 0
	ld	hl, 0
	xor	a
	ld	hl, background
	ld	de, 0E800h
	call	display
keyscan:
;	ld 	a, ($68fb)			; <shift>
;	and	$04
;	jr 	z, intro
	ld 	a, ($68ef)			; M
	and	$020
	jr 	z, right
key0:	ld 	a, ($68ef)			; ,
	and	$008
	jr 	z, left
key1:	ld	de, background
	ld	hl, (screenx)
	add	hl, de
	call	display

	jp	keyscan



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Scroll screen for LEFT KEY						  ; Lefticus.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


left:	ld	hl,screenx
	inc	(hl)
	ld	hl, (offsety)
	inc	hl
	ld	a, (hl)
	or	a	; cp 0
	jr	z, l2	; Jump if no issue (no colours in destination)
	ld	bc, 32
	add	hl, bc
	ld	a, (hl)
	or	a	; cp 0 
	jr	z, l2	; Jump if no issue (no colours in destination)
	ld	bc, 32
	add	hl, bc
	ld	a, (hl)
	or	a	; cp 0
	jr	z, l2	; Jump if no issue (no colours in destination)

	ld	hl, screenx				
	dec	(hl)
l2:	ld	hl, background
	ld	de, (screenx)
	add	hl, de

	call	display
	jp	keyscan

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Scroll screen for RIGHT KEY						  ; Righticus.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

right:	ld	hl, screenx
	dec	(hl)
	ld	hl, (offsety)
	dec	hl
	ld	a, (hl)
	or	a	; cp 0
	jr	z, r2	; Jump if no issue (no colours in destination)
	ld	bc, 32
	add	hl, bc
	ld	a, (hl)
	or	a	; cp 0
	jr	z, r2	; Jump if no issue (no colours in destination)
	ld	bc, 32
	add	hl, bc
	ld	a, (hl)
	or	a	; cp 0
	jr	z, r2	; Jump if no issue (no colours in destination)

	ld	hl, screenx
	inc	(hl)

r2:	ld	hl, background
	ld	de, (screenx)
	add	hl, de

	call	display
	jp	keyscan



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Display current screen in buffer
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

display:xor	b			;ld	b, 0
	ld	a,  32
	ld	de, buffer
disp2: 	ld	c, 32
loop03:	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
    	jp 	pe, loop03
	ld	bc, 255
	add	hl, bc
	ld	bc, 32
loop04:	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
    	jp 	pe, loop04
	ld	bc, 255
	add	hl, bc
	dec	a
	jr	nz, disp2


;	LD 	hl,$6800		; display sync. Rem out for time being.
;sync3:	BIT 	7,(hl)
;	jr	NZ,sync3
	


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Display BALL in Centre at Y-position and check surroundings - hit blue ball or wall or change or direction.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ball:	ld	a, (balld)		; ball direction. 1=down.
	or	a			; cp 0
	jr	nz, ball_dn		; jp if balld=1 (DOWN)


ball_up:ld 	hl, (bally)		; make ball go up two lines.
	ld	bc, -64
	add	hl, bc
	ld	(bally), hl
	ld	bc, buffer +  16	; Centre of screen for ball
	add	hl, bc			; HL = Offset
	ld	(offsety), hl
	ld	bc, -32			; compare/check if colour above for ball hit or turning point
	add	hl, bc
	ld	a, (hl)
	cp	170
	jr	z, ball_hit_up1	; display score
	or	a		; cp 0
	jr	z, disp_ball	; Jump if no issue (no colours in destination)
	ld	hl, balld	; change direction (UP)
	ld	(hl), 1
	jp	ball



ball_dn:ld	hl, (bally)		; make ball go down two lines.
	ld	bc, 64
	add	hl, bc
	ld	(bally), hl		; balld = 1 . DOWN
	ld	bc, buffer +  16	; Centre of screen for ball
	add	hl, bc			; HL & DE = Offset
	ld	(offsety), hl
	ld	bc, 32			; compare/check if colour below for ball hit or turning point
	add	hl, bc
	ld	a, (hl)
	cp	170
	jr	z, ball_hit_down1	; Display score
	or	a		; cp 0
	jr	z, disp_ball	; Jump if no issue (no colours in destination)
	ld	hl, balld	; change direction (UP)
	ld	(hl), 0
	jp	ball


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;  Hit a blue ball. Display score. Short jmp to long jmp.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

ball_hit:
ball_hit_up1:
	jp	ball_hit_up2
ball_hit_down1:
	jp	ball_hit_down2




; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;  Display the ball in current Y axis
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

disp_ball:ld	hl, (offsety)
	ld	(hl), $aa
	ld	bc, 32
	add	hl, bc
	ld	(hl), $28
	ld	bc, -64
	add	hl, bc
	ld	(hl), $28




; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;  Top line Score timer and display
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

score_timer:			; display top line score timer.
	ld	hl, timer2
	dec	(hl)
	dec	(hl)
;	dec	(hl)
;	dec	(hl)
	dec	(hl)
	jr	nz, disp_timer
	dec	(hl)
	ld	hl, timer
	dec	(hl)
	jr	nz, disp_timer2
	jp	game_over	
disp_timer2:
	
disp_timer:
	ld	a, (timer)	; for I=1 to (32-timer)
	ld	b, a
	ld	hl, buffer
dt:	ld	(hl), 85	; draw yellow timer line.
	inc	hl		; Next I
	djnz	dt

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;  Do dumb bar Score.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	
	ld	a, (score)	; display score.
	cp	0
	jr	z, scoreE
	ld	b, a
	LD	HL, buffer+96	; HL=OFFSET TO PUT SCORE
scoreLP:LD	(hl), $Aa	; Blue to indicate number of boxes
	ld	de, 64
	add	hl, de
	DJNz	scoreLP	
scoreE:	
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   Do final Blit of screen buffer at $BUFFER to video ram at x7000
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	ld	hl, buffer
	ld	de, $7000
	ld	bc, 2048
loop05:	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
    	jp 	pe, loop05
	ret

;##########################################
;##########################################
;##########################################


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   Fancy scrolling "GAME OVER" man
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

game_over:
	ld	hl, background
	ld	de, 0E800h
	call	disp_gameover
	ld	de, 0
	ld	b, 255				; //lefticus
gol1:	inc	de
	ld	hl, background
	add	hl, de
	call	disp_gameover
	djnz	gol1	
	ld	b, 255				; //righticus
gol2:	dec	de
	ld	hl, background
	add	hl, de
	call	disp_gameover
	djnz	gol2
	jp	game_over
fin:	jp intro


disp_gameover:
	push	de
	push	bc
	ld	b, 0
	ld	a,  64
	ld	de, buffer
dgo1: 	ld	c, 32
	push	hl
	LD 	hl,$6800
sync3:	BIT 	7,(hl)
	jr	NZ,sync3
	pop	hl
loop06:	ldi			
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
    	jp 	pe, loop06
	ld	bc, 255		
	add	hl, bc
	dec	a
	jr	nz, dgo1

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   WINNER / GAMEOVER or just GAMEOVER?  
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	ld	a, (win)
	cp 	0
	jr	z, dis_go1	


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   DISPLAY OR'd "WINNER"
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


	ld	bc, 670					; display  'WINNER'
go01:	ld	hl, buffer + 704-672+64+64
	add	hl, bc
	ld	a, (hl)
	ld	d, a	
	ld	hl, gameover1
	add	hl, bc
	ld	a, (hl)
	cp	0
	jr	nz, go02
	ld	hl, buffer + 704-672+64+64
	add	hl, bc
	xor	d				 
	ld	(hl), a
	jp	go03
go02:	ld	hl, buffer + 704-672+64+64
	add	hl, bc
	ld	(hl), a
go03:	dec	bc
	ld	a, b
	or	c
	jp	nz, go01

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   DISPLAY OR'd "GAME OVER" 
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

dis_go1:ld	bc, 670					; display 'GAMEOVER'
go11:	ld	hl, buffer + 704+128+128
	add	hl, bc
	ld	a, (hl)
	ld	d, a	
	ld	hl, gameover
	add	hl, bc
	ld	a, (hl)
	cp	0
	jr	nz, go12
	ld	hl, buffer + 704+128+128
	add	hl, bc
	xor	d				
	ld	(hl), a
	jp	go13
go12:	ld	hl, buffer + 704+128+128
	add	hl, bc
	ld	(hl), a
go13:	dec	bc
	ld	a, b
	or	c
	jp	nz, go11
goc:	ld	hl, buffer
	ld	de, $7000
	ld	bc, 2048-32
loop08:	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
    	jp 	pe, loop08   
	pop	bc
	pop	de
	ret


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   Do BALL HIT
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;	ball is sitting at : buffer + screenx + offsety 
;       In order to remove the blue balls, need to remove from original background in memory at "background:"
;       so: offsety = multiple of 32 within screen buffer $E800
;       1. Div offsetY by 32  =  raw Y value (do this by SHR 5)
;       2. background image offset = background_offset + (Multiply Raw Y by 287)
;	3. Add X-axis screen offset, plus 16 (middle).
; 	4. Then add another line (287) to get next row of ball to nip out.
; 	5. complicated: yes.
;       6. This entirely fails when want to start over again, coz the balls are now no longer there!
;       6a. Re-add the balls when wanting to start a new game. Doh.
;

ball_hit_down2:					; HL = offset on buffer
	ld	bc, -287			; BALL GOING DOWN. NEED TO KILL PREVIOUS HIGHER LIGHT OF BOX
	push	bc
	ld	bc, 287
	push	bc
	jp	ball_hit_cont
ball_hit_up2:
	ld	bc, 287				; BALL GOING UP. NEED TO KILL PREVIOUS LOWER LINE OF BOX
	push	bc
	ld	bc, -287
	push	bc

ball_hit_cont:
	ld	a, (score)			; WHILST IN THIS ROUTINE, ADD A POINT TO SCORE
	inc	a
	ld	(score), a


	cp	30				; all 30 points gotten?
	jr	z, winner

	ld	hl, (bally)			; GET RAW y VALUE OF BALL BY DIV IT BY 5
	XOR 	A
	ADD 	HL, HL
	RLA
	ADD 	HL, HL
	RLA
	ADD 	HL, HL
	RLA
	ld	b, h				; RAW VALUE.
	ld	hl, background
bhu:	ld	de, 287				; ROUGH WAY TO MULTIPLE Y * 287 (BACKGROUND WIDTH)
	add	hl, de
	djnz	bhu
	ld	bc, (screenx)			; ADD BALL x VALUE TO GET BACKGROUND OFFSET OF BALL LOCATION
	add	hl, bc
	ld	bc, 16
	add	hl, bc
	pop	bc
	add	hl, bc
	ld	(hl), clear_ball		; CLEAR LINE 1 OR 3 OF BALL, DEPENDING ON UP OR DOWN
	pop	bc
	add	hl, bc
	ld	(hl), clear_ball		; CLEAR LINE 2 
	add	hl, bc
	ld	(hl), clear_ball		; CLEAR LINE 3 OR 1 OF BALL
	jp	ball


; - - - - - - - - - - - - - - - - - - - - - - - - -
; SET WINNER flag; go do WINNER / GAMEOVER SCROLLY
; - - - - - - - - - - - - - - - - - - - - - - - - -

winner:	ld	a, 1				
	ld	(win), a			; SET WIN flag = YES.
	jp	game_over			; Do FANCY GAME_OVER WITH "WINNER"







ball1: 		defb $AA;,$AA		; 4x3 pixels. middle.     Blue.  
ball2: 		defb $28;,$50		; 4x3 pixels. top&bottom. Blue.
bally:		defw 1
balld:		defb 1
ballu:		defb 0,0
screenx:	defw 0,0		; screen offset + 16 = X centre
offsety:	defw 0,0		; offset y = y centre
timer:		defb 32		;32
timer2:		defw 0
iscroll:	defb 0
ballhit:	defb 0
score:		defb 0
win:		defb 0
song:		defb 0



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;    DO PHASERX Music Engine with "PhaserX Demo" song.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
phaser_music:

;PhaserX
; PhaserX Demo song
;by utz 09'2016 * www.irrlichtproject.de
;*******************************************************************************

mix_xor equ $ac00
mix_or	equ $b400
mix_and equ $a400
fsid	equ $4
fnoise	equ $80
noupd1	equ $1
noupd2	equ $40
kick	equ $1
hhat	equ $80
ptnend	equ $40
rest	equ 0

a0	 equ $e4
ais0	 equ $f1
b0	 equ $100
c1	 equ $10f
cis1	 equ $11f
d1	 equ $130
dis1	 equ $142
e1	 equ $155
f1	 equ $169
fis1	 equ $17f
g1	 equ $196
gis1	 equ $1ae
a1	 equ $1c7
ais1	 equ $1e2
b1	 equ $1ff
c2	 equ $21d
cis2	 equ $23e
d2	 equ $260
dis2	 equ $284
e2	 equ $2aa
f2	 equ $2d3
fis2	 equ $2fe
g2	 equ $32b
gis2	 equ $35b
a2	 equ $38f
ais2	 equ $3c5
b2	 equ $3fe
c3	 equ $43b
cis3	 equ $47b
d3	 equ $4bf
dis3	 equ $508
e3	 equ $554
f3	 equ $5a5
fis3	 equ $5fb
g3	 equ $656
gis3	 equ $6b7
a3	 equ $71d
ais3	 equ $789
b3	 equ $7fc
c4	 equ $876
cis4	 equ $8f6
d4	 equ $97f
dis4	 equ $a0f
e4	 equ $aa9
f4	 equ $b4b
fis4	 equ $bf7
g4	 equ $cad
gis4	 equ $d6e
a4	 equ $e3a
ais4	 equ $f13
b4	 equ $ff8
c5	 equ $10eb
cis5	 equ $11ed
d5	 equ $12fe
dis5	 equ $141f
e5	 equ $1551
f5	 equ $1696
fis5	 equ $17ed
g5	 equ $195a
gis5	 equ $1adc
a5	 equ $1c74
ais5	 equ $1e26
b5	 equ $1ff0
c6	 equ $21d7
cis6	 equ $23da
d6	 equ $25fb
dis6	 equ $283e
e6	 equ $2aa2
f6	 equ $2d2b
fis6	 equ $2fdb
g6	 equ $32b3
gis6	 equ $35b7
a6	 equ $38e9
ais6	 equ $3c4b
b6	 equ $3fe1
c7	 equ $43ad
cis7	 equ $47b3
d7	 equ $4bf7
dis7	 equ $507b
e7	 equ $5544
f7	 equ $5a56
fis7	 equ $5fb6
g7	 equ $6567
gis7	 equ $6b6e
a7	 equ $71d1




phaser_music1:

	di
	exx
	push 	hl			;preserve HL' for return to BASIC
	ld 	(oldSP),sp

	ld 	hl, musicData1		; play first few bars, then auto return.
	ld	a, (song)
	cp	0
	jr	z, md2
md1:	ld 	hl, musicData2		; play first few bars, then auto return.
md2:	ld 	(seqpntr),hl
	ld 	iyl,0		;timer lo


;*******************************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0
	
	jp songexit			;uncomment to disable looping	
	ld sp,songloop		;get loop point
	jr rdseq+3

;*******************************************************************************
songexit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ret

;*******************************************************************************
rdptn0
	ld (ptnpntr),de
readPtn
;	ld 	a, ($68fd)	; press <s> to continue
;	and	$02
;	jr 	z, songexit

	ld 	a, ($68ef)	; press <space> to continue
	and	$10
	jr 	z, songexit



ptnpntr equ $+1
	ld sp,0	
	pop af			;speed + drums
	jr z,rdseq
	jp c,drum1
	jp m,drum2
	ex af,af'
drumret
	pop af			;flags + mix_method (xor = $ac, or = $b4, and = a4)
	ld (mixMethod),a
	jr c,noUpdateCh1
	exx
	ld a,$9f		;sbc a,a
	jp pe,setSid
	ld a,$97		;sub a,a
setSid
	ld (sid),a
	ld hl,$04cb		;rlc h
	jp m,setNoise
	ld hl,$0
setNoise
	ld (noise),hl
	pop bc			;dutymod/duty 1
	ld a,b
	ld (dutymod1),a
	pop de			;freq1
	ld hl,0			;reset ch1 accu
	exx
noUpdateCh1
	jr z,noUpdateCh2
	pop hl			;dutymod 2a/b
	ld a,h
	ld (dutymod2a),a
	ld a,l
	ld (dutymod2b),a
	pop bc			;duty 2a/b
	pop de			;freq 2a
	pop hl			;freq 2b
	ld (freq2b),hl
	pop ix			;phase 2b
	ld hl,0			;reset ch2a accu
noUpdateCh2
	ld (ptnpntr),sp
freq2b equ $+1
	ld sp,0

;*******************************************************************************	
playNote
	exx			;4
	add hl,de		;11
sid
	sbc a,a			;4	;replace with sub a for no sid
	ld b,a			;4	;temp
	add a,c			;4	;c = duty
	ld c,a			;4
	ld a,b			;4
dutymod1 equ $+1
	and 32			;7
	xor c			;4
	ld c,a			;4
	cp h			;4
	sbc a,a			;4
noise
;	ds 2			;8	;replace with rlc h for noise
	rlc h
	exx			;4
	add hl,de		;11
	and 33
	or 8
	ld (26624), a
	sbc a,a			;4
dutymod2a equ $+1
	and 32			;7
	xor b			;4
	ld b,a			;4
	cp h			;4
	sbc a,a			;4
	ld iyh,a		;8
	add ix,sp		;15
	sbc a,a			;4
dutymod2b equ $+1
	and 32			;7
	xor c			;4
	ld c,a			;4
	cp ixh			;8
	sbc a,a			;4
mixMethod equ $+1	
	and iyh			;8
	dec iyl			;8
	jr nz,skipTimerHi	;12
	ex af,af'
	dec a
	jp z,readPtn
	ex af,af'
skipTimerHi	
	and 33
	or 8
	ld (26624), a
	jr playNote		;12
				;224


;*******************************************************************************
drum2
	ld (restoreHL),hl
	ld (restoreBC),bc
	ex af,af'
	ld hl,hat1
	ld b,hat1end-hat1
	jr drentry
drum1
	ld (restoreHL),hl
	ld (restoreBC),bc
	ex af,af'
	ld hl,kick1		;10
	ld b,kick1end-kick1	;7
drentry
	xor a			;4
_s2	
	ld c,(hl)		;7
	inc hl			;6
_s1	

	and 33
;	bit 4, a
	or 8
	ld (26624), a

	dec c			;4
	jr nz,_s1		;12/7    
	
	djnz _s2		;13/8
	ld iyl,$9		;7	;correct tempo
restoreHL equ $+1
	ld hl,0
restoreBC equ $+1
	ld bc,0
	jp drumret		;10
	
kick1					;27*16*4 + 27*32*4 + 27*64*4 + 27*128*4 + 27*256*4 = 53568, + 20*33 = 53568 -> -239 loops -> AF' = $11
	ds 4,$10
	ds 4,$20
	ds 4,$40
	ds 4,$80
	ds 4,0
kick1end

hat1
	db 16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3,16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3
	db 12,8,1,24,6,7,4,9,18,12,8,3,11,7,5,8,3,17,9,15,22,6,5,8,11,13,4,8,12,9,2,4,7,8,12,6,7,4,19,22,1,9,6,27,4,3,11
	db 5,8,14,2,11,13,5,9,2,17,10,3,7,19,4,3,8,2,9,11,4,17,6,4,9,14,2,22,8,4,19,2,3,5,11,1,16,20,4,7
	db 8,9,4,12,2,8,14,3,7,7,13,9,15,1,8,4,17,3,22,4,8,11,4,21,9,6,12,4,3,8,7,17,5,9,2,11,17,4,9,3,2
	db 22,4,7,3,8,9,4,11,8,5,9,2,6,2,8,8,3,11,5,3,9,6,7,4,8
hat1end






;---------------------------------------------------------------------------------------

background:			; Main level
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ;	
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ;	
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ;	
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$D5,$5F,$F5,$55,$55,$55,$57,$D5,$55,$55
defb $FF,$FF,$FF,$FF,$5F,$FF,$33,$0C,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$17,$FD
defb $57,$F5,$55,$55,$55,$57,$F5,$55,$55,$55,$55,$55,$57,$FF,$D5,$55
defb $04,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$00,$00,$00	; NEW BOX 8 Line 1
defb $00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$FD,$55,$FF,$55,$55,$55,$55,$F5,$55,$40,$30
defb $00,$FF,$FD,$57,$FC,$CC,$F0,$C0,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$51,$FF,$3F
defb $FD,$55,$55,$55,$7F,$F5,$55,$55,$55,$55,$55,$7F,$FF,$FD,$55,$50
defb $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$00,$00,$00,$00   ; NEW BOX 8 Line 2
defb $FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$FF,$D5,$5F,$F5,$55,$55,$55,$F5,$50,$FF,$03,$FC
defb $3F,$F5,$55,$FF,$33,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$7F,$FF,$D5
defb $55,$55,$57,$FF,$D5,$55,$55,$55,$55,$57,$FF,$00,$3F,$D5,$04,$04
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$00,$00,$00,$00,$FF	; NEW BOX 8 Line 3
defb $FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$D5,$FD,$55,$FF,$55,$55,$55,$F4,$03,$00,$CC,$03,$0F
defb $D5,$05,$7C,$CC,$F0,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$51,$1F,$FD,$55,$55
defb $55,$7F,$FD,$55,$55,$55,$55,$55,$57,$F0,$00,$03,$F5,$50,$40,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$00,$00,$00,$00,$FF,$FF	; NEW BOX 8 Line 4
defb $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$FF,$5F,$D5,$5F,$F5,$55,$55,$7C,$0C,$14,$30,$50,$CF,$54
defb $01,$5F,$33,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$FF,$FF,$55,$55,$57
defb $FF,$D5,$55,$55,$55,$55,$55,$5F,$00,$00,$00,$FD,$04,$04,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$57,$F5,$FC,$00,$F3,$50,$05,$7C,$0C,$7D,$01,$F4,$CD,$50,$00
defb $54,$CC,$F0,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$04,$5F,$FF,$7F,$D5,$55,$7F,$FD
defb $55,$55,$55,$55,$55,$55,$7C,$00,$00,$00,$0F,$50,$40,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $55,$7F,$5C,$55,$5D,$F5,$45,$7C,$0C,$7D,$01,$F4,$C5,$40,$00,$15
defb $33,$0C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$17,$F5,$1F,$F5,$57,$FF,$D5,$55
defb $55,$55,$55,$55,$55,$7C,$00,$00,$00,$0F,$04,$04,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$54,$00
defb $00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55
defb $57,$5C,$55,$75,$FF,$55,$5F,$0C,$14,$10,$50,$D5,$00,$00,$05,$4C
defb $F0,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$04,$51,$51,$53,$FD,$7F,$FD,$55,$55,$55
defb $55,$55,$55,$55,$7C,$00,$10,$00,$0F,$50,$40,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$54,$00,$00
defb $00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$57
defb $5C,$50,$00,$0F,$F5,$5F,$03,$00,$10,$03,$54,$00,$00,$01,$53,$0C
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$15,$15,$15,$FF,$FF,$D5,$55,$55,$55,$55
defb $55,$55,$55,$7C,$00,$04,$00,$0F,$44,$04,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$54,$00,$00,$00
defb $00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$7F,$7C
defb $50,$00,$05,$FF,$5F,$00,$C0,$00,$0D,$50,$00,$00,$00,$54,$F0,$C0
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$50,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$04,$51,$51,$51,$FF,$FD,$55,$55,$55,$55,$55,$55
defb $55,$55,$7C,$00,$04,$00,$0F,$50,$40,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55
defb $55,$55,$55,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$05,$5F,$F7,$C0,$31,$55,$35,$40,$00,$00,$00,$15,$0C,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$54,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$15,$15,$1F,$FF,$FD,$55,$55,$55,$55,$55,$55,$7F
defb $D5,$7C,$00,$04,$00,$3F,$44,$FC,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55
defb $55,$55,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$00,$00,$00,$00,$00 ; Box #4. Line 1
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $05,$45,$FF,$D0,$0C,$00,$D5,$00,$00,$FF,$F0,$05,$70,$C0,$00,$00
defb $00,$00,$00,$00,$00,$00,$01,$54,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$04,$51,$51,$FF,$F7,$FF,$55,$55,$55,$55,$55,$5F,$FF,$FD
defb $7F,$00,$04,$00,$3D,$57,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55
defb $55,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$00,$00,$00,$00,$00,$00 ; BOX #4. Line 2.
defb $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05
defb $4F,$FF,$F5,$03,$03,$54,$00,$00,$3F,$FF,$01,$5C,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$01,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$15,$1F,$FF,$55,$7F,$D5,$55,$55,$55,$55,$7F,$C0,$FF,$5F
defb $C0,$00,$00,$3D,$7F,$CF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$AA,$00,$00,$00,$00,$00,$00,$00 ; BOX #4, line 3
defb $00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$7F
defb $F5,$FF,$50,$CD,$50,$00,$00,$3C,$FF,$F0,$54,$C0,$00,$00,$00,$00
defb $00,$00,$00,$00,$05,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $04,$51,$FF,$F1,$55,$5F,$F5,$5F,$D5,$55,$55,$FC,$00,$0F,$D7,$C0
defb $00,$00,$FD,$FF,$00,$3F,$C0,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
defb $00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
defb $01,$55,$55,$55,$55,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$AA,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX #4, line 4
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$7F,$55
defb $FF,$F5,$35,$40,$00,$00,$3C,$3F,$FF,$15,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$05,$05,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $1F,$FF,$15,$55,$57,$FD,$FF,$F5,$55,$57,$F0,$00,$03,$F7,$F0,$00
defb $00,$FF,$F0,$00,$0F,$F0,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$D7,$FF,$FF,$5F,$FF,$FD,$7F,$00,$00
defb $00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$FD,$7F,$FF,$F5
defb $FF,$FF,$D7,$FF,$FF,$FF,$D5,$FF,$5F,$DF,$7D,$F7,$F5,$FD,$F7,$FF
defb $FD,$5F,$F5,$FD,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$01
defb $55,$55,$55,$55,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$75,$55,$F5
defb $FF,$55,$00,$00,$00,$FC,$3C,$3F,$F5,$40,$00,$00,$00,$00,$00,$00
defb $00,$00,$15,$05,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$FF
defb $F1,$51,$55,$55,$FF,$FF,$55,$55,$57,$C0,$00,$00,$FD,$F0,$00,$03
defb $FF,$C0,$00,$03,$FC,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$F5,$FF,$FF,$D7,$FF,$FF,$5F,$00,$00,$00
defb $00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$F5,$FF,$FF,$D7,$FF
defb $FF,$5F,$FF,$FF,$FF,$DF,$7D,$F7,$DF,$7D,$77,$DF,$7D,$F7,$FF,$FD
defb $F7,$DF,$7D,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$01,$55
defb $55,$55,$55,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$45,$55,$7D,$5F
defb $54,$00,$00,$0F,$FC,$3C,$03,$FF,$50,$00,$00,$00,$00,$00,$00,$00
defb $00,$15,$01,$50,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$FF,$55
defb $15,$55,$55,$FF,$F5,$55,$55,$5F,$C0,$00,$00,$3F,$F0,$00,$03,$FF
defb $00,$00,$00,$FC,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FD,$7F,$FF,$F5,$FF,$FF,$D7,$00,$00,$00,$00
defb $00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$D7,$FF,$FF,$5F,$FF,$FD
defb $7F,$FF,$FF,$FF,$DF,$7D,$F7,$DF,$7D,$77,$DF,$FD,$F7,$FF,$FD,$F7
defb $DF,$7D,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00
defb $00,$05,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$00,$00,$00,$00,$FD,$5D,$5F,$50,$00,$05,$45,$55,$7D,$41,$50
defb $00,$00,$FF,$C0,$FC,$00,$3F,$54,$00,$00,$00,$00,$00,$15,$55,$55
defb $54,$01,$55,$55,$55,$50,$00,$00,$00,$00,$00,$00,$0F,$F1,$11,$51
defb $55,$5F,$FF,$FD,$55,$55,$5F,$00,$00,$00,$03,$F0,$3F,$0F,$F0,$00
defb $00,$00,$3C,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$D5,$55,$5F,$55,$55,$7D,$55,$55,$00,$00,$00,$00,$00
defb $FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$55,$55,$7D,$55,$55,$F5,$55
defb $57,$FF,$FF,$DD,$FD,$F7,$DF,$7D,$D7,$DF,$FF,$57,$FF,$FD,$DF,$D5
defb $7D,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00
defb $05,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $00,$00,$00,$00,$FF,$5D,$7F,$50,$00,$05,$45,$55,$5D,$05,$40,$00
defb $0F,$FC,$0F,$C0,$00,$0F,$15,$00,$00,$00,$00,$00,$15,$55,$55,$54
defb $01,$55,$55,$55,$40,$00,$00,$00,$00,$00,$00,$07,$C4,$45,$15,$55
defb $FF,$F5,$FF,$55,$55,$5F,$00,$00,$00,$00,$3F,$FF,$FF,$00,$00,$00
defb $00,$3C,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FD,$7F,$FF,$F5,$FF,$FF,$D7,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$D7,$FF,$FF,$5F,$FF,$FD,$7F,$FF
defb $FF,$FF,$DF,$7D,$F7,$DF,$7D,$D7,$DF,$FF,$F7,$FF,$FD,$F7,$DF,$7D
defb $FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$05
defb $40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00
defb $00,$00,$00,$FF,$D5,$FF,$50,$00,$05,$45,$55,$54,$15,$00,$00,$FF
defb $C3,$FC,$00,$00,$0F,$05,$40,$00,$00,$00,$00,$05,$54,$00,$00,$30
defb $00,$00,$55,$40,$00,$00,$00,$00,$00,$00,$01,$11,$11,$51,$55,$7F
defb $55,$7F,$D5,$55,$7C,$00,$54,$00,$00,$3F,$D7,$FC,$00,$00,$15,$00
defb $3C,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$F5,$FF,$FF,$D7,$FF,$FF,$5F,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$F5,$FF,$FF,$D7,$FF,$FF,$5F,$FF,$FF
defb $FF,$DF,$7D,$F7,$DF,$7D,$F7,$DF,$7D,$F7,$FF,$FD,$F7,$DF,$7D,$FF
defb $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$05,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00
defb $00,$00,$FF,$F7,$FF,$50,$00,$05,$45,$55,$50,$54,$00,$0F,$FC,$3F
defb $C0,$00,$00,$3C,$01,$50,$00,$00,$00,$00,$01,$55,$00,$00,$30,$00
defb $01,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$15,$15,$55,$55
defb $5F,$55,$55,$7C,$00,$05,$40,$00,$FD,$55,$7F,$00,$01,$40,$00,$3C
defb $00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$D7,$FF,$FF,$5F,$FF,$FD,$7F,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$FD,$7F,$FF,$F5,$FF,$FF,$D7,$FF,$FF,$FF
defb $D5,$FF,$5F,$F5,$FD,$F7,$F5,$FF,$5F,$FF,$FD,$5F,$DF,$7D,$5F,$57
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$05,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00
defb $00,$FF,$FF,$FF,$50,$00,$00,$00,$00,$41,$50,$00,$3F,$CF,$FC,$00
defb $00,$00,$3C,$00,$54,$00,$00,$00,$00,$00,$55,$40,$03,$33,$00,$05
defb $54,$00,$00,$00,$00,$00,$00,$00,$04,$44,$44,$51,$51,$51,$51,$51
defb $51,$51,$7C,$00,$00,$00,$00,$F5,$00,$57,$C0,$00,$00,$00,$3C,$00
defb $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$05,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00
defb $FF,$FF,$FF,$50,$00,$00,$00,$00,$45,$40,$00,$30,$3F,$C0,$00,$00
defb $00,$3C,$00,$15,$00,$00,$00,$00,$00,$15,$50,$03,$33,$00,$15,$50
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA ; BOX 7, line 1.
defb $00,$3C,$00,$00,$00,$03,$F4,$00,$07,$C0,$00,$00,$00,$3C,$00,$00
defb $00,$00,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$03,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 8, line 1.
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$AA,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 9, Line 1.
defb $00,$00,$00,$AA,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; NEW BOX 10
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$FF
defb $FF,$F4,$50,$00,$00,$00,$00,$55,$00,$00,$F0,$3C,$00,$00,$00,$00
defb $F0,$00,$54,$00,$00,$00,$00,$00,$05,$50,$33,$33,$30,$15,$40,$00
defb $00,$00,$00,$00,$00,$00,$11,$11,$11,$11,$11,$11,$11,$11,$AA,$11 ; BOX 7 line 2
defb $3F,$00,$00,$00,$03,$D4,$00,$07,$F0,$00,$00,$00,$FC,$00,$00,$00
defb $00,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$03,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 8 Line 2 
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$AA,$FF,$FF,$FF,$00,$05,$55,$55,$00,$00,$00,$00,$00,$00,$00 ; BOX 9 Line 2
defb $00,$00,$AA,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; BOX 10 LINE 2
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$FF,$55
defb $54,$50,$00,$00,$00,$00,$54,$00,$00,$C0,$F0,$00,$00,$00,$00,$F0
defb $01,$50,$00,$00,$00,$00,$00,$01,$57,$33,$33,$33,$55,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$00,$0F ; BOX 7 Line 3
defb $C0,$00,$00,$03,$D0,$00,$05,$F0,$00,$00,$03,$FC,$00,$00,$00,$00
defb $FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $03,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 8 Line 3
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $AA,$FF,$FF,$FF,$00,$05,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 9 Line 3
defb $00,$AA,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; BOX 10 LINE 3
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$FF,$7F,$D4
defb $50,$00,$00,$00,$00,$55,$00,$03,$C0,$C0,$00,$00,$00,$C3,$F0,$05
defb $40,$00,$00,$00,$00,$00,$05,$50,$33,$33,$30,$15,$40,$00,$00,$00
defb $00,$00,$00,$00,$44,$44,$44,$44,$44,$44,$44,$44,$AA,$44,$47,$FF ; BOX 7 LINE 4
defb $00,$3F,$FF,$D4,$00,$07,$FF,$FC,$00,$3F,$F0,$00,$00,$00,$00,$FF
defb $FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03
defb $FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 8 LINE 4
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA ; BOX 9 Line 4
defb $FF,$FF,$FF,$00,$05,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $AA,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; BOX 10 LINE 4
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$55,$70,$F4,$50
defb $00,$00,$00,$00,$45,$40,$03,$C3,$C0,$00,$00,$03,$C3,$C0,$15,$00
defb $00,$00,$00,$00,$00,$15,$50,$03,$33,$00,$15,$50,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
defb $FF,$FF,$F5,$00,$17,$FF,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$FF,$FF
defb $FF,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF
defb $FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF
defb $FF,$FF,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$55,$7C,$3C,$50,$00
defb $05,$40,$00,$41,$50,$03,$C3,$C0,$00,$00,$FF,$F3,$C0,$54,$00,$00
defb $00,$00,$00,$00,$55,$40,$03,$33,$00,$05,$50,$00,$00,$00,$00,$00
defb $00,$01,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$13,$FF,$F3
defb $FC,$FD,$55,$5F,$CF,$F3,$FF,$F0,$00,$00,$00,$00,$00,$FF,$FF,$FF
defb $C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF
defb $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
defb $FF,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$55,$5F,$0F,$50,$00,$05
defb $40,$00,$40,$54,$03,$C3,$C0,$00,$03,$FC,$3F,$C1,$50,$00,$00,$00
defb $00,$00,$00,$55,$00,$00,$30,$00,$01,$54,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$C0
defb $FF,$D7,$FF,$03,$FC,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$C0
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF,$FF
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF
defb $00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $00,$00,$00,$00,$00,$AA,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00 ; BOX 1. Line 1
defb $55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$00,$00,$00,$00,$55,$57,$C3,$D0,$00,$05,$40
defb $00,$D0,$15,$03,$F3,$C0,$00,$3F,$FF,$3F,$05,$40,$00,$00,$00,$00
defb $00,$01,$54,$00,$00,$30,$00,$00,$55,$00,$00,$00,$00,$00,$00,$04
defb $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$47,$FF,$00,$0F
defb $FF,$F0,$00,$3F,$F0,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$C0,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF,$FF,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00
defb $00,$00,$15,$55,$55,$55,$55,$55,$55,$55,$55,$50,$00,$05,$55,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
defb $00,$00,$00,$00,$AA,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55 ; BOX 1. Line 2
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$00,$00,$00,$00,$55,$55,$F0,$F0,$00,$05,$40,$00
defb $F5,$05,$40,$FF,$F0,$03,$FC,$3F,$FF,$15,$00,$00,$00,$00,$00,$00
defb $05,$55,$55,$54,$01,$55,$55,$55,$40,$00,$00,$00,$00,$15,$40,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$FC,$00,$00,$3F
defb $00,$00,$0F,$FC,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$C0,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF,$FF,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00
defb $00,$15,$55,$55,$55,$55,$55,$55,$55,$55,$50,$00,$05,$55,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00
defb $00,$00,$00,$AA,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55 ; BOX 1. Line 3
defb $55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$00,$00,$00,$00,$55,$55,$7C,$70,$00,$05,$40,$00,$FF
defb $51,$50,$3F,$FF,$FF,$C0,$00,$3C,$54,$00,$00,$00,$00,$00,$00,$15
defb $55,$55,$54,$01,$55,$55,$55,$40,$00,$00,$00,$00,$55,$51,$11,$11
defb $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$3F,$C0,$00,$00,$3C,$00
defb $00,$00,$FF,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$C0,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF,$FF,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00
defb $15,$55,$55,$55,$55,$55,$55,$55,$55,$50,$00,$05,$55,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00
defb $00,$00,$AA,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55 ; Box 1. Line 4
defb $55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$00,$00,$00,$00,$55,$55,$5F,$50,$00,$05,$40,$00,$FF,$F4
defb $54,$00,$FF,$FC,$00,$00,$3D,$50,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$15,$01,$50,$00,$00,$00,$00,$00,$00,$01,$50,$54,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$00,$3F,$00,$00
defb $00,$3F,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$C0,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$03,$FF,$FF,$FF,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$50,$00,$05,$00,$FF,$FF,$FF,$FF	
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$00,$00,$00,$00,$55,$55,$57,$D7,$D5,$55,$40,$00,$FF,$FD,$55
defb $00,$0F,$F0,$00,$00,$05,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $15,$05,$40,$00,$00,$00,$00,$00,$00,$05,$40,$15,$44,$44,$44,$44
defb $44,$44,$44,$44,$44,$44,$44,$44,$FC,$00,$00,$00,$3F,$00,$00,$00
defb $0F,$C0,$00,$00,$00,$00,$00,$FD,$55,$55,$00,$00,$15,$55,$50,$15
defb $55,$55,$55,$55,$00,$00,$00,$00,$00,$01,$55,$54,$3F,$00,$FF,$05
defb $55,$43,$FC,$03,$FC,$15,$55,$0F,$F0,$00,$00,$03,$FF,$FD,$5C,$00
defb $00,$05,$55,$54,$00,$00,$55,$55,$40,$55,$55,$55,$55,$54,$00,$00
defb $00,$00,$3F,$05,$55,$50,$FF,$00,$FF,$05,$55,$43,$FC,$03,$FC,$15
defb $55,$0F,$F0,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $00,$00,$00,$00,$55,$55,$54,$F5,$F5,$55,$40,$00,$FF,$FF,$D5,$40
defb $00,$00,$00,$00,$15,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05
defb $05,$40,$00,$00,$00,$00,$00,$00,$05,$00,$05,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$03,$F0,$00,$00,$00,$F3,$C0,$04,$00,$03
defb $F0,$00,$00,$00,$00,$00,$01,$55,$55,$00,$00,$15,$55,$50,$15,$55
defb $55,$55,$55,$00,$00,$00,$00,$00,$15,$55,$55,$4F,$00,$FC,$55,$55
defb $54,$FC,$03,$F1,$55,$55,$53,$F0,$00,$00,$03,$FF,$FD,$5C,$00,$00
defb $0D,$55,$54,$30,$30,$55,$55,$00,$55,$55,$55,$55,$54,$00,$00,$00
defb $00,$3C,$55,$55,$55,$7F,$00,$FC,$55,$55,$54,$FC,$03,$F1,$55,$55
defb $53,$F0,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00
defb $00,$00,$00,$55,$55,$54,$7C,$3D,$55,$40,$AA,$5F,$FF,$FD,$50,$00	; box 6 line 1
defb $00,$00,$00,$54,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$55
defb $00,$00,$00,$00,$00,$00,$00,$15,$00,$05,$51,$11,$11,$11,$11,$11
defb $11,$11,$11,$11,$11,$1F,$C0,$00,$10,$00,$F3,$C0,$01,$00,$03,$F0
defb $00,$00,$00,$00,$00,$01,$55,$55,$00,$00,$15,$55,$50,$15,$55,$55
defb $55,$55,$00,$00,$00,$00,$00,$55,$55,$55,$53,$00,$F1,$55,$55,$55
defb $3C,$03,$C5,$55,$55,$54,$F0,$00,$00,$03,$FF,$F5,$7C,$00,$00,$0D
defb $55,$54,$03,$00,$55,$55,$00,$55,$55,$55,$55,$54,$00,$00,$00,$00
defb $31,$55,$55,$55,$5F,$00,$F1,$55,$55,$55,$3C,$03,$C5,$55,$55,$54
defb $F0,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00
defb $00,$00,$55,$57,$54,$0F,$0C,$55,$40,$AA,$45,$FF,$FF,$54,$00,$00 ; BOX 6 line 2
defb $00,$01,$50,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$55,$00
defb $00,$00,$00,$00,$00,$00,$54,$03,$01,$50,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$0F,$C0,$00,$50,$03,$F3,$C0,$01,$40,$03,$F0,$00
defb $00,$00,$00,$00,$01,$55,$55,$00,$00,$15,$55,$50,$15,$55,$55,$55
defb $55,$00,$00,$00,$00,$01,$55,$55,$55,$54,$00,$C5,$55,$55,$55,$4C
defb $03,$15,$55,$55,$55,$30,$00,$00,$03,$FF,$F5,$7C,$00,$00,$0D,$55
defb $54,$0F,$C0,$55,$55,$00,$55,$55,$55,$55,$54,$00,$00,$00,$00,$05
defb $55,$55,$55,$53,$00,$C5,$55,$55,$55,$4C,$03,$15,$55,$55,$55,$30
defb $00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00
defb $00,$55,$5D,$D5,$57,$0D,$55,$40,$AA,$40,$7F,$FF,$55,$00,$00,$00 ; BOX 6 Line 3
defb $05,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$54,$00,$00
defb $00,$00,$00,$00,$01,$50,$00,$00,$54,$44,$44,$44,$44,$44,$44,$44
defb $44,$44,$44,$4F,$C0,$00,$40,$03,$F3,$F0,$00,$40,$03,$F0,$00,$00
defb $00,$00,$00,$03,$15,$55,$40,$00,$55,$55,$30,$15,$55,$55,$55,$55
defb $00,$00,$00,$00,$01,$55,$55,$55,$55,$00,$15,$55,$55,$55,$50,$00
defb $55,$55,$55,$55,$40,$00,$00,$03,$FF,$F5,$7C,$00,$00,$0C,$55,$55
defb $03,$01,$55,$54,$00,$55,$55,$55,$55,$54,$00,$00,$00,$00,$05,$55
defb $55,$55,$57,$00,$15,$55,$55,$55,$50,$00,$55,$55,$55,$55,$40,$00
defb $00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF 
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00 
defb $55,$77,$75,$57,$0D,$55,$40,$AA,$50,$17,$FD,$45,$40,$00,$00,$15 ; BoX 6 Line 4
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$54,$00,$00,$00
defb $00,$00,$00,$05,$40,$0F,$C0,$15,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$0F,$F0,$01,$00,$03,$F3,$F0,$00,$00,$03,$F0,$00,$00,$00
defb $00,$00,$03,$15,$55,$40,$00,$55,$55,$30,$15,$55,$55,$55,$55,$00
defb $00,$00,$00,$01,$55,$50,$55,$55,$00,$15,$55,$01,$55,$50,$00,$55
defb $54,$05,$55,$40,$00,$00,$03,$FF,$D5,$FC,$00,$00,$0C,$55,$55,$00
defb $01,$55,$54,$00,$55,$55,$55,$55,$54,$00,$00,$00,$00,$15,$55,$7F
defb $55,$57,$00,$15,$55,$01,$55,$50,$00,$55,$54,$05,$55,$40,$00,$00
defb $00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ;;
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$55
defb $DD,$DD,$57,$0D,$55,$40,$00,$54,$01,$7D,$51,$50,$00,$00,$54,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$50,$00,$00,$00,$00
defb $00,$00,$15,$00,$00,$00,$05,$51,$11,$11,$11,$11,$11,$11,$11,$11
defb $11,$13,$FC,$00,$00,$0F,$C3,$FC,$00,$00,$3F,$F0,$00,$00,$00,$00
defb $00,$03,$15,$55,$40,$00,$55,$55,$30,$00,$00,$01,$55,$54,$00,$00
defb $00,$00,$05,$55,$40,$15,$55,$00,$15,$55,$01,$55,$50,$00,$55,$54
defb $05,$55,$40,$00,$00,$03,$FF,$D5,$FC,$00,$00,$0C,$55,$55,$03,$01
defb $55,$54,$00,$FF,$FF,$F5,$55,$5C,$00,$00,$00,$00,$15,$55,$0C,$55
defb $57,$00,$15,$55,$01,$55,$50,$00,$55,$54,$05,$55,$40,$00,$00,$00
defb $00,$00,$FF,$FF,$FF,$00,$05,$55,$55,$55,$55,$55,$55,$55,$55,$00
defb $00,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$57,$77
defb $77,$57,$0F,$FF,$55,$55,$55,$00,$15,$00,$54,$00,$01,$50,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$15,$00,$FF,$FC,$05,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$FF,$00,$00,$0F,$C0,$FF,$00,$00,$FF,$C0,$00,$00,$00,$00,$00
defb $03,$05,$55,$50,$01,$55,$54,$30,$00,$00,$01,$55,$50,$00,$00,$00
defb $00,$05,$55,$40,$15,$55,$00,$55,$54,$00,$55,$54,$01,$55,$50,$01
defb $55,$50,$00,$00,$03,$FF,$D5,$FC,$00,$00,$0C,$D5,$55,$43,$05,$55
defb $50,$00,$CC,$CC,$C5,$55,$4C,$00,$00,$00,$00,$3F,$D5,$FF,$55,$57
defb $00,$55,$54,$00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$00,$00
defb $00,$FF,$FF,$FF,$00,$05,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00
defb $50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF 
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$5D,$DD,$DD
defb $D7,$00,$03,$D5,$55,$55,$45,$55,$55,$15,$00,$05,$41,$55,$55,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $54,$00,$00,$00,$01,$54,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
defb $7F,$C0,$00,$3F,$C0,$3F,$00,$03,$FF,$00,$00,$00,$00,$00,$00,$03
defb $05,$55,$50,$01,$55,$54,$30,$00,$00,$05,$55,$40,$00,$00,$00,$00
defb $01,$55,$40,$15,$55,$00,$55,$54,$00,$55,$54,$01,$55,$50,$01,$55
defb $50,$00,$00,$03,$FF,$D5,$FC,$00,$00,$0C,$D5,$55,$43,$05,$55,$50
defb $00,$FF,$FF,$D5,$55,$FC,$00,$00,$00,$00,$3F,$FF,$FD,$55,$5F,$00
defb $55,$54,$00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$00,$00,$00
defb $FF,$FF,$FF,$00,$05,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$50
defb $00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$77,$77,$77,$77
defb $00,$00,$F5,$55,$55,$45,$55,$55,$05,$40,$15,$05,$55,$55,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$50
defb $0F,$FF,$FF,$C0,$54,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3F
defb $F0,$00,$FF,$00,$3F,$C0,$0F,$FC,$00,$00,$00,$00,$00,$00,$03,$01
defb $55,$50,$01,$55,$50,$30,$00,$00,$15,$55,$00,$00,$00,$00,$00,$00
defb $00,$00,$15,$55,$00,$55,$54,$00,$55,$54,$01,$55,$50,$01,$55,$50
defb $00,$00,$03,$FF,$57,$FC,$00,$00,$0C,$C5,$55,$40,$05,$55,$40,$00
defb $33,$33,$55,$57,$30,$00,$00,$00,$00,$30,$C3,$15,$55,$53,$00,$55
defb $54,$00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$00,$00,$00,$FF
defb $FF,$FF,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$50,$00
defb $05,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55
defb $55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$5D,$DD,$DD,$D7,$FF
defb $FC,$3D,$55,$55,$45,$55,$55,$41,$50,$54,$15,$55,$55,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$40,$00
defb $00,$00,$00,$15,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$13,$FF
defb $FF,$FC,$00,$0F,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$03,$01,$55
defb $50,$01,$55,$50,$30,$00,$00,$55,$55,$00,$00,$55,$55,$50,$00,$00
defb $00,$55,$54,$00,$55,$54,$00,$55,$54,$01,$55,$50,$01,$55,$50,$00
defb $00,$03,$FF,$57,$FC,$00,$00,$0C,$C5,$55,$40,$05,$55,$40,$00,$FF
defb $FD,$55,$57,$FC,$01,$55,$55,$40,$3F,$FF,$D5,$55,$FF,$00,$55,$54
defb $00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$00,$00,$00,$FF,$FF
defb $FF,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$50,$00,$05
defb $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55
defb $55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$57,$77,$77,$55,$55,$5F
defb $0F,$55,$55,$41,$11,$54,$50,$55,$50,$54,$44,$05,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$15,$00,$3F,$CF
defb $CF,$F0,$05,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF
defb $F0,$00,$03,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$03,$01,$55,$54
defb $05,$55,$50,$30,$00,$01,$55,$54,$00,$00,$55,$55,$50,$00,$00,$01
defb $55,$57,$00,$55,$54,$00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00
defb $03,$FF,$57,$FC,$00,$00,$0C,$C5,$55,$50,$15,$55,$40,$00,$CC,$C5
defb $55,$5C,$CC,$01,$55,$55,$40,$3F,$FF,$D5,$55,$FF,$00,$55,$54,$00
defb $55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$00,$00,$00,$FF,$FF,$FF
defb $00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$50,$00,$05,$00
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$DD,$DD,$55,$55,$57,$C3
defb $D5,$55,$41,$11,$54,$50,$15,$40,$54,$44,$05,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$00,$3C,$C0,$0C
defb $F0,$05,$50,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$7F,$FF,$C0
defb $00,$03,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$03,$00,$55,$54,$05
defb $55,$40,$30,$00,$05,$55,$50,$00,$00,$55,$55,$50,$00,$00,$05,$55
defb $5F,$00,$55,$54,$00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$03
defb $FD,$57,$FC,$00,$00,$0C,$CD,$55,$50,$15,$55,$00,$00,$FF,$D5,$55
defb $7F,$FC,$01,$55,$55,$40,$30,$C3,$15,$55,$53,$00,$55,$54,$00,$55
defb $54,$01,$55,$50,$01,$55,$50,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00
defb $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$50,$00,$05,$00,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$55,$77,$75,$55,$55,$55,$F0,$F5
defb $55,$41,$11,$54,$51,$05,$04,$54,$44,$05,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$54,$00,$3F,$CF,$CF,$F0
defb $01,$50,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$55,$54,$05,$55
defb $40,$30,$00,$15,$55,$40,$00,$00,$55,$55,$50,$00,$00,$55,$55,$4F
defb $00,$55,$54,$00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$03,$FD
defb $5F,$FC,$00,$00,$0C,$CD,$55,$50,$15,$55,$00,$00,$33,$55,$55,$33
defb $30,$01,$55,$55,$40,$3F,$FF,$D5,$55,$57,$00,$55,$54,$00,$55,$54
defb $01,$55,$50,$01,$55,$50,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$05
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$50,$00,$05,$00,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$55,$5D,$D5,$55,$55,$55,$7C,$3D,$55
defb $41,$11,$54,$51,$40,$14,$54,$44,$05,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$01,$50,$00,$3F,$00,$03,$F0,$00
defb $54,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$10,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$55,$55,$15,$55,$40
defb $30,$00,$55,$55,$00,$00,$00,$55,$55,$50,$00,$01,$55,$55,$33,$00
defb $55,$54,$00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$03,$FD,$5F
defb $FC,$00,$00,$0C,$CD,$55,$54,$55,$55,$00,$00,$FD,$55,$57,$FF,$FC
defb $01,$55,$55,$40,$3F,$FF,$FF,$55,$55,$00,$55,$54,$00,$55,$54,$01
defb $55,$50,$01,$55,$50,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$05,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$50,$00,$05,$00,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$55,$57,$55,$55,$55,$55,$5F,$0F,$55,$41
defb $11,$54,$51,$55,$14,$54,$44,$05,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$05,$40,$03,$30,$3F,$F0,$33,$00,$15
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$15,$55,$15,$55,$00,$30
defb $01,$55,$54,$00,$00,$00,$55,$55,$50,$00,$05,$55,$54,$33,$00,$55
defb $54,$00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$03,$FD,$5F,$FC
defb $00,$00,$0C,$CC,$55,$54,$55,$54,$00,$00,$C5,$55,$5C,$CC,$CC,$01
defb $55,$55,$40,$30,$C3,$0C,$15,$55,$00,$55,$54,$00,$55,$54,$01,$55
defb $50,$01,$55,$50,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$05,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$50,$00,$05,$00,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$57,$FF,$55,$41,$11
defb $54,$51,$55,$14,$54,$44,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$15,$00,$00,$30,$00,$00,$30,$00,$05,$44
defb $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$03,$00,$15,$55,$15,$55,$00,$30,$05
defb $55,$50,$00,$00,$00,$00,$00,$00,$00,$15,$55,$40,$33,$00,$55,$54
defb $00,$55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$03,$F5,$7F,$FC,$00
defb $00,$0C,$CC,$55,$54,$55,$54,$00,$00,$D5,$55,$7F,$FF,$FC,$00,$00
defb $00,$00,$3F,$FF,$FF,$D5,$55,$00,$55,$54,$00,$55,$54,$01,$55,$50
defb $01,$55,$50,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$05,$00,$01,$55
defb $55,$55,$55,$55,$55,$55,$55,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$55,$00,$0F,$33,$FF,$FF,$33,$C0,$05,$50,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$03,$00,$05,$55,$15,$54,$0C,$30,$05,$55
defb $40,$00,$00,$00,$00,$00,$00,$00,$55,$55,$03,$FF,$C0,$55,$54,$00
defb $55,$54,$01,$55,$50,$01,$55,$50,$00,$00,$03,$F5,$7F,$FC,$00,$00
defb $0C,$CC,$D5,$54,$55,$50,$00,$00,$15,$55,$33,$33,$30,$00,$00,$00
defb $00,$3D,$55,$FF,$D5,$55,$00,$55,$54,$00,$55,$54,$01,$55,$50,$01
defb $55,$50,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$05,$00,$01,$55,$55
defb $55,$55,$55,$55,$55,$55,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$01,$54,$00,$00,$30,$00,$00,$30,$00,$01,$55,$11,$11
defb $11,$11,$11,$11,$11,$11,$11,$11,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$03,$00,$05,$55,$55,$54,$0C,$30,$15,$55,$00
defb $00,$00,$00,$00,$00,$00,$01,$55,$54,$00,$00,$30,$15,$55,$01,$55
defb $50,$00,$55,$54,$05,$55,$40,$00,$00,$03,$F5,$7F,$FC,$00,$00,$0C
defb $CC,$D5,$55,$55,$50,$0C,$03,$55,$57,$FF,$FF,$FC,$00,$00,$00,$00
defb $15,$55,$0C,$15,$55,$00,$15,$55,$01,$55,$53,$FC,$55,$54,$05,$55
defb $40,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$05,$00,$01,$55,$55,$55
defb $55,$55,$55,$55,$55,$50,$00,$05,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$01,$50,$00,$FF,$33,$FF,$FF,$33,$FC,$00,$54,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$03,$0F,$C5,$55,$55,$54,$3C,$30,$55,$55,$55,$55
defb $55,$40,$00,$00,$00,$01,$55,$55,$55,$55,$0C,$15,$55,$01,$55,$50
defb $00,$55,$54,$05,$55,$70,$00,$00,$03,$F5,$7F,$FC,$00,$00,$0C,$CC
defb $D5,$55,$55,$50,$00,$01,$55,$55,$55,$55,$55,$00,$00,$00,$00,$35
defb $55,$7F,$55,$55,$00,$15,$55,$01,$55,$5C,$03,$55,$54,$05,$55,$70
defb $00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$05,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$05,$40,$00,$00,$30,$00,$00,$30,$00,$00,$15,$04,$44,$44,$44
defb $44,$44,$44,$44,$44,$44,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$03,$00,$01,$55,$55,$50,$30,$30,$55,$55,$55,$55,$55
defb $40,$00,$00,$00,$05,$55,$55,$55,$55,$0C,$15,$55,$55,$55,$50,$F0
defb $55,$55,$55,$55,$70,$00,$00,$03,$D5,$FF,$FC,$00,$00,$0C,$CC,$C5
defb $55,$55,$40,$CC,$C1,$55,$55,$55,$55,$55,$00,$00,$00,$00,$35,$55
defb $55,$55,$54,$00,$15,$55,$55,$55,$53,$0C,$55,$55,$55,$55,$70,$00
defb $00,$00,$00,$00,$FF,$FF,$FF,$00,$05,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $15,$00,$03,$FF,$FF,$FF,$FF,$FF,$FF,$00,$05,$40,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$03,$0C,$C1,$55,$55,$50,$3F,$30,$55,$55,$55,$55,$55,$40
defb $03,$00,$00,$05,$55,$55,$55,$55,$03,$05,$55,$55,$55,$40,$F0,$15
defb $55,$55,$55,$30,$00,$00,$03,$D5,$FF,$FC,$00,$00,$0C,$CC,$C5,$55
defb $55,$40,$3F,$01,$55,$55,$55,$55,$55,$00,$00,$00,$00,$31,$55,$55
defb $55,$57,$00,$05,$55,$55,$55,$73,$0C,$D5,$55,$55,$55,$30,$00,$00
defb $00,$00,$00,$FF,$FF,$FF,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA ; BOX 2 Line 1 
defb $55,$55,$55,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 3 LINE 1
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 5 line 1
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$51,$11,$11,$11,$11,$11
defb $11,$11,$11,$11,$10,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$03,$00,$01,$55,$55,$50,$03,$30,$55,$55,$55,$55,$55,$40,$0C
defb $C0,$00,$15,$55,$55,$55,$55,$0C,$01,$55,$55,$55,$03,$0C,$05,$55
defb $55,$54,$30,$00,$00,$03,$D5,$FF,$FF,$0F,$0F,$0F,$CC,$C5,$55,$55
defb $40,$0C,$01,$55,$55,$55,$55,$55,$00,$00,$00,$3F,$31,$55,$55,$55
defb $53,$FF,$01,$55,$55,$55,$30,$00,$C5,$55,$55,$54,$30,$00,$00,$00
defb $00,$00,$FF,$FF,$FF,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$55 ; BOX 2 Line 2
defb $55,$55,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 3 LINE 2
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 5 LINE 2
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$54,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$01,$54,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $03,$0F,$C1,$55,$55,$50,$0F,$30,$55,$55,$55,$55,$55,$40,$FF,$FC
defb $00,$15,$55,$55,$55,$55,$03,$00,$55,$55,$54,$0C,$03,$01,$55,$55
defb $50,$F0,$00,$00,$03,$57,$FF,$FC,$F0,$F0,$F0,$FC,$CD,$55,$55,$00
defb $0C,$01,$55,$55,$55,$55,$55,$00,$00,$00,$C3,$FF,$15,$55,$55,$43
defb $C0,$C0,$55,$55,$54,$0C,$FC,$C1,$55,$55,$50,$F0,$00,$00,$00,$00
defb $00,$FF,$FF,$FF,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$55,$55 ; BOX 2 LINE 3
defb $55,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 3 LINE 3
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55
defb $55,$55,$55,$55,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 5 LINE 3
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$54,$44,$44,$44,$44,$44,$44,$44
defb $44,$44,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03
defb $0C,$C1,$55,$55,$50,$0C,$30,$55,$55,$55,$55,$55,$40,$00,$00,$00
defb $15,$55,$55,$55,$55,$0C,$00,$05,$55,$40,$30,$F0,$C0,$15,$55,$03
defb $F0,$00,$00,$03,$57,$FF,$FC,$00,$00,$00,$0F,$CD,$55,$55,$00,$33
defb $01,$55,$55,$55,$55,$55,$00,$00,$03,$0C,$3F,$C1,$55,$54,$0F,$0C
defb $30,$05,$55,$40,$3F,$03,$F0,$15,$55,$03,$F0,$00,$00,$00,$00,$00
defb $FF,$FF,$FF,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$55,$55,$55 ; BOX 2 LINE 4
defb $AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 3 LINE 4
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55
defb $55,$55,$55,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; BOX 5 LINE 4
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$55,$55,$55,$55
defb $55,$55,$55,$55,$55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$0C
defb $C0,$00,$00,$00,$0C,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$03,$00,$00,$00,$00,$30,$00,$C0,$00,$00,$0F,$F0
defb $00,$00,$03,$03,$FF,$FC,$00,$00,$00,$00,$CC,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$0C,$30,$03,$F0,$00,$00,$30,$00,$0C
defb $00,$00,$00,$C0,$00,$0C,$00,$00,$0F,$F0,$00,$00,$00,$00,$00,$FF
defb $FF,$FF,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF








;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
intro_screen:							     ;        Bouncy Ball screen
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
defb $55,$57,$FF,$55,$57,$D5,$55,$55,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $55,$57,$FF,$55,$57,$D5,$55,$55,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $55,$57,$FF,$55,$57,$D5,$55,$55,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $55,$57,$FF,$6A,$A7,$55,$55,$55,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$AA,$BF,$FF,$FF,$FF,$EA,$FA,$BF
defb $55,$57,$FA,$AA,$AA,$55,$55,$55,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$EA,$AA,$AB,$FF,$FF,$FF,$EA,$FA,$BF
defb $55,$57,$FA,$95,$6A,$55,$55,$55,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $EA,$FF,$FF,$FF,$FF,$FF,$FF,$EA,$FF,$AB,$FF,$AA,$AB,$EB,$FA,$FF
defb $55,$57,$FA,$95,$5A,$FF,$AA,$A5,$7A,$FF,$FF,$FE,$BE,$AA,$BF,$FE
defb $AA,$AF,$FF,$FF,$AB,$FF,$FF,$EA,$FF,$EB,$FE,$AA,$AB,$EB,$FA,$FF
defb $55,$57,$FA,$95,$5A,$FE,$A5,$A9,$FA,$FF,$FA,$BE,$AA,$AA,$AF,$FA
defb $BF,$AF,$EA,$FF,$AB,$FF,$FF,$EA,$FF,$EB,$FA,$BF,$EB,$EB,$FA,$FF
defb $55,$57,$FA,$95,$5A,$FA,$95,$6A,$FA,$FF,$FA,$BE,$AB,$FF,$AB,$EA
defb $FF,$FF,$EA,$FF,$AB,$FF,$FF,$EA,$FF,$EB,$EA,$FF,$AB,$EB,$FA,$FF
defb $D5,$55,$FA,$95,$AA,$FA,$95,$5A,$FA,$FF,$FA,$BE,$AF,$FF,$EB,$EA
defb $FF,$FF,$EB,$FF,$AB,$FF,$FF,$EA,$FE,$AB,$EA,$FF,$AB,$EB,$FA,$FF
defb $D5,$55,$7A,$AA,$AB,$FA,$55,$5A,$FA,$FF,$FA,$BE,$AF,$FF,$EB,$EB
defb $FF,$FF,$EA,$FF,$AB,$FF,$FF,$EA,$AA,$AF,$EB,$FF,$AB,$EA,$FA,$BF
defb $F5,$55,$5A,$96,$AF,$FA,$55,$5A,$FA,$BF,$FA,$BE,$AF,$FF,$EB,$EB
defb $FF,$EB,$EA,$FF,$AB,$FF,$FF,$EA,$FA,$BF,$EB,$FF,$AB,$EA,$FA,$BF
defb $F5,$55,$5A,$95,$AB,$FA,$95,$6A,$FA,$BF,$FA,$BF,$AF,$FF,$EB,$EA
defb $FF,$AB,$EA,$FE,$AB,$FF,$FF,$EA,$FE,$AF,$EA,$FF,$AB,$EA,$FA,$BF
defb $FD,$55,$56,$95,$AB,$DA,$A5,$AB,$FA,$BF,$EA,$BF,$AF,$FF,$AB,$FA
defb $BE,$AB,$FA,$FA,$AB,$FF,$FF,$FA,$FE,$AF,$EA,$FF,$AB,$EA,$FA,$BF
defb $FD,$55,$56,$AA,$AF,$56,$AA,$A5,$5E,$AA,$AA,$BF,$AF,$FF,$AB,$FA
defb $AA,$AF,$EA,$AA,$AF,$FF,$FF,$FA,$AA,$BF,$FA,$AA,$AB,$EA,$FA,$BF
defb $FF,$55,$56,$AA,$FF,$55,$6A,$55,$5F,$AA,$BE,$BF,$AF,$FF,$AF,$FF
defb $AA,$FF,$EA,$AB,$AF,$FF,$FF,$FA,$AB,$FF,$FE,$AA,$AB,$EA,$FA,$BF
defb $FF,$55,$55,$57,$FF,$55,$55,$55,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$EA,$FF,$AF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$D5,$55,$5F,$FF,$D5,$55,$55,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$EA,$FE,$AF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$D5,$55,$5F,$FF,$D5,$55,$55,$5F,$FF,$FC,$0F,$FF,$FF,$FF,$FF
defb $FF,$FF,$FA,$AA,$BF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$F5,$55,$7F,$FF,$D5,$55,$55,$5F,$FF,$00,$00,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$AB,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0,$00,$00,$03,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$3F,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$03,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$00,$FF,$FF
defb $FF,$D5,$55,$57,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$3F,$FF
defb $F5,$7F,$FF,$FD,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$0F,$FF
defb $D7,$FF,$FF,$FF,$F5,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$03,$FF
defb $5F,$FF,$FF,$FF,$FF,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$00,$00,$00,$FD
defb $7F,$FF,$FF,$FF,$FF,$F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$51,$40,$00,$00,$00,$00,$FD
defb $FF,$FF,$FF,$FF,$FF,$FD,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$51,$40,$00,$00,$00,$00,$3F
defb $FF,$FF,$FF,$FF,$FF,$FD,$7F,$FF,$FF,$F5,$55,$5F,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$3F
defb $FF,$FF,$FF,$FF,$FF,$FF,$5F,$FF,$FF,$D7,$FF,$D5,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$51,$40,$00,$00,$00,$00,$3F
defb $FF,$FF,$FF,$FF,$FF,$FF,$D7,$FF,$FD,$7F,$FF,$FD,$7F,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$51,$40,$00,$00,$00,$00,$0F
defb $FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF,$F5,$FF,$FF,$FF,$5F,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$0F
defb $FF,$FF,$FF,$FF,$FF,$FF,$F5,$FF,$F7,$FF,$FF,$FF,$F7,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$0F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$D7,$FF,$FF,$FF,$F5,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$0F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$DF,$FF,$FF,$FF,$FD,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$03
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$5F,$FF,$FF,$FF,$FD,$7F,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$03
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$DF,$7F,$FF,$FF,$FF,$FF,$7F,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$03
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$DF,$7F,$FF,$FF,$FF,$FF,$7F,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$03
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$D7,$FF,$FF,$FF,$FF,$FF,$5F,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$03
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F5,$FF,$FF,$FF,$FF,$FF,$DF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$03
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F5,$FF,$FF,$FF,$FF,$FF,$DF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$03
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF,$FF,$FF,$FF,$FF,$D7,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$0F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$0F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$FF,$FF,$FF,$FF,$F5,$FF,$F7
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$0F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$DF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$0F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$7F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$3F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$7F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$3F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$7F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$3F
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FD,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$00,$00,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$7F,$DF,$FF,$FF,$FF,$FD,$F7,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$00,$00,$03,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$DF,$7F,$7F,$FF,$FF,$FF,$FD,$F7,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$00,$00,$00,$00,$0F,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7,$75,$FF,$FF,$FF,$FF,$FD,$5F,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$3F,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$00,$00,$00,$00,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$DF,$FF,$FF,$FF,$FF,$FD,$7F,$7F,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0,$00,$00,$00,$00,$03,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$DF,$FF,$FF,$FF,$FF,$D7,$F5,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$00,$00,$3F,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FC,$00,$00,$03,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF,$FF,$FF,$FF,$FF,$7F,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$C0,$00,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF








;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
keys:  								      ;       KEYS/intro SCREEN
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$95,$55,$6A,$AA,$55,$AA,$96,$AA,$96,$96,$AA,$96,$AA,$55
defb $6A,$5A,$AA,$5A,$A9,$55,$56,$AA,$A5,$6A,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$95,$55,$5A,$A5,$55,$5A,$96,$AA,$96,$95,$AA,$96,$A5,$55
defb $5A,$56,$A9,$5A,$A9,$55,$55,$AA,$A5,$6A,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$96,$AA,$5A,$A5,$AA,$5A,$96,$AA,$96,$95,$6A,$96,$A5,$AA
defb $56,$96,$A9,$6A,$A9,$6A,$A5,$AA,$96,$5A,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$96,$AA,$5A,$96,$AA,$96,$96,$AA,$96,$95,$6A,$96,$96,$AA
defb $9A,$A5,$A5,$AA,$A9,$6A,$A5,$AA,$96,$5A,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$96,$AA,$5A,$96,$AA,$96,$96,$AA,$96,$96,$5A,$96,$96,$AA
defb $AA,$A5,$A5,$AA,$A9,$6A,$A5,$AA,$96,$5A,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$95,$55,$6A,$96,$AA,$96,$96,$AA,$96,$96,$96,$96,$96,$AA
defb $AA,$A9,$56,$AA,$A9,$55,$56,$AA,$5A,$96,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$95,$55,$5A,$96,$AA,$96,$96,$AA,$96,$96,$96,$96,$96,$AA
defb $AA,$AA,$5A,$AA,$A9,$55,$55,$AA,$5A,$96,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$96,$AA,$56,$96,$AA,$96,$96,$AA,$96,$96,$A5,$96,$96,$AA
defb $AA,$AA,$5A,$AA,$A9,$6A,$A5,$6A,$55,$56,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$96,$AA,$96,$96,$AA,$96,$96,$AA,$96,$96,$A9,$56,$96,$AA
defb $9A,$AA,$5A,$AA,$A9,$6A,$A9,$69,$55,$55,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$96,$AA,$96,$A5,$AA,$5A,$95,$AA,$56,$96,$A9,$56,$A5,$AA
defb $56,$AA,$5A,$AA,$A9,$6A,$A9,$69,$6A,$A5,$A5,$AA,$AA,$5A,$AA,$AA
defb $AA,$AA,$95,$55,$5A,$A5,$55,$5A,$A5,$55,$5A,$96,$AA,$56,$A5,$55
defb $5A,$AA,$5A,$AA,$A9,$55,$55,$A9,$6A,$A5,$A5,$55,$5A,$55,$55,$AA
defb $AA,$AA,$95,$55,$6A,$AA,$55,$AA,$A9,$55,$6A,$96,$AA,$96,$AA,$55
defb $6A,$AA,$5A,$AA,$A9,$55,$56,$A5,$AA,$A9,$65,$55,$5A,$55,$55,$AA
defb $AA,$AA,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$EA
defb $AA,$AA,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$EA
defb $AA,$AA,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$EA
defb $AA,$AA,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
defb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$EA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$99,$AA,$AA,$A5,$6A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$6A,$AA
defb $A9,$AA,$9A,$AA,$AA,$AA,$AA,$6A,$A9,$55,$69,$55,$95,$55,$AA,$AA
defb $AA,$69,$AA,$AA,$9A,$6A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$9A,$AA
defb $A9,$6A,$5A,$AA,$AA,$AA,$AA,$6A,$A9,$AA,$A9,$AA,$AA,$6A,$AA,$AA
defb $AA,$69,$A9,$5A,$55,$5A,$A9,$5A,$99,$99,$A5,$69,$A9,$A9,$9A,$AA
defb $A9,$6A,$5A,$AA,$AA,$AA,$AA,$6A,$A9,$AA,$A9,$AA,$AA,$6A,$AA,$AA
defb $A9,$A9,$A6,$A6,$9A,$6A,$A6,$A6,$96,$96,$9A,$99,$A9,$A9,$A6,$AA
defb $A9,$99,$9A,$AA,$95,$56,$AA,$6A,$A9,$AA,$A9,$AA,$AA,$6A,$AA,$AA
defb $A9,$A9,$A6,$A6,$9A,$6A,$AA,$A6,$9A,$9A,$9A,$9A,$66,$66,$A6,$AA
defb $A9,$99,$9A,$AA,$AA,$AA,$AA,$6A,$A9,$55,$69,$56,$AA,$6A,$AA,$AA
defb $A9,$A9,$A5,$56,$9A,$6A,$A9,$56,$9A,$9A,$9A,$9A,$66,$66,$A6,$AA
defb $A9,$99,$9A,$AA,$AA,$AA,$AA,$6A,$A9,$AA,$A9,$AA,$AA,$6A,$AA,$AA
defb $A9,$A9,$A6,$AA,$9A,$6A,$A6,$A6,$9A,$9A,$9A,$9A,$66,$66,$A6,$AA
defb $A9,$99,$9A,$AA,$95,$56,$AA,$6A,$A9,$AA,$A9,$AA,$AA,$6A,$AA,$AA
defb $A9,$A9,$A6,$A6,$9A,$6A,$A6,$96,$9A,$9A,$9A,$9A,$9A,$9A,$A6,$AA
defb $A9,$A6,$9A,$AA,$AA,$AA,$AA,$6A,$A9,$AA,$A9,$AA,$AA,$6A,$AA,$AA
defb $AA,$69,$A9,$5A,$9A,$5A,$A9,$66,$9A,$9A,$A5,$6A,$9A,$9A,$9A,$AA
defb $A9,$A6,$9A,$AA,$AA,$AA,$AA,$55,$59,$55,$69,$AA,$AA,$6A,$AA,$AA
defb $AA,$6A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$9A,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$9A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$6A,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$9A,$A9,$AA,$AA,$9A,$AA,$6A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $6A,$AA,$AA,$AA,$AA,$AA,$A9,$55,$6A,$6A,$95,$AA,$6A,$A6,$55,$56
defb $AA,$6A,$AA,$AA,$AA,$9A,$AA,$6A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $9A,$AA,$AA,$AA,$AA,$AA,$A9,$AA,$9A,$6A,$6A,$6A,$6A,$A6,$A9,$AA
defb $AA,$69,$99,$A9,$66,$99,$69,$5A,$A9,$5A,$99,$99,$A5,$69,$A9,$A9
defb $9A,$AA,$AA,$AA,$AA,$AA,$A9,$AA,$9A,$69,$AA,$9A,$6A,$A6,$A9,$AA
defb $A9,$A9,$69,$A6,$96,$96,$9A,$6A,$A6,$A6,$96,$96,$9A,$99,$A9,$A9
defb $A6,$AA,$AA,$AA,$55,$5A,$A9,$AA,$9A,$69,$AA,$AA,$6A,$A6,$A9,$AA
defb $A9,$A9,$A9,$A6,$A6,$9A,$9A,$6A,$AA,$A6,$9A,$9A,$9A,$9A,$66,$66
defb $A6,$AA,$AA,$AA,$AA,$AA,$A9,$55,$6A,$69,$A9,$5A,$55,$56,$A9,$AA
defb $A9,$A9,$A9,$A6,$A6,$9A,$9A,$6A,$A9,$56,$9A,$9A,$9A,$9A,$66,$66
defb $A6,$AA,$AA,$AA,$AA,$AA,$A9,$A9,$AA,$69,$AA,$9A,$6A,$A6,$A9,$AA
defb $A9,$A9,$A9,$A6,$A6,$9A,$9A,$6A,$A6,$A6,$9A,$9A,$9A,$9A,$66,$66
defb $A6,$AA,$AA,$AA,$55,$5A,$A9,$AA,$6A,$69,$AA,$9A,$6A,$A6,$A9,$AA
defb $A9,$A9,$A9,$A6,$96,$9A,$9A,$6A,$A6,$96,$9A,$9A,$9A,$9A,$9A,$9A
defb $A6,$AA,$AA,$AA,$AA,$AA,$A9,$AA,$6A,$6A,$6A,$6A,$6A,$A6,$A9,$AA
defb $AA,$69,$A9,$A9,$66,$9A,$9A,$5A,$A9,$66,$9A,$9A,$A5,$6A,$9A,$9A
defb $9A,$AA,$6A,$AA,$AA,$AA,$A9,$AA,$9A,$6A,$95,$AA,$6A,$A6,$A9,$AA
defb $AA,$6A,$AA,$AA,$A6,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $9A,$AA,$6A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$9A,$AA,$A5,$5A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $6A,$AA,$6A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$28,$AA,$AA,$AA,$AA,$AA,$AA,$8A
defb $AA,$AA,$AA,$AA,$AA,$AA,$8A,$AA,$2A,$AA,$AA,$AA,$2A,$AA,$A8,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$28,$80,$82,$A0,$28,$0A,$AA,$2A
defb $02,$02,$80,$28,$2A,$0A,$A2,$A8,$0A,$0A,$AA,$00,$08,$02,$00,$2A
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$8A,$28,$8A,$A2,$AA,$A8,$A8
defb $AA,$28,$AA,$22,$88,$A2,$A8,$AA,$28,$A2,$A8,$AA,$2A,$A2,$28,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$2A,$8A,$00,$A0,$A8,$2A,$AA,$2A
defb $0A,$28,$A0,$22,$A8,$02,$A2,$AA,$28,$A2,$AA,$0A,$2A,$02,$28,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$2A,$8A,$2A,$AA,$2A,$8A,$AA,$8A
defb $A2,$28,$8A,$22,$88,$AA,$8A,$AA,$28,$A2,$AA,$A2,$28,$A2,$28,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$2A,$8A,$80,$80,$A0,$2A,$AA,$A8
defb $0A,$02,$80,$28,$2A,$02,$AA,$AA,$0A,$0A,$A8,$0A,$08,$02,$28,$2A
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$2A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
defb $AA,$2A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA






;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
gameover1:							      ;       
winner_grfx:							      ;       WINNER GRAPHIC WITHIN GAMEOVER
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
defb $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
defb $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
defb $000,$005,$055,$040,$015,$055,$000,$055,$050,$055,$050,$015,$050,$000,$015,$054
defb $001,$055,$000,$001,$055,$040,$015,$055,$055,$055,$050,$055,$055,$055,$050,$000
defb $000,$03F,$0FD,$043,$0FF,$0F5,$00F,$0FF,$05F,$0FF,$050,$0FF,$0D4,$000,$0FF,$0D4
defb $00F,$0FD,$040,$00F,$0FD,$040,$0FF,$0FF,$0FF,$0FF,$053,$0FF,$0FF,$0FF,$0D5,$000
defb $000,$03F,$0FD,$043,$0FF,$0F5,$00F,$0FF,$05F,$0FF,$050,$0FF,$0F5,$000,$0FF,$0D4
defb $00F,$0FF,$050,$00F,$0FD,$040,$0FF,$0FF,$0FF,$0FF,$053,$0FF,$0FF,$0FF,$0FD,$040
defb $000,$00F,$0FF,$053,$0FF,$0F5,$03F,$0FD,$05F,$0FF,$050,$0FF,$0FD,$040,$0FF,$0D4
defb $00F,$0FF,$0D4,$00F,$0FD,$040,$0FF,$0FF,$0FF,$0FF,$053,$0FF,$0FF,$0FF,$0FF,$050
defb $000,$00F,$0FF,$05F,$0FF,$0FD,$03F,$0FD,$05F,$0FF,$050,$0FF,$0FF,$050,$0FF,$0D4
defb $00F,$0FF,$0F5,$00F,$0FD,$040,$0FF,$0FF,$0FF,$0FF,$003,$0FF,$0FF,$0FF,$0FF,$050
defb $000,$00F,$0FF,$05F,$0FF,$0FD,$07F,$0FD,$05F,$0FF,$050,$0FF,$0FF,$054,$0FF,$0D4
defb $00F,$0FF,$0F5,$04F,$0FD,$040,$0FF,$0F5,$000,$000,$003,$0FF,$0D4,$00F,$0FF,$050
defb $000,$00F,$0FF,$05F,$0FF,$0FD,$07F,$0FD,$05F,$0FF,$050,$0FF,$0FF,$0D5,$0FF,$0D4
defb $00F,$0FF,$0FD,$05F,$0FD,$040,$0FF,$0F5,$055,$055,$043,$0FF,$0D5,$05F,$0FF,$050
defb $000,$003,$0FF,$0FF,$0F7,$0FF,$0FF,$0F5,$04F,$0FF,$050,$0FF,$0FF,$0F5,$0FF,$0D4
defb $00F,$0FF,$0FF,$05F,$0FD,$040,$0FF,$0FF,$0FF,$0FD,$043,$0FF,$0FF,$0FF,$0FF,$000
defb $000,$003,$0FF,$0FF,$0F7,$0FF,$0FF,$0F5,$04F,$0FF,$050,$0FF,$0FF,$0FD,$0FF,$0D4
defb $00F,$0FF,$0FF,$0DF,$0FD,$040,$0FF,$0FF,$0FF,$0FD,$043,$0FF,$0FF,$0FF,$0FC,$000
defb $000,$003,$0FF,$0FF,$0F7,$0FF,$0FF,$0F5,$04F,$0FF,$050,$0FF,$0FF,$0FF,$0FF,$0D4
defb $00F,$0FF,$0FF,$0FF,$0FD,$040,$0FF,$0FF,$0FF,$0FD,$043,$0FF,$0FF,$0FF,$0F0,$000
defb $000,$003,$0FF,$0FF,$0D5,$0FF,$0FF,$0F5,$04F,$0FF,$050,$0FF,$0DF,$0FF,$0FF,$0D4
defb $00F,$0FD,$0FF,$0FF,$0FD,$040,$0FF,$0FF,$0FF,$0FC,$003,$0FF,$0FF,$0FF,$0D4,$000
defb $000,$000,$0FF,$0FF,$0D5,$0FF,$0FF,$0D5,$00F,$0FF,$050,$0FF,$0D7,$0FF,$0FF,$0D4
defb $00F,$0FD,$07F,$0FF,$0FD,$040,$0FF,$0F5,$000,$000,$003,$0FF,$0D7,$0FF,$0F5,$000
defb $000,$000,$0FF,$0FF,$0D5,$0FF,$0FF,$0D5,$00F,$0FF,$050,$0FF,$0D4,$0FF,$0FF,$0D4
defb $00F,$0FD,$04F,$0FF,$0FD,$040,$0FF,$0F5,$000,$000,$003,$0FF,$0D4,$0FF,$0FD,$040
defb $000,$000,$0FF,$0FF,$0D4,$0FF,$0FF,$0D5,$00F,$0FF,$050,$0FF,$0D4,$0FF,$0FF,$0D4
defb $00F,$0FD,$04F,$0FF,$0FD,$040,$0FF,$0F5,$055,$055,$053,$0FF,$0D4,$03F,$0FD,$040
defb $000,$000,$0FF,$0FF,$054,$03F,$0FF,$0D4,$00F,$0FF,$050,$0FF,$0D4,$03F,$0FF,$0D4
defb $00F,$0FD,$043,$0FF,$0FD,$040,$0FF,$0FF,$0FF,$0FF,$053,$0FF,$0D4,$03F,$0FF,$050
defb $000,$000,$03F,$0FF,$050,$03F,$0FF,$054,$00F,$0FF,$050,$0FF,$0D4,$00F,$0FF,$0D4
defb $00F,$0FD,$040,$0FF,$0FD,$040,$0FF,$0FF,$0FF,$0FF,$053,$0FF,$0D4,$00F,$0FF,$0D4
defb $000,$000,$03F,$0FF,$050,$03F,$0FF,$050,$00F,$0FF,$050,$0FF,$0D4,$003,$0FF,$0D4
defb $00F,$0FD,$040,$03F,$0FD,$040,$0FF,$0FF,$0FF,$0FF,$053,$0FF,$0D4,$003,$0FF,$0D4
defb $000,$000,$03F,$0FC,$000,$00F,$0FF,$000,$00F,$0FF,$000,$0FF,$0C0,$000,$0FF,$0C0
defb $00F,$0FC,$000,$00F,$0FC,$000,$0FF,$0FF,$0FF,$0FF,$003,$0FF,$0C0,$003,$0FF,$0F0
defb $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
defb $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
defb $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
defb $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000




;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
gameover:							      ;       Game over graphic wording
gameover2:
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$2A,$A8,$00,$02,$AA,$A0,$02,$AA,$00,$2A,$A2,$AA,$AA,$A0
defb $00,$00,$AA,$80,$0A,$A0,$00,$2A,$8A,$AA,$AA,$8A,$AA,$AA,$00,$00
defb $00,$00,$AA,$AA,$00,$02,$AA,$A0,$02,$AA,$00,$2A,$A2,$AA,$AA,$A0
defb $00,$02,$AA,$A0,$0A,$A8,$00,$AA,$8A,$AA,$AA,$8A,$AA,$AA,$80,$00
defb $00,$02,$AA,$AA,$80,$02,$AA,$A0,$02,$AA,$00,$2A,$A2,$AA,$AA,$A0
defb $00,$0A,$AA,$A8,$02,$A8,$00,$AA,$0A,$AA,$AA,$8A,$AA,$AA,$A0,$00
defb $00,$0A,$AA,$AA,$A0,$0A,$AA,$A8,$02,$AA,$00,$2A,$A2,$AA,$AA,$A0
defb $00,$2A,$AA,$AA,$02,$A8,$00,$AA,$0A,$AA,$AA,$8A,$AA,$AA,$A0,$00
defb $00,$0A,$A0,$2A,$A0,$0A,$AA,$A8,$02,$AA,$80,$AA,$A2,$A8,$00,$00
defb $00,$2A,$80,$AA,$02,$A8,$00,$AA,$0A,$A0,$00,$0A,$A0,$0A,$A0,$00
defb $00,$2A,$A0,$0A,$00,$0A,$A2,$A8,$02,$AA,$80,$AA,$A2,$A8,$00,$00
defb $00,$AA,$80,$AA,$82,$AA,$02,$A8,$0A,$A0,$00,$0A,$A0,$0A,$A0,$00
defb $00,$2A,$80,$00,$00,$0A,$A2,$A8,$02,$AA,$80,$AA,$A2,$A8,$00,$00
defb $00,$AA,$00,$2A,$80,$AA,$02,$A8,$0A,$A0,$00,$0A,$A0,$0A,$A0,$00
defb $00,$2A,$80,$00,$00,$0A,$A2,$A8,$02,$A2,$80,$A2,$A2,$AA,$AA,$80
defb $00,$AA,$00,$2A,$80,$AA,$02,$A8,$0A,$AA,$AA,$0A,$AA,$AA,$A0,$00
defb $00,$2A,$80,$AA,$A0,$2A,$A2,$AA,$02,$A2,$A2,$A2,$A2,$AA,$AA,$80
defb $00,$AA,$00,$2A,$80,$AA,$02,$A8,$0A,$AA,$AA,$0A,$AA,$AA,$80,$00
defb $00,$2A,$80,$AA,$A0,$2A,$80,$AA,$02,$A2,$A2,$A2,$A2,$AA,$AA,$80
defb $00,$AA,$00,$2A,$80,$2A,$8A,$A0,$0A,$AA,$AA,$0A,$AA,$AA,$00,$00
defb $00,$2A,$80,$AA,$A0,$2A,$80,$AA,$02,$A2,$A2,$A2,$A2,$AA,$AA,$80
defb $00,$AA,$00,$2A,$80,$2A,$8A,$A0,$0A,$AA,$AA,$0A,$AA,$A8,$00,$00
defb $00,$2A,$80,$AA,$A0,$2A,$AA,$AA,$02,$A0,$A2,$82,$A2,$A8,$00,$00
defb $00,$AA,$00,$2A,$80,$2A,$8A,$A0,$0A,$A0,$00,$0A,$A0,$AA,$00,$00
defb $00,$2A,$80,$0A,$A0,$AA,$AA,$AA,$82,$A0,$A2,$82,$A2,$A8,$00,$00
defb $00,$AA,$00,$2A,$80,$2A,$8A,$A0,$0A,$A0,$00,$0A,$A0,$AA,$80,$00
defb $00,$2A,$A0,$0A,$A0,$AA,$AA,$AA,$82,$A0,$AA,$82,$A2,$A8,$00,$00
defb $00,$AA,$80,$AA,$80,$0A,$8A,$80,$0A,$A0,$00,$0A,$A0,$2A,$80,$00
defb $00,$0A,$A0,$2A,$A0,$AA,$AA,$AA,$82,$A0,$AA,$82,$A2,$A8,$00,$00
defb $00,$2A,$80,$AA,$00,$0A,$AA,$80,$0A,$A0,$00,$0A,$A0,$2A,$80,$00
defb $00,$0A,$AA,$AA,$A0,$AA,$AA,$AA,$82,$A0,$2A,$82,$A2,$AA,$AA,$A0
defb $00,$2A,$AA,$AA,$00,$0A,$AA,$80,$0A,$AA,$AA,$8A,$A0,$2A,$A0,$00
defb $00,$02,$AA,$AA,$A0,$AA,$00,$2A,$82,$A0,$2A,$02,$A2,$AA,$AA,$A0
defb $00,$0A,$AA,$A8,$00,$0A,$AA,$00,$0A,$AA,$AA,$8A,$A0,$0A,$A0,$00
defb $00,$00,$AA,$AA,$02,$AA,$00,$2A,$A2,$A0,$2A,$02,$A2,$AA,$AA,$A0
defb $00,$02,$AA,$A8,$00,$02,$AA,$00,$0A,$AA,$AA,$8A,$A0,$0A,$A0,$00
defb $00,$00,$2A,$A8,$02,$A8,$00,$0A,$A2,$A0,$2A,$02,$A2,$AA,$AA,$A0
defb $00,$00,$AA,$80,$00,$02,$AA,$00,$0A,$AA,$AA,$8A,$A0,$0A,$A8,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00



;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;PhaserX Demo song music data
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

musicData1			; first scrolly screen music
	dw mdb_Patterns_ptn1
	dw mdb_Patterns_ptn1
	dw mdb_Patterns_ptn1
	dw mdb_Patterns_ptn1
	dw 0			; auto exit, to then display KEYs screen.
musicData2			; second KEYs screen music
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn3
	dw mdb_Patterns_ptn3
	dw mdb_Patterns_ptn3
	dw mdb_Patterns_ptn3a
songloop
	dw mdb_Patterns_ptn4
	dw mdb_Patterns_ptn4
	dw mdb_Patterns_ptn4
	dw mdb_Patterns_ptn4a
	dw mdb_Patterns_ptn5
	dw mdb_Patterns_ptn5
	dw mdb_Patterns_ptn5
	dw mdb_Patterns_ptn5a
	dw 0				;songloop



mdb_Patterns_ptn1

	dw $600, $b400, $80, 0, 0, $2020, a1, a1+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, e2, e2+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, d2, d2+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, a1, a1+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, e2, e2+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, d2, d2+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, a1, a1+1, 0
	dw $600, $b441
	dw $600, $b401, 0, $2020, c2, c2+1, 0
	dw $600, $b441
	db $40



mdb_Patterns_ptn2

	dw $600, $b404, $4010, a1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, c3, c3+1, 0
	dw $600, $b445
	db $40



mdb_Patterns_ptn3

	dw $600, $b404, $8020, f1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, c3, c3+1, 0
	dw $600, $b445
	db $40



mdb_Patterns_ptn3a

	dw $600, $b404, $8020, f1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $600, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b444, $8020, fis1
	dw $600, $b404, $8020, g1, $10, $2020, c3, c3+1, 0
	dw $600, $b444, $8020, gis1
	db $40



mdb_Patterns_ptn4

	dw $601, $b404, $4010, a1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, e3, e3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, a2, a2+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, d3, d3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, c3, c3+1, 0
	dw $680, $b445
	db $40



mdb_Patterns_ptn4a

	dw $601, $b404, $4010, a1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, e3, e3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, a2, a2+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, d3, d3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b444, $4010, gis1
	dw $680, $b404, $4010, g1, $10, $2020, c3, c3+1, 0
	dw $680, $b444, $4010, fis1
	db $40



mdb_Patterns_ptn5

	dw $601, $b404, $8020, f1, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, e3, e3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, d3, d3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, a2, a2+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, e3, e3+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, d3, d3+1, 0
	dw $680, $b445
	dw $601, $b405, $10, $2020, a2, a2+1, 0
	dw $600, $b445
	dw $680, $b405, $10, $2020, c3, c3+1, 0
	dw $680, $b445
	db $40



mdb_Patterns_ptn5a

	dw $601, $ac04, $8020, f1, $10, $2020, a2, a2+1, $1000
	dw $600, $ac45
	dw $680, $ac05, $10, $2020, e3, e3+1, $1000
	dw $680, $ac45
	dw $601, $ac05, $10, $2020, d3, d3+1, $1000
	dw $600, $ac45
	dw $680, $ac05, $10, $2020, a2, a2+1, $1000
	dw $680, $ac45
	dw $601, $ac05, $10, $2020, e3, e3+1, $1000
	dw $600, $ac45
	dw $680, $ac05, $10, $2020, d3, d3+1, $1000
	dw $680, $ac45
	dw $601, $ac05, $10, $2020, a2, a2+1, $1000
	dw $600, $ac44, $8020, fis1
	dw $680, $ac04, $8020, g1, $10, $2020, c3, c3+1, $1000
	dw $680, $ac44, $8020, gis1
	db $40




;loops2:	ld 	a, ($68ef)	; press <space> to continue
;		and	$10
;		jr 	nz, loops2
