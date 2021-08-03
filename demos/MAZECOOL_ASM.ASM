
;10 DIM A(2,33):A1=0:A2=1:A3=2:C=1
;20 FOR X = C TO 32STEP 2: Z=RND(2)
;30 IFZ=1, A(A2,X-1)=12:A(A2,X)=12:A(A2,X+1)=8 : NEXT
;40 IFZ=2, A(A1,X)=A(A1,X)OR10:A(A2,X)=10:A(A3,X)=8:NEXT
;50 FORX=1TO32:PRINTCHR$(128ORA(A1,X));:A(A1,X)=0:NEXTX
;60 AA=A1:A1=A2:A2=A3:A3=AA:C=3-C: GOTO 20


	ORG 	$8000
	LD	DE, A0		; Fill 4x 33 byte arrays with zero.
	LD	b, 132 		; This saves a lot of unncessary "DEFB 0" below.
	LD	A,0		; Setting A=0 for a 132 loop of 'LD (DE), 0'
	LDIR			; Loop and repeat for 132 times.
	LD	C, 1		; Reg C = var C
ST0:	LD	B, C		; Reg B = var X
LOOP1:	LD	E, B		; Reg E = array offset 0-32.
RANDOM2:push    bc		; Z=RND(2).	
SEED1	equ	$+1
	ld 	hl,1234
    	ld 	b,h
    	ld 	c,l
    	add 	hl,hl
    	add 	hl,hl
    	inc 	l
    	add 	hl,bc
    	ld 	(SEED1),hl
SEED2	equ 	$+1
    	ld 	hl,5678
    	add 	hl,hl
    	sbc 	a,a
    	and 	%00101101
    	xor 	l
    	ld 	l,a
    	ld 	(SEED2),hl
    	add 	hl,bc
	ld      a, l		; Reg A = RND(255)
	and 	3		; Reg A = RND(3)
        pop     bc

LINE30:	CP	2		; IF Z=2 THEN 
	JR	Z, LINE40	; goto LINE40
	LD	IX, A2		; ELSE LINE30.  IX="A2 array"
	ld	d, 0			
	add	ix, de		; DE=array offset from for-to-next
	LD	(IX), 12	; A(A2,X)=12
	DEC	IX		;   x=x-1 --> X-1
	LD	(IX), 12	; A(A2,X-1)=12
	INC	IX		;   x=x+1 --> back to X
	INC	IX		;   x=x+1 --> X+1
	LD	(IX), 8		; A(A2,X+1)=8
	JP	line30b

LINE40: LD	IX, A1		; IX=A1 array.		
	add	ix, de		; DE=array offset from for-to-next
	LD	A, (IX)	
	OR	10
	LD	(IX), A		; A(A1,X)=A(A1,X) OR 10
	LD	IX, A2		; IX=A2 array		
	add	ix, de		
	LD	(IX), 10	; A(A2,X)=10	
	LD	IX, A3		; IX=A3 array.
	add	ix, de
	LD	(IX), 8		; A(A3,X)=8

line30b:INC	B		; STEP2 from for-to-next
	INC	B
	LD	A, B		; comparison for loop
	CP	32		; If > 32
	JR	C, LOOP1	; then jump		

LINE50:	LD	IX, A1	-1	; set A1 array
	ld	b, 32		; FORX=1TO32
	PUSH	DE
	LD	DE, $7000 + 480-1	 ; Get destination for POKE
loop4:	LD	A, (IX)		; load IX to OR yellow blocks
	OR	128+16		; +16 for POKE blocks
	ld	(de), a		; POKE@DE,A1-blocks
	inc	e		; INC POKE offset
	LD	A, 0		
	LD	(IX), A		; A(A1,X)=0
	INC	IX		; inc A1 array offset.
	djnz	loop4		; NEXTX
	POP	DE
	LD	A, 10		; FORCE a <CR> at each offset 32
	CALL	$033A		; Write out character <CR>

LINE60:	LD	B, 33		; AA = A1
	LD	IX, A0		; destination
	LD	IY, A1		; source
	call	move		; move array
	LD	B, 33		; A1 = A2
	LD	IX, A1		; destination
	LD	IY, A2		; source
	call	move		; move array
	LD	B, 33		; A2 = A3
	LD	IX, A2		; destination
	LD	IY, A3		; source
	call	move		; move array
	LD	B, 33		; A3 = AA
	LD	IX, A3		; destination
	LD	IY, A0		; source
	call	move		; move array
	LD	A, 3		; C=3-c
	SUB	c
	LD	C, A
	JP	ST0		; GOTO 20

move:	LD	A, (IY)		; move array
	LD	(IX), A		; IY=source
	INC	IX		; IX=destination.
	INC	IY
	DJNZ	move		; Loop B number of times.
	ret
	DEFB	0
;SEED3:  DEFB 	8765
;SEED4:	DEFB 	4321, 0

A0	EQU 	$
A1	EQU	$ + 34
A2	EQU	$ + 34 + 34
A3	EQU	$ + 34 + 34 + 34


