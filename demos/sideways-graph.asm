; VZ sine wave graph thingy - sideways sliding. 
;
; 	128			32
; ------------              ----------
; |          |              |        |
; |          | 64           |        | 64
; |          |              |        |
; ------------              ----------
; 


	background equ 85

	ORG $8000

	di
	ld 	a,8			; mode (1)
	ld 	($6800),a

	ld	hl, $7000		; CLS screen
	ld	a, background
	ld	(hl), a
	ld	de, $7001
	ld	bc, 2048
	ldir
	
	ld	hl, $b000		; CLS buffer
	ld	a, background
	ld	(hl), a
	ld	de, $b001
	ld	bc, 2048
	ldir

	
	
	ld	de, $b000 + 31*32 -1	; Set start middle point, RHS, in buffer
	ld	(line1), de
	ld	de, $b000 + 31*32 -1	; Set start middle point, RHS, in buffer
	ld	(line2), de
	ld	de, $b000 + 31*32 -1	; Set start middle point, RHS, in buffer
	ld	(line3), de

start0:


	ld a,r
	rrca
	rrca
	neg
seed1: equ $ + 1
	xor 0
	rrca
	ld (seed1),a

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


	ld a,r
	rrca
	rrca
	neg
seed2: equ $ + 1
	xor 0
	rrca
	ld (seed2),a


	ld	de, (line2)	; get line 2
	cp	170		; determine to go LINE2 : FWD or BACK.  up or down.
	jp 	pe, FWD2	; 1/3: go down
	cp	85
	jp	pe, HERE3	; 1/3: go straight
	jp 	po, BACK2	; 1/3: go up

FWD2:	inc	de		; LINE 2. go down.
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
	jp 	HERE3	

BACK2:	dec	de			; LINE 2. go Up
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



HERE3:  ld 	(line2), de 	;save line 2
				; ========  DO LINE 3

	ld a,r
	rrca
	rrca
	neg
seed3: equ $ + 1
	xor 0
	rrca
	ld (seed3),a

	ld	de, (line3)	; get line 3
	cp	170		; determine to go LINE3 : FWD or BACK.  up or down.
	jp 	pe, FWD3	; 1/3: go down
	cp	85
	jp	pe, HERE4	; 1/3: go straight
	jp 	po, BACK3	; 1/3: go up

FWD3:	inc	de		; LINE 3. go down.
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
	jp 	HERE4

BACK3:	dec	de			; LINE 3. go Up
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
HERE4:	ld	(line3), de		; save line 3

	ld	de, (line1)
	ld	a, 255
	ld	(de), a

	ld	de, (line2)
	ld	a, 170
	ld	(de), a

	ld	de, (line3)
	ld	a, 0
	ld	(de), a



;	ld	hl, $b000
;	ld	de, $7000
;	ld	bc, 2048
;	ldir


	ld	hl, $b000
	ld	de, $7000
;	ld	bc, 2048

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
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	djnz	LOOP2




;	ld	hl, $7001
;	ld	de, $b000
;	ld	bc, 2048
;	ldir

	ld	hl, $7001
	ld	de, $b000


	ld	c, 0
	ld	b, 63			; Y = 64 rows
