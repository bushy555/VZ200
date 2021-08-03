
	org $8000


wave1	equ 0
wave2	equ $800
wave3	equ $1000
wave4	equ $1800
wave5	equ $2000
wave6	equ $2800
wave7	equ $3000
wave8	equ $3800
wave9	equ $4000
wave10	equ $4800
wave11	equ $5000
wave12	equ $5800
wave13	equ $6000
wave14	equ $6800
wave15	equ $7000
wave16	equ $7800
wave17	equ $8000
wave18	equ $8800
wave19	equ $9000
wave20	equ $9800
wave21	equ $a000
wave22	equ $a800
wave23	equ $b000
wave24	equ $b800
wave25	equ $c000
wave26	equ $c800
wave27	equ $d000
wave28	equ $d800
wave29	equ $e000
wave30	equ $e800
wave31	equ $f000
wave32	equ $f800

kick equ $1
hhat equ $40

rest	equ 0
noise	equ $75

a0	 equ $17
ais0	 equ $19
b0	 equ $1a
c1	 equ $1c
cis1	 equ $1d
d1	 equ $1f
dis1	 equ $21
e1	 equ $23
f1	 equ $25
fis1	 equ $27
g1	 equ $2a
gis1	 equ $2c
a1	 equ $2f
ais1	 equ $32
b1	 equ $34
c2	 equ $38
cis2	 equ $3b
d2	 equ $3e
dis2	 equ $42
e2	 equ $46
f2	 equ $4a
fis2	 equ $4f
g2	 equ $53
gis2	 equ $58
a2	 equ $5d
ais2	 equ $63
b2	 equ $69
c3	 equ $6f
cis3	 equ $76
d3	 equ $7d
dis3	 equ $84
e3	 equ $8c
f3	 equ $94
fis3	 equ $9d
g3	 equ $a7
gis3	 equ $b0
a3	 equ $bb
ais3	 equ $c6
b3	 equ $d2
c4	 equ $de
cis4	 equ $ec
d4	 equ $fa
dis4	 equ $108
e4	 equ $118
f4	 equ $129
fis4	 equ $13a
g4	 equ $14d
gis4	 equ $161
a4	 equ $176
ais4	 equ $18c
b4	 equ $1a4
c5	 equ $1bd
cis5	 equ $1d7
d5	 equ $1f3
dis5	 equ $211
e5	 equ $230
f5	 equ $252
fis5	 equ $275
g5	 equ $29a
gis5	 equ $2c2
a5	 equ $2ec
ais5	 equ $318
b5	 equ $348
c6	 equ $379
cis6	 equ $3ae
d6	 equ $3e6
dis6	 equ $422
e6	 equ $461
f6	 equ $4a3
fis6	 equ $4ea
g6	 equ $535
gis6	 equ $584
a6	 equ $5d8
ais6	 equ $631
b6	 equ $68f
c7	 equ $6f3
cis7	 equ $75d
d7	 equ $7cd

	;test code

begin

	ld hl,music_data
	call play
	ret
	


;wtbeep 0.1
;experimental beeper engine for ZX Spectrum
;by utz 11'2016 * www.irrlichtproject.de



play
	
	di
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (mLoopVar),de
	ld (seqpntr),hl
	exx
	ld c,0			;timer lo
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld ix,0
	ld iy,0

;*******************************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0
	
mLoopVar equ $+1
	ld sp,0		;get loop point		;comment out to disable looping
	jr rdseq+3					;comment out to disable looping

;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

;*******************************************************************************
rdptn0
	ld (ptnpntr),de

readPtn
	in a,($fe)		;read kbd
	cpl
	and $1f
	jr nz,exit


ptnpntr equ $+1
	ld sp,0	
	;jr $
	pop af			;timer + ctrl
	jr z,rdseq
	
	ld b,a			;timer ($ ticks)
	
	jr c,_noUpd1
	
	ex af,af'
	
	ld h,mixAlgo/256
	pop de
	ld a,d
	
	and $f8
	ld l,a
	
	ld a,(hl)
	ld (algo1),a
	inc l
	ld a,(hl)
	ld (algo1+1),a
	inc l
	ld a,(hl)
	ld (algo1+2),a
	inc l
	ld a,(hl)
	ld (algo1+3),a
	inc l
	ld a,(hl)
	ld (algo1+4),a
	
	ld hl,0
	
	ld a,d
	and $7
	ld d,a
	
	ex af,af'

