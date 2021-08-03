;
;--------------------------------
; BUZZKICK
; ------------------------------


	background equ 0

	ORG	$8000

begin



	ld 	a,8			; mode (1)
	ld 	($6800),a
	DI

	ld	hl, $7000		; CLS screen
	ld	a, background
	ld	(hl), a
	ld	de, $7001
	ld	bc, 2050
	ldir
	

	ld	de, $7000 + 31*32 -1	; Set start middle point, RHS, in buffer
	ld	(line1), de





	ld hl,musicdata1
	call play
	ret



	;engine code

play

	di

	ld (drumList+1),hl

	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a

	xor a
	ld (songSpeedComp+1),a
	ld (ch1out+1),a
	ld (ch2out+1),a

	ld a,128
	ld (ch1freq+1),a
	ld (ch2freq+1),a
	ld a,1
	ld (ch1delay1+1),a
	ld (ch2delay1+1),a
	ld a,16
	ld (ch1delay2+1),a
	ld (ch2delay2+1),a

	exx
	ld d,a
	ld e,a
	ld b,a
	ld c,a
	push hl
	exx

readRow

	ld c,(hl)
	inc hl

	bit 7,c
	jr z,noSpeed

	ld a,(hl)
	inc hl
	or a
	jr nz,noLoop

	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	jr readRow

noLoop

	ld (songSpeed+1),a

noSpeed

	bit 6,c
	jr z,noSustain1

	ld a,(hl)
	inc hl
	exx
	ld d,a
	ld e,a
	exx

noSustain1

	bit 5,c
	jr z,noSustain2

	ld a,(hl)
	inc hl
	exx
	ld b,a
	ld c,a
	exx

noSustain2

	bit 4,c
	jr z,noNote1

	ld a,(hl)
	ld d,a
	inc hl
	or a
	jr z,$+4
;	ld a,$18
	ld	a, 32
	ld (ch1out+1),a
	jr z,noNote1

	ld a,d
	ld (ch1freq+1),a
	srl a
	srl a
	ld (ch1delay2+1),a
	ld a,1
	ld (ch1delay1+1),a

	exx
	ld e,d
	exx

noNote1

	bit 3,c
	jr z,noNote2

	ld a,(hl)
	ld e,a
	inc hl
	or a
	jr z,$+4
;	ld a,$18
	ld	a, 32

	ld (ch2out+1),a
	jr z,noNote2
	ld a,e
	ld (ch2freq+1),a
	srl a
	srl a
	srl a
	ld (ch2delay2+1),a
	ld a,1
	ld (ch2delay1+1),a
	exx
	ld c,b
	exx
noNote2
	ld a,c
	and 7
	jr z,noDrum
playDrum
	push hl
	add a,a
	add a,a
	ld c,a
	ld b,0
drumList:
	ld hl,0
	add hl,bc
	ld a,(hl)				;length in 256-sample blocks
	ld b,a
	inc hl
	inc hl
	add a,a
	add a,a
	ld (songSpeedComp+1),a
	ld a,(hl)
	inc hl
	ld h,(hl)				;sample data
	ld l,a
	ld a,1
	ld (mask+1),a
	ld c,0
loop0	ld a,(hl)				;7
mask:	and 0					;7
	sub 1					;7
	sbc a,a					;4
;	and $18					;7
	and 32
	or 8
;	out ($fe),a				;11
	ld	(26624), a
	ld a,(mask+1)			;13
	rlc a					;8
	ld (mask+1),a			;13
	jr nc,$+3				;7/12
	inc hl					;6

	jr $+2					;12
	jr $+2					;12
	jr $+2					;12
	jr $+2					;12
	nop						;4
	nop						;4
	ld a,0					;7
	dec c					;4
	jr nz,loop0			;7/12=168t
	djnz loop0
	pop hl
noDrum
songSpeed:
	ld a,0
	ld b,a
songSpeedComp:
	sub 0
	jr nc,$+3
	xor a
	ld c,a
	ld a,(songSpeedComp+1)
	sub b
	jr nc,$+3
	xor a
	ld (songSpeedComp+1),a
	ld a,c
	or a
	jp z,readRow
	ld c,a
	ld b,64
