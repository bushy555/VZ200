
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
LOOPSTART:            DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT2
                      DEFW      PAT2
                      DEFW      PAT2
                      DEFW      PAT3
                      DEFW      PAT4
                      DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT5
                      DEFW      PAT6
                      DEFW      PAT7
                      DEFW      PAT8
                      DEFW      PAT9
                      DEFW      PAT10
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
                      DEFW      PAT21
                      DEFW      PAT22
                      DEFW      PAT23
                      DEFW      PAT24
                      DEFW      PAT25
                      DEFW      PAT26
                      DEFW      PAT27
                      DEFW      PAT28
                      DEFW      PAT29
                      DEFW      PAT30
                      DEFW      PAT31
                      DEFW      PAT32
                      DEFW      PAT29
                      DEFW      PAT30
                      DEFW      PAT31
                      DEFW      PAT32
                      DEFW      PAT33
                      DEFW      PAT28
                      DEFW      PAT33
                      DEFW      PAT28
                      DEFW      PAT33
                      DEFW      PAT28
                      DEFW      PAT34
                      DEFW      PAT35
                      DEFW      $0000
                      DEFW      LOOPSTART

; *** Patterns ***
PAT0:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$EC,$90,$EB,$A0,$ED
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$00    ,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$00    ,$90,$EB,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$EC,$00    ,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$FA,$90,$F9,$A1,$F4
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$EC,$90,$EB,$A1,$D8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$00    ,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT1:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$FA,$90,$F9,$A0,$FB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$00    ,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$00    ,$90,$EB,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$D2,$90,$D1,$A0,$D3
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$D2,$90,$D1,$A1,$A4
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$EC,$90,$EB,$A1,$D8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT2:
                ;;DEFW  1236     ; Pattern tempo
                DEFW 970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$EC,$F5,$86,$A0,$EB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$E4,$63,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$D3,$B0,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$C3,$49,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$81,$D8,$B3,$B0,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A4,$63,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$EC,$94,$E7,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$85,$86,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$FA,$93,$E8,$A1,$F4
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A4,$63,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B4,$E7,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$C5,$86,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$EC,$D6,$92,$A1,$D8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$E5,$86,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$F4,$63,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$E3,$E8,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT3:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$FA,$F3,$E8,$A0,$F9
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$E5,$86,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$D4,$E7,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$C5,$86,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$00    ,$B3,$B0,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$E8,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$D2,$93,$49,$A0,$D2
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$85,$86,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$D2,$83,$49,$A1,$A4
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$93,$B0,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A5,$DB,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B5,$86,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$EC,$C3,$B0,$A1,$D8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$D3,$E8,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$E4,$63,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$F5,$86,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT4:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$EC,$95,$DB,$A0,$EB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$95,$86,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$94,$63,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$93,$B0,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$00    ,$90,$EB,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$EC,$00    ,$A0,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$FA,$97,$D0,$A1,$F4
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$97,$60,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$94,$63,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$93,$B0,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$EC,$97,$60,$A1,$D8
                DEFB      $01    ,$01    ,$01
                DEFB      $00    ,$93,$B0,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $08,$80,$EC,$00    ,$A0,$EB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT5:
                ;;DEFW  1236     ; Pattern tempo
                DEFW 970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$3B,$A2,$ED,$84,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$49,$95,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$76,$A3,$B0,$A5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A2,$ED,$B4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$81,$3B,$A3,$49,$C5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$D5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$C3,$A2,$ED,$E4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$49,$F5,$86
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$82,$ED,$A3,$B0,$F5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A2,$ED,$E4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$3B,$A3,$49,$D5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$C5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$82,$C3,$A2,$ED,$B4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$49,$A5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$76,$A3,$B0,$95,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A2,$ED,$84,$E7
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT6:
                ;;DEFW  1236     ; Pattern tempo
                DEFW 970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$18,$B3,$49,$85,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$B0,$95,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$31,$B3,$E8,$A6,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$B5,$86
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$81,$18,$B3,$B0,$C5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$D6,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$76,$B3,$49,$E5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$B0,$F5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$82,$C3,$B3,$E8,$F6,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$E5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$18,$B3,$B0,$D5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$C6,$92
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$82,$76,$B3,$49,$B5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$B0,$A5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$18,$B3,$E8,$96,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$85,$DB
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT7:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$D2,$B2,$76,$83,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$C3,$94,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$A4,$B2,$ED,$A4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$76,$B3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$D2,$B2,$C3,$C4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$D4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$D8,$B2,$76,$E3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$C3,$F4,$63
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$81,$F4,$B2,$ED,$F4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$76,$E3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$D2,$B2,$C3,$D4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$C4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$81,$D8,$B2,$76,$B3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$C3,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$D2,$B2,$ED,$94,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$76,$83,$E8
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT8:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$FA,$B2,$ED,$84,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$95,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$F4,$B3,$B0,$A5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$B4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$FA,$B3,$49,$C5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$B0,$D5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$31,$B2,$ED,$E4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$F5,$86
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$82,$76,$B3,$B0,$F5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$E4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$FA,$B3,$49,$D5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$B0,$C5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$82,$31,$B2,$ED,$B4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$A5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$FA,$B3,$B0,$95,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$84,$E7
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT9:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$3B,$A2,$ED,$87,$60
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$49,$97,$60
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$76,$A3,$B0,$A5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A2,$ED,$B5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$81,$3B,$A3,$49,$C4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$D4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$C3,$A2,$ED,$E4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$49,$F4,$63
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$82,$ED,$A3,$B0,$F4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A2,$ED,$E4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$3B,$A3,$49,$D5,$0F
                DEFB      $01    ,$01    ,$D4,$E7
                DEFB      $01    ,$A3,$B0,$C4,$BF
                DEFB      $01    ,$01    ,$C4,$E7
                DEFB  $06,$82,$C3,$A2,$ED,$B4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$49,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$76,$A3,$B0,$93,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A2,$ED,$83,$B0
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT10:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$18,$B3,$49,$83,$5D
                DEFB      $01    ,$01    ,$83,$49
                DEFB      $01    ,$B3,$B0,$93,$35
                DEFB      $01    ,$01    ,$93,$49
                DEFB      $82,$31,$B3,$E8,$A3,$5D
                DEFB      $01    ,$01    ,$A3,$49
                DEFB      $01    ,$B3,$49,$B3,$35
                DEFB      $01    ,$01    ,$B3,$49
                DEFB  $06,$81,$18,$B3,$B0,$C3,$01
                DEFB      $01    ,$01    ,$C2,$ED
                DEFB      $01    ,$B3,$E8,$D2,$D9
                DEFB      $01    ,$01    ,$D2,$ED
                DEFB      $82,$76,$B3,$49,$E3,$01
                DEFB      $01    ,$01    ,$E2,$ED
                DEFB      $01    ,$B3,$B0,$F2,$D9
                DEFB      $01    ,$01    ,$F2,$ED
                DEFB  $05,$82,$C3,$B3,$E8,$F2,$D7
                DEFB      $01    ,$01    ,$F2,$C3
                DEFB      $01    ,$B3,$49,$E2,$AF
                DEFB      $01    ,$01    ,$E2,$C3
                DEFB      $81,$18,$B3,$B0,$D2,$D7
                DEFB      $01    ,$01    ,$D2,$C3
                DEFB      $01    ,$B3,$E8,$C2,$AF
                DEFB      $01    ,$01    ,$C2,$C3
                DEFB  $06,$82,$76,$B3,$49,$B2,$45
                DEFB      $01    ,$01    ,$B2,$31
                DEFB      $01    ,$B3,$B0,$A2,$1D
                DEFB      $01    ,$01    ,$A2,$31
                DEFB      $81,$18,$B3,$E8,$92,$45
                DEFB      $01    ,$01    ,$92,$31
                DEFB      $01    ,$B3,$49,$82,$1D
                DEFB      $01    ,$01    ,$82,$31
                DEFB  $FF  ; End of Pattern

