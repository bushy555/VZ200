;******************************************************************
;nanobeep
;77 byte beeper engine by utz 09'2015-04'2016
;******************************************************************
;
;ignores kempston
;only reads keys Space,A,Q,1 (can be fixed with 2 additional bytes)
;
;D - add counter ch1
;E - base freq ch1
;B - internal delay counter
;C - add counter ch2
;HL - data pointer
;IY - timer

	org $8000

init
	di
	ld (oldSP),sp
	ld sp,musicdata+2

;******************************************************************
rdseq
	xor a
	pop hl			;pattern pointer to HL
	or h
	jr nz,rdptn
	;jr exit		;uncomment to disable looping
	
	ld sp,loop
	jr rdseq

drum
	ex de,hl
	ld h,a
	ld c,l
	ld b,h
	otir
	ex de,hl

;******************************************************************	
rdptn
	inc hl	
	ld a,(hl)		;base freq ch1		
	ld e,a
	inc a			;if A=$ff
	jr z,rdseq
	
	inc a
	jr z,drum

	inc hl			;point to base freq ch2	

	ld iy,(musicdata)	;speed

;******************************************************************
play
	ld a,d
	add a,e
	ld d,a
	
	ld b,33
	
	sbc a,a
	and b
;	out ($fe),a
	ld (26624), a

	djnz $

	ld a,c
	add a,(hl)
	ld c,a
	
	ld b,33

	sbc a,a
	and b
;	out ($fe),a
	ld (26624), a
	
	djnz $

	dec iy
	ld a,iyh
	or b
	jr nz,play
	
	in a,($fe)		;read kbd
	rra
	jr c,rdptn		;only space,a,q,1 will exit
	;cpl			;comment out the 2 lines above and uncomment this for full keyboard scan
	;and $1f
	;jr nz,rdptn
	
;******************************************************************			
exit
oldSP equ $+1
	ld sp,0
	ei
	ret
;******************************************************************

musicdata
;speed
	dw $200

;sequence
loop
	dw ptn0-1
	dw ptn0-1
	dw ptn1-1
	dw ptn0-1
	dw 0

;pattern data
ptn0
	db $10,$20
	db $10,$26
	db $10,$30
	db $10,$39
	db $20,$40
	db $20,$4c
	db $20,$60
	db $20,$72
	db $10,$20
	db $10,$26
	db $10,$30
	db $10,$39
	db $20,$40
	db $20,$4c
	db $20,$60
	db $20,$72
	db $10,$20
	db $10,$26
	db $10,$30
	db $10,$39
	db $20,$40
	db $20,$4c
	db $20,$60
	db $20,$72
	db $13,$20
	db $13,$26
	db $13,$30
	db $13,$39
	db $26,$40
	db $26,$4c
	db $26,$60
	db $26,$72
	db $10,$20
	db $10,$26
	db $10,$30
	db $10,$39
	db $20,$40
	db $20,$4c
	db $20,$60
	db $20,$72
	db $10,$20
	db $10,$26
	db $10,$30
	db $10,$39
	db $20,$40
	db $20,$4c
	db $20,$60
	db $20,$72
	db $10,$20
	db $10,$26
	db $10,$30
	db $10,$39
	db $20,$40
	db $20,$4c
	db $20,$60
	db $20,$72
	db $30,$20
	db $30,$26
	db $30,$30
	db $30,$39
	db $26,$40
	db $26,$4c
	db $26,$60
	db $26,$72
	db $ff

ptn1
	db $15,$2b
	db $15,$33
	db $15,$40
	db $15,$4c
	db $2b,$55
	db $2b,$66
	db $2b,$80
	db $2b,$98
	db $15,$2b
	db $15,$33
	db $15,$40
	db $15,$4c
	db $2b,$55
	db $2b,$66
	db $2b,$80
	db $2b,$98
	db $15,$2b
	db $15,$33
	db $15,$40
	db $15,$4c
	db $2b,$55
	db $2b,$66
	db $2b,$80
	db $2b,$98
	db $19,$2b
	db $19,$33
	db $19,$40
	db $19,$4c
	db $33,$55
	db $33,$66
	db $33,$80
	db $33,$98
	db $15,$2b
	db $15,$33
	db $15,$40
	db $15,$4c
	db $2b,$55
	db $2b,$66
	db $2b,$80
	db $2b,$98
	db $15,$2b
	db $15,$33
	db $15,$40
	db $15,$4c
	db $2b,$55
	db $2b,$66
	db $2b,$80
	db $2b,$98
	db $15,$2b
	db $15,$33
	db $15,$40
	db $15,$4c
	db $2b,$55
	db $2b,$66
	db $2b,$80
	db $2b,$98
	db $e,$2b
	db $e,$33
	db $e,$40
	db $e,$4c
	db $1d,$55
	db $1d,$66
	db $1d,$80
	db $1d,$98
	db $ff