soundLoop
	ld a,3				;7
	dec a				;4
	jr nz,$-1			;7/12=50t
	jr $+2				;12
	dec d				;4
	jp nz,ch2			;10
ch1freq:ld d,0				;7
ch1delay1:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12
ch1out:	ld a,0				;7
;	out ($fe),a			;11
	and 32
	or 8
	ld	(26624), a
ch1delay2:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12
;	out ($fe),a			;11
	and 	32
	or	8
	ld	(26624), a
ch2	ld a,3				;7
	dec a				;4
	jr nz,$-1			;7/12=50t
	jr $+2				;12
	dec e				;4
	jp nz,loop			;10
ch2freq:ld e,0				;7
ch2delay1:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12
ch2out:	ld 	a,0				;7
;	out 	($fe),a			;11
	and 	32
	or	8
	ld	(26624), a
ch2delay2:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12
;	out ($fe),a			;11
	and 	32
	or 	8
	ld	(26624), a
loop	dec b				;4
	jr nz,soundLoop		;7/12=168t
	ld b,64
envelopeDown
	exx
	dec e
	jp nz,noEnv1
	ld e,d
	ld hl,ch1delay2+1
	dec (hl)
	jr z,$+5
	ld hl,ch1delay1+1
	inc (hl)

noEnv1
	dec c
	jp nz,noEnv2
	ld c,b
	ld hl,ch2delay2+1
	dec (hl)
	jr z,$+5
	ld hl,ch2delay1+1
	inc (hl)
noEnv2	exx
	dec c
	jp nz,soundLoop
	xor a










demo:	

	push	hl
	push	de
	push	bc

; VZ sine wave graph thingy - sideways sliding. 
;
; 	128			32
; ------------              ----------
; |          |              |        |
; |          | 64           |        | 64
; |          |              |        |
; ------------              ----------
; 

	
	

;	push	bc
seed1 equ $+1 	
	ld a, 	23	; (seed1)
 	ld b, 	a 
 	rrca 	; multiply by 32
 	rrca
 	rrca
 	xor 	$1f
 	add 	a, b
 	sbc 	a, 255 ; carry
 	ld 	(seed1), a
;	pop	bc




	ld	de, (line1)	; get line1
	cp	170		; determine to go LINE1 : FWD or BACK.  up or down.
	jp 	pe, FWD1	; 1/3: go down
	cp	85
	jp	pe, HERE2	; 1/3: go straight
	jp 	po, BACK1	; 1/3: go up

FWD1:	inc	de		; go down 1 line.
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	inc	de
	jp 	HERE2

BACK1:	dec	de		; go up 1 line
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de
	dec	de



HERE2:	ld	(line1), de	; save line 1
				; ============DO LINE 2
hereb:	ld	de, (line1)
	push 	de
	ld	a, 85
	ld	(de), a
	add	a, e
	ld	e, a
	ld	(de), a

	ld	hl, $7001
	ld	de, $7000

	ld	c, 0	
	ld	b, 63			; Y = 64 rows
LOOP2:	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	inc	hl
	inc	de
	
	djnz	LOOP2

	pop	de
	ld	a, 0
	ld	(de), a



;	pop	af
	pop	bc
	pop	de
	pop	hl



	jp	readRow

	pop hl
	exx
	ei
	ret




;	seed1	db  	23

	line1	dw 0



musicdata1:


musicData
 dw .song,0
.drums
 dw 1,.drum0
 dw 2,.drum1
 dw 2,.drum2
 dw 3,.drum3
 dw 1,.drum4
 dw 1,.drum5
 dw 4,.drum6
.drum0
 db 0,0,0,0,0,0,128,0,0,204,255,255,191,255,255,255,255,255,31,4,0,0,0,0,0,0,0,0,0,0,0,0
