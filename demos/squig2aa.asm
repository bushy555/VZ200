; VZ SQUIG - MODE 1
; 
;
;
base_graphics EQU $7000

	ORG $8000



	ld 	a,8			; mode (1)
	ld 	($6800),a

loop00:	
	ld	hl, $7000	; MODE(1) CLS
	ld	de, $7001
	ld	a, 0
	ld	(hl), a
	ld	(de), a
	ld	bc, 2048
	ldir

	ld	c, 2		; Show in RED, four corners
	ld	l, 0
	ld	h, 0
	call	vz_plot1
	ld	l, 127
	ld	h, 0
	call	vz_plot1
	ld	l, 127
	ld	h, 63
	call	vz_plot1
	ld	l, 0
	ld	h, 63
	call	vz_plot1
	
	ld	l, 64		; X = 64
	ld	h, 32		; y = 32

loop0:	;call	vz_rand2
	call	vz_rand
;> To compare stuff, simply do a CP, 
;> if the zero flag is set, A and the argument were equal, 
;> if the carry is set the argument was greater, 
;> if neither is set, then A must be greater 

	cp	192		; Is 192 or greater?
	jp	nc, here1	; Then jump!
	cp	128		; Is 128 or greater (128 to 191?)
	jp	nc, here2	; Then jump!
	cp	64		; Is 64 to 127?	
	jp	nc, here3	; Then jump!
	jp	here4		; Must be 0 to 63 then, so go here!

	jp	loop0		; Should not really ever get to here
	

here1:	inc	l		; L = X		H = Y
	ld	a, l		; This all INC or DEC both X,Y
	cp	126		; Then checks if in bounds
	jr	z, here1a	; INC X
	jp	here5		; If X = 126 then X=126 etc
here1a:	dec	l
	jp	here5
here2:	dec	l		; INC Y
	ld	a, l		; IF Y = 1 then Y=1
	cp	1
	jr	z, here2a
	jp	here5
here2a:	inc	l
	jp	here5
here3:	inc	h		; H = Y
	ld	a, h
	cp	62
	jr	z, here3a
	jp	here5
here3a:	dec	h
	jp	here5
here4:	dec	h
	ld	a, h
	cp	1
	jr	z, here4a
	jp	here5
here4a:	inc	h
	jp	here5
here5:

;	ld	l, d
;	ld	h, e
	call	vz_plot1

	jp	loop0




;==================================================
vz_plot1:
; 	c = colour
;	l = X
; 	h = Y

pset4:  

	push	bc
	push	de
	push	hl
	push	af
        ld      a, l            ; get x
        sla     l               ; calculate screen offset
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
        ld      (hl), a
	pop	af
	pop	hl
	pop	de
	pop	bc
	ret

; -----------------------------------------------------------

vz_plot2:
   ; l = x
   ; h = y
   ; c = colour

asmentry

	push	hl
	push	de
	push	af
	push	bc
;   ld	a,c
   and 3
   ld	c,a

   ld a,h
   cp 64
   ret nc
   
   ld a,l
   cp 128
   ret nc

   sla l                     ; calculate screen offset
   srl h
   rr l
   srl h
   rr l
   srl h
   rr l
   
   and $03                   ; pixel offset   
   inc a
   ld b,a
   
   ld a,$fc

pset1

   rrca
   rrca
   rrc c
   rrc c
   djnz pset1

   ld de, $7000
   add hl,de
   and (hl)
   or c
   ld (hl),a
   	pop	bc
	pop	af
	pop	de
	pop	hl
   ret



vz_rand:

;-----> Generate a random number
; output a=answer 0<=a<=255
; all registers are preserved except: af
random:
        push    hl
        push    de
        ld      hl,(randData)
        ld      a,r
        ld      d,a
        ld      e,(hl)
        add     hl,de
        add     a,l
        xor     h
        ld      (randData),hl
	ld	a, l
        pop     de
        pop     hl
        ret

randData DB 23







vz_rand2:
; Fast RND
;
; An 8-bit pseudo-random number generator,
; using a similar method to the Spectrum ROM,
; - without the overhead of the Spectrum ROM
;
; R = random number seed
; an integer in the range [1, 256]
;
; R -> (33*R) mod 257
;
; S = R - 1
; an 8-bit unsigned integer

	push	bc
	push	af

 	ld a, (seed)
 	ld b, a 

 	rrca ; multiply by 32
 	rrca
 	rrca
 	xor $1f
        ld      a,r
	ld	b, a
 	add a, b
 	sbc a, 255 ; carry

 	ld (seed), a
	ld	b, a
	pop	af
	ld	a, b
	pop	bc
 	ret
seed	DB 12
END





;;Constants
;JP NN        	;no condition
;JP C,NN        ;jumps if C is set
;JP NC,NN       ;jumps if C is reset
;JP Z,NN        ;jumps if Z is set
;JP NZ,NN    	;jumps if Z is reset
;JP M,NN        ;jumps if S is set
;JP P,NN        ;jumps if S is reset
;JP PE,NN    	;jumps if P/V is set
;JP PO,NN    	;jumps if P/V is reset


