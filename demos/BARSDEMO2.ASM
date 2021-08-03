; F3: JOINING E + circle together.
;
; ASSEMBLE WITH PASMO assembler.
;
; JMP TO BASIC		JP 	$1A1F
;
;
;	black = 128	white   = 207
;	green = 143	cyan    = 223
; 	yellow= 159	magenta = 239
;	blue  = 175	buff    = 255
;	red   = 191



        ORG    8000h
GRAFX_MEM_BUFFER	EQU	$A000		; GRAFX BUFFER
GRAFX_MEM_VIDEO		EQU	$7000		; GRAFX VIDEO
video_buffer_offset	EQU	$4000	; +$7000 = buffer at : $B000 

intro:	di

	ld	l, 24		; X = 64
	ld	h, 8		; y = 32
	push	hl
	pop	ix		; IX = initial coords of Squig.


	ld	hl, 	circle
	ld	de, 	array0
	ld	c, 82
	ldir


	ld 	hl,$b000		; CLS BUFFER
	ld 	(hl),96
	ld 	de,$b001
	ld 	bc,2048
	ldir
	ld 	hl,$7000		; CLS VIDEO
	ld 	(hl),96
	ld 	de,$7001
	ld 	bc,2048
	ldir


starty:
;=============================
; VERTICAL BARS
;=============================
	ld	b, 64
vert:	push	bc
	ld	hl, 00
	ld	a, (counter1)
	call	dis2	
	ld	hl, 01
	ld	a, (counter2)
	call	dis2	
	ld	hl, 02
	ld	a, (counter3)
	call	dis2	
	ld	hl, 03
	ld	a, (counter4)
	call	dis2	
	ld	hl, 04
	ld	a, (counter5)
	call	dis2	
	ld	hl, 05
	ld	a, (counter6)
	call	dis2	
	ld	hl, 06
	ld	a, (counter7)
	call	dis2	
	ld	hl, 07
	ld	a, (counter8)
	call	dis2	
	ld	hl, 08
	ld	a, (counter9)
	call	dis2	
	ld	hl, 09
	ld	a, (counter1)
	call	dis2	
	ld	hl, 10
	ld	a, (counter2)
	call	dis2	
	ld	hl, 11
	ld	a, (counter3)
	call	dis2	
	ld	hl, 12
	ld	a, (counter4)
	call	dis2	
	ld	hl, 13
	ld	a, (counter5)
	call	dis2	
	ld	hl, 14
	ld	a, (counter6)
	call	dis2	
	ld	hl, 15
	ld	a, (counter7)
	call	dis2	
	ld	hl, 16
	ld	a, (counter8)
	call	dis2	
	ld	hl, 17
	ld	a, (counter9)
	call	dis2	
	ld	hl, 18
	ld	a, (counter1)
	call	dis2	
	ld	hl, 19
	ld	a, (counter2)
	call	dis2	
	ld	hl, 20
	ld	a, (counter3)
	call	dis2	
	ld	hl, 21
	ld	a, (counter4)
	call	dis2	
	ld	hl, 22
	ld	a, (counter5)
	call	dis2	
	ld	hl, 23
	ld	a, (counter6)
	call	dis2	
	ld	hl, 24
	ld	a, (counter7)
	call	dis2	
	ld	hl, 25
	ld	a, (counter8)
	call	dis2	
	ld	hl, 26
	ld	a, (counter9)
	call	dis2	
	ld	hl, 27
	ld	a, (counter1)
	call	dis2	
	ld	hl, 28
	ld	a, (counter2)
	call	dis2	
	ld	hl, 29
	ld	a, (counter3)
	call	dis2	
	ld	hl, 30
	ld	a, (counter4)
	call	dis2	
	ld	hl, 31
	ld	a, (counter5)
	call	dis2	
	ld	hl, (counter9)
	ld	(counter10), hl
	ld	hl, (counter8)
	ld	(counter9), hl
	ld	hl, (counter7)
	ld	(counter8), hl
	ld	hl, (counter6)
	ld	(counter7), hl
	ld	hl, (counter5)
	ld	(counter6), hl
	ld	hl, (counter4)
	ld	(counter5), hl
	ld	hl, (counter3)
	ld	(counter4), hl
	ld	hl, (counter2)
	ld	(counter3), hl
	ld	hl, (counter1)
	ld	(counter2), hl
	ld	hl, (counter10)
	ld	(counter1), hl


	call	squig

	LD 	hl,0x6800
vsync1:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,vsync1
	ld	hl, $b000		; BLIT buffer to video
	ld	de, $7000
	ld	bc, 1024
	ldir
