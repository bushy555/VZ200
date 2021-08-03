; ZX10 Engine for the VZ.         20/April/2019.  Bushy.
;
;
;4-channel music generator ZX-10
;Original code JDeak (c)1989 Bytepack Bratislava
;Modified 1tracker version by Shiru 04'12
;
; MUSIC BOX - 4 channel, for the VZ.   Bushy. March 2019.
;    	- ZX-10 Theme
; 	- WARPZONE.    Was incorrectly named: Earthshaker.
;       - Intro Theme
; 	- Doom Level
; 	- GALAXY
;
; Assemble:


; IF USING TASM, UNCOMMENT THE FOLLOWING:
; IF USING PASMO, LEAVE THE FOLLOWING COMMENTED OUT
;#define defb .db
;#define defw .dw
;#define db  .db
;#define dw  .dw
;#define end .end
;#define org .org
;#define DEFB .db
;#define DEFW .dw
;#define DB  .db
;#define DW  .dw
;#define END .end
;#define ORG .org
;#define equ .equ
;#define EQU .equ


	ORG	$8000


start:	xor	a
	ld	(26624),a		; MODE (0)
	call	$01c9		; CLS
	ld	hl, MSG1	; Print MENU
	call	$28a7
	ld	hl, MSG2
	call	$28a7
	ld	hl, MSG3
	call	$28a7

	ld	hl, MSG4
	call	$28a7
;	ld	hl, MSG5
;	call	$28a7

	ld	hl, POSCURSOR	; reposition cursor to show key input 
	call	$28a7
scan:	call 	$2ef4		; scan keyboard
	or 	a		; any key pressed?
	jr	z, scan		; back if not
	cp	49		; "1"	Menu selection.  
	jr	z, m1		; 	GO here for "1". Then displays "1", and selects Music 1 DATA
	cp	50		; "2"
	jr	z, m2
	cp	51		; "3"
	jr	z, m3
	cp	52		; "4"
	jr	z, m4
	cp	53		; "5"
	jr	z, m5
;	cp	54		; "6"
;	jr	z, m6
;	cp	55		; "7"
;	jr	z, m7
;	cp	56		; "8"
;	jr	z, m8
;	cp	57		; "-" - Menu
;	jr	z, m9

	cp	81		; "Q" - quit
	jr	z, exit2
	jr	nz, start	; back if not
exit2:	jp	exit


m1:	ld	hl, D1			; Pick whichever key stroke, to then display.
	ld 	de,musicData1		; Load HL = MUSIC DATA
	jp	continue		; Continue on....
m2:	ld	hl, D2
	ld 	de,musicData2
	jp	continue
m3:	ld	hl, D3
	ld 	de,musicData3
	jp	continue
m4:	ld	hl, D4
	ld 	de,musicData4
	jp	continue
m5:	ld	hl, D5
	ld 	de,musicData5
	jp	continue
m6:	ld	hl, D6
;	ld 	de,musicData6
	jp	scan
m7:	ld	hl, D7
;	ld 	de,musicData7
	jp	scan
m8:	ld	hl, D8
;	ld 	de,musicData8
	jp	scan
m9:	ld	hl, D9
;	ld 	de,musicData9
	jp	scan

continue:
	push	de
	call	$28a7			; display message
	pop	hl

begin:	call 	play
exit:					; Exchange all registers back.
	ei				; Enable interrupts
	jp	$1a19			; Jump to basic
	ret				

play:
	di
	ld 	a,(hl)
	inc 	hl
	ld 	(speed+1),a
	dec 	a
	ld 	(speedCnt),a
	xor 	a
	ld 	e,(hl)
	inc 	hl
	ld 	d,(hl)
	inc 	hl
	ld 	(ch1order),de
	ld 	(de),a
	ld 	(sc1+3),a
	ld 	e,(hl)
	inc 	hl
	ld 	d,(hl)
	inc 	hl
	ld 	(ch2order),de
	ld 	(de),a
	ld 	(sc2+3),a
	ld 	e,(hl)
	inc 	hl
	ld 	d,(hl)
	inc 	hl
	ld 	(ch3order),de
	ld 	(de),a
	ld 	(sc3+3),a
	ld 	e,(hl)
	inc 	hl
	ld 	d,(hl)
	ld 	(ch4order),de
	ld 	(de),a
	ld 	(sc4+3),a
	ld 	hl,adst
	ld 	de,sx
	ld 	bc,$0400
init0:	ld 	(hl),c
	inc 	hl
	ld 	(hl),e
	inc 	hl
	ld 	(hl),d
	inc 	hl
	djnz 	init0

playRow:ld   	ix,sc1
	ld   	hl,adst
	ld   	de,8
	ld   	b,4
decay0:	ld   	a,(hl)
	or   	a
	jr   	z,decay1
	dec  	(hl)
	sla  	(ix+3)
	set  	4,(ix+3)
decay1:	add 	ix,de
	inc  	hl
	inc  	hl
	inc  	hl
	djnz 	decay0
	ld 	a,(speedCnt)
	inc 	a
speed:	cp 	0
	jr 	nz,noNextRow4
	ld   	ix,sc1
	ld   	hl,adst
	ld   	b,4
nextRow0:
	push 	hl
	inc  	hl
	ld   	e,(hl)
	inc  	hl
	ld   	d,(hl)
	ld   	a,(de)
	inc  	de
	ld   	(hl),d
	dec  	hl
	ld   	(hl),e
	cp   	$e0
	jp 	nz,noNextOrder
	ld   	de,12
	add  	hl,de
	ld   	c,(hl)
	inc  	hl
	ld   	a,(hl)
	or 	a
	sbc 	hl,de
	push 	hl
	ld 	l,c
	ld 	h,a
	ld   	a,(hl)
	inc  	hl
	cp   	(hl)
	dec  	hl
	jr   	nz,porder1
	xor  	a			;loop channel
	ld   	(hl),a
	jr   	porder2
	pop 	hl			;exit at end of the song
	pop 	hl
	jp 	keyPressed
noNextRow4:
	jp 	noNextRow
porder1:inc  	(hl)
porder2:inc  	a
	ex   	de,hl
	ld   	l,a
	ld   	h,0
	add  	hl,hl
	add  	hl,de
	ld   	e,(hl)
	inc  	hl
	ld   	d,(hl)
	pop  	hl
	ld   	a,(de)
	inc  	de
	ld   	(hl),d
	dec  	hl
	ld   	(hl),e
noNextOrder:
	ld   	c,a
	and  	31
	cp 	2
	jr 	nc,nextRow2
	or 	a
	jr 	nz,nextRow1
	pop 	hl
	jr 	nextRow4
nextRow1:
	set  	4,(ix+2)
	jr 	nextRow3
nextRow2:
	res  	4,(ix+2)
nextRow3:
	ld   	e,a
	ld   	d,0
	ld   	hl,frq			;note
	add  	hl,de
	ld   	a,(hl)
	ld   	(ix+1),a
	ld   	a,c			;duration
	rlca
	rlca
	rlca
	rlca
	and  	14
	inc  	a
	pop  	hl
	ld   	(hl),a
	ld   	(ix+3),$1f
nextRow4:
	ld   	de,8
	add  	ix,de
	inc  	hl
	inc  	hl
	inc  	hl
	djnz 	nextRow0

	xor 	a
noNextRow:
	ld 	(speedCnt),a

	xor 	a
; ----------------------------------	Original code
; 
;	ld 	a,%10111111			;+ new keyhandler
;	out 	(1),a
;	in 	a,(1)				;read keyboard
;	cpl
;	bit 	6,a
;	jp   	nz,keyPressed
; ----------------------------------

	call 	$2ef4		; scan keyboard
;	or 	a		; any key pressed?
;	jr	z, no_key	; Not pressed, continue on then...

	cp	45		; Key "-".   'Menu' menu selection.  
	jr	nz, no_key	; Not pressed, continue on then...
	exx			; Key pressed. Exchange regs
	ei
	jp	start		; Jp Start to start over.
	
no_key:	ld   	hl,256
sc:	exx
sc0:	dec  	c
	jp   	nz,s1
sc1:	ld   	c,0
	ld   	l,0
l1:	dec  	b
	jp   	nz,s2
sc2:	ld   	b,0
	ld   	l,0
l2:	dec  	e
	jp   	nz,s3
sc3:	ld   	e,0
	ld   	l,0
l3:	dec  	d
	jp   	nz,s4
sc4:	ld   	d,0
	ld   	l,0
l4:	ld   	a,l				;sound loop
;	and 	$10
	and 	33
	sla  	l
	push 	af
	bit 	4,a
	jr 	z,$+$04
	ld	a, 32
toggle1:
	xor	33
	and 	33
;	or	8
	ld 	(26624), a
	ld 	(26624), a
	ld 	(26624), a
	ld 	(26624), a
;	ld 	(26624), a
	pop 	af
	exx
	dec  	hl
	ld   	a,h
	or   	l
	exx
	jp   	nz,sc0

	push 	af
	bit 	4,a
	jr 	z,$+$04
	ld	a, 32

toggle2:
	xor	33
	and	33
; 	or 	8
	ld 	(26624), a
	ld 	(26624), a
	ld 	(26624), a
	ld 	(26624), a
;	ld 	(26624), a
	pop 	af

	exx
	jp   playRow

s1:	nop
	jp   l1
s2:	nop
	jp   l2
s3:	nop
	jp   l3
s4:	nop
	jp   l4


keyPressed:
	exx
	ei
	ret



MSG1	db	"ZX-10 4-CH TUNE PLAYER. BUSHY", $0d, $0d
	db	"PLEASE SELECT:"               , $0d, $00
MSG2	db	" 1 ZX-10 THEME"              , $0d
	db	" 2 WARPZONE"                 , $0d
	db	" 3 ZX-10 INTRO"              , $0d
	db	" 4 DOOM LEVEL"               , $0d
	db	" 5 GALAXY"                   , $0d
	db	" 6   "                       , $0d, $00
MSG3	db	" 7                - MENU"    , $0d
	db	" 8                Q QUIT"    , $0d
	db				         $0d, $00
MSG4	db	">"                          , $0d, $00


POSCURSOR db	27,09,00
D1	db	" 1 ",$00
D2	db	" 2 ",$00
D3	db	" 3 ",$00
D4	db	" 4 ",$00
D5	db	" 5 ",$00
D6	db	" 6 ",$00
D7	db	" 7 ",$00
D8	db	" 8 ",$00
D9	db	" 9 ",$00


frq:	db   0,255,241,227,214,202,191,180
	db 170,161,152,143,135,127,120,114
	db 107,101, 95, 90, 85, 80, 76, 71
	db  67, 63, 60, 57, 53, 50, 47, 45

sx:	db   $e0

adst:	db   0
	dw   0
	db   0
	dw   0
	db   0
	dw   0
	db   0
	dw   0
	db   0
ch1order:
	dw   0
	db   0
ch2order:
	dw   0
	db   0
ch3order:
	dw   0
	db   0
ch4order:
	dw   0

speedCnt:
	db 	0
toggleg2:
	db	0

; ===========================
;    ZX-10 THEME MUSIC DATA
; ===========================

musicData1
	db $0a
	dw md1order0
	dw md1order1
	dw md1order2
	dw md1order3

md1order0
	dw $2c00
	dw md1pattern0
	dw md1pattern1
	dw md1pattern2
	dw md1pattern3
	dw md1pattern4
	dw md1pattern5
	dw md1pattern6
	dw md1pattern7
	dw md1pattern8
	dw md1pattern9
	dw md1pattern10
	dw md1pattern11
	dw md1pattern12
	dw md1pattern13
	dw md1pattern14
	dw md1pattern15
	dw md1pattern16
	dw md1pattern17
	dw md1pattern18
	dw md1pattern19
	dw md1pattern20
	dw md1pattern21
	dw md1pattern22
	dw md1pattern23
	dw md1pattern24
	dw md1pattern25
	dw md1pattern26
	dw md1pattern27
	dw md1pattern28
	dw md1pattern29
	dw md1pattern30
	dw md1pattern31
	dw md1pattern32
	dw md1pattern33
	dw md1pattern34
	dw md1pattern35
	dw md1pattern36
	dw md1pattern37
	dw md1pattern38
	dw md1pattern39
	dw md1pattern40
	dw md1pattern41
	dw md1pattern42
	dw md1pattern43
md1order1
	dw $2c00
	dw md1pattern44
	dw md1pattern45
	dw md1pattern46
	dw md1pattern47
	dw md1pattern48
	dw md1pattern49
	dw md1pattern50
	dw md1pattern51
	dw md1pattern52
	dw md1pattern53
	dw md1pattern54
	dw md1pattern55
	dw md1pattern56
	dw md1pattern57
	dw md1pattern58
	dw md1pattern59
	dw md1pattern60
	dw md1pattern61
	dw md1pattern62
	dw md1pattern63
	dw md1pattern64
	dw md1pattern65
	dw md1pattern66
	dw md1pattern67
	dw md1pattern68
	dw md1pattern69
	dw md1pattern70
	dw md1pattern71
	dw md1pattern72
	dw md1pattern73
	dw md1pattern74
	dw md1pattern75
	dw md1pattern76
	dw md1pattern77
	dw md1pattern54
	dw md1pattern78
	dw md1pattern79
	dw md1pattern80
	dw md1pattern81
	dw md1pattern82
	dw md1pattern83
	dw md1pattern84
	dw md1pattern85
	dw md1pattern86
md1order2
	dw $2c00
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
md1order3
	dw $2c00
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87
	dw md1pattern87

