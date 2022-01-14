rem   
@echo off
rem    Set Z88DK compiler environment variables: 
rem    Example:
rem       SET Z80_OZFILES = C:\progra~1\Z88DK\lib\
rem       SET ZCCCFG      = C:\progra~1\Z88DK\lib\config\
rem       SET PATH        = C:\progra~1\Z88DK\bin;%PATH%
rem   
rem   


rem    Build all of this with:
rem      zcc +vz -zorg=32768 -O3 -vn -m %1.c %1.asm -o %1.vz -create-app -lndos

::    SET Z80_OZFILES = C:\progra~1\Z88DK\lib
::    SET ZCCCFG      = C:\progra~1\Z88DK\lib\config
::    SET PATH        = C:\progra~1\Z88DK\bin;%PATH%


::    SET Z80_OZFILES = C:\vz\Z88DK\lib
::    SET ZCCCFG      = C:\vz\Z88DK\lib\config
::    SET PATH        = C:\vz\Z88DK\bin;%PATH%



call	z88dkenv.bat

::==================================================
:: rem z88dk.bat
:: rem IF NOT "Z88DK"=="" GOTO exit_without_settings
:: SET Z80_OZFILES=C:\progra~1\Z88DK\lib\
:: SET ZCCCFG=C:\progra~1\Z88DK\lib\config\
:: SET PATH=C:\progra~1\Z88DK\bin;%PATH%
:: SET Z88DK=true
:: GOTO the_end
:: 
:: :exit_without_settings
:: rem echo Nothing to set :-)
:: :the_end
:: ==================================================


zcc +vz -zorg=32768 -O3 -vn -m %1.c %1.asm -o %1.vz -create-app -lndos
