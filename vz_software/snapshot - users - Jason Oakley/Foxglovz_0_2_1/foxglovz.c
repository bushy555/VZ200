#include "foxglovz.h"

void fox_textat(struct myfontspecs *myfont, char *text);

char *fontarray; // Sprite data to display

int fontdataoffset = 4;
int arrayoffset = 2;

void fox_textat(struct myfontspecs *myfont, char *text)
{
	// Start rendering init
	int i,j,fontdatastart,textchar;
	int fontoffset,charval;
	struct fontspecs fontspec;
	struct maxvalues mymaxvalues;
	
	// Computer specific settings (VZ200 & VZ300)
	mymaxvalues.xmax = 127; // Maximum X value onscreen
	mymaxvalues.ymax = 63;
	mymaxvalues.colmax = 7; // Maximum colours
	
	fontspec.width = *(font+2);
	fontspec.height = *(font+3);

	// Allocate memory space for our own font array for sprites
	fontarray = (char*)calloc((fontspec->height+arrayoffset),sizeof(char));
	
	// Check parameters are valid
	if (myfont->xpos < 0 || myfont->xpos > mymaxvalues.xmax) return;
	if (myfont->ypos < 0 || myfont->ypos > mymaxvalues.ymax) return;
	if (myfont->colour < 0 || myfont->colour > mymaxvalues.colmax) return;

	//vz_color(myfont->colour);

	fontspec.spacing = myfont->spacing;
	fontoffset = 32;

	// Build fontarray data for sprite
	fontarray[0] = fontspec->width;
	fontarray[1] = fontspec->height;	

	for (i=0;i < strlen(text); i++) 
	{ 
		textchar = text[i];
		fontdatastart = fontspec->height*(textchar-fontoffset)+fontdataoffset;
		for (j=0;j<fontspec->height;j++)
		{ 
			charval = *(font+fontdatastart+j);
			if (myfont->fx & (1<<_fxinverse)) charval = ~charval;
			memset(fontarray+j+arrayoffset,charval,sizeof(char));
		}
		putsprite(spr_or, myfont->xpos+(fontspec->width+fontspec->spacing)*i, myfont->ypos, fontarray);
	}
	// Add fx
	if (myfont->fx & (1<<_fxunderline)) {
		draw(myfont->xpos, myfont->ypos+fontspec->height+1, myfont->xpos+(fontspec->width+myfont->spacing)*strlen(text)-myfont->spacing-1, myfont->ypos+fontspec->height+1);
	}
	free(fontarray); // Free calloc memory
	return 0;
}