md1pattern0	db $8f,$8f,$8f,$8f,$8f,$8d,$8d,$8f,$e0
md1pattern1	db $94,$8f,$8f,$8f,$8d,$8d,$8f,$8f,$e0
md1pattern2	db $8f,$8f,$8f,$8d,$8d,$8f,$8f,$8f,$e0
md1pattern3	db $8f,$8f,$8f,$8d,$8d,$8f,$94,$8f,$e0
md1pattern4	db $8f,$8f,$8d,$8d,$8f,$8f,$8f,$8f,$e0
md1pattern5	db $8f,$8d,$8d,$8f,$83,$8f,$91,$8f,$e0
md1pattern6	db $91,$8f,$8e,$8c,$8e,$8f,$91,$8e,$e0
md1pattern7	db $8a,$8a,$88,$8f,$8f,$94,$8f,$8f,$e0
md1pattern8	db $8f,$8a,$91,$96,$9a,$96,$91,$8e,$e0
md1pattern9	db $91,$8f,$8f,$91,$93,$91,$8f,$8e,$e0
md1pattern10	db $8c,$8e,$8f,$96,$8e,$8a,$8a,$88,$e0
md1pattern11	db $8f,$8f,$98,$8f,$8f,$8f,$8a,$8a,$e0
md1pattern12	db $8a,$8a,$96,$91,$9a,$91,$9b,$87,$e0
md1pattern13	db $94,$9b,$8f,$91,$91,$96,$91,$94,$e0
md1pattern14	db $88,$94,$98,$96,$8a,$9b,$87,$8f,$e0
md1pattern15	db $9b,$93,$91,$98,$96,$91,$94,$93,$e0
md1pattern16	db $91,$8a,$96,$87,$8f,$96,$8f,$91,$e0
md1pattern17	db $91,$96,$91,$94,$88,$94,$98,$96,$e0
md1pattern18	db $8a,$96,$87,$8f,$96,$93,$91,$98,$e0
md1pattern19	db $96,$91,$94,$93,$91,$96,$96,$96,$e0
md1pattern20	db $96,$96,$96,$83,$8f,$91,$8f,$91,$e0
md1pattern21	db $8f,$8e,$8c,$8e,$8f,$91,$8e,$8a,$e0
md1pattern22	db $8a,$88,$8f,$8f,$94,$8f,$8f,$8f,$e0
md1pattern23	db $8a,$91,$96,$9a,$96,$91,$8e,$91,$e0
md1pattern24	db $8f,$8f,$91,$93,$91,$8f,$8e,$8c,$e0
md1pattern25	db $8e,$8f,$96,$8e,$8a,$8a,$88,$8f,$e0
md1pattern26	db $8f,$98,$8f,$8f,$8f,$8a,$8a,$8a,$e0
md1pattern27	db $8a,$96,$91,$9a,$91,$8f,$8f,$8f,$e0
md1pattern28	db $8f,$8f,$8d,$8d,$8f,$94,$8f,$8f,$e0
md1pattern29	db $8f,$8d,$8d,$8f,$8f,$8f,$8f,$8f,$e0
md1pattern30	db $8d,$8d,$8f,$9b,$9b,$94,$96,$9b,$e0
md1pattern31	db $99,$99,$9b,$8f,$94,$8f,$94,$99,$e0
md1pattern32	db $99,$9b,$94,$99,$99,$98,$99,$99,$e0
md1pattern33	db $9b,$83,$8f,$91,$8f,$91,$8f,$8e,$e0
md1pattern34	db $8c,$8e,$8f,$91,$8e,$8a,$8a,$88,$e0
md1pattern35	db $8f,$8f,$94,$8f,$8f,$8f,$8a,$91,$e0
md1pattern36	db $96,$9a,$96,$91,$8e,$91,$8f,$8f,$e0
md1pattern37	db $91,$93,$91,$8f,$8e,$8c,$8e,$8f,$e0
md1pattern38	db $96,$8e,$8a,$8a,$88,$8f,$8f,$98,$e0
md1pattern39	db $8f,$8f,$8f,$8a,$8a,$8a,$8a,$96,$e0
md1pattern40	db $91,$9a,$91,$9b,$8f,$9d,$9b,$96,$e0
md1pattern41	db $8f,$93,$98,$8e,$93,$8c,$94,$8f,$e0
md1pattern42	db $94,$98,$8f,$8f,$8a,$91,$96,$9a,$e0
md1pattern43	db $91,$8f,$00,$00,$00,$00,$00,$00,$e0
md1pattern44	db $2f,$34,$33,$34,$38,$36,$34,$36,$e0
md1pattern45	db $34,$33,$3f,$38,$36,$34,$2f,$34,$e0
md1pattern46	db $33,$34,$38,$36,$34,$36,$2f,$34,$e0
md1pattern47	db $33,$34,$38,$36,$34,$36,$34,$33,$e0
md1pattern48	db $3f,$38,$36,$34,$2f,$34,$33,$34,$e0
md1pattern49	db $38,$36,$34,$36,$23,$2f,$31,$33,$e0
md1pattern50	db $36,$36,$33,$2f,$33,$2f,$36,$2e,$e0
md1pattern51	db $2a,$2a,$2f,$38,$38,$38,$38,$2f,$e0
md1pattern52	db $2f,$31,$3a,$3a,$3a,$36,$3a,$2e,$e0
md1pattern53	db $3a,$36,$33,$36,$33,$36,$36,$33,$e0
md1pattern54	db $2f,$33,$2f,$36,$2e,$2a,$2a,$2f,$e0
md1pattern55	db $38,$38,$38,$38,$2f,$2f,$2f,$2e,$e0
md1pattern56	db $2a,$2e,$36,$3a,$3a,$3a,$3b,$27,$e0
md1pattern57	db $2f,$3b,$36,$36,$31,$36,$36,$34,$e0
md1pattern58	db $28,$38,$38,$3a,$2a,$3f,$27,$34,$e0
md1pattern59	db $3f,$33,$36,$38,$36,$36,$34,$33,$e0
md1pattern60	db $31,$2f,$3b,$27,$34,$3b,$36,$36,$e0
md1pattern61	db $31,$36,$36,$34,$28,$38,$38,$3a,$e0
md1pattern62	db $2a,$3b,$27,$34,$3b,$33,$36,$38,$e0
md1pattern63	db $36,$36,$34,$33,$31,$2f,$2f,$2f,$e0
md1pattern64	db $2f,$2f,$2f,$23,$2f,$31,$33,$36,$e0
md1pattern65	db $36,$33,$2f,$33,$2f,$36,$2e,$2a,$e0
md1pattern66	db $2a,$2f,$38,$38,$38,$38,$2f,$2f,$e0
md1pattern67	db $31,$3a,$3a,$3a,$36,$3a,$2e,$3a,$e0
md1pattern68	db $36,$33,$36,$33,$36,$36,$33,$2f,$e0
md1pattern69	db $33,$2f,$36,$2e,$2a,$2a,$2f,$38,$e0
md1pattern70	db $38,$38,$38,$2f,$2f,$2f,$2e,$2a,$e0
md1pattern71	db $2e,$36,$3a,$3a,$3a,$2f,$34,$33,$e0
md1pattern72	db $34,$38,$36,$34,$36,$34,$33,$3f,$e0
md1pattern73	db $38,$36,$34,$2f,$34,$33,$34,$38,$e0
md1pattern74	db $36,$34,$36,$3b,$34,$38,$3b,$3f,$e0
md1pattern75	db $36,$36,$3b,$34,$38,$2f,$3b,$36,$e0
md1pattern76	db $34,$3b,$38,$3d,$3d,$38,$36,$34,$e0
md1pattern77	db $3f,$23,$2f,$31,$33,$36,$36,$33,$e0
md1pattern78	db $38,$38,$38,$38,$2f,$2f,$31,$3a,$e0
md1pattern79	db $3a,$3a,$36,$3a,$2e,$3a,$36,$33,$e0
md1pattern80	db $36,$33,$36,$36,$33,$2f,$33,$2f,$e0
md1pattern81	db $36,$2e,$2a,$2a,$2f,$38,$38,$38,$e0
md1pattern82	db $38,$2f,$2f,$2f,$2e,$2a,$2e,$36,$e0
md1pattern83	db $3a,$3a,$3a,$3b,$2f,$3d,$3f,$36,$e0
md1pattern84	db $36,$33,$38,$2e,$33,$33,$34,$38,$e0
md1pattern85	db $34,$38,$38,$2f,$31,$31,$3a,$3a,$e0
md1pattern86	db $3a,$36,$00,$00,$00,$00,$00,$00,$e0
md1pattern87	db $00,$00,$00,$00,$00,$00,$00,$00,$e0



; =======================
;    EARTHSHAKER MUSIC
; =======================

musicData2:						
	db $06
	dw dooforder0
	dw dooforder1
	dw dooforder2
	dw dooforder3

dooforder0:
	dw $e100
	dw doofpattern0
	dw doofpattern1
	dw doofpattern0
	dw doofpattern2
	dw doofpattern3
	dw doofpattern1
	dw doofpattern1
	dw doofpattern4
	dw doofpattern0
	dw doofpattern1
	dw doofpattern0
	dw doofpattern2
	dw doofpattern3
	dw doofpattern1
	dw doofpattern1
	dw doofpattern5
	dw doofpattern6
	dw doofpattern1
	dw doofpattern6
	dw doofpattern7
	dw doofpattern8
	dw doofpattern1
	dw doofpattern1
	dw doofpattern9
	dw doofpattern6
	dw doofpattern1
	dw doofpattern6
	dw doofpattern7
	dw doofpattern8
	dw doofpattern1
	dw doofpattern1
	dw doofpattern10
	dw doofpattern2
	dw doofpattern1
	dw doofpattern2
	dw doofpattern11
	dw doofpattern12
	dw doofpattern1
	dw doofpattern1
	dw doofpattern13
	dw doofpattern2
	dw doofpattern1
	dw doofpattern2
	dw doofpattern11
	dw doofpattern14
	dw doofpattern1
	dw doofpattern1
	dw doofpattern15
	dw doofpattern7
	dw doofpattern1
	dw doofpattern7
	dw doofpattern16
	dw doofpattern17
	dw doofpattern1
	dw doofpattern1
	dw doofpattern18
	dw doofpattern7
	dw doofpattern1
	dw doofpattern7
	dw doofpattern16
	dw doofpattern19
	dw doofpattern1
	dw doofpattern1
	dw doofpattern20
	dw doofpattern21
	dw doofpattern1
	dw doofpattern21
	dw doofpattern22
	dw doofpattern12
	dw doofpattern1
	dw doofpattern1
	dw doofpattern23
	dw doofpattern21
	dw doofpattern1
	dw doofpattern21
	dw doofpattern22
	dw doofpattern24
	dw doofpattern1
	dw doofpattern1
	dw doofpattern25
	dw doofpattern21
	dw doofpattern1
	dw doofpattern21
	dw doofpattern22
	dw doofpattern12
	dw doofpattern1
	dw doofpattern1
	dw doofpattern23
	dw doofpattern0
	dw doofpattern1
	dw doofpattern0
	dw doofpattern26
	dw doofpattern27
	dw doofpattern1
	dw doofpattern1
	dw doofpattern28
	dw doofpattern29
	dw doofpattern30
	dw doofpattern31
	dw doofpattern1
	dw doofpattern32
	dw doofpattern33
	dw doofpattern34
	dw doofpattern35
	dw doofpattern36
	dw doofpattern37
	dw doofpattern1
	dw doofpattern38
	dw doofpattern39
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern40
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern41
	dw doofpattern1
	dw doofpattern1
	dw doofpattern42
	dw doofpattern39
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern43
	dw doofpattern44
	dw doofpattern45
	dw doofpattern46
	dw doofpattern47
	dw doofpattern48
	dw doofpattern33
	dw doofpattern8
	dw doofpattern49
	dw doofpattern50
	dw doofpattern51
	dw doofpattern52
	dw doofpattern53
	dw doofpattern54
	dw doofpattern55
	dw doofpattern56
	dw doofpattern43
	dw doofpattern44
	dw doofpattern45
	dw doofpattern46
	dw doofpattern57
	dw doofpattern58
	dw doofpattern33
	dw doofpattern8
	dw doofpattern49
	dw doofpattern50
	dw doofpattern51
	dw doofpattern52
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern12
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern17
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern60
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern61
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern60
	dw doofpattern17
	dw doofpattern12
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern62
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern17
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern63
	dw doofpattern64
	dw doofpattern65
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern66
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern61
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern60
	dw doofpattern17
	dw doofpattern59
dooforder1:
	dw $e100
	dw doofpattern67
	dw doofpattern68
	dw doofpattern69
	dw doofpattern70
	dw doofpattern71
	dw doofpattern1
	dw doofpattern1
	dw doofpattern72
	dw doofpattern67
	dw doofpattern68
	dw doofpattern69
	dw doofpattern70
	dw doofpattern71
	dw doofpattern1
	dw doofpattern1
	dw doofpattern73
	dw doofpattern74
	dw doofpattern3
	dw doofpattern75
	dw doofpattern76
	dw doofpattern77
	dw doofpattern1
	dw doofpattern1
	dw doofpattern78
	dw doofpattern74
	dw doofpattern3
	dw doofpattern75
	dw doofpattern76
	dw doofpattern77
	dw doofpattern1
	dw doofpattern1
	dw doofpattern79
	dw doofpattern80
	dw doofpattern81
	dw doofpattern82
	dw doofpattern83
	dw doofpattern84
	dw doofpattern1
	dw doofpattern1
	dw doofpattern85
	dw doofpattern86
	dw doofpattern48
	dw doofpattern87
	dw doofpattern83
	dw doofpattern84
	dw doofpattern1
	dw doofpattern1
	dw doofpattern88
	dw doofpattern89
	dw doofpattern90
	dw doofpattern91
	dw doofpattern92
	dw doofpattern93
	dw doofpattern1
	dw doofpattern1
	dw doofpattern94
	dw doofpattern95
	dw doofpattern96
	dw doofpattern97
	dw doofpattern92
	dw doofpattern93
	dw doofpattern1
	dw doofpattern1
	dw doofpattern98
	dw doofpattern99
	dw doofpattern100
	dw doofpattern101
	dw doofpattern102
	dw doofpattern103
	dw doofpattern1
	dw doofpattern1
	dw doofpattern104
	dw doofpattern105
	dw doofpattern93
	dw doofpattern106
	dw doofpattern102
	dw doofpattern103
	dw doofpattern1
	dw doofpattern1
	dw doofpattern107
	dw doofpattern99
	dw doofpattern100
	dw doofpattern101
	dw doofpattern102
	dw doofpattern103
	dw doofpattern1
	dw doofpattern1
	dw doofpattern104
	dw doofpattern67
	dw doofpattern68
	dw doofpattern69
	dw doofpattern70
	dw doofpattern71
	dw doofpattern1
	dw doofpattern1
	dw doofpattern108
	dw doofpattern109
	dw doofpattern109
	dw doofpattern109
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern110
	dw doofpattern111
	dw doofpattern111
	dw doofpattern1
	dw doofpattern17
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern112
	dw doofpattern109
	dw doofpattern109
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern110
	dw doofpattern111
	dw doofpattern111
	dw doofpattern1
	dw doofpattern17
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern113
	dw doofpattern114
	dw doofpattern115
	dw doofpattern116
	dw doofpattern117
	dw doofpattern118
	dw doofpattern119
	dw doofpattern117
	dw doofpattern120
	dw doofpattern61
	dw doofpattern60
	dw doofpattern121
	dw doofpattern122
	dw doofpattern63
	dw doofpattern123
	dw doofpattern124
	dw doofpattern113
	dw doofpattern114
	dw doofpattern115
	dw doofpattern116
	dw doofpattern125
	dw doofpattern126
	dw doofpattern127
	dw doofpattern63
	dw doofpattern120
	dw doofpattern61
	dw doofpattern60
	dw doofpattern121
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern128
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern128
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern128
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern129
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern128
	dw doofpattern130
	dw doofpattern131
	dw doofpattern132
	dw doofpattern133
	dw doofpattern1
	dw doofpattern134
	dw doofpattern1
	dw doofpattern135
	dw doofpattern1
	dw doofpattern136
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern137
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern138
	dw doofpattern138
	dw doofpattern138
	dw doofpattern138
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern129
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern128
	dw doofpattern130
	dw doofpattern59
dooforder2:
	dw $e100
	dw doofpattern140
	dw doofpattern141
	dw doofpattern31
	dw doofpattern1
	dw doofpattern142
	dw doofpattern143
	dw doofpattern144
	dw doofpattern145
	dw doofpattern146
	dw doofpattern141
	dw doofpattern31
	dw doofpattern1
	dw doofpattern147
	dw doofpattern143
	dw doofpattern144
	dw doofpattern148
	dw doofpattern149
	dw doofpattern150
	dw doofpattern151
	dw doofpattern1
	dw doofpattern152
	dw doofpattern153
	dw doofpattern154
	dw doofpattern155
	dw doofpattern156
	dw doofpattern150
	dw doofpattern151
	dw doofpattern1
	dw doofpattern157
	dw doofpattern153
	dw doofpattern154
	dw doofpattern158
	dw doofpattern159
	dw doofpattern160
	dw doofpattern161
	dw doofpattern12
	dw doofpattern162
	dw doofpattern163
	dw doofpattern164
	dw doofpattern165
	dw doofpattern166
	dw doofpattern160
	dw doofpattern161
	dw doofpattern1
	dw doofpattern162
	dw doofpattern163
	dw doofpattern164
	dw doofpattern167
	dw doofpattern168
	dw doofpattern169
	dw doofpattern170
	dw doofpattern17
	dw doofpattern171
	dw doofpattern163
	dw doofpattern172
	dw doofpattern173
	dw doofpattern174
	dw doofpattern169
	dw doofpattern170
	dw doofpattern1
	dw doofpattern171
	dw doofpattern163
	dw doofpattern172
	dw doofpattern175
	dw doofpattern176
	dw doofpattern177
	dw doofpattern178
	dw doofpattern12
	dw doofpattern179
	dw doofpattern130
	dw doofpattern128
	dw doofpattern180
	dw doofpattern181
	dw doofpattern177
	dw doofpattern178
	dw doofpattern1
	dw doofpattern179
	dw doofpattern130
	dw doofpattern128
	dw doofpattern182
	dw doofpattern183
	dw doofpattern177
	dw doofpattern178
	dw doofpattern12
	dw doofpattern179
	dw doofpattern130
	dw doofpattern128
	dw doofpattern180
	dw doofpattern184
	dw doofpattern185
	dw doofpattern186
	dw doofpattern1
	dw doofpattern187
	dw doofpattern188
	dw doofpattern144
	dw doofpattern189
	dw doofpattern190
	dw doofpattern191
	dw doofpattern191
	dw doofpattern192
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern193
	dw doofpattern194
	dw doofpattern194
	dw doofpattern195
	dw doofpattern1
	dw doofpattern1
	dw doofpattern196
	dw doofpattern1
	dw doofpattern190
	dw doofpattern191
	dw doofpattern191
	dw doofpattern192
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern193
	dw doofpattern194
	dw doofpattern194
	dw doofpattern195
	dw doofpattern1
	dw doofpattern1
	dw doofpattern196
	dw doofpattern1
	dw doofpattern197
	dw doofpattern198
	dw doofpattern199
	dw doofpattern200
	dw doofpattern200
	dw doofpattern198
	dw doofpattern199
	dw doofpattern200
	dw doofpattern201
	dw doofpattern202
	dw doofpattern203
	dw doofpattern201
	dw doofpattern201
	dw doofpattern202
	dw doofpattern203
	dw doofpattern201
	dw doofpattern197
	dw doofpattern198
	dw doofpattern199
	dw doofpattern200
	dw doofpattern200
	dw doofpattern198
	dw doofpattern199
	dw doofpattern200
	dw doofpattern201
	dw doofpattern202
	dw doofpattern203
	dw doofpattern201
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern129
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern204
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern164
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern172
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern164
	dw doofpattern204
	dw doofpattern205
	dw doofpattern206
	dw doofpattern206
	dw doofpattern207
	dw doofpattern208
	dw doofpattern209
	dw doofpattern209
	dw doofpattern209
	dw doofpattern210
	dw doofpattern211
	dw doofpattern212
	dw doofpattern212
	dw doofpattern213
	dw doofpattern213
	dw doofpattern213
	dw doofpattern213
	dw doofpattern214
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern77
	dw doofpattern1
	dw doofpattern1
	dw doofpattern1
	dw doofpattern172
	dw doofpattern1
	dw doofpattern1
	dw doofpattern59
	dw doofpattern1
	dw doofpattern1
	dw doofpattern164
	dw doofpattern204
	dw doofpattern59
