
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
	call	$01c9		; VZ ROM CLS
	ld	hl, MSG1	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG2	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG3	; Print MENU
	call	$28a7		; VZ ROM Print string.


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



MSG1	db $0d,"TRITONE ENGINE - BY SHIRU.",00
MSG2	db $0d,"VZ CONVERSION BY BUSHY."
	db " SEP'19.",0
MSG3	db $0d,"SONG: JOURNEY."
	db 0,0,0




musicData


; *** Song layout ***
LOOPSTART:            DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT4
                      DEFW      PAT3
                      DEFW      PAT4
                      DEFW      PAT3
                      DEFW      PAT9
                      DEFW      PAT9
                      DEFW      PAT10
                      DEFW      PAT10
                      DEFW      PAT15
                      DEFW      PAT15
                      DEFW      PAT16
                      DEFW      PAT16
                      DEFW      PAT11
                      DEFW      PAT12
                      DEFW      PAT3
                      DEFW      PAT4
                      DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT4
                      DEFW      PAT3
                      DEFW      PAT4
                      DEFW      PAT3
                      DEFW      PAT9
                      DEFW      PAT10
                      DEFW      PAT15
                      DEFW      PAT27
                      DEFW      PAT22
                      DEFW      PAT23
                      DEFW      PAT24
                      DEFW      PAT25
                      DEFW      PAT26
                      DEFW      PAT26
                      DEFW      PAT15
                      DEFW      PAT15
                      DEFW      PAT27
                      DEFW      PAT27
                      DEFW      PAT22
                      DEFW      PAT23
                      DEFW      PAT24
                      DEFW      PAT25
                      DEFW      $0000
                      DEFW      LOOPSTART

; *** Patterns ***
PAT0:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$76,$F1,$61,$90,$EC
                DEFB      $80,$EC,$01    ,$E1,$D8
                DEFB      $80,$76,$01    ,$90,$EC
                DEFB      $80,$EC,$01    ,$91,$D8
                DEFB  $04,$80,$8C,$F1,$A4,$91,$18
                DEFB      $81,$18,$01    ,$E2,$31
                DEFB      $80,$8C,$01    ,$91,$18
                DEFB      $81,$18,$01    ,$92,$31
                DEFB  $06,$80,$9D,$F1,$D8,$91,$3B
                DEFB      $81,$3B,$01    ,$E2,$76
                DEFB      $80,$9D,$01    ,$91,$3B
                DEFB      $81,$3B,$01    ,$92,$76
                DEFB  $04,$80,$69,$F1,$3B,$90,$D2
                DEFB      $80,$D2,$01    ,$E1,$A4
                DEFB      $80,$69,$01    ,$90,$D2
                DEFB      $80,$D2,$01    ,$91,$A4
                DEFB  $FF  ; End of Pattern

PAT3:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$EC,$F0,$ED,$B0,$76
                DEFB      $81,$61,$F1,$62,$01
                DEFB  $06,$81,$D8,$F1,$D9,$01
                DEFB      $80,$EC,$F0,$ED,$01
                DEFB  $03,$81,$61,$F1,$62,$01
                DEFB      $81,$D8,$F1,$D9,$01
                DEFB  $0E,$80,$EC,$F0,$ED,$01
                DEFB      $81,$61,$F1,$62,$01
                DEFB  $06,$81,$18,$F2,$31,$B1,$A4
                DEFB      $01    ,$01    ,$01
                DEFB  $06,$01    ,$81,$19,$81,$A4
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$01    ,$F2,$31,$B1,$A4
                DEFB      $01    ,$01    ,$01
                DEFB  $0E,$E1,$18,$B1,$19,$E1,$A4
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT4:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$EC,$E3,$B0,$80,$77
                DEFB      $81,$61,$E3,$49,$D1,$62
                DEFB  $06,$81,$D8,$82,$C3,$D1,$D9
                DEFB      $80,$EC,$81,$D8,$80,$77
                DEFB  $04,$81,$61,$E1,$A4,$D1,$62
                DEFB      $81,$D8,$E1,$D8,$D1,$D9
                DEFB  $0E,$80,$EC,$F2,$31,$80,$77
                DEFB      $81,$61,$00    ,$D1,$62
                DEFB  $06,$81,$18,$D2,$C3,$F1,$A4
                DEFB      $01    ,$D2,$31,$F0,$D2
                DEFB  $09,$01    ,$81,$D8,$81,$A4
                DEFB      $01    ,$81,$A4,$80,$D2
                DEFB  $04,$01    ,$E3,$B0,$F1,$A4
                DEFB      $01    ,$E3,$49,$F0,$D2
                DEFB  $0E,$E1,$18,$82,$C3,$E1,$A4
                DEFB      $01    ,$E2,$C3,$01
                DEFB  $FF  ; End of Pattern