;	ld	hl, $b000 + 1024
;	ld	de, $7000 + 1024
;	ld	bc, 1024
;	ldir
	LD 	hl,0x6800
vsync2:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,vsync2
;	ld 	hl,$b000		; CLS BUFFER
;	ld 	(hl),96
;	ld 	de,$b001
;	ld 	bc,2048
;	ldir
	pop	bc
	dec	b	
	ld	a, b
	or	b



	jr	z, horizon
	jp	vert



;=============================
; HORIZONTAL BARS
;=============================
horizon:ld	b, 64

hor:	push	bc
	ld	hl, 00
	ld	a, (counter1)
	call 	display
	ld	hl, 32
	ld	a, (counter2)
	call	display
	ld	hl, 64
	ld	a, (counter3)
	call	display
	ld	hl, 96
	ld	a, (counter4)
	call	display
	ld	hl, 128
	ld	a, (counter5)
	call	display
	ld	hl, 160
	ld	a, (counter6)
	call	display
	ld	hl, 192
	ld	a, (counter7)
	call	display
	ld	hl, 224
	ld	a, (counter8)
	call	display
	ld	hl, 256
	ld	a, (counter9)
	call	display
	ld	hl, 288
	ld	a, (counter1)
	call	display
	ld	hl, 320
	ld	a, (counter2)
	call	display
	ld	hl, 352
	ld	a, (counter3)
	call	display
	ld	hl, 384
	ld	a, (counter4)
	call	display
	ld	hl, 416
	ld	a, (counter5)
	call	display
	ld	hl, 448
	ld	a, (counter6)
	call	display
	ld	hl, 480
	ld	a, (counter7)
	call	display
	ld	hl, (counter9)
	ld	(counter10), hl
	ld	hl, (counter8)
	ld	(counter9), hl
	ld	hl, (counter7)
	ld	(counter8), hl
	ld	hl, (counter6)
	ld	(counter7), hl
	ld	hl, (counter5)
	ld	(counter6), hl
	ld	hl, (counter4)
	ld	(counter5), hl
	ld	hl, (counter3)
	ld	(counter4), hl
	ld	hl, (counter2)
	ld	(counter3), hl
	ld	hl, (counter1)
	ld	(counter2), hl
	ld	hl, (counter10)
	ld	(counter1), hl

	call	squig

	LD 	hl,0x6800
hsync1:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,hsync1
	ld	hl, $b000
	ld	de, $7000
	ld	bc, 1024
	ldir
	ld	hl, $b000 + 1024
	ld	de, $7000 + 1024
	ld	bc, 1024
	ldir
	LD 	hl,0x6800
hsync2:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,hsync2
	ld 	hl,$b000		; CLS BUFFER
	ld 	(hl),96
	ld 	de,$b001
	ld 	bc,2048
	ldir
	pop	bc
	dec	b	
	ld	a, b
	or	b
	jr	z, diagonl
	jp	hor



;===============
;DIAGONAL
;===============
diagonl:ld	b, 64
diag:	push	bc
	ld	de, $7000 + video_buffer_offset ; 28672	; Line 1
	ld	hl, row1
	ld	bc, 32
	ldir
	ld	de, $7020 + video_buffer_offset	; 28704	; LINE 2
	ld	hl, row2
	ld	c, 32
	ldir
	ld	de, $7040 + video_buffer_offset	; 28736	; LINE 3
	ld	hl, row3
	ld	c, 32
	ldir
	ld	de, $7060 + video_buffer_offset	; 28768	; LINE 4
	ld	hl, row4
	ld	c, 32
	ldir
	ld	de, $7080 + video_buffer_offset	; 28800	; LINE 5
	ld	hl, row5
	ld	c, 32
	ldir
	ld	de, $70a0 + video_buffer_offset	; 28832	; LINE 6
	ld	hl, row6
	ld	c, 32
	ldir
	ld	de, $70c0 + video_buffer_offset	; 28864	; LINE 7
	ld	hl, row7
	ld	c, 32
	ldir
	ld	de, $70e0 + video_buffer_offset	; 28896	; LINE 8
	ld	hl, row8
	ld	c, 32
	ldir
	ld	de, $7100 + video_buffer_offset ; 28928	; LINE 9 
	ld	hl, row9
	ld	c, 32
	ldir
	ld	de, $7120 + video_buffer_offset	; 28960	; LINE 	10
	ld	hl, row10
	ld	c, 32
	ldir
	ld	de, $7140 + video_buffer_offset	; 28992	; LINE 	11
	ld	hl, row11
	ld	c, 32
	ldir
	ld	de, $7160 + video_buffer_offset	; 29024	; LINE 	12
	ld	hl, row12
	ld	c, 32
	ldir
	ld	de, $7180 + video_buffer_offset	; 29056	; LINE 	13
	ld	hl, row13
	ld	c, 32
	ldir
	ld	de, $71A0 + video_buffer_offset	; 29088	; LINE 	14
	ld	hl, row14
	ld	c, 32
	ldir
	ld	de, $71C0 + video_buffer_offset	; 29120	; LINE 	15
	ld	hl, row15
	ld	c, 32
	ldir
	ld	hl, $71E0 + video_buffer_offset	; 29152	; LINE 	16
	ld	hl, row16
	ld	c, 32
	ldir

	call	squig

	LD 	hl,0x6800
