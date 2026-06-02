
==================
(G)  EMULATORS
==================

VZ / Laser EMULATORS v1.3						as at June/2026.
=========================


(1) VZEM			- Guy Thomason

    a) DOS								16bit DOS / Command line.

    b) Windows GUI							Windows 32-bit

    c) SDL release

    c) Android

    d) Pocket PC

    e) Raspberry PI

(2) JamesVZ200.			- James 'EmuCompBoy' Tamer. 		Windows.

(3) MAME.			- Juergen Buchmueller and Dirk Best	Windows. Linux

(4) JEMU (java)			- Richard Wilson	    		Windows. Linux

(5) WinVZ300 and DSEVZ200 	- Gavin Turner				Windows

(6) Emulator 2001 		- Gavin Turner				Windows

(7) VZ SoundPaint java emu	- Jürgen Reuter				Windows. Linux

(8) VZ200 Remake (java)		- Jürgen Wahlmann & Christian Wahlmann	Windows. Linux

(9) Laser 310 Emu 		- ZZEMU    (SDL2, DD20) 		Windows

(10) FPGA Laser310 emu		- ZZEMU.   				FPGA : Altera Cyclone based FPGA DE0, DE1, DE2 boards.

(11) VZ Emulator		- Paul Anderson				Windows.

(12) VZ-Next			- Paul Robson				Windows. Linux. ESP32. Raspi 

(13) MISTer 			- Alan.					MiSTer port of the core from PGA Laser310 emu

(14) JSMESS 			- Jason Scott				Windows. Linux.

(15) Laser 310 Emu 		- Antonino Porcino.			Windows. Linux.

(16) Emulator 			- Richard Chandler			Windows. ?

(17) FPGA Laser 210 clone	- Jesus Arias (2025). 			FPGA : Alhambra-II.

(18) Laser310 Browser VZEM	- Guy Thomason 				Browser		https://www.compumuseum.com/emularity.html?machine=laser310



(1) VZEM   -  FAQ - Guy Thomason's VZEM Emulator v.2.2
========
VZEM and VZEM SDL			https://bluebilby.com/sdm_categories/tools/

Guy's Main site		(bad link)	http://intertek00.customer.netspace.net.au/vz200/
VZEM v2.2 (DOS)		(bad link)	https://vzalive.bluebilby.com/emulators/vzem_22.zip
VZEM (aka WinVZ)	(bad link)	https://vzalive.bluebilby.com/emulators/winvz4.zip
VZEM SDL		(bad link)	http://intertek00.customer.netspace.net.au/vz4sdl/
VZEM Android		(bad link)	http://intertek00.customer.netspace.net.au/vz4droid/
VZEM Pocket PC		(bad link)	http://intertek00.customer.netspace.net.au/pocketvz/
VZEM Raspberry PI	(bad link)	http://intertek00.customer.netspace.net.au/PI2VZ.htm   
3 chip project		(bad link)	http://intertek00.customer.netspace.net.au/3ChipVZ/



VZEM INDEX
----------
0) Introduction.
1) Running, editing and listing the code within the Emulator.
2) Loading TEXT files, or an ASCII program listings into the Emulator.
3) ROM versions.
4) Memory Capability.
5) LLIST or LPRINTING 
6) Opening files - VZ and WAV.
7) Opening files - floppy disk images.
8) Saving your code.
9) Importing BMP images.





0) Introduction
-----------------

In late 1998 a group of VZ enthusiast people were founded together by George Lui 
through a direct email list. This only lasted for a month or three before the 
"VZEMU" Yahoogroups email list started. Within 12 months there were around 100
odd members from around the globe. These first two to three years within the 
group was really really a cool time to be alive.

Guy Thomason hit the world with his first release of a small green screen executable 
in around July 1999. This was the first working VZ emulator. Development through his 
enthusiasm was quick and only within a few months Guy released a full working 
version of his emulator that would interpret the BASIC in ROM of a real VZ, and 
shortly after, VZ DOS. 
In September 2001 his emulator supported cassette, floppy disk & 4MB of paged memory.

The formatting format of the original DOS/Command-line version of VZEM emulator 
(versions 1 and 2.0), dated 1999, has a slight bug within. The format of the original came out 
as a 98k image, whilst version 2.2 and all subsequent releases of VZEM in all flavours all had 
99k images.  This small fix will change the original release to fix the 98 to 99k problem. 
However, please note, that all of those original 98k images can not be read correctly.

