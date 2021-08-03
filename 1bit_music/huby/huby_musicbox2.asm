; HUBY-M  ---    HUBY MUSIC BOX #2
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
; 1. Theme from 1943.
; 2. Beeper Dance. Beepola.
; 3. Cant slow down. Beepola.
; 4. Caldron. Beepola
; 5. Cars
; 6. Hangover
; 7. classical gas
; 8. dweller on the threshold
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
	cp	54		; "6 - "
	jr	z, m6
	cp	55		; "7 - "
	jr	z, m7
	cp	56		; "8 - "
	jr	z, m8

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
m6: 	ld 	hl, D6
	ld 	de,musicData6
	jp 	continue
m7: 	ld 	hl, D7
	ld 	de,musicData7
	jp 	continue
m8: 	ld 	hl, D8
	ld 	de,musicData8
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


MSG1 	db	"HUBY MUSICBOX #2.      BUSHY'19", $0d
	db 	$0d,$0d, "PLEASE SELECT:  ", $0d
	db 	"1 1943", $0d
	db 	"2 BEEPER DANCE", $0d
	db 	"3 SLOW DOWN", $0d
	db 	"4 CALDRON", $0d
	db 	"5 CARS", $0d
	db 	"6 HANGOVER", $0d,00
MSG2	db 	"7 CLASSICAL GAS", $0d
	db 	"8 DWELLER ON THE THRESHOLD", $0d
	db 	$0d, ">",00

MSGQUIT db	$08, $08, "QUIT...",$0d,00
PLAYING db	08,08,08,"NOW PLAYING:",0

POSCURSOR db	09,00
D1 	db	"1943 ",0,0		
D2 	db	"BEEPER DANCE",0,0			
D3 	db	"SLOW DOWN ",0,0			
D4 	db	"CALDRON",0,0
D5 	db	"CARS",0,0
D6 	db	"HANGOVER",0,0
D7 	db	"CLASSICAL GAS",0,0
D8 	db	"DWELLER ON THE THRESHOLD",0,0


;---------------------------------
; SONG 1 : 
;---------------------------------
;------------------------------
; Theme from 1943
; -----------------------------
musicData1:
		DEFW  $09A0		  ; Initial tempo
		DEFW  PATTDATA1 - 8	   ; Ptr to start of pattern data - 8
		DEFB  $01
		DEFB  $02
		DEFB  $01
		DEFB  $03
		DEFB  $01
		DEFB  $04
		DEFB  $01
		DEFB  $05
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $09
		DEFB  $0A
		DEFB  $01
		DEFB  $0B
		DEFB  $01
		DEFB  $0C
		DEFB  $0D
		DEFB  $0E
		DEFB  $0F
		DEFB  $10
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $09
		DEFB  $0A
		DEFB  $01
		DEFB  $0B
		DEFB  $01
		DEFB  $0C
		DEFB  $0D
		DEFB  $0E
		DEFB  $0F
		DEFB  $10
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $06
		DEFB  $14
		DEFB  $15
		DEFB  $01
		DEFB  $06
		DEFB  $01
		DEFB  $15
		DEFB  $01
		DEFB  $16
		DEFB  $17
		DEFB  $16
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $19
		DEFB  $01
		DEFB  $1B
		DEFB  $1C
		DEFB  $1B
		DEFB  $1D
		DEFB  $16
		DEFB  $14
		DEFB  $16
		DEFB  $01
		DEFB  $1E
		DEFB  $1F
		DEFB  $1E
		DEFB  $20
		DEFB  $19
		DEFB  $1F
		DEFB  $19
		DEFB  $01
		DEFB  $21
		DEFB  $22
		DEFB  $21
		DEFB  $23
		DEFB  $24
		DEFB  $25
		DEFB  $26
		DEFB  $01
		DEFB  $16
		DEFB  $17
		DEFB  $16
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $19
		DEFB  $01
		DEFB  $1B
		DEFB  $1C
		DEFB  $1B
		DEFB  $1D
		DEFB  $16
		DEFB  $14
		DEFB  $16
		DEFB  $01
		DEFB  $1E
		DEFB  $1F
		DEFB  $1E
		DEFB  $20
		DEFB  $19
		DEFB  $1F
		DEFB  $19
		DEFB  $01
		DEFB  $21
		DEFB  $22
		DEFB  $21
		DEFB  $27
		DEFB  $16
		DEFB  $25
		DEFB  $28
		DEFB  $01
		DEFB  $29
		DEFB  $01
		DEFB  $06
		DEFB  $01
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $09
		DEFB  $0A
		DEFB  $01
		DEFB  $0B
		DEFB  $01
		DEFB  $0C
		DEFB  $0D
		DEFB  $0E
		DEFB  $0F
		DEFB  $10
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $2A
		DEFB  $0A
		DEFB  $01
		DEFB  $0B
		DEFB  $01
		DEFB  $0C
		DEFB  $07
		DEFB  $0C
		DEFB  $2B
		DEFB  $10
		DEFB  $2C
		DEFB  $2D
		DEFB  $2E
		DEFB  $06
		DEFB  $14
		DEFB  $15
		DEFB  $01
		DEFB  $06
		DEFB  $01
		DEFB  $15
		DEFB  $01
		DEFB  $16
		DEFB  $17
		DEFB  $16
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $19
		DEFB  $01
		DEFB  $1B
		DEFB  $1C
		DEFB  $1B
		DEFB  $1D
		DEFB  $16
		DEFB  $14
		DEFB  $16
		DEFB  $01
		DEFB  $1E
		DEFB  $1F
		DEFB  $1E
		DEFB  $20
		DEFB  $19
		DEFB  $1F
		DEFB  $19
		DEFB  $01
		DEFB  $21
		DEFB  $22
		DEFB  $21
		DEFB  $23
		DEFB  $24
		DEFB  $25
		DEFB  $26
		DEFB  $01
		DEFB  $16
		DEFB  $17
		DEFB  $16
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $19
		DEFB  $01
		DEFB  $1B
		DEFB  $1C
		DEFB  $1B
		DEFB  $1D
		DEFB  $16
		DEFB  $14
		DEFB  $16
		DEFB  $01
		DEFB  $1E
		DEFB  $1F
		DEFB  $1E
		DEFB  $20
		DEFB  $19
		DEFB  $1F
		DEFB  $19
		DEFB  $01
		DEFB  $21
		DEFB  $22
		DEFB  $21
		DEFB  $27
		DEFB  $16
		DEFB  $25
		DEFB  $28
		DEFB  $01
		DEFB  $29
		DEFB  $01
		DEFB  $06
		DEFB  $01
		DEFB  $00		  ; End of song

