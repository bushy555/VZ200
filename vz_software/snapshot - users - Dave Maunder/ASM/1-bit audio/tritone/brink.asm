
;Tritone v2 beeper music engine by Shiru (shiru@mail.ru) 03'11
;Three channels of tone, per-pattern tempo
;One channel of interrupting drums
;Feel free to do whatever you want with the code, it is PD
;
;
; TRITONE Engine
; Song :JOURNEY (found within Z88DK Tritone examples)
; VZ conversion: Sep 19
;
; Assemble with PASMO
;
; 	pasmo --alocal %1.asm
; 	rbinary %1.obj %1.vz


OP_NOP	equ $00
OP_SCF	equ $37
OP_ORC	equ $b1


	org $8000

begin

	ld hl,musicData
	call play
	jp begin


NO_VOLUME equ 0			;define this if you want to have the same volume for all the channels

play
	di
	ld (.nppos),hl
	ld c,33
	push iy
	exx
	push hl
	ld (.prevSP),sp
	xor a
	ld h,a
	ld l,h
	ld (.cnt0),hl
	ld (.cnt1),hl
	ld (.cnt2),hl
	ld (.duty0),a
	ld (.duty1),a
	ld (.duty2),a
	ld (.skipDrum),a
;	in a,($1f)
;;	and $1f
;	ld a,OP_NOP
;	jr nz,$+4
;	ld a,OP_ORC
;	ld (.checkKempston),a
	jp nextPos

nextRow
.nrpos equ $+1
	ld hl,0
	ld a,(hl)
	inc hl
	cp 2
	jr c,.ch0
	cp 128
	jr c,drumSound
	cp 255
	jp z,nextPos

.ch0
	ld d,1
	cp d
	jr z,.ch1
	or a
	jr nz,.ch0note
	ld b,a
	ld c,a
	jr .ch0set
.ch0note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
.ch0set
	ld (.duty0),a
	ld (.cnt0),bc
.ch1
	ld a,(hl)
	inc hl
	cp d
	jr z,.ch2
	or a
	jr nz,.ch1note
	ld b,a
	ld c,a
	jr .ch1set
.ch1note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
.ch1set
	ld (.duty1),a
	ld (.cnt1),bc
.ch2
	ld a,(hl)
	inc hl
	cp d
	jr z,.skip
	or a
	jr nz,.ch2note
	ld b,a
	ld c,a
	jr .ch2set
.ch2note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
.ch2set
	ld (.duty2),a
	ld (.cnt2),bc

.skip
	ld (.nrpos),hl
.skipDrum equ $
	scf
	jp nc,playRow
	ld a,OP_NOP
	ld (.skipDrum),a

	ld hl,(.speed)
	ld de,-150
	add hl,de
	ex de,hl
	jr c,$+5
	ld de,257
	ld a,d
	or a
	jr nz,$+3
	inc d
	ld a,e
	or a
	jr nz,$+3
	inc e
	jP .drum

drumSound
	ld (.nrpos),hl

	add a,a
	ld ixl,a
	ld ixh,0
	ld bc,drumSettings-4
	add ix,bc
	cp 14*2
	ld a,OP_SCF
	ld (.skipDrum),a
	jr nc,drumNoise

drumTone
	ld bc,2
	ld a,b
	ld de,$2100	; DJM
	ld l,(ix)
.l01
	bit 0,b
	jr z,.l11
	dec e
	jr nz,.l11
	ld e,l
	exa
	ld a,l
	add a,(ix+1)
	ld l,a
;	exa
	ex af,af'
	xor d
.l11
	ld (26624), a
	djnz .l01
	dec c
	jr nz,.l01

	jp nextRow

drumNoise
	ld b,0
	ld h,b
	ld l,h
	ld de,$2100	; DJM
.l02
	ld a,(hl)
	and d
	ld (26624), a
	and (ix)
	dec e
	ld (26624), a
	jr nz,.l12
	ld e,(ix+1)
	inc hl
.l12
	djnz .l02

	jp nextRow

nextPos
.nppos equ $+1
	ld hl,0
.read
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,d
	or e
	jr z,orderLoop
	ld (.nppos),hl
	ex de,hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld (.nrpos),hl
	ld (.speed),bc
	jp nextRow

orderLoop
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	jr .read

playRow
.speed equ $+1
	ld de,0
.drum
.cnt0 equ $+1
	ld bc,0