From Guy:
"Disk formatting:
Yeah it seems to work OK now. If you can't wait for the upgraded 
version, change the byte at 1BE73H in VZEM.EXE from A0H to B0H."


The latest release of his emulator (dated around Feb 2021) fixes a few common annoyances that 
have lurked within for a few years. After hundreds of hours of personally testing the product 
alongside real hardware, it is as close as you will ever get. Super High Res Graphics and 1-bit 
audio are absolutely spot on. And in some rare circumstances (1-bit audio), the emulator actually
works better, whereas there is hardware limitations (think 1-bit audio and the VZ's own internal 
piezo speaker) for instance, where the internal speaker refuses to play. Plugging in an external 
amplified speaker to the piezo speaker plays the music perfectly as does the emulator.

During the years, Guy has released a number of flavours of his emulator, on to Raspberry, 
Android, and even a Pocket Pc. Guy will become your best friend should you mention the words 
'beer' and/or 'bacon'. Please do not ever mention the word 'iPhone' to him. 


The most latest and current version of VZEM emulators are:

Command-Line text-only VZEM 	: v 2.2. 23/Sep/2001.
PocketPC VZEM			: v Build 20080929
Android VZEM			: v Oct 2016.		
Windows GUI 			: v Build 20230225	(Feb 2023)

Command Line Version 2.2 emulates the following VZ hardware:
* 4 meg RAM, in switchable 16k pages, mode0 & mode1 graphics, disk drive, vz speaker, 
keyboard.

Windows GUI emulates all of the above, including up to 256x192 extended graphics, 
AY & 76489 sound chips and more.

Note, Guy removed extended sound emulation (AY8910 & SN76489) from after his Nov 2010 VZEM release.




1)  Running, editing and listing the code within the Emulator.
--------------------------------------------------------------
Some BASIC knowledge is assumed in the following.
Whilst other emulators can change keyboard combo to suit, or use a character or key replica
to that of a standard PC keyboard , eg: Left open bracket on VZ is left open bracket on PC
keyboard, VZEM doesn't do this. 
Essentially VZEM is a physical-layout key-for-key identical replica of the VZ/Laser keyboard 
to that, say, of a typical PC style keyboard.
Double quotes? "  : they are <Shift> + <2> where it is on the VZ keyboard.
At sign @         : its at <shift> + <0>   where it is on the VZ keyboard.

Editing : use either the PC arrow keys to move the cursor around, or,
the VZ's original editing keys:

<Ctrl> + <M>      for arrow left
<Ctrl> + <comma>  for arrow right
<Ctrl> + <period> for arrow up
<Ctrl> + <space>  for arrow down
<Ctrl> + <5> is the shortcut to the 'LIST' command.
<Ctrl> + <6> is the shortcut to the 'RUN' command.
<Ctrl> + <->  is the VZ's <ctrl>-<break> key combination.
<Ctrl> + <L>  will INSERT a space when editing.
<insert>      will insert a space when editing.
<Ctrl> + <semicolon> will delete a character when editing.
<DEL>                will delete a character when editing.
<Ctrl> + <apostrophe> is the VZ Inverse key, that will inverse text.
<Apostrophe> is the VZ's colon character input key.

Ideally, you would have a photo of a VZ or Laser sitting in front of you.
After 21 years of using VZEM, you do naturally get used to where the keys are located.
For first timers though, I can understand your frustration.



2)  Loading an ASCII program listings into the Emulator.
--------------------------------------------------------
Loading ASCII.   Have a BASIC listing , say, in Notepad or Notepad++.  
Select all, and copy to place it into the computers clipboard. 
Within the emulator, simply select 'Edit' --> 'Paste'. 
This will paste the contents from the clipboard into the emulator, along with
carrage returns at the end of each line.
The emulator does intermittently skip characters (line numbers, line content, 
carriage returns).

The fix :

- Usually pad out each line of the text file with five <CR> between each line
- or re-paste individual lines from the text file.



3. ROM versions.
-------------------
VZEM comes with the latest VZ BASIC ROM (version 2.0 and a patched version 2.1)
and VZ DOS BASIC (version 1.2) 
To run a different ROM, for example the modified BASIC v2.1+, select :
   FILE --> LOAD ROM. 
Then select the ROM, and File --> Reset.   
The selected ROM will now be loaded and fired up.



4. Memory capability.
----------------------
VZEM offers everything, bar the fully fledged "64k ram expansion" experience.  
By default it is set for 4 meg, which simply uses 256x memory banks of 16k.
The first four memory 16k banks will be equal to a 64k VZ, so in essence, the 
user is experiencing the lush outfit of 64k. This is all controlled by OUT 
statements selecting the banks. 
See VZEM Readme.txt file for further technical info on using the OUT statements
for switching banks for RAM, as well as Extended Graphics, for the use of 
BASIC, C and Assembly.



5.  LLIST or LPRINTING the corrected code to provide corrected images of code.
-------------------------
Within the emulator select FILE --> MAP PRINTER.  A pop up windows will ask for 
a destination folder & filename. After a LLIST, LPRINT or COPY, anything to go 
to the printer, will be outputted to the text file.
Note: VZEM needs to be closed in order for the printer output text routine to 
write out the text file correctly.

The outputted text file, if it is a listing, can be re-edited in Notepad 
(for example) when semi-graphic characters are in use, and, then the text file 
can be re-imported back in.



6.  Opening files - VZ and WAV.
--------------------------------

This is the most useful and single handed most used feature of VZEM. 
That is, the ability to open and run a .VZ program in an emulated state.

Go to File --> Load VZ --> navigate to the correct directory and select the 
.VZ snapshot that you wish to run.
Depending on the file type, the program will essentially perform a "CLOAD" 
(so to speak) for BASIC programs, and then you type "RUN" and press enter. 
Or, the selected program will auto-execute for BINARY written games and utility 
programs.

If you wish to open a .WAV file, you will need to first convert the WAV file into 
a VZ snapshot file through the use of one of the many conversion tools that are 
available on a number of websites.




7.  Opening files - floppy disk images.
----------------------------------------

To mount a floppy disk image, the quickest/easiest method is to:
Find the BLANK.DSK image that comes with VZEM, and make a copy of it & rename it.
Run VZEM, select FILE --> DISK --> MOUNT and then select either Drive 1 or drive 2.
Select the newly copied and renamed blank disk image.

Save your BASIC programs by using  :    SAVE"PROGRAM"
Or, your machine language programs :	BSAVE"PROGRAM",start_address_HEX,end_address_HEX

To save the contents of the screen, for example, :  BSAVE"SCREEN",7000,7200
To reload that screen image:  CLS:BLOAD"SCREEN"

To unmount a disk image, simply follow the same above after selecting :
FILE --> DISK --> UNMOUNT



8.  Saving your code.
---------------------
File --> Save VZ  : This will allow the user to save either the BASIC or Machine 
Language program , as either, also allows you to enter in start and end memory 
addresses, as well as allowing the saving as a .VZ snapshot file, or a standard 
Windows PCM .WAV file that will allow immediate play-back into a real VZ. 

If a disk image was previous set up, with DRIVE 1 being selected to said disk image, 
the BASIC / BINARY file can be SAVE'd / BSAVE'd to the disk image.
The disk image is saved as a .DSK 99 kilobyte disk image file, and can also be easily 
copied/ stored/ sent/ re-loaded. Unfortunately the .DSK file format is only 
compatible with Guy's Emulator, the MAME/MESS emulator, and another fellow's upcoming 
emu that is still being written.

By far the most common method now has been to use the versatile .VZ snapshot for 
storing / archiving purposes.

From version 20210204 (4th February 2021 release), Guy implemented the saving 
function to also include saving your program as a .WAV file.
Within the save screen, simply select .WAV , and check your BASIC (F0) or BINARY (F1) 
settings along with the start and end addressing. This saves the hassle of performing 
a VZ2WAV conversion afterwards when you wish to transfer the program to real hardware.




9) Importing BMP images.
------------------------
In 2009 era, this function was added in, to allow to loading and storing of 6k in size
super High-res 256x192 mono graphical images. There was no other method of loading in
such files in to upper high memory, and so, this import function came about.
This function simply checks if a selcted .BMP (standards windows bitmap .BMP file)
is 256x192 2-colour, and then loads this to $C000 with an end address of $D800.

If a disk drive image is mounted, you can save the image to a disk .DSK image by the
line command :   
                BSAVE "IMAGE1",C000,D800

