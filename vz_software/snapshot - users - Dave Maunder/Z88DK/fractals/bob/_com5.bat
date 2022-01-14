rem    FOR CALLING ASM PROCEDURES WITHIN C FOR ARKY2019.C
rem   
rem   
rem    Call ASM procedures from within C
rem   

   call z88dkenv.bat
   zcc +vz -zorg=32768 -O3 -vn -m %1.c %1.asm -o %1.vz -create-app -lndos

rem   
rem    ##############################################
rem   
rem    Normal FAST compilation of C only.
rem   
rem   call z88dkenv.bat
rem   zcc +vz -create-app -lm %1.c -o %1.vz
rem   
rem    ##############################################
