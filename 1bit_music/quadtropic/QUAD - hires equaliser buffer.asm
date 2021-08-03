;quattropic
;beeper engine by utz 08'2015
; With MODE (1) graphics equailiser. 4 pixels wide. With screen buffer.
; Assemble with PASMO.EXE
; Found here : http://pasmo.speccy.org/
;
; pasmo quad.asm
; rbinary quad.obj quad.vz
;
; Load into VZEMU, MAME, or on a real VZ200 / VZ300.
;

;HL  = add counter ch1/noise
;DE  = base freq ch1/noise
;IX  = add counter ch2
;BC  = base freq ch2
;IY  = add counter ch3
;DE' = base freq ch3
;HL' = add counter ch4
;SP  = base freq ch4
;BC' = timer


	org $8000
;	org origin


;	call	$01c9		; VZ ROM CLS
;	ld	hl, MSG1	; Print MENU
;	call	$28a7		; VZ ROM Print string.
;	ld	hl, MSG2	; Print MENU
;	call	$28a7		; VZ ROM Print string.
;	ld	hl, MSG3	; Print MENU
;	call	$28a7		; VZ ROM Print string.


	ld 	hl, $A000;28672	; CLEAR Equaliser SCREEN
	ld	bc, 2048			; to a dark green background
l00:	ld	(hl), 0
	inc	hl
	djnz	l00			; LDIR doesn't work properly for some reason


	di
init
	ei			;detect kempston
;	halt
;	in a,($1f)
;	inc a
;	jr nz,_skip
;	ld (maskKempston),a
_skip	
	di
	exx
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,musicdata
	ld a,(hl)
	ld (speed),a
	inc hl
	ld (seqpntr),hl

;******************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0
	
	;jp exit		;uncomment to disable looping
	
	ld sp,loop		;get loop point
	jr rdseq+3

;******************************************************************
rdptn0
	ld (patpntr),de	
rdptn
;	in a,($1f)		;read joystick
;maskKempston equ $+1
;	and $1f
;	ld c,a
;	in a,($fe)		;read kbd
;	cpl
;	or c
;	and $1f
;	jp nz,exit



;
; With grahical equaliser.
;
;





;	ld 	($A000+128+128), a
;	ld	a, c
;	ld 	($A000+128+128 + 2), a
;	ld	a, b
;	ld 	($A000+128+128 + 4), a
;	ld	a, d
;	ld 	($A000+128+128 + 6), a
;	ld	a, e
;	ld 	($A000+128+128 + 8), a
;	ld	a, h
;	ld 	($A000+128+128 + 10), a
;	ld	a, l
;	ld 	($A000+128+128 + 12), a
;
;	USED	: A,B,C,D,E,H
;	NOT USED: L

;	push	af
	push	hl
	push	bc
	push	de
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push	hl
	push	de
	push	bc


	ld 	hl, $A000;28672		; DUMPS DBL-SCRN-BUFFER TO SCREEN 
	ld	de, 28672		; A000 is screen buffer
	ld	bc, 2048
	ldir


	push	af
	ld	a, 0				; CLEAR BUFFER Equaliser SCREEN
	ld	($A000), a			; essenitally a CLS
	ld 	hl, $A000
	ld	de, $A001 ;28673
	ld	bc, 2048

	ldir

	pop	af

	ld 	hl, $A000+160+12+320+512+512+512		; Do  reg A
	ld	c, a
	srl	a			; Divide A by 2 five times.
	srl	a
;	srl	a
;	srl	a
;	srl	a
	inc	a
	ld	b ,a
l1:	ld	(hl), 85		; colour
	inc	hl			; inc 3x pixels wide
	ld	(hl), 85
	inc	hl
	ld	(hl), 85
	inc	hl
	ld	(hl), 85
	ld	de, 65501		; sub 32, by adding 65536-32-3pixels
	add 	hl, de			; do the subraction of adding 32
	djnz	l1			; done 'B' times.


;	jp here

	pop	bc				; Do reg B
	ld	a, b
	ld	c, b
	srl	a
	srl	a
;	srl	a
;	srl	a
;	srl	a
	inc	a
	ld	b ,a
	ld 	hl, $A000+160+320+512+512+512
l2:	ld	(hl), 170
	inc	hl
	ld	(hl), 170
	inc	hl
	ld	(hl), 170
	inc	hl
	ld	(hl), 170
	ld	de, 65501
	add 	hl, de
	djnz	l2


						; DO reg C
	ld	a, c
	srl	a
	srl	a
;	srl	a
;	srl	a
;	srl	a
	inc	a
	ld	b, a
	ld 	hl, $A000+160+16+320+512+512+512