PATTDATA1:
		DEFB  $00, $00, $00, $00, $00, $00, $00, $00
		DEFB  $66, $00, $00, $00, $60, $00, $00, $00
		DEFB  $5B, $00, $00, $00, $56, $00, $00, $00
		DEFB  $51, $00, $00, $00, $4C, $00, $00, $00
		DEFB  $48, $00, $00, $00, $44, $00, $00, $00
		DEFB  $80, $00, $80, $00, $80, $00, $80, $00
		DEFB  $20, $00, $00, $00, $20, $00, $00, $00
		DEFB  $2C, $00, $80, $00, $2C, $00, $80, $00
		DEFB  $00, $00, $24, $00, $20, $00, $24, $00
		DEFB  $90, $00, $90, $00, $90, $00, $90, $00
		DEFB  $2C, $00, $90, $00, $2C, $00, $90, $00
		DEFB  $A1, $00, $A1, $00, $A1, $00, $A1, $00
		DEFB  $28, $00, $00, $00, $28, $00, $00, $00
		DEFB  $2C, $00, $A1, $00, $2C, $00, $A1, $00
		DEFB  $00, $00, $28, $00, $30, $00, $36, $00
		DEFB  $97, $00, $97, $00, $97, $00, $97, $00
		DEFB  $39, $00, $00, $40, $00, $00, $39, $00
		DEFB  $2C, $00, $88, $00, $88, $00, $88, $00
		DEFB  $39, $00, $00, $44, $00, $00, $39, $00
		DEFB  $19, $00, $00, $00, $00, $00, $00, $00
		DEFB  $80, $00, $80, $00, $80, $00, $90, $88
		DEFB  $40, $00, $80, $00, $80, $00, $40, $80
		DEFB  $33, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $00, $00, $30, $00, $2D, $00
		DEFB  $44, $00, $88, $00, $88, $00, $44, $88
		DEFB  $2B, $00, $00, $00, $00, $00, $00, $00
		DEFB  $4C, $00, $97, $00, $97, $00, $4C, $97
		DEFB  $26, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $22, $00, $20, $00, $1C, $00
		DEFB  $39, $00, $72, $00, $72, $00, $39, $72
		DEFB  $18, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $13, $00, $00, $00, $15, $00
		DEFB  $56, $00, $AB, $00, $AB, $00, $56, $AB
		DEFB  $1C, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $18, $00, $00, $00, $19, $00
		DEFB  $80, $00, $80, $40, $88, $00, $80, $40
		DEFB  $20, $00, $00, $00, $00, $00, $00, $00
		DEFB  $97, $00, $80, $40, $AB, $00, $80, $40
		DEFB  $2B, $00, $00, $00, $1C, $00, $00, $00
		DEFB  $40, $00, $80, $00, $40, $00, $40, $80
		DEFB  $80, $FF, $80, $FF, $80, $FF, $80, $FF
		DEFB  $1B, $00, $1C, $00, $20, $00, $24, $00
		DEFB  $1B, $00, $1C, $00, $20, $00, $1B, $00
		DEFB  $18, $00, $00, $20, $00, $00, $18, $00
		DEFB  $88, $00, $88, $00, $88, $00, $88, $00
		DEFB  $15, $00, $00, $1C, $00, $00, $15, $00


;---------------------
; Beeperdance from Beepola Tracker.
;---------------------
musicData2: 	     
		DEFW  1F36		 ; Initial tempo
		DEFW  PATTDATA2 - 8	   ; Ptr to start of pattern data - 8
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $05
		DEFB  $06
		DEFB  $03
		DEFB  $07
		DEFB  $08
		DEFB  $09
		DEFB  $03
		DEFB  $0A
		DEFB  $01
		DEFB  $02
		DEFB  $0B
		DEFB  $06
		DEFB  $0C
		DEFB  $0D
		DEFB  $0C
		DEFB  $03
		DEFB  $0C
		DEFB  $0D
		DEFB  $0C
		DEFB  $03
		DEFB  $0C
		DEFB  $0E
		DEFB  $0C
		DEFB  $0F
		DEFB  $0C
		DEFB  $0D
		DEFB  $0C
		DEFB  $03
		DEFB  $0C
		DEFB  $10
		DEFB  $0C
		DEFB  $11
		DEFB  $0C
		DEFB  $0D
		DEFB  $0C
		DEFB  $03
		DEFB  $0C
		DEFB  $12
		DEFB  $0C
		DEFB  $13
		DEFB  $0C
		DEFB  $0D
		DEFB  $0C
		DEFB  $03
		DEFB  $0C
		DEFB  $0E
		DEFB  $0C
		DEFB  $0F
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $05
		DEFB  $06
		DEFB  $03
		DEFB  $07
		DEFB  $08
		DEFB  $09
		DEFB  $03
		DEFB  $0A
		DEFB  $01
		DEFB  $02
		DEFB  $0B
		DEFB  $06
		DEFB  $14
		DEFB  $02
		DEFB  $14
		DEFB  $04
		DEFB  $15
		DEFB  $06
		DEFB  $15
		DEFB  $07
		DEFB  $16
		DEFB  $09
		DEFB  $16
		DEFB  $0A
		DEFB  $14
		DEFB  $02
		DEFB  $17
		DEFB  $06
		DEFB  $18
		DEFB  $02
		DEFB  $18
		DEFB  $04
		DEFB  $19
		DEFB  $06
		DEFB  $19
		DEFB  $07
		DEFB  $1A
		DEFB  $09
		DEFB  $1A
		DEFB  $0A
		DEFB  $18
		DEFB  $02
		DEFB  $1B
		DEFB  $06
		DEFB  $0C
		DEFB  $0D
		DEFB  $0C
		DEFB  $03
		DEFB  $FF		  ; Tempo change
		DEFW  $10D2		  ; New tempo value
		DEFB  $1C
		DEFB  $0D
		DEFB  $03
		DEFB  $03
		DEFB  $03
		DEFB  $03
		DEFB  $03
		DEFB  $03
		DEFB  $00		  ; End of song

PATTDATA2:
		DEFB  $A1, $00, $00, $00, $00, $00, $00, $00
		DEFB  $36, $00, $00, $00, $22, $00, $00, $00
		DEFB  $00, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $22, $24, $22, $24, $28, $2D
		DEFB  $B4, $00, $00, $00, $00, $00, $00, $00
		DEFB  $3D, $00, $00, $00, $24, $00, $00, $00
		DEFB  $00, $00, $1B, $1E, $1B, $1E, $22, $24
		DEFB  $79, $00, $00, $00, $00, $00, $00, $00
		DEFB  $33, $00, $00, $00, $28, $00, $00, $00
		DEFB  $00, $00, $24, $28, $24, $22, $1E, $33
		DEFB  $6C, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $B4, $2C, $88, $2C, $B4, $2C, $88
		DEFB  $28, $00, $00, $00, $00, $00, $00, $00
		DEFB  $24, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $00, $00, $2D, $00, $00, $00
		DEFB  $1E, $00, $00, $00, $00, $00, $00, $00
		DEFB  $22, $00, $00, $2D, $00, $00, $00, $00
		DEFB  $1B, $00, $00, $00, $00, $1E, $00, $00
		DEFB  $17, $00, $00, $00, $11, $00, $00, $00
		DEFB  $2C, $A1, $2C, $A1, $2C, $51, $2C, $51
		DEFB  $2C, $B4, $2C, $B4, $2C, $5B, $2C, $5B
		DEFB  $2C, $79, $2C, $79, $2C, $3D, $2C, $3D
		DEFB  $2C, $6C, $2C, $6C, $2C, $36, $2C, $36
		DEFB  $2C, $A1, $51, $2C, $2C, $51, $A1, $51
		DEFB  $2C, $B4, $5B, $2C, $2C, $5B, $B4, $5B
		DEFB  $2C, $79, $3D, $2C, $2C, $3D, $79, $3D
		DEFB  $2C, $6C, $36, $2C, $2C, $2C, $6C, $36
		DEFB  $2C, $00, $00, $00, $00, $00, $00, $00

; --------------------------------------
; Cant slow down
;----------------------------------------

