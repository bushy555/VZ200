; NYAN CAT & Astroy boy compression.
;
;
; Displays NYAN
; Displays Astro
; Displays NYAN from Buffer2
; Compresses Astro from Astro_pic to Buffer1
; Clears buffers
; Decompresses Buffer1 to Buffer2
; Displays Buffer2 (astro)
;
;
; Compress and decompress works.
;
; compress on PC side of things, not yet work.
;
; STEPJ util needs binary output & RLE ascii to be done.
;
;

video	equ	$7000
program equ	$8000
buffer1	equ	$B000
buffer2 equ	$C000



	org 	$8000



begin	di
	ld 	a,8
	ld 	($6800), a

	ld	de, video+1	; $7001
	ld	a, 85
	ld	hl, video	; $7000
	ld	(hl), a
	ld	bc, 2048
	ldir


	ld	de, buffer1	; $7001
	inc	de
	ld	a, 0
	ld	hl, buffer1	; $7000
	ld	(hl), a
	ld	bc, 6000
	ldir


	ld	de, buffer2	; $7001
	inc	de
	ld	a, 0
	ld	hl, buffer2	; $7000
	ld	(hl), a
	ld	bc, 6000
	ldir


	ld	hl, nyan_pic
	ld	de, video
	ld	bc, 2048
	ldir

	LD BC, $f000
	CALL 0060H		; delay

	ld	hl, astro_pic
	ld	de, video
	ld	bc, 2048
	ldir

	LD BC, $f000
	CALL 0060H		; delay

	ld	de, video+1	; $7001
	ld	a, 170
	ld	hl, video	; $7000
	ld	(hl), a
	ld	bc, 2047
	ldir

	ld	hl, nyan_pic
	ld	de, buffer2
	ld	bc, 2048
	ldir

	ld	hl, buffer2
	ld	de, video
	ld	bc, 2048
	ldir

	LD BC, $f000
	CALL 0060H		; delay




	ld	iy, 0		; Global 0-2047

	ld	hl, astro_pic
	ld	de, buffer1



	ld	a, (hl)
l0:	ld	ix, 0		; local char counter
	ld	c, 0
l1:	ld	a, (hl)
	ld	c, a		; C := original.
l2:	inc	hl		; inc HL pointer.
	inc	ix		; local counter.
	inc	iy		; global counter
	
	ld	a, (hl)
	cp	c		; c=current. a=prior
	jr	nz, write	; is not equal, so jump to write
	jr	l2		; is equal.

write:	ld	a, c		; write out CHAR
	ld	(de), a
	inc	de
	ld	a, ixl		; write out QNTY
	ld	(de), a
	inc	de


	push	hl
	push	de
	push	iy
	push	ix
	push	bc
	push	af

	push	iy		; IY=global counter = DE
	pop	de
	ld	hl, 2048	; CP HL with DE
	rst	$18		; RST $18 = "CMP HL, DE"
	jr	c, quit		; C = "HL > DE, so jump"
	
	pop	af
	pop	bc
	pop	ix
	pop	iy
	pop	de
	pop	hl
	jp	l0

;HL < DE : carry set
;HL > DE : no carry
;HL <> DE : NZ
;HL = DE : Z
;
;- say between 100 and 500 (decimal):
;	LD HL,500 ;load HL with upper limit
;	RST 18H ;& call comparison routine
;	JR C,ERR ;carry means num>500
;	LD HL,100 ;now set for lower limit
;	RST 18H ;& try again
;	JR NC,ERR ;no carry means num < 100
;	.... ;if still here, must be OK




quit: 	pop	af
	pop	bc
	pop	ix
	pop	iy
	pop	de
	pop	hl
	ei
;	ld	h, 0
;	ld	l, a
;	CALL 	0FAFh

	ld	b, 100
	ld	a, "-"
l05a:	ldi
	djnz	l05a

	ld	b, 255
	ld	a, 0
l06a1:	ldi
	djnz	l06a1
	ld	b, 255
	ld	a, 0
l06a2:	ldi
	djnz	l06a2
	ld	b, 255
	ld	a, 0
