;	Run time start off for Small C.
	.module	_crt
	.globl	main
;	This will be at the start location in the final image
.start:
	ld	sp,#.stack; pick up core top
;
;	call main with argc = 1 and argv = [ "main", 0 ]
;
	ld	hl,#1
	push	hl
	ld	hl,#.argv
	push	hl
	ld	a,#2
	call	main		; call main program
	pop	bc
	pop	bc
	jp	0x1a19		; return to BASIC

;*****************************************************
;
;	Video Technology library for small C compiler
;
;		Juergen Buchmueller
;
;*****************************************************

;*****************************************************
; numeric functions
;*****************************************************
	.globl	sqrt
; ----- int sqrt(int val);
sqrt:   push    ix
	ld	ix, #0
        add     ix, sp
	ld	l, 5(ix)	; MSB of val
	ld	h, #0
	ld	a, #0		; result
	ld	de, #1

sqrt1:  or      a
	sbc	hl, de
        jr      c, sqrt2
	inc	de
        inc     de
	add	a, #0x10	; result += 16
	jr	sqrt1

sqrt2:	add	hl, de		; take back SBC HL, DE
	ld	c, a		; save result
	ld	e, a		; save result * 16 in E
	inc	a		; result * 16 + 1
	add	a, e		; add to E
	ld	e, a		; start subtracting here
	ld	d, #0
	ld	a, c		; get result
	ld	h, l		; val <<= 8
	ld	l, 4(ix)	; + LSB(val)

sqrt3:  or      a
        sbc     hl, de
	jr	c, sqrt4
	inc	de
	inc	de
	inc	a		; result += 1
	jr	sqrt3

sqrt4:	add	hl, de		; take back SBC HL, DE
	ld	l, a		; result in HL
        pop     ix
	ret

	.globl	rand
; ----- int rand(void);
rand:	push	ix
	ld	ix, #0
	add	ix, sp
;	17 bit polynome
;	x = ((x << 7) | (x >> 10)) + 0x18000

	ld	a, r
	and	#7
	inc	a
	ld	c, a
	ld	hl, (seed)
	ld	a, (seed+2)
rand0:	ld	b, #7
rand1:	rra
	adc	hl,hl
	rla
	djnz	rand1
	ld	de, #0x8000
	add	hl, de
	adc	a, #1
        dec     c
	jr	nz, rand0
	ld	(seed), hl
	ld	(seed+2), a
	res	#7, h	; positive numbers only
        ld      e, l
	ld	d, h
        ld      l, 4(ix)
        ld      h, 5(ix)
	pop	ix
	jp	.mod

	.globl	srand
; ----- void srand(int start);
srand:
	push	ix
	ld	ix, #0
        add     ix, sp
	ld	l, 4(ix)
	ld	h, 5(ix)
	ld	a, h
	or	l
	jr	nz, srand1
	ld	a, r
	ld	l, a
	add	a, b
	adc	a, c
	sbc	a, d
	xor	e
	ld	h, a
srand1:
	ld	(seed), hl
	pop	ix
	ret

;*****************************************************
; string functions
;*****************************************************


; ----- char *midstr(char *str, pos);
	.globl	strcpy
midstr: push	ix
	ld	ix, #0
     add     ix, sp
	ld      l,6(ix)         ; get *str
	ld	h,7(ix)
	ld de,#0
	ld	e,4(ix) 	; get pos
	add hl,de
	ld a,(hl)
	ld hl,#0
	ld l,a
	pop	ix
     ret

; ----- int strlen(char *src);
        .globl  strlen
strlen: push	ix
        ld      ix, #0
        add     ix, sp
	ld	l,4(ix) 	; get *src
        ld      h,5(ix)
	xor	a		; search '\0'
	ld	bc, #0		; max 64K
	cpir
	ld	hl, #0		; zero
	jr	nz, slenx	; not found? return 0
	or	a
	sbc	hl, bc		; 0 - count -> length + 1
	dec	hl		; length
slenx:	pop	ix
	ret

; ----- char *strcpy(char *dst, char *src);
	.globl	strcpy
strcpy: push	ix
	ld	ix, #0
        add     ix, sp
scpy0:  ld      l,6(ix)         ; get *dst
	ld	h,7(ix)
	ld	e,4(ix) 	; get *src
	ld	d,5(ix)
	ld	c, l		; copy of *dst
	ld	b, h
scpy1:	ld	a, (de)
	inc	de
	ld	(bc), a
	inc	bc
	or	a
	jr	nz, scpy1
	pop	ix
        ret

; ----- char *strcat(char *dst, char *src);
	.globl	strcat
strcat: push	ix
	ld	ix, #0
        add     ix, sp
        ld      l,6(ix)         ; get *dst
	ld	h,7(ix)
        xor     a               ; search '\0'
	ld	bc, #0		; max 64K
	cpir
	jr	nz, scatx	; not found? return NULL
        dec     hl
	ld	c, l
        ld      b, h
	ld	e,4(ix) 	; get *src
	ld	d,5(ix)
scat1:	ld	a, (de)
	inc	de
	ld	(bc), a
	inc	bc
	or	a
        jr      nz, scpy1
scatx:	ld	l,6(ix) 	; return *dst
	ld	h,7(ix)
	pop	ix
	ret

; ----- int strcmp(char *dst, char *src);
        .globl  strcmp
strcmp: push	ix
	ld	ix, #0
        add     ix, sp
        ld      e, 4(ix)        ; get *src
	ld	d, 5(ix)
	ld	l, 6(ix)	; get *dst
        ld      h, 7(ix)
