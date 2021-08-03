;fluidcore
;4 channel wavetable player for the zx spectrum beeper
;by utz 03'2016

NMOS EQU 1
CMOS EQU 2

Z80 EQU 1

IF Z80=NMOS			;values for NMOS Z80
	pon equ $2020
	poff equ 0
;	pon equ $18fe
;	poff equ 0
	seta equ $af		;xor a
ENDIF
IF Z80=CMOS			;values for CMOS Z80
	pon equ $2020
	poff equ $20
;	pon equ $00fe
;	poff equ $18
	seta equ $79		;ld c,a
ENDIF

	org $8000
	;org origin	;org address is defined externally by compile script

init
;	ei			;detect kempston
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
	ld (seqpntr),hl
	ld ixl,0

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
	
	ld sp,loop		;get loop point - comment out when disabling looping
	jr rdseq+3
	
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

;************************************************************************************************
updateTimer
	ld (26624), a
updateTimerND
	ld a,i
	dec a
	jr z,rdptn
	ld i,a
	ld a,$ff
	ex af,af'
	jp (ix)
	
updateTimerOD
	ld a,i
	dec a
	jr z,rdptn
	ld i,a
	ld a,$ff
	ex af,af'
	jp core16

;************************************************************************************************
rdptn0
	ld (patpntr),de	
rdptn
;	in a,($1f)		;read joystick
;maskKempston equ $+1
;	and $1f
;	ld d,a
;	in a,($fe)		;read kbd
;	cpl
;	or d
;	and $1f
;	jp nz,exit

patpntr equ $+1			;fetch pointer to pattern data
	ld sp,0

	pop af
	jr z,rdseq
	
	ld i,a
	
	pop hl			;10	;freq.ch1
	ld (buffer),hl		;16
	pop hl			;10	;freq.ch2
	ld (buffer+4),hl	;16
	pop de			;10	;sample.ch1/2
	ld a,d			;4
	ld (buffer+3),a		;13
	ld a,e			;4
	ld (buffer+7),a		;13	
	pop hl			;10	;freq.ch3
	ld (buffer+8),hl	;16
	pop hl			;10	;freq.ch4
	ld (buffer+12),hl	;20
	pop de			;10	;sample.ch3/4
	ld a,d			;4
	ld (buffer+11),a	;13
	ld a,e			;4
	ld (buffer+15),a	;13
	ld (patpntr),sp		;20
				;212
				
	xor a
IF Z80=NMOS

	ld (26624), a
ENDIF
	ld h,a
	ld l,a
	ld d,a
	ld e,a

	exx
	ld h,a
	ld l,a
	ld d,a
	ld e,a
		
	ex af,af'
	ld a,$fe		;set timer lo-byte
IF Z80=CMOS
	ld (26624), a
ENDIF
	ex af,af'
	
	;ld bc,pon
	jp pEntry
	;jp core0
	
;************************************************************************************************	
core0						;volume 0
IF (LOW($))!=0
	org 256*(1+(HIGH($)))
ENDIF
basec equ HIGH($)

_frame1
	ld (26624), a		;12___12
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerND	;10
	ex af,af'		;4
pEntry	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 9			;48		;9x nop
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld (26624), a		;12___12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 17			;68		;14x nop
				;152
	
_frame3
	ld (26624), a		;12___12
	nop			;4	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 15			;60	;12x nop
				;152

_frame4
	ld (26624), a		;12___12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ds 7			;28
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
buffer
	ds 16					;4x base freq, 4x base sample pointer	

;************************************************************************************************
core1	org 256*(1+(HIGH($)))				;volume 1 ... 12 t-states
_frame1
	ld	a, b
	ld (26624), a

;	out (c),b		;12___
	ld (26624), a		;12___12
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerND	;10
	ex af,af'		;4
	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 6			;36		;9x nop
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a

;	out (c),b		;12
	ld (26624), a		;12___12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 14			;56		;14x nop
				;152
	
_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ld (26624), a		;12___12
	nop			;4	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 12			;48	;12x nop
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ld (26624), a		;12___12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ds 4			;16
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************					
core2	org 256*(1+(HIGH($)))				;volume 2 ... 16 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	ld (26624), a		;12___16
	
	dec a			;4
	jp z,updateTimerND	;10
	ex af,af'		;4
	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 6			;36		;9x nop
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	ld (26624), a		;12___16
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 14			;56		;14x nop
				;152
	
