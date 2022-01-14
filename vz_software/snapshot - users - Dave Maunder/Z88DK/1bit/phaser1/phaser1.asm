
;Phaser - ZX Spectrum beeper engine
;by utz 08'2014
;
;
;
XDEF _phaser
_phaser:


begin:

;	call	$01c9		; VZ ROM CLS
;	ld	hl, MSG0	; Print MENU
;	call	$28a7		; VZ ROM Print string.
;	ld	hl, MSG1	
;	call	$28a7		
;	ld	hl, MSG2	
;	call	$28a7		
;	ld	hl, MSG3	
;	call	$28a7		

	ld hl,musicData
	call play
	ret


play:				;engine code
    di
    push iy

    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld (insTable),hl
    ld (curInsOff),hl

	ld a,($5c48)
	rra
	rra
	rra
	and 7

    ld h,0
    ld l,a
    ld (cnt1a),hl
    ld (cnt1b),hl
    ld (div1a),hl
    ld (div1b),hl
    ld (cnt2),hl
    ld (div2),hl
borderCol equ $+1
    ld a,0
    ld (out1),a
    ld (out2),a

    ex de,hl
    ld (seqPtr),hl

mainLoop:
    ld iyl,0
readLoop:
seqPtr equ $+1
    ld hl,0
    ld a,(hl)
    inc hl
    ld (seqPtr),hl
    or a

    jp z,restart		;end of song, loop
    ;jp z,exitPlayer 	;end of song, stop

    bit 7,a
    jp z,render     	;wait
    ld iyh,a
    and 63
    cp 60
    jp nc,other     	;other parameters
    add a,a         	;note
    ld b,0
    ld c,a
    ld hl,noteTable
    add hl,bc
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld a,iyl
    or a
    jr nz,setNote2  	;second channel
setNote1:
    ld (div1a),de
    ex de,hl
curInsOff equ $+2
    ld ix,0
    ld a,(ix)
    or a
    jr z,$+5
    ld b,a
    add hl,hl
    djnz $-1
    ld e,(ix+1)
    ld d,(ix+2)
    add hl,de
    ld (div1b),hl
    ld iyl,1
    ld a,iyh
    and 64
    jr z,readLoop   	;no phase reset
    ld hl,out1
    res 4,(hl)
    ld hl,0
    ld (cnt1a),hl
    ld h,(ix+3)
    ld (cnt1b),hl
    jr readLoop
setNote2:
    ld (div2),de
    ld a,iyh
    ld hl,out2
    res 4,(hl)
    ld hl,0
    ld (cnt2),hl
    jr readLoop

setStop:
    ld hl,0
    ld a,iyl
    or a
    jr nz,setStop2
setStop1:
    ld (div1a),hl
    ld (div1b),hl
    ld hl,out1
    res 4,(hl)
    ld iyl,1
    jp readLoop
setStop2:
    ld (div2),hl
    ld hl,out2
    res 4,(hl)
    jp readLoop

other:
    cp 60
    jr z,setStop    	;stop note
    cp 62
    jr z,skipChn1   	;no changes for ch1
    cp 63
    jr z,setLoop    	;loop start
    ld hl,(seqPtr)  	;instrument change
    ld a,(hl)
    inc hl
    ld (seqPtr),hl
    ld h,0
    ld l,a
    add hl,hl
insTable equ $+1
    ld bc,0
    add hl,bc
    ld (curInsOff),hl
    jp readLoop

skipChn1:
    ld iyl,1
    jp readLoop

setLoop:
    ld hl,(seqPtr)
    ld (seqStart),hl
    jp readLoop

restart:
seqStart equ $+1
    ld hl,0
    ld (seqPtr),hl
    jp readLoop

exitPlayer:

	ld hl,10072
	exx
    pop iy
    ei
    ret

render:

    and 127
    cp 118

	jp nc,playDrum

    ld d,a
    exx

cnt1a equ $+1
    ld hl,0
cnt1b equ $+2
    ld ix,0
div1a equ $+1
    ld bc,0
div1b equ $+1
    ld de,0
out1 equ $+1
    ld a,0
    exx
;    exa
	ex	af, af'
cnt2 equ $+1
    ld hl,0
div2 equ $+1
    ld bc,0
out2 equ $+1
    ld a,0

