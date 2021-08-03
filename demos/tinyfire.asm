;	Fire routine
;	http://z80-heaven.wikidot.com/forum/t-675609/fire-animation-tutorial
;

	org	$8000

buffer	equ	$c000

	di
	ld	a, $fe
	ld	($6800), a
	ld	(30779), a

	ld	de, buffer+1
	ld	hl, buffer	
	ld	(hl), 0
	ld	bc, 2048
	ldir

Main:
     	ld 	bc, $c004    ;$F403   ;10    ;B = 244, C = 3
 	 		     		;10    ;we are going to read through 756 bytes worth of the screen at a time
     	ld 	de, buffer+32	 	;14    ;IX points to row 1 of the graph buffer
Loop:	call	rnd2
     	ld 	hl, LUT     		;10    ;This is our LUT for the pixel mask.

     	and 	7         		;7     ;mask it with %00000111 to get it in the range of 000 to 111 (0 to 7)
     	add	a, l       		;4
     	ld 	l, a        		;4
     	jr 	nc, $+3     		;12|11
     	inc 	h         		;--
     	ld 	a, (hl)     		;7
     	ld 	hl, 32;12      		;10
     	add 	hl, de     		;11     ;Now HL points to the byte that we want to read, and DE is HL-12... the row above!
     	or	(hl)      		;7
 
     	ld 	(de), a     		;7
     	inc 	de       		;6
     	djnz 	Loop     		;13|8
     	dec 	c         		;4
     	jr 	nz, Loop    		;12|7

	ld	bc, 2048
	ld	hl, buffer
	ld	de, $7000
	ldir

     	jp 	Main    		;12|7




rnd2:	ld 	a, r
	rrca
	rrca
	neg
seed2 equ $ + 1
	xor 0
	rrca
	ld 	(seed2),a
	ret
	



rnd:	push	hl
	push	de
	push	bc
        ld hl,LFSRSeed+4
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld c,(hl)
        inc hl
        ld a,(hl)
        ld b,a
        rl e 
	rl d
        rl c 
	rla
        rl e 
	rl d
        rl c
	rla
        rl e
	rl d
        rl c 
	rla
        ld h,a
        rl e 
	rl d
        rl c 
	rla
        xor b
        rl e 
	rl d
        xor h
        xor c
        xor d
        ld hl,LFSRSeed+6
        ld de,LFSRSeed+7
        ld bc,7
        lddr
        ld (de),a
	pop	bc
	pop	de
	pop	hl
        ret

LFSRSeed defb $11,$22,$33,$44,$55,$66,$77,$88,$99$,00



	shp equ 15

LUT:	defb	 %00000001	; 016
	defb 	 %00000010
	defb 	 %00000100
	defb 	 %00001000
	defb 	 %00010000
	defb 	 %00100000
	defb 	 %01000000
	defb 	 %10000000