.prevHL equ $+1
	ld hl,0
	exx
.cnt1 equ $+1
	ld de,0
.cnt2 equ $+1
	ld sp,0
	exx


soundLoop
	if NO_VOLUME = 1		;all the channels has the same volume
	
	add hl,bc	;11
	ld a,h		;4
.duty0 equ $+1
	cp 128		;7
	sbc a,a		;4
	exx			;4
	and c		;4
	ld (26624), a	;11
	add ix,de	;15
	ld a,ixh	;8
.duty1 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	ld (26624), a	;11
	add hl,sp	;11
	ld a,h		;4
.duty2 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	exx			;4
	dec e		;4
	ld (26624), a	;11
	jr nz,soundLoop	;10=153t
	dec d		;4
	jr nz,soundLoop	;10
	
	else				; all the channels has different volume

	add hl,bc	;11
	ld a,h		;4
	exx			;4
.duty0 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	add ix,de	;15
	ld (26624), a	;11
	ld a,ixh	;8
.duty1 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	ld (26624), a	;11
	add hl,sp	;11
	ld a,h		;4
.duty2 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	exx			;4
	dec e		;4
	ld (26624), a	;11
	jr nz,soundLoop	;10=153t
	dec d		;4
	jr nz,soundLoop	;10
	
	endif
	

;	xor a
;	ld (26624), a

	ld (.prevHL),hl

;	in a,($1f)
;	and $1f
;	ld c,a
;	in a,($fe)
;	cpl
;.checkKempston equ $
;	or c
;	and $1f
;	jp z,nextRow
	jp nextRow

stopPlayer
.prevSP equ $+1
	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret

drumSettings
	db $01,$01	;tone,highest
	db $01,$02
	db $01,$04
	db $01,$08
	db $01,$20
	db $20,$04
	db $40,$04
	db $40,$08	;lowest
	db $04,$80	;special
	db $08,$80
	db $10,$80
	db $10,$02
	db $20,$02
	db $40,$02
	db $16,$01	;noise,highest
	db $16,$02
	db $16,$04
	db $16,$08
	db $16,$10
	db $00,$01
	db $00,$02
	db $00,$04
	db $00,$08
	db $00,$10





musicData:

; *** Song layout ***
LOOPSTART:            DEFW      PAT5
                      DEFW      PAT5
                      DEFW      PAT6
                      DEFW      PAT7
                      DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT2
                      DEFW      PAT3
                      DEFW      PAT4
                      DEFW      PAT8
                      DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT2
                      DEFW      PAT3
                      DEFW      PAT9
                      DEFW      PAT24
                      DEFW      PAT21
                      DEFW      PAT22
                      DEFW      PAT23
                      DEFW      PAT11
                      DEFW      PAT12
                      DEFW      PAT13
                      DEFW      PAT14
                      DEFW      PAT15
                      DEFW      PAT16
                      DEFW      PAT17
                      DEFW      PAT18
                      DEFW      PAT11
                      DEFW      PAT12
                      DEFW      PAT13
                      DEFW      PAT14
                      DEFW      PAT15
                      DEFW      PAT16
                      DEFW      PAT17
                      DEFW      PAT18
                      DEFW      PAT19
                      DEFW      PAT20
                      DEFW      PAT19
                      DEFW      PAT20
                      DEFW      PAT25
                      DEFW      PAT26
                      DEFW      PAT27
                      DEFW      PAT28
                      DEFW      PAT15
                      DEFW      PAT16
                      DEFW      PAT17
                      DEFW      PAT18
                      DEFW      PAT25
                      DEFW      PAT26
                      DEFW      PAT27
                      DEFW      PAT28
                      DEFW      PAT15
                      DEFW      PAT16
                      DEFW      PAT17
                      DEFW      PAT18
                      DEFW      PAT19
                      DEFW      PAT20
                      DEFW      PAT19
                      DEFW      PAT20
                      DEFW      PAT21
                      DEFW      PAT22
                      DEFW      PAT10
                      DEFW      $0000
                      DEFW      LOOPSTART