PAT11:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$D2,$B2,$76,$82,$76
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$C3,$92,$76
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$A4,$B2,$ED,$A2,$76
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$76,$B2,$76
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$D2,$B2,$C3,$C2,$C3
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$D2,$C3
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$D8,$B2,$76,$E2,$C3
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$C3,$F2,$C3
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$81,$F4,$B2,$ED,$F2,$ED
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$76,$E2,$ED
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$D2,$B2,$C3,$D2,$ED
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$C2,$ED
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$81,$D8,$B2,$76,$B3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$C3,$A3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$D2,$B2,$ED,$93,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$76,$83,$E8
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT12:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$FA,$B2,$ED,$83,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$93,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$F4,$B3,$B0,$A3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$B3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$FA,$B3,$49,$C3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$B0,$D3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$31,$B2,$ED,$E3,$49
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$F3,$49
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$82,$76,$B3,$B0,$F3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$E3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$FA,$B3,$49,$D3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$B0,$C3,$B0
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$82,$31,$B2,$ED,$B4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$FA,$B3,$B0,$94,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B2,$ED,$84,$63
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT13:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$3B,$A2,$ED,$84,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$49,$94,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$76,$A3,$B0,$A4,$FB
                DEFB      $01    ,$01    ,$A4,$E7
                DEFB      $01    ,$A3,$49,$B4,$D3
                DEFB      $01    ,$01    ,$B4,$E7
                DEFB  $06,$81,$3B,$A2,$ED,$C4,$FB
                DEFB      $01    ,$01    ,$C4,$E7
                DEFB      $01    ,$A3,$49,$D4,$D3
                DEFB      $01    ,$01    ,$D4,$E7
                DEFB      $82,$C3,$A3,$B0,$E4,$FB
                DEFB      $01    ,$01    ,$E4,$E7
                DEFB      $01    ,$A3,$49,$F4,$D3
                DEFB      $01    ,$01    ,$F4,$E7
                DEFB  $05,$82,$ED,$A2,$ED,$F4,$FB
                DEFB      $01    ,$01    ,$F4,$E7
                DEFB      $01    ,$A3,$49,$E4,$D3
                DEFB      $01    ,$01    ,$E4,$E7
                DEFB      $81,$3B,$A3,$B0,$D4,$FB
                DEFB      $01    ,$01    ,$D4,$E7
                DEFB      $01    ,$A3,$49,$C4,$D3
                DEFB      $01    ,$01    ,$C4,$E7
                DEFB  $06,$82,$C3,$A2,$ED,$B4,$FB
                DEFB      $01    ,$01    ,$B4,$E7
                DEFB      $01    ,$A3,$49,$A4,$D3
                DEFB      $01    ,$01    ,$A4,$E7
                DEFB      $82,$76,$A3,$B0,$94,$FB
                DEFB      $01    ,$01    ,$94,$E7
                DEFB      $01    ,$A3,$49,$84,$D3
                DEFB      $01    ,$01    ,$84,$E7
                DEFB  $FF  ; End of Pattern

PAT14:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$18,$B3,$49,$85,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$B0,$95,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$31,$B3,$E8,$A5,$9A
                DEFB      $01    ,$01    ,$A5,$86
                DEFB      $01    ,$B3,$B0,$B5,$72
                DEFB      $01    ,$01    ,$B5,$86
                DEFB  $06,$81,$18,$B3,$49,$C5,$9A
                DEFB      $01    ,$01    ,$C5,$86
                DEFB      $01    ,$B3,$B0,$D5,$72
                DEFB      $01    ,$01    ,$D5,$86
                DEFB      $82,$76,$B3,$E8,$E5,$9A
                DEFB      $01    ,$01    ,$E5,$86
                DEFB      $01    ,$B3,$B0,$F5,$72
                DEFB      $01    ,$01    ,$F5,$86
                DEFB  $05,$82,$C3,$B3,$49,$F5,$9A
                DEFB      $01    ,$01    ,$F5,$86
                DEFB      $01    ,$B3,$B0,$E5,$72
                DEFB      $01    ,$01    ,$E5,$86
                DEFB      $81,$18,$B3,$E8,$D5,$9A
                DEFB      $01    ,$01    ,$D5,$86
                DEFB      $01    ,$B3,$B0,$C5,$72
                DEFB      $01    ,$01    ,$C5,$86
                DEFB  $06,$82,$76,$B3,$49,$B5,$9A
                DEFB      $01    ,$01    ,$B5,$86
                DEFB      $01    ,$B3,$B0,$A5,$72
                DEFB      $01    ,$01    ,$A5,$86
                DEFB      $81,$18,$B3,$E8,$95,$9A
                DEFB      $01    ,$01    ,$95,$86
                DEFB      $01    ,$B3,$B0,$85,$72
                DEFB      $01    ,$01    ,$85,$86
                DEFB  $FF  ; End of Pattern