playNote:

    ld e,a          ;4
;    xor a           ;4
;    in a,($fe)      ;11
;    or $e0          ;7
;    inc a           ;4
;
;    jr nz,exitPlayer	;7/12 z equ hold key, nz equ wait key

    ld a,e          ;4
    ld e,0          ;7 equ 48t

soundLoop:

    exx             	;4
	ex	af, af'
    add hl,bc    
	or 8  	 	;11
	ld (26624), a
    jr c,$+4        	;7/12
    jr $+4          	;7/12
    xor 33
    add ix,de       	;15
    jr c,$+4       		;7/12
    jr $+4          	;7/12
	xor 33
	ex	af, af'
	or 8
	ld (26624), a
    exx             	;4
    add hl,bc       	;11
    jr c,$+4        	;7/12
    jr $+4				;7/12
	xor 33
    dec e           	;4
   jr nz,soundLoop		;7/12 equ 152, aligned to 8t

    dec d           	;4
    jp nz,playNote  	;10

    ld (cnt2),hl
    ld (out2),a
    exx
	ex	af, af'
    ld (cnt1a),hl
    ld (cnt1b),ix
    ld (out1),a

    jp mainLoop



noteTable:
	defw 186,197,208,221,234,248,263,278,295,313,331,351
	defw 372,394,417,442,469,496,526,557,590,626,663,702
	defw 744,788,835,885,938,993,1053,1115,1181,1252,1326,1405
	defw 1489,1577,1671,1771,1876,1987,2106,2231,2363,2504,2653,2811
	defw 2978,3155,3343,3542,3752,3975,4212,4462,4727,5009,5306,5622
	
	
	


playDrum:

	sub 116
	ld b,a
	ld a,128
	rla
	djnz $-1

	ld (smpn),a
	ld hl,smpData
	ld bc,1024
l0a:
	ld a,(hl)		;7
smpn equ $+1
	and 33			;7
	ld a,d			;4
	jr nz,$+4		;7/12
	jr z,$+4		;7/12
	or 33
	or 8
	ld	(26624), a
	ld e,4			;7
	dec e			;4
	jr nz,$-1		;7/12 equ 56
	inc hl			;6
	dec bc			;6
	ld a,b			;4
	or c			;4
	jr nz,l0a		;7/12 equ 83t
	jp mainLoop



MSG0:   defb "#=-=-=-=-=-=-=-=-=-=-=-=-=-#",$0d,0
MSG1:	defb "# ENGINE: PHASER 1.  AUG19 #",$0d,0
MSG2:	defb "# SONG: FASEUNO            #",$0d,0
MSG3:	defb "#=-=-=-=-=-=-=-=-=-=-=-=-=-#",$0d,0