_noUpd1
	jp pe,_noUpd2
	
	exx
	ex af,af'
	
	ld h,mixAlgo/256
	pop bc
	ld a,b
	
	and $f8
	ld l,a
	
	ld a,(hl)
	ld (algo2),a
	inc l
	ld a,(hl)
	ld (algo2+1),a
	inc l
	ld a,(hl)
	ld (algo2+2),a
	inc l
	ld a,(hl)
	ld (algo2+3),a
	inc l
	ld a,(hl)
	ld (algo2+4),a
	
	ld hl,0
	
	ld a,b
	and $7
	ld b,a	
	
	ex af,af'
	exx
	
_noUpd2
	jp m,_noUpd3
	
	exx
	
	pop de
	ld a,d
	ex af,af'
	ld a,d
	and $7
	ld d,a
	ld (fdiv3),de
	
	ex af,af'
	and $f8
	ld e,a
	ld d,mixAlgo/256
	
	ld a,(de)
	ld (algo3),a
	inc e
	ld a,(de)
	ld (algo3+1),a
	inc e
	ld a,(de)
	ld (algo3+2),a
	inc e
	ld a,(de)
	ld (algo3+3),a
	inc e
	ld a,(de)
	ld (algo3+4),a
	
	ld de,0
	exx

_noUpd3
	
	pop af
	jp po,_noSweepReset
	
	ld iy,0					;reset sweep registers
	ld ixh,0
_noSweepReset
	jr c,drum1
	jr z,drum2
	dec sp
drumRet	
	
	ld (ptnpntr),sp
	
fdiv3 equ $+1
	ld sp,0

;*******************************************************************************
playNote
	add hl,de	;11	
	ld a,h		;4

algo1	
	ds 5		;20

;	out ($fe),a	;11___64
	and	33
	ld (26624), a
	
	exx		;4
	
	add hl,bc	;11
	ld a,h		;4

algo2	
	ds 5		;20
	
	inc bc		;6		;timing
;	out ($fe),a	;11___56
	and	33
	ld (26624), a
	
	ex de,hl	;4
	
	add hl,sp	;11
	ld a,h		;4

algo3	
	ds 5		;20
	
	dec bc		;6		;timing
	nop		;4
	
	ex de,hl	;4
	
;	out ($fe),a	;11___64
	and	33
	ld (26624), a
	
	
	exx		;4
	
	dec c		;4
	jp nz,playNote	;10
			;184
	
	inc iyl				;update sweep counters
	ld a,iyl
	rrca
	rrca
	ld iyh,a
	rrca
	ld ixh,a
	
	dec b
	jp nz,playNote

	jp readPtn
	
;*******************************************************************************
drum2						;noise
	ld (hlRest),hl
	ld (bcRest),bc
	
	ld b,a
	ex af,af'
	
	ld a,b
	ld hl,1					;$1 (snare) <- 1011 -> $1237 (hat)
	rrca
	jr c,setVol
	ld hl,$1237

setVol	
	and $7f
	ld (dvol),a	
				
	ld bc,$a803				;length
sloop
	add hl,hl		;11
	sbc a,a			;4
	xor l			;4
	ld l,a			;4

dvol equ $+1	
	cp $80			;7		;volume
	sbc a,a			;4
				
;	or $7			;7		;border
;	out ($fe),a		;11
	and	33
	ld (26624), a

	djnz sloop		;13/8

	dec c			;4
	jr nz,sloop		;12

	jr drumEnd
	
drum1						;kick
	ld (deRest),de
	ld (bcRest),bc
	ld (hlRest),hl

	ld d,a					;A = start_pitch<<1
	ld e,0					;B = 0
	ld h,e
	ld l,e
	
	ex af,af'
	
	srl d					;set start pitch
	rl e
	
	ld c,$3					;length
	
xlllp
	add hl,de
	jr c,_noUpd
	ld a,e
_slideSpeed equ $+1
	sub $10					;speed
	ld e,a
	sbc a,a
	add a,d
	ld d,a
_noUpd
	ld a,h					
;	or $7					;border
	and	33
	ld (26624), a