l3:	ld	(hl), 255 ;c			;159
	inc	hl
	ld	(hl), 255
	inc	hl
	ld	(hl), 255
	inc	hl
	ld	(hl), 255
	ld	de, 65501 	
	add 	hl, de
	djnz	l3


	pop	de				; DO reg D
	ld	a, d
	ld	c, e				; save E
	srl	a
	srl	a
;	srl	a
;	srl	a
;	srl	a
	inc	a
	ld	b, a
	ld 	hl, $A000+160+4+320+512+512+512
l4:	ld	(hl), 85;c
	inc	hl
	ld	(hl), 85;c
	inc	hl
	ld	(hl), 85;c
	inc	hl
	ld	(hl), 85;c
	ld	de, 65501
	add 	hl, de
	djnz	l4


	ld	a, c			; DO REG E
	srl	a
	srl	a
;	srl	a
;	srl	a
;	srl	a
	inc	a
	ld	b, a
	ld 	hl, $A000+160+20+320+512+512+512
l42:	ld	(hl), 170;c
	inc	hl
	ld	(hl), 170;c
	inc	hl
	ld	(hl), 170;c
	inc	hl
	ld	(hl), 170;c
	ld	de, 65501
	add 	hl, de
	djnz	l42


	pop	hl				; DO reg H
	ld	a, h
	srl	a
	srl	a
;	srl	a
;	srl	a
;	srl	a
	inc	a
	ld	b, a
	ld 	hl, $A000+160+8+320+512+512+512
l5:	ld	(hl), 255 ;c			;159
	inc	hl
	ld	(hl), 255;c
	inc	hl
	ld	(hl), 255;c
	inc	hl
	ld	(hl), 255;c
	ld	de, 65501
	add 	hl, de
	djnz	l5


	push	ix				;DO REG IX
	pop	hl
	ld	a, l
	srl	a
	srl	a
;	srl	a
;	srl	a
;	srl	a
	inc	a
	ld	b, a
	ld 	hl, $A000+160+24+320+512+512+512
l52:	ld	(hl), 85;c			;159
	inc	hl
	ld	(hl), 85;c
	inc	hl
	ld	(hl), 85;c
	inc	hl
	ld	(hl), 85;c
	ld	de, 65501
	add 	hl, de
	djnz	l52


	push	iy				;DO REG IY
	pop	hl
	ld	a, l
;	ld	c, h
	srl	a
	srl	a
;	srl	a
;	srl	a
;	srl	a
	inc	a
	ld	b, a
	ld 	hl, $A000+160+28+320+512+512+512
l53:	ld	(hl), 170;c			;159
	inc	hl
	ld	(hl), 170;c
	inc	hl
	ld	(hl), 170;c
	inc	hl
	ld	(hl), 170;c
	ld	de, 65501
	add 	hl, de
	djnz	l53


here:





	POP	DE
	POP	BC
	POP	HL
;	POP	AF




speed equ $+2
	ld bc,0			;timer
	exx

patpntr equ $+1			;fetch pointer to pattern data
	ld sp,0

	pop af
	jr nz,nrdseq
	jp rdseq
nrdseq
	
	jp c,noiseCore
	jp pe,slideCore
	jp m,noiseslideCore

;******************************************************************
regularCore
	ld (ch1Length),a
	
	ld a,33
	ld (stopch),a

	pop hl			;duty1,2
	ld a,h
	ld (duty1),a
	ld a,l
	ld (duty2),a
	
	pop hl			;duty3,4
	ld a,h
	ld (duty3),a
	ld a,l
	ld (duty4),a
	
	pop de			;freq1	
	pop bc			;freq2
	
	ld hl,0
	ld ix,0
	ld iy,0

	exx
	
	pop de			;freq3
	pop hl			;freq4
	
	ld (patpntr),sp		;preserve data pointer
	ld sp,hl
	ld hl,0

;******************************************************************
playRegular
	exx			;4
	add hl,de		;11
	ld a,h			;4
duty1 equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33			;7
	or 8
	ld (26624), a		;11

	
	add ix,bc		;15
	ld a,ixh		;8
duty2 equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33		;7
	or 8
	ld (26624), a		;11

	nop			;4
	nop			;4
	
	exx			;4

	add hl,sp		;11
	ld a,h			;4
duty4 equ $+1
	cp $80			;7
	sbc a,a			;4
stopch equ $+1
	and 33		;7
	or 8
	ld (26624), a		;11


	add iy,de		;15
	ld a,iyh		;8
duty3 equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33		;7
	or 8
	ld (26624), a		;11		
	
	dec c			;4
	jr nz,playRegular	;12
				;224
	ld a,b
ch1Length equ $+1	
	sub $ff				;= timer - actual length
	jr z,_skip2
	djnz playRegular
	jp rdptn

_skip2
	ld (stopch),a
	
	djnz playRegular
	jp rdptn


;******************************************************************
noiseCore
	ld (ch1Lengtha),a
	
	ld a,33
	ld (stopcha),a

	pop hl			;duty1,2
	ld a,h
	ld (duty1a),a
	ld a,l
	ld (duty2a),a
	
	pop hl			;duty3,4
	ld a,h
	ld (duty3a),a
	ld a,l
	ld (duty4a),a
	
	pop de			;freq1
	
	pop bc			;freq2
	
	ld hl,0
	ld ix,0
	ld iy,0

	exx
	
	pop de			;freq3
	pop hl			;freq4
	
	ld (patpntr),sp		;preserve data pointer
	ld sp,hl
	ld hl,0

;******************************************************************
playNoise
	exx			;4
	add hl,de		;11
	ld a,h			;4
duty1a equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33			;7
	or 8
	ld (26624), a		;11
	
	add ix,bc		;15
	ld a,ixh		;8
duty2a equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33			;7
	or 8
	ld (26624), a		;11

	exx			;4
	rlc h

	add hl,sp		;11
	ld a,h			;4
duty4a equ $+1
	cp $80			;7
	sbc a,a			;4
stopcha equ $+1
	and 33			;7
	or 8
	ld (26624), a		;11

	add iy,de		;15
	ld a,iyh		;8
duty3a equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33			;7
	or 8
	ld (26624), a		;11		
	
	dec c			;4
	jr nz,playNoise		;12
				;224
	ld a,b
	
ch1Lengtha equ $+1	
	sub $ff				;= timer - actual length
	jr z,_skip3
	djnz playNoise
	jp rdptn

_skip3
	ld (stopcha),a
	djnz playNoise
	jp rdptn


;******************************************************************
slideCore
	ld (ch1Lengthb),a
	
	ld a,33
	ld (stopchb),a

	pop hl			;duty1,2
	ld a,h
	ld (duty1b),a
	ld a,l
	ld (duty2b),a
	
	pop hl			;duty3,4
	ld a,h
	ld (duty3b),a
	ld a,l
	ld (duty4b),a
	
	pop de			;freq1	
	pop bc			;freq2
	
	ld hl,0
	ld ix,0
	ld iy,0

	exx
	
	pop de			;freq3
	pop hl			;freq4
	
	ld (patpntr),sp		;preserve data pointer
	ld sp,hl
	ld hl,0

;******************************************************************
playSlide
	exx			;4
	add hl,de		;11
	ld a,h			;4
duty1b equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33			;7
	or 8
	ld (26624), a		;11
	
	add ix,bc		;15
	ld a,ixh		;8
duty2b equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33			;7
	or 8
	ld (26624), a		;11

	nop			;4	;;;;;;;;;
	nop			;4	;;;;;;;;;;
	exx			;4

	add hl,sp		;11
	ld a,h			;4
duty4b equ $+1
	cp $80			;7
	sbc a,a			;4
stopchb equ $+1
	and 33			;7
	or 8
	ld (26624), a		;11

	add iy,de		;15
	ld a,iyh		;8
duty3b equ $+1
	cp $80			;7
	sbc a,a			;4

	and 33			;7
	or 8
	ld (26624), a		;11		

	nop
	nop
	
	dec c			;4
	jr nz,playSlide		;12
				;224
	ld a,b
	
ch1Lengthb equ $+1	
	sub $ff				;= timer - actual length
	jr z,_skip4
	srl d
	djnz playSlide
	jp rdptn

_skip4
	ld (stopchb),a
	djnz playSlide
	jp rdptn


;******************************************************************
noiseslideCore
	ld (ch1Lengthc),a
	
	ld a,33
	ld (stopchc),a

	pop hl			;duty1,2
	ld a,h
	ld (duty1c),a
	ld a,l
	ld (duty2c),a
	
	pop hl			;duty3,4
	ld a,h
	ld (duty3c),a
	ld a,l
	ld (duty4c),a
	
	pop de			;freq1	
	pop bc			;freq2
	
	ld hl,0
	ld ix,0
	ld iy,0

	exx
	
	pop de			;freq3
	pop hl			;freq4
	
	ld (patpntr),sp		;preserve data pointer
	ld sp,hl
	ld hl,0

;******************************************************************
playNoiseSlide
	exx			;4
	add hl,de		;11
	ld a,h			;4
duty1c equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33			;7
	or 8
	ld (26624), a		;11
	
	add ix,bc		;15
	ld a,ixh		;8
duty2c equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33			;7
	or 8
	ld (26624), a		;11

	exx			;4
	;rlc h			;8

	add hl,sp		;11
	ld a,h			;4
duty4c equ $+1
	cp $80			;7
	sbc a,a			;4
stopchc equ $+1
	and 33		;7
	or 8
	ld (26624), a		;11

	add iy,de		;15
	ld a,iyh		;8
duty3c equ $+1
	cp $80			;7
	sbc a,a			;4
	and 33			;7
	or 8
	ld (26624), a		;11		
	
	rlc h
	dec c			;4
	jr nz,playNoiseSlide	;12
				;224
	ld a,b
	
ch1Lengthc equ $+1	
	sub $ff				;= timer - actual length
	jr z,_skip5
	srl d
	djnz playNoiseSlide
	jp rdptn

_skip5
	ld (stopchc),a
	djnz playNoiseSlide
	jp rdptn


;******************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************

MSG1	db "QUADTROPIC ENGINE. BY UTZ"
	db $0d,0
MSG2	db "VZ CONVERSION BY BUSHY.",0
MSG3	db "AUG'19.",$0d,0

musicdata

	db $4		;speed

;sequence
loop
	dw ptn0
	dw ptn0
	dw ptn1
	dw ptn0
	dw ptn4
	dw ptn2
	dw ptn3
	dw ptn5
	dw 0

;pattern data
ptn0
	dw $ff04,$8080,$8000,$180,$300,$600,$0
	dw $ff00,$8080,$0,$180,$391,$0,$0
	dw $401,$8080,$8020,$180,$47f,$c0,$18bb
	dw $401,$8080,$8020,$180,$558,$c0,$18bb
	dw $ff80,$8080,$8040,$300,$600,$600,$cba
	dw $ff00,$8080,$0,$300,$723,$0,$0
	dw $401,$8080,$8020,$300,$8fd,$c0,$18bb
	dw $401,$8080,$8020,$300,$ab1,$c0,$18bb
	dw $ff04,$8040,$8000,$180,$300,$600,$0
	dw $ff00,$8040,$0,$180,$391,$0,$0
	dw $401,$8040,$8020,$180,$47f,$c0,$18bb
	dw $401,$8040,$8020,$180,$558,$c0,$18bb
	dw $ff80,$8040,$8040,$300,$600,$600,$cba
	dw $ff00,$8040,$0,$300,$723,$0,$0
	dw $401,$8040,$8020,$300,$8fd,$c0,$18bb
	dw $401,$8040,$8020,$300,$ab1,$c0,$18bb
	dw $ff04,$8020,$8000,$180,$300,$600,$0
	dw $ff00,$8020,$0,$180,$391,$0,$0
	dw $401,$8020,$8020,$180,$47f,$c0,$18bb
	dw $401,$8020,$8020,$180,$558,$c0,$18bb
	dw $ff80,$8020,$8040,$300,$600,$600,$cba
	dw $ff00,$8020,$0,$300,$723,$0,$0
	dw $401,$8020,$8020,$300,$8fd,$c0,$18bb
	dw $401,$8020,$8020,$300,$ab1,$c0,$18bb
	dw $ff04,$8010,$8000,$1c9,$300,$600,$0
	dw $ff00,$8010,$0,$1c9,$391,$0,$0
	dw $401,$8010,$8020,$1c9,$47f,$e4,$18bb
	dw $401,$8010,$8020,$1c9,$558,$e4,$18bb
	dw $ff80,$8010,$8040,$391,$600,$600,$cba
	dw $ff00,$8010,$0,$391,$723,$0,$0
	dw $401,$8010,$8020,$391,$8fd,$e4,$18bb
	dw $401,$8010,$8020,$391,$ab1,$e4,$18bb
	dw $ff04,$8010,$8000,$180,$300,$600,$0
	dw $ff00,$8010,$0,$180,$391,$0,$0
	dw $401,$8010,$8020,$180,$47f,$c0,$18bb
	dw $401,$8010,$8020,$180,$558,$c0,$18bb
	dw $ff80,$8010,$8040,$300,$600,$600,$cba
	dw $ff00,$8010,$0,$300,$723,$0,$0
	dw $401,$8010,$8020,$300,$8fd,$c0,$18bb
	dw $401,$8010,$8020,$300,$ab1,$c0,$18bb
	dw $ff04,$8020,$8000,$180,$300,$600,$0
	dw $ff00,$8020,$0,$180,$391,$0,$0
	dw $401,$8020,$8020,$180,$47f,$c0,$18bb
	dw $401,$8020,$8020,$180,$558,$c0,$18bb
	dw $ff80,$8020,$8040,$300,$600,$600,$cba
	dw $ff00,$8020,$0,$300,$723,$0,$0
	dw $401,$8020,$8020,$300,$8fd,$c0,$18bb
	dw $401,$8020,$8020,$300,$ab1,$c0,$18bb
	dw $ff04,$8040,$8000,$180,$300,$600,$0
	dw $ff00,$8040,$0,$180,$391,$0,$0
	dw $401,$8040,$8020,$180,$47f,$c0,$18bb
	dw $401,$8040,$8020,$180,$558,$c0,$18bb
	dw $ff80,$8040,$8040,$300,$600,$600,$cba
	dw $ff00,$8040,$0,$300,$723,$0,$0
	dw $401,$8040,$8020,$300,$8fd,$c0,$18bb
	dw $401,$8040,$8020,$300,$ab1,$c0,$18bb
	dw $ff04,$8080,$8000,$47f,$300,$600,$0
	dw $ff00,$8080,$0,$47f,$391,$0,$0
	dw $401,$8080,$8020,$47f,$47f,$2d5,$18bb
	dw $401,$8080,$8020,$47f,$558,$2d5,$18bb
	dw $280,$8080,$8040,$391,$600,$600,$cba
	dw $401,$8080,$20,$391,$723,$0,$cd44
	dw $401,$8080,$8020,$391,$8fd,$2d5,$18bb
	dw $401,$8080,$8010,$391,$ab1,$2d5,$99a
	db $40

