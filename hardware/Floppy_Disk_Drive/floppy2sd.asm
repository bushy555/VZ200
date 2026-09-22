;*****************************************************************************
;
;                            DISK to SD transfer 
;
; This utility is run on the VZ to communicate with the Arduino  
; 
;
; Compile using the TASM cross assembler: 
; 	tasm -80 -b floppy2sd.asm
;
; Build the .vz snapshot:
; 	rbinary floppy2sd.obj floppy2sd.vz 
;
; Build a wav file to CRUN on the VZ
;	vz2wav floppy2sd.vz floppy2sd.wav 
;
; Copy the wav file onto a device with a headphone jack that can play back 
; the tones. Anything is probably better than an iPhone  
;
;
;*****************************************************************************


DISPLAY_STRING:		.equ 28A7h
DISPLAY_CHARACTER:	.equ 033Ah
BASIC:				.equ 1A19h
CLS:				.equ 01C9h
ASCIIRESULT:		.equ 7930h		; output from ASCII conversions
INT2ASCII:			.equ 132Fh	
BUFFER:				.equ 7100h

	.org	8000h

;
;	Main section 
;
	CALL	CLS		
	LD 		HL, TITLE_STRING 
	CALL	DISPLAY_STRING
WAIT_S:
	LD		A,(68FDh)
	BIT		1,A 
	JR		NZ, WAIT_S
	CALL	CLS	
	
	LD		A, 00h 						; start at track zero 
	LD 		(TRACK), A 
	
NEXT_TRACK:
	LD		B,16						; 16 sectors per track
	LD		HL, SECTOR_ORDER			; point to start sequence of sectors		

NEXT_SECTOR:
	CALL	LDELAY						; allow time for microcontroller to write the last track 

	LD		A, (HL)						; Get the current sector  
	LD		(SECTOR), A 				; save the sector# 

	;
	;	write track/sector 
	;
	LD		A, (TRACK)
	CALL	OUTBYTE 
	LD		A, (SECTOR)
	CALL	OUTBYTE 
	;
	;	write the 128 data bytes 
	;
	
	CALL	DISPLAY_TRACK_SECTOR
	CALL	READ_SECTOR	
	CALL	OUTPUT_BUFFER
	INC	HL							; point to next sector
	DJNZ	NEXT_SECTOR				; read all 16 sectors
	LD		A, (TRACK)				; get current track
	INC		A						; point to next track 
	LD		(TRACK),A 				; 
	CP		40						; have we read tracks 00-39
	JR		NZ, NEXT_TRACK			; no - read next track
	
	JP		BASIC 					; we are done - jump to basic
	
	

READ_SECTOR:
		PUSH	BC 
		PUSH	DE 
		PUSH	HL 
		
		LD A,10h		
    	LD (IY+0Bh),A
    	CALL 4008h			; turn on drive 1 
		LD	A, (TRACK)
    	LD (IY+12h),A 		; track
		LD A, (SECTOR) 
    	LD (IY+11h),A		; sector 
    	DI
    	CALL 4035h			; read sector
    	LD DE,BUFFER 		; destination buffer - halfway down text screen
    	LD L,(IY+31h)		; source buffer
    	LD H,(IY+32h)
    	LD BC,0080h
    	LDIR				; copy 128 bytes to destination
    	CALL 400Bh			; turn off drive 
		
		POP		HL 
		POP		DE 
		POP		BC 
		
    	RET

OUTPUT_BUFFER:
		PUSH	BC 
		PUSH	DE 
		PUSH	HL 
		
		; write the 128 byte buffer containing the sector data  
		
		LD		HL,BUFFER 
		LD		B, 80h
NEXT_BYTE: 
		LD		A,(HL) 
		CALL	OUTBYTE 
		INC		HL 
		DJNZ	NEXT_BYTE 
		
		POP		HL 
		POP		DE 
		POP		BC 
		RET 

OUTBYTE:
	;
	;	Output the value of Reg A to port 40h serially via D7
	;	The output bit will be latched and read by the Arduino to 
	;	reconstruct the byte 
	;
	PUSH	BC 
	PUSH	DE 

	LD	B,8
	LD	C,80h		; start at bit 7
	LD	D,A			; save original value 
LOOP:
	AND	C			; compare mask against output byte
	LD	A,00h		; assume low bit 
	JR	Z,WRITE		; if zero, output zero
	LD	A,80h		; otherwise output 80h
WRITE:
	OUT	(40h),A		; send the bit
	XOR	A
DELAY:
	DEC	A
	JR	NZ,DELAY	; short software delay between bits
	SRL	C			; divide mask by 2 
	LD	A,D			; restore orginal byte value 
	DJNZ	LOOP	; and repeat until all bits sent 
	
	POP		DE 
	POP		BC 
	RET	
	
	
DISPLAY_AREG_ASCII:
	LD		E,A 			; convert to 16 bit integer in DE 
	LD		D,0
	LD		(7921h), DE 	; pointer to start of integer in WRA1 
	LD 		BC,0000h		; suppress commas & decimal points 
	LD		HL,ASCIIRESULT	; put ascii integer here 	
	CALL 	INT2ASCII   	; convert integer in WRA1 to ascii
	LD		HL,ASCIIRESULT	; point back to the string  	
	INC		HL 				; string is 5 digits long, only want last 2 
	INC		HL 
	INC 	HL 
	CALL	DISPLAY_STRING	; display at current cursor position 
	RET 
	
LDELAY:
	;
	; long delay - used to give the arduino time to write the data  
	; to the SD card after each sector read 
	; 
	PUSH	BC 
	LD		BC,0FFFFh 
DLOOP:	
	DEC		BC 
	LD		A,B 
	OR 		C 
	JR 		NZ, DLOOP
	POP		BC 
	RET 

DISPLAY_TRACK_SECTOR:
	PUSH	AF
	PUSH	BC
	PUSH	DE 
	PUSH	HL 
	
	CALL	CLS
	; display current track 
	LD		HL, TRACK_STRING
	CALL	DISPLAY_STRING 
	LD		A, (TRACK) 
	CALL	DISPLAY_AREG_ASCII
	LD		A, 0Dh
	CALL	DISPLAY_CHARACTER

	; display current sector  
	LD		HL, SECTOR_STRING
	CALL	DISPLAY_STRING 
	LD		A, (SECTOR) 
	CALL	DISPLAY_AREG_ASCII
	LD		A, 0Dh
	CALL	DISPLAY_CHARACTER


	POP		HL 
	POP		DE 
	POP		BC 
	POP		AF 
	
	RET 


SECTOR_ORDER:
	.db	0,11,6,1,12,7,2,13,8,3,14,9,4,15,10,5 
TRACK:
	.db 00
SECTOR:
	.db 00 
TITLE_STRING :
	.text "INSERT DISK AND PRESS <S>"
	.db 00 	
TRACK_STRING:
	.text "TRACK : "
	.db 00
SECTOR_STRING:
	.text "SECTOR: "
	.db 00 
	.end
