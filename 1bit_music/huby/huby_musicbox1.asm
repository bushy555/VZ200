; HUBY-K  ---    HUBY MUSIC BOX #1
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
#define defw .dw
#define db  .db
#define dw  .dw
#define end .end
#define org .org
#define equ .equ
#define DEFB .db
#define DEFW .dw
#define DB  .db
#define DW  .dw
#define END .end
#define ORG .org
#define EQU .EQU

	ORG 	$8000


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
; Mucking around on around the ~15-20 March and finally got two out of a bunch of
; Spectrum, ZX81 and Ti calc players working. Years in the making to work out how
; to simply do it.  ...still learning z80. Was stoked when I got the first one working
; and then doubly stoked getting a second one working on the same day.
;
; Huby 1-bit player. Originally 100 byte player but modified as above. 2 channels.
; ZX-10 1-bit player. A player written for the Ti Calculator. 4 channels.
;
; Theme From Huby Tracker.
; Song #4. From another Player.
; Song #5. From another Player.
; Butterfly Catcher, from Beepola, Song by Shiru.
; Formation from Beepola, Song by Shiru.
; River City, from Beepola, Song by Shiru.
; Streets of Rain, from Beepola, Song by Shiru.
; Money Money Money, from Beepola. Song by Abba of Beatles or Rick Ashley or something.
; Theme From Monkey Magic. Beepola.
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

cls: 	ei
	call 	$01c9		; VZ ROM CLS
	ld 	hl, MSG1	; Print MENU
	call 	$28a7		; VZ ROM Print string.
	ld 	hl, MSG2
	call 	$28a7
	ld 	hl, POSCURSOR	; reposition cursor to show key input 
	call 	$28a7


scan: 	call 	$2ef4		; VZ scan keyboard
	or 	a		; any key pressed?
	jr 	z, scan 	; back if not
				;       Menu selection.  
	cp 	49		; "1 - Huby's THeme"
	jr 	z, m1		;       
	cp 	50		; "2 - Song #4"
	jr 	z, m2
	cp 	51		; "3 - Song #5"
	jr 	z, m3
	cp 	52		; "4 - BUtterfly Catcher"
	jr 	z, m4
	cp 	53		; "5 - Formation"
	jr 	z, m5
	cp 	54		; "6 - River City"
	jr 	z, m6
	cp 	55		; "7 - Street of Rain"
	jr 	z, m7
	cp 	56		; "8 - Money Money Money"
	jr 	z, m8
	cp 	57		; "9 - Monkey Magic"
	jr 	z, m9		

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
m9: 	ld 	hl, D9
	ld 	de,musicData9
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


MSG1 	db	"HUBY MUSICBOX #1.     BUSHY'19", $0d
	db 	$0d,$0d, "PLEASE SELECT:  ", $0d
	db 	"1 HUBY PLAYER THEME     ", $0d
	db 	"2 SONG 4 (ANTEATER)        ", $0d
	db 	"3 SONG 5 (NTROPIC)", $0d
	db 	"4 BUTTERFLY CATCHER ", $0d
	db 	"5 FORMATION      ", $0d
	db 	"6 RIVER CITY     ", $0d,00
MSG2	db 	"7 STREETS OF RAIN ", $0d
 	db	"8 MONEY MONEY MONEY     - MENU", $0d
	db 	"9 MONKEY MAGIC THEME    Q QUIT", $0d
	db 	$0d, ">",00

MSGQUIT db	$08, $08, "QUIT...",$0d,00
PLAYING db	08,08,08,"NOW PLAYING:",0

POSCURSOR db	09,00
D1 	db	"HUBY THEME ",0,0		
D2 	db	"ANTEATER ",0,0			
D3 	db	"NTROPIC ",0,0			
D4 	db	"BUTTERFLY CATCHER",00
D5 	db	"FORMATION",$00
D6 	db	"RIVER CITY",$00
D7 	db	"STREETS OF RAIN",$00
D8 	db	"MONEY MONEY MONEY",$00
D9 	db	"MONKEY MAGIC THEME",$00


;---------------------------------
;Huby Tracker theme
;---------------------------------
musicData1
	dw $0944
	dw PATTDATA1-8
	db $01,$02
	db $03,$04
	db $05,$06
	db $07,$08
	db $09,$0a
	db $0b,$0c
	db $01,$0d
	db $0e,$0f
	db $01,$02
	db $03,$04
	db $05,$06
	db $07,$10
	db $09,$11
	db $0b,$12
	db $05,$13
	db $14,$15
	db $16,$17
	db $18,$19
	db $1a,$17
	db $1b,$1c
	db $1d,$1e
	db $1f,$20
	db $1d,$1e
	db $21,$20
	db $16,$17
	db $18,$1c
	db $1a,$17
	db $1b,$22
	db $23,$24
	db $25,$24
	db $23,$26
	db $27,$28
	db $16,$17
	db $18,$19
	db $1a,$17
	db $1b,$1c
	db $1d,$1e
	db $1f,$20
	db $1d,$1e
	db $21,$20
	db $16,$17
	db $18,$1c
	db $1a,$17
	db $1b,$22
	db $29,$28
	db $2a,$28
	db $29,$2b
	db $2c,$2d
	db $00
PATTDATA1
	db $e2,$00,$e2,$00,$e2,$00,$e2,$00
	db $00,$00,$38,$38,$32,$32,$2c,$2c
	db $2c,$00,$e2,$00,$e2,$00,$e2,$00
	db $38,$38,$38,$38,$3c,$3c,$38,$38
	db $97,$00,$97,$00,$97,$00,$97,$00
	db $38,$38,$3c,$3c,$00,$00,$00,$00
	db $2c,$00,$97,$00,$97,$00,$97,$00
	db $43,$43,$3c,$3c,$00,$00,$4b,$4b
	db $a9,$00,$a9,$00,$a9,$00,$a9,$00
	db $4b,$4b,$54,$54,$4b,$4b,$43,$43
	db $2c,$00,$a9,$00,$a9,$00,$a9,$00
	db $4b,$4b,$4b,$4b,$54,$54,$4b,$4b
	db $4b,$4b,$59,$00,$59,$00,$59,$00
	db $2c,$00,$ca,$00,$b3,$00,$b3,$00
	db $54,$00,$54,$00,$4b,$00,$4b,$00
	db $38,$38,$32,$32,$00,$00,$3c,$3c
	db $3c,$3c,$43,$43,$4b,$4b,$54,$54
	db $65,$65,$59,$59,$00,$00,$4b,$4b
	db $4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b
	db $2c,$00,$97,$00,$2c,$00,$2c,$00
	db $4b,$4b,$4b,$4b,$00,$00,$00,$00
	db $a9,$00,$a9,$a9,$54,$00,$54,$54
	db $43,$43,$38,$38,$32,$32,$43,$43
	db $2c,$00,$a9,$a9,$54,$00,$54,$54
	db $38,$38,$32,$32,$38,$38,$32,$32
	db $97,$00,$97,$97,$4b,$00,$4b,$4b
	db $2c,$00,$97,$97,$2c,$00,$2c,$4b
	db $38,$38,$32,$32,$43,$43,$38,$38
	db $86,$00,$86,$86,$43,$00,$43,$43
	db $3c,$3c,$38,$38,$32,$32,$3c,$3c
	db $2c,$00,$86,$86,$43,$00,$43,$43
	db $38,$38,$32,$32,$3c,$3c,$38,$38
	db $2c,$00,$86,$86,$2c,$00,$2c,$43
	db $38,$38,$32,$32,$43,$43,$3c,$3c
	db $ca,$00,$ca,$ca,$65,$00,$65,$65
	db $43,$00,$43,$00,$43,$00,$43,$00
	db $2c,$00,$ca,$ca,$65,$00,$65,$65
	db $3c,$00,$3c,$00,$3c,$00,$3c,$00
	db $2c,$00,$ca,$ca,$65,$00,$65,$00
	db $38,$00,$38,$00,$38,$00,$38,$00
	db $e2,$00,$e2,$e2,$71,$00,$71,$71
	db $2c,$00,$e2,$e2,$71,$00,$71,$71
	db $38,$38,$38,$38,$38,$38,$38,$38
	db $2c,$e2,$e2,$e2,$e2,$00,$00,$00
	db $38,$38,$38,$38,$38,$00,$00,$00

; -------------------------------
; Song #4. From some other player.
;---------------------------------
musicData2
	dw $0d2a
	dw PATTDATA2-8
	db $01,$02
	db $01,$02
	db $01,$02
	db $03,$02
	db $01,$02
	db $01,$02
	db $01,$02
	db $04,$02
	db $01,$02
	db $01,$02
	db $01,$02
	db $03,$02
	db $01,$02
	db $01,$02
	db $01,$02
	db $04,$02
	db $05,$02
	db $05,$02
	db $05,$02
	db $06,$02
	db $05,$02
	db $05,$02
	db $05,$02
	db $07,$02
	db $01,$02
	db $01,$02
	db $01,$02
	db $03,$02
	db $01,$02
	db $01,$02
	db $01,$02
	db $04,$02
	db $00
PATTDATA2
	db $f0,$f0,$f0,$f0,$78,$78,$78,$78
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $ca,$ca,$ca,$ca,$65,$65,$65,$65
	db $50,$50,$50,$50,$65,$65,$65,$65
	db $b3,$b3,$b3,$b3,$59,$59,$59,$59
	db $97,$97,$97,$97,$4b,$4b,$4b,$4b
	db $00,$00,$00,$00,$86,$86,$86,$86


; ----------------------------
; Song #5. From some other Spectrum or ZX player.
;---------------------------------
musicData3
	dw $0d2a
	dw PATTDATA3-8
	db $01,$02
	db $01,$02
	db $01,$02
	db $03,$02
	db $01,$02
	db $01,$02
	db $01,$02
	db $04,$02
	db $01,$02
	db $01,$02
	db $01,$02
	db $03,$02
	db $01,$02
	db $01,$02
	db $01,$02
	db $04,$02
	db $05,$06
	db $05,$06
	db $05,$06
	db $07,$06
	db $05,$06
	db $05,$06
	db $05,$06
	db $08,$06
	db $01,$02
	db $01,$02
	db $01,$02
	db $03,$02
	db $01,$02
	db $01,$02
	db $01,$02
	db $04,$02
	db $00
PATTDATA3
	db $f0,$f0,$f0,$f0,$78,$78,$78,$78
	db $78,$65,$50,$43,$3c,$32,$28,$21
	db $ca,$ca,$ca,$ca,$65,$65,$65,$65
	db $50,$50,$50,$50,$65,$65,$65,$65
	db $b3,$b3,$b3,$b3,$59,$59,$59,$59
	db $59,$4b,$3c,$32,$2c,$25,$1e,$19
	db $97,$97,$97,$97,$4b,$4b,$4b,$4b
	db $00,$00,$00,$00,$86,$86,$86,$86

;------------------------------------------------
; Butterfly Catcher. From Beepola. By Shiru.
;-----------------------------------------------
musicData4
		DEFW  $10D2		  ; Initial tempo
		DEFW  PATTDATA4 - 8	   ; Ptr to start of pattern data - 8
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
		DEFB  $0A
		DEFB  $0B
		DEFB  $0C
		DEFB  $0D
		DEFB  $01
		DEFB  $02
		DEFB  $0E
		DEFB  $0F
		DEFB  $04
		DEFB  $05
		DEFB  $10
		DEFB  $11
		DEFB  $07
		DEFB  $08
		DEFB  $12
		DEFB  $13
		DEFB  $0A
		DEFB  $0B
		DEFB  $14
		DEFB  $15
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
		DEFB  $20
		DEFB  $21
		DEFB  $14
		DEFB  $1B
		DEFB  $22
		DEFB  $23
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
		DEFB  $20
		DEFB  $21
		DEFB  $14
		DEFB  $17
		DEFB  $24
		DEFB  $25
		DEFB  $24
		DEFB  $26
		DEFB  $27
		DEFB  $28
		DEFB  $24
		DEFB  $29
		DEFB  $2A
		DEFB  $17
		DEFB  $24
		DEFB  $26
		DEFB  $2B
		DEFB  $2C
		DEFB  $24
		DEFB  $26
		DEFB  $2D
		DEFB  $2E
		DEFB  $2F
		DEFB  $26
		DEFB  $30
		DEFB  $28
		DEFB  $31
		DEFB  $29
		DEFB  $32
		DEFB  $17
		DEFB  $33
		DEFB  $26
		DEFB  $34
		DEFB  $2C
		DEFB  $35
		DEFB  $26
		DEFB  $36
		DEFB  $37
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
		DEFB  $20
		DEFB  $21
		DEFB  $14
		DEFB  $1B
		DEFB  $22
		DEFB  $23
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
		DEFB  $20
		DEFB  $21
		DEFB  $14
		DEFB  $17
		DEFB  $24
		DEFB  $25
		DEFB  $00		  ; End of song

PATTDATA4:
		DEFB  $2C, $00, $24, $00, $00, $00, $2C, $00
		DEFB  $2D, $00, $00, $00, $1E, $00, $00, $00
		DEFB  $2C, $00, $24, $00, $00, $00, $24, $00
		DEFB  $2C, $00, $2D, $00, $00, $00, $2C, $00
		DEFB  $36, $00, $00, $00, $24, $00, $00, $00
		DEFB  $2C, $00, $2D, $00, $00, $00, $2D, $00
		DEFB  $2C, $00, $36, $00, $00, $00, $2C, $00
		DEFB  $44, $00, $00, $00, $2D, $00, $00, $00
		DEFB  $2C, $00, $36, $00, $00, $00, $36, $00
		DEFB  $2C, $00, $30, $00, $00, $00, $2C, $00
		DEFB  $3D, $00, $00, $00, $28, $00, $00, $00
		DEFB  $2C, $00, $00, $00, $79, $00, $60, $00
		DEFB  $3D, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $00, $24, $00, $00, $00, $5B, $00
		DEFB  $2D, $00, $00, $00, $1E, $00, $24, $00
		DEFB  $2C, $00, $2D, $00, $00, $00, $6C, $00
		DEFB  $36, $00, $00, $00, $24, $00, $2D, $00
		DEFB  $2C, $00, $36, $00, $00, $00, $88, $00
		DEFB  $44, $00, $00, $00, $2D, $00, $36, $00
		DEFB  $2C, $00, $00, $00, $51, $00, $2C, $00
		DEFB  $3D, $00, $00, $00, $00, $00, $00, $26
		DEFB  $2C, $00, $00, $00, $3D, $00, $2C, $00
		DEFB  $24, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $00, $5B, $00, $48, $00, $5B, $00
		DEFB  $00, $00, $28, $00, $2D, $00, $3D, $00
		DEFB  $2C, $00, $00, $00, $48, $00, $2C, $00
		DEFB  $28, $00, $00, $00, $00, $00, $26, $24
		DEFB  $2C, $00, $6C, $00, $5B, $00, $6C, $00
		DEFB  $00, $00, $00, $00, $2D, $00, $00, $00
		DEFB  $2C, $00, $00, $00, $5B, $00, $2C, $00
		DEFB  $22, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $00, $88, $00, $6C, $00, $88, $00
		DEFB  $00, $00, $24, $00, $28, $00, $36, $00
		DEFB  $2C, $00, $79, $00, $60, $00, $79, $00
		DEFB  $00, $00, $00, $00, $28, $00, $30, $00
		DEFB  $2C, $00, $00, $00, $00, $00, $00, $00
		DEFB  $28, $00, $00, $00, $00, $00, $00, $00
		DEFB  $24, $00, $00, $24, $00, $00, $22, $00
		DEFB  $00, $00, $00, $00, $5B, $00, $2C, $00
		DEFB  $24, $00, $00, $00, $24, $00, $28, $00
		DEFB  $24, $00, $00, $24, $00, $00, $28, $00
		DEFB  $00, $00, $00, $00, $6C, $00, $79, $00
		DEFB  $00, $00, $00, $00, $90, $00, $2C, $00
		DEFB  $24, $00, $00, $00, $2D, $00, $28, $00
		DEFB  $00, $00, $00, $00, $79, $00, $60, $00
		DEFB  $1E, $00, $00, $00, $18, $00, $00, $00
		DEFB  $2C, $00, $5B, $00, $5B, $00, $5B, $00
		DEFB  $5B, $00, $5B, $00, $5B, $00, $2C, $00
		DEFB  $2C, $00, $6C, $00, $6C, $00, $6C, $00
		DEFB  $6C, $00, $2C, $00, $6C, $00, $79, $00
		DEFB  $2C, $00, $88, $00, $88, $00, $88, $00
		DEFB  $88, $00, $88, $00, $90, $00, $2C, $00
		DEFB  $2C, $00, $79, $00, $79, $00, $79, $00
		DEFB  $3D, $00, $00, $00, $79, $00, $2C, $00
		DEFB  $1E, $00, $00, $00, $18, $00, $00, $28

;---------------------------------
; Formation - from Beepola. By Shiru.
;---------------------------------
musicData5
		DEFW  $0C06		  ; Initial tempo
		DEFW  PATTDATA5 - 8	   ; Ptr to start of pattern data - 8
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $02
		DEFB  $01
		DEFB  $04
		DEFB  $05
		DEFB  $04
		DEFB  $01
		DEFB  $06
		DEFB  $03
		DEFB  $06
		DEFB  $01
		DEFB  $07
		DEFB  $03
		DEFB  $07
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $02
		DEFB  $01
		DEFB  $04
		DEFB  $05
		DEFB  $04
		DEFB  $01
		DEFB  $06
		DEFB  $03
		DEFB  $06
		DEFB  $01
		DEFB  $07
		DEFB  $03
		DEFB  $07
		DEFB  $08
		DEFB  $09
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
		DEFB  $14
		DEFB  $0D
		DEFB  $15
		DEFB  $16
		DEFB  $08
		DEFB  $09
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
		DEFB  $14
		DEFB  $0D
		DEFB  $15
		DEFB  $17
		DEFB  $08
		DEFB  $18
		DEFB  $0A
		DEFB  $16
		DEFB  $0C
		DEFB  $19
		DEFB  $0E
		DEFB  $1A
		DEFB  $10
		DEFB  $1B
		DEFB  $12
		DEFB  $16
		DEFB  $14
		DEFB  $1C
		DEFB  $15
		DEFB  $1D
		DEFB  $08
		DEFB  $18
		DEFB  $0A
		DEFB  $16
		DEFB  $0C
		DEFB  $19
		DEFB  $0E
		DEFB  $1A
		DEFB  $10
		DEFB  $1B
		DEFB  $12
		DEFB  $16
		DEFB  $14
		DEFB  $1C
		DEFB  $1E
		DEFB  $1D
		DEFB  $08
		DEFB  $09
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
		DEFB  $14
		DEFB  $0D
		DEFB  $15
		DEFB  $16
		DEFB  $08
		DEFB  $09
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
		DEFB  $14
		DEFB  $0D
		DEFB  $15
		DEFB  $17
		DEFB  $08
		DEFB  $18
		DEFB  $0A
		DEFB  $16
		DEFB  $0C
		DEFB  $19
		DEFB  $0E
		DEFB  $1A
		DEFB  $10
		DEFB  $1B
		DEFB  $12
		DEFB  $16
		DEFB  $14
		DEFB  $1C
		DEFB  $15
		DEFB  $1D
		DEFB  $08
		DEFB  $18
		DEFB  $0A
		DEFB  $16
		DEFB  $0C
		DEFB  $19
		DEFB  $0E
		DEFB  $1A
		DEFB  $10
		DEFB  $1B
		DEFB  $12
		DEFB  $16
		DEFB  $14
		DEFB  $1C
		DEFB  $1E
		DEFB  $1D
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $22
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $22
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $22
		DEFB  $23
		DEFB  $24
		DEFB  $01
		DEFB  $16
		DEFB  $00		  ; End of song

PATTDATA5:
		DEFB  $2C, $00, $00, $00, $00, $00, $00, $00
		DEFB  $79, $79, $3D, $3D, $79, $79, $3D, $3D
		DEFB  $2C, $00, $2C, $00, $00, $00, $00, $00
		DEFB  $97, $97, $4C, $4C, $97, $97, $4C, $4C
		DEFB  $2C, $00, $2C, $00, $00, $00, $2C, $00
		DEFB  $88, $88, $44, $44, $88, $88, $44, $44
		DEFB  $B4, $B4, $5B, $5B, $B4, $B4, $5B, $5B
		DEFB  $2C, $79, $3D, $3D, $79, $79, $3D, $3D
		DEFB  $00, $00, $3D, $00, $00, $00, $36, $00
		DEFB  $2C, $79, $2C, $3D, $79, $79, $3D, $3D
		DEFB  $00, $00, $33, $00, $00, $00, $00, $00
		DEFB  $2C, $97, $4C, $4C, $97, $97, $4C, $4C
		DEFB  $44, $00, $00, $00, $44, $00, $3D, $00
		DEFB  $2C, $97, $2C, $4C, $97, $97, $2C, $4C
		DEFB  $00, $00, $36, $00, $00, $00, $00, $00
		DEFB  $2C, $88, $44, $44, $88, $88, $44, $44
		DEFB  $00, $00, $00, $00, $3D, $00, $00, $00
		DEFB  $2C, $88, $2C, $44, $88, $88, $44, $44
		DEFB  $36, $00, $00, $00, $33, $00, $00, $00
		DEFB  $2C, $B4, $5B, $5B, $B4, $B4, $5B, $5B
		DEFB  $2C, $B4, $2C, $5B, $B4, $B4, $5B, $5B
		DEFB  $00, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $00, $00, $48, $00, $00, $00
		DEFB  $3D, $00, $00, $00, $00, $00, $00, $00
		DEFB  $4C, $00, $00, $00, $00, $00, $51, $00
		DEFB  $00, $00, $00, $00, $4C, $00, $00, $00
		DEFB  $44, $00, $00, $00, $00, $00, $00, $00
		DEFB  $5B, $00, $00, $00, $5B, $00, $51, $00
		DEFB  $00, $00, $00, $00, $5B, $00, $00, $00
		DEFB  $2C, $2C, $2C, $2C, $B4, $B4, $5B, $5B
		DEFB  $2C, $00, $79, $2C, $79, $00, $2C, $00
		DEFB  $00, $00, $79, $00, $00, $00, $79, $00
		DEFB  $2C, $00, $79, $00, $3D, $00, $3D, $00
		DEFB  $00, $00, $79, $00, $00, $00, $3D, $00
		DEFB  $2C, $00, $00, $2C, $00, $00, $2C, $00
		DEFB  $79, $00, $00, $00, $00, $00, $00, $00

; ---------------------------
; River city from Beepola. By Shiru.
; ---------------------------

musicData6
		DEFW  $10D2		  ; Initial tempo
		DEFW  PATTDATA6 - 8	   ; Ptr to start of pattern data - 8
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
		DEFB  $05
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $09
		DEFB  $02
		DEFB  $0A
		DEFB  $0B
		DEFB  $0C
		DEFB  $0D
		DEFB  $0E
		DEFB  $0F
		DEFB  $09
		DEFB  $02
		DEFB  $0A
		DEFB  $0B
		DEFB  $10
		DEFB  $0F
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $02
		DEFB  $14
		DEFB  $04
		DEFB  $15
		DEFB  $06
		DEFB  $16
		DEFB  $08
		DEFB  $13
		DEFB  $02
		DEFB  $14
		DEFB  $04
		DEFB  $15
		DEFB  $06
		DEFB  $17
		DEFB  $08
		DEFB  $18
		DEFB  $02
		DEFB  $19
		DEFB  $0B
		DEFB  $1A
		DEFB  $0D
		DEFB  $1B
		DEFB  $0F
		DEFB  $18
		DEFB  $02
		DEFB  $19
		DEFB  $0B
		DEFB  $1C
		DEFB  $0F
		DEFB  $1D
		DEFB  $12
		DEFB  $1E
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $1E
		DEFB  $22
		DEFB  $20
		DEFB  $23
		DEFB  $1E
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $1E
		DEFB  $24
		DEFB  $20
		DEFB  $25
		DEFB  $26
		DEFB  $27
		DEFB  $28
		DEFB  $21
		DEFB  $26
		DEFB  $29
		DEFB  $28
		DEFB  $2A
		DEFB  $2B
		DEFB  $2C
		DEFB  $2D
		DEFB  $2E
		DEFB  $2B
		DEFB  $2F
		DEFB  $30
		DEFB  $31
		DEFB  $1E
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $1E
		DEFB  $22
		DEFB  $20
		DEFB  $23
		DEFB  $1E
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $1E
		DEFB  $24
		DEFB  $20
		DEFB  $25
		DEFB  $26
		DEFB  $27
		DEFB  $28
		DEFB  $21
		DEFB  $26
		DEFB  $29
		DEFB  $28
		DEFB  $2A
		DEFB  $2B
		DEFB  $2C
		DEFB  $2D
		DEFB  $32
		DEFB  $33
		DEFB  $34
		DEFB  $35
		DEFB  $36
		DEFB  $37
		DEFB  $38
		DEFB  $39
		DEFB  $3A
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
		DEFB  $37
		DEFB  $38
		DEFB  $39
		DEFB  $3A
		DEFB  $37
		DEFB  $38
		DEFB  $39
		DEFB  $3A
		DEFB  $3B
		DEFB  $3C
		DEFB  $3D
		DEFB  $3E
		DEFB  $43
		DEFB  $40
		DEFB  $44
		DEFB  $45
		DEFB  $13
		DEFB  $02
		DEFB  $14
		DEFB  $04
		DEFB  $15
		DEFB  $06
		DEFB  $16
		DEFB  $08
		DEFB  $13
		DEFB  $02
		DEFB  $14
		DEFB  $04
		DEFB  $15
		DEFB  $06
		DEFB  $17
		DEFB  $08
		DEFB  $18
		DEFB  $02
		DEFB  $19
		DEFB  $0B
		DEFB  $1A
		DEFB  $0D
		DEFB  $1B
		DEFB  $0F
		DEFB  $46
		DEFB  $02
		DEFB  $47
		DEFB  $0B
		DEFB  $48
		DEFB  $0F
		DEFB  $49
		DEFB  $4A
		DEFB  $13
		DEFB  $02
		DEFB  $14
		DEFB  $04
		DEFB  $15
		DEFB  $06
		DEFB  $16
		DEFB  $08
		DEFB  $13
		DEFB  $02
		DEFB  $14
		DEFB  $04
		DEFB  $15
		DEFB  $06
		DEFB  $17
		DEFB  $08
		DEFB  $18
		DEFB  $02
		DEFB  $19
		DEFB  $0B
		DEFB  $1A
		DEFB  $0D
		DEFB  $1B
		DEFB  $0F
		DEFB  $18
		DEFB  $02
		DEFB  $19
		DEFB  $0B
		DEFB  $1C
		DEFB  $0F
		DEFB  $1D
		DEFB  $12
		DEFB  $1E
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $1E
		DEFB  $22
		DEFB  $20
		DEFB  $23
		DEFB  $1E
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $1E
		DEFB  $24
		DEFB  $20
		DEFB  $25
		DEFB  $26
		DEFB  $27
		DEFB  $28
		DEFB  $21
		DEFB  $26
		DEFB  $29
		DEFB  $28
		DEFB  $2A
		DEFB  $2B
		DEFB  $2C
		DEFB  $2D
		DEFB  $2E
		DEFB  $2B
		DEFB  $2F
		DEFB  $30
		DEFB  $31
		DEFB  $1E
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $1E
		DEFB  $22
		DEFB  $20
		DEFB  $23
		DEFB  $1E
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $1E
		DEFB  $24
		DEFB  $20
		DEFB  $25
		DEFB  $26
		DEFB  $27
		DEFB  $28
		DEFB  $21
		DEFB  $26
		DEFB  $29
		DEFB  $28
		DEFB  $2A
		DEFB  $2B
		DEFB  $2C
		DEFB  $2D
		DEFB  $32
		DEFB  $33
		DEFB  $34
		DEFB  $35
		DEFB  $36
		DEFB  $37
		DEFB  $38
		DEFB  $39
		DEFB  $3A
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
		DEFB  $37
		DEFB  $38
		DEFB  $39
		DEFB  $3A
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
		DEFB  $4B
		DEFB  $4C
		DEFB  $4D
		DEFB  $4E
		DEFB  $00		  ; End of song

PATTDATA6:
		DEFB  $51, $51, $00, $00, $22, $1E, $51, $51
		DEFB  $00, $00, $22, $1E, $1B, $1B, $1E, $1B
		DEFB  $1E, $51, $51, $1B, $51, $00, $1B, $00
		DEFB  $00, $1B, $1E, $00, $1B, $00, $1B, $1E
		DEFB  $79, $79, $22, $22, $24, $22, $79, $6C
		DEFB  $22, $22, $24, $22, $00, $22, $00, $24
		DEFB  $00, $6C, $6C, $1E, $6C, $00, $00, $1E
		DEFB  $1E, $1E, $24, $1E, $00, $1E, $24, $00
		DEFB  $66, $66, $00, $00, $22, $1E, $66, $66
		DEFB  $1E, $66, $66, $1B, $66, $00, $00, $1B
		DEFB  $00, $1B, $1E, $1B, $00, $1B, $1E, $00
		DEFB  $5B, $5B, $1E, $1E, $22, $1E, $5B, $5B
		DEFB  $1E, $1E, $22, $1E, $00, $1E, $00, $22
		DEFB  $00, $5B, $5B, $1E, $5B, $00, $00, $1E
		DEFB  $1E, $1E, $22, $1E, $00, $1E, $22, $00
		DEFB  $5B, $5B, $1E, $1E, $22, $1E, $5B, $00
		DEFB  $5B, $00, $00, $00, $66, $00, $5B, $00
		DEFB  $1E, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $51, $00, $2C, $51, $1E, $2C, $51
		DEFB  $2C, $51, $51, $2C, $51, $00, $2C, $00
		DEFB  $2C, $79, $22, $2C, $79, $22, $2C, $6C
		DEFB  $2C, $6C, $6C, $2C, $6C, $00, $2C, $1E
		DEFB  $2C, $6C, $6C, $2C, $6C, $00, $00, $1E
		DEFB  $2C, $66, $00, $2C, $66, $1E, $2C, $66
		DEFB  $2C, $66, $66, $2C, $66, $66, $2C, $1B
		DEFB  $2C, $5B, $1E, $2C, $5B, $1E, $2C, $5B
		DEFB  $2C, $5B, $5B, $2C, $5B, $00, $2C, $1E
		DEFB  $2C, $5B, $1E, $2C, $5B, $1E, $2C, $1E
		DEFB  $5B, $1E, $22, $00, $1E, $00, $00, $00
		DEFB  $2C, $51, $00, $51, $44, $00, $51, $51
		DEFB  $36, $36, $00, $00, $00, $00, $36, $36
		DEFB  $2C, $44, $2C, $51, $44, $00, $5B, $00
		DEFB  $00, $00, $00, $00, $24, $22, $00, $22
		DEFB  $24, $24, $2D, $00, $00, $00, $3D, $00
		DEFB  $36, $00, $00, $00, $00, $00, $00, $00
		DEFB  $24, $00, $2D, $00, $00, $2D, $24, $00
		DEFB  $2D, $00, $00, $00, $36, $00, $3D, $00
		DEFB  $2C, $79, $00, $79, $66, $00, $79, $79
		DEFB  $33, $33, $00, $00, $00, $00, $33, $33
		DEFB  $2C, $66, $2C, $79, $66, $00, $88, $00
		DEFB  $24, $00, $2D, $00, $00, $00, $24, $00
		DEFB  $2D, $00, $00, $00, $2D, $00, $28, $00
		DEFB  $2C, $6C, $00, $6C, $5B, $00, $6C, $6C
		DEFB  $24, $24, $00, $00, $00, $00, $24, $24
		DEFB  $2C, $5B, $2C, $6C, $5B, $00, $79, $00
		DEFB  $00, $00, $00, $00, $1E, $1B, $00, $1B
		DEFB  $1E, $00, $22, $00, $00, $00, $24, $00
		DEFB  $2C, $5B, $2C, $6C, $5B, $00, $51, $00
		DEFB  $22, $00, $00, $00, $44, $00, $3D, $00
		DEFB  $00, $00, $00, $00, $1E, $1B, $00, $1E
		DEFB  $2C, $6C, $2C, $6C, $5B, $2C, $6C, $6C
		DEFB  $1B, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $5B, $00, $2C, $66, $00, $5B, $00
		DEFB  $00, $00, $00, $00, $44, $00, $3D, $00
		DEFB  $2C, $2C, $44, $2C, $51, $2C, $51, $2C
		DEFB  $36, $36, $22, $36, $36, $1E, $36, $36
		DEFB  $2C, $2C, $51, $2C, $51, $2C, $44, $2C
		DEFB  $22, $36, $36, $1E, $36, $1E, $22, $1E
		DEFB  $2C, $2C, $33, $2C, $79, $2C, $79, $2C
		DEFB  $28, $28, $19, $28, $28, $17, $28, $28
		DEFB  $2C, $2C, $79, $2C, $79, $2C, $36, $2C
		DEFB  $19, $28, $28, $17, $28, $19, $1B, $19
		DEFB  $2C, $2C, $5B, $2C, $6C, $2C, $6C, $6C
		DEFB  $24, $24, $2D, $24, $24, $28, $24, $24
		DEFB  $2C, $6C, $6C, $2C, $6C, $5B, $6C, $5B
		DEFB  $2D, $24, $24, $28, $24, $2D, $36, $2D
		DEFB  $2C, $2C, $5B, $2C, $6C, $2C, $6C, $2C
		DEFB  $5B, $6C, $6C, $51, $00, $6C, $66, $5B
		DEFB  $2D, $24, $24, $28, $00, $00, $00, $00
		DEFB  $2C, $66, $00, $2C, $22, $1E, $2C, $66
		DEFB  $2C, $66, $66, $2C, $66, $00, $2C, $1B
		DEFB  $2C, $5B, $1E, $2C, $22, $1E, $2C, $00
		DEFB  $2C, $00, $1E, $2C, $66, $00, $5B, $00
		DEFB  $1E, $00, $00, $00, $33, $00, $2D, $00
		DEFB  $2C, $6C, $2C, $51, $00, $6C, $66, $5B
		DEFB  $2D, $24, $24, $28, $00, $36, $33, $2D
		DEFB  $51, $00, $00, $00, $00, $00, $00, $00
		DEFB  $28, $00, $00, $00, $00, $00, $00, $00


; ---------------------------
; street of rain. From Beepola. By Shiru.
; ---------------------------
musicData7
		DEFW  $10D2		  ; Initial tempo
		DEFW  PATTDATA - 8	  ; Ptr to start of pattern data - 8
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
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $09
		DEFB  $0A
		DEFB  $0B
		DEFB  $0C
		DEFB  $05
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $0D
		DEFB  $0E
		DEFB  $0F
		DEFB  $10
		DEFB  $11
		DEFB  $12
		DEFB  $11
		DEFB  $13
		DEFB  $11
		DEFB  $12
		DEFB  $11
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $15
		DEFB  $13
		DEFB  $15
		DEFB  $17
		DEFB  $15
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $19
		DEFB  $13
		DEFB  $19
		DEFB  $1B
		DEFB  $19
		DEFB  $1C
		DEFB  $15
		DEFB  $1D
		DEFB  $15
		DEFB  $1E
		DEFB  $15
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $11
		DEFB  $12
		DEFB  $11
		DEFB  $13
		DEFB  $11
		DEFB  $12
		DEFB  $11
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $15
		DEFB  $13
		DEFB  $15
		DEFB  $17
		DEFB  $15
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $19
		DEFB  $13
		DEFB  $19
		DEFB  $1B
		DEFB  $19
		DEFB  $1C
		DEFB  $15
		DEFB  $1D
		DEFB  $15
		DEFB  $1E
		DEFB  $15
		DEFB  $22
		DEFB  $20
		DEFB  $13
		DEFB  $23
		DEFB  $24
		DEFB  $25
		DEFB  $13
		DEFB  $23
		DEFB  $24
		DEFB  $25
		DEFB  $26
		DEFB  $27
		DEFB  $28
		DEFB  $29
		DEFB  $13
		DEFB  $2A
		DEFB  $28
		DEFB  $29
		DEFB  $2B
		DEFB  $23
		DEFB  $2C
		DEFB  $25
		DEFB  $13
		DEFB  $23
		DEFB  $2C
		DEFB  $25
		DEFB  $2D
		DEFB  $2E
		DEFB  $2F
		DEFB  $30
		DEFB  $22
		DEFB  $31
		DEFB  $22
		DEFB  $30
		DEFB  $32
		DEFB  $33
		DEFB  $34
		DEFB  $35
		DEFB  $36
		DEFB  $33
		DEFB  $34
		DEFB  $35
		DEFB  $36
		DEFB  $37
		DEFB  $38
		DEFB  $39
		DEFB  $3A
		DEFB  $37
		DEFB  $38
		DEFB  $39
		DEFB  $3A
		DEFB  $3B
		DEFB  $3C
		DEFB  $3D
		DEFB  $3E
		DEFB  $3B
		DEFB  $3C
		DEFB  $3D
		DEFB  $3E
		DEFB  $37
		DEFB  $38
		DEFB  $39
		DEFB  $3A
		DEFB  $3F
		DEFB  $40
		DEFB  $41
		DEFB  $21
		DEFB  $11
		DEFB  $12
		DEFB  $11
		DEFB  $13
		DEFB  $11
		DEFB  $12
		DEFB  $11
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $15
		DEFB  $13
		DEFB  $15
		DEFB  $17
		DEFB  $15
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $19
		DEFB  $13
		DEFB  $19
		DEFB  $1B
		DEFB  $19
		DEFB  $1C
		DEFB  $15
		DEFB  $1D
		DEFB  $15
		DEFB  $1E
		DEFB  $15
		DEFB  $1F
		DEFB  $20
		DEFB  $21
		DEFB  $11
		DEFB  $12
		DEFB  $11
		DEFB  $13
		DEFB  $11
		DEFB  $12
		DEFB  $11
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $15
		DEFB  $13
		DEFB  $15
		DEFB  $17
		DEFB  $15
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $19
		DEFB  $13
		DEFB  $19
		DEFB  $1B
		DEFB  $19
		DEFB  $1C
		DEFB  $15
		DEFB  $1D
		DEFB  $15
		DEFB  $1E
		DEFB  $15
		DEFB  $22
		DEFB  $20
		DEFB  $13
		DEFB  $42
		DEFB  $02
		DEFB  $43
		DEFB  $04
		DEFB  $42
		DEFB  $02
		DEFB  $43
		DEFB  $04
		DEFB  $44
		DEFB  $06
		DEFB  $45
		DEFB  $08
		DEFB  $44
		DEFB  $06
		DEFB  $45
		DEFB  $08
		DEFB  $46
		DEFB  $0A
		DEFB  $47
		DEFB  $0C
		DEFB  $44
		DEFB  $06
		DEFB  $45
		DEFB  $08
		DEFB  $42
		DEFB  $02
		DEFB  $43
		DEFB  $04
		DEFB  $48
		DEFB  $0E
		DEFB  $00		  ; End of song

PATTDATA:
		DEFB  $00, $00, $00, $51, $00, $36, $00, $28
		DEFB  $51, $00, $36, $00, $28, $00, $22, $00
		DEFB  $00, $22, $00, $1B, $00, $22, $00, $28
		DEFB  $1B, $00, $22, $00, $28, $00, $36, $00
		DEFB  $00, $00, $00, $5B, $00, $3D, $00, $2D
		DEFB  $5B, $00, $3D, $00, $2D, $00, $24, $00
		DEFB  $00, $24, $00, $1E, $00, $24, $00, $2D
		DEFB  $1E, $00, $24, $00, $2D, $00, $3D, $00
		DEFB  $00, $00, $00, $66, $00, $44, $00, $33
		DEFB  $66, $00, $44, $00, $33, $00, $28, $00
		DEFB  $00, $28, $00, $22, $00, $28, $00, $33
		DEFB  $22, $00, $28, $00, $33, $00, $66, $00
		DEFB  $00, $00, $51, $00, $00, $00, $00, $00
		DEFB  $51, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $51, $00, $00, $00, $5B, $00
		DEFB  $51, $00, $00, $00, $5B, $00, $00, $24
		DEFB  $2C, $00, $2D, $2C, $00, $00, $2C, $00
		DEFB  $22, $00, $00, $36, $00, $00, $36, $00
		DEFB  $00, $00, $00, $00, $00, $00, $00, $00
		DEFB  $22, $00, $00, $24, $00, $00, $28, $00
		DEFB  $2C, $00, $33, $2C, $00, $00, $2C, $00
		DEFB  $24, $00, $00, $3D, $00, $00, $3D, $00
		DEFB  $28, $24, $00, $00, $00, $00, $33, $2D
		DEFB  $28, $00, $00, $2D, $00, $00, $3D, $00
		DEFB  $2C, $00, $36, $2C, $00, $00, $2C, $00
		DEFB  $28, $00, $00, $44, $00, $00, $44, $00
		DEFB  $28, $00, $00, $44, $00, $00, $44, $24
		DEFB  $22, $00, $00, $00, $51, $00, $3D, $00
		DEFB  $36, $00, $00, $3D, $00, $00, $44, $00
		DEFB  $44, $00, $00, $3D, $00, $00, $36, $00
		DEFB  $3D, $00, $00, $00, $00, $00, $00, $00
		DEFB  $5B, $00, $2C, $2D, $00, $00, $2C, $00
		DEFB  $00, $00, $00, $00, $00, $00, $00, $24
		DEFB  $2D, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $2C, $44, $00, $44, $00, $44, $44
		DEFB  $51, $51, $00, $00, $00, $00, $51, $51
		DEFB  $44, $00, $2C, $00, $44, $00, $44, $00
		DEFB  $00, $28, $24, $00, $22, $00, $24, $00
		DEFB  $2C, $2C, $00, $00, $24, $00, $24, $24
		DEFB  $5B, $5B, $00, $00, $00, $00, $5B, $5B
		DEFB  $24, $00, $2C, $00, $24, $00, $24, $00
		DEFB  $2C, $2C, $24, $00, $24, $00, $24, $24
		DEFB  $00, $2D, $28, $00, $28, $00, $2D, $00
		DEFB  $66, $66, $00, $00, $00, $00, $66, $66
		DEFB  $00, $00, $33, $00, $2D, $00, $28, $00
		DEFB  $2C, $2C, $2D, $00, $2D, $00, $2D, $00
		DEFB  $5B, $5B, $2D, $00, $00, $00, $5B, $5B
		DEFB  $2D, $00, $2C, $00, $2D, $00, $2D, $00
		DEFB  $2C, $2C, $2D, $00, $2D, $00, $5B, $5B
		DEFB  $00, $00, $5B, $00, $5B, $00, $5B, $00
		DEFB  $2C, $2C, $2D, $44, $00, $00, $2C, $2C
		DEFB  $51, $51, $00, $28, $51, $00, $28, $28
		DEFB  $51, $00, $2C, $00, $44, $00, $2C, $00
		DEFB  $00, $00, $48, $28, $51, $00, $48, $00
		DEFB  $2C, $2C, $33, $24, $00, $00, $2C, $2C
		DEFB  $5B, $5B, $00, $2D, $5B, $00, $2D, $2D
		DEFB  $5B, $00, $2C, $00, $24, $00, $2C, $00
		DEFB  $00, $00, $28, $2D, $5B, $00, $28, $00
		DEFB  $2C, $2C, $36, $28, $00, $00, $2C, $2C
		DEFB  $66, $66, $00, $33, $66, $00, $33, $33
		DEFB  $66, $00, $2C, $00, $28, $00, $2C, $00
		DEFB  $00, $00, $2D, $33, $66, $00, $2D, $00
		DEFB  $2C, $2C, $2D, $33, $5B, $00, $2C, $2C
		DEFB  $5B, $5B, $00, $2D, $5B, $00, $28, $24
		DEFB  $00, $00, $6C, $00, $5B, $00, $2C, $00
		DEFB  $2C, $00, $00, $51, $00, $36, $2C, $28
		DEFB  $00, $22, $00, $1B, $00, $22, $2C, $28
		DEFB  $2C, $00, $00, $5B, $00, $3D, $2C, $2D
		DEFB  $00, $24, $00, $1E, $00, $24, $2C, $2D
		DEFB  $2C, $00, $00, $66, $00, $44, $2C, $33
		DEFB  $00, $28, $00, $22, $00, $28, $2C, $33
		DEFB  $2C, $00, $51, $00, $00, $00, $00, $00

	 
;-------------------------
; Money Money Money. By the Beatles or some dumb mob.
;--------------------------
  
musicData8:
		DEFW  $10D2		  ; Initial tempo
		DEFW  PATTDATA8 - 8	   ; Ptr to start of pattern data - 8
		DEFB  $01
		DEFB  $02
		DEFB  $03
		DEFB  $04
		DEFB  $01
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
		DEFB  $0F
		DEFB  $10
		DEFB  $11
		DEFB  $10
		DEFB  $11
		DEFB  $10
		DEFB  $11
		DEFB  $10
		DEFB  $12
		DEFB  $13
		DEFB  $14
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $0E
		DEFB  $17
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $1B
		DEFB  $11
		DEFB  $13
		DEFB  $14
		DEFB  $13
		DEFB  $14
		DEFB  $15
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $0E
		DEFB  $17
		DEFB  $1C
		DEFB  $13
		DEFB  $1D
		DEFB  $13
		DEFB  $11
		DEFB  $13
		DEFB  $1E
		DEFB  $13
		DEFB  $1F
		DEFB  $13
		DEFB  $20
		DEFB  $21
		DEFB  $0F
		DEFB  $22
		DEFB  $23
		DEFB  $22
		DEFB  $24
		DEFB  $22
		DEFB  $20
		DEFB  $25
		DEFB  $0F
		DEFB  $26
		DEFB  $27
		DEFB  $26
		DEFB  $27
		DEFB  $FF		  ; Tempo change
		DEFW  $1338		  ; New tempo value
		DEFB  $28
		DEFB  $27
		DEFB  $0E
		DEFB  $29
		DEFB  $FF		  ; Tempo change
		DEFW  $1A6A		  ; New tempo value
		DEFB  $0E
		DEFB  $2A
		DEFB  $2B
		DEFB  $0E
		DEFB  $FF		  ; Tempo change
		DEFW  $10D2		  ; New tempo value
		DEFB  $2C
		DEFB  $2D
		DEFB  $2E
		DEFB  $2F
		DEFB  $30
		DEFB  $31
		DEFB  $32
		DEFB  $33
		DEFB  $34
		DEFB  $31
		DEFB  $34
		DEFB  $35
		DEFB  $36
		DEFB  $0E
		DEFB  $2C
		DEFB  $37
		DEFB  $2C
		DEFB  $2D
		DEFB  $2E
		DEFB  $2F
		DEFB  $30
		DEFB  $31
		DEFB  $32
		DEFB  $33
		DEFB  $34
		DEFB  $31
		DEFB  $38
		DEFB  $35
		DEFB  $2C
		DEFB  $0E
		DEFB  $2C
		DEFB  $39
		DEFB  $3A
		DEFB  $0E
		DEFB  $3B
		DEFB  $3C
		DEFB  $3D
		DEFB  $3E
		DEFB  $3F
		DEFB  $40
		DEFB  $2C
		DEFB  $41
		DEFB  $42
		DEFB  $43
		DEFB  $3A
		DEFB  $0E
		DEFB  $44
		DEFB  $45
		DEFB  $2C
		DEFB  $46
		DEFB  $2E
		DEFB  $47
		DEFB  $48
		DEFB  $31
		DEFB  $38
		DEFB  $35
		DEFB  $49
		DEFB  $4A
		DEFB  $03
		DEFB  $04
		DEFB  $01
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
		DEFB  $0F
		DEFB  $00		  ; End of song

PATTDATA8:
		DEFB  $22, $00, $22, $00, $22, $00, $22, $00
		DEFB  $1B, $00, $1B, $00, $1B, $00, $1B, $00
		DEFB  $22, $00, $22, $00, $36, $28, $22, $1B
		DEFB  $1B, $00, $1B, $00, $00, $00, $00, $00
		DEFB  $1C, $00, $1C, $00, $1C, $00, $1C, $00
		DEFB  $22, $00, $22, $00, $33, $28, $22, $1C
		DEFB  $1C, $00, $1C, $00, $00, $00, $00, $00
		DEFB  $79, $00, $00, $00, $00, $00, $00, $00
		DEFB  $1E, $00, $00, $00, $22, $00, $28, $00
		DEFB  $6C, $00, $00, $00, $00, $00, $00, $00
		DEFB  $22, $00, $22, $00, $00, $00, $28, $00
		DEFB  $A1, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $00, $00, $00, $28, $22, $1B
		DEFB  $00, $00, $00, $00, $00, $00, $00, $00
		DEFB  $14, $00, $00, $00, $00, $00, $00, $00
		DEFB  $A1, $00, $A1, $00, $A1, $00, $A1, $00
		DEFB  $14, $12, $11, $0D, $14, $12, $11, $0D
		DEFB  $14, $12, $11, $0D, $14, $12, $1B, $0D
		DEFB  $51, $00, $51, $00, $51, $00, $51, $00
		DEFB  $1B, $00, $19, $00, $19, $00, $1B, $00
		DEFB  $56, $00, $56, $00, $56, $00, $56, $00
		DEFB  $1B, $00, $14, $00, $14, $00, $15, $00
		DEFB  $6C, $00, $6C, $00, $6C, $00, $6C, $00
		DEFB  $1E, $00, $1E, $00, $00, $00, $1E, $00
		DEFB  $A1, $00, $A1, $00, $51, $00, $51, $00
		DEFB  $22, $00, $00, $0D, $14, $12, $11, $0D
		DEFB  $51, $00, $51, $00, $51, $00, $1B, $00
		DEFB  $19, $00, $19, $00, $00, $00, $19, $00
		DEFB  $1B, $00, $00, $0D, $14, $12, $11, $0D
		DEFB  $0F, $00, $0F, $00, $00, $00, $11, $00
		DEFB  $00, $00, $00, $00, $11, $00, $00, $00
		DEFB  $12, $00, $12, $00, $00, $00, $11, $12
		DEFB  $51, $00, $51, $00, $5B, $00, $5B, $00
		DEFB  $66, $00, $66, $00, $66, $00, $66, $00
		DEFB  $00, $00, $0F, $00, $0F, $00, $00, $00
		DEFB  $11, $00, $11, $00, $00, $00, $11, $00
		DEFB  $66, $00, $66, $00, $6C, $00, $6C, $00
		DEFB  $79, $00, $79, $00, $79, $00, $79, $00
		DEFB  $14, $00, $12, $00, $12, $00, $14, $00
		DEFB  $E3, $00, $00, $00, $00, $00, $00, $00
		DEFB  $14, $00, $11, $00, $11, $00, $12, $00
		DEFB  $1B, $19, $1E, $1B, $22, $1E, $24, $1B
		DEFB  $6C, $66, $79, $6C, $88, $79, $90, $88
		DEFB  $2C, $00, $A1, $00, $A1, $00, $A1, $00
		DEFB  $14, $00, $12, $00, $11, $00, $14, $00
		DEFB  $2C, $00, $A1, $00, $44, $00, $2C, $00
		DEFB  $12, $00, $11, $00, $36, $00, $39, $00
		DEFB  $2C, $00, $90, $00, $90, $00, $90, $00
		DEFB  $00, $00, $00, $00, $12, $00, $14, $00
		DEFB  $2C, $00, $90, $00, $28, $00, $2C, $00
		DEFB  $12, $00, $11, $00, $39, $00, $3D, $00
		DEFB  $2C, $00, $D7, $00, $D7, $00, $D7, $00
		DEFB  $11, $00, $11, $00, $00, $00, $14, $00
		DEFB  $2C, $00, $A1, $00, $A1, $00, $2C, $00
		DEFB  $0D, $0F, $11, $14, $11, $12, $14, $00
		DEFB  $2C, $00, $D7, $00, $D7, $00, $2C, $00
		DEFB  $0D, $0F, $11, $14, $11, $00, $0C, $00
		DEFB  $2C, $00, $79, $00, $79, $00, $79, $00
		DEFB  $2C, $00, $79, $00, $79, $00, $2C, $00
		DEFB  $00, $00, $00, $0C, $0F, $00, $0D, $00
		DEFB  $2C, $00, $6C, $00, $6C, $00, $6C, $00
		DEFB  $00, $00, $00, $00, $1B, $00, $1E, $00
		DEFB  $2C, $00, $6C, $00, $6C, $00, $2C, $00
		DEFB  $1B, $00, $19, $00, $00, $00, $20, $00
		DEFB  $00, $00, $00, $00, $19, $00, $1B, $00
		DEFB  $2C, $00, $A1, $00, $A1, $00, $79, $00
		DEFB  $19, $00, $1B, $00, $28, $00, $1E, $00
		DEFB  $2C, $00, $66, $00, $6C, $00, $6C, $00
		DEFB  $22, $00, $00, $00, $24, $00, $00, $00
		DEFB  $28, $00, $24, $00, $22, $00, $28, $00
		DEFB  $24, $00, $22, $00, $36, $00, $33, $00
		DEFB  $2C, $00, $F0, $00, $F0, $00, $F0, $00
		DEFB  $A1, $00, $00, $00, $22, $00, $22, $00
		DEFB  $00, $00, $1B, $00, $1B, $00, $1B, $00

; -----------------------------
; Theme from Money Magic
; -------------------------------

musicData9:
		DEFW  $0E6C		  ; Initial tempo
		DEFW  PATTDATA9 - 8	   ; Ptr to start of pattern data - 8
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
		DEFB  $09
		DEFB  $0A
		DEFB  $0B
		DEFB  $0C
		DEFB  $05
		DEFB  $06
		DEFB  $07
		DEFB  $08
		DEFB  $09
		DEFB  $0A
		DEFB  $0B
		DEFB  $0C
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
		DEFB  $0D
		DEFB  $0E
		DEFB  $FF		  ; Tempo change
		DEFW  $04D4		  ; New tempo value
		DEFB  $0F
		DEFB  $10
		DEFB  $11
		DEFB  $12
		DEFB  $13
		DEFB  $11
		DEFB  $FF		  ; Tempo change
		DEFW  $0E6C		  ; New tempo value
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $18
		DEFB  $19
		DEFB  $1A
		DEFB  $1B
		DEFB  $14
		DEFB  $15
		DEFB  $16
		DEFB  $17
		DEFB  $18
		DEFB  $19
		DEFB  $1C
		DEFB  $1B
		DEFB  $1D
		DEFB  $1E
		DEFB  $1F
		DEFB  $20
		DEFB  $1D
		DEFB  $21
		DEFB  $22
		DEFB  $23
		DEFB  $24
		DEFB  $15
		DEFB  $25
		DEFB  $17
		DEFB  $26
		DEFB  $19
		DEFB  $1A
		DEFB  $11
		DEFB  $27
		DEFB  $28
		DEFB  $29
		DEFB  $2A
		DEFB  $2B
		DEFB  $2C
		DEFB  $2D
		DEFB  $2E
		DEFB  $27
		DEFB  $28
		DEFB  $29
		DEFB  $2A
		DEFB  $2F
		DEFB  $2C
		DEFB  $30
		DEFB  $2E
		DEFB  $27
		DEFB  $28
		DEFB  $29
		DEFB  $2A
		DEFB  $2B
		DEFB  $2C
		DEFB  $2D
		DEFB  $2E
		DEFB  $27
		DEFB  $28
		DEFB  $29
		DEFB  $2A
		DEFB  $2F
		DEFB  $2C
		DEFB  $31
		DEFB  $2E
		DEFB  $00		  ; End of song

PATTDATA9:
		DEFB  $D7, $3D, $79, $80, $2D, $A1, $24, $90
		DEFB  $30, $2D, $28, $24, $20, $1E, $1B, $18
		DEFB  $1E, $B4, $18, $A1, $14, $C0, $B4, $A1
		DEFB  $17, $14, $12, $10, $0F, $0D, $00, $00
		DEFB  $90, $90, $00, $40, $00, $90, $00, $3D
		DEFB  $30, $30, $00, $36, $00, $30, $00, $28
		DEFB  $00, $90, $00, $40, $00, $90, $00, $00
		DEFB  $00, $30, $00, $36, $00, $30, $00, $00
		DEFB  $A1, $A1, $51, $3D, $00, $A1, $00, $A1
		DEFB  $30, $30, $00, $30, $00, $30, $00, $30
		DEFB  $18, $00, $00, $00, $1B, $00, $00, $00
		DEFB  $A1, $00, $00, $00, $00, $00, $00, $00
		DEFB  $A1, $A1, $00, $00, $00, $A1, $00, $A1
		DEFB  $1E, $24, $28, $30, $36, $3D, $48, $51
		DEFB  $C0, $00, $00, $00, $00, $00, $00, $00
		DEFB  $00, $00, $00, $00, $0E, $10, $12, $13
		DEFB  $00, $00, $00, $00, $00, $00, $00, $00
		DEFB  $18, $1C, $20, $24, $26, $30, $39, $60
		DEFB  $00, $00, $66, $00, $00, $00, $00, $00
		DEFB  $90, $00, $00, $A1, $00, $00, $90, $00
		DEFB  $18, $00, $00, $1B, $00, $00, $1E, $00
		DEFB  $6C, $00, $00, $79, $00, $00, $6C, $00
		DEFB  $1B, $00, $00, $1E, $00, $00, $24, $00
		DEFB  $90, $00, $00, $00, $A1, $00, $00, $90
		DEFB  $1E, $00, $00, $00, $28, $00, $00, $24
		DEFB  $00, $00, $00, $00, $00, $00, $2C, $2C
		DEFB  $00, $00, $00, $00, $00, $00, $28, $00
		DEFB  $00, $00, $00, $00, $00, $00, $A1, $00
		DEFB  $2C, $2C, $79, $80, $2C, $2C, $00, $90
		DEFB  $1B, $00, $00, $00, $1B, $00, $1E, $00
		DEFB  $2C, $2C, $00, $A1, $2C, $2C, $B4, $A1
		DEFB  $18, $00, $1B, $00, $1B, $00, $00, $00
		DEFB  $1B, $00, $00, $1E, $00, $00, $1E, $00
		DEFB  $2C, $2C, $00, $A1, $2C, $C0, $B4, $A1
		DEFB  $1B, $00, $00, $00, $00, $00, $00, $00
		DEFB  $2C, $2C, $00, $A1, $2C, $2C, $90, $00
		DEFB  $2C, $2C, $00, $79, $2C, $2C, $6C, $00
		DEFB  $2C, $2C, $00, $00, $2C, $2C, $00, $90
		DEFB  $D7, $00, $6C, $00, $2C, $6C, $2C, $66
		DEFB  $00, $00, $00, $00, $36, $00, $3D, $00
		DEFB  $2C, $00, $00, $6C, $2C, $00, $2C, $00
		DEFB  $30, $00, $00, $36, $00, $00, $00, $00
		DEFB  $90, $00, $48, $00, $2C, $00, $2C, $00
		DEFB  $00, $00, $00, $00, $3D, $00, $48, $00
		DEFB  $2C, $00, $79, $00, $2C, $00, $2C, $2C
		DEFB  $51, $00, $00, $48, $00, $00, $00, $00
		DEFB  $D7, $00, $00, $00, $2C, $00, $2C, $00
		DEFB  $2C, $00, $00, $00, $2C, $00, $2C, $2C
		DEFB  $90, $90, $00, $00, $00, $00, $00, $00


end
