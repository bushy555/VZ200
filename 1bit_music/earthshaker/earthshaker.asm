; -------------------------------------
; Earthshaker
; --------------------------------------

#define defb .db
#define defw .dw
#define db  .db
#define dw  .dw
#define end .end
#define org .org
#define DEFB .db
#define DEFW .dw
#define DB  .db
#define DW  .dw
#define END .end
#define ORG .org
#define equ .equ
#define EQU .equ



	ORG	$8000

;Two channel beeper music engine from Earth Shaker game
;original code by Michael Batty, 1990
;reversed by Oleg Origin, 2012
;1tracker version by Shiru, 2013
; most of the code and song format has been changed
; sound generation loop and sound features are kept intact


	
begin
	ei
;;	call	$01c9		; VZ ROM CLS
;;	ld	hl, MSG1	; Print MENU
;;	call	$28a7		; VZ ROM Print string.
;;	ld	hl,musicData
;;	call	play
;;	ret
	
;############################################
ei
	call	$01c9		; VZ ROM CLS
	ld	hl, MSG1	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG2
	call	$28a7
;	ld	hl, POSCURSOR	; reposition cursor to show key input 
;	call	$28a7


scan:	call 	$2ef4		; VZ scan keyboard
	or 	a		; any key pressed?
	jr	z, scan		; back if not
				; 	Menu selection.  
	cp	49		; "1 - "
	jr	z, m1		; 	
	cp	50		; "2 - "
	jr	z, m2
;;	cp	51		; "3 - "
;;	jr	z, m3
;;	cp	52		; "4 - "
;;	jr	z, m4
;;	cp	53		; "5 - "
;;	jr	z, m5
;;	cp	54		; "6 - "
;;	jr	z, m6
;;	cp	55		; "7 - "
;;	jr	z, m7
;;	cp	56		; "8 - "
;;	jr	z, m8
	cp 	81		; "Q" - quit
	jr 	z, quit
	jr 	nz, begin ;scan	; back if not

quit: 	ei
	ld 	hl, MSGQUIT
	call 	$28a7			; print message. HL
	jp 	$1a19			; Jump to VZ basic


	

m1: 	
	ld 	hl, D1			; Pick whichever key stroke, to then display.
	ld 	de,musicData1		; Load HL = MUSIC DATA
	jp 	continue		; Continue on....
m2: 	ld 	hl, D2
	ld 	de,musicData2
	jp 	continue
;m3: 	ld 	hl, D3
;	ld 	de,musicData3
;	jp 	continue
;m4: 	ld 	hl, D4
;	ld 	de,musicData4
;	jp 	continue
;m5: 	ld 	hl, D5
;	ld 	de,musicData5
;	jp 	continue
;m6: 	ld 	hl, D6
;	ld 	de,musicData6
;	jp 	continue
;m7: 	ld 	hl, D7
;	ld 	de,musicData7
;	jp 	continue
;m8: 	ld 	hl, D8
;	ld 	de,musicData8
;	jp 	continue


continue:	push	de			; save de (music offset) 
		push	hl
		ld 	hl, PLAYING
		call 	$28a7
		pop	hl
		call 	$28a7			; print message. 
		pop 	hl			; restore musicData offset into HL
		call 	play
		jp	begin	


;#############################################


play	di

playLoop
	ld a,(hl)	;row length, $ff is end of the song
	cp $ff
	jr z,playStop

	inc hl
	ld e,(hl)	;ch1 note, bit 7 is drum 1
	inc hl
	ld c,(hl)	;ch2 note, bit 7 is drum 2
	inc hl
	push hl		;remember song pointer
	ld h,a
	xor a
	ld l,a
	ld d,a
	ld b,a
	push hl		;remember row length
	sla c
	rla
	sla e
	rla
	push de
	push bc

	or a
	jr z,noDrum
	ld de,3
	ld hl,523
	dec a
	jr z,playDrum
	ld de,5
	ld hl,262
playDrum
	call $600	;drums are simply ROM beep calls
	di
noDrum
	pop bc
	pop de

	ld hl,noteTable	;get first channel freq
	add hl,de
	ld   e,(hl)
	inc  hl
	ld   d,(hl)
	push de
	pop  ix
	dec  ix

	ld hl,noteTable	;get second channel freq
	add hl,bc
	ld   c,(hl)
	inc  hl
	ld   b,(hl)
	push bc
	pop  iy

	pop hl	;restore row length

