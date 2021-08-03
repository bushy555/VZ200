#define TI82				; select target platform here
;#define TI83


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

port1	equ 16
port2	equ 0



;Octode beeper music engine by Shiru (shiru@mail.ru) 02'11
;Eight channels of tone
;One channel of interrupting drums, no ROM data required
;Feel free to do whatever you want with the code, it is PD
;Modified for Z80 TI calculators by utz


begin

cls: 	call 	$01c9		; VZ ROM CLS
	ld 	hl, MSG1	; Print MENU
	call 	$28a7		; VZ ROM Print string.


	di	
	ld hl,musicData
	call play
	ei

	ret

OPxNOP	EQU $00
OPxRRA	EQU $1f
OPxSCF	EQU $37
OPxORC	EQU $b1


.MODULE octode

play
	di
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (xspeed),de

	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (xptr),de

	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (xloop),de

readNotes
xptr .EQU $+1
	ld hl,0
	ld a,(hl)
	inc hl
	cp 240
	jr c,xnoLoop
	cp 255
	jr nz,xdrum
xloop .EQU $+1
	ld hl,0
	ld (xptr),hl
	jp xcheckKey

xdrum
	ld (xptr),hl
	ld b,8
	ld hl,xdrum2
	ld (hl),OPxNOP
	inc hl
	djnz $-3
	sub 240
	jr z,xdrum0
	ld b,a
	ld hl,xdrum2
	ld (hl),OPxRRA
	inc hl
	djnz $-3
xdrum0
	ld bc,100*256
xdrum1
	ld a,c
xdrum2 .EQU $
	rra
	rra
	rra
	rra
	rra
	rra
	rra
	rra
	xor b
	and port1
	
	push af		;+11
	bit 4,a		;+8
	jr nz, $+6	;+7/12
	ld a,$fc	;+7
	jr $+6		;+12 
	nop			;+4
	nop			;+4
	ld a,port2	;f
	and 33
	ld        (26624),a	;11
	ld        (26624),a	;+11
	ld        (26624),a	;+11
	push hl		;+11
	nop			;+4
	nop			;+4
	pop hl		;+11
	pop af		;+10	+55/56 +41

	bit 0,(ix)
	inc c
	inc c
	xor a
			
	push af		;+11
	bit 4,a		;+8
	jr nz, $+6	;+7/12
	ld a,$fc	;+7
	jr $+6		;+12 
	nop			;+4
	nop			;+4
	ld a, port2
	and 33
	ld        (26624),a	;11
	ld        (26624),a	;+11
	ld        (26624),a	;+11
	push hl		;+11
	nop			;+4
	nop			;+4
	pop hl		;+11
	pop af		;+10	+55/56 +41

	djnz xdrum1

	ld hl,(xptr)

xnoLoop
	ld b,(hl)
	inc hl

	ld c,OPxSCF

	xor a
	rr b
	jr nc,xch1
	ld a,(hl)
	inc hl
	ld (xfrq0),a
	ld a,c
xch1
	ld (xoff0),a

	xor a
	rr b
	jr nc,xch2
	ld a,(hl)
	inc hl
	ld (xfrq1),a
	ld a,c
xch2
	ld (xoff1),a

	xor a
	rr b
	jr nc,xch3
	ld a,(hl)
	inc hl
	ld (xfrq2),a
	ld a,c
xch3
	ld (xoff2),a

	xor a
	rr b
	jr nc,xch4
	ld a,(hl)
	inc hl
	ld (xfrq3),a
	ld a,c
xch4
	ld (xoff3),a

	xor a
	rr b
	jr nc,xch5
	ld a,(hl)
	inc hl
	ld (xfrq4),a
	ld a,c
xch5
	ld (xoff4),a

	xor a
	rr b
	jr nc,xch6
	ld a,(hl)
	inc hl
	ld (xfrq5),a
	ld a,c
xch6
	ld (xoff5),a

	xor a
	rr b
	jr nc,xch7
	ld a,(hl)
	inc hl
	ld (xfrq6),a
	ld a,c
xch7
	ld (xoff6),a

	xor a
	rr b
	jr nc,xchDone
	ld a,(hl)
	inc hl
	ld (xfrq7),a
	ld a,c
xchDone
	ld (xoff7),a

	ld (xptr),hl

xprevBC .EQU $+1
	ld bc,0
xspeed .EQU $+1
	ld hl,0
	and a

soundLoop
	xor a		;4

	dec b		;4
	jr z,xla0	;7/12
	nop			;4
	jr xlb0		;12
xla0
xfrq0 .EQU $+1
	ld b,0		;7
xoff0 .EQU $
	scf			;4
xlb0
	dec c		;4
	jr z,xla1	;7/12
	nop			;4
	jr xlb1		;12
xla1
xfrq1 .EQU $+1
	ld c,0		;7
xoff1 .EQU $
	scf			;4
xlb1
	dec d		;4
	jr z,xla2	;7/12
	nop			;4
	jr xlb2		;12
xla2
xfrq2 .EQU $+1
	ld d,0		;7
xoff2 .EQU $
	scf			;4
xlb2
	dec e		;4
	jr z,xla3	;7/12
	nop			;4
	jr xlb3		;12
xla3
xfrq3 .EQU $+1
	ld e,0		;7
xoff3 .EQU $
	scf			;4
xlb3
	exx			;4
	
	push af		;+11
	bit 4,a		;+8
	jr nz, $+6	;+7/12
	ld a,$fc	;+7
	jr $+6		;+12 
	nop			;+4
	nop			;+4
	ld a, port2
	and 33
	ld        (26624),a	;11
	ld        (26624),a	;+11
	ld        (26624),a	;+11
	push hl		;+11
	nop			;+4
	nop			;+4
	pop hl		;+11
	pop af		;+10	+55/56 +41
	
	dec b		;4
	jr z,xla4	;7/12
	nop			;4
	jr xlb4		;12