dooforder3:
	dw $e100
	dw doofpattern187
	dw doofpattern143
	dw doofpattern215
	dw doofpattern216
	dw doofpattern153
	dw doofpattern129
	dw doofpattern217
	dw doofpattern218
	dw doofpattern187
	dw doofpattern143
	dw doofpattern215
	dw doofpattern216
	dw doofpattern153
	dw doofpattern129
	dw doofpattern217
	dw doofpattern219
	dw doofpattern220
	dw doofpattern153
	dw doofpattern221
	dw doofpattern222
	dw doofpattern223
	dw doofpattern204
	dw doofpattern224
	dw doofpattern225
	dw doofpattern220
	dw doofpattern153
	dw doofpattern221
	dw doofpattern222
	dw doofpattern223
	dw doofpattern226
	dw doofpattern224
	dw doofpattern227
	dw doofpattern162
	dw doofpattern163
	dw doofpattern228
	dw doofpattern229
	dw doofpattern163
	dw doofpattern130
	dw doofpattern230
	dw doofpattern231
	dw doofpattern162
	dw doofpattern163
	dw doofpattern228
	dw doofpattern229
	dw doofpattern163
	dw doofpattern130
	dw doofpattern230
	dw doofpattern232
	dw doofpattern171
	dw doofpattern163
	dw doofpattern233
	dw doofpattern234
	dw doofpattern163
	dw doofpattern235
	dw doofpattern236
	dw doofpattern237
	dw doofpattern171
	dw doofpattern163
	dw doofpattern233
	dw doofpattern234
	dw doofpattern163
	dw doofpattern235
	dw doofpattern236
	dw doofpattern238
	dw doofpattern179
	dw doofpattern130
	dw doofpattern239
	dw doofpattern240
	dw doofpattern130
	dw doofpattern241
	dw doofpattern242
	dw doofpattern243
	dw doofpattern179
	dw doofpattern130
	dw doofpattern239
	dw doofpattern240
	dw doofpattern130
	dw doofpattern241
	dw doofpattern242
	dw doofpattern244
	dw doofpattern179
	dw doofpattern130
	dw doofpattern239
	dw doofpattern240
	dw doofpattern130
	dw doofpattern241
	dw doofpattern242
	dw doofpattern243
	dw doofpattern245
	dw doofpattern188
	dw doofpattern215
	dw doofpattern246
	dw doofpattern247
	dw doofpattern248
	dw doofpattern249
	dw doofpattern219
	dw doofpattern250
	dw doofpattern251
	dw doofpattern252
	dw doofpattern250
	dw doofpattern250
	dw doofpattern251
	dw doofpattern252
	dw doofpattern250
	dw doofpattern253
	dw doofpattern254
	dw doofpattern255
	dw doofpattern253
	dw doofpattern253
	dw doofpattern254
	dw doofpattern255
	dw doofpattern253
	dw doofpattern250
	dw doofpattern251
	dw doofpattern252
	dw doofpattern250
	dw doofpattern250
	dw doofpattern251
	dw doofpattern252
	dw doofpattern250
	dw doofpattern253
	dw doofpattern254
	dw doofpattern255
	dw doofpattern253
	dw doofpattern253
	dw doofpattern254
	dw doofpattern255
	dw doofpattern253
	dw doofpattern250
	dw doofpattern251
	dw doofpattern252
	dw doofpattern250
	dw doofpattern250
	dw doofpattern251
	dw doofpattern252
	dw doofpattern250
	dw doofpattern253
	dw doofpattern254
	dw doofpattern255
	dw doofpattern253
	dw doofpattern253
	dw doofpattern254
	dw doofpattern255
	dw doofpattern253
	dw doofpattern250
	dw doofpattern251
	dw doofpattern252
	dw doofpattern250
	dw doofpattern250
	dw doofpattern251
	dw doofpattern252
	dw doofpattern250
	dw doofpattern253
	dw doofpattern254
	dw doofpattern255
	dw doofpattern253
	dw doofpattern253
	dw doofpattern254
	dw doofpattern256
	dw doofpattern257
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern258
	dw doofpattern258
	dw doofpattern259
	dw doofpattern259
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern259
	dw doofpattern259
	dw doofpattern258
	dw doofpattern258
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern259
	dw doofpattern259
	dw doofpattern259
	dw doofpattern259
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern260
	dw doofpattern260
	dw doofpattern260
	dw doofpattern260
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern139
	dw doofpattern59

doofpattern0:	db $47,$00,$4a,$00,$4e,$00,$51,$00,$e0
doofpattern1:	db $00,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern2:	db $4e,$00,$51,$00,$55,$00,$58,$00,$e0
doofpattern3:	db $53,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern4:	db $4c,$4e,$4c,$00,$5a,$5b,$5d,$00,$e0
doofpattern5:	db $58,$56,$55,$00,$58,$56,$55,$53,$e0
doofpattern6:	db $49,$00,$4c,$00,$50,$00,$53,$00,$e0
doofpattern7:	db $50,$00,$53,$00,$57,$00,$5a,$00,$e0
doofpattern8:	db $55,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern9:	db $4e,$50,$4e,$00,$5c,$5d,$5f,$00,$e0
doofpattern10:	db $5a,$58,$57,$00,$5a,$58,$57,$55,$e0
doofpattern11:	db $55,$00,$58,$00,$5c,$00,$5f,$00,$e0
doofpattern12:	db $02,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern13:	db $13,$15,$13,$00,$1f,$1f,$1f,$00,$e0
doofpattern14:	db $5a,$00,$02,$00,$00,$00,$00,$00,$e0
doofpattern15:	db $1f,$1d,$1c,$00,$1f,$1d,$1c,$1a,$e0
doofpattern16:	db $57,$00,$5a,$00,$5e,$00,$5f,$00,$e0
doofpattern17:	db $04,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern18:	db $15,$17,$15,$00,$1f,$1f,$1f,$00,$e0
doofpattern19:	db $5c,$00,$04,$00,$00,$00,$00,$00,$e0
doofpattern20:	db $1f,$1f,$1e,$00,$1f,$1f,$1e,$00,$e0
doofpattern21:	db $46,$00,$49,$00,$4d,$00,$50,$00,$e0
doofpattern22:	db $4d,$00,$50,$00,$54,$00,$55,$00,$e0
doofpattern23:	db $0b,$0d,$0b,$00,$15,$15,$15,$00,$e0
doofpattern24:	db $52,$00,$06,$00,$00,$00,$00,$00,$e0
doofpattern25:	db $15,$15,$14,$00,$15,$15,$14,$00,$e0
doofpattern26:	db $4e,$00,$51,$00,$55,$00,$56,$00,$e0
doofpattern27:	db $53,$00,$07,$00,$00,$00,$00,$00,$e0
doofpattern28:	db $16,$16,$15,$00,$16,$16,$15,$00,$e0
doofpattern29:	db $42,$42,$00,$00,$47,$00,$4c,$00,$e0
doofpattern30:	db $55,$00,$56,$00,$00,$00,$56,$56,$e0
doofpattern31:	db $56,$00,$53,$00,$51,$00,$53,$00,$e0
doofpattern32:	db $53,$00,$53,$00,$53,$00,$53,$00,$e0
doofpattern33:	db $56,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern34:	db $4a,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern35:	db $56,$56,$56,$00,$56,$56,$56,$55,$e0
doofpattern36:	db $57,$37,$00,$00,$2e,$2e,$00,$00,$e0
doofpattern37:	db $30,$04,$00,$00,$00,$00,$00,$00,$e0
doofpattern38:	db $03,$04,$05,$06,$07,$08,$09,$0a,$e0
doofpattern39:	db $2b,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern40:	db $42,$42,$00,$00,$00,$00,$00,$00,$e0
doofpattern41:	db $44,$24,$00,$00,$00,$00,$00,$00,$e0
doofpattern42:	db $23,$24,$25,$26,$27,$28,$29,$2a,$e0
doofpattern43:	db $29,$29,$09,$00,$09,$0a,$0b,$0c,$e0
doofpattern44:	db $2c,$2c,$0c,$00,$00,$00,$00,$4c,$e0
doofpattern45:	db $0a,$00,$00,$00,$00,$00,$00,$4a,$e0
doofpattern46:	db $49,$00,$00,$00,$00,$00,$00,$49,$e0
doofpattern47:	db $35,$35,$15,$00,$00,$00,$00,$55,$e0
doofpattern48:	db $58,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern49:	db $00,$2b,$2b,$0b,$00,$00,$0b,$0c,$e0
doofpattern50:	db $0d,$2e,$2e,$0e,$00,$2e,$2e,$00,$e0
doofpattern51:	db $4e,$0c,$00,$00,$00,$00,$00,$00,$e0
doofpattern52:	db $4c,$0b,$00,$00,$00,$00,$00,$4b,$e0
doofpattern53:	db $0b,$00,$00,$00,$00,$00,$00,$4b,$e0
doofpattern54:	db $0e,$00,$00,$00,$00,$00,$00,$4e,$e0
doofpattern55:	db $0c,$00,$00,$00,$00,$00,$00,$4c,$e0
doofpattern56:	db $0b,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern57:	db $35,$33,$15,$00,$00,$00,$00,$55,$e0
doofpattern58:	db $5d,$00,$00,$00,$00,$00,$5f,$5d,$e0
doofpattern59:	db $01,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern60:	db $05,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern61:	db $07,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern62:	db $5d,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern63:	db $15,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern64:	db $00,$00,$00,$00,$11,$10,$0f,$0c,$e0
doofpattern65:	db $0b,$0a,$07,$06,$05,$00,$00,$00,$e0
doofpattern66:	db $10,$00,$00,$00,$01,$00,$00,$00,$e0
doofpattern67:	db $00,$00,$47,$00,$4a,$00,$4e,$00,$e0
doofpattern68:	db $51,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern69:	db $00,$00,$47,$00,$4e,$00,$4f,$00,$e0
doofpattern70:	db $4e,$00,$4c,$00,$4a,$00,$4c,$00,$e0
doofpattern71:	db $47,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern72:	db $51,$53,$55,$00,$53,$55,$56,$00,$e0
doofpattern73:	db $55,$56,$55,$00,$55,$53,$55,$53,$e0
doofpattern74:	db $00,$00,$49,$00,$4c,$00,$50,$00,$e0
doofpattern75:	db $00,$00,$49,$00,$50,$00,$51,$00,$e0
doofpattern76:	db $50,$00,$4e,$00,$4c,$00,$4e,$00,$e0
doofpattern77:	db $49,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern78:	db $53,$55,$57,$00,$55,$57,$58,$00,$e0
doofpattern79:	db $57,$58,$57,$00,$57,$55,$57,$55,$e0
doofpattern80:	db $02,$00,$0e,$00,$11,$00,$15,$00,$e0
doofpattern81:	db $18,$00,$02,$00,$00,$00,$00,$00,$e0
doofpattern82:	db $00,$00,$0e,$00,$15,$00,$16,$00,$e0
doofpattern83:	db $55,$00,$53,$00,$51,$00,$53,$00,$e0
doofpattern84:	db $4e,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern85:	db $58,$5a,$5c,$00,$5a,$5c,$5d,$00,$e0
doofpattern86:	db $00,$00,$4e,$00,$51,$00,$55,$00,$e0
doofpattern87:	db $00,$00,$4e,$00,$55,$00,$56,$00,$e0
doofpattern88:	db $5c,$5d,$5c,$00,$5c,$5a,$5c,$5a,$e0
doofpattern89:	db $04,$00,$10,$00,$13,$00,$17,$00,$e0
doofpattern90:	db $1a,$00,$04,$00,$00,$00,$00,$00,$e0
doofpattern91:	db $00,$00,$10,$00,$17,$00,$18,$00,$e0
doofpattern92:	db $57,$00,$55,$00,$53,$00,$55,$00,$e0
doofpattern93:	db $50,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern94:	db $5a,$5c,$5e,$00,$5c,$5e,$5f,$00,$e0
doofpattern95:	db $00,$00,$50,$00,$53,$00,$57,$00,$e0
doofpattern96:	db $5a,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern97:	db $00,$00,$50,$00,$57,$00,$58,$00,$e0
doofpattern98:	db $5e,$5f,$5e,$00,$5e,$5c,$5e,$00,$e0
doofpattern99:	db $02,$00,$06,$00,$09,$00,$0d,$00,$e0
doofpattern100:	db $10,$00,$02,$00,$00,$00,$00,$00,$e0
doofpattern101:	db $00,$00,$06,$00,$0d,$00,$0e,$00,$e0
doofpattern102:	db $4d,$00,$4b,$00,$49,$00,$4b,$00,$e0
doofpattern103:	db $46,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern104:	db $50,$52,$54,$00,$52,$54,$55,$00,$e0
doofpattern105:	db $00,$00,$46,$00,$49,$00,$4d,$00,$e0
doofpattern106:	db $00,$00,$46,$00,$4d,$00,$4e,$00,$e0
doofpattern107:	db $54,$55,$54,$00,$54,$52,$54,$00,$e0
doofpattern108:	db $55,$56,$55,$00,$55,$53,$55,$00,$e0
doofpattern109:	db $02,$00,$00,$00,$0e,$00,$00,$00,$e0
doofpattern110:	db $04,$00,$00,$00,$0e,$00,$00,$00,$e0
doofpattern111:	db $04,$00,$00,$00,$10,$00,$00,$00,$e0
doofpattern112:	db $13,$00,$11,$00,$0e,$00,$00,$00,$e0
doofpattern113:	db $02,$00,$00,$00,$03,$04,$05,$06,$e0
doofpattern114:	db $05,$00,$00,$00,$00,$00,$00,$01,$e0
doofpattern115:	db $03,$00,$00,$00,$00,$00,$00,$01,$e0
doofpattern116:	db $02,$00,$00,$00,$00,$00,$00,$01,$e0
doofpattern117:	db $0e,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern118:	db $11,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern119:	db $0f,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern120:	db $04,$00,$00,$00,$00,$00,$05,$06,$e0
doofpattern121:	db $04,$00,$00,$00,$00,$00,$15,$16,$e0
doofpattern122:	db $17,$00,$00,$00,$00,$00,$18,$17,$e0
doofpattern123:	db $0f,$11,$00,$00,$00,$00,$13,$11,$e0
doofpattern124:	db $04,$00,$00,$00,$00,$00,$00,$01,$e0
doofpattern125:	db $0e,$0c,$0e,$00,$00,$00,$16,$17,$e0
doofpattern126:	db $18,$00,$00,$00,$00,$00,$1a,$18,$e0
doofpattern127:	db $16,$00,$00,$00,$00,$00,$18,$16,$e0
doofpattern128:	db $29,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern129:	db $2e,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern130:	db $35,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern131:	db $15,$09,$00,$00,$35,$09,$00,$00,$e0
doofpattern132:	db $15,$09,$00,$00,$15,$09,$00,$00,$e0
doofpattern133:	db $00,$09,$00,$00,$15,$09,$00,$00,$e0
doofpattern134:	db $3a,$00,$3c,$00,$00,$00,$00,$00,$e0
doofpattern135:	db $3c,$00,$3d,$00,$00,$00,$00,$00,$e0
doofpattern136:	db $09,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern137:	db $1c,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern138:	db $55,$49,$00,$00,$55,$49,$00,$00,$e0
doofpattern139:	db $15,$13,$10,$11,$15,$13,$10,$11,$e0
doofpattern140:	db $00,$00,$47,$00,$00,$00,$4c,$00,$e0
doofpattern141:	db $55,$00,$58,$00,$00,$00,$5a,$58,$e0
doofpattern142:	db $33,$00,$00,$00,$00,$00,$33,$00,$e0
doofpattern143:	db $38,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern144:	db $2a,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern145:	db $35,$36,$38,$00,$38,$3a,$3b,$00,$e0
doofpattern146:	db $47,$00,$00,$00,$47,$00,$4c,$00,$e0
doofpattern147:	db $33,$00,$00,$00,$33,$00,$33,$33,$e0
doofpattern148:	db $3a,$38,$3a,$00,$3a,$38,$36,$35,$e0
doofpattern149:	db $00,$00,$00,$00,$49,$00,$4e,$00,$e0
doofpattern150:	db $57,$00,$5a,$00,$00,$00,$5c,$5a,$e0
doofpattern151:	db $58,$00,$55,$00,$53,$00,$55,$00,$e0
doofpattern152:	db $35,$00,$35,$00,$00,$00,$35,$00,$e0
doofpattern153:	db $3a,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern154:	db $2c,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern155:	db $37,$38,$3a,$00,$3a,$3c,$3d,$00,$e0
doofpattern156:	db $49,$00,$00,$00,$49,$00,$4e,$00,$e0
doofpattern157:	db $35,$38,$3c,$3f,$33,$37,$3a,$3d,$e0
doofpattern158:	db $3c,$3a,$3c,$00,$3c,$3a,$38,$37,$e0
doofpattern159:	db $00,$00,$00,$00,$4e,$00,$53,$00,$e0
doofpattern160:	db $5c,$00,$5f,$00,$00,$00,$5f,$5f,$e0
doofpattern161:	db $5d,$00,$5a,$00,$58,$00,$5a,$00,$e0
doofpattern162:	db $3a,$00,$3a,$00,$3a,$00,$3a,$00,$e0
doofpattern163:	db $3f,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern164:	db $31,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern165:	db $3c,$3d,$3f,$00,$3f,$3f,$3f,$00,$e0
doofpattern166:	db $4e,$00,$00,$00,$4e,$00,$53,$00,$e0
doofpattern167:	db $3f,$3f,$3f,$00,$3f,$3f,$3d,$3c,$e0
doofpattern168:	db $00,$00,$00,$00,$50,$00,$55,$00,$e0
doofpattern169:	db $5e,$00,$5f,$00,$00,$00,$5f,$5f,$e0
doofpattern170:	db $5f,$00,$5c,$00,$5a,$00,$5c,$00,$e0
doofpattern171:	db $3c,$00,$3c,$00,$3c,$00,$3c,$00,$e0
doofpattern172:	db $33,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern173:	db $3e,$3f,$3f,$00,$3f,$3f,$3f,$00,$e0
doofpattern174:	db $50,$00,$00,$00,$50,$00,$55,$00,$e0
doofpattern175:	db $3f,$3f,$3f,$00,$3f,$3f,$3f,$3e,$e0
doofpattern176:	db $51,$00,$00,$00,$46,$00,$4b,$00,$e0
doofpattern177:	db $54,$00,$55,$00,$00,$00,$55,$55,$e0
doofpattern178:	db $55,$00,$52,$00,$50,$00,$52,$00,$e0
doofpattern179:	db $32,$00,$32,$00,$32,$00,$32,$00,$e0
doofpattern180:	db $34,$35,$35,$00,$35,$35,$35,$00,$e0
doofpattern181:	db $46,$00,$00,$00,$46,$00,$4b,$00,$e0
doofpattern182	db $35,$35,$35,$00,$35,$35,$35,$34,$e0
doofpattern183:	db $00,$00,$00,$00,$46,$00,$4b,$00,$e0
doofpattern184:	db $07,$00,$00,$00,$07,$00,$0c,$00,$e0
doofpattern185:	db $15,$00,$16,$00,$00,$00,$16,$16,$e0
doofpattern186:	db $16,$00,$13,$00,$11,$00,$13,$00,$e0
doofpattern187:	db $33,$00,$33,$00,$33,$00,$33,$00,$e0
doofpattern188:	db $36,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern189:	db $36,$36,$36,$00,$36,$36,$36,$35,$e0
doofpattern190:	db $0e,$01,$0e,$01,$0e,$00,$02,$00,$e0
doofpattern191:	db $0e,$00,$02,$00,$0e,$00,$02,$00,$e0
doofpattern192:	db $02,$00,$0e,$00,$02,$00,$0e,$00,$e0
doofpattern193:	db $10,$01,$10,$01,$10,$00,$04,$00,$e0
doofpattern194:	db $10,$00,$04,$00,$10,$00,$04,$00,$e0
doofpattern195:	db $04,$00,$10,$00,$04,$00,$10,$00,$e0
doofpattern196:	db $00,$00,$00,$00,$3a,$00,$30,$00,$e0
doofpattern197:	db $22,$00,$2e,$00,$22,$2e,$00,$38,$e0
doofpattern198:	db $25,$31,$00,$3d,$25,$31,$00,$3b,$e0
doofpattern199:	db $23,$2f,$00,$3b,$23,$2f,$00,$39,$e0
doofpattern200:	db $22,$2e,$00,$3a,$22,$2e,$00,$38,$e0
doofpattern201:	db $24,$30,$3c,$30,$24,$30,$3a,$30,$e0
doofpattern202:	db $27,$33,$3f,$33,$27,$33,$3d,$33,$e0
doofpattern203:	db $25,$31,$3d,$31,$25,$31,$3b,$31,$e0
doofpattern204:	db $30,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern205:	db $35,$3f,$3c,$3d,$15,$3f,$3c,$3d,$e0
doofpattern206:	db $35,$3f,$3c,$3d,$35,$3f,$3c,$3d,$e0
doofpattern207:	db $00,$00,$00,$00,$00,$39,$38,$37,$e0
doofpattern208:	db $36,$35,$33,$30,$31,$35,$33,$30,$e0
doofpattern209:	db $31,$35,$33,$30,$31,$35,$33,$30,$e0
doofpattern210:	db $15,$1f,$1c,$1d,$15,$1f,$1c,$1d,$e0
doofpattern211:	db $15,$1f,$1c,$00,$1c,$1f,$1c,$1d,$e0
doofpattern212:	db $1c,$1f,$1c,$1d,$1c,$1f,$1c,$1d,$e0
doofpattern213:	db $35,$3f,$3c,$31,$35,$3f,$3c,$31,$e0
doofpattern214:	db $15,$13,$11,$00,$00,$00,$00,$00,$e0
doofpattern215:	db $27,$00,$27,$00,$27,$00,$27,$00,$e0
doofpattern216:	db $3d,$38,$33,$38,$3d,$38,$33,$38,$e0
doofpattern217:	db $2f,$00,$00,$00,$2e,$00,$2c,$00,$e0
doofpattern218:	db $29,$2a,$2c,$00,$2c,$2e,$2f,$00,$e0
doofpattern219:	db $2e,$2c,$2e,$00,$2e,$2c,$2a,$29,$e0
doofpattern220:	db $35,$00,$35,$00,$35,$00,$35,$00,$e0
doofpattern221:	db $29,$00,$29,$00,$29,$00,$29,$00,$e0
doofpattern222:	db $3f,$3a,$35,$3a,$3f,$3a,$35,$3a,$e0
doofpattern223:	db $3c,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern224:	db $31,$00,$00,$00,$30,$00,$2e,$00,$e0
doofpattern225:	db $2b,$2c,$2e,$00,$2e,$30,$31,$00,$e0
doofpattern226:	db $2e,$31,$35,$38,$2e,$31,$35,$38,$e0
doofpattern227:	db $30,$2e,$30,$00,$30,$2e,$2c,$2b,$e0
doofpattern228:	db $2e,$00,$2e,$00,$2e,$00,$2e,$00,$e0
doofpattern229:	db $3f,$3f,$3a,$3f,$3f,$3f,$3a,$3f,$e0
doofpattern230:	db $36,$00,$00,$00,$35,$00,$33,$00,$e0
doofpattern231:	db $30,$31,$33,$00,$33,$35,$36,$00,$e0
doofpattern232:	db $35,$33,$35,$00,$35,$33,$31,$30,$e0
doofpattern233:	db $30,$00,$30,$00,$30,$00,$30,$00,$e0
doofpattern234:	db $3f,$3f,$3c,$3f,$3f,$3f,$3c,$3f,$e0
doofpattern235:	db $37,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern236:	db $38,$00,$00,$00,$37,$00,$35,$00,$e0
doofpattern237:	db $32,$33,$35,$00,$35,$37,$38,$00,$e0
doofpattern238:	db $37,$35,$37,$00,$37,$35,$33,$32,$e0
doofpattern239:	db $26,$00,$26,$00,$26,$00,$26,$00,$e0
doofpattern240:	db $35,$35,$32,$35,$35,$35,$32,$35,$e0
doofpattern241:	db $2d,$00,$00,$00,$00,$00,$00,$00,$e0
doofpattern242:	db $2e,$00,$00,$00,$2d,$00,$2b,$00,$e0
doofpattern243:	db $28,$29,$2b,$00,$2b,$2d,$2e,$00,$e0
doofpattern244:	db $2d,$2b,$2d,$00,$2d,$2b,$29,$28,$e0
doofpattern245:	db $3f,$00,$3a,$00,$36,$00,$33,$00,$e0
doofpattern246:	db $36,$36,$33,$36,$36,$36,$33,$36,$e0
doofpattern247:	db $5f,$00,$5a,$00,$58,$00,$56,$00,$e0
doofpattern248:	db $5d,$00,$5a,$00,$56,$00,$53,$00,$e0
doofpattern249:	db $5a,$00,$56,$00,$53,$00,$4e,$00,$e0
doofpattern250:	db $3a,$00,$35,$00,$31,$00,$35,$00,$e0
doofpattern251:	db $3d,$00,$35,$00,$31,$00,$35,$00,$e0
doofpattern252:	db $3b,$00,$35,$00,$31,$00,$35,$00,$e0
doofpattern253:	db $3c,$00,$37,$00,$33,$00,$37,$00,$e0
doofpattern254:	db $3f,$00,$37,$00,$33,$00,$37,$00,$e0
doofpattern255:	db $3d,$00,$37,$00,$33,$00,$37,$00,$e0
doofpattern256:	db $3d,$01,$37,$01,$33,$01,$37,$01,$e0
doofpattern257:	db $3c,$01,$37,$01,$53,$53,$57,$57,$e0
doofpattern258:	db $55,$53,$50,$51,$55,$53,$50,$51,$e0
doofpattern259:	db $35,$33,$30,$31,$35,$33,$30,$31,$e0
doofpattern260:	db $1a,$18,$15,$16,$1a,$18,$15,$16,$e0


