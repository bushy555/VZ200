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

starty:	ld	b, 139          ;121;70; 100
	ld	c, 0

starty2:ld	ix, sin		; IX = SIN Table pointer.
	ld	d, 0
	ld	e, b		; de = "FOR B = 70 to 1 STEP -1". Loop thru 70 points in SIN table.
	add	ix, de		; IX = SIN Table + FOR-TO-NEXT offset DE
	ld	a, (ix)		; A = SIN + variable offset
	ld	l, a
	ld	h, 0		; move 8bit A into 16bit HL for multiplying by 32.
 	ADD 	HL, HL	;\
  	ADD 	HL, HL	; \
  	ADD 	HL, HL 	;  | 	; HL = HL * 32
  	ADD 	HL, HL	; /
  	ADD 	HL, HL	;/			
				;  HL = Sin Table * 32 , which = screen pointer.
	ld	de, $B000	;  DE = VIDEO BUFFER
	add	hl, de		;  HL = VIDEO buffer + HL offset for start of bars.
				;  HL = screen position. 32, 64, 96, 128, 164 etc 


	push	bc
			;  FREE :   	
			; 		DE
			


	ld	(offset1), hl

	ld	hl, (offset21)
	ld	(offset22), hl
	ld	hl, (offset20)
	ld	(offset21), hl
	ld	hl, (offset19)
	ld	(offset20), hl
	ld	hl, (offset18)
	ld	(offset19), hl
	ld	hl, (offset17)
	ld	(offset18), hl
	ld	hl, (offset16)
	ld	(offset17), hl
	ld	hl, (offset15)
	ld	(offset16), hl
	ld	hl, (offset14)
	ld	(offset15), hl
	ld	hl, (offset13)
	ld	(offset14), hl
	ld	hl, (offset12)
	ld	(offset13), hl
	ld	hl, (offset11)
	ld	(offset12), hl
	ld	hl, (offset10)
	ld	(offset11), hl
	ld	hl, (offset9)
	ld	(offset10), hl
	ld	hl, (offset8)
	ld	(offset9), hl
	ld	hl, (offset7)
	ld	(offset8), hl
	ld	hl, (offset6)
	ld	(offset7), hl
	ld	hl, (offset5)
	ld	(offset6), hl
	ld	hl, (offset4)
	ld	(offset5), hl
	ld	hl, (offset3)
	ld	(offset4), hl
	ld	hl, (offset2)
	ld	(offset3), hl
	ld	hl, (offset1)
	ld	(offset2), hl

;	ld	hl, (offset1)
;	ld	a, 128
;	call	display
	ld	hl, (offset1)
	ld	a, 159 
	call	display
	ld	hl, (offset4)
	ld	a, 175 
	call	display
	ld	hl, (offset7)
	ld	a, 191 
	call	display
	ld	hl, (offset10)
	ld	a, 207 
	call	display
	ld	hl, (offset13)
	ld	a, 223 
	call	display
	ld	hl, (offset16)
	ld	a, 239 
	call	display
	ld	hl, (offset19)
	ld	a, 255
	call 	display
;	ld	hl, (offset22)
;	ld	a, 128
;	call 	display


;	black = 128	white   = 207
;	green = 143	cyan    = 223
; 	yellow= 159	magenta = 239
;	blue  = 175	buff    = 255
;	red   = 191


;	LD 	hl,0x6800
;sync2:	BIT 	7,(hl)			; fancy wait retrace.
;	jr	NZ,sync2

	ld	hl, $b000
	ld	de, $7000
	ld	bc, 2048
	ldir

;	ld	hl, $b000 + 1024
;	ld	de, $7000 + 1024
;	ld	bc, 1024
;	ldir

	ld 	hl,$b000		; CLS BUFFER
	ld 	(hl),96
	ld 	de,$b001
	ld 	bc,2048
	ldir


	pop	bc
	dec	b
	ld	a, b
	and	a
	jr	nz, here2

	jp	starty
