	output p4.obj
	org $8000


GRAFX_MEM_BUFFER1	EQU	$b000		; GRAFX BUFFER
GRAFX_MEM_BUFFER2	EQU	$b000 + 512	; GRAFX BUFFER
GRAFX_MEM_VIDEO		EQU	$7000		; GRAFX VIDEO
video_buffer_offset	EQU	$4000	; +$7000 = buffer at : $B000 


begin


; ----- START OF GRAFX SETUP

;	ld 	hl, 	GRAFX_MEM_BUFFER1		; CLS BUFFERs 1 , 2, 3, 4
;	ld 	(hl),96
;	ld 	de,$b001
;	ld 	bc,2048
;;	ldir
;	ld 	hl,$7000				; CLS VIDEO
;	ld 	(hl),96
;	ld 	de,$7001
;	ld 	bc,2048
;	ldir
	ld	bc, 512					; move alien1 grafx to buffer1
	ld	hl, alien1
;	ld	de, GRAFX_MEM_BUFFER1
	ld	de, GRAFX_MEM_VIDEO
	ldir
;	ld	bc, 512					; move alien2 grafx to buffer2
;	ld	hl, alien2
;	ld	de, GRAFX_MEM_BUFFER2
;	ldir

;
;anim1:	ld	bc, 512					; DISPLAY ALIEN 1 grafx.
;	ld	hl, GRAFX_MEM_BUFFER1
;	ld	de, GRAFX_MEM_VIDEO
;	ldir
;	ret



; ----- END OF GRAFX SETUP

here:


	ld hl,musicData
	call play
	jp begin


;Phaser2 beeper music engine by Shiru (shiru@mail.ru) 03'11
;Two channels of phase synth, per-pattern tempo
;One channel of interrupting drums
;Feel free to do whatever you want with the code, it is PD



OP_INCDE	equ $13
OP_DECDE	equ $1b
OP_DECHL	equ $2b
OP_ANDH		equ $a4
OP_XORH		equ $ac
OP_ORC		equ $b1
OP_ORH		equ $b4



play
	di
	exx
	push hl
	push iy
	ld (stopPlayer.oldSP),sp
	exx
	ld e,(hl)
	inc l
	ld d,(hl)
	inc l
	ld (readPos.pos),de
	ld e,(hl)
	inc l
	ld d,(hl)
	ld (drumSynth.drumSettings),de
	ld a,h
	ld (readRow.insList0),a
	ld (readRow.insList1),a





	ld hl,0
	ld (soundInit.ch0cnt0),hl
	ld ix,0						;ch0cnt1
	ld (readRow.ch1cnt0),hl
	ld iy,0						;ch1cnt1
	ld (soundInit.ch0add0),hl
	ld sp,hl					;ch0add1
	ld (readRow.ch1add0),hl
	ld (readRow.ch1add1),hl
	xor a
	ld (readRow.ch0int),a
	ld (readRow.ch1int),a
	ld (readRow.ch0det),a
	ld (readRow.ch1det),a
	ld a,64
	ld (readRow.ch0pha),a
	ld (readRow.ch1pha),a
	ld a,OP_XORH
	ld (soundLoop.op0),a
	ld (soundLoop.op1),a
	ld hl,1000
	ld (soundInit.len),hl
	exx
	ld hl,0						;ch1cnt0
	ld de,0						;ch1add1
	ld bc,0						;ch1add0
	exx

	in a,($1f)
	and $1f
	jr nz,$+4
	ld a,OP_ORC
	ld (readRow.enableKemp),a

readPos
.pos=$+1
	ld hl,0

.read
	ld e,(hl)
	inc l
	ld d,(hl)
	inc hl
	ld a,d
	or e
	jr z,.loop
	ld (.pos),hl
	ex de,hl
	ld e,(hl)
	inc l
	ld d,(hl)
	inc hl
	ld (soundInit.len),de
	jp readRow.read
.loop
	ld e,(hl)
	inc l
	ld d,(hl)
	ex de,hl
	jp .read

readRow
.pos=$+1
	
	ld hl,0
.read
	ld a,(hl)
	cp 246
	jp c,.ch0
	cp 255
	jp z,readPos
	inc hl
	ld (.pos),hl
	sub 246
	jp drumSynth

.ch0mute
	ld sp,0
	ld ix,0
	ld (soundInit.ch0cnt0),sp
	ld (soundInit.ch0add0),sp
	jp .ch1

.ch1mute
	exx
	ld hl,0
	ld d,h
	ld e,h
	ld b,h
	ld c,h
	exx
	jp .ch1skip