In order to view the file as an image, a program will need to be written to load the first
2k of the image to $7000 to the first bank of either the Aus or German mod mode, then 
the second 2k is required to go to the second bank of extended graphical memory, and 
then finally the third 2k of the 6k image needs to go to $7000 of the third bank of ram.
This is a little outside the scope of this file, however, more information can be read
within the readme.txt file that comes with VZEM , or, enquire further on to the VZ Fans
Facebook group.

This is the method in which most of the youtube animation type VZ videos have been created.

Of course, through the use of further tools, the disk image can then be transferred over 
to a real floppy disk and, if your real VZ happens to have the super high-res graphics 
modifications, the above mentioned program can be written, and the high-res image(s) can 
be viewed on real hardware. Have enough images and animation is easily possible.


Words from Guy: Importing 256x192 screens into memory into VZEM.
There’s probably better ways, but this is the developers methods:
I bumbled my way through it by:
- Use irfanview to advance each frame of juggler.avi (24 frames)
- Press Ctrl + F11 to capture each frame to a directory
- Use the irfanview batch convert feature to convert each frame from 320x200 color to 256x192 mono

Once all the frames were converted I used the “Import BMP” feature in vzem to load each bitmap to 
address 8000h I did a BSAVE of each bitmap 8000h – 9800h  (6k) spanning two disks
			     c000  - d800  49152 to 55296
FOR I=49152-32767 TO 55296-32767:poke i-16384,peek(i):next
The basic loader program BLOADs each frame from disk, saving each frame to bank memory
To get the animation the program loops through each frame, activates that bank and blits it to the 
screen. Once I started on it properly the whole thing only took about 3 or 4 hours, was very 
gratifying to actually see it work!











===============
(2) James VZ200.
===============
By: James Tamer
JVZ was written very early in the peace, having been the second VZ emulator released sometime in 
the 2000-2001 era, and unfortunately the initial released copy of it was not ever kept.
Version 0.2.0 was released in 2002 with version 0.2.1 being the final release.
geocities died years ago, ocities is the archive of geocities.

Original link was : 			http://www.geocities.com/emucompboy
JVZ200 (v0.21b)                		http://www.geocities.ws/emucompboy/        
JVZ200 (v0.21b)				http://www.oocities.com/emucompboy



===============
(3) MAME (mess).
===============

VZ by: Juergen Buchmueller and Dirk Best

MAME.ZIP (6 parts included in this repositry) is version 2.17 x32 from 2019 era.
Configured for the VZ/Laser with a bunch of games, demos and music under the .\snapshot directory.


MAME is the biggest and largest combination of emulators on this planet. All rolled up into one 
heck of a single platform. Juergen Buchmueller and Dirk Best were both members of the VZ Yahoogroups
list in the early years, and wrote the VZ emulator within MESS/MAME. 
Disk drive and serial terminal emulation works. 


http://www.mamedev.org					MAME						
https://messui.1emulation.com/				Downloads.
https://messui.1emulation.com/howto.html		How to. Website still alive Feb 2022.
https://docs.mamedev.org/usingmame/index.html		Basic MAME Usage and Configuration
http://www.youtube.com/watch?v=0kIcY2f7f_A		fx.vz running on MESS (Youtube)
https://www.planetemu.net/roms/mess-roms		Download ROMS from here. (Valid Aug '25)
https://mame.spludlow.co.uk/Machine.aspx?name=vz300	Download ROMS from here. (Valid Aug '25)
https://wiki.batocera.org/systems:laser310		Good writeup for VZ/Laser configuration for MAME.


Quick Setup overview
--------------------

1. Find and download MESS.

2. Install to C:\MESS

3. Command prompt, Go to drive letter, CD \MESS

4. MESS -CC		(creates MESS.INI)

5. Create c:\mess\ini 

6. move mess.ini to c:\mess\ini

7. create sub directory 	c:\mess\roms

8. create sub directory 	c:\mess\ini

9. edit c:\mess\ini
	    	readconfig 		1
	    	writeconfig 	1
	    	inipath 		ini
	    	menu 		1
	    	filter 		0
	    	hlsl_enable 	0
	    	rompath             c:\mess\roms

9. Find these files
     		vtechv20.u09
     	 	vtechv20.u10
		vtechv20.u12
      		vtechv20.lo
      		vtechv20.hi
      		vtechv20.rom

