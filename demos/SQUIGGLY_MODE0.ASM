; VZ SQUIG - 
;
; SQ1B	: MODE 0 attempt
; 
;
;
base_graphics EQU $7000

	ORG $8000




loop00:	
	ld	hl, $7000	; MODE(1) CLS
	ld	de, $7001
	ld	a, 128
	ld	(hl), a
	ld	(de), a
	ld	bc, 512
	ldir


	
	ld	l, 24		; X = 64
	ld	h, 8		; y = 32

sloop0:	
	call	vz_rand4		; OUTPUT is in REG A.
	ld	b, a	

;> To compare stuff, simply do a CP, 
;> if the zero flag is set, A and the argument were equal, 
;> if the carry is set the argument was greater, 
;> if neither is set, then A must be greater 

	ld	a, b
	cp	192		; Is 192 or greater?
	jp	nc, shere1	; Then jump!
	ld	a, b
	cp	128		; Is 128 or greater (128 to 191?)
	jp	nc, shere2	; Then jump!
	ld	a, b
	cp	64		; Is 64 to 127?	
	jp	nc, shere3	; Then jump!
	jp	shere4		; Must be 0 to 63 then, so go here!



	jp	sloop0		; Should not really ever get to here
	

shere1:	inc	l		; L = X		H = Y
	ld	a, l		; This all INC or DEC both X,Y
	cp	32		; Then checks if in bounds
	jr	nz, shere5	; INC X
shere1a:dec	l		; If X = 126 then X=126 etc
	jp	shere5
shere2:	dec	l		; INC Y
	ld	a, l		; IF Y = 1 then Y=1
	cp	0
	jr	nz, shere5
shere2a:inc	l
	jp	shere5
shere3:	inc	h		; H = Y
	ld	a, h
	cp	16
	jr	nz, shere5
shere3a:dec	h

	jp	shere5
shere4:	dec	h
	ld	a, h
	cp	0
	jr	nz, shere5
shere4a:	inc	h
	jp	shere5
shere5:

	ld	(array100), hl

	ld	hl, (array0)
	ld	c, 128				; blank !!, or COLOR 0
	call	vz_plot1
	
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



;	black = 128	white   = 207
;	green = 143	cyan    = 223
; 	yellow= 159	magenta = 239
;	blue  = 175	buff    = 255
;	red   = 191


	ld	hl, (array1)
	ld	c, 128			; COLOR 1
	call	vz_plot1
	ld	hl, (array2)
	call	vz_plot1
	ld	hl, (array3)
	call	vz_plot1
	ld	hl, (array4)
	call	vz_plot1
	ld	hl, (array5)
	call	vz_plot1
	ld	hl, (array6)
	call	vz_plot1
	ld	hl, (array7)
	call	vz_plot1
	ld	hl, (array8)
	call	vz_plot1
	ld	hl, (array9)
	call	vz_plot1
	ld	hl, (array10)
	call	vz_plot1
	ld	hl, (array11)
	call	vz_plot1
	ld	c, 143			; COLOR 1
	call	vz_plot1
	ld	hl, (array11)
	call	vz_plot1
	ld	hl, (array12)
	call	vz_plot1
	ld	hl, (array13)
	call	vz_plot1
	ld	hl, (array14)
	call	vz_plot1
	ld	hl, (array15)
	call	vz_plot1
	ld	hl, (array16)
	call	vz_plot1
	ld	hl, (array17)
	call	vz_plot1
	ld	hl, (array18)
	call	vz_plot1
	ld	hl, (array19)
	call	vz_plot1
	ld	hl, (array20)
	call	vz_plot1
	ld	hl, (array21)
	call	vz_plot1
	ld	hl, (array22)
	call	vz_plot1
	ld	c, 159
	ld	hl, (array23)
	call	vz_plot1
	ld	hl, (array24)
	call	vz_plot1
	ld	hl, (array25)
	call	vz_plot1
	ld	hl, (array26)
	call	vz_plot1
	ld	hl, (array27)
	call	vz_plot1
	ld	hl, (array28)
	call	vz_plot1
	ld	hl, (array29)
	call	vz_plot1
	ld	hl, (array30)
	call	vz_plot1
	ld	hl, (array31)
	call	vz_plot1
	ld	hl, (array32)
	call	vz_plot1
	ld	hl, (array33)
	ld	c, 175			; COLOR 2
	call	vz_plot1
	ld	hl, (array34)
	call	vz_plot1
	ld	hl, (array35)
	call	vz_plot1
	ld	hl, (array36)
	call	vz_plot1
	ld	hl, (array37)
	call	vz_plot1
	ld	hl, (array38)
	call	vz_plot1
	ld	hl, (array39)
	call	vz_plot1
	ld	hl, (array40)
	call	vz_plot1
	ld	hl, (array41)
	call	vz_plot1
	ld	hl, (array42)
	call	vz_plot1
	ld	hl, (array43)
	call	vz_plot1
	ld	hl, (array44)
	call	vz_plot1
	ld	hl, (array45)
	call	vz_plot1
	ld	hl, (array46)
	call	vz_plot1
	ld	hl, (array47)
	call	vz_plot1
	ld	hl, (array48)
	call	vz_plot1
	ld	hl, (array49)
	call	vz_plot1
	ld	hl, (array50)
	call	vz_plot1

	ld	hl, (array51)
	ld	c, 191			; COLOR 2
	call	vz_plot1
	ld	hl, (array52)
	call	vz_plot1
	ld	hl, (array53)
	call	vz_plot1
	ld	hl, (array54)
	call	vz_plot1
	ld	hl, (array55)
	call	vz_plot1
	ld	hl, (array56)
	call	vz_plot1
	ld	hl, (array57)
	call	vz_plot1
	ld	hl, (array58)
	call	vz_plot1
	ld	hl, (array59)
	call	vz_plot1
	ld	hl, (array60)
	call	vz_plot1
	ld	hl, (array61)
	call	vz_plot1

	ld	hl, (array100)
	ld	c, 191			; COLOR 3
	call	vz_plot1



	jp	sloop0