_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	nop			;4
	ld (26624), a		;12___16	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 12			;48	;12x nop
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	ld (26624), a		;12___16
	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ds 4			;16
	cp maxc			;10
	jp nc,overdrive		;7
	jp (ix)			;8
				;152

	
;************************************************************************************************	
core3	org 256*(1+(HIGH($)))			;volume  3 ... 24 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	nop			;4
	ld (26624), a		;12___24
	
	jp z,updateTimerND	;10
	ex af,af'		;4
	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 5			;32
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	ds 2			;8
	ld (26624), a		;12___24
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 12			;48		;14x nop
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	nop			;4
	nop			;4
	nop			;4
	ld (26624), a		;12___24	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 10			;40	;10x nop
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	nop			;4
	nop			;4
	ld (26624), a		;12___24
	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ds 2			;8
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core4	org 256*(1+(HIGH($)))			;volume  4 ... 32 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	ds 3			;12
	ld (26624), a		;12___32
	
	jp z,updateTimerND	;10
	ex af,af'		;4
	
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 3			;24
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	ds 4			;16
	ld (26624), a		;12___32
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 10			;40
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	nop			;4
	nop			;4
	nop			;4
	nop			;4
	nop			;4
	ld (26624), a		;12___32	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 8			;32	;12x nop
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	ld a,poff		;7
		ld (26624), a
;	out ($fe),a		;11___32
	
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ld bc,pon		;10	;timing
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core5	org 256*(1+(HIGH($)))			;volume  5 ... 40 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ld sp,buffer		;10
	ld (26624), a		;12___40
	
	ex af,af'		;4	
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 6			;36
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	ds 6			;24
	ld (26624), a		;12___40
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 8			;32
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ds 7			;28
	ld (26624), a		;12___40	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 6			;24
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	;xor a			;4
	db seta
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
		ld (26624), a
;	out ($fe),a		;11___40
	
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ld ($0000),a		;13	;timing
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core6	org 256*(1+(HIGH($)))			;volume  6 ... 48 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	nop			;4
	ld (26624), a		;12___48
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 5			;32
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	ds 8			;32
	ld (26624), a		;12___48
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 6			;24
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ds 9			;36
	ld (26624), a		;12___48	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 4			;16	;12x nop
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	;xor a			;4
	db seta
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	ds 2			;8
		ld (26624), a
;	out ($fe),a		;11___48
	
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	ret z			;5	;timing - safe while using reasonable values (total vol <$7f)
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core7	org 256*(1+(HIGH($)))			;volume  7 ... 56 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	ds 3			;12
	ld (26624), a		;12___56
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 3			;24
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	ds 10			;40
	ld (26624), a		;12___56
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 4			;16
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ds 11			;44
	ld (26624), a		;12___56	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
	ds 2			;8	;12x nop
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	;xor a			;4
	db seta
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	dec bc			;6	;timing
	pop bc			;10
		ld (26624), a
;	out ($fe),a		;11___56

	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	
	cp maxc			;7
	jp nc,overdrive0	;10
	ld a,0			;7	;timing
	jp (ix)			;8
				;152

;************************************************************************************************
core8	org 256*(1+(HIGH($)))			;volume  8 ... 64 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	ds 5			;20
	ld (26624), a		;12___64
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	nop			;16
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	ds 12			;48
	ld (26624), a		;12___64
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ds 2			;8
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ds 13			;52
	ld (26624), a		;12___64	
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld bc,pon		;10
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	;xor a			;4
	db seta
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	dec bc			;6	;timing
	pop bc			;10
	ld c,h			;4
	ex de,hl		;4
		ld (26624), a
;	out ($fe),a		;11___64

	ld a,(bc)		;7
	add a,iyh		;8
	
	exx			;4

	add a,basec		;7
	ld ixh,a		;8
	
	ld bc,pon		;10
	cp maxc			;7
	jp nc,overdrive0	;10
	ld a,0			;7
	jp (ix)			;8
				;152

;************************************************************************************************
core9	org 256*(1+(HIGH($)))			;volume  9 ... 72 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	ds 4			;28
	ex af,af'
	dec a
	ex af,af'
	ld (26624), a		;12___72
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
	ds 2			;8
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	ds 14			;56
	ld (26624), a		;12___72
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyl,a		;8
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	ld (26624), a		;12___72
	
	add a,iyl		;8
	ld iyh,a		;8
	ds 13			;52
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,basec		;7
			;7
	ld (26624), a		;12___72
	
	ex de,hl		;4
	add a,iyh		;8
	
	exx			;4
	
	ld ixh,a		;8
	
	ld bc,pon		;10
	ld r,a			;9
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core10	org 256*(1+(HIGH($)))			;volume 10 ... 80 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	ds 6			;36
	ex af,af'
	dec a
	ex af,af'
	ld (26624), a		;12___80
		
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	nop			;4
	ld bc,pon		;10
	ld (26624), a		;12___80
	
	ld iyl,a		;8
	ds 13			;52
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld (26624), a		;12___80
	
	ld iyh,a		;8
	ds 13			;52
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,basec		;7
	ex de,hl		;4
	exx			;4
			;7
	ld (26624), a		;12___80
	
	add a,iyh		;8
	
	ld ixh,a		;8
	
	ld bc,pon		;10	;ld b,$18 will be enough
	ld r,a			;9
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core11	org 256*(1+(HIGH($)))			;volume 11 ... 88 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
			;7
	nop			;16
	ex af,af'
	dec a
	ex af,af'
	ld (26624), a		;12___88
		
	pop bc			;10
	ld c,h			;4
	ld ($0000),a		;13		;timing
	ld a,(bc)		;7
	ld iyh,a		;8
	ld bc,pon		;10
				;152


_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	nop			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ld (26624), a		;12___88
	ds 13			;52
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ld (26624), a		;12___88
	ds 13			;52
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,basec		;7
	add a,iyh		;8
	ex de,hl		;4
	exx			;4
			;7
	ld (26624), a		;12___88
	
	ld ixh,a		;8
	
	ld bc,pon		;10
	ld r,a			;9
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core12	org 256*(1+(HIGH($)))			;volume 12 ... 96 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld (26624), a		;12___96
		
	ld iyh,a		;8
	ds 6			;36
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 3			;12
	ld (26624), a		;12___96
	ds 11			;44
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 2			;8
	ld (26624), a		;12___96
	ds 11			;44
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
			;7
	ld (26624), a		;12___96
	
	ld bc,pon		;10	;ld b,$18 will do
	ld r,a			;9
	cp maxc			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core13	org 256*(1+(HIGH($)))			;volume 13 ... 104 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	ld (26624), a		;12___104

	ds 6			;36
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 5			;20
	ld (26624), a		;12___104
	ds 9			;36
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 4			;16
	ld (26624), a		;12___104
	ds 9			;36
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	ld bc,pon		;10
	ret z			;5	;timing - Z is never set when using reasonable values (total vol <$7f)
	ld (26624), a		;12___104
	
	nop			;4
	cp maxc			;7
	jp nc,overdrive0	;10
	ld a,0			;7
	jp (ix)			;8
				;152
				
;************************************************************************************************
core14	org 256*(1+(HIGH($)))			;volume 14 ... 112 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	ds 2			;8
	ld (26624), a		;12___112

	ds 4			;28
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 7			;28
	ld (26624), a		;12___112
	ds 7			;28
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 6			;24
	ld (26624), a		;12___112
	ds 7			;28
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	dec bc			;6	;timing
	ld bc,pon		;10
	cp maxc			;7
	ld (26624), a		;12___112
	ld bc,pon		;10
	jp nc,overdrive		;10
	jp (ix)			;8
				;152

;************************************************************************************************
core15	org 256*(1+(HIGH($)))			;volume 15 ... 120 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	ds 4			;16
	ld (26624), a		;12___120

	ds 2			;20
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 9			;36
	ld (26624), a		;12___120
	ds 5			;20
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 8			;32
	ld (26624), a		;12___120
	ds 5			;20
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	nop			;4
	ld bc,pon		;10
	cp maxc			;7
	jp nc,overdrivey	;10
	ld (26624), a		;12___120
	ds 3			;12
	jp (ix)			;8
				;152

;************************************************************************************************
core16	org 256*(1+(HIGH($)))			;volume 16 ... 128 t-states
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	ds 6			;24
	ld (26624), a		;12___128

	;ds 3			;12
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 11			;44
	ld (26624), a		;12___128
	ds 3			;12
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 10			;40
	ld (26624), a		;12___128
	ds 3			;12
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	ld bc,pon		;7
	cp maxc			;7
	ld a,0			;7
	nop			;4
	nop			;4
	jp nc,overdrivex	;10
	ld (26624), a		;12___128
	nop			;4
	jp (ix)			;8
				;152

;************************************************************************************************
	;org $90f8			;handling frames with overdriven volume
	org (256*(1+(HIGH($))) - 12)
overdrivey
	ld (26624), a
	jr overdrive
overdrivex	
	ld (26624), a
	jr core17
overdrive0
	ld a,0
overdrive
	nop
	nop

core17	;org 256*(1+(HIGH($)))			;volume 17 ... 152 t-states
maxc equ (1 + (HIGH($)))
_frame1
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex af,af'		;4
	dec a			;4
	jp z,updateTimerOD	;10
	ex af,af'		;4
	ld sp,buffer		;10
	pop bc			;10		;base freq 1
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	ld iyh,a		;8
	ds 9			;48
	ex af,af'
	dec a
	ex af,af'
				;152

_frame2
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ex de,hl		;4	
	exx			;4
	ld bc,pon		;10
	ld iyl,a		;8
	ds 17			;68
				;152

_frame3
	ld	a, b
		ld (26624), a
;	out (c),b		;12
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	ld bc,pon		;10
	add a,iyh		;8
	add a,iyl		;8
	ld iyh,a		;8
	ds 16			;64
				;152

_frame4
	ld	a, b
		ld (26624), a
;	out (c),b		;12___
	ex de,hl		;4
	pop bc			;10
	add hl,bc		;11
	pop bc			;10
	ld c,h			;4
	ld a,(bc)		;7
	add a,iyh		;8
	ex de,hl		;4
	add a,basec		;7
	ld ixh,a		;8
	exx			;4
	ld bc,pon		;7
	ds 6			;24
	cp maxc			;7
	ld a,0			;7
	jp nc,overdrive		;10
	jp (ix)			;8
				;152


samples
	org 256*(1+(HIGH($)))			;align to 256b page
smp0				;silence
	ds 256,0

smpb
	include "samples/tri-v2.asm"
smpc
	include "samples/tri-v4.asm"
smpd
	include "samples/tri-v5.asm"
smpe
	include "samples/tri-v6.asm"
smp1f
	include "samples/kick-v5.asm"
smp6
	include "samples/sq25-v1.asm"
smp23
	include "samples/whitenoise-v3.asm"
smp7
	include "samples/sq25-v2.asm"
smp24
	include "samples/whitenoise-v4.asm"
smp8
	include "samples/sq25-v3.asm"
smp9
	include "samples/sq25-v4.asm"
smpa
	include "samples/sq25-v5.asm"
smp1a
	include "samples/ice2-v4.asm"
smp15
	include "samples/phat-v2.asm"
smp13
	include "samples/sine-v5.asm"
smp18
	include "samples/phat3-v3.asm"

	
musicdata





sequence
	dw ptn0
	dw ptn2
	dw ptn2
	dw ptn3
	dw ptn4
	dw ptn3
	dw ptn4
	dw ptn5
	dw ptn8
	dw ptn6
	dw ptn7
	dw 0

;pattern data
ptn0
	dw $800,$200,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpb))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpc))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpd))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	dw $800,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$0,$0,(HIGH(smp0))*256+(HIGH(smp0))
	db $40

ptn2
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp6))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smpa))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp9))*256+(HIGH(smp0))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp8))*256+(HIGH(smp0))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$0,(HIGH(smp7))*256+(HIGH(smp0))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$0,(HIGH(smp7))*256+(HIGH(smp0))
	db $40