;	out ($fe),a
	djnz xlllp
	dec c
	jr nz,xlllp

						;45680 (/224 = 248.3)
deRest equ $+1
	ld de,0


drumEnd
hlRest equ $+1
	ld hl,0
bcRest equ $+1
	ld bc,0
	
	ld c,6					;adjust timer
	jp drumRet

;*******************************************************************************

;	align 256

mixAlgo

	ds 8			;00	50% square
	
	daa			;02	32% square
	and h
	ds 6
	
	rlca			;01	25% square
	and h
	ds 6
	
	daa			;03	19% square
	cpl
	and h
	ds 5
	
	inc a			;04	12.5% square
	inc a
	xor h
	rrca
	ds 4
	
	inc a			;05	6.25% square
	xor h
	rrca
	ds 5

	add a,iyl		;06	duty sweep (fast) (cpl, dec a is not needed, but makes for a nicer attack env)
	cpl
	dec a
	or h
	ds 3
	
	add a,iyh		;07	duty sweep (slow)
	cpl
	dec a
	or h
	ds 3
	
	add a,ixh		;08	duty sweep (very slow, start lo)
	cpl
	dec a
	and h
	ds 3

	add a,ixh		;09	duty sweep (very slow, start hi)
	and h
	ds 5
	

	add a,iyh		;0a	duty sweep (slow) + oct
	rlca
	xor h
	ds 4

	add a,iyh		;0b	duty sweep (slow) - oct
	rrca
	xor h
	ds 4
	
	add a,iyl		;0c	duty sweep (fast) - oct
	rrca
	xor h
	ds 4

	daa			;0d	vowel 1
	rlca
	cpl
	xor h
	ds 4
	
	daa			;0e	vowel 2
	rlca
	rlca
	cpl
	xor h
	ds 3
	
	daa			;0f	vowel 3
	cpl
	xor h
	ds 5

	rrca			;10	vowel 4
	rrca
	sbc a,a
	and h
	rlca
	ds 3
	
	rlca			;11	vowel 5
	rlca
	xor h
	rlca
	ds 4
	
	rrca			;12	vowel 6
	sbc a,a
	and h
	rlca
	ds 4
	
	cpl			;13	rasp 1
	daa
	sbc a,a
	rlca
	and h
	ds 3
	
	rlca			;14	rasp 2
	rlca
	sbc a,a
	and h
	ds 4

	daa			;15	phat rasp
	rrca
	rrca
	cpl
	or h
	ds 3

	daa			;16	phat 2
	rrca
	rrca
	cpl
	and h
	ds 3
	
	daa			;17	phat 3
	rlca
	rlca
	cpl
	and h
	ds 3

	daa			;18	phat 4
	rlca
	cpl
	and h
	ds 4
	
	daa			;19	phat 5
	rrca
	rrca
	cpl
	xor h
	ds 3
	
	cpl			;1a	phat 6
	daa
	sbc a,a
	rlca
	xor h
	ds 3
	
	rlca			;1b	phat 7
	rlca
	sbc a,a
	and h
	rlca
	ds 3
	
	rlc h			;1c	noise 1
	and h
	ds 5
	
	rlc h			;1e	noise 2
	sbc a,a
	or h
	ds 4
	
	rlc h			;1d	noise 3
	ds 6
	
	rlc h			;1f	noise 4
	or h
	xor l
	ds 5

music_data



	dw ptn2
	dw ptn2a
	dw ptn2b
	dw ptn2c
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3a
	dw ptn3a
	dw ptn3b
	dw ptn3b
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3
	dw ptn3a
	dw ptn3a
	dw ptn3b
	dw ptn3c
mLoop
	dw ptn4
	dw ptn4x
	dw ptn4a
	dw ptn4aa
	dw ptn4b
	dw ptn4bx
	dw ptn4c
	dw ptn4cx
	dw ptn4
	dw ptn4x
	dw ptn4a
	dw ptn4aa
	dw ptn4b
	dw ptn4bx
	dw ptn4c
	dw ptn4cxa