musicData3:
		DEFW  $0E6C		  ; Initial tempo
		DEFW  PATTDATA3 - 8	   ; Ptr to start of pattern data - 8
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $01
		DEFB  $05
		DEFB  $03
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $03
		DEFB  $08
		DEFB  $09
		DEFB  $0A
		DEFB  $0B
		DEFB  $0C
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $0D
		DEFB  $0E
		DEFB  $0F
		DEFB  $10
		DEFB  $07
		DEFB  $08
		DEFB  $03
		DEFB  $08
		DEFB  $09
		DEFB  $0A
		DEFB  $0B
		DEFB  $0C
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $18
		DEFB  $11
		DEFB  $19
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $1A
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $18
		DEFB  $11
		DEFB  $19
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $1A
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $18
		DEFB  $11
		DEFB  $19
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $1A
		DEFB  $11
		DEFB  $1B
		DEFB  $13
		DEFB  $1C
		DEFB  $15
		DEFB  $1D
		DEFB  $17
		DEFB  $1E
		DEFB  $11
		DEFB  $19
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $18
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $22
		DEFB  $23
		DEFB  $24
		DEFB  $21
		DEFB  $22
		DEFB  $25
		DEFB  $26
		DEFB  $27
		DEFB  $28
		DEFB  $29
		DEFB  $2A
		DEFB  $2B
		DEFB  $1C
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $22
		DEFB  $23
		DEFB  $24
		DEFB  $21
		DEFB  $22
		DEFB  $25
		DEFB  $26
		DEFB  $27
		DEFB  $28
		DEFB  $29
		DEFB  $2A
		DEFB  $2B
		DEFB  $1C
		DEFB  $FF		  ; Tempo change
		DEFW  $04D4		  ; New tempo value
		DEFB  $2C
		DEFB  $2D
		DEFB  $2E
		DEFB  $2F
		DEFB  $30
		DEFB  $31
		DEFB  $2C
		DEFB  $2D
		DEFB  $32
		DEFB  $2F
		DEFB  $33
		DEFB  $31
		DEFB  $2C
		DEFB  $2D
		DEFB  $2E
		DEFB  $34
		DEFB  $30
		DEFB  $31
		DEFB  $2C
		DEFB  $2D
		DEFB  $32
		DEFB  $2F
		DEFB  $35
		DEFB  $31
		DEFB  $2C
		DEFB  $36
		DEFB  $2E
		DEFB  $2F
		DEFB  $30
		DEFB  $37
		DEFB  $2C
		DEFB  $38
		DEFB  $32
		DEFB  $39
		DEFB  $33
		DEFB  $3A
		DEFB  $2C
		DEFB  $38
		DEFB  $3B
		DEFB  $3C
		DEFB  $35
		DEFB  $3D
		DEFB  $3E
		DEFB  $3F
		DEFB  $32
		DEFB  $40
		DEFB  $41
		DEFB  $42
		DEFB  $2C
		DEFB  $43
		DEFB  $2E
		DEFB  $44
		DEFB  $30
		DEFB  $45
		DEFB  $2C
		DEFB  $46
		DEFB  $32
		DEFB  $47
		DEFB  $33
		DEFB  $48
		DEFB  $2C
		DEFB  $49
		DEFB  $2E
		DEFB  $4A
		DEFB  $30
		DEFB  $4B
		DEFB  $2C
		DEFB  $49
		DEFB  $32
		DEFB  $4C
		DEFB  $35
		DEFB  $4D
		DEFB  $2C
		DEFB  $4E
		DEFB  $2E
		DEFB  $45
		DEFB  $30
		DEFB  $4F
		DEFB  $2C
		DEFB  $4C
		DEFB  $32
		DEFB  $50
		DEFB  $33
		DEFB  $48
		DEFB  $2C
		DEFB  $51
		DEFB  $3B
		DEFB  $52
		DEFB  $35
		DEFB  $53
		DEFB  $3E
		DEFB  $08
		DEFB  $32
		DEFB  $54
		DEFB  $41
		DEFB  $08
		DEFB  $FF		  ; Tempo change
		DEFW  $0E6C		  ; New tempo value
		DEFB  $55
		DEFB  $56
		DEFB  $57
		DEFB  $58
		DEFB  $55
		DEFB  $59
		DEFB  $5A
		DEFB  $5B
		DEFB  $FF		  ; Tempo change
		DEFW  $04D4		  ; New tempo value
		DEFB  $2C
		DEFB  $5C
		DEFB  $2E
		DEFB  $5D
		DEFB  $30
		DEFB  $5E
		DEFB  $2C
		DEFB  $5F
		DEFB  $32
		DEFB  $60
		DEFB  $33
		DEFB  $61
		DEFB  $FF		  ; Tempo change
		DEFW  $0E6C		  ; New tempo value
		DEFB  $62
		DEFB  $63
		DEFB  $64
		DEFB  $65
		DEFB  $FF		  ; Tempo change
		DEFW  $04D4		  ; New tempo value
		DEFB  $2C
		DEFB  $66
		DEFB  $2E
		DEFB  $67
		DEFB  $30
		DEFB  $68
		DEFB  $2C
		DEFB  $69
		DEFB  $32
		DEFB  $6A
		DEFB  $33
		DEFB  $6B
		DEFB  $2C
		DEFB  $6C
		DEFB  $2E
		DEFB  $6D
		DEFB  $30
		DEFB  $6E
		DEFB  $2C
		DEFB  $6F
		DEFB  $32
		DEFB  $70
		DEFB  $35
		DEFB  $71
		DEFB  $2C
		DEFB  $72
		DEFB  $2E
		DEFB  $73
		DEFB  $30
		DEFB  $74
		DEFB  $2C
		DEFB  $75
		DEFB  $32
		DEFB  $76
		DEFB  $33
		DEFB  $77
		DEFB  $2C
		DEFB  $78
		DEFB  $2E
		DEFB  $79
		DEFB  $30
		DEFB  $08
		DEFB  $7A
		DEFB  $7B
		DEFB  $32
		DEFB  $08
		DEFB  $08
		DEFB  $7C
		DEFB  $FF		  ; Tempo change
		DEFW  $0E6C		  ; New tempo value
		DEFB  $7D
		DEFB  $7E
		DEFB  $7F
		DEFB  $80
		DEFB  $7D
		DEFB  $81
		DEFB  $82
		DEFB  $83
		DEFB  $84
		DEFB  $85
		DEFB  $86
		DEFB  $87
		DEFB  $88
		DEFB  $89
		DEFB  $08
		DEFB  $08
		DEFB  $00		  ; End of song

PATTDATA3:
		DEFB  $2C, $00, $90, $90, $2C, $90, $90, $00
		DEFB  $39, $00, $00, $36, $00, $00, $30, $00
		DEFB  $2C, $00, $90, $00, $2C, $00, $90, $00
		DEFB  $00, $00, $28, $00, $00, $00, $30, $00
		DEFB  $2B, $00, $00, $36, $00, $00, $30, $00
		DEFB  $00, $00, $30, $00, $30, $00, $30, $00
		DEFB  $2C, $00, $C0, $A1, $2C, $C0, $90, $00
		DEFB  $00, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $00, $00, $00, $2C, $00, $00, $00
		DEFB  $51, $6C, $48, $6C, $6C, $60, $6C, $90
		DEFB  $2C, $00, $60, $00, $2C, $90, $90, $90
		DEFB  $90, $00, $48, $00, $00, $00, $00, $00
		DEFB  $2C, $00, $00, $90, $2C, $90, $90, $00
		DEFB  $24, $00, $00, $36, $00, $00, $30, $00
		DEFB  $2C, $00, $90, $00, $2C, $90, $90, $00
		DEFB  $00, $00, $30, $00, $00, $30, $30, $00
		DEFB  $2C, $00, $00, $90, $2C, $00, $90, $00
		DEFB  $36, $00, $00, $36, $00, $00, $39, $00
		DEFB  $2C, $00, $60, $00, $2C, $00, $90, $00
		DEFB  $00, $00, $48, $00, $00, $00, $00, $00
		DEFB  $2C, $00, $6C, $60, $2C, $6C, $60, $00
		DEFB  $48, $00, $51, $48, $00, $51, $48, $00
		DEFB  $2C, $00, $A1, $00, $2C, $00, $90, $00
		DEFB  $00, $00, $00, $00, $60, $00, $00, $00
		DEFB  $51, $00, $00, $51, $00, $00, $48, $00
		DEFB  $00, $00, $00, $00, $60, $00, $39, $00
		DEFB  $36, $00, $00, $36, $00, $00, $30, $00
		DEFB  $00, $00, $30, $00, $00, $00, $00, $00
		DEFB  $90, $00, $A1, $90, $00, $A1, $90, $00
		DEFB  $00, $00, $00, $00, $60, $00, $48, $00
		DEFB  $2C, $A1, $A1, $A1, $2C, $A1, $A1, $A1
		DEFB  $A1, $00, $A1, $00, $A1, $00, $A1, $00
		DEFB  $2C, $AB, $AB, $AB, $2C, $AB, $AB, $AB
		DEFB  $AB, $00, $AB, $00, $AB, $00, $AB, $00
		DEFB  $2C, $C0, $C0, $C0, $2C, $C0, $C0, $C0
		DEFB  $C0, $00, $C0, $00, $C0, $00, $C0, $00
		DEFB  $2C, $00, $A1, $90, $2C, $A1, $90, $00
		DEFB  $60, $00, $00, $60, $00, $00, $60, $00
		DEFB  $2C, $00, $A1, $00, $2C, $00, $00, $00
		DEFB  $00, $00, $00, $00, $60, $00, $51, $00
		DEFB  $2C, $00, $00, $56, $2C, $00, $90, $00
		DEFB  $36, $00, $00, $51, $00, $00, $60, $00
		DEFB  $2C, $00, $48, $00, $2C, $00, $00, $00
		DEFB  $2C, $00, $00, $00, $00, $00, $C0, $00
		DEFB  $13, $00, $12, $00, $13, $00, $15, $00
		DEFB  $00, $AB, $00, $00, $2C, $00, $00, $C0
		DEFB  $18, $00, $15, $00, $13, $00, $12, $00
		DEFB  $00, $00, $AB, $00, $00, $00, $00, $00
		DEFB  $13, $00, $15, $00, $18, $00, $15, $00
		DEFB  $00, $00, $00, $00, $2C, $00, $00, $00
		DEFB  $00, $00, $90, $00, $00, $00, $00, $00
		DEFB  $18, $00, $1C, $00, $13, $00, $12, $00
		DEFB  $00, $00, $C0, $00, $00, $00, $00, $00
		DEFB  $12, $00, $10, $00, $12, $00, $15, $00
		DEFB  $13, $00, $15, $00, $18, $00, $1C, $00
		DEFB  $19, $00, $18, $00, $19, $00, $1C, $00
		DEFB  $19, $00, $1C, $00, $19, $00, $18, $00
		DEFB  $19, $00, $1C, $00, $1E, $00, $24, $00
		DEFB  $00, $AB, $00, $00, $2C, $00, $00, $60
		DEFB  $1E, $00, $24, $00, $20, $00, $24, $00
		DEFB  $26, $00, $24, $00, $20, $00, $24, $00
		DEFB  $2C, $00, $00, $00, $00, $00, $60, $00
		DEFB  $26, $00, $2B, $00, $26, $00, $24, $00
		DEFB  $26, $00, $2B, $00, $30, $00, $2B, $00
		DEFB  $00, $00, $60, $00, $00, $00, $00, $00
		DEFB  $26, $00, $30, $00, $33, $00, $2B, $00
		DEFB  $39, $00, $33, $00, $30, $00, $33, $00
		DEFB  $39, $00, $33, $00, $30, $00, $2B, $00
		DEFB  $33, $00, $39, $00, $33, $00, $30, $00
		DEFB  $33, $00, $39, $00, $40, $00, $4C, $00
		DEFB  $48, $00, $40, $00, $4C, $00, $48, $00
		DEFB  $40, $00, $48, $00, $40, $00, $39, $00
		DEFB  $33, $00, $30, $00, $33, $00, $39, $00
		DEFB  $40, $00, $39, $00, $33, $00, $30, $00
		DEFB  $33, $00, $39, $00, $40, $00, $39, $00
		DEFB  $40, $00, $4C, $00, $48, $00, $40, $00
		DEFB  $48, $00, $4C, $00, $40, $00, $39, $00
		DEFB  $33, $00, $30, $00, $2B, $00, $30, $00
		DEFB  $33, $00, $40, $00, $4C, $00, $48, $00
		DEFB  $39, $00, $48, $00, $4C, $00, $48, $00
		DEFB  $4C, $00, $48, $00, $40, $00, $4C, $00
		DEFB  $56, $00, $72, $00, $80, $00, $72, $00
		DEFB  $66, $00, $40, $00, $00, $00, $00, $00
		DEFB  $00, $00, $00, $00, $48, $00, $00, $00
		DEFB  $2C, $00, $C0, $AB, $2C, $C0, $AB, $00
		DEFB  $40, $00, $39, $00, $2B, $30, $39, $40
		DEFB  $2C, $00, $C0, $00, $2C, $00, $90, $00
		DEFB  $39, $3D, $39, $3D, $39, $3D, $40, $48
		DEFB  $56, $48, $40, $3D, $39, $30, $39, $3D
		DEFB  $2C, $00, $C0, $00, $2C, $00, $C0, $00
		DEFB  $39, $3D, $39, $39, $30, $33, $39, $3D
		DEFB  $39, $00, $00, $33, $00, $00, $30, $00
		DEFB  $33, $00, $39, $00, $33, $00, $00, $30
		DEFB  $33, $00, $39, $00, $00, $3D, $00, $00
		DEFB  $39, $00, $00, $3D, $00, $00, $40, $00
		DEFB  $00, $48, $00, $00, $30, $00, $33, $00
		DEFB  $39, $00, $3D, $00, $00, $39, $00, $00
		DEFB  $2C, $00, $C0, $AB, $2C, $C0, $C0, $00
		DEFB  $33, $39, $3D, $39, $3D, $40, $48, $40
		DEFB  $2C, $00, $60, $00, $2C, $00, $60, $00
		DEFB  $00, $00, $2B, $00, $00, $00, $2B, $00
		DEFB  $24, $00, $2B, $00, $30, $00, $40, $00
		DEFB  $39, $00, $00, $00, $2B, $00, $00, $30
		DEFB  $00, $00, $2B, $00, $00, $30, $00, $00
		DEFB  $20, $00, $24, $00, $30, $00, $30, $00
		DEFB  $00, $20, $00, $24, $00, $30, $00, $30
		DEFB  $00, $00, $20, $00, $24, $00, $30, $00
		DEFB  $1C, $00, $20, $00, $30, $00, $00, $30
		DEFB  $00, $1C, $00, $20, $00, $30, $00, $00
		DEFB  $30, $00, $1C, $00, $20, $00, $30, $00
		DEFB  $18, $00, $1C, $00, $30, $00, $00, $30
		DEFB  $00, $18, $00, $1C, $00, $30, $00, $00
		DEFB  $30, $00, $18, $00, $1C, $00, $30, $00
		DEFB  $15, $00, $18, $00, $30, $00, $00, $30
		DEFB  $00, $15, $00, $18, $00, $30, $00, $00
		DEFB  $30, $00, $15, $00, $18, $00, $30, $00
		DEFB  $12, $00, $15, $00, $30, $00, $00, $30
		DEFB  $00, $12, $00, $00, $1C, $1B, $19, $18
		DEFB  $15, $00, $30, $36, $39, $40, $48, $4C
		DEFB  $56, $60, $6C, $72, $80, $00, $10, $0F
		DEFB  $0E, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $00, $00, $00, $00, $00, $00, $00
		DEFB  $10, $0F, $0E, $00, $00, $00, $00, $00
		DEFB  $00, $00, $39, $00, $00, $39, $00, $00
		DEFB  $2C, $00, $00, $80, $2C, $00, $80, $00
		DEFB  $33, $33, $33, $30, $30, $30, $2B, $2B
		DEFB  $2C, $80, $80, $80, $2C, $80, $80, $80
		DEFB  $2B, $2B, $2B, $2B, $24, $24, $24, $24
		DEFB  $26, $26, $26, $30, $30, $30, $2B, $2B
		DEFB  $2C, $80, $80, $80, $2C, $00, $00, $00
		DEFB  $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B
		DEFB  $2C, $00, $00, $C0, $2C, $C0, $C0, $C0
		DEFB  $26, $26, $26, $24, $24, $24, $20, $20
		DEFB  $2C, $C0, $C0, $C0, $2C, $C0, $C0, $00
		DEFB  $20, $20, $20, $20, $1B, $1B, $1B, $1B
		DEFB  $2C, $00, $00, $90, $2C, $00, $C0, $00
		DEFB  $1C, $1C, $1C, $24, $24, $24, $20, $00
		DEFB  $00, $00, $00

; --------------------------
; Caldron
; --------------------------
musicData4:
		DEFW  $073A		  ; Initial tempo
		DEFW  PATTDATA4 - 8	   ; Ptr to start of pattern data - 8
		DEFB  $01
		DEFB  $02
		DEFB  $01
		DEFB  $03
		DEFB  $01
		DEFB  $04
		DEFB  $01
		DEFB  $05
		DEFB  $01
		DEFB  $02
		DEFB  $01
		DEFB  $03
		DEFB  $01
		DEFB  $04
		DEFB  $01
		DEFB  $05
		DEFB  $01
		DEFB  $02
		DEFB  $01
		DEFB  $03
		DEFB  $01
		DEFB  $04
		DEFB  $01
		DEFB  $05
		DEFB  $06
		DEFB  $02
		DEFB  $07
		DEFB  $03
		DEFB  $08
		DEFB  $09
		DEFB  $0A
		DEFB  $05
		DEFB  $01
		DEFB  $02
		DEFB  $01
		DEFB  $03
		DEFB  $01
		DEFB  $04
		DEFB  $01
		DEFB  $05
		DEFB  $01
		DEFB  $02
		DEFB  $01
		DEFB  $03
		DEFB  $01
		DEFB  $04
		DEFB  $01
		DEFB  $05
		DEFB  $01
		DEFB  $02
		DEFB  $01
		DEFB  $03
		DEFB  $01
		DEFB  $09
		DEFB  $01
		DEFB  $05
		DEFB  $0B
		DEFB  $02
		DEFB  $0C
		DEFB  $03
		DEFB  $0D
		DEFB  $0E
		DEFB  $0F
		DEFB  $10
		DEFB  $11
		DEFB  $0E
		DEFB  $12
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $11
		DEFB  $18
		DEFB  $12
		DEFB  $19
		DEFB  $14
		DEFB  $1A
		DEFB  $1B
		DEFB  $18
		DEFB  $01
		DEFB  $1C
		DEFB  $01
		DEFB  $13
		DEFB  $01
		DEFB  $1D
		DEFB  $01
		DEFB  $1E
		DEFB  $11
		DEFB  $1F
		DEFB  $12
		DEFB  $20
		DEFB  $14
		DEFB  $21
		DEFB  $16
		DEFB  $22
		DEFB  $01
		DEFB  $23
		DEFB  $01
		DEFB  $24
		DEFB  $01
		DEFB  $23
		DEFB  $01
		DEFB  $24
		DEFB  $11
		DEFB  $25
		DEFB  $12
		DEFB  $26
		DEFB  $14
		DEFB  $27
		DEFB  $1B
		DEFB  $25
		DEFB  $11
		DEFB  $28
		DEFB  $12
		DEFB  $29
		DEFB  $14
		DEFB  $2A
		DEFB  $16
		DEFB  $1D
		DEFB  $2B
		DEFB  $1C
		DEFB  $2C
		DEFB  $1D
		DEFB  $2D
		DEFB  $2E
		DEFB  $2F
		DEFB  $05
		DEFB  $00		  ; End of song

PATTDATA4:
		DEFB  $2C, $00, $00, $00, $00, $00, $00, $00
		DEFB  $A1, $00, $00, $00, $51, $00, $5B, $00
		DEFB  $A1, $00, $00, $00, $44, $00, $00, $00
		DEFB  $A1, $00, $00, $00, $00, $00, $00, $00
		DEFB  $51, $00, $00, $00, $51, $00, $5B, $00
		DEFB  $2C, $00, $0F, $0C, $10, $0D, $11, $0E
		DEFB  $2C, $0F, $13, $10, $14, $11, $15, $12
		DEFB  $2C, $13, $18, $14, $19, $15, $1B, $17
		DEFB  $A1, $00, $00, $00, $00, $00, $11, $00
		DEFB  $2C, $18, $1E, $19, $1E, $20, $22, $24
		DEFB  $2C, $00, $36, $39, $33, $39, $30, $39
		DEFB  $2C, $39, $2B, $39, $28, $39, $26, $39
		DEFB  $2C, $39, $22, $39, $20, $39, $1E, $39
		DEFB  $A1, $00, $00, $00, $6C, $00, $00, $00
		DEFB  $2C, $1B, $18, $15, $14, $12, $11, $0F
		DEFB  $88, $00, $00, $00, $90, $00, $00, $00
		DEFB  $2C, $00, $00, $00, $2C, $00, $2C, $00
		DEFB  $00, $00, $00, $00, $00, $00, $2C, $00
		DEFB  $51, $00, $00, $00, $44, $00, $00, $00
		DEFB  $2C, $00, $00, $00, $2C, $00, $00, $00
		DEFB  $51, $00, $00, $00, $6C, $00, $00, $00
		DEFB  $00, $00, $00, $00, $00, $00, $00, $00
		DEFB  $88, $00, $00, $00, $6C, $00, $00, $00
		DEFB  $A1, $00, $00, $00, $51, $00, $00, $00
		DEFB  $90, $00, $00, $00, $48, $00, $00, $00
		DEFB  $88, $00, $00, $00, $44, $00, $00, $00
		DEFB  $0D, $00, $00, $00, $11, $00, $00, $00
		DEFB  $90, $00, $00, $00, $60, $00, $00, $00
		DEFB  $51, $00, $00, $00, $60, $00, $00, $00
		DEFB  $72, $00, $00, $00, $60, $00, $00, $00
		DEFB  $48, $00, $00, $00, $90, $00, $00, $00
		DEFB  $51, $00, $00, $00, $90, $00, $00, $00
		DEFB  $60, $00, $00, $00, $6C, $00, $00, $00
		DEFB  $72, $00, $00, $00, $90, $00, $00, $00
		DEFB  $79, $00, $00, $00, $51, $00, $00, $00
		DEFB  $44, $00, $00, $00, $51, $00, $00, $00
		DEFB  $79, $00, $00, $00, $3D, $00, $00, $00
		DEFB  $6C, $00, $00, $00, $36, $00, $00, $00
		DEFB  $66, $00, $00, $00, $33, $00, $00, $00
		DEFB  $24, $00, $00, $00, $28, $00, $00, $00
		DEFB  $30, $00, $00, $00, $36, $00, $00, $00
		DEFB  $39, $00, $00, $00, $48, $00, $00, $00
		DEFB  $2C, $00, $0C, $00, $0D, $00, $0E, $00
		DEFB  $2C, $0C, $10, $0D, $11, $0E, $12, $0F
		DEFB  $2C, $10, $14, $11, $15, $12, $17, $13
		DEFB  $90, $00, $00, $00, $00, $00, $00, $00
		DEFB  $18, $14, $19, $15, $1B, $17, $1C, $18
		DEFB  $00, $00, $00
; ----------------------------------
; SONG 5 : CARS, Gary Numan.
; ----------------------------------
	  
musicData5: 	DEFW  $0E6C		  ; Initial tempo
		DEFW  PATTDATA5 - 8	   ; Ptr to start of pattern data - 8
		DEFB  $01
		DEFB  $02, $03, $04, $01, $02, $03, $04, $01, $02, $03, $04, $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $05
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $05
		DEFB  $09
		DEFB  $07
		DEFB  $04
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $0A
		DEFB  $05
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $05
		DEFB  $09
		DEFB  $07
		DEFB  $04
		DEFB  $01
		DEFB  $0B
		DEFB  $03
		DEFB  $0C
		DEFB  $01
		DEFB  $0B
		DEFB  $03
		DEFB  $0C
		DEFB  $01
		DEFB  $0B
		DEFB  $03
		DEFB  $0C
		DEFB  $01
		DEFB  $0B
		DEFB  $0D
		DEFB  $0C
		DEFB  $05
		DEFB  $0E
		DEFB  $07
		DEFB  $0F
		DEFB  $05
		DEFB  $0E
		DEFB  $10
		DEFB  $04
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $14
		DEFB  $11
		DEFB  $12
		DEFB  $15
		DEFB  $16
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $14
		DEFB  $17
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $14
		DEFB  $11
		DEFB  $12
		DEFB  $15
		DEFB  $16
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $14
		DEFB  $1B
		DEFB  $1C
		DEFB  $04
		DEFB  $04
		DEFB  $00		  ; End of song

PATTDATA5:
		DEFB  $2C, $00, $80, $00, $B4, $00, $A1, $00
		DEFB  $28, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $00, $A1, $00, $A1, $00, $00, $00
		DEFB  $00, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $00, $00, $00, $90, $00, $B4, $00
		DEFB  $28, $00, $00, $00, $00, $00, $2D, $00
		DEFB  $2C, $00, $00, $00, $00, $00, $C0, $00
		DEFB  $00, $00, $00, $00, $3D, $00, $00, $00
		DEFB  $48, $00, $00, $00, $00, $00, $5B, $00
		DEFB  $00, $00, $00, $00, $24, $00, $00, $00
		DEFB  $3D, $00, $40, $00, $5B, $00, $51, $00
		DEFB  $00, $00, $51, $00, $51, $00, $00, $00
		DEFB  $00, $00, $A1, $00, $A1, $00, $00, $00
		DEFB  $5B, $00, $00, $00, $48, $00, $5B, $00
		DEFB  $00, $00, $00, $00, $00, $00, $60, $00
		DEFB  $2C, $00, $00, $00, $00, $00, $00, $00
		DEFB  $79, $00, $00, $00, $3D, $00, $51, $00
		DEFB  $3D, $00, $00, $00, $1E, $00, $28, $00
		DEFB  $00, $00, $48, $00, $44, $00, $48, $00
		DEFB  $00, $00, $24, $00, $22, $00, $24, $00
		DEFB  $00, $00, $33, $00, $36, $00, $00, $00
		DEFB  $00, $00, $19, $00, $1B, $00, $00, $00
		DEFB  $79, $00, $00, $00, $00, $00, $79, $00
		DEFB  $3D, $00, $00, $00, $00, $00, $3D, $00
		DEFB  $00, $00, $48, $44, $3D, $00, $00, $00
		DEFB  $00, $00, $24, $22, $1E, $00, $00, $00
		DEFB  $79, $00, $5B, $00, $51, $00, $3D, $00
		DEFB  $3D, $00, $2D, $00, $28, $00, $1E, $00


;---------------------------------
; SONG 6 : Hangover
;---------------------------------
musicData6      DEFW  $09A0               ; Initial tempo
                DEFW  md6 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $05
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $08
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $05
                DEFB  $07
                DEFB  $08
                DEFB  $0A
                DEFB  $08
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0C
                DEFB  $0E
                DEFB  $0C
                DEFB  $0F
                DEFB  $0C
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $11
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $14
                DEFB  $16
                DEFB  $0C
                DEFB  $17
                DEFB  $0C
                DEFB  $18
                DEFB  $0C
                DEFB  $19
                DEFB  $0C
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0C
                DEFB  $1A
                DEFB  $0C
                DEFB  $1B
                DEFB  $0C
                DEFB  $1C
                DEFB  $11
                DEFB  $1D
                DEFB  $11
                DEFB  $1E
                DEFB  $14
                DEFB  $1F
                DEFB  $14
                DEFB  $20
                DEFB  $0C
                DEFB  $21
                DEFB  $0C
                DEFB  $22
                DEFB  $0C
                DEFB  $23
                DEFB  $0C
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $07
                DEFB  $08
                DEFB  $0A
                DEFB  $08
                DEFB  $07
                DEFB  $08
                DEFB  $0A
                DEFB  $08
                DEFB  $24
                DEFB  $05
                DEFB  $25
                DEFB  $05
                DEFB  $24
                DEFB  $05
                DEFB  $25
                DEFB  $05
                DEFB  $07
                DEFB  $08
                DEFB  $0A
                DEFB  $08
                DEFB  $07
                DEFB  $08
                DEFB  $0A
                DEFB  $08
                DEFB  $26
                DEFB  $27
                DEFB  $03
                DEFB  $28
                DEFB  $26
                DEFB  $29
                DEFB  $03
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $0A
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $25
                DEFB  $2F
                DEFB  $2B
                DEFB  $30
                DEFB  $0A
                DEFB  $31
                DEFB  $26
                DEFB  $32
                DEFB  $03
                DEFB  $33
                DEFB  $2B
                DEFB  $34
                DEFB  $0A
                DEFB  $35
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0C
                DEFB  $0E
                DEFB  $0C
                DEFB  $0F
                DEFB  $0C
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $11
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $14
                DEFB  $16
                DEFB  $0C
                DEFB  $17
                DEFB  $0C
                DEFB  $18
                DEFB  $0C
                DEFB  $19
                DEFB  $0C
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0C
                DEFB  $1A
                DEFB  $0C
                DEFB  $1B
                DEFB  $0C
                DEFB  $1C
                DEFB  $11
                DEFB  $1D
                DEFB  $11
                DEFB  $1E
                DEFB  $14
                DEFB  $1F
                DEFB  $14
                DEFB  $20
                DEFB  $0C
                DEFB  $21
                DEFB  $0C
                DEFB  $22
                DEFB  $0C
                DEFB  $23
                DEFB  $0C
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $07
                DEFB  $08
                DEFB  $0A
                DEFB  $08
                DEFB  $07
                DEFB  $08
                DEFB  $0A
                DEFB  $08
                DEFB  $24
                DEFB  $05
                DEFB  $25
                DEFB  $05
                DEFB  $24
                DEFB  $05
                DEFB  $25
                DEFB  $05
                DEFB  $07
                DEFB  $08
                DEFB  $0A
                DEFB  $08
                DEFB  $07
                DEFB  $08
                DEFB  $0A
                DEFB  $08
                DEFB  $FF                 ; Tempo change
                DEFW  $10D2               ; New tempo value
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $38
                DEFB  $00                 ; End of song