; -----------------------------------------
;  ZX-10 Intro.
; -----------------------------------------
musicData3
	db $09
	dw md3order0
	dw md3order1
	dw md3order2
	dw md3order3
	dw md3order2
	dw md3order3
	dw md3order1
	dw md3order2
	dw md3order3

md3order0
	dw $0400
	dw pattern0
	dw pattern0
	dw pattern0
	dw pattern0
md3order1
	dw $0400
	dw pattern1
	dw pattern2
	dw pattern3
	dw pattern2
md3order2
	dw $0400
	dw pattern4
	dw pattern1
	dw pattern4
	dw pattern4
md3order3
	dw $0400
	dw pattern5
	dw pattern6
	dw pattern5
	dw pattern6

pattern0	db $07,$01,$13,$01,$07,$01,$13,$01,$e0
pattern1	db $00,$00,$00,$00,$00,$00,$00,$00,$e0
pattern2	db $00,$00,$56,$56,$01,$56,$56,$01,$e0
pattern3	db $56,$01,$00,$00,$00,$00,$00,$00,$e0
pattern4	db $00,$00,$5a,$5a,$01,$5a,$5a,$01,$e0
pattern5	db $33,$01,$36,$01,$3a,$01,$3d,$01,$e0
pattern6	db $3f,$01,$3d,$01,$3a,$01,$36,$01,$e0




; -------------------------------
; SONG : DOOM LEVEL. By Utz.
; -------------------------------
musicData4
	db $06
	dw doomorder0
	dw doomorder1
	dw doomorder2
	dw doomorder3

doomorder0
	dw $dc00
	dw doompattern0
	dw doompattern1
	dw doompattern2
	dw doompattern3
	dw doompattern4
	dw doompattern5
	dw doompattern6
	dw doompattern1
	dw doompattern2
	dw doompattern7
	dw doompattern4
	dw doompattern5
	dw doompattern8
	dw doompattern9
	dw doompattern10
	dw doompattern11
	dw doompattern1
	dw doompattern2
	dw doompattern7
	dw doompattern4
	dw doompattern5
	dw doompattern8
	dw doompattern9
	dw doompattern10
	dw doompattern12
	dw doompattern13
	dw doompattern10
	dw doompattern14
	dw doompattern15
	dw doompattern16
	dw doompattern12
	dw doompattern13
	dw doompattern10
	dw doompattern14
	dw doompattern15
	dw doompattern16
	dw doompattern12
	dw doompattern13
	dw doompattern10
	dw doompattern17
	dw doompattern18
	dw doompattern19
	dw doompattern17
	dw doompattern20
	dw doompattern21
	dw doompattern22
	dw doompattern23
	dw doompattern24
	dw doompattern25
	dw doompattern26
	dw doompattern27
	dw doompattern28
	dw doompattern29
	dw doompattern30
	dw doompattern31
	dw doompattern32
	dw doompattern33
	dw doompattern34
	dw doompattern35
	dw doompattern36
	dw doompattern25
	dw doompattern26
	dw doompattern27
	dw doompattern28
	dw doompattern29
	dw doompattern30
	dw doompattern31
	dw doompattern32
	dw doompattern33
	dw doompattern34
	dw doompattern35
	dw doompattern36
	dw doompattern37
	dw doompattern26
	dw doompattern27
	dw doompattern28
	dw doompattern29
	dw doompattern30
	dw doompattern38
	dw doompattern39
	dw doompattern40
	dw doompattern28
	dw doompattern41
	dw doompattern42
	dw doompattern37
	dw doompattern26
	dw doompattern27
	dw doompattern28
	dw doompattern29
	dw doompattern30
	dw doompattern38
	dw doompattern39
	dw doompattern40
	dw doompattern28
	dw doompattern41
	dw doompattern42
	dw doompattern43
	dw doompattern44
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern46
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern47
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern48
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern49
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern50
	dw doompattern51
	dw doompattern45
	dw doompattern45
	dw doompattern47
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern48
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern52
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern50
	dw doompattern51
	dw doompattern45
	dw doompattern45
	dw doompattern47
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern48
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern53
	dw doompattern54
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern9
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern55
	dw doompattern45
	dw doompattern56
	dw doompattern45
	dw doompattern57
	dw doompattern45
	dw doompattern57
	dw doompattern45
	dw doompattern58
	dw doompattern45
	dw doompattern9
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern55
	dw doompattern45
	dw doompattern59
	dw doompattern45
	dw doompattern60
	dw doompattern45
	dw doompattern61
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern59
	dw doompattern45
	dw doompattern62
	dw doompattern45
	dw doompattern63
	dw doompattern64
	dw doompattern65
	dw doompattern66
	dw doompattern59
	dw doompattern45
	dw doompattern60
	dw doompattern45
	dw doompattern61
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern59
	dw doompattern45
	dw doompattern62
	dw doompattern45
	dw doompattern63
	dw doompattern64
	dw doompattern65
	dw doompattern67
	dw doompattern68
	dw doompattern45
	dw doompattern69
	dw doompattern45
	dw doompattern45
	dw doompattern70
	dw doompattern71
	dw doompattern45
	dw doompattern72
	dw doompattern8
doomorder1
	dw $dc00
	dw doompattern54
	dw doompattern73
	dw doompattern74
	dw doompattern54
	dw doompattern73
	dw doompattern74
	dw doompattern75
	dw doompattern73
	dw doompattern74
	dw doompattern54
	dw doompattern73
	dw doompattern74
	dw doompattern8
	dw doompattern76
	dw doompattern77
	dw doompattern78
	dw doompattern73
	dw doompattern74
	dw doompattern54
	dw doompattern79
	dw doompattern74
	dw doompattern8
	dw doompattern76
	dw doompattern77
	dw doompattern80
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern80
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern81
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern82
	dw doompattern45
	dw doompattern45
	dw doompattern83
	dw doompattern84
	dw doompattern85
	dw doompattern86
	dw doompattern45
	dw doompattern87
	dw doompattern88
	dw doompattern45
	dw doompattern89
	dw doompattern6
	dw doompattern45
	dw doompattern90
	dw doompattern88
	dw doompattern91
	dw doompattern92
	dw doompattern86
	dw doompattern45
	dw doompattern87
	dw doompattern88
	dw doompattern45
	dw doompattern93
	dw doompattern6
	dw doompattern45
	dw doompattern94
	dw doompattern95
	dw doompattern96
	dw doompattern97
	dw doompattern98
	dw doompattern99
	dw doompattern100
	dw doompattern88
	dw doompattern45
	dw doompattern101
	dw doompattern6
	dw doompattern45
	dw doompattern102
	dw doompattern88
	dw doompattern91
	dw doompattern92
	dw doompattern98
	dw doompattern99
	dw doompattern100
	dw doompattern88
	dw doompattern45
	dw doompattern101
	dw doompattern6
	dw doompattern45
	dw doompattern94
	dw doompattern95
	dw doompattern45
	dw doompattern45
	dw doompattern103
	dw doompattern104
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern108
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern108
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern108
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern108
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern108
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern108
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern108
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern108
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern109
	dw doompattern110
	dw doompattern111
	dw doompattern112
	dw doompattern113
	dw doompattern105
	dw doompattern106
	dw doompattern107
	dw doompattern109
	dw doompattern110
	dw doompattern111
	dw doompattern112
	dw doompattern114
	dw doompattern115
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern76
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern69
	dw doompattern116
	dw doompattern117
	dw doompattern45
	dw doompattern9
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern9
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern118
	dw doompattern45
	dw doompattern119
	dw doompattern120
	dw doompattern121
	dw doompattern122
	dw doompattern123
	dw doompattern124
	dw doompattern125
	dw doompattern126
	dw doompattern127
	dw doompattern128
	dw doompattern129
	dw doompattern130
	dw doompattern131
	dw doompattern132
	dw doompattern132
	dw doompattern132
	dw doompattern133
	dw doompattern120
	dw doompattern121
	dw doompattern122
	dw doompattern123
	dw doompattern124
	dw doompattern125
	dw doompattern126
	dw doompattern134
	dw doompattern135
	dw doompattern136
	dw doompattern137
	dw doompattern138
	dw doompattern139
	dw doompattern139
	dw doompattern139
	dw doompattern140
	dw doompattern141
	dw doompattern142
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern8
	dw doompattern45
	dw doompattern45
	dw doompattern8
