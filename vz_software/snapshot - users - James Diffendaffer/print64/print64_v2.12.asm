;**************************************************
;* File: print64.z80
;**************************************************
;* Copyright (c) 2008-2015 James Diffendaffer
;**************************************************
;* Description:
;*  Emulates a 64 character by 24 line text display using 
;*  4 bit wide characters on a 256 * 192 graphics display.
;*  This version is for the VZ200 and Z80 CPU
;*
;*  Contains functions to print a string at the current screen location,
;*  print strings @ a specific screen location, line wrapping, scrolling,
;*  clear screen, the character generator and a font.
;*  Characters are stored with identical data in the left and right nibble
;*  to make rendering faster and several loops have been unrolled for speed.
;*  The print64 routine has been rewritten and now differs quite a bit from the 
;*  original spectrum code found on the worldofspectrum forum.
;*  The font rendering sequence is smaller and faster.
;**************************************************
;* Version history
;*  Version  Date               Description
;*     2.12  Oct   14, 2015      Updated 64180 code to reflect a change in register usage 
;*     2.11  Oct   14, 2015      Added printing 2 characters at a tine and optional 64180/z80 instruction usage
;*     2.10  Sept  30, 2015      changed font rendering code to use XOR.  Saves 3 instructions per character pixel height
;*     2.09  Sept  28, 2015      added .VZ file header so batch file can directly build VZ file
;*     2.08  Sept  28, 2015      documentation and code cleanup
;*     2.07  Sept  27, 2015      added background color for cls and scroll, code for inverting RAM/font
;*     2.06  Sept  27, 2015      preliminary changes to use inverse screen color.  Font needs inverted for best speed.
;*     2.05  Sept  26, 2015      reintroduced optimization that removed subtracting 32 (space) from the character
;*     2.04  Sept  25, 2015      removed redundant code from print64 and fixed some comments
;*     2.03  Sept  24, 2015      Fixed missing descenders
;*     2.02  Sept  24, 2015      Rewrote print64 routine to use 4 less instructions per byte written to the screen
;*     2.01  Sept   9, 2015      Altered documentation
;*     2.00  Sept   6, 2015      Refactored code to unroll loops, use faster instruction sequences,
;*                           altered font format to eliminate bit shifting, eliminated some unnecesary code, and fixed a bug
;*     1.04  Feb   15, 2013      Initial running VZ demo
;*     1.00         ?, 2008      Initial port to VZ (exact date unknown)?
;**************************************************

;* definitions to make TASM use more common assembler directives
#define EQU     .EQU
#define ORG     .ORG
#define RMB     .BLOCK
#define DEFB .BYTE
#define FCC     .TEXT
#define FDB     .WORD
#define END  .END

#define equ     .EQU
#define org     .ORG
#define rmb     .BLOCK
#define defb .BYTE
#define fcc     .TEXT
#define fdb     .WORD
#define end  .END

;if we want to use HD64180/Z180 instructions.  Requires using the -x3 command line option on TASM for additional instructions
;#define 64180 1

;**************************************************
;VZ ROM entry vector addresses
;**************************************************
POLCAT equ $FFDC  ; Read the keyboard



;**************************************************
;VZ Graphics hardware definitions
;**************************************************
;* VTech VZ200/300/Laser/... constants
#define screen 7000h   ; address of VZ screen memory

#define AUSMOD 1    ; for use with Australian VZ graphics mod
;#define GERMOD 1    ; for use with German VZ graphics mod

;**********
;* info for Australian hi res mod
;**********
;* video RAM $7000-$77FF
;* $6800 Bit 3 of cassette/Speaker/vdg control latch sets hi-res graphics when = 1
;* Bit 4 = VDG background 128x64
;* VDG Port is at 32 aka 20h
;* out 32,!00000000   ;text screen page zero
;* bits 0-1 = bank select
;* bits 2-4 = 6847 graphics mode 0-7
;* bit 5 = internal/external font control, unused in most mods
;**********
#ifdef AUSMOD
#define vdgport 20h    ; I/O port address to set the VDG mode

#define vdgcmode 6800h  ; address to set color palette and graphics/text select
#define vdgcolor0 00000000b ;Color palette settings
#define vdgcolor1 00010000b

#define CG1 00000000b ; CG1 graphics mode bits	GM0 OUT 32,0	64x64	Color		1024 bytes
#define RG1 00010000b ; RG1 graphics mode bits	GM1 OUT 32,4	128x64	Monochrome	1024 bytes
#define CG2 00001000b ; CG2 graphics mode bits	GM2 OUT 32,8	128x64	Color		2048 bytes
#define RG2 00011000b ; RG2 graphics mode bits	GM3 OUT 32,12	128x96	Monochrome	1536 bytes
#define CG3 00000100b ; CG3 graphics mode bits	GM4 OUT 32,16	128x96	Color		3072 bytes
#define RG3 00010100b ; RG3 graphics mode bits	GM5 OUT 32,20	128x192	Monochrome	3072 bytes
#define CG6 00001100b ; CG6 graphics mode bits	GM6 OUT 32,24	128x192	Color		6144 bytes
#define RG6 00011100b ; RG6 graphics mode bits	GM7 OUT 32,28	256x192	Monochrome	6144 bytes

;      James    Guy
;CG1	0	0
;CG2	8	8
;CG3	4	16
;CG6	12	24
;RG1	16	4
;RG2	24	12
;RG3	20	20
;RG6	28	28
;




