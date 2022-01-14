#include <games.h>
#include <vz.h>
#include <stdlib.h>
#include <string.h>
#include <balloc.h> 
#include "font.h"
#include "foxglovz.c"

int main(void)
{
	clg();

	struct myfontspecs myfont;
	strcpy(myfont.name, "sansserif5x7");
	myfont.xpos = 0;
	myfont.ypos = 0;
	myfont.spacing = 1;
	myfont.colour = _vzred;
	myfont.fx = _fxnormal;
	myfont.fx |= (1<<_fxunderline);

	fox_textat(&myfont,"Testing 1,2,3");
		
	while(1) {}
}