ptn3
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$800,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$8fb,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$984,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp8))*256+(HIGH(smp15))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$1000,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$1000,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$1000,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$1000,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1000,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$1000,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$1000,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$1000,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$1000,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$1000,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$1000,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$1000,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$e41,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$e41,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$e41,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$e41,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$cb3,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp7))*256+(HIGH(smp15))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$984,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$984,(HIGH(smp6))*256+(HIGH(smp1a))
	db $40

ptn4
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$984,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$984,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$984,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$984,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$984,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$984,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$984,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$984,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$8fb,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$87a,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$800,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$800,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$800,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$800,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$800,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$800,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$800,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$800,(HIGH(smp8))*256+(HIGH(smp15))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$cb3,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$cb3,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$cb3,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$cb3,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$cb3,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$cb3,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$cb3,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$cb3,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$cb3,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$cb3,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1c82,$cb3,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$cb3,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$1c82,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$bfd,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$aae,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$aae,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$aae,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$aae,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp9))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$aae,(HIGH(smp8))*256+(HIGH(smp1a))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$aae,(HIGH(smp7))*256+(HIGH(smp15))
	dw $400,$200,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$aae,(HIGH(smp7))*256+(HIGH(smp15))
	dw $400,$261,$1307,(HIGH(smpe))*256+(HIGH(smp6)),$1966,$8fb,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$261,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$8fb,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ab,$1000,(HIGH(smpe))*256+(HIGH(smp6)),$1307,$984,(HIGH(smp7))*256+(HIGH(smp1a))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$8fb,(HIGH(smp6))*256+(HIGH(smp1a))
	dw $400,$2ff,$1966,(HIGH(smpe))*256+(HIGH(smp6)),$17f9,$8fb,(HIGH(smp6))*256+(HIGH(smp1a))
	db $40

ptn5
	dw $400,$200,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$21e7,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$21e7,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$21e7,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$21e7,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	db $40

ptn6
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$17f9,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$10f4,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$11f6,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1307,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$17f9,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1966,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smpe))*256+(HIGH(smp24)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smpe))*256+(HIGH(smp24)),$155c,$21e7,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$21e7,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1e34,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smpe))*256+(HIGH(smp24)),$2000,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$2000,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$2000,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$2000,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1c82,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1c82,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1c82,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1c82,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1c82,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$17f9,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1966,$21e7,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$21e7,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$17f9,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	db $40

ptn7
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$17f9,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1000,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$10f4,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$11f6,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1307,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1307,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$17f9,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$17f9,$1000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$17f9,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1000,$1307,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1000,$1000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1966,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$1307,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smpe))*256+(HIGH(smp24)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smpe))*256+(HIGH(smp24)),$155c,$21e7,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$21e7,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1e34,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smpe))*256+(HIGH(smp24)),$2000,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$2000,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$2000,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$2000,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1c82,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1c82,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smpe))*256+(HIGH(smp1f)),$1c82,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1c82,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1c82,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1c82,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$1966,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$1966,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$17f9,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smpe))*256+(HIGH(smp24)),$1966,$21e7,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$2000,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smpe))*256+(HIGH(smp0)),$1966,$21e7,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$17f9,$155c,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smpe))*256+(HIGH(smp0)),$17f9,$2000,(HIGH(smp18))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smpe))*256+(HIGH(smp23)),$155c,$1966,(HIGH(smp18))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smpe))*256+(HIGH(smp0)),$155c,$155c,(HIGH(smp18))*256+(HIGH(smpb))
	db $40

ptn8
	dw $400,$200,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$200,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$200,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$261,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$17f9,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1307,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$21e7,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$21e7,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$41,(HIGH(smp13))*256+(HIGH(smp1f)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ab,$80,(HIGH(smp13))*256+(HIGH(smp24)),$0,$21e7,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ab,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$2ff,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$21e7,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$32d,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$32d,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$2000,(HIGH(smp0))*256+(HIGH(smpb))
	dw $400,$390,$fe,(HIGH(smp13))*256+(HIGH(smp23)),$0,$1966,(HIGH(smp0))*256+(HIGH(smpd))
	dw $400,$390,$0,(HIGH(smp13))*256+(HIGH(smp0)),$0,$155c,(HIGH(smp0))*256+(HIGH(smpb))
	db $40

loop equ sequence+$2



