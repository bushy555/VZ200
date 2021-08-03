;ntropic
;beeper routine by utz 01'14 (irrlichtproject.de)
;2ch tone, 1ch noise, click drum, size 151 bytes
;uses ROM data in range $0000-$3800
;this code is public domain

	org $8000

begin	
	call	$01c9		; VZ ROM CLS
	ld	hl, MSG1	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG3	; Print MENU
	call	$28a7		; VZ ROM Print string.

	di
	push ix
	push iy
	ld c,0			;initialize speed counter
reset	ld hl,ptab		;setup pattern sequence table pointer
	
lpt	ld e,(hl)		;read pattern pointer
	inc hl
	ld d,(hl)
	ld a,e
	or d
	jr z,reset		;if d=0, loop to start
	;jr z,exit		;or exit
	inc hl
	push hl			;preserve pattern pointer
	ex de,hl		;put data pointer in hl

	call main
	
	pop hl
	jr z,lpt		;if no key has been pressed, read next pattern
	
exit	ld hl,$2758		;restore hl' for return to BASIC
	exx
	pop iy
	pop ix
	ei
	ret

;****************************************************************************************
main	push hl			;preserve data pointer
	ld ix,skip1
	
	
rdata	ld iyh,$10		;output switch mask
	
	;ld a,(speed)
	;ld b,a			;timer
	pop hl			;restore data pointer
	
	ld a,(hl)		;read drum byte
	inc a			;and exit if it was $ff
	ret z
	
	ld a,(hl)		;read speed
	and %11111110
	ld b,a
	
	;dec a
	ld a,(hl)
	rra
	;call nz,drum
	call c,drum
	
	inc hl
	
;	in a,($fe)		;read keyboard
;	cpl
;	and $1f
;	ret nz
	
	ld a,(hl)		;read counter ch1
	
	or a			;mute switch ch1
	jr nz,rsk1
	ld iyh,a
	
rsk1	ld d,a
	ld e,a
	
	inc hl
		
	push hl			;read counter ch2
	exx
	pop hl
	ld b,32
	ld a,(hl)
	
	or a			;mute switch ch2
	jr nz,rsk2
	ld b,a
	
rsk2	ld d,a
	ld e,d
	ld hl,skip2
	exx
	
	inc hl
	ld a,(hl)		;read noise length val
	inc hl
	push hl			;preserve data pointer
	ld h,a			;setup ROM pointer for noise, length to h	
	xor a			;mask for ch1
	ld l,a			;and part 2 of ROM pointer setup
	ex af,af'
	xor a			
	push af			;mask for ch2

;****************************************************************************************
sndlp	ex af,af'	;4
;	out ($fe),a	;11
	and 33
	ld (26624), a
	dec d		;4	;decrement counter ch1
	jp nz,wait1	;10	;if counter=0
	
m1 equ $+1
	xor iyh		;8	;flip output mask and reset counter
	ld d,e		;4
skip1	

	ex af,af'	;4
	exx		;4
	pop af		;10	;load output mask ch2
				;44t output for ch1
	
	
;	out ($fe),a	;11
	and 33
	ld (26624), a

	dec d		;4	;decrement counter ch2
	jp nz,wait2	;10	;if counter=0
	
m2 equ $+1
	xor b		;4	;flip output mask and reset counter
	ld d,e		;4
skip2	
	push af		;11	;preserve output mask ch2
	exx		;4
	
	
noise	ld a,(hl)	;7	;read byte from ROM
				;43t output for ch2
	and 32		;7	;waste some time
	
;	out ($fe),a	;11	;output whatever
	and 33
	ld (26624), a

	bit 7,h		;8	;check if ROM pointer has rolled over to $ffxx
	jp nz,wait3	;10
	
	dec hl		;6	;decrement ROM pointer
	nop		;4	;waste some time
	
dtim
	dec bc		;6	;decrement timer
	ld a,b		;4
	or c		;4
	jp nz,sndlp	;10	;repeat sound loop until bc=0
			;184
	
	pop af			;clean stack
	jr rdata		;read next note

;****************************************************************************************
wait1	nop		;4
	jp (ix)		;8

wait2	nop		;4
	jp (hl)		;4
	
wait3	jp dtim		;10

	
drum	push hl			;preserve data pointer
	push bc			;preserve timer
	ld hl,$3000		;setup ROM pointer - change val for different drum sounds
	ld de,$0809		;loopldiloop
	ld b,72
	
dlp3	ld a,(hl)		;read byte from ROM
;	out ($fe),a		;output whatever
	and 33
	ld (26624), a


	dec hl			;decrement ROM pointer $2b/$23 (inc hl)
	;inc hl			;use this instead for quieter click drum
	dec bc			;decrement timer

dlp4	dec d
	jr nz,dlp4
	
	ld d,e
	inc e
	djnz dlp3
	
	pop bc			;restore timer
	pop hl
	dec b			;adjust timing
	ret