.ch0
	inc hl
	add a,a
	jp z,.ch1
	jp nc,.note0	;bit 7 is not set, it is a note

	ex de,hl		;set instrument of channel 0
.insList0=$+1
	ld h,0
	ld l,a
	ld a,(hl)
	inc l
	ld (.ch0int),a
	ld a,(hl)
	inc l
	ld (.ch0pha),a
	ld a,(hl)
	ld (.ch0det),a
	inc l
	ld a,(hl)
	ld (soundLoop.op0),a
	ex de,hl
	ld a,(hl)
	inc hl
	add a,a

.note0
	cp 2
	jr z,.ch0mute
	ex de,hl		;then read note and check for channel two data
	ld l,a
	add a,a
	jr nc,.ch0pskip
	ld ix,(soundInit.ch0cnt0)
.ch0pha=$+1
	ld a,0
	add a,ixh
	ld ixh,a
	res 7,l
.ch0pskip
	ld h,noteTable/256
	ld c,(hl)
	inc l
	ld b,(hl)
	ld (soundInit.ch0add0),bc
.ch0int=$+1
	ld a,0
	add a,l
	ld l,a
	ld b,(hl)
	dec l
	ld c,(hl)
.ch0det=$+1
	ld hl,0
	add hl,bc
	ld sp,hl		;ch0add1
	ex de,hl

.ch1
	ld a,(hl)
	inc hl
	add a,a
	jp z,.ch1skip
	jp nc,.note1

	ex de,hl		;set instrument of channel 1
.insList1=$+1
	ld h,0
	ld l,a
	ld a,(hl)
	inc l
	ld (.ch1int),a
	ld a,(hl)
	inc l
	ld (.ch1pha),a
	ld a,(hl)
	ld (.ch1det),a
	inc l
	ld a,(hl)
	ld (soundLoop.op1),a
	ex de,hl
	ld a,(hl)
	inc hl
	add a,a

.note1
	cp 2
	jp z,.ch1mute
	ex de,hl		;then read note and play a row
	ld l,a
	add a,a
	jr nc,.ch1pskip
	ld iy,(.ch1cnt0)
.ch1pha=$+1
	ld a,0
	add a,iyh
	ld iyh,a
	res 7,l
.ch1pskip
	ld h,noteTable/256
	ld c,(hl)
	inc l
	ld b,(hl)
	ld (.ch1add0),bc
.ch1int=$+1
	ld a,0
	add a,l
	ld l,a
	ld b,(hl)
	dec l
	ld c,(hl)
.ch1det=$+1
	ld hl,0
	add hl,bc
	ld (.ch1add1),hl
	ex de,hl
	exx
.ch1cnt0=$+1
	ld hl,0
.ch1add1=$+1
	ld de,0
.ch1add0=$+1
	ld bc,0
	exx

.ch1skip
	ld (.pos),hl

	in a,($1f)
	ld c,a
	xor a
	in a,($fe)
	cpl
.enableKemp=$
	or c
	and $1f
	jp z,soundInit

stopPlayer
.oldSP=$+1
	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret


soundInit
.skip=$+1
	ld hl,0
.len=$+1
;	ld de,$2710	;10000			; $2710  DJM
	ld	de, $2721
	ld a,h
	or l
	jp z,.noSkip
	ld a,h
	cp d
	jr c,.skipHL
	ld a,l
	cp e
	jr c,.skipHL
	and a
	sbc hl,de
	ld (.skip),hl
	jp readRow
.skipHL
	ex de,hl
	sbc hl,de
	ex de,hl
	ld hl,0
	ld (.skip),hl
.noSkip
.ch0cnt0=$+1
	ld hl,0
.ch0add0=$+1
	ld bc,200

soundLoop
	add hl,bc	;11
	ld a,h		;4
	add ix,sp	;15
.op0=$+1
	xor ixh		;8
	rla			;4
	sbc a,a		;4
	and 32	;7
	ld  ($6800), a
	exx			;4
	add hl,bc	;11
	ld a,h		;4
	add iy,de	;15
.op1=$+1
	xor iyh		;8
	rla			;4
	sbc a,a		;4
	and 32	;7
	ld  ($6800), a
	exx			;4
	dec de		;6
	ld a,d		;4
	or e		;4
	jp nz,soundLoop	;10=160t

	ld (soundInit.ch0cnt0),hl

	jp readRow


drumSynth
	ld (.prevIX),ix
	ld (.prevIY),iy

	add a,a
	ld b,a
	add a,a
	add a,a
	add a,b
	ld b,0
	ld c,a
