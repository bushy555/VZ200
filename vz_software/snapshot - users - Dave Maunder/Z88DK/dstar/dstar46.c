/*
 *
 *
 *  Rough crack at Lode Runner using Death Star.
 *  Fail. DM. 12/Oct/2019
 *  Unrolled various loops within level decompress, but still not enough grunt.
 *   - Gotta eliminate the entire compress/decompress level.
 *   - Entire level is drawn each movement. slow.
 *   - Current level design has no colour. 
 *   - Current level design is pretty useless....
 *   - uses lode.h for keys and level and stuff
 *
 *      The keys are defined in #define statements, and default thus:
 *
 *      Up:     Q
 *      Down:   A
 *      Left:   O
 *      Right:  P
 *      Quit:   G
 *      Retry:  H
 *      Switch: [SPACE]
 *
 *      Switch changes between the dark bubble and the solid box.
 *
 */

 /* Skip closeall() gunk */

#pragma output nostreams


/* Call up the required header files */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

/* lode.h contains the levels and "sprite" data */

#include "lode.h"



#define NO 0
#define MAXLEVEL 25
#define STARTLEV  0     /* Start level -1 */

/* Block numbers.. */

#define WALL 1  
#define BUBB 2
#define BALL 3
#define BOX 4

/* Key definitions, change these to define your keys! */

#define K_UP 'Q'
#define K_DOWN 'A'
#define K_LEFT 'O'
#define K_RIGHT 'P'
#define K_SWITCH 32
#define K_EXIT  'G'
#define K_CLEAR 'H'


/* Declare some variables to start off with! */


char balloffset;        /* Ball position */
char boxoffset;         /* Box position */
char ballorbox;         /* 1 if box, 0 if ball */
char level;             /* Take a guess! */

char board[144];        /* Level internal map thing */
char tiscr[1024];       /* Our very own TI86 screen! */


/* prototype to stop barfing */

void redrawscreen(void);
static void myexit(void);
static void playgame(void);
static void setupgame(void);
static void gamekeys(void);
static void left(char *ptr);
static void right(char *ptr);
static void down(char *ptr);
static void up(char *ptr);
static int standardmiddle(char nextpos);
static int checkfinish(void);
static void setuplevel(void);
static void drawboard(void);
static void puttiblock(unsigned char spr,int x, int y);
static void dovzcopyasm(void);

void main()
{
	#asm
	di
	#endasm

        redrawscreen();         /* Define the windows */
        playgame();     /* Play the game */
        myexit();       /* Clean up after ourselves */

}

void myexit()
{
        exit(0);                /* Get outta here! */
}


void playgame()
{
        setupgame();            /* Set level to 1, get level etc */
/* Loop while checkfinish() says we haven't finished! */

        while ( checkfinish() ) {
	#asm
	di
	#endasm

                gamekeys();     /* Scan keys */
        }
}


/* Set some variables up at the start.. */

void setupgame()
{
        ballorbox=NO;
        level=STARTLEV;
        setuplevel();
}


void gamekeys()
{
        char *charptr;

/* Set up a pointer to the variable we want to change (either for
 * box or for ball
 */
        if (ballorbox) charptr=&boxoffset;
        else charptr=&balloffset;

        switch( toupper(getk()) ) {      /* Use OZ to get the key */
                case K_DOWN:
                        down(charptr);
                        break;
                case K_UP:
                        up(charptr);
                        break;
                case K_RIGHT:
                        right(charptr);
                        break;
                case K_LEFT:
                        left(charptr);
                        break;
                case K_SWITCH:
                        ballorbox^=1;   /* Toggle ball/box */
                        break;
                case K_EXIT:
                        myexit();
                case K_CLEAR:
                        setuplevel();
        }
}


/* Movement functions - all of these are pretty well similar so I
 * will only comment the first one - it's fairly obvious what is
 * happening though
 */

void left(char *ptr)
{
        char *locn;

        while(1) {
                locn=*(ptr)+board;
                if (standardmiddle(*(locn-1)) ) return;
                *(locn-1)=*locn;
                *locn=0;
                (*ptr)--;       /* ptr is the location of blob */
                drawboard();    /* Draw screen */
        }
}


void right(char *ptr)
{
        char *locn;

        while(1) {
                locn=*(ptr)+board;
                if (standardmiddle(*(locn+1)) ) return;
                *(locn+1)=*locn;
                *locn=0;
                (*ptr)++;
                drawboard();
        }
}

void down(char *ptr)
{
        char *locn;

        while(1) {
                locn=*(ptr)+board;
                if (standardmiddle(*(locn+16)) ) return;
                *(locn+16)=*locn;
                *locn=0;
                (*ptr)+=16;
                drawboard();
        }
}

void up(char *ptr)
{
        char *locn;

        while(1) {
                locn=*(ptr)+board;
                if ( standardmiddle(*(locn-16)) ) return;
                *(locn-16)=*locn;
                *locn=0;
                (*ptr)-=16;
                drawboard();
        }
}


/* Check to see if we're running into anything, if box is set then
 * if we hit anything we want to stop, if we're ball then if we
 * hit anything except for bubble we wanna stop
 */
int standardmiddle(char nextpos)
{
        if (ballorbox)
                return (nextpos);       /* For box */
        else
                if (nextpos==BUBB || nextpos==NO) return(0);
        return(1);
}



/* Check to see if a level is finished
 * There are 144 squares in each level, note the use of != instead of
 * </<= - this is quicker to execute on the Z80!
 */