#define CSS 00010000b ; color set select bit
#define GFX 00001000b ; graphics mode select
#endif


;**********
;* info for German hi res mod
;**********
;* address 783B bit 1 set enables 256x192
;* port 222 bit 0-1 = page
;*
;* This code is incomplete
;**********
#ifdef GERMOD
;#define vpage 222
#endif




;**************************************************
;* screen parameters
;*
;*  Define the graphics mode you are going to use as 1
;*  This is used to set up all the screen parameters used by
;*  the graphics routines so they will work in your 
;*  chosen mode. 
;**************************************************
#define GFX_RG6 1  ; Set the mode we will use here


;**************************************************
;* sets up the screen parameters based on define above
;**************************************************
#ifdef GFX_CG1   ; parameters for CG1
#define CGMODE 1
ScreenWidth  equ 64
ScreenHeight equ 64
BytesPerLine equ (ScreenWidth)/4
#endif
#ifdef GFX_CG2   ; parameters for CG2
#define CGMODE 1
ScreenWidth  equ 128
ScreenHeight equ 64
BytesPerLine equ (ScreenWidth)/4
#endif
#ifdef GFX_CG3   ; parameters for CG3
#define CGMODE 1
ScreenWidth  equ 128
ScreenHeight equ 96
BytesPerLine equ (ScreenWidth)/4
#endif
#ifdef GFX_CG6   ; parameters for CG6
#define CGMODE 1
ScreenWidth  equ 128
ScreenHeight equ 192
BytesPerLine equ (ScreenWidth)/4
#endif
#ifdef GFX_RG1   ; parameters for RG1
#define RGMODE 1
ScreenWidth  equ 128
ScreenHeight equ 64
BytesPerLine equ ((ScreenWidth)/8)
#endif
#ifdef GFX_RG2   ; parameters for RG2
#define RGMODE 1
ScreenWidth  equ 128
ScreenHeight equ 96
BytesPerLine equ ((ScreenWidth)/8)
#endif
#ifdef GFX_RG3   ; parameters for RG3
#define RGMODE 1
ScreenWidth  equ 128
ScreenHeight equ 192
BytesPerLine equ ((ScreenWidth)/8)
#endif
#ifdef GFX_RG6   ; parameters for RG4
#define RGMODE 1
#define ScreenWidth 256
#define ScreenHeight 192
#define BytesPerLine ((ScreenWidth)/8)
#endif

#define VidRAMSize 2048 ; size of video RAM window
;BytesPerLine*ScreenHeight


;**************************************************
;* graphics text routine macros
;**************************************************
#DEFINE PRINTAT(loc,str) ld bc,loc \ ld hl,str \ call print_at
#DEFINE PRINT(str) ld hl,str \ call print
#DEFINE SETVDG() out (vdgport),a
#DEFINE SetBGColor(color)   ld a,color \ ld (BACKGRND),a
;#DEFINE SETVDG(mode,page) ld a,mode+page \ out (vdgport),a
#DEFINE InvertFont(font,length)   ld hl,font \ ld bc,length \ call invert_mem

;#DEFINE DEMO2 1

;**************************************************
;**************************************************
 org  $B000-24
; fcc  VCF0     ; file type ID
 fcc  VCF0PRINT64
 defb 0,0,0,0,0,0,0,0,0  ; zero padded file name
 defb 0,$f1     ; checksum?
; fdb  endofprog-START,
 fdb  START     ; start address
 
START:
; org $B000     ;where to store out program

;**************************************************
;* test code
;**************************************************
 di
 
; SetBGColor($ff)     ; set the background color
 SetBGColor($00)     ; set the background color
 call CLS      ; clear the screen
; InvertFont(font,fontend-font) ; inverting the bits in our font so we can print black on green
 
 ld  a,GFX+vdgcolor0   ; set to graphics with color set 0
 ld  (vdgcmode),a   ; set the hardware
 ld  a,RG6
 SETVDG()      ; set the graphics mode to 256x192 B&W

#ifdef DEMO1 
 PRINTAT(24,string1)    ;demo the print routines
 PRINTAT(8*64+24,string2)
 PRINTAT(2*8*64+24,string3)
neverquit:
 jr  neverquit
#endif

#ifdef DEMO2 
 ld  hl,sstring
neverquit:
 xor  a      ;clear a
 ld  (hl),a     ;
loopy:
 ld  (hl),a
 call print
 ld  hl,sstring
 ld  a,(hl)
 inc  a
 cp  96
 jr  nz,loopy
 jr  neverquit
#endif

 ld  a,' '     ; the first character in our font
 ld  hl,TextString   ; the address where we will put our text string
lll:
 ld  (hl),a     ; write the character to the string
 inc  hl      ; point to next string address
 inc  a      ; increment the character value
 cp  '~'+1     ; last character in the character set?
 jr  nz,lll     ; branch if not
 xor  a       ; clear a
 ld  (hl),a     ; zero terminate the string

 ; print the string we just built endlessly
neverquit:
 ld  hl,TextString
 call print
; ld  hl,version    ; string with the current version number
; call print     ; print it
scan:
; call 2EF4H     ;scan the keyboard
; or  a      ;check to see if a key was pressed
; jr  nz,scan     ;keep looping as long as it is
 

 jr  neverquit
 ret

;version:
; defb "  Version 2.07 ",0

#ifdef DEMO1
;* characters are stored in first byte for demo2
sstring:
 defb " ",0
#endif