.drumSettings=$+1
	ld hl,0
	add hl,bc
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld (soundInit.skip),bc
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,(hl)
	inc hl
	ld (.toneSFreq),a
	ld a,(hl)
	inc hl
	ld (.toneSlide),a
	ld a,(hl)
	inc hl
	ld (.noiseFrq),a
	ld a,(hl)
	ld (.noiseEnable),a

	ld hl,0
	ld ix,$0101
	ld iy,0
.l0
	add hl,de	;10
	ld a,(iy)	;19
	dec ixh		;8
	jp nz,.l1	;10
.noiseFrq=$+2
	ld ixh,1	;11
	inc iy		;10
	jp .l2		;10
.l1
	ld a,(iy)	;19
	jr $+2		;12
.l2
.noiseEnable=$+1
	and 32		;7
	ld  ($6800), a
	dec ixl		;8
	jp nz,.l3	;10
.toneSFreq=$+2
	ld ixl,5	;11
.toneSlide=$
	dec hl		;6
	jp .l4		;10
.l3
	jp $+3		;10
	jp $+3		;10
	ld a,0		;7
.l4
	ld a,h		;4
	rla			;4
	sbc a,a		;4
	and 32		;7
	ld  ($6800), a

	dec bc		;6
	ld a,b		;4
	or c		;4
	jp nz,.l0	;10=195t

.prevIX=$+2
	ld ix,0
.prevIY=$+2
	ld iy,0

	jp readRow





	align 256
noteTable
	dw $0000,$0000
	dw $00c3,$00cf,$00db,$00e9,$00f6,$0105,$0115,$0125,$0137,$0149,$015d,$0171
	dw $0187,$019f,$01b7,$01d2,$01ed,$020b,$022a,$024b,$026e,$0293,$02ba,$02e3
	dw $030f,$033e,$036f,$03a4,$03db,$0416,$0454,$0496,$04dc,$0526,$0574,$05c7
	dw $061f,$067c,$06df,$0748,$07b7,$082c,$08a8,$092c,$09b8,$0a4c,$0ae9,$0b8f
	dw $0c3f,$0cf9,$0dbf,$0e90,$0f6e,$1059,$1151,$1259,$1370,$1498,$15d2,$171e
	dw $187e,$19f3,$1b7e,$1d20,$1edc,$20b2,$22a3,$24b3,$26e1,$2931,$2ba4,$2e3c
	dw $30fc,$33e6,$36fc,$3a41,$3db8,$4164,$4547,$4966,$4dc3,$5263,$5748,$5c79
	dw $61f9,$67cc,$6df8,$7483,$7b71,$82c8,$8a8f,$92cc,$9b86,$a4c6,$ae91,$b8f3
	dw $0030,$0033,$0036,$003a,$003d,$0041,$0045,$0049,$004d,$0052,$0057,$005c ;lowest octaves
	dw $0061,$0067,$006d,$0074,$007b,$0082,$008a,$0092,$009b,$00a4,$00ae,$00b8




	align 256
musicData
	dw .start
	dw .drums
.insList
	db 0	;interval (offset from the base in semitones*2)
	db 64	;phase
	db 4	;detune (offset from the base in counter units)
	db OP_ORH
	db 0
	db 0
	db 8
	db OP_XORH
.drums
;tom
	dw 1000*195/160	;length in tone samples
	dw 1000	;length in drum samples
	dw 1800	;tone div
	db 1	;slide div
	db OP_DECDE	;slide direction, dec de,inc de,dec hl
	db 0	;noise div
	db 0	;noise enable
;snare
	dw 1500*195/160	;length in tone samples
	dw 1500	;length in drum samples
	dw 1500	;tone div
	db 1	;slide div
	db OP_DECDE	;slide direction, dec de,inc de,dec hl
	db 2	;noise div
	db 16	;noise enable
;kick
	dw 600*195/160	;length in tone samples
	dw 600	;length in drum samples
	dw 800	;tone div
	db 1	;slide div
	db OP_DECDE	;slide direction, dec de,inc de,dec hl
	db 0	;noise div
	db 0	;noise enable
;open hat
	dw 400*195/160	;length in tone samples
	dw 400	;length in drum samples
	dw 0	;tone div
	db 0	;slide div
	db OP_DECHL	;slide direction, dec de,inc de,dec hl
	db 1	;noise div
	db 16	;noise enable