int checkfinish()
{
        char *ptr;
        int i;
        ptr=board;
        for (i=1; i!=144; i++) {
                if (*ptr++ == BUBB) return(1);
        }
        if ( ++level==MAXLEVEL ) return(0);     /* Done all the levels!! */
        setuplevel();
        return(1);
}

/* Setup a level..the level is stored compressed, taking up 38 bytes a
 * time.
 *      byte 0 - position of ball
 *      byte 1 - position of box
 *      2-37   - level data
 *
 * Level data is stored as two bits per square, so we have to shift our
 * picked up byte round to get it
 */

void setuplevel()
{
        int y,x;
        char *ptr,*ptr2;
        ptr2=board;
        ptr=levels+(level*38);
/* ptr points to start of level now */
/* First two bytes are the ball and the boxes position */
        balloffset=*ptr++;
        boxoffset=*ptr++;

/* Now, decompress level into board */
        for (y=0; y!=9; y++) {
                for (x=0; x !=4; x++) {
                        *ptr2++=((*ptr)>>6)&3;
                        *ptr2++=((*ptr)>>4)&3;
                        *ptr2++=((*ptr)>>2)&3;
                        *ptr2++=(*ptr)&3;
                        ptr++;
                }
        }
/* Now, plot the ball and box into the internal map */
        ptr2=board;
        *(ptr2+balloffset)=BALL;
        *(ptr2+boxoffset)=BOX;
        drawboard();
}



/* Define the text window and the graphics window
 * If can't open graphics window then exit gracefully
 */

void redrawscreen(void)
{
/* Init Graphics page */
#asm
				ld	a,8
				ld	(6800h),a
				ld	(783bh),a		; force graph mode

				ld	hl,7000h	; base of graphics area
				ld	(hl),0
				ld	d,h
				ld	e,1			; de	= base_graphics+1
				ld	bc,128*64/4-1
				ldir				; reset graphics window (2K)
#endasm
}

/* Draw the board, mostly written in C, even though we did take a bit
 * of a performance hit when it was converted over from asm
 */

void drawboard()
{
        int x,y;
        char *ptr;

        ptr=board;

        for (y=0;y!=9;y++) {
                        puttiblock((*ptr++),0,y);
                        puttiblock((*ptr++),1,y);
                        puttiblock((*ptr++),2,y);
                        puttiblock((*ptr++),3,y);
                        puttiblock((*ptr++),4,y);
                        puttiblock((*ptr++),5,y);
                        puttiblock((*ptr++),6,y);
                        puttiblock((*ptr++),7,y);
                        puttiblock((*ptr++),8,y);
                        puttiblock((*ptr++),9,y);
                        puttiblock((*ptr++),10,y);
                        puttiblock((*ptr++),11,y);
                        puttiblock((*ptr++),12,y);
                        puttiblock((*ptr++),13,y);
                        puttiblock((*ptr++),14,y);
                        puttiblock((*ptr++),15,y);


        }



			/* copy to screen */
#asm
        ld      de,28672
        ld      hl,_tiscr
        ld      bc,1024
.cploop
        ld	a,(hl)
	push	bc
.nibble1
	rla
	push	af
	rl	c
	pop	af
	rl	c
	rla
	push	af
	rl	c
	pop	af
	rl	c
	rla
	push	af
	rl	c
	pop	af
	rl	c
	rla
	push	af
	rl	c
	pop	af
	rl	c

	push	af
	ld	a,c
	and 	170
	ld	(de),a
	pop	af
	inc	de

.nibble2
	rla
	push	af
	rl	c
	pop	af
	rl	c
	rla
	push	af
	rl	c
	pop	af
	rl	c
	rla
	push	af
	rl	c
	pop	af
	rl	c
	rla
	push	af
	rl	c
	pop	af
	rl	c

	ld	a,c
	and 170
	ld	(de),a
	inc	de
	inc	hl
	pop	bc

	dec	bc
	
        ld	a,b
        or	c
        jr	nz,cploop

#endasm
}


/* Dump a sprite onto the TI screen we've built
 * The TI screen is 16 characters wide by 8 deep i.e. half the size
 * of the Z88's map screen. It's stored line by line (sensible!)
 *
 * We enter with y being y/7 and x being x/8 (if we think in pixels)
 * So for each y we have to step down by 112.
 * The increment between rows is 16.
 */
 


void puttiblock(unsigned char spr,int x, int y)
{
        char *ptr2,*ptr;
        int i;

/* We use this method instead of y*=112 because the compiler has special
 * cases for multiplying by ints less than 16 (except for 11 and 13 
 * (Hmmm, I wonder why?!?!)
 */
//        y=(y*14)*8;
/* So, get where we want to dump our sprite into ptr */
        ptr=tiscr+(y*14)*8+x;
/* Calculate where the sprite is */
        spr*=8;
        ptr2=sprites+spr;
/* And dump it in there */
                *ptr=*(ptr2++);
                ptr+=16;
                *ptr=*(ptr2++);
                ptr+=16;
                *ptr=*(ptr2++);
                ptr+=16;
                *ptr=*(ptr2++);
                ptr+=16;
                *ptr=*(ptr2++);
                ptr+=16;
                *ptr=*(ptr2++);
                ptr+=16;
                *ptr=*(ptr2++);
                ptr+=16;
                *ptr=*(ptr2++);
                ptr+=16;



}
