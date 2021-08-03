; MATRIX VZ300
; ==============
;

	ORG	$8000

;0 B=29182:DIMA(13):FORI=1TO13:A(I)=28672+RND(14)*32+RND(32):NEXT 
;1 FORI=RND(3)TORND(3)+4:FORJ=1TORND(8):POKEA(I),RND(63)+64
;2 NEXTJ,I
;3 FORI=1TO7:IFA(I)<B,POKEA(I),RND(63)+64:A(I)=A(I)+32:NEXT:GOTO5
;4 A(I)=28671+RND(32):NEXT 
;5 FORI=8TO12:IFA(I)<B,POKEA(I),96:A(I)=A(I)+32:NEXT:GOTO1
;6 A(I)=28671+RND(32):NEXT:GOTO3


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;Clear screen
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	ld	hl, $7000	; CLEAR SCREEN 
	ld	de, $7001
	ld	(hl), 96
	ld	bc, 2048
	ldir
	di
	
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
line0:	;0 B=29182:DIMA(13):FORI=1TO13:A(I)=28672+RND(14)*32+RND(32):NEXT 
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	call	load_1
	ld	(a1), hl
	call	load_1
	ld	(a2), hl
	call	load_1
	ld	(a3), hl
	call	load_1
	ld	(a4), hl
	call	load_1
	ld	(a5), hl
	call	load_1
	ld	(a6), hl
	call	load_1
	ld	(a7), hl
	call	load_1
	ld	(a8), hl
	call	load_1
	ld	(a9), hl
	call	load_1
	ld	(a10), hl
	call	load_1
	ld	(a11), hl
	call	load_1
	ld	(a12), hl
	call	load_1
	ld	(a13), hl
	call	load_1
	ld	(a14), hl
	jp	here2

load_1:	ld	hl, $7000
	ld	d, 0
	call	random
	ld	e, a
	add	hl, de
	call	random
	ld	D, 0
	ld	e, a
	add	hl, de
	ret
	
here2:


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
line1:	;1 FORI=RND(3)TORND(3)+4:FORJ=1TORND(8):POKEA(I),RND(63)+64:NEXTJ,I
;   For the first random amount of entries (I), display a random amount of chars (j=1to RND(8)) on screen.
;   First initial funky bit of the display. loop thru a bunch of chars before picking one legit char and sticking to it.
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;	call 	random		; select 0-255 number of times to display random chars.
	ld	b, 55
loop1b:	call	random127		; select random char to display.
	ld	de, (a1)
	ld	(de), a	
	djnz	loop1b
	
;	call 	random
	ld	b, 55
loop2b:	call	random127
	ld	de, (a2)
	ld	(de), a	
	djnz	loop2b

	call 	random
	ld	b, a
loop3b:	call	random127
	ld	de, (a3)
	ld	(de), a	
	djnz	loop3b


	call 	random
	ld	b, a
loop4b:	call	random127
	ld	de, (a4)
	ld	(de), a	
	djnz	loop4b

	call 	random
	ld	b, a
loop5b:	call	random127
	ld	de, (a5)
	ld	(de), a	
	djnz	loop5b

	call 	random
	ld	b, a
loop6b:	call	random127
	ld	de, (a6)
	ld	(de), a	
	djnz	loop6b

	call 	random
	ld	b, a
loop7b:	call	random127
	ld	de, (a7)
	ld	(de), a	
	djnz	loop7b



;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
line3:	;3 B=29182:FORI=1TO7:IFA(I)<B,POKEA(I),RND(63)+64:A(I)=A(I)+32:NEXT:GOTO5
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;=========================================================================
;Comapre DE & HL registers pairs
;
;RST $18 may be used to call a routine wihch compares the contents of the DE and HL reg pairs.
;Routine uses the A register only, but will work for unsigned or positive numbers . 
;Upon returning, the result of the comparison will be in the status register
;HL<DE 		: carry set
;HL > DE 	: no carry
;HL <> DE 	: NZ
;HL=DE 		: Z
;
;LD 	HL, 500
;RST 	$18
;JR 	C, err		carry means num > 500
;LD 	HL, 100
;RST	$18		
;JR	NC, ERR		no carry means num < 100
;....			if here,, must be ok
;
;=========================================================================
;
;


	ld	hl, (a1)
	ld	ix, a1
	ld	de, 29182
	rst	$18
	jr	c, loop8
	call	line4
	jp	line3a