PAT9:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$ED,$90,$EC,$F1,$D8
                DEFB      $B0,$76,$01    ,$80,$EC
                DEFB  $06,$B0,$D3,$90,$D2,$F1,$A4
                DEFB      $01    ,$01    ,$F0,$D2
                DEFB  $04,$B0,$ED,$90,$EC,$F1,$D8
                DEFB      $B0,$76,$01    ,$F0,$EC
                DEFB  $0E,$B0,$ED,$90,$EC,$00
                DEFB  $09,$00    ,$01    ,$01
                DEFB  $06,$B0,$EC,$90,$ED,$F1,$D8
                DEFB      $B0,$76,$01    ,$F0,$EC
                DEFB  $09,$01    ,$00    ,$00
                DEFB      $01    ,$01    ,$80,$EC
                DEFB  $04,$B0,$ED,$90,$EC,$F1,$D8
                DEFB      $B0,$76,$00    ,$80,$EC
                DEFB  $0E,$B0,$D2,$90,$D3,$F1,$A4
                DEFB      $B0,$69,$01    ,$80,$D2
                DEFB  $FF  ; End of Pattern

PAT10:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$ED,$90,$EC,$93,$B0
                DEFB      $B0,$76,$01    ,$00
                DEFB  $06,$B0,$D3,$90,$D2,$93,$49
                DEFB      $01    ,$01    ,$00
                DEFB  $04,$B0,$ED,$90,$EC,$94,$63
                DEFB      $B0,$76,$01    ,$E4,$63
                DEFB  $0E,$B0,$ED,$90,$EC,$93,$B0
                DEFB      $00    ,$01    ,$E3,$B0
                DEFB  $06,$B0,$EC,$90,$ED,$F1,$D8
                DEFB      $B0,$76,$01    ,$F0,$EC
                DEFB  $0E,$01    ,$00    ,$00
                DEFB      $01    ,$01    ,$80,$EC
                DEFB  $04,$B0,$ED,$90,$EC,$F1,$D8
                DEFB      $B0,$76,$00    ,$80,$EC
                DEFB  $0E,$B0,$D3,$90,$D2,$F1,$A4
                DEFB      $B0,$69,$01    ,$80,$D2
                DEFB  $FF  ; End of Pattern

PAT11:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$ED,$F0,$EC,$93,$B0
                DEFB      $80,$76,$01    ,$93,$49
                DEFB  $06,$80,$D3,$F0,$D2,$92,$C3
                DEFB      $01    ,$01    ,$93,$49
                DEFB  $04,$80,$ED,$F0,$EC,$93,$B0
                DEFB      $80,$76,$01    ,$00
                DEFB  $0E,$80,$ED,$F0,$EC,$94,$63
                DEFB      $00    ,$01    ,$D4,$63
                DEFB  $06,$80,$ED,$F0,$EC,$F4,$63
                DEFB      $80,$76,$01    ,$00
                DEFB  $06,$01    ,$00    ,$F3,$B0
                DEFB      $01    ,$01    ,$D3,$9C
                DEFB  $04,$80,$ED,$F0,$EC,$E3,$87
                DEFB      $80,$76,$00    ,$B3,$73
                DEFB  $0E,$80,$D3,$F0,$D2,$93,$5E
                DEFB      $80,$69,$01    ,$83,$49
                DEFB  $FF  ; End of Pattern

PAT12:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$80,$ED,$F0,$EC,$93,$49
                DEFB      $80,$76,$01    ,$D3,$49
                DEFB  $06,$80,$D3,$F0,$D2,$F3,$49
                DEFB      $01    ,$01    ,$00
                DEFB  $04,$80,$ED,$F0,$EC,$01
                DEFB      $80,$76,$01    ,$01
                DEFB  $0E,$80,$ED,$F0,$EC,$F1,$D8
                DEFB      $00    ,$01    ,$00
                DEFB  $06,$80,$ED,$F0,$EC,$D2,$C3
                DEFB      $80,$76,$F1,$D8,$E2,$31
                DEFB  $06,$01    ,$00    ,$F1,$D8
                DEFB      $01    ,$01    ,$00
                DEFB  $04,$80,$ED,$F0,$EC,$D1,$D8
                DEFB      $80,$76,$00    ,$81,$D8
                DEFB  $0E,$80,$D3,$F0,$D2,$D1,$A4
                DEFB      $80,$69,$01    ,$81,$A4
                DEFB  $FF  ; End of Pattern

