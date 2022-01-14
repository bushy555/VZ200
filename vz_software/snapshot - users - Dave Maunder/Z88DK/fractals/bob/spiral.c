#include <vz.h>
//#include <games.h>
//#include <stdio.h>
//#include <stdlib.h>
//#include <conio.h>
//#include <graphics.h>
#include <math.h>

float a,b,t,r,u,v,x,y,z;

int main(){

   vz_mode(1);

#asm	
   di    
#endasm

   a=.3;
   b=.1;
   for (t=0;t<50;t=t+.1) {
      r=a*exp(b*t);
      u=x;
      v=y;
      x=r*cos(t);
      y=r*sin(t);       
      vz_line(60+u,32+v,60+x,32+y,2);
   }
   z=1;
   while(z=1){;}
}