#ifdef DEMO2 
;* strings for demo1 
string1:
 defb "Graphics Page 0",0
string2:
 defb "Graphics Page 1",0
string3:
 defb "Graphics Page 2",0
#endif 
;**************************************************



;************************************************** 
;* CLS
;**************************************************
;* clear the graphics screen
;************************************************** 
CLS:
 ;set graphics page to 0
 ld  a,RG6+0     ;RG6 page 0
 SETVDG()
 call zero_fill_screen  ;clear page
 
 ;set graphics page to 1
 ld  a,RG6+1     ;RG6 page 1
 SETVDG()
 call zero_fill_screen  ;clear page
 
 ;set graphics page to 2
 ld  a,RG6+2     ;RG6 page 2
 SETVDG()
 ;fall through to fill_screen and return directly from there
 
;**************************************************
zero_fill_screen:
 ld  hl,screen    ;source
 ld  de,screen+1    ;destination
 ld  bc,VidRAMSize-1   ;number of bytes to clear
; xor  a      ;clear a
 ld  a,(BACKGRND)   ;clear a
 ld  (hl),a     ;clear first byte
 ldir       ;clear the rest

 ret
 
;**************************************************


;**************************************************
; invert_mem
;**************************************************
; hl contains pointer to RAM to invert
; bc contains number of bytes to invert
;**************************************************
invert_mem:
nxtaddr:
 ld a,(hl)      ; get original byte
 cpl        ; invert it
 ld (hl),a      ; write it back
 inc hl       ; point to next memory address
 dec bc       ; decrement count
 ; we have to do this because the Z80 doesn't update cpu flags with the DEC instruction
 ld a,b       ; if b or c has any bits set, the or will set them and the flags will show non-zero
 or c
 jr nz,nxtaddr     ; go until the counter is zero
 
 ret
 
;**************************************************


;**************************************************
; print_at
;**************************************************
; works like Microsoft BASIC PRINT@ command
; 64 characters by 24 lines in RG6 mode
; print_at locations 0-1535 (64*24-1)
; HL contains string pointer
; BC contains print@ location
;
; Since screen width is 64 (0-63), lowest 6 bits of bc is column
; The next 5 bits are the row
;**************************************************
print_at:
  ld  a,c      ;get the print at low byte
  and  (BytesPerLine*2)-1  ;111111 ;mask off row bits
  ld  (AT_COL),a    ;set the column
  ld  a,b      ;get the print at upper byte 
  and  %00000111    ;mask off top bits so carry isn't impacted
  rl  c      ;rotate top 2 bits into a through the carry
  rl  a
  rl  c
  rl  a
  ld  (AT_ROW),a    ;save row
  ;fall through to print

  
;**************************************************
; print  
;**************************************************
; hl contains the string pointer
;**************************************************
print:
  ld  a,(AT_ROW)
  ld  b,0

  ; determin what screen memory page we are going to print on and set the hardware
  ; there are 8 lines of text per page
  cp  8
  jr  c,_cnext   ; less than?
  sbc  a,8     ; adjust for next page
  inc  b     ; for graphics page setting

  cp  8
  jr  c,_cnext   ; less than?
  sbc  a,8     ; adjust for next page
  inc  b     ; for graphics page setting

  cp  8
  jr  c,_cnext   ; less than?
  sbc  a,8     ; adjust for next page
  inc  b     ; for graphics page setting
  
_cnext:
  ld  (AT_IROW),a   ; set page row
  ld  a,b     ; setup bits for changing graphics page
  add  a,RG6
  SETVDG()     ; set the hardware

_nextchar:
  ld  a,(hl)    ; get character
  cp  0     ; string terminator?
  jr  z,_printexit  ; exit if zero (string terminator)
    
;  cp       ; carriage return?
;  jr  z,_creturn   ; handle it if so
;  cp       ; linefeed?
;  jr  z,_lfeed   ; handle it if so
; tab?
; bell?
; home?
; inverse text?

  ; now calculate screen address and check for 2 character print
  ld  c,a     ; save first character
  ex  de,hl    ; save string pointer to DE
  ; IROW is corrected for the screen page by subtracting 8 for each page above 0 by the caller
  ld  a,(AT_IROW)   ; get the screen page row
  adc  a,70h    ; add screen MSB (from $7000)
  ld  h,a     ; save it
  ld  a,(AT_COL)   ; get the column
  rra       ; least significant bit only indicates which half of byte character is on
  ld  l,a     ; screen address LSB is 0 so just put a in l
  ld  (SCREENPTR),hl  ; save the screen pointer
  ex  de,hl    ; restore string pointer
  
  jr  c,onechar0   ; First character is in the right nibble so we only print one character

  ; 1st character is in the left nibble, now check for two characters
  inc  hl     ; point to next character
  ld  a,(hl)    ; get next character into A
  cp  0     ; string terminator?
  jr  z,onechar   ; we can only print one character if it's zero

  ; we can print two characters at once
  push hl     ; save string pointer
  call print642   ; output 2 characters
  pop  hl     ; restore string pointer
  inc  hl     ; next char
  ld  a,(AT_COL)   ; and 2 to column
  add  a,2
  ld  (AT_COL),a
  
  jr  testeol

onechar0:
  inc  hl     ; point to next character
onechar:
  ; character is in c
  push hl     ; save string pointer
  call print_64   ; output a character
  pop  hl     ; restore string pointer

  ;update the column
  ld  a,(AT_COL)   ; get column
  inc  a     ; next colum
  ld  (AT_COL),a   ; save it