xla4
xfrq4 .EQU $+1
	ld b,0		;7
xoff4 .EQU $
	scf			;4
xlb4
	dec c		;4
	jr z,xla5	;7/12
	nop			;4
	jr xlb5		;12
xla5
xfrq5 .EQU $+1
	ld c,0		;7
xoff5 .EQU $
	scf			;4
xlb5
	dec d		;4
	jr z,xla6	;7/12
	nop			;4
	jr xlb6		;12
xla6
xfrq6 .EQU $+1
	ld d,0		;7
xoff6 .EQU $
	scf			;4
xlb6
	dec e		;4
	jr z,xla7	;7/12
	nop			;4
	jr xlb7		;12
xla7
xfrq7 .EQU $+1
	ld e,0		;7
xoff7 .EQU $
	scf			;4
xlb7
	exx			;4
	sbc a,a		;4
	and port1		;7
	
	push af		;+11
	bit 4,a		;+8
	jr nz, $+6	;+7/12
	ld a,$fc	;+7
	jr $+6		;+12 
	nop			;+4
	nop			;+4
	ld a, port2
	and 33
	ld        (26624),a	;11
	ld        (26624),a	;+11
	ld        (26624),a	;+11
	push hl		;+11
	nop			;+4
	nop			;+4
	pop hl		;+11
	pop af		;+10	+55/56 +41
	
	dec l		;4
	jp nz,soundLoop	;10 = 275t
	dec h		;4
	jp nz,soundLoop	;10

	ld (xprevBC),bc

	xor a
	
	push af		;+11
	bit 4,a		;+8
	jr nz, $+6	;+7/12
	ld a,$fc	;+7
	jr $+6		;+12 
	nop			;+4
	nop			;+4
	ld a, port2
	and 33
	ld        (26624),a	;11
	ld        (26624),a	;+11
	ld        (26624),a	;+11
	push hl		;+11
	nop			;+4
	nop			;+4
	pop hl		;+11
	pop af		;+10	+55/56 +41


xcheckKey
	xor a
	ld c,a
;	ld a,%10111111				;+ new keyhandler
;	out (1),a
;	in a,(1)				;read keyboard
;	cpl
;	bit 6,a
;	jp z,readNotes

	jp readNotes

stopPlayer
	exx
	ei
	ret

MSG1	db " VZ OCTODE 8 CHANNEL",$0d
	db "  CHIP TUNE PLAYER",$0d, $0d
MSG2	db "PLAYING:OCTODE THEME",00


	

musicData

	dw $0200
	dw patstart
	dw patloop
