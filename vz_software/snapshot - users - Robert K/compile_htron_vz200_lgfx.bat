setlocal
rem Set your z88dk root path here
set z88root=C:\Misc\z88dk\

set path=%PATH%;%z88root%bin\
set zcccfg=%z88root%lib\config\
set z80_ozfiles=%z88root%lib\

zcc +vz -pragma-redirect:fputc_cons=fputc_cons_generic -lgfxvzblock -o htron_vz200_lgfx.vz htron.c -DVZ200_LGFX

endlocal

rem pause