smpData:defb $02,$02,$02,$02,$00,$00,$02,$00,$0e,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$08,$10,$10,$10
	defb $18,$70,$70,$70,$70,$70,$70,$70,$74,$70,$50,$50,$d8,$d0,$d0,$d0,$d4,$d0,$d0,$d0,$d0,$d0,$d0,$d0
	defb $d4,$d1,$d1,$d1,$5d,$41,$41,$41,$41,$41,$41,$41,$4d,$41,$41,$41,$49,$41,$41,$41,$47,$41,$41,$60
	defb $6c,$22,$20,$20,$2e,$22,$20,$20,$22,$22,$22,$22,$26,$32,$32,$32,$36,$32,$32,$32,$36,$b2,$b2,$b2
	defb $b2,$b2,$32,$32,$3e,$32,$32,$b2,$b2,$b2,$b2,$b2,$be,$12,$12,$11,$17,$13,$93,$93,$97,$83,$83,$c3
	defb $cb,$c3,$c3,$c3,$cb,$c3,$c1,$c1,$c9,$c1,$c1,$c1,$c5,$c1,$c1,$c1,$41,$41,$41,$41,$4d,$41,$41,$41
	defb $41,$40,$40,$40,$6c,$60,$70,$70,$78,$70,$70,$70,$7c,$70,$70,$70,$74,$70,$70,$70,$70,$70,$70,$70
	defb $34,$30,$30,$30,$38,$30,$30,$30,$38,$30,$30,$b0,$b8,$b0,$b0,$b0,$a4,$a0,$a0,$a0,$84,$80,$80,$80
	defb $8c,$80,$80,$80,$8c,$82,$82,$82,$8c,$80,$82,$82,$8e,$83,$81,$83,$8f,$83,$83,$83,$87,$83,$83,$83
	defb $87,$d3,$d3,$d3,$d7,$d3,$d3,$53,$53,$53,$73,$73,$77,$73,$73,$73,$7b,$73,$73,$73,$73,$73,$73,$73
	defb $73,$73,$73,$73,$77,$73,$73,$73,$7d,$73,$73,$71,$6d,$61,$60,$60,$6c,$62,$62,$62,$62,$60,$60,$60
	defb $64,$60,$60,$20,$00,$00,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$04,$00,$90,$90
	defb $1c,$10,$10,$10,$90,$90,$90,$90,$18,$10,$10,$10,$90,$90,$90,$10,$1c,$10,$10,$10,$1c,$30,$30,$30
	defb $34,$b0,$b0,$b0,$34,$30,$f0,$f0,$f4,$f0,$e0,$e0,$e4,$e0,$e0,$60,$68,$e0,$e0,$e0,$e0,$e2,$e2,$e2
	defb $e6,$e0,$e2,$e0,$e6,$e3,$e3,$e3,$e3,$61,$63,$e3,$e7,$e3,$43,$43,$4f,$41,$41,$41,$43,$53,$53,$53
	defb $57,$53,$53,$53,$57,$53,$53,$53,$13,$13,$13,$13,$17,$13,$13,$13,$1b,$13,$13,$11,$19,$13,$13,$11
	defb $11,$11,$13,$11,$11,$11,$11,$13,$1b,$33,$33,$a1,$a3,$a1,$a1,$a1,$21,$21,$a1,$a1,$a9,$a0,$a0,$a0
	defb $a0,$a0,$20,$20,$28,$20,$a0,$a0,$a0,$20,$20,$a0,$e0,$e0,$60,$e0,$e0,$e0,$e0,$e0,$e8,$60,$60,$70
	defb $78,$f0,$f0,$f0,$d8,$50,$50,$50,$58,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$50,$58,$50,$50,$50
	defb $50,$50,$50,$50,$50,$50,$50,$50,$5c,$50,$50,$50,$54,$40,$42,$40,$00,$02,$00,$00,$00,$00,$20,$20
	defb $20,$22,$22,$22,$22,$22,$20,$22,$2a,$20,$22,$22,$22,$20,$22,$22,$26,$22,$20,$22,$26,$22,$20,$22
	defb $22,$22,$a2,$b2,$b8,$b0,$b0,$b2,$b2,$b2,$b2,$32,$32,$b2,$b0,$b2,$b0,$b0,$32,$90,$90,$92,$52,$51
	defb $51,$51,$d1,$d1,$d9,$d1,$51,$51,$51,$51,$53,$d1,$d9,$51,$51,$d3,$d3,$51,$41,$c1,$c1,$c1,$c1,$c1
	defb $c9,$c1,$c1,$c1,$41,$41,$c1,$c1,$c9,$c1,$c1,$41,$c9,$c1,$c1,$61,$69,$e1,$e1,$e1,$61,$61,$61,$61
	defb $61,$61,$61,$61,$29,$21,$21,$21,$25,$31,$31,$31,$35,$31,$31,$31,$39,$b1,$b1,$31,$31,$31,$31,$31
	defb $31,$b1,$32,$30,$b0,$b0,$30,$30,$34,$30,$32,$32,$14,$10,$10,$10,$10,$10,$10,$10,$10,$90,$92,$12
	defb $10,$92,$82,$02,$00,$00,$00,$02,$8a,$02,$02,$02,$ce,$40,$40,$40,$40,$42,$40,$42,$4a,$c2,$c2,$42
	defb $40,$40,$40,$40,$48,$c2,$42,$42,$48,$40,$60,$60,$ea,$62,$62,$e2,$ea,$60,$70,$70,$70,$70,$f0,$f0
	defb $70,$70,$72,$70,$7a,$72,$70,$70,$f0,$f0,$70,$f0,$f0,$70,$70,$f0,$f2,$70,$f0,$b0,$3c,$30,$30,$30
	defb $34,$30,$30,$30,$30,$b0,$b0,$30,$b0,$90,$10,$00,$00,$00,$00,$80,$82,$02,$00,$00,$00,$00,$00,$00
	defb $00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	defb $00,$00,$00,$00,$00,$50,$50,$50,$58,$72,$70,$70,$70,$70,$70,$70,$70,$70,$70,$72,$7a,$72,$72,$70
	defb $f8,$f0,$f0,$f2,$7a,$70,$70,$70,$f0,$f0,$f0,$70,$70,$70,$72,$f2,$f0,$70,$70,$f2,$f2,$f0,$f0,$e0
	defb $e8,$e2,$60,$60,$e0,$e0,$e2,$e2,$ea,$c0,$c2,$c2,$c2,$42,$00,$82,$82,$82,$80,$82,$80,$80,$80,$80
	defb $80,$80,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$10,$10,$10,$10,$10,$10
	defb $18,$10,$10,$10,$12,$10,$10,$10,$10,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$70
	defb $70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60
	defb $68,$60,$60,$60,$60,$60,$60,$60,$68,$60,$60,$c0,$c8,$c0,$c0,$c0,$c0,$40,$40,$40,$40,$c0,$c0,$40
	defb $40,$42,$40,$c2,$c8,$c0,$40,$42,$c2,$c2,$10,$10,$98,$90,$92,$92,$12,$12,$10,$10,$10,$10,$10,$10
	defb $9a,$92,$90,$90,$98,$90,$90,$90,$12,$12,$92,$90,$b0,$b0,$30,$30,$38,$30,$30,$30,$38,$30,$30,$30
	defb $3a,$30,$32,$30,$30,$30,$20,$22,$20,$a0,$a0,$20,$28,$a0,$a2,$a2,$a0,$20,$20,$20,$20,$60,$60,$60
	defb $60,$60,$62,$60,$68,$e0,$e0,$e0,$e0,$e0,$60,$60,$60,$60,$e0,$e0,$40,$40,$40,$40,$40,$40,$40,$40
	defb $48,$40,$40,$40,$58,$50,$50,$50,$58,$50,$d0,$d0,$50,$50,$50,$50
	
	