10. ZIP up  vtechv20.u09 and vtechv20.u10 and rename ZIP file to: LASER210.ZIP
    ZIP up  vtechv20.u12 and rename ZIP file to: LASER310.ZIP
    ZIP up  vtechv20.lo and vtechv20.hi and rename ZIP file to: VZ200.ZIP
    ZIP up  vtechv20.rom and rename ZIP file to: VZ300.ZIP

11. MOVE ZIP files to c:\mess\roms
    In later MAME versions, place your VTech Laser 310 ROMs in /userdata/roms/laser310/


12. From command prompt within c:\mess , type :  	MESS LASER310
	Screen should come up. Type in 'ok', and the VZ screen should then come up.
    From c:\mess should be able to run MESSGUI.EXE and run any of the listed VZ/Laser systems.

13. MESS File Manager and Settings PRESS :

      Press :  <SCROLL LOCK> then <TAB>

      Down-arrow down to SNAPSHOT. Go looking for a .VZ file.


14. Using snapshot (.vz) files is recommended, as these are binary memory dumps with a simple header.
    They can be automatically bootstrapped by MAME. 
    .CAS cassette formats will require keyboard interaction from the user :
      'CLOAD' followed by the F2 key to start the tape.




MD5 checksum				Share file path		Description
42c8f9e6c2133ae0e953b89ccbbdb7e2	bios/laser310.zip	vtechv20.u12: BASIC V2.0
f7e5d9a3eb2b57bf5f4e2a4565318a8f	bios/laser310.zip	vtechv21.u12: BASIC V2.1 (hack)



3. ROM INFO for MESS
---------------------

resource (
        name laserfdc
        description "Laser/VZ Floppy Disk Controller"
        rom ( name vzdos.rom size 8192 crc b6ed6084 )
)

resource (
        name vz_rs232
        description "DSE VZ-200/300 RS-232 Interface"
        rom ( name rs232_v15.ic2 size 2048 crc 6545260d )
)

resource (
        name wordpro
        description "DSE VZ-300 WordPro"
        rom ( name wordpro.u3 size 4096 crc c37ea780 )
        rom ( name wordpro.u4 size 4096 crc 2e3a8c45 )
        rom ( name wordpro.u5 size 4096 crc 2a336802 )
)

game (
        name vz200
        description "VZ-200 (Oceania)"
        year 1984
        manufacturer "Dick Smith Electronics"
        rom ( name vz200_v101.u9 size 8192 crc 70340b97 )
)





4. More info
------------


* Press F5, this will scan your roms so that MESSUI will know which systems can be run.
* Click on View, Customize fields... - you can choose which columns to display in the list of systems
* Click on View, and make sure the first 5 choices are ticked/checked.
* Click on View, Show Pictures and choose which things you would like to see on the righthand side.
* Click on Options, Directories and for each item in the list, choose where it is located. The list is somewhat daunting, so for now do nothing, it can be fine-tuned later.
* Click on Options, Background Image... - navigate to a folder containing PNG files, then choose a nice-looking one.
* Now, the system list might be hard to read, so click on Options, System List Font, and choose another colour. Note this changes ALL text in MESSUI.
* Click on Options, System List Clone Color - if you want clones to be another colour, choose it here. You can't choose a different font.
* Click on Options, Default System Options - this should be the same as you had set up in MESS.INI earlier, but you can change it here. It only applies to systems you have never run.
* Now, exit MESSUI so we can save our settings. If MESSUI crashes, any changed settings are lost. 





5. Words from Dirk Best.
------------------------
MESS can be confusing to use, it's the price we have to pay to support a few thousand 
systems and run on many different operating systems.

Some tips:

First time you run MESS, start it with "mess.exe -cc", this creates the mess.ini main 
config file. I like to edit it and disable fullscreen for example.

Some keys:

- ScrLock: Disables or enables full keyboard mode. In full keyboard mode, all
   keys are grabbed and sent to the emulated system (so you can't even exit the
   emulator with ESC). In partial keyboard mode, the UI keys respond as normal.
- F12: Screenshot
- F11: Display current emulation speed and framerate
- F10: Toggle throttle, if you don't want to wait for something to load (great for tapes)
- Tab: Open builtin menu, to load files or configure the emulator

Starting a system from the command line with the -listmedia switch will
display the files it accepts. For vz300:

d:\workspace\mame>mess64.exe vz300 -listmedia
 SYSTEM      MEDIA NAME (brief)   IMAGE FILE EXTENSIONS SUPPORTED