scmp1:	ld	a,(de)		; get char from *src
	ld	c, a		; into C too
	inc	de
	ld	b,(hl)		; get char from *dst
	inc	hl
	or	b		; *dst and *src both '\0' ?
	jr	z, scmpx	; yup, strings are equal
	ld	a, c		; *src
	sub	b		; - *dst
	jr	z, scmp1	; equal, continue
scmpx:	pop	ix
	jp	.sxt		; extend sign char to int

;*****************************************************
; memory functions
;*****************************************************

; ----- int memset(char *dst, int chr, int size);
	.globl	memset
memset: push	ix
        ld      ix, #0
        add     ix, sp
	ld	c,4(ix) 	; get size
	ld	b,5(ix)
	ld	e,6(ix) 	; get chr
	ld	l,8(ix) 	; get *dst
	ld	h,9(ix)
mset1:	ld	(hl), e
	inc	hl
	dec	bc
	ld	a, b
	or	c
	jr	nz, mset1
	pop	ix
	ret

; ----- int memcpy(char *dst, char *src, int size);
	.globl	memcpy
memcpy: push	ix
        ld      ix, #0
        add     ix, sp
	ld	c,4(ix) 	; get size
	ld	b,5(ix)
	ld	l,6(ix) 	; get *src
	ld	h,7(ix)
	ld	e,8(ix) 	; get *dst
	ld	d,9(ix)
	ldir
	pop	ix
	ret

; ----- int soundcopy(char *dst, char *src, int size, int sound1, int sound2);
	.globl	soundcopy
