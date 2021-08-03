; NYAN CAT de-compression RLE routine.
;
;
; To create compression routine:
;    Get PSP RAW image. (nyan1.raw)
;    STEPL NYAN1.RAW NYAN1.OUT     Option (A)    - Does nibbling into hex and outputs.
;    COMPRESS NYAN1.OUT NYAN1.RLE 		 - Does RLE compression and outputs.
;    STEPL NYAN1.RLE NYAN1.INC			 - Converts .RLE compressed BIN into an ASCII include file.
;    Get ascii include file, and add to this decmopression program.
;    Assemble and run.
;
;	
; Reads in from NYAN_PIC  (ASCII compressed RLE version of RAW screenshot)
; Decompresses and writes into BUFFER2
; BUFFER into $7000 video.
; Displays NYAN1.
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
	ld	hl, nyan_pic	; vid buffer 1 $9000
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


	ei

	ld	hl, buffer2
	ld	de, video
	ld	bc, 2048
	ldir


forever:jp	forever

;	ei
;	jp 	$1a19			; Jump to VZ basic

	
nyan_pic:
db $0AA,$06E,$0BF,$001,$0FF,$005,$0FA,$001,$0AA,$019,$0D5,$001,$055,$005,$05E,$001
db $0AA,$018,$0AB,$001,$055,$006,$057,$001,$0AA,$00B,$0AB,$001,$0FF,$001,$0FA,$001
db $0AA,$001,$0BF,$001,$0FF,$001,$0AA,$001,$0AB,$001,$0FF,$001,$0FA,$001,$0AA,$001
db $0BF,$001,$0FF,$001,$0ED,$001,$055,$002,$057,$001,$055,$002,$05D,$001,$057,$001
db $0AA,$00B,$0FF,$00D,$0ED,$001,$055,$006,$057,$001,$0AA,$00B,$0FD,$001,$055,$001
db $05F,$001,$0FF,$001,$0D5,$001,$055,$001,$0FF,$001,$0FD,$001,$055,$001,$05F,$001
db $0FF,$001,$0D5,$001,$055,$001,$06D,$001,$057,$001,$055,$002,$057,$001,$05D,$001
db $055,$001,$057,$001,$0AA,$001,$0BA,$001,$0AA,$009,$055,$00D,$06D,$001,$055,$004
db $077,$001,$055,$001,$057,$001,$0AA,$001,$0DE,$001,$0AA,$009,$054,$001,$000,$001
db $005,$001,$055,$001,$040,$001,$000,$001,$055,$001,$054,$001,$000,$001,$005,$001
db $055,$001,$040,$001,$000,$001,$02D,$001,$055,$004,$075,$001,$0D5,$001,$057,$001
db $0AB,$001,$05E,$001,$0AA,$009,$000,$00D,$02D,$001,$055,$004,$075,$002,$057,$001
db $0AD,$001,$05E,$001,$0AA,$009,$002,$001,$0AA,$001,$0A0,$001,$000,$001,$02A,$001
db $0AA,$001,$000,$001,$002,$001,$0AA,$001,$0A0,$001,$000,$001,$02A,$001,$0AA,$001
db $0AD,$001,$055,$002,$05D,$001,$055,$001,$075,$001,$05D,$001,$057,$001,$0B5,$001
db $05E,$001,$0AA,$016,$0AD,$001,$057,$001,$055,$003,$075,$001,$057,$001,$0FF,$001
db $0D5,$001,$05E,$001,$0AA,$009,$0AB,$001,$0FF,$001,$0FA,$001,$0AA,$001,$0BF,$001
db $0FF,$001,$0AA,$001,$0AB,$001,$0FF,$001,$0FA,$001,$0AA,$001,$0BF,$001,$0FF,$001
db $0ED,$001,$055,$004,$075,$001,$055,$003,$05E,$001,$0AA,$009,$0FF,$00D,$0ED,$001
db $055,$004,$075,$001,$055,$003,$05E,$001,$0AA,$009,$0FD,$001,$055,$001,$05F,$001
db $0FF,$001,$0D5,$001,$055,$001,$0FF,$001,$0FD,$001,$055,$001,$05F,$001,$0FF,$001
db $0D7,$001,$0FF,$001,$0FD,$001,$055,$003,$057,$001,$0D5,$001,$049,$001,$055,$001
db $025,$001,$057,$001,$0EA,$001,$0AA,$008,$055,$00B,$05D,$001,$055,$001,$05D,$001
db $075,$001,$055,$001,$075,$001,$05D,$001,$055,$001,$069,$001,$055,$001,$0A5,$001
db $055,$001,$07A,$001,$0AA,$008,$054,$001,$000,$001,$005,$001,$055,$001,$040,$001
db $000,$001,$055,$001,$054,$001,$000,$001,$005,$001,$055,$001,$075,$001,$055,$001
db $05D,$001,$055,$003,$05D,$001,$055,$002,$07D,$001,$055,$002,$07A,$001,$0AA,$008
db $000,$00B,$035,$001,$07F,$001,$0FD,$001,$055,$003,$05D,$001,$045,$001,$055,$003
db $045,$001,$07A,$001,$0AA,$008,$002,$001,$0AA,$001,$0A0,$001,$000,$001,$02A,$001
db $0AA,$001,$000,$001,$002,$001,$0AA,$001,$0A0,$001,$000,$001,$0D5,$001,$0EA,$001
db $0AD,$001,$055,$003,$05D,$001,$055,$001,$075,$003,$055,$001,$07A,$001,$0AA,$013
db $0D7,$001,$0AA,$001,$0AD,$001,$055,$003,$057,$001,$055,$001,$07F,$001,$0FF,$001
db $0F5,$001,$055,$001,$0EA,$001,$0AA,$013,$0BE,$001,$0AA,$001,$0AD,$001,$055,$001
db $075,$001,$055,$002,$0D5,$001,$055,$003,$057,$001,$0AA,$016,$0AB,$001,$055,$004
db $075,$001,$055,$003,$05E,$001,$0AA,$017,$0D5,$001,$055,$003,$05F,$001,$0FF,$003
db $0FA,$001,$0AA,$016,$0B5,$001,$0FF,$004,$0FA,$001,$0B5,$001,$0AA,$001,$0D6,$001
db $0AA,$017,$0B5,$001,$0EB,$001,$05E,$001,$0AA,$003,$0B5,$001,$0AA,$001,$0D6,$001
db $0AA,$017,$0B7,$001,$0AB,$001,$07A,$001,$0AA,$003,$0D6,$001,$0AB,$001,$05A,$001
db $0AA,$017,$0BE,$001,$0AA,$001,$0FA,$001,$0AA,$0FF,$0AA,$0FF,$0AA,$0FF,$0AA,$0FF
db $0AA,$0FF
 ; ---------------------------------------------------------



end