l06a3:	ldi
	djnz	l06a3
	ld	b, 255
	ld	a, 0
l06a4:	ldi
	djnz	l06a4
	ld	b, 255
	ld	a, 0
l06a5:	ldi
	djnz	l06a5



;	CLS
;----------
	ld	de, video + 1	;$7001
	ld	a, 0
	ld	hl, video	;$7000
	ld	(hl), a
	ld	bc, 2048
	ldir




; DECOMPRESS from buffer to screen.
; =================================

	ld	iy, 0		; Global 0-2047
	ld	hl, buffer1	; vid buffer 1 $9000
	ld	de, buffer2	;buffer2	; vid buffer 2 $B000 
	ld	a, (hl)
l0b:	ld	c, 0
l1b:	ld	a, (hl)
	ld	c, a		; C := original char for later.
l2b:	inc	hl		; inc HL pointer.
	inc	iy		; global counter
	ld	(de), a		; write out first CHAR
	inc	de
	ld	a, (hl)		; read CHAR QNTY
	inc	hl
	cp	1
	jr	z, here		; if equals 1, then jump out.
	ld	b, a		; load B qnty.
	dec	b		; decrease QNTY by one coz already have one
	ld	a, c		; CHAR into a 
writing:ld	(de), a		; write out number of CHARs
	inc	de
	inc	iy
	djnz	writing
here:	push	hl
	push	de
	push	iy
	push	ix
	push	bc
	push	af
	push	iy
	pop	de
	ld	hl, 2048
	rst	$18
	jp	c, quit2
	pop	af
	pop	bc
	pop	ix
	pop	iy
	pop	de
	pop	hl
	jp	l0b

quit2: 	pop	af
	pop	bc
	pop	ix
	pop	iy
	pop	de
	pop	hl


	ld	hl, buffer2
	ld	de, video
	ld	bc, 2048
	ldir


forever:jp	forever

;	ei
;	jp 	$1a19			; Jump to VZ basic

	
nyan_pic:
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
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


