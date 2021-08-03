; HUBY-N  ---    HUBY MUSIC BOX #3
; 
; +-----------------------------------------------+
; !                                               !
; !              VZ 2-channel "chip tune"         !
; !                     Music Player              !
; !                                               !
; !                                  Bushy. 03/19 !
; !                                               !
; !   Assemble with:                              !
; !   tasm -80 -b <filename>                      !
; !   rbinary <filename.obj> <filename.vz>        !
; +-----------------------------------------------+
;              

#define defb .db
#define DEFB .DB
#define defw .dw
#define DEFW .DW
#define db  .db
#define DB  .DB
#define dw  .dw
#define DW  .DW
#define end .end
#define END .end
#define org .org
#define ORG .org
#define equ .equ
#define EQU .EQU

	ORG	$8000


; -------------------------------------------
; original ZX player comments by Shiru
; -------------------------------------------
;Huby beeper music engine by Shiru (shiru@mail.ru) 04'11
;Two channels of tone, no volume, global speed
;One drum, replaces note on the first channel
;The main feature of this engine is the size, just 100 bytes
;Feel free to do whatever you want with the code, it is PD
;modified for TI82 by utz, Akareyon, and calc84maniac
;well, unfortunately it's more than 100 bytes now :(
;
;
; -------------------------------------------
; .....dopey comments by Bushy. 31/mar/2019
; -------------------------------------------
;
; Huby 1-bit player. Originally 100 byte player but modified as above. 2 channels.
; ZX-10 1-bit player. A player written for the Ti Calculator. 4 channels.
;
; 1. Harder Faster Better
; 2. LAURA
; 3. LAUTRE VALSE
; 4. MONTY ON THE RUN
; 5. PHAZER
;
; Things to try #1
; -----------------
; Grab Beepola. The 1-bit tracker written by Chris Cowley.
; Find .BBSONG modules.
; Export as asm-only.
; Copy & paste asm into player. Modify the menu and selection bit. Just follow current items.
; Save & compile with TASM cross assembler v3.01 (Speech Tech).
;              tasm -80 -b <filename>
;              rbinary <filename.obj> <filename.vz>
;              ( rbinary.exe can be found on various VZ websites, usually included in the tasm.zip found on these sites.
;              ( ...or just ask for it on Facebook / VZEMU yahoogroups mailing list
;
;
; Things to try #3
; -----------------
; Find & grab 1-tracker. Load in .1TM files, export out as .ASM.
; Load into this source, re-assemble. RUn.
;
; 
; Things to try #3
; -----------------
; Find any .XM music module that clearly does not have samples within --- only has synthesised instruments. Usually are well under 100k in size.
; Use XM2HUBY.EXE which converts from the .XM format to an .ASM listing.
; Copy and paste and do menu.
; Save & compiled as above.
;
;
;


start:
begin:
cls:	ei
	call	$01c9		; VZ ROM CLS
	ld	hl, MSG1	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG2
	call	$28a7
	ld	hl, POSCURSOR	; reposition cursor to show key input 
	call	$28a7


scan:	call 	$2ef4		; VZ scan keyboard
	or 	a		; any key pressed?
	jr	z, scan		; back if not
				; 	Menu selection.  
	cp	49		; "1 - "
	jr	z, m1		; 	
	cp	50		; "2 - "
	jr	z, m2
	cp	51		; "3 - "
	jr	z, m3
	cp	52		; "4 - "
	jr	z, m4
	cp	53		; "5 - "
	jr	z, m5

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
m3: 	ld 	hl, D3
	ld 	de,musicData3
	jp 	continue
m4: 	ld 	hl, D4
	ld 	de,musicData4
	jp 	continue
m5: 	ld 	hl, D5
	ld 	de,musicData5
	jp 	continue

continue:	push	de			; save de (music offset) 
		push	hl
		ld 	hl, PLAYING
		call 	$28a7
		pop	hl
		call 	$28a7			; print message. 
		pop 	hl			; restore musicData offset into HL
		call 	huby_play
		jp	begin	

huby_play: 	di
		LD    C,(HL)		  ; Read the tempo word
		INC   HL
		LD    B,(HL)
		INC   HL
		LD    E,(HL)		  ; Offset to pattern data is 
		INC   HL		  ; kept in DE always. 
		LD    D,(HL)		  ; And HL = current position in song layout.
READPOS: 	INC   HL
		LD    A,(HL)		  ; Read the pattern number for channel 1
		INC   HL
		OR    A
		RET   Z 		  ; Zero signifies the end of the song

; This code is for handling Tempo changes in the middle of a song.
; As the song data specified in Beepola (see MUSICDATA below) doesn't
; have any tempo changes, this code has been commented out to save 9
; bytes. Uncomment it if you want to use this routine to play tunes
; that contain mid-song tempo changes...
		CP    $FF		  ; $FF signifies SET TEMPO
		JR    NZ,NOT_TEMPO
		LD    C,(HL)
		INC   HL
		LD    B,(HL)
		JR    READPOS

NOT_TEMPO: 	PUSH  HL		  ; Store the layout pointer
		PUSH  DE		  ; Store the pattern offset pointer
		PUSH  BC		  ; Store current tempo
		LD    L,(HL)		  ; Read the pattern number for channel 2
		LD    B,2		  ; DJNZ through following code twice (1x for each channel)
CALC_ADR: 	LD    H,0		  ; Multiply pattern number by 8...
		ADD   HL,HL		  ; x2
		ADD   HL,HL		  ; x4
		ADD   HL,HL		  ; x8
		ADD   HL,DE		  ; Add the offset to the pattern data
		PUSH  HL		  ; Store the address of pattern data
		LD    L,A
		DJNZ  CALC_ADR		  ; Do the same thing for channel 2
		EXX
		POP   HL
		POP   DE
		LD    B,8		  ; Fixed pattern length = 8 rows
READ_ROW: 	LD    A,(DE)		  ; Read note for channel 1
		INC   DE		  ; inc channel 1 row pointer
		EXX
		LD    H,A
		LD    D,A
		EXX
		LD    A,(HL)		  ; Read note for channel 2
		INC   HL		  ; inc channel 2 row pointer
		EXX
		LD    L,A
		LD    E,A
		CP    $2c	      ; If channel 1 note == $2C then play drum
		JR    Z,SET_DRUMSLIDE
		XOR   A
SET_DRUMSLIDE:  LD    (SND_SLIDE),A
		POP   BC		  ; Retrieve tempo
		PUSH  BC
		DI
SOUND_LOOP: 	XOR   A
		DEC   E
		JR    NZ,SND_LOOP1
		LD    E,L
		SUB   L
SND_SLIDE: 	NOP 			  ; This is set to INC L for the drum sound
SND_LOOP1: 	DEC   D
		JR    NZ,SND_LOOP2
		LD    D,H
		SUB   H
SND_LOOP2: 	SBC   A,A
		and 	33
		ld      (26624), a
;		ld      (26624), a
;		ld      (26624), a
;		ld      (26624), a

					; READ KEYBOARD.				
		ld 	a, ($68DF)	; $68DF	Address for minus key.  Bit 2 = 0 when Minus Key is pressed.  =59d
		CPL			; %111011 --> invert --> %000100
		AND 4			; cmp to 4?
		jr	z, no_key	; JP if not = 59 (minus key pressed)

		exx 			; Key pressed. Exchange regs
		ei
		jp 	start		; Jp Start to start over.
no_key:		DEC   BC
		LD    A,B
		OR    C
		JR    NZ,SOUND_LOOP	  ; 113/123 Ts

SND_LOOP3: 	LD    HL,$2758		  ; Set HL' for returning to BASIC
		EXX   
		EI
		JR    NZ,PATTERN_END
		DJNZ  READ_ROW
PATTERN_END: 	POP   BC
		POP   DE
		POP   HL
		JR    Z,READPOS 	  ; No key pressed, goto next pattern
		RET 			  ; Otherwise return


MSG1 	db	"HUBY MUSICBOX #3.      BUSHY'19", $0d
	db 	$0d,$0d, "PLEASE SELECT:  ", $0d
	db 	"1 HARDER FASTER BETTER", $0d
	db 	"2 LAURA", $0d
	db 	"3 LAUTRE VALSE", $0d
	db 	"4 MONTY ON THE RUN", $0d
	db 	"5 PHAZER", $0d,00

MSG2	
	db 	$0d, ">",00


MSGQUIT db	$08, $08, "QUIT...",$0d,00
PLAYING db	08,08,08,"NOW PLAYING:",0

POSCURSOR db	09,00
D1 	db	"HARDER FASTER BETTER",0,0		
D2 	db	"LAURA",0,0			
D3 	db	"LAUTRE VALSE",0,0			
D4 	db	"MONTY ON THE RUN",0,0
D5 	db	"PHAZER",0,0


;---------------------------------
; SONG 1 : Harder Faster Better
;---------------------------------
musicData1:
                DEFW  $0E6C               ; Initial tempo
                DEFW  md1 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0B
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $0A
                DEFB  $19
                DEFB  $0C
                DEFB  $1A
                DEFB  $0E
                DEFB  $19
                DEFB  $0F
                DEFB  $10
                DEFB  $02
                DEFB  $1B
                DEFB  $04
                DEFB  $1C
                DEFB  $06
                DEFB  $1D
                DEFB  $08
                DEFB  $1E
                DEFB  $0A
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $1F
                DEFB  $0F
                DEFB  $23
                DEFB  $24
                DEFB  $25
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $18
                DEFB  $0A
                DEFB  $19
                DEFB  $2B
                DEFB  $1A
                DEFB  $22
                DEFB  $19
                DEFB  $0F
                DEFB  $10
                DEFB  $02
                DEFB  $1B
                DEFB  $04
                DEFB  $1C
                DEFB  $06
                DEFB  $1D
                DEFB  $08
                DEFB  $1E
                DEFB  $0A
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $1F
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $27
                DEFB  $15
                DEFB  $29
                DEFB  $17
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $2F
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $12
                DEFB  $35
                DEFB  $14
                DEFB  $36
                DEFB  $16
                DEFB  $37
                DEFB  $38
                DEFB  $0A
                DEFB  $39
                DEFB  $2B
                DEFB  $3A
                DEFB  $22
                DEFB  $39
                DEFB  $0F
                DEFB  $10
                DEFB  $3B
                DEFB  $12
                DEFB  $3C
                DEFB  $14
                DEFB  $3D
                DEFB  $16
                DEFB  $3E
                DEFB  $3F
                DEFB  $0A
                DEFB  $40
                DEFB  $2B
                DEFB  $41
                DEFB  $22
                DEFB  $40
                DEFB  $0F
                DEFB  $10
                DEFB  $34
                DEFB  $12
                DEFB  $35
                DEFB  $14
                DEFB  $36
                DEFB  $16
                DEFB  $37
                DEFB  $2C
                DEFB  $42
                DEFB  $2E
                DEFB  $43
                DEFB  $44
                DEFB  $45
                DEFB  $2E
                DEFB  $46
                DEFB  $47
                DEFB  $48
                DEFB  $49
                DEFB  $4A
                DEFB  $4B
                DEFB  $4C
                DEFB  $4D
                DEFB  $4E
                DEFB  $4F
                DEFB  $50
                DEFB  $51
                DEFB  $52
                DEFB  $53
                DEFB  $54
                DEFB  $55
                DEFB  $56
                DEFB  $57
                DEFB  $58
                DEFB  $59
                DEFB  $4A
                DEFB  $5A
                DEFB  $4C
                DEFB  $5B
                DEFB  $5C
                DEFB  $5D
                DEFB  $5E
                DEFB  $5F
                DEFB  $60
                DEFB  $61
                DEFB  $60
                DEFB  $62
                DEFB  $60
                DEFB  $63
                DEFB  $48
                DEFB  $64
                DEFB  $65
                DEFB  $66
                DEFB  $67
                DEFB  $68
                DEFB  $5C
                DEFB  $69
                DEFB  $50
                DEFB  $6A
                DEFB  $52
                DEFB  $6B
                DEFB  $54
                DEFB  $6C
                DEFB  $6D
                DEFB  $6E
                DEFB  $58
                DEFB  $6F
                DEFB  $4A
                DEFB  $70
                DEFB  $4C
                DEFB  $71
                DEFB  $4E
                DEFB  $72
                DEFB  $73
                DEFB  $6A
                DEFB  $74
                DEFB  $6B
                DEFB  $74
                DEFB  $75
                DEFB  $74
                DEFB  $76
                DEFB  $77
                DEFB  $64
                DEFB  $78
                DEFB  $79
                DEFB  $7A
                DEFB  $7B
                DEFB  $78
                DEFB  $7C
                DEFB  $74
                DEFB  $7D
                DEFB  $7E
                DEFB  $7F
                DEFB  $80
                DEFB  $81
                DEFB  $82
                DEFB  $83
                DEFB  $84
                DEFB  $64
                DEFB  $85
                DEFB  $86
                DEFB  $87
                DEFB  $68
                DEFB  $85
                DEFB  $7C
                DEFB  $88
                DEFB  $7D
                DEFB  $89
                DEFB  $8A
                DEFB  $8B
                DEFB  $8C
                DEFB  $8D
                DEFB  $8E
                DEFB  $88
                DEFB  $64
                DEFB  $8F
                DEFB  $86
                DEFB  $90
                DEFB  $71
                DEFB  $91
                DEFB  $69
                DEFB  $92
                DEFB  $93
                DEFB  $94
                DEFB  $6B
                DEFB  $95
                DEFB  $96
                DEFB  $97
                DEFB  $98
                DEFB  $99
                DEFB  $64
                DEFB  $9A
                DEFB  $70
                DEFB  $9B
                DEFB  $71
                DEFB  $9C
                DEFB  $9D
                DEFB  $9E
                DEFB  $7D
                DEFB  $9F
                DEFB  $A0
                DEFB  $A1
                DEFB  $6C
                DEFB  $A2
                DEFB  $8E
                DEFB  $A3
                DEFB  $64
                DEFB  $A4
                DEFB  $86
                DEFB  $A5
                DEFB  $68
                DEFB  $A6
                DEFB  $7C
                DEFB  $A7
                DEFB  $7D
                DEFB  $A8
                DEFB  $A9
                DEFB  $AA
                DEFB  $81
                DEFB  $AB
                DEFB  $83
                DEFB  $AC
                DEFB  $64
                DEFB  $AD
                DEFB  $86
                DEFB  $AE
                DEFB  $68
                DEFB  $AF
                DEFB  $7C
                DEFB  $B0
                DEFB  $7D
                DEFB  $B1
                DEFB  $B2
                DEFB  $B3
                DEFB  $B4
                DEFB  $B5
                DEFB  $8E
                DEFB  $B6
                DEFB  $64
                DEFB  $9A
                DEFB  $86
                DEFB  $B7
                DEFB  $68
                DEFB  $B8
                DEFB  $7C
                DEFB  $B9
                DEFB  $7D
                DEFB  $BA
                DEFB  $A9
                DEFB  $BB
                DEFB  $81
                DEFB  $BC
                DEFB  $83
                DEFB  $AC
                DEFB  $64
                DEFB  $AD
                DEFB  $86
                DEFB  $AE
                DEFB  $68
                DEFB  $AF
                DEFB  $7C
                DEFB  $B0
                DEFB  $7D
                DEFB  $B1
                DEFB  $B2
                DEFB  $B3
                DEFB  $B4
                DEFB  $B5
                DEFB  $8E
                DEFB  $BD
                DEFB  $64
                DEFB  $BE
                DEFB  $86
                DEFB  $BF
                DEFB  $68
                DEFB  $C0
                DEFB  $7C
                DEFB  $C1
                DEFB  $7D
                DEFB  $C2
                DEFB  $C3
                DEFB  $C4
                DEFB  $C5
                DEFB  $C6
                DEFB  $8E
                DEFB  $BD
                DEFB  $64
                DEFB  $C7
                DEFB  $86
                DEFB  $88
                DEFB  $68
                DEFB  $84
                DEFB  $7C
                DEFB  $85
                DEFB  $7D
                DEFB  $BD
                DEFB  $C8
                DEFB  $C9
                DEFB  $CA
                DEFB  $CB
                DEFB  $CC
                DEFB  $CD
                DEFB  $CD
                DEFB  $CD
                DEFB  $CD
                DEFB  $CD
                DEFB  $CD
                DEFB  $CD
                DEFB  $00                 ; End of song

md1:
                DEFB  $5B, $00, $79, $5B, $5B, $79, $5B, $5B
                DEFB  $B4, $00, $B4, $B4, $00, $B4, $B4, $00
                DEFB  $79, $00, $5B, $00, $00, $00, $00, $00
                DEFB  $5B, $00, $5B, $5B, $00, $5B, $5B, $00
                DEFB  $4C, $00, $66, $4C, $4C, $66, $4C, $4C
                DEFB  $97, $00, $97, $97, $00, $97, $97, $00
                DEFB  $66, $00, $4C, $00, $00, $00, $00, $00
                DEFB  $4C, $00, $4C, $4C, $00, $4C, $4C, $00
                DEFB  $88, $00, $5B, $88, $44, $5B, $5B, $44
                DEFB  $33, $00, $2D, $33, $00, $2D, $33, $00
                DEFB  $39, $5B, $5B, $39, $44, $5B, $5B, $44
                DEFB  $2D, $00, $00, $00, $2D, $33, $00, $2D
                DEFB  $88, $5B, $5B, $88, $44, $5B, $5B, $44
                DEFB  $33, $00, $2D, $33, $00, $00, $33, $00
                DEFB  $4C, $00, $00, $4C, $00, $00, $4C, $00
                DEFB  $2C, $5B, $79, $5B, $5B, $79, $5B, $2C
                DEFB  $00, $00, $00, $00, $3D, $00, $44, $3D
                DEFB  $66, $00, $2C, $66, $66, $88, $66, $66
                DEFB  $00, $44, $3D, $00, $44, $00, $4C, $44
                DEFB  $2C, $00, $4C, $72, $72, $4C, $72, $2C
                DEFB  $00, $4C, $44, $00, $51, $00, $5B, $51
                DEFB  $79, $00, $2C, $79, $79, $51, $79, $79
                DEFB  $00, $5B, $51, $00, $79, $00, $88, $79
                DEFB  $88, $00, $5B, $88, $88, $5B, $5B, $88
                DEFB  $72, $5B, $5B, $72, $88, $5B, $5B, $88
                DEFB  $88, $5B, $5B, $88, $88, $5B, $5B, $88
                DEFB  $79, $00, $2C, $00, $00, $00, $00, $00
                DEFB  $2C, $00, $66, $4C, $4C, $66, $4C, $2C
                DEFB  $66, $00, $2C, $00, $00, $00, $00, $00
                DEFB  $2C, $00, $5B, $88, $44, $5B, $5B, $2C
                DEFB  $39, $5B, $2C, $39, $44, $5B, $5B, $44
                DEFB  $2D, $00, $00, $00, $00, $00, $3D, $00
                DEFB  $2C, $5B, $5B, $88, $44, $5B, $5B, $2C
                DEFB  $00, $3D, $00, $00, $3D, $00, $00, $00
                DEFB  $2C, $5B, $79, $5B, $5B, $79, $5B, $5B
                DEFB  $00, $00, $00, $00, $5B, $00, $66, $5B
                DEFB  $2C, $00, $88, $66, $66, $88, $66, $66
                DEFB  $00, $66, $5B, $00, $44, $00, $4C, $44
                DEFB  $2C, $00, $4C, $72, $72, $4C, $72, $72
                DEFB  $00, $4C, $44, $00, $3D, $00, $44, $3D
                DEFB  $2C, $00, $51, $79, $79, $51, $79, $79
                DEFB  $00, $44, $3D, $00, $A1, $00, $B4, $A1
                DEFB  $2D, $00, $00, $00, $2D, $33, $3D, $00
                DEFB  $2C, $00, $79, $88, $88, $00, $88, $2C
                DEFB  $3D, $88, $44, $3D, $3D, $44, $44, $3D
                DEFB  $88, $00, $2C, $88, $88, $00, $88, $88
                DEFB  $3D, $44, $44, $3D, $3D, $44, $44, $3D
                DEFB  $2C, $00, $88, $88, $2C, $00, $88, $88
                DEFB  $2C, $00, $5B, $66, $2C, $5B, $66, $79
                DEFB  $44, $44, $3D, $00, $44, $00, $00, $00
                DEFB  $2C, $66, $79, $5B, $5B, $79, $5B, $2C
                DEFB  $B4, $00, $B4, $B4, $3D, $B4, $44, $3D
                DEFB  $5B, $44, $5B, $5B, $44, $5B, $4C, $44
                DEFB  $97, $4C, $97, $97, $51, $97, $5B, $51
                DEFB  $4C, $5B, $4C, $4C, $79, $4C, $88, $79
                DEFB  $2C, $00, $5B, $88, $2C, $5B, $5B, $88
                DEFB  $2C, $5B, $5B, $72, $2C, $5B, $5B, $88
                DEFB  $2C, $5B, $5B, $88, $2C, $5B, $5B, $88
                DEFB  $B4, $00, $B4, $B4, $5B, $B4, $66, $5B
                DEFB  $5B, $66, $5B, $5B, $4C, $5B, $4C, $4C
                DEFB  $97, $4C, $97, $97, $3D, $97, $44, $3D
                DEFB  $4C, $44, $4C, $4C, $A1, $4C, $B4, $A1
                DEFB  $2C, $00, $5B, $88, $88, $5B, $5B, $2C
                DEFB  $72, $5B, $2C, $72, $88, $5B, $5B, $88
                DEFB  $2C, $5B, $5B, $88, $88, $5B, $5B, $2C
                DEFB  $B4, $88, $97, $B4, $88, $97, $97, $88
                DEFB  $5B, $97, $4C, $5B, $44, $4C, $4C, $44
                DEFB  $2C, $00, $88, $88, $88, $00, $88, $2C
                DEFB  $3D, $4C, $44, $3D, $4C, $44, $5B, $4C
                DEFB  $66, $5B, $5B, $66, $4C, $5B, $5B, $4C
                DEFB  $2C, $00, $88, $5B, $5B, $00, $5B, $2C
                DEFB  $B4, $5B, $97, $B4, $5B, $97, $4C, $5B
                DEFB  $5B, $00, $2C, $5B, $5B, $00, $5B, $5B
                DEFB  $3D, $4C, $4C, $3D, $5B, $4C, $4C, $5B
                DEFB  $2C, $00, $5B, $66, $66, $00, $66, $2C
                DEFB  $66, $4C, $66, $66, $4C, $66, $66, $4C
                DEFB  $66, $00, $2C, $66, $66, $00, $66, $66
                DEFB  $44, $66, $4C, $44, $51, $4C, $4C, $51
                DEFB  $2C, $00, $66, $6C, $6C, $00, $6C, $2C
                DEFB  $36, $4C, $6C, $36, $5B, $6C, $6C, $5B
                DEFB  $6C, $00, $2C, $6C, $6C, $00, $6C, $6C
                DEFB  $44, $6C, $4C, $44, $5B, $4C, $6C, $5B
                DEFB  $2C, $00, $6C, $72, $72, $00, $72, $2C
                DEFB  $72, $6C, $72, $72, $5B, $72, $4C, $5B
                DEFB  $5B, $00, $2C, $5B, $5B, $5B, $5B, $5B
                DEFB  $B4, $4C, $B4, $B4, $B4, $B4, $B4, $B4
                DEFB  $2C, $B4, $5B, $B4, $5B, $00, $5B, $2C
                DEFB  $B4, $B4, $97, $B4, $5B, $97, $4C, $5B
                DEFB  $5B, $00, $2C, $2D, $5B, $00, $5B, $B4
                DEFB  $2C, $00, $5B, $66, $33, $00, $66, $2C
                DEFB  $66, $00, $2C, $33, $66, $00, $66, $33
                DEFB  $44, $66, $4C, $44, $51, $4C, $26, $51
                DEFB  $2C, $00, $66, $6C, $36, $00, $6C, $2C
                DEFB  $4C, $26, $4C, $4C, $5B, $4C, $5B, $5B
                DEFB  $6C, $00, $2C, $36, $6C, $00, $6C, $36
                DEFB  $4C, $5B, $4C, $26, $5B, $4C, $5B, $5B
                DEFB  $2C, $00, $6C, $72, $00, $00, $72, $2C
                DEFB  $79, $00, $2C, $79, $00, $00, $79, $00
                DEFB  $2C, $00, $79, $5B, $2D, $79, $3D, $2C
                DEFB  $4C, $79, $2C, $4C, $5B, $79, $79, $5B
                DEFB  $3D, $4C, $4C, $3D, $5B, $4C, $26, $5B
                DEFB  $2C, $79, $88, $66, $66, $88, $44, $2C
                DEFB  $66, $4C, $66, $33, $4C, $66, $33, $4C
                DEFB  $51, $88, $2C, $51, $66, $88, $88, $66
                DEFB  $2C, $88, $44, $6C, $36, $88, $44, $2C
                DEFB  $5B, $88, $2C, $5B, $6C, $88, $44, $6C
                DEFB  $2C, $88, $4C, $72, $39, $4C, $26, $2C
                DEFB  $5B, $4C, $2C, $5B, $2D, $B4, $5B, $2D
                DEFB  $B4, $4C, $B4, $B4, $5B, $B4, $B4, $5B
                DEFB  $2C, $5B, $79, $B4, $2D, $3D, $1E, $2C
                DEFB  $4C, $79, $2C, $4C, $5B, $79, $3D, $5B
                DEFB  $2C, $79, $88, $66, $33, $88, $44, $2C
                DEFB  $51, $88, $2C, $51, $66, $88, $44, $66
                DEFB  $2C, $88, $44, $6C, $36, $88, $22, $2C
                DEFB  $4C, $4C, $4C, $4C, $5B, $4C, $5B, $2D
                DEFB  $4C, $5B, $4C, $26, $5B, $4C, $5B, $2D
                DEFB  $79, $4C, $2C, $79, $3D, $51, $28, $79
                DEFB  $2C, $51, $79, $5B, $2D, $79, $3D, $2C
                DEFB  $66, $5B, $2D, $66, $4C, $5B, $2D, $4C
                DEFB  $3D, $5B, $44, $3D, $4C, $44, $5B, $4C
                DEFB  $2C, $79, $88, $66, $66, $44, $22, $2C
                DEFB  $66, $5B, $2D, $66, $4C, $B4, $5B, $4C
                DEFB  $51, $44, $2C, $51, $66, $88, $22, $66
                DEFB  $2C, $88, $88, $6C, $6C, $88, $88, $2C
                DEFB  $5B, $88, $2C, $5B, $6C, $88, $88, $6C
                DEFB  $97, $5B, $97, $26, $B4, $97, $B4, $B4
                DEFB  $2C, $88, $4C, $72, $72, $97, $26, $2C
                DEFB  $4C, $B4, $4C, $26, $5B, $4C, $5B, $2D
                DEFB  $79, $4C, $2C, $79, $79, $51, $51, $79
                DEFB  $4C, $5B, $4C, $4C, $5B, $4C, $5B, $5B
                DEFB  $2C, $51, $79, $5B, $5B, $79, $79, $2C
                DEFB  $66, $5B, $B4, $66, $97, $B4, $B4, $97
                DEFB  $79, $B4, $88, $79, $97, $88, $B4, $97
                DEFB  $2C, $79, $88, $66, $66, $88, $88, $2C
                DEFB  $66, $B4, $B4, $66, $97, $B4, $B4, $97
                DEFB  $66, $B4, $5B, $66, $4C, $5B, $5B, $4C
                DEFB  $44, $3D, $44, $44, $4C, $44, $5B, $3D
                DEFB  $2C, $88, $4C, $72, $72, $4C, $72, $72
                DEFB  $66, $5B, $5B, $66, $4C, $5B, $44, $4C
                DEFB  $5B, $00, $5B, $5B, $5B, $5B, $5B, $5B
                DEFB  $B4, $44, $B4, $B4, $B4, $B4, $B4, $B4
                DEFB  $2C, $5B, $79, $5B, $5B, $79, $79, $2C
                DEFB  $3D, $5B, $2D, $4C, $5B, $2D, $66, $00
                DEFB  $5B, $4C, $5B, $5B, $4C, $5B, $2D, $4C
                DEFB  $3D, $5B, $4C, $97, $5B, $00, $3D, $00
                DEFB  $66, $4C, $5B, $66, $4C, $5B, $3D, $97
                DEFB  $5B, $88, $2C, $5B, $6C, $88, $22, $6C
                DEFB  $4C, $3D, $5B, $2D, $66, $5B, $5B, $66
                DEFB  $97, $5B, $88, $B4, $5B, $66, $97, $00
                DEFB  $79, $4C, $2C, $79, $5B, $51, $5B, $5B
                DEFB  $B4, $B4, $66, $66, $97, $66, $B4, $00
                DEFB  $2C, $5B, $79, $5B, $2D, $79, $3D, $2C
                DEFB  $44, $3D, $44, $22, $B4, $44, $B4, $3D
                DEFB  $66, $B4, $5B, $66, $66, $5B, $5B, $66
                DEFB  $44, $5B, $4C, $44, $66, $4C, $5B, $66
                DEFB  $4C, $5B, $5B, $4C, $3D, $5B, $44, $3D
                DEFB  $2C, $88, $88, $6C, $6C, $88, $22, $2C
                DEFB  $44, $5B, $4C, $5B, $44, $5B, $4C, $5B
                DEFB  $44, $5B, $4C, $5B, $44, $5B, $4C, $3D
                DEFB  $2C, $88, $4C, $72, $72, $4C, $26, $2C
                DEFB  $3D, $5B, $44, $5B, $4C, $3D, $44, $4C
                DEFB  $44, $44, $4C, $00, $44, $00, $66, $5B
                DEFB  $4C, $66, $97, $4C, $26, $5B, $5B, $4C
                DEFB  $3D, $5B, $5B, $4C, $5B, $2D, $3D, $66
                DEFB  $5B, $4C, $5B, $2D, $4C, $66, $5B, $4C
                DEFB  $3D, $5B, $4C, $26, $5B, $00, $3D, $B4
                DEFB  $97, $4C, $97, $97, $26, $B4, $5B, $97
                DEFB  $79, $88, $97, $4C, $B4, $00, $79, $B4
                DEFB  $2C, $88, $4C, $72, $72, $4C, $4C, $2C
                DEFB  $97, $4C, $B4, $97, $79, $B4, $88, $79
                DEFB  $4C, $3D, $79, $44, $88, $4C, $5B, $3D
                DEFB  $5B, $44, $66, $4C, $5B, $66, $79, $5B
                DEFB  $66, $5B, $5B, $5B, $79, $3D, $66, $44
                DEFB  $3D, $5B, $5B, $3D, $5B, $44, $66, $5B
                DEFB  $5B, $66, $5B, $5B, $66, $44, $5B, $4C
                DEFB  $44, $5B, $66, $44, $5B, $4C, $79, $5B
                DEFB  $66, $5B, $5B, $5B, $79, $00, $66, $5B
                DEFB  $72, $88, $6C, $72, $88, $00, $72, $00
                DEFB  $2D, $5B, $2D, $2D, $5B, $2D, $5B, $5B
                DEFB  $79, $00, $00, $79, $5B, $00, $5B, $5B
                DEFB  $B4, $B4, $5B, $B4, $5B, $00, $B4, $B4
                DEFB  $44, $3D, $44, $44, $B4, $44, $B4, $3D
                DEFB  $44, $5B, $4C, $44, $79, $4C, $88, $79
                DEFB  $97, $88, $B4, $97, $B4, $B4, $B4, $B4
                DEFB  $B4, $B4, $79, $B4, $66, $79, $79, $66
                DEFB  $66, $B4, $66, $B4, $79, $00, $66, $B4
                DEFB  $3D, $B4, $00, $44, $00, $00, $4C, $00
                DEFB  $4C, $3D, $00, $44, $4C, $4C, $5B, $3D
                DEFB  $3D, $B4, $44, $3D, $4C, $44, $5B, $4C
                DEFB  $44, $5B, $4C, $00, $5B, $00, $00, $00
                DEFB  $66, $00, $5B, $66, $4C, $5B, $5B, $4C
                DEFB  $5B, $5B, $4C, $00, $5B, $00, $00, $00
                DEFB  $79, $00, $88, $79, $97, $88, $B4, $97
                DEFB  $88, $B4, $97, $00, $B4, $00, $00, $00
                DEFB  $2C, $88, $4C, $4C, $44, $4C, $44, $2C
                DEFB  $97, $00, $97, $97, $88, $97, $88, $88
                DEFB  $5B, $44, $2C, $5B, $5B, $5B, $5B, $5B
                DEFB  $B4, $88, $B4, $B4, $B4, $B4, $B4, $B4
                DEFB  $79, $5B, $88, $79, $97, $88, $B4, $97
                DEFB  $2C, $88, $4C, $72, $72, $4C, $4C, $72
                DEFB  $B4, $5B, $2D, $B4, $5B, $2D, $B4, $5B
                DEFB  $5B, $4C, $5B, $5B, $5B, $5B, $5B, $5B
                DEFB  $2D, $B4, $5B, $00, $5B, $00, $00, $00
                DEFB  $5B, $5B, $5B, $00, $5B, $00, $00, $00
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00

; ----------------------------
; SONG2 : LAURA
; ----------------------------
musicData2:
                DEFW  $1804               ; Initial tempo
                DEFW  md2 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $04
                DEFB  $05
                DEFB  $01
                DEFB  $06
                DEFB  $03
                DEFB  $07
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $05
                DEFB  $01
                DEFB  $06
                DEFB  $03
                DEFB  $07
                DEFB  $01
                DEFB  $02
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $01
                DEFB  $05
                DEFB  $01
                DEFB  $06
                DEFB  $03
                DEFB  $07
                DEFB  $01
                DEFB  $02
                DEFB  $04
                DEFB  $10
                DEFB  $01
                DEFB  $11
                DEFB  $0A
                DEFB  $12
                DEFB  $01
                DEFB  $11
                DEFB  $0A
                DEFB  $13
                DEFB  $01
                DEFB  $14
                DEFB  $0C
                DEFB  $15
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $10
                DEFB  $01
                DEFB  $11
                DEFB  $0A
                DEFB  $12
                DEFB  $01
                DEFB  $11
                DEFB  $0A
                DEFB  $13
                DEFB  $01
                DEFB  $14
                DEFB  $19
                DEFB  $1A
                DEFB  $01
                DEFB  $1B
                DEFB  $1C
                DEFB  $02
                DEFB  $00                 ; End of song

md2:
                DEFB  $17, $17, $13, $2C, $0F, $17, $13, $2C
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $1C, $1C, $17, $2C, $18, $18, $0F, $2C
                DEFB  $1C, $1C, $17, $2C, $18, $18, $0F, $14
                DEFB  $00, $00, $00, $00, $00, $2D, $26, $2D
                DEFB  $1E, $2D, $00, $26, $00, $2D, $2D, $2D
                DEFB  $39, $39, $2D, $22, $28, $26, $28, $2D
                DEFB  $1C, $1C, $17, $2C, $18, $2C, $0F, $14
                DEFB  $00, $00, $00, $00, $00, $00, $00, $2D
                DEFB  $17, $17, $11, $2C, $0E, $17, $11, $2C
                DEFB  $22, $00, $22, $22, $00, $22, $00, $22
                DEFB  $19, $19, $14, $2C, $11, $19, $14, $2C
                DEFB  $28, $00, $00, $28, $00, $2D, $28, $00
                DEFB  $13, $13, $0F, $2C, $0C, $13, $0F, $2C
                DEFB  $26, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $00, $00, $00, $00, $2D, $2D, $28
                DEFB  $26, $26, $26, $26, $26, $26, $00, $26
                DEFB  $00, $22, $00, $22, $00, $2D, $2D, $28
                DEFB  $00, $22, $00, $22, $00, $00, $2D, $28
                DEFB  $26, $00, $26, $00, $26, $26, $00, $28
                DEFB  $00, $28, $00, $26, $00, $28, $2D, $00
                DEFB  $18, $18, $14, $2C, $0F, $18, $14, $2C
                DEFB  $1E, $00, $00, $00, $00, $00, $00, $00
                DEFB  $18, $18, $11, $2C, $0F, $18, $11, $18
                DEFB  $18, $18, $14, $2C, $0F, $18, $11, $2C
                DEFB  $00, $28, $00, $26, $00, $28, $26, $00
                DEFB  $2D, $00, $00, $00, $00, $00, $00, $00
                DEFB  $17, $17, $11, $2C, $0F, $18, $14, $18


;---------------------
; SONG 3 : lautre-valse  
;---------------------
musicData3: 	     
                DEFW  $026E               ; Initial tempo
                DEFW  md3 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04, $03,  $05, $01, $06, $03,  $06, $03
                DEFB  $06 ,$01,  $02, $03, $04, $03,  $05, $01
                DEFB  $06, $03,  $07, $03, $08, $09,  $0A, $0B
                DEFB  $0A
                DEFB  $0B
                DEFB  $0A
                DEFB  $09
                DEFB  $0C
                DEFB  $0B
                DEFB  $0C
                DEFB  $0B
                DEFB  $0C
                DEFB  $09
                DEFB  $0D
                DEFB  $0B
                DEFB  $0D
                DEFB  $0B
                DEFB  $0D
                DEFB  $09
                DEFB  $0C
                DEFB  $0B
                DEFB  $0C
                DEFB  $0B
                DEFB  $0C
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $03
                DEFB  $05
                DEFB  $01
                DEFB  $06
                DEFB  $03
                DEFB  $06
                DEFB  $03
                DEFB  $06
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $03
                DEFB  $05
                DEFB  $01
                DEFB  $06
                DEFB  $03
                DEFB  $07
                DEFB  $03
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0A
                DEFB  $0B
                DEFB  $0A
                DEFB  $09
                DEFB  $0C
                DEFB  $0B
                DEFB  $0C
                DEFB  $0B
                DEFB  $0C
                DEFB  $09
                DEFB  $0D
                DEFB  $0B
                DEFB  $0D
                DEFB  $0B
                DEFB  $0D
                DEFB  $09
                DEFB  $0C
                DEFB  $0B
                DEFB  $0C
                DEFB  $0B
                DEFB  $0C
                DEFB  $01
                DEFB  $0E
                DEFB  $03
                DEFB  $0E
                DEFB  $03
                DEFB  $0E
                DEFB  $01
                DEFB  $0F
                DEFB  $03
                DEFB  $0F
                DEFB  $03
                DEFB  $0F
                DEFB  $01
                DEFB  $10
                DEFB  $03
                DEFB  $10
                DEFB  $03
                DEFB  $10
                DEFB  $01
                DEFB  $11
                DEFB  $03
                DEFB  $11
                DEFB  $03
                DEFB  $11
                DEFB  $09
                DEFB  $12
                DEFB  $0B
                DEFB  $12
                DEFB  $0B
                DEFB  $12
                DEFB  $09
                DEFB  $13
                DEFB  $0B
                DEFB  $13
                DEFB  $0B
                DEFB  $13
                DEFB  $09
                DEFB  $14
                DEFB  $0B
                DEFB  $14
                DEFB  $0B
                DEFB  $14
                DEFB  $09
                DEFB  $0F
                DEFB  $0B
                DEFB  $0F
                DEFB  $0B
                DEFB  $15
                DEFB  $01
                DEFB  $0E
                DEFB  $03
                DEFB  $0E
                DEFB  $03
                DEFB  $16
                DEFB  $01
                DEFB  $0F
                DEFB  $03
                DEFB  $0F
                DEFB  $03
                DEFB  $17
                DEFB  $01
                DEFB  $10
                DEFB  $03
                DEFB  $10
                DEFB  $03
                DEFB  $18
                DEFB  $01
                DEFB  $11
                DEFB  $03
                DEFB  $11
                DEFB  $03
                DEFB  $11
                DEFB  $09
                DEFB  $12
                DEFB  $0B
                DEFB  $12
                DEFB  $0B
                DEFB  $19
                DEFB  $09
                DEFB  $13
                DEFB  $0B
                DEFB  $13
                DEFB  $0B
                DEFB  $1A
                DEFB  $09
                DEFB  $14
                DEFB  $0B
                DEFB  $14
                DEFB  $0B
                DEFB  $1B
                DEFB  $09
                DEFB  $0F
                DEFB  $0B
                DEFB  $0F
                DEFB  $0B
                DEFB  $0F
                DEFB  $01
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1D
                DEFB  $1E
                DEFB  $01
                DEFB  $1F
                DEFB  $1D
                DEFB  $20
                DEFB  $1D
                DEFB  $20
                DEFB  $01
                DEFB  $21
                DEFB  $1D
                DEFB  $22
                DEFB  $1D
                DEFB  $22
                DEFB  $01
                DEFB  $23
                DEFB  $1D
                DEFB  $24
                DEFB  $1D
                DEFB  $25
                DEFB  $09
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $27
                DEFB  $28
                DEFB  $09
                DEFB  $29
                DEFB  $27
                DEFB  $2A
                DEFB  $27
                DEFB  $2A
                DEFB  $09
                DEFB  $21
                DEFB  $27
                DEFB  $22
                DEFB  $27
                DEFB  $22
                DEFB  $09
                DEFB  $2B
                DEFB  $27
                DEFB  $2C
                DEFB  $27
                DEFB  $2D
                DEFB  $01
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1D
                DEFB  $1E
                DEFB  $01
                DEFB  $1F
                DEFB  $1D
                DEFB  $20
                DEFB  $1D
                DEFB  $20
                DEFB  $01
                DEFB  $21
                DEFB  $1D
                DEFB  $22
                DEFB  $1D
                DEFB  $22
                DEFB  $01
                DEFB  $23
                DEFB  $1D
                DEFB  $24
                DEFB  $1D
                DEFB  $25
                DEFB  $09
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $27
                DEFB  $28
                DEFB  $09
                DEFB  $29
                DEFB  $27
                DEFB  $2A
                DEFB  $27
                DEFB  $2A
                DEFB  $09
                DEFB  $21
                DEFB  $27
                DEFB  $22
                DEFB  $27
                DEFB  $22
                DEFB  $09
                DEFB  $2B
                DEFB  $27
                DEFB  $2C
                DEFB  $27
                DEFB  $2D
                DEFB  $00                 ; End of song

md3:
                DEFB  $72, $72, $72, $72, $72, $72, $72, $00
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2D, $26, $2D, $26, $00, $00, $00, $00
                DEFB  $1E, $1E, $1E, $1E, $1C, $1C, $1C, $1C
                DEFB  $19, $19, $19, $19, $17, $17, $17, $17
                DEFB  $19, $19, $19, $19, $19, $19, $19, $19
                DEFB  $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C
                DEFB  $1C, $1C, $1C, $1C, $1E, $1E, $1E, $1E
                DEFB  $90, $90, $90, $90, $90, $90, $90, $00
                DEFB  $20, $20, $20, $20, $20, $20, $20, $20
                DEFB  $39, $30, $39, $30, $00, $00, $00, $00
                DEFB  $24, $24, $24, $24, $24, $24, $24, $24
                DEFB  $26, $26, $26, $26, $26, $26, $26, $26
                DEFB  $1E, $0F, $1E, $0F, $1E, $0F, $1E, $0F
                DEFB  $1C, $0E, $1C, $0E, $1C, $0E, $1C, $0E
                DEFB  $19, $0C, $19, $0C, $19, $0C, $19, $0C
                DEFB  $17, $00, $17, $00, $17, $00, $17, $00
                DEFB  $26, $13, $26, $13, $26, $13, $26, $13
                DEFB  $24, $12, $24, $12, $24, $12, $24, $12
                DEFB  $20, $10, $20, $10, $20, $10, $20, $10
                DEFB  $1C, $0E, $1C, $0E, $1C, $0E, $1C, $0F
                DEFB  $1E, $0F, $1E, $0F, $1E, $0F, $1E, $0E
                DEFB  $1C, $0E, $1C, $0E, $1C, $0E, $1C, $0C
                DEFB  $19, $0C, $19, $0C, $19, $0C, $19, $00
                DEFB  $26, $13, $26, $13, $26, $13, $26, $12
                DEFB  $24, $12, $24, $12, $24, $12, $24, $10
                DEFB  $20, $10, $20, $10, $20, $10, $20, $0E
                DEFB  $0F, $0F, $0F, $00, $0E, $00, $0E, $00
                DEFB  $5B, $4C, $5B, $4C, $00, $00, $00, $00
                DEFB  $0F, $00, $0F, $00, $0E, $00, $0E, $00
                DEFB  $11, $11, $11, $00, $0E, $00, $0E, $00
                DEFB  $11, $00, $11, $00, $0E, $00, $0E, $00
                DEFB  $13, $13, $13, $00, $0E, $00, $0E, $00
                DEFB  $13, $00, $13, $00, $0E, $00, $0E, $00
                DEFB  $15, $15, $15, $00, $0E, $00, $0E, $00
                DEFB  $15, $00, $15, $00, $0E, $00, $0E, $00
                DEFB  $17, $00, $17, $00, $0E, $00, $0E, $00
                DEFB  $10, $10, $10, $00, $0E, $00, $0E, $00
                DEFB  $72, $60, $72, $60, $00, $00, $00, $00
                DEFB  $10, $00, $10, $00, $0E, $00, $0E, $00
                DEFB  $12, $12, $12, $00, $0E, $00, $0E, $00
                DEFB  $12, $00, $12, $00, $0E, $00, $0E, $00
                DEFB  $12, $12, $12, $00, $18, $00, $18, $00
                DEFB  $14, $00, $14, $00, $13, $00, $13, $00
                DEFB  $12, $00, $12, $00, $10, $00, $10, $00

;---------------------
; SONG 4 : MONTY ON THE RUN
;---------------------

musicData4: 	DEFW  $04D4               ; Initial tempo
                DEFW  md4 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $01
                DEFB  $12
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $13
                DEFB  $05
                DEFB  $13
                DEFB  $06
                DEFB  $14
                DEFB  $03
                DEFB  $15
                DEFB  $04
                DEFB  $14
                DEFB  $05
                DEFB  $12
                DEFB  $07
                DEFB  $14
                DEFB  $08
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $16
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $02
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $13
                DEFB  $09
                DEFB  $13
                DEFB  $0A
                DEFB  $14
                DEFB  $08
                DEFB  $15
                DEFB  $04
                DEFB  $14
                DEFB  $09
                DEFB  $12
                DEFB  $0B
                DEFB  $14
                DEFB  $0C
                DEFB  $12
                DEFB  $04
                DEFB  $17
                DEFB  $03
                DEFB  $16
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $18
                DEFB  $03
                DEFB  $14
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $12
                DEFB  $03
                DEFB  $02
                DEFB  $0E
                DEFB  $12
                DEFB  $0F
                DEFB  $17
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $17
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $01
                DEFB  $19
                DEFB  $03
                DEFB  $19
                DEFB  $04
                DEFB  $19
                DEFB  $05
                DEFB  $19
                DEFB  $06
                DEFB  $19
                DEFB  $03
                DEFB  $19
                DEFB  $04
                DEFB  $19
                DEFB  $05
                DEFB  $19
                DEFB  $01
                DEFB  $19
                DEFB  $03
                DEFB  $19
                DEFB  $04
                DEFB  $1A
                DEFB  $05
                DEFB  $1A
                DEFB  $06
                DEFB  $1B
                DEFB  $03
                DEFB  $1C
                DEFB  $04
                DEFB  $1B
                DEFB  $05
                DEFB  $19
                DEFB  $07
                DEFB  $1B
                DEFB  $08
                DEFB  $19
                DEFB  $04
                DEFB  $19
                DEFB  $09
                DEFB  $1D
                DEFB  $0A
                DEFB  $1D
                DEFB  $08
                DEFB  $1D
                DEFB  $04
                DEFB  $1D
                DEFB  $09
                DEFB  $1D
                DEFB  $07
                DEFB  $1D
                DEFB  $08
                DEFB  $1D
                DEFB  $04
                DEFB  $1A
                DEFB  $09
                DEFB  $1A
                DEFB  $0A
                DEFB  $1B
                DEFB  $08
                DEFB  $1C
                DEFB  $04
                DEFB  $1B
                DEFB  $09
                DEFB  $19
                DEFB  $0B
                DEFB  $1B
                DEFB  $0C
                DEFB  $19
                DEFB  $04
                DEFB  $1E
                DEFB  $03
                DEFB  $1D
                DEFB  $0D
                DEFB  $1D
                DEFB  $0C
                DEFB  $1D
                DEFB  $04
                DEFB  $1D
                DEFB  $03
                DEFB  $1D
                DEFB  $0B
                DEFB  $1D
                DEFB  $0C
                DEFB  $1D
                DEFB  $04
                DEFB  $1F
                DEFB  $03
                DEFB  $1B
                DEFB  $0D
                DEFB  $1B
                DEFB  $0C
                DEFB  $1B
                DEFB  $04
                DEFB  $19
                DEFB  $03
                DEFB  $19
                DEFB  $0E
                DEFB  $19
                DEFB  $0F
                DEFB  $1E
                DEFB  $04
                DEFB  $20
                DEFB  $10
                DEFB  $1E
                DEFB  $11
                DEFB  $1E
                DEFB  $0F
                DEFB  $1E
                DEFB  $04
                DEFB  $1E
                DEFB  $10
                DEFB  $1E
                DEFB  $0E
                DEFB  $1E
                DEFB  $0F
                DEFB  $1E
                DEFB  $04
                DEFB  $1E
                DEFB  $10
                DEFB  $1E
                DEFB  $11
                DEFB  $1E
                DEFB  $0F
                DEFB  $1E
                DEFB  $04
                DEFB  $1E
                DEFB  $10
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $15
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $05
                DEFB  $12
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $05
                DEFB  $12
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $13
                DEFB  $04
                DEFB  $17
                DEFB  $05
                DEFB  $16
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $15
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $09
                DEFB  $12
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $09
                DEFB  $12
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $13
                DEFB  $04
                DEFB  $17
                DEFB  $09
                DEFB  $16
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $15
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $03
                DEFB  $12
                DEFB  $0B
                DEFB  $02
                DEFB  $0C
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $03
                DEFB  $12
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $13
                DEFB  $04
                DEFB  $17
                DEFB  $03
                DEFB  $16
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $15
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $10
                DEFB  $12
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $12
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $12
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $13
                DEFB  $04
                DEFB  $17
                DEFB  $10
                DEFB  $16
                DEFB  $01
                DEFB  $21
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $05
                DEFB  $02
                DEFB  $01
                DEFB  $21
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $05
                DEFB  $02
                DEFB  $07
                DEFB  $21
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $09
                DEFB  $02
                DEFB  $07
                DEFB  $21
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $02
                DEFB  $08
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $09
                DEFB  $02
                DEFB  $0B
                DEFB  $21
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $03
                DEFB  $02
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $03
                DEFB  $02
                DEFB  $0B
                DEFB  $21
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $21
                DEFB  $03
                DEFB  $02
                DEFB  $0D
                DEFB  $02
                DEFB  $0C
                DEFB  $02
                DEFB  $04
                DEFB  $15
                DEFB  $03
                DEFB  $02
                DEFB  $0E
                DEFB  $15
                DEFB  $0F
                DEFB  $22
                DEFB  $04
                DEFB  $15
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $14
                DEFB  $10
                DEFB  $02
                DEFB  $0E
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $02
                DEFB  $0F
                DEFB  $02
                DEFB  $04
                DEFB  $02
                DEFB  $10
                DEFB  $02
                DEFB  $00                 ; End of song

md4:
                DEFB  $2C, $66, $11, $66, $22, $66, $11, $00
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $66, $0C, $66, $19, $66, $0C, $00
                DEFB  $17, $00, $00, $00, $17, $00, $00, $00
                DEFB  $2C, $44, $0C, $44, $19, $44, $0C, $00
                DEFB  $2C, $66, $00, $66, $11, $66, $00, $00
                DEFB  $2C, $79, $11, $79, $22, $79, $11, $00
                DEFB  $2C, $79, $0C, $79, $19, $79, $0C, $00
                DEFB  $2C, $51, $0C, $51, $19, $51, $0C, $00
                DEFB  $2C, $79, $00, $79, $11, $79, $00, $00
                DEFB  $2C, $97, $11, $97, $22, $97, $11, $00
                DEFB  $2C, $97, $0C, $97, $19, $97, $0C, $00
                DEFB  $2C, $97, $00, $97, $11, $97, $00, $00
                DEFB  $2C, $88, $11, $88, $22, $88, $11, $00
                DEFB  $2C, $88, $0C, $88, $19, $88, $0C, $00
                DEFB  $2C, $5B, $0C, $5B, $19, $5B, $0C, $00
                DEFB  $2C, $88, $00, $88, $11, $88, $00, $00
                DEFB  $14, $00, $00, $00, $00, $00, $00, $00
                DEFB  $13, $00, $00, $00, $14, $00, $00, $00
                DEFB  $13, $00, $00, $00, $00, $00, $00, $00
                DEFB  $11, $00, $00, $00, $00, $00, $00, $00
                DEFB  $19, $00, $00, $00, $00, $00, $00, $00
                DEFB  $17, $00, $00, $00, $00, $00, $00, $00
                DEFB  $1E, $00, $00, $00, $00, $00, $00, $00
                DEFB  $19, $14, $19, $14, $19, $14, $19, $14
                DEFB  $17, $13, $17, $13, $19, $14, $19, $14
                DEFB  $17, $13, $17, $13, $17, $13, $17, $13
                DEFB  $14, $11, $14, $11, $14, $11, $14, $11
                DEFB  $1E, $19, $1E, $19, $1E, $19, $1E, $19
                DEFB  $1B, $17, $1B, $17, $1B, $17, $1B, $17
                DEFB  $26, $1E, $26, $1E, $26, $1E, $26, $1E
                DEFB  $1B, $17, $1B, $17, $00, $00, $00, $00
                DEFB  $0C, $00, $00, $00, $00, $00, $00, $00
                DEFB  $0F, $00, $00, $00, $00, $00, $00, $00

;---------------------
; SONG 5 : PHAZER
;---------------------
musicData5: 	     
                DEFW  $0E6C               ; Initial tempo
                DEFW  md5 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $04
                DEFB  $12
                DEFB  $06
                DEFB  $13
                DEFB  $08
                DEFB  $14
                DEFB  $0A
                DEFB  $15
                DEFB  $0C
                DEFB  $16
                DEFB  $0D
                DEFB  $17
                DEFB  $0F
                DEFB  $10
                DEFB  $18
                DEFB  $11
                DEFB  $19
                DEFB  $12
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $14
                DEFB  $1D
                DEFB  $15
                DEFB  $1E
                DEFB  $16
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $10
                DEFB  $22
                DEFB  $11
                DEFB  $23
                DEFB  $12
                DEFB  $24
                DEFB  $1B
                DEFB  $25
                DEFB  $14
                DEFB  $26
                DEFB  $15
                DEFB  $27
                DEFB  $16
                DEFB  $28
                DEFB  $0F
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $2A
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3A
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $3F
                DEFB  $39
                DEFB  $3A
                DEFB  $40
                DEFB  $41
                DEFB  $35
                DEFB  $42
                DEFB  $43
                DEFB  $44
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $02
                DEFB  $11
                DEFB  $04
                DEFB  $12
                DEFB  $06
                DEFB  $13
                DEFB  $08
                DEFB  $14
                DEFB  $0A
                DEFB  $15
                DEFB  $0C
                DEFB  $16
                DEFB  $0D
                DEFB  $17
                DEFB  $0F
                DEFB  $10
                DEFB  $18
                DEFB  $11
                DEFB  $19
                DEFB  $12
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $14
                DEFB  $1D
                DEFB  $15
                DEFB  $1E
                DEFB  $16
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $10
                DEFB  $22
                DEFB  $11
                DEFB  $23
                DEFB  $12
                DEFB  $24
                DEFB  $1B
                DEFB  $25
                DEFB  $14
                DEFB  $26
                DEFB  $15
                DEFB  $27
                DEFB  $16
                DEFB  $28
                DEFB  $0F
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $2A
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3A
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $3F
                DEFB  $39
                DEFB  $3A
                DEFB  $40
                DEFB  $41
                DEFB  $35
                DEFB  $42
                DEFB  $43
                DEFB  $44
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $FF                 ; Tempo change
                DEFW  $10D2               ; New tempo value
                DEFB  $0D
                DEFB  $0D
                DEFB  $45
                DEFB  $45
                DEFB  $FF                 ; Tempo change
                DEFW  $0C06               ; New tempo value
                DEFB  $46
                DEFB  $47
                DEFB  $1C
                DEFB  $47
                DEFB  $1C
                DEFB  $47
                DEFB  $1C
                DEFB  $47
                DEFB  $1C
                DEFB  $48
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $FF                 ; Tempo change
                DEFW  $0E6C               ; New tempo value
                DEFB  $49
                DEFB  $1C
                DEFB  $1C
                DEFB  $1C
                DEFB  $00                 ; End of song

md5:
                DEFB  $2C, $79, $79, $79, $3D, $33, $79, $79
                DEFB  $F0, $F0, $F0, $F0, $79, $66, $F0, $F0
                DEFB  $79, $79, $3D, $33, $79, $79, $3D, $33
                DEFB  $F0, $F0, $79, $66, $F0, $F0, $79, $66
                DEFB  $88, $88, $88, $88, $44, $36, $88, $88
                DEFB  $00, $00, $00, $00, $88, $6C, $00, $00
                DEFB  $88, $88, $44, $36, $88, $88, $44, $36
                DEFB  $00, $00, $88, $6C, $00, $00, $88, $6C
                DEFB  $97, $97, $97, $97, $4C, $3D, $97, $97
                DEFB  $97, $97, $97, $97, $97, $79, $97, $97
                DEFB  $97, $97, $4C, $3D, $97, $97, $4C, $3D
                DEFB  $97, $97, $97, $79, $97, $97, $97, $79
                DEFB  $CB, $CB, $CB, $CB, $51, $44, $D7, $D7
                DEFB  $D7, $D7, $2C, $2C, $D7, $D7, $5B, $44
                DEFB  $D7, $D7, $5B, $44, $D7, $D7, $5B, $44
                DEFB  $2C, $79, $79, $79, $3D, $33, $2C, $79
                DEFB  $79, $79, $2C, $33, $79, $79, $3D, $33
                DEFB  $2C, $88, $88, $88, $44, $36, $2C, $88
                DEFB  $88, $88, $2C, $36, $88, $88, $44, $36
                DEFB  $2C, $97, $97, $97, $4C, $3D, $2C, $97
                DEFB  $97, $97, $2C, $3D, $97, $97, $4C, $3D
                DEFB  $2C, $CB, $CB, $CB, $2C, $44, $D7, $D7
                DEFB  $D7, $D7, $5B, $2C, $D7, $D7, $5B, $44
                DEFB  $1E, $1E, $00, $00, $00, $00, $28, $28
                DEFB  $1E, $1E, $1B, $1B, $19, $19, $14, $14
                DEFB  $00, $00, $1B, $1B, $1B, $00, $00, $00
                DEFB  $88, $88, $2C, $2C, $88, $88, $2C, $36
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $26, $26, $33, $33, $26, $26, $22, $22
                DEFB  $1E, $1E, $22, $22, $26, $26, $00, $00
                DEFB  $28, $28, $26, $26, $22, $22, $2D, $2D
                DEFB  $2C, $2C, $2C, $44, $2C, $D7, $2C, $2C
                DEFB  $00, $00, $17, $19, $1B, $22, $2D, $44
                DEFB  $3D, $36, $33, $2D, $36, $33, $2D, $28
                DEFB  $33, $2D, $28, $26, $2D, $28, $26, $22
                DEFB  $19, $1B, $22, $1B, $22, $2D, $22, $2D
                DEFB  $33, $2D, $33, $36, $33, $36, $44, $22
                DEFB  $13, $14, $17, $19, $14, $17, $19, $1B
                DEFB  $17, $19, $1B, $1E, $19, $1B, $1E, $22
                DEFB  $28, $22, $19, $22, $28, $22, $19, $22
                DEFB  $2D, $22, $1B, $22, $1B, $19, $17, $11
                DEFB  $2C, $4C, $3D, $4C, $2C, $4C, $33, $4C
                DEFB  $0F, $0F, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $4C, $33, $4C, $2C, $4C, $3D, $2C
                DEFB  $0F, $0F, $0D, $0D, $0C, $0C, $00, $00
                DEFB  $2C, $79, $3D, $79, $2C, $79, $33, $79
                DEFB  $00, $00, $0C, $0C, $14, $14, $00, $00
                DEFB  $2C, $88, $44, $88, $2C, $33, $36, $44
                DEFB  $00, $00, $0D, $0D, $11, $0F, $0D, $00
                DEFB  $0C, $0C, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $4C, $33, $4C, $2C, $2C, $2C, $2C
                DEFB  $0F, $0F, $13, $13, $19, $19, $0F, $0F
                DEFB  $2C, $51, $26, $51, $2C, $51, $2D, $51
                DEFB  $10, $10, $14, $14, $17, $17, $1B, $1B
                DEFB  $28, $2D, $33, $36, $3D, $40, $4C, $51
                DEFB  $14, $17, $19, $1B, $1E, $20, $26, $28
                DEFB  $2C, $4C, $3D, $4C, $36, $4C, $2C, $4C
                DEFB  $33, $26, $33, $3D, $33, $26, $33, $3D
                DEFB  $2D, $4C, $2C, $4C, $36, $4C, $3D, $4C
                DEFB  $2C, $79, $3D, $79, $36, $79, $2C, $79
                DEFB  $33, $28, $33, $3D, $33, $28, $33, $3D
                DEFB  $36, $88, $2C, $2C, $2D, $33, $2C, $44
                DEFB  $36, $2D, $36, $44, $5B, $44, $36, $2D
                DEFB  $26, $4C, $2C, $4C, $1E, $4C, $26, $4C
                DEFB  $33, $26, $33, $3D, $26, $1E, $26, $33
                DEFB  $36, $28, $36, $40, $36, $28, $36, $40
                DEFB  $2C, $2C, $2C, $36, $2C, $40, $2C, $2C
                DEFB  $51, $5B, $66, $6C, $79, $80, $97, $A1
                DEFB  $D7, $D7, $5B, $44, $5B, $44, $36, $2D
                DEFB  $F0, $00, $00, $00, $00, $00, $00, $00
                DEFB  $3D, $36, $33, $28, $1E, $28, $33, $36
                DEFB  $3D, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $00, $2C, $00, $00, $00, $00, $00




end
