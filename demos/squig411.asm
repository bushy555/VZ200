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

	ld	c, 3		; Show in RED, four corners
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

loop0:	
	call	vz_rand4
	ld	b, a	

;> To compare stuff, simply do a CP, 
;> if the zero flag is set, A and the argument were equal, 
;> if the carry is set the argument was greater, 
;> if neither is set, then A must be greater 

	ld	a, b
	cp	192		; Is 192 or greater?
	jp	nc, here1	; Then jump!
	ld	a, b
	cp	128		; Is 128 or greater (128 to 191?)
	jp	nc, here2	; Then jump!
	ld	a, b
	cp	64		; Is 64 to 127?	
	jp	nc, here3	; Then jump!
	jp	here4		; Must be 0 to 63 then, so go here!



	jp	loop0		; Should not really ever get to here
	

here1:	inc	l		; L = X		H = Y
	ld	a, l		; This all INC or DEC both X,Y
	cp	126		; Then checks if in bounds
	jr	nz, here5	; INC X
here1a:	dec	l		; If X = 126 then X=126 etc
	jp	here5
here2:	dec	l		; INC Y
	ld	a, l		; IF Y = 1 then Y=1
	cp	1
	jr	nz, here5
here2a:	inc	l

	jp	here5
here3:	inc	h		; H = Y
	ld	a, h
	cp	62
	jr	nz, here5
here3a:	dec	h

	jp	here5
here4:	dec	h
	ld	a, h
	cp	1
	jr	nz, here5
here4a:	inc	h
	jp	here5
here5:

	ld	de, (array5)
	ld	(array4), de
	ld	de, (array4)
	ld	(array3), de
	ld	de, (array3)
	ld	(array2), de
	ld	de, (array2)
	ld	(array1), de
	ld	de, (array1)
	ld	(array0), de
	ld	(array5), hl


	
	ld	c, 2
	call	vz_plot2

	
	ld	hl, (array0)


	ld	c, 0
	call	vz_plot2


	jp	loop0




array0	DW	0
array1	DW	0
array2	DW	0
array3	DW	0
array4	DW	0
array5	DW	0

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
   ld	a,c
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
;	ld a, 255
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

vz_rand3:
;out:
; a = 8 bit random number
RandLFSR:
	push	hl
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

LFSRSeed DB $11,$22,$33,$44,$55,$66,$77,$88,$99$,00


vz_rand4:
;   (seed1) contains a 16-bit seed value
;   (seed2) contains a NON-ZERO 16-bit seed value
;Outputs:
;   HL is the result
;   BC is the result of the LCG, so not that great of quality
;   DE is preserved
;Destroys:
;   AF
;cycle: 4,294,901,760 (almost 43 billion)
;160cc
;26 bytes
	push	hl
	push	bc
	push	de
	
    ld hl,(seed1)
    ld b,h
    ld c,l
    add hl,hl
    add hl,hl
    inc l
    add hl,bc
    ld (seed1),hl
    ld hl,(seed2)
    add hl,hl
    sbc a,a
    and %00101101
    xor l
    ld l,a
    ld (seed2),hl
    add hl,bc
	
	ld	a, l
	pop	de
	pop	bc
	pop	hl
	ret

seed1	DB 1234
seed2	DB 5678

END