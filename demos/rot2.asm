
	ORG $8000

	ld 	a,8			; mode (1)
	ld 	($6800),a
loop00:	ld	hl, $7000	; MODE(1) CLS
	ld	de, $7001
	ld	a, 0
	ld	(hl), a
	ld	(de), a
	ld	bc, 2048
	ldir
	ld	hl, $9000	; Screen Buffer 
	ld	de, $9001	; At $9000
	ld	a, 0
	ld	(hl), a
	ld	bc, 1048
	ldir
	ld	bc, 1048
	ldir
go:	ld	ix, 63
	ld	iy, 63
	ld	a, 0		; part 0
	ld	(x1), a
	ld	(y1), a
	ld	(y2), a
	ld	a, 127
	ld	(x2), a
	ld	a, 63
	ld	(x3), a
	ld	(y3), a
	ld	b, 64
l1:	push	bc
	call	chaos
	ld	a, (x2)
	dec	a
	ld	(x2), a
	ld	a, (y1)
	inc	a
	ld	(y1), a
	ld	a, (x3)
	inc	a
	ld	(x3), a
	pop	bc
	djnz	l1
	ld	b, 64		; part 1
l2:	push	bc
	call	chaos
	ld	a, (x2)
	dec	a
	ld	(x2), a
	ld	a, (x1)
	inc	a
	ld	(x1), a
	ld	a, (y3)
	dec	a
	ld	(y3), a
	pop	bc
	djnz	l2
	ld	a, 63		; part 2
	ld	(x1), a
	ld	(y1), a
	ld	a, 0
	ld	(x2), a
	ld	(y2), a
	ld	(y3), a
	ld	a, 127
	ld	(x3), a
	ld	b, 62
l3:	push	bc
	call	chaos
	ld	a, (y2)
	inc	a
	ld	(y2), a
	ld	a, (x1)
	inc	a
	ld	(x1), a
	ld	a, (x3)
	dec	a
	ld	(x3), a
	pop	bc
	djnz	l3
	ld	a, 127		; part 3
	ld	(x1), a
	ld	a, 63
	ld	(y1), a
	ld	(y2), a
	ld	(x3), a
	ld	a, 0
	ld	(x2), a
	ld	(y3), a
	ld	b, 62
l4:	push	bc
	call	chaos
	ld	a, (x2)
	inc	a
	ld	(x2), a
	ld	a, (y1)
	dec	a
	ld	(y1), a
	ld	a, (x3)
	dec	a
	ld	(x3), a
	pop	bc
	djnz	l4
	ld	a, 127		; part 4
	ld	(x1), a
	ld	a, 0
	ld	(y1), a
	ld	(x3), a
	ld	(y3), a
	ld	a, 63
	ld	(x2), a
	ld	(y2), a
	ld	b, 62
l5:	push	bc
	call	chaos
	ld	a, (x2)
	inc	a
	ld	(x2), a
	ld	a, (x1)
	dec	a
	ld	(x1), a
	ld	a, (y3)
	inc	a
	ld	(y3), a
	pop	bc
	djnz	l5
	ld	a, 0		; part 5
	ld	(y1), a
	ld	(x3), a
	ld	a, 127
	ld	(x2), a
	ld	a, 63
	ld	(x1), a
	ld	(y2), a
	ld	(y3), a
	ld	b, 62
l6:	push	bc
	call	chaos
	ld	a, (y2)
	inc	a
	ld	(y2), a
	ld	a, (x1)
	dec	a
	ld	(x1), a
	ld	a, (x3)
	inc	a
	ld	(x3), a
	pop	bc
	djnz	l6

h3:	jp h3

chaos:	ld	b, 20		; Will loop 500+ times
	ld	d, 2
chaos2:	push	bc
	push	de

rand1 equ $+1
	 ld a,$A6
rand2 equ $+1
	 ld hl,$8243
	 inc l
	 dec h
	 add a,(hl)
	 ld (rand2),hl
	 rlca
	 rlca
	 sub h
	 add a,l
	 ld (rand1),a

	cp	85	
	jr	c, next2	; 0,0	-JMP BELOW
	cp	170
	jr	nc, next	;-JMP ABOVE
	ld	bc, (x2)
	add	ix, bc		; 128, 0
	ld	bc, (y2)
	add	iy, bc
	jp	calc
next:	ld	bc, (x3)	; (64, 63)
	add	ix, bc
	ld	bc, (y3)	
	add	iy, bc
	jp	calc
next2:	ld	bc, (x1)	; (0,0)
	add	ix, bc
	ld	bc, (y1)
	add	iy, bc
calc:	ld	a, iyl		; DIV IY /2
	srl	a			
	ld	iyl, a
	ld	h, a
	ld	a, ixl		; DIV IX /2
	srl	a	
	ld	ixl, a
	ld	l, a
	ld	c, 2
   	sla 	l            ; calculate screen offset
   	srl 	h
   	rr 	l
  	srl 	h
   	rr 	l
   	srl 	h
   	rr 	l 
   	and 	$03             ; pixel offset   
   	inc 	a
   	ld 	b,a
   	ld 	a,$fc
pset1: 	rrca
   	rrca
   	rrc 	c
   	rrc 	c
   	djnz pset1
   	ld 	de, $7800
   	add 	hl,de
   	and 	(hl)
   	or 	c
 	ld 	(hl),a	
	pop	de
	pop	bc
	djnz	chaos2
	dec	d
	jp	nz, chaos2

	ld 	hl, $7800	; BLIT FROM $7800 BUffer to screen
	ld	de, $7000
;	ld	bc, 2048
	ld	bc, $8000
a1:	ldi
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
	djnz	a1

	ld	hl, $9000	; MODE(1) CLS BUFFER at $9000
	ld	de, $7800
;	ld	bc, 2048
;	ldir


	ld	bc, $8000
a2:	ldi
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
	djnz	a2

	ret


x1	defw	0
y1	defw	0
x2	defw	127
y2	defw	0
x3	defw	63
y3 	defw	63