; *** Patterns ***
PAT0:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$01    ,$81,$A4,$83,$49
                DEFB      $01    ,$01    ,$83,$E8
                DEFB      $01    ,$80,$D2,$84,$E7
                DEFB      $01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$83,$E8
                DEFB      $01    ,$01    ,$84,$E7
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$00    ,$81,$A4,$83,$49
                DEFB      $01    ,$01    ,$83,$E8
                DEFB      $01    ,$80,$D2,$84,$E7
                DEFB      $01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$83,$E8
                DEFB      $01    ,$01    ,$84,$E7
                DEFB  $02,$01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$83,$49
                DEFB      $8D,$25,$01    ,$83,$B0
                DEFB      $8F,$A1,$80,$FA,$84,$E7
                DEFB      $89,$D9,$01    ,$83,$49
                DEFB      $8D,$25,$01    ,$83,$B0
                DEFB      $8F,$A1,$01    ,$84,$E7
                DEFB  $07,$00    ,$81,$A4,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT1:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $01    ,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$01    ,$83,$49
                DEFB      $8D,$25,$01    ,$83,$B0
                DEFB      $8F,$A1,$01    ,$84,$E7
                DEFB      $89,$D9,$01    ,$83,$49
                DEFB      $8D,$25,$01    ,$83,$B0
                DEFB      $8F,$A1,$01    ,$84,$E7
                DEFB  $07,$00    ,$81,$F4,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$83,$E8
                DEFB      $01    ,$01    ,$84,$E7
                DEFB      $01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$83,$E8
                DEFB      $01    ,$01    ,$84,$E7
                DEFB      $01    ,$82,$31,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$18,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$89,$D9,$81,$F4,$83,$49
                DEFB      $8D,$25,$01    ,$83,$B0
                DEFB      $8F,$A1,$80,$FA,$84,$E7
                DEFB      $89,$D9,$01    ,$83,$49
                DEFB      $8D,$25,$01    ,$83,$B0
                DEFB      $8F,$A1,$01    ,$84,$E7
                DEFB      $00    ,$81,$A4,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT2:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$01    ,$81,$76,$82,$ED
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$80,$BB,$84,$63
                DEFB      $01    ,$01    ,$82,$ED
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$81,$D8,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$00    ,$81,$76,$82,$ED
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$80,$BB,$84,$63
                DEFB      $01    ,$01    ,$82,$ED
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB  $02,$01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$81,$D8,$83,$49
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$80,$EC,$84,$E7
                DEFB      $88,$C6,$01    ,$83,$49
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$01    ,$84,$E7
                DEFB  $07,$00    ,$81,$76,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT3:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $01    ,$81,$4D,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$A6,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$83,$49
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$01    ,$84,$E7
                DEFB      $88,$C6,$01    ,$83,$49
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$01    ,$84,$E7
                DEFB  $07,$00    ,$81,$D8,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$EC,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$82,$ED
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$82,$ED
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$81,$F4,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$88,$C6,$81,$D8,$83,$49
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$80,$EC,$84,$E7
                DEFB      $88,$C6,$01    ,$83,$49
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$01    ,$84,$E7
                DEFB      $00    ,$81,$76,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT4:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$01    ,$81,$76,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$80,$BB,$85,$DB
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$85,$DB
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$81,$D8,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$00    ,$81,$76,$83,$49
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$80,$BB,$84,$E7
                DEFB      $01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$84,$E7
                DEFB  $02,$01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$81,$D8,$82,$ED
                DEFB      $8B,$B6,$01    ,$83,$B0
                DEFB      $8E,$C1,$80,$EC,$84,$63
                DEFB      $88,$C6,$01    ,$82,$ED
                DEFB      $8B,$B6,$01    ,$83,$B0
                DEFB      $8E,$C1,$01    ,$84,$63
                DEFB  $07,$00    ,$81,$76,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT5:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$F4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$F4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$F4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$82,$31,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$18,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$F4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT6:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $00    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $00    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$A4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$D2,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$82,$31,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$18,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $00    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT7:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $00    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $00    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$89,$D9,$81,$76,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$BB,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $89,$D9,$81,$A4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$D2,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$82,$31,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$18,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $02,$00    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT8:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $01    ,$81,$4D,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$A6,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$83,$B0
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$01    ,$85,$DB
                DEFB      $88,$C6,$01    ,$83,$B0
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$01    ,$85,$DB
                DEFB  $07,$00    ,$81,$D8,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$EC,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$84,$E7
                DEFB      $01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$84,$E7
                DEFB      $01    ,$81,$F4,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$88,$C6,$81,$D8,$82,$ED
                DEFB      $8B,$B6,$01    ,$83,$B0
                DEFB      $8E,$C1,$80,$EC,$84,$63
                DEFB      $88,$C6,$01    ,$82,$ED
                DEFB      $8B,$B6,$01    ,$83,$B0
                DEFB      $8E,$C1,$01    ,$84,$63
                DEFB      $00    ,$81,$76,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT9:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$01    ,$81,$76,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$80,$BB,$85,$DB
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$85,$DB
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$85,$DB
                DEFB      $01    ,$01    ,$83,$B0
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $88,$C6,$81,$D8,$85,$DB
                DEFB      $8B,$B6,$01    ,$00
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$00    ,$81,$76,$83,$49
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$80,$BB,$84,$E7
                DEFB      $01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$84,$E7
                DEFB  $02,$01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$81,$D8,$83,$B0
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$80,$EC,$85,$DB
                DEFB      $88,$C6,$01    ,$83,$B0
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$01    ,$85,$DB
                DEFB  $07,$00    ,$81,$76,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT10:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$84,$E7,$8D,$25,$81,$A4
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$D2
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB  $07,$01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB  $07,$01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB  $07,$01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB  $07,$00    ,$8D,$25,$81,$A4
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$D2
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$00    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$82,$31,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$18,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$81,$F4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT11:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$00    ,$81,$A4,$E3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $E3,$49,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$F3,$49,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB  $02,$01    ,$01    ,$E3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $E3,$49,$01    ,$D3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$C3,$E8
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$C3,$E8,$81,$A4,$B4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT12:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $B4,$63,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB  $07,$01    ,$81,$A4,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$A4,$63,$81,$F4,$A3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$A3,$E8,$01    ,$A3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $A3,$B0,$82,$31,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$18,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$89,$D9,$81,$F4,$A3,$49
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $A3,$49,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT13:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$01    ,$81,$A4,$B2,$ED
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $B2,$ED,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$B2,$ED,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$C3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $C3,$B0,$01    ,$D3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$E2,$ED
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$E2,$ED,$81,$A4,$E3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT14:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $E3,$49,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$8D,$25,$81,$A4,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8D,$25,$80,$D2,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$8E,$C1,$81,$F4,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$80,$FA,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB  $02,$8D,$25,$01    ,$01
                DEFB      $86,$92,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $86,$92,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $86,$92,$01    ,$01
                DEFB      $00    ,$82,$31,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$18,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $8F,$A1,$81,$A4,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $8F,$A1,$80,$D2,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT15:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$00    ,$81,$76,$A2,$ED
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $A2,$ED,$01    ,$A3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$81,$D8,$A3,$B0
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$A3,$B0,$81,$76,$A3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$A3,$E8,$01    ,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $A4,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$81,$D8,$A4,$E7
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$A4,$E7,$81,$76,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT16:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $01    ,$81,$4D,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$A6,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$81,$76,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$A3,$E8
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$A3,$E8,$81,$D8,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$EC,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$A3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $A3,$B0,$81,$F4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$88,$C6,$81,$D8,$A3,$49
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB      $A3,$49,$81,$76,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT17:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$A4,$63,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$81,$D8,$A3,$E8
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$A3,$E8,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$A3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $A3,$B0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$81,$D8,$A3,$49
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$A3,$49,$81,$76,$A2,$ED
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT18:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8F,$A1,$81,$4D,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $8F,$A1,$80,$A6,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB  $07,$8E,$C1,$81,$76,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$80,$BB,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$8E,$C1,$81,$D8,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB  $02,$8F,$A1,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB  $02,$8E,$C1,$81,$F4,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$80,$FA,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB  $07,$88,$C6,$81,$D8,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$80,$EC,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB  $07,$89,$D9,$81,$76,$01
                DEFB      $84,$E7,$01    ,$01
                DEFB      $89,$D9,$80,$BB,$01
                DEFB      $84,$E7,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $84,$E7,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT19:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$82,$76,$FE,$C1,$81,$3B
                DEFB      $01    ,$F7,$60,$01
                DEFB      $01    ,$FE,$C1,$80,$9D
                DEFB      $01    ,$F7,$60,$01
                DEFB      $01    ,$FE,$C1,$01
                DEFB      $01    ,$F7,$60,$01
                DEFB      $01    ,$EB,$B6,$01
                DEFB      $01    ,$E5,$DB,$01
                DEFB      $01    ,$EB,$B6,$01
                DEFB      $01    ,$E5,$DB,$01
                DEFB      $01    ,$EB,$B6,$01
                DEFB      $01    ,$E5,$DB,$01
                DEFB      $01    ,$D9,$D9,$80,$EC
                DEFB      $01    ,$D4,$E7,$01
                DEFB      $01    ,$D9,$D9,$80,$76
                DEFB      $01    ,$D4,$E7,$01
                DEFB      $01    ,$D9,$D9,$01
                DEFB      $01    ,$D4,$E7,$01
                DEFB  $07,$01    ,$C8,$C6,$81,$3B
                DEFB      $01    ,$C4,$63,$01
                DEFB      $01    ,$C8,$C6,$80,$9D
                DEFB      $01    ,$C4,$63,$01
                DEFB      $01    ,$C8,$C6,$01
                DEFB      $01    ,$C4,$63,$01
                DEFB  $02,$01    ,$B7,$60,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB      $01    ,$B7,$60,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB      $01    ,$B7,$60,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB  $02,$01    ,$A5,$DB,$01
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$A5,$DB,$01
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$A5,$DB,$01
                DEFB      $01    ,$A2,$ED,$01
                DEFB  $02,$01    ,$94,$E7,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$94,$E7,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$94,$E7,$01
                DEFB      $01    ,$92,$76,$01
                DEFB  $02,$01    ,$84,$63,$01
                DEFB      $01    ,$82,$31,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $01    ,$82,$31,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $01    ,$82,$31,$01
                DEFB  $07,$82,$31,$FD,$25,$81,$18
                DEFB      $01    ,$F6,$92,$01
                DEFB      $01    ,$FD,$25,$80,$8C
                DEFB      $01    ,$F6,$92,$01
                DEFB      $01    ,$FD,$25,$01
                DEFB      $01    ,$F6,$92,$01
                DEFB      $01    ,$EA,$6E,$01
                DEFB      $01    ,$E5,$37,$01
                DEFB      $01    ,$EA,$6E,$01
                DEFB      $01    ,$E5,$37,$01
                DEFB      $01    ,$EA,$6E,$01
                DEFB      $01    ,$E5,$37,$01
                DEFB      $01    ,$D8,$C6,$80,$D2
                DEFB      $01    ,$D4,$63,$01
                DEFB      $01    ,$D8,$C6,$80,$69
                DEFB      $01    ,$D4,$63,$01
                DEFB      $01    ,$D8,$C6,$01
                DEFB      $01    ,$D4,$63,$01
                DEFB  $07,$01    ,$C7,$D0,$81,$18
                DEFB      $01    ,$C3,$E8,$01
                DEFB      $01    ,$C7,$D0,$80,$8C
                DEFB      $01    ,$C3,$E8,$01
                DEFB      $01    ,$C7,$D0,$01
                DEFB      $01    ,$C3,$E8,$01
                DEFB  $02,$01    ,$B6,$92,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B6,$92,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B6,$92,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $02,$01    ,$A5,$37,$01
                DEFB      $01    ,$A2,$9B,$01
                DEFB      $01    ,$A5,$37,$01
                DEFB      $01    ,$A2,$9B,$01
                DEFB      $01    ,$A5,$37,$01
                DEFB      $01    ,$A2,$9B,$01
                DEFB  $02,$01    ,$94,$63,$01
                DEFB      $01    ,$92,$31,$01
                DEFB      $01    ,$94,$63,$01
                DEFB      $01    ,$92,$31,$01
                DEFB      $01    ,$94,$63,$01
                DEFB      $01    ,$92,$31,$01
                DEFB  $02,$01    ,$83,$E8,$01
                DEFB      $01    ,$81,$F4,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB      $01    ,$81,$F4,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB      $01    ,$81,$F4,$01
                DEFB  $FF  ; End of Pattern