loop8:	call	random63_2
	ld	(a1), hl
;	jp	line5

line3a:	ld	hl, (a2)
	ld	ix, a2
	ld	de, 29182
	rst	$18
	jr	c, loop9
	call	line4
	jp	line3b
loop9:	call	random63_2
	ld	(a2), hl
;	jp	line5

line3b:	ld	hl, (a3) 
	ld	ix, a3
	ld	de, 29182
	rst	$18
	jr	c, loop10
	call	line4
	jp	line3c
loop10:	call	random63_2
	ld	(a3), hl
;	jp	line5

line3c:	ld	hl, (a4)
	ld	ix, a4
	ld	de, 29182
	rst	$18
	jr	c, loop11
	call	line4
	jp	line3d
loop11:	call	random63_2
	ld	(a4), hl
;	jp	line5

line3d:	ld	hl, (a5)
	ld	ix, a5
	ld	de, 29182
	rst	$18
	jr	c, loop12
	call	line4
	jp	line3e
loop12:	call	random63_2
	ld	(a5), hl
;	jp	line5

line3e:	ld	hl, (a6)
	ld	ix, a6
	ld	de, 29182
	rst	$18
	jr	c, loop13
	call	line4
	jp	line3f
loop13:	call	random63_2
	ld	(a6), hl
;	jp	line5

line3f:	ld	hl, (a7)
	ld	ix, a7
	ld	de, 29182
	rst	$18
	jr	c, loop14
	call	line4
	jp	line3g
loop14:	call	random63_2
	ld	(a7), hl
;	jp	line5
	

line3g:	jp 	line5

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
line4:	;4 A(I)=28671+RND(32):NEXT 
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loop15:	call	random
	ld	b, 0
	ld	c, a
	ld	hl, 28672
	add	hl, bc
	ld	(ix), l
	ld	(ix+1), h

	ret

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
line5:	;5 FORI=8TO12:IFA(I)<B,POKEA(I),96:A(I)=A(I)+32:NEXT:GOTO1
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	ld	hl, (a8)
	ld	ix, a8
	ld	de, 29182
	rst	$18
	jr	c, loop5a1
	call	line4
	jp	line5b1
loop5a1:ld	(hl), 96
	ld	e, 32
	ld	d, 0
	add	hl, de
	ld	(a8), hl
	

line5b1:ld	hl, (a9)
	ld	ix, a9
	ld	de, 29182
	rst	$18
	jr	c, loop5b1
	call	line4
	jp	line5c
loop5b1:ld	(hl), 96
	ld	e, 32
	ld	d, 0
	add	hl, de
	ld	(a9), hl

line5c:	ld	hl, (a10)
	ld	ix, a10
	ld	de, 29182
	rst	$18
	jr	c, loop5c
	call	line4
	jp	line5d
loop5c:	ld	(hl), 96
	ld	e, 32
	ld	d, 0
	add	hl, de
	ld	(a10), hl

line5d:	ld	hl, (a11)
	ld	ix, a11
	ld	de, 29182
	rst	$18
	jr	c, loop5d
	call	line4
	jp	line5e
loop5d:	ld	(hl), 96
	ld	e, 32
	ld	d, 0
	add	hl, de
	ld	(a11), hl

line5e:	ld	hl, (a12)
	ld	ix, a12
	ld	de, 29182
	rst	$18
	jr	c, loop5e
	call	line4
	jp	line5f
loop5e:	ld	(hl), 96
	ld	e, 32
	ld	d, 0
	add	hl, de
	ld	(a12), hl

line5f:	ld	hl, (a13)
	ld	ix, a13
	ld	de, 29182
	rst	$18
	jr	c, loop5f
	call	line4
	jp	line5g
loop5f:	ld	(hl), 96
	ld	e, 32
	ld	d, 0
	add	hl, de
	ld	(a13), hl

line5g:	ld	hl, (a14)
	ld	ix, a14
	ld	de, 29182
	rst	$18
	jr	c, loop5g
	call	line4
	jp	line5h
loop5g:	ld	(hl), 96
	ld	e, 32
	ld	d, 0
	add	hl, de
	ld	(a14), hl


line5h:
la1	ld	hl, (a15)
	ld	ix, a15
	ld	de, 29182
	rst	$18
	jr	c, lb1
	call	line4
	jp	la2
lb1:	ld	(hl), 96
	ld	e, 32
	ld	d, 0
	add	hl, de
	ld	(a15), hl

la2	ld	hl, (a16)
	ld	ix, a16
	ld	de, 29182
	rst	$18
	jr	c, lb2
	call	line4
	jp	la3
lb2:	ld	(hl), 96
	ld	e, 32
	ld	d, 0
	add	hl, de
	ld	(a16), hl

la3:


	jp	line1	

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
line6:	;6 A(I)=28671+RND(32):NEXT:GOTO3
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loop17:	call	random
	ld	b, 0
	ld	c, a
;	call	random
;	add	a, c
;	ld	c, a
	ld	hl, 28671
	add	hl, bc
	ld	(ix), h
	ld	(ix+1), l
	ret




;Line 0 : Set fall off screen location. Set array, clearescreen. Set 13 entrys of array to be random locations on the screen.
;
;Line 1 : For the first random amount of entries, display a random amount of random characters on screen.
;         This is the initial effect when The Matrix characters appear dripping down the screen.
;
;Line 2:  Can not fit on Line 1 unfortunately. And can not find enough space for a CLS.
;         ONLY ONE SINGLE MORE CHARACTER IS NEEDED!. 
;         This is dreadful, however, I simply gave up looking further.
;         This adds one more line to the VZ300 listing.
;
;Line 3 : For the first seven entries that are on the screen, pick a random character and display it.
;	 Increase the location on the screen by one line down. And do this 7 times for each entry.
;         If the location is on the screen then skip line 4.
;
;Line 4 : This line will only be reached if a single entry's display location has dropped off / fallen 
;         off the screen. So select a new screen location.
;
;
;Line 5 : For the next six array entries if they are still on the screen, blank them out - make them light green space for VZ300.
;         And increase down to the following line. Do this six times, then jump back to line 1.
;
;Line 6 : For each array entriy that has fallen off the screen, pick a new screen location. Goto 3 coz don't 
;	 really need to do fancy char display for this run as all it does is add a tiny unwanted delay.
;
;
;
;
;
;=========================================================================
;Comapre DE & HL registers pairs
;
;RST $18 may be used to call a routine wihch compares the contents of the DE and HL reg pairs.
;Routine uses the A register only, but will work for unsigned or positive numbers . 
;Upon returning, the result of the comparison will be in the status register
;HL<DE 		: carry set
;HL > DE 	: no carry
;HL <> DE 	: NZ
;HL=DE 		: Z
;
;LD 	HL, 500
;RST 	$18
;JR 	C, err		carry means num > 500
;LD 	HL, 100
;RST	$18		
;JR	NC, ERR		no carry means num < 100
;....			if here,, must be ok
;
;=========================================================================
;
;
;
;


;
;
;
;; Q; Q-26: How do I implement a less-than/greater-than test in assembly?
;; A: To compare stuff, simply do a CP, and :
;;    - if the zero flag is set, A and the argument were equal,
;;    - if the carry is set the argument was greater,
;;    - if neither is set, then A must be greater 
;;    (CP does nothing to the registers, only the F (flag) register is changed). 
;
;
;UnSigned
;If A == N, then Z flag is set.
;If A != N, then Z flag is reset.
;If A < N, then C flag is set.
;If A >= N, then C flag is reset.
;
;Signed
;If A == N, then Z flag is set.
;If A != N, then Z flag is reset.
;If A < N, then S and P/V are different.
;A >= N, then S and P/V are the same.  bit 3, bit 8


;95 normal chars : 32 to 127.
;63 invers chars : 192 to 255.



;
;; - - - - - - - - - - - - - -
;; GET Y-AXIS * 32.
;; - - - - - - - - - - - - - - 
;
;
;	ld	hl, 0		; GET Y-AXIS, MULTIPLY BY 32.   DE = Y*32.
;	ld	l, b
;	ADD 	HL, HL
;  	ADD 	HL, HL
;	ADD 	HL, HL
;	ADD 	HL, HL
;	ADD 	HL, HL
;	ld	a, d		; tempory	a=d=tempory X-axis value.
;	ld	de, $7000
;	ex	de, hl		; poke 28672+D,A.  HL=$7000,DE=Y*32.
;	add	hl, de		; add Y component to HL.   HL=$7000+(Y*32)
;				; DE can go now away.
;	push	bc
;	ld	bc, 0
;	ld	c, a
;
;
;; - - - - - - - - - - - - - -
;; FANCY WAIT RETRACE
;; - - - - - - - - - - - - - - 
;;	push	hl
;;	LD 	hl,$6800
;;sync2:	BIT 	7,(hl)			; fancy wait retrace.
;;	jr	NZ,sync2
;;	pop	hl
;


