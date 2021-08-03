	ORG 	$8000
	ld 	a,8		; mode (1)
	ld 	($6800),a
loop00:	ld	hl, $7000	; clear mode(1) screen
	ld	de, $7001
	xor	a
	ld	(hl), a
	ld	bc, 2048
	ldir
	ld	c, 3		; Show in RED
	ld	l, 64		; X = 64
	ld	h, 32		; y = 32
loop0:	push    hl		
rando equ $+1
        ld      hl,23		; random number generator
        ld      a,r
        ld      d,a
        ld      e,(hl)
        add     hl,de
        add     a,l
        xor     h
	ld 	(rando), hl
	ld	a, l		; a = RND(255)
        pop     hl

	cp	192		; Is 192 or greater?
	jp	nc, here2	; Then jump!
	cp	128		; Is 128 or greater (128 to 191?)
	jp	nc, here3	; Then jump!
	cp	64		; Is 64 to 127?	
	jp	nc, here4	; Then jump!
	
	inc	l		; L = X		H = Y
	ld	a, l		; This all INC or DEC both X,Y
	cp	126		; Then checks if in bounds.
	jr	nz, here5	; INC X. If X = 126 then X=126 etc.
	dec	l
	jp	here5
here2:	dec	l		; INC Y
	ld	a, l		; IF Y = 1 then Y=1.
	cp	1
	jr	nz, here5
	inc	l
	jp	here5
here3:	inc	h		; H = Y
	ld	a, h
	cp	62		; IF Y=62 then y=62
	jr	nz, here5
	dec	h
	jp	here5
here4:	dec	h
	ld	a, h
	cp	1		; IF y=1 then y=1
	jr	nz, here5
	inc	h
here5:
vz_plot1:push	bc	; c=colour, SET(L,H)  ie: H=Y, L=X
	push	hl	; 	
        ld      a, l    ; get x
        sla     l       ; calculate screen offset
        srl     h
        rr      l
        srl     h
        rr      l
        srl     h
        rr      l
        and     $3              ; pixel offset
        inc     a
        ld      b, %11111100
pset3:  rrc     b
        rrc     b
        rrc     c
        rrc     c
        dec     a
        jr      nz, pset3
	ld	de, $7000
	add	hl, de
        ld      a, (hl)
        and     b
        or      c
        ld      (hl), a		; SET(X,Y) pixel
	pop	hl
	pop	bc
	jp	loop0		; jump back for another shot