PAT15:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$D2,$B3,$49,$85,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$B0,$95,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$A4,$B3,$E8,$A5,$EF
                DEFB      $01    ,$01    ,$A5,$DB
                DEFB      $01    ,$B3,$B0,$B5,$C7
                DEFB      $01    ,$01    ,$B5,$DB
                DEFB  $06,$80,$D2,$B3,$49,$C5,$EF
                DEFB      $01    ,$01    ,$C5,$DB
                DEFB      $01    ,$B3,$B0,$D5,$C7
                DEFB      $01    ,$01    ,$D5,$DB
                DEFB      $81,$D8,$B3,$E8,$E5,$EF
                DEFB      $01    ,$01    ,$E5,$DB
                DEFB      $01    ,$B3,$B0,$F5,$C7
                DEFB      $01    ,$01    ,$F5,$DB
                DEFB  $05,$81,$F4,$B3,$49,$F5,$EF
                DEFB      $01    ,$01    ,$F5,$DB
                DEFB      $01    ,$B3,$B0,$E5,$C7
                DEFB      $01    ,$01    ,$E5,$DB
                DEFB      $80,$D2,$B3,$E8,$D5,$EF
                DEFB      $01    ,$01    ,$D5,$DB
                DEFB      $01    ,$B3,$B0,$C5,$C7
                DEFB      $01    ,$01    ,$C5,$DB
                DEFB  $06,$81,$D8,$B3,$49,$B5,$EF
                DEFB      $01    ,$01    ,$B5,$DB
                DEFB      $01    ,$B3,$B0,$A5,$C7
                DEFB      $01    ,$01    ,$A5,$DB
                DEFB      $80,$D2,$B3,$E8,$95,$EF
                DEFB      $01    ,$01    ,$95,$DB
                DEFB      $01    ,$B3,$B0,$85,$C7
                DEFB      $01    ,$01    ,$85,$DB
                DEFB  $FF  ; End of Pattern

PAT16:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$FA,$B2,$ED,$87,$D0
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$49,$97,$D0
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$F4,$B3,$B0,$A7,$E9
                DEFB      $01    ,$01    ,$A7,$D0
                DEFB      $01    ,$B3,$49,$B7,$B7
                DEFB      $01    ,$01    ,$B7,$D0
                DEFB  $06,$80,$FA,$B2,$ED,$C7,$79
                DEFB      $01    ,$01    ,$C7,$60
                DEFB      $01    ,$B3,$49,$D7,$47
                DEFB      $01    ,$01    ,$D7,$60
                DEFB      $82,$31,$B3,$B0,$E7,$79
                DEFB      $01    ,$01    ,$E7,$60
                DEFB      $01    ,$B3,$49,$F7,$47
                DEFB      $01    ,$01    ,$F7,$60
                DEFB  $05,$82,$76,$B2,$ED,$F5,$F4
                DEFB      $01    ,$01    ,$F5,$DB
                DEFB      $01    ,$B3,$49,$E5,$C2
                DEFB      $01    ,$01    ,$E5,$DB
                DEFB      $80,$FA,$B3,$B0,$D5,$F4
                DEFB      $01    ,$01    ,$D5,$DB
                DEFB      $01    ,$B3,$49,$C5,$C2
                DEFB      $01    ,$01    ,$C5,$DB
                DEFB  $06,$82,$31,$B2,$ED,$B5,$00
                DEFB      $01    ,$01    ,$B4,$E7
                DEFB      $01    ,$B3,$49,$A4,$CE
                DEFB      $01    ,$01    ,$A4,$E7
                DEFB      $80,$FA,$B3,$B0,$95,$00
                DEFB      $01    ,$01    ,$94,$E7
                DEFB      $01    ,$B3,$49,$84,$CE
                DEFB      $01    ,$01    ,$84,$E7
                DEFB  $FF  ; End of Pattern

PAT17:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$3B,$A2,$ED,$87,$60
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$96,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$76,$A4,$E7,$A5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$B5,$86
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$81,$3B,$A2,$ED,$C6,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$D5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$C3,$A4,$E7,$E5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$F4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$82,$ED,$A2,$EC,$F8,$C6
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$E7,$60
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$3B,$A4,$E7,$D6,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$C5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$82,$C3,$A2,$ED,$B9,$D9
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$A8,$C6
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$76,$A4,$E7,$97,$60
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$B0,$86,$92
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT18:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$18,$B3,$49,$85,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B4,$63,$95,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$31,$B5,$86,$A6,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B4,$63,$B5,$86
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$81,$18,$B3,$49,$C5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B4,$63,$D6,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$76,$B5,$86,$E5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B4,$63,$F5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$82,$C3,$B3,$49,$F6,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B4,$63,$E5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$18,$B5,$86,$D5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B4,$63,$C6,$92
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$82,$76,$B3,$49,$B5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B4,$63,$A5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$18,$B5,$86,$96,$92
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B4,$63,$85,$DB
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT19:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$D2,$A3,$49,$83,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$E8,$94,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$A4,$A4,$E7,$A4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$E8,$B3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$D2,$A3,$49,$C4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$E8,$D4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$D8,$A4,$E7,$E3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$E8,$F4,$63
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$81,$F4,$A3,$49,$F4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$E8,$E3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$D2,$A4,$E7,$D4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$E8,$C4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$81,$D8,$A3,$49,$B3,$E8
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$E8,$A4,$63
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$D2,$A4,$E7,$94,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$A3,$E8,$83,$E8
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT20:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$FA,$B2,$ED,$84,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$95,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $81,$F4,$B4,$E7,$A5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$B4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$80,$FA,$B2,$ED,$C5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$D5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $82,$31,$B4,$E7,$E4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$F5,$86
                DEFB      $01    ,$01    ,$01
                DEFB  $05,$82,$76,$B2,$ED,$F5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$E4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$FA,$B4,$E7,$D5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$C5,$DB
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$82,$31,$B2,$ED,$B4,$E7
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$A5,$86
                DEFB      $01    ,$01    ,$01
                DEFB      $80,$FA,$B4,$E7,$95,$DB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$B3,$E8,$84,$E7
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT21:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$3B,$82,$ED,$83,$B0
                DEFB      $01    ,$82,$ED,$83,$B0
                DEFB      $01    ,$93,$01,$83,$C4
                DEFB      $01    ,$92,$ED,$83,$B0
                DEFB      $82,$76,$A2,$D9,$93,$9C
                DEFB      $01    ,$A2,$ED,$93,$B0
                DEFB      $01    ,$B3,$01,$93,$C4
                DEFB      $01    ,$B2,$ED,$93,$B0
                DEFB  $06,$81,$3B,$C2,$D9,$A3,$9C
                DEFB      $01    ,$C2,$ED,$A3,$B0
                DEFB      $01    ,$D3,$01,$A3,$C4
                DEFB      $01    ,$D2,$ED,$A3,$B0
                DEFB      $82,$C3,$E2,$D9,$B3,$9C
                DEFB      $01    ,$E2,$ED,$B3,$B0
                DEFB      $01    ,$F3,$01,$B3,$C4
                DEFB      $01    ,$F2,$ED,$B3,$B0
                DEFB  $05,$82,$ED,$F2,$D9,$C3,$9C
                DEFB      $01    ,$F2,$ED,$C3,$B0
                DEFB      $01    ,$E3,$01,$C3,$C4
                DEFB      $01    ,$E2,$ED,$C3,$B0
                DEFB      $81,$3B,$D2,$D9,$D3,$9C
                DEFB      $01    ,$D2,$ED,$D3,$B0
                DEFB      $01    ,$C3,$01,$D3,$C4
                DEFB      $01    ,$C2,$ED,$D3,$B0
                DEFB  $06,$82,$C3,$B2,$D9,$E3,$9C
                DEFB      $01    ,$B2,$ED,$E3,$B0
                DEFB      $01    ,$A3,$01,$E3,$C4
                DEFB      $01    ,$A2,$ED,$E3,$B0
                DEFB      $82,$76,$92,$D9,$F3,$9C
                DEFB      $01    ,$92,$ED,$F3,$B0
                DEFB      $01    ,$83,$01,$F3,$C4
                DEFB      $01    ,$82,$ED,$F3,$B0
                DEFB  $FF  ; End of Pattern

