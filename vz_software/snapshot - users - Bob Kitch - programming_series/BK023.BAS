1 '********************** 
2 '***  DEMO PROGRAM  *** 
3 '***  TO SHOW HOW   *** 
4 '***  THE 280 MPU   *** 
5 '***   USES LOGIC   *** 
6 '***   OPERATIONS   *** 
7 '***  TO SET FLAGS  *** 
8 '***  RBK 30.11. 86 *** 
9 '********************** 
10 '***MAINLINE OF PROGRAM*** 
20 GOSUB 30000:'***INITIALIZATION*** 
30 GOSUB 20000:'***PROGRAM MIDDLE*** 
50 B$="PRESS <SPACE> TO CONTINUE":X%=3:Y%=15:GOSUB 7000
51 ' *** NB THIS MESSAGE WAS IN INVERSE *** BUT DOES NOT AFFECT RUNNING. 
60 M$=INKEY$:M$=INKEY$:IF AA$="" THEN GOTO 60 
90 GOTO 30 
1000 '***SET NEGATIVE AND ZERO FLAGS*** 
1100 '***SET NEGATIVE FLAG BY BIT 7*** 
1200 NG%=ABS(INT(AC%/128)) 
1300 '***SET ZERO FLAG IF AC%=ZERO*** 
1400 IF (AC%=0) THEN ZE%=1 ELSE ZE%=0 
1990 RETURN 
5000 '***DEC N% TO HEX HN$*** 
5100 HI%=INT(N%/16) 
5110 HN$=MID$(HX$,HI%+1,1) 
5200 LO%=N%-HI%*16 
5210 HN$=HN$+MID$(HX$,L0%+1,1) 
5990 RETURN 
6000 '***DEC N% TO BIN BN$*** 
6100 BN$="" 
6200 FOR Q%=7 TO 0 STEP -1 
6210    BT$="0" 
6220    IF(N% AND 2^Q%) THEN BT$="1" 
6230    BN$=BN$+BT$ 
6240 NEXT Q% 
6990 RETURN 
7000 '***PRINT B$ AT (X%,Y%)*** 
7100 PS%=32*Y%+X% 
7200 PRINT@PS%,B$; 
7300 RETURN 
8000 '***BIN BN$ TO DEC N%*** 
8100 N%=0 
8200 FOR Q%=0 TO 7 
8210    IF VAL(MID$(BN$,Q%+1,1)) THEN N%=N%+2^(7-Q%) 
8220 NEXT Q% 
8990 RETURN 
9000 '***HEX HN$ TO DEC N% 
9100 A%=ASC(LEFT$(HN$,1))-48 
9110 B%=ASC(RIGHT$(HN$,1))-48 
9200 N%=B%+7*(B%>9)-(-1)*(16*(A%+7*(A%>9))) 
9990 RETURN 
10000 '***AND THE ACCUMULATOR WITH THE DATA*** 
10100 AC%=AC% AND DT% 
10200 GOSUB 1000 
10990 RETURN 
11000 '***OR THE ACCUMULATOR WITH THE DATA*** 
11100 AC%=AC% OR DT% 
11200 GOSUB 1000 
11990 RETURN 
12000 '***EXCLUSIVE-OR THE ACCUMULATOR WITH THE DATA*** 
12100 AC%=(AC% OR DT%) - (AC% AND DT%) 
12200 GOSUB 1000 
12990 RETURN 
20000 '***PROGRAM MIDDLE*** 
20100 '***CLEAR SCREEN, PICK CASE, PRINT HEADER*** 
20110 CLS 
20120 MX%=3:MN%=0:GOSUB 40000:CS%=RN% 
20130 B$=OP$(CS%):X%=12:Y%=0:GOSUB 7000 
20140 B$=HD$:X%=1:Y%=3:GOSUB 7000 
20200 '***PRINT TRANSLATIONS OF ACCUMULATOR CONTENTS*** 
20210 MX%=255:MN%=0:GOSUB 40000:N%=RN% 
20250 YO%=5:GOSUB 21000 
20260 AC%=N% 
20300 '***PRINT TRANSLATION OF DATA ADDRESS CONTENTS*** 
20310 GOSUB 40000:N%=RN% 
20320 YO%=7:GOSUB 21000 
20330 DT%=N% 
20400 '***GET AND SORT GUESS INTO BIN/HEX/DEC*** 
20500 B$="":X%=1:Y%=9:GOSUB 7000 
20510 INPUT "RESULT B/H/D";G$
20511  ' *** NB THIS MESSAGE WAS IN INVERSE *** BUT DOES NOT AFFECT RUNNING.  
20520 IF (LEN(G$)<1) OR (LEN(G$)>9) THEN GOTO 20500 
20530 A$=LEFT$(G$,1) 
20540 C$=RIGHT$(G$,LEN(G$)-1) 
20550 IF A$<>"B" THEN GOTO 20600: '***GUESS NOT BIN*** 
20560 BN$=C$ 
20570 GOSUB 8000 
20580 F%=3 
20590 GOTO 20700 
20600 IF A$<>"H" THEN GOTO 20650:'***GUESS NOT HEX*** 
20610 HN$=C$ 
20620 GOSUB 9000 
20630 F%=2 
20640 GOTO 20700 
20650 IF A$<>"D" THEN GOTO 20500: '***GUESS NOT DEC*** 
20655 N%=VAL(C$) 
20660 F%=1 
20700 '***GUESS HERE*** 
20710 G%=N% 
20800 '***DO OPERATION*** 
20812 IF CS%=0 THEN GOSUB 10000 
20813 IF CS%=1 THEN GOSUB 11000 
20814 IF CS%=2 THEN GOSUB 12000 
20820 YO%=11:N%=AC%:GOSUB 21000 
20900 '***UPDATE SCORE*** 
20910 IF G%=AC% THEN PT%=PT%+10*F% 
20920 B$="SCORE"+STR$(PT%):X%=9:Y%=13:GOSUB 7000
20921 ' *** NB THIS MESSAGE WAS IN INVERSE *** BUT DOES NOT AFFECT RUNNING.   
20990 RETURN 
21000 '***TRANSLATE DEC N% AND PRINT AT YO%*** 
21210 GOSUB 6000 
21220 GOSUB 5000 
21240 B$=BN$:X%=1:Y%=YO%:GOSUB 7000 
21250 B$=HN$:X%=10:Y%=YO%:GOSUB 7000 
21260 B$=RIGHT$(" "+STR$(N%),3):X%=14:Y%=YO%:GOSUB 7000 
21300 IF YO%<>11 THEN GOTO 21990 
21400 B$=STR$(NG%)+STR$(ZE%):X%=17:GOSUB 7000 
21990 RETURN 
30000 '***INITIALIZATION*** 
30100 HX$="0123456789ABCDEF" 
30120 PT%=0 
30130 HD$=" BINARY  HEX DEC N Z":' SPACING MAY NEED FIXING***  
30131' *** NB THIS MESSAGE WAS IN INVERSE *** BUT DOES NOT AFFECT RUNNING.  
30200 DIM OP$(2) 
30210 FOR Q%=0 TO 2 
30220    READ OP$(Q%) 
30230 NEXT Q% 
30240 DATA "AND", "ORA", "EOR" 
30241 ' *** NB THIS MESSAGE WAS IN INVERSE *** BUT DOES NOT AFFECT RUNNING.  
30300 GOSUB 50000 
30400 CLS 
30500 RETURN 
40000 '***RANDOM NUMBER GENERATOR IN RANGE OF MN% -MX%*** 
40100 RN%=INT(RND(0)*(MX%-MN%))+MN% 
40200 RETURN 
50000 '***INSTRUCTIONS*** 
50010 CLS 
50020 PRINT"THIS PROGRAM rs DESIGNED TO MAKE THE USER FAMILIAR"; 
50030 PRINT"WITH LOGIC OPERATORS." 
50040 PRINT"THE 'AND' 'OR' AND 'EOR(XOR)' " 
50050 PRINT"OPERATORS ARE TESTED.":PRINT 
50060 PRINT"ADDITIONALLY BINARY, HEXADECIMAL AND DECIMAL"; 
50070 PRINT" NOTATION IS USED.":PRINT 
50080 PRINT"THE SETTING OF THE 'NEGATIVE' AND 'ZERO' FLAG"; 
50090 PRINT"IN A TYPICAL MPU IS ALSO SHOWN IN THE ANSWER." 
50100 PRINT"IF A FLAG IS SET, IT IS SET TO 1"; 
50110 PRINT"I.E.THE CONDITION IS TRUE.":PRINT:GOSUB 60000 
50200 PRINT"THE PROGRAM WILL ACCEPT" 
50205 PRINT"RESPONSES PREFIXED BY":PRINT 
50210 PRINT"      BINARY <B>" 
50220 PRINT" HEXADECIMAL <H> OR" 
50230 PRINT"     DECIMAL <D>":PRINT 
50240 PRINT"ALSO A BONUS SCORE IS GIVEN IF" 
50250 PRINT"THE ANSWER IS GIVEN IN BINARY.":PRINT:PRINT 
50255 PRINT:PRINT:PRINT:PRINT 
50260 GOSUB 60000:RETURN 
60000 '***SUB FOR NEW SCREEN*** 
60120 PRINT"PRESS ANY KEY TO CONTINUE";
60121 ' *** NB THIS MESSAGE WAS IN INVERSE *** BUT DOES NOT AFFECT RUNNING.   
60130 AA$=INKEY$:AA$=INKEY$:IF AA$="" THEN GOTO 60130 
60140 CLS:RETURN 
60150 END