musicData:
 defw sequence
 defb 1
 defw 2
 defb 0
 defb 0
 defw 1
 defb 128
 defb 0
 defw 2
 defb 128
 defb 0
 defw 1
 defb 0
 defb 0
 defw 0
 defb 2
 defb 1
 defw 2
 defb 0
 defb 0
 defw 1
 defb 8
 defb 0
 defw 0
 defb 8
sequence: defb $fd,0
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 133
 defb 20
 defb 145
 defb 20
 defb 133
 defb 20
 defb 145
 defb 20
 defb 135
 defb 20
 defb 147
 defb 20
 defb 135
 defb 20
 defb 147
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 137
 defb 20
 defb 149
 defb 20
 defb 133
 defb 20
 defb 145
 defb 20
 defb 133
 defb 20
 defb 145
 defb 20
 defb 135
 defb 20
 defb 147
 defb 20
 defb 135
 defb 20
 defb 147
 defb 16
 defb 118
 defb $fe
 defb 1
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 133
 defb 16
 defb 120
 defb 145
 defb 16
 defb 118
 defb 133
 defb 16
 defb 120
 defb 145
 defb 16
 defb 118
 defb 135
 defb 16
 defb 120
 defb 147
 defb 16
 defb 118
 defb 135
 defb 16
 defb 120
 defb 147
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 137
 defb 16
 defb 120
 defb 149
 defb 16
 defb 118
 defb 133
 defb 16
 defb 120
 defb 145
 defb 16
 defb 118
 defb 133
 defb 16
 defb 120
 defb 145
 defb 16
 defb 118
 defb 135
 defb 12
 defb 122
 defb $fe
 defb 1
 defb 122
 defb 147
 defb 16
 defb 123
 defb 135
 defb 16
 defb 124
 defb 147
 defb 16
 defb 118
 defb $fd,2
 defb 216
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 125
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 125
 defb 154
 defb 201
 defb 16
 defb 121
 defb 152
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 125
 defb $fe
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fd,0
 defb 156
 defb 199
 defb 16
 defb 121
 defb 154
 defb 211
 defb 16
 defb 125
 defb $fd,8
 defb 144
 defb 199
 defb 16
 defb 121
 defb 142
 defb 211
 defb 16
 defb 118
 defb $fd,4
 defb 228
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 125
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 125
 defb 166
 defb 201
 defb 16
 defb 121
 defb 164
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 125
 defb $fe
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fd,6
 defb 220
 defb 199
 defb 16
 defb 119
 defb $fd,8
 defb 144
 defb 211
 defb 16
 defb 125
 defb $fd,6
 defb 159
 defb 199
 defb 16
 defb 119
 defb $fd,8
 defb 147
 defb 211
 defb 16
 defb 118
 defb $fd,2
 defb 216
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 125
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 156
 defb 213
 defb 16
 defb 125
 defb 154
 defb 201
 defb 16
 defb 121
 defb 152
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 125
 defb $fe
 defb 197
 defb 16
 defb 121
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fd,0
 defb 156
 defb 199
 defb 16
 defb 121
 defb 154
 defb 211
 defb 16
 defb 125
 defb $fd,8
 defb 144
 defb 199
 defb 16
 defb 121
 defb 142
 defb 211
 defb 16
 defb 118
 defb $fd,4
 defb 228
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 125
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 201
 defb 16
 defb 121
 defb 168
 defb 213
 defb 16
 defb 125
 defb 166
 defb 201
 defb 16
 defb 121
 defb 164
 defb 213
 defb 16
 defb 118
 defb $fc
 defb 197
 defb 16
 defb 121
 defb $fd,14
 defb 220
 defb 209
 defb 16
 defb 125
 defb 154
 defb 197
 defb 16
 defb 121
 defb 152
 defb 209
 defb 12
 defb 119
 defb $fe
 defb 1
 defb 119
 defb $fd,12
 defb 208
 defb 211
 defb 16
 defb 120
 defb $fe
 defb 16
 defb 125
 defb 147
 defb 215
 defb 16
 defb 120
 defb $fe
 defb 16
 defb 118
 defb 152
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb 154
 defb 201
 defb 16
 defb 120
 defb 151
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb 147
 defb 199
 defb 16
 defb 120
 defb 151
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb 215
 defb 199
 defb 16
 defb 118
 defb $fe
 defb 211
 defb 16
 defb 118
 defb 149
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb 147
 defb 197
 defb 16
 defb 120
 defb 149
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb 152
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb 154
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb 152
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 12
 defb 119
 defb $fe
 defb 1
 defb 119
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 119
 defb $fe
 defb 211
 defb 12
 defb $fc
 defb 4
 defb 118
 defb $fd,10
 defb 215
 defb 201
 defb 4
 defb 152
 defb 12
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 119
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 119
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 119
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 201
 defb 16
 defb 120
 defb $fe
 defb 213
 defb 16
 defb 119
 defb 154
 defb 201
 defb 16
 defb 120
 defb 151
 defb 213
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb 144
 defb 199
 defb 4
 defb 147
 defb 12
 defb 120
 defb 151
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb 215
 defb 199
 defb 16
 defb 118
 defb $fe
 defb 211
 defb 16
 defb 118
 defb 149
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 119
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 119
 defb 147
 defb 197
 defb 16
 defb 120
 defb 149
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 119
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 118
 defb $fe
 defb 197
 defb 16
 defb 120
 defb $fe
 defb 209
 defb 16
 defb 119
 defb 151
 defb 197
 defb 4
 defb 152
 defb 12
 defb 118
 defb $fe
 defb 209
 defb 16
 defb 118
 defb 154
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb 152
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 119
 defb $fe
 defb 199
 defb 16
 defb 120
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fe
 defb 199
 defb 12
 defb 122
 defb $fe
 defb 1
 defb 122
 defb $fe
 defb 211
 defb 12
 defb 124
 defb $fe
 defb 1
 defb 123
 defb $fe
 defb 199
 defb 12
 defb 124
 defb $fe
 defb 1
 defb 124
 defb $fe
 defb 211
 defb 16
 defb 118
 defb $fd,0
 defb 137
 defb $fc
 defb $fe
 defb $fe
 defb $fe
 defb $fe
 defb $fe
 defb $fe
 defb $fe
 defb 117
 defb 39
 defb $fc
 defb 20
 defb $fc,$fc,$ff,117
 defb 0
