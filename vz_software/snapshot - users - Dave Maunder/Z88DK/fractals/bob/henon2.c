
#include <vz.h>
#include <graphics.h>
#include <math.h>

int   d,j,l,m,n,o,s,z,x,t,y;
float a, b,c,i,k,u,v,w;

int main(){

#asm
	di
#endasm


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

//	z=1;
//	while (z==1){
//  a = rand();
//  b = rand()%0;
//  printf ("RND= %f \n",a/1000);
//	}

	
   for (k=1;k<20;k++) {
       b = rand()%0;
       c = rand()%0;
      x = -4 + (b/10000);
      y=-.4+(c/10000);
      a=.24;
      i=sqrt (1-a^2);	
      for (n=1;n<500;n++) {

         s = 60 + (x*63);
         t=30+(y*32);
	 vz_plot(s,t,2);
	 z=x;
	 x=x*a-(y-x*x)*i;
	 y=z*i+(y-z*z)*a;
         u=abs(x);
         v=abs(y);
         w=u+v;
         if (w > 10) {
	    k=k+.1;
	    n=500;
	 }
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
