REM FOR FOXGLOVZ LIBRARY  and  for calling asm from within C

call z88dkenv.bat
zcc +vz -zorg=32768 -O3 -vn -m %1.c %1.asm -o %1.vz -create-app -lndos -DAMALLOC -pragma-redirect:scrbase=base_graphics -lm 
