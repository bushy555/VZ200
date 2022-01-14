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




#include <games.h>
#include <vz.h>
#include <stdlib.h>
#include <string.h>
#include <balloc.h> 
#include "font.h"
#include "foxglovz.c"


main(){
	clg();

	struct myfontspecs myfont;
	strcpy(myfont.name, "sansserif5x7");
	myfont.xpos = 0;
	myfont.ypos = 0;
	myfont.spacing = 1;
	myfont.colour = _vzred;
	myfont.fx = _fxnormal;
//	myfont.fx |= (1<<_fxunderline);

	fox_textat(&myfont,"Phaser 1 1-bit player.");
	myfont.xpos = 0;
	myfont.ypos = 7;
	fox_textat(&myfont,"playing from within C");
	myfont.xpos = 0;
	myfont.ypos = 14;
	fox_textat(&myfont,"using Z88 Dev kit.");

	myfont.xpos = 0;
	myfont.ypos = 30;
	fox_textat(&myfont,"Song: Faseuno.");
	myfont.xpos = 0;
	myfont.ypos = 40;
	fox_textat(&myfont,"Using FOXGLOVZ Lib.");
	myfont.xpos = 0;
	myfont.ypos = 50;
	fox_textat(&myfont,"Nov 2019.");
		
	phaser();
}