testeol:
  cp  BytesPerLine*2  ; 64 chsrs / line (0-63)
  jr  c,_nextchar   ; is column past the end of a line?  Keep printing if not.

  ;wrap the line, update column, row, scroll
  xor  a     ; clear a
  ld  (AT_COL),a   ; set column to zero

_lfeed:
  ld  a,(AT_ROW)   ; increment the row
  inc  a
  ld  (AT_ROW),a
  cp  24     ; (ScreenHeight/8) ;24 lines (0-23)
  jr  c,print    ; if row isn't past the end of the screen, we are still worrying about possible page flips

  dec  a     ; reduce row back to last line
  ld  (AT_ROW),a   ; save it
  push hl
  call scroll    ; scroll the screen
  pop  hl
  jr  _nextchar   ; Once we get here we don't worry about switching pages so skip that code
  
_creturn:
  xor  a     ; clear a
  ld  (AT_COL),a   ; set column to zero
  jp  print    ; keep printing

_printexit:
  ret
;**************************************************


;**************************************************
;* scroll
;**************************************************
;* scroll the paged graphics screen
;**************************************************
#define Scrol1() ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi
scroll:
 ;***********************
 ;scroll page 0
 ;***********************
 ld a,RG6+0       ;RG6 page 0
 SETVDG()
 call scroll_page
 
 ;***********************
 ;copy line of characters from page 1 to page 0
 ;***********************
 ld a,RG6+1       ;RG6 page 1 (source page)
 SETVDG()
 ld hl,screen      ;copy from source page to buffer
 ld de,Scroll_Buffer
 ld bc,BytesPerLine*8    ;1 row of characters 8 bits high
; ldir

 ;copy one row of text
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 
 ld a,RG6+0       ;RG6 page 0 (destination page)
 SETVDG()
 ld hl,Scroll_Buffer    ;copy from buffer to destination page
 ld de,BytesPerLine*8*7+screen
 ld bc,BytesPerLine*8    ;1 row of characters 8 bits high
; ldir
 ;copy one row of text
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 
 ;***********************
 ;scroll page 1
 ;***********************
 ld a,RG6+1       ;RG6 page 1 (source page)
 SETVDG()
 call scroll_page

 ;***********************
 ;copy line of characters from page 2 to page 1
 ;***********************
 ld a,RG6+2       ;RG6 page 2 (source page)
 SETVDG()
 ld hl,screen      ;copy from source page to buffer
 ld de,Scroll_Buffer
 ld bc,BytesPerLine*8    ;1 row of characters 8 bits high
; ldir
 ;copy one row of text
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()

 ld a,RG6+1       ;RG6 page 1 (destination page)
 SETVDG()
 ld hl,Scroll_Buffer    ;copy from buffer to destination page
 ld de,BytesPerLine*8*7+screen  ;56=8*7
 ld bc,BytesPerLine*8    ;1 row of characters 8 bits high
; ldir
 ;copy one row of text
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 
 ;***********************
 ;scroll page 2
 ;***********************
 ld a,RG6+2       ;RG6 page 2
 SETVDG()
 call scroll_page

 ;***********************
 ;clear last line
 ;***********************
 ld hl,BytesPerLine*8*7+screen  ;BytesPerLine * # of lines per character * 7 lines + screen address
; ld (hl),0       ;store 0 at fist address
 ld a,(BACKGRND)     ; get background color
 ld (hl),a       ;store background color at fist address
 ld de,BytesPerLine*8*7+1+screen ;ld de,hl+1
 ld bc,BytesPerLine*8-1    ;one line minus first byte.
; ldir
;clrloop1
 ;copy one row of text
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 
 ret
 
;**************************************************
scroll_page:
 ld hl,BytesPerLine*8+screen ;source      ;address of 2nd line on page
 ld de,screen     ;destination    ;address of 1st line on page
; ld bc,ScreenHeight/3*BytesPerLine - BytesPerLine*8  ;number of rows for 1/3 of the screen -1 (lines on page to be scrolled)
 ld bc,2048 - 256           ;number of rows for 1/3 of the screen -1 (lines on page to be scrolled)
; ldir
scrloop1:
 ;scroll one row of text
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 Scrol1()
 jp pe, scrloop1

 ret
;**************************************************


;**************************************************
;* 64#4 - 4x8 FONT DRIVER FOR 64 COLUMNS (c) 2007, 2011, 2013
;**************************************************
;* Original by Andrew Owen (657 bytes)
;* Optimized by Crisis (602 bytes)
;* Reimplemented by Einar Saukas (496 bytes)
;* VZ implementation by James Diffendaffer (424 bytes)
;**************************************************
print_64:
  ; c contains character
#ifndef 64180
  ld  h,0
  ld  l,c    ; now HL = INT(char)
  ; now do the multiply
  ld  b,h
;  ld  c,l    ; now BC = char
  add  hl,hl   ; now HL = 2 *  INT(char)
  add  hl,hl   ; now HL = 4 *  INT(char)
  add  hl,hl   ; now HL = 8 *  INT(char)
  sbc  hl,bc   ; now HL = 7 *  INT(char)
  ex  de,hl   ; now DE contains 7 * char.
#else
  ld  d,7    ; for the multiply by 7
  ld  e,c    ; now DE = INT(char)
  ; now do the multiply
  mlt  de    ; now DE contains 7 * char
