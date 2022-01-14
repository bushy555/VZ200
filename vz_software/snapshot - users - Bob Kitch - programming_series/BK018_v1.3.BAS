1 'LISTING 4 
2 '************************************ 
3 '***NEAR-LIGHT-SPEED GRAPHICS DEMO*** 
4 '***          HI-RES              *** 
5 '***        VERSION 1.3           *** 
6 '***       R.B.K. 22/5/86         *** 
7 '************************************ 
8 '*** EXECUTION TIME <0.5 SECS. 
9 '***LOAD MACHINE CODE INTO FSL ABOVE BASIC VLT. 
10 FOR I=-28687 TO -28673 
20    READ A:POKE I,A 
30 NEXT I 
39 ' 
40 DATA 62,170         :'LD A, 170 (#170D BLUE) 
41 DATA 33,0,112       :'LD HL, 7000H (#28672D START VIDEO RAM) 
42 DATA 17,1,112       :'LD DE, 7001H (#28673D NEXT) 
43 DATA 1,255,7        :'LD BC, 07FFH (#2047D SIZE OF VIDEO RAM) 
44 DATA 119            :'LD (HL), A 
45 DATA 237,176        :'LDIR (BLOCK LOAD COMMAND) 
46 DATA 201            :'RET 
47 ' 
49 '***INITIALIZE USR() TO ADDRESS 8FF1H OR #-28687D IN FSL. 
50 POKE 30862,241:POKE 30863,143 
58 ' 
59 '***PUT UP BLUE SCREEN. 
60 MODE(1):COLOR,0 
70 SOUND 10,1 
80 X=USR(0) 
90 SOUND 10,1 
98 ' 
99 '***DELAY TO VIEW SCREEN. 
100 FOR I=0 TO 2000:NEXT I 
110 END 