PAT22:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$18,$83,$49,$F4,$63
                DEFB      $01    ,$83,$49,$F4,$63
                DEFB      $01    ,$93,$5D,$F4,$77
                DEFB      $01    ,$93,$49,$F4,$63
                DEFB      $82,$31,$A3,$35,$E4,$4F
                DEFB      $01    ,$A3,$49,$E4,$63
                DEFB      $01    ,$B3,$5D,$E4,$77
                DEFB      $01    ,$B3,$49,$E4,$63
                DEFB  $06,$81,$18,$C3,$35,$D4,$4F
                DEFB      $01    ,$C3,$49,$D4,$63
                DEFB      $01    ,$D3,$5D,$D4,$77
                DEFB      $01    ,$D3,$49,$D4,$63
                DEFB      $82,$76,$E3,$35,$C4,$4F
                DEFB      $01    ,$E3,$49,$C4,$63
                DEFB      $01    ,$F3,$5D,$C4,$77
                DEFB      $01    ,$F3,$49,$C4,$63
                DEFB  $05,$82,$C3,$F3,$35,$B4,$4F
                DEFB      $01    ,$F3,$49,$B4,$63
                DEFB      $01    ,$E3,$5D,$B4,$77
                DEFB      $01    ,$E3,$49,$B4,$63
                DEFB      $81,$18,$D3,$35,$A4,$4F
                DEFB      $01    ,$D3,$49,$A4,$63
                DEFB      $01    ,$C3,$5D,$A4,$77
                DEFB      $01    ,$C3,$49,$A4,$63
                DEFB  $06,$82,$76,$B3,$35,$94,$4F
                DEFB      $01    ,$B3,$49,$94,$63
                DEFB      $01    ,$A3,$5D,$94,$77
                DEFB      $01    ,$A3,$49,$94,$63
                DEFB      $81,$18,$93,$35,$84,$4F
                DEFB      $01    ,$93,$49,$84,$63
                DEFB      $01    ,$83,$5D,$84,$77
                DEFB      $01    ,$83,$49,$84,$63
                DEFB  $FF  ; End of Pattern

PAT23:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$D2,$83,$E8,$84,$E7
                DEFB      $01    ,$83,$E8,$84,$E7
                DEFB      $01    ,$94,$04,$85,$0B
                DEFB      $01    ,$93,$E8,$84,$E7
                DEFB      $81,$A4,$A3,$CC,$84,$C3
                DEFB      $01    ,$A3,$E8,$84,$E7
                DEFB      $01    ,$B4,$04,$85,$0B
                DEFB      $01    ,$B3,$E8,$84,$E7
                DEFB  $06,$80,$D2,$C3,$CC,$94,$C3
                DEFB      $01    ,$C3,$E8,$94,$E7
                DEFB      $01    ,$D4,$04,$95,$0B
                DEFB      $01    ,$D3,$E8,$94,$E7
                DEFB      $81,$D8,$E3,$CC,$A4,$C3
                DEFB      $01    ,$E3,$E8,$A4,$E7
                DEFB      $01    ,$F4,$04,$A5,$0B
                DEFB      $01    ,$F3,$E8,$A4,$E7
                DEFB  $05,$81,$F4,$F3,$CC,$B4,$C3
                DEFB      $01    ,$F3,$E8,$B4,$E7
                DEFB      $01    ,$E4,$04,$B5,$0B
                DEFB      $01    ,$E3,$E8,$B4,$E7
                DEFB      $80,$D2,$D3,$CC,$C4,$C3
                DEFB      $01    ,$D3,$E8,$C4,$E7
                DEFB      $01    ,$C4,$04,$C5,$0B
                DEFB      $01    ,$C3,$E8,$C4,$E7
                DEFB  $06,$81,$D8,$B3,$CC,$D4,$C3
                DEFB      $01    ,$B3,$E8,$D4,$E7
                DEFB      $01    ,$A4,$04,$D5,$0B
                DEFB      $01    ,$A3,$E8,$D4,$E7
                DEFB      $80,$D2,$93,$CC,$E4,$C3
                DEFB      $01    ,$93,$E8,$E4,$E7
                DEFB      $01    ,$84,$04,$E5,$0B
                DEFB      $01    ,$83,$E8,$E4,$E7
                DEFB  $FF  ; End of Pattern

PAT24:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$FA,$84,$E7,$F5,$DB
                DEFB      $01    ,$84,$E7,$F5,$DB
                DEFB      $01    ,$94,$E7,$F5,$DB
                DEFB      $01    ,$94,$E7,$F5,$DB
                DEFB      $81,$F4,$A5,$08,$E5,$FF
                DEFB      $01    ,$A4,$E7,$E5,$DB
                DEFB      $01    ,$B4,$C6,$E5,$B7
                DEFB      $01    ,$B4,$E7,$E5,$DB
                DEFB  $06,$80,$FA,$C5,$08,$D5,$FF
                DEFB      $01    ,$C4,$E7,$D5,$DB
                DEFB      $01    ,$D4,$C6,$D5,$B7
                DEFB      $01    ,$D4,$E7,$D5,$DB
                DEFB      $82,$31,$E5,$08,$C5,$FF
                DEFB      $01    ,$E4,$E7,$C5,$DB
                DEFB      $01    ,$F4,$C6,$C5,$B7
                DEFB      $01    ,$F4,$E7,$C5,$DB
                DEFB  $05,$82,$76,$F5,$08,$B5,$FF
                DEFB      $01    ,$F4,$E7,$B5,$DB
                DEFB      $01    ,$E4,$C6,$B5,$B7
                DEFB      $01    ,$E4,$E7,$B5,$DB
                DEFB      $80,$FA,$D5,$08,$A5,$FF
                DEFB      $01    ,$D4,$E7,$A5,$DB
                DEFB      $01    ,$C4,$C6,$A5,$B7
                DEFB      $01    ,$C4,$E7,$A5,$DB
                DEFB  $06,$82,$31,$B5,$08,$95,$FF
                DEFB      $01    ,$B4,$E7,$95,$DB
                DEFB      $01    ,$A4,$C6,$95,$B7
                DEFB      $01    ,$A4,$E7,$95,$DB
                DEFB      $80,$FA,$95,$08,$85,$FF
                DEFB      $01    ,$94,$E7,$85,$DB
                DEFB      $01    ,$84,$C6,$85,$B7
                DEFB      $01    ,$84,$E7,$85,$DB
                DEFB  $FF  ; End of Pattern

PAT25:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$3B,$87,$60,$85,$DB
                DEFB      $01    ,$84,$E7,$85,$DB
                DEFB      $01    ,$97,$60,$85,$EF
                DEFB      $01    ,$94,$E7,$85,$DB
                DEFB      $82,$76,$A7,$60,$95,$C7
                DEFB      $01    ,$A4,$E7,$95,$DB
                DEFB      $01    ,$B7,$60,$95,$EF
                DEFB      $01    ,$B4,$E7,$95,$DB
                DEFB  $06,$81,$3B,$C7,$60,$A5,$C7
                DEFB      $01    ,$C4,$E7,$A5,$DB
                DEFB      $01    ,$D7,$60,$A5,$EF
                DEFB      $01    ,$D4,$E7,$A5,$DB
                DEFB      $82,$C3,$E7,$60,$B5,$C7
                DEFB      $01    ,$E4,$E7,$B5,$DB
                DEFB      $01    ,$F7,$60,$B5,$EF
                DEFB      $01    ,$F4,$E7,$B5,$DB
                DEFB  $05,$82,$ED,$F7,$60,$C5,$C7
                DEFB      $01    ,$F4,$E7,$C5,$DB
                DEFB      $01    ,$E7,$60,$C5,$EF
                DEFB      $01    ,$E4,$E7,$C5,$DB
                DEFB      $81,$3B,$D7,$60,$D5,$C7
                DEFB      $01    ,$D4,$E7,$D5,$DB
                DEFB      $01    ,$C7,$60,$D5,$EF
                DEFB      $01    ,$C4,$E7,$D5,$DB
                DEFB  $06,$82,$C3,$B7,$60,$E5,$C7
                DEFB      $01    ,$B4,$E7,$E5,$DB
                DEFB      $01    ,$A7,$60,$E5,$EF
                DEFB      $01    ,$A4,$E7,$E5,$DB
                DEFB      $82,$76,$97,$60,$F5,$C7
                DEFB      $01    ,$94,$E7,$F5,$DB
                DEFB      $01    ,$87,$60,$F5,$EF
                DEFB      $01    ,$84,$E7,$F5,$DB
                DEFB  $FF  ; End of Pattern

PAT26:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$18,$86,$92,$F5,$86
                DEFB      $01    ,$84,$63,$F5,$86
                DEFB      $01    ,$96,$92,$F5,$9A
                DEFB      $01    ,$94,$63,$F5,$86
                DEFB      $82,$31,$A6,$92,$E5,$72
                DEFB      $01    ,$A4,$63,$E5,$86
                DEFB      $01    ,$B6,$92,$E5,$9A
                DEFB      $01    ,$B4,$63,$E5,$86
                DEFB  $06,$81,$18,$C6,$92,$D5,$72
                DEFB      $01    ,$C4,$63,$D5,$86
                DEFB      $01    ,$D6,$92,$D5,$9A
                DEFB      $01    ,$D4,$63,$D5,$86
                DEFB      $82,$76,$E6,$92,$C5,$72
                DEFB      $01    ,$E4,$63,$C5,$86
                DEFB      $01    ,$F6,$92,$C5,$9A
                DEFB      $01    ,$F4,$63,$C5,$86
                DEFB  $05,$82,$C3,$F6,$92,$B5,$72
                DEFB      $01    ,$F4,$63,$B5,$86
                DEFB      $01    ,$E6,$92,$B5,$9A
                DEFB      $01    ,$E4,$63,$B5,$86
                DEFB      $81,$18,$D6,$92,$A5,$72
                DEFB      $01    ,$D4,$63,$A5,$86
                DEFB      $01    ,$C6,$92,$A5,$9A
                DEFB      $01    ,$C4,$63,$A5,$86
                DEFB  $06,$82,$76,$B6,$92,$95,$72
                DEFB      $01    ,$B4,$63,$95,$86
                DEFB      $01    ,$A6,$92,$95,$9A
                DEFB      $01    ,$A4,$63,$95,$86
                DEFB      $81,$18,$96,$92,$85,$72
                DEFB      $01    ,$94,$63,$85,$86
                DEFB      $01    ,$86,$92,$85,$9A
                DEFB      $01    ,$84,$63,$85,$86
                DEFB  $FF  ; End of Pattern

