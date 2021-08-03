;Octode beeper music engine by Shiru (shiru@mail.ru) 02'11
;Eight channels of tone, per-pattern tempo
;One channel of interrupting drums, no ROM data required
;Feel free to do whatever you want with the code, it is PD

OP_NOP	equ #00
OP_RRA	equ #1f
OP_SCF	equ #37
OP_ORC	equ #b1


	module octode

play
	di
	ld hl,musicData
	push iy
	push hl
	pop iy
	exx
	push hl
	in a,(#1f)
	and #1f
	ld a,OP_NOP
	jr nz,$+4
	ld a,OP_ORC
	ld (soundLoop.checkKempston),a
	jr readNotes.readOrder

readNotes
.ptr=$+1
	ld hl,0
	ld a,(hl)
	cp 240
	jr c,.noLoop
	cp 255
	jr nz,.drum
.readOrder
	ld l,(iy)
	ld h,(iy+1)
	ld a,h
	or l
	jr nz,.setPattern
	ld l,(iy+2)
	ld h,(iy+3)
	push hl
	pop iy
	jr .readOrder
.setPattern
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld (.ptr),hl
	ld (.speed),bc
	inc iy
	inc iy
	jr readNotes
.drum
	inc hl
	ld (.ptr),hl
	ld b,8
	ld hl,.drum2
	ld (hl),OP_NOP
	inc hl
	djnz $-3
	sub 240
	jr z,.drum0
	ld b,a
	ld hl,.drum2
	ld (hl),OP_RRA
	inc hl
	djnz $-3
.drum0
	ld bc,100*256
.drum1
	ld a,c
.drum2=$
	rra
	rra
	rra
	rra
	rra
	rra
	rra
	rra
	xor b
	and 16
	out (#fe),a
	bit 0,(ix)
	inc c
	inc c
	xor a
	out (#fe),a
	djnz .drum1
	jr readNotes
.noLoop
	ld c,OP_SCF
	or a
	jr z,$+6
	ld (soundLoop.frq0),a
	ld a,c
	ld (soundLoop.off0),a
	inc hl
	ld a,(hl)
	or a
	jr z,$+6
	ld (soundLoop.frq1),a
	ld a,c
	ld (soundLoop.off1),a
	inc hl
	ld a,(hl)
	or a
	jr z,$+6
	ld (soundLoop.frq2),a
	ld a,c
	ld (soundLoop.off2),a
	inc hl
	ld a,(hl)
	or a
	jr z,$+6
	ld (soundLoop.frq3),a
	ld a,c
	ld (soundLoop.off3),a
	inc hl
	ld a,(hl)
	or a
	jr z,$+6
	ld (soundLoop.frq4),a
	ld a,c
	ld (soundLoop.off4),a
	inc hl
	ld a,(hl)
	or a
	jr z,$+6
	ld (soundLoop.frq5),a
	ld a,c
	ld (soundLoop.off5),a
	inc hl
	ld a,(hl)
	or a
	jr z,$+6
	ld (soundLoop.frq6),a
	ld a,c
	ld (soundLoop.off6),a
	inc hl
	ld a,(hl)
	or a
	jr z,$+6
	ld (soundLoop.frq7),a
	ld a,c
	ld (soundLoop.off7),a
	inc hl
	ld (.ptr),hl

.prevBC=$+1
	ld bc,0
.speed=$+1
	ld hl,0
	and a

soundLoop
	xor a		;4

	dec b		;4
	jr z,.la0	;7/12
	nop			;4
	jr .lb0		;12
.la0
.frq0=$+1
	ld b,0		;7
.off0=$
	scf			;4
.lb0
	dec c		;4
	jr z,.la1	;7/12
	nop			;4
	jr .lb1		;12
.la1
.frq1=$+1
	ld c,0		;7
.off1=$
	scf			;4
.lb1
	dec d		;4
	jr z,.la2	;7/12
	nop			;4
	jr .lb2		;12
.la2
.frq2=$+1
	ld d,0		;7
.off2=$
	scf			;4
.lb2
	dec e		;4
	jr z,.la3	;7/12
	nop			;4
	jr .lb3		;12
.la3
.frq3=$+1
	ld e,0		;7
.off3=$
	scf			;4
.lb3
	exx			;4
	out (#fe),a	;11
	dec b		;4
	jr z,.la4	;7/12
	nop			;4
	jr .lb4		;12
.la4
.frq4=$+1
	ld b,0		;7
.off4=$
	scf			;4
.lb4
	dec c		;4
	jr z,.la5	;7/12
	nop			;4
	jr .lb5		;12
.la5
.frq5=$+1
	ld c,0		;7
.off5=$
	scf			;4
.lb5
	dec d		;4
	jr z,.la6	;7/12
	nop			;4
	jr .lb6		;12
.la6
.frq6=$+1
	ld d,0		;7
.off6=$
	scf			;4
.lb6
	dec e		;4
	jr z,.la7	;7/12
	nop			;4
	jr .lb7		;12
.la7
.frq7=$+1
	ld e,0		;7
.off7=$
	scf			;4
.lb7
	exx			;4
	sbc a,a		;4
	and 16		;7
	out (#fe),a	;11
	dec l		;4
	jp nz,soundLoop	;10=275t
	dec h		;4
	jp nz,soundLoop	;10

	ld (readNotes.prevBC),bc

	xor a
	out (#fe),a
	
	in a,(#1f)
	and #1f
	ld c,a
	in a,(#fe)
	cpl
.checkKempston=$
	or c
	and #1f
	jp z,readNotes

stopPlayer
	pop hl
	exx
	pop iy
	ei
	ret

	endmodule