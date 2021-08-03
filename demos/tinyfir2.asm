;	Fire routine
;	http://z80-heaven.wikidot.com/forum/t-675609/fire-animation-tutorial
;

	org	$8000

buffer	equ	$c000

	di			;disabled interrupts. We go faster disabling keyboard and other stuff.
	ld	a, $fe		;value for German SHRG black on white. Use $ for dark green on light green.
	ld	($6800), a	;write to Video Latch.
	ld	(30779), a	;and write to copy of video latch.

	ld	hl, buffer	; intial CLS.
	ld	de, buffer+1
	ld	(hl), 0
	ld	bc, 2048
	ldir

Main:  	ld 	bc, $c004    	;we are going to read through 512 bytes worth of the screen at a time
     	ld 	de, buffer+32	;DE points to second row of the vid buffer
Loop:	call	random		;Returns A=RND(8)
     	ld 	hl, table     	;Lookup table for pixel masking.
     	add	a, l       	;Get table offset
     	ld 	l, a        	;re-setup HL
     	jr 	nc, $+3     	;
     	inc 	h         	;
     	ld 	a, (hl)     	;Load mask value into reg A.
     	ld 	hl, 32      	;Load 32 into HL for below line.
     	add 	hl, de     	;HL points to the byte that we want to read, and DE is HL-32... the row above.
     	or	(hl)      	;Mask the pixel value in A with the pixel above. This creates the fading effect.
      	ld 	(de), a     	;Write the new pixel to the line above.
     	inc 	de       	;Above pxiel : Go to the next pixel along
     	djnz 	Loop     	;Inside loop "Counter A" - loop 192 times.
     	dec 	c         	;decrement Counter B
     	jr 	nz, Loop    	;Outside loop "Counter B" - Loop 4 times.  4 * 192 loops is enough for our 512 bytes.
	ld	hl, buffer	;DE above was pointing to the buffer for writing. Now HL is in order to write the buffer to video.
	ld	de, $7000	;DE now points to Video output
	ld	bc, 2048	;...and set BC to the video size (2k) to do a single blit. 
	ldir			;Blit!
     	jp 	Main    	;Jump back to main.



random:	ld 	a, r
	rrca
	rrca
	neg
seed 	equ $ + 1
	xor 0
	rrca
	ld 	(seed),a
     	and 	7         		;mask A with 7 to get a range of 0 TO 7. 8 offsets.
	ret
	


table:	defb	 %00000001	; 016
	defb 	 %00000010
	defb 	 %00000100
	defb 	 %00001000
	defb 	 %00010000
	defb 	 %00100000
	defb 	 %01000000
	defb 	 %10000000