playTone
	dec  de
	ld   a,d
	or   e
	jr   nz,playTone1
	xor  a
	and	33
	ld	(26624), a
	ld   a,32
	ld	(26624), a
	push ix
	pop  de
playTone1
	dec  bc
	ld   a,b
	or   c
	jr   nz,playTone2
	ld	a, 33
	ld	(26624), a
	xor  a
	and	33
	ld	(26624), a
	push iy
	pop  bc
playTone2
	dec  hl
	ld   a,h
	or   l
	jr   nz,playTone


	ld 	a, ($68DF)	; $68DF	Address for minus key.  Bit 2 = 0 when Minus Key is pressed.  =59d
	CPL			; %111011 --> invert --> %000100
	AND 4			; cmp to 4?
	jr	nz, exit2	; JP if not = 59 (minus key pressed)

	pop hl	;restore song pointer
	jr playLoop

playStop
	ld iy,$5c3a
	ei
	ret

exit2:	exx 			; Key pressed. Exchange regs
	ei
	jp begin


MSG1	db "EARTHSHAKER MUSICBOX.  BUSHY'19"
	db $0d,$0d, "PLEASE SELECT:  ", $0d
	db "1 EARTHSHAKER THEME    - MENU",$0d
	db "2 HEADBANGER           Q QUIT",$0d,00
MSG2	db "3                     ",$0d
	db "4                     ",$0d
	db "5                     ",$0d
        db "6                     ",$0d
	db $0d,$0d
	db ">",00



MSGQUIT db	08,08,"QUIT...",$0d,00
PLAYING db	08,08,"NOW PLAYING:",0

POSCURSOR db	09,00
D1 	db	"EARTHSHAKER",0		
D2 	db	"HEADBANGER ",0			
D3 	db	" ",0	
D4 	db	" ",0
D5 	db	" ",0
D6 	db	" ",0


noteTable
	dw $0400,$03C7,$0390,$035D,$032D,$02FF,$02D4,$02AB
	dw $0285,$0261,$023F,$021E,$0200,$01E3,$01C8,$01AF
	dw $0196,$0180,$016A,$0156,$0143,$0130,$011F,$010F
	dw $0100,$00F2,$00E4,$00D7,$00CB,$00C0,$00B5,$00AB
	dw $00A1,$0098,$0090,$0088,$0080,$0079,$0072,$006C
	dw $0066,$0060,$005B,$0055,$0051,$004C,$0048,$0044
	dw $0040,$003C,$0039,$0036,$0033,$0030,$002D,$002B
	dw $0028,$0026,$0024,$0022,$0020,$001E,$001D,$001B
	dw $0019,$0018,$0017,$0015,$0014,$0013,$0012,$0011
	dw $0010


