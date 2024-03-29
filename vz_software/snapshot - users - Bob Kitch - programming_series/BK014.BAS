10 ' ************************************* 
20 ' ***   DISPLAY INVERSE CHARACTER   *** 
30 ' ***           SET IN ROM          *** 
40 ' ***     AS USED BY DOT MATRIX     *** 
50 ' ***             PRINTER           *** 
60 ' ***     R. B. KITCH 27/9/86       *** 
70 ' ************************************* 
80 ' 
100 'WHEN INVERSE CHARACTERS ARE SENT TO A DOT MATRIX PRINTER 
110 'THE PRINTER SHIFTS TO GRAPHICS MODE AND REQUIRES A ROUTINE 
120 'TO SUPPLY THE APPROPRIATE SHAPES TO THE HEAD. (NORMAL 
130 'CHARACTERS ARE HELD IN THE PRINTERS ROM) 
140 'IN THE VZ COMPUTER A TABLE OF SHAPES IS LOCATED AT 
150 '3B94H TO 3CD3H IN ROM. THERE ARE 64 CHARACTERS, EACH USING 
160 '5 BYTES TO DEFINE THEIR GRAPHIC SHAPE. THE SHAPES MAY BE 
170 'DECODED AND OUTPUT TO THE SCREEN AS IS DONE IN THIS 
180 'PROGRAM. NOTE THAT THERE ARE SOME ERRORS IN THE ROM. 
190 'THE 5 BYTES DEFINE A 5 BY 8 DOT MATRIX WHICH IS THE SHAPE 
200 'OF THE CHARACTER, WHICH INCIDENTLY ARE NOT ORDERED 
210 'ACCORDING TO THE ASCII CODE. 
220 'THE FIRST BYTE DEFINES THE LEFT HAND EDGE OF THE CHARACTER
230 'WHICH IS THE FIRST PRINTED DURING A PASS OF THE PRINTER 
240 'HEAD. IN TANDY PRINTERS THE MSB IS THE LOWERMOST PIN OF THE 
250 'HEAD AND THE LSB IS THE UPPERMOST PIN. THE PINS ON EPSON 
260 'PRINTER HEADS ARE ARRANGED IN THE OPPOSITE SENSE. THIS 
270 'REQUIRES THAT THE BITS IN EACH BYTE BE REVERSED. 
280 '*********************************************************** 
290 '
300 DIM MK%(7) :'***VECTOR OF BIT MASK VALUES - POWERS OF 2 
310 DIM BT%(7) :'***VECTOR OF DECODED BITS FROM ROM VALUE. 
320 ' 
330 '***FILL MASK VECTOR WITH POWERS OF 2 FOR DECODING. 
340 FOR I%=0 TO 7 :MK%(I%)=2^I% :NEXT I% 
350 ' 
400 '***INITIALIZE PARAMETERS - MAY BE CHANGED TO VARY SCREEN. 
410 CC%=4   :'***CHARACTER COLOUR.  (1-4) 
420 BC%=2   :'***BACKGROUND COLOUR. (1-4) 
430 CS%=0   :'***COLOUR SET.        (0-1) 
440 CW%=3   :'***COLUMN WIDTH BETWEEN CHARACTERS. 
450 SP%=16  :'***ROW SPACING FOR CHARACTERS. 
460 HS%=0   :'***STARTING HORIZONTAL POSITION ON HI-RES SCREEN. 
470 VP%=3   :'***STARTING VERTICAL POSITION ON HI-RES SCREEN. 
480 HM%=127 :'***MAXIMUM HORIZONTAL POSITION. (0-127) 
490 
600 '***SET UP MAIN LOOP TO STEP THROUGH ROM FROM 3894H-3CD3. 
610 BK%=0               :'***BYTE COUNTER FOR EACH CHARACTER. 
620 HP%=HS%             :'***SET HORIZONTAL POSITION TO START 
630 MODE(1) :COLOR,CS%  :'***SET HI-RES SCREEN AND COLOR SET. 
640 FOR AD%=15252 TO 15571 :'***ROM ADDRESSES FOR SHAPE TABLE.
650    DV%=PEEK(AD%)       :'***DECIMAL VALUE IN ROM. 
660 ' 
700 '   ***DECODE THE INDIVIDUAL BITS OF DV% AND STORE IN BT%().
710 '   ***THE MASK VALUES IN MK%() ARE "ANDED" WITH THE VALUE. 
720 '   ***THE RESULT STORED IN BT%() IS THE "COLOUR" OF THE BIT. 
730    FOR I%= 0 TO 7     :'***PROCEED FROM LSB TO MSB. 
740       IF DV% AND MK%(I%) THEN BT%(I%)=BC% ELSE BT%(I%)=CC% 
750    NEXT I% 
800 ' 
810 '   ***CHECK THAT THERE IS ENOUGH ROOM TO PLOT CHARACTER. 
820    IF BK%=0 AND HM%-HP%<4 THEN HP%=HS%:VP%=VP%+SP%:'*NEW ROW 
830    BK%=BK%+1          :'***INCREMENT BYTE COUNTER. 
840 '   
900 '***OUTPUT BYTE TO SCREEN. 
910    FOR I%=0 TO 7 
920       COLOR BT%(I%)   :'***SET COLOUR OF BIT. 
930       SET(HP%,VP%+I%) :'***PLOT BIT. 
940    NEXT I% 
950 ' 
1000 '   ***PREPARE FOR NEXT BYTE. 
1010    HP%=HP%+1        :'***INCREMENT HORIZONTAL POSITION. 
1020    IF BK%=5 THEN BK%=0 :HP%=HP%+CW% :'***NEW CHARACTER. 
1030 NEXT AD% 
2000 GOTO 2000 :END 
