
"PANNING". Originally written in 2013-ish, with a 384x192 image of Windows 3.1 "CHESS.BMP" background.
Dec 2020: Fiddling with the 256x192 Super High Res Graphic modes within the VZEM emulator, and had to give it a go.

Found a re-vamped version of the Chess backgroud in super cool high-res billion colour background on google.
Straight into Paint Shop Pro, resized to 512x384 and two colour. Saved as a RAW image file.
Used my old home-made rubbish program to read RAW file and output bytes in text as an 'include file'.
Pulled out the old Panning code that was written in Asm, but within a C wrapper for the Z88 Dev Kit.
Removed all the C dribble within it, changed the offsets and wrap around and what not to make it work for 512x384.
Added the few lines for the Aus graphics mode (Out 32) and the German graphics mode (Out 222).
Tested and both modes working within VZEM. 
Neither modes work correctly in an old copy of Gavins WinDSEVZ200 emulator.

-dave. 24/Dec/2020.



German : Bit 4 (so says Guy. Poke 30779,8).  Bit 2 so says doco. Poke30779,2
         Attempt POKE30779,10




GERMAN_0.VZ		Green and green. (COLOR,0). Picture is correct colour sequence for real hardware. (Inversed on VZEM)
GERMAN_0_INV.VZ		Green and green. (COLOR,0). Picture is Correct colour sequence for VZEM.  (Inversed on real hardware)

GERMAN_1.VZ		Black and white. (COLOR,1). Picture is Correct colour sequence for real hardware. (Inversed on VZEM)
GERMAN_1_INV.VZ		Black and white. (COLOR,1). Picture is Correct colour sequence for VZEM.  (Inversed on real hardware)




	ld	a, $ef		; Dark Green and Light green  	(COLOUR ,0)
	ld	(30779), a
	ld	($6800), a


	ld	a, $ff		; Black and white  		(COLOUR ,1)
	ld	(30779), a
	ld	($6800), a



* Correct in VZEM will be inverse on real hardware.
* COrrect on real hardware will be inversed on real hardware.
