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

;	ld	c, 3		; Show in RED, four corners
;	ld	l, 0
;	ld	h, 0
;	call	vz_plot1
;	ld	l, 127
;	ld	h, 0
;	call	vz_plot1
;	ld	l, 127
;	ld	h, 63
;	call	vz_plot1
;	ld	l, 0
;	ld	h, 63
;	call	vz_plot1
	
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

	ld	(array100), hl

	ld	hl, (array0)
	ld	c, 0
	call	vz_plot2
	
	ld	de, (array1)
	ld	(array0), de
	ld	de, (array2)
	ld	(array1), de
	ld	de, (array3)
	ld	(array2), de
	ld	de, (array4)
	ld	(array3), de
	ld	de, (array5)
	ld	(array4), de
	ld	de, (array6)
	ld	(array5), de
	ld	de, (array7)
	ld	(array6), de
	ld	de, (array8)
	ld	(array7), de
	ld	de, (array9)
	ld	(array8), de
	ld	de, (array10)
	ld	(array9), de
	ld	de, (array11)
	ld	(array10), de
	ld	de, (array12)
	ld	(array11), de
	ld	de, (array13)
	ld	(array12), de
	ld	de, (array14)
	ld	(array13), de
	ld	de, (array15)
	ld	(array14), de
	ld	de, (array16)
	ld	(array15), de
	ld	de, (array17)
	ld	(array16), de
	ld	de, (array18)
	ld	(array17), de
	ld	de, (array19)
	ld	(array18), de
	ld	de, (array20)
	ld	(array19), de
	ld	de, (array21)
	ld	(array20), de
	ld	de, (array22)
	ld	(array21), de
	ld	de, (array23)
	ld	(array22), de
	ld	de, (array24)
	ld	(array23), de
	ld	de, (array25)
	ld	(array24), de
	ld	de, (array26)
	ld	(array25), de
	ld	de, (array27)
	ld	(array26), de
	ld	de, (array28)
	ld	(array27), de
	ld	de, (array29)
	ld	(array28), de
	ld	de, (array30)
	ld	(array29), de
	ld	de, (array31)
	ld	(array30), de
	ld	de, (array32)
	ld	(array31), de
	ld	de, (array33)
	ld	(array32), de
	ld	de, (array34)
	ld	(array33), de
	ld	de, (array35)
	ld	(array34), de
	ld	de, (array36)
	ld	(array35), de
	ld	de, (array37)
	ld	(array36), de
	ld	de, (array38)
	ld	(array37), de
	ld	de, (array39)
	ld	(array38), de
	ld	de, (array40)
	ld	(array39), de
	ld	de, (array41)
	ld	(array40), de
	ld	de, (array42)
	ld	(array41), de
	ld	de, (array43)
	ld	(array42), de
	ld	de, (array44)
	ld	(array43), de
	ld	de, (array45)
	ld	(array44), de
	ld	de, (array46)
	ld	(array45), de
	ld	de, (array47)
	ld	(array46), de
	ld	de, (array48)
	ld	(array47), de
	ld	de, (array49)
	ld	(array48), de
	ld	de, (array50)
	ld	(array49), de
	ld	de, (array51)
	ld	(array50), de
	ld	de, (array52)
	ld	(array51), de
	ld	de, (array53)
	ld	(array52), de
	ld	de, (array54)
	ld	(array53), de
	ld	de, (array55)
	ld	(array54), de
	ld	de, (array56)
	ld	(array55), de
	ld	de, (array57)
	ld	(array56), de
	ld	de, (array58)
	ld	(array57), de
	ld	de, (array59)
	ld	(array58), de
	ld	de, (array60)
	ld	(array59), de
	ld	de, (array61)
	ld	(array60), de
	ld	de, (array62)
	ld	(array61), de
	ld	de, (array63)
	ld	(array62), de
	ld	de, (array64)
	ld	(array63), de
	ld	de, (array65)
	ld	(array64), de
	ld	de, (array66)
	ld	(array65), de
	ld	de, (array67)
	ld	(array66), de
	ld	de, (array68)
	ld	(array67), de
	ld	de, (array69)
	ld	(array68), de
	ld	de, (array70)
	ld	(array69), de
	ld	de, (array71)
	ld	(array70), de
	ld	de, (array72)
	ld	(array71), de
	ld	de, (array73)
	ld	(array72), de
	ld	de, (array74)
	ld	(array73), de
	ld	de, (array75)
	ld	(array74), de
	ld	de, (array76)
	ld	(array75), de
	ld	de, (array77)
	ld	(array76), de
	ld	de, (array78)
	ld	(array77), de
	ld	de, (array79)
	ld	(array78), de
	ld	de, (array80)
	ld	(array79), de
	ld	de, (array81)
	ld	(array80), de
	ld	de, (array82)
	ld	(array81), de
	ld	de, (array83)
	ld	(array82), de
	ld	de, (array84)
	ld	(array83), de
	ld	de, (array85)
	ld	(array84), de
	ld	de, (array86)
	ld	(array85), de
	ld	de, (array87)
	ld	(array86), de
	ld	de, (array88)
	ld	(array87), de
	ld	de, (array89)
	ld	(array88), de
	ld	de, (array90)
	ld	(array89), de
	ld	de, (array91)
	ld	(array90), de
	ld	de, (array92)
	ld	(array91), de
	ld	de, (array93)
	ld	(array92), de
	ld	de, (array94)
	ld	(array93), de
	ld	de, (array95)
	ld	(array94), de
	ld	de, (array96)
	ld	(array95), de
	ld	de, (array97)
	ld	(array96), de
	ld	de, (array98)
	ld	(array97), de
	ld	de, (array99)
	ld	(array98), de
	ld	de, (array100)
	ld	(array99), de

	ld	hl, (array33)
	ld	c, 1
	call	vz_plot2

	ld	hl, (array66)
	ld	c, 2
	call	vz_plot2

	ld	hl, (array100)
	ld	c, 3
	call	vz_plot2



	jp	loop0