soundcopy:
	push	ix
        ld      ix, #0
        add     ix, sp
	ld	c,8(ix) 	; get size
        ld      b,9(ix)
        ld      l,10(ix)        ; get *src
        ld      h,11(ix)
        ld      e,12(ix)        ; get *dst
        ld      d,13(ix)
        exx
	ld	c,4(ix) 	; sound 2
	ld	b,6(ix) 	; sound 1
	ld	e,c
	ld	d,b
	ld	hl,(seed)
	ld	a,c		; both off?
	or	b
	exx
        ld      a,(#0x783b)     ; get latch data
	jr	nz, soundcopy1	; sound is on
	ldir
	jp	soundcopyx

soundcopy1:
	exx
	inc	d		; tone ?
	dec	d
        jr      z,soundcopy2    ; nope, skip
	dec	d		; counted down?
	jr	nz,soundcopy2	; nope
	ld	d,b		; reset counter
	xor	#0x21		; toggle output
	ld	(#0x6800),a
soundcopy2:
	inc	e		; noise ?
        dec     e
	jr	z,soundcopy3	; nope, skip
	dec	e		; counted down?
	jr	nz,soundcopy3	; nope
	ld	e,c		; reset counter
	add	hl,hl		; rotate 16 random bits
	jr	nc,soundcopy3	; not set
	inc	l		; set bit 0 agaon
	xor	#0x21		; toggle output
        ld      (#0x6800),a
soundcopy3:
        exx
	ldi			; transfer 4 bytes
        ldi
        ldi
        ldi
	jp	pe, soundcopy1	; until done
	ld	(#0x783b),a
soundcopyx:
        pop     ix
	ret

;*****************************************************
; BASIC
;*****************************************************
	.globl	clrscr
; ----- clrscr();
clrscr: push    ix
	call	0x1c9		; clear screen
	pop	ix
	ret

	.globl	inch
; ----- int inch();
inch:   push    ix
	call	0x2ef4		; read keyboard
	pop	ix
	jp	.sxt		; sign extend A to HL

	.globl	getch
; ----- int getch();
getch:  push    ix
getch1: call	0x0049		; wait for keyboard
	pop	ix
	jp	.sxt		; sign extend A to HL

outchar:
	push	bc
	push	de
	push	hl
	push	af
	call	0x032a		; output character
	pop	af
	pop	hl
	pop	de
	pop	bc
	ret

outstr:
	ld	a,(hl)
	or	a
	ret	z
	inc	hl
	call	outchar
	jr	outstr

	.area	_DATA
numbuf: .ds	32+32
sign:	.db	0
zero:	.db	0
radix:  .dw     10

        .area   _CODE

; HL = DE / HL, DE = DE % HL [unsigned]
udiv:
	ld	b,h
	ld	c,l
	ld	a,#16
	ex	de,hl
	ld	de,#0
udiv1:
	push	af
	add	hl,hl
	rl	e		; rotate DE left
	rl	d
	ld	a,d		; DE zero?
        or      e
	jr	z,udiv2
	ld	a,e		; compare DE and BC
        sub     c
        ld      a,d
        sbc     a,b
	jp	m,udiv2
	inc	l		; result++
	ld	d,a		; D -= B + carry
	ld	a,e		; E -= C
	sub	c
	ld	e,a
udiv2:	pop	af
	dec	a
	jr	nz,udiv1
	ret

number:
	push	bc
	ld	de, #numbuf+32
        xor     a
	dec	de		; --dst
	ld	(de), a 	; terminating null byte
number1:
        push    de
        ld      e, l            ; number
        ld      d, h
        ld      hl, (radix)     ; get radix
	call	udiv		; unsigned divide/modulo
        ld      a, e            ; remainder
        add     a, #0x30        ; + '0'
        cp      #0x3a           ; <= '9'
        jr      c, number2      ; in range
	add	a, #7		; adjust for radix > 10
number2:
        pop     de
	dec	de		; --dst
        ld      (de), a         ; store digit
        ld      a, h            ; result not zero ?
        or      l
        jr      nz, number1     ; next digit
	ld	a,(sign)	; get sign
	or	a
	jr	z, number3	; no sign
	dec	de
	ld	(de),a		; into buffer
number3:
	ex	de,hl
	pop	bc
        ret

rpad:
	ld	a,c		; C
	neg			; make it positive
	jr	pad1
lpad:
	ld	a,c		; C
pad1:
        sub     b               ; - B
	ret	z		; leave if zero
	ret	m		; or below zero
pad2:
	push	af
	ld	a,#0x20
	call	outchar
	pop	af
	dec	a
	jr	nz,pad2
	ret

        .globl  printf
; ----- printf(char *fmt, ...)
printf:
	push	ix
	ld	l, a		; # of args
	ld	h, #0
	inc	hl		; +2
	inc	hl
	add	hl, hl		; *2
	add	hl, sp		; after first argument
	dec	hl		; get first arg
	ld	d,(hl)		; format string MSB
	dec	hl
	ld	e,(hl)		; LSB
pf_1:
	ld	a,(de)		; get fmt char
	inc	de
	or	a
	j	z,pf_x		; end of string
	cp	#0x25		; argument?
	jr	z, pf_4 	; check format

pf_2:
	cp	#10		; \n ?
	jr	nz, pf_3	; not new line
	ld	a, #13		; replace with CR
pf_3:
	call	outchar 	; output char
	jr	pf_1

pf_4:
        ld      bc, #0          ; sign/zero = 0
        ld      (sign),bc       ; no sign, no leading zeroes
pf_5:
        ld      a,(de)          ; get argument type
	inc	de
	cp	#0x25		; percent (%%) ?
	jr	z, pf_3 	; output percent character
	cp	#0x30
	jr	c, pf_7 	; below '0'
	jr	nz, pf_6	; not equal to '0'
	ld	(zero),a	; leading zeroes
pf_6:
	cp	#0x3a		; above '9'?
	jr	nc,pf_7
	sub	#0x30		; digit -> decimal
	push	af
	ld	a,c		; c*1
	add	a,a		; *2
	add	a,a		; *4
	add	a,c		; *5
	add	a,a		; *10
	ld	c,a		; save number
	pop	af
	add	a,c		; + digit
	ld	c,a		; -> c
	jr	pf_5

pf_7:
	cp	#0x2d		; '-'
	jr	nz, pf_8
	inc	b		; toggle width sign flag
	jr	pf_5
pf_8:
	bit	#0, b		; negative width?
	jr	z, pf_9 	; nope
	ld	b, a
	ld	a, c
	neg
	ld	c, a
	ld	a, b
pf_9:
        push    de              ; save fmt
	dec	hl		; get next arg
        ld      d, (hl)         ; MSB
	dec	hl
	ld	e, (hl) 	; LSB
        push    hl              ; save argptr
	ex	de, hl		; next arg in HL

	cp	#0x63		; 'c'haracter ?
	j	z, pf_chr
	cp	#0x64		; 'd'ecimal?
	j	z, pf_dec
	cp	#0x73		; 's'tring?
	j	z, pf_str
        cp      #0x75           ; 'u'nsigned?
	j	z, pf_uns
	cp	#0x78		; he'x'adecimal ?
	j	z, pf_hex
	jp	pf_3		; print unknown format char

pf_chr:
	ld	h, #0		; null byte
	ld	(numbuf),hl	; store char and terminating null byte
	ld	hl, #numbuf	; print this as string
	ld	b, #1		; 1 character
	jr	pf_out

pf_dec:
	bit	#7, h		; int negative?
	jr	z, pf_uns
	ld	a,#0x2d
	ld	(sign),a
	call	.neg		; make HL positive
pf_uns:
	ld	a,#10		; radix is 10
	.db	0x11		; cover the following opcode "LD A,#16"
pf_hex:
        ld      a,#16
        ld      (radix), a      ; store radix
	call	number		; output unsigned integer
pf_str:
	ld	b,#-1
	ld	e,l
	ld	d,h
pf_len:
	inc	b
	ld	a,(de)
	inc	de
	or	a
	jr	nz,pf_len
pf_out:
	call	lpad		; left pad to width C characters
        call    outstr          ; output string
	call	rpad		; right pad to width -C characters
        pop     hl
        pop     de
	jp	pf_1

pf_x:
	pop	ix
	ret

        .globl  gotoxy
; ----- gotoxy(int x, int y);
gotoxy:
	push	ix
	ld	ix, #0
	add	ix, sp
	ld	l, 4(ix)	; get y LSB
	ld	h, 5(ix)	; MSB
	ld	de, #16
	or	a
	sbc	hl, de		; below 16 ?
	jr	c, gxy_1
	ld	hl, #-1 	; -1 + 16 -> 15
gxy_1:
	add	hl, de
	add	hl, hl		; * 32
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
	ld	e, 6(ix)	; get x LSB
	ld	d, #0x70
	add	hl, de
	ld	(#0x7820), hl	; set cursor position
	pop	ix
	ret

	.globl	sound
; ----- sound(int freq, int cycles);
sound:
	push	ix
	ld	ix, #0
	add	ix, sp
	ld	c, 4(ix)	; get cycles
	ld	b, 5(ix)
	ld	l, 6(ix)	; get frequency
	ld	h, 7(ix)
	call	0x345c		; sound
        pop     ix
	ret

;*****************************************************
; Text/Graphics
;*****************************************************

	.globl	score
; ----- score(int addr, char byte)
score:		push	ix
			ld	ix, #0
        		add     ix, sp
			ld      l,6(ix)       ; HL = addr      
			ld      h,7(ix)       
			ld		a,#5
			ld		(counter),a
			ld      a,4(ix)       ; A = byte
			cp 		#0
			ld		de,#numbers
			jr		z,showit
countit: 	inc	de
			inc	de
			inc	de
			inc	de
			inc	de
			dec	a
			jr	nz,countit
showit:
			ld	a,(de)
			inc	de
			ld	(hl),a
			ld	bc,#32			 ; A line's length
			add	hl,bc
			ld	a,(counter)
			dec	a
			ld	(counter),a
			jr	nz,showit
			pop	ix
			ret

	.area	_DATA		
counter: .byte 0x00
numbers:
		; 0
		.byte 0x3F
		.byte 0x33
		.byte 0x33
		.byte 0x33
		.byte 0x3F
		
		; 1
		.byte 0x3C
		.byte 0x0C
		.byte 0x0C
		.byte 0x0C
		.byte 0x3F
		
		; 2
		.byte 0x3F
		.byte 0x03
		.byte 0x0C
		.byte 0x30
		.byte 0x3F
		
		; 3
		.byte 0x3F
		.byte 0x03
		.byte 0x0F
		.byte 0x03
		.byte 0x3F
		
		; 4
		.byte 0x33
		.byte 0x33
		.byte 0x3F
		.byte 0x03
		.byte 0x03
		
		; 5
		.byte 0x3F
		.byte 0x30
		.byte 0x0C
		.byte 0x03
		.byte 0x3F
		
		; 6
		.byte 0x3F
		.byte 0x30
		.byte 0x3F
		.byte 0x33
		.byte 0x3F

		; 7
		.byte 0x3F
		.byte 0x03
		.byte 0x03
		.byte 0x03
		.byte 0x03
		
		; 8
		.byte 0x3F
		.byte 0x33
		.byte 0x0C
		.byte 0x33
		.byte 0x3F
		
		; 9
		.byte 0x3F
		.byte 0x33
		.byte 0x3F
		.byte 0x03
		.byte 0x3F

	.area	_CODE

	.globl	brick
; ----- brick(int addr, char byte)
brick:		push	ix
			ld	ix, #0
        		add     ix, sp
			ld      l,6(ix)       ; HL = addr      
			ld      h,7(ix)       
			ld		a,#3
			ld		(countr),a
			ld      a,4(ix)       ; A = byte
			cp 		#0
			ld		de,#bricks
			jr		z,showt
countt: 		inc	de
			inc	de
			inc	de
			inc	de
			inc	de
			inc	de
			dec	a
			jr	nz,countt
showt:
			ld	a,(de)
			inc	de
			ld	(hl),a
			inc hl
			ld	a,(de)
			inc	de
			ld	(hl),a
			dec hl
			ld	bc,#32			 ; A line's length
			add	hl,bc
			ld	a,(countr)
			dec	a
			ld	(countr),a
			jr	nz,showt
endt:		pop	ix
			ret

	.area	_DATA		
countr: .byte 0x00
bricks:
		; 0
		.byte #000, #000, #000, #000, #000, #000

		; 1
		.byte #085, #084, #085, #084, #085, #084
		
		; 2
		.byte #255, #252, #255, #252, #255, #252
		
		; 3
		.byte #087, #084, #087, #084, #087, #084
		
		; 4
		.byte #253, #252, #253, #252, #253, #252
		
		; 5
		.byte #085, #084, #255, #252, #085, #084
		
		; 6
		.byte #255, #252, #085, #084, #255, #252
		
		; 7
		.byte #245, #124, #245, #124, #245, #124

		; 8
		.byte #170, #168, #165, #104, #170, #168
		
		; 9
		.byte #170, #168, #175, #232, #170, #168

	.area	_CODE

	.globl	poke
; ----- poke(int addr, char byte)
poke:		push	ix
			ld	ix, #0
        		add     ix, sp
			ld      l,6(ix)       ; HL = addr      
			ld      h,7(ix)       
			ld      a,4(ix)       ; A = byte
			ld      (hl),a          ; load byte into address
			pop	ix
			ret

	.globl	mode
; ----- mode(int n);
mode:	push	ix
	ld	ix, #0
        add     ix, sp
	ld	a, 4(ix)	; check n
	or	a, 5(ix)
	ld	hl, #0x783b
	ld	a, (hl)
	jr	nz, mode1
mode0:	res	#3,a
	ld	(hl),a
	ld	(#0x6800),a
	call	0x01c9		; cls
	pop	ix
	ret

mode1:	set	#3,a
	ld	(hl), a
	ld	(#0x6800),a
	ld	hl, #0x7000
	ld	de, #0x7001
	ld	bc, #0x7ff
	ld	a, #0
	ld	(hl),a
	ldir
	pop	ix
        ret

	.globl	color
; ----- bgrd(int n);
color:	push	ix
	ld	ix, #0
        add     ix, sp
	ld	a, 4(ix)	; get n
	and	#7		; 0 to 7
	ld	(#0xffff),a	; ????????????????
	pop	ix
	ret

        .globl  bgrd
; ----- bgrd(int n);
bgrd:	push	ix
	ld	ix, #0
        add     ix, sp
	ld	a, 4(ix)	; check n
	or	a, 5(ix)
	ld	hl, #0x783b
	ld	a,(hl)
	set	#4,a
        jr      nz, bgrd1
	res	#4,a
bgrd1:	ld	(hl),a
	ld	(#0x6800),a
	pop	ix
	ret

	.globl	setbase
; ----- void setbase(int start);
setbase:
	push	ix
	ld	ix, #0
        add     ix, sp
	ld	l, 4(ix)
	ld	h, 5(ix)
	ld	(scrbase), hl
	pop	ix
	ret

; ----- graphics mode set pixel at x=L, y=H color C
pset:   push    bc
	push	de
        push    hl
        push    af
        ld      a, h            ; get y
        cp      #64             ; >= 64 ?
        jr      nc, psetx       ; nah, won't pset there
        ld      a, l            ; get x
        cp      #128            ; >= 128 ?
        jr      nc, psetx
        sla     l               ; calculate screen offset
        srl     h
        rr      l
        srl     h
        rr      l
        srl     h
        rr      l
        and     #3              ; pixel offset
        inc     a
        ld      b, #0b11111100
pset1:  rrc     b
        rrc     b
        rrc     c
        rrc     c
        dec     a
        jr      nz, pset1
	ld	de, (scrbase)
	add	hl, de
        ld      a, (hl)
        and     b
        or      c
        ld      (hl), a
psetx:  pop     af
        pop     hl
	pop	de
        pop     bc
        ret

        .globl  plot
; ----- plot(int x, int y, int c);
plot:	push	ix
	ld	ix, #0
        add     ix, sp
	ld	l, 8(ix)	; x
	ld	h, 6(ix)	; y
	ld	c, 4(ix)	; color
	call	pset		; grapics plot
        pop     ix
        ret

	.globl	line
; ----- line(int x1, int y1, int x2, int y2, int c);
line:	push	ix
	ld	ix, #0
        add     ix, sp
	ld	l, 12(ix)	; x1
	ld	h, 10(ix)	; y1
	ld	e,  8(ix)	; x2
	ld	d,  6(ix)	; y2
	ld	c,  4(ix)	; color
	ld	a, e
	cp	l
	jr	nc, line1
	ex	de,hl		; swap so that x1 < x2
line1:	ld	a, e
	sub	l		; dx
	ld	e, a		; save dx
	ld	a, d
	sub	h
	jp	c, lup		; negative (up)

ldn:	ld	d, a		; save dy
	cp	e		; dy < dx ?
	jr	c, ldnx

ldny:	ld	b, a		; count = dy
	srl	a		; /2 -> overflow
ldny1:	call	pset
	dec	b		; done?
	jp	m, linex
	inc	h		; y++
	sub	e		; overflow -= dx
	jr	nc, ldny1
        inc     l               ; x++
	add	a, d		; overflow += dy
	jr	ldny1

ldnx:	ld	a, e		; get dx
	ld	b, a		; count = dx
	srl	a		; /2 -> overflow
ldnx1:	call	pset
	dec	b		; done?
	jp	m, linex
	inc	l		; x++
	sub	d		; overflow -= dy
	jr	nc, ldnx1
	inc	h		; y++
	add	a, e		; overflow += dx
	jr	ldnx1

lup:	neg			; make dy positive
	ld	d, a		; save dy
	cp	e		; dy < dx ?
	jr	c, lupx

lupy:	ld	b, a		; count = dy
	srl	a		; /2 -> overflow
lupy1:	call	pset
	dec	b		; done?
	jp	m, linex
	dec	h		; y--
	sub	e		; overflow -= dx
	jr	nc, lupy1
	inc	l		; x++
	add	a, d		; overflow += dy
	jr	lupy1

lupx:	ld	a, e		; get dx
	ld	b, a		; count = dx
	srl	a		; /2 -> overflow
lupx1:	call	pset
	dec	b		; done?
	jp	m, linex
	inc	l		; x++
	sub	d		; overflow -= dy
	jr	nc, lupx1
	dec	h		; y--
	add	a, e		; overflow += dx
	jr	lupx1

linex:	pop	ix
	ret

	.globl	shape
; ----- line(int x, int y, int w, int h, int c, char *data);
shape:  push    ix
	ld	ix, #0
	add	ix, sp
	push	iy
	ld	e, 4(ix)	; get *data
	ld	d, 5(ix)
	ld	iy, #0
	add	iy, de		; to IY

	ld	h,12(ix)	; y coordinate
	ld	l,14(ix)	; x coordinate

; convert HL to screen offset
	sla	l
	sra	h
	rr	l
	sra	h
        rr      l
	sra	h
        rr      l
	ld	de, (scrbase)
	add	hl, de

	ld	a, 6(ix)	; color
	and	#3		; only 0..3 allowed
	ld	c, a
	ld	b, #0xfc	; pixel mask
        ld      a,14(ix)        ; x offset
	and	#3		; mask lower two bits of x
	xor	#3		; flip 3->0, 2->1, 1->2, 0->3
	jr	z, shape1	; offset was 3, done
shape0:
	rlc	c		; shift color left
	rlc	c
	rlc	b		; shift mask left
        rlc     b
	dec	a		; more shifts?
	jr	nz, shape0
shape1:
        ld      a,12(ix)        ; get y
	or	a		; negative ?
	jp	m, shape8	; next row
	cp	#64		; above 64 ?
	jp	nc, shapex	; leave function
	ld	e,10(ix)	; get width
shape2:
	push	bc		; save mask/color
	push	hl		; save screen offset
shape3:
	ld	d, (iy) 	; get data byte
	inc	iy		; increment data pointer
	ld	a, (hl) 	; get screen contents
shape4:
        rlc     d               ; next bit set?
	jr	nc, shape5	; no, skip
        and     b               ; remove old pixel
	or	c		; set new pixel
shape5:
	rrc	c		; rotate color
        rrc     c
	rrc	b		; rotate mask
	rrc	b
	jr	c, shape6	; mask not yet through? skip
	ld	(hl), a 	; store screen contents
        inc     hl              ; increment screen address
	ld	a, (hl) 	; get screen contents
shape6:
	dec	e		; decrement width
	jr	z, shape7	; zero: row done
	bit	#0, e
	jr	nz, shape4	; odd count
	bit	#1, e
        jr      nz, shape4      ; odd count
	bit	#2, e
        jr      nz, shape4      ; odd count
	ld	(hl), a 	; store screen contents
        jr      shape3          ; fetch next datum
shape7:
	ld	(hl), a 	; store screen contents
        pop     hl              ; get back screen offset
        pop     bc              ; get back mask/color
	jr	shape9
shape8:
        ld      e,10(ix)        ; get width
	ld	d,#0
	ld	a,#7		; + 7
	add	a,e
	ld	e,a
	ld	a,d
	adc	a,#0
	ld	d,a
	sra	d		; / 8
	rr	e
	sra	d
        rr      e
	sra	d
        rr      e
	add	iy,de		; skip data bytes
shape9:
	ld	de, #32 	; one row down
	add	hl, de
	inc	12(ix)		; increment y
	dec	8(ix)		; decrement h
	jp	nz, shape1	; more rows?
shapex:
        pop     iy
	pop	ix
	ret

	.area	_DATA
char_shape:
	.byte 0x00,0x00,0x00,0x00,0x00	; space
	.byte 0x20,0x20,0x20,0x00,0x20	; !
	.byte 0x50,0x50,0x00,0x00,0x00	; "
	.byte 0x50,0xf8,0x50,0xf8,0x50	; #
	.byte 0x78,0xa0,0x70,0x28,0xf0	; $
	.byte 0xc8,0xd0,0x20,0x58,0x98	; %
	.byte 0x40,0xa0,0x68,0x90,0x68	; &
	.byte 0x20,0x20,0x40,0x00,0x00	; '
	.byte 0x30,0x40,0x40,0x40,0x30	; (
	.byte 0x60,0x10,0x10,0x10,0x60	; )
	.byte 0xa8,0x70,0xf8,0x70,0xa8	; *
	.byte 0x20,0x20,0xf8,0x20,0x20	; +
	.byte 0x00,0x00,0x20,0x20,0x40	; ,
	.byte 0x00,0x00,0xf8,0x00,0x00	; -
	.byte 0x00,0x00,0x00,0x60,0x60	; .
	.byte 0x08,0x10,0x20,0x40,0x80	; /
	.byte 0x70,0x88,0xa8,0x88,0x70	; 0
	.byte 0x20,0x60,0x20,0x20,0x70	; 1
	.byte 0xf0,0x08,0x70,0x80,0xf8	; 2
	.byte 0xf8,0x10,0x70,0x08,0xf0	; 3
	.byte 0x10,0x30,0x50,0xf8,0x10	; 4
	.byte 0xf8,0x80,0xf0,0x08,0xf0	; 5
	.byte 0x70,0x80,0xf0,0x88,0x70	; 6
	.byte 0xf8,0x10,0x20,0x40,0x80	; 7
	.byte 0x70,0x88,0x70,0x88,0x70	; 8
	.byte 0x70,0x88,0x78,0x08,0x70	; 9
	.byte 0x00,0x20,0x00,0x20,0x00	; :
	.byte 0x00,0x20,0x00,0x20,0x40	; ;
	.byte 0x10,0x20,0x40,0x20,0x10	; <
	.byte 0x00,0xf8,0x00,0xf8,0x00	; =
	.byte 0x40,0x20,0x10,0x20,0x40	; >
	.byte 0x70,0x88,0x30,0x00,0x20	; ?
	.byte 0x70,0x88,0xb8,0x80,0x70	; @
	.byte 0x70,0x88,0xf8,0x88,0x88	; A
	.byte 0xf0,0x88,0xf0,0x88,0xf0	; B
	.byte 0x70,0x88,0x80,0x88,0x70	; C
	.byte 0xe0,0x90,0x88,0x90,0xe0	; D
	.byte 0xf8,0x80,0xf0,0x80,0xf8	; E
	.byte 0xf8,0x80,0xf0,0x80,0x80	; F
	.byte 0x78,0x80,0xb8,0x88,0x78	; G
	.byte 0x88,0x88,0xf8,0x88,0x88	; H
	.byte 0x70,0x20,0x20,0x20,0x70	; I
	.byte 0xf8,0x08,0x08,0x88,0x70	; J
	.byte 0x88,0x90,0xe0,0x90,0x88	; K
	.byte 0x80,0x80,0x80,0x80,0xf8	; L
	.byte 0x88,0xd8,0xa8,0x88,0x88	; M
	.byte 0x88,0xc8,0xa8,0x98,0x88	; N
	.byte 0x70,0x88,0x88,0x88,0x70	; O
	.byte 0xf0,0x88,0xf0,0x80,0x80	; P
	.byte 0x70,0x88,0xa8,0x90,0x68	; Q
	.byte 0xf0,0x88,0xf0,0x90,0x88	; R
	.byte 0x78,0x80,0x70,0x08,0xf0	; S
	.byte 0xf8,0x20,0x20,0x20,0x20	; T
	.byte 0x88,0x88,0x88,0x88,0x70	; U
	.byte 0x88,0x88,0x88,0x50,0x20	; V
	.byte 0x88,0x88,0xa8,0xd8,0x88	; W
	.byte 0x88,0x50,0x20,0x50,0x88	; X
	.byte 0x88,0x50,0x20,0x20,0x20	; Y
	.byte 0xf8,0x10,0x20,0x40,0xf8	; Z
	.byte 0x78,0x60,0x60,0x60,0x78	; [
	.byte 0x80,0x40,0x20,0x10,0x08	; \
	.byte 0xf0,0x30,0x30,0x30,0xf0	; ]
	.byte 0x20,0x70,0xa8,0x20,0x20	; ^
	.byte 0x00,0x00,0x00,0x00,0xf8	; _
	.byte 0x20,0x20,0x10,0x00,0x00	; `
	.byte 0x00,0x78,0x88,0x88,0x78	; a
	.byte 0x80,0xf0,0x88,0x88,0xf0	; b
	.byte 0x00,0x70,0x80,0x80,0x78	; c
	.byte 0x08,0x78,0x88,0x88,0x78	; d
	.byte 0x00,0x70,0xf8,0x80,0x70	; e
	.byte 0x18,0x20,0x78,0x20,0x20	; f
	.byte 0x00,0x78,0xf8,0x08,0x70	; g
	.byte 0x80,0xf0,0x88,0x88,0x88	; h
	.byte 0x20,0x60,0x20,0x20,0x70	; i
	.byte 0x08,0x18,0x08,0x08,0x38	; j
	.byte 0x80,0x90,0xe0,0x90,0x88	; k
	.byte 0x60,0x20,0x20,0x20,0x70	; l
	.byte 0x00,0xd0,0xa8,0x88,0x88	; m
	.byte 0x00,0xf0,0x88,0x88,0x88	; n
	.byte 0x00,0x70,0x88,0x88,0x70	; o
	.byte 0x00,0xf0,0x88,0xf0,0x80	; p
	.byte 0x00,0x78,0x88,0x78,0x08	; q
	.byte 0x00,0xf0,0x88,0x80,0x80	; r
	.byte 0x00,0x78,0xe0,0x38,0xf0	; s
	.byte 0x20,0x78,0x20,0x20,0x18	; t
	.byte 0x00,0x88,0x88,0x88,0x78	; u
	.byte 0x00,0x88,0x88,0x50,0x20	; v
	.byte 0x00,0x88,0xa8,0xd8,0x88	; w
	.byte 0x00,0x88,0x70,0x88,0x88	; x
	.byte 0x00,0x88,0x78,0x08,0x70	; y
	.byte 0x00,0xf8,0x20,0x40,0xf8	; z
	.byte 0x18,0x20,0xc0,0x20,0x18	; {
	.byte 0x20,0x20,0x20,0x20,0x20	; |
	.byte 0xc0,0x20,0x18,0x20,0xc0	; }
	.byte 0x68,0xb0,0x00,0x00,0x00	; ~
        .byte 0xf8,0xf8,0xf8,0xf8,0xf8  ; block

	.area	_CODE
	.globl	char_draw
; ----- text(int x, int y, int c, char ch);
char_draw:
	push	ix
	ld	ix, #0
	add	ix, sp
	ld	l,10(ix)	; get x
	ld	h,11(ix)
	push	hl
	ld	l, 8(ix)	; get y
	ld	h, 9(ix)
        push    hl
	ld	hl, #5
	push	hl		; width
	push	hl		; height
	ld	l, 6(ix)	; get c
	ld	h, 7(ix)
        push    hl
	ld	a, 4(ix)	; get ch
	cp	#0x20
	jr	nc, char_shape1
	ld	a, #0x20
char_shape1:
	cp	#0x80
	jr	c, char_shape2
	ld	a, #0x20
char_shape2:
	sub	#0x20
	ld	l, a		; * 5
	ld	h, #0
	ld	e, l
	ld	d, h
	add	hl, hl
        add     hl, hl
	add	hl, de
	ld	de, #char_shape
	add	hl, de
	push	hl		; *data
	call	shape

        ld      sp, ix          ; clean up stack
        pop     ix
	ret

;*****************************************************
;
;	runtime library for small C compiler
;
;	c.s - runtime routine for basic C code
;
;		Ron Cain
;
;*****************************************************

	.globl	.gchar
	.globl	.sxt
; fetch char from (HL) and sign extend into HL
.gchar:	ld	a,(hl)
.sxt:	ld	l,a
	rlca
	sbc	a,a
	ld	h,a
	ret

        .globl  .gint
; fetch int from (HL)
.gint:	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret

	.globl	.pchar
; store char from HL into (DE)
.pchar: ld	a,l
	ld	(de),a
	ret

        .globl  .pint
; store int from HL into (DE)
.pint:	ld	a,l
	ld	(de),a
	inc	de
	ld	a,h
	ld	(de),a
	ret

	.globl	.or
; "or" HL and DE into HL
.or:	ld	a,l
	or	e
	ld	l,a
	ld	a,h
	or	d
	ld	h,a
	ret

	.globl	.xor
; "xor" HL and DE into HL
.xor:	ld	a,l
	xor	e
	ld	l,a
	ld	a,h
	xor	d
	ld	h,a
	ret

	.globl	.and
; "and" HL and DE into HL
.and:	ld	a,l
	and	e
	ld	l,a
	ld	a,h
	and	d
	ld	h,a
	ret
;
;......logical operations: HL set to 0 (false) or 1 (true)
;
; DE == HL
	.globl	.eq
.eq:    call    .cmp
	ret	z
	dec	hl
	ret

	.globl	.ne
; DE != HL
.ne:	call	.cmp
	ret	nz
	dec	hl
	ret

	.globl	.gt
; DE > HL [signed]
.gt:	ex	de,hl
	call	.cmp
	ret	c
	dec	hl
	ret

	.globl	.le
; DE <= HL [signed]
.le:	call	.cmp
	ret	z
	ret	c
	dec	hl
	ret

	.globl	.ge
; DE >= HL [signed]
.ge:	call	.cmp
	ret	nc
	dec	hl
	ret

	.globl	.lt
; DE < HL [signed]
.lt:	call	.cmp
	ret	c
	dec	hl
	ret

	.globl	.uge
; DE >= HL [unsigned]
.uge:	call	.ucmp
	ret	nc
	dec	hl
	ret

	.globl	.ult
; DE < HL [unsigned]
.ult:	call	.ucmp
	ret	c
	dec	hl
	ret

	.globl	.ugt
; DE > HL [unsigned]
.ugt:	ex	de,hl
	call	.ucmp
	ret	c
	dec	hl
	ret

	.globl	.ule
; DE <= HL [unsigned]
.ule:	call	.ucmp
	ret	z
	ret	c
	dec	hl
	ret

	.globl	.cmp
; signed compare of DE and HL
;   carry is sign of difference [set => DE < HL]
;   zero is zero/non-zero
.cmp:	ld	a,e
	sub	l
	ld	e,a
	ld	a,d
	sbc	a,h
	ld	hl,#1		;preset true
	jp	m,.cmp1
	or	e		;resets carry
	ret
.cmp1:	or	e
	scf
	ret

	.globl	.ucmp
; unsigned compare of DE and HL
;   carry is sign of difference [set => DE < HL]
;   zero is zero/non-zero
.ucmp:	ld	a,d
	cp	h
	jr	nz,.ucmp1
	ld	a,e
	cp	l
.ucmp1:	ld	hl,#1		;preset true
	ret

	.globl	.asr
; shift DE right arithmetically by HL, move to HL
.asr:	ex	de,hl
.asr1:	dec	e
	ret	m
	sra	h
	rr	l
	jr	.asr1

	.globl	.asl
; shift DE left arithmetically by HL, move to HL
.asl:	ex	de,hl
.asl1:	dec	e
	ret	m
	add	hl,hl
	jr	.asl1

	.globl	.sub
; HL = DE - HL
.sub:	ex	de,hl
	or	a
	sbc	hl,de
	ret

	.globl	.neg
; HL = -HL
.neg:	dec	hl

	.globl	.com
; HL = ~HL
.com:	ld	a,h
	cpl
	ld	h,a
	ld	a,l
	cpl
	ld	l,a
	ret

	.globl	.bool
; HL = HL ? 1 : 0
.bool:  call    .lneg

	.globl	.lneg
; HL = !HL
.lneg:	ld	a,h
	or	l
	jr	z,.lneg1
	ld	hl,#0
	ret
.lneg1:	inc	hl
	ret

	.globl	.mul
; HL = DE * HL [signed]
.mul:	ld	b,h
	ld	c,l
	ld	hl,#0
.mul1:	ld	a,c
	rrca
	jr	nc,.mul2
	add	hl,de
.mul2:	xor	a
	ld	a,b
	rra
	ld	b,a
	ld	a,c
	rra
	ld	c,a
	or	b
	ret	z
	xor	a
	ld	a,e
	rla
	ld	e,a
	ld	a,d
	rla
	ld	d,a
	or	e
	ret	z
	jr	.mul1

        .globl  .div
; HL = DE / HL, DE = DE % HL
.div:	ld	b,h
	ld	c,l
	ld	a,d
	xor	b
	push	af
	ld	a,d
	or	a
	call	m,.deneg
	ld	a,b
	or	a
	call	m,.bcneg
.div0:	ld	a,#16
	ex	de,hl
	ld	de,#0
.div1:	push	af
	add	hl,hl
	rl	e		; rotate DE left
	rl	d
	ld	a,d		; DE zero?
        or      e
        jr      z,.div2
	ld	a,e		; compare DE and BC
        sub     c
        ld      a,d
        sbc     a,b
        jp      m,.div2
	inc	l		; result++
	ld	d,a		; D -= B + carry
	ld	a,e		; E -= C
	sub	c
	ld	e,a
.div2:	pop	af
	dec	a
	jr	nz,.div1
	pop	af
	ret	p
	call	.deneg
	call	.neg
	ret

	.globl	.mod
; HL = DE % HL, DE = DE / HL
.mod:	call	.div
	ex	de,hl
	ret

        .globl  .deneg
; {DE = -DE}
.deneg: ld	a,d
	cpl
	ld	d,a
	ld	a,e
	cpl
	ld	e,a
	inc	de
	ret

	.globl	.bcneg
; {BC = -BC}
.bcneg: ld	a,b
	cpl
	ld	b,a
	ld	a,c
	cpl
	ld	c,a
	inc	bc
	ret


	.globl	.case
; case jump
.case:	ex	de,hl			;switch value to DE
	pop	hl		;get table address
.case1:	call	.case4		;get case value
	ld	a,e
	cp	c		;equal to switch value .
	jr	nz,.case2	;no
	ld	a,d
	cp	b		;equal to switch value .
	jr	nz,.case2	;no
	call	.case4		;get case label
	jr	z,.case3	;end of table, go to default
	push	bc
	ret			;case jump
.case2:	call	.case4		;get case label
	jr	nz,.case1	;next case
.case3:	dec	hl
	dec	hl
	dec	hl
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	ex	de,hl
	jp	(hl)		;default jump
.case4:	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	a,c
	or	b
	ret

        .area   _DATA
	.globl	etext
scrbase:.dw	0x7000		; screen base address
seed:	.dw	0		; random seed
etext:
        .globl  brkend
brkend: .dw     edata           ;current "break"

.main:	.asciz	'MAIN'
.argv:	.dw	.main

        .dw     0

        .area   _BSS
	.globl	edata
edata:
	.area	_STACK		;actually top of stack
	.ds	256
.stack:

