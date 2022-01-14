/* Foxglovz (c) by Jason "WauloK" Oakley
   v0.2.1
Foxglovz is licensed under a
Creative Commons Attribution-ShareAlike 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by-sa/3.0/>. */


#ifndef _FOXGLOVZ_H_
#define _FOXGLOVZ_H_

extern void fox_textat(struct myfontspecs *myfont, char *text);

// Specifications from font.h file
extern struct fontspecs
{
	unsigned char width;
	unsigned char height;
	unsigned char spacing;
};

// Specifications passed from user program
extern struct myfontspecs
{
	unsigned char name[20];
	unsigned char xpos;
	unsigned char ypos;
	unsigned char spacing;
	unsigned char colour;
	unsigned char fx;
};

// Defint maximum values for sprite info
extern struct maxvalues {
	unsigned char xmax; // Maximum X value onscreen
	unsigned char ymax;
	unsigned char colmax; // Maximum colours
};

extern int _vzgreen = 0;
extern int _vzyellow = 1;
extern int _vzblue = 2;
extern int _vzred = 3;
extern int _vzbuff = 4;
extern int _vzcyan = 5;
extern int _vzmagenta = 6;
extern int _vzorange = 7;

extern int _fxnormal = 0;
extern int _fxinverse = 1;
extern int _fxunderline = 2;

#endif