;	ld	b, 139;140;128;70; 100
;	ld	c, 0

here2:	jp	starty2


;	djnz	starty2
;	jp	starty


display:
	ld 	b,32
l1:	ld	(hl), a
	inc	hl
	djnz	l1

	ret	






sin: 	
	defb 08,08			; middle 2	; 2
	defb 09,09					; 2
	defb 10,10					; 2
	defb 11,11,11					; 3
	defb 12,12,12,12,12				; 5
	defb 13,13,13,13,13,13,13			; 7
	defb 14,14,14,14,14,14,14,14,14			; 9
	defb 15,15,15,15,15,15,15,15,15,15		; 10
	defb 14,14,14,14,14,14,14,14,14			; 9
	defb 13,13,13,13,13,13,13			; 7
	defb 12,12,12,12,12				; 5
	defb 11,11,11					; 3
	defb 10,10					; 2
	defb 09,09					; 2
	defb 08,08			; middle 2	; 2
	defb 07,07			; middle 1	; 2
	defb 06,06					; 2
	defb 05,05					; 2
	defb 04,04,04					; 3
	defb 03,03,03,03,03				; 5
	defb 02,02,02,02,02,02,02			; 7
	defb 01,01,01,01,01,01,01,01,01			; 9
	defb 00,00,00,00,00,00,00,00,00,00		; 10
	defb 01,01,01,01,01,01,01,01,01			; 9
	defb 02,02,02,02,02,02,02			; 7
	defb 03,03,03,03,03				; 5
	defb 04,04,04					; 3
	defb 05,05					; 2
	defb 06,06					; 2
	defb 07,07			; middle 1	; 2




	defb 06,06					; 2
	defb 05,05					; 2
	defb 04,04,04					; 3
	defb 03,03,03,03,03				; 5
	defb 02,02,02,02,02,02,02			; 7
	defb 01,01,01,01,01,01,01,01,01			; 9
	defb 00,00,00,00,00,00,00,00,00,00		; 11


temp2: 	defb 00,00,00,00,00,00,00,00,00,00
	defb 01,01,01,01,01,01,01,01,01
	defb 02,02,02,02,02,02,02
	defb 03,03,03,03,03

temp:	defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	defb 14,14,14,14,14,14,14			; 7
	defb 13,13,13,13,13,13				; 6
	defb 12,12,12,12				; 4
	defb 11,11,11					; 3
	defb 10,10					; 2
	defb 09,09					; 2
	defb 08,07			; middle 2	; 2
	defb 07,07			; middle 1	; 2
	defb 06,06					; 2
	defb 05,05					; 2
	defb 04,04,04					; 3
	defb 03,03,03,03				; 4
	defb 02,02,02,02,02,02				; 6
	defb 01,01,01,01,01,01,01			; 7
	defb 00,00,00,00,00,00,00,00			; 8
	defb 01,01,01,01,01,01,01			; 7
	defb 02,02,02,02,02,02				; 6
	defb 03,03,03,03				; 4
	defb 04,04,04					; 3
	defb 05,05					; 3
	defb 06,06					; 2
	defb 07,07			; middle 1	; 2
	defb 08,08			; middle 2	; 2
	defb 09,09					; 2
	defb 10,10					; 2
	defb 11,11,11					; 3
	defb 12,12,12,12				; 4
	defb 13,13,13,13,13,13				; 6
	defb 14,14,14,14,14,14,14			; 7
	defb 15,15,15,15,15,15,15,15			; 8



offset1 	defw 0
offset2 	defw 0
offset3 	defw 0
offset4 	defw 0
offset5 	defw 0
offset6 	defw 0
offset7 	defw 0
offset8 	defw 0
offset9 	defw 0
offset10	defw 0
offset11	defw 0
offset12	defw 0
offset13	defw 0
offset14	defw 0
offset15	defw 0
offset16	defw 0
offset17	defw 0
offset18	defw 0
offset19	defw 0
offset20	defw 0
offset21	defw 0
offset22	defw 0


.END
