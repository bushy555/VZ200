Utility : 4 colour manipulator.
================================
Use this on outputted stacked .DAT files to change from one colour to another.
To do: Add a tempory fifth colour, so that one specific colour can be changed to this 5th colour tempory, whilst 
other colours are being changed. Ie, colour 1 to go to colour 5. COlor 4 can go to colour 1. Colour 2 to 3, 5 to 4.



; Stripper 117.    23/11/2022.     VZ SD Loader .DAT file image reverser / manipulator. 
	
Name	  : STRIP117.EXE
O/S 	  : 16-bit windows command-line.  Windows x86 XP & 7 only.
file size : 6326 bytes.
USEAGE    : STRIP117.EXE <in-file> <out-file> <selection parameter>



 VZ COLOUR TRANSFER.  For use with video DAT files for VZ SD Loader.'

 Call this a VZ MODE(1) colour manipulator. Has the ability to change any of',cr,lf
 the four colours to any of the other three colours, within either',cr,lf
 standalone image, or, a video .DAT file such as for the SD Loader.'

seelction
parameter

01	colour change : 	GREEN --> YELLOW.	YELLOW --> GREEN.
02	colour change : 	GREEN --> BLUE.		BLUE   --> GREEN.
03	colour change : 	GREEN --> RED.		RED    --> GREEN.
04	colour change : 	YELLOW--> GREEN.	GREEN  --> YELLOW.
05	colour change : 	YELLOW--> BLUE.		BLUE   --> YELLOW.
06	colour change : 	YELLOW--> RED.		RED    --> YELLOW.
07	colour change : 	BLUE  --> GREEN.	GREEN  --> BLUE.
08	colour change : 	BLUE  --> YELLOW.	YELLOW --> BLUE.
09	colour change : 	BLUE  --> RED.		RED    --> BLUE.
10	colour change : 	RED   --> GREEN.	GREEN  --> RED.
11	colour change : 	RED   --> YELLOW.	YELLOW --> RED.
12	colour change : 	RED   --> BLUE.		BLUE   --> RED.
13	colour change : 	ALL GREEN --> YELLOW ONLY.
14	colour change : 	ALL GREEN --> BLUE ONLY.
15	colour change : 	ALL GREEN --> RED ONLY. 
16	colour change :		ALL YELLOW--> GREEN ONLY.
17	colour change : 	ALL YELLOW--> BLUE ONLY.
18	colour change : 	ALL YELLOW--> RED ONLY. 
19	colour change : 	ALL BLUE  --> GREEN ONLY.
20	colour change : 	ALL BLUE  --> YELLOW ONLY.
21	colour change : 	ALL BLUE  --> RED ONLY. 
22	colour change : 	ALL RED   --> GREEN ONLY.
23	colour change : 	ALL RED   --> YELLOW ONLY.
24	colour change : 	ALL RED   --> BLUE ONLY.





STRIP118
; Copies (reads and writes) first 2048 bytes, then ignores the rest of the file.
; For binary files. 
; FOR VZ video extracion to grab one frame.



STRIP119
; Copies (reads and writes) <param 3> number of 2048 bytes, then ignores the rest of the file.
; For binary files. 
; FOR VZ video extracion to grab one frame.



STRIP120
; Copies (reads and writes) <param 3> number of 2048 bytes, then ignores the rest of the file.
; For binary files. 
; FOR VZ video extracion to grab one frame.
;
; <in-file> <out-file> <number of 2048byte frames to skip, then read and write 1x 2048 frame, then skip rest>