.drum1
 db 0,0,252,255,255,0,0,0,64,0,0,224,223,255,255,31,7,0,0,0,0,248,255,255,255,27,1,0,0,0,0,0,192,240,254,191,255,63,0,0,0,0,0,194,199,255,255,191,0,0,0,0,0,0,132,182,247,254,127,6,0,0,0,0
.drum2
 db 200,29,3,0,0,0,0,0,24,35,140,253,255,255,255,31,0,0,0,0,0,0,0,0,254,255,255,255,255,191,0,0,0,0,0,0,0,0,224,255,255,255,255,255,255,247,0,0,0,0,0,0,0,0,192,249,255,255,255,255,159,0,0,0
.drum3
 db 0,0,252,255,255,3,0,0,0,0,0,0,254,255,255,255,255,9,0,0,0,0,240,255,255,255,111,37,0,0,0,0,0,0,0,220,255,255,255,15,0,0,0,0,0,128,207,255,255,255,20,0,0,0,0,0,128,164,238,255,251,123,19,0,0,0,0,0,0,128,254,207,127,182,1,0,0,0,0,0,0,128,180,105,201,11,0,0,64,0,0,0,0,0,240,242
.drum4
 db 0,0,0,0,0,120,0,0,224,15,0,0,192,0,0,0,30,0,0,176,1,0,0,0,0,0,128,0,0,0,0,0
.drum5
 db 0,192,15,0,224,7,0,224,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.drum6
.song
 db 249,25,99,99,168,126
 db 0
 db 0
 db 0
 db 25,126,0
 db 16,0
 db 16,126
 db 16,0
 db 9,126
 db 8,0
 db 16,126
 db 16,0
 db 17,126
 db 16,0
 db 8,126
 db 8,0
 db 17,126
 db 16,0
 db 16,126
 db 16,0
 db 9,126
 db 8,0
 db 16,126
 db 16,0
 db 17,126
 db 16,0
 db 24,168,126
 db 0
 db 25,168,126
 db 0
 db 24,189,126
 db 0
 db 25,168,126
 db 0
 db 0
 db 0
 db 25,126,0
 db 16,0
 db 16,126
 db 16,0
 db 9,126
 db 8,0
 db 16,126
 db 16,0
 db 17,126
 db 16,0
 db 8,126
 db 8,0
 db 17,126
 db 16,0
 db 16,126
 db 16,0
 db 9,126
 db 8,0
 db 16,126
 db 16,0
 db 17,126
 db 16,0
 db 24,168,126
 db 0
 db 25,168,126
 db 0
 db 24,189,126
 db 0
 db 25,212,159
 db 0
 db 0
 db 0
 db 25,159,0
 db 16,0
 db 16,159
 db 16,0
 db 9,159
 db 8,0
 db 16,159
 db 16,0
 db 17,159
 db 16,0
 db 8,159
 db 8,0
 db 17,159
 db 16,0
 db 16,159
 db 16,0
 db 9,159
 db 8,0
 db 16,159
 db 16,0
 db 17,159
 db 16,0
 db 24,212,159
 db 0
 db 25,212,159
 db 0
 db 24,225,168
 db 0
 db 25,212,159
 db 0
 db 0
 db 0
 db 25,159,0
 db 16,0
 db 8,159
 db 8,0
 db 25,212,159
 db 0
 db 0
 db 0
 db 25,159,0
 db 16,0
 db 8,159
 db 8,0
 db 25,189,141
 db 0
 db 0
 db 0
 db 25,141,0
 db 16,0
 db 8,141
 db 8,0
 db 25,189,141
 db 0
 db 0
 db 2
 db 25,141,0
 db 16,0
 db 10,141
 db 8,0
 db 25,168,126
 db 0
 db 0
 db 1
 db 26,126,168
 db 24,0,0
 db 25,126,168
 db 8,0
 db 24,0,126
 db 8,0
 db 25,126,168
 db 24,0,0
 db 26,126,168
 db 0
 db 24,0,126
 db 8,0
 db 25,126,168
 db 24,0,0
 db 24,126,168
 db 9,0
 db 26,0,126
 db 8,0
 db 25,126,168
 db 24,0,0
 db 24,126,168
 db 24,0,0
 db 25,168,126
 db 0
 db 26,168,126
 db 0
 db 24,189,126
 db 0
 db 25,168,126
 db 0
 db 0
 db 1
 db 26,126,168
 db 24,0,0
 db 25,126,168
 db 8,0
 db 24,0,126
 db 8,0
 db 25,126,168
 db 24,0,0
 db 26,126,168
 db 8,0
 db 24,0,126
 db 8,0
 db 25,126,168
 db 24,0,0
 db 24,126,168
 db 9,0
 db 26,0,126
 db 8,0
 db 25,126,168
 db 24,0,0
 db 24,126,168
 db 24,0,0
 db 25,168,126
 db 0
 db 26,168,126
 db 0
 db 26,189,126
 db 2
 db 25,212,159
 db 0
 db 0
 db 1
 db 26,159,212
 db 24,0,0
 db 25,159,212
 db 8,0
 db 25,0,159
 db 8,0
 db 24,159,212
 db 25,0,0
 db 26,159,212
 db 8,0
 db 25,0,159
 db 8,0
 db 25,159,212
 db 24,0,0
 db 24,159,212
 db 9,0
 db 26,0,159
 db 8,0
 db 25,159,212
 db 24,0,0
 db 25,159,212
 db 24,0,0
 db 24,212,159
 db 1
 db 26,212,159
 db 0
 db 25,225,168
 db 0
 db 25,212,159
 db 0
 db 1
 db 0
 db 25,159,212
 db 16,0
 db 9,159
 db 8,0
 db 25,212,159
 db 0
 db 1
 db 0
 db 25,159,212
 db 16,0
 db 9,159
 db 8,0
 db 26,189,141
 db 0
 db 2
 db 0
 db 26,141,189
 db 16,0
 db 10,141
 db 8,0
 db 28,189,141
 db 4
 db 3
 db 3
 db 28,141,189
 db 20,0
 db 11,141
 db 11,0
 db 121,70,25,59,168
 db 16,56
 db 8,0
 db 0
 db 10,168
 db 24,0,0
 db 24,56,168
 db 0
 db 9,56
 db 0
 db 9,168
 db 24,0,0
 db 26,56,168
 db 0
 db 8,56
 db 0
 db 25,63,168
 db 8,0
 db 8,168
 db 0
 db 10,63
 db 0
 db 24,70,168
 db 8,0
 db 9,168
 db 8,0
 db 9,168
 db 0
 db 26,126,168
 db 0
 db 8,189
 db 0
 db 25,94,168
 db 0
 db 8,126
 db 0
 db 10,168
 db 8,0
 db 24,42,168
 db 0
 db 9,94
 db 0
 db 9,168
 db 8,0
 db 26,56,168
 db 0
 db 8,42
 db 0
 db 9,168
 db 8,0
 db 8,168
 db 0
 db 10,56
 db 0
 db 8,168
 db 8,0
 db 9,168
 db 8,0
 db 9,168
 db 0
 db 10,168
 db 0
 db 8,189
 db 0
 db 25,59,212
 db 16,56
 db 8,0
 db 0
 db 10,212
 db 24,0,0
 db 24,56,212
 db 0
 db 9,56
 db 0
 db 9,212
 db 16,0
 db 26,56,212
 db 0
 db 8,225
 db 0
 db 25,63,189
 db 0
 db 8,56
 db 0
 db 10,189
 db 8,0
 db 24,70,189
 db 0
 db 9,63
 db 0
 db 9,189
 db 0
 db 26,126,189
 db 0
 db 8,212
 db 0
 db 25,126,168
 db 16,112
 db 8,126
 db 0
 db 10,168
 db 8,0
 db 24,112,168
 db 0
 db 9,112
 db 0
 db 9,168
 db 8,0
 db 26,126,168
 db 16,112
 db 8,112
 db 0
 db 9,168
 db 8,0
 db 11,168
 db 3
 db 10,112
 db 0
 db 11,168
 db 8,0
 db 12,168
 db 8,0
 db 11,168
 db 0
 db 12,168
 db 0
 db 12,189
 db 0
 db 25,59,168
 db 16,56
 db 8,0
 db 0
 db 10,168
 db 24,0,0
 db 24,56,168
 db 0
 db 9,56
 db 0
 db 9,168
 db 24,0,0
 db 26,56,168
 db 0
 db 8,0
 db 0
 db 25,63,168
 db 8,0
 db 8,168
 db 0
 db 10,56
 db 0
 db 24,70,168
 db 8,0
 db 9,168
 db 8,0
 db 9,168
 db 0
 db 26,126,168
 db 0
 db 8,189
 db 0
 db 25,94,168
 db 0
 db 8,126
 db 0
 db 10,168
 db 8,0
 db 24,42,168
 db 0
 db 9,94
 db 0
 db 9,168
 db 8,0
 db 26,56,168
 db 0
 db 8,42
 db 0
 db 9,168
 db 8,0
 db 8,168
 db 0
 db 10,56
 db 0
 db 8,168
 db 10,0
 db 9,168
 db 8,0
 db 9,168
 db 0
 db 26,56,168
 db 0
 db 24,53,189
 db 0
 db 25,47,212
 db 0
 db 8,53
 db 0
 db 10,212
 db 24,0,0
 db 24,47,212
 db 0
 db 9,47
 db 0
 db 9,212
 db 16,0
 db 26,47,212
 db 0
 db 8,225
 db 0
 db 25,42,189
 db 0
 db 8,47
 db 0
 db 10,189
 db 8,0
 db 8,189
 db 0
 db 9,42
 db 0
 db 25,35,189
 db 0
 db 26,31,189
 db 0
 db 24,42,212
 db 0
 db 9,168
 db 0
 db 8,42
 db 0
 db 10,168
 db 8,0
 db 8,168
 db 2
 db 9,42
 db 0
 db 9,168
 db 8,0
 db 10,168
 db 0
 db 8,0
 db 0
 db 11,168
 db 3
 db 3
 db 0
 db 12,0
 db 0
 db 4
 db 0
 db 1
 db 0
 db 1
 db 0
 db 1
 db 0
 db 1
 db 0
 db 121,5,99,53,212
 db 8,0
 db 24,56,212
 db 8,0
 db 29,63,212
 db 8,53
 db 25,84,212
 db 8,56
 db 26,53,212
 db 8,63
 db 29,56,212
 db 8,84
 db 25,63,212
 db 8,53
 db 24,84,212
 db 8,56
 db 29,53,212
 db 8,63
 db 24,56,212
 db 8,84
 db 25,63,212
 db 8,53
 db 29,84,212
 db 8,56
 db 26,53,212
 db 8,63
 db 24,56,212
 db 8,84
 db 29,63,212
 db 8,53
 db 24,84,212
 db 8,56
 db 25,53,189
 db 8,63
 db 24,56,189
 db 8,84
 db 29,63,189
 db 8,53
 db 25,84,189
 db 8,56
 db 26,53,189
 db 8,63
 db 29,56,189
 db 8,84
 db 25,63,189
 db 8,53
 db 24,84,189
 db 8,56
 db 24,53,252
 db 8,63
 db 24,56,252
 db 8,84
 db 29,63,252
 db 8,53
 db 24,84,252
 db 8,56
 db 26,126,252
 db 8,63
 db 29,112,252
 db 8,84
 db 28,106,252
 db 8,126
 db 28,84,252
 db 8,112
 db 25,53,212
 db 8,106
 db 24,56,212
 db 8,84
 db 29,63,212
 db 8,53
 db 25,84,212
 db 8,56
 db 26,53,212
 db 8,63
 db 29,56,212
 db 8,84
 db 25,63,212
 db 8,53
 db 24,84,212
 db 8,56
 db 29,53,212
 db 8,63
 db 24,56,212
 db 8,84
 db 25,63,212
 db 8,53
 db 29,84,212
 db 8,56
 db 26,53,212
 db 8,63
 db 24,56,212
 db 8,84
 db 29,63,212
 db 8,53
 db 24,84,212
 db 8,56
 db 25,53,189
 db 8,63
 db 24,56,189
 db 8,84
 db 29,63,189
 db 8,53
 db 25,84,189
 db 8,56
 db 26,53,189
 db 8,63
 db 29,56,189
 db 8,84
 db 25,63,189
 db 8,53
 db 24,84,189
 db 8,56
 db 25,159,159
 db 8,63
 db 24,126,159
 db 10,84
 db 28,112,159
 db 8,159
 db 27,106,159
 db 8,126
 db 27,79,168
 db 8,112
 db 27,63,168
 db 8,106
 db 27,56,168
 db 8,79
 db 27,53,168
 db 8,63
 db 25,84,126
 db 8,56
 db 30,70,126
 db 14,53
 db 28,63,126
 db 8,84
 db 25,56,126
 db 8,70
 db 30,84,126
 db 8,63
 db 25,70,126
 db 8,56
 db 28,63,126
 db 8,84
 db 30,56,126
 db 8,70
 db 25,84,126
 db 8,63
 db 30,70,126
 db 14,56
 db 28,63,126
 db 8,84
 db 25,56,126
 db 8,70
 db 30,53,126
 db 8,63
 db 25,56,126
 db 8,56
 db 28,63,126
 db 8,53
 db 26,70,126
 db 10,56
 db 25,79,189
 db 8,63
 db 30,70,189
 db 14,70
 db 28,63,189
 db 8,79
 db 25,56,189
 db 8,70
 db 30,79,189
 db 8,63
 db 25,70,189
 db 8,56
 db 28,63,189
 db 8,79
 db 30,56,189
 db 8,70
 db 25,79,141
 db 8,63
 db 30,70,141
 db 14,56
 db 28,63,141
 db 8,79
 db 25,56,141
 db 8,70
 db 30,126,141
 db 8,63
 db 25,112,141
 db 8,56
 db 28,106,141
 db 12,126
 db 28,84,141
 db 12,112
 db 25,84,126
 db 8,106
 db 30,70,126
 db 14,84
 db 28,63,126
 db 8,84
 db 25,56,126
 db 8,70
 db 30,84,126
 db 8,63
 db 25,70,126
 db 8,56
 db 28,63,126
 db 8,84
 db 30,56,126
 db 8,70
 db 25,84,126
 db 8,63
 db 30,70,126
 db 14,56
 db 28,63,126
 db 8,84
 db 25,56,126
 db 8,70
 db 30,53,126
 db 8,63
 db 25,56,126
 db 8,56
 db 28,63,126
 db 8,53
 db 24,70,126
 db 8,56
 db 28,79,189
 db 8,63
 db 25,84,189
 db 8,70
 db 28,94,189
 db 8,79
 db 25,106,189
 db 8,84
 db 28,79,189
 db 8,94
 db 25,84,189
 db 8,106
 db 28,94,189
 db 8,53
 db 25,106,189
 db 8,56
 db 28,84,168
 db 10,63
 db 28,79,168
 db 8,84
 db 28,63,168
 db 8,79
 db 28,56,168
 db 0
 db 8,63
 db 0
 db 24,0,56
 db 0
 db 8,0
 db 0
 db 0
 db 0
 db 121,70,25,59,168
 db 16,56
 db 8,0
 db 0
 db 10,168
 db 24,0,0
 db 24,56,168
 db 0
 db 13,56
 db 0
 db 9,168
 db 24,0,0
 db 26,56,168
 db 0
 db 13,56
 db 0
 db 25,63,168
 db 8,0
 db 8,168
 db 0
 db 10,63
 db 0
 db 24,70,168
 db 8,0
 db 13,168
 db 8,0
 db 9,168
 db 0
 db 26,126,168
 db 0
 db 8,189
 db 0
 db 9,168
 db 0
 db 8,126
 db 0
 db 26,94,168
 db 8,0
 db 8,168
 db 0
 db 29,42,94
 db 0
 db 9,168
 db 8,0
 db 26,56,168
 db 0
 db 13,42
 db 0
 db 9,168
 db 8,0
 db 8,168
 db 0
 db 10,56
 db 0
 db 8,168
 db 8,0
 db 13,168
 db 8,0
 db 9,168
 db 0
 db 10,168
 db 0
 db 8,189
 db 0
 db 25,59,212
 db 16,56
 db 8,0
 db 0
 db 10,212
 db 24,0,0
 db 24,56,212
 db 0
 db 13,56
 db 0
 db 9,212
 db 16,0
 db 26,56,212
 db 0
 db 13,225
 db 0
 db 25,63,189
 db 0
 db 8,56
 db 0
 db 10,189
 db 8,0
 db 24,70,189
 db 0
 db 13,63
 db 0
 db 9,189
 db 0
 db 26,126,189
 db 0
 db 8,212
 db 0
 db 25,126,168
 db 16,112
 db 8,126
 db 0
 db 10,168
 db 8,0
 db 24,112,168
 db 0
 db 13,112
 db 0
 db 9,168
 db 8,0
 db 26,126,168
 db 16,112
 db 13,112
 db 0
 db 9,168
 db 8,0
 db 11,168
 db 3
 db 10,112
 db 0
 db 11,168
 db 8,0
 db 12,168
 db 8,0
 db 11,168
 db 0
 db 12,168
 db 0
 db 12,189
 db 0
 db 25,59,168
 db 16,56
 db 8,0
 db 0
 db 12,168
 db 24,0,0
 db 24,56,168
 db 0
 db 13,56
 db 0
 db 9,168
 db 24,0,0
 db 28,56,168
 db 0
 db 13,0
 db 0
 db 25,63,168
 db 8,0
 db 8,168
 db 0
 db 12,56
 db 0
 db 24,70,168
 db 8,0
 db 13,168
 db 8,0
 db 9,168
 db 0
 db 28,126,168
 db 0
 db 8,189
 db 0
 db 25,94,168
 db 0
 db 8,126
 db 0
 db 12,168
 db 8,0
 db 24,42,168
 db 0
 db 13,94
 db 0
 db 9,168
 db 8,0
 db 28,56,168
 db 0
 db 13,42
 db 0
 db 9,168
 db 8,0
 db 8,168
 db 0
 db 12,56
 db 0
 db 8,168
 db 10,0
 db 13,168
 db 8,0
 db 9,168
 db 0
 db 28,56,168
 db 0
 db 24,53,189
 db 0
 db 25,47,212
 db 0
 db 8,53
 db 0
 db 12,212
 db 24,0,0
 db 24,47,212
 db 0
 db 13,47
 db 0
 db 9,212
 db 16,0
 db 28,47,212
 db 0
 db 13,225
 db 0
 db 25,42,189
 db 0
 db 8,47
 db 0
 db 12,189
 db 8,0
 db 8,189
 db 0
 db 13,42
 db 0
 db 25,35,189
 db 0
 db 28,31,189
 db 0
 db 24,42,212
 db 0
 db 9,168
 db 0
 db 8,42
 db 0
 db 12,168
 db 8,0
 db 8,168
 db 2
 db 13,42
 db 0
 db 9,168
 db 8,0
 db 12,168
 db 0
 db 13,0
 db 0
 db 27,112,168
 db 27,112,168
 db 27,112,168
 db 24,0,0
 db 0
 db 0
 db 27,112,168
 db 27,112,168
 db 28,112,168
 db 0
 db 24,0,0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 25,63,212
 db 16,56
 db 8,212
 db 0
 db 14,63
 db 8,56
 db 8,212
 db 8,56
 db 10,212
 db 0
 db 14,0
 db 0
 db 24,70,212
 db 0
 db 8,212
 db 0
 db 30,0,70
 db 0
 db 8,212
 db 8,70
 db 9,212
 db 0
 db 8,0
 db 0
 db 26,84,212
 db 0
 db 8,212
 db 0
 db 29,63,84
 db 0
 db 5
 db 0
 db 9,189
 db 8,63
 db 8,189
 db 0
 db 14,0
 db 0
 db 8,189
 db 0
 db 26,70,189
 db 0
 db 30,84,0
 db 0
 db 24,94,189
 db 8,70
 db 8,189
 db 8,84
 db 14,252
 db 8,94
 db 8,252
 db 0
 db 25,84,0
 db 0
 db 8,252
 db 8,84
 db 10,252
 db 0
 db 24,94,84
 db 0
 db 13,252
 db 0
 db 13,94
 db 0
 db 25,0,212
 db 0
 db 8,212
 db 0
 db 26,56,0
 db 0
 db 9,212
 db 8,56
 db 26,0,212
 db 0
 db 26,70,56
 db 0
 db 9,212
 db 8,70
 db 24,0,212
 db 0
 db 26,84,70
 db 0
 db 9,212
 db 8,84
 db 25,0,212
 db 0
 db 8,84
 db 0
 db 26,70,212
 db 0
 db 8,212
 db 0
 db 29,47,70
 db 0
 db 5
 db 0
 db 9,189
 db 8,47
 db 8,189
 db 0
 db 29,53,0
 db 0
 db 9,189
 db 8,53
 db 26,56,189
 db 0
 db 13,53
 db 0
 db 25,84,189
 db 8,56
 db 8,189
 db 8,84
 db 9,126
 db 0
 db 8,126
 db 0
 db 12,0
 db 0
 db 8,126
 db 2
 db 11,126
 db 0
 db 10,0
 db 0
 db 28,70,126
 db 0
 db 28,63,0
 db 0
 db 25,56,212
 db 8,70
 db 14,212
 db 8,63
 db 12,212
 db 8,56
 db 25,53,212
 db 8,56
 db 14,212
 db 8,0
 db 9,212
 db 8,53
 db 28,84,212
 db 8,53
 db 14,212
 db 8,0
 db 25,0,212
 db 8,84
 db 14,212
 db 8,84
 db 28,112,212
 db 24,106,0
 db 9,212
 db 8,0
 db 30,84,212
 db 8,53
 db 25,0,212
 db 8,84
 db 28,70,212
 db 8,0
 db 10,212
 db 10,0
 db 25,56,189
 db 8,70
 db 14,189
 db 8,0
 db 12,189
 db 8,56
 db 25,53,189
 db 8,56
 db 14,189
 db 8,0
 db 9,189
 db 8,53
 db 28,63,189
 db 8,53
 db 14,189
 db 8,0
 db 25,0,252
 db 8,63
 db 14,252
 db 8,0
 db 28,141,252
 db 24,126,0
 db 9,252
 db 24,0,0
 db 28,112,252
 db 8,126
 db 9,252
 db 8,0
 db 28,106,252
 db 12,112
 db 12,252
 db 12,0
 db 26,56,212
 db 8,106
 db 9,212
 db 8,0
 db 14,212
 db 8,56
 db 26,53,212
 db 8,56
 db 9,212
 db 8,0
 db 14,212
 db 8,53
 db 26,70,212
 db 8,53
 db 9,212
 db 8,0
 db 30,0,212
 db 8,70
 db 14,212
 db 8,0
 db 28,112,212
 db 24,106,0
 db 9,212
 db 8,106
 db 30,84,212
 db 8,0
 db 9,212
 db 8,84
 db 28,47,212
 db 8,0
 db 8,212
 db 8,94
 db 28,53,189
 db 8,0
 db 9,189
 db 8,53
 db 28,0,189
 db 8,53
 db 25,70,189
 db 8,0
 db 12,189
 db 8,70
 db 25,0,189
 db 8,70
 db 28,70,189
 db 24,63,0
 db 9,189
 db 8,0
 db 28,63,252
 db 24,0,63
 db 28,63,252
 db 24,0,63
 db 28,63,252
 db 24,0,63
 db 28,126,252
 db 0
 db 8,126
 db 0
 db 16,0
 db 0
 db 0
 db 0
 db 0
 db 8,0
 db 0
.loop
 db 24,0,0
 dw $0080,.loop



end