md6:
                DEFB  $2C, $5B, $66, $6C, $44, $5B, $66, $6C
                DEFB  $00, $88, $00, $88, $00, $88, $00, $88
                DEFB  $44, $5B, $66, $6C, $44, $51, $66, $6C
                DEFB  $2C, $51, $5B, $60, $3D, $51, $2C, $60
                DEFB  $00, $79, $00, $79, $00, $79, $00, $79
                DEFB  $3D, $51, $5B, $60, $2C, $48, $5B, $60
                DEFB  $2C, $66, $72, $79, $4C, $66, $72, $79
                DEFB  $00, $97, $00, $97, $00, $97, $00, $97
                DEFB  $4C, $66, $72, $79, $4C, $5B, $2C, $79
                DEFB  $4C, $66, $72, $79, $4C, $5B, $72, $79
                DEFB  $2C, $44, $44, $44, $5B, $5B, $5B, $5B
                DEFB  $00, $88, $00, $97, $00, $B4, $00, $88
                DEFB  $5B, $5B, $5B, $5B, $44, $44, $44, $44
                DEFB  $2C, $36, $36, $36, $36, $36, $44, $44
                DEFB  $44, $44, $44, $44, $51, $51, $51, $51
                DEFB  $2C, $2D, $2D, $2D, $2D, $2D, $33, $33
                DEFB  $00, $79, $00, $B4, $00, $90, $00, $79
                DEFB  $33, $33, $33, $33, $36, $36, $36, $36
                DEFB  $2C, $4C, $4C, $4C, $4C, $4C, $4C, $4C
                DEFB  $00, $97, $00, $B4, $00, $72, $00, $97
                DEFB  $4C, $4C, $4C, $4C, $33, $33, $33, $33
                DEFB  $2C, $26, $26, $26, $28, $28, $28, $28
                DEFB  $2D, $2D, $2D, $2D, $33, $33, $33, $33
                DEFB  $2C, $36, $36, $36, $3D, $3D, $3D, $3D
                DEFB  $44, $44, $44, $44, $33, $33, $33, $33
                DEFB  $2C, $36, $36, $36, $36, $36, $2D, $2D
                DEFB  $2D, $2D, $2D, $2D, $22, $22, $22, $22
                DEFB  $2C, $1E, $22, $22, $24, $24, $28, $24
                DEFB  $2D, $2D, $33, $33, $36, $33, $3D, $3D
                DEFB  $2C, $2D, $28, $26, $1E, $1E, $22, $26
                DEFB  $28, $2D, $33, $36, $3D, $44, $4C, $51
                DEFB  $2C, $2D, $33, $36, $33, $2D, $33, $36
                DEFB  $22, $22, $24, $28, $22, $1E, $22, $24
                DEFB  $2C, $28, $2D, $33, $36, $3D, $44, $4C
                DEFB  $5B, $5B, $4C, $4C, $44, $44, $3D, $3D
                DEFB  $2C, $51, $5B, $60, $3D, $51, $5B, $60
                DEFB  $3D, $51, $5B, $60, $3D, $48, $5B, $60
                DEFB  $44, $5B, $66, $6C, $44, $5B, $66, $6C
                DEFB  $22, $88, $28, $88, $36, $88, $33, $88
                DEFB  $2D, $88, $28, $88, $2D, $88, $28, $88
                DEFB  $24, $88, $28, $88, $33, $88, $36, $88
                DEFB  $2D, $88, $00, $88, $00, $88, $00, $88
                DEFB  $4C, $66, $72, $79, $4C, $66, $72, $79
                DEFB  $26, $97, $28, $97, $2D, $97, $33, $97
                DEFB  $3D, $51, $5B, $60, $3D, $51, $5B, $60
                DEFB  $19, $79, $1B, $79, $1E, $79, $22, $79
                DEFB  $1E, $79, $00, $79, $00, $79, $00, $79
                DEFB  $33, $97, $39, $97, $33, $97, $2D, $97
                DEFB  $26, $97, $2D, $97, $26, $97, $22, $97
                DEFB  $1B, $88, $00, $88, $00, $88, $00, $88
                DEFB  $1B, $88, $1E, $88, $22, $88, $00, $88
                DEFB  $26, $97, $00, $97, $00, $97, $00, $97
                DEFB  $26, $97, $28, $97, $2D, $97, $44, $97
                DEFB  $88, $00, $00, $00, $88, $00, $00, $00
                DEFB  $22, $44, $88, $00, $44, $00, $00, $00
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00


;---------------------------------
; SONG 7 : CLASSICAL GAS
;---------------------------------
musicData7
                DEFW  $159E               ; Initial tempo
                DEFW  md7 - 8        ; Ptr to start of pattern data - 8
                DEFB  $FF                 ; Tempo change
                DEFW  $0E6C               ; New tempo value
                DEFB  $01
                DEFB  $02
                DEFB  $FF                 ; Tempo change
                DEFW  $159E               ; New tempo value
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $08
                DEFB  $05
                DEFB  $06
                DEFB  $0C
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $08
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $08
                DEFB  $05
                DEFB  $06
                DEFB  $0C
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $08
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $03
                DEFB  $04
                DEFB  $11
                DEFB  $12
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $15
                DEFB  $16
                DEFB  $19
                DEFB  $1A
                DEFB  $15
                DEFB  $16
                DEFB  $19
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $08
                DEFB  $08
                DEFB  $00                 ; End of song

