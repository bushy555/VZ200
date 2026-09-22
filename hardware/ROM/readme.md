All specific GA003/GA004/GA008 ROM stuff for the VZ.
Be it diagrams, circuit fixes & replacements, firmware. v1.0 , v1.1, 1.2, 2.0 or our own hacked 2.1's.
Might also include SD Loader stuff.

Various stuff in here collected from over numerous years posted on our "VZ/Laser Fans" facebok group.
Acknowledgement and credits go to Geronimus Vanden for the complete disassembly & circuitry for the GA003 and GA004 with photos, Rhys Weatherly (see his github) for circuirty & diagrams & dead-rom test, and SK Leung for his work in the rom area.  


p.GA003 and GA004 reverse engineering - Geronimus Vanden
Hack a Day article : 	https://hackaday.com/2014/04/02/reverse-engineering-programmable-logic/

Rhys Weatherly: 
Restoration info: https://github.com/rweather/vz200-restoration
Redrawn schematic: https://github.com/rweather/vz200-restoration/blob/main/schematics/VZ200/PDF/VZ200.pdf
Dead VZ200 ROM TEST : https://github.com/rweather/vz200-restoration/tree/main/src/deadtest


Dave Collins ROM disassembly:
This is the complete, annotated listing for the VZ200 V2.0 BASIC ROM
https://github.com/lindoran/VZ200-Level-II-BASIC-Disasembly


--------------------


This file describes the startup sequence of the VZ200 ROM's, based on a disassembly of v2.0 of the ROM's.

  When the CPU resets, it starts running code at address $0000 and proceeds to do the following:

    Disable interrupts with a DI instruction.
    Write $00 to I/O address $6800 which sets all output pins on U1 to zero.
        Turns off the speaker and casette outputs.
        Selects alphanumeric mode in the MC6847 Video Display Generator (VDG).
        Selects the green background color in the VDG.
    Copies the $0036 bytes at $06D2 in ROM to $7800 in RAM. This initialises the system vectors and other variables in RAM.
    The copy is repeated 128 times, which has the effect of producing a delay at startup to allow the voltage rails to settle.
    Initialize global variables for the BASIC interpreter.
    Clear the screen.
    Determine the amount of available RAM and populate the top of memory pointer in $78B1 and $78B2.
    Print the startup banner message VIDEO TECHNOLOGY BASIC V2.0.
    Check the four bytes at $4000, $6000, and $8000 looking for the pattern $AA, $55, $E7, $18. If that pattern is found, then there is       a ROM cartridge at that address. Re-enable interrupts and jump to the code that starts at $4004, $6004, or $8004 depending upon         which ROM cartridge was detected.
    Otherwise re-enable interrupts and jump into the BASIC interpreter.

    


