#include <vz.h>
#include <graphics.h>
#include <math.h>

int   b,n;
float i,j,u,v,x,y,s,t,a,c,p,q,pi,z;

int main(){
   vz_mode(1);

#asm	
   di    
#endasm

      a=.2;
      c=.9;
      p=1/sqrt (2);
      q=p*sqrt(1-c*c);
      pi=3.1415927;
      
   for (n=-500;n<500;n++) {
      s=n*pi/100;
//      t=atn(a*s);
      t=tan(a*s);
      x=cos(s)*cos(t);
      y=sin(s)*cos(t);
      z=sin(t);
      i=u;
      j=v;
      u=p*(y-x);
      v=c*z-q*(x+y);
      vz_line(60+i*60,30+j*15,60+u*60,30+v*15,2);
   }
 
   b=1;
   while(b=1){};

}