md7:
                DEFB  $88, $00, $00, $97, $00, $00, $88, $00
                DEFB  $44, $00, $00, $00, $4C, $3D, $00, $44
                DEFB  $72, $00, $00, $00, $44, $00, $00, $00
                DEFB  $2D, $00, $4C, $33, $39, $00, $33, $00
                DEFB  $88, $00, $00, $00, $88, $00, $5B, $00
                DEFB  $39, $3D, $39, $44, $00, $39, $00, $3D
                DEFB  $97, $66, $4C, $A1, $66, $4C, $A1, $66
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $B4, $00, $00, $00, $B4, $00, $B4, $00
                DEFB  $3D, $44, $4C, $44, $00, $3D, $00, $44
                DEFB  $88, $5B, $44, $88, $5B, $44, $88, $44
                DEFB  $97, $66, $4C, $A1, $66, $4C, $88, $66
                DEFB  $88, $00, $00, $00, $97, $00, $00, $00
                DEFB  $00, $5B, $44, $3D, $00, $4C, $3D, $39
                DEFB  $88, $00, $00, $79, $00, $00, $79, $00
                DEFB  $00, $44, $39, $00, $4C, $33, $00, $4C
                DEFB  $AB, $00, $00, $00, $B4, $00, $00, $00
                DEFB  $44, $00, $00, $4C, $44, $5B, $44, $4C
                DEFB  $72, $00, $00, $AB, $00, $00, $66, $00
                DEFB  $2D, $39, $4C, $2B, $39, $44, $28, $33
                DEFB  $88, $00, $00, $00, $88, $00, $88, $00
                DEFB  $1C, $1E, $22, $26, $00, $22, $00, $28
                DEFB  $66, $00, $00, $66, $00, $00, $88, $00
                DEFB  $00, $22, $28, $00, $22, $28, $00, $22
                DEFB  $66, $00, $66, $00, $00, $66, $00, $00
                DEFB  $00, $26, $00, $22, $26, $00, $22, $2D
                DEFB  $00, $00, $1C, $22, $26, $00, $22, $26
                DEFB  $00, $00, $39, $00, $00, $44, $00, $00
                DEFB  $97, $00, $2D, $72, $00, $2B, $AB, $00
                DEFB  $88, $2D, $00, $88, $2D, $00, $88, $2D
                DEFB  $00, $33, $00, $00, $33, $00, $00, $33


;---------------------------------
; SONG 8 : Dweller on the Threshold
;---------------------------------
musicData8
                DEFW  $0E6C               ; Initial tempo
                DEFW  md8 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02,  $01,  $03,  $04, $05,  $04
                DEFB  $03
                DEFB  $06
                DEFB  $02
                DEFB  $06
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $04
                DEFB  $03
                DEFB  $01
                DEFB  $02
                DEFB  $01
                DEFB  $03
                DEFB  $04
                DEFB  $07
                DEFB  $04
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $09
                DEFB  $03
                DEFB  $0B
                DEFB  $0C
                DEFB  $0B
                DEFB  $03
                DEFB  $01
                DEFB  $0D
                DEFB  $01
                DEFB  $03
                DEFB  $04
                DEFB  $0E
                DEFB  $04
                DEFB  $03
                DEFB  $06
                DEFB  $0F
                DEFB  $06
                DEFB  $10
                DEFB  $04
                DEFB  $0E
                DEFB  $04
                DEFB  $11
                DEFB  $01
                DEFB  $0D
                DEFB  $01
                DEFB  $03
                DEFB  $04
                DEFB  $12
                DEFB  $04
                DEFB  $13
                DEFB  $09
                DEFB  $14
                DEFB  $09
                DEFB  $03
                DEFB  $0B
                DEFB  $15
                DEFB  $16
                DEFB  $03
                DEFB  $06
                DEFB  $17
                DEFB  $06
                DEFB  $13
                DEFB  $09
                DEFB  $18
                DEFB  $09
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $1A
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1D
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $20
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $23
                DEFB  $25
                DEFB  $26
                DEFB  $27
                DEFB  $26
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $29
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2C
                DEFB  $2E
                DEFB  $2C
                DEFB  $2D
                DEFB  $2C
                DEFB  $2E
                DEFB  $2C
                DEFB  $2D
                DEFB  $2C
                DEFB  $2E
                DEFB  $2C
                DEFB  $03
                DEFB  $2F
                DEFB  $03
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $34
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $34
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $34
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $34
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $00                 ; End of song

md8:
                DEFB  $2C, $6C, $D7, $6C, $2C, $6C, $D7, $6C
                DEFB  $48, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $60, $C0, $60, $2C, $60, $C0, $60
                DEFB  $4C, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $5B, $B4, $5B, $2C, $5B, $B4, $5B
                DEFB  $4C, $00, $00, $00, $00, $00, $48, $00
                DEFB  $00, $00, $00, $00, $40, $00, $00, $00
                DEFB  $2C, $48, $90, $48, $2C, $48, $90, $48
                DEFB  $3D, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $51, $A1, $51, $2C, $51, $A1, $51
                DEFB  $40, $00, $00, $00, $00, $00, $00, $00
                DEFB  $24, $00, $00, $00, $00, $00, $00, $00
                DEFB  $26, $00, $00, $00, $00, $00, $00, $00
                DEFB  $24, $00, $00, $00, $00, $00, $1E, $00
                DEFB  $00, $00, $00, $00, $20, $00, $24, $00
                DEFB  $00, $00, $00, $00, $00, $00, $30, $00
                DEFB  $26, $00, $00, $00, $00, $00, $24, $00
                DEFB  $00, $00, $00, $00, $20, $00, $00, $00
                DEFB  $1E, $00, $00, $00, $00, $00, $00, $00
                DEFB  $20, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $51, $A1, $51, $A1, $51, $A1, $51
                DEFB  $3D, $00, $00, $00, $00, $00, $30, $00
                DEFB  $00, $00, $00, $00, $00, $00, $2D, $00
                DEFB  $00, $00, $00, $00, $1E, $00, $00, $00
                DEFB  $2C, $4C, $97, $4C, $2C, $4C, $97, $4C
                DEFB  $00, $00, $00, $00, $00, $00, $28, $00
                DEFB  $00, $00, $00, $00, $1B, $00, $00, $00
                DEFB  $2C, $3D, $79, $3D, $2C, $3D, $79, $3D
                DEFB  $00, $00, $00, $00, $00, $00, $26, $00
                DEFB  $00, $00, $00, $00, $19, $00, $00, $00
                DEFB  $2C, $40, $80, $40, $2C, $40, $80, $40
                DEFB  $00, $00, $00, $00, $00, $00, $22, $00
                DEFB  $00, $00, $00, $00, $17, $00, $00, $00
                DEFB  $2C, $33, $66, $33, $2C, $33, $66, $33
                DEFB  $00, $00, $00, $00, $00, $00, $20, $00
                DEFB  $00, $00, $00, $00, $15, $00, $00, $00
                DEFB  $2C, $36, $6C, $36, $2C, $36, $6C, $36
                DEFB  $00, $00, $00, $00, $00, $00, $1C, $00
                DEFB  $00, $00, $00, $00, $13, $00, $00, $00
                DEFB  $2C, $2B, $56, $2B, $2C, $2B, $56, $2B
                DEFB  $00, $00, $00, $00, $00, $00, $1B, $00
                DEFB  $00, $00, $00, $00, $12, $00, $00, $00
                DEFB  $2C, $2D, $5B, $2D, $2C, $2D, $5B, $2D
                DEFB  $00, $00, $00, $00, $00, $00, $18, $00
                DEFB  $00, $00, $00, $00, $10, $00, $00, $00
                DEFB  $2C, $2D, $5B, $2D, $5B, $2D, $5B, $2D
                DEFB  $2C, $00, $CB, $00, $2C, $00, $CB, $00
                DEFB  $6C, $00, $66, $00, $6C, $00, $66, $00
                DEFB  $2C, $00, $B4, $00, $2C, $00, $CB, $00
                DEFB  $6C, $00, $5B, $00, $56, $00, $66, $00
                DEFB  $6C, $00, $5B, $00, $60, $00, $66, $00
                DEFB  $2C, $00, $97, $00, $2C, $00, $AB, $00
                DEFB  $6C, $00, $4C, $00, $51, $00, $56, $00
                DEFB  $2C, $00, $79, $00, $2C, $00, $88, $00
                DEFB  $39, $00, $3D, $00, $40, $00, $44, $00





end
