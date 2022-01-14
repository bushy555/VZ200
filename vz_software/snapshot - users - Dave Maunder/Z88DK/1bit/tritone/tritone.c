//
// Phaser 1 1-bit player engine.
// Song : FUSEUNO
// GLOVVZ Font Library. Available from:    https://bluebilby.com/foxglovz/
// 	(font.h and foxflovz.c must be available ni the pathing.)
//
//
//
//
// Set Z88DK compiler environment variables: 
// Example:
//    SET Z80_OZFILES = C:\progra~1\Z88DK\lib\
//    SET ZCCCFG      = C:\progra~1\Z88DK\lib\config\
//    SET PATH        = C:\progra~1\Z88DK\bin;%PATH%
//
//
// Build all of this with:
// zcc +vz -zorg=32768 -O3 -vn -m phaser1.c phaser1.asm -o phaser1.vz -create-app -lndos -DAMALLOC -pragma-redirect:scrbase=base_graphics -lm 




main(){
	tritone();
}