PAT27:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$D2,$83,$E8,$84,$E7
                DEFB      $01    ,$86,$92,$84,$E7
                DEFB      $01    ,$93,$E8,$85,$0B
                DEFB      $01    ,$96,$92,$84,$E7
                DEFB      $81,$A4,$A3,$E8,$94,$C3
                DEFB      $01    ,$A6,$92,$94,$E7
                DEFB      $01    ,$B3,$E8,$95,$0B
                DEFB      $01    ,$B6,$92,$94,$E7
                DEFB  $06,$80,$D2,$C3,$E8,$A4,$C3
                DEFB      $01    ,$C6,$92,$A4,$E7
                DEFB      $01    ,$D3,$E8,$A5,$0B
                DEFB      $01    ,$D6,$92,$A4,$E7
                DEFB      $81,$D8,$E3,$E8,$B4,$C3
                DEFB      $01    ,$E6,$92,$B4,$E7
                DEFB      $01    ,$F3,$E8,$B5,$0B
                DEFB      $01    ,$F6,$92,$B4,$E7
                DEFB  $05,$81,$F4,$F3,$E8,$C4,$C3
                DEFB      $01    ,$F6,$92,$C4,$E7
                DEFB      $01    ,$E3,$E8,$C5,$0B
                DEFB      $01    ,$E6,$92,$C4,$E7
                DEFB      $80,$D2,$D3,$E8,$D4,$C3
                DEFB      $01    ,$D6,$92,$D4,$E7
                DEFB      $01    ,$C3,$E8,$D5,$0B
                DEFB      $01    ,$C6,$92,$D4,$E7
                DEFB  $06,$81,$D8,$B3,$E8,$E4,$C3
                DEFB      $01    ,$B6,$92,$E4,$E7
                DEFB      $01    ,$A3,$E8,$E5,$0B
                DEFB      $01    ,$A6,$92,$E4,$E7
                DEFB      $80,$D2,$93,$E8,$F4,$C3
                DEFB      $01    ,$96,$92,$F4,$E7
                DEFB      $01    ,$83,$E8,$F5,$0B
                DEFB      $01    ,$86,$92,$F4,$E7
                DEFB  $FF  ; End of Pattern

PAT28:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$FA,$83,$E8,$F4,$E7
                DEFB      $01    ,$85,$DB,$F4,$E7
                DEFB      $01    ,$93,$E8,$F4,$E7
                DEFB      $01    ,$95,$DB,$F4,$E7
                DEFB      $81,$F4,$A3,$E8,$E5,$0B
                DEFB      $01    ,$A5,$DB,$E4,$E7
                DEFB      $01    ,$B3,$E8,$E4,$C3
                DEFB      $01    ,$B5,$DB,$E4,$E7
                DEFB  $06,$80,$FA,$C3,$E8,$D5,$0B
                DEFB      $01    ,$C5,$DB,$D4,$E7
                DEFB      $01    ,$D3,$E8,$D4,$C3
                DEFB      $01    ,$D5,$DB,$D4,$E7
                DEFB      $82,$31,$E3,$E8,$C5,$0B
                DEFB      $01    ,$E5,$DB,$C4,$E7
                DEFB      $01    ,$F3,$E8,$C4,$C3
                DEFB      $01    ,$F5,$DB,$C4,$E7
                DEFB  $05,$82,$76,$F3,$E8,$B5,$0B
                DEFB      $01    ,$F5,$DB,$B4,$E7
                DEFB      $01    ,$E3,$E8,$B4,$C3
                DEFB      $01    ,$E5,$DB,$B4,$E7
                DEFB      $80,$FA,$D3,$E8,$A5,$0B
                DEFB      $01    ,$D5,$DB,$A4,$E7
                DEFB      $01    ,$C3,$E8,$A4,$C3
                DEFB      $01    ,$C5,$DB,$A4,$E7
                DEFB  $06,$82,$31,$B3,$E8,$95,$0B
                DEFB      $01    ,$B5,$DB,$94,$E7
                DEFB      $01    ,$A3,$E8,$94,$C3
                DEFB      $01    ,$A5,$DB,$94,$E7
                DEFB      $80,$FA,$93,$E8,$85,$0B
                DEFB      $01    ,$95,$DB,$84,$E7
                DEFB      $01    ,$83,$E8,$84,$C3
                DEFB      $01    ,$85,$DB,$84,$E7
                DEFB  $FF  ; End of Pattern

PAT29:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$3B,$87,$60,$85,$DB
                DEFB      $01    ,$84,$E7,$95,$DB
                DEFB      $01    ,$97,$60,$A5,$EF
                DEFB      $01    ,$94,$E7,$B5,$DB
                DEFB      $82,$76,$A7,$60,$C7,$4C
                DEFB      $01    ,$A4,$E7,$D7,$60
                DEFB      $01    ,$B7,$60,$E7,$74
                DEFB      $01    ,$B4,$E7,$F7,$60
                DEFB  $06,$81,$3B,$C7,$60,$F8,$B2
                DEFB      $01    ,$C4,$E7,$E8,$C6
                DEFB      $01    ,$D7,$60,$D8,$DA
                DEFB      $01    ,$D4,$E7,$C8,$C6
                DEFB      $82,$C3,$E7,$60,$B9,$C5
                DEFB      $01    ,$E4,$E7,$A9,$D9
                DEFB      $01    ,$F7,$60,$99,$ED
                DEFB      $01    ,$F4,$E7,$89,$D9
                DEFB  $05,$82,$ED,$F7,$60,$8B,$A2
                DEFB      $01    ,$F4,$E7,$9B,$B6
                DEFB      $01    ,$E7,$60,$AB,$CA
                DEFB      $01    ,$E4,$E7,$BB,$B6
                DEFB      $81,$3B,$D7,$60,$CB,$A2
                DEFB      $01    ,$D4,$E7,$DB,$B6
                DEFB      $01    ,$C7,$60,$EB,$CA
                DEFB      $01    ,$C4,$E7,$FB,$B6
                DEFB  $06,$82,$C3,$B7,$60,$FB,$A2
                DEFB      $01    ,$B4,$E7,$EB,$B6
                DEFB      $01    ,$A7,$60,$DB,$CA
                DEFB      $01    ,$A4,$E7,$CB,$B6
                DEFB      $82,$76,$97,$60,$BE,$AD
                DEFB      $01    ,$94,$E7,$AE,$C1
                DEFB      $01    ,$87,$60,$9E,$D5
                DEFB      $01    ,$84,$E7,$8E,$C1
                DEFB  $FF  ; End of Pattern