#endif
  ld  hl,(SCREENPTR) ; get the screen pointer
  ld  a,(AT_COL)  ; get the column
  rra      ; least significant bit only indicates which half of byte character is on
  ex  de,hl   ; now HL = INT(char) and DE contains screen address.  64180 HL contains 7 * char

  jr  c,RIGHTnibble ; carry is still set or clear from rra above

  ; Calculate location of the character font data in FONT_ADDR
  ; Formula: FONT_ADDR + 7 * INT ((char-32)/2) - 1

  ;left side
  ld  bc,FONT_ADDRl-224 ;add font address  - correct for missing  sbc a,' '
  add  hl,bc   ; now hl = FONT_ADDR + 7 *  INT(char)
  ex  de,hl   ; I have to use de for the font so we can add hl,bc for screen address

  ld  bc,32   ; 32 bytes per line, used to update hl below
  
  ; Main loop to copy 8 font bytes into screen (1 blank + 7 from font data)
  ld  a,(BACKGRND) ; first font byte is always background color
  ld  (hl),a   ; write background color to screen
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  11110000b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  11110000b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  11110000b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  11110000b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  11110000b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  11110000b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  11110000b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
;  inc  de    ; next font data location
;  add  hl,bc   ; next line

  ret

  
;**************************************************
RIGHTnibble:
  ;right side
  ld  bc,FONT_ADDRr-224 ;add font address  - correct for missing  sbc a,' '
  add  hl,bc   ; now hl = FONT_ADDR + 7 *  INT(char)
  ex  de,hl   ; I have to use de for the font so we can add hl,bc for screen address

  ld  bc,32   ; 32 bytes per line, used to update hl below

  ; Main loop to copy 8 font bytes into screen (1 blank + 7 from font data)
  ld  a,(BACKGRND) ; first font byte is always background color
  ld  (hl),a   ; write background color to screen
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  00001111b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  00001111b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  00001111b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  00001111b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  00001111b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  00001111b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
  inc  de    ; next font data location
  add  hl,bc   ; next line

  ld  a,(de)   ; store next font byte in A
  xor  (hl)    ; combine half screen and half font
  and  00001111b  ; mask half of the font byte
  xor  (hl)    ; combine half screen and half font
  ld  (hl),a   ; write result back to screen
;  inc  de    ; next font data location
;  add  hl,bc   ; next line

  ret

  
;**************************************************
; write two characters at once
;**************************************************
print642:

#ifndef 64180
  ; C contains left character, A contains right character
  ld  b,0
;  ld  c,a    ; now BC = INT(char)
;  inc  hl
;  ld  a,(hl)   ; get 2nd character before HL gets changed

  ; Calculate location of the first character font data in FONT_ADDR
  ; Formula: FONT_ADDR + 7 * INT ((char-32)/2) - 1
  ld  h,b
  ld  l,c    ; now HL = char

  add  hl,hl   ; now HL = 2 *  INT(char)
  add  hl,hl   ; now HL = 4 *  INT(char)
  add  hl,hl   ; now HL = 8 *  INT(char)
  sbc  hl,bc   ; now HL = 7 *  INT(char)
  ld  bc,FONT_ADDRl-224 ;add font address  - correct for missing  sbc a,' '
  add  hl,bc   ; now hl = FONT_ADDR + 7 *  INT(char)
  ex  de,hl   ; use DE for first character data pointer
  
  ; Calculate location of the second character font data in FONT_ADDR
  ; Formula: FONT_ADDR + 7 * INT ((char-32)/2) - 1
  ld  h,0
  ld  l,a    ; now HL = INT(char)

  ld  b,h
  ld  c,l    ; now BC = char

  add  hl,hl   ; now HL = 2 *  INT(char)
  add  hl,hl   ; now HL = 4 *  INT(char)
  add  hl,hl   ; now HL = 8 *  INT(char)
  sbc  hl,bc   ; now HL = 7 *  INT(char)
  ld  bc,FONT_ADDRr-224 ;add font address  - correct for missing  sbc a,' '
  add  hl,bc   ; now hl = FONT_ADDR + 7 *  INT(char)  HL is now 2nd character data pointer
#else  
  ; C contains left character, A contains right character
  ld  d,7    ; for the multiply by 7
  ld  e,c    ; left character
;  inc  hl    ; point to next character
;  ld  a,(hl)   ; get right character before we change HL
  ld  h,d    ; for the multiply by 7
  ld  l,a    ; right character
  mlt  DE    ; multiply the left character by 7
  mlt  HL    ; multiply the right character by 7
  ld  bc,FONT_ADDRr-224 ; get the right nibble adjusted font address
  add  hl,bc   ; add it to HL
  ex  de,hl   ; put it in DE so we can us HL again
  ld  bc,FONT_ADDRl-224 ; get the left nibble adjusted font address
  add  hl,bc   ; add it to HL
;  ex  de,hl   ; Code works without this, just remember DE and HL have been reversed from Z80 code
#endif 
  ;set up the screen pointers
  ld  ix,(SCREENPTR)
  ld  iy,(SCREENPTR)
  ld  bc,128   ; Index offsets only go to 127(?) so IY must be 128 greater than IX. 
  add  iy,bc
  
;start printing
  ld  a,(BACKGRND) ; first font byte is always background color
;;  ld  a,(de)   ; get byte of 1st char
;;  add  a,(hl)   ; get byte of 2nd char
  ld  (IX+0),a  ; write result back to screen