----------  --------------------  ------------------------------------
vz300        printer     (prin)     .prn
             snapshot    (dump)     .vz
             cassette    (cass)     .wav  .cas
             cartridge   (cart)     .rom
             floppydisk1 (flop1)    .dsk
             floppydisk2 (flop2)    .dsk

So you can use "-dump file.vz" to load it.


-ramsize ram_value'', where //ram_value// can assume one of the following values 
  2k - standard model
  18k - with 16K memory expansion
  66k (default) - with 64K memory expansion
  4098k - with 4MB memory expansion


MESS Debuger 				mess.exe vz300 -debug			(type help)

Loading a file from command line	mess.exe vz300 -dump FX.VZ

Using the builtin file manager		mess.exe vz300
						Press <ScrLock> to disable full keyboard emulation.
						Press <TAB>
						Select the File Manager and then load FX.VZ into the Snapshot slot.

Dumping to AVI video file		mess.exe vz300 -dump FX.VZ -aviwrite fx.avi



As of around 2023, MAME now supports emulation of the RTTY ham radio module, the Dick Smith serial terminal module kit,
and full emulation of Ben Grimmett's SD Loader.


						

6. Running MAME on Linux - Command line example
------------------------------------------------
mame laser210 -mem laser_64k -video soft -ui_active -bp ~/.mame/roms -resolution0 1280x720 -aspect 1000:750 -skip_gameinfo -nowindow -dump thejungle.vz 









(4) JEMU

Richard Wilson's name is big within the Amstrad CPC community. He wrote WinApe. Never heard of 
WinApe? Do a google. Richard was also a member of the VZ community in the early years whilst he
wrote his java emulator. Its all there within his site. Load it up, get Java working, and play 
a game as if you were on a real VZ. Richard lives in Tasmania, Australia.

Java VZ					https://jemu.winape.net




(5) WinVZ300 / DSEVZ200 

Gavin Turner is (was?) a highly active fellow in Christchurch in New Zealand. Loves his emulators. 
Has written a number of them for differing flavours of hardware over he years. Originally writing 
Emulator 2001 with a bunch of things rolled into one, he turned to the humble VZ and decided to 
write a dedicated VZ emulator, 100%, in Intel assembley. A tough gig, but managed to do it with his 
first release in 2010-2011 era. After many many releases, some of which were not ever captured, his 
final release in his first round came in about 2013 which had its own 1 meg download installer.
This was unfortunate to most VZ users since we quite liked a single executable. 
Gavin left the VZ community under some bad terms shortly after.
Fast forward to 2019 era, and out of nowhere Gavin came back with a second round of releases into 
a single executable file. He shot out three more releases that fixed issues from the previous rounds
There was some concerns within the community that a lot of anti-virus software were picking up his
emulator as being a virus. Gavin disappeared from the community again after his third release.

Gavin can be found on his 'VZ demo' Facebook page; and unfortunately performing a google search on 
his emaultor will find many many pages acknowledging his emulator, but most, if not all, go to now
dead download links. 

Original website (long been dead): 	http://gstsoftware.co.nz/        
Can still be found on Way Backmachine.

WinVZ300 / DSEVZ200 / Emulator 2001	https://web.archive.org/web/20160303181605/http://gstsoftware.co.nz/
Latest version on Facebook		https://www.facebook.com/dsvz200/ 
					https://web.archive.org/web/20130801182925/http://www.gstsoftware.co.nz/ 	   
DSVZ200 				https://web.archive.org/web/20130730230114/http://www.blockypixels.com:80/ 	   
DSEVZ200				https://emutopia.com/index.php/emulators/item/369-vtech-laser-200/1093-dsevz200
WinVZ300				https://github.com/PhoenixInteractiveNL/emuDownloadCenter/wiki/Emulator-winvz300 	   
Archive site				https://archive.is/hsAiB



(6) Arcadia Emulator 2001

By Gavin TUrner

Arcadia-2001				https://web.archive.org/web/20051026150459/http://www.gstsoftware.co.nz/ 	   




(7) SoundPaint - Jürgen Reuter

by: Jürgen Reuter
Sits on Github with a youtube available showing Jurgen performing a lecture about it.

Soundpaint VZ Emu			https://github.com/soundpaint/VZ200-Emulator
video #1				https://www.youtube.com/watch?v=S65sOWSTnGA
Video #2				https://media.ccc.de/v/gpn19-114-retrocomputing-emulator-vz200-z80





