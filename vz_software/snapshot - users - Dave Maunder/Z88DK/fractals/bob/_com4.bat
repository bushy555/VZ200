rem    Calling C from within asm

call z88dkenv.bat
zcc +vz -create-app -pragma-redirect:scrbase=base_graphics -lm %1.c -o %1.vz

