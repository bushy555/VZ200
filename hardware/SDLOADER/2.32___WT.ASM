.org 7FE8h
	.db 20h, 20h, 00h, 00h, 56h, 5Ah, 44h, 4Fh, 53h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0F1h, 00h, 80h
.org 8000h

;Start of the Program
	call Beep ;Do a little cheeky beep
	call CLSsub ;clear the screen
	ld hl,BootMessage; Point HL towards to message string
	call DrawString; Draw the string on the screen
	

;This code example will Open a file and assign it a Filenumber
	ld 	hl, FILENAME1 ;point HL to the file we'll attempt to open
	ld 	a, 1		;we need to assign it a filenumber or handle
	call OpenFile	; Open the file. 
	;Errorlevel is returned in A. 1=error, 0=OK.
	cp 0
	jr z, NoError
	ld HL, ErrorMsg
	call DrawString
	jr infloop ;couldn't open the file, we'll halt the program here
NoError:
	ld HL, OKMsg
	call DrawString
;Now the file has been opened, we need to Select the file for R/W
;It is done this way so you can 'open' multiple files, and use the 
;Handle to access each file quickly.	
	ld 	a, 1		  ;Set the filehandle
	call SelectHandle ; SelectHandle - This loads the first Sector into 
					  ; RAMbuffer. It is ready to access

;Now We'll manipulate the file contents
;We'll start by displaying the file contents, 16 bytes of it
	ld HL,RAMBUFFER
	ld b,32
ShowRAMcontents:
	LD A,(HL) ;Grab the first byte of the current sector
	CALL DrawChr	;Draw it to the screen
	inc HL
	dec b
	jr nz, ShowRAMcontents
;We'll add a new line so its a bit neater
	ld a,0Dh
	call DrawChr
	
;Now we'll replace some data in the RAMBUFFER and then write it back
;to the files
	ld HL,RAMBUFFER
	ld DE,Msg2WriteBack
CopyMsg: ;a quick loop to read the message and terminate when null
	ld a,(DE)
	ld (HL),a
	inc DE
	inc HL
	cp 0
	jr nz, CopyMsg
;Now we'll write the RAMBUFFER back to the currently accessed SD Sector
	call SD_WriteSector ;

;All done! we'll let usr know and terminate the program
	ld hl,DoneMsg; Point HL towards to message string
	call DrawString; Draw the string on the screen


infloop:
	jr infloop

Msg2WriteBack:
	.DB "DATA WE'LL WRITE BACK "
	.db "TO FILE1.DAT ON THE SD"
	.DB 00h ;TASM has a hard limit to chrs on a line in a .db string. 
DoneMsg:
	.DB "ALL DONE! CHECK FILE1.DAT"
	.DB 0Dh
	.DB "ON YOUR PC",0DH,00H ;Note, the string must terminate with null. x0D is CR/LF
ErrorMsg:
	.DB "FAILED TO OPEN FILE",0DH,00H ;Note, the string must terminate with null. x0D is CR/LF
OKMsg:
	.DB "FILE OPENED!",0DH,00H ;Note, the string must terminate with null. x0D is CR/LF

BootMessage:
	.DB "FILE IO TEST ROM",0DH,00H ;Note, the string must terminate with null. x0D is CR/LF
FILENAME1:	
	.db 	22h,"FILE1",22h 	; filename to load (DAT Extension - FILE1.DAT)


RAMBUFFER   	.equ 0F800H ;512 bytes from F800 - F9FF
SDbufferAddress	.equ 0FB80h;
FAT_NextSector 	.equ 5F09h;
CLSsub 			.equ 01C9H	;Basic CLS routine
DrawString 		.equ 28A7H	;Basic Draw String routine
DrawChr 		.equ 033AH	;Basic Draw Character Routine
InKey 			.equ 2EF4H	;Basic Inkey routine
Beep 			.equ 3450H	;Basic Beep routine
OpenFile 		.equ 5F00h
SelectHandle 	.equ 5F03h
DrawFrame 		.equ 5F06h
Fat32_Root		.equ 5F0Ch
CDbasic 		.equ 5F0Fh
DIRbasic 		.equ 5F12h
Seek 			.equ 5F15h
SD_GetSector 	.equ 5F18h ; - Read the current sector, put it in location defined by SDbufferAddress (0FB80h)
SD_WriteSector 	.equ 5F1Bh; - Write 512bytes from RAMBUFFER to current sector (0F800H)
ErrorLevel		.equ 0FB05h; Error flag

.end