PAT20:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$81,$F4,$FB,$B6,$80,$FA
                DEFB      $01    ,$F5,$DB,$01
                DEFB      $01    ,$FB,$B6,$80,$7D
                DEFB      $01    ,$F5,$DB,$01
                DEFB      $01    ,$FB,$B6,$01
                DEFB      $01    ,$F5,$DB,$01
                DEFB      $01    ,$E9,$D9,$01
                DEFB      $01    ,$E4,$E7,$01
                DEFB      $01    ,$E9,$D9,$01
                DEFB      $01    ,$E4,$E7,$01
                DEFB      $01    ,$E9,$D9,$01
                DEFB      $01    ,$E4,$E7,$01
                DEFB      $01    ,$D7,$D0,$80,$BB
                DEFB      $01    ,$D3,$E8,$01
                DEFB      $01    ,$D7,$D0,$80,$5D
                DEFB      $01    ,$D3,$E8,$01
                DEFB      $01    ,$D7,$D0,$01
                DEFB      $01    ,$D3,$E8,$01
                DEFB      $01    ,$C7,$60,$80,$FA
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$C7,$60,$80,$7D
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$C7,$60,$01
                DEFB      $01    ,$C3,$B0,$01
                DEFB  $07,$01    ,$B5,$DB,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B5,$DB,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B5,$DB,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$A4,$E7,$01
                DEFB      $01    ,$A2,$76,$01
                DEFB      $01    ,$A4,$E7,$01
                DEFB      $01    ,$A2,$76,$01
                DEFB      $01    ,$A4,$E7,$01
                DEFB      $01    ,$A2,$76,$01
                DEFB      $01    ,$93,$E8,$01
                DEFB      $01    ,$91,$F4,$01
                DEFB      $01    ,$93,$E8,$01
                DEFB      $01    ,$91,$F4,$01
                DEFB      $01    ,$93,$E8,$01
                DEFB      $01    ,$91,$F4,$01
                DEFB      $01    ,$83,$B0,$01
                DEFB      $01    ,$81,$D8,$01
                DEFB      $01    ,$83,$B0,$01
                DEFB      $01    ,$81,$D8,$01
                DEFB      $01    ,$83,$B0,$01
                DEFB      $01    ,$81,$D8,$01
                DEFB  $07,$81,$D8,$83,$B0,$80,$EC
                DEFB      $01    ,$81,$D8,$01
                DEFB      $01    ,$83,$B0,$80,$76
                DEFB      $01    ,$81,$D8,$01
                DEFB      $01    ,$83,$B0,$01
                DEFB      $01    ,$81,$D8,$01
                DEFB      $01    ,$94,$63,$01
                DEFB      $01    ,$92,$31,$01
                DEFB      $01    ,$94,$63,$01
                DEFB      $01    ,$92,$31,$01
                DEFB      $01    ,$94,$63,$01
                DEFB      $01    ,$92,$31,$01
                DEFB      $01    ,$A5,$37,$80,$EC
                DEFB      $01    ,$A2,$9B,$01
                DEFB      $01    ,$A5,$37,$80,$76
                DEFB      $01    ,$A2,$9B,$01
                DEFB      $01    ,$A5,$37,$01
                DEFB      $01    ,$A2,$9B,$01
                DEFB      $01    ,$B6,$92,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B6,$92,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B6,$92,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $07,$81,$F4,$C7,$D0,$80,$FA
                DEFB      $01    ,$C3,$E8,$01
                DEFB      $01    ,$C7,$D0,$80,$7D
                DEFB      $01    ,$C3,$E8,$01
                DEFB      $01    ,$C7,$D0,$01
                DEFB      $01    ,$C3,$E8,$01
                DEFB      $01    ,$D9,$D9,$01
                DEFB      $01    ,$D4,$E7,$01
                DEFB      $01    ,$D9,$D9,$01
                DEFB      $01    ,$D4,$E7,$01
                DEFB      $01    ,$D9,$D9,$01
                DEFB      $01    ,$D4,$E7,$01
                DEFB      $82,$31,$ED,$25,$81,$18
                DEFB      $01    ,$E6,$92,$01
                DEFB      $01    ,$ED,$25,$80,$8C
                DEFB      $01    ,$E6,$92,$01
                DEFB      $01    ,$ED,$25,$01
                DEFB      $01    ,$E6,$92,$01
                DEFB      $01    ,$FF,$A1,$01
                DEFB      $01    ,$F7,$D0,$01
                DEFB      $01    ,$FF,$A1,$01
                DEFB      $01    ,$F7,$D0,$01
                DEFB      $01    ,$FF,$A1,$01
                DEFB      $01    ,$F7,$D0,$01
                DEFB  $FF  ; End of Pattern