array0	DW	0
array1	DW	0
array2	DW	0
array3	DW	0
array4	DW	0
array5	DW	0
array6	DW	0
array7	DW	0
array8	DW	0
array9	DW	0
array10	DW	0
array11	DW	0
array12	DW	0
array13	DW	0
array14	DW	0
array15	DW	0
array16	DW	0
array17	DW	0
array18	DW	0
array19	DW	0
array20	DW	0
array21	DW	0
array22	DW	0
array23	DW	0
array24	DW	0
array25	DW	0
array26	DW	0
array27	DW	0
array28	DW	0
array29	DW	0
array30	DW	0
array31	DW	0
array32	DW	0
array33	DW	0
array34	DW	0
array35	DW	0
array36	DW	0
array37	DW	0
array38	DW	0
array39	DW	0
array40	DW	0
array41	DW	0
array42	DW	0
array43	DW	0
array44	DW	0
array45	DW	0
array46	DW	0
array47	DW	0
array48	DW	0
array49	DW	0
array50	DW	0
array51	DW	0
array52	DW	0
array53	DW	0
array54	DW	0
array55	DW	0
array56	DW	0
array57	DW	0
array58	DW	0
array59	DW	0
array60	DW	0
array61	DW	0
array62	DW	0
array63	DW	0
array64	DW	0
array65	DW	0
array66	DW	0
array67	DW	0
array68	DW	0
array69	DW	0
array70	DW	0
array71	DW	0
array72	DW	0
array73	DW	0
array74	DW	0
array75	DW	0
array76	DW	0
array77	DW	0
array78	DW	0
array79	DW	0
array80	DW	0
array81	DW	0
array82	DW	0
array83	DW	0
array84	DW	0
array85	DW	0
array86	DW	0
array87	DW	0
array88	DW	0
array89	DW	0
array90	DW	0
array91	DW	0
array92	DW	0
array93	DW	0
array94	DW	0
array95	DW	0
array96	DW	0
array97	DW	0
array98	DW	0
array99	DW	0
array100 DW	0

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