;;  inc  de    ; next font1 data location
;;  inc  hl    ; next font2 data location

  ld  a,(de)   ; get byte of 1st char
  add  a,(hl)   ; get byte of 2nd char
  ld  (IX+32),a  ; write result back to screen
  inc  de    ; next font1 data location
  inc  hl    ; next font2 data location

  ld  a,(de)   ; get byte of 1st char
  add  a,(hl)   ; get byte of 2nd char
  ld  (IX+64),a  ; write result back to screen
  inc  de    ; next font1 data location
  inc  hl    ; next font2 data location

  ld  a,(de)   ; get byte of 1st char
  add  a,(hl)   ; get byte of 2nd char
  ld  (IX+96),a  ; write result back to screen
  inc  de    ; next font1 data location
  inc  hl    ; next font2 data location

  ld  a,(de)   ; get byte of 1st char
  add  a,(hl)   ; get byte of 2nd char
  ld  (IY+0),a  ; write result back to screen
  inc  de    ; next font1 data location
  inc  hl    ; next font2 data location

  ld  a,(de)   ; get byte of 1st char
  add  a,(hl)   ; get byte of 2nd char
  ld  (IY+32),a  ; write result back to screen
  inc  de    ; next font1 data location
  inc  hl    ; next font2 data location

  ld  a,(de)   ; get byte of 1st char
  add  a,(hl)   ; get byte of 2nd char
  ld  (IY+64),a  ; write result back to screen
  inc  de    ; next font1 data location
  inc  hl    ; next font2 data location

  ld  a,(de)   ; get byte of 1st char
  add  a,(hl)   ; get byte of 2nd char
  ld  (IY+96),a  ; write result back to screen

  ret


;**************************************************
; LOCAL VARIABLES
;**************************************************
AT_COL:
        defb    0    ; current column position (0-31)
AT_ROW:
        defb    0    ; current row position (0-23)
AT_IROW:
  defb 0    ; row on graphics page ;,70h   ;70h is upper byte of screen address
BACKGRND:
  defb 0    ; background color  (set to $00 or $FF)
SCREENPTR:
  fdb  0
  
;**************************************************
; HALF WIDTH 4x8 FONT designed by Andrew Owen
; Top row is always zero and not stored (96 chars x 7 / 2 = 336 bytes)
;**************************************************
 ;**************************************************
