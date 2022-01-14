; *******************************************************************************
;
;	SIDEWAYS SCROLLY.  1280x192. SHRG 256x192 resolution.
; Assemble with PASMO.EXE assembler.
;
; =================================
; USING : AUSTRLALIAN GRFX GM7 MOD
; =================================
;
;
;
; German : 	OUT 222, 0    	- Bank 0, 1x 2k screen.  256x192x2
;		OUT 222, 1    	- Bank 1, 1x 2k screen.
;		OUT 222, 2    	- Bank 2, 1x 2k screen.
;
; Aus	 :	OUT 32, 28	- Bank 0, 1x 2k screen.  256x192x2
; 	 :	OUT 32, 29	- Bank 1, 1x 2k screen.  256x192x2
;	 :	OUT 32, 30	- Bank 2, 1x 2k screen.  256x192x2
;
; *******************************************************************************
; - Youtube video was captured as an AVI.
; - AVI 2 GIF - nine frames were captured for one entire loop of the Juggler animation.
; - Five frames were selected (each second frame). Five being the limit for our memory usage. 5x6k = 30k.
;       - Need to start using image compression!.
; - All five images were loaded into Paint Shop Pro, converted to 256x192, mono colour, saved as a .RAW image type.
; - Another homemade quickie tool was used to write out correct byte sequence as a "DB include file". (See asm listing below)
;       - 256x192: each pixel = 1 bit. 8 pixels = 1 byte. All five screens converted to five "include" files.
; - Animation assembly written German mod and include files added.
; - tested in vzem.
; - went "wow". this actually works.
; - posted onto VZ FB page.
; - GV tried it on real hardware; failed.
; - Whacked in Australian Mod.
; - tested in vzem.
; - posting on to VZ FB page.
; - over to GV for testing Aus Mod.
;
;
; - Note:	- image corruption at bottom on last frame due to memory size and whatnot. No idea.
;		- Should be lots of snow!
;






SCROLLY1	1280x192 - "Hello World" scrolly.
SCROLLY2	1280x192 - some chick laying down.	
SCROLLY3	1280x192 - some chick laying down. Not for work. Not for kids. Not for wives.