;compiled music data
; ----------------------------
; SONG 1 : EARTHSHAKER THEME
; -----------------------------
musicData1
	db $3c,$18,$18
	db $28,$18,$1d
	db $14,$18,$1c
	db $28,$18,$1d
	db $14,$18,$21
	db $28,$16,$1f
	db $14,$16,$1d
	db $3c,$18,$1f
	db $28,$1d,$1d
	db $14,$18,$1c
	db $28,$18,$29
	db $14,$18,$21
	db $28,$16,$1f
	db $14,$16,$1d
	db $3c,$18,$18
	db $28,$18,$1d
	db $14,$18,$1c
	db $28,$18,$1d
	db $14,$18,$21
	db $28,$16,$1f
	db $14,$16,$1d
	db $f0,$18,$1f
	db $3c,$18,$18
	db $28,$18,$1d
	db $14,$18,$1c
	db $28,$18,$1d
	db $14,$18,$21
	db $28,$16,$1f
	db $14,$16,$1d
	db $3c,$18,$1f
	db $28,$1d,$1d
	db $14,$18,$1c
	db $28,$18,$29
	db $14,$18,$21
	db $28,$16,$1f
	db $14,$16,$1d
	db $3c,$18,$18
	db $28,$18,$1d
	db $14,$18,$1c
	db $28,$18,$1d
	db $14,$18,$21
	db $28,$16,$1f
	db $14,$16,$1d
	db $f0,$18,$1f
	db $28,$8c,$0c
	db $14,$18,$98
	db $28,$1a,$1a
	db $3c,$98,$1c
	db $14,$9a,$1f
	db $28,$18,$9f
	db $14,$17,$9c
	db $28,$95,$18
	db $14,$17,$9c
	db $28,$18,$18
	db $3c,$9a,$1f
	db $14,$97,$17
	db $28,$13,$93
	db $14,$13,$93
	db $28,$91,$18
	db $14,$18,$a1
	db $28,$18,$21
	db $3c,$9d,$21
	db $14,$98,$21
	db $28,$18,$98
	db $14,$18,$98
	db $28,$13,$9a
	db $14,$1a,$a3
	db $28,$1f,$a3
	db $14,$23,$a3
	db $28,$1f,$9f
	db $14,$1a,$a3
	db $28,$17,$97
	db $14,$1a,$a3
	db $28,$98,$1f
	db $14,$18,$9c
	db $28,$1a,$1f
	db $3c,$9c,$1c
	db $14,$9a,$1f
	db $28,$18,$9f
	db $14,$17,$9c
	db $28,$95,$18
	db $14,$17,$9c
	db $28,$18,$18
	db $3c,$9f,$1f
	db $14,$97,$17
	db $28,$13,$93
	db $14,$13,$93
	db $28,$91,$18
	db $14,$18,$a1
	db $28,$18,$21
	db $3c,$a1,$21
	db $14,$98,$21
	db $28,$18,$98
	db $14,$18,$98
	db $28,$93,$18
	db $14,$93,$17
	db $28,$13,$93
	db $14,$93,$17
	db $28,$9f,$1f
	db $14,$9a,$23
	db $28,$23,$a3
	db $14,$9a,$23
	db $28,$a4,$24
	db $14,$90,$10
	db $28,$1d,$98
	db $3c,$a4,$24
	db $14,$98,$1f
	db $28,$1a,$9f
	db $14,$1a,$9a
	db $28,$9f,$1f
	db $14,$9a,$1f
	db $28,$1d,$9d
	db $14,$91,$11
	db $28,$1d,$a1
	db $14,$21,$a1
	db $28,$1f,$a3
	db $14,$13,$93
	db $28,$a4,$2b
	db $14,$90,$10
	db $28,$18,$9d
	db $3c,$a4,$2b
	db $14,$9c,$1c
	db $28,$1a,$9f
	db $14,$a1,$21
	db $28,$9f,$1f
	db $14,$9a,$1f
	db $14,$1d,$9d
	db $14,$1c,$1c
	db $14,$9a,$1a
	db $78,$93,$18
	db $28,$9f,$24
	db $14,$90,$10
	db $28,$18,$9d
	db $3c,$9f,$24
	db $14,$98,$1f
	db $28,$1a,$9f
	db $14,$9a,$1a
	db $28,$9f,$1f
	db $14,$1a,$9f
	db $28,$1d,$9d
	db $14,$11,$91
	db $28,$1d,$a1
	db $14,$21,$a1
	db $28,$1f,$a3
	db $14,$13,$93
	db $28,$9f,$24
	db $14,$90,$10
	db $28,$18,$9d
	db $3c,$9f,$24
	db $14,$9c,$1c
	db $28,$1a,$9f
	db $14,$a1,$21
	db $28,$9f,$1f
	db $14,$9a,$1f
	db $14,$1d,$9d
	db $14,$1c,$1c
	db $14,$9a,$1a
	db $14,$1f,$98
	db $14,$1f,$98
	db $14,$1f,$98
	db $14,$1f,$98
	db $14,$1f,$98
	db $14,$1f,$98
	db $28,$8c,$0c
	db $14,$18,$98
	db $28,$1a,$1a
	db $3c,$98,$1c
	db $14,$9a,$1f
	db $28,$18,$9f
	db $14,$17,$9c
	db $28,$95,$18
	db $14,$17,$9c
	db $28,$18,$18
	db $3c,$9a,$1f
	db $14,$97,$17
	db $28,$13,$93
	db $14,$13,$93
	db $28,$91,$18
	db $14,$18,$a1
	db $28,$18,$21
	db $3c,$9d,$21
	db $14,$98,$21
	db $28,$18,$98
	db $14,$18,$98
	db $28,$13,$9a
	db $14,$1a,$a3
	db $28,$1f,$a3
	db $14,$23,$a3
	db $28,$1f,$9f
	db $14,$1a,$a3
	db $28,$17,$97
	db $14,$1a,$a3
	db $28,$98,$1f
	db $14,$18,$9c
	db $28,$1a,$1f
	db $3c,$9c,$1c
	db $14,$9a,$1f
	db $28,$18,$9f
	db $14,$17,$9c
	db $28,$95,$18
	db $14,$17,$9c
	db $28,$18,$18
	db $3c,$9f,$1f
	db $14,$97,$17
	db $28,$13,$93
	db $14,$13,$93
	db $28,$91,$18
	db $14,$18,$a1
	db $28,$18,$21
	db $3c,$a1,$21
	db $14,$98,$21
	db $28,$18,$98
	db $14,$18,$98
	db $28,$93,$18
	db $14,$93,$17
	db $28,$13,$93
	db $14,$93,$17
	db $28,$9f,$1f
	db $14,$9a,$23
	db $28,$23,$a3
	db $14,$9a,$23
	db $3c,$98,$18
	db $28,$18,$9d
	db $14,$98,$1c
	db $28,$98,$1d
	db $14,$18,$21
	db $28,$16,$9f
	db $14,$96,$1d
	db $3c,$98,$1f
	db $28,$1d,$9d
	db $14,$98,$1c
	db $28,$18,$a9
	db $14,$18,$a1
	db $28,$16,$9f
	db $14,$16,$9d
	db $3c,$98,$18
	db $28,$18,$9d
	db $14,$98,$1c
	db $28,$98,$1d
	db $14,$18,$a1
	db $28,$16,$9f
	db $14,$16,$9d
	db $f0,$18,$9f
	db $3c,$24,$a4
	db $28,$a4,$1d
	db $14,$1d,$a1
	db $28,$1f,$a4
	db $14,$24,$2b
	db $28,$a2,$1f
	db $14,$22,$9f
	db $3c,$24,$a4
	db $28,$98,$1d
	db $14,$1d,$a1
	db $28,$18,$98
	db $14,$1d,$24
	db $28,$22,$9f
	db $14,$22,$9d
	db $3c,$24,$a4
	db $28,$9d,$21
	db $14,$22,$a6
	db $28,$22,$a6
	db $14,$21,$a1
	db $28,$22,$9f
	db $14,$22,$9d
	db $f0,$24,$ab
	db $28,$8c,$0c
	db $14,$18,$98
	db $28,$1a,$1a
	db $3c,$98,$1c
	db $14,$9a,$1f
	db $28,$18,$9f
	db $14,$17,$9c
	db $28,$95,$18
	db $14,$17,$9c
	db $28,$18,$18
	db $3c,$9a,$1f
	db $14,$97,$17
	db $28,$13,$93
	db $14,$13,$93
	db $28,$91,$18
	db $14,$18,$a1
	db $28,$18,$21
	db $3c,$9d,$21
	db $14,$98,$21
	db $28,$18,$98
	db $14,$18,$98
	db $28,$13,$9a
	db $14,$1a,$a3
	db $28,$1f,$a3
	db $14,$23,$a3
	db $28,$1f,$9f
	db $14,$1a,$a3
	db $28,$17,$97
	db $14,$1a,$a3
	db $28,$98,$1f
	db $14,$18,$9c
	db $28,$1a,$1f
	db $3c,$9c,$1c
	db $14,$9a,$1f
	db $28,$18,$9f
	db $14,$17,$9c
	db $28,$95,$18
	db $14,$17,$9c
	db $28,$18,$18
	db $3c,$9f,$1f
	db $14,$97,$17
	db $28,$13,$93
	db $14,$13,$93
	db $28,$91,$18
	db $14,$18,$a1
	db $28,$18,$21
	db $3c,$a1,$21
	db $14,$98,$21
	db $28,$18,$98
	db $14,$18,$98
	db $28,$93,$18
	db $14,$93,$17
	db $28,$13,$93
	db $14,$93,$17
	db $28,$9f,$1f
	db $14,$9a,$23
	db $28,$23,$a3
	db $14,$9a,$23
	db $28,$a4,$24
	db $14,$18,$98
	db $28,$26,$26
	db $3c,$a4,$2b
	db $14,$9f,$1f
	db $28,$18,$9f
	db $14,$1c,$9c
	db $28,$a1,$21
	db $14,$17,$97
	db $28,$1c,$1c
	db $8c,$15,$1c
	db $28,$9d,$1d
	db $14,$18,$a1
	db $28,$1d,$1d
	db $3c,$a1,$21
	db $14,$98,$21
	db $3c,$98,$18
	db $28,$93,$1a
	db $14,$1a,$9a
	db $28,$1f,$a3
	db $14,$23,$a3
	db $78,$1a,$a3
	db $f0,$98,$1f
	db $ff

