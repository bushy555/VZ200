

 	ORG $8000

cls: 	ei
	call 	$01c9		; VZ ROM CLS
	ld 	hl, MSG1	; Print MENU
	call 	$28a7		; VZ ROM Print string.
	di

begin:
scan: 	call 	$2ef4		; VZ scan keyboard
	or 	a		; any key pressed?
	jr 	z, scan 	; back if not
				;       Menu selection.  

; 49   50   51   52   53   54   55   56
;  81   87   69   82   84   89   85   73   
;   65   83   68   70   71   72   74   75   
;    90   88   67   86   66   78   77

	cp 	49		;
	jp 	z, m1		;       
	cp 	50		; 
	jp 	z, m2
	cp 	51		; 
	jp 	z, m3
	cp 	52		; 
	jp 	z, m4
	cp 	53		; 
	jp 	z, m5
	cp 	54		; 
	jp 	z, m6
	cp 	55		; 
	jp 	z, m7
	cp 	56		
	jp 	z, m8

	cp 	65
	jp 	z, mA
	cp 	66
	jp 	z, mB
	cp 	67
	jp 	z, mC
	cp 	68
	jp 	z, mD
	cp 	69
	jp 	z, mE
	cp 	70
	jp 	z, mF
	cp 	71
	jp 	z, mG
	cp 	72
	jp 	z, mH
	cp 	73
	jp 	z, mI
	cp 	74
	jp 	z, mJ
	cp 	75
	jp 	z, mK
;	cp 	76
;	jp 	z, mL
	cp 	77
	jp 	z, mM
	cp 	78
	jp 	z, mN
;	cp 	79
;	jp 	z, mO
;	cp 	80
;	jp 	z, mP
	cp 	81
	jp 	z, mQ
	cp 	82
	jp 	z, mR
	cp 	83
	jp 	z, mS
	cp 	84
	jp 	z, mT
	cp 	85
	jp 	z, mU
	cp 	86
	jp 	z, mV
	cp 	87
	jp 	z, mW
	cp 	88
	jp 	z, mX
	cp 	89
	jp 	z, mY
	cp 	90
	jp 	z, mZ


	jp 	begin 	;scan


quit: 	ei
	ld 	hl, MSGQUIT
	call 	$28a7			; print message. HL
	jp 	$1a19			; Jump to VZ basic
	


; 49   50   51   52   53   54   55   56
;  81   87   69   82   84   89   85   73   
;   65   83   68   70   71   72   74   75   
;    90   88   67   86   66   78   77

	

m1:	ld 	hl, (K1)
	jp	sound
m2: 	ld 	hl, (K2)
	jp	sound
m3: 	ld 	hl, (K3)
	jp	sound
m4: 	ld 	hl, (K4)
	jp	sound
m5: 	ld 	hl, (K5)
	jp	sound
m6: 	ld 	hl, (K6)
	jp	sound
m7: 	ld 	hl, (K7)
	jp	sound
m8: 	ld 	hl, (K8)
	jp	sound

mA: 	ld 	hl, (KA)
	jp	sound
mB: 	ld 	hl, (KB)
	jp	sound
mC: 	ld 	hl, (KC)
	jp	sound
mD: 	ld 	hl, (KD)
	jp	sound
mE: 	ld 	hl, (KE)
	jp	sound
mF: 	ld 	hl, (KF)
	jp	sound
mG: 	ld 	hl, (KG)
	jp	sound
mH: 	ld 	hl, (KH)
	jp	sound
mI: 	ld 	hl, (KI)
	jp	sound
mJ: 	ld 	hl, (KJ)
	jp	sound
mK: 	ld 	hl, (KK)
	jp	sound
;mL: 	ld 	hl, (KL)
;	jp	sound
mM: 	ld 	hl, (KM)
	jp	sound
mN: 	ld 	hl, (KN)
	jp	sound
;mO: 	ld 	hl, (KO)
;	jp	sound
;mP: 	ld 	hl, (KP)
;	jp	sound
mQ: 	ld 	hl, (KQ)
	jp	sound
mR: 	ld 	hl, (KR)
	jp	sound
mS: 	ld 	hl, (KS)
	jp	sound
mT: 	ld 	hl, (KT)
	jp	sound
mU: 	ld 	hl, (KU)
	jp	sound
mV: 	ld 	hl, (KV)
	jp	sound
mW: 	ld 	hl, (KW)
	jp	sound
mX: 	ld 	hl, (KX)
	jp	sound
mY: 	ld 	hl, (KY)
	jp	sound
mZ: 	ld 	hl, (KZ)
	jp	sound




sound:	ld	bc, 25
	call	$345C

	jp	begin


MSG1 	DB	"  STUPID DUMB VZ PIANO",$0D
	DB	$0D
	db	"1 2 3 4 5 6 7 8 ", $0d
	db	" Q W E R T Y U I ", $0d
	db 	"  A S D F G H J K ", $0d
	db 	"   Z X C V B N M", $0d
	db 	$0d, $0d, ">",00


; 49   50   51   52   53   54   55   56
;  81   87   69   82   84   89   85   73   
;   65   83   68   70   71   72   74   75   
;    90   88   67   86   66   78   77

K1	dw	94
K2	dw	105
K3	dw	116
K4	dw	127	; 390
K5	dw	138
K6	dw	149
K7	dw	160
K8	dw	171

KQ	dw	182
KW	dw	193
KE	dw	204
KR	dw	215
KT	dw	226
KY	dw	237
KU	dw	248
KI	dw	259	; 414

KA	dw	281
KS	dw	303
KD	dw	325
KF	dw	347
KG	dw	369
KH	dw	391
KJ	dw	413
KK	dw	435

KZ	dw	457
KX	dw	479
KC	dw	501
KV	dw	526	; 526
KB	dw	548
KN	dw	570
KM	dw	592



; 1	A2	Z
; 2	A2#	X
; 3	B2	C
; 4	C3	V	526
; 5	C3#	B
; 6	D3	N
; 7	D3#	M
; 8	E3	K
; 9	F3	J
;10	F3#	H
;11	G3	G
;12	G3#	F
;13	A3	D
;14	A3#	S
;15	B3	A
;16	C4	I	259
;17	C4#	U
;18	D4	Y
;19	D4#	T
;20	E4	R
;21	F4	E
;22	F4#	W
;23	G4	Q
;24	G4#	8
;25	A4	7
;26	A4#	6
;27	B4	5
;28	C5	4	127
;29	C5#	3
;30	D5	2
;31	D5#	1



end