(8) VZ200 Remake

By: Jürgen Wahlmann & Christian Wahlmann
Is a full on remake of Richard's Java VZ, with many updates.

VZ200Remake				https://github.com/cwahlmann/vz200-remake
					https://github.com/cwahlmann/vz200




(9) ZZEMU Laser 310 Emu

"LASER310 Emulator"

ZZEMU Laser 310 emu			https://github.com/zzemu-cn/LASER310EMU





(10) ZZEMU's FPGA - By ZZEMU


Terrasic FPGA DE1 DE2			https://github.com/zzemu-cn/LASER310_FPGA
Terrasic FPGA DE1 DE2 Floppy		https://github.com/zzemu-cn/LASER310_FPGA_DD20
Terrasic FPGA base version 		https://github.com/zzemu-cn/LASER310_FPGA_BASE





(11) VZ Emulator - By: Paul Anderson


"An emulator for the VZ200/VZ300 Z80 8-bit CPU based Computer. Written in c#"

VZEmulator				https://github.com/PaulAnderson/VzEmulator
					https://github.com/PaulAnderson/VzEmulator/releases/tag/Release
					v1.00 released 1/Sep/2024.

>Thanks for dropping in, I had no idea anyone else was still interested in this! 
>I've seen a few a few of the other emulators around and wanted to create my own 
>as a learning exercise and to be able to add new features.
>
>Pity Yahoo killed everything off!. I'll check out the facebook group.
>Cheers
>Paul



(12) VZ-Next

by: Paul Robson. "An implementation of the TX800/VZ200/Laser200 platform for ESP32/Windows/Linux/Raspi"

VZ-Next					https://github.com/paulscottrobson/vz-next


https://github.com/paulscottrobson/vz-next-aux	VZ/Laser/Texet emulator, hardware and software
https://github.com/paulscottrobson/vz400	VZ400. VZ/Laser/Texet emulator, hardware and software
https://github.com/paulscottrobson/vz-next-2



(13) MISTer - Alan.

By: Alan. "This is a MiSTer port of the core of	https://github.com/zzemu-cn/LASER310_FPGA_DD20"

MISTer					https://github.com/alanswx/Laser310_MiSTer
					https://github.com/MiSTer-devel/Laser310_MiSTer




(14) JSMESS

By: Jason Scott 
MESS
					https://github.com/jsmess/jsmess/wiki/JSMESS-v1.0-Systems



(15) Laser 310 Emu 

By: Antonino Porcino.
Written in Feb-Mar 2021. Updated continuously.
 
Laser310 java website			https://nippur72.github.io/laser310-emu/
					https://github.com/nippur72/laser310-emu

Load up the emulator in your favourite browser. (Emulator will not work on anything on Windows XP)
Simply Drag and Drop a .VZ file in to the emulator screen.

The emulator now can dump to a WAV file to the cassette and speaker outputs. 
The commands are :
- open browser's JavaScript console (F12 key)
- type "csave()" on the console (without quotes)
- make any sounds on the emulator
- type "cstop()" on the console
The .wav file will be downloaded as a normal browser download.

Little bit offtopc, Antonino is also a Laser500 guru. His online Laser500 emulator is here:	 nippur72.github.io/laser500emu



(16) VZ Emulator - By: Richard Chandler

No information yet available.





(17) FPGA Laser 210 clone	- Jesus Arias (2025)

Supplied by SK 21/July/25.
Destined FPGA:  Alhambra-II.
Description and details : 	http://www.ele.uva.es/~jesus/laser200.pdf
Download files		:  	https://www.ele.uva.es/~jesus/VZ200.tgz




(18) Laser310 - Browser based DOS based VZEM.

URL	: https://www.compumuseum.com/emularity.html?machine=laser310


It is a home personal computer based on Z80 processor designed by Hong Kong VIEE, which was 
once introduced to the mainland as a large number of educational equipment.
This emulator is 
a VZEM running in DOSBox. Its speed is slightly slower than that of a solid machine. Please 
wait patiently for loading and the words "READY" appear before you can use it. For the sake 
of smooth operation, this web version emulator disables sound.
When using a PC keyboard, 
please use the Shift and Ctrl buttons on the left, and the corresponding buttons on the right 
do not work.