ptn1
	dw $ff04,$8080,$8000,$201,$401,$600,$0
	dw $ff00,$8080,$0,$201,$4c3,$0,$0
	dw $401,$8080,$8020,$201,$600,$100,$18bb
	dw $401,$8080,$8020,$201,$723,$100,$18bb
	dw $ff80,$8080,$8040,$401,$802,$600,$cba
	dw $ff00,$8080,$0,$401,$986,$0,$0
	dw $401,$8080,$8020,$401,$c00,$100,$18bb
	dw $401,$8080,$8020,$401,$e45,$100,$18bb
	dw $ff04,$8080,$8000,$201,$401,$600,$0
	dw $ff00,$8080,$0,$201,$4c3,$0,$0
	dw $401,$8080,$8020,$201,$600,$100,$18bb
	dw $401,$8080,$8020,$201,$723,$100,$18bb
	dw $ff80,$8080,$8040,$401,$802,$600,$cba
	dw $ff00,$8080,$0,$401,$986,$0,$0
	dw $401,$8080,$8020,$401,$c00,$100,$18bb
	dw $401,$8080,$8020,$401,$e45,$100,$18bb
	dw $ff04,$8040,$8000,$201,$401,$600,$0
	dw $ff00,$8040,$0,$201,$4c3,$0,$0
	dw $401,$8040,$8020,$201,$600,$100,$18bb
	dw $401,$8040,$8020,$201,$723,$100,$18bb
	dw $ff80,$8040,$8040,$401,$802,$600,$cba
	dw $ff00,$8040,$0,$401,$986,$0,$0
	dw $401,$8040,$8020,$401,$c00,$100,$18bb
	dw $401,$8040,$8020,$401,$e45,$100,$18bb
	dw $ff04,$8040,$8000,$262,$401,$600,$0
	dw $ff00,$8040,$0,$262,$4c3,$0,$0
	dw $401,$8040,$8020,$262,$600,$131,$18bb
	dw $401,$8040,$8020,$262,$723,$131,$18bb
	dw $ff80,$8040,$8040,$4c3,$802,$600,$cba
	dw $ff00,$8040,$0,$4c3,$986,$0,$0
	dw $401,$8040,$8020,$4c3,$c00,$131,$18bb
	dw $401,$8040,$8020,$4c3,$e45,$131,$18bb
	dw $ff04,$8020,$8000,$201,$401,$600,$0
	dw $ff00,$8020,$0,$201,$4c3,$0,$0
	dw $401,$8020,$8020,$201,$600,$100,$18bb
	dw $401,$8020,$8020,$201,$723,$100,$18bb
	dw $ff80,$8020,$8040,$401,$802,$600,$cba
	dw $ff00,$8020,$0,$401,$986,$0,$0
	dw $401,$8020,$8020,$401,$c00,$100,$18bb
	dw $401,$8020,$8020,$401,$e45,$100,$18bb
	dw $ff04,$8020,$8000,$201,$401,$600,$0
	dw $ff00,$8020,$0,$201,$4c3,$0,$0
	dw $401,$8020,$8020,$201,$600,$100,$18bb
	dw $401,$8020,$8020,$201,$723,$100,$18bb
	dw $ff80,$8020,$8040,$401,$802,$600,$cba
	dw $ff00,$8020,$0,$401,$986,$0,$0
	dw $401,$8020,$8020,$401,$c00,$100,$18bb
	dw $401,$8020,$8020,$401,$e45,$100,$18bb
	dw $ff04,$8010,$8000,$201,$401,$600,$0
	dw $ff00,$8010,$0,$201,$4c3,$0,$0
	dw $401,$8010,$8020,$201,$600,$100,$18bb
	dw $401,$8010,$8020,$201,$723,$100,$18bb
	dw $ff80,$8010,$8040,$401,$802,$600,$cba
	dw $ff00,$8010,$0,$401,$986,$0,$0
	dw $401,$8010,$8020,$401,$c00,$100,$18bb
	dw $401,$8010,$8020,$401,$e45,$100,$18bb
	dw $ff04,$8010,$8000,$156,$401,$600,$0
	dw $ff00,$8010,$0,$156,$4c3,$0,$0
	dw $401,$8010,$8020,$156,$600,$2d5,$18bb
	dw $401,$8010,$8020,$156,$723,$2d5,$18bb
	dw $280,$8010,$8040,$2ac,$802,$600,$cba
	dw $401,$8010,$20,$2ac,$986,$0,$cd44
	dw $401,$8010,$8020,$2ac,$c00,$2d5,$18bb
	dw $401,$8010,$8010,$2ac,$e45,$2d5,$99a
	db $40

ptn2
	dw $ff00,$8080,$8080,$300,$723,$8fd,$ab1
	dw $ff00,$8080,$8080,$300,$391,$8fd,$ab1
	dw $ff00,$8080,$8080,$300,$391,$47f,$ab1
	dw $ff00,$8080,$8080,$300,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$ab1
	dw $ff00,$4080,$8080,$300,$723,$8fd,$ab1
	dw $ff00,$4040,$8080,$300,$391,$8fd,$ab1
	dw $ff00,$4040,$4080,$300,$391,$47f,$ab1
	dw $ff00,$4040,$4040,$300,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$ab1
	dw $ff00,$2040,$4040,$300,$723,$8fd,$ab1
	dw $ff00,$2020,$4040,$300,$391,$8fd,$ab1
	dw $ff00,$2020,$2040,$300,$391,$47f,$ab1
	dw $ff00,$2020,$2020,$300,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$ab1
	dw $ff00,$1020,$2020,$300,$723,$8fd,$ab1
	dw $ff00,$1010,$2020,$300,$391,$8fd,$ab1
	dw $ff00,$1010,$1020,$300,$391,$47f,$ab1
	dw $ff00,$1010,$1010,$300,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$ab1
	dw $ff00,$1010,$1010,$300,$723,$8fd,$ab1
	dw $ff00,$1010,$1010,$300,$391,$8fd,$ab1
	dw $ff00,$1010,$1010,$300,$391,$47f,$ab1
	dw $ff00,$1010,$1010,$300,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$ab1
	dw $ff00,$2010,$1010,$300,$723,$8fd,$ab1
	dw $ff00,$2020,$1010,$300,$391,$8fd,$ab1
	dw $ff00,$2020,$2010,$300,$391,$47f,$ab1
	dw $ff00,$2020,$2020,$300,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$ab1
	dw $ff00,$4020,$2020,$300,$723,$8fd,$ab1
	dw $ff00,$4040,$2020,$300,$391,$8fd,$ab1
	dw $ff00,$4040,$4020,$300,$391,$47f,$ab1
	dw $ff00,$4040,$4040,$300,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$ab1
	dw $ff00,$8040,$4040,$300,$723,$8fd,$ab1
	dw $ff00,$8080,$4040,$300,$391,$8fd,$ab1
	dw $ff00,$8080,$8040,$300,$391,$47f,$ab1
	dw $ff00,$8080,$8080,$300,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$ab1
	db $40

