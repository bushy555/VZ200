

#include <vz.h>
#include <games.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <graphics.h>
#include <math.h>


int   d,pi,n;
float a,b,c,k,u,w,x,y,z;


int main(){

#asm
	di
#endasm

   vz_mode(1);
   a=.7;
   b=.9998;
   c=2-7*a;    // 2-2*a;
   d=1;
   x=2;
   y=12.1;
   w=a*x+c*x*x/(1+x*x);
   for (n=1;n<3000;n++) {
      vz_plot(80+x,32+y,(n/1000) + 1);
      z=x;
      x=b*y+w;
      u=x*x;
      w=a*x+c*u/(1+u);
      y=w-z;
   }
   z=1;
   while(z=1){;}

}