PAT15:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$EC,$F1,$D8,$93,$B0
                DEFB      $B0,$76,$80,$EC,$91,$D8
                DEFB  $0E,$B0,$D2,$F1,$A4,$93,$49
                DEFB      $01    ,$F0,$D3,$91,$A4
                DEFB  $04,$B0,$EC,$F1,$D8,$94,$E7
                DEFB      $B0,$76,$F0,$EC,$95,$86
                DEFB  $0E,$B0,$EC,$00    ,$93,$B0
                DEFB      $00    ,$01    ,$E1,$D8
                DEFB  $06,$B0,$EC,$F1,$D9,$81,$D8
                DEFB      $B0,$76,$F0,$EC,$01
                DEFB  $0F,$01    ,$00    ,$80,$EC
                DEFB      $01    ,$80,$ED,$01
                DEFB  $04,$B0,$EC,$F1,$D8,$D3,$B0
                DEFB      $B0,$76,$80,$EC,$91,$D8
                DEFB  $0E,$B0,$D2,$F1,$A4,$B3,$49
                DEFB      $B0,$69,$80,$D2,$B1,$A4
                DEFB  $FF  ; End of Pattern

PAT16:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$EC,$F1,$D8,$B6,$92
                DEFB      $B0,$76,$80,$EC,$B5,$86
                DEFB  $0E,$B0,$D2,$F1,$A4,$B4,$63
                DEFB      $01    ,$F0,$D3,$93,$B0
                DEFB  $04,$B0,$EC,$F1,$D8,$00
                DEFB      $B0,$76,$F0,$EC,$85,$37
                DEFB  $0E,$B0,$EC,$00    ,$F4,$E7
                DEFB      $00    ,$01    ,$B4,$E7
                DEFB  $06,$B0,$EC,$F1,$D8,$94,$63
                DEFB      $B0,$76,$F0,$EC,$00
                DEFB  $09,$01    ,$00    ,$93,$B0
                DEFB      $01    ,$80,$EC,$91,$D8
                DEFB  $04,$B0,$D2,$F1,$A4,$E3,$49
                DEFB      $B0,$69,$80,$D2,$00
                DEFB  $0E,$B0,$EC,$F1,$D8,$E3,$B0
                DEFB      $B0,$76,$80,$EC,$00
                DEFB  $FF  ; End of Pattern

PAT22:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$ED,$A3,$B0,$F1,$D8
                DEFB      $B0,$76,$A4,$63,$80,$EC
                DEFB  $0E,$B0,$D3,$A5,$86,$F1,$A4
                DEFB      $01    ,$00    ,$F0,$D2
                DEFB  $04,$B0,$ED,$D3,$B0,$F1,$D8
                DEFB      $B0,$76,$00    ,$F0,$EC
                DEFB  $0E,$B1,$19,$D4,$63,$F2,$31
                DEFB  $17,$B0,$8C,$D5,$86,$00
                DEFB  $06,$B0,$ED,$D7,$60,$F1,$D8
                DEFB      $B0,$76,$00    ,$F0,$EC
                DEFB  $0E,$B0,$D2,$E8,$C6,$F1,$A4
                DEFB  $06,$01    ,$E8,$47,$80,$D2
                DEFB  $04,$B1,$19,$E7,$60,$F2,$31
                DEFB      $B0,$8C,$E6,$92,$01
                DEFB  $0E,$B0,$ED,$F5,$86,$F1,$D8
                DEFB      $B0,$76,$F4,$63,$01
                DEFB  $FF  ; End of Pattern

PAT23:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$D3,$E8,$47,$F1,$A4
                DEFB      $B0,$69,$01    ,$80,$D2
                DEFB  $0E,$B0,$BC,$01    ,$F1,$76
                DEFB  $06,$01    ,$01    ,$F0,$BB
                DEFB  $04,$B0,$D3,$E6,$92,$F1,$A4
                DEFB      $B0,$69,$01    ,$F0,$D2
                DEFB  $0E,$B0,$BC,$01    ,$F1,$76
                DEFB  $07,$B0,$5D,$01    ,$00
                DEFB  $06,$B0,$D3,$D4,$E7,$F1,$A4
                DEFB      $B0,$69,$01    ,$F0,$D2
                DEFB  $06,$B0,$BB,$01    ,$F1,$76
                DEFB      $01    ,$01    ,$80,$BB
                DEFB  $04,$B0,$D3,$B4,$63,$F1,$A4
                DEFB      $B0,$69,$01    ,$80,$D2
                DEFB  $05,$B0,$BC,$94,$23,$F1,$76
                DEFB  $06,$B0,$5D,$01    ,$80,$BB
                DEFB  $FF  ; End of Pattern