PAT30:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$18,$86,$92,$8B,$0D
                DEFB      $01    ,$84,$63,$9B,$0D
                DEFB      $01    ,$96,$92,$AB,$21
                DEFB      $01    ,$94,$63,$BB,$0D
                DEFB      $82,$31,$A6,$92,$C8,$B2
                DEFB      $01    ,$A4,$63,$D8,$C6
                DEFB      $01    ,$B6,$92,$E8,$DA
                DEFB      $01    ,$B4,$63,$F8,$C6
                DEFB  $06,$81,$18,$C6,$92,$F6,$7E
                DEFB      $01    ,$C4,$63,$E6,$92
                DEFB      $01    ,$D6,$92,$D6,$A6
                DEFB      $01    ,$D4,$63,$C6,$92
                DEFB      $82,$76,$E6,$92,$B5,$72
                DEFB      $01    ,$E4,$63,$A5,$86
                DEFB      $01    ,$F6,$92,$95,$9A
                DEFB      $01    ,$F4,$63,$85,$86
                DEFB  $05,$82,$C3,$F6,$92,$84,$4F
                DEFB      $01    ,$F4,$63,$94,$63
                DEFB      $01    ,$E6,$92,$A4,$77
                DEFB      $01    ,$E4,$63,$B4,$63
                DEFB      $81,$18,$D6,$92,$C4,$4F
                DEFB      $01    ,$D4,$63,$D4,$63
                DEFB      $01    ,$C6,$92,$E4,$77
                DEFB      $01    ,$C4,$63,$F4,$63
                DEFB  $06,$82,$76,$B6,$92,$F4,$4F
                DEFB      $01    ,$B4,$63,$E4,$63
                DEFB      $01    ,$A6,$92,$D4,$77
                DEFB      $01    ,$A4,$63,$C4,$63
                DEFB      $82,$31,$96,$92,$B4,$4F
                DEFB      $01    ,$94,$63,$A4,$63
                DEFB      $01    ,$86,$92,$94,$77
                DEFB      $01    ,$84,$63,$84,$63
                DEFB  $FF  ; End of Pattern

PAT31:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$D2,$83,$E8,$84,$E7
                DEFB      $01    ,$86,$92,$84,$E7
                DEFB      $01    ,$93,$E8,$85,$0B
                DEFB      $01    ,$96,$92,$84,$E7
                DEFB      $81,$A4,$A3,$E8,$94,$3F
                DEFB      $01    ,$A6,$92,$94,$63
                DEFB      $01    ,$B3,$E8,$94,$87
                DEFB      $01    ,$B6,$92,$94,$63
                DEFB  $06,$80,$D2,$C3,$E8,$A4,$C3
                DEFB      $01    ,$C6,$92,$A4,$E7
                DEFB      $01    ,$D3,$E8,$A5,$0B
                DEFB      $01    ,$D6,$92,$A4,$E7
                DEFB      $81,$D8,$E3,$E8,$B4,$3F
                DEFB      $01    ,$E6,$92,$B4,$63
                DEFB      $01    ,$F3,$E8,$B4,$87
                DEFB      $01    ,$F6,$92,$B4,$63
                DEFB  $05,$81,$F4,$F3,$E8,$C5,$B7
                DEFB      $01    ,$F6,$92,$C5,$DB
                DEFB      $01    ,$E3,$E8,$C5,$FF
                DEFB      $01    ,$E6,$92,$C5,$DB
                DEFB      $80,$D2,$D3,$E8,$D5,$B7
                DEFB      $01    ,$D6,$92,$D5,$DB
                DEFB      $01    ,$C3,$E8,$D5,$FF
                DEFB      $01    ,$C6,$92,$D5,$DB
                DEFB  $06,$81,$D8,$B3,$E8,$E4,$C3
                DEFB      $01    ,$B6,$92,$E4,$E7
                DEFB      $01    ,$A3,$E8,$E5,$0B
                DEFB      $01    ,$A6,$92,$E4,$E7
                DEFB      $80,$D2,$93,$E8,$F4,$3F
                DEFB      $01    ,$96,$92,$F4,$63
                DEFB      $01    ,$83,$E8,$F4,$87
                DEFB      $01    ,$86,$92,$F4,$63
                DEFB  $FF  ; End of Pattern

PAT32:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$FA,$83,$E8,$F5,$DB
                DEFB      $01    ,$85,$DB,$F4,$E7
                DEFB      $01    ,$93,$E8,$F5,$DB
                DEFB      $01    ,$95,$DB,$F4,$E7
                DEFB      $81,$F4,$A3,$E8,$E5,$0B
                DEFB      $01    ,$A5,$DB,$E4,$E7
                DEFB      $01    ,$B3,$E8,$E4,$C3
                DEFB      $01    ,$B5,$DB,$E4,$E7
                DEFB  $06,$80,$FA,$C3,$E8,$D5,$FF
                DEFB      $01    ,$C5,$DB,$D4,$E7
                DEFB      $01    ,$D3,$E8,$D5,$B7
                DEFB      $01    ,$D5,$DB,$D4,$E7
                DEFB      $82,$31,$E3,$E8,$C5,$FF
                DEFB      $01    ,$E5,$DB,$C4,$E7
                DEFB      $01    ,$F3,$E8,$C5,$B7
                DEFB      $01    ,$F5,$DB,$C4,$E7
                DEFB  $05,$82,$76,$F3,$E8,$B5,$0B
                DEFB      $01    ,$F5,$DB,$B4,$E7
                DEFB      $01    ,$E3,$E8,$B4,$C3
                DEFB      $01    ,$E5,$DB,$B4,$E7
                DEFB      $80,$FA,$D3,$E8,$A5,$0B
                DEFB      $01    ,$D5,$DB,$A4,$E7
                DEFB      $01    ,$C3,$E8,$A4,$C3
                DEFB      $01    ,$C5,$DB,$A4,$E7
                DEFB  $06,$82,$31,$B3,$E8,$95,$0B
                DEFB      $01    ,$B5,$DB,$94,$E7
                DEFB      $01    ,$A3,$E8,$94,$C3
                DEFB      $01    ,$A5,$DB,$94,$E7
                DEFB      $80,$FA,$93,$E8,$85,$0B
                DEFB      $01    ,$95,$DB,$84,$E7
                DEFB      $01    ,$83,$E8,$84,$C3
                DEFB      $01    ,$85,$DB,$84,$E7
                DEFB  $FF  ; End of Pattern

