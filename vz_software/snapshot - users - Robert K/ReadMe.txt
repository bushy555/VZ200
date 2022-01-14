https://sourceforge.net/projects/h-tron/

H-Tron - a Tron motorcycle game for Z80-based computers
Author: RobertK (RobertK@psc.at)
Portable Version 2018-10-04

H-Tron is a portable little game for various classic Z80-based computers, written in C using the z88dk compiler (www.z88dk.org).

This is the classic overhead view "Tron" game from the movie of the same title (motorcycles that leave "wall trails" behind them). If you crash into a wall, your opponent scores a point. The player who first reaches a score of 5 wins.

The compiled program is a little over 8K in size, so it usually requires the target machine to have at least 16K RAM.

The following systems are currently supported:

Amstrad CPC
Bandai RX-78
Camputers Lynx
Casio PV-1000
Casio PV-2000
CCE MC-1000
ColecoVision
EACA EG2000 Colour Genie
Exidy Sorcerer
Jupiter Ace
Mattel Aquarius
Memotech MTX
MicroBee 128k Standard / Premium / Premium Plus
Mitsubishi Multi 8
MSX
Nascom (*)
NEC PC-6001mkII
Osborne 1
Philips P2000
Philips VG5000
Robotron KC 85/2-5 and HC 900
Robotron Z 1013
Robotron Z 9001 (KC 85/1, KC 87)
Samsung SPC-1000
Sega SC-3000
Sharp MZ
Sinclair ZX81
Sinclair ZX Spectrum
Sord M5
Spectravideo SVI
Tandy TRS-80
Tatung Einstein (separate TK02 80 column version)
Triumph Adler Alphatronic PC
VTech Laser 210/310 / VZ 200
VTech Laser 500/700

(*) The Nascom is not powerful enough for this game, only two-player mode runs at decent speed.


=== Controls (on QWERTY keyboards, AZERTY differs, consoles use joystick only) ===

Turn left/right:
  Left Player: A/S
  Right Player: N/M or 5/8 (Cursor left/right on ZX81)
  (in one-player mode, human is right player)
Start round: Space or 0
Pause game: P
End game: X

Note that on some systems usability of the two-player mode is currently very limited because z88dk does not support checking the status of two keys simultaneously on all target machines. Therefore a fully usable two-player mode is currently available only on the following systems:

ColecoVision (Joystick control)
EACA EG2000 Colour Genie
Exidy Sorcerer
Jupiter Ace
Mattel Aquarius
Philips VG5000
PV-1000 (Joystick control)
Sinclair ZX81
Sinclair ZX Spectrum
Tandy TRS-80
VZ 200 / Laser 210/310


=== Compiling ===

Download the latest nightly build (or for the "simple source" version download the latest stable release 1.99B) from www.z88dk.org and extract it to any location on your computer.
Edit the compile_htron_....bat batch file and modify the z88root path (make sure that there is a backslash at the end).
Run the batch file and the compiler will hopefully run without errors and create the compiled program file.

The entire source is contained in one single file (htron.c).

With all the "#if defined(...)" preprocessor directives (used to make the game portable), the source may be a little difficult to read and understand.
So I have also included a "simple" version that is for the Sinclair ZX81 only and hopefully easier to understand. This should help z88dk newcomers on their first steps towards creating new software for our beloved classic computers.


=== Known Bugs / Limitations / TODOs ===

- Limited usability of two-player mode on some systems (see above) because the state of two buttons cannot be checked simultaneously. Maybe some day the z88dk will add this functionality for more targets.


=== Thanks ===

Thanks to the z88dk team for creating this wonderful compiler and for their continuous work in order to further improve it. And thanks to A. Rea for providing ASM plot functions (zx81plot.h) used in the "simple source" ZX81-only version, they are a little faster than the standard plot/point functions from graphics.h.


=== History ===

The history behind the game: in 2016 I decided to write a game for XT-class DOS PCs equipped with a Hercules graphics card, since there are so few games that truly support the Hercules card (most 1980s games simply blew up their 320x200 CGA graphics, but very few produced a real 720x348 Hercules screen).

So "H-Tron" was born (the "H" stands for "Hercules"), written in December 2016 in Borland Turbo C 2.01.
Later I found the great z88dk C compiler for Z80 computers (www.z88dk.org) that allowed me to port the game to the ZX81.


=== Portable Release Version History ===

2018-10-04:
- New targets supported:
	CCE MC-1000
	MicroBee 128k Standard / Premium / Premium Plus
	Tatung Einstein 80 Column Mode (TK02)

2018-09-22:
- New targets supported:
	Amstrad CPC
	Memotech MTX

2018-09-21:
- New targets supported:
	Camputers Lynx
	Osborne 1
	Tatung Einstein
Notes:
- On the Einstein, when you exit the game the characters at the CP/M prompt are broken, you need to restart the machine at that point.
- For the Camputers Lynx two different versions are included - their font looks a little different, but they both do the same. htron_CamputersLynx.tap uses the "Generic Console" while htron_CamputersLynx_StandardConsole.tap uses the built-in routines to display characters. The latter looks better IMHO but is much slower at displaying the game menu texts.

2018-09-12:
- New target supported: VTech Laser 500/700. Two different .WAV tape files are included: one that can be loaded by M.A.M.E, while the other one should be able to run on real hardware.
- VTech Laser 210/310 / VZ 200: new alternative lo-resolution version added ("lgfx")
- TRS-80: a .cas tape file is now also included in the package

2018-08-29:
- New target supported: Robotron KC 85/2-5 and HC 900

2018-08-19:
- New targets supported:
	MSX
	NEC PC-6001mkII
	Sord M5
	Spectravideo SVI
- Philips VG5000: improved graphics (no longer requiring the huge characters for displaying text)

2018-07-27:
- New target supported: Sega SC-3000
- Casio PV-2000: Bugfixes (graphics glitches, collision detection)

2018-07-22:
- New targets supported: 
	Bandai RX-78
	Casio PV-2000
	Nascom (*)
	Sinclair ZX Spectrum
(*) The Nascom is not powerful enough for this game, only two-player mode runs at decent speed.

2018-07-10:
- New targets supported: 
	Casio PV-1000
	ColecoVision
	Exidy Sorcerer
	Mitsubishi Multi 8
	Samsung SPC-1000
	Triumph Adler Alphatronic PC
- VG5000, TRS-80, EG2000, Aquarius: new keyboard input method makes the two-player mode usable
- VZ 200 / Laser 310: "Visible Cursor Problem" (that occurred occasionally) hopefully solved
- Bugfixes: correct random seed initialization, automatic round restart (on some systems, without space or 0 pressed) fixed

2018-06-24:
- Jupiter Ace and VZ200: new keyboard input method provided by z88dk that allows simultaneously checking more than just one key, so two-player mode is now usable on these two systems.

2018-06-22:
- New target supported: Sharp MZ
- EG2000 screen size changed to 102x96 to support the older EG2000 models.

2018-06-14: Initial release
