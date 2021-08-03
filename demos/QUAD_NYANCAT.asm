;quattropic and NYAN CAT


	org $8000

init


begin	
	ld	hl, nyan_pic
	ld	de, $e000
	ld	bc, 2048
	ldir

	ld 	a,8
	ld 	($6800), a

	ld	hl, picture
	ld	de, $7000
	ld	bc, 2048
	ldir

	ld	ix, Sin_Table

	ld	de, 0
	ld	(y_axis), de	
	ld	bc, 128
	ld	(position), bc
	ld	ix, 1
	ld	(ix_offset), ix

	ld	bc, (position)		; any of 128
	ld	de, (y_axis)

	ld	ix, (ix_offset)
	ld	a, (ix_offset)
	inc	ix			; increase sine table offset
	inc	ix
	ld	(ix_offset), ix

	srl	a			; div SIN by 2 (0 to 64 "POKE")
	srl	a			; div SIN by 2 (0 to 32 "POKE")
;	srl	a			; div SIN by 2 (0 to 32 "POKE")

	ld	b, 0
	ld	c, a			; b=0 already.

	ld	hl, nyan_pic
	add	hl, de			; increase by 32 every step.
	add	hl, bc

	ld	(position), bc		; bc = 1 of 128 positions for below single loop.

	ld	de, $7000
	ld	bc, 2048
	ldir	

	ld	de, (y_axis)		; HL = DE (Y-Axis)
	ld	hl, 64;32;128;64;32
	add	hl, de
	ld	d,h
	ld	e,l
	ld	(y_axis), de	


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

	push	ix
	push	hl
	push	de
	push	bc
	ld	bc, (position)
	
nyan2:
sin_u:	ld	de, (y_axis)

	ld	a, (ix_offset)
	ld	ix, (ix_offset)
	inc	ix			; increase sine table offset
	inc	ix
	ld	(ix_offset), ix

	srl	a			; div SIN by 2 (0 to 64 "POKE")
	srl	a			; div SIN by 2 (0 to 32 "POKE")
;	srl	a			; div SIN by 2 (0 to 32 "POKE")

	ld	b, 0
	ld	c, a			; b=0 already.

;	ld	hl, ansi_pic
	ld	hl, nyan_pic
	add	hl, de			; increase by 32 every step.
	add	hl, bc

	ld	(position), bc		; bc = 1 of 128 positions for below single loop.

	ld	de, $7000
	ld	bc, 2048
	ldir	

;	LD 	hl,$6800
;sync1:	BIT 	7,(hl)
;	jr	NZ,sync1

;	ld	hl, $e000
;	ld	de, $7000
;	ld	bc, 2048
;	ldir
;	ld	hl, nyan_pic
;	ld	de, $e000
;	ld	bc, 2048
;	ldir
	ld	de, (y_axis)		; HL = DE (Y-Axis)
	ld	hl, 64;32;128;64;32
	add	hl, de
	ld	d,h
	ld	e,l
	ld	(y_axis), de	
	pop	bc
	pop	de
	pop	hl
	pop	ix
	



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









musicdata

	db $5		;speed

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





position	dw 0
ix_offset	dw 0
y_axis		dw 0




Sin_Table:		; 128 points
db 0,3,6,9,12,16,19,22,25,28,31,34,37,40,43,46
db 49,51,54,57,60,63,65,68,71,73,76,78,81,83,85,88
db 90,92,94,96,98,100,102,104,106,107,109,111,112,113,115,116
db 117,118,120,121,122,122,123,124,125,125,126,126,126,127,127,127
db 127,127,127,127,126,126,126,125,125,124,123,122,122,121,120,118
db 117,116,115,113,112,111,109,107,106,104,102,100,98,96,94,92
db 90,88,85,83,81,78,76,73,71,68,65,63,60,57,54,51
db 49,46,43,40,37,34,31,28,25,22,19,16,12,9,6,3