doomorder2
	dw $dc00
	dw doompattern143
	dw doompattern144
	dw doompattern47
	dw doompattern3
	dw doompattern145
	dw doompattern47
	dw doompattern146
	dw doompattern144
	dw doompattern147
	dw doompattern148
	dw doompattern145
	dw doompattern149
	dw doompattern150
	dw doompattern151
	dw doompattern152
	dw doompattern153
	dw doompattern144
	dw doompattern147
	dw doompattern154
	dw doompattern155
	dw doompattern156
	dw doompattern150
	dw doompattern151
	dw doompattern152
	dw doompattern7
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern157
	dw doompattern158
	dw doompattern6
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern7
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern159
	dw doompattern45
	dw doompattern45
	dw doompattern160
	dw doompattern161
	dw doompattern162
	dw doompattern3
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern163
	dw doompattern163
	dw doompattern163
	dw doompattern163
	dw doompattern163
	dw doompattern164
	dw doompattern165
	dw doompattern165
	dw doompattern165
	dw doompattern166
	dw doompattern167
	dw doompattern167
	dw doompattern7
	dw doompattern45
	dw doompattern45
	dw doompattern160
	dw doompattern45
	dw doompattern45
	dw doompattern159
	dw doompattern45
	dw doompattern60
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern7
	dw doompattern45
	dw doompattern45
	dw doompattern160
	dw doompattern45
	dw doompattern45
	dw doompattern159
	dw doompattern45
	dw doompattern60
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern168
	dw doompattern169
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern170
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern2
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern5
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern170
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern170
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern2
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern5
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern69
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern170
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern54
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern171
	dw doompattern45
	dw doompattern45
	dw doompattern46
	dw doompattern45
	dw doompattern172
	dw doompattern173
	dw doompattern174
	dw doompattern175
	dw doompattern176
	dw doompattern177
	dw doompattern178
	dw doompattern179
	dw doompattern180
	dw doompattern173
	dw doompattern174
	dw doompattern175
	dw doompattern181
	dw doompattern179
	dw doompattern179
	dw doompattern179
	dw doompattern180
	dw doompattern173
	dw doompattern174
	dw doompattern175
	dw doompattern176
	dw doompattern177
	dw doompattern178
	dw doompattern179
	dw doompattern180
	dw doompattern173
	dw doompattern174
	dw doompattern175
	dw doompattern181
	dw doompattern179
	dw doompattern179
	dw doompattern179
	dw doompattern182
	dw doompattern183
	dw doompattern184
	dw doompattern185
	dw doompattern186
	dw doompattern187
	dw doompattern188
	dw doompattern189
	dw doompattern190
	dw doompattern183
	dw doompattern184
	dw doompattern185
	dw doompattern191
	dw doompattern189
	dw doompattern189
	dw doompattern189
	dw doompattern192
	dw doompattern173
	dw doompattern174
	dw doompattern175
	dw doompattern176
	dw doompattern177
	dw doompattern178
	dw doompattern179
	dw doompattern180
	dw doompattern173
	dw doompattern174
	dw doompattern175
	dw doompattern181
	dw doompattern179
	dw doompattern179
	dw doompattern179
	dw doompattern193
	dw doompattern194
	dw doompattern45
	dw doompattern195
	dw doompattern45
	dw doompattern59
	dw doompattern45
	dw doompattern3
	dw doompattern45
	dw doompattern8
doomorder3
	dw $dc00
	dw doompattern56
	dw doompattern196
	dw doompattern197
	dw doompattern56
	dw doompattern196
	dw doompattern197
	dw doompattern198
	dw doompattern199
	dw doompattern197
	dw doompattern56
	dw doompattern196
	dw doompattern197
	dw doompattern8
	dw doompattern200
	dw doompattern201
	dw doompattern202
	dw doompattern199
	dw doompattern197
	dw doompattern203
	dw doompattern204
	dw doompattern205
	dw doompattern8
	dw doompattern200
	dw doompattern201
	dw doompattern8
	dw doompattern56
	dw doompattern206
	dw doompattern8
	dw doompattern45
	dw doompattern45
	dw doompattern8
	dw doompattern56
	dw doompattern206
	dw doompattern8
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern207
	dw doompattern45
	dw doompattern45
	dw doompattern207
	dw doompattern208
	dw doompattern209
	dw doompattern210
	dw doompattern211
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern210
	dw doompattern211
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern212
	dw doompattern45
	dw doompattern45
	dw doompattern213
	dw doompattern45
	dw doompattern53
	dw doompattern214
	dw doompattern45
	dw doompattern118
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern212
	dw doompattern45
	dw doompattern45
	dw doompattern213
	dw doompattern45
	dw doompattern53
	dw doompattern214
	dw doompattern45
	dw doompattern118
	dw doompattern8
	dw doompattern45
	dw doompattern45
	dw doompattern215
	dw doompattern5
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern216
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern216
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern46
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern217
	dw doompattern218
	dw doompattern218
	dw doompattern218
	dw doompattern219
	dw doompattern220
	dw doompattern220
	dw doompattern220
	dw doompattern221
	dw doompattern222
	dw doompattern222
	dw doompattern222
	dw doompattern223
	dw doompattern224
	dw doompattern224
	dw doompattern224
	dw doompattern225
	dw doompattern226
	dw doompattern226
	dw doompattern226
	dw doompattern227
	dw doompattern228
	dw doompattern229
	dw doompattern230
	dw doompattern231
	dw doompattern232
	dw doompattern233
	dw doompattern234
	dw doompattern235
	dw doompattern236
	dw doompattern237
	dw doompattern238
	dw doompattern239
	dw doompattern240
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern60
	dw doompattern45
	dw doompattern61
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern60
	dw doompattern45
	dw doompattern61
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern63
	dw doompattern64
	dw doompattern241
	dw doompattern45
	dw doompattern61
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern45
	dw doompattern60
	dw doompattern45
	dw doompattern242
	dw doompattern243
	dw doompattern244
	dw doompattern245
	dw doompattern246
	dw doompattern247
	dw doompattern248
	dw doompattern249
	dw doompattern250
	dw doompattern243
	dw doompattern244
	dw doompattern245
	dw doompattern251
	dw doompattern249
	dw doompattern249
	dw doompattern249
	dw doompattern250
	dw doompattern243
	dw doompattern244
	dw doompattern245
	dw doompattern246
	dw doompattern247
	dw doompattern248
	dw doompattern249
	dw doompattern250
	dw doompattern243
	dw doompattern244
	dw doompattern245
	dw doompattern251
	dw doompattern249
	dw doompattern249
	dw doompattern249
	dw doompattern252
	dw doompattern253
	dw doompattern45
	dw doompattern55
	dw doompattern45
	dw doompattern70
	dw doompattern68
	dw doompattern45
	dw doompattern45
	dw doompattern8

doompattern0
	db $07,$00,$00,$00,$00,$00,$00,$33,$e0
doompattern1
	db $5f,$00,$00,$00,$27,$00,$00,$00,$e0
doompattern2
	db $00,$00,$00,$00,$5d,$00,$00,$00,$e0
doompattern3
	db $27,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern4
	db $5a,$00,$00,$00,$27,$00,$00,$00,$e0
doompattern5
	db $00,$00,$00,$00,$5b,$00,$00,$00,$e0
doompattern6
	db $13,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern7
	db $07,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern8
	db $01,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern9
	db $00,$00,$00,$00,$3a,$00,$00,$00,$e0
doompattern10
	db $38,$00,$00,$00,$3b,$00,$00,$00,$e0
doompattern11
	db $01,$00,$00,$00,$13,$00,$00,$00,$e0
doompattern12
	db $3a,$00,$38,$00,$36,$00,$35,$00,$e0
doompattern13
	db $33,$00,$00,$00,$3a,$00,$00,$00,$e0
doompattern14
	db $3a,$00,$38,$00,$36,$00,$38,$00,$e0
doompattern15
	db $35,$00,$36,$00,$33,$00,$31,$00,$e0
doompattern16
	db $33,$00,$35,$00,$36,$00,$38,$00,$e0
doompattern17
	db $3a,$00,$38,$00,$3a,$00,$38,$00,$e0
doompattern18
	db $36,$00,$35,$00,$33,$00,$00,$00,$e0
doompattern19
	db $3a,$00,$00,$00,$3b,$00,$00,$00,$e0
doompattern20
	db $3a,$00,$00,$00,$3d,$00,$3a,$00,$e0
doompattern21
	db $3d,$00,$3a,$00,$3d,$00,$3a,$00,$e0
doompattern22
	db $15,$13,$11,$10,$0e,$00,$00,$00,$e0
doompattern23
	db $00,$00,$01,$00,$35,$00,$00,$00,$e0
doompattern24
	db $33,$00,$00,$00,$36,$00,$00,$00,$e0
doompattern25
	db $1f,$5f,$1a,$5a,$13,$53,$1f,$5f,$e0
doompattern26
	db $5a,$5a,$53,$53,$5f,$5f,$5a,$5a,$e0
doompattern27
	db $53,$53,$5f,$5f,$5a,$5a,$53,$53,$e0
doompattern28
	db $5d,$5d,$5a,$5a,$53,$53,$5d,$5d,$e0
doompattern29
	db $5a,$5a,$53,$53,$5d,$5d,$5a,$5a,$e0
doompattern30
	db $53,$53,$5d,$5d,$5a,$5a,$53,$53,$e0
doompattern31
	db $5b,$5b,$58,$58,$4f,$4f,$5b,$5b,$e0
doompattern32
	db $58,$58,$4f,$4f,$5b,$5b,$58,$58,$e0
doompattern33
	db $4f,$4f,$5b,$5b,$58,$58,$4f,$4f,$e0
doompattern34
	db $5a,$5a,$56,$56,$4e,$4e,$5a,$5a,$e0
doompattern35
	db $56,$56,$4e,$4e,$5d,$5d,$56,$56,$e0
doompattern36
	db $4e,$4e,$5d,$5d,$56,$56,$4e,$4e,$e0
doompattern37
	db $5f,$5f,$5a,$5a,$53,$53,$5f,$5f,$e0
doompattern38
	db $5b,$5b,$58,$58,$53,$53,$5b,$5b,$e0
doompattern39
	db $58,$58,$53,$53,$5b,$5b,$58,$58,$e0
doompattern40
	db $53,$53,$5b,$5b,$58,$58,$53,$53,$e0
doompattern41
	db $5a,$5a,$55,$55,$5d,$5d,$5a,$5a,$e0
doompattern42
	db $55,$55,$5d,$5d,$5a,$5a,$55,$55,$e0
doompattern43
	db $01,$00,$00,$36,$37,$38,$39,$3a,$e0
doompattern44
	db $3b,$3c,$3d,$3e,$58,$00,$00,$00,$e0
doompattern45
	db $00,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern46
	db $00,$00,$00,$00,$58,$00,$00,$00,$e0
doompattern47
	db $00,$00,$00,$00,$56,$00,$00,$00,$e0
doompattern48
	db $00,$00,$00,$00,$54,$00,$00,$00,$e0
doompattern49
	db $00,$00,$00,$00,$0c,$4c,$0c,$4c,$e0
doompattern50
	db $0f,$4f,$0f,$4f,$0e,$4e,$0e,$4e,$e0
doompattern51
	db $00,$00,$00,$00,$4a,$00,$00,$00,$e0
doompattern52
	db $00,$00,$00,$00,$07,$47,$07,$47,$e0
doompattern53
	db $00,$00,$00,$00,$00,$00,$01,$00,$e0
doompattern54
	db $00,$00,$00,$00,$36,$00,$00,$00,$e0
doompattern55
	db $00,$00,$00,$00,$3d,$00,$00,$00,$e0
doompattern56
	db $00,$00,$00,$00,$2a,$00,$00,$00,$e0
doompattern57
	db $00,$00,$00,$00,$2c,$00,$00,$00,$e0
doompattern58
	db $36,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern59
	db $00,$00,$00,$00,$07,$00,$00,$00,$e0
doompattern60
	db $00,$00,$00,$00,$05,$00,$00,$00,$e0
doompattern61
	db $00,$00,$00,$00,$03,$00,$00,$00,$e0
doompattern62
	db $00,$00,$00,$00,$09,$00,$00,$00,$e0
doompattern63
	db $00,$00,$00,$00,$0f,$00,$00,$00,$e0
doompattern64
	db $00,$00,$03,$00,$00,$00,$00,$00,$e0
doompattern65
	db $00,$00,$0f,$00,$00,$00,$00,$00,$e0
doompattern66
	db $03,$00,$00,$00,$05,$00,$00,$00,$e0
doompattern67
	db $03,$00,$00,$00,$00,$00,$05,$00,$e0
doompattern68
	db $00,$00,$00,$00,$01,$00,$00,$00,$e0
doompattern69
	db $00,$00,$00,$00,$33,$00,$00,$00,$e0
doompattern70
	db $00,$00,$00,$00,$3f,$00,$00,$00,$e0
doompattern71
	db $3d,$3a,$38,$36,$33,$00,$00,$00,$e0
doompattern72
	db $27,$00,$00,$00,$07,$00,$00,$00,$e0
doompattern73
	db $5a,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern74
	db $36,$00,$00,$00,$5a,$00,$00,$00,$e0
doompattern75
	db $47,$00,$00,$00,$56,$00,$00,$00,$e0
doompattern76
	db $00,$00,$00,$00,$2e,$00,$00,$00,$e0
doompattern77
	db $2c,$00,$00,$00,$2c,$00,$00,$00,$e0
doompattern78
	db $01,$00,$00,$00,$36,$00,$00,$00,$e0
doompattern79
	db $3a,$00,$00,$00,$38,$00,$00,$00,$e0
doompattern80
	db $2e,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern81
	db $2c,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern82
	db $2f,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern83
	db $31,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern84
	db $00,$00,$01,$00,$31,$00,$00,$00,$e0
doompattern85
	db $35,$00,$00,$00,$38,$00,$00,$00,$e0
doompattern86
	db $07,$00,$13,$00,$11,$00,$13,$00,$e0
doompattern87
	db $00,$00,$00,$00,$00,$33,$0e,$00,$e0
doompattern88
	db $11,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern89
	db $00,$00,$00,$00,$00,$00,$00,$31,$e0
doompattern90
	db $00,$00,$00,$00,$0f,$00,$0c,$00,$e0
doompattern91
	db $00,$00,$00,$00,$15,$00,$00,$00,$e0
doompattern92
	db $00,$00,$00,$00,$16,$00,$15,$00,$e0
doompattern93
	db $00,$00,$00,$00,$00,$31,$00,$51,$e0
doompattern94
	db $00,$00,$00,$00,$15,$00,$16,$00,$e0
doompattern95
	db $15,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern96
	db $00,$00,$00,$00,$00,$35,$00,$15,$e0
doompattern97
	db $0e,$11,$15,$18,$15,$11,$0e,$0a,$e0
doompattern98
	db $13,$00,$15,$00,$16,$00,$13,$00,$e0
doompattern99
	db $15,$00,$16,$00,$15,$00,$00,$00,$e0
doompattern100
	db $13,$00,$00,$00,$0e,$00,$00,$00,$e0
doompattern101
	db $00,$00,$00,$00,$00,$00,$00,$01,$e0
doompattern102
	db $00,$00,$00,$00,$0f,$00,$0a,$00,$e0
doompattern103
	db $00,$00,$00,$55,$00,$00,$00,$01,$e0
doompattern104
	db $00,$00,$00,$00,$5f,$00,$5d,$00,$e0
doompattern105
	db $5b,$00,$5a,$00,$5b,$00,$5a,$00,$e0
doompattern106
	db $5b,$00,$5a,$00,$58,$00,$5a,$00,$e0
doompattern107
	db $58,$00,$5a,$00,$5b,$00,$5a,$00,$e0
doompattern108
	db $5b,$00,$5d,$00,$5f,$00,$5d,$00,$e0
doompattern109
	db $5b,$00,$5d,$00,$3f,$00,$3d,$00,$e0
doompattern110
	db $3b,$00,$3a,$00,$3b,$00,$3a,$00,$e0
doompattern111
	db $3b,$00,$3a,$00,$38,$00,$3a,$00,$e0
doompattern112
	db $38,$00,$3a,$00,$3b,$00,$3a,$00,$e0
doompattern113
	db $3b,$00,$3d,$00,$5f,$00,$5d,$00,$e0
doompattern114
	db $3b,$00,$3d,$00,$01,$00,$00,$00,$e0
doompattern115
	db $35,$00,$55,$00,$3a,$00,$00,$00,$e0
doompattern116
	db $00,$00,$2f,$00,$00,$00,$00,$00,$e0
doompattern117
	db $31,$00,$00,$00,$35,$00,$00,$00,$e0
doompattern118
	db $00,$00,$00,$00,$35,$00,$00,$00,$e0
doompattern119
	db $00,$00,$00,$00,$00,$00,$56,$5f,$e0
doompattern120
	db $5a,$56,$53,$5f,$5a,$56,$53,$5f,$e0
doompattern121
	db $5a,$56,$53,$5f,$5a,$56,$53,$5d,$e0
doompattern122
	db $5a,$56,$55,$5d,$5a,$56,$55,$5d,$e0
doompattern123
	db $5a,$56,$55,$5d,$5a,$56,$55,$5b,$e0
doompattern124
	db $56,$53,$56,$5a,$56,$53,$56,$5a,$e0
doompattern125
	db $56,$53,$56,$5b,$56,$53,$56,$5b,$e0
doompattern126
	db $56,$53,$56,$5d,$56,$53,$56,$5b,$e0
doompattern127
	db $56,$53,$56,$5a,$56,$53,$56,$3f,$e0
doompattern128
	db $3a,$36,$33,$3f,$3a,$36,$33,$3f,$e0
doompattern129
	db $3a,$36,$33,$3f,$3a,$36,$33,$3d,$e0
doompattern130
	db $3a,$36,$35,$3d,$3a,$36,$35,$3d,$e0
doompattern131
	db $3a,$36,$35,$3d,$3a,$36,$35,$3f,$e0
doompattern132
	db $36,$33,$36,$3d,$36,$33,$36,$3b,$e0
doompattern133
	db $36,$33,$36,$3a,$33,$36,$3a,$5f,$e0
doompattern134
	db $56,$53,$56,$5a,$56,$53,$56,$1f,$e0
doompattern135
	db $1a,$16,$13,$1f,$1a,$16,$13,$1f,$e0
doompattern136
	db $1a,$16,$13,$1f,$1a,$16,$13,$1d,$e0
doompattern137
	db $1a,$16,$15,$1d,$1a,$16,$15,$1d,$e0
doompattern138
	db $1a,$16,$15,$1d,$1a,$16,$15,$1f,$e0
doompattern139
	db $16,$13,$16,$1d,$16,$13,$16,$1b,$e0
doompattern140
	db $16,$13,$16,$1a,$00,$00,$00,$5a,$e0
doompattern141
	db $00,$00,$00,$01,$00,$00,$00,$00,$e0
doompattern142
	db $00,$00,$00,$00,$00,$00,$36,$00,$e0
doompattern143
	db $07,$00,$00,$00,$00,$01,$01,$00,$e0
doompattern144
	db $56,$00,$00,$00,$27,$00,$00,$00,$e0
doompattern145
	db $56,$00,$00,$00,$07,$00,$00,$00,$e0
doompattern146
	db $13,$00,$00,$00,$00,$5f,$01,$5a,$e0
doompattern147
	db $36,$00,$38,$00,$55,$00,$56,$00,$e0
doompattern148
	db $07,$00,$00,$00,$13,$15,$16,$18,$e0
doompattern149
	db $18,$00,$00,$00,$5b,$00,$00,$00,$e0
doompattern150
	db $5a,$00,$58,$00,$56,$00,$55,$00,$e0
doompattern151
	db $53,$00,$00,$00,$22,$00,$00,$00,$e0
doompattern152
	db $25,$00,$00,$00,$31,$00,$00,$00,$e0
doompattern153
	db $07,$0a,$0e,$11,$0e,$11,$15,$18,$e0
doompattern154
	db $07,$00,$00,$00,$56,$55,$56,$00,$e0
doompattern155
	db $56,$00,$00,$00,$31,$00,$00,$00,$e0
doompattern156
	db $3b,$00,$00,$00,$5b,$00,$00,$00,$e0
doompattern157
	db $00,$00,$00,$00,$00,$08,$09,$0a,$e0
doompattern158
	db $0b,$0c,$0d,$0e,$0f,$10,$11,$12,$e0
doompattern159
	db $03,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern160
	db $02,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern161
	db $00,$00,$00,$00,$02,$00,$00,$00,$e0
doompattern162
	db $0c,$00,$00,$00,$0f,$00,$00,$00,$e0
doompattern163
	db $02,$00,$22,$01,$02,$00,$22,$01,$e0
doompattern164
	db $02,$00,$42,$42,$02,$00,$42,$42,$e0
doompattern165
	db $03,$00,$43,$43,$03,$00,$43,$43,$e0
doompattern166
	db $05,$00,$45,$45,$05,$00,$45,$45,$e0
doompattern167
	db $05,$00,$25,$45,$05,$00,$25,$45,$e0
doompattern168
	db $00,$00,$00,$00,$45,$00,$00,$00,$e0
doompattern169
	db $00,$00,$01,$00,$5f,$00,$00,$00,$e0
doompattern170
	db $00,$00,$00,$00,$5f,$00,$00,$00,$e0
doompattern171
	db $38,$00,$36,$00,$38,$00,$00,$00,$e0
doompattern172
	db $01,$00,$00,$01,$1f,$1a,$16,$13,$e0
doompattern173
	db $1f,$1a,$16,$13,$1f,$1a,$16,$13,$e0
doompattern174
	db $1f,$1a,$16,$13,$1d,$1a,$16,$15,$e0
doompattern175
	db $1d,$1a,$16,$15,$1d,$1a,$16,$15,$e0
doompattern176
	db $1d,$1a,$16,$15,$1b,$16,$13,$16,$e0
doompattern177
	db $1a,$16,$13,$16,$1a,$16,$13,$16,$e0
doompattern178
	db $1b,$16,$13,$16,$1b,$16,$13,$16,$e0
doompattern179
	db $1d,$16,$13,$16,$1b,$16,$13,$16,$e0
doompattern180
	db $1a,$16,$13,$16,$1f,$1a,$16,$13,$e0
doompattern181
	db $1d,$1a,$16,$15,$1f,$16,$13,$16,$e0
doompattern182
	db $1a,$16,$13,$16,$3f,$3a,$36,$33,$e0
doompattern183
	db $3f,$3a,$36,$33,$3f,$3a,$36,$33,$e0
doompattern184
	db $3f,$3a,$36,$33,$3d,$3a,$36,$35,$e0
doompattern185
	db $3d,$3a,$36,$35,$3d,$3a,$36,$35,$e0
doompattern186
	db $3d,$3a,$36,$35,$3b,$36,$33,$36,$e0
doompattern187
	db $3a,$36,$33,$36,$3a,$36,$33,$36,$e0
doompattern188
	db $3b,$36,$33,$36,$3b,$36,$33,$36,$e0
doompattern189
	db $3d,$36,$33,$36,$3b,$36,$33,$36,$e0
doompattern190
	db $3a,$36,$33,$36,$3f,$3a,$36,$33,$e0
doompattern191
	db $3d,$3a,$36,$35,$3f,$36,$33,$36,$e0
doompattern192
	db $3a,$36,$33,$36,$1f,$1a,$16,$13,$e0
doompattern193
	db $1a,$16,$13,$16,$00,$00,$00,$00,$e0
doompattern194
	db $56,$00,$00,$00,$00,$00,$01,$00,$e0
doompattern195
	db $00,$38,$00,$00,$00,$00,$00,$00,$e0
doompattern196
	db $53,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern197
	db $2a,$00,$00,$00,$53,$00,$00,$00,$e0
doompattern198
	db $5f,$00,$00,$00,$5a,$00,$58,$00,$e0
doompattern199
	db $5b,$00,$00,$00,$3a,$00,$00,$00,$e0
doompattern200
	db $00,$00,$00,$00,$22,$00,$00,$00,$e0
doompattern201
	db $25,$00,$00,$00,$35,$00,$00,$00,$e0
doompattern202
	db $3f,$00,$00,$00,$3a,$00,$38,$00,$e0
doompattern203
	db $5a,$58,$5a,$00,$5a,$58,$5a,$00,$e0
doompattern204
	db $33,$00,$00,$00,$5d,$00,$00,$00,$e0
doompattern205
	db $4a,$00,$00,$00,$53,$00,$00,$00,$e0
doompattern206
	db $29,$00,$00,$00,$2c,$00,$00,$00,$e0
doompattern207
	db $2a,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern208
	db $00,$00,$00,$01,$2a,$00,$00,$00,$e0
doompattern209
	db $2c,$00,$00,$00,$2f,$00,$00,$00,$e0
doompattern210
	db $00,$00,$00,$00,$42,$00,$4e,$01,$e0
doompattern211
	db $4e,$01,$4e,$01,$00,$00,$00,$00,$e0
doompattern212
	db $22,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern213
	db $25,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern214
	db $33,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern215
	db $35,$00,$00,$00,$00,$55,$00,$00,$e0
doompattern216
	db $00,$00,$00,$00,$5a,$00,$00,$00,$e0
doompattern217
	db $00,$00,$00,$00,$2c,$4c,$2c,$4c,$e0
doompattern218
	db $2c,$4c,$2c,$4c,$2c,$4c,$2c,$4c,$e0
doompattern219
	db $2c,$4c,$2c,$4c,$2e,$2e,$2e,$2e,$e0
doompattern220
	db $2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e,$e0
doompattern221
	db $2e,$2e,$2e,$2e,$2f,$2f,$2f,$2f,$e0
doompattern222
	db $2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$e0
doompattern223
	db $2f,$2f,$2f,$2f,$31,$31,$31,$31,$e0
doompattern224
	db $31,$31,$31,$31,$31,$31,$31,$31,$e0
doompattern225
	db $31,$31,$31,$31,$0c,$4c,$0c,$4c,$e0
doompattern226
	db $0c,$4c,$0c,$4c,$0c,$4c,$0c,$4c,$e0
doompattern227
	db $0c,$4c,$0c,$4c,$02,$22,$02,$22,$e0
doompattern228
	db $02,$22,$02,$22,$0e,$2e,$02,$22,$e0
doompattern229
	db $02,$22,$0e,$2e,$02,$22,$02,$22,$e0
doompattern230
	db $02,$22,$02,$22,$02,$22,$0e,$2e,$e0
doompattern231
	db $02,$22,$02,$22,$03,$23,$03,$23,$e0
doompattern232
	db $03,$23,$03,$23,$0f,$2f,$03,$23,$e0
doompattern233
	db $03,$23,$0f,$2f,$03,$23,$03,$23,$e0
doompattern234
	db $03,$23,$03,$23,$03,$23,$0f,$2f,$e0
doompattern235
	db $03,$23,$03,$23,$05,$25,$05,$25,$e0
doompattern236
	db $05,$25,$05,$25,$11,$31,$05,$25,$e0
doompattern237
	db $05,$25,$11,$31,$05,$25,$05,$25,$e0
doompattern238
	db $05,$25,$05,$25,$05,$25,$11,$25,$e0
doompattern239
	db $05,$25,$05,$25,$00,$00,$2e,$00,$e0
doompattern240
	db $4e,$00,$01,$00,$03,$00,$00,$00,$e0
doompattern241
	db $05,$00,$00,$00,$00,$00,$00,$00,$e0
doompattern242
	db $00,$00,$06,$00,$01,$36,$3f,$3a,$e0
doompattern243
	db $36,$33,$3f,$3a,$36,$33,$3f,$3a,$e0
doompattern244
	db $36,$33,$3f,$3a,$36,$33,$3d,$3a,$e0
doompattern245
	db $36,$35,$3d,$3a,$36,$35,$3d,$3a,$e0
doompattern246
	db $36,$35,$3d,$3a,$36,$35,$3b,$36,$e0
doompattern247
	db $33,$36,$3a,$36,$33,$36,$3a,$36,$e0
doompattern248
	db $33,$36,$3b,$36,$33,$36,$3b,$36,$e0
doompattern249
	db $33,$36,$3d,$36,$33,$36,$3b,$36,$e0
doompattern250
	db $33,$36,$3a,$36,$33,$36,$3f,$3a,$e0
doompattern251
	db $36,$35,$3d,$3a,$36,$35,$3f,$36,$e0
doompattern252
	db $33,$36,$3a,$36,$33,$00,$00,$00,$e0
doompattern253
	db $00,$53,$00,$00,$00,$00,$00,$00,$e0



; -------------------------------
; SONG : GALAXY. By Utz.
; -------------------------------
musicData5
	db $06
	dw galorder0
	dw galorder1
	dw galorder2
	dw galorder3

galorder0
	dw $e600
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern1
	dw galpattern2
	dw galpattern0
	dw galpattern3
	dw galpattern4
	dw galpattern0
	dw galpattern0
	dw galpattern5
	dw galpattern1
	dw galpattern2
	dw galpattern0
	dw galpattern0
	dw galpattern6
	dw galpattern7
	dw galpattern0
	dw galpattern5
	dw galpattern1
	dw galpattern2
	dw galpattern0
	dw galpattern3
	dw galpattern4
	dw galpattern0
	dw galpattern0
	dw galpattern5
	dw galpattern1
	dw galpattern2
	dw galpattern0
	dw galpattern0
	dw galpattern6
	dw galpattern7
	dw galpattern0
	dw galpattern3
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern8
	dw galpattern8
	dw galpattern8
	dw galpattern8
	dw galpattern8
	dw galpattern8
	dw galpattern8
	dw galpattern9
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern6
	dw galpattern10
	dw galpattern10
	dw galpattern10
	dw galpattern10
	dw galpattern10
	dw galpattern10
	dw galpattern11
	dw galpattern12
	dw galpattern13
	dw galpattern14
	dw galpattern15
	dw galpattern16
	dw galpattern16
	dw galpattern17
	dw galpattern18
	dw galpattern19
	dw galpattern20
	dw galpattern21
	dw galpattern22
	dw galpattern15
	dw galpattern13
	dw galpattern23
	dw galpattern23
	dw galpattern24
	dw galpattern19
	dw galpattern17
	dw galpattern25
	dw galpattern26
	dw galpattern27
	dw galpattern13
	dw galpattern14
	dw galpattern15
	dw galpattern16
	dw galpattern16
	dw galpattern17
	dw galpattern18
	dw galpattern19
	dw galpattern20
	dw galpattern21
	dw galpattern22
	dw galpattern15
	dw galpattern13
	dw galpattern23
	dw galpattern23
	dw galpattern24
	dw galpattern19
	dw galpattern17
	dw galpattern25
	dw galpattern26
	dw galpattern27
	dw galpattern13
	dw galpattern14
	dw galpattern15
	dw galpattern16
	dw galpattern13
	dw galpattern14
	dw galpattern15
	dw galpattern16
	dw galpattern16
	dw galpattern17
	dw galpattern18
	dw galpattern19
	dw galpattern20
	dw galpattern21
	dw galpattern22
	dw galpattern15
	dw galpattern13
	dw galpattern23
	dw galpattern23
	dw galpattern24
	dw galpattern19
	dw galpattern17
	dw galpattern25
	dw galpattern26
	dw galpattern27
	dw galpattern28
	dw galpattern29
	dw galpattern30
	dw galpattern31
	dw galpattern28
	dw galpattern29
	dw galpattern30
	dw galpattern31
	dw galpattern32
	dw galpattern0
	dw galpattern33
	dw galpattern34
	dw galpattern35
	dw galpattern36
	dw galpattern36
	dw galpattern37
	dw galpattern38
	dw galpattern39
	dw galpattern40
	dw galpattern40
	dw galpattern41
	dw galpattern42
	dw galpattern43
	dw galpattern44
	dw galpattern44
	dw galpattern37
	dw galpattern38
	dw galpattern39
	dw galpattern40
	dw galpattern40
	dw galpattern45
	dw galpattern46
	dw galpattern47
	dw galpattern48
	dw galpattern48
	dw galpattern49
	dw galpattern38
	dw galpattern39
	dw galpattern40
	dw galpattern40
	dw galpattern41
	dw galpattern42
	dw galpattern43
	dw galpattern44
	dw galpattern44
	dw galpattern37
	dw galpattern38
	dw galpattern39
	dw galpattern40
	dw galpattern40
	dw galpattern45
	dw galpattern46
	dw galpattern47
	dw galpattern48
	dw galpattern48
	dw galpattern49
	dw galpattern38
	dw galpattern39
	dw galpattern40
	dw galpattern40
	dw galpattern41
	dw galpattern42
	dw galpattern43
	dw galpattern44
	dw galpattern44
	dw galpattern37
	dw galpattern38
	dw galpattern39
	dw galpattern40
	dw galpattern40
	dw galpattern50
	dw galpattern34
	dw galpattern35
	dw galpattern36
	dw galpattern36
	dw galpattern37
	dw galpattern38
	dw galpattern39
	dw galpattern40
	dw galpattern40
	dw galpattern41
	dw galpattern42
	dw galpattern43
	dw galpattern44
	dw galpattern44
	dw galpattern37
	dw galpattern38
	dw galpattern39
	dw galpattern40
	dw galpattern40
	dw galpattern51
	dw galpattern52
	dw galpattern53
	dw galpattern54
	dw galpattern0
	dw galpattern2