ptn3
	dw $ff00,$8080,$8080,$401,$723,$8fd,$ab1
	dw $ff00,$8080,$8080,$401,$4c3,$8fd,$ab1
	dw $ff00,$8080,$8080,$401,$4c3,$600,$ab1
	dw $ff00,$8080,$8080,$401,$4c3,$600,$723
	dw $ff00,$8080,$8080,$802,$4c3,$600,$723
	dw $ff00,$8080,$8080,$802,$986,$600,$723
	dw $ff00,$8080,$8080,$802,$986,$c00,$723
	dw $ff00,$8080,$8080,$802,$986,$c00,$e45
	dw $ff00,$4080,$8080,$401,$986,$c00,$e45
	dw $ff00,$4040,$8080,$401,$4c3,$c00,$e45
	dw $ff00,$4040,$4080,$401,$4c3,$600,$e45
	dw $ff00,$4040,$4040,$401,$4c3,$600,$723
	dw $ff00,$4040,$4040,$802,$4c3,$600,$723
	dw $ff00,$4040,$4040,$802,$986,$600,$723
	dw $ff00,$4040,$4040,$802,$986,$c00,$723
	dw $ff00,$4040,$4040,$802,$986,$c00,$e45
	dw $ff00,$2040,$4040,$401,$986,$c00,$e45
	dw $ff00,$2020,$4040,$401,$4c3,$c00,$e45
	dw $ff00,$2020,$2040,$401,$4c3,$600,$e45
	dw $ff00,$2020,$2020,$401,$4c3,$600,$723
	dw $ff00,$2020,$2020,$802,$4c3,$600,$723
	dw $ff00,$2020,$2020,$802,$986,$600,$723
	dw $ff00,$2020,$2020,$802,$986,$c00,$723
	dw $ff00,$2020,$2020,$802,$986,$c00,$e45
	dw $ff00,$1020,$2020,$401,$986,$c00,$e45
	dw $ff00,$1010,$2020,$401,$4c3,$c00,$e45
	dw $ff00,$1010,$1020,$401,$4c3,$600,$e45
	dw $ff00,$1010,$1010,$401,$4c3,$600,$723
	dw $ff00,$1010,$1010,$802,$4c3,$600,$723
	dw $ff00,$1010,$1010,$802,$986,$600,$723
	dw $ff00,$1010,$1010,$802,$986,$c00,$723
	dw $ff00,$1010,$1010,$802,$986,$c00,$e45
	dw $ff00,$1010,$1010,$401,$986,$c00,$e45
	dw $ff00,$1010,$1010,$401,$4c3,$c00,$e45
	dw $ff00,$1010,$1010,$401,$4c3,$600,$e45
	dw $ff00,$1010,$1010,$401,$4c3,$600,$723
	dw $ff00,$1010,$1010,$802,$4c3,$600,$723
	dw $ff00,$1010,$1010,$802,$986,$600,$723
	dw $ff00,$1010,$1010,$802,$986,$c00,$723
	dw $ff00,$1010,$1010,$802,$986,$c00,$e45
	dw $ff00,$2010,$1010,$401,$986,$c00,$e45
	dw $ff00,$2020,$1010,$401,$4c3,$c00,$e45
	dw $ff00,$2020,$2010,$401,$4c3,$600,$e45
	dw $ff00,$2020,$2020,$401,$4c3,$600,$723
	dw $ff00,$2020,$2020,$802,$4c3,$600,$723
	dw $ff00,$2020,$2020,$802,$986,$600,$723
	dw $ff00,$2020,$2020,$802,$986,$c00,$723
	dw $ff00,$2020,$2020,$802,$986,$c00,$e45
	dw $ff00,$4020,$2020,$401,$986,$c00,$e45
	dw $ff00,$4040,$2020,$401,$4c3,$c00,$e45
	dw $ff00,$4040,$4020,$401,$4c3,$600,$e45
	dw $ff00,$4040,$4040,$401,$4c3,$600,$723
	dw $ff00,$4040,$4040,$802,$4c3,$600,$723
	dw $ff00,$4040,$4040,$802,$986,$600,$723
	dw $ff00,$4040,$4040,$802,$986,$c00,$723
	dw $ff00,$4040,$4040,$802,$986,$c00,$e45
	dw $ff00,$8040,$4040,$401,$986,$c00,$e45
	dw $ff00,$8080,$4040,$401,$4c3,$c00,$e45
	dw $ff00,$8080,$8040,$401,$4c3,$600,$e45
	dw $ff00,$8080,$8080,$401,$4c3,$600,$723
	dw $ff00,$8080,$8080,$802,$4c3,$600,$723
	dw $ff00,$8080,$8080,$802,$986,$600,$723
	dw $ff00,$8080,$8080,$802,$986,$c00,$723
	dw $ff00,$8080,$8080,$802,$986,$c00,$e45
	db $40

