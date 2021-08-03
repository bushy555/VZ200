STEPK.EXE is a command line graphical utility for the conversion of a Windows 16 colours image into VZ's four colours.

However, it also allows for "BPOKE" commands for the use in C with the Z88DK kit.

It also allows various other dumps ('DEFB' and 'DB' for asm include files) along with the VZ's representation of graphical data.
From the .RAW format (as used by Paint Shop Pro and others) (which uses a colour template of 00, 01, 02, 03) and converts these byte-per-pixel .RAW into a nibble-per pixel output.

Basically: It converts a RAW exported image from a fancy graphical package into a VZ MODE(1) format, and does all the nibbling 2byte-per-colour conversion.
This program is a hack of a hack of a hack, and is not fancy at all, and will most likely disappoint you.
It was written by Dave for Dave to do his dumb graphical stuff. Included in here for completeness. 
It runs on 32bit XP and Win7 only.


STEPLW is for SHRG colour templates that use 00 and 01. Converts from .RAW format into correct format output file for inclusion.


Both also can do a straight thru, (functions 9 and A) just like a DB2INC or DEFB2INC conversion util.

Dave. 12/Nov/2019