galorder1
	dw $e600
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern55
	dw galpattern56
	dw galpattern56
	dw galpattern56
	dw galpattern57
	dw galpattern57
	dw galpattern57
	dw galpattern57
	dw galpattern58
	dw galpattern58
	dw galpattern58
	dw galpattern58
	dw galpattern57
	dw galpattern57
	dw galpattern57
	dw galpattern57
	dw galpattern59
	dw galpattern60
	dw galpattern61
	dw galpattern62
	dw galpattern63
	dw galpattern63
	dw galpattern64
	dw galpattern65
	dw galpattern66
	dw galpattern66
	dw galpattern66
	dw galpattern67
	dw galpattern68
	dw galpattern68
	dw galpattern64
	dw galpattern69
	dw galpattern59
	dw galpattern60
	dw galpattern61
	dw galpattern62
	dw galpattern63
	dw galpattern63
	dw galpattern64
	dw galpattern65
	dw galpattern66
	dw galpattern66
	dw galpattern66
	dw galpattern67
	dw galpattern68
	dw galpattern68
	dw galpattern64
	dw galpattern69
	dw galpattern59
	dw galpattern60
	dw galpattern61
	dw galpattern62
	dw galpattern63
	dw galpattern63
	dw galpattern64
	dw galpattern65
	dw galpattern66
	dw galpattern66
	dw galpattern66
	dw galpattern67
	dw galpattern68
	dw galpattern68
	dw galpattern70
	dw galpattern71
	dw galpattern72
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern73
	dw galpattern0
	dw galpattern0
	dw galpattern74
	dw galpattern0
	dw galpattern75
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern76
	dw galpattern0
	dw galpattern0
	dw galpattern77
	dw galpattern0
	dw galpattern0
	dw galpattern72
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern73
	dw galpattern0
	dw galpattern0
	dw galpattern74
	dw galpattern0
	dw galpattern75
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern76
	dw galpattern0
	dw galpattern0
	dw galpattern77
	dw galpattern0
	dw galpattern0
	dw galpattern78
	dw galpattern79
	dw galpattern80
	dw galpattern81
	dw galpattern78
	dw galpattern79
	dw galpattern80
	dw galpattern81
	dw galpattern82
	dw galpattern83
	dw galpattern84
	dw galpattern85
	dw galpattern86
	dw galpattern87
	dw galpattern88
	dw galpattern89
	dw galpattern78
	dw galpattern90
	dw galpattern90
	dw galpattern91
	dw galpattern92
	dw galpattern93
	dw galpattern94
	dw galpattern95
	dw galpattern96
	dw galpattern97
	dw galpattern0
	dw galpattern98
	dw galpattern0
	dw galpattern97
	dw galpattern0
	dw galpattern98
	dw galpattern0
	dw galpattern99
	dw galpattern0
	dw galpattern100
	dw galpattern101
	dw galpattern102
	dw galpattern103
	dw galpattern103
	dw galpattern104
	dw galpattern101
	dw galpattern102
	dw galpattern103
	dw galpattern103
	dw galpattern104
	dw galpattern101
	dw galpattern102
	dw galpattern103
	dw galpattern103
	dw galpattern104
	dw galpattern101
	dw galpattern102
	dw galpattern103
	dw galpattern103
	dw galpattern105
	dw galpattern106
	dw galpattern74
	dw galpattern0
	dw galpattern0
	dw galpattern107
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern108
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern109
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern52
	dw galpattern106
	dw galpattern74
	dw galpattern0
	dw galpattern0
	dw galpattern107
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern108
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern109
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern52
	dw galpattern106
	dw galpattern74
	dw galpattern0
	dw galpattern0
	dw galpattern107
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern108
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern109
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern110
	dw galpattern111
	dw galpattern112
	dw galpattern113
	dw galpattern110
	dw galpattern0
galorder2
	dw $e600
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern114
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern115
	dw galpattern116
	dw galpattern117
	dw galpattern118
	dw galpattern119
	dw galpattern120
	dw galpattern120
	dw galpattern121
	dw galpattern122
	dw galpattern120
	dw galpattern120
	dw galpattern120
	dw galpattern123
	dw galpattern124
	dw galpattern125
	dw galpattern121
	dw galpattern126
	dw galpattern127
	dw galpattern128
	dw galpattern129
	dw galpattern130
	dw galpattern131
	dw galpattern131
	dw galpattern132
	dw galpattern133
	dw galpattern134
	dw galpattern134
	dw galpattern135
	dw galpattern136
	dw galpattern137
	dw galpattern138
	dw galpattern139
	dw galpattern140
	dw galpattern141
	dw galpattern142
	dw galpattern143
	dw galpattern144
	dw galpattern131
	dw galpattern131
	dw galpattern132
	dw galpattern133
	dw galpattern134
	dw galpattern134
	dw galpattern135
	dw galpattern136
	dw galpattern137
	dw galpattern138
	dw galpattern145
	dw galpattern146
	dw galpattern147
	dw galpattern148
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern149
	dw galpattern150
	dw galpattern151
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern152
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern153
	dw galpattern0
	dw galpattern147
	dw galpattern148
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern149
	dw galpattern150
	dw galpattern151
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern154
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern153
	dw galpattern0
	dw galpattern13
	dw galpattern14
	dw galpattern15
	dw galpattern16
	dw galpattern13
	dw galpattern14
	dw galpattern15
	dw galpattern16
	dw galpattern16
	dw galpattern17
	dw galpattern18
	dw galpattern19
	dw galpattern20
	dw galpattern21
	dw galpattern155
	dw galpattern156
	dw galpattern156
	dw galpattern156
	dw galpattern156
	dw galpattern157
	dw galpattern158
	dw galpattern158
	dw galpattern159
	dw galpattern160
	dw galpattern160
	dw galpattern161
	dw galpattern0
	dw galpattern162
	dw galpattern0
	dw galpattern161
	dw galpattern0
	dw galpattern162
	dw galpattern163
	dw galpattern164
	dw galpattern0
	dw galpattern165
	dw galpattern166
	dw galpattern167
	dw galpattern168
	dw galpattern168
	dw galpattern169
	dw galpattern166
	dw galpattern167
	dw galpattern168
	dw galpattern168
	dw galpattern169
	dw galpattern166
	dw galpattern167
	dw galpattern168
	dw galpattern168
	dw galpattern169
	dw galpattern166
	dw galpattern167
	dw galpattern168
	dw galpattern168
	dw galpattern170
	dw galpattern171
	dw galpattern172
	dw galpattern173
	dw galpattern173
	dw galpattern174
	dw galpattern166
	dw galpattern167
	dw galpattern168
	dw galpattern168
	dw galpattern169
	dw galpattern166
	dw galpattern167
	dw galpattern168
	dw galpattern168
	dw galpattern169
	dw galpattern166
	dw galpattern167
	dw galpattern168
	dw galpattern168
	dw galpattern175
	dw galpattern176
	dw galpattern177
	dw galpattern178
	dw galpattern178
	dw galpattern179
	dw galpattern180
	dw galpattern181
	dw galpattern182
	dw galpattern183
	dw galpattern184
	dw galpattern185
	dw galpattern186
	dw galpattern182
	dw galpattern183
	dw galpattern187
	dw galpattern188
	dw galpattern189
	dw galpattern190
	dw galpattern191
	dw galpattern192
	dw galpattern193
	dw galpattern194
	dw galpattern178
	dw galpattern178
	dw galpattern195
	dw galpattern196
	dw galpattern197
	dw galpattern198
	dw galpattern199
	dw galpattern200
	dw galpattern201
	dw galpattern202
	dw galpattern203
	dw galpattern197
	dw galpattern204
	dw galpattern205
	dw galpattern206
	dw galpattern207
	dw galpattern191
	dw galpattern208
	dw galpattern209
	dw galpattern210
	dw galpattern211
	dw galpattern212
	dw galpattern0
galorder3
	dw $e600
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern213
	dw galpattern214
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern215
	dw galpattern216
	dw galpattern217
	dw galpattern218
	dw galpattern219
	dw galpattern220
	dw galpattern220
	dw galpattern221
	dw galpattern221
	dw galpattern220
	dw galpattern220
	dw galpattern220
	dw galpattern222
	dw galpattern223
	dw galpattern223
	dw galpattern221
	dw galpattern224
	dw galpattern225
	dw galpattern226
	dw galpattern218
	dw galpattern219
	dw galpattern227
	dw galpattern227
	dw galpattern228
	dw galpattern228
	dw galpattern227
	dw galpattern227
	dw galpattern227
	dw galpattern229
	dw galpattern230
	dw galpattern230
	dw galpattern228
	dw galpattern231
	dw galpattern232
	dw galpattern233
	dw galpattern234
	dw galpattern235
	dw galpattern220
	dw galpattern220
	dw galpattern221
	dw galpattern221
	dw galpattern220
	dw galpattern220
	dw galpattern220
	dw galpattern222
	dw galpattern223
	dw galpattern223
	dw galpattern236
	dw galpattern237
	dw galpattern238
	dw galpattern239
	dw galpattern0
	dw galpattern0
	dw galpattern240
	dw galpattern241
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern242
	dw galpattern243
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern244
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern245
	dw galpattern0
	dw galpattern238
	dw galpattern239
	dw galpattern0
	dw galpattern0
	dw galpattern240
	dw galpattern241
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern242
	dw galpattern243
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern244
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern245
	dw galpattern0
	dw galpattern246
	dw galpattern246
	dw galpattern246
	dw galpattern246
	dw galpattern246
	dw galpattern246
	dw galpattern246
	dw galpattern246
	dw galpattern246
	dw galpattern247
	dw galpattern247
	dw galpattern247
	dw galpattern248
	dw galpattern248
	dw galpattern249
	dw galpattern250
	dw galpattern250
	dw galpattern250
	dw galpattern250
	dw galpattern251
	dw galpattern252
	dw galpattern252
	dw galpattern253
	dw galpattern254
	dw galpattern254
	dw galpattern28
	dw galpattern29
	dw galpattern30
	dw galpattern31
	dw galpattern28
	dw galpattern29
	dw galpattern30
	dw galpattern31
	dw galpattern255
	dw galpattern256
	dw galpattern257
	dw galpattern258
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern259
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern260
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern259
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern52
	dw galpattern106
	dw galpattern74
	dw galpattern0
	dw galpattern0
	dw galpattern261
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern262
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern261
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern52
	dw galpattern106
	dw galpattern74
	dw galpattern0
	dw galpattern0
	dw galpattern261
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern262
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern261
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern263
	dw galpattern106
	dw galpattern74
	dw galpattern0
	dw galpattern0
	dw galpattern261
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern262
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern261
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern0
	dw galpattern110
	dw galpattern264
	dw galpattern265
	dw galpattern266
	dw galpattern267
	dw galpattern2

galpattern0
	db $00,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern1
	db $07,$47,$07,$47,$13,$53,$00,$00,$e0
galpattern2
	db $01,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern3
	db $00,$00,$00,$00,$13,$53,$13,$53,$e0
galpattern4
	db $07,$47,$07,$47,$00,$00,$01,$00,$e0
galpattern5
	db $00,$00,$00,$00,$00,$00,$13,$53,$e0
galpattern6
	db $07,$47,$07,$47,$13,$53,$13,$53,$e0
galpattern7
	db $00,$00,$01,$00,$00,$00,$00,$00,$e0
galpattern8
	db $05,$45,$05,$45,$11,$51,$11,$51,$e0
galpattern9
	db $05,$45,$05,$45,$11,$51,$11,$11,$e0
galpattern10
	db $02,$42,$02,$42,$0e,$4e,$0e,$4e,$e0
galpattern11
	db $02,$42,$02,$42,$45,$00,$00,$01,$e0
galpattern12
	db $44,$00,$00,$01,$43,$00,$00,$01,$e0
galpattern13
	db $02,$00,$00,$00,$0e,$00,$00,$00,$e0
galpattern14
	db $13,$00,$15,$00,$02,$00,$00,$00,$e0
galpattern15
	db $0e,$00,$00,$00,$13,$00,$15,$00,$e0
galpattern16
	db $02,$00,$0e,$00,$13,$00,$15,$00,$e0
galpattern17
	db $05,$00,$00,$00,$11,$00,$00,$00,$e0
galpattern18
	db $15,$00,$16,$00,$05,$00,$00,$00,$e0
galpattern19
	db $11,$00,$00,$00,$15,$00,$16,$00,$e0
galpattern20
	db $03,$00,$00,$00,$0f,$00,$00,$00,$e0
galpattern21
	db $15,$00,$16,$00,$03,$00,$0f,$00,$e0
galpattern22
	db $15,$00,$16,$00,$02,$00,$00,$00,$e0
galpattern23
	db $13,$00,$15,$00,$02,$00,$0e,$00,$e0
galpattern24
	db $13,$00,$15,$00,$05,$00,$00,$00,$e0
galpattern25
	db $15,$00,$16,$00,$03,$00,$00,$00,$e0
galpattern26
	db $0f,$00,$00,$00,$15,$00,$16,$00,$e0
galpattern27
	db $03,$00,$0f,$00,$15,$00,$16,$00,$e0
galpattern28
	db $1f,$1c,$18,$15,$18,$15,$10,$0c,$e0
galpattern29
	db $10,$0c,$09,$05,$04,$00,$00,$00,$e0
galpattern30
	db $03,$07,$0a,$0e,$0a,$0e,$11,$15,$e0
galpattern31
	db $11,$15,$18,$1c,$1d,$00,$00,$00,$e0
galpattern32
	db $3d,$00,$00,$00,$5d,$00,$00,$00,$e0
galpattern33
	db $00,$00,$5c,$5b,$5a,$00,$00,$00,$e0
galpattern34
	db $5a,$00,$00,$00,$5f,$00,$55,$00,$e0
galpattern35
	db $5a,$00,$00,$00,$5a,$00,$00,$00,$e0
galpattern36
	db $5f,$00,$55,$00,$5a,$00,$5a,$00,$e0
galpattern37
	db $5f,$00,$55,$00,$58,$00,$00,$00,$e0
galpattern38
	db $58,$00,$00,$00,$5f,$00,$55,$00,$e0
galpattern39
	db $58,$00,$00,$00,$58,$00,$00,$00,$e0
galpattern40
	db $5f,$00,$55,$00,$58,$00,$58,$00,$e0
galpattern41
	db $5f,$00,$55,$00,$4a,$00,$00,$00,$e0
galpattern42
	db $4a,$00,$00,$00,$5f,$00,$55,$00,$e0
galpattern43
	db $4a,$00,$00,$00,$4a,$00,$00,$00,$e0
galpattern44
	db $5f,$00,$55,$00,$4a,$00,$4a,$00,$e0
galpattern45
	db $5f,$00,$55,$00,$3a,$00,$00,$00,$e0
galpattern46
	db $3a,$00,$00,$00,$3f,$00,$35,$00,$e0
galpattern47
	db $3a,$00,$00,$00,$3a,$00,$00,$00,$e0
galpattern48
	db $3f,$00,$35,$00,$3a,$00,$3a,$00,$e0
galpattern49
	db $3f,$00,$35,$00,$58,$00,$00,$00,$e0
galpattern50
	db $5f,$00,$55,$00,$5a,$00,$00,$00,$e0
galpattern51
	db $5f,$00,$55,$00,$00,$00,$01,$00,$e0
galpattern52
	db $00,$00,$00,$00,$07,$00,$00,$00,$e0
galpattern53
	db $13,$00,$00,$00,$00,$33,$00,$00,$e0
galpattern54
	db $00,$00,$53,$00,$00,$00,$00,$00,$e0
galpattern55
	db $00,$36,$00,$00,$01,$36,$00,$00,$e0
galpattern56
	db $01,$36,$00,$00,$01,$36,$00,$00,$e0
galpattern57
	db $01,$35,$00,$00,$01,$35,$00,$00,$e0
galpattern58
	db $01,$33,$00,$00,$01,$33,$00,$00,$e0
galpattern59
	db $13,$36,$00,$00,$13,$36,$00,$00,$e0
galpattern60
	db $13,$36,$00,$00,$15,$36,$00,$00,$e0
galpattern61
	db $1a,$36,$00,$00,$1a,$36,$00,$00,$e0
galpattern62
	db $1a,$36,$00,$00,$11,$36,$00,$00,$e0
galpattern63
	db $11,$35,$00,$00,$11,$35,$00,$00,$e0
galpattern64
	db $18,$35,$00,$00,$18,$35,$00,$00,$e0
galpattern65
	db $18,$35,$00,$00,$1a,$35,$00,$00,$e0
galpattern66
	db $11,$33,$00,$00,$11,$33,$00,$00,$e0
galpattern67
	db $11,$33,$00,$00,$13,$33,$00,$00,$e0
galpattern68
	db $15,$35,$00,$00,$15,$35,$00,$00,$e0
galpattern69
	db $18,$35,$00,$00,$16,$35,$00,$00,$e0
galpattern70
	db $18,$35,$00,$00,$31,$00,$00,$01,$e0
galpattern71
	db $30,$00,$00,$01,$2f,$00,$00,$01,$e0
galpattern72
	db $2e,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern73
	db $31,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern74
	db $13,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern75
	db $00,$00,$00,$00,$2e,$00,$00,$00,$e0
galpattern76
	db $00,$00,$00,$00,$31,$00,$00,$00,$e0