; ------------------------------------
; SONG 2: HEADBANGER. Grabbed from 1-Tracker.
; -------------------------------------


musicData2

	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1f,$1a
	db $14,$1f,$1a
	db $14,$1e,$19
	db $14,$1e,$19
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1e,$12
	db $14,$12,$12
	db $14,$1f,$13
	db $14,$13,$13
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1f,$1a
	db $14,$1f,$1a
	db $14,$1e,$19
	db $14,$1e,$19
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$12,$12
	db $14,$12,$12
	db $14,$12,$12
	db $14,$12,$12
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$9f,$1a
	db $14,$1f,$1a
	db $14,$1e,$19
	db $14,$1e,$19
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1e,$92
	db $14,$92,$12
	db $14,$1f,$93
	db $14,$93,$13
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$9f,$1a
	db $14,$1f,$1a
	db $14,$1e,$19
	db $14,$1e,$19
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1a,$15
	db $14,$9c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$1c,$17
	db $14,$15,$92
	db $14,$15,$12
	db $14,$15,$12
	db $14,$15,$12
	db $14,$9c,$10
	db $14,$1c,$10
	db $14,$1c,$1c
	db $14,$9a,$10
	db $14,$1c,$90
	db $14,$1c,$10
	db $14,$9c,$1f
	db $14,$1a,$1e
	db $14,$9c,$10
	db $14,$1c,$10
	db $14,$1c,$1c
	db $14,$9a,$10
	db $14,$1c,$90
	db $14,$1c,$10
	db $14,$9c,$17
	db $14,$1a,$15
	db $14,$98,$0c
	db $14,$18,$0c
	db $14,$18,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$18,$1e
	db $14,$97,$1c
	db $14,$18,$1a
	db $14,$9a,$1e
	db $14,$1a,$1e
	db $14,$1a,$1f
	db $14,$9a,$1f
	db $14,$1a,$9e
	db $14,$1a,$1e
	db $14,$18,$98
	db $14,$1a,$9a
	db $14,$9c,$10
	db $14,$1c,$10
	db $14,$1c,$1c
	db $14,$9a,$10
	db $14,$1c,$90
	db $14,$1c,$10
	db $14,$9c,$1f
	db $14,$1a,$1e
	db $14,$9c,$10
	db $14,$1c,$10
	db $14,$1c,$1c
	db $14,$9a,$10
	db $14,$1c,$90
	db $14,$1c,$10
	db $14,$9c,$17
	db $14,$1a,$15
	db $14,$98,$0c
	db $14,$18,$0c
	db $14,$18,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$18,$1e
	db $14,$97,$1c
	db $14,$18,$1a
	db $14,$9a,$1e
	db $14,$1a,$1e
	db $14,$1a,$1f
	db $14,$9a,$1f
	db $14,$1a,$9e
	db $14,$1a,$1e
	db $14,$18,$98
	db $14,$1a,$9a
	db $14,$98,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$98,$1f
	db $14,$18,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$18,$1f
	db $14,$9a,$1e
	db $14,$9a,$0e
	db $14,$1a,$9e
	db $14,$9a,$1e
	db $14,$1a,$0e
	db $14,$9a,$0e
	db $14,$1a,$9c
	db $14,$1a,$1c
	db $14,$9c,$1f
	db $14,$9c,$1e
	db $14,$1c,$9a
	db $14,$9c,$1f
	db $14,$1c,$1e
	db $14,$9c,$1a
	db $14,$1a,$9f
	db $14,$1a,$1e
	db $14,$9c,$1f
	db $14,$9c,$1e
	db $14,$1c,$9a
	db $14,$9c,$1f
	db $14,$1c,$1e
	db $14,$9c,$1a
	db $14,$1a,$9f
	db $14,$1a,$9e
	db $14,$98,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$98,$1f
	db $14,$18,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$18,$1f
	db $14,$9a,$1e
	db $14,$9a,$0e
	db $14,$1a,$9f
	db $14,$9a,$1f
	db $14,$1a,$0e
	db $14,$9a,$0e
	db $14,$1a,$9e
	db $14,$1a,$1e
	db $14,$9c,$1f
	db $14,$9c,$1e
	db $14,$1c,$9a
	db $14,$9c,$1f
	db $14,$1c,$1e
	db $14,$9c,$1a
	db $14,$1a,$9f
	db $14,$1a,$1e
	db $14,$9c,$1a
	db $14,$9c,$1f
	db $14,$1c,$9e
	db $14,$9c,$1a
	db $28,$1c,$9f
	db $28,$1c,$1f
	db $28,$1c,$1f
	db $28,$1c,$1f
	db $14,$90,$17
	db $14,$10,$17
	db $14,$1c,$17
	db $14,$10,$17
	db $14,$10,$23
	db $14,$10,$23
	db $14,$1c,$17
	db $14,$10,$17
	db $14,$10,$21
	db $14,$10,$21
	db $14,$1c,$23
	db $14,$10,$23
	db $14,$10,$17
	db $14,$10,$17
	db $14,$1c,$17
	db $14,$10,$17
	db $14,$8e,$1e
	db $14,$0e,$1e
	db $14,$1a,$1e
	db $14,$0e,$1e
	db $14,$0e,$2a
	db $14,$0e,$2a
	db $14,$1a,$1e
	db $14,$0e,$1e
	db $14,$0e,$28
	db $14,$0e,$28
	db $14,$1a,$2a
	db $14,$0e,$2a
	db $14,$0e,$1e
	db $14,$0e,$1e
	db $14,$9a,$1e
	db $14,$0e,$1e
	db $14,$8c,$1c
	db $14,$0c,$1c
	db $14,$18,$1c
	db $14,$0c,$1c
	db $14,$0c,$28
	db $14,$0c,$28
	db $14,$18,$1c
	db $14,$0c,$1c
	db $14,$0c,$2b
	db $14,$0c,$2b
	db $14,$18,$28
	db $14,$0c,$28
	db $14,$0c,$1c
	db $14,$0c,$1c
	db $14,$18,$1c
	db $14,$0c,$1c
	db $14,$92,$17
	db $14,$12,$17
	db $14,$1e,$17
	db $14,$12,$17
	db $14,$12,$23
	db $14,$12,$23
	db $14,$1e,$17
	db $14,$12,$17
	db $14,$92,$21
	db $14,$12,$21
	db $14,$9e,$23
	db $14,$12,$23
	db $14,$12,$ad
	db $14,$12,$2d
	db $14,$9e,$2f
	db $14,$12,$2f
	db $14,$90,$17
	db $14,$10,$17
	db $14,$1c,$97
	db $14,$9c,$17
	db $14,$10,$23
	db $14,$90,$23
	db $14,$1c,$97
	db $14,$10,$17
	db $14,$90,$21
	db $14,$10,$21
	db $14,$1c,$a3
	db $14,$9c,$23
	db $14,$10,$17
	db $14,$90,$17
	db $14,$1c,$97
	db $14,$9c,$17
	db $14,$8e,$1e
	db $14,$0e,$1e
	db $14,$1a,$9e
	db $14,$9a,$1e
	db $14,$0e,$2a
	db $14,$8e,$2a
	db $14,$1a,$9e
	db $14,$0e,$9e
	db $14,$8e,$28
	db $14,$0e,$28
	db $14,$1a,$aa
	db $14,$9a,$2a
	db $14,$0e,$9e
	db $14,$0e,$9e
	db $14,$1a,$9e
	db $14,$1a,$9e
	db $14,$8c,$1c
	db $14,$0c,$1c
	db $14,$18,$9c
	db $14,$98,$1c
	db $14,$0c,$28
	db $14,$8c,$28
	db $14,$18,$9c
	db $14,$0c,$1c
	db $14,$8c,$2b
	db $14,$0c,$2b
	db $14,$18,$a8
	db $14,$98,$28
	db $14,$0c,$1c
	db $14,$8c,$1c
	db $14,$18,$9c
	db $14,$98,$1c
	db $14,$92,$17
	db $14,$12,$17
	db $14,$1e,$97
	db $14,$9e,$17
	db $14,$12,$23
	db $14,$92,$23
	db $14,$1e,$97
	db $14,$12,$17
	db $14,$92,$21
	db $14,$12,$21
	db $14,$1e,$23
	db $14,$1e,$23
	db $14,$12,$2d
	db $14,$12,$2d
	db $14,$1e,$2f
	db $14,$1e,$2f
	db $14,$98,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$98,$1f
	db $14,$18,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$18,$1f
	db $14,$9a,$1e
	db $14,$9a,$0e
	db $14,$1a,$9e
	db $14,$9a,$1e
	db $14,$1a,$0e
	db $14,$9a,$0e
	db $14,$1a,$9c
	db $14,$1a,$1c
	db $14,$9c,$1f
	db $14,$9c,$1e
	db $14,$1c,$9a
	db $14,$9c,$1f
	db $14,$1c,$1e
	db $14,$9c,$1a
	db $14,$1a,$9f
	db $14,$1a,$1e
	db $14,$9c,$1f
	db $14,$9c,$1e
	db $14,$1c,$9a
	db $14,$9c,$1f
	db $14,$1c,$1e
	db $14,$9c,$1a
	db $14,$1a,$9f
	db $14,$1a,$9e
	db $14,$98,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$98,$1f
	db $14,$18,$0c
	db $14,$98,$0c
	db $14,$18,$9f
	db $14,$18,$1f
	db $14,$9a,$1e
	db $14,$9a,$0e
	db $14,$1a,$9e
	db $14,$9a,$1e
	db $14,$1a,$0e
	db $14,$9a,$0e
	db $14,$1a,$9c
	db $14,$1a,$1c
	db $14,$a8,$1f
	db $14,$a8,$1e
	db $14,$26,$9a
	db $14,$a8,$1f
	db $14,$a8,$1e
	db $14,$a6,$1a
	db $14,$28,$9f
	db $14,$a8,$1e
	db $14,$2b,$9f
	db $14,$aa,$1e
	db $14,$26,$9a
	db $14,$ab,$1f
	db $14,$2a,$9e
	db $14,$26,$9a
	db $14,$2b,$9f
	db $14,$2a,$9e
	db $14,$a4,$0c
	db $14,$a4,$0c
	db $14,$24,$9f
	db $14,$a4,$1f
	db $14,$24,$0c
	db $14,$a4,$0c
	db $14,$24,$9f
	db $14,$24,$1f
	db $14,$a6,$1e
	db $14,$a6,$0e
	db $14,$26,$9e
	db $14,$a6,$1e
	db $14,$1a,$0e
	db $14,$9a,$0e
	db $14,$26,$9c
	db $14,$26,$1c
	db $14,$1f,$9f
	db $14,$1c,$9e
	db $14,$9a,$1a
	db $14,$9c,$1f
	db $14,$1e,$9e
	db $14,$1c,$9a
	db $14,$9f,$1f
	db $14,$9a,$1e
	db $14,$1f,$9f
	db $14,$9c,$1e
	db $14,$1a,$9a
	db $14,$9c,$1f
	db $14,$1e,$9e
	db $14,$1c,$9a
	db $14,$9f,$1f
	db $14,$9a,$1e
	db $14,$a4,$0c
	db $14,$a4,$0c
	db $14,$24,$9f
	db $14,$a4,$1f
	db $14,$24,$0c
	db $14,$a4,$0c
	db $14,$24,$9f
	db $14,$24,$1f
	db $14,$a6,$1e
	db $14,$a6,$0e
	db $14,$26,$9f
	db $14,$a6,$1f
	db $14,$1a,$0e
	db $14,$9a,$0e
	db $14,$26,$9e
	db $14,$26,$1e
	db $14,$2b,$9f
	db $14,$9e,$1e
	db $14,$26,$9a
	db $14,$9f,$2b
	db $14,$1e,$b6
	db $14,$9a,$32
	db $14,$2b,$9f
	db $14,$9e,$1e
	db $14,$26,$9a
	db $14,$1f,$ab
	db $14,$9e,$36
	db $14,$9a,$32
	db $05,$1c,$9f
	db $05,$1c,$9f
	db $05,$1c,$9f
	db $05,$1c,$9f
	db $0a,$1c,$1f
	db $0a,$1c,$1f
	db $0a,$1c,$1f
	db $0a,$1c,$1f
	db $14,$1c,$1f
	db $14,$1c,$1f
	db $14,$1c,$1f
	db $14,$1c,$1f
	db $28,$1c,$1f
	db $28,$1c,$1f
	db $28,$1c,$1f
	db $ff

end
