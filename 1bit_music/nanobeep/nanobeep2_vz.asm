;nanobeep2
;tiny ZX Spectrum beeper engine
;by utz 08'2017 * www.irrlichtproject.de


	org $8000

borderMasking equ 0
fullKeyboardCheck equ 0
useDrum equ 1
loopToStart equ 1
usePatternSpeed equ 0
pwmSweep equ 1
usePrescaling equ 1

rest	 equ $00
hhat	 equ $fe
ptnEnd	 equ $ff
d1	 equ $f
dis1	 equ $10
e1	 equ $11
f1	 equ $12
fis1	 equ $13
g1	 equ $14
gis1	 equ $15
a1	 equ $16
ais1	 equ $18
b1	 equ $19
c2	 equ $1b
cis2	 equ $1c
d2	 equ $1e
dis2	 equ $20
e2	 equ $21
f2	 equ $23
fis2	 equ $26
g2	 equ $28
gis2	 equ $2a
a2	 equ $2d
ais2	 equ $2f
b2	 equ $32
c3	 equ $35
cis3	 equ $38
d3	 equ $3c
dis3	 equ $3f
e3	 equ $43
f3	 equ $47
fis3	 equ $4b
g3	 equ $50
gis3	 equ $54
a3	 equ $59
ais3	 equ $5f
b3	 equ $64
c4	 equ $6a
cis4	 equ $71
d4	 equ $77
dis4	 equ $7e
e4	 equ $86
f4	 equ $8e
fis4	 equ $96
g4	 equ $9f
gis4	 equ $a9
a4	 equ $b3
ais4	 equ $bd
b4	 equ $c9
c5	 equ $d5
cis5	 equ $e1
d5	 equ $ef
dis5	 equ $fd

	
;new tiny engine: 64-99 bytes
;fullKeyboardCheck +1 bytes
;borderMasking = +4/+6 bytes
;useDrum = +11 bytes
;loopToStart = +0
;variable pattern speed = +4
;pwmSweep +2
;usePrescaling +11 (down = $f, up = $7)


init
	di
	
	ld d,0
	ld c,d
	exx
	push hl
	ld (_oldSP),sp
_initSeq
	ld bc,musicData

;*******************************************************************************	
_readSeq
	ld a,(bc)
	ld l,a
	inc bc
	ld a,(bc)
	or a
	jr z,_initSeq
	inc bc
	ld h,a
	ld sp,hl

;*******************************************************************************
	pop af
	ld (_ptnSpeed),a
	pop hl
	ld a,h
	ld (_prescale1),a
	ld a,l
	ld (_prescale2),a
_readPtn
	in a,($fe)
	cpl
	and $1f
	ld d,a
	jr z,_cont	
;	rra
;	jr c,_cont
_exit	
_oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

_drum
	ld h,l
	dec sp
_drumlp
	ld a,(hl)
;	out ($fe),a
	and 33
	ld (26624), a
	dec l
	jr nz,_drumlp
_cont	
	pop hl
	ld a,l
	inc l
	jr z,_readSeq
	inc l
	jr z,_drum

	ld e,h
	exx
	ld e,a

_ptnSpeed equ $+1
	ld b,0
;*******************************************************************************	
_soundloop
	
	ld a,h			;4	;load ch1 osc state
	add a,b
	and h
_prescale1
	nop
;	out ($fe),a		;11
	and 33
	ld (26624), a
	exx			;4
	add hl,de		;11	;update ch2 osc
	ld a,h			;4
_prescale2
	nop
	exx			;4
	dec bc			;6
	add hl,de		;11	;update ch1 osc (moved here for better volume balance)
	
;	out ($fe),a		;11
	and 33
	ld	(26624), a
	ld a,b			;4
	or c			;4
	jr nz,_soundloop	;12
				;86	
	exx
	jr _readPtn

;*******************************************************************************
musicData



speed equ $f	

	dw ptn0
	dw ptn0
	dw ptn0
	dw ptn0
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn2
	dw ptn2
	dw ptn2
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3a
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn2
	dw ptn2
	dw ptn2a
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4
	dw ptn4a
	dw ptn5
	dw ptn5
	dw ptn5
	dw ptn5
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn7
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6
	dw ptn6a
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn1
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn8
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw 0
	
ptn0
	dw $0f00
	db hhat, c2, rest
	db c3, rest
	db c4, rest
	db c3, rest
	db ptnEnd

ptn1
	dw $0f00
	db hhat, c2, dis4
	db c3, dis4
	db c4, dis4
	db c3, dis4
	db ptnEnd
	
ptn2
	dw $0f00
	db hhat, c2, f4
	db c3, f4
	db c4, f4
	db c3, f4
	db ptnEnd
	
ptn2a
	dw $0f00
	db hhat, c2, f4
	db c3, f4
	db c4, dis4
	db c3, f4
	db ptnEnd
	
ptn3
	dw $0f00
	db hhat, c2, c4
	db c3, c4
	db c4, c4
	db c3, c4
	db ptnEnd
	
ptn3a
	dw $0f00
	db hhat, c2, c4
	db hhat, c3, c4
	db hhat, c4, rest
	db hhat, c3, rest
	db ptnEnd
	
ptn4
	dw $0f00
	db hhat, c2, g4
	db c3, g4
	db c4, g4
	db c3, g4
	db ptnEnd
	
ptn4a
	dw $0f00
	db hhat, c2, g4
	db hhat, c3, g4
	db hhat, c4, rest
	db hhat, c3, rest
	db ptnEnd

ptn5
	dw $0f00
	db hhat, gis1, dis4
	db gis2, dis4
	db gis3, dis4
	db gis2, dis4
	db ptnEnd	

ptn6
	dw $0f00
	db hhat, gis1, c4
	db gis2, c4
	db gis3, c4
	db gis2, c4
	db ptnEnd
	
ptn6a
	dw $0f00
	db hhat,g1, c4
	db g2, c4
	db g3, rest
	db g2, rest
	db ptnEnd
	
ptn7
	dw $0f00
	db hhat, gis1, c4
	db gis2, c4
	db gis3, ais3
	db gis2, ais3
	db ptnEnd

ptn8
	dw $0f00
	db hhat, c2, c4
	db c3, c4
	db c4, ais3
	db c3, ais3
	db ptnEnd