PAT24:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$BC,$94,$63,$F1,$76
                DEFB      $B0,$5D,$A4,$63,$80,$BB
                DEFB  $06,$B0,$ED,$B4,$63,$F1,$D8
                DEFB      $01    ,$C4,$63,$F0,$EC
                DEFB  $04,$B1,$19,$D4,$63,$F2,$31
                DEFB      $B0,$8C,$E4,$63,$F1,$18
                DEFB  $0E,$B0,$ED,$F4,$63,$F1,$D8
                DEFB  $06,$01    ,$01    ,$00
                DEFB  $06,$B0,$BC,$E4,$E7,$F1,$76
                DEFB      $B0,$5D,$01    ,$F0,$BB
                DEFB  $06,$B0,$EC,$E4,$63,$F1,$D8
                DEFB      $01    ,$01    ,$80,$EC
                DEFB  $04,$B0,$ED,$E3,$B0,$F1,$D8
                DEFB      $01    ,$01    ,$80,$EC
                DEFB  $09,$B0,$BC,$E2,$ED,$F1,$76
                DEFB      $B0,$5D,$01    ,$80,$BB
                DEFB  $FF  ; End of Pattern

PAT25:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$B1,$E2,$C3,$F1,$61
                DEFB      $01    ,$B2,$C3,$80,$B0
                DEFB  $06,$B0,$DF,$E2,$C3,$F1,$BD
                DEFB      $01    ,$B2,$C3,$F0,$DE
                DEFB  $04,$B1,$09,$F2,$C3,$F2,$11
                DEFB      $B0,$84,$01    ,$F1,$08
                DEFB  $0E,$B0,$DF,$B2,$C3,$F1,$BD
                DEFB  $04,$01    ,$92,$C3,$00
                DEFB  $06,$B0,$B1,$F2,$C3,$F1,$61
                DEFB      $01    ,$01    ,$F0,$B0
                DEFB  $06,$B0,$DE,$82,$C3,$F1,$BD
                DEFB      $01    ,$01    ,$80,$DE
                DEFB  $04,$B0,$DF,$F1,$61,$F1,$BD
                DEFB      $01    ,$01    ,$80,$DE
                DEFB  $0E,$B0,$B1,$F1,$62,$F1,$61
                DEFB  $09,$01    ,$01    ,$80,$B0
                DEFB  $FF  ; End of Pattern

PAT26:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$ED,$93,$B0,$91,$D8
                DEFB      $B0,$76,$91,$D8,$00
                DEFB  $0E,$B0,$D3,$93,$49,$91,$A4
                DEFB      $01    ,$91,$A4,$00
                DEFB  $04,$B0,$ED,$93,$B0,$91,$D8
                DEFB      $B0,$76,$94,$63,$E0,$EC
                DEFB  $0E,$B0,$ED,$93,$B0,$90,$76
                DEFB      $00    ,$91,$D8,$01
                DEFB  $06,$B0,$ED,$90,$EC,$F1,$D8
                DEFB      $B0,$76,$01    ,$F0,$EC
                DEFB  $0E,$01    ,$00    ,$00
                DEFB      $01    ,$01    ,$80,$EC
                DEFB  $04,$B0,$ED,$90,$EC,$F1,$D8
                DEFB      $B0,$76,$00    ,$80,$EC
                DEFB  $0E,$B0,$D3,$90,$D2,$F1,$A4
                DEFB      $B0,$69,$01    ,$80,$D2
                DEFB  $FF  ; End of Pattern

PAT27:
                DEFW  2896  ;; was 3692     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$B0,$ED,$F1,$D8,$E3,$B0
                DEFB      $B0,$76,$80,$EC,$E3,$49
                DEFB  $0E,$B0,$D3,$F1,$A4,$85,$37
                DEFB      $01    ,$F0,$D2,$94,$E7
                DEFB  $04,$B0,$ED,$F1,$D8,$00
                DEFB      $B0,$76,$F0,$EC,$E4,$63
                DEFB  $0E,$B0,$ED,$00    ,$E3,$B0
                DEFB      $00    ,$01    ,$81,$D8
                DEFB  $06,$B0,$EC,$F1,$D9,$E4,$63
                DEFB      $B0,$76,$F0,$EC,$00
                DEFB  $06,$01    ,$00    ,$E3,$B0
                DEFB      $01    ,$80,$ED,$00
                DEFB  $04,$B0,$D2,$F1,$A4,$B3,$49
                DEFB      $B0,$69,$80,$D2,$91,$A4
                DEFB  $0E,$B0,$EC,$F1,$D8,$E3,$B0
                DEFB      $B0,$76,$80,$EC,$E1,$D8
                DEFB  $FF  ; End of Pattern

