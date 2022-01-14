13th August 2009
--------------------------
- Added support for AY8910 soundchip. This is selectable from the options menu -> extended sound. 
To create a simple tone, enter the following commands from basic

OUT 129,8 		'volume register for channel a
OUT 128,15 		'volume data for register a
OUT 129,0 		'channel a fine register for channel a
OUT 128,49 		'fine note data for register a

James Diffendaffer has written an example program that demonstrates programming for the AY8910. 
It is included in this zip as:

forest.asm	assembler source	
forest.vz 	compiled snapshot