; HALF WIDTH 4x8 FONT
; Top row is always zero and not stored (336 bytes)
; characters are 4 bits wide and 7 bits high 
; (the top row is always blank)
;**************************************************
.MODULE Font
font:
FONT_ADDRl:
 defb $00, $00, $00, $00, $00, $00, $00 ; 
 defb $20, $20, $20, $20, $00, $20, $00 ;!
 defb $50, $50, $00, $00, $00, $00, $00 ;"
 defb $20, $70, $20, $20, $70, $20, $00 ;#
 defb $20, $70, $60, $30, $70, $20, $00 ;$
 defb $50, $10, $20, $20, $40, $50, $00 ;%
 defb $20, $40, $30, $50, $50, $30, $00 ;&
 defb $20, $20, $00, $00, $00, $00, $00 ;'
 defb $10, $20, $40, $40, $40, $20, $10 ;(
 defb $40, $20, $10, $10, $10, $20, $40 ;)
 defb $20, $70, $20, $50, $00, $00, $00 ;*
 defb $00, $00, $20, $70, $20, $00, $00 ;+
 defb $00, $00, $00, $00, $00, $20, $20 ;,
 defb $00, $00, $00, $70, $00, $00, $00 ;-
 defb $00, $00, $00, $00, $00, $10, $00 ;.
 defb $10, $10, $20, $20, $40, $40, $00 ;/
 defb $20, $50, $50, $50, $50, $20, $00 ;0
 defb $20, $60, $20, $20, $20, $70, $00 ;1
 defb $20, $50, $10, $20, $40, $70, $00 ;2
 defb $70, $10, $20, $10, $50, $20, $00 ;3
 defb $50, $50, $50, $70, $10, $10, $00 ;4
 defb $70, $40, $60, $10, $50, $20, $00 ;5
 defb $10, $20, $60, $50, $50, $20, $00 ;6
 defb $70, $10, $10, $20, $20, $20, $00 ;7
 defb $20, $50, $20, $50, $50, $20, $00 ;8
 defb $20, $50, $50, $30, $20, $40, $00 ;9
 defb $00, $00, $20, $00, $00, $20, $00 ;:
 defb $00, $00, $20, $00, $00, $20, $20 ;;
 defb $00, $10, $20, $40, $20, $10, $00 ;<
 defb $00, $00, $70, $00, $70, $00, $00 ;=
 defb $00, $40, $20, $10, $20, $40, $00 ;>
 defb $20, $50, $10, $20, $00, $20, $00 ;?
 defb $20, $50, $70, $70, $40, $30, $00 ;@
 defb $30, $50, $50, $70, $50, $50, $00 ;A
 defb $60, $50, $60, $50, $50, $60, $00 ;B
 defb $30, $40, $40, $40, $40, $30, $00 ;C
 defb $60, $50, $50, $50, $50, $60, $00 ;D
 defb $70, $40, $60, $40, $40, $70, $00 ;E
 defb $70, $40, $60, $40, $40, $40, $00 ;F
 defb $30, $40, $40, $50, $50, $30, $00 ;G
 defb $50, $50, $70, $50, $50, $50, $00 ;H
 defb $70, $20, $20, $20, $20, $70, $00 ;I
 defb $30, $10, $10, $50, $50, $20, $00 ;J
 defb $50, $50, $60, $50, $50, $50, $00 ;K
 defb $40, $40, $40, $40, $40, $70, $00 ;L
 defb $50, $70, $50, $50, $50, $50, $00 ;M
 defb $60, $50, $50, $50, $50, $50, $00 ;N
 defb $20, $50, $50, $50, $50, $20, $00 ;O
 defb $60, $50, $50, $60, $40, $40, $00 ;P
 defb $20, $50, $50, $50, $50, $30, $00 ;Q
 defb $60, $50, $50, $60, $50, $50, $00 ;R
 defb $30, $40, $20, $10, $50, $20, $00 ;S
 defb $70, $20, $20, $20, $20, $20, $00 ;T
 defb $50, $50, $50, $50, $50, $20, $00 ;U
 defb $50, $50, $50, $50, $20, $20, $00 ;V
 defb $50, $50, $50, $50, $70, $50, $00 ;W
 defb $50, $50, $20, $20, $50, $50, $00 ;X
 defb $50, $50, $50, $20, $20, $20, $00 ;Y
 defb $70, $10, $20, $20, $40, $70, $00 ;Z
 defb $30, $20, $20, $20, $20, $20, $30 ;[
 defb $40, $40, $20, $20, $10, $10, $00 ;\
 defb $60, $20, $20, $20, $20, $20, $60 ;]
 defb $20, $50, $00, $00, $00, $00, $00 ;^
 defb $00, $00, $00, $00, $00, $00, $F0 ;_
 defb $20, $10, $00, $00, $00, $00, $00 ;£
 defb $00, $00, $30, $50, $50, $30, $00 ;a
 defb $40, $40, $60, $50, $50, $60, $00 ;b
 defb $00, $00, $30, $40, $40, $30, $00 ;c
 defb $10, $10, $30, $50, $50, $30, $00 ;d
 defb $00, $00, $20, $50, $60, $30, $00 ;e
 defb $10, $20, $70, $20, $20, $40, $00 ;f
 defb $00, $00, $30, $50, $50, $30, $60 ;g
 defb $40, $40, $60, $50, $50, $50, $00 ;h
 defb $20, $00, $60, $20, $20, $70, $00 ;i
 defb $10, $00, $30, $10, $10, $50, $20 ;j
 defb $40, $40, $50, $60, $50, $50, $00 ;k
 defb $60, $20, $20, $20, $20, $70, $00 ;l
 defb $00, $00, $50, $70, $50, $50, $00 ;m
 defb $00, $00, $60, $50, $50, $50, $00 ;n
 defb $00, $00, $20, $50, $50, $20, $00 ;o
 defb $00, $00, $60, $50, $50, $60, $40 ;p
 defb $00, $00, $30, $50, $50, $30, $10 ;q
 defb $00, $00, $50, $60, $40, $40, $00 ;r
 defb $00, $00, $30, $60, $30, $60, $00 ;s
 defb $00, $20, $70, $20, $20, $10, $00 ;t
 defb $00, $00, $50, $50, $50, $20, $00 ;u
 defb $00, $00, $50, $50, $20, $20, $00 ;v
 defb $00, $00, $50, $50, $70, $50, $00 ;w
 defb $00, $00, $50, $20, $20, $50, $00 ;x
 defb $00, $00, $50, $50, $50, $30, $60 ;y
 defb $00, $00, $70, $30, $60, $70, $00 ;z
 defb $10, $20, $20, $40, $20, $20, $10 ;{
 defb $20, $20, $20, $20, $20, $20, $00 ;|
 defb $40, $20, $20, $10, $20, $20, $40 ;}
 defb $50, $a0, $00, $00, $00, $00, $00 ;~
 defb $60, $90, $60, $40, $60, $90, $60 ;©