patstart
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$70                ,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$78            ,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$7c        ,$55,$56,$ac,$ad,$ab    
	db $00,$00                                
	db $00,$f8            ,$56,$ac,$ad,$ab,$55
	db $00,$fc        ,$ad,$56,$ac,$ad,$ab,$55
	db $00,$fc        ,$a3,$56,$ac,$ad,$ab,$55
	db $00,$04        ,$9a                    
	db $00,$fc        ,$91,$56,$ac,$ad,$ab,$55
	db $00,$04        ,$89                    
	db $00,$fc        ,$81,$56,$ac,$ad,$ab,$55
	db $00,$04        ,$7a                    
	db $00,$fc        ,$73,$56,$ac,$ad,$ab,$55
	db $00,$fc        ,$6d,$56,$ac,$ad,$ab,$55
	db $00,$ff,$ce,$cd,$67,$56,$ac,$ad,$ab,$55
	db $00,$07,$ce,$cd,$67                    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$26,$54    
	db $00,$7b,$56,$55    ,$39,$30,$26,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$24,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$24,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$43,$56,$55                ,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$5f,$ad,$ac,$56,$39,$30    ,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $00,$5f,$ad,$ac,$2b,$39,$30    ,$ab    
	db $00,$5f,$ad,$ac,$2b,$39,$30    ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f8,$5f,$56,$55,$2b,$39,$30    ,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$58            ,$39,$30    ,$54    
	db $00,$40                        ,$54    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f1,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f8,$5b,$56,$55    ,$39,$30    ,$54    
	db $00,$5b,$56,$55    ,$39,$30    ,$54    
	db $00,$58            ,$39,$30    ,$54    
	db $00,$40                        ,$54    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f1,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$48,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$48,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$48,$55    
	db $00,$7b,$56,$55    ,$39,$30,$48,$55    
	db $00,$78            ,$39,$30,$48,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$40,$55    
	db $00,$43,$56,$55                ,$55    
	db $f1,$78            ,$39,$30,$40,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$40,$55    
	db $00,$7b,$56,$55    ,$39,$30,$40,$55    
	db $f1,$78            ,$39,$30,$40,$55    
	db $f1,$40                        ,$54    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$26,$54    
	db $00,$7b,$56,$55    ,$39,$30,$26,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$24,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$24,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$43,$56,$55                ,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$1c,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$1c,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$1c,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$1c,$ab    
	db $00,$78            ,$39,$30,$1c,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$1c,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$1c,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$1c,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$1c,$ab    
	db $00,$78            ,$39,$30,$1c,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$20,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$20,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$20,$54    
	db $00,$7b,$56,$55    ,$39,$30,$20,$54    
	db $00,$78            ,$39,$30,$20,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$20,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$20,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$20,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$20,$ab    
	db $00,$78            ,$39,$30,$20,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$48,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$48,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$48,$55    
	db $00,$7b,$56,$55    ,$39,$30,$48,$55    
	db $00,$78            ,$39,$30,$48,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$40,$55    
	db $00,$43,$56,$55                ,$55    
	db $00,$78            ,$39,$30,$40,$55    
	db $00,$c0                        ,$54,$36
	db $f1,$fb,$56,$55    ,$39,$30,$40,$55,$33
	db $00,$fb,$56,$55    ,$39,$30,$40,$55,$2d
	db $00,$f8            ,$39,$30,$40,$55,$2b
	db $00,$c0                        ,$54,$28
	db $f1,$ff,$ad,$ac,$56,$39,$30,$26,$ab,$13
	db $00,$c7,$ad,$ac,$56            ,$ab,$26
	db $00,$f8            ,$39,$30,$26,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $00,$ff,$ad,$ac,$2b,$39,$30,$26,$ab,$13
	db $00,$ff,$ad,$ac,$2b,$39,$30,$26,$ab,$26
	db $00,$f8            ,$39,$30,$26,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$c0                        ,$54,$26
	db $00,$fb,$ad,$ac    ,$39,$30,$26,$ab,$15
	db $00,$fb,$ad,$ac    ,$39,$30,$26,$ab,$2b
	db $00,$f8            ,$39,$30,$26,$ab,$18
	db $00,$c0                        ,$ab,$30
	db $f1,$fb,$ad,$ac    ,$39,$30,$26,$ab,$1c
	db $00,$c3,$ad,$ac                ,$ab,$39
	db $00,$f8            ,$39,$30,$26,$ab,$1c
	db $00,$c0                        ,$ab,$39
	db $f8,$fb,$56,$55    ,$39,$30,$26,$54,$1c
	db $00,$fb,$56,$55    ,$39,$30,$26,$54,$39
	db $00,$f8            ,$39,$30,$26,$54,$1c
	db $00,$c0                        ,$54,$39
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$c0                        ,$ab,$39
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$fb,$ad,$ac    ,$39,$30,$24,$ab,$12
	db $00,$c3,$ad,$ac                ,$ab,$24
	db $00,$f8            ,$39,$30,$24,$ab,$12
	db $00,$c0                        ,$ab,$24
	db $f8,$fb,$56,$55    ,$39,$30,$24,$55,$12
	db $00,$fb,$56,$55    ,$39,$30,$24,$55,$24
	db $00,$f8            ,$39,$30,$24,$55,$12
	db $00,$c0                        ,$54,$24
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$43,$56,$55                ,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$c0                        ,$54,$24
	db $f1,$df,$ad,$ac,$56,$39,$30    ,$ab,$13
	db $00,$c7,$ad,$ac,$56            ,$ab,$26
	db $00,$d8            ,$39,$30    ,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $00,$df,$ad,$ac,$2b,$39,$30    ,$ab,$13
	db $00,$df,$ad,$ac,$2b,$39,$30    ,$ab,$26
	db $00,$d8            ,$39,$30    ,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $f8,$5f,$56,$55,$2b,$39,$30    ,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$58            ,$39,$30    ,$54    
	db $00,$40                        ,$54    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f1,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f8,$5b,$56,$55    ,$39,$30    ,$54    
	db $00,$5b,$56,$55    ,$39,$30    ,$54    
	db $00,$58            ,$39,$30    ,$54    
	db $00,$40                        ,$54    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f1,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$48,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$48,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$48,$55    
	db $00,$7b,$56,$55    ,$39,$30,$48,$55    
	db $00,$78            ,$39,$30,$48,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$40,$55    
	db $00,$43,$56,$55                ,$55    
	db $f1,$78            ,$39,$30,$40,$55    
	db $00,$40                        ,$54    
	db $f1,$fb,$56,$55    ,$39,$30,$40,$55,$1c
	db $00,$fb,$56,$55    ,$39,$30,$40,$55,$39
	db $f1,$f8            ,$39,$30,$40,$55,$18
	db $f1,$c0                        ,$54,$30
	db $f1,$ff,$ad,$ac,$56,$39,$30,$26,$ab,$13
	db $00,$c7,$ad,$ac,$56            ,$ab,$26
	db $00,$f8            ,$39,$30,$26,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $00,$ff,$ad,$ac,$2b,$39,$30,$26,$ab,$13
	db $00,$ff,$ad,$ac,$2b,$39,$30,$26,$ab,$26
	db $00,$f8            ,$39,$30,$26,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$c0                        ,$ab,$26
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$26,$54    
	db $00,$7b,$56,$55    ,$39,$30,$26,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$fb,$ad,$ac    ,$39,$30,$24,$ab,$12
	db $00,$c3,$ad,$ac                ,$ab,$24
	db $00,$f8            ,$39,$30,$24,$ab,$12
	db $00,$c0                        ,$ab,$24
	db $f8,$fb,$56,$55    ,$39,$30,$24,$55,$12
	db $00,$fb,$56,$55    ,$39,$30,$24,$55,$24
	db $00,$f8            ,$39,$30,$24,$55,$12
	db $00,$c0                        ,$54,$24
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$43,$56,$55                ,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$c0                        ,$54,$24
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$ff,$ce,$cd,$67,$39,$30,$1c,$cd,$0e
	db $00,$c7,$ce,$cd,$67            ,$cd,$18
	db $00,$f8            ,$39,$30,$1c,$cd,$0e
	db $00,$c0                        ,$cd,$18
	db $00,$ff,$ce,$cd,$33,$39,$30,$1c,$cd,$0e
	db $00,$ff,$ce,$cd,$33,$39,$30,$1c,$cd,$18
	db $00,$f8            ,$39,$30,$1c,$cd,$0e
	db $00,$c0                        ,$cd,$18
	db $f8,$7f,$67,$66,$33,$39,$30,$1c,$66    
	db $00,$47,$67,$66,$33            ,$66    
	db $00,$78            ,$39,$30,$1c,$66    
	db $00,$40                        ,$66    
	db $00,$fb,$ce,$cd    ,$39,$30,$1c,$cd,$18
	db $00,$fb,$ce,$cd    ,$39,$30,$1c,$cd,$0e
	db $00,$78            ,$39,$30,$1c,$cd    
	db $00,$40                        ,$cd    
	db $f1,$fb,$ce,$cd    ,$39,$30,$20,$cd,$10
	db $00,$c3,$ce,$cd                ,$cd,$19
	db $00,$f8            ,$39,$30,$20,$cd,$10
	db $00,$c0                        ,$cd,$19
	db $f8,$fb,$67,$66    ,$39,$30,$20,$66,$10
	db $00,$fb,$67,$66    ,$39,$30,$20,$66,$19
	db $00,$f8            ,$39,$30,$20,$66,$10
	db $00,$c0                        ,$66,$19
	db $00,$7b,$ce,$cd    ,$39,$30,$20,$cd    
	db $00,$43,$ce,$cd                ,$cd    
	db $00,$f8            ,$39,$30,$20,$cd,$19
	db $00,$40                        ,$cd    
	db $f1,$7b,$ce,$cd    ,$39,$30,$20,$cd    
	db $00,$7b,$ce,$cd    ,$39,$30,$20,$cd    
	db $00,$f8            ,$39,$30,$20,$cd,$19
	db $00,$40                        ,$cd    
	db $f1,$ff,$91,$90,$48,$39,$30,$26,$90,$13
	db $00,$c7,$91,$90,$48            ,$90,$20
	db $00,$f8            ,$39,$30,$26,$90,$13
	db $00,$c0                        ,$90,$20
	db $00,$ff,$91,$90,$24,$39,$30,$26,$90,$13
	db $00,$ff,$91,$90,$24,$39,$30,$26,$90,$20
	db $00,$f8            ,$39,$30,$26,$90,$13
	db $00,$c0                        ,$90,$20
	db $f8,$7f,$48,$47,$24,$39,$30,$26,$47    
	db $00,$47,$48,$47,$24            ,$47    
	db $00,$f8            ,$39,$30,$26,$47,$20
	db $00,$40                        ,$47    
	db $00,$7b,$91,$90    ,$39,$30,$26,$90    
	db $00,$7b,$91,$90    ,$39,$30,$26,$90    
	db $00,$f8            ,$39,$30,$26,$90,$20
	db $00,$40                        ,$90    
	db $f1,$fb,$91,$90    ,$39,$30,$48,$90,$18
	db $00,$c3,$91,$90                ,$90,$30
	db $00,$f8            ,$39,$30,$48,$90,$18
	db $00,$c0                        ,$90,$30
	db $f8,$fb,$48,$47    ,$39,$30,$48,$47,$18
	db $00,$fb,$48,$47    ,$39,$30,$48,$47,$30
	db $00,$f8            ,$39,$30,$48,$47,$18
	db $00,$c0                        ,$46,$30
	db $f1,$fb,$48,$47    ,$39,$30,$40,$47,$20
	db $00,$c3,$48,$47                ,$47,$40
	db $00,$f8            ,$39,$30,$40,$47,$20
	db $00,$c0                        ,$46,$40
	db $f1,$fb,$48,$47    ,$39,$30,$40,$47,$20
	db $00,$fb,$48,$47    ,$39,$30,$40,$47,$40
	db $00,$f8            ,$39,$30,$40,$47,$20
	db $00,$c0                        ,$46,$40
	db $f1,$ff,$ad,$ac,$56,$39,$30,$26,$ab,$13
	db $00,$c7,$ad,$ac,$56            ,$ab,$26
	db $00,$f8            ,$39,$30,$26,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $00,$ff,$ad,$ac,$2b,$39,$30,$26,$ab,$13
	db $00,$ff,$ad,$ac,$2b,$39,$30,$26,$ab,$26
	db $00,$f8            ,$39,$30,$26,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$c0                        ,$54,$26
	db $00,$fb,$ad,$ac    ,$39,$30,$26,$ab,$15
	db $00,$fb,$ad,$ac    ,$39,$30,$26,$ab,$2b
	db $00,$f8            ,$39,$30,$26,$ab,$18
	db $00,$c0                        ,$ab,$30
	db $f1,$fb,$ad,$ac    ,$39,$30,$26,$ab,$1c
	db $00,$c3,$ad,$ac                ,$ab,$39
	db $00,$f8            ,$39,$30,$26,$ab,$1c
	db $00,$c0                        ,$ab,$39
	db $f8,$fb,$56,$55    ,$39,$30,$26,$54,$1c
	db $00,$fb,$56,$55    ,$39,$30,$26,$54,$39
	db $00,$f8            ,$39,$30,$26,$54,$1c
	db $00,$c0                        ,$54,$39
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$c0                        ,$ab,$39
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$fb,$ad,$ac    ,$39,$30,$24,$ab,$12
	db $00,$c3,$ad,$ac                ,$ab,$24
	db $00,$f8            ,$39,$30,$24,$ab,$12
	db $00,$c0                        ,$ab,$24
	db $f8,$fb,$56,$55    ,$39,$30,$24,$55,$12
	db $00,$fb,$56,$55    ,$39,$30,$24,$55,$24
	db $00,$f8            ,$39,$30,$24,$55,$12
	db $00,$c0                        ,$54,$24
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$43,$56,$55                ,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$c0                        ,$54,$24
	db $f1,$df,$ad,$ac,$56,$39,$30    ,$ab,$13
	db $00,$c7,$ad,$ac,$56            ,$ab,$26
	db $00,$d8            ,$39,$30    ,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $00,$df,$ad,$ac,$2b,$39,$30    ,$ab,$13
	db $00,$df,$ad,$ac,$2b,$39,$30    ,$ab,$26
	db $00,$d8            ,$39,$30    ,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $f8,$5f,$56,$55,$2b,$39,$30    ,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$58            ,$39,$30    ,$54    
	db $00,$40                        ,$54    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f1,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f8,$5b,$56,$55    ,$39,$30    ,$54    
	db $00,$5b,$56,$55    ,$39,$30    ,$54    
	db $00,$58            ,$39,$30    ,$54    
	db $00,$40                        ,$54    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f1,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$5b,$ad,$ac    ,$39,$30    ,$ab    
	db $00,$58            ,$39,$30    ,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$48,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$48,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$48,$55    
	db $00,$7b,$56,$55    ,$39,$30,$48,$55    
	db $00,$78            ,$39,$30,$48,$55    
	db $00,$40                        ,$54    
	db $f1,$7b,$56,$55    ,$39,$30,$40,$55    
	db $00,$43,$56,$55                ,$55    
	db $f1,$78            ,$39,$30,$40,$55    
	db $00,$40                        ,$54    
	db $f1,$fb,$56,$55    ,$39,$30,$40,$55,$1c
	db $00,$fb,$56,$55    ,$39,$30,$40,$55,$39
	db $f1,$f8            ,$39,$30,$40,$55,$18
	db $f1,$c0                        ,$54,$30
	db $f1,$ff,$ad,$ac,$56,$39,$30,$26,$ab,$13
	db $00,$c7,$ad,$ac,$56            ,$ab,$26
	db $00,$f8            ,$39,$30,$26,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $00,$ff,$ad,$ac,$2b,$39,$30,$26,$ab,$13
	db $00,$ff,$ad,$ac,$2b,$39,$30,$26,$ab,$26
	db $00,$f8            ,$39,$30,$26,$ab,$13
	db $00,$c0                        ,$ab,$26
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$c0                        ,$ab,$26
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7b,$56,$55    ,$39,$30,$26,$54    
	db $00,$7b,$56,$55    ,$39,$30,$26,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$43,$ad,$ac                ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$7f,$ad,$ac,$56,$39,$30,$26,$ab    
	db $00,$47,$ad,$ac,$56            ,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$7f,$ad,$ac,$2b,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f8,$7f,$56,$55,$2b,$39,$30,$26,$54    
	db $00,$47,$56,$55,$2b            ,$54    
	db $00,$78            ,$39,$30,$26,$54    
	db $00,$40                        ,$54    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$7b,$ad,$ac    ,$39,$30,$26,$ab    
	db $00,$78            ,$39,$30,$26,$ab    
	db $00,$40                        ,$ab    
	db $f1,$fb,$ad,$ac    ,$39,$30,$24,$ab,$12
	db $00,$c3,$ad,$ac                ,$ab,$24
	db $00,$f8            ,$39,$30,$24,$ab,$12
	db $00,$c0                        ,$ab,$24
	db $f8,$fb,$56,$55    ,$39,$30,$24,$55,$12
	db $00,$fb,$56,$55    ,$39,$30,$24,$55,$24
	db $00,$f8            ,$39,$30,$24,$55,$12
	db $00,$c0                        ,$54,$24
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$43,$56,$55                ,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$c0                        ,$54,$24
	db $f1,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$7b,$56,$55    ,$39,$30,$24,$55    
	db $00,$78            ,$39,$30,$24,$55    
	db $00,$40                        ,$54    
	db $f1,$ff,$81,$80,$40,$39,$30,$1c,$80,$0e
	db $00,$c7,$81,$80,$40            ,$80,$18
	db $00,$f8            ,$39,$30,$1c,$80,$0e
	db $00,$c0                        ,$80,$18
	db $00,$ff,$81,$80,$20,$39,$30,$1c,$80,$0e
	db $00,$ff,$81,$80,$20,$39,$30,$1c,$80,$18
	db $00,$f8            ,$39,$30,$1c,$80,$0e
	db $00,$c0                        ,$80,$18
	db $f8,$7f,$40,$3f,$20,$39,$30,$1c,$3f    
	db $00,$47,$40,$3f,$20            ,$3f    
	db $00,$78            ,$39,$30,$1c,$3f    
	db $00,$40                        ,$3f    
	db $00,$fb,$81,$80    ,$39,$30,$1c,$80,$18
	db $00,$fb,$81,$80    ,$39,$30,$1c,$80,$0e
	db $00,$78            ,$39,$30,$1c,$80    
	db $00,$40                        ,$80    
	db $f1,$fb,$81,$80    ,$39,$30,$20,$80,$10
	db $00,$c3,$81,$80                ,$80,$19
	db $00,$f8            ,$39,$30,$20,$80,$10
	db $00,$c0                        ,$80,$19
	db $f8,$fb,$40,$3f    ,$39,$30,$20,$3f,$10
	db $00,$fb,$40,$3f    ,$39,$30,$20,$3f,$19
	db $00,$f8            ,$39,$30,$20,$3f,$10
	db $00,$c0                        ,$3f,$19
	db $00,$7b,$81,$80    ,$39,$30,$20,$80    
	db $00,$43,$81,$80                ,$80    
	db $00,$f8            ,$39,$30,$20,$80,$19
	db $00,$40                        ,$80    
	db $f1,$7b,$81,$80    ,$39,$30,$20,$80    
	db $00,$7b,$81,$80    ,$39,$30,$20,$80    
	db $00,$f8            ,$39,$30,$20,$80,$19
	db $00,$40                        ,$80    
	db $f1,$ff,$81,$80,$40,$39,$30,$26,$80,$13
	db $00,$c7,$81,$80,$40            ,$80,$20
	db $00,$f8            ,$39,$30,$26,$80,$13
	db $00,$c0                        ,$80,$20
	db $00,$ff,$81,$80,$20,$39,$30,$26,$80,$13
	db $00,$ff,$81,$80,$20,$39,$30,$26,$80,$20
	db $00,$f8            ,$39,$30,$26,$80,$13
	db $00,$c0                        ,$80,$20
	db $f8,$7f,$40,$3f,$20,$39,$30,$26,$3f    
	db $00,$47,$40,$3f,$20            ,$3f    
	db $00,$f8            ,$39,$30,$26,$3f,$20
	db $00,$40                        ,$3f    
	db $00,$7b,$81,$80    ,$39,$30,$26,$80    
	db $00,$7b,$81,$80    ,$39,$30,$26,$80    
	db $00,$f8            ,$39,$30,$26,$80,$20
	db $00,$40                        ,$80    
	db $f1,$fb,$81,$80    ,$39,$30,$48,$80,$18
	db $00,$c3,$81,$80                ,$80,$30
	db $00,$f8            ,$39,$30,$48,$80,$18
	db $00,$c0                        ,$80,$30
	db $f8,$fb,$40,$3f    ,$39,$30,$48,$3f,$18
	db $00,$fb,$40,$3f    ,$39,$30,$48,$3f,$30
	db $00,$f8            ,$39,$30,$48,$3f,$18
	db $00,$c0                        ,$3e,$30
	db $f1,$fb,$40,$3f    ,$39,$30,$40,$3f,$20
	db $00,$c3,$40,$3f                ,$3f,$40
	db $00,$f8            ,$39,$30,$40,$3f,$20
	db $00,$c0                        ,$3e,$40
	db $f1,$fb,$40,$3f    ,$39,$30,$40,$3f,$20
	db $00,$fb,$40,$3f    ,$39,$30,$40,$3f,$40
	db $00,$f8            ,$39,$30,$40,$3f,$20
	db $00,$c0                        ,$3e,$40
	db $f1,$fb,$39,$0c    ,$56,$55,$ad,$ab,$ad
	db $00,$01,$30                            
	db $00,$fb,$20,$39    ,$56,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$0c                    
	db $00,$fb,$30,$0e    ,$56,$55,$ad,$ab,$ad
	db $00,$fb,$20,$39    ,$56,$55,$ad,$ab,$ad
	db $00,$fb,$39,$30    ,$56,$55,$ad,$ab,$ad
	db $00,$07,$30,$20,$0e                    
	db $f8,$fb,$20,$12    ,$56,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $00,$fb,$30,$20    ,$56,$55,$ad,$ab,$ad
	db $00,$07,$20,$39,$12                    
	db $00,$fb,$39,$13    ,$56,$55,$ad,$ab,$ad
	db $00,$fb,$30,$20    ,$56,$55,$ad,$ab,$ad
	db $00,$fb,$24,$39    ,$56,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$13                    
	db $f1,$fb,$30,$18    ,$56,$55,$ad,$ab,$ad
	db $00,$03,$24,$39                        
	db $00,$fb,$39,$30    ,$56,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$18                    
	db $f8,$f3,$24,$1c        ,$55,$ad,$ab,$ad
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$1c                    
	db $00,$f3,$39,$10        ,$55,$ad,$ab,$ad
	db $00,$03,$30,$24                        
	db $00,$f3,$26,$39        ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$10                    
	db $f1,$f3,$30,$26        ,$55,$ad,$ab,$ad
	db $00,$f3,$26,$39        ,$55,$ad,$ab,$ad
	db $00,$f7,$39,$30,$1c    ,$55,$ad,$ab,$ad
	db $00,$03,$30,$26                        
	db $f1,$f3,$26,$39        ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$1c                    
	db $00,$f3,$30,$26        ,$55,$ad,$ab,$ad
	db $00,$03,$26,$39                        
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$f3,$30,$26        ,$55,$ad,$ab,$ad
	db $00,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $f8,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$03,$24,$39                        
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$03,$30,$24                        
	db $00,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$03,$24,$39                        
	db $f1,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$03,$30,$24                        
	db $00,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $f8,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$03,$30,$24                        
	db $f1,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $00,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$03,$24,$39                        
	db $f1,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $f1,$fb,$39,$18    ,$56,$55,$ad,$ab,$ad
	db $00,$03,$30,$30                        
	db $00,$fb,$20,$39    ,$56,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $00,$fb,$30,$13    ,$56,$55,$ad,$ab,$ad
	db $00,$fb,$20,$39    ,$56,$55,$ad,$ab,$ad
	db $00,$fb,$39,$30    ,$56,$55,$ad,$ab,$ad
	db $00,$03,$30,$20                        
	db $f8,$fb,$20,$0c    ,$56,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $00,$ff,$30,$20,$0c,$56,$55,$ad,$ab,$ad
	db $00,$03,$20,$39                        
	db $00,$fb,$39,$0e    ,$56,$55,$ad,$ab,$ad
	db $00,$fb,$30,$20    ,$56,$55,$ad,$ab,$ad
	db $00,$ff,$24,$39,$0e,$56,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $f1,$f3,$30,$12        ,$55,$ad,$ab,$ad
	db $00,$03,$24,$39                        
	db $00,$f7,$39,$30,$12    ,$55,$ad,$ab,$ad
	db $00,$03,$30,$24                        
	db $f8,$f3,$24,$13        ,$55,$ad,$ab,$ad
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$f7,$30,$24,$13    ,$55,$ad,$ab,$ad
	db $00,$03,$24,$39                        
	db $00,$f3,$39,$18        ,$55,$ad,$ab,$ad
	db $00,$03,$30,$24                        
	db $00,$f3,$26,$39        ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$18                    
	db $f1,$f3,$30,$1c        ,$55,$ad,$ab,$ad
	db $00,$f3,$26,$39        ,$55,$ad,$ab,$ad
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$07,$30,$26,$1c                    
	db $f1,$f3,$26,$39        ,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $00,$f3,$30,$26        ,$55,$ad,$ab,$ad
	db $00,$03,$26,$39                        
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$f3,$30,$26        ,$55,$ad,$ab,$ad
	db $00,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $f8,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$03,$24,$39                        
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$03,$30,$24                        
	db $00,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$03,$24,$39                        
	db $f1,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$03,$30,$24                        
	db $00,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $f8,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$03,$30,$24                        
	db $f1,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $00,$03,$39,$30                        
	db $f1,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $00,$03,$24,$39                        
	db $f1,$f3,$39,$30        ,$55,$ad,$ab,$ad
	db $00,$f3,$30,$24        ,$55,$ad,$ab,$ad
	db $f1,$f3,$24,$39        ,$55,$ad,$ab,$ad
	db $f1,$03,$39,$30                        
	db $f1,$fb,$33,$0b    ,$4d,$4c,$9a,$98,$9a
	db $00,$01,$2b                            
	db $00,$fb,$1c,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $00,$fb,$2b,$0c    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$1c,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$1c                        
	db $f8,$fb,$1c,$10    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $00,$fb,$2b,$1c    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$1c,$33                        
	db $00,$fb,$33,$11    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$2b,$1c    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $f1,$fb,$2b,$15    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $f8,$fb,$20,$19    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $00,$f3,$33,$0e        ,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $00,$f3,$22,$33        ,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $f1,$f3,$2b,$22        ,$4c,$9a,$98,$9a
	db $00,$f3,$22,$33        ,$4c,$9a,$98,$9a
	db $00,$f3,$33,$2b        ,$4c,$9a,$98,$9a
	db $00,$03,$2b,$22                        
	db $f1,$fb,$22,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $00,$fb,$2b,$22    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$22,$33                        
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$2b,$22    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $f8,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $f1,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $f8,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $f1,$f3,$20,$33        ,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $00,$f3,$2b,$20        ,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $f1,$f3,$33,$2b        ,$4c,$9a,$98,$9a
	db $00,$f3,$2b,$20        ,$4c,$9a,$98,$9a
	db $00,$f3,$20,$33        ,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $f1,$fb,$33,$15    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$2b                        
	db $00,$fb,$1c,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $00,$fb,$2b,$11    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$1c,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$1c                        
	db $f8,$fb,$1c,$0b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $00,$fb,$2b,$1c    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$1c,$33                        
	db $00,$fb,$33,$0c    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$2b,$1c    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $f1,$fb,$2b,$10    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $f8,$fb,$20,$11    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $00,$fb,$33,$15    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $00,$fb,$22,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $f1,$fb,$2b,$19    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$22,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$22                        
	db $f1,$fb,$22,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $00,$fb,$2b,$22    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$22,$33                        
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$2b,$22    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $f8,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $f1,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $f8,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$20                        
	db $f1,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $00,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$20,$33                        
	db $f1,$fb,$33,$2b    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$2b,$20    ,$4d,$4c,$9a,$98,$9a
	db $00,$fb,$20,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