astro_pic:
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB,0x3A,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xEA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA8,0x8A,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB,0x3A,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAE,0x0E,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA0,0xE2,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xB8,0x0C,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAE,0xAE,0xE2,0x6A,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xBA,0xE2,0x60,0x0C,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAB,0x83,0x33,0xB2,0xE3,0x2A,0xAA,0xAA,0xAA,0xAA,0xCA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAE,0x38,0x88,0x00,0x02,0x3A,0xAA,0xAA,0xAA,0x2E,0x38,0x2A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xEE,0xEA
defb 0xAA,0xAA,0xAA,0xC0,0x03,0x33,0xBB,0xB3,0x8A,0xAA,0xAA,0xAA,0xC1,0x04,0x0A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0x11,0x1B
defb 0xAA,0xAA,0xAB,0x8B,0xB8,0x88,0x00,0x08,0x3A,0xAA,0xAA,0xA0,0x04,0x03,0x2A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAC,0x00,0x04
defb 0xAA,0xAA,0xAA,0x70,0x03,0x33,0xBB,0xB3,0x8E,0xAA,0xAA,0x26,0x43,0x10,0x0A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xB0,0x4C,0x43
defb 0x3A,0xAA,0xB8,0x8B,0xB8,0x88,0xCC,0x08,0x22,0xAA,0xAA,0xC0,0x30,0x0C,0x0A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA1,0x00,0xC0
defb 0x6A,0xAA,0x8C,0x30,0x03,0x34,0x03,0xB3,0x39,0xAA,0xAA,0x4C,0x66,0x40,0xE2,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xC0,0xC4,0x30
defb 0x0E,0xAB,0x20,0x22,0xE2,0xC9,0xB0,0x22,0x02,0xAA,0xAC,0x20,0x0C,0x30,0x12,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0x90,0x03,0x06
defb 0x4B,0xB8,0xCE,0xCC,0x3C,0x10,0x0C,0xCC,0xEC,0xAA,0xA8,0xC4,0x41,0x01,0x08,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB,0x0C,0x4C,0x01
defb 0x90,0x00,0x88,0x22,0xC0,0x0C,0x40,0x22,0x02,0x2A,0xAC,0x10,0xC8,0x30,0xC0,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA8,0x00,0x00,0x4C
defb 0x3B,0xBB,0x33,0x33,0x03,0x03,0x0E,0x73,0x38,0xAA,0xA9,0x24,0x0D,0x0C,0x00,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAE,0x4C,0xC6,0x00
defb 0x64,0x00,0x88,0x89,0x30,0x64,0x00,0x02,0x27,0x2A,0xAC,0x13,0x32,0x40,0x4A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAC,0x00,0x01,0xCC
defb 0x30,0xEC,0xCC,0xE4,0x00,0xC8,0x31,0x3C,0xC0,0xEA,0xA0,0xC2,0x44,0x30,0x92,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xC3,0x11,0x30,0x00
defb 0xCA,0x02,0x22,0x30,0xC4,0xB0,0x00,0x0B,0x1C,0xAA,0xAC,0x04,0x20,0x04,0x02,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0x8C,0x0C,0x04,0xCE
defb 0x6E,0xEC,0xCC,0xC1,0x03,0x2E,0x33,0x10,0x21,0x9A,0x60,0xC3,0x11,0x30,0x4A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB,0x10,0x40,0xC8,0x01
defb 0xA6,0xA2,0x22,0xC0,0x32,0xE8,0x00,0x04,0x43,0x0B,0x83,0x00,0xE4,0x03,0x02,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0x48,0x30,0x11,0x1B
defb 0xAA,0xBC,0xF3,0x0C,0x00,0xB9,0x24,0xC3,0x30,0xE4,0x40,0x11,0x0C,0xCC,0x1A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB,0x04,0x01,0x0C,0xBA
defb 0xAA,0xA9,0x89,0x01,0x3B,0xAC,0xC0,0x00,0x80,0xC0,0x13,0x0C,0x90,0x00,0x6A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA6,0x43,0x12,0x01,0xE6
defb 0xAA,0xAB,0x04,0x90,0x00,0xBA,0x04,0xCC,0x0C,0x83,0x00,0x43,0x43,0x13,0x0A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA9,0x00,0x01,0xD8,0x0B
defb 0xAA,0xB0,0xC3,0x03,0x3B,0x21,0x10,0x03,0x80,0xC4,0x30,0x30,0xCC,0x00,0x2A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA4,0x30,0xCC,0x93,0x04
defb 0x66,0xA9,0x00,0x30,0x02,0xC0,0x0C,0x48,0xC3,0x00,0x04,0xC3,0x00,0x32,0x2A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB,0x04,0x00,0x0C,0x10
defb 0x1B,0xA2,0xC4,0x01,0x31,0x0C,0xC0,0x32,0x09,0x0C,0x40,0x34,0xC0,0x02,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA0,0x03,0x04,0x40,0x43
defb 0x00,0x4C,0x93,0x10,0x00,0xC0,0x13,0xAE,0xCC,0x10,0x33,0x0C,0x13,0x3A,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA8,0xE4,0x10,0x30,0x30
defb 0x10,0x00,0xE0,0x0C,0xC4,0x04,0x00,0xBB,0xA4,0xC3,0x0C,0x40,0x26,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0x00,0xC3,0x03,0x01
defb 0x0C,0x4C,0x43,0x00,0x03,0x93,0x30,0xEA,0x60,0x00,0x10,0x31,0x9A,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB,0x00,0x30,0x10
defb 0xC0,0x10,0x38,0x4C,0x4F,0x70,0x03,0xB9,0x91,0x31,0x0C,0x0B,0x2A,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xB1,0x01,0x0C
defb 0x0C,0xD4,0xC1,0x00,0x3F,0xF9,0x30,0x46,0x40,0x00,0xC0,0xC2,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0x4C,0x00
defb 0xC0,0x0C,0x04,0xC4,0xC3,0xB6,0x43,0x03,0x0C,0x4C,0x0C,0x2A,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAB,0x80,0xCC
defb 0x04,0x40,0x40,0x48,0x0C,0xC0,0x04,0x30,0x01,0x00,0xCA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xB8,0x90
defb 0x41,0x84,0x33,0x13,0x0C,0x4C,0x48,0x03,0x30,0xCC,0x8A,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xEC,0x8E,0x4C
defb 0x10,0x43,0x14,0x0C,0x02,0x00,0xC1,0x19,0x00,0x2A,0x6A,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAE,0x22,0x23,0x00
defb 0x33,0x0D,0x0C,0x40,0xED,0xC4,0x04,0xE4,0xC6,0xDA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xBB,0xB2,0xCE,0xC8,0x31
defb 0x90,0x00,0xC1,0x30,0x10,0x2E,0xCB,0x10,0x2E,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xBB,0xFB,0x80,0x40,0xB8,0x93,0x04
defb 0x03,0x34,0x13,0x01,0x03,0x01,0x04,0x0E,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xBF,0xF0,0x44,0x0C,0xC3,0x20,0x0C
defb 0x4C,0x04,0x04,0x10,0xC4,0x10,0x43,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xEF,0xFF,0x30,0xC3,0x38,0x88,0x0E,0x40
defb 0x00,0x43,0x31,0x0C,0x20,0xC3,0x2E,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xEF,0xFE,0xFF,0x81,0x00,0x0C,0xCC,0x88,0xC3
defb 0x30,0x30,0x40,0xC0,0x70,0x18,0xEA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xBB,0xFF,0xFF,0xFC,0x10,0xC4,0xE2,0x23,0x32,0x00
defb 0x04,0xC1,0x30,0x0C,0x9B,0x2A,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xBF,0xFF,0xFB,0xFF,0x0C,0x00,0x33,0x32,0x22,0xE4
defb 0xC0,0x04,0x04,0xC0,0xE6,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAB,0xFF,0xFF,0xFF,0xFE,0x00,0x33,0x22,0x23,0x38,0x39
defb 0x0C,0x4C,0xC0,0x18,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xB2,0xCB,0xFF,0xFE,0xFF,0xFD,0x31,0x00,0x4C,0xC2,0x22,0x20
defb 0x10,0x00,0x13,0x26,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAB,0x35,0x5F,0xFF,0xFF,0xFF,0xFF,0x00,0xC4,0xB8,0x8C,0xCC,0x8E
defb 0xC3,0x31,0x08,0xEA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xCD,0x15,0x5F,0xFF,0xEF,0xFE,0xFF,0x13,0x00,0x63,0x08,0x8B,0x20
defb 0x24,0x00,0x26,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xEA,0x55,0x5C,0xCF,0xFE,0xFF,0xFF,0xFF,0xB0,0x13,0x32,0x33,0x32,0xC2
defb 0xC8,0xCE,0x6A,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAD,0x53,0x05,0x7B,0xFF,0xFF,0xFF,0x7F,0xD9,0x00,0x83,0x22,0x20,0xB8
defb 0x8E,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAE,0xD5,0x53,0x77,0x5F,0xFF,0xFF,0xF3,0xBF,0xFF,0xB9,0xCB,0x33,0x33,0x0C
defb 0xEA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAB,0x55,0x5D,0x75,0xC7,0xFF,0xFF,0xFF,0xFF,0xFF,0xC0,0x10,0xB0,0x00,0x0B
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xA9,0x55,0x51,0x65,0x16,0xFF,0xFC,0xFF,0xCB,0xB3,0xFC,0x0C,0x4D,0xEE,0x6A
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xA4,0x11,0x55,0x55,0x5D,0x3B,0xEF,0xEF,0xFF,0xFF,0xF9,0x10,0x08,0x2A,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAE,0xAC,0xD5,0xCD,0xD7,0x3F,0xFF,0xFF,0xCF,0xFF,0xCE,0x46,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xA2,0x55,0x64,0x71,0xFF,0xFF,0xFF,0xFF,0xFF,0xFA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xB5,0x55,0x5D,0xD3,0x2F,0xFF,0xFF,0xFB,0xBF,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xEA,0x95,0x54,0x51,0x5B,0xFB,0xEE,0xC0,0x6A,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xA9,0x95,0x37,0x00,0xBC,0xC1,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAB,0xB3,0x08,0xCA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
defb 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA


end

