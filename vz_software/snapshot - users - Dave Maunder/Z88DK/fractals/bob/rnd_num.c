

#include <vz.h>
#include <games.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <graphics.h>
#include <math.h>

float a, b, c,k, x, y,z;
int d;

int main(){

//#asm
//	di
//	ld 	a,8
//	ld 	(0x6800), a
//#endasm


//%c 	Character
//%		Character
//%d	Signed decimal integer
//%i	Signed decimal integer
//%e	scientific notation
//%E	scientific notation
//%f	Floating
//%g	Short %e
//%G	short %E
//%o	signed Octal
//%s	String
//%u	unsigned decimal integer
//%x	unsigned HEX
//%X	unsigned HEX
//%P	pointer
//%n	nothing printed

	z=1;
 while (z==1){
  a = rand();
  b = rand()%0;
  printf ("RND= %f \n",a/1000);
	}

	}

// FOR k = 1 TO 20
//45  COLOR RND(3)+1
//50  x=-4+RAND()%1:y=-.4+RAND()%1
//70  a=.24:b=SQR(1-a^2)
//80  FOR n = 1 TO 500
//85   SET (60+(x*63)),30+(y*32))
//90   z=x:x=x*a-(y-x*x)*b
//100  y=z*b+(y-z*z)*a
//110  IF (ABS(x) + ABS(y))>10,k=k+.1:NEXTK
//120  NEXT N
//130 NEXT k
//140 GOTO 140





}