PAT21:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$A3,$49,$8D,$25,$81,$18
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$8C
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$8A,$6E,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $01    ,$8A,$6E,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$88,$C6,$81,$18
                DEFB      $01    ,$84,$63,$01
                DEFB      $01    ,$88,$C6,$80,$8C
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$8D,$25,$81,$18
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$8C
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$8A,$6E,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $01    ,$8A,$6E,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$88,$C6,$81,$18
                DEFB      $01    ,$84,$63,$01
                DEFB      $01    ,$88,$C6,$80,$8C
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$8D,$25,$81,$18
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$8C
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$8A,$6E,$81,$18
                DEFB      $01    ,$85,$37,$01
                DEFB      $01    ,$8A,$6E,$80,$8C
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT22:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$A3,$E8,$8D,$25,$81,$4D
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$A6
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$8A,$6E,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $01    ,$8A,$6E,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$87,$D0,$81,$4D
                DEFB      $01    ,$83,$E8,$01
                DEFB      $01    ,$87,$D0,$80,$A6
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$8D,$25,$81,$4D
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$A6
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$8A,$6E,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $01    ,$8A,$6E,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$87,$D0,$81,$4D
                DEFB      $01    ,$83,$E8,$01
                DEFB      $01    ,$87,$D0,$80,$A6
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$8D,$25,$81,$4D
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$A6
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$8A,$6E,$81,$4D
                DEFB      $01    ,$85,$37,$01
                DEFB      $01    ,$8A,$6E,$80,$A6
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT23:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$84,$E7,$8D,$25,$81,$A4
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$D2
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB  $07,$01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB  $07,$01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB  $07,$01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB  $07,$00    ,$8D,$25,$81,$A4
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$80,$D2
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$8D,$25,$01
                DEFB      $01    ,$86,$92,$01
                DEFB      $01    ,$00    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT24:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $01    ,$81,$4D,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$A6,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$83,$B0
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$01    ,$85,$DB
                DEFB      $88,$C6,$01    ,$83,$B0
                DEFB      $8B,$B6,$01    ,$84,$63
                DEFB      $8E,$C1,$01    ,$85,$DB
                DEFB  $07,$00    ,$81,$D8,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$EC,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$89,$D9,$01    ,$83,$49
                DEFB      $84,$E7,$01    ,$84,$63
                DEFB      $89,$D9,$01    ,$84,$E7
                DEFB      $00    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$84,$63
                DEFB      $01    ,$01    ,$84,$E7
                DEFB      $8B,$B6,$81,$F4,$00
                DEFB      $85,$DB,$01    ,$01
                DEFB      $8B,$B6,$80,$FA,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$88,$C6,$81,$D8,$82,$ED
                DEFB      $8B,$B6,$01    ,$83,$B0
                DEFB      $8E,$C1,$80,$EC,$84,$63
                DEFB      $88,$C6,$01    ,$82,$ED
                DEFB      $8B,$B6,$01    ,$83,$B0
                DEFB      $8E,$C1,$01    ,$84,$63
                DEFB      $8D,$25,$81,$76,$00
                DEFB      $86,$92,$01    ,$01
                DEFB      $8D,$25,$80,$BB,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT25:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$00    ,$81,$A4,$E3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $E3,$49,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$F3,$49,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB  $02,$01    ,$01    ,$E3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $E3,$49,$01    ,$D3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$D3,$E8,$81,$A4,$C4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT26:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $C4,$63,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$01    ,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$C4,$63,$81,$F4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$FA,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$82,$31,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$18,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$89,$D9,$81,$F4,$B4,$E7
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $B4,$E7,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT27:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $07,$01    ,$81,$A4,$A3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $A3,$E8,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$A3,$E8,$81,$A4,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$01    ,$01    ,$A3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $A3,$B0,$01    ,$B3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $89,$D9,$81,$F4,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$B3,$49,$81,$A4,$C3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$D2,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT28:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $C3,$B0,$81,$76,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$80,$BB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$8D,$25,$81,$A4,$D3,$B0
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8D,$25,$80,$D2,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $89,$D9,$01    ,$C3,$49
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB  $07,$8E,$C1,$81,$F4,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$80,$FA,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $8E,$C1,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB  $02,$8D,$25,$01    ,$B3,$B0
                DEFB      $86,$92,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $86,$92,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $86,$92,$01    ,$01
                DEFB      $B3,$B0,$82,$31,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$81,$18,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $07,$89,$D9,$81,$F4,$A3,$49
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$80,$FA,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $8D,$25,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $8F,$A1,$81,$A4,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $8F,$A1,$80,$D2,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $8F,$A1,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB  $FF  ; End of Pattern