; mLoop
	dw ptn5x
	dw ptn5ax
	dw ptn5bx
	dw ptn5cx
	dw ptn5d
	dw ptn5e
	dw ptn5f
	dw ptn5g
	dw ptn5
	dw ptn5a
	dw ptn5b
	dw ptn5c
	dw ptn5d
	dw ptn5e
	dw ptn5f
	dw ptn5g
	dw ptn6
	dw ptn6a
	dw ptn6b
	dw ptn6c
	dw ptn6d
	dw ptn6e
	dw ptn6f
	dw ptn6g
	dw ptn7
	dw ptn7a
	dw ptn7b
	dw ptn7c
	dw ptn7d
	dw ptn7e
	dw ptn7f
	dw ptn7g
	dw 0


ptn5	dw $800, wave20|c3, rest, rest
	dw kick|$500
	dw $884, wave20|c4
	db 0
	dw $884, wave20|c5
	db 0
	dw $884, wave20|c4
	db 0
	db $40
	
ptn5a	dw $800, wave21|c3, rest, rest
	dw kick|$500
	dw $884, wave21|c4
	db 0
	dw $884, wave21|c5
	db 0
	dw $884, wave21|c4
	db 0
	db $40

ptn5b	dw $800, wave22|c3, rest, rest
	dw kick|$500
	dw $884, wave22|c4
	db 0
	dw $884, wave22|c5
	db 0
	dw $884, wave22|c4
	db 0
	db $40
	
ptn5c	dw $800, wave23|c3, rest, rest
	dw kick|$500
	dw $884, wave23|c4
	db 0
	dw $884, wave23|c5
	db 0
	dw $884, wave23|c4
	db 0
	db $40
	
ptn5x	dw $800, wave20|c3, wave1|c1, rest
	dw kick|$500
	dw $884, wave20|c4
	db 0
	dw $884, wave20|c5
	db 0
	dw $884, wave20|c4
	db 0
	db $40
	
ptn5ax	dw $800, wave21|c3, wave2|c1, rest
	dw kick|$500
	dw $884, wave21|c4
	db 0
	dw $884, wave21|c5
	db 0
	dw $884, wave21|c4
	db 0
	db $40

ptn5bx	dw $800, wave22|c3, wave5|c1, rest
	dw kick|$500
	dw $884, wave22|c4
	db 0
	dw $884, wave22|c5
	db 0
	dw $884, wave22|c4
	db 0
	db $40
	
ptn5cx	dw $800, wave23|c3, wave6|c1, rest
	dw kick|$500
	dw $884, wave23|c4
	db 0
	dw $884, wave23|c5
	db 0
	dw $884, wave23|c4
	db 0
	db $40
	
ptn5d	dw $800, wave24|c2, rest, rest
	dw kick|$500
	dw $884, wave24|c3
	db 0
	dw $884, wave24|c4
	db 0
	dw $884, wave24|c3
	db 0
	db $40
	
ptn5e	dw $800, wave25|c2, rest, rest
	dw kick|$500
	dw $884, wave25|c3
	db 0
	dw $884, wave25|c4
	db 0
	dw $884, wave25|c2
	db 0
	db $40
	
ptn5f	dw $800, wave26|c3, rest, rest
	dw kick|$500
	dw $884, wave26|c4
	db 0
	dw $884, wave26|c5
	db 0
	dw $884, wave26|c4
	db 0
	db $40
	
ptn5g	dw $800, wave27|c3, rest, rest
	dw kick|$500
	dw $884, wave27|c4
	db 0
	dw $884, wave27|c5
	db 0
	dw $884, wave27|c4
	db 0
	db $40

ptn6	dw $800, wave20|a2, rest, rest
	dw kick|$500
	dw $884, wave20|a3
	db 0
	dw $884, wave20|a4
	db 0
	dw $884, wave20|a3
	db 0
	db $40
	
ptn6a	dw $800, wave21|a2, rest, rest
	dw kick|$500
	dw $884, wave21|a3
	db 0
	dw $884, wave21|a4
	db 0
	dw $884, wave21|a3
	db 0
	db $40

ptn6b	dw $800, wave22|a2, rest, rest
	dw kick|$500
	dw $884, wave22|a3
	db 0
	dw $884, wave22|a4
	db 0
	dw $884, wave22|a3
	db 0
	db $40
	
ptn6c	dw $800, wave23|a2, rest, rest
	dw kick|$500
	dw $884, wave23|a3
	db 0
	dw $884, wave23|a4
	db 0
	dw $884, wave23|a3
	db 0
	db $40
	
