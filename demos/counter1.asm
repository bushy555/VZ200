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

SPR_HEIGHT 		EQU 	50		; symbolic constants
SPR_WIDTH  		EQU 	88
GRAFX_MEM_BUFFER	EQU	$A000		; GRAFX BUFFER
GRAFX_MEM_VIDEO		EQU	$7000		; GRAFX VIDEO


intro:	
	di

starty:

	ld	hl, 0


starty2:


	push	hl
	CALL 0FAFh		; DISPLAY HL
	pop	hl

	inc	hl

	ld	de, 78a6h
	ld	a, 32
	ld	(de), a

	jr starty2


.END