db 0,-3,-6,-9,-12,-16,-19,-22,-25,-28,-31,-34,-37,-40,-43,-46
db -49,-51,-54,-57,-60,-63,-65,-68,-71,-73,-76,-78,-81,-83,-85,-88
db -90,-92,-94,-96,-98,-100,-102,-104,-106,-107,-109,-111,-112,-113,-115,-116
db -117,-118,-120,-121,-122,-122,-123,-124,-125,-125,-126,-126,-126,-127,-127,-127
db -127,-127,-127,-127,-126,-126,-126,-125,-125,-124,-123,-122,-122,-121,-120,-118
db -117,-116,-115,-113,-112,-111,-109,-107,-106,-104,-102,-100,-98,-96,-94,-92
db -90,-88,-85,-83,-81,-78,-76,-73,-71,-68,-65,-63,-60,-57,-54,-51
db -49,-46,-43,-40,-37,-34,-31,-28,-25,-22,-19,-16,-12,-9,-6,-3


nyan_pic:
picture:

db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$BF,$FF
db $FF,$FF,$FF,$FF,$FA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$D5,$55
db $55,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$55,$55
db $55,$55,$55,$55,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FE,$AA,$AF,$FF,$EA,$AA,$FF,$FE,$AA,$AF,$FF,$EA,$AA,$AD,$55,$55
db $57,$55,$55,$5D,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$ED,$55,$55
db $55,$55,$5D,$55,$57,$AA,$BA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $57,$FF,$F5,$55,$7F,$FF,$55,$57,$FF,$F5,$55,$7F,$FF,$ED,$57,$55
db $55,$57,$77,$55,$57,$AA,$DE,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$6D,$55,$55
db $55,$55,$75,$D5,$57,$AB,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $01,$55,$50,$00,$15,$55,$00,$01,$55,$50,$00,$15,$55,$6D,$55,$55
db $55,$55,$75,$75,$57,$AD,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$2D,$55,$55
db $55,$55,$75,$5D,$57,$B5,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $A8,$00,$0A,$AA,$80,$00,$AA,$A8,$00,$0A,$AA,$80,$00,$2D,$55,$55
db $5D,$55,$75,$57,$FF,$D5,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$57,$55
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FE,$AA,$AF,$FF,$EA,$AA,$FF,$FE,$AA,$AF,$FF,$EA,$AA,$AD,$55,$55
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$ED,$55,$55
db $55,$57,$D5,$49,$55,$25,$57,$EA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $57,$FF,$F5,$55,$7F,$FF,$55,$57,$FF,$F5,$55,$7F,$FF,$FD,$55,$55
db $55,$5D,$55,$69,$55,$A5,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$57,$55,$5D,$75,$55
db $75,$5D,$55,$55,$7D,$55,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $01,$55,$50,$00,$15,$55,$00,$01,$55,$50,$00,$3D,$55,$5D,$55,$55
db $55,$5D,$45,$55,$55,$55,$45,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$D5,$7F,$FD,$55,$55
db $55,$5D,$55,$75,$75,$75,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $A8,$00,$0A,$AA,$80,$00,$AA,$A8,$00,$0A,$AD,$57,$EA,$AD,$55,$55
db $55,$57,$55,$7F,$FF,$F5,$55,$EA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7E,$AA,$AD,$55,$55
db $55,$55,$D5,$55,$55,$55,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$EA,$AA,$AD,$55,$75
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$55,$55
db $55,$55,$5F,$FF,$FF,$FF,$FA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$D5,$55
db $55,$55,$5A,$B5,$EA,$D7,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7F,$FF
db $FF,$FF,$FA,$B5,$EA,$D7,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7B,$57
db $AA,$AA,$AA,$AB,$EA,$BF,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7A,$D7
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AF,$EA,$BF
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$BF,$FF
db $FF,$FF,$FF,$FF,$FA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$D5,$55
db $55,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$55,$55
db $55,$55,$55,$55,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FE,$AA,$AF,$FF,$EA,$AA,$FF,$FE,$AA,$AF,$FF,$EA,$AA,$AD,$55,$55
db $57,$55,$55,$5D,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$ED,$55,$55
db $55,$55,$5D,$55,$57,$AA,$BA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $57,$FF,$F5,$55,$7F,$FF,$55,$57,$FF,$F5,$55,$7F,$FF,$ED,$57,$55
db $55,$57,$77,$55,$57,$AA,$DE,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$6D,$55,$55
db $55,$55,$75,$D5,$57,$AB,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $01,$55,$50,$00,$15,$55,$00,$01,$55,$50,$00,$15,$55,$6D,$55,$55
db $55,$55,$75,$75,$57,$AD,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$2D,$55,$55
db $55,$55,$75,$5D,$57,$B5,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $A8,$00,$0A,$AA,$80,$00,$AA,$A8,$00,$0A,$AA,$80,$00,$2D,$55,$55
db $5D,$55,$75,$57,$FF,$D5,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$57,$55
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FE,$AA,$AF,$FF,$EA,$AA,$FF,$FE,$AA,$AF,$FF,$EA,$AA,$AD,$55,$55
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$ED,$55,$55
db $55,$57,$D5,$49,$55,$25,$57,$EA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $57,$FF,$F5,$55,$7F,$FF,$55,$57,$FF,$F5,$55,$7F,$FF,$FD,$55,$55
db $55,$5D,$55,$69,$55,$A5,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$57,$55,$5D,$75,$55
db $75,$5D,$55,$55,$7D,$55,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $01,$55,$50,$00,$15,$55,$00,$01,$55,$50,$00,$3D,$55,$5D,$55,$55
db $55,$5D,$45,$55,$55,$55,$45,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$D5,$7F,$FD,$55,$55
db $55,$5D,$55,$75,$75,$75,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $A8,$00,$0A,$AA,$80,$00,$AA,$A8,$00,$0A,$AD,$57,$EA,$AD,$55,$55
db $55,$57,$55,$7F,$FF,$F5,$55,$EA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7E,$AA,$AD,$55,$55
db $55,$55,$D5,$55,$55,$55,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$EA,$AA,$AD,$55,$75
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$55,$55
db $55,$55,$5F,$FF,$FF,$FF,$FA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$D5,$55
db $55,$55,$5A,$B5,$EA,$D7,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7F,$FF
db $FF,$FF,$FA,$B5,$EA,$D7,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7B,$57
db $AA,$AA,$AA,$AB,$EA,$BF,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7A,$D7
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AF,$EA,$BF
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA


db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$BF,$FF
db $FF,$FF,$FF,$FF,$FA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$D5,$55
db $55,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$55,$55
db $55,$55,$55,$55,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FE,$AA,$AF,$FF,$EA,$AA,$FF,$FE,$AA,$AF,$FF,$EA,$AA,$AD,$55,$55
db $57,$55,$55,$5D,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$ED,$55,$55
db $55,$55,$5D,$55,$57,$AA,$BA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $57,$FF,$F5,$55,$7F,$FF,$55,$57,$FF,$F5,$55,$7F,$FF,$ED,$57,$55
db $55,$57,$77,$55,$57,$AA,$DE,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$6D,$55,$55
db $55,$55,$75,$D5,$57,$AB,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $01,$55,$50,$00,$15,$55,$00,$01,$55,$50,$00,$15,$55,$6D,$55,$55
db $55,$55,$75,$75,$57,$AD,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$2D,$55,$55
db $55,$55,$75,$5D,$57,$B5,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $A8,$00,$0A,$AA,$80,$00,$AA,$A8,$00,$0A,$AA,$80,$00,$2D,$55,$55
db $5D,$55,$75,$57,$FF,$D5,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$57,$55
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FE,$AA,$AF,$FF,$EA,$AA,$FF,$FE,$AA,$AF,$FF,$EA,$AA,$AD,$55,$55
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$ED,$55,$55
db $55,$57,$D5,$49,$55,$25,$57,$EA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $57,$FF,$F5,$55,$7F,$FF,$55,$57,$FF,$F5,$55,$7F,$FF,$FD,$55,$55
db $55,$5D,$55,$69,$55,$A5,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$57,$55,$5D,$75,$55
db $75,$5D,$55,$55,$7D,$55,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $01,$55,$50,$00,$15,$55,$00,$01,$55,$50,$00,$3D,$55,$5D,$55,$55
db $55,$5D,$45,$55,$55,$55,$45,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$D5,$7F,$FD,$55,$55
db $55,$5D,$55,$75,$75,$75,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $A8,$00,$0A,$AA,$80,$00,$AA,$A8,$00,$0A,$AD,$57,$EA,$AD,$55,$55
db $55,$57,$55,$7F,$FF,$F5,$55,$EA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7E,$AA,$AD,$55,$55
db $55,$55,$D5,$55,$55,$55,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$EA,$AA,$AD,$55,$75
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$55,$55
db $55,$55,$5F,$FF,$FF,$FF,$FA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$D5,$55
db $55,$55,$5A,$B5,$EA,$D7,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7F,$FF
db $FF,$FF,$FA,$B5,$EA,$D7,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7B,$57
db $AA,$AA,$AA,$AB,$EA,$BF,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7A,$D7
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AF,$EA,$BF
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$BF,$FF
db $FF,$FF,$FF,$FF,$FA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$D5,$55
db $55,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$55,$55
db $55,$55,$55,$55,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FE,$AA,$AF,$FF,$EA,$AA,$FF,$FE,$AA,$AF,$FF,$EA,$AA,$AD,$55,$55
db $57,$55,$55,$5D,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$ED,$55,$55
db $55,$55,$5D,$55,$57,$AA,$BA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $57,$FF,$F5,$55,$7F,$FF,$55,$57,$FF,$F5,$55,$7F,$FF,$ED,$57,$55
db $55,$57,$77,$55,$57,$AA,$DE,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$6D,$55,$55
db $55,$55,$75,$D5,$57,$AB,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $01,$55,$50,$00,$15,$55,$00,$01,$55,$50,$00,$15,$55,$6D,$55,$55
db $55,$55,$75,$75,$57,$AD,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$2D,$55,$55
db $55,$55,$75,$5D,$57,$B5,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $A8,$00,$0A,$AA,$80,$00,$AA,$A8,$00,$0A,$AA,$80,$00,$2D,$55,$55
db $5D,$55,$75,$57,$FF,$D5,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$57,$55
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FE,$AA,$AF,$FF,$EA,$AA,$FF,$FE,$AA,$AF,$FF,$EA,$AA,$AD,$55,$55
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$ED,$55,$55
db $55,$57,$D5,$49,$55,$25,$57,$EA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $57,$FF,$F5,$55,$7F,$FF,$55,$57,$FF,$F5,$55,$7F,$FF,$FD,$55,$55
db $55,$5D,$55,$69,$55,$A5,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$57,$55,$5D,$75,$55
db $75,$5D,$55,$55,$7D,$55,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $01,$55,$50,$00,$15,$55,$00,$01,$55,$50,$00,$3D,$55,$5D,$55,$55
db $55,$5D,$45,$55,$55,$55,$45,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$D5,$7F,$FD,$55,$55
db $55,$5D,$55,$75,$75,$75,$55,$7A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $A8,$00,$0A,$AA,$80,$00,$AA,$A8,$00,$0A,$AD,$57,$EA,$AD,$55,$55
db $55,$57,$55,$7F,$FF,$F5,$55,$EA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7E,$AA,$AD,$55,$55
db $55,$55,$D5,$55,$55,$55,$57,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$EA,$AA,$AD,$55,$75
db $55,$55,$75,$55,$55,$55,$5E,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AB,$55,$55
db $55,$55,$5F,$FF,$FF,$FF,$FA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$D5,$55
db $55,$55,$5A,$B5,$EA,$D7,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7F,$FF
db $FF,$FF,$FA,$B5,$EA,$D7,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7B,$57
db $AA,$AA,$AA,$AB,$EA,$BF,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AD,$7A,$D7
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AF,$EA,$BF
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA