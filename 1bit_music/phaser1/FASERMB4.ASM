

; Phaser 1 engine with synthesised drums MUSICBOX for VZ Laser.
;                                                        Done by dave. June 2023.
; Well over 100 hours now plonked into MB3 and MB4 over the past three
; weeks whilst watching old re-runs of Top Gear & Breaking Bad from scratch.
; 
;
; *****************************************************************************
; * Phaser1 Engine, with synthesised drums
; *
; * Original code by Shiru - http://shiru.untergrund.net/
; * Modified by Chris Cowley
; *
; * Produced by Beepola v1.08.01
; ******************************************************************************
;
;	Song 1 	: lazer power lesbian space dildo Roulette.
;	Song 2	: Pylon
;	SONG 3	: Veeblefetzer
;	SONG 4	: Day at the beach
; 	SONG 5  : Continence
;
;	Assemble with SJASMPLUS.   "  SJASMPLUS FASERMB4.ASM  "
;
	output"FASERMB4.vz"

Origin		equ  $7B00
BORDER_COL     	EQU  $0						; ex zx code left as is

; -------------------------------
; Generic .VZ snapshot header
; -------------------------------

	org 	Origin - 24
	db 	$20, $20, $00, $00, $56, $5A, $44, $4F 		; generic header
	db	$53, $00, $00, $00, $00, $00, $00, $00
	db	$00, $00, $00, $00, $00, $F1
	dw	START

	org 	Origin
START equ $

; -------------------------------
; Intro stuff
; -------------------------------
	di
	call	do_intro		; Do fancy intro
	ld	a, 0
	ld	($6800), a		; MODE (0)
	ld	a, 0
	ld	(speaker_or_cas), a	; 0=speaker. 1=cassette port.

begin:	
cls:	
; -------------------------------
; Menu stuff
; -------------------------------

	ei
	call	$01c9		; VZ ROM CLS
	di
	ld	hl, MSG1	
	call	$28a7		; Print MENU 1, VZ ROM Print string.
	ld	hl, MSG2	
	call	$28a7		; Print MENU 2, VZ ROM Print string.
	ld	hl, MSG3
	call	$28a7		; Print MENU 3, VZ ROM Print string.

;; -------------------------------
;; SPEAKER OR CASSETTE SELECTION
;; -------------------------------
;menucas:ld	a, (speaker_or_cas)	; display MENU INVERSE SPEAKER or CASSETTE
;	cp	1
;	jr	z, menuc1
;	ld	hl, SPEAKINV
;	jr	menuc2
;menuc1:ld	hl, CASSEINV
;menuc2:ld	e, (hl)		
;	inc	hl
;	ld	d, (hl)		; de=dest
;	inc	hl
;	ld	b, 0
;	ld	c, (hl)		; get length
;	inc	hl
;	ldir			; and display INVERSE text.

menuca2:di
scan:	call 	$2ef4		; VZ scan keyboard
	or 	a		; any key pressed?
	jr	z, scan		; back if not
	di
	cp	49		; "1 - "   lazer power lesbian space dildo Roulette
	jr	z, m1		; 	
	cp	50		; "2 - "   Pylon
	jr	z, m2
	cp	51		; "3 - "   Veeblefetzer
	jr	z, m3
	cp	52		; "4 - "   Day at the beach
	jr	z, m4
	cp	53		; "5 - "   Continence
	jr	z, m5

	cp 	81		; "Q" - quit
	jr 	z, quit
;	cp	"Y"		; "Y - "   SELECT SPEAKER
;	jr	z, m14
;	cp	"Z"		; "Z - "   SELECT CAS PORT
;	jr	z, m15
	jp 	nz, begin 
;	jp 	scan 
;	jp	begin

quit: 	ei
	call	$01c9	
	jp 	$1a19			; Jump to VZ basic
	
m1: 	ld 	hl, SONG1		; Pick whichever key stroke, to then display.
	ld	de, SONG1INV
	jp 	continue
m2: 	ld 	hl, SONG2
	ld	de, SONG2INV
	jp 	continue
m3: 	ld 	hl, SONG3
	ld	de, SONG3INV
	jp 	continue
m4: 	ld 	hl, SONG4
	LD	de, SONG4INV
	jp 	continue
m5: 	ld 	hl, SONG5
	ld	de, SONG5INV
	jp	continue
;m14:	ld	a, 0			; speaker
;	jr	m15a
;m15:	ld	a, 1			;cassette port
;m15a:	ld	(speaker_or_cas), a	; set speaker or cass_port.
;	jp	begin

continue:
; ----------------------------------------------------
; Display inverse MENU of selection song title stuff
; ----------------------------------------------------
	push	hl		
	push	de		
	pop	hl
	ld	e, (hl)		
	inc	hl
	ld	d, (hl)		; de=dest
	inc	hl
	ld	b, 0
	ld	c, (hl)		; get length
	inc	hl
	ldir			; and display INVERSE text.
	pop	hl	
	di


;; ----------------------------------------------------
;; You can choose only one. Choose wisely.
;; ----------------------------------------------------
;
;	ld	a, (speaker_or_cas)
;	cp	1
;	jp	z, cassette_port_player		; if set to 1, goto cass_port_player


; ----------------------------------------------------
; INTERNAL VZ/LASER SPEAKER
; ----------------------------------------------------

;             LD    HL,MUSICDATA         ;  <- Pointer to Music Data. Change
                                        ;     this to play a different song
             LD   A,(HL)                         ; Get the loop start pointer
             LD   (PATTERN_LOOP_BEGIN),A
             INC  HL
             LD   A,(HL)                         ; Get the song end pointer
             LD   (PATTERN_LOOP_END),A
             INC  HL
             LD   E,(HL)
             INC  HL
             LD   D,(HL)
             INC  HL
             LD   (INSTRUM_TBL),HL
             LD   (CURRENT_INST),HL
             ADD  HL,DE
             LD   (PATTERN_ADDR),HL
             XOR  A
             LD   (PATTERN_PTR),A                ; Set the pattern pointer to zero
             LD   H,A
             LD   L,A
             LD   (NOTE_PTR),HL                  ; Set the note offset (within this pattern) to 0

PLAYER:      DI
             PUSH IY
             LD   A,BORDER_COL
             LD   H,$00
             LD   L,A
             LD   (CNT_1A),HL
             LD   (CNT_1B),HL
             LD   (DIV_1A),HL
             LD   (DIV_1B),HL
             LD   (CNT_2),HL
             LD   (DIV_2),HL
             LD   (OUT_1),A
             LD   (OUT_2),A
             JR   MAIN_LOOP

; ********************************************************************************************************
; * NEXT_PATTERN
; *
; * Select the next pattern in sequence (and handle looping if we've reached PATTERN_LOOP_END
; * Execution falls through to PLAYNOTE to play the first note from our next pattern
; ********************************************************************************************************
NEXT_PATTERN:	LD   	A,(PATTERN_PTR)
                INC  	A
                INC  	A
                DEFB 	$FE                           ; CP n
PATTERN_LOOP_END:DEFB 	0
                JR   	NZ,NO_PATTERN_LOOP
                         ; Handle Exit at and of song
                        DEFB $3E                           ; LD A,n
PATTERN_LOOP_BEGIN:     DEFB 0
                JP   	EXIT_PLAYER
NO_PATTERN_LOOP:LD   	(PATTERN_PTR),A
                LD	HL,$0000
		LD   	(NOTE_PTR),HL   ; Start of pattern (NOTE_PTR = 0)
MAIN_LOOP:	LD   	IYL,0                        ; Set channel = 0
READ_LOOP:   LD   HL,(PATTERN_ADDR)
             LD   A,(PATTERN_PTR)
             LD   E,A
             LD   D,0
             ADD  HL,DE
             LD   E,(HL)
             INC  HL
             LD   D,(HL)                       ; Now DE = Start of Pattern data
             LD   HL,(NOTE_PTR)
             INC  HL                           ; Increment the note pointer and...
             LD   (NOTE_PTR),HL                ; ..store it
             DEC  HL
             ADD  HL,DE                        ; Now HL = address of note data
             LD   A,(HL)
             OR   A
             JR   Z,NEXT_PATTERN               ; select next pattern

             BIT  7,A
             JP   Z,RENDER                     ; Play the currently defined note(S) and drum
             LD   IYH,A
             AND  $3F
             CP   $3C
             JP   NC,OTHER                     ; Other parameters
             ADD  A,A
             LD   B,0
             LD   C,A
             LD   HL,FREQ_TABLE
             ADD  HL,BC
             LD   E,(HL)
             INC  HL
             LD   D,(HL)
             LD   A,IYL                        ; IYL = 0 for channel 1, or = 1 for channel 2
             OR   A
             JR   NZ,SET_NOTE2
             LD   (DIV_1A),DE
             EX   DE,HL

             DEFB $DD,$21                      ; LD IX,nn
CURRENT_INST:
             DEFW $0000

             LD   A,(IX+$00)
             OR   A
             JR   Z,L809B                      ; Original code jumps into byte 2 of the DJNZ (invalid opcode FD)
             LD   B,A
L8098:       ADD  HL,HL
             DJNZ L8098
L809B:       LD   E,(IX+$01)
             LD   D,(IX+$02)
             ADD  HL,DE
             LD   (DIV_1B),HL
             LD   IYL,1                        ; Set channel = 1
             LD   A,IYH
             AND  $40
             JR   Z,READ_LOOP                  ; No phase reset

             LD   HL,OUT_1                     ; Reset phaser
             RES  4,(HL)
             LD   HL,$0000
             LD   (CNT_1A),HL
             LD   H,(IX+$03)
             LD   (CNT_1B),HL
             JR   READ_LOOP

SET_NOTE2:   LD   (DIV_2),DE
             LD   A,IYH
             LD   HL,OUT_2
             RES  4,(HL)
             LD   HL,$0000
             LD   (CNT_2),HL
             JP   READ_LOOP

SET_STOP:    LD   HL,$0000
             LD   A,IYL
             OR   A
             JR   NZ,SET_STOP2
             ; Stop channel 1 note
             LD   (DIV_1A),HL
             LD   (DIV_1B),HL
             LD   HL,OUT_1
             RES  4,(HL)
             LD   IYL,1
             JP   READ_LOOP
SET_STOP2:
             ; Stop channel 2 note
             LD   (DIV_2),HL
             LD   HL,OUT_2
             RES  4,(HL)
             JP   READ_LOOP

OTHER:       CP   $3C
             JR   Z,SET_STOP                   ; Stop note
             CP   $3E
             JR   Z,SKIP_CH1                   ; No changes to channel 1
             INC  HL                           ; Instrument change
             LD   L,(HL)
             LD   H,$00
             ADD  HL,HL
             LD   DE,(NOTE_PTR)
             INC  DE
             LD   (NOTE_PTR),DE                ; Increment the note pointer
             DEFB $01                          ; LD BC,nn
INSTRUM_TBL: DEFW $0000
             ADD  HL,BC
             LD   (CURRENT_INST),HL
             JP   READ_LOOP
SKIP_CH1:    LD   IYL,$01
             JP   READ_LOOP

EXIT_PLAYER: LD   	HL, $2758
             EXX
             POP  	IY
             EI
	     jp		begin

RENDER:	     AND  	$7F                          ; L813A
             CP   	$76
             JP   	NC,DRUMS
             LD   	D,A
             EXX
             DEFB 	$21                          ; LD HL,nn
CNT_1A:      DEFW 	$0000
             DEFB 	$DD, $21                      ; LD IX,nn
CNT_1B:      DEFW 	$0000
             DEFB 	$01                          ; LD BC,nn
DIV_1A:      DEFW 	$0000
             DEFB 	$11                          ; LD DE,nn
DIV_1B:      DEFW 	$0000
             DEFB 	$3E                          ; LD A,n
OUT_1:       DEFB 	$0
             EXX
             EX   	AF, AF'
             DEFB 	$21                          ; LD HL,nn
CNT_2:       DEFW 	$0000
             DEFB 	$01                          ; LD BC,nn
DIV_2:       DEFW 	$0000
             DEFB 	$3E                          ; LD A,n
OUT_2:       DEFB 	$00
PLAY_NOTE:
				             ; Read keyboard
        LD   	E,A
	XOR  	A
keyM:	ld 	a, (0x68EF)			// M
	and	$20
	jr	nz, wait_key_cont:

	LD 	HL,$2758			; restart
	EXX
        POP	IY
        EI	
        JP	cls

wait_key_cont:LD   A,E
	LD   	E,0
L8168:  EXX
        EX   	AF,AF'
        ADD  	HL,BC
	LD   	($6800), A

             JR   C,L8171
             JR   L8173
L8171:       XOR  $20
L8173:       ADD  IX,DE
             JR   C,L8179
             JR   L817B
L8179:       XOR  $20
L817B:       EX   AF,AF'


             LD   ($6800), A

             EXX
             ADD  HL,BC
             JR   C,L8184
             JR   L8186
L8184:       XOR  $20
L8186:       NOP
             JP   L818A

L818A:       EXX
             EX   AF,AF'
             ADD  HL,BC
             LD   ($6800), A


             JR   C,L8193
             JR   L8195
L8193:       XOR  $20
L8195:       ADD  IX,DE
             JR   C,L819B
             JR   L819D
L819B:       XOR  $20
L819D:       EX   AF,AF'

             LD   ($6800), A

             EXX
             ADD  HL,BC
             JR   C,L81A6
             JR   L81A8
L81A6:       XOR  $20
L81A8:       NOP
             JP   L81AC

L81AC:       EXX
             EX   AF,AF'
             ADD  HL,BC

             LD   ($6800), A

             JR   C,L81B5
             JR   L81B7
L81B5:       XOR  $20
L81B7:       ADD  IX,DE
             JR   C,L81BD
             JR   L81BF
L81BD:       XOR  $20
L81BF:       EX   AF,AF'

             LD   ($6800), A

             EXX
             ADD  HL,BC
             JR   C,L81C8
             JR   L81CA
L81C8:       XOR  $20
L81CA:       NOP
             JP   L81CE

L81CE:       EXX
             EX   AF,AF'
             ADD  HL,BC

             LD   ($6800), A

             JR   C,L81D7
             JR   L81D9
L81D7:       XOR  $20
L81D9:       ADD  IX,DE
             JR   C,L81DF
             JR   L81E1
L81DF:       XOR  $20
L81E1:       EX   AF,AF'

             LD   ($6800), A

             EXX
             ADD  HL,BC
             JR   C,L81EA
             JR   L81EC
L81EA:       XOR  $20

L81EC:       DEC  E
             JP   NZ,L8168

             EXX
             EX   AF,AF'
             ADD  HL,BC

             LD   ($6800), A

             JR   C,L81F9
             JR   L81FB
L81F9:       XOR  $20
L81FB:       ADD  IX,DE
             JR   C,L8201
             JR   L8203
L8201:       XOR  $20
L8203:       EX   AF,AF'

             LD   ($6800), A

             EXX
             ADD  HL,BC
             JR   C,L820C
             JR   L820E
L820C:       XOR  $20

L820E:       DEC  D
             JP   NZ,PLAY_NOTE

             LD   (CNT_2),HL
             LD   (OUT_2),A
             EXX
             EX   AF,AF'
             LD   (CNT_1A),HL
             LD   (CNT_1B),IX
             LD   (OUT_1),A
             JP   MAIN_LOOP

; ************************************************************
; * DRUMS - Synthesised
; ************************************************************
DRUMS:
             ADD  A,A                          ; On entry A=$75+Drum number (i.e. $76 to $7E)
             LD   B,0
             LD   C,A
             LD   HL,DRUM_TABLE - 236
             ADD  HL,BC
             LD   E,(HL)
             INC  HL
             LD   D,(HL)
             EX   DE,HL
             JP   (HL)

DRUM_TONE1:  LD   L,16
             JR   DRUM_TONE
DRUM_TONE2:  LD   L,12
             JR   DRUM_TONE
DRUM_TONE3:  LD   L,8
             JR   DRUM_TONE
DRUM_TONE4:  LD   L,6
             JR   DRUM_TONE
DRUM_TONE5:  LD   L,4
             JR   DRUM_TONE
DRUM_TONE6:  LD   L,2
DRUM_TONE:
             LD   DE,3700
             LD   BC,$0101
             LD   A,BORDER_COL
DT_LOOP0:    
             LD   ($6800), A

             DEC  B
             JR   NZ,DT_LOOP1
             XOR  $20
             LD   B,C
             EX   AF,AF'
             LD   A,C
             ADD  A,L
             LD   C,A
             EX   AF,AF'
DT_LOOP1:    DEC  E
             JR   NZ,DT_LOOP0
             DEC  D
             JR   NZ,DT_LOOP0
             JP   MAIN_LOOP

DRUM_NOISE1: LD   DE,2480
             LD   IXL,1
             JR   DRUM_NOISE
DRUM_NOISE2: LD   DE,1070
             LD   IXL,10
             JR   DRUM_NOISE
DRUM_NOISE3: LD   DE,365
             LD   IXL,101
DRUM_NOISE:
             LD   H,D
             LD   L,E
             LD   A,BORDER_COL
             LD   C,A
DN_LOOP0:    LD   A,(HL)
             AND  $21
             OR   C

             LD   ($6800), A

             LD   B,IXL
DN_LOOP1:    DJNZ DN_LOOP1
             INC  HL
             DEC  E
             JR   NZ,DN_LOOP0
             DEC  D
             JR   NZ,DN_LOOP0
             JP   MAIN_LOOP




; #######################################################################
; #######################################################################
do_intro:

	di

	ld	a, 8
	ld	($6800), a



;// -------------------------------------------- 
;// Horizontal SPLIT-IN screen effect            
;// -------------------------------------------- 
;
;	SCREEN LOCATION IN MEMORY AT intro_screen
; 	SCREEN DUMPED TO VIDEO AT $7000
;
;	for(i=1;i<1024+32;i=i+32){ 		
;	   memcpy(0x7800-i+1,0xe000+1024,i);
;	   memcpy(0x7000    ,0xe000+1024-i+1,i);
;	   for(j=0;j<200;j++){}
;	}

	ld	ix, 0
	ld	a, 0
splitin1:cp	32			; for(i=1;i<1024+32;i=i+32){ 		
	jr	z, splitin2
	inc	a
	push	ix
	pop	hl
	push	bc
	ld	bc, 32
	add	hl, bc
	pop	bc
	push	hl
	pop	ix			; ix=ix+32
	LD 	hl,0x6800
spltin1:BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,spltin1
	LD 	hl,0x6800
spltin2:BIT 	7,(hl)			; fancy wait retrace.
	jr	Z,spltin2
	ld	de, $7000
	ld	hl, intro_screen+1024 	;	   memcpy(0x7000    ,0xe000+1024-i+1,i);
	push	ix
	pop	bc
	sbc	hl, bc
	push	ix
	pop	bc
	ldir
	ld	hl, $7800		;	   memcpy(0x7800-i+1,0xe000+1024,i);
	push	ix
	pop	bc
	sbc	hl, bc
	inc	l
	push	hl
	pop	de
	ld	hl, intro_screen + 1025
	push	ix
	pop	bc
	ldir
	jr	splitin1
splitin2:
	
	LD 	BC, $fffe
	CALL 	$0060		; delay
	LD 	BC, $fffe
	CALL 	$0060		; delay
	LD 	BC, $fffe
	CALL 	$0060		; delay

;
;// -------------------------------------------- 
;// Horizontal SPLIT-OUT screen effect           
;// -------------------------------------------- 
;
;	SCREEN LOCATION IN MEMORY AT intro_screen
; 	SCREEN DUMPED TO VIDEO AT $7000
;
;	for(i=0;i<32;i++){
;		memcpy(0x7000   , 0xE000+(i*32)+32,1024-32-(i*32));
;	   	memset (0x7000+(1024-32-(i*32)), 255,32);
;		memcpy(0x7400+(i*32)   , 0xE400, 1024-(i*32));
;	   	memset (0x7400-32+(i*32), 255,32);

	ld	ix, 0
	ld	a, 0
splout1:cp	30
	jr	z, splout2
	inc	a	
	push	ix
	pop	hl
	push	bc
	ld	bc, 32
	add	hl, bc
	pop	bc
	push	hl
	pop	ix			; ix=ix+32
	LD 	hl,0x6800
sptout1:BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,sptout1
	LD 	hl,0x6800
sptout2:BIT 	7,(hl)			; fancy wait retrace.
	jr	Z,sptout2

; memcpy(0x7000   , 0xE000+(i*32)+32,1024-32-(i*32));
	ld	hl, intro_screen+32	
	push	ix
	pop	bc
	add	hl, bc
	push	hl
	ld	hl, 1024-32
	push	ix
	pop	bc
	sbc	hl, bc
	push	hl
	pop	bc
	pop	hl
	ld	de, $7000		
	ldir
	
; memset (0x7000+(1024-32-(i*32)), 255,32);
	ld	hl, 1024-32	
	push	ix
	pop	bc
	sbc	hl, bc
	ld	bc, $7000
	add	hl, bc
	ld	(hl), 255
	push	hl
	pop	de
	inc	de
	ld	bc, 32
	ldir

; memcpy(0x7400+(i*32)   , 0xE400, 1024-(i*32));
	ld	hl, $7000+1024
	push	ix
	pop	bc
	add	hl, bc
	push	hl
	ld	hl, 1024
	push	ix
	pop	bc
	sbc	hl, bc
	push	hl
	pop	bc
	ld	hl, intro_screen+1024	; mid screen
	pop	de
	ldir
	
; memset (0x7400-32+(i*32), 255,32);
	ld	hl, $7000+1024-64	
	push	ix
	pop	bc
	add	hl, bc
	ld	(hl), 255
	push	hl
	pop	de
	inc	de
	ld	bc, 32
	ldir
	jr	splout1
splout2:
	ret



;=================================================================



PATTERN_ADDR:   DEFW  $0000
PATTERN_PTR:    DEFB  0
NOTE_PTR:       DEFW  $0000

; **************************************************************
; * Frequency Table
; **************************************************************
FREQ_TABLE:
             DEFW 178,189,200,212,225,238,252,267,283,300,318,337
             DEFW 357,378,401,425,450,477,505,535,567,601,637,675
             DEFW 715,757,802,850,901,954,1011,1071,1135,1202,1274,1350
             DEFW 1430,1515,1605,1701,1802,1909,2023,2143,2270,2405,2548,2700
             DEFW 2860,3030,3211,3402,3604,3818,4046,4286,4541,4811,5097,5400

; *****************************************************************
; * Synth Drum Lookup Table
; *****************************************************************
DRUM_TABLE:
             DEFW DRUM_TONE1,DRUM_TONE2,DRUM_TONE3,DRUM_TONE4,DRUM_TONE5,DRUM_TONE6
             DEFW DRUM_NOISE1,DRUM_NOISE2,DRUM_NOISE3






;1  a
;2  b
;3  c
;4  d
;5  e
;6  f
;7  g
;8  h
;9  i
;10 j
;11 k
;12 l
;13 m
;14 n
;15 o
;16 p
;17 q
;18 r
;19 s
;20 t
;21 u
;22 v
;23 w
;24 x
;25 y
;26 z
		; dw destination
		; db song_title_length , song_title_inversed
SONG1INV:  dw 	28672+4*32+3
	   db  	20, 12,1,26,5,18,32,16,15,23,5,18,32,18,15,21,12,5,20,20,5
SONG2INV:  dw	28672+5*32+3
	   db	05, 16,25,12,15,14
SONG3INV:  dw	28672+6*32+3
	   db	12,  22,5,5,2,12,5,6,5,20,26,5,18
SONG4INV:  dw	28672+7*32+3
	   db 	16,  4,1,25,32,1,20,32,20,8,5,32,2,5,1,3,8
SONG5INV:  dw	28672+8*32+3
	   db 	10,  3,15,14,20,9,14,5,14,3,5
SPEAKINV:  dw   28672+10*32+18				; SPEAKER
	   db	8, 19,16,5,1,11,5,18,32
CASSEINV:  dw   28672+11*32+18				; CASSETTE PORT
	   db   13,  3,1,19,19,5,20,20,5,32,16,15,18,20

speaker_or_cas	db 0
outdevice		db 33



MSG1 	db	$d, "       PHASER-1 MUSICBOX 4"
	db	$d, "          (SYNTH DRUMS)"
	db 	$d, "SELECT:  "
	db 	$d,"1: LAZER POWER ROULETTE"
	db	0

MSG2	db 	$d,"2: PYLON" 
	db 	$d,"3: VEEBLEFETZER"
	db	$d,"4: DAY AT THE BEACH"   
	db 	$d,"5: CONTINENCE"
	db	0

MSG3:	db	$d
	db	$d,"M: MENU "
	db	$d,"Q: QUIT "
	db	$d,32,32
	db	0





;===================================================================
SONG1:				; lazer_power_lesbian_space_dildo_roulette
;===================================================================

             DEFB 0  ; Pattern loop begin * 2
             DEFB 80  ; Song length * 2
             DEFW 4         ; Offset to start of song (length of instrument table)
             DEFB 0      ; Multiple
             DEFW 2      ; Detune
             DEFB 3      ; Phase

PATTERNDATAa:       DEFW      PAT0a
                    DEFW      PAT1a
                    DEFW      PAT0a
                    DEFW      PAT1a
                    DEFW      PAT3a
                    DEFW      PAT2a
                    DEFW      PAT4a
                    DEFW      PAT5a
                    DEFW      PAT6a
                    DEFW      PAT7a
                    DEFW      PAT8a
                    DEFW      PAT5a
                    DEFW      PAT9a
                    DEFW      PAT10a
                    DEFW      PAT11a
                    DEFW      PAT12a
                    DEFW      PAT12a
                    DEFW      PAT13a
                    DEFW      PAT13a
                    DEFW      PAT3a
                    DEFW      PAT5a
                    DEFW      PAT6a
                    DEFW      PAT5a
                    DEFW      PAT9a
                    DEFW      PAT0a
                    DEFW      PAT1a
                    DEFW      PAT2a
                    DEFW      PAT4a
                    DEFW      PAT14a
                    DEFW      PAT15a
                    DEFW      PAT16a
                    DEFW      PAT17a
                    DEFW      PAT14a
                    DEFW      PAT15a
                    DEFW      PAT16a
                    DEFW      PAT17a
                    DEFW      PAT18a
                    DEFW      PAT19a
                    DEFW      PAT20a
                    DEFW      PAT21a

; *** Pattern data - $00 marks the end of a pattern ***
PAT0a:
         DEFB $BD,0
         DEFB 196
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 157
     DEFB 3
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 164
     DEFB 3
         DEFB 190
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 157
     DEFB 3
         DEFB 190
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 164
     DEFB 3
         DEFB 190
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 157
     DEFB 3
         DEFB 190
         DEFB 164
     DEFB 3
         DEFB $00
PAT1a:
         DEFB $BD,0
         DEFB 194
         DEFB 154
     DEFB 3
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 164
     DEFB 3
         DEFB 190
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 154
     DEFB 3
         DEFB 190
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 164
     DEFB 3
         DEFB 190
         DEFB 163
     DEFB 3
         DEFB $00
PAT2a:
         DEFB $BD,0
         DEFB 156
         DEFB 180
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 175
     DEFB 3
         DEFB 132
         DEFB 168
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 175
     DEFB 3
         DEFB 156
         DEFB 180
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 175
     DEFB 3
         DEFB 132
         DEFB 168
         DEFB 124
     DEFB 2
         DEFB 190
         DEFB 175
     DEFB 3
         DEFB 154
         DEFB 178
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 173
     DEFB 3
         DEFB 130
         DEFB 166
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 173
     DEFB 3
         DEFB 154
         DEFB 178
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 173
     DEFB 3
         DEFB 130
         DEFB 178
         DEFB 124
     DEFB 2
         DEFB 190
         DEFB 173
     DEFB 3
         DEFB $00
PAT3a:
         DEFB $BD,0
         DEFB 218
         DEFB 142
     DEFB 24
         DEFB 190
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 2
         DEFB $00
PAT4a:
         DEFB 164
         DEFB 152
         DEFB 118
     DEFB 2
         DEFB 151
         DEFB 118
     DEFB 2
         DEFB 166
         DEFB 142
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 118
     DEFB 2
         DEFB 164
         DEFB 152
         DEFB 118
     DEFB 2
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB 163
         DEFB 139
         DEFB 123
     DEFB 2
         DEFB 149
         DEFB 124
     DEFB 2
         DEFB 164
         DEFB 152
         DEFB 118
     DEFB 5
         DEFB 163
         DEFB 139
         DEFB 118
     DEFB 2
         DEFB 151
     DEFB 3
         DEFB 161
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB 149
         DEFB 123
     DEFB 2
         DEFB 163
         DEFB 139
         DEFB 118
     DEFB 2
         DEFB 151
         DEFB 125
     DEFB 2
         DEFB $00
PAT5a:
         DEFB 147
         DEFB 183
     DEFB 6
         DEFB 159
         DEFB 178
     DEFB 6
         DEFB 147
         DEFB 176
     DEFB 6
         DEFB 159
         DEFB 175
     DEFB 6
         DEFB 145
         DEFB 183
     DEFB 6
         DEFB 157
         DEFB 187
     DEFB 6
         DEFB 145
         DEFB 186
     DEFB 6
         DEFB 157
         DEFB 187
     DEFB 6
         DEFB $00
PAT6a:
         DEFB 143
         DEFB 186
     DEFB 6
         DEFB 155
         DEFB 183
     DEFB 6
         DEFB 143
         DEFB 182
     DEFB 6
         DEFB 155
         DEFB 180
     DEFB 6
         DEFB 142
         DEFB 178
     DEFB 6
         DEFB 154
         DEFB 182
     DEFB 6
         DEFB 142
         DEFB 185
     DEFB 6
         DEFB 154
         DEFB 182
     DEFB 6
         DEFB $00
PAT7a:
         DEFB 242
         DEFB 163
     DEFB 3
         DEFB 176
         DEFB 139
     DEFB 3
         DEFB 175
         DEFB 151
     DEFB 3
         DEFB 176
         DEFB 139
     DEFB 3
         DEFB 175
         DEFB 163
     DEFB 3
         DEFB 173
         DEFB 139
     DEFB 3
         DEFB 175
         DEFB 151
     DEFB 3
         DEFB 173
         DEFB 139
     DEFB 3
         DEFB 171
         DEFB 161
     DEFB 3
         DEFB 173
         DEFB 137
     DEFB 3
         DEFB 171
         DEFB 149
     DEFB 3
         DEFB 173
         DEFB 137
     DEFB 3
         DEFB 175
         DEFB 161
     DEFB 3
         DEFB 176
         DEFB 137
     DEFB 3
         DEFB 175
         DEFB 149
     DEFB 3
         DEFB 176
         DEFB 137
     DEFB 3
         DEFB $00
PAT8a:
         DEFB 180
         DEFB 158
     DEFB 3
         DEFB 168
         DEFB 134
     DEFB 3
         DEFB 175
         DEFB 146
     DEFB 3
         DEFB 171
         DEFB 134
     DEFB 3
         DEFB 173
         DEFB 158
     DEFB 3
         DEFB 168
         DEFB 134
     DEFB 3
         DEFB 175
         DEFB 146
     DEFB 3
         DEFB 173
         DEFB 134
     DEFB 3
         DEFB 180
         DEFB 161
     DEFB 3
         DEFB 169
         DEFB 137
     DEFB 3
         DEFB 176
         DEFB 149
     DEFB 3
         DEFB 170
         DEFB 137
     DEFB 3
         DEFB 178
         DEFB 161
     DEFB 3
         DEFB 166
         DEFB 137
     DEFB 3
         DEFB 175
         DEFB 149
     DEFB 3
         DEFB 170
         DEFB 137
     DEFB 3
         DEFB $00
PAT9a:
         DEFB 139
         DEFB 187
     DEFB 6
         DEFB 151
         DEFB 185
     DEFB 6
         DEFB 139
         DEFB 183
     DEFB 6
         DEFB 151
         DEFB 182
     DEFB 6
         DEFB 137
         DEFB 185
     DEFB 6
         DEFB 149
         DEFB 187
     DEFB 6
         DEFB 137
         DEFB 182
     DEFB 6
         DEFB 149
         DEFB 185
     DEFB 6
         DEFB $00
PAT10a:
         DEFB 170
         DEFB 146
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 168
         DEFB 142
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB $00
PAT11a:
         DEFB 173
         DEFB 153
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 171
     DEFB 1
         DEFB 173
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 171
     DEFB 1
         DEFB 173
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 171
     DEFB 1
         DEFB 173
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 171
     DEFB 1
         DEFB 173
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 171
     DEFB 1
         DEFB 173
     DEFB 1
         DEFB 168
         DEFB 149
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 170
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB 165
     DEFB 1
         DEFB 166
     DEFB 1
         DEFB 168
     DEFB 1
         DEFB $00
PAT12a:
         DEFB 156
         DEFB 159
         DEFB 118
         DEFB 188
     DEFB 1
         DEFB 156
     DEFB 1
         DEFB 188
     DEFB 1
         DEFB 156
         DEFB 147
         DEFB 118
     DEFB 3
         DEFB 156
         DEFB 159
         DEFB 118
         DEFB 188
     DEFB 1
         DEFB 156
     DEFB 1
         DEFB 188
     DEFB 1
         DEFB 156
         DEFB 147
         DEFB 118
     DEFB 3
         DEFB 159
         DEFB 159
         DEFB 118
         DEFB 188
     DEFB 1
         DEFB 159
     DEFB 1
         DEFB 188
     DEFB 1
         DEFB 159
         DEFB 147
         DEFB 118
     DEFB 3
         DEFB 154
         DEFB 159
         DEFB 118
         DEFB 188
     DEFB 1
         DEFB 154
     DEFB 1
         DEFB 188
     DEFB 1
         DEFB 154
         DEFB 147
         DEFB 118
     DEFB 3
         DEFB 163
         DEFB 158
         DEFB 118
         DEFB 188
     DEFB 1
         DEFB 163
     DEFB 1
         DEFB 188
     DEFB 1
         DEFB 163
         DEFB 146
         DEFB 118
     DEFB 3
         DEFB 159
         DEFB 158
         DEFB 118
         DEFB 188
     DEFB 1
         DEFB 159
     DEFB 1
         DEFB 188
     DEFB 1
         DEFB 159
         DEFB 146
         DEFB 118
     DEFB 3
         DEFB 161
         DEFB 158
         DEFB 118
         DEFB 188
     DEFB 1
         DEFB 161
     DEFB 1
         DEFB 188
     DEFB 1
         DEFB 161
         DEFB 146
         DEFB 118
     DEFB 3
         DEFB 158
         DEFB 158
         DEFB 118
         DEFB 188
     DEFB 1
         DEFB 158
     DEFB 1
         DEFB 188
     DEFB 1
         DEFB 158
         DEFB 146
         DEFB 118
     DEFB 3
         DEFB $00
PAT13a:
         DEFB 203
         DEFB 163
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 163
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 161
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 161
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 137
         DEFB 163
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 164
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 163
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 164
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 161
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 161
         DEFB 118
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 1
         DEFB $00
PAT14a:
         DEFB 132
         DEFB 144
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 122
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 122
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 122
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 122
     DEFB 5
         DEFB $00
PAT15a:
         DEFB 135
         DEFB 147
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 120
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 120
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 120
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 120
     DEFB 5
         DEFB $00
PAT16a:
         DEFB 139
         DEFB 151
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 120
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 120
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 120
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 120
     DEFB 5
         DEFB $00
PAT17a:
         DEFB 137
         DEFB 149
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 121
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 121
     DEFB 5
         DEFB 190
         DEFB 118
     DEFB 5
         DEFB 190
         DEFB 121
     DEFB 5
         DEFB 190
         DEFB 122
     DEFB 2
         DEFB 190
         DEFB 123
     DEFB 2
         DEFB 190
         DEFB 122
     DEFB 2
         DEFB 190
         DEFB 123
     DEFB 2
         DEFB $00
PAT18a:
         DEFB 139
         DEFB 156
     DEFB 3
         DEFB 135
         DEFB 151
     DEFB 3
         DEFB 137
         DEFB 154
     DEFB 3
         DEFB 139
         DEFB 156
     DEFB 3
         DEFB 135
         DEFB 151
     DEFB 3
         DEFB 137
         DEFB 154
     DEFB 3
         DEFB 139
         DEFB 156
     DEFB 3
         DEFB 135
         DEFB 151
     DEFB 3
         DEFB 137
         DEFB 154
     DEFB 3
         DEFB 139
         DEFB 156
     DEFB 3
         DEFB 135
         DEFB 151
     DEFB 3
         DEFB 137
         DEFB 154
     DEFB 3
         DEFB 139
         DEFB 156
     DEFB 3
         DEFB 135
         DEFB 151
     DEFB 3
         DEFB 137
         DEFB 154
     DEFB 3
         DEFB 139
         DEFB 156
     DEFB 3
         DEFB $00
PAT19a:
         DEFB 132
         DEFB 188
         DEFB 124
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 2
         DEFB 190
         DEFB 126
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 2
         DEFB 190
         DEFB 126
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 2
         DEFB 190
         DEFB 124
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 2
         DEFB 190
         DEFB 124
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 2
         DEFB 190
         DEFB 126
     DEFB 2
         DEFB 190
         DEFB 126
     DEFB 2
         DEFB 190
         DEFB 126
     DEFB 5
         DEFB 190
         DEFB 126
     DEFB 5
         DEFB $00
PAT20a:
         DEFB 252
         DEFB 188
         DEFB 126
     DEFB 47
         DEFB $00
PAT21a:
         DEFB 252
         DEFB 188
     DEFB 48
         DEFB $00





;===================================================================
SONG2:					; Pylon
;===================================================================

             DEFB 0  ; Pattern loop begin * 2
             DEFB 80  ; Song length * 2
             DEFW 40         ; Offset to start of song (length of instrument table)
             DEFB 3      ; Multiple
             DEFW 3      ; Detune
             DEFB 4      ; Phase
             DEFB 1      ; Multiple
             DEFW 1      ; Detune
             DEFB 0      ; Phase
             DEFB 3      ; Multiple
             DEFW 2      ; Detune
             DEFB 0      ; Phase
             DEFB 2      ; Multiple
             DEFW 3      ; Detune
             DEFB 2      ; Phase
             DEFB 1      ; Multiple
             DEFW 0      ; Detune
             DEFB 3      ; Phase
             DEFB 4      ; Multiple
             DEFW 1      ; Detune
             DEFB 4      ; Phase
             DEFB 1      ; Multiple
             DEFW 1      ; Detune
             DEFB 5      ; Phase
             DEFB 3      ; Multiple
             DEFW 3      ; Detune
             DEFB 0      ; Phase
             DEFB 2      ; Multiple
             DEFW 1      ; Detune
             DEFB 2      ; Phase
             DEFB 1      ; Multiple
             DEFW 3      ; Detune
             DEFB 4      ; Phase

PATTERNDATAb:       DEFW      PAT0b
                    DEFW      PAT0b
                    DEFW      PAT0b
                    DEFW      PAT0b
                    DEFW      PAT1b
                    DEFW      PAT2b
                    DEFW      PAT3b
                    DEFW      PAT4b
                    DEFW      PAT5b
                    DEFW      PAT6b
                    DEFW      PAT7b
                    DEFW      PAT8b
                    DEFW      PAT9b
                    DEFW      PAT10b
                    DEFW      PAT11b
                    DEFW      PAT12b
                    DEFW      PAT11b
                    DEFW      PAT12b
                    DEFW      PAT1b
                    DEFW      PAT2b
                    DEFW      PAT4b
                    DEFW      PAT2b
                    DEFW      PAT1b
                    DEFW      PAT2b
                    DEFW      PAT15b
                    DEFW      PAT16b
                    DEFW      PAT5b
                    DEFW      PAT7b
                    DEFW      PAT8b
                    DEFW      PAT9b
                    DEFW      PAT17b
                    DEFW      PAT11b
                    DEFW      PAT12b
                    DEFW      PAT11b
                    DEFW      PAT13b
                    DEFW      PAT0b
                    DEFW      PAT0b
                    DEFW      PAT0b
                    DEFW      PAT0b
                    DEFW      PAT14b

; *** Pattern data - $00 marks the end of a pattern ***
PAT0b:
         DEFB $BD,2
         DEFB 152
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 152
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,6
         DEFB 164
         DEFB 152
     DEFB 3
         DEFB $BD,8
         DEFB 152
         DEFB 140
         DEFB 125
     DEFB 2
         DEFB $BD,10
         DEFB 152
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 164
         DEFB 152
     DEFB 3
         DEFB $BD,14
         DEFB 152
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 152
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,2
         DEFB 164
         DEFB 152
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 152
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 152
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 164
         DEFB 152
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 152
         DEFB 140
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 152
         DEFB 140
     DEFB 3
         DEFB $BD,14
         DEFB 164
         DEFB 152
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 152
         DEFB 140
     DEFB 3
         DEFB $00
PAT1b:
         DEFB $BD,0
         DEFB 168
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
         DEFB 149
     DEFB 3
         DEFB $BD,8
         DEFB 149
         DEFB 137
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 168
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 161
         DEFB 149
     DEFB 3
         DEFB $BD,14
         DEFB 149
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 173
         DEFB 149
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 161
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 149
         DEFB 137
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 149
         DEFB 137
     DEFB 3
         DEFB $BD,0
         DEFB 164
         DEFB 149
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 137
     DEFB 3
         DEFB $00
PAT2b:
         DEFB $BD,2
         DEFB 149
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,6
         DEFB 161
         DEFB 149
     DEFB 3
         DEFB $BD,8
         DEFB 149
         DEFB 137
         DEFB 125
     DEFB 2
         DEFB $BD,10
         DEFB 149
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 161
         DEFB 149
     DEFB 3
         DEFB $BD,14
         DEFB 149
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,2
         DEFB 161
         DEFB 149
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 161
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 149
         DEFB 137
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 149
         DEFB 137
     DEFB 3
         DEFB $BD,14
         DEFB 161
         DEFB 149
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 137
     DEFB 3
         DEFB $00
PAT3b:
         DEFB $BD,0
         DEFB 168
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
         DEFB 137
     DEFB 3
         DEFB $BD,8
         DEFB 149
         DEFB 149
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 168
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 161
         DEFB 137
     DEFB 3
         DEFB $BD,14
         DEFB 149
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
         DEFB 137
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 161
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 149
         DEFB 149
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 149
         DEFB 137
     DEFB 3
         DEFB $BD,0
         DEFB 168
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 149
     DEFB 3
         DEFB $00
PAT4b:
         DEFB $BD,0
         DEFB 166
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 168
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
         DEFB 149
     DEFB 3
         DEFB $BD,0
         DEFB 168
         DEFB 137
         DEFB 125
     DEFB 2
         DEFB $BD,10
         DEFB 149
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 161
         DEFB 137
     DEFB 3
         DEFB $BD,14
         DEFB 149
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,2
         DEFB 161
         DEFB 137
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 149
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 161
         DEFB 137
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 149
         DEFB 149
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 149
         DEFB 137
     DEFB 3
         DEFB $BD,14
         DEFB 161
         DEFB 137
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 149
     DEFB 3
         DEFB $00
PAT5b:
         DEFB $BD,18
         DEFB 176
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,2
         DEFB 152
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,18
         DEFB 178
         DEFB 152
     DEFB 3
         DEFB $BD,4
         DEFB 152
         DEFB 140
         DEFB 125
     DEFB 2
         DEFB $BD,18
         DEFB 179
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 152
         DEFB 152
     DEFB 3
         DEFB $BD,18
         DEFB 181
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,8
         DEFB 152
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,18
         DEFB 176
         DEFB 152
         DEFB 126
     DEFB 2
         DEFB $BD,10
         DEFB 152
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,18
         DEFB 178
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,12
         DEFB 152
         DEFB 152
         DEFB 118
     DEFB 2
         DEFB $BD,18
         DEFB 179
         DEFB 140
         DEFB 125
     DEFB 2
         DEFB $BD,14
         DEFB 152
         DEFB 140
     DEFB 3
         DEFB $BD,18
         DEFB 181
         DEFB 152
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 188
         DEFB 140
     DEFB 3
         DEFB $00
PAT6b:
         DEFB $BD,18
         DEFB 183
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,2
         DEFB 152
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,18
         DEFB 181
         DEFB 152
     DEFB 3
         DEFB $BD,4
         DEFB 152
         DEFB 140
         DEFB 125
     DEFB 2
         DEFB $BD,18
         DEFB 179
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 152
         DEFB 152
     DEFB 3
         DEFB $BD,18
         DEFB 178
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,8
         DEFB 152
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,18
         DEFB 183
         DEFB 152
         DEFB 126
     DEFB 2
         DEFB $BD,10
         DEFB 152
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB $BD,18
         DEFB 181
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,12
         DEFB 152
         DEFB 152
         DEFB 118
     DEFB 2
         DEFB $BD,18
         DEFB 179
         DEFB 140
         DEFB 125
     DEFB 2
         DEFB $BD,14
         DEFB 152
         DEFB 140
     DEFB 3
         DEFB $BD,18
         DEFB 178
         DEFB 152
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 152
         DEFB 140
     DEFB 3
         DEFB $00
PAT7b:
         DEFB $BD,2
         DEFB 152
         DEFB 176
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 152
         DEFB 179
         DEFB 124
     DEFB 2
         DEFB $BD,6
         DEFB 164
         DEFB 178
     DEFB 3
         DEFB $BD,8
         DEFB 152
         DEFB 179
         DEFB 125
     DEFB 2
         DEFB $BD,10
         DEFB 152
         DEFB 181
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 164
         DEFB 179
     DEFB 3
         DEFB $BD,14
         DEFB 152
         DEFB 178
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 152
         DEFB 179
         DEFB 124
     DEFB 2
         DEFB $BD,2
         DEFB 164
         DEFB 176
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 152
         DEFB 179
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 152
         DEFB 181
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 164
         DEFB 179
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 152
         DEFB 183
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 152
         DEFB 181
     DEFB 3
         DEFB $BD,14
         DEFB 164
         DEFB 179
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 152
         DEFB 178
     DEFB 3
         DEFB $00
PAT8b:
         DEFB $BD,2
         DEFB 152
         DEFB 183
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 152
         DEFB 181
         DEFB 124
     DEFB 2
         DEFB $BD,6
         DEFB 164
         DEFB 179
     DEFB 3
         DEFB $BD,8
         DEFB 152
         DEFB 178
         DEFB 125
     DEFB 2
         DEFB $BD,10
         DEFB 152
         DEFB 181
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 164
         DEFB 179
     DEFB 3
         DEFB $BD,14
         DEFB 152
         DEFB 178
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 152
         DEFB 176
         DEFB 124
     DEFB 2
         DEFB $BD,2
         DEFB 164
         DEFB 179
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 152
         DEFB 178
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 152
         DEFB 176
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 164
         DEFB 174
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 152
         DEFB 173
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 152
         DEFB 171
     DEFB 3
         DEFB $BD,14
         DEFB 164
         DEFB 169
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 152
         DEFB 167
     DEFB 3
         DEFB $00
PAT9b:
         DEFB $BD,0
         DEFB 168
         DEFB 185
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
         DEFB 188
     DEFB 3
         DEFB $BD,8
         DEFB 149
         DEFB 183
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 168
         DEFB 188
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 161
         DEFB 181
     DEFB 3
         DEFB $BD,14
         DEFB 149
         DEFB 188
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 180
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 188
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 149
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 161
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 149
         DEFB 181
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 149
         DEFB 180
     DEFB 3
         DEFB $BD,0
         DEFB 168
         DEFB 178
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 183
     DEFB 3
         DEFB $00
PAT10b:
         DEFB $BD,0
         DEFB 168
         DEFB 185
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 181
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
     DEFB 3
         DEFB $BD,8
         DEFB 149
         DEFB 180
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 168
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 161
         DEFB 188
     DEFB 3
         DEFB $BD,14
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 149
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 161
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 149
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 149
     DEFB 3
         DEFB $BD,0
         DEFB 168
         DEFB 176
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 149
     DEFB 3
         DEFB $00
PAT11b:
         DEFB $BD,2
         DEFB 152
         DEFB 179
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 190
         DEFB 178
         DEFB 124
     DEFB 2
         DEFB $BD,6
         DEFB 167
         DEFB 176
         DEFB 118
     DEFB 2
         DEFB $BD,8
         DEFB 190
         DEFB 188
         DEFB 123
     DEFB 2
         DEFB $BD,10
         DEFB 169
         DEFB 178
         DEFB 124
     DEFB 2
         DEFB $BD,12
         DEFB 190
         DEFB 188
         DEFB 125
     DEFB 2
         DEFB $BD,14
         DEFB 171
         DEFB 174
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 190
         DEFB 169
         DEFB 125
     DEFB 2
         DEFB $BD,2
         DEFB 174
         DEFB 188
         DEFB 124
     DEFB 2
         DEFB $BD,4
         DEFB 190
         DEFB 164
         DEFB 122
     DEFB 2
         DEFB $BD,6
         DEFB 175
         DEFB 167
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 190
         DEFB 188
         DEFB 120
     DEFB 2
         DEFB $BD,10
         DEFB 176
         DEFB 176
         DEFB 124
     DEFB 2
         DEFB $BD,12
         DEFB 190
         DEFB 174
         DEFB 125
     DEFB 2
         DEFB $BD,14
         DEFB 178
         DEFB 188
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 190
         DEFB 169
         DEFB 125
     DEFB 2
         DEFB $00
PAT12b:
         DEFB $BD,2
         DEFB 150
         DEFB 177
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 190
         DEFB 176
         DEFB 124
     DEFB 2
         DEFB $BD,6
         DEFB 165
         DEFB 174
     DEFB 3
         DEFB $BD,8
         DEFB 190
         DEFB 188
         DEFB 125
     DEFB 2
         DEFB $BD,10
         DEFB 167
         DEFB 176
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 190
         DEFB 188
     DEFB 3
         DEFB $BD,14
         DEFB 169
         DEFB 172
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 190
         DEFB 167
         DEFB 124
     DEFB 2
         DEFB $BD,2
         DEFB 172
         DEFB 188
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 190
         DEFB 162
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 173
         DEFB 165
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 190
         DEFB 188
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 174
         DEFB 174
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 190
         DEFB 172
     DEFB 3
         DEFB $BD,14
         DEFB 176
         DEFB 188
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 190
         DEFB 167
     DEFB 3
         DEFB $00
PAT13b:
         DEFB $BD,2
         DEFB 154
         DEFB 181
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 190
         DEFB 180
         DEFB 124
     DEFB 2
         DEFB $BD,6
         DEFB 169
         DEFB 178
     DEFB 3
         DEFB $BD,8
         DEFB 190
         DEFB 188
         DEFB 125
     DEFB 2
         DEFB $BD,10
         DEFB 171
         DEFB 180
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 190
         DEFB 188
     DEFB 3
         DEFB $BD,14
         DEFB 173
         DEFB 176
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 190
         DEFB 171
         DEFB 124
     DEFB 2
         DEFB $BD,2
         DEFB 176
         DEFB 188
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 190
         DEFB 166
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 177
         DEFB 169
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 190
         DEFB 188
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 178
         DEFB 178
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 190
         DEFB 176
     DEFB 3
         DEFB $BD,14
         DEFB 180
         DEFB 188
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 190
         DEFB 171
     DEFB 3
         DEFB $00
PAT14b:
         DEFB $BD,2
         DEFB 152
         DEFB 140
         DEFB 118
     DEFB 2
         DEFB 188
         DEFB 119
     DEFB 2
         DEFB 190
         DEFB 188
         DEFB 120
     DEFB 2
         DEFB $BD,2
         DEFB 152
         DEFB 140
         DEFB 121
     DEFB 2
         DEFB 190
         DEFB 122
     DEFB 2
         DEFB 190
         DEFB 188
         DEFB 123
     DEFB 2
         DEFB $BD,4
         DEFB 164
         DEFB 140
         DEFB 124
     DEFB 2
         DEFB $BD,6
         DEFB 190
     DEFB 3
         DEFB $BD,8
         DEFB 190
         DEFB 126
     DEFB 2
         DEFB $BD,10
         DEFB 152
         DEFB 140
         DEFB 126
     DEFB 2
         DEFB $BD,12
         DEFB 190
         DEFB 126
     DEFB 2
         DEFB $BD,14
         DEFB 190
         DEFB 188
         DEFB 126
     DEFB 2
         DEFB $BD,16
         DEFB 190
         DEFB 126
     DEFB 2
         DEFB $BD,18
         DEFB 188
         DEFB 126
     DEFB 8
         DEFB $00
PAT15b:
         DEFB $BD,0
         DEFB 164
         DEFB 135
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 166
         DEFB 135
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 167
         DEFB 147
     DEFB 3
         DEFB $BD,0
         DEFB 166
         DEFB 135
         DEFB 125
     DEFB 2
         DEFB $BD,10
         DEFB 147
         DEFB 135
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 159
         DEFB 135
     DEFB 3
         DEFB $BD,14
         DEFB 147
         DEFB 147
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 147
         DEFB 135
         DEFB 124
     DEFB 2
         DEFB $BD,2
         DEFB 159
         DEFB 135
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 147
         DEFB 147
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 147
         DEFB 135
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 159
         DEFB 135
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 147
         DEFB 147
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 147
         DEFB 135
     DEFB 3
         DEFB $BD,14
         DEFB 159
         DEFB 135
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 147
         DEFB 147
     DEFB 3
         DEFB $00
PAT16b:
         DEFB $BD,2
         DEFB 151
         DEFB 139
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 151
         DEFB 139
         DEFB 124
     DEFB 2
         DEFB $BD,6
         DEFB 163
         DEFB 151
     DEFB 3
         DEFB $BD,8
         DEFB 151
         DEFB 139
         DEFB 125
     DEFB 2
         DEFB $BD,10
         DEFB 151
         DEFB 139
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 163
         DEFB 151
     DEFB 3
         DEFB $BD,14
         DEFB 151
         DEFB 139
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 151
         DEFB 139
         DEFB 124
     DEFB 2
         DEFB $BD,2
         DEFB 163
         DEFB 151
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 151
         DEFB 139
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 151
         DEFB 139
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 163
         DEFB 151
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 151
         DEFB 139
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 151
         DEFB 139
     DEFB 3
         DEFB $BD,14
         DEFB 163
         DEFB 151
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 151
         DEFB 139
     DEFB 3
         DEFB $00
PAT17b:
         DEFB $BD,0
         DEFB 168
         DEFB 187
         DEFB 118
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 185
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
     DEFB 3
         DEFB $BD,8
         DEFB 149
         DEFB 180
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 168
         DEFB 118
     DEFB 2
         DEFB $BD,12
         DEFB 161
         DEFB 188
     DEFB 3
         DEFB $BD,14
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,16
         DEFB 149
         DEFB 124
     DEFB 2
         DEFB $BD,0
         DEFB 169
         DEFB 126
     DEFB 2
         DEFB $BD,4
         DEFB 149
         DEFB 118
     DEFB 2
         DEFB $BD,6
         DEFB 149
         DEFB 124
     DEFB 2
         DEFB $BD,8
         DEFB 161
         DEFB 118
     DEFB 2
         DEFB $BD,10
         DEFB 149
         DEFB 125
     DEFB 2
         DEFB $BD,12
         DEFB 149
     DEFB 3
         DEFB $BD,0
         DEFB 168
         DEFB 176
         DEFB 124
     DEFB 2
         DEFB $BD,16
         DEFB 149
     DEFB 3
         DEFB $00



;===================================================================
SONG3:						; Veeblefetzer
;===================================================================

             DEFB 0  ; Pattern loop begin * 2
             DEFB 88  ; Song length * 2
             DEFW 28         ; Offset to start of song (length of instrument table)
             DEFB 3      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 1      ; Multiple
             DEFW 6      ; Detune
             DEFB 0      ; Phase
             DEFB 2      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 4      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 5      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 1      ; Multiple
             DEFW 14      ; Detune
             DEFB 0      ; Phase
             DEFB 10      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase

PATTERNDATAc:       DEFW      PAT0c
                    DEFW      PAT1c
                    DEFW      PAT0c
                    DEFW      PAT2c
                    DEFW      PAT3c
                    DEFW      PAT4c
                    DEFW      PAT3c
                    DEFW      PAT5c
                    DEFW      PAT6c
                    DEFW      PAT7c
                    DEFW      PAT8c
                    DEFW      PAT9c
                    DEFW      PAT10c
                    DEFW      PAT11c
                    DEFW      PAT10c
                    DEFW      PAT12c
                    DEFW      PAT13c
                    DEFW      PAT14c
                    DEFW      PAT13c
                    DEFW      PAT15c
                    DEFW      PAT16c
                    DEFW      PAT17c
                    DEFW      PAT16c
                    DEFW      PAT18c
                    DEFW      PAT6c
                    DEFW      PAT7c
                    DEFW      PAT8c
                    DEFW      PAT9c
                    DEFW      PAT19c
                    DEFW      PAT20c
                    DEFW      PAT21c
                    DEFW      PAT22c
                    DEFW      PAT3c
                    DEFW      PAT4c
                    DEFW      PAT3c
                    DEFW      PAT5c
                    DEFW      PAT16c
                    DEFW      PAT17c
                    DEFW      PAT16c
                    DEFW      PAT17c
                    DEFW      PAT23c
                    DEFW      PAT24c
                    DEFW      PAT23c
                    DEFW      PAT25c

; *** Pattern data - $00 marks the end of a pattern ***
PAT0c:
         DEFB 188
         DEFB 163
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 175
     DEFB 2
         DEFB $BD,2
         DEFB 178
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 175
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 4
         DEFB 190
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 175
         DEFB 124
     DEFB 1
         DEFB 182
         DEFB 163
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 187
         DEFB 175
     DEFB 2
         DEFB 180
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 4
         DEFB 188
         DEFB 170
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 182
     DEFB 2
         DEFB 190
         DEFB 154
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 166
         DEFB 124
     DEFB 1
         DEFB $00
PAT1c:
         DEFB 190
         DEFB 154
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 166
     DEFB 2
         DEFB $BD,2
         DEFB 182
         DEFB 178
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
         DEFB 123
     DEFB 1
         DEFB 180
         DEFB 166
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 178
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 166
         DEFB 166
         DEFB 124
     DEFB 1
         DEFB 178
         DEFB 153
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
         DEFB 165
         DEFB 124
     DEFB 1
         DEFB 180
         DEFB 177
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
         DEFB 153
     DEFB 2
         DEFB 183
         DEFB 152
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
         DEFB 164
     DEFB 2
         DEFB 182
         DEFB 176
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
         DEFB 164
         DEFB 124
     DEFB 1
         DEFB $00
PAT2c:
         DEFB 190
         DEFB 154
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 166
     DEFB 2
         DEFB $BD,2
         DEFB 182
         DEFB 178
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
         DEFB 123
     DEFB 1
         DEFB 180
         DEFB 166
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 178
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 178
         DEFB 166
         DEFB 124
     DEFB 1
         DEFB 180
         DEFB 188
         DEFB 122
     DEFB 3
         DEFB 188
         DEFB 122
     DEFB 1
         DEFB 182
         DEFB 122
     DEFB 3
         DEFB 188
     DEFB 2
         DEFB 185
         DEFB 122
     DEFB 3
         DEFB 164
         DEFB 124
     DEFB 1
         DEFB 183
         DEFB 122
     DEFB 3
         DEFB 188
         DEFB 122
     DEFB 1
         DEFB $00
PAT3c:
         DEFB $BD,2
         DEFB 175
         DEFB 139
         DEFB 119
     DEFB 3
         DEFB 190
         DEFB 151
     DEFB 2
         DEFB $BD,0
         DEFB 154
         DEFB 163
         DEFB 124
     DEFB 3
         DEFB $BD,2
         DEFB 182
         DEFB 188
     DEFB 2
         DEFB 178
         DEFB 151
         DEFB 126
     DEFB 3
         DEFB $BD,0
         DEFB 151
         DEFB 188
     DEFB 2
         DEFB $BD,2
         DEFB 182
         DEFB 163
         DEFB 124
     DEFB 3
         DEFB 180
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB 182
         DEFB 139
         DEFB 119
     DEFB 3
         DEFB $BD,0
         DEFB 175
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB $BD,0
         DEFB 180
         DEFB 163
         DEFB 119
     DEFB 3
         DEFB 166
         DEFB 188
     DEFB 2
         DEFB $BD,0
         DEFB 158
         DEFB 146
         DEFB 126
     DEFB 3
         DEFB $BD,2
         DEFB 178
         DEFB 158
     DEFB 2
         DEFB 180
         DEFB 130
         DEFB 124
     DEFB 3
         DEFB 182
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $00
PAT4c:
         DEFB $BD,2
         DEFB 182
         DEFB 130
         DEFB 119
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 182
         DEFB 142
     DEFB 2
         DEFB $BD,0
         DEFB 158
         DEFB 154
         DEFB 124
     DEFB 3
         DEFB $BD,2
         DEFB 180
         DEFB 188
         DEFB 119
     DEFB 1
         DEFB 178
         DEFB 142
         DEFB 126
     DEFB 3
         DEFB 182
         DEFB 188
     DEFB 2
         DEFB 178
         DEFB 154
         DEFB 124
     DEFB 3
         DEFB $BD,0
         DEFB 142
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $BD,2
         DEFB 180
         DEFB 129
         DEFB 119
     DEFB 3
         DEFB $BD,0
         DEFB 146
         DEFB 141
         DEFB 124
     DEFB 1
         DEFB $BD,2
         DEFB 178
         DEFB 153
         DEFB 119
     DEFB 3
         DEFB $BD,0
         DEFB 153
         DEFB 129
     DEFB 2
         DEFB $BD,2
         DEFB 176
         DEFB 128
         DEFB 126
     DEFB 3
         DEFB $BD,0
         DEFB 152
         DEFB 140
     DEFB 2
         DEFB $BD,2
         DEFB 180
         DEFB 152
         DEFB 124
     DEFB 3
         DEFB 188
         DEFB 140
         DEFB 124
     DEFB 1
         DEFB $00
PAT5c:
         DEFB $BD,2
         DEFB 182
         DEFB 130
         DEFB 119
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 182
         DEFB 142
     DEFB 2
         DEFB $BD,0
         DEFB 158
         DEFB 154
         DEFB 124
     DEFB 3
         DEFB $BD,2
         DEFB 180
         DEFB 188
         DEFB 119
     DEFB 1
         DEFB 178
         DEFB 142
         DEFB 126
     DEFB 3
         DEFB 182
         DEFB 188
     DEFB 2
         DEFB 178
         DEFB 154
         DEFB 124
     DEFB 3
         DEFB $BD,0
         DEFB 142
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $BD,2
         DEFB 180
         DEFB 129
         DEFB 119
     DEFB 3
         DEFB $BD,0
         DEFB 146
         DEFB 141
         DEFB 124
     DEFB 1
         DEFB $BD,2
         DEFB 178
         DEFB 153
         DEFB 119
     DEFB 3
         DEFB $BD,0
         DEFB 153
         DEFB 129
     DEFB 2
         DEFB $BD,2
         DEFB 183
         DEFB 128
         DEFB 126
     DEFB 3
         DEFB $BD,0
         DEFB 152
         DEFB 140
         DEFB 124
     DEFB 1
         DEFB $BD,2
         DEFB 182
         DEFB 152
         DEFB 126
     DEFB 3
         DEFB 188
         DEFB 140
         DEFB 126
     DEFB 1
         DEFB $00
PAT6c:
         DEFB $BD,0
         DEFB 139
         DEFB 139
         DEFB 119
     DEFB 3
         DEFB $BD,4
         DEFB 139
         DEFB 151
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 163
         DEFB 124
     DEFB 3
         DEFB 188
         DEFB 188
     DEFB 2
         DEFB $BD,8
         DEFB 139
         DEFB 151
         DEFB 126
     DEFB 3
         DEFB $BD,6
         DEFB 139
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 139
         DEFB 163
         DEFB 124
     DEFB 3
         DEFB $BD,0
         DEFB 139
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB $BD,4
         DEFB 139
         DEFB 139
         DEFB 119
     DEFB 3
         DEFB $BD,6
         DEFB 139
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB $BD,8
         DEFB 139
         DEFB 163
         DEFB 119
     DEFB 3
         DEFB 188
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 146
         DEFB 126
     DEFB 3
         DEFB $BD,4
         DEFB 139
         DEFB 158
     DEFB 2
         DEFB $BD,8
         DEFB 139
         DEFB 130
         DEFB 124
     DEFB 3
         DEFB $BD,6
         DEFB 139
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $00
PAT7c:
         DEFB $BD,4
         DEFB 142
         DEFB 130
         DEFB 119
     DEFB 3
         DEFB $BD,0
         DEFB 142
         DEFB 142
     DEFB 2
         DEFB $BD,4
         DEFB 142
         DEFB 154
         DEFB 124
     DEFB 3
         DEFB 188
         DEFB 188
         DEFB 119
     DEFB 1
         DEFB $BD,6
         DEFB 142
         DEFB 142
         DEFB 126
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,8
         DEFB 142
         DEFB 154
         DEFB 124
     DEFB 3
         DEFB $BD,6
         DEFB 142
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $BD,4
         DEFB 141
         DEFB 129
         DEFB 119
     DEFB 3
         DEFB $BD,0
         DEFB 141
         DEFB 141
         DEFB 124
     DEFB 1
         DEFB $BD,4
         DEFB 141
         DEFB 153
         DEFB 119
     DEFB 3
         DEFB 188
         DEFB 129
     DEFB 2
         DEFB $BD,6
         DEFB 140
         DEFB 128
         DEFB 126
     DEFB 3
         DEFB $BD,8
         DEFB 140
         DEFB 140
         DEFB 124
     DEFB 1
         DEFB $BD,6
         DEFB 140
         DEFB 152
         DEFB 126
     DEFB 3
         DEFB $BD,4
         DEFB 140
         DEFB 140
         DEFB 126
     DEFB 1
         DEFB $00
PAT8c:
         DEFB $BD,8
         DEFB 139
         DEFB 139
         DEFB 119
     DEFB 3
         DEFB $BD,6
         DEFB 139
         DEFB 151
     DEFB 2
         DEFB $BD,4
         DEFB 139
         DEFB 163
         DEFB 124
     DEFB 3
         DEFB 188
         DEFB 188
     DEFB 2
         DEFB $BD,0
         DEFB 139
         DEFB 151
         DEFB 126
     DEFB 3
         DEFB $BD,4
         DEFB 139
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 163
         DEFB 124
     DEFB 3
         DEFB $BD,8
         DEFB 139
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB $BD,6
         DEFB 139
         DEFB 139
         DEFB 119
     DEFB 3
         DEFB $BD,4
         DEFB 139
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB $BD,0
         DEFB 139
         DEFB 163
         DEFB 119
     DEFB 3
         DEFB 188
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 139
         DEFB 146
         DEFB 126
     DEFB 3
         DEFB $BD,6
         DEFB 139
         DEFB 158
     DEFB 2
         DEFB $BD,8
         DEFB 139
         DEFB 130
         DEFB 124
     DEFB 3
         DEFB $BD,6
         DEFB 139
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $00
PAT9c:
         DEFB $BD,8
         DEFB 142
         DEFB 130
         DEFB 119
     DEFB 3
         DEFB $BD,6
         DEFB 142
         DEFB 142
     DEFB 2
         DEFB $BD,4
         DEFB 142
         DEFB 154
         DEFB 124
     DEFB 3
         DEFB 188
         DEFB 188
         DEFB 119
     DEFB 1
         DEFB $BD,0
         DEFB 142
         DEFB 142
         DEFB 126
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 142
         DEFB 154
         DEFB 124
     DEFB 3
         DEFB $BD,6
         DEFB 142
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $BD,8
         DEFB 141
         DEFB 129
         DEFB 122
     DEFB 3
         DEFB $BD,6
         DEFB 141
         DEFB 141
         DEFB 122
     DEFB 1
         DEFB $BD,4
         DEFB 141
         DEFB 153
         DEFB 122
     DEFB 3
         DEFB 188
         DEFB 129
         DEFB 124
     DEFB 1
         DEFB $BD,0
         DEFB 140
         DEFB 128
         DEFB 122
     DEFB 3
         DEFB $BD,4
         DEFB 140
         DEFB 140
         DEFB 122
     DEFB 1
         DEFB $BD,6
         DEFB 140
         DEFB 152
         DEFB 122
     DEFB 3
         DEFB $BD,8
         DEFB 140
         DEFB 140
         DEFB 122
     DEFB 1
         DEFB $00
PAT10c:
         DEFB $BD,2
         DEFB 139
         DEFB 163
         DEFB 119
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 175
     DEFB 2
         DEFB 151
         DEFB 178
         DEFB 124
     DEFB 3
         DEFB 190
         DEFB 180
     DEFB 2
         DEFB 146
         DEFB 175
         DEFB 126
     DEFB 3
         DEFB 190
         DEFB 182
     DEFB 2
         DEFB 190
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 175
         DEFB 124
     DEFB 1
         DEFB 142
         DEFB 182
         DEFB 119
     DEFB 3
         DEFB 190
         DEFB 187
     DEFB 2
         DEFB 190
         DEFB 180
         DEFB 124
     DEFB 3
         DEFB 190
         DEFB 178
     DEFB 2
         DEFB 130
         DEFB 170
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 182
     DEFB 2
         DEFB 190
         DEFB 154
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 166
         DEFB 124
     DEFB 1
         DEFB $00
PAT11c:
         DEFB $BD,2
         DEFB 144
         DEFB 154
         DEFB 119
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 166
     DEFB 2
         DEFB 190
         DEFB 182
         DEFB 124
     DEFB 3
         DEFB 190
         DEFB 188
         DEFB 119
     DEFB 1
         DEFB 132
         DEFB 180
         DEFB 126
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 178
         DEFB 124
     DEFB 3
         DEFB 190
         DEFB 166
         DEFB 124
     DEFB 1
         DEFB 147
         DEFB 178
         DEFB 119
     DEFB 3
         DEFB 190
         DEFB 165
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 180
         DEFB 119
     DEFB 3
         DEFB 190
         DEFB 153
     DEFB 2
         DEFB 146
         DEFB 183
         DEFB 126
     DEFB 3
         DEFB 190
         DEFB 164
     DEFB 2
         DEFB 190
         DEFB 182
         DEFB 124
     DEFB 3
         DEFB 190
         DEFB 164
         DEFB 124
     DEFB 1
         DEFB $00
PAT12c:
         DEFB $BD,2
         DEFB 144
         DEFB 154
         DEFB 119
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 3
         DEFB 190
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 182
         DEFB 124
     DEFB 5
         DEFB 190
         DEFB 188
         DEFB 119
     DEFB 2
         DEFB 132
         DEFB 180
         DEFB 126
     DEFB 5
         DEFB 190
         DEFB 188
     DEFB 3
         DEFB 190
         DEFB 178
         DEFB 124
     DEFB 5
         DEFB 190
         DEFB 166
         DEFB 124
     DEFB 2
         DEFB 147
         DEFB 178
         DEFB 122
     DEFB 5
         DEFB 190
         DEFB 165
         DEFB 124
     DEFB 2
         DEFB 190
         DEFB 180
         DEFB 122
     DEFB 5
         DEFB 190
         DEFB 153
         DEFB 122
     DEFB 2
         DEFB 146
         DEFB 183
         DEFB 122
     DEFB 5
         DEFB 190
         DEFB 164
         DEFB 122
     DEFB 2
         DEFB 190
         DEFB 182
         DEFB 122
     DEFB 5
         DEFB 190
         DEFB 164
         DEFB 122
     DEFB 2
         DEFB $00
PAT13c:
         DEFB $BD,10
         DEFB 227
         DEFB 139
     DEFB 10
         DEFB 229
         DEFB 163
     DEFB 10
         DEFB 230
         DEFB 151
     DEFB 10
         DEFB 254
         DEFB 142
     DEFB 10
         DEFB 234
         DEFB 166
     DEFB 10
         DEFB 235
         DEFB 154
     DEFB 10
         DEFB 234
         DEFB 147
     DEFB 10
         DEFB 254
         DEFB 159
     DEFB 10
         DEFB 230
         DEFB 146
     DEFB 10
         DEFB 229
         DEFB 141
     DEFB 10
         DEFB 254
         DEFB 153
     DEFB 10
         DEFB 234
         DEFB 165
     DEFB 10
         DEFB $00
PAT14c:
         DEFB $BD,10
         DEFB 234
         DEFB 139
     DEFB 10
         DEFB 235
         DEFB 163
     DEFB 10
         DEFB 234
         DEFB 151
     DEFB 10
         DEFB 232
         DEFB 142
     DEFB 10
         DEFB 230
         DEFB 166
     DEFB 10
         DEFB 232
         DEFB 154
     DEFB 10
         DEFB 234
         DEFB 147
     DEFB 10
         DEFB 235
         DEFB 159
     DEFB 10
         DEFB 234
         DEFB 146
     DEFB 10
         DEFB 254
         DEFB 141
     DEFB 10
         DEFB 235
         DEFB 153
     DEFB 10
         DEFB 234
         DEFB 165
     DEFB 10
         DEFB $00
PAT15c:
         DEFB $BD,10
         DEFB 170
         DEFB 139
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 171
         DEFB 163
     DEFB 2
         DEFB 170
         DEFB 151
     DEFB 2
         DEFB 190
         DEFB 188
     DEFB 4
         DEFB 168
         DEFB 142
     DEFB 4
         DEFB 166
         DEFB 154
     DEFB 2
         DEFB 168
         DEFB 142
     DEFB 6
         DEFB 170
         DEFB 147
     DEFB 4
         DEFB 171
         DEFB 159
     DEFB 2
         DEFB 170
         DEFB 147
     DEFB 4
         DEFB 188
         DEFB 159
     DEFB 2
         DEFB 170
         DEFB 141
         DEFB 122
     DEFB 3
         DEFB 171
         DEFB 153
         DEFB 122
     DEFB 1
         DEFB 170
         DEFB 141
         DEFB 122
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 171
         DEFB 153
         DEFB 122
     DEFB 1
         DEFB $00
PAT16c:
         DEFB $BD,10
         DEFB 175
         DEFB 139
         DEFB 119
     DEFB 3
         DEFB 190
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB $BD,0
         DEFB 154
         DEFB 163
         DEFB 125
     DEFB 3
         DEFB $BD,10
         DEFB 182
         DEFB 188
     DEFB 2
         DEFB 178
         DEFB 151
         DEFB 126
     DEFB 3
         DEFB $BD,4
         DEFB 151
         DEFB 188
         DEFB 124
     DEFB 1
         DEFB $BD,10
         DEFB 182
         DEFB 163
         DEFB 125
     DEFB 3
         DEFB 180
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB 182
         DEFB 139
         DEFB 119
     DEFB 3
         DEFB $BD,6
         DEFB 175
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB $BD,8
         DEFB 180
         DEFB 163
         DEFB 119
     DEFB 3
         DEFB $BD,10
         DEFB 166
         DEFB 188
         DEFB 125
     DEFB 1
         DEFB $BD,6
         DEFB 158
         DEFB 146
         DEFB 126
     DEFB 3
         DEFB $BD,10
         DEFB 178
         DEFB 158
     DEFB 2
         DEFB 180
         DEFB 130
         DEFB 124
     DEFB 3
         DEFB 182
         DEFB 142
         DEFB 125
     DEFB 1
         DEFB $00
PAT17c:
         DEFB $BD,10
         DEFB 182
         DEFB 130
         DEFB 119
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 182
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $BD,0
         DEFB 158
         DEFB 154
         DEFB 125
     DEFB 3
         DEFB $BD,10
         DEFB 180
         DEFB 188
         DEFB 119
     DEFB 1
         DEFB 178
         DEFB 142
         DEFB 126
     DEFB 3
         DEFB 182
         DEFB 188
         DEFB 124
     DEFB 1
         DEFB 178
         DEFB 154
         DEFB 125
     DEFB 3
         DEFB $BD,4
         DEFB 142
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $BD,10
         DEFB 180
         DEFB 129
         DEFB 119
     DEFB 3
         DEFB $BD,6
         DEFB 146
         DEFB 141
         DEFB 124
     DEFB 1
         DEFB $BD,10
         DEFB 178
         DEFB 153
         DEFB 119
     DEFB 3
         DEFB $BD,8
         DEFB 153
         DEFB 129
         DEFB 125
     DEFB 1
         DEFB $BD,10
         DEFB 176
         DEFB 128
         DEFB 126
     DEFB 3
         DEFB $BD,6
         DEFB 152
         DEFB 140
     DEFB 2
         DEFB $BD,10
         DEFB 180
         DEFB 152
         DEFB 124
     DEFB 3
         DEFB 188
         DEFB 140
         DEFB 125
     DEFB 1
         DEFB $00
PAT18c:
         DEFB $BD,10
         DEFB 182
         DEFB 130
         DEFB 119
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 182
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $BD,0
         DEFB 158
         DEFB 154
         DEFB 125
     DEFB 3
         DEFB $BD,10
         DEFB 180
         DEFB 188
         DEFB 119
     DEFB 1
         DEFB 178
         DEFB 142
         DEFB 126
     DEFB 3
         DEFB 182
         DEFB 188
         DEFB 124
     DEFB 1
         DEFB 178
         DEFB 154
         DEFB 125
     DEFB 3
         DEFB $BD,4
         DEFB 142
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB $BD,10
         DEFB 180
         DEFB 129
         DEFB 119
     DEFB 3
         DEFB $BD,6
         DEFB 146
         DEFB 141
         DEFB 122
     DEFB 1
         DEFB $BD,10
         DEFB 178
         DEFB 153
         DEFB 119
     DEFB 1
         DEFB 190
         DEFB 122
     DEFB 1
         DEFB $BD,8
         DEFB 153
         DEFB 129
         DEFB 125
     DEFB 1
         DEFB $BD,10
         DEFB 176
         DEFB 128
         DEFB 122
     DEFB 3
         DEFB $BD,6
         DEFB 152
         DEFB 140
         DEFB 122
     DEFB 1
         DEFB $BD,10
         DEFB 180
         DEFB 152
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 122
     DEFB 1
         DEFB 188
         DEFB 140
         DEFB 125
     DEFB 1
         DEFB $00
PAT19c:
         DEFB $BD,0
         DEFB 139
         DEFB 163
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 139
         DEFB 175
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
     DEFB 2
         DEFB $BD,8
         DEFB 139
         DEFB 175
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 139
     DEFB 2
         DEFB $BD,4
         DEFB 139
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,0
         DEFB 139
         DEFB 175
         DEFB 124
     DEFB 1
         DEFB $BD,4
         DEFB 139
         DEFB 163
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 175
     DEFB 2
         DEFB $BD,8
         DEFB 139
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 170
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 139
         DEFB 182
     DEFB 2
         DEFB $BD,8
         DEFB 139
         DEFB 154
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 166
         DEFB 124
     DEFB 1
         DEFB $00
PAT20c:
         DEFB $BD,4
         DEFB 142
         DEFB 154
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,0
         DEFB 142
         DEFB 166
     DEFB 2
         DEFB $BD,4
         DEFB 142
         DEFB 178
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
         DEFB 123
     DEFB 1
         DEFB $BD,6
         DEFB 142
         DEFB 166
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 4
         DEFB $BD,8
         DEFB 142
         DEFB 178
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 142
         DEFB 166
         DEFB 124
     DEFB 1
         DEFB $BD,4
         DEFB 141
         DEFB 153
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,0
         DEFB 141
         DEFB 165
         DEFB 124
     DEFB 1
         DEFB $BD,4
         DEFB 141
         DEFB 177
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
         DEFB 153
     DEFB 2
         DEFB $BD,6
         DEFB 140
         DEFB 152
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,8
         DEFB 140
         DEFB 164
     DEFB 2
         DEFB $BD,6
         DEFB 140
         DEFB 176
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 140
         DEFB 164
         DEFB 124
     DEFB 1
         DEFB $00
PAT21c:
         DEFB $BD,8
         DEFB 139
         DEFB 163
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 175
     DEFB 2
         DEFB $BD,4
         DEFB 139
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
     DEFB 2
         DEFB $BD,0
         DEFB 139
         DEFB 175
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 139
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,8
         DEFB 139
         DEFB 175
         DEFB 124
     DEFB 1
         DEFB $BD,6
         DEFB 139
         DEFB 163
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 139
         DEFB 175
     DEFB 2
         DEFB $BD,0
         DEFB 139
         DEFB 187
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 139
         DEFB 170
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 182
     DEFB 2
         DEFB $BD,8
         DEFB 139
         DEFB 154
         DEFB 124
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 139
         DEFB 166
         DEFB 124
     DEFB 1
         DEFB $00
PAT22c:
         DEFB $BD,8
         DEFB 142
         DEFB 154
         DEFB 123
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 142
         DEFB 166
         DEFB 123
     DEFB 1
         DEFB $BD,4
         DEFB 142
         DEFB 178
     DEFB 2
         DEFB 190
         DEFB 188
         DEFB 123
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB $BD,0
         DEFB 142
         DEFB 166
         DEFB 125
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB 190
         DEFB 125
     DEFB 1
         DEFB $BD,4
         DEFB 142
         DEFB 178
     DEFB 2
         DEFB 190
         DEFB 188
         DEFB 125
     DEFB 1
         DEFB $BD,6
         DEFB 142
         DEFB 166
     DEFB 2
         DEFB $BD,8
         DEFB 141
         DEFB 153
         DEFB 126
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,6
         DEFB 141
         DEFB 165
         DEFB 126
     DEFB 1
         DEFB $BD,4
         DEFB 141
         DEFB 177
     DEFB 2
         DEFB 190
         DEFB 188
         DEFB 126
     DEFB 1
         DEFB 188
         DEFB 153
     DEFB 2
         DEFB $BD,0
         DEFB 140
         DEFB 152
         DEFB 122
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,4
         DEFB 140
         DEFB 164
         DEFB 122
     DEFB 1
         DEFB $BD,6
         DEFB 140
         DEFB 176
         DEFB 122
     DEFB 1
         DEFB 190
         DEFB 188
     DEFB 2
         DEFB $BD,8
         DEFB 140
         DEFB 164
         DEFB 122
     DEFB 1
         DEFB $00
PAT23c:
         DEFB $BD,12
         DEFB 227
         DEFB 139
         DEFB 119
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 239
         DEFB 139
         DEFB 124
     DEFB 1
         DEFB 242
         DEFB 151
         DEFB 125
     DEFB 3
         DEFB 244
         DEFB 151
         DEFB 124
     DEFB 1
         DEFB 239
         DEFB 146
         DEFB 126
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 246
         DEFB 146
     DEFB 2
         DEFB 251
         DEFB 146
         DEFB 124
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 239
         DEFB 146
         DEFB 125
     DEFB 1
         DEFB 246
         DEFB 142
         DEFB 119
     DEFB 3
         DEFB 251
         DEFB 142
     DEFB 2
         DEFB 244
         DEFB 142
         DEFB 124
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 242
         DEFB 142
         DEFB 125
     DEFB 1
         DEFB 234
         DEFB 130
         DEFB 126
     DEFB 3
         DEFB 246
         DEFB 130
         DEFB 124
     DEFB 1
         DEFB 218
         DEFB 130
         DEFB 125
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 230
         DEFB 130
         DEFB 124
     DEFB 1
         DEFB $00
PAT24c:
         DEFB $BD,12
         DEFB 154
         DEFB 144
         DEFB 119
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 230
         DEFB 144
         DEFB 124
     DEFB 1
         DEFB 246
         DEFB 144
         DEFB 125
     DEFB 3
         DEFB 252
         DEFB 144
         DEFB 119
     DEFB 1
         DEFB 244
         DEFB 132
         DEFB 126
     DEFB 3
         DEFB 252
         DEFB 132
         DEFB 124
     DEFB 1
         DEFB 242
         DEFB 132
         DEFB 125
     DEFB 3
         DEFB 230
         DEFB 132
         DEFB 124
     DEFB 1
         DEFB 242
         DEFB 147
         DEFB 119
     DEFB 3
         DEFB 229
         DEFB 146
         DEFB 125
     DEFB 1
         DEFB 244
         DEFB 147
         DEFB 119
     DEFB 3
         DEFB 217
         DEFB 146
         DEFB 124
     DEFB 1
         DEFB 247
         DEFB 146
         DEFB 126
     DEFB 3
         DEFB 228
         DEFB 144
         DEFB 124
     DEFB 1
         DEFB 246
         DEFB 146
         DEFB 125
     DEFB 3
         DEFB 228
         DEFB 144
         DEFB 124
     DEFB 1
         DEFB $00
PAT25c:
         DEFB $BD,12
         DEFB 154
         DEFB 144
         DEFB 119
     DEFB 1
         DEFB 188
     DEFB 2
         DEFB 230
         DEFB 144
         DEFB 124
     DEFB 1
         DEFB 246
         DEFB 144
         DEFB 125
     DEFB 3
         DEFB 252
         DEFB 144
         DEFB 119
     DEFB 1
         DEFB 244
         DEFB 132
         DEFB 126
     DEFB 3
         DEFB 252
         DEFB 132
         DEFB 124
     DEFB 1
         DEFB 242
         DEFB 132
         DEFB 125
     DEFB 3
         DEFB 230
         DEFB 132
         DEFB 124
     DEFB 1
         DEFB 242
         DEFB 147
         DEFB 119
     DEFB 3
         DEFB 229
         DEFB 146
         DEFB 125
     DEFB 1
         DEFB 244
         DEFB 147
         DEFB 119
     DEFB 3
         DEFB 217
         DEFB 146
         DEFB 124
     DEFB 1
         DEFB 247
         DEFB 146
         DEFB 122
     DEFB 3
         DEFB 228
         DEFB 144
         DEFB 122
     DEFB 1
         DEFB 246
         DEFB 146
         DEFB 122
     DEFB 3
         DEFB 228
         DEFB 144
         DEFB 122
     DEFB 1
         DEFB $00


;===================================================================
SONG4:						; Day at the beach
;===================================================================
             DEFB 0  ; Pattern loop begin * 2
             DEFB 48  ; Song length * 2
             DEFW 4         ; Offset to start of song (length of instrument table)
             DEFB 0      ; Multiple
             DEFW 1      ; Detune
             DEFB 1      ; Phase

PATTERNDATAd:       DEFW      PAT0d
                    DEFW      PAT1d
                    DEFW      PAT2d
                    DEFW      PAT3d
                    DEFW      PAT0d
                    DEFW      PAT1d
                    DEFW      PAT2d
                    DEFW      PAT3d
                    DEFW      PAT4d
                    DEFW      PAT5d
                    DEFW      PAT6d
                    DEFW      PAT7d
                    DEFW      PAT8d
                    DEFW      PAT9d
                    DEFW      PAT10d
                    DEFW      PAT9d
                    DEFW      PAT8d
                    DEFW      PAT9d
                    DEFW      PAT11d
                    DEFW      PAT12d
                    DEFW      PAT13d
                    DEFW      PAT14d
                    DEFW      PAT13d
                    DEFW      PAT15d

; *** Pattern data - $00 marks the end of a pattern ***
PAT0d:
         DEFB $BD,0
         DEFB 254
         DEFB 137
     DEFB 3
         DEFB 153
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 137
     DEFB 3
         DEFB 153
         DEFB 149
     DEFB 3
         DEFB 163
         DEFB 158
     DEFB 3
         DEFB 190
         DEFB 137
     DEFB 3
         DEFB 153
         DEFB 149
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 137
     DEFB 3
         DEFB 153
         DEFB 149
     DEFB 3
         DEFB 163
         DEFB 158
     DEFB 3
         DEFB 190
         DEFB 137
     DEFB 3
         DEFB 153
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 6
         DEFB $00
PAT1d:
         DEFB 190
         DEFB 137
     DEFB 3
         DEFB 153
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 137
     DEFB 3
         DEFB 153
         DEFB 149
     DEFB 3
         DEFB 163
         DEFB 158
     DEFB 3
         DEFB 190
         DEFB 137
     DEFB 3
         DEFB 153
         DEFB 149
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 137
     DEFB 3
         DEFB 153
         DEFB 149
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 141
     DEFB 3
         DEFB 156
         DEFB 151
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 6
         DEFB $00
PAT2d:
         DEFB 254
         DEFB 146
     DEFB 3
         DEFB 161
         DEFB 158
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 146
     DEFB 3
         DEFB 161
         DEFB 158
     DEFB 3
         DEFB 163
         DEFB 158
     DEFB 3
         DEFB 190
         DEFB 146
     DEFB 3
         DEFB 161
         DEFB 158
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 146
     DEFB 3
         DEFB 161
         DEFB 158
     DEFB 3
         DEFB 163
         DEFB 158
     DEFB 3
         DEFB 190
         DEFB 146
     DEFB 3
         DEFB 161
         DEFB 158
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 6
         DEFB $00
PAT3d:
         DEFB 190
         DEFB 146
     DEFB 3
         DEFB 161
         DEFB 158
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 146
     DEFB 3
         DEFB 161
         DEFB 158
     DEFB 3
         DEFB 163
         DEFB 158
     DEFB 3
         DEFB 190
         DEFB 146
     DEFB 3
         DEFB 161
         DEFB 158
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 146
     DEFB 3
         DEFB 161
         DEFB 158
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 6
         DEFB $00
PAT4d:
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 163
         DEFB 158
     DEFB 3
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 168
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 6
         DEFB $00
PAT5d:
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 170
         DEFB 165
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 170
         DEFB 165
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 168
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 168
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 168
         DEFB 163
     DEFB 6
         DEFB $00
PAT6d:
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 168
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 163
         DEFB 158
     DEFB 3
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 142
     DEFB 3
         DEFB 158
         DEFB 154
     DEFB 3
         DEFB 168
         DEFB 163
     DEFB 6
         DEFB $00
PAT7d:
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 170
         DEFB 165
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 170
         DEFB 165
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 172
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 172
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 172
         DEFB 163
     DEFB 6
         DEFB $00
PAT8d:
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 3
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 3
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 175
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 175
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 177
         DEFB 168
     DEFB 6
         DEFB $00
PAT9d:
         DEFB 190
         DEFB 147
     DEFB 3
         DEFB 163
         DEFB 159
     DEFB 3
         DEFB 170
         DEFB 165
     DEFB 3
         DEFB 190
         DEFB 147
     DEFB 3
         DEFB 163
         DEFB 159
     DEFB 3
         DEFB 170
         DEFB 165
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 159
         DEFB 156
     DEFB 3
         DEFB 171
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 159
         DEFB 156
     DEFB 3
         DEFB 171
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 159
         DEFB 156
     DEFB 3
         DEFB 171
         DEFB 166
     DEFB 6
         DEFB $00
PAT10d:
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 3
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 3
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 175
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 175
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 149
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 6
         DEFB $00
PAT11d:
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 171
         DEFB 166
     DEFB 3
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 3
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 176
         DEFB 171
     DEFB 3
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 178
         DEFB 173
     DEFB 3
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 6
         DEFB $00
PAT12d:
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 176
         DEFB 171
     DEFB 3
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 176
         DEFB 171
     DEFB 3
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 3
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 3
         DEFB 190
         DEFB 145
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 3
         DEFB 173
         DEFB 168
     DEFB 6
         DEFB $00
PAT13d:
         DEFB 190
         DEFB 147
     DEFB 3
         DEFB 163
         DEFB 159
     DEFB 3
         DEFB 168
         DEFB 164
     DEFB 3
         DEFB 190
         DEFB 147
     DEFB 3
         DEFB 163
         DEFB 159
     DEFB 3
         DEFB 168
         DEFB 164
     DEFB 3
         DEFB 190
         DEFB 147
     DEFB 3
         DEFB 163
         DEFB 159
     DEFB 3
         DEFB 166
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 147
     DEFB 3
         DEFB 163
         DEFB 159
     DEFB 3
         DEFB 166
         DEFB 163
     DEFB 3
         DEFB 190
         DEFB 147
     DEFB 3
         DEFB 163
         DEFB 159
     DEFB 3
         DEFB 166
         DEFB 163
     DEFB 6
         DEFB $00
PAT14d:
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 163
         DEFB 160
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 163
         DEFB 160
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 163
         DEFB 160
     DEFB 6
         DEFB $00
PAT15d:
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 165
         DEFB 161
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 163
         DEFB 160
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 163
         DEFB 160
     DEFB 3
         DEFB 190
         DEFB 144
     DEFB 3
         DEFB 160
         DEFB 156
     DEFB 3
         DEFB 161
         DEFB 156
     DEFB 6
         DEFB $00

;===================================================================
SONG5:						; continence
;===================================================================
             DEFB 82  ; Pattern loop begin * 2
             DEFB 84  ; Song length * 2
             DEFW 36         ; Offset to start of song (length of instrument table)
             DEFB 1      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 4      ; Multiple
             DEFW 1      ; Detune
             DEFB 16      ; Phase
             DEFB 2      ; Multiple
             DEFW 1      ; Detune
             DEFB 0      ; Phase
             DEFB 1      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 1      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 1      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 1      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 1      ; Multiple
             DEFW 0      ; Detune
             DEFB 0      ; Phase
             DEFB 16      ; Multiple
             DEFW 256      ; Detune
             DEFB 128      ; Phase

PATTERNDATAe:       DEFW      PAT0e
                    DEFW      PAT0e
                    DEFW      PAT0e
                    DEFW      PAT0e
                    DEFW      PAT1e
                    DEFW      PAT1e
                    DEFW      PAT1e
                    DEFW      PAT1e
                    DEFW      PAT2e
                    DEFW      PAT2e
                    DEFW      PAT2e
                    DEFW      PAT2e
                    DEFW      PAT3e
                    DEFW      PAT3e
                    DEFW      PAT3e
                    DEFW      PAT3e
                    DEFW      PAT4e
                    DEFW      PAT4e
                    DEFW      PAT4e
                    DEFW      PAT4e
                    DEFW      PAT5e
                    DEFW      PAT5e
                    DEFW      PAT5e
                    DEFW      PAT5e
                    DEFW      PAT6e
                    DEFW      PAT6e
                    DEFW      PAT6e
                    DEFW      PAT6e
                    DEFW      PAT7e
                    DEFW      PAT7e
                    DEFW      PAT7e
                    DEFW      PAT7e
                    DEFW      PAT5e
                    DEFW      PAT5e
                    DEFW      PAT5e
                    DEFW      PAT5e
                    DEFW      PAT4e
                    DEFW      PAT4e
                    DEFW      PAT4e
                    DEFW      PAT4e
                    DEFW      PAT99e
                    DEFW      PAT98e

; *** Pattern data - $00 marks the end of a pattern ***
PAT0e:
         DEFB 145
         DEFB 142
     DEFB 18
         DEFB 190
         DEFB 143
     DEFB 6
         DEFB 142
     DEFB 12
         DEFB 190
         DEFB 142
     DEFB 12
         DEFB 145
     DEFB 6
         DEFB 190
         DEFB 145
     DEFB 18
         DEFB 143
         DEFB 143
     DEFB 12
         DEFB 190
         DEFB 142
     DEFB 12
         DEFB $00
PAT1e:
         DEFB $BD,0
         DEFB 130
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 131
     DEFB 3
         DEFB 131
         DEFB 143
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB 142
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 142
         DEFB 118
     DEFB 2
         DEFB 131
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 142
     DEFB 3
         DEFB 133
         DEFB 145
         DEFB 121
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 133
         DEFB 145
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 143
     DEFB 3
         DEFB 131
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 118
     DEFB 2
         DEFB 142
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 131
     DEFB 3
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 130
     DEFB 3
         DEFB 142
     DEFB 3
         DEFB $00
PAT2e:
         DEFB $BD,0
         DEFB 130
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 125
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 118
     DEFB 2
         DEFB 131
     DEFB 3
         DEFB 131
         DEFB 143
         DEFB 125
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB 142
     DEFB 3
         DEFB 130
         DEFB 125
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 142
         DEFB 118
     DEFB 2
         DEFB 131
     DEFB 3
         DEFB 130
         DEFB 125
     DEFB 2
         DEFB 142
     DEFB 3
         DEFB 133
         DEFB 145
         DEFB 121
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 133
         DEFB 145
         DEFB 125
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 143
         DEFB 118
     DEFB 2
         DEFB 131
     DEFB 3
         DEFB 130
         DEFB 125
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 121
     DEFB 2
         DEFB 142
     DEFB 3
         DEFB 130
         DEFB 125
     DEFB 2
         DEFB 131
     DEFB 3
         DEFB 130
         DEFB 142
         DEFB 118
     DEFB 2
         DEFB 130
     DEFB 3
         DEFB 130
         DEFB 125
     DEFB 2
         DEFB 142
     DEFB 3
         DEFB $00
PAT3e:
         DEFB $BD,2
         DEFB 130
         DEFB 154
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB $BD,0
         DEFB 130
         DEFB 154
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB $BD,0
         DEFB 130
         DEFB 154
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB $BD,2
         DEFB 130
         DEFB 155
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB $BD,2
         DEFB 130
         DEFB 154
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB $BD,0
         DEFB 194
         DEFB 154
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB $BD,2
         DEFB 130
         DEFB 154
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB $BD,0
         DEFB 130
         DEFB 155
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
         DEFB 142
     DEFB 3
         DEFB $00
PAT4e:
         DEFB $BD,2
         DEFB 130
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 130
         DEFB 125
     DEFB 2
         DEFB $BD,16
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 130
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 130
         DEFB 143
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 130
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 130
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 130
         DEFB 142
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 130
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $00
PAT5e:
         DEFB $BD,2
         DEFB 142
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,16
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 142
         DEFB 145
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 143
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 143
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $00
PAT6e:
         DEFB $BD,16
         DEFB 142
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,16
         DEFB 142
         DEFB 145
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 143
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,16
         DEFB 142
         DEFB 143
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $00
PAT7e:
         DEFB $BD,16
         DEFB 142
         DEFB 130
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,16
         DEFB 142
         DEFB 130
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 142
         DEFB 121
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,0
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,16
         DEFB 142
         DEFB 130
         DEFB 118
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $BD,2
         DEFB 142
         DEFB 125
     DEFB 2
         DEFB $BD,0
         DEFB 130
     DEFB 3
         DEFB $00
PAT98e:
     DEFB 48
         DEFB $00
PAT99e:
         DEFB 190
         DEFB 119
     DEFB 8
         DEFB 188
     DEFB 12
         DEFB 190
         DEFB 188
     DEFB 3
         DEFB 190
         DEFB 188
     DEFB 24
         DEFB $00


;===================================================================

;===================================================================


intro_screen:
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0C0,$000,$003,$0FF,$0F0,$000,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0FF,$0F0,$000,$003,$0FF,$0FF,$0C0,$000,$03F,$0FD,$055,$040,$000,$01F,$0FF,$0FF
 db $0FF,$0C0,$000,$003,$0FF,$0F0,$000,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0FC,$000,$000,$000,$00F,$0FF,$0C0,$000,$03F,$0F5,$050,$000,$000,$000,$0FF,$0FF
 db $0FF,$0C0,$000,$003,$0FF,$0F0,$000,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0F0,$000,$000,$000,$003,$0FF,$0C0,$000,$03F,$0D5,$040,$000,$000,$000,$03F,$0FF
 db $0FF,$0C0,$000,$000,$0FF,$0C0,$000,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0C0,$000,$000,$000,$000,$0FF,$0C0,$000,$03F,$055,$000,$000,$000,$000,$00F,$0FF
 db $0FF,$0C0,$000,$000,$0FF,$0C0,$000,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0C0,$000,$000,$000,$000,$0FF,$0C0,$000,$03D,$054,$000,$000,$000,$000,$003,$0FF
 db $0FF,$0C0,$000,$000,$0FF,$0C0,$000,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $000,$000,$03F,$000,$000,$03F,$0C0,$000,$035,$050,$000,$001,$050,$000,$003,$0FF
 db $0FF,$0C0,$000,$000,$0FF,$0C0,$000,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $000,$000,$0FF,$0C0,$000,$03F,$0C0,$000,$015,$050,$000,$005,$054,$000,$000,$0FF
 db $0FF,$0C0,$000,$000,$03F,$000,$000,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $000,$000,$0FF,$0FF,$0FF,$0FF,$0C0,$000,$015,$050,$000,$005,$055,$000,$003,$0FF
 db $0FF,$0C0,$003,$000,$03F,$000,$030,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $000,$000,$003,$0FF,$0FF,$0FF,$0C0,$000,$015,$040,$000,$015,$055,$00F,$0FF,$0FF
 db $0FF,$0C0,$003,$000,$03F,$000,$030,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0C0,$000,$000,$003,$0FF,$0FF,$0C0,$000,$015,$040,$000,$015,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$003,$000,$03F,$000,$030,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0C0,$000,$000,$000,$00F,$0FF,$0C0,$000,$015,$040,$000,$015,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$003,$0C0,$00C,$000,$0F0,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0F0,$000,$000,$000,$000,$0FF,$0C0,$000,$015,$040,$000,$015,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$003,$0C0,$00C,$000,$0F0,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0FF,$000,$000,$000,$000,$03F,$0C0,$000,$015,$040,$000,$015,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$003,$0C0,$00C,$000,$0F0,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0FF,$0FC,$000,$000,$000,$03F,$0C0,$000,$015,$040,$000,$015,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$003,$0C0,$00C,$000,$0F0,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FF
 db $0FF,$0FF,$0FF,$000,$000,$00F,$0C0,$000,$015,$040,$000,$015,$055,$00F,$0FF,$0FF
 db $0FF,$0C0,$003,$0F0,$000,$003,$0F0,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FC
 db $000,$003,$0FF,$0F0,$000,$00F,$0C0,$000,$015,$040,$000,$015,$055,$000,$00F,$0FF
 db $0FF,$0C0,$003,$0F0,$000,$003,$0F0,$000,$0FF,$0C0,$000,$03F,$0FF,$000,$000,$0FC
 db $000,$003,$0FF,$0F0,$000,$00F,$0C0,$000,$015,$050,$000,$015,$054,$000,$000,$0FF
 db $0FF,$0C0,$003,$0F0,$000,$003,$0F0,$000,$0FF,$0F0,$000,$00F,$0FC,$000,$000,$0FC
 db $000,$000,$0FF,$0F0,$000,$00F,$040,$000,$015,$050,$000,$005,$054,$000,$000,$0FF
 db $0FF,$0C0,$003,$0FC,$000,$00F,$0F0,$000,$0FF,$0F0,$000,$003,$0F0,$000,$003,$0FF
 db $000,$000,$03F,$0C0,$000,$00D,$040,$000,$015,$050,$000,$001,$050,$000,$003,$0FF
 db $0FF,$0C0,$003,$0FC,$000,$00F,$0F0,$000,$0FF,$0F0,$000,$000,$000,$000,$003,$0FF
 db $000,$000,$000,$000,$000,$035,$040,$000,$015,$05C,$000,$000,$000,$000,$003,$0FF
 db $0FF,$0C0,$003,$0FC,$000,$00F,$0F0,$000,$0FF,$0FC,$000,$000,$000,$000,$00F,$0FF
 db $0C0,$000,$000,$000,$000,$0D5,$040,$000,$015,$07D,$000,$000,$000,$000,$00F,$0FF
 db $0FF,$0C0,$003,$0FF,$000,$00F,$0F0,$000,$0FF,$0FF,$000,$000,$000,$000,$03F,$0FF
 db $0F0,$000,$000,$000,$003,$055,$040,$000,$015,$0FD,$040,$000,$000,$000,$03F,$0FF
 db $0FF,$0C0,$003,$0FF,$000,$03F,$0F0,$000,$0FF,$0FF,$0C0,$000,$000,$000,$0FF,$0FF
 db $0FC,$000,$000,$000,$00D,$055,$040,$000,$017,$0FD,$050,$000,$000,$000,$0FF,$0FF
 db $0FF,$0C0,$003,$0FF,$000,$03F,$0F0,$000,$0FF,$0FF,$0FF,$000,$000,$03F,$0FF,$0FF
 db $0FF,$0F0,$000,$003,$0F5,$055,$040,$000,$01F,$0FD,$055,$040,$000,$01F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0F5,$055,$055,$055,$07F,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0D5,$055,$055,$055,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$055,$055,$055,$055,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FD,$055,$055,$055,$057,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0F5,$055,$055,$055,$05F,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0D5,$055,$055,$055,$07F,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$055,$055,$055,$055,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$055,$055,$055,$057,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0F5,$055,$055,$055,$05F,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0D5,$055,$055,$055,$07F,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$055,$055,$055,$055,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$000,$000,$00F,$0FF,$0FF,$0FF,$0F0,$000,$003,$0FF,$0FF,$0FC,$000
 db $00F,$0FF,$055,$040,$000,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$000,$000,$000,$0FF,$0FF,$0FF,$000,$000,$000,$03F,$0FF,$0FF,$000
 db $003,$0FF,$055,$000,$001,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$000,$000,$000,$03F,$0FF,$0F0,$000,$000,$000,$003,$0FF,$0FF,$0C0
 db $000,$0FF,$054,$000,$005,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$000,$000,$000,$00F,$0FF,$0C0,$000,$000,$000,$000,$0FF,$0FF,$0C0
 db $000,$03F,$050,$000,$005,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$000,$000,$000,$00F,$0FF,$000,$000,$000,$000,$000,$03F,$0FF,$0F0
 db $000,$03F,$050,$000,$015,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$03F,$0C0,$000,$00F,$0FC,$000,$000,$0FF,$0C0,$000,$00F,$0FF,$0FC
 db $000,$00F,$040,$000,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$03F,$0F0,$000,$00F,$0FC,$000,$003,$0FF,$0F0,$000,$00F,$0FF,$0FC
 db $000,$003,$000,$000,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$03F,$0F0,$000,$00F,$0FC,$000,$003,$0FF,$0F0,$000,$00F,$0FF,$0FF
 db $000,$000,$000,$001,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$03F,$0C0,$000,$03F,$0F0,$000,$00F,$0FF,$0FC,$000,$003,$0FF,$0FF
 db $0C0,$000,$000,$005,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$000,$000,$000,$0FF,$0F0,$000,$00F,$0FF,$0FC,$000,$003,$0FF,$0FF
 db $0C0,$000,$000,$005,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$000,$000,$003,$0FF,$0F0,$000,$00F,$0FF,$0FC,$000,$003,$0FF,$0FF
 db $0F0,$000,$000,$015,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$000,$000,$003,$0FF,$0F0,$000,$00F,$0FF,$0FC,$000,$003,$0FF,$0FF
 db $0FC,$000,$000,$015,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$000,$000,$000,$03F,$0F0,$000,$00F,$0FF,$0FC,$000,$003,$0FF,$0FF
 db $0F0,$000,$000,$015,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$05F
 db $0FF,$0C0,$000,$000,$000,$000,$00F,$0F0,$000,$00F,$0FF,$0FC,$000,$003,$0FF,$0FF
 db $0C0,$000,$000,$00F,$0FF,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$03F,$0F0,$000,$003,$0F0,$000,$00F,$0FF,$0FC,$000,$003,$0FF,$0FF
 db $0C0,$000,$000,$00F,$0FF,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$03F,$0FC,$000,$003,$0F0,$000,$00F,$0FF,$0FC,$000,$003,$0FF,$0FF
 db $000,$000,$000,$003,$0FF,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$03F,$0FC,$000,$003,$0FC,$000,$003,$0FF,$0F0,$000,$00F,$0FF,$0FC
 db $000,$003,$000,$000,$0FF,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$03F,$0FC,$000,$003,$0FC,$000,$003,$0FF,$0F0,$000,$00F,$0FF,$0FC
 db $000,$00F,$0C0,$000,$03F,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$03F,$0F0,$000,$003,$0FC,$000,$000,$0FF,$0C0,$000,$00F,$0FF,$0F0
 db $000,$00F,$0C0,$000,$03F,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$000,$000,$000,$003,$0FF,$000,$000,$000,$000,$000,$03F,$0FF,$0C0
 db $000,$03F,$0F0,$000,$00F,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$000,$000,$000,$00F,$0FF,$0C0,$000,$000,$000,$000,$0FF,$0FF,$000
 db $000,$0FF,$0FC,$000,$003,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$000,$000,$000,$03F,$0FF,$0F0,$000,$000,$000,$003,$0FF,$0FF,$000
 db $003,$0FF,$0FF,$000,$003,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$000,$000,$000,$0FF,$0FF,$0FF,$000,$000,$000,$00F,$0FF,$0FC,$000
 db $00F,$0FF,$0FF,$0C0,$000,$0FF,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0C0,$000,$000,$000,$00F,$0FF,$0FF,$0FF,$0F0,$000,$003,$0FF,$0FF,$0F0,$000
 db $03F,$0FF,$0FF,$0F0,$000,$03F,$0FF,$0FF,$0FF,$0FD,$055,$055,$055,$05F,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
 db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF


