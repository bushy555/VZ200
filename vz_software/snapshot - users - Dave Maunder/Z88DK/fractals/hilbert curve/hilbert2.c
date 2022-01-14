//  Compile with :
//  
//  SET Z80_OZFILES=C:\vz\z88dk\lib
//  SET ZCCCFG=C:\vz\z88dk\lib\config
//  SET PATH=C:\vz\z88dk\bin;%PATH%
//  
//  zcc +vz -create-app -lm %1.c -o %1.vz
//  <or>
//  zcc +vz -O3 -vn %1.c -o %1.vz -create-app -lndos


#include <vz.h>

 
	int o,t,dy,dx;
	int x,y,z;
	int x1,y1;
	int tmp;

//  5 O=10:T=-1:DY=2:DX=0:X=60:Y=1
// 10 MODE(1):GOSUB20:END
// 20 O=O-1:T=-T:TMP=DY:DY=-T*DX:DX=T*TMP:IFO>0,GOSUB20
// 30 X1=X:Y1=Y:X=X+DX:Y=Y+DY:PLOT(X1,Y1)TO(X,Y):T=-T
// 40 TMP=DY:DY=-T*DX:DX=T*TMP:IFO>0,GOSUB20
// 50 X1=X:Y1=Y:X=X+DX:Y=Y+DY:PLOT(X1,Y1)TO(X,Y):IFO>0,GOSUB20
// 60 TMP=DY:DY=-T*DX:DX=T*TMP:T=-T
// 70 X1=X:Y1=Y:X=X+DX:Y=Y+DY:PLOT(X1,Y1)TO(X,Y):IFO>0,GOSUB20
// 80 TMP=DY:DY=-T*DX:DX=T*TMP:T=-T:O=O+1:RETURN

void loopy(){
	o--;					// line 20
	t = -t;
	tmp=dy;
	dy=-t*dx;
	dx=t*tmp;
	if (o>0){ loopy();}
	x1=x;					// line 30	
	y1=y;
	x=x+dx;
	y=y+dy;
	vz_line(x1,y1,x,y,2);
	t=-t;					
	tmp=dy;					// line 40
	dy=-t*dx;
	dx=t*tmp;
	if (o>0){ loopy();}
	x1=x;					// line 50	
	y1=y;
	x=x+dx;
	y=y+dy;
	vz_line(x1,y1,x,y,2);
	if (o>0){ loopy();}
	tmp=dy;					// line 60	
	dy=-t*dx;
	dx=t*tmp;
	t=-t;
	x1=x;					// line 70	
	y1=y;
	x=x+dx;
	y=y+dy;
	vz_line(x1,y1,x,y,2);
	if (o>0){ loopy();}
	tmp=dy;					// line 80	
	dy=-t*dx;
	dx=t*tmp;
	t=-t;
	o++;
	return ;
}
void main(){
	o=10;					// LINE 5
	t=-1;
	dx=2;
	dy=0;
	x=60;
	y=1;
	z=1;	

#asm
	di
#endasm

   vz_mode(1);
   while (z==1) {	
      loopy();	}
}
