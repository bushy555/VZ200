5 'LISTING 1
10 '***SNAIL GRAPHICS DEMO*** 
20 '***      HI-RES       *** 
30 '***    VERSION 1.1    *** 
40 '***   R.B.K. 22/5/86  *** 
50 '*** EXECUTION TIME 57.6 SECS. 
100 'SET TO HI-RES SCREEN. 
120 MODE(1) 
130 COLOR 3,0              :'RED ON GREEN 
140 SOUND 10,1             :'START TIMING SOUND  
200 FOR V=0 TO 63          :'STEP ACROSS COLUMNS
210    FOR H=0 TO 127      :'STEP ACROSS ROWS 
220       SET(H,V)         :'LIGHT SCREEN
230    NEXT H 
240 NEXT V 
250 SOUND 10,1             :'END TIMING SOUND
260 FOR I=0 TO 2000:NEXT I :'PAUSE TO VIEW RESULTS  
270 STOP 
280 END
