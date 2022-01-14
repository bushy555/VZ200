#include <games.h>
#include <vz.h>
#include <stdlib.h>
#include <string.h>
#include <balloc.h> 
#include "font.h"
#include "foxglovz.c"

int main(void)
{
	int	i,j;

	clg();

	struct myfontspecs myfont;
	strcpy(myfont.name, "sansserif5x7");
	myfont.spacing = 0;
	myfont.colour = _vzred;
	myfont.fx = _fxnormal;
//	myfont.fx |= (1<<_fxinverse);
//	myfont.fx |= (1<<_fxunderline);


//     	fox_textat(&myfont,"xxxxxxxxxxxxx"


	myfont.xpos = 00;
	myfont.ypos = 00;
     	fox_textat(&myfont,"`~1234567890");	// LINE 1
	myfont.xpos = 00;
	myfont.ypos = 7;  
     	fox_textat(&myfont,"=_+!@#$%^&*()");	// LINE 2
	myfont.xpos = 00;
	myfont.ypos = 14;
     	fox_textat(&myfont,"[]\\{}|;':""");	// LINE 3
	myfont.xpos = 00;
	myfont.ypos = 21;
     	fox_textat(&myfont,"-,./<>?");		// LINE 4
	myfont.xpos = 00;
	myfont.ypos = 28;
       	fox_textat(&myfont,"ABCDEFGHIJKLM");	// LINE 5
	myfont.xpos = 00;
	myfont.ypos = 35;
       	fox_textat(&myfont,"NOPQRSTUVWXYZ");	// LINE 6
	myfont.xpos = 00;
	myfont.ypos = 42;
       	fox_textat(&myfont,"abcdefghijklm");	// LINE 7
	myfont.xpos = 00;
	myfont.ypos = 49;
	fox_textat(&myfont,"nopqrstuvwxyz");	// LINE 8



		
	while(1) {}


}