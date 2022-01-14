

;AntEater - ZX Spectrum beeper engine
;by utz 08'2014
;
; BUILD WITH :  zcc +vz -zorg=32768 -O3 -vn -m anteat.c anteat.asm -o anteat.vz -create-app -lndos
;

XDEF _anteat
_anteat:
begin:
	ld hl,music_data
	call play
	ret
play:
	di
play_loop:
	ld (OrderPntr),hl
	call readOrder
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	jr z,play_loop
	xor a
	ld	(26624), a
	ld 	hl,$2758 ;restore alternative HL to default value
	exx
	ei
	ret
;**************************************************************************************************
readOrder:
	ld 	hl,(OrderPntr) ;get order pointer
	ld 	e,(hl) ;read pnt pointer
	inc 	hl
	ld 	d,(hl)
	inc 	hl
	ld 	(OrderPntr),hl
	ld 	a,d ;if pattern pointer = $0000, end of song reached
	or 	e
	ret 	z
	ld 	(PtnPntr),de
;**************************************************************************************************
readPtn:
	in 	a,($fe)
	cpl
	and 	$1f
	ret	nz
	ld 	a,$10
	ld 	(switch1 + 1),a
	ld 	(switch2 + 1),a
	ld 	hl,(PtnPntr)
	ld 	a,(hl) ;check for pattern end
	cp 	$ff
	jr 	z,readOrder
	ld 	a,(hl)
	and 	$fc ;and %11111100 ;mask lowest 2 bits
	ld 	b,a ;speed
	ld 	c,b
	ld 	a,(hl)
	and 	$3 ;and %00000011
	or 	a ;if !=0, we have drum
	call 	nz,drums
drdata:
	inc 	hl
	xor 	a
	ld 	d,(hl) ;counter ch2
	ld 	e,d
	push 	hl
;	ld 	h,$10 ;output mask ch2
	ld	h, 33
	or 	d
	jr 	nz,rdskip1
	ld 	h,a ;mute if note byte = 0
rdskip1:
	ld 	l,h ;swap mask
	exx
	pop 	hl
	inc 	hl
	ld 	b,(hl) ;counter A
	or 	b
	jr 	nz,rdskip2
	ld 	(switch1 + 1),a
	ld 	(switch2 + 1),a
rdskip2:
	ld 	c,b ;backup counter A/B
	ld 	d,b ;counter B
	inc 	hl
	ld 	(PtnPntr),hl
;	ld 	hl,$1000 ;output mask ch1
	ld 	hl,$2100 ;output mask ch1
	exx
;**************************************************************************************************
playloop:
	ld 	a,h ;4 ;load output mask ch2
	exx 	;4
	dec 	b ;4 ;dec counter A
	ld 	(26624), a
	jr 	nz,wait1 ;12/7
	ld 	a,h ;4 ;flip output mask and restore counter
.switch1
;	xor 	$10 ;7
	xor	33
	ld 	h,a ;4
	ld 	b,c ;4
skip1:
	dec 	d ;4 ;dec counter B
	ld 	a,l ;4 ;load output mask ch1
	jr 	nz,wait2 ;12/7
	ld 	d,c ;4 ;restore counter
.switch2
;	xor 	$10 ;7 ;swap output mask
	xor	33
	ld 	l,a ;4
	rra 	;4 ;increment counter to create pwm effect if output mask = $10
	rra 	;4
	rra 	;4
	rra 	;4
	add a,d ;4
	ld d,a ;4
skip2:
	ld 	a,l ;4
	and 	h ;4 ;combine output masks
;	out ($fe),a ;11 ;output ch1
	ld	(26624), a
	exx 	;4
	dec 	d ;4 ;decrement counter ch1
	jp 	nz,wait3 ;10
	ld 	d,e ;4 ;restore counter
	ld 	a,h ;4 ;swap output mask
	xor 	l ;4
	ld 	h,a ;4
skip3:
	dec 	bc ;6 ;decrement speed counter
	ld 	a,b ;4
	or 	c ;4
	nop 	;4 ;take care of IO contention
	jp 	nz,playloop ;10
;184
	jr readPtn
;**************************************************************************************************
wait1:
	nop;4
	jp skip1;10
wait2:
	sla (hl);15
	sla (hl);15
	nop;4
	jr skip2;12
;46
wait3:
	nop ;4
	jr skip3 ;12
;**************************************************************************************************
drums:
	push hl
	dec a
	ld hl,switch2 + 1
	ld d,$fd
	jr z,drum2
	dec a
	ld d,$bf
	ld hl,drdata+7
	jr z,drumloop3
drum1:
	ld hl,drdata
	ld a,c ;timing correction
	sub $c2
	ld c,a
	jr nc,tskip1
	dec b
tskip1:
	push bc
	ld b,12
drum1a:
	ld	a, 33
	ld	(26624), a
	ld a,(hl)
drumloop1:
	dec a
	jr nz,drumloop1

	ld	(26624), a
	ld 	a,(hl)
drumloop2:
	dec a
	jr nz,drumloop2
	inc hl
	djnz drum1a
	jr drumret
drum2:
	dec b ;timing correction
	ld a,$d9
	ld (switch3 + 1),a ;modify end marker value
drumloop3:
	ld a,c ;timing correction
	sub d
	jr nc,tskip2
	dec b
tskip2:
	push bc
drumloop30:
	ld	a, 33
	ld	(26624), a
.switch3
	ld a,6
	ld b,(hl)
	xor b
	jr z,drumret
dl3a:
	push hl
	pop hl
	djnz dl3a
	xor a
	ld (26624), a
	ld b,(hl)
dl3b:
	push hl
	pop hl
	djnz dl3b
	inc hl
	jr drumloop30
	ld a,6
	ld (switch3 + 1),a
drumret:
	pop bc
	pop hl
	ret
;**************************************************************************************************
OrderPntr: defw 0
PtnPntr: defw 0


;compiled music data
music_data:
defw 0
defw loop
loop:
defw pattern1
defw pattern3
defw pattern1
defw pattern3
defw pattern1
defw pattern3
defw pattern3
defw pattern3
defw pattern1
defw pattern1
defw pattern1
defw pattern2
defw pattern2
defw pattern2
defw pattern1
defw pattern1
defw pattern1
defw pattern2
defw pattern2
defw pattern2
defw 0
defw loop
pattern1:
defb $5,$40,$20
defb $4,$0,$0
defb $4,$0,$0
defb $4,$0,$0
defb $4,$39,$1c
defb $4,$0,$0
defb $4,$0,$0
defb $4,$0,$0
defb $ff
pattern2:
defb $5,$24,$40
defb $4,$0,$0
defb $4,$0,$0
defb $4,$0,$0
defb $4,$20,$39
defb $4,$0,$0
defb $4,$0,$0
defb $4,$0,$0
defb $ff
pattern3:
defb $5,$4,$60
defb $4,$0,$0
defb $4,$0,$0
defb $4,$0,$0
defb $4,$01,$56
defb $4,$0,$0
defb $4,$0,$0
defb $4,$0,$0
defb $ff

