#define TI82				; select target platform here
;#define TI83

#ifdef TI82
#include CRASH82.INC
#else
#nolist
#include ion.inc
#list
	.ORG	progstart
	xor a
	jr	nc,begin
	ret
#endif

.DB "OCTODE TI 0.1", 0		; put a song name of your choice here
#define db .byte
#define dw .word


;Octode beeper music engine by Shiru (shiru@mail.ru) 02'11
;Eight channels of tone
;One channel of interrupting drums, no ROM data required
;Feel free to do whatever you want with the code, it is PD
;Modified for Z80 TI calculators by utz


begin
#ifdef TI82
	ld   a,%00010000			;+ set interrupts to fastest mode
	out (4),a
#endif
	
	ld hl,musicData
	call play

#ifdef TI82	
	ld a,%00010110				;+ set interrupts back to normal
	out (4),a
#endif

	ret

OP_NOP	.EQU $00
OP_RRA	.EQU $1f
OP_SCF	.EQU $37
OP_ORC	.EQU $b1


.MODULE octode

play
	di
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (_speed),de

	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (_ptr),de

	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (_loop),de

readNotes
_ptr .EQU $+1
	ld hl,0
	ld a,(hl)
	inc hl
	cp 240
	jr c,_noLoop
	cp 255
	jr nz,_drum
_loop .EQU $+1
	ld hl,0
	ld (_ptr),hl
	jp _checkKey

_drum
	ld (_ptr),hl
	ld b,8
	ld hl,_drum2
	ld (hl),OP_NOP
	inc hl
	djnz $-3
	sub 240
	jr z,_drum0
	ld b,a
	ld hl,_drum2
	ld (hl),OP_RRA
	inc hl
	djnz $-3
_drum0
	ld bc,100*256
_drum1
	ld a,c
_drum2 .EQU $
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
	
	push af		;+11
	bit 4,a		;+8
	jr nz, $+6	;+7/12
	ld a,$fc	;+7
	jr $+6		;+12 
	nop			;+4
	nop			;+4
#ifdef TI82
	ld a,$c0	;+7
#else
	ld a,$ff
#endif
	out (0),a	;11
	out (0),a	;+11
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
#ifdef TI82
	ld a,$c0	;+7
#else
	ld a,$ff
#endif
	out (0),a	;11
	
	out (0),a	;+11
	push hl		;+11
	nop			;+4
	nop			;+4
	pop hl		;+11
	pop af		;+10	+55/56 +41

	djnz _drum1

	ld hl,(_ptr)

_noLoop
	ld b,(hl)
	inc hl

	ld c,OP_SCF

	xor a
	rr b
	jr nc,_ch1
	ld a,(hl)
	inc hl
	ld (_frq0),a
	ld a,c
_ch1
	ld (_off0),a

	xor a
	rr b
	jr nc,_ch2
	ld a,(hl)
	inc hl
	ld (_frq1),a
	ld a,c
_ch2
	ld (_off1),a

	xor a
	rr b
	jr nc,_ch3
	ld a,(hl)
	inc hl
	ld (_frq2),a
	ld a,c
_ch3
	ld (_off2),a

	xor a
	rr b
	jr nc,_ch4
	ld a,(hl)
	inc hl
	ld (_frq3),a
	ld a,c
_ch4
	ld (_off3),a

	xor a
	rr b
	jr nc,_ch5
	ld a,(hl)
	inc hl
	ld (_frq4),a
	ld a,c
_ch5
	ld (_off4),a

	xor a
	rr b
	jr nc,_ch6
	ld a,(hl)
	inc hl
	ld (_frq5),a
	ld a,c
_ch6
	ld (_off5),a

	xor a
	rr b
	jr nc,_ch7
	ld a,(hl)
	inc hl
	ld (_frq6),a
	ld a,c
_ch7
	ld (_off6),a

	xor a
	rr b
	jr nc,_chDone
	ld a,(hl)
	inc hl
	ld (_frq7),a
	ld a,c
_chDone
	ld (_off7),a

	ld (_ptr),hl

_prevBC .EQU $+1
	ld bc,0
_speed .EQU $+1
	ld hl,0
	and a

soundLoop
	xor a		;4

	dec b		;4
	jr z,_la0	;7/12
	nop			;4
	jr _lb0		;12
_la0
_frq0 .EQU $+1
	ld b,0		;7
_off0 .EQU $
	scf			;4
_lb0
	dec c		;4
	jr z,_la1	;7/12
	nop			;4
	jr _lb1		;12
_la1
_frq1 .EQU $+1
	ld c,0		;7
_off1 .EQU $
	scf			;4
_lb1
	dec d		;4
	jr z,_la2	;7/12
	nop			;4
	jr _lb2		;12
_la2
_frq2 .EQU $+1
	ld d,0		;7
_off2 .EQU $
	scf			;4
_lb2
	dec e		;4
	jr z,_la3	;7/12
	nop			;4
	jr _lb3		;12
_la3
_frq3 .EQU $+1
	ld e,0		;7
_off3 .EQU $
	scf			;4
_lb3
	exx			;4
	
	push af		;+11
	bit 4,a		;+8
	jr nz, $+6	;+7/12
	ld a,$fc	;+7
	jr $+6		;+12 
	nop			;+4
	nop			;+4
#ifdef TI82
	ld a,$c0	;+7
#else
	ld a,$ff
#endif 
	out (0),a	;11
	
	out (0),a	;+11
	push hl		;+11
	nop			;+4
	nop			;+4
	pop hl		;+11
	pop af		;+10	+55/56 +41
	
	dec b		;4
	jr z,_la4	;7/12
	nop			;4
	jr _lb4		;12
_la4
_frq4 .EQU $+1
	ld b,0		;7
_off4 .EQU $
	scf			;4
_lb4
	dec c		;4
	jr z,_la5	;7/12
	nop			;4
	jr _lb5		;12
_la5
_frq5 .EQU $+1
	ld c,0		;7
_off5 .EQU $
	scf			;4
_lb5
	dec d		;4
	jr z,_la6	;7/12
	nop			;4
	jr _lb6		;12
_la6
_frq6 .EQU $+1
	ld d,0		;7
_off6 .EQU $
	scf			;4
_lb6
	dec e		;4
	jr z,_la7	;7/12
	nop			;4
	jr _lb7		;12
_la7
_frq7 .EQU $+1
	ld e,0		;7
_off7 .EQU $
	scf			;4
_lb7
	exx			;4
	sbc a,a		;4
	and 16		;7
	
	push af		;+11
	bit 4,a		;+8
	jr nz, $+6	;+7/12
	ld a,$fc	;+7
	jr $+6		;+12 
	nop			;+4
	nop			;+4
#ifdef TI82
	ld a,$c0	;+7
#else
	ld a,$ff
#endif
	out (0),a	;11
	
	out (0),a	;+11
	push hl		;+11
	nop			;+4
	nop			;+4
	pop hl		;+11
	pop af		;+10	+55/56 +41
	
	dec l		;4
	jp nz,soundLoop	;10 = 275t
	dec h		;4
	jp nz,soundLoop	;10

	ld (_prevBC),bc

	xor a
	
	push af		;+11
	bit 4,a		;+8
	jr nz, $+6	;+7/12
	ld a,$fc	;+7
	jr $+6		;+12 
	nop			;+4
	nop			;+4
#ifdef TI82
	ld a,$c0	;+7
#else
	ld a,$ff
#endif
	out (0),a	;11
	
	out (0),a	;+11
	push hl		;+11
	nop			;+4
	nop			;+4
	pop hl		;+11
	pop af		;+10	+55/56 +41


_checkKey
	xor a
	ld c,a
	ld a,%10111111				;+ new keyhandler
	out (1),a
	in a,(1)				;read keyboard
	cpl
	bit 6,a
	jp z,readNotes

stopPlayer
	exx
	ei
	ret

musicData
#include "ti1bit/octode/music.asm"

#ifdef TI83
.END
	dw $0000
.END
#endif
