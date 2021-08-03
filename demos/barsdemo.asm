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
	LD 	hl,0x6800
vsync1:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,vsync1
	ld	hl, $b000
	ld	de, $7000
	ld	bc, 1024
	ldir
	ld	hl, $b000 + 1024
	ld	de, $7000 + 1024
	ld	bc, 1024
	ldir
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

.END