ptn6d	dw $800, wave24|a1, rest, rest
	dw kick|$500
	dw $884, wave24|a2
	db 0
	dw $884, wave24|a3
	db 0
	dw $884, wave24|a2
	db 0
	db $40
	
ptn6e	dw $800, wave25|a1, rest, rest
	dw kick|$500
	dw $884, wave25|a2
	db 0
	dw $884, wave25|a3
	db 0
	dw $884, wave25|a2
	db 0
	db $40
	
ptn6f	dw $800, wave26|a2, rest, rest
	dw kick|$500
	dw $884, wave26|a3
	db 0
	dw $884, wave26|a4
	db 0
	dw $884, wave26|a3
	db 0
	db $40
	
ptn6g	dw $800, wave27|a2, rest, rest
	dw kick|$500
	dw $884, wave27|a3
	db 0
	dw $884, wave27|a4
	db 0
	dw $884, wave27|a3
	db 0
	db $40	


ptn7	dw $800, wave20|ais2, wave5|g3, wave5|ais3
	dw kick|$500
	dw $884, wave20|ais3
	db 0
	dw $884, wave20|ais4
	db 0
	dw $884, wave20|ais3
	db 0
	db $40
	
ptn7a	dw $800, wave21|ais2, wave5|g3, wave5|ais3
	dw kick|$500
	dw $884, wave21|ais3
	db 0
	dw $884, wave21|ais4
	db 0
	dw $884, wave21|ais3
	db 0
	db $40

ptn7b	dw $800, wave22|ais2, wave5|g3, wave5|ais3
	dw kick|$500
	dw $884, wave22|ais3
	db 0
	dw $884, wave22|ais4
	db 0
	dw $884, wave22|ais3
	db 0
	db $40
	
ptn7c	dw $800, wave23|ais2, wave5|g3, wave5|ais3
	dw kick|$500
	dw $884, wave23|ais3
	db 0
	dw $884, wave23|ais4
	db 0
	dw $884, wave23|ais3
	db 0
	db $40
	
ptn7d	dw $800, wave24|ais1, wave5|f3, wave5|ais3
	dw kick|$500
	dw $884, wave24|ais2
	db 0
	dw $884, wave24|ais3
	db 0
	dw $884, wave24|ais2
	db 0
	db $40
	
ptn7e	dw $800, wave25|ais1, wave5|f3, wave5|ais3
	dw kick|$500
	dw $884, wave25|ais2
	db 0
	dw $884, wave25|ais3
	db 0
	dw $884, wave25|ais2
	db 0
	db $40
	
ptn7f	dw $800, wave26|ais2, wave5|f3, wave5|ais3
	dw kick|$500
	dw $884, wave26|ais3
	db 0
	dw $884, wave26|ais4
	db 0
	dw $884, wave26|ais3
	db 0
	db $40
	
ptn7g	dw $800, wave27|ais2, wave6|f3, wave16|ais4
	dw kick|$500
	dw $804, wave27|ais3, wave15|ais4
	db 0
	dw $804, wave27|ais4, wave14|ais4
	db 0
	dw $804, wave27|ais3, wave13|ais4
	db 0
	db $40	


ptn4
	dw $800, wave2|c3, wave8|dis3, wave21|c3
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|c4, wave21|c4
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	dw $804, wave30|f3, wave21|c3
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|g3, wave21|c4
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	db $40
	
ptn4x
	dw $804, wave2|c3, wave21|c3
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|c4, wave21|c4
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	dw $804, wave30|f3, wave21|c3
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|g3, wave21|c4
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	db $40


ptn4a
	dw $800, wave2|c3, wave8|f3, wave21|c3
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|c4, wave21|c4
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	dw $804, wave30|f3, wave21|c3
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|g3, wave21|c4
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	db $40
	
ptn4aa
	dw $804, wave2|c3, wave21|c3
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|c4, wave21|c4
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	dw $804, wave30|f3, wave21|c3
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|g3, wave21|c4
	dw hhat|$1000
	dw $884, wave2|c2
	dw hhat|$1000
	db $40
	
ptn4b
	dw $800, wave2|c3, wave8|g3, wave21|a2
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|c4, wave21|a3
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	dw $804, wave30|f3, wave21|a2
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|g3, wave21|a3
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	db $40
	
ptn4bx
	dw $804, wave2|c3, wave21|a2
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|c4, wave21|a3
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	dw $804, wave30|f3, wave21|a2
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|g3, wave21|a3
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	db $40
	
ptn4c
	dw $800, wave2|c3, wave8|f3, wave21|ais2
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|c4, wave21|ais3
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	dw $804, wave30|f3, wave21|ais2
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|g3, wave21|ais3
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	db $40
	
ptn4cx
	dw $804, wave2|c3, wave21|ais2
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|c4, wave21|ais3
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	dw $804, wave30|f3, wave21|ais2
	dw kick|$500
	dw $884, wave2|c2
	dw kick|$500
	dw $804, wave2|g3, wave21|ais3
	dw kick|$500
	dw $884, wave2|c2
	dw kick|$500
	db $40
	
ptn4cxa
	dw $804, wave2|c3, wave21|ais2
	dw kick|$500
	dw $884, wave2|c2
	db 0
	dw $804, wave2|c4, wave21|ais3
	dw hhat|$1000
	dw $884, wave2|c2
	db 0
	dw $404, wave30|f3, wave21|ais2
	dw kick|$500
	dw $484, wave2|f3
	db 0
	dw $484, wave30|f3
	dw kick|$500
	dw $484, wave2|c2
	db 0
	dw $404, wave30|f3, wave21|ais3
	dw kick|$500
	dw $484, wave2|g3
	db 0
	dw $484, wave30|f3
	dw kick|$500
	dw $484, wave2|c2
	db 0
	db $40

ptn3
	dw $800, wave2|c3, rest, wave10|c1
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|c4
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|f3
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|g3
	db 0
	dw $884, wave2|c2
	db 0
	db $40
	
ptn3a
	dw $800, wave2|c3, rest, wave10|a0
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|c4
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|f3
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|g3
	db 0
	dw $884, wave2|c2
	db 0
	db $40
	
ptn3b
	dw $800, wave2|c3, rest, wave10|ais0
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|c4
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|f3
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|g3
	db 0
	dw $884, wave2|c2
	db 0
	db $40
	
ptn3c
	dw $800, wave2|c3, rest, wave10|ais0
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|c4
	db 0
	dw $884, wave2|c2
	db 0
	dw $884, wave2|f3
	dw hhat|$0800
	dw $884, wave2|c2
	dw hhat|$1000
	dw $884, wave2|g3
	dw hhat|$1800
	dw $884, wave2|c2
	dw hhat|$2000
	db $40


ptn2
	dw $800, wave6|c3, rest, rest
	db 0
	dw $884, wave6|c2
	db 0
	dw $884, wave6|c4
	db 0
	dw $884, wave6|c2
	db 0
	dw $884, wave6|f3
	db 0
	dw $884, wave6|c2
	db 0
	dw $884, wave6|g3
	db 0
	dw $884, wave6|c2
	db 0
	db $40
	
ptn2a
	dw $800, wave5|c3, rest, rest
	db 0
	dw $884, wave5|c2
	db 0
	dw $884, wave5|c4
	db 0
	dw $884, wave5|c2
	db 0
	dw $884, wave5|f3
	db 0
	dw $884, wave5|c2
	db 0
	dw $884, wave5|g3
	db 0
	dw $884, wave5|c2
	db 0
	db $40

ptn2b
	dw $800, wave4|c3, rest, rest
	db 0
	dw $884, wave4|c2
	db 0
	dw $884, wave4|c4
	db 0
	dw $884, wave4|c2
	db 0
	dw $884, wave4|f3
	db 0
	dw $884, wave4|c2
	db 0
	dw $884, wave4|g3
	db 0
	dw $884, wave4|c2
	db 0
	db $40
	
ptn2c
	dw $800, wave3|c3, rest, rest
	db 0
	dw $884, wave3|c2
	db 0
	dw $884, wave3|c4
	db 0
	dw $884, wave3|c2
	db 0
	dw $884, wave3|f3
	db 0
	dw $884, wave3|c2
	db 0
	dw $884, wave3|g3
	db 0
	dw $884, wave3|c2
	db 0
	db $40