LOOP3:	ldi
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
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	djnz	LOOP3



	ld	a, background				; Wipe out RHS so to not scroll around and double up/trip up/quad up. Single line only.
	ld	de, $b000
	ld	(de), a
	ld	de, $b000+32
	ld	(de), a
	ld	de, $b000+32+32
	ld	(de), a
	ld	de, $b000+32+32+32
	ld	(de), a
	ld	de, $b000+32+32+32+32
	ld	(de), a
	ld	de, $b000+32+32+32+32+32
	ld	(de), a
	ld	de, $b000+32+32+32+32+32+32
	ld	(de), a
	ld	de, $b000+   64+   64+   64+32
	ld	(de), a
	ld	de, $b000+   64+   64+   64+   64
	ld	(de), a
	ld	de, $b000+        128+        128+   32
	ld	(de), a
	ld	de, $b000+128+128+64
	ld	(de), a
	ld	de, $b000+128+128+64+32
	ld	(de), a
	ld	de, $b000+128+128+128
	ld	(de), a
	ld	de, $b000+128+128+128+32
	ld	(de), a
	ld	de, $b000+128+128+128+64
	ld	(de), a
	ld	de, $b000+128+128+128+64+32
	ld	(de), a
	ld	de, $b000+128+128+128+128
	ld	(de), a
	ld	de, $b000+128+128+128+128+32
	ld	(de), a
	ld	de, $b000+128+128+128+128+64
	ld	(de), a
	ld	de, $b000+128+128+128+128+64+32
	ld	(de), a
	ld	de, $b000+128+128+128+128+128
	ld	(de), a
	ld	de, $b000+128+128+128+128+128+32
	ld	(de), a
	ld	de, $b000+128+128+128+128+128+64
	ld	(de), a
	ld	de, $b000+128+128+128+128+128+64+32
	ld	(de), a
	ld	de, $b000+128+128+128+128+128+128
	ld	(de), a
	ld	de, $b000+256+256+256+32
	ld	(de), a
	ld	de, $b000+256+256+256+64
	ld	(de), a
	ld	de, $b000+256+256+256+64+32
	ld	(de), a
	ld	de, $b000+256+256+256+128
	ld	(de), a
	ld	de, $b000+256+256+256+128+32
	ld	(de), a
	ld	de, $b000+256+256+256+128+64
	ld	(de), a
	ld	de, $b000+256+256+256+128+64+32
	ld	(de), a
	ld	de, $b000+256+256+256+256
	ld	(de), a
	ld	de, $b000+256+256+256+256+32
	ld	(de), a
	ld	de, $b000+256+256+256+256+64
	ld	(de), a
	ld	de, $b000+256+256+256+256+64+32
	ld	(de), a
	ld	de, $b000+256+256+256+256+128
	ld	(de), a
	ld	de, $b000+256+256+256+256+128+32
	ld	(de), a
	ld	de, $b000+256+256+256+256+128+64
	ld	(de), a
	ld	de, $b000+256+256+256+256+128+64+32
	ld	(de), a
	ld	de, $b000+256+256+256+256+256
	ld	(de), a
	ld	de, $b000+512+512+256+32
	ld	(de), a
	ld	de, $b000+512+512+256+64
	ld	(de), a
	ld	de, $b000+512+512+256+64+32
	ld	(de), a
	ld	de, $b000+512+512+256+128
	ld	(de), a
	ld	de, $b000+512+512+256+128+32
	ld	(de), a
	ld	de, $b000+512+512+256+128+64
	ld	(de), a
	ld	de, $b000+512+512+256+128+64+32
	ld	(de), a
	ld	de, $b000+512+512+512
	ld	(de), a
	ld	de, $b000+512+512+512+32
	ld	(de), a
	ld	de, $b000+512+512+512+64
	ld	(de), a
	ld	de, $b000+512+512+512+64+32
	ld	(de), a
	ld	de, $b000+512+512+512+128
	ld	(de), a
	ld	de, $b000+512+512+512+128+32
	ld	(de), a
	ld	de, $b000+512+512+512+128+64
	ld	(de), a
	ld	de, $b000+512+512+512+128+64+32
	ld	(de), a
	ld	de, $b000+512+512+512+256
	ld	(de), a
	ld	de, $b000+512+512+512+256+32
	ld	(de), a
	ld	de, $b000+512+512+512+256+64
	ld	(de), a
	ld	de, $b000+512+512+512+256+64+32
	ld	(de), a
	ld	de, $b000+512+512+512+256+128
	ld	(de), a
	ld	de, $b000+512+512+512+256+128+32
	ld	(de), a
	ld	de, $b000+512+512+512+256+128+64
	ld	(de), a
	ld	de, $b000+512+512+512+256+128+64+32
	ld	(de), a
	ld	de, $b000+512+512+512+512
	ld	(de), a





;	call	DELAY2

	

	jp	start0




DELAY2:	
	push	de
	push	bc
	;	ld	c, 0
	ld	b, 100
LOOPD3:	push	bc
		ld	b, 100
LOOPD4:		djnz	LOOPD4
	pop	bc
	djnz	LOOPD3
	pop	bc
	pop	de
	ret



RND:

	ld a,r
	rrca
	rrca
	neg
seed: equ $ + 1
	xor 0
	rrca
	ld (seed),a
	ret

	line1	dw 0
	line2	dw 0
	line3	dw 0



END