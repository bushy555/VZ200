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


;poww - 1-bit music routine for ZX Spectrum
;by utz 05'2013
;Code is released into Public Domain wherever this is applicable.

		
begin		
		call	$01c9		; CLS


		ld	hl, MSG
		call	$28a7			; display message

		di
		ld de,sdata
		call rdata
		ret nz
		jr begin

rdata		ld h,80			;---> set speed value here <----
		ld a,33
		ld (sw2),a
		ld (nsw2),a			;revert possible code modification

		ld a,(de)			;load drum byte
		cp $ff				;if it is $ff
		ret z				;we've reached the end of the song
		or a
		jr z,rd1
		exx
		ld hl,$3000
		dec a
		call z,drum1
		dec a
		call z,drum2
		exx
		dec h
		dec h
		dec h
		
rd1		inc de
		ld a,(de)			;load instrument byte
		exx
		ld b,0
		ld c,a
		exx

		inc de
		ld a,(de)		
		or a
		jr nz,sadj			;if ch1 is muted
		ld (sw2),a			;deactivate flip mask
		ld a,32			;still need to generate something to keep the timing stable
		
		
sadj		ld l,a
		xor a
		ld (sw1),a			;revert possible code modification
		ld b,8
dloop						;speed adjustment: divide speed val by note val ch1
		sla h
		rla
		cp l
		jr c, $+4
		sub l
		inc h
		djnz dloop		
		
		inc h
		ld b,h
		
		ld a,(de)
		or a
		jr nz,skm1
		ld a,32
skm1		inc de				;increase data pointer
		
		exx
		ld de,pwtab			;point to pwm table
		ld hl,pw0			;point to pwm template
		add hl,bc
		ld c,11				;calculate 11 values
		
pwtlp		ld b,(hl)			;read pwm multiplier
		push af
		push de
		ld d,a
pwtlp1		add a,d				;multiply note byte with pwm multiplier
		djnz pwtlp1
		
		pop de
		ld (de),a			;store value in pwm table
		pop af
		inc hl
		inc de				;and off to the next value
		dec c
		jr nz,pwtlp
	
		exx
		
		ld a,(de)			;read note byte ch2
		or a
		jr nz,skch2			;if ch2 is supposed to be muted (note byte = $00)
		ld (nsw2),a			;override mask flip
		cpl				;set note counter to $ff
		
skch2		inc de
		push de				;preserve song data pointer
		ld e,a				;save counter ch2 in d, and back a backup in e
		ld d,a

rinit		push bc				;preserve speed counter
		ld hl,pwtab			;point to pwm table
		ld a,32			;switch on output mask
		ld c,11				;table is 12 bytes long
		
sndlp		ld b,(hl)		;7	;get counter value

s1		;out ($fe),a		;11	;send out mask
		ld 	(26624), a
		ex af,af'		;4
		nop			;4
		nop			;4
		nop			;4
sw1 EQU $+1			
		ld a,1			;7	;self-modifying, will be replaced by ld a,10 if counter ch2 flips
;		out ($fe),a		;11	;out ch2
		ld 	(26624), a

		dec d			;4	;decrement counter ch2
		jp z,note2		;10	;if it has reached 0, flip mask and backup counter
		
swr		ex af,af'		;4
		djnz s1			;13	;decrement pwm counter

sw2 EQU $+1		
		xor 32	;$10			;7	;flip mask ch1 for next pwm counter
		inc hl			;6
		dec c			;4	;see if we're done with all 12 steps
		jp nz,sndlp		;10
		
		pop bc				;restore speed counter
		djnz rinit			;if it isn't 0, repeat process

		pop de				;else, restore data pointer
		
;		in a,($fe)			;read keyboard
;		cpl
;		and $1f
;		jr nz,exit
		jp rdata			;and read in next notes

exit		exx
		ld hl,$2758			;restore HL' as needed by BASIC
		exx
		xor a
		out ($fe),a			;make sure sound is turned off
		cpl
		or a
		ei
		ret

note2		
nsw2 EQU $+1	
		xor 32
		ld (sw1),a
		ld d,e
		jp swr

		
drum2		ld bc,$03fd
dlp2		call dlpx
		ld a,b
		or c
		jr nz,dlp2
		ret

drum1		ld de,$0809
		ld b,72
dlp3		call dlpx
dlp4		dec d
		jr nz,dlp4
		ld d,e
		inc e
		djnz dlp3
		ret

dlpx		ld a,(hl)
;		or %11100111
;		xor %11100111

;		or 	33
;		xor	33
;		or 	231
;		xor	231

;	or 33
 and 33
	xor 33

;		out ($fe),a
		ld 	(26624), a

		inc hl
		dec bc
		ret		


MSG		db ".-#  POWW 1-BIT ENGINE  #-.",$0d,0$d,00

pwtab:
		db 0,0,0,0,0,0,0,0,0,0,0,0

pw0:		db 4,1,9,1,3,2,2,3,1,9,1	;pwm templates (instruments)
		db 2,2,8,2,3,2,2,3,2,8,2
		db 4,2,3,2,4,1,10,1,4,2,3
		db 6,5,4,3,2,1,1,2,3,4,5
		db 1,1,2,3,5,6,6,5,4,2,1
		db 3,3,3,3,3,3,3,3,4,4,4
		db 5,1,5,2,5,1,5,1,5,1,5
		db 1,1,7,7,1,1,1,1,1,7,8
		db 0,0,9,9,0,0,0,0,0,9,9
		db 0,9,0,0,9,0,0,9,0,0,9

sdata:		


	db 1,0,17,0
	db 0,0,15,0
	db 0,0,13,0
	db 0,0,5,0
	db 1,0,10,0

	db 1,11,17,0
	db 0,11,15,0
	db 0,11,13,0
	db 0,11,5,0
	db 1,11,10,0
	
	db 1,33,17,0
	db 0,33,15,0
	db 0,33,13,0
	db 0,33,5,0
	db 1,33,10,0

	db 1,44,17,0
	db 0,44,15,0
	db 0,44,13,0
	db 0,44,5,0
	db 1,44,10,0

	db 1,55,17,0
	db 0,55,15,0
	db 0,55,13,0
	db 0,55,5,0
	db 1,55,10,0

	db 1,66,17,0
	db 0,66,15,0
	db 0,66,13,0
	db 0,66,5,0
	db 1,66,10,0

	db 1,77,17,0
	db 0,77,15,0
	db 0,77,13,0
	db 0,77,5,0
	db 1,77,10,0

	db 1,88,17,0
	db 0,88,15,0
	db 0,88,13,0
	db 0,88,5,0
	db 1,88,10,0
	
	db 1,99,17,0
	db 0,99,15,0
	db 0,99,13,0
	db 0,99,5,0
	db 1,99,10,0	

	db 2,0,0,200
	db 0,0,0,180
	db 0,0,0,150
	db 2,0,0,120
	db 2,0,0,80
	
	db 1,0,17,200
	db 0,0,15,180
	db 0,0,13,150
	db 1,0,5,120
	db 1,0,10,80
	
	db 2,0,17,80
	db 0,0,15,70
	db 0,0,13,60
	db 0,0,5,50
	db 2,0,10,40
	
	db 1,0,17,200
	db 0,0,15,200
	db 0,0,13,200
	db 0,0,5,200
	db 1,0,10,200
	
	db 2,0,9,89
	db 0,0,8,89
	db 0,0,6,89
	db 0,0,6,89
	db 2,0,4,89
	db 2,0,4,89
	db 0,0,6,89
	db 0,11,6,89
	db 0,22,6,89
	db 2,0,5,88
	db 2,11,5,88
	db 0,22,5,88
	db 2,0,5,44
	db 2,0,5,22
	db 1,0,0,0
	db 1,0,0,0
	db $ff

end		