PAT33:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$81,$3B,$85,$DB,$84,$E7
                DEFB      $01    ,$84,$E7,$84,$E7
                DEFB      $01    ,$95,$DB,$84,$FB
                DEFB      $01    ,$94,$E7,$84,$E7
                DEFB      $82,$76,$A5,$DB,$94,$D3
                DEFB      $01    ,$A4,$E7,$94,$E7
                DEFB      $01    ,$B5,$DB,$94,$FB
                DEFB      $01    ,$B4,$E7,$94,$E7
                DEFB  $06,$81,$3B,$C5,$DB,$A4,$D3
                DEFB      $01    ,$C4,$E7,$A4,$E7
                DEFB      $01    ,$D5,$DB,$A4,$FB
                DEFB      $01    ,$D4,$E7,$A4,$E7
                DEFB      $82,$C3,$E5,$DB,$B4,$D3
                DEFB      $01    ,$E4,$E7,$B4,$E7
                DEFB      $01    ,$F5,$DB,$B4,$FB
                DEFB      $01    ,$F4,$E7,$B4,$E7
                DEFB  $05,$82,$ED,$F5,$DB,$C4,$D3
                DEFB      $01    ,$F4,$E7,$C4,$E7
                DEFB      $01    ,$E5,$DB,$C4,$FB
                DEFB      $01    ,$E4,$E7,$C4,$E7
                DEFB      $81,$3B,$D5,$DB,$D4,$D3
                DEFB      $01    ,$D4,$E7,$D4,$E7
                DEFB      $01    ,$C5,$DB,$D4,$FB
                DEFB      $01    ,$C4,$E7,$D4,$E7
                DEFB  $06,$82,$C3,$B5,$DB,$E4,$D3
                DEFB      $01    ,$B4,$E7,$E4,$E7
                DEFB      $01    ,$A5,$DB,$E4,$FB
                DEFB      $01    ,$A4,$E7,$E4,$E7
                DEFB      $82,$76,$95,$DB,$F4,$D3
                DEFB      $01    ,$94,$E7,$F4,$E7
                DEFB      $01    ,$85,$DB,$F4,$FB
                DEFB      $01    ,$84,$E7,$F4,$E7
                DEFB  $FF  ; End of Pattern

PAT34:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$EC,$85,$86,$84,$63
                DEFB      $01    ,$83,$B0,$84,$63
                DEFB      $01    ,$95,$86,$84,$77
                DEFB      $01    ,$93,$B0,$84,$63
                DEFB      $81,$D8,$A5,$86,$94,$4F
                DEFB      $01    ,$A3,$B0,$94,$63
                DEFB      $01    ,$B5,$86,$94,$77
                DEFB      $01    ,$B3,$B0,$94,$63
                DEFB  $06,$80,$EC,$C5,$86,$A4,$4F
                DEFB      $01    ,$C3,$B0,$A4,$63
                DEFB      $01    ,$D5,$86,$A4,$77
                DEFB      $01    ,$D3,$B0,$A4,$63
                DEFB      $82,$11,$E5,$86,$B4,$4F
                DEFB      $01    ,$E3,$B0,$B4,$63
                DEFB      $01    ,$F5,$86,$B4,$77
                DEFB      $01    ,$F3,$B0,$B4,$63
                DEFB  $05,$82,$31,$F5,$86,$C4,$4F
                DEFB      $01    ,$F3,$B0,$C4,$63
                DEFB      $01    ,$E5,$86,$C4,$77
                DEFB      $01    ,$E3,$B0,$C4,$63
                DEFB      $80,$EC,$D5,$86,$D4,$4F
                DEFB      $01    ,$D3,$B0,$D4,$63
                DEFB      $01    ,$C5,$86,$D4,$77
                DEFB      $01    ,$C3,$B0,$D4,$63
                DEFB  $06,$82,$11,$B5,$86,$E4,$4F
                DEFB      $01    ,$B3,$B0,$E4,$63
                DEFB      $01    ,$A5,$86,$E4,$77
                DEFB      $01    ,$A3,$B0,$E4,$63
                DEFB      $81,$D8,$95,$86,$F4,$4F
                DEFB      $01    ,$93,$B0,$F4,$63
                DEFB      $01    ,$85,$86,$F4,$77
                DEFB      $01    ,$83,$B0,$F4,$63
                DEFB  $FF  ; End of Pattern

PAT35:
                ;;DEFW  1236     ; Pattern tempo
                DEFW	970
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$EC,$85,$86,$F4,$63
                DEFB      $01    ,$83,$B0,$F4,$63
                DEFB      $01    ,$95,$86,$F4,$77
                DEFB      $01    ,$93,$B0,$F4,$63
                DEFB      $81,$D8,$A5,$86,$E4,$4F
                DEFB      $01    ,$A3,$B0,$E4,$63
                DEFB      $01    ,$B5,$86,$E4,$77
                DEFB      $01    ,$B3,$B0,$E4,$63
                DEFB  $06,$80,$EC,$C5,$86,$D4,$4F
                DEFB      $01    ,$C3,$B0,$D4,$63
                DEFB      $01    ,$D5,$86,$D4,$77
                DEFB      $01    ,$D3,$B0,$D4,$63
                DEFB      $82,$11,$E5,$86,$C4,$4F
                DEFB      $01    ,$E3,$B0,$C4,$63
                DEFB      $01    ,$F5,$86,$C4,$77
                DEFB      $01    ,$F3,$B0,$C4,$63
                DEFB  $05,$82,$31,$F5,$86,$B4,$4F
                DEFB      $01    ,$F3,$B0,$B4,$63
                DEFB      $01    ,$E5,$86,$B4,$77
                DEFB      $01    ,$E3,$B0,$B4,$63
                DEFB      $80,$EC,$D5,$86,$A4,$4F
                DEFB      $01    ,$D3,$B0,$A4,$63
                DEFB      $01    ,$C5,$86,$A4,$77
                DEFB      $01    ,$C3,$B0,$A4,$63
                DEFB  $06,$82,$11,$B5,$86,$94,$4F
                DEFB      $01    ,$B3,$B0,$94,$63
                DEFB      $01    ,$A5,$86,$94,$77
                DEFB      $01    ,$A3,$B0,$94,$63
                DEFB      $81,$D8,$95,$86,$84,$4F
                DEFB      $01    ,$93,$B0,$84,$63
                DEFB      $01    ,$85,$86,$84,$77
                DEFB      $01    ,$83,$B0,$84,$63
                DEFB  $FF  ; End of Pattern