random:

;Works pretty good regarding randomness.   
; Use Lower 'L' part of HL; ie  ld a,l
;   (seed1) contains a 16-bit seed value
;   (seed2) contains a NON-ZERO 16-bit seed value
;Outputs:
;   HL is the result
;   BC is the result of the LCG, so not that great of quality
;   DE is preserved
;   A is 0-255. 
;Destroys:
;   AF
;cycle: 4,294,901,760 (almost 4.3 billion)
;160cc
;26 bytes
            push     hl
            push     bc
            push     de
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
            ld          a, l
            pop       de
            pop       bc
            pop       hl
           ret


random32:			; 0-32 ONLY.   Result in A.
        push    hl
        push    bc
        push   	de
r_loop0:ld 	hl,(seed3)
    	ld 	b,h
    	ld 	c,l
    	add 	hl,hl
    	add 	hl,hl
    	inc 	l
    	add 	hl,bc
    	ld 	(seed3),hl
    	ld 	hl,(seed4)
    	add 	hl,hl
    	sbc 	a,a
    	and 	%00101101
    	xor 	l
    	ld 	l,a
    	ld 	(seed4),hl
    	add 	hl,bc
	ld      a, l
	cp	32
	jr	nc, r_loop0
        pop     de
        pop     bc
        pop     hl
        ret


random63_1:			; 0-63 ONLY.  Result in A.
        push    hl
        push    bc
        push   	de
r_loop1:ld 	hl,(seed3)
    	ld 	b,h
    	ld 	c,l
    	add 	hl,hl
    	add 	hl,hl
    	inc 	l
    	add 	hl,bc
    	ld 	(seed3),hl
    	ld 	hl,(seed4)
    	add 	hl,hl
    	sbc 	a,a
    	and 	%00101101
    	xor 	l
    	ld 	l,a
    	ld 	(seed4),hl
    	add 	hl,bc
	ld      a, l
	cp	63
	jr	nc, r_loop1
        pop     de
        pop     bc
        pop     hl
        ret

random63_2:			; 0-63 ONLY.  A = A + 64.  Result in A.
        push    bc
        push   	de
	push	hl
r_loop2:ld 	hl,(seed3)
    	ld 	b,h
    	ld 	c,l
    	add 	hl,hl
    	add 	hl,hl
    	inc 	l
    	add 	hl,bc
    	ld 	(seed3),hl
    	ld 	hl,(seed4)
    	add 	hl,hl
    	sbc 	a,a
    	and 	%00101101
    	xor 	l
    	ld 	l,a
    	ld 	(seed4),hl
    	add 	hl,bc
	ld      a, l
	cp	63
	jr	nc, r_loop2
	add	a, 64
	pop	hl
	ld	(hl), a	
	ld	e, 32
	ld	d, 0
	add	hl, de

        pop     de
        pop     bc
        ret

random127:			; 0-127 ONLY.    Result in A.
        push    hl
        push    bc
        push   	de
r_loop3:ld 	hl,(seed3)
    	ld 	b,h
    	ld 	c,l
    	add 	hl,hl
    	add 	hl,hl
    	inc 	l
    	add 	hl,bc
    	ld 	(seed3),hl
    	ld 	hl,(seed4)
    	add 	hl,hl
    	sbc 	a,a
    	and 	%00101101
    	xor 	l
    	ld 	l,a
    	ld 	(seed4),hl
    	add 	hl,bc
	ld      a, l
	cp	127
	jr	nc, r_loop3
        pop     de
        pop     bc
        pop     hl
        ret



seed1:  defb 1234
seed2:	defb 5678
	defb 0
seed3:  defb 8765
seed4:	defb 4321
	defb 0




a1:	defw 0
a2:	defw 0
a3:	defw 0
a4:	defw 0
a5:	defw 0
a6:	defw 0
a7:	defw 0
a8:	defw 0
a9:	defw 0
a10:	defw 0
a11:	defw 0
a12:	defw 0
a13:	defw 0
a14:	defw 0
a15:	defw 0
a16:	defw 0