; HUBY-O  ---    HUBY MUSIC BOX $4
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
; 1. PLASTIC GALAXY
; 2. PYLON
; 3. ROOT BEER RAG
; 4. MUSIC STUDIO THEME
; 5. MY BEEP SONG
; 6. ROLLS AND BALLS
; 7. TSERBRALNOE NARUSHENIE
;
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


MSG1 	db	"HUBY MUSICBOX #4.      BUSHY'19", $0d
	db 	$0d,$0d, "PLEASE SELECT:  ", $0d
	db 	"1 PLASTIC GALAXY", $0d
	db 	"2 PYLON", $0d
	db 	"3 ROOT BEER RAG", $0d
	db 	"4 MUSICSTUDIO THEME", $0d
	db 	"5 MY BEEP SONG", $0d,00
MSG2	db 	"6 ROLLS AND BALLS", $0d
	db 	"7 TSEREBRALNOE NARUSHENIE", $0d
	db 	$0d, ">", 00


MSGQUIT db	$08, $08, "QUIT...",$0d,00
PLAYING db	08,08,08,"NOW PLAYING:",0
POSCURSOR db	09,00

D1 	db	"PLASTIC GALAXY",0,0		
D2 	db	"PYLON",0,0			
D3 	db	"ROOT BEER RAG",0,0			
D4 	db	"MUSICSTUDIO THEME",0,0
D5 	db	"MY BEEP SONG",0,0
D6 	db	"ROLLS AND BALLSG",0,0
D7 	db	"TSEREBRALNOE NARUSHENIE",0,0






;---------------------------------
; SONG 1 : Plastic Galaxy
;---------------------------------
musicData1:
                DEFW  $10D2               ; Initial tempo
                DEFW  md1 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $09
                DEFB  $06
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $0C
                DEFB  $14
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $15
                DEFB  $12
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $02
                DEFB  $20
                DEFB  $04
                DEFB  $21
                DEFB  $06
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $02
                DEFB  $20
                DEFB  $04
                DEFB  $25
                DEFB  $06
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $0C
                DEFB  $14
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $15
                DEFB  $12
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $02
                DEFB  $20
                DEFB  $04
                DEFB  $21
                DEFB  $06
                DEFB  $22
                DEFB  $23
                DEFB  $1F
                DEFB  $02
                DEFB  $20
                DEFB  $04
                DEFB  $25
                DEFB  $06
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $2C
                DEFB  $29
                DEFB  $30
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $33
                DEFB  $3B
                DEFB  $35
                DEFB  $3C
                DEFB  $37
                DEFB  $3D
                DEFB  $39
                DEFB  $3E
                DEFB  $3F
                DEFB  $3E
                DEFB  $40
                DEFB  $41
                DEFB  $42
                DEFB  $43
                DEFB  $44
                DEFB  $45
                DEFB  $46
                DEFB  $47
                DEFB  $1A
                DEFB  $1A
                DEFB  $1A
                DEFB  $1A
                DEFB  $1A
                DEFB  $1A
                DEFB  $00                 ; End of song

md1:
                DEFB  $51, $40, $36, $2B, $24, $40, $36, $2B
                DEFB  $A1, $36, $2B, $20, $1B, $36, $2B, $20
                DEFB  $66, $44, $36, $28, $22, $44, $36, $28
                DEFB  $33, $51, $44, $36, $28, $51, $44, $36
                DEFB  $5B, $24, $1E, $18, $14, $24, $1E, $18
                DEFB  $B4, $30, $24, $1E, $18, $30, $24, $1E
                DEFB  $79, $33, $28, $22, $1B, $33, $28, $22
                DEFB  $3D, $28, $22, $1B, $14, $28, $22, $1B
                DEFB  $5B, $24, $1E, $18, $14, $24, $1E, $2C
                DEFB  $66, $2C, $2C, $6C, $24, $2C, $B4, $00
                DEFB  $33, $22, $17, $36, $1E, $12, $24, $00
                DEFB  $2C, $40, $A1, $36, $28, $1E, $A1, $1B
                DEFB  $20, $00, $00, $51, $20, $24, $00, $24
                DEFB  $2C, $2C, $66, $2D, $66, $33, $00, $66
                DEFB  $22, $00, $33, $24, $22, $28, $00, $33
                DEFB  $2C, $5B, $B4, $3D, $1E, $17, $00, $B4
                DEFB  $24, $28, $24, $00, $24, $1E, $00, $24
                DEFB  $2C, $2C, $79, $30, $28, $2C, $1E, $18
                DEFB  $1B, $00, $1B, $1E, $00, $24, $00, $1E
                DEFB  $20, $00, $00, $51, $20, $1E, $24, $00
                DEFB  $24, $00, $24, $00, $24, $28, $2D, $28
                DEFB  $00, $00, $30, $51, $00, $00, $60, $00
                DEFB  $2C, $2D, $28, $1B, $00, $2D, $28, $1B
                DEFB  $66, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $2D, $28, $1B, $00, $2D, $28, $1E
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $48, $2D, $28, $1B, $3D, $2D, $28, $1B
                DEFB  $B4, $00, $00, $00, $00, $00, $00, $00
                DEFB  $48, $2D, $28, $2C, $3D, $2D, $28, $12
                DEFB  $00, $00, $00, $00, $5B, $B4, $5B, $17
                DEFB  $2C, $40, $36, $2B, $24, $40, $36, $2C
                DEFB  $2C, $44, $2C, $28, $22, $44, $36, $28
                DEFB  $2C, $24, $1E, $2C, $14, $24, $1E, $18
                DEFB  $2C, $33, $2C, $22, $1B, $33, $28, $22
                DEFB  $3D, $28, $22, $1B, $14, $28, $22, $28
                DEFB  $2C, $40, $36, $2B, $24, $40, $36, $2B
                DEFB  $2C, $24, $1E, $2C, $14, $24, $1E, $2C
                DEFB  $79, $3D, $2C, $2C, $88, $44, $44, $88
                DEFB  $30, $51, $60, $28, $28, $00, $00, $00
                DEFB  $B4, $00, $00, $00, $00, $00, $2C, $00
                DEFB  $26, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $A1, $97, $79, $51, $4C, $2C, $2D
                DEFB  $00, $00, $00, $A1, $97, $79, $51, $4C
                DEFB  $2C, $00, $00, $00, $00, $00, $2C, $00
                DEFB  $33, $00, $00, $00, $00, $00, $00, $00
                DEFB  $88, $79, $51, $00, $00, $00, $00, $00
                DEFB  $00, $00, $88, $79, $51, $00, $00, $00
                DEFB  $00, $2C, $97, $79, $51, $4C, $3D, $2D
                DEFB  $44, $3D, $33, $00, $00, $00, $00, $00
                DEFB  $00, $00, $44, $3D, $33, $00, $00, $00
                DEFB  $2C, $00, $26, $1E, $72, $00, $26, $1E
                DEFB  $2D, $00, $00, $00, $00, $3D, $33, $2D
                DEFB  $2C, $4C, $66, $51, $66, $00, $72, $00
                DEFB  $26, $3D, $28, $3D, $2D, $3D, $33, $2D
                DEFB  $2C, $00, $3D, $26, $5B, $00, $3D, $26
                DEFB  $00, $00, $00, $00, $00, $3D, $33, $2D
                DEFB  $2C, $00, $3D, $26, $51, $00, $3D, $2C
                DEFB  $26, $3D, $22, $3D, $26, $3D, $28, $2D
                DEFB  $2D, $00, $00, $00, $00, $2D, $26, $22
                DEFB  $1E, $2D, $17, $2D, $19, $2D, $1C, $1E
                DEFB  $00, $00, $00, $00, $00, $2D, $26, $22
                DEFB  $1E, $2D, $00, $2D, $00, $2D, $26, $22
                DEFB  $72, $2C, $1E, $2C, $13, $2C, $00, $2C
                DEFB  $2C, $00, $22, $2C, $19, $2C, $22, $2C
                DEFB  $1E, $00, $14, $00, $13, $00, $14, $00
                DEFB  $72, $2C, $3D, $2C, $26, $2C, $2D, $2C
                DEFB  $3D, $5B, $00, $5B, $00, $5B, $4C, $44
                DEFB  $66, $00, $00, $00, $28, $00, $00, $00
                DEFB  $3D, $00, $00, $00, $22, $00, $00, $00
                DEFB  $2C, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2D, $00, $00, $00, $00, $00, $00, $00

;---------------------
; Song 2 : Pylon 
;---------------------
musicData2: 	     
                DEFW  $10D2               ; Initial tempo
                DEFW  md2 - 8        ; Ptr to start of pattern data - 8
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
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $05
                DEFB  $09
                DEFB  $07
                DEFB  $0A
                DEFB  $0B
                DEFB  $06
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $0C
                DEFB  $0A
                DEFB  $01
                DEFB  $10
                DEFB  $03
                DEFB  $11
                DEFB  $01
                DEFB  $12
                DEFB  $03
                DEFB  $12
                DEFB  $13
                DEFB  $02
                DEFB  $14
                DEFB  $04
                DEFB  $15
                DEFB  $02
                DEFB  $16
                DEFB  $04
                DEFB  $17
                DEFB  $06
                DEFB  $18
                DEFB  $0D
                DEFB  $19
                DEFB  $06
                DEFB  $1A
                DEFB  $0D
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $05
                DEFB  $09
                DEFB  $07
                DEFB  $0A
                DEFB  $0E
                DEFB  $0F
                DEFB  $0C
                DEFB  $0A
                DEFB  $05
                DEFB  $09
                DEFB  $07
                DEFB  $0A
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $05
                DEFB  $09
                DEFB  $07
                DEFB  $0A
                DEFB  $23
                DEFB  $24
                DEFB  $25
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $01
                DEFB  $10
                DEFB  $03
                DEFB  $11
                DEFB  $13
                DEFB  $02
                DEFB  $14
                DEFB  $04
                DEFB  $15
                DEFB  $02
                DEFB  $16
                DEFB  $04
                DEFB  $17
                DEFB  $06
                DEFB  $18
                DEFB  $0D
                DEFB  $2B
                DEFB  $06
                DEFB  $1A
                DEFB  $0D
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
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
                DEFB  $04
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $00                 ; End of song

md2:
                DEFB  $2C, $88, $44, $88, $2C, $44, $2C, $88
                DEFB  $44, $44, $22, $44, $44, $22, $44, $44
                DEFB  $44, $2C, $88, $2C, $88, $88, $44, $88
                DEFB  $22, $44, $44, $22, $44, $44, $22, $44
                DEFB  $2C, $A1, $51, $A1, $2C, $51, $2C, $A1
                DEFB  $1B, $51, $19, $51, $1B, $28, $51, $51
                DEFB  $51, $2C, $A1, $2C, $A1, $A1, $51, $A1
                DEFB  $14, $51, $51, $28, $51, $51, $22, $51
                DEFB  $51, $51, $28, $51, $51, $28, $51, $51
                DEFB  $28, $51, $51, $28, $51, $51, $28, $51
                DEFB  $2C, $A1, $A1, $51, $2C, $A1, $2C, $A1
                DEFB  $A1, $2C, $A1, $2C, $51, $A1, $A1, $51
                DEFB  $19, $51, $51, $28, $51, $51, $1B, $51
                DEFB  $2C, $A1, $51, $A1, $2C, $A1, $2C, $A1
                DEFB  $1E, $1B, $19, $1B, $51, $28, $51, $51
                DEFB  $11, $44, $0F, $44, $0E, $44, $0C, $44
                DEFB  $11, $44, $0F, $44, $0E, $44, $0C, $00
                DEFB  $00, $44, $0C, $44, $0E, $44, $0F, $44
                DEFB  $2C, $0E, $0F, $0E, $2C, $0E, $2C, $0E
                DEFB  $11, $2C, $0C, $2C, $00, $0C, $0E, $0F
                DEFB  $2C, $0C, $0E, $0F, $2C, $0E, $2C, $11
                DEFB  $0E, $2C, $11, $2C, $14, $17, $19, $1C
                DEFB  $2C, $00, $00, $00, $2C, $0C, $2C, $0D
                DEFB  $00, $2C, $00, $2C, $0C, $0D, $0F, $00
                DEFB  $2C, $0C, $00, $0D, $2C, $00, $2C, $00
                DEFB  $00, $2C, $00, $2C, $00, $00, $11, $00
                DEFB  $2C, $0F, $2C, $00, $0F, $00, $13, $19
                DEFB  $44, $00, $1C, $00, $19, $00, $17, $00
                DEFB  $00, $22, $1C, $00, $11, $13, $00, $19
                DEFB  $13, $00, $12, $00, $11, $00, $0F, $00
                DEFB  $2C, $11, $13, $00, $2C, $00, $2C, $1C
                DEFB  $4C, $00, $20, $00, $1C, $00, $19, $00
                DEFB  $00, $2C, $20, $2C, $13, $15, $00, $1C
                DEFB  $15, $00, $14, $00, $13, $00, $11, $00
                DEFB  $2C, $B4, $5B, $B4, $2C, $B4, $2C, $B4
                DEFB  $22, $1E, $1C, $1E, $5B, $2D, $5B, $5B
                DEFB  $B4, $2C, $B4, $2C, $5B, $B4, $B4, $5B
                DEFB  $2D, $5B, $5B, $2D, $5B, $5B, $2D, $5B
                DEFB  $2C, $90, $48, $90, $2C, $48, $2C, $90
                DEFB  $48, $48, $24, $48, $48, $24, $48, $48
                DEFB  $48, $2C, $90, $2C, $90, $90, $48, $90
                DEFB  $24, $48, $48, $24, $48, $48, $24, $48
                DEFB  $2C, $00, $00, $0D, $2C, $00, $2C, $00
                DEFB  $2C, $0D, $0F, $00, $2C, $00, $2C, $17
                DEFB  $3D, $00, $19, $00, $17, $00, $14, $00
                DEFB  $00, $2C, $19, $2C, $0F, $11, $00, $17
                DEFB  $11, $00, $10, $00, $0F, $00, $0D, $00
                DEFB  $2C, $00, $00, $88, $00, $00, $88, $00
                DEFB  $44, $00, $00, $44, $00, $00, $22, $00
                DEFB  $00, $88, $00, $00, $00, $00, $00, $00
                DEFB  $00, $44, $00, $00, $00, $00, $00, $00

;---------------------
; SONG 3 : Root Beer Rag
;---------------------
musicData3: 	     
                DEFW  $073A               ; Initial tempo
                DEFW  md3 - 8        ; Ptr to start of pattern data - 8
                DEFB  $FF                 ; Tempo change
                DEFW  $0C06               ; New tempo value
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $01
                DEFB  $02
                DEFB  $09
                DEFB  $04
                DEFB  $0A
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $01
                DEFB  $02
                DEFB  $09
                DEFB  $04
                DEFB  $0A
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $25
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $21
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $20
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $20
                DEFB  $00                 ; End of song

md3:
                DEFB  $88, $00, $00, $00, $00, $00, $00, $00
                DEFB  $22, $44, $2D, $22, $44, $2D, $22, $44
                DEFB  $48, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2D, $22, $44, $2D, $22, $44, $2D, $22
                DEFB  $51, $00, $00, $00, $00, $00, $00, $00
                DEFB  $22, $44, $33, $22, $44, $33, $22, $44
                DEFB  $66, $00, $00, $00, $00, $00, $00, $00
                DEFB  $33, $22, $44, $33, $22, $44, $33, $22
                DEFB  $90, $00, $00, $00, $00, $00, $00, $00
                DEFB  $A1, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $00, $3D, $00, $3D, $36, $2C, $2C
                DEFB  $00, $44, $2D, $44, $2D, $2D, $00, $44
                DEFB  $2C, $00, $3D, $00, $3D, $36, $44, $40
                DEFB  $2D, $44, $2D, $44, $2D, $2D, $00, $00
                DEFB  $2C, $00, $26, $00, $26, $00, $2C, $2C
                DEFB  $33, $00, $1E, $00, $1E, $00, $1E, $00
                DEFB  $2C, $00, $00, $00, $44, $00, $00, $00
                DEFB  $22, $2D, $33, $00, $33, $00, $00, $00
                DEFB  $2C, $00, $3D, $00, $3D, $00, $2C, $2C
                DEFB  $33, $00, $33, $00, $33, $00, $33, $00
                DEFB  $2C, $00, $00, $00, $3D, $00, $00, $00
                DEFB  $3D, $51, $5B, $00, $5B, $00, $00, $00
                DEFB  $2C, $00, $00, $00, $22, $00, $00, $00
                DEFB  $22, $2D, $33, $00, $33, $00, $00, $28
                DEFB  $2C, $00, $00, $00, $60, $00, $00, $00
                DEFB  $00, $2B, $28, $24, $1E, $22, $24, $28
                DEFB  $2C, $00, $00, $00, $51, $00, $00, $00
                DEFB  $2D, $30, $2D, $2B, $28, $2D, $33, $36
                DEFB  $2C, $00, $00, $00, $5B, $00, $00, $00
                DEFB  $3D, $40, $3D, $36, $2D, $33, $36, $3D
                DEFB  $2C, $00, $5B, $00, $88, $00, $00, $00
                DEFB  $44, $00, $00, $00, $00, $00, $00, $00
                DEFB  $5B, $00, $51, $00, $4C, $00, $48, $00
                DEFB  $48, $00, $44, $00, $40, $00, $3D, $00
                DEFB  $44, $00, $48, $00, $5B, $00, $6C, $00
                DEFB  $36, $00, $3D, $00, $48, $00, $5B, $00
                DEFB  $44, $00, $3D, $00, $39, $00, $36, $00
                DEFB  $36, $00, $33, $00, $30, $00, $2D, $00
                DEFB  $33, $00, $36, $00, $33, $00, $36, $00
                DEFB  $28, $00, $2D, $00, $28, $00, $2D, $00
                DEFB  $66, $00, $6C, $00, $00, $00, $66, $00
                DEFB  $51, $00, $5B, $00, $00, $00, $44, $00
                DEFB  $6C, $00, $00, $00, $00, $00, $00, $00
                DEFB  $B4, $5B, $A1, $51, $97, $4C, $90, $48
                DEFB  $00, $48, $00, $44, $00, $40, $00, $3D
                DEFB  $88, $44, $90, $48, $B4, $5B, $6C, $6C
                DEFB  $00, $36, $00, $3D, $00, $48, $00, $5B
                DEFB  $88, $44, $79, $3D, $72, $39, $6C, $36
                DEFB  $00, $36, $00, $33, $00, $30, $00, $2D
                DEFB  $66, $33, $6C, $36, $66, $33, $6C, $36
                DEFB  $00, $28, $00, $2D, $00, $28, $00, $2D
                DEFB  $66, $00, $00, $00, $60, $00, $00, $00
                DEFB  $00, $28, $44, $51, $28, $30, $44, $51
                DEFB  $5B, $00, $00, $40, $51, $40, $00, $00
                DEFB  $2D, $44, $5B, $28, $00, $28, $00, $00
                DEFB  $79, $00, $00, $00, $5B, $00, $00, $00
                DEFB  $36, $44, $36, $44, $36, $44, $3D, $00
                DEFB  $88, $00, $5B, $00, $88, $00, $00, $00

;----------------------------------
; Song 4 - MusicStudio Box demo theme
; --------------------------------------
musicData4:
                DEFW  $0C06               ; Initial tempo
                DEFW  md4 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $02
                DEFB  $06
                DEFB  $04
                DEFB  $07
                DEFB  $02
                DEFB  $08
                DEFB  $04
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $04
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
                DEFB  $13
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $14
                DEFB  $02
                DEFB  $15
                DEFB  $04
                DEFB  $14
                DEFB  $02
                DEFB  $16
                DEFB  $04
                DEFB  $17
                DEFB  $02
                DEFB  $17
                DEFB  $04
                DEFB  $17
                DEFB  $02
                DEFB  $17
                DEFB  $04
                DEFB  $18
                DEFB  $02
                DEFB  $19
                DEFB  $04
                DEFB  $1A
                DEFB  $02
                DEFB  $19
                DEFB  $04
                DEFB  $1B
                DEFB  $02
                DEFB  $1C
                DEFB  $04
                DEFB  $1D
                DEFB  $1E
                DEFB  $1F
                DEFB  $0C
                DEFB  $00                 ; End of song

md4:
                DEFB  $39, $56, $00, $56, $00, $00, $56, $00
                DEFB  $00, $AB, $00, $AB, $AB, $AB, $00, $AB
                DEFB  $00, $48, $00, $00, $40, $00, $39, $00
                DEFB  $90, $90, $00, $90, $80, $80, $00, $80
                DEFB  $00, $56, $00, $00, $56, $00, $56, $00
                DEFB  $00, $48, $00, $00, $56, $00, $60, $5B
                DEFB  $00, $40, $00, $00, $40, $00, $39, $00
                DEFB  $00, $56, $00, $00, $56, $00, $60, $5B
                DEFB  $00, $39, $00, $00, $39, $00, $39, $00
                DEFB  $00, $40, $00, $00, $48, $56, $60, $56
                DEFB  $00, $2C, $00, $2C, $AB, $AB, $2C, $AB
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $90, $00, $2C, $80, $80, $2C, $80
                DEFB  $00, $2C, $00, $AB, $2C, $AB, $00, $2C
                DEFB  $90, $2C, $2C, $90, $2C, $2C, $2C, $2C
                DEFB  $56, $AB, $56, $AB, $AB, $AB, $48, $AB
                DEFB  $00, $60, $00, $60, $56, $60, $00, $00
                DEFB  $90, $90, $56, $90, $80, $80, $00, $80
                DEFB  $56, $60, $00, $60, $56, $60, $00, $00
                DEFB  $39, $40, $39, $40, $39, $40, $48, $00
                DEFB  $40, $48, $56, $60, $56, $48, $40, $00
                DEFB  $60, $56, $56, $60, $56, $60, $56, $00
                DEFB  $60, $5B, $56, $56, $00, $56, $56, $00
                DEFB  $60, $5B, $1C, $20, $2B, $30, $2B, $30
                DEFB  $2B, $20, $1C, $20, $2B, $30, $2B, $30
                DEFB  $30, $30, $1C, $20, $2B, $30, $2B, $30
                DEFB  $30, $30, $00, $2B, $2B, $00, $2B, $2B
                DEFB  $00, $00, $24, $00, $00, $24, $00, $00
                DEFB  $24, $00, $00, $2C, $AB, $2C, $00, $2C
                DEFB  $00, $AB, $00, $00, $00, $00, $00, $00
                DEFB  $90, $2C, $00, $2C, $2C, $80, $2C, $2C


;----------------------------
; SONG 5 - My Beep Song
;-----------------------------
musicData5:
                DEFW  $1F36               ; Initial tempo
                DEFW  md5 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $08
                DEFB  $04
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $04
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $04
                DEFB  $0B
                DEFB  $06
                DEFB  $0C
                DEFB  $04
                DEFB  $0B
                DEFB  $06
                DEFB  $0D
                DEFB  $04
                DEFB  $09
                DEFB  $0E
                DEFB  $0A
                DEFB  $0F
                DEFB  $09
                DEFB  $10
                DEFB  $0A
                DEFB  $11
                DEFB  $0B
                DEFB  $12
                DEFB  $0C
                DEFB  $13
                DEFB  $0B
                DEFB  $14
                DEFB  $0D
                DEFB  $15
                DEFB  $09
                DEFB  $0E
                DEFB  $0A
                DEFB  $0F
                DEFB  $09
                DEFB  $10
                DEFB  $0A
                DEFB  $11
                DEFB  $0B
                DEFB  $12
                DEFB  $0C
                DEFB  $13
                DEFB  $0B
                DEFB  $14
                DEFB  $0D
                DEFB  $15
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $1A
                DEFB  $16
                DEFB  $1B
                DEFB  $1C
                DEFB  $1D
                DEFB  $16
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $04
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $04
                DEFB  $0B
                DEFB  $06
                DEFB  $0C
                DEFB  $04
                DEFB  $0B
                DEFB  $06
                DEFB  $0D
                DEFB  $04
                DEFB  $09
                DEFB  $0E
                DEFB  $0A
                DEFB  $0F
                DEFB  $09
                DEFB  $10
                DEFB  $0A
                DEFB  $11
                DEFB  $0B
                DEFB  $12
                DEFB  $0C
                DEFB  $13
                DEFB  $0B
                DEFB  $14
                DEFB  $0D
                DEFB  $15
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $00                 ; End of song

md5:
                DEFB  $51, $36, $28, $36, $51, $36, $24, $36
                DEFB  $A1, $00, $00, $00, $00, $00, $00, $00
                DEFB  $51, $36, $22, $36, $51, $36, $24, $36
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $5B, $36, $28, $36, $5B, $36, $24, $36
                DEFB  $B4, $00, $00, $00, $00, $00, $00, $00
                DEFB  $5B, $36, $22, $36, $5B, $36, $1E, $36
                DEFB  $5B, $36, $22, $36, $5B, $36, $1B, $36
                DEFB  $51, $36, $28, $2C, $51, $36, $24, $36
                DEFB  $51, $36, $22, $2C, $51, $36, $24, $36
                DEFB  $5B, $36, $28, $2C, $5B, $36, $24, $36
                DEFB  $5B, $36, $22, $2C, $5B, $36, $1E, $36
                DEFB  $5B, $36, $22, $2C, $5B, $2C, $1B, $36
                DEFB  $A1, $00, $1E, $1B, $A1, $00, $11, $1B
                DEFB  $A1, $00, $00, $00, $11, $12, $17, $1B
                DEFB  $A1, $00, $1B, $17, $A1, $00, $11, $12
                DEFB  $A1, $00, $00, $17, $00, $1E, $00, $00
                DEFB  $B4, $00, $11, $12, $B4, $00, $17, $1B
                DEFB  $B4, $00, $00, $00, $24, $28, $2D, $36
                DEFB  $B4, $00, $11, $12, $B4, $00, $1B, $1E
                DEFB  $B4, $00, $11, $00, $24, $28, $2D, $28
                DEFB  $2C, $36, $28, $2C, $2C, $36, $24, $2C
                DEFB  $1B, $00, $00, $00, $00, $00, $00, $17
                DEFB  $2C, $36, $22, $2C, $2C, $36, $24, $36
                DEFB  $1E, $00, $00, $00, $22, $00, $00, $00
                DEFB  $11, $00, $00, $00, $12, $00, $00, $00
                DEFB  $1E, $00, $00, $00, $00, $00, $00, $1B
                DEFB  $2C, $36, $22, $2C, $2C, $36, $1E, $36
                DEFB  $1E, $00, $00, $00, $24, $00, $00, $00
                DEFB  $1E, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $36, $22, $2C, $2C, $36, $2C, $36
                DEFB  $2D, $28, $24, $1E, $1B, $17, $12, $11
;------------------------------
;SONG 6 : ROLLS AND BALLS
;---------------------------------
musicData6:
              DEFW  $0E6C               ; Initial tempo
                DEFW  md6 - 8        ; Ptr to start of pattern data - 8
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
                DEFB  $05
                DEFB  $04
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $06
                DEFB  $0A
                DEFB  $08
                DEFB  $09
                DEFB  $06
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $01
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $01
                DEFB  $11
                DEFB  $0F
                DEFB  $12
                DEFB  $01
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $01
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $06
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $16
                DEFB  $1D
                DEFB  $18
                DEFB  $1E
                DEFB  $FF                 ; Tempo change
                DEFW  $073A               ; New tempo value
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $25
                DEFB  $26
                DEFB  $FF                 ; Tempo change
                DEFW  $0E6C               ; New tempo value
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $27
                DEFB  $33
                DEFB  $29
                DEFB  $34
                DEFB  $2B
                DEFB  $35
                DEFB  $2D
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $3F
                DEFB  $40
                DEFB  $41
                DEFB  $42
                DEFB  $43
                DEFB  $44
                DEFB  $45
                DEFB  $46
                DEFB  $47
                DEFB  $48
                DEFB  $49
                DEFB  $4A
                DEFB  $4B
                DEFB  $3C
                DEFB  $4C
                DEFB  $3E
                DEFB  $4D
                DEFB  $40
                DEFB  $4E
                DEFB  $42
                DEFB  $4F
                DEFB  $44
                DEFB  $50
                DEFB  $46
                DEFB  $51
                DEFB  $48
                DEFB  $52
                DEFB  $4A
                DEFB  $FF                 ; Tempo change
                DEFW  $073A               ; New tempo value
                DEFB  $53
                DEFB  $54
                DEFB  $55
                DEFB  $56
                DEFB  $57
                DEFB  $58
                DEFB  $59
                DEFB  $5A
                DEFB  $5B
                DEFB  $5C
                DEFB  $5D
                DEFB  $5E
                DEFB  $5F
                DEFB  $60
                DEFB  $61
                DEFB  $62
                DEFB  $63
                DEFB  $64
                DEFB  $65
                DEFB  $66
                DEFB  $67
                DEFB  $68
                DEFB  $69
                DEFB  $6A
                DEFB  $6B
                DEFB  $6C
                DEFB  $6D
                DEFB  $6E
                DEFB  $6F
                DEFB  $70
                DEFB  $71
                DEFB  $72
                DEFB  $53
                DEFB  $54
                DEFB  $55
                DEFB  $56
                DEFB  $57
                DEFB  $58
                DEFB  $59
                DEFB  $5A
                DEFB  $5B
                DEFB  $5C
                DEFB  $5D
                DEFB  $5E
                DEFB  $5F
                DEFB  $60
                DEFB  $61
                DEFB  $62
                DEFB  $63
                DEFB  $64
                DEFB  $65
                DEFB  $66
                DEFB  $67
                DEFB  $68
                DEFB  $69
                DEFB  $6A
                DEFB  $6B
                DEFB  $6C
                DEFB  $6D
                DEFB  $6E
                DEFB  $6F
                DEFB  $70
                DEFB  $71
                DEFB  $72
                DEFB  $FF                 ; Tempo change
                DEFW  $0E6C               ; New tempo value
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
                DEFB  $05
                DEFB  $04
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $06
                DEFB  $0A
                DEFB  $08
                DEFB  $09
                DEFB  $06
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $01
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $01
                DEFB  $11
                DEFB  $0F
                DEFB  $12
                DEFB  $01
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $01
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $06
                DEFB  $1A
                DEFB  $1B
                DEFB  $1C
                DEFB  $16
                DEFB  $1D
                DEFB  $18
                DEFB  $1E
                DEFB  $FF                 ; Tempo change
                DEFW  $073A               ; New tempo value
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $25
                DEFB  $26
                DEFB  $FF                 ; Tempo change
                DEFW  $219C               ; New tempo value
                DEFB  $73
                DEFB  $74
                DEFB  $75
                DEFB  $75
                DEFB  $75
                DEFB  $75
                DEFB  $75
                DEFB  $75
                DEFB  $00                 ; End of song

md6:
                DEFB  $2C, $00, $79, $2C, $3D, $00, $2C, $00
                DEFB  $51, $00, $00, $51, $00, $00, $51, $00
                DEFB  $5B, $00, $2C, $00, $51, $00, $48, $00
                DEFB  $00, $00, $5B, $00, $79, $00, $60, $00
                DEFB  $5B, $00, $2C, $00, $51, $00, $2C, $00
                DEFB  $2C, $00, $88, $2C, $44, $00, $2C, $00
                DEFB  $5B, $00, $00, $5B, $00, $00, $5B, $00
                DEFB  $66, $00, $2C, $00, $66, $00, $2C, $00
                DEFB  $4C, $00, $51, $00, $4C, $00, $44, $00
                DEFB  $5B, $00, $00, $5B, $00, $5B, $4C, $51
                DEFB  $5B, $00, $00, $5B, $00, $4C, $51, $4C
                DEFB  $66, $00, $2C, $2C, $66, $00, $66, $00
                DEFB  $44, $00, $4C, $00, $51, $00, $33, $00
                DEFB  $51, $00, $28, $51, $00, $22, $1E, $00
                DEFB  $5B, $00, $2C, $00, $88, $00, $44, $00
                DEFB  $24, $00, $28, $00, $2D, $00, $28, $00
                DEFB  $30, $00, $00, $30, $00, $30, $2D, $00
                DEFB  $28, $00, $24, $00, $22, $00, $1E, $00
                DEFB  $3D, $00, $3D, $51, $00, $28, $1E, $18
                DEFB  $88, $00, $2C, $00, $5B, $00, $2C, $00
                DEFB  $17, $18, $1E, $00, $17, $18, $22, $00
                DEFB  $2C, $00, $97, $2C, $4C, $00, $2C, $00
                DEFB  $33, $36, $33, $3D, $00, $00, $28, $00
                DEFB  $97, $00, $2C, $00, $97, $00, $2C, $00
                DEFB  $00, $00, $1E, $00, $1E, $28, $33, $00
                DEFB  $2D, $00, $00, $00, $00, $00, $36, $00
                DEFB  $88, $00, $2C, $00, $88, $00, $2C, $00
                DEFB  $00, $00, $00, $00, $33, $00, $36, $33
                DEFB  $28, $2D, $28, $1E, $00, $00, $19, $00
                DEFB  $1B, $00, $22, $28, $00, $2D, $36, $00
                DEFB  $79, $00, $00, $00, $79, $00, $00, $00
                DEFB  $51, $00, $00, $00, $00, $00, $51, $00
                DEFB  $2C, $00, $2C, $00, $79, $00, $00, $00
                DEFB  $00, $00, $00, $00, $51, $00, $00, $00
                DEFB  $5B, $00, $00, $00, $2C, $00, $2C, $00
                DEFB  $00, $00, $00, $00, $5B, $00, $00, $00
                DEFB  $51, $00, $00, $00, $48, $00, $00, $00
                DEFB  $79, $00, $00, $00, $60, $00, $00, $00
                DEFB  $2C, $97, $4C, $97, $00, $2C, $00, $97
                DEFB  $19, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $80, $56, $56, $2C, $97, $4C, $97
                DEFB  $1C, $20, $1C, $20, $19, $26, $2B, $66
                DEFB  $00, $2C, $00, $97, $2C, $80, $A1, $2C
                DEFB  $00, $66, $00, $66, $2B, $56, $36, $6C
                DEFB  $2C, $2C, $56, $2C, $00, $2C, $00, $2C
                DEFB  $39, $00, $00, $40, $00, $00, $39, $00
                DEFB  $2C, $2C, $60, $C0, $2C, $2C, $56, $2C
                DEFB  $00, $48, $4C, $60, $72, $00, $00, $00
                DEFB  $00, $2C, $00, $2C, $2C, $90, $60, $C0
                DEFB  $00, $00, $00, $72, $6C, $6C, $40, $80
                DEFB  $33, $00, $00, $26, $00, $00, $20, $00
                DEFB  $22, $2B, $39, $40, $33, $00, $00, $00
                DEFB  $00, $00, $00, $66, $2B, $56, $36, $6C
                DEFB  $2B, $39, $00, $2B, $30, $00, $39, $24
                DEFB  $2C, $2C, $60, $C0, $AB, $2C, $2C, $AB
                DEFB  $00, $39, $24, $39, $26, $30, $39, $2B
                DEFB  $00, $AB, $00, $2C, $2C, $90, $60, $C0
                DEFB  $00, $39, $26, $30, $39, $2B, $40, $80
                DEFB  $AB, $2C, $97, $2C, $6C, $72, $2C, $AB
                DEFB  $72, $66, $66, $72, $48, $4C, $00, $72
                DEFB  $97, $2C, $97, $2C, $72, $2C, $AB, $2C
                DEFB  $66, $56, $66, $48, $4C, $00, $72, $6C
                DEFB  $97, $AB, $2C, $80, $72, $2C, $00, $2C
                DEFB  $66, $72, $66, $56, $4C, $56, $00, $4C
                DEFB  $00, $2C, $2C, $2C, $00, $2C, $C0, $2C
                DEFB  $00, $6C, $72, $79, $00, $79, $80, $88
                DEFB  $97, $2C, $80, $2C, $97, $72, $2C, $97
                DEFB  $66, $72, $56, $72, $66, $4C, $72, $66
                DEFB  $6C, $2C, $72, $2C, $72, $2C, $00, $2C
                DEFB  $48, $00, $4C, $56, $4C, $66, $00, $72
                DEFB  $97, $80, $2C, $97, $66, $2C, $97, $2C
                DEFB  $66, $56, $72, $66, $44, $72, $66, $39
                DEFB  $5B, $2C, $2C, $2C, $72, $80, $00, $00
                DEFB  $3D, $72, $66, $3D, $4C, $56, $00, $00
                DEFB  $2C, $97, $97, $AB, $6C, $72, $00, $2C
                DEFB  $2C, $80, $97, $6C, $72, $00, $AB, $2C
                DEFB  $2C, $AB, $97, $80, $72, $80, $00, $72
                DEFB  $2C, $2C, $2C, $2C, $00, $2C, $C0, $B4
                DEFB  $2C, $AB, $80, $AB, $97, $72, $AB, $97
                DEFB  $2C, $00, $72, $80, $72, $97, $00, $AB
                DEFB  $2C, $80, $AB, $97, $66, $2C, $97, $2C
                DEFB  $2C, $AB, $97, $2C, $72, $80, $00, $00
                DEFB  $2C, $00, $97, $00, $97, $00, $AB, $00
                DEFB  $13, $15, $19, $1B, $1C, $20, $26, $2B
                DEFB  $6C, $00, $72, $00, $00, $00, $2C, $00
                DEFB  $10, $13, $14, $15, $19, $1B, $1C, $20
                DEFB  $2C, $00, $80, $00, $97, $00, $6C, $00
                DEFB  $0D, $0E, $0F, $10, $13, $14, $15, $19
                DEFB  $72, $00, $00, $00, $AB, $00, $2C, $00
                DEFB  $0D, $00, $0E, $00, $10, $00, $0E, $00
                DEFB  $2C, $00, $AB, $00, $97, $00, $80, $00
                DEFB  $20, $00, $26, $00, $20, $00, $19, $00
                DEFB  $72, $00, $80, $00, $00, $00, $72, $00
                DEFB  $20, $00, $19, $00, $15, $00, $19, $00
                DEFB  $2C, $00, $2C, $00, $2C, $00, $2C, $00
                DEFB  $15, $00, $10, $00, $22, $00, $00, $00
                DEFB  $00, $00, $B4, $00, $C0, $00, $B4, $00
                DEFB  $20, $00, $22, $00, $2B, $00, $33, $00
                DEFB  $2C, $00, $AB, $00, $80, $00, $AB, $00
                DEFB  $26, $28, $2B, $33, $2B, $00, $39, $00
                DEFB  $97, $00, $72, $00, $AB, $00, $97, $00
                DEFB  $33, $00, $26, $22, $20, $1E, $19, $15
                DEFB  $2C, $00, $00, $00, $72, $00, $80, $00
                DEFB  $12, $24, $00, $00, $13, $26, $20, $40
                DEFB  $72, $00, $97, $00, $00, $00, $AB, $00
                DEFB  $1C, $39, $13, $26, $00, $00, $15, $2B
                DEFB  $2C, $00, $80, $00, $AB, $00, $97, $00
                DEFB  $26, $28, $2B, $33, $36, $39, $40, $4C
                DEFB  $66, $00, $2C, $00, $97, $00, $2C, $00
                DEFB  $4C, $00, $4C, $00, $4C, $00, $39, $00
                DEFB  $2C, $00, $AB, $00, $97, $00, $2C, $00
                DEFB  $3D, $00, $39, $00, $66, $00, $80, $00
                DEFB  $72, $00, $80, $00, $00, $00, $00, $00
                DEFB  $40, $00, $56, $00, $00, $00, $00, $00
                DEFB  $2C, $2C, $00, $00, $00, $00, $00, $79
                DEFB  $60, $00, $00, $00, $00, $00, $00, $3D
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00

;-------------------------
;SONG 7 : TSEREBRALNOE NARUSHENIE
;--------------------------
musicData7:
                DEFW  $09A0               ; Initial tempo
                DEFW  md7 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $03
                DEFB  $01
                DEFB  $02
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $03
                DEFB  $01
                DEFB  $02
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $0D
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0E
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
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $0B
                DEFB  $1C
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $1D
                DEFB  $18
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $0E
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
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $0B
                DEFB  $1C
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $1D
                DEFB  $18
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $23
                DEFB  $22
                DEFB  $24
                DEFB  $25
                DEFB  $24
                DEFB  $26
                DEFB  $24
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $24
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $36
                DEFB  $2C
                DEFB  $37
                DEFB  $2E
                DEFB  $38
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $32
                DEFB  $35
                DEFB  $24
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $24
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $36
                DEFB  $2C
                DEFB  $37
                DEFB  $2E
                DEFB  $38
                DEFB  $FF                 ; Tempo change
                DEFW  $0E6C               ; New tempo value
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3C
                DEFB  $39
                DEFB  $3D
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3C
                DEFB  $39
                DEFB  $3E
                DEFB  $3F
                DEFB  $40
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3C
                DEFB  $39
                DEFB  $3D
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3C
                DEFB  $39
                DEFB  $3E
                DEFB  $3F
                DEFB  $40
                DEFB  $FF                 ; Tempo change
                DEFW  $09A0               ; New tempo value
                DEFB  $41
                DEFB  $42
                DEFB  $43
                DEFB  $42
                DEFB  $41
                DEFB  $42
                DEFB  $43
                DEFB  $42
                DEFB  $41
                DEFB  $42
                DEFB  $43
                DEFB  $42
                DEFB  $FF                 ; Tempo change
                DEFW  $04D4               ; New tempo value
                DEFB  $42
                DEFB  $42
                DEFB  $42
                DEFB  $42
                DEFB  $42
                DEFB  $42
                DEFB  $42
                DEFB  $42
                DEFB  $FF                 ; Tempo change
                DEFW  $09A0               ; New tempo value
                DEFB  $24
                DEFB  $25
                DEFB  $24
                DEFB  $26
                DEFB  $24
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $24
                DEFB  $27
                DEFB  $28
                DEFB  $29
                DEFB  $2A
                DEFB  $36
                DEFB  $2C
                DEFB  $37
                DEFB  $2E
                DEFB  $38
                DEFB  $30
                DEFB  $31
                DEFB  $44
                DEFB  $25
                DEFB  $45
                DEFB  $26
                DEFB  $46
                DEFB  $27
                DEFB  $47
                DEFB  $29
                DEFB  $48
                DEFB  $2B
                DEFB  $49
                DEFB  $2D
                DEFB  $4A
                DEFB  $2F
                DEFB  $4B
                DEFB  $31
                DEFB  $4C
                DEFB  $25
                DEFB  $4D
                DEFB  $26
                DEFB  $46
                DEFB  $27
                DEFB  $47
                DEFB  $29
                DEFB  $48
                DEFB  $2B
                DEFB  $49
                DEFB  $2D
                DEFB  $4A
                DEFB  $2F
                DEFB  $4B
                DEFB  $31
                DEFB  $FF                 ; Tempo change
                DEFW  $3000               ; New tempo value
                DEFB  $4E
                DEFB  $4F
                DEFB  $FF                 ; Tempo change
                DEFW  $10D2               ; New tempo value
                DEFB  $42
                DEFB  $42
                DEFB  $42
                DEFB  $42
                DEFB  $00                 ; End of song

md7:
                DEFB  $B4, $B4, $00, $00, $B4, $B4, $B4, $B4
                DEFB  $B4, $00, $00, $00, $B4, $00, $B4, $00
                DEFB  $00, $00, $00, $00, $00, $00, $B4, $00
                DEFB  $00, $00, $00, $00, $B4, $B4, $B4, $B4
                DEFB  $00, $00, $00, $00, $B4, $00, $B4, $00
                DEFB  $97, $97, $00, $00, $97, $97, $97, $97
                DEFB  $97, $00, $00, $00, $97, $00, $97, $00
                DEFB  $00, $00, $00, $00, $00, $00, $97, $00
                DEFB  $88, $88, $00, $00, $88, $88, $88, $88
                DEFB  $88, $00, $00, $00, $88, $00, $88, $00
                DEFB  $88, $88, $80, $80, $88, $88, $80, $80
                DEFB  $88, $00, $80, $00, $88, $00, $80, $00
                DEFB  $00, $00, $00, $00, $00, $00, $97, $97
                DEFB  $B4, $B4, $3D, $2D, $B4, $B4, $B4, $B4
                DEFB  $B4, $5B, $5B, $5B, $B4, $5B, $B4, $5B
                DEFB  $5B, $5B, $3D, $5B, $3D, $2D, $B4, $28
                DEFB  $1E, $1E, $22, $1E, $5B, $5B, $26, $5B
                DEFB  $B4, $B4, $2D, $5B, $B4, $B4, $B4, $B4
                DEFB  $B4, $5B, $5B, $00, $B4, $5B, $B4, $5B
                DEFB  $00, $00, $3D, $2D, $B4, $26, $B4, $22
                DEFB  $5B, $5B, $5B, $5B, $B4, $5B, $B4, $5B
                DEFB  $97, $97, $1E, $22, $97, $97, $97, $97
                DEFB  $97, $4C, $4C, $4C, $97, $4C, $97, $4C
                DEFB  $1E, $22, $3D, $1E, $3D, $28, $97, $26
                DEFB  $4C, $4C, $4C, $4C, $4C, $4C, $97, $4C
                DEFB  $88, $88, $44, $26, $88, $88, $88, $88
                DEFB  $88, $44, $22, $44, $88, $44, $88, $44
                DEFB  $88, $44, $40, $40, $88, $40, $40, $40
                DEFB  $97, $66, $66, $66, $97, $66, $97, $66
                DEFB  $66, $66, $66, $66, $66, $66, $97, $66
                DEFB  $88, $88, $44, $88, $88, $88, $88, $88
                DEFB  $88, $44, $00, $44, $88, $44, $00, $44
                DEFB  $88, $88, $80, $80, $19, $88, $1E, $80
                DEFB  $00, $00, $1E, $1C, $00, $1C, $00, $22
                DEFB  $88, $40, $3D, $39, $36, $33, $30, $2D
                DEFB  $2C, $B4, $79, $79, $B4, $B4, $79, $79
                DEFB  $B4, $3D, $79, $3D, $79, $3D, $1E, $22
                DEFB  $79, $3D, $79, $3D, $79, $3D, $22, $26
                DEFB  $79, $3D, $79, $3D, $79, $3D, $26, $28
                DEFB  $2C, $B4, $79, $79, $B4, $B4, $79, $2C
                DEFB  $79, $3D, $79, $3D, $79, $3D, $28, $79
                DEFB  $2C, $97, $66, $66, $97, $97, $66, $66
                DEFB  $3D, $3D, $66, $3D, $66, $3D, $28, $26
                DEFB  $2C, $97, $72, $72, $97, $97, $72, $72
                DEFB  $6C, $72, $3D, $72, $3D, $72, $26, $22
                DEFB  $2C, $79, $3D, $3D, $79, $79, $3D, $3D
                DEFB  $00, $3D, $79, $3D, $79, $3D, $1E, $1C
                DEFB  $2C, $79, $3D, $3D, $79, $79, $33, $3D
                DEFB  $79, $33, $79, $33, $79, $1E, $79, $28
                DEFB  $2C, $B4, $79, $79, $B4, $2D, $79, $79
                DEFB  $B4, $3D, $2D, $3D, $79, $3D, $1E, $22
                DEFB  $2C, $B4, $79, $79, $B4, $B4, $2D, $79
                DEFB  $79, $3D, $79, $2D, $79, $3D, $22, $26
                DEFB  $3D, $33, $66, $33, $66, $33, $28, $26
                DEFB  $6C, $72, $2D, $72, $2D, $72, $26, $22
                DEFB  $00, $5B, $79, $5B, $79, $5B, $1E, $1C
                DEFB  $6C, $6C, $36, $2D, $6C, $6C, $36, $2D
                DEFB  $00, $1E, $24, $24, $24, $24, $24, $1E
                DEFB  $6C, $6C, $36, $2D, $66, $66, $66, $66
                DEFB  $1E, $1E, $28, $28, $28, $2D, $28, $28
                DEFB  $24, $24, $24, $24, $28, $28, $2D, $33
                DEFB  $24, $24, $24, $24, $24, $24, $24, $24
                DEFB  $6C, $6C, $36, $2D, $A1, $A1, $88, $51
                DEFB  $88, $88, $88, $88, $5B, $5B, $5B, $5B
                DEFB  $2C, $00, $2C, $2C, $00, $00, $00, $00
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $00, $00, $2C, $00, $00, $00, $00
                DEFB  $2C, $B4, $2C, $2C, $B4, $B4, $1E, $79
                DEFB  $2C, $B4, $79, $2C, $B4, $B4, $22, $79
                DEFB  $B4, $B4, $79, $2C, $B4, $B4, $2C, $79
                DEFB  $2C, $B4, $2C, $2C, $B4, $B4, $79, $3D
                DEFB  $2C, $97, $66, $66, $97, $97, $2C, $66
                DEFB  $2C, $97, $2C, $2C, $97, $97, $26, $72
                DEFB  $2C, $79, $2C, $2C, $79, $79, $3D, $3D
                DEFB  $2C, $79, $2C, $2C, $79, $79, $33, $3D
                DEFB  $2C, $B4, $79, $79, $B4, $B4, $2C, $79
                DEFB  $2C, $B4, $2C, $2C, $B4, $B4, $22, $79
                DEFB  $6C, $6C, $6C, $6C, $6C, $6C, $00, $2C
                DEFB  $36, $00, $00, $00, $00, $00, $00, $00



end