;closed hat
	dw 100*195/160	;length in tone samples
	dw 100	;length in drum samples
	dw 0	;tone div
	db 0	;slide div
	db OP_DECHL	;slide direction, dec de,inc de,dec hl
	db 1	;noise div
	db 16	;noise enable
.start
.loop
	dw .pattern0
	dw .pattern0
	dw .pattern0
	dw .pattern0
	dw .pattern1
	dw .pattern1
	dw .pattern2
	dw .pattern3
	dw 0
	dw .loop
.pattern0
	dw 5000
	db 248,128+4,64+26,128+2,64+2
	db 249,28,64+14
	db 247,30,64+2
	db 249,31,64+14
	db 255
.pattern1
	dw 5000
	db 248,128+4,64+26,128+2,64+7
	db 249,28,64+19
	db 247,30,64+7
	db 249,31,64+19
	db 255
.pattern2
	dw 5000
	db 248,128+4,64+26,128+2,64+9
	db 249,28,64+21
	db 247,30,64+9
	db 249,31,64+21
	db 255
.pattern3
	dw 5000/2
	db 246,128+4,64+26,128+2,64+9
	db 0,0
	db 246,28,64+21
	db 0,0
	db 247,30,64+9
	db 246,0,0
	db 246,31,64+21
	db 246,0,0
	db 255








;=======================================
; ALIEN GRAFX DUDE DEF bytes
;=======================================
;	black = 128	white   = 207
;	green = 143	cyan    = 223
; 	yellow= 159	magenta = 239
;	blue  = 175	buff    = 255
;	red   = 191


alien1 defb 128,128,128,128,128,128,128,128,207,207,207,128,128,128,207,207,207,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line2 defb 128,128,128,128,128,128,128,207,207,128,207,207,128,207,207,128,207,207,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line3 defb 128,128,128,128,128,128,128,207,207,128,207,207,128,207,207,128,207,207,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line4 defb 128,128,128,128,128,128,128,128,207,207,207,128,128,128,207,207,207,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line5 defb 128,128,128,128,128,128,128,128,239,239,239,128,128,128,239,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line6 defb 128,128,128,239,239,128,128,128,128,239,239,128,128,128,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line7 defb 128,128,191,191,128,191,128,128,128,191,191,128,128,128,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line8 defb 128,128,191,191,128,128,128,128,128,191,191,128,128,128,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line9 defb 128,128,239,239,128,128,128,128,128,239,239,128,128,128,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line10 defb 128,128,239,239,239,128,128,128,239,239,239,239,128,239,239,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line11 defb 128,128,191,191,191,191,128,191,191,191,191,191,191,191,191,191,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line12 defb 128,128,191,191,191,191,191,191,191,191,191,191,191,191,191,191,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line13 defb 128,128,239,239,239,239,239,239,159,159,159,159,128,159,159,128,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line14 defb 128,128,239,239,239,239,239,128,159,159,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line15 defb 128,128,128,191,191,191,191,191,128,191,191,191,191,191,191,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a1line16 defb 128,128,128,128,191,191,191,191,191,191,191,191,191,191,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128

alien2 defb 128,128,128,128,128,128,128,128,239,239,239,128,128,128,239,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line2 defb 128,128,128,128,128,128,128,239,239,239,239,239,128,239,239,239,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line3 defb 128,128,128,128,128,128,128,207,207,128,207,207,128,207,207,128,207,207,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line4 defb 128,128,128,128,128,128,128,128,207,207,207,128,128,128,207,207,207,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line5 defb 128,128,128,128,239,239,128,128,239,239,239,128,128,128,239,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line6 defb 128,128,128,239,239,128,128,128,128,239,239,128,128,128,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line7 defb 128,128,191,191,191,128,128,128,128,191,191,128,128,128,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line8 defb 128,128,191,191,128,128,128,128,128,191,191,191,128,191,191,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line9 defb 128,128,239,239,128,128,128,128,239,239,239,239,239,239,239,239,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line10 defb 128,128,239,239,239,128,128,128,239,239,239,239,239,239,239,239,239,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line11 defb 128,128,191,191,191,191,128,191,159,159,159,159,128,159,159,128,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line12 defb 128,128,191,191,191,191,191,191,159,159,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line13 defb 128,128,239,239,239,239,239,239,159,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line14 defb 128,128,239,239,239,239,239,128,159,159,159,128,159,159,128,159,239,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line15 defb 128,128,128,191,191,191,191,191,128,191,191,191,191,191,191,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128
a2line16 defb 128,128,128,128,191,191,191,191,191,191,191,191,191,191,191,191,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128


.END

	
;	savesna "pha.obj",begin