FONT_ADDRr:
 defb $00, $00, $00, $00, $00, $00, $00 ; 
 defb $02, $02, $02, $02, $00, $02, $00 ;!
 defb $05, $05, $00, $00, $00, $00, $00 ;"
 defb $02, $07, $02, $02, $07, $02, $00 ;#
 defb $02, $07, $06, $03, $07, $02, $00 ;$
 defb $05, $01, $02, $02, $04, $05, $00 ;%
 defb $02, $04, $03, $05, $05, $03, $00 ;&
 defb $02, $02, $00, $00, $00, $00, $00 ;'
 defb $01, $02, $04, $04, $04, $02, $01 ;(
 defb $04, $02, $01, $01, $01, $02, $04 ;)
 defb $02, $07, $02, $05, $00, $00, $00 ;*
 defb $00, $00, $02, $07, $02, $00, $00 ;+
 defb $00, $00, $00, $00, $00, $02, $02 ;,
 defb $00, $00, $00, $07, $00, $00, $00 ;-
 defb $00, $00, $00, $00, $00, $01, $00 ;.
 defb $01, $01, $02, $02, $04, $04, $00 ;/
 defb $02, $05, $05, $05, $05, $02, $00 ;0
 defb $02, $06, $02, $02, $02, $07, $00 ;1
 defb $02, $05, $01, $02, $04, $07, $00 ;2
 defb $07, $01, $02, $01, $05, $02, $00 ;3
 defb $05, $05, $05, $07, $01, $01, $00 ;4
 defb $07, $04, $06, $01, $05, $02, $00 ;5
 defb $01, $02, $06, $05, $05, $02, $00 ;6
 defb $07, $01, $01, $02, $02, $02, $00 ;7
 defb $02, $05, $02, $05, $05, $02, $00 ;8
 defb $02, $05, $05, $03, $02, $04, $00 ;9
 defb $00, $00, $02, $00, $00, $02, $00 ;:
 defb $00, $00, $02, $00, $00, $02, $02 ;;
 defb $00, $01, $02, $04, $02, $01, $00 ;<
 defb $00, $00, $07, $00, $07, $00, $00 ;=
 defb $00, $04, $02, $01, $02, $04, $00 ;>
 defb $02, $05, $01, $02, $00, $02, $00 ;?
 defb $02, $05, $07, $07, $04, $03, $00 ;@
 defb $03, $05, $05, $07, $05, $05, $00 ;A
 defb $06, $05, $06, $05, $05, $06, $00 ;B
 defb $03, $04, $04, $04, $04, $03, $00 ;C
 defb $06, $05, $05, $05, $05, $06, $00 ;D
 defb $07, $04, $06, $04, $04, $07, $00 ;E
 defb $07, $04, $06, $04, $04, $04, $00 ;F
 defb $03, $04, $04, $05, $05, $03, $00 ;G
 defb $05, $05, $07, $05, $05, $05, $00 ;H
 defb $07, $02, $02, $02, $02, $07, $00 ;I
 defb $03, $01, $01, $05, $05, $02, $00 ;J
 defb $05, $05, $06, $05, $05, $05, $00 ;K
 defb $04, $04, $04, $04, $04, $07, $00 ;L
 defb $05, $07, $05, $05, $05, $05, $00 ;M
 defb $06, $05, $05, $05, $05, $05, $00 ;N
 defb $02, $05, $05, $05, $05, $02, $00 ;O
 defb $06, $05, $05, $06, $04, $04, $00 ;P
 defb $02, $05, $05, $05, $05, $03, $00 ;Q
 defb $06, $05, $05, $06, $05, $05, $00 ;R
 defb $03, $04, $02, $01, $05, $02, $00 ;S
 defb $07, $02, $02, $02, $02, $02, $00 ;T
 defb $05, $05, $05, $05, $05, $02, $00 ;U
 defb $05, $05, $05, $05, $02, $02, $00 ;V
 defb $05, $05, $05, $05, $07, $05, $00 ;W
 defb $05, $05, $02, $02, $05, $05, $00 ;X
 defb $05, $05, $05, $02, $02, $02, $00 ;Y
 defb $07, $01, $02, $02, $04, $07, $00 ;Z
 defb $03, $02, $02, $02, $02, $02, $03 ;[
 defb $04, $04, $02, $02, $01, $01, $00 ;\
 defb $06, $02, $02, $02, $02, $02, $06 ;]
 defb $02, $05, $00, $00, $00, $00, $00 ;^
 defb $00, $00, $00, $00, $00, $00, $0f ;_
 defb $02, $01, $00, $00, $00, $00, $00 ;£
 defb $00, $00, $03, $05, $05, $03, $00 ;a
 defb $04, $04, $06, $05, $05, $06, $00 ;b
 defb $00, $00, $03, $04, $04, $03, $00 ;c
 defb $01, $01, $03, $05, $05, $03, $00 ;d
 defb $00, $00, $02, $05, $06, $03, $00 ;e
 defb $01, $02, $07, $02, $02, $04, $00 ;f
 defb $00, $00, $03, $05, $05, $03, $06 ;g
 defb $04, $04, $06, $05, $05, $05, $00 ;h
 defb $02, $00, $06, $02, $02, $07, $00 ;i
 defb $01, $00, $03, $01, $01, $05, $02 ;j
 defb $04, $04, $05, $06, $05, $05, $00 ;k
 defb $06, $02, $02, $02, $02, $07, $00 ;l
 defb $00, $00, $05, $07, $05, $05, $00 ;m
 defb $00, $00, $06, $05, $05, $05, $00 ;n
 defb $00, $00, $02, $05, $05, $02, $00 ;o
 defb $00, $00, $06, $05, $05, $06, $04 ;p
 defb $00, $00, $03, $05, $05, $03, $01 ;q
 defb $00, $00, $05, $06, $04, $04, $00 ;r
 defb $00, $00, $03, $06, $03, $06, $00 ;s
 defb $00, $02, $07, $02, $02, $01, $00 ;t
 defb $00, $00, $05, $05, $05, $02, $00 ;u
 defb $00, $00, $05, $05, $02, $02, $00 ;v
 defb $00, $00, $05, $05, $07, $05, $00 ;w
 defb $00, $00, $05, $02, $02, $05, $00 ;x
 defb $00, $00, $05, $05, $05, $03, $06 ;y
 defb $00, $00, $07, $03, $06, $07, $00 ;z
 defb $01, $02, $02, $04, $02, $02, $01 ;{
 defb $02, $02, $02, $02, $02, $02, $00 ;|
 defb $04, $02, $02, $01, $02, $02, $04 ;}
 defb $05, $0a, $00, $00, $00, $00, $00 ;~
 defb $06, $09, $06, $04, $06, $09, $06 ;©
fontend:

curchar:
 defb 0

endofprog:
TextString:
 rmb 256

;**************************************************
; Determine where temporary buffer for the screen scroll will lie
;**************************************************
Scroll_Buffer:
  rmb BytesPerLine*8 ; temporary buffer for copying across page boundary
 

;**************************************************
 
  end
;**************************************************
;**************************************************