dsync1:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,dsync1
	ld	hl, $b000		; BLIT BUFFER TO VIDEO FIRST 1024
	ld	de, $7000
	ld	bc, 2048
	ldir
	LD 	hl,0x6800
dsync2:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,dsync2
;	ld	hl, $b000+1024		; BLIT BUFFER TO VIDEO second 1024
;	ld	de, $7000+1024
;	ld	bc, 1024
;	ldir
	LD 	hl,0x6800
dsync3:BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,dsync3

	ld	hl, row15
	ld	de, row16
	ld	bc, 32
	ldir
	ld	hl, row14
	ld	de, row15
	ld	bc, 32
	ldir
	ld	hl, row13
	ld	de, row14
	ld	bc, 32
	ldir
	ld	hl, row12
	ld	de, row13
	ld	bc, 32
	ldir
	ld	hl, row11
	ld	de, row12
	ld	bc, 32
	ldir
	ld	hl, row10
	ld	de, row11
	ld	bc, 32
	ldir
	ld	hl, row9
	ld	de, row10
	ld	bc, 32
	ldir
	ld	hl, row9
	ld	de, rowtemp
	ld	bc, 32
	ldir
	ld	hl, row8
	ld	de, row9
	ld	bc, 32
	ldir
	ld	hl, row7
	ld	de, row8
	ld	bc, 32
	ldir
	ld	hl, row6
	ld	de, row7
	ld	bc, 32
	ldir
	ld	hl, row5
	ld	de, row6
	ld	bc, 32
	ldir
	ld	hl, row4
	ld	de, row5
	ld	bc, 32
	ldir
	ld	hl, row3
	ld	de, row4
	ld	bc, 32
	ldir
	ld	hl, row2
	ld	de, row3
	ld	bc, 32
	ldir
	ld	hl, row1
	ld	de, row2
	ld	bc, 32
	ldir
	ld	hl, rowtemp
	ld	de, row1
	ld	bc, 32
	ldir
	pop	bc
	dec	b	
	ld	a, b
	or	a
	jr	z, here4
	jp	diag

here4:	jp	starty






;===================================================
;HORIZONTAL DISPLAY CALLED ROUTINE
;=================================
display:ld	de, $B000	;  DE = VIDEO BUFFER
	add	hl, de		;  HL = VIDEO buffer + HL offset for start of bars.
	push hl
	LD 	hl,0x6800
vsync3:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,vsync3
	pop hl
	ld 	b,32
l1:	ld	(hl), a
	inc	hl
	djnz	l1
	ret

;=====================================================
;VERTICAL DISPLAY CALLED ROUTINE
;===============================
dis2:	ld	de, $B000	;  DE = VIDEO BUFFER
	add	hl, de		;  HL = VIDEO buffer + HL offset for start of bars.
	ld 	b,16
l2:	ld	(hl), a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	djnz	l2
	ret


;=================================================
; SQUIG
;======



; ===========================================
; VZ SQUIG - 	: MODE 0 
; ===========================================
; 
;

squig:	push	ix
	pop	hl		; retrieve X & Y from IX. h=y. l=x.

;> To compare stuff, simply do a CP, 
;> if the zero flag is set, A and the argument were equal, 
;> if the carry is set the argument was greater, 
;> if neither is set, then A must be greater 

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
	ld	de, (array0)
	ld	(array100), de

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
	ld	c, 159;143;255;128			; COLOR 1
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
	ld	c, 128
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
	ld	c, 191			; COLOR 2
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
	ld	hl, (array62)
	call	vz_plot1

	ld	hl, (array97)
	ld	c, 175			; COLOR 3
	call	vz_plot1
	ld	hl, (array98)
	call	vz_plot1
	ld	hl, (array99)
	call	vz_plot1
	ld	hl, (array100)
	call	vz_plot1

	push	hl
	pop	ix

	ret



debug:
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   Press <S> to Start				
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	push	af
loop3:	ld 	a, (0x68fd)	
	and	0x02
	jr	z, You_Pressed_S
	jr 	nz, loop3
You_Pressed_S:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   Press <SPACE> to Start				
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
loop4:	ld 	a, (0x68ef)	
	and	0x10
	jr	z,  You_pressed_space
	jr 	nz, loop4
You_pressed_space:
	pop	af

	ret




; ===========================================
vz_plot1:		; 	c = colour
			;	l = X
			; 	h = Y
; ===========================================
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
	ld	de, $b000	; add buffer
	add	hl, de
	ld	a, c
        ld      (hl), a
	pop	af
	pop	hl
	pop	de
	pop	bc
	ret


; ===========================================
; 4.3 billion RND(). Output:  reg A 0-255.
; ===========================================
vz_rand4:push	hl
	push	bc
	push	de
    	ld 	hl,(rndseed1)
    	ld 	b,h
    	ld 	c,l
    	add 	hl,hl
    	add 	hl,hl
    	inc 	l
    	add 	hl,bc
    	ld 	(rndseed1),hl
    	ld 	hl,(rndseed2)
    	add 	hl,hl
    	sbc 	a,a
    	and 	%00101101
    	xor 	l
    	ld 	l,a
    	ld 	(rndseed2),hl
    	add 	hl,bc
	ld	a, l
	pop	de
	pop	bc
	pop	hl
	ret









;====================================
; VERTICAL   DEF BYTES
; HORIZONTAL DEF BYTES
;====================================


;	black = 128	white   = 207
;	green = 143	cyan    = 223
; 	yellow= 159	magenta = 239
;	blue  = 175	buff    = 255
;	red   = 191

counter0	defb 	128
counter1 	defb 	143
counter2 	defb 	159
counter3 	defb 	175
counter4 	defb 	191
counter5 	defb 	207
counter6 	defb 	223
counter7 	defb 	239
counter8 	defb 	255
counter9 	defb 	128
counter10	defb    143


		defb	0
		defb	0


;=======================================
; DIAGONALS DEF bytes
;=======================================
;	black = 128	white   = 207
;	green = 143	cyan    = 223
; 	yellow= 159	magenta = 239
;	blue  = 175	buff    = 255
;	red   = 191

row1	defb	143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239
row2	defb	159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255
row3	defb	175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128
row4	defb	191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143
row5	defb	207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159
row6	defb	223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175
row7	defb	239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191
row8	defb	255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207
row9 	defb	128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223
row10	defb	143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239
row11	defb	159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255
row12	defb	175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128
row13	defb	191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143
row14	defb	207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159
row15	defb	223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175
row16	defb	239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191
rowtemp	defb	255,255,128,128,143,143,159,159,175,175,191,191,207,207,223,223,239,239,255,255,128,128,143,143,159,159,175,175,191,191,207,207


;==========================================
; SQUIG DEF bytes
;==========================================
	dw	0
array0	DW	0;128
array1	DW	0;128
array2	DW	0;128
array3	DW	0;128
array4	DW	128
array5	DW	128
array6	DW	128
array7	DW	128
array8	DW	128
array9	DW	128
array10	DW	128
array11	DW	128
array12	DW	143
array13	DW	143
array14	DW	143
array15	DW	143
array16	DW	143
array17	DW	143
array18	DW	143
array19	DW	143
array20	DW	143
array21	DW	143
array22	DW	159
array23	DW	159
array24	DW	159
array25	DW	159
array26	DW	159
array27	DW	159
array28	DW	159
array29	DW	159
array30	DW	159
array31	DW	159
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
array50 DW	0
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
	DW	0

rndseed1	DB 1234
rndseed2	DB 5678


; 34 x,y. 68 in total.
	defb  18,3
circle	defb  17,13, 16,13, 15,13, 14,13, 13,13, 12,13, 11,12, 10,12, 9,11, 8,10, 8,9, 8,8, 8,7, 8,6, 8,5
        defb  9,4, 10,3, 11,3, 12,2, 13,2, 14,2, 15,2, 16,2, 17,2, 18,2, 19,2, 20,3, 21,3, 22,4, 23,5, 23,6, 23,7
        defb  23,8, 23,9, 22,10, 22,11, 21,12, 20,12, 19,13, 18,13, 17,13, 16,13
	defb  15,13, 14,13


END