ptn4
	dw $ff00,$8000,$0,$300,$0,$0,$0
	dw $ff00,$8080,$0,$300,$391,$0,$0
	dw $ff00,$8080,$8000,$300,$391,$47f,$0
	dw $ff00,$8080,$8080,$300,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$ab1
	dw $ff00,$4080,$8080,$300,$723,$8fd,$ab1
	dw $ff00,$4040,$8080,$300,$391,$8fd,$ab1
	dw $ff00,$4040,$4080,$300,$391,$47f,$ab1
	dw $ff00,$4040,$4040,$300,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$ab1
	dw $ff00,$2040,$4040,$300,$723,$8fd,$ab1
	dw $ff00,$2020,$4040,$300,$391,$8fd,$ab1
	dw $ff00,$2020,$2040,$300,$391,$47f,$ab1
	dw $ff00,$2020,$2020,$300,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$ab1
	dw $ff00,$1020,$2020,$300,$723,$8fd,$ab1
	dw $ff00,$1010,$2020,$300,$391,$8fd,$ab1
	dw $ff00,$1010,$1020,$300,$391,$47f,$ab1
	dw $ff00,$1010,$1010,$300,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$ab1
	dw $ff00,$1010,$1010,$300,$723,$8fd,$ab1
	dw $ff00,$1010,$1010,$300,$391,$8fd,$ab1
	dw $ff00,$1010,$1010,$300,$391,$47f,$ab1
	dw $ff00,$1010,$1010,$300,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$ab1
	dw $ff00,$2010,$1010,$300,$723,$8fd,$ab1
	dw $ff00,$2020,$1010,$300,$391,$8fd,$ab1
	dw $ff00,$2020,$2010,$300,$391,$47f,$ab1
	dw $ff00,$2020,$2020,$300,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$ab1
	dw $ff00,$4020,$2020,$300,$723,$8fd,$ab1
	dw $ff00,$4040,$2020,$300,$391,$8fd,$ab1
	dw $ff00,$4040,$4020,$300,$391,$47f,$ab1
	dw $ff00,$4040,$4040,$300,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$ab1
	dw $ff00,$8040,$4040,$300,$723,$8fd,$ab1
	dw $ff00,$8080,$4040,$300,$391,$8fd,$ab1
	dw $ff00,$8080,$8040,$300,$391,$47f,$ab1
	dw $ff00,$8080,$8080,$300,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$ab1
	db $40

ptn5
	dw $ff00,$8080,$8080,$300,$986,$c00,$e45
	dw $ff00,$8080,$8080,$300,$391,$c00,$e45
	dw $ff00,$8080,$8080,$300,$391,$47f,$e45
	dw $ff00,$8080,$8080,$300,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$ab1
	dw $ff00,$4080,$8080,$300,$723,$8fd,$ab1
	dw $ff00,$4040,$8080,$300,$391,$8fd,$ab1
	dw $ff00,$4040,$4080,$300,$391,$47f,$ab1
	dw $ff00,$4040,$4040,$300,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$ab1
	dw $ff00,$2040,$4040,$300,$723,$8fd,$ab1
	dw $ff00,$2020,$4040,$300,$391,$8fd,$ab1
	dw $ff00,$2020,$2040,$300,$391,$47f,$ab1
	dw $ff00,$2020,$2020,$300,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$ab1
	dw $ff00,$1020,$2020,$300,$723,$8fd,$ab1
	dw $ff00,$1010,$2020,$300,$391,$8fd,$ab1
	dw $ff00,$1010,$1020,$300,$391,$47f,$ab1
	dw $ff00,$1010,$1010,$300,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$ab1
	dw $ff00,$1010,$1010,$300,$723,$8fd,$ab1
	dw $ff00,$1010,$1010,$300,$391,$8fd,$ab1
	dw $ff00,$1010,$1010,$300,$391,$47f,$ab1
	dw $ff00,$1010,$1010,$300,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$391,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$47f,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$558
	dw $ff00,$1010,$1010,$600,$723,$8fd,$ab1
	dw $ff00,$2010,$1010,$300,$723,$8fd,$ab1
	dw $ff00,$2020,$1010,$300,$391,$8fd,$ab1
	dw $ff00,$2020,$2010,$300,$391,$47f,$ab1
	dw $ff00,$2020,$2020,$300,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$391,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$47f,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$558
	dw $ff00,$2020,$2020,$600,$723,$8fd,$ab1
	dw $ff00,$4020,$2020,$300,$723,$8fd,$ab1
	dw $ff00,$4040,$2020,$300,$391,$8fd,$ab1
	dw $ff00,$4040,$4020,$300,$391,$47f,$ab1
	dw $ff00,$4040,$4040,$300,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$391,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$47f,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$558
	dw $ff00,$4040,$4040,$600,$723,$8fd,$ab1
	dw $ff00,$8040,$4040,$300,$723,$8fd,$ab1
	dw $ff00,$8080,$4040,$300,$391,$8fd,$ab1
	dw $ff00,$8080,$8040,$300,$391,$47f,$ab1
	dw $ff00,$8080,$8080,$300,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$391,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$47f,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$558
	dw $ff00,$8080,$8080,$600,$723,$8fd,$ab1
	db $40