galpattern77
	db $00,$00,$00,$00,$13,$00,$00,$00,$e0
galpattern78
	db $0e,$00,$00,$00,$1a,$00,$00,$00,$e0
galpattern79
	db $1f,$00,$1f,$00,$2e,$00,$00,$00,$e0
galpattern80
	db $3a,$00,$00,$00,$3f,$00,$3f,$00,$e0
galpattern81
	db $0e,$00,$1a,$00,$1f,$00,$1f,$00,$e0
galpattern82
	db $0e,$00,$1a,$00,$3f,$00,$3f,$00,$e0
galpattern83
	db $31,$00,$00,$00,$3d,$00,$00,$00,$e0
galpattern84
	db $5f,$00,$5f,$00,$51,$00,$00,$00,$e0
galpattern85
	db $5d,$00,$00,$00,$3f,$00,$3f,$00,$e0
galpattern86
	db $2f,$00,$00,$00,$3b,$00,$00,$00,$e0
galpattern87
	db $1f,$00,$1f,$00,$0f,$00,$1b,$00,$e0
galpattern88
	db $1f,$00,$1f,$00,$0e,$00,$00,$00,$e0
galpattern89
	db $1a,$00,$00,$00,$1f,$00,$1f,$00,$e0
galpattern90
	db $1f,$00,$1f,$00,$0e,$00,$1a,$00,$e0
galpattern91
	db $1f,$00,$1f,$00,$11,$00,$00,$00,$e0
galpattern92
	db $1d,$00,$00,$00,$1f,$00,$1f,$00,$e0
galpattern93
	db $11,$00,$00,$00,$1d,$00,$00,$00,$e0
galpattern94
	db $1f,$00,$1f,$00,$0f,$00,$00,$00,$e0
galpattern95
	db $1b,$00,$00,$00,$1f,$00,$1f,$00,$e0
galpattern96
	db $0f,$00,$1b,$00,$1f,$00,$1f,$00,$e0
galpattern97
	db $09,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern98
	db $07,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern99
	db $00,$00,$27,$00,$00,$00,$47,$00,$e0
galpattern100
	db $00,$00,$00,$00,$53,$00,$00,$00,$e0
galpattern101
	db $53,$00,$00,$00,$56,$00,$51,$00,$e0
galpattern102
	db $53,$00,$00,$00,$53,$00,$00,$00,$e0
galpattern103
	db $56,$00,$51,$00,$53,$00,$53,$00,$e0
galpattern104
	db $56,$00,$51,$00,$53,$00,$00,$00,$e0
galpattern105
	db $56,$00,$51,$00,$07,$00,$00,$00,$e0
galpattern106
	db $07,$00,$08,$09,$0c,$10,$11,$12,$e0
galpattern107
	db $00,$00,$00,$00,$15,$00,$00,$00,$e0
galpattern108
	db $00,$00,$00,$00,$16,$00,$00,$00,$e0
galpattern109
	db $00,$00,$00,$00,$0c,$00,$00,$00,$e0
galpattern110
	db $00,$00,$00,$00,$00,$00,$01,$00,$e0
galpattern111
	db $00,$00,$00,$00,$00,$0a,$00,$00,$e0
galpattern112
	db $00,$16,$00,$00,$00,$00,$36,$00,$e0
galpattern113
	db $00,$00,$00,$56,$00,$00,$00,$00,$e0
galpattern114
	db $00,$00,$3a,$00,$3a,$01,$3a,$00,$e0
galpattern115
	db $3a,$01,$3a,$00,$3a,$01,$3a,$00,$e0
galpattern116
	db $00,$13,$3a,$00,$00,$13,$3a,$00,$e0
galpattern117
	db $00,$13,$3a,$00,$00,$16,$3a,$00,$e0
galpattern118
	db $00,$1a,$3a,$00,$00,$1a,$3a,$00,$e0
galpattern119
	db $00,$1a,$3a,$00,$00,$11,$3a,$00,$e0
galpattern120
	db $00,$11,$3a,$00,$00,$11,$3a,$00,$e0
galpattern121
	db $00,$18,$3a,$00,$00,$18,$3a,$00,$e0
galpattern122
	db $00,$18,$3a,$00,$00,$1a,$3a,$00,$e0
galpattern123
	db $00,$11,$3a,$00,$00,$15,$3a,$00,$e0
galpattern124
	db $38,$15,$3a,$00,$00,$15,$3a,$00,$e0
galpattern125
	db $00,$15,$3a,$00,$00,$15,$3a,$00,$e0
galpattern126
	db $00,$18,$3a,$00,$00,$16,$3a,$00,$e0
galpattern127
	db $01,$13,$0e,$00,$00,$13,$0e,$00,$e0
galpattern128
	db $00,$13,$0e,$00,$0f,$11,$12,$00,$e0
galpattern129
	db $13,$1a,$13,$00,$00,$1a,$13,$00,$e0
galpattern130
	db $00,$1a,$13,$00,$00,$11,$13,$00,$e0
galpattern131
	db $00,$11,$15,$00,$00,$11,$15,$00,$e0
galpattern132
	db $00,$18,$11,$00,$00,$18,$11,$00,$e0
galpattern133
	db $00,$18,$11,$00,$00,$1a,$11,$00,$e0
galpattern134
	db $00,$11,$11,$00,$00,$11,$11,$00,$e0
galpattern135
	db $00,$11,$31,$00,$00,$11,$31,$00,$e0
galpattern136
	db $00,$11,$31,$00,$00,$15,$31,$00,$e0
galpattern137
	db $38,$15,$31,$00,$00,$15,$31,$00,$e0
galpattern138
	db $00,$15,$31,$00,$00,$15,$31,$00,$e0
galpattern139
	db $00,$18,$31,$00,$00,$18,$31,$00,$e0
galpattern140
	db $00,$18,$31,$00,$00,$16,$31,$00,$e0
galpattern141
	db $01,$13,$3a,$00,$00,$13,$3a,$00,$e0
galpattern142
	db $00,$13,$3a,$00,$2f,$11,$3a,$00,$e0
galpattern143
	db $33,$1a,$3a,$00,$00,$1a,$3a,$00,$e0
galpattern144
	db $00,$0e,$2e,$2f,$00,$11,$35,$00,$e0
galpattern145
	db $00,$1a,$31,$00,$3d,$00,$00,$01,$e0
galpattern146
	db $3c,$00,$00,$01,$3b,$00,$00,$01,$e0
galpattern147
	db $33,$00,$00,$00,$01,$00,$33,$36,$e0
galpattern148
	db $38,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern149
	db $3a,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern150
	db $00,$00,$00,$00,$33,$00,$00,$00,$e0
galpattern151
	db $01,$00,$33,$36,$38,$00,$00,$00,$e0
galpattern152
	db $36,$00,$35,$00,$33,$35,$33,$00,$e0
galpattern153
	db $00,$00,$00,$00,$3a,$00,$00,$00,$e0
galpattern154
	db $36,$00,$35,$00,$36,$38,$36,$00,$e0
galpattern155
	db $15,$00,$16,$00,$00,$4e,$51,$55,$e0
galpattern156
	db $58,$55,$58,$5c,$5f,$4e,$51,$55,$e0
galpattern157
	db $58,$55,$58,$5c,$5f,$51,$55,$58,$e0
galpattern158
	db $5c,$58,$5c,$5f,$5d,$51,$55,$58,$e0
galpattern159
	db $5c,$58,$5c,$5f,$5d,$4f,$53,$56,$e0
galpattern160
	db $5a,$56,$5a,$5d,$5f,$4f,$53,$56,$e0
galpattern161
	db $04,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern162
	db $0a,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern163
	db $00,$00,$00,$00,$00,$00,$2a,$00,$e0
galpattern164
	db $00,$00,$4a,$00,$00,$00,$00,$00,$e0
galpattern165
	db $00,$00,$00,$00,$56,$00,$00,$00,$e0
galpattern166
	db $56,$00,$00,$00,$5a,$00,$55,$00,$e0
galpattern167
	db $56,$00,$00,$00,$56,$00,$00,$00,$e0
galpattern168
	db $5a,$00,$55,$00,$56,$00,$56,$00,$e0
galpattern169
	db $5a,$00,$55,$00,$56,$00,$00,$00,$e0
galpattern170
	db $5a,$00,$55,$00,$36,$00,$00,$00,$e0
galpattern171
	db $36,$00,$00,$00,$3a,$00,$35,$00,$e0
galpattern172
	db $36,$00,$00,$00,$36,$00,$00,$00,$e0
galpattern173
	db $3a,$00,$35,$00,$36,$00,$36,$00,$e0
galpattern174
	db $3a,$00,$35,$00,$56,$00,$00,$00,$e0
galpattern175
	db $5a,$00,$55,$00,$0e,$00,$00,$00,$e0
galpattern176
	db $0e,$00,$0f,$10,$13,$12,$13,$14,$e0
galpattern177
	db $0e,$00,$00,$00,$16,$00,$00,$00,$e0
galpattern178
	db $1a,$00,$15,$00,$16,$00,$16,$00,$e0
galpattern179
	db $1a,$00,$15,$00,$18,$00,$00,$00,$e0
galpattern180
	db $18,$00,$00,$00,$1a,$00,$15,$00,$e0
galpattern181
	db $18,$00,$00,$00,$18,$00,$00,$00,$e0
galpattern182
	db $1a,$00,$15,$00,$1a,$00,$18,$00,$e0
galpattern183
	db $16,$00,$15,$00,$13,$00,$13,$00,$e0
galpattern184
	db $16,$00,$11,$00,$13,$00,$00,$00,$e0
galpattern185
	db $13,$00,$00,$00,$1a,$00,$15,$00,$e0
galpattern186
	db $16,$00,$00,$00,$16,$00,$00,$00,$e0
galpattern187
	db $1a,$00,$15,$00,$13,$00,$00,$00,$e0
galpattern188
	db $13,$00,$00,$00,$13,$00,$11,$00,$e0
galpattern189
	db $13,$00,$00,$00,$13,$00,$00,$00,$e0
galpattern190
	db $13,$00,$15,$00,$13,$00,$15,$00,$e0
galpattern191
	db $16,$00,$18,$00,$16,$00,$18,$00,$e0
galpattern192
	db $1a,$00,$1d,$00,$1f,$00,$00,$00,$e0
galpattern193
	db $13,$00,$1f,$1d,$1f,$1d,$1a,$18,$e0
galpattern194
	db $1a,$00,$00,$00,$16,$00,$00,$00,$e0
galpattern195
	db $1a,$00,$15,$00,$1a,$00,$00,$00,$e0
galpattern196
	db $18,$00,$00,$00,$1a,$00,$18,$00,$e0
galpattern197
	db $1a,$18,$16,$15,$1a,$18,$16,$15,$e0
galpattern198
	db $1a,$00,$18,$00,$16,$00,$15,$00,$e0
galpattern199
	db $16,$00,$15,$00,$13,$15,$16,$18,$e0
galpattern200
	db $13,$15,$16,$18,$13,$00,$00,$00,$e0
galpattern201
	db $13,$00,$00,$00,$1f,$00,$1d,$00,$e0
galpattern202
	db $1f,$00,$00,$00,$18,$00,$00,$00,$e0
galpattern203
	db $1a,$00,$18,$00,$1a,$00,$18,$00,$e0
galpattern204
	db $1f,$1d,$1b,$1a,$3a,$3d,$3a,$3d,$e0
galpattern205
	db $36,$3d,$36,$3d,$35,$3d,$35,$3d,$e0
galpattern206
	db $31,$3d,$31,$3d,$31,$3d,$31,$3d,$e0
galpattern207
	db $36,$3f,$36,$3f,$38,$3f,$38,$3f,$e0
galpattern208
	db $16,$18,$16,$18,$16,$18,$1a,$5d,$e0
galpattern209
	db $00,$00,$00,$00,$01,$00,$0e,$00,$e0
galpattern210
	db $00,$00,$1a,$00,$00,$00,$00,$00,$e0
galpattern211
	db $3a,$00,$00,$00,$5a,$00,$00,$00,$e0
galpattern212
	db $00,$00,$00,$00,$00,$01,$00,$00,$e0
galpattern213
	db $00,$00,$00,$5d,$00,$00,$00,$5d,$e0
galpattern214
	db $00,$01,$00,$5d,$00,$00,$00,$5d,$e0
galpattern215
	db $01,$00,$00,$5d,$00,$00,$00,$5d,$e0
galpattern216
	db $01,$00,$13,$5d,$01,$00,$13,$5d,$e0
galpattern217
	db $01,$00,$13,$5d,$01,$00,$18,$5d,$e0
galpattern218
	db $01,$00,$1a,$5d,$01,$00,$1a,$5d,$e0
galpattern219
	db $01,$00,$1a,$5d,$01,$00,$11,$5d,$e0
galpattern220
	db $00,$00,$11,$5d,$00,$00,$11,$5d,$e0
galpattern221
	db $00,$00,$18,$5d,$00,$00,$18,$5d,$e0
galpattern222
	db $00,$00,$11,$5d,$00,$00,$16,$5d,$e0
galpattern223
	db $00,$00,$15,$5d,$00,$00,$15,$5d,$e0
galpattern224
	db $00,$00,$18,$5d,$00,$00,$16,$5d,$e0
galpattern225
	db $01,$0e,$13,$5d,$01,$00,$13,$5d,$e0
galpattern226
	db $01,$00,$13,$5d,$01,$4a,$18,$5d,$e0
galpattern227
	db $01,$00,$11,$5d,$01,$00,$11,$5d,$e0
galpattern228
	db $01,$00,$18,$5d,$01,$00,$18,$5d,$e0
galpattern229
	db $01,$00,$11,$5d,$01,$00,$16,$5d,$e0
galpattern230
	db $01,$00,$15,$5d,$01,$00,$15,$5d,$e0
galpattern231
	db $01,$00,$18,$5d,$01,$00,$16,$5d,$e0
galpattern232
	db $00,$00,$13,$5d,$00,$00,$13,$5d,$e0
galpattern233
	db $00,$00,$13,$5d,$00,$00,$18,$5d,$e0
galpattern234
	db $00,$00,$1a,$5d,$00,$00,$1a,$5d,$e0
galpattern235
	db $00,$00,$1a,$5d,$00,$00,$11,$5d,$e0
galpattern236
	db $00,$00,$1c,$5d,$01,$5f,$5e,$5d,$e0
galpattern237
	db $5c,$5b,$5d,$5c,$5b,$5a,$59,$5a,$e0
galpattern238
	db $38,$00,$00,$00,$01,$00,$38,$3d,$e0
galpattern239
	db $3f,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern240
	db $00,$00,$00,$00,$3d,$00,$3c,$00,$e0
galpattern241
	db $3d,$3f,$3d,$00,$00,$00,$00,$00,$e0
galpattern242
	db $00,$00,$00,$00,$38,$00,$00,$00,$e0
galpattern243
	db $01,$00,$38,$3d,$3f,$00,$00,$00,$e0
galpattern244
	db $3d,$00,$3c,$00,$3d,$3f,$3d,$00,$e0
galpattern245
	db $00,$00,$00,$00,$3f,$00,$00,$00,$e0
galpattern246
	db $4e,$51,$55,$58,$55,$58,$5c,$5f,$e0
galpattern247
	db $51,$55,$58,$5c,$58,$5c,$5f,$5d,$e0
galpattern248
	db $4f,$53,$56,$5a,$56,$5a,$5d,$5f,$e0
galpattern249
	db $4f,$53,$56,$5a,$4e,$51,$55,$58,$e0
galpattern250
	db $55,$58,$5c,$5f,$4e,$51,$55,$58,$e0
galpattern251
	db $55,$58,$5c,$5f,$51,$55,$58,$5c,$e0
galpattern252
	db $58,$5c,$5f,$5d,$51,$55,$58,$5c,$e0
galpattern253
	db $58,$5c,$5f,$5d,$4f,$53,$56,$5a,$e0
galpattern254
	db $56,$5a,$5d,$5f,$4f,$53,$56,$5a,$e0
galpattern255
	db $00,$00,$00,$00,$3d,$00,$00,$00,$e0
galpattern256
	db $5d,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern257
	db $00,$00,$5c,$5b,$07,$00,$00,$00,$e0
galpattern258
	db $27,$00,$00,$00,$00,$00,$00,$00,$e0
galpattern259
	db $00,$00,$00,$00,$25,$00,$00,$00,$e0
galpattern260
	db $00,$00,$00,$00,$23,$00,$00,$00,$e0
galpattern261
	db $00,$00,$00,$00,$05,$00,$00,$00,$e0
galpattern262
	db $00,$00,$00,$00,$03,$00,$00,$00,$e0
galpattern263
	db $00,$00,$00,$00,$27,$00,$00,$00,$e0
galpattern264
	db $00,$00,$00,$00,$00,$00,$00,$11,$e0
galpattern265
	db $00,$00,$00,$1f,$00,$00,$00,$00,$e0
galpattern266
	db $00,$3f,$00,$00,$00,$5f,$00,$00,$e0
galpattern267
	db $00,$00,$00,$00,$5a,$56,$53,$00,$e0


end