MSG1	db "NTROPIC ENGINE. BY UTZ", $0d
MSG2	db "VZ CONVERSION BY BUSHY.",$0d,0
MSG3	db "SONG: NTROPIC DEMO.",$0d
	db "AUG 2019.",$0d
	db 0,0,0


;****************************************************************************************	
;music data

	

ptab
	dw ptn0
	dw ptn0
	dw ptn1
	dw ptn0
	dw 0

ptn0
	db $9,$80,$40,$30
	db $8,$80,$36,$30
	db $8,$80,$2b,$0
	db $8,$80,$24,$0
	db $8,$40,$20,$2
	db $8,$40,$1b,$0
	db $8,$40,$15,$2
	db $8,$40,$12,$0
	db $9,$80,$40,$0
	db $8,$80,$36,$0
	db $8,$80,$2b,$0
	db $8,$80,$24,$0
	db $8,$40,$20,$2
	db $8,$40,$1b,$0
	db $8,$40,$15,$2
	db $8,$40,$12,$0
	db $9,$80,$40,$0
	db $8,$80,$36,$0
	db $8,$80,$2b,$0
	db $8,$80,$24,$0
	db $8,$40,$20,$2
	db $8,$40,$1b,$0
	db $8,$40,$15,$2
	db $8,$40,$12,$0
	db $9,$6b,$40,$0
	db $8,$6b,$36,$0
	db $8,$6b,$2b,$0
	db $8,$6b,$24,$0
	db $8,$36,$20,$2
	db $8,$36,$1b,$0
	db $8,$36,$15,$2
	db $8,$36,$12,$0
	db $9,$80,$40,$0
	db $8,$80,$36,$0
	db $8,$80,$2b,$0
	db $8,$80,$24,$0
	db $8,$40,$20,$2
	db $8,$40,$1b,$0
	db $8,$40,$15,$2
	db $8,$40,$12,$0
	db $9,$80,$40,$0
	db $8,$80,$36,$0
	db $8,$80,$2b,$0
	db $8,$80,$24,$0
	db $8,$40,$20,$2
	db $8,$40,$1b,$0
	db $8,$40,$15,$2
	db $8,$40,$12,$0
	db $9,$80,$40,$0
	db $8,$80,$36,$0
	db $8,$80,$2b,$0
	db $8,$80,$24,$0
	db $8,$40,$20,$2
	db $8,$40,$1b,$0
	db $8,$40,$15,$2
	db $8,$40,$12,$0
	db $9,$2b,$40,$4
	db $8,$2b,$36,$0
	db $8,$2b,$2b,$0
	db $8,$2b,$24,$0
	db $9,$36,$20,$2
	db $8,$36,$1b,$0
	db $9,$36,$15,$2
	db $8,$36,$12,$0
	db $ff

ptn1
	db $9,$60,$30,$30
	db $8,$60,$28,$30
	db $8,$60,$20,$0
	db $8,$60,$1b,$0
	db $8,$30,$18,$2
	db $8,$30,$14,$0
	db $8,$30,$10,$2
	db $8,$30,$d,$0
	db $9,$60,$30,$0
	db $8,$60,$28,$0
	db $8,$60,$20,$0
	db $8,$60,$1b,$0
	db $8,$30,$18,$2
	db $8,$30,$14,$0
	db $8,$30,$10,$2
	db $8,$30,$d,$0
	db $9,$60,$30,$0
	db $8,$60,$28,$0
	db $8,$60,$20,$0
	db $8,$60,$1b,$0
	db $8,$30,$18,$2
	db $8,$30,$14,$0
	db $8,$30,$10,$2
	db $8,$30,$d,$0
	db $9,$50,$30,$0
	db $8,$50,$28,$0
	db $8,$50,$20,$0
	db $8,$50,$1b,$0
	db $8,$28,$18,$2
	db $8,$28,$14,$0
	db $8,$28,$10,$2
	db $8,$28,$d,$0
	db $9,$60,$30,$0
	db $8,$60,$28,$0
	db $8,$60,$20,$0
	db $8,$60,$1b,$0
	db $8,$30,$18,$2
	db $8,$30,$14,$0
	db $8,$30,$10,$2
	db $8,$30,$d,$0
	db $9,$60,$30,$0
	db $8,$60,$28,$0
	db $8,$60,$20,$0
	db $8,$60,$1b,$0
	db $8,$30,$18,$2
	db $8,$30,$14,$0
	db $8,$30,$10,$2
	db $8,$30,$d,$0
	db $9,$60,$30,$0
	db $8,$60,$28,$0
	db $8,$60,$20,$0
	db $8,$60,$1b,$0
	db $8,$30,$18,$2
	db $8,$30,$14,$0
	db $8,$30,$10,$2
	db $8,$30,$d,$0
	db $9,$8f,$30,$4
	db $8,$8f,$28,$0
	db $8,$8f,$20,$0
	db $8,$8f,$1b,$0
	db $9,$48,$18,$2
	db $8,$48,$14,$0
	db $9,$48,$10,$2
	db $8,$48,$d,$0
	db $ff


end