patloop
	db $f1,$ff,$39,$0c,$24,$56,$55,$ad,$ab,$ad
	db $00,$05,$30    ,$24                    
	db $00,$ff,$20,$39,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$24                    
	db $00,$ff,$30,$0e,$24,$56,$55,$ad,$ab,$ad
	db $00,$ff,$20,$39,$24,$56,$55,$ad,$ab,$ad
	db $00,$ff,$39,$30,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$30,$20,$24                    
	db $f8,$ff,$20,$12,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$24                    
	db $00,$ff,$30,$20,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$20,$39,$24                    
	db $00,$ff,$39,$13,$26,$56,$55,$ad,$ab,$ad
	db $00,$ff,$30,$20,$26,$56,$55,$ad,$ab,$ad
	db $00,$ff,$24,$39,$26,$56,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$26                    
	db $f1,$ff,$30,$18,$26,$56,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$26                    
	db $00,$ff,$39,$30,$26,$56,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$26                    
	db $f8,$f7,$24,$1c,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$30,$24,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$26                    
	db $00,$f7,$39,$10,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$26                    
	db $00,$f7,$26,$39,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$26                    
	db $f1,$f7,$30,$26,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$26,$39,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$26,$26                    
	db $f1,$f7,$26,$39,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$26                    
	db $00,$f7,$30,$26,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$26,$39,$26                    
	db $00,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$30,$26,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$24,$39,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$26                    
	db $f8,$f7,$30,$24,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$26                    
	db $00,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$26                    
	db $00,$f7,$24,$39,$24    ,$55,$ad,$ab,$ad
	db $00,$f7,$39,$30,$24    ,$55,$ad,$ab,$ad
	db $00,$f7,$30,$26,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$26                    
	db $f1,$f7,$39,$30,$30    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$30                    
	db $00,$f7,$24,$39,$30    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$30                    
	db $f8,$f7,$30,$24,$30    ,$55,$ad,$ab,$ad
	db $00,$f7,$24,$39,$30    ,$55,$ad,$ab,$ad
	db $00,$f7,$39,$30,$30    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$30                    
	db $f1,$f7,$24,$39,$30    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$30                    
	db $00,$f7,$30,$24,$30    ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$30                    
	db $f1,$f7,$39,$30,$39    ,$55,$ad,$ab,$ad
	db $00,$f7,$30,$24,$39    ,$55,$ad,$ab,$ad
	db $00,$f7,$24,$39,$39    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$39                    
	db $f1,$ff,$39,$18,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$30,$30,$24                    
	db $00,$ff,$20,$39,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$24                    
	db $00,$ff,$30,$13,$24,$56,$55,$ad,$ab,$ad
	db $00,$ff,$20,$39,$24,$56,$55,$ad,$ab,$ad
	db $00,$ff,$39,$30,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$30,$20,$24                    
	db $f8,$ff,$20,$0c,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$24                    
	db $00,$ff,$30,$20,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$20,$39,$24                    
	db $00,$ff,$39,$0e,$24,$56,$55,$ad,$ab,$ad
	db $00,$ff,$30,$20,$24,$56,$55,$ad,$ab,$ad
	db $00,$ff,$24,$39,$24,$56,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$24                    
	db $f1,$f7,$30,$12,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$26                    
	db $00,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$26                    
	db $f8,$f7,$24,$13,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$30,$24,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$26                    
	db $00,$f7,$39,$18,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$26                    
	db $00,$f7,$26,$39,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$26                    
	db $f1,$f7,$30,$1c,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$26,$39,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$26,$26                    
	db $f1,$f7,$26,$39,$2b    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$2b                    
	db $00,$f7,$30,$26,$2b    ,$55,$ad,$ab,$ad
	db $00,$07,$26,$39,$2b                    
	db $00,$f7,$39,$30,$2b    ,$55,$ad,$ab,$ad
	db $00,$f7,$30,$26,$2b    ,$55,$ad,$ab,$ad
	db $00,$f7,$24,$39,$2b    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$2b                    
	db $f8,$f7,$30,$24,$2b    ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$2b                    
	db $00,$f7,$39,$30,$2b    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$2b                    
	db $00,$f7,$24,$39,$2b    ,$55,$ad,$ab,$ad
	db $00,$f7,$39,$30,$2b    ,$55,$ad,$ab,$ad
	db $00,$f7,$30,$24,$2b    ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$2b                    
	db $f1,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$26                    
	db $00,$f7,$24,$39,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$26                    
	db $f8,$f7,$30,$24,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$24,$39,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$30,$24,$26                    
	db $f1,$f7,$24,$39,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$39,$30,$26                    
	db $f1,$f7,$30,$24,$26    ,$55,$ad,$ab,$ad
	db $00,$07,$24,$39,$26                    
	db $f1,$f7,$39,$30,$26    ,$55,$ad,$ab,$ad
	db $00,$f7,$30,$24,$26    ,$55,$ad,$ab,$ad
	db $f1,$f7,$24,$39,$26    ,$55,$ad,$ab,$ad
	db $f1,$07,$39,$30,$26                    
	db $f1,$ff,$33,$0b,$22,$4d,$4c,$9a,$98,$9a
	db $00,$05,$2b    ,$22                    
	db $00,$ff,$1c,$33,$22,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$22                    
	db $00,$ff,$2b,$0c,$22,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$1c,$33,$22,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$33,$2b,$22,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$1c,$22                    
	db $f8,$ff,$1c,$10,$22,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$22                    
	db $00,$ff,$2b,$1c,$22,$4d,$4c,$9a,$98,$9a
	db $00,$07,$1c,$33,$22                    
	db $00,$ff,$33,$11,$20,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$2b,$1c,$20,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$20,$33,$20,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$20                    
	db $f1,$ff,$2b,$15,$22,$4d,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$22                    
	db $00,$ff,$33,$2b,$22,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$22                    
	db $f8,$ff,$20,$19,$22,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$33,$2b,$22,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$2b,$20,$22,$4d,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$22                    
	db $00,$f7,$33,$0e,$22    ,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$22                    
	db $00,$f7,$22,$33,$22    ,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$22                    
	db $f1,$f7,$2b,$22,$20    ,$4c,$9a,$98,$9a
	db $00,$f7,$22,$33,$20    ,$4c,$9a,$98,$9a
	db $00,$f7,$33,$2b,$20    ,$4c,$9a,$98,$9a
	db $00,$07,$2b,$22,$20                    
	db $f1,$ff,$22,$33,$20,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$20                    
	db $00,$ff,$2b,$22,$20,$4d,$4c,$9a,$98,$9a
	db $00,$07,$22,$33,$20                    
	db $00,$ff,$33,$2b,$20,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$2b,$22,$20,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$20,$33,$20,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$20                    
	db $f8,$ff,$2b,$20,$19,$4d,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$19                    
	db $00,$ff,$33,$2b,$1c,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$1c                    
	db $00,$ff,$20,$33,$20,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$33,$2b,$20,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$2b,$20,$22,$4d,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$22                    
	db $f1,$ff,$33,$2b,$20,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$20                    
	db $00,$ff,$20,$33,$20,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$20                    
	db $f8,$ff,$2b,$20,$26,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$20,$33,$26,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$33,$2b,$26,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$26                    
	db $f1,$f7,$20,$33,$26    ,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$26                    
	db $00,$f7,$2b,$20,$26    ,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$26                    
	db $f1,$f7,$33,$2b,$26    ,$4c,$9a,$98,$9a
	db $00,$f7,$2b,$20,$26    ,$4c,$9a,$98,$9a
	db $00,$f7,$20,$33,$26    ,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$26                    
	db $f1,$fb,$33,$15    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$2b,$2b                        
	db $00,$fb,$1c,$33    ,$4d,$4c,$9a,$98,$9a
	db $00,$03,$33,$2b                        
	db $00,$ff,$2b,$11,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$1c,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$1c,$33                    
	db $f8,$ff,$1c,$0b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$33                    
	db $00,$ff,$2b,$1c,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$1c,$33,$33                    
	db $00,$ff,$33,$0c,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$2b,$1c,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$20,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$33                    
	db $f1,$ff,$2b,$10,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$33                    
	db $00,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$33                    
	db $f8,$ff,$20,$11,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$2b,$20,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$33                    
	db $00,$ff,$33,$15,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$33                    
	db $00,$ff,$22,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$33                    
	db $f1,$ff,$2b,$19,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$22,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$22,$33                    
	db $f1,$ff,$22,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$33                    
	db $00,$ff,$2b,$22,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$22,$33,$33                    
	db $00,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$2b,$22,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$20,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$33                    
	db $f8,$ff,$2b,$20,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$33                    
	db $00,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$33                    
	db $00,$ff,$20,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$2b,$20,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$33                    
	db $f1,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$33                    
	db $00,$ff,$20,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$33                    
	db $f8,$ff,$2b,$20,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$20,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$2b,$20,$33                    
	db $f1,$ff,$20,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$33                    
	db $00,$ff,$2b,$20,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$20,$33,$33                    
	db $f1,$ff,$33,$2b,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$2b,$20,$33,$4d,$4c,$9a,$98,$9a
	db $00,$ff,$20,$33,$33,$4d,$4c,$9a,$98,$9a
	db $00,$07,$33,$2b,$33                    
	db $ff,$00                                
	db $ff



#ifdef TI83
.END
	dw $0000
.END
#endif

end