array0	DW	96
array1	DW	96
array2	DW	96
array3	DW	96
array4	DW	96
array5	DW	96
array6	DW	96
array7	DW	96
array8	DW	96
array9	DW	96
array10	DW	96
array11	DW	96
array12	DW	96
array13	DW	96
array14	DW	96
array15	DW	96
array16	DW	96
array17	DW	96
array18	DW	96
array19	DW	96
array20	DW	96
array21	DW	96
array22	DW	96
array23	DW	96
array24	DW	96
array25	DW	96
array26	DW	96
array27	DW	96
array28	DW	96
array29	DW	96
array30	DW	96
array31	DW	96
array32	DW	96
array33	DW	96
array34	DW	96
array35	DW	96
array36	DW	96
array37	DW	96
array38	DW	96
array39	DW	96
array40	DW	96
array41	DW	96
array42	DW	96
array43	DW	96
array44	DW	96
array45	DW	96
array46	DW	96
array47	DW	96
array48	DW	96
array49	DW	96
array50 DW	96
array51	DW	96
array52	DW	96
array53	DW	96
array54	DW	96
array55	DW	96
array56	DW	96
array57	DW	96
array58	DW	96
array59	DW	96
array60	DW	96
array61	DW	96
array62	DW	96
array63	DW	96
array64	DW	96
array65	DW	96
array66	DW	96
array67	DW	96
array68	DW	96
array69	DW	96
array70	DW	96
array71	DW	96
array72	DW	96
array73	DW	96
array74	DW	96
array75	DW	96
array76	DW	96
array77	DW	96
array78	DW	96
array79	DW	96
array80	DW	96
array81	DW	96
array82	DW	96
array83	DW	96
array84	DW	96
array85	DW	96
array86	DW	96
array87	DW	96
array88	DW	96
array89	DW	96
array90	DW	96
array91	DW	96
array92	DW	96
array93	DW	96
array94	DW	96
array95	DW	96
array96	DW	96
array97	DW	96
array98	DW	96
array99	DW	96
array100 DW	96

;==================================================
vz_plot1:
; 	c = colour
;	l = X
; 	h = Y

	push	bc
	push	de
	push	hl
	push	af
        ld      a, l            ; get x
	ld	l, h
	ld	h, 0		; move 8bit A into 16bit HL for multiplying by 32.
 	ADD 	HL, HL	;\
  	ADD 	HL, HL	; \
  	ADD 	HL, HL 	;  | 	; HL = HL * 32
  	ADD 	HL, HL	; /
  	ADD 	HL, HL	;/	; Y=Y*32  or  :  hl=h*32
	ld	d, 0
	ld	e, a
	add	hl, de		; ADD X offset
	ld	de, $7000
	add	hl, de
	ld	a, c
        ld      (hl), a
	pop	af
	pop	hl
	pop	de
	pop	bc
	ret

; -----------------------------------------------------------

vz_rand4:               ;cycle: 4,294,901,760 (almost 43 billion)
;Outputs:		A: 0-255.
	push	hl
	push	bc
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
	pop	bc
	pop	hl
	ret

seed1	DB 1234
seed2	DB 5678

END
