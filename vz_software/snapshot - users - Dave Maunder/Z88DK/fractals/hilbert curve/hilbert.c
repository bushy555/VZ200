//
//
// Set Z88DK compiler environment variables: 
// Example:
//    SET Z80_OZFILES = C:\progra~1\Z88DK\lib\
//    SET ZCCCFG      = C:\progra~1\Z88DK\lib\config\
//    SET PATH        = C:\progra~1\Z88DK\bin;%PATH%
//
//
// Build all of this with:
//   zcc +vz -zorg=32768 -O3 -vn -m %1.c %1.asm -o %1.vz -create-app -lndos


#include <vz.h>
#include <games.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <graphics.h>
#include <math.h>


void main(){

int o,t,dy,dx;
int x,y,z;
int x1,y1;
int tmp, tmp2;
#asm
	di
	ld 	a,8
	ld 	(0x6800), a
#endasm


	o=10;
	t=-1;
	dx=0;
	dy=2;
	x=60;
	y=1;

	z=1;	

	while (z==1) {

// line 20	

loopy()
{		o--;
		t = -t;
		tmp=dy;
		dy=-t*dx;
		dx=t*tmp;
		if (o>0) loopy();
//		if (o>0) { loopy() }

// line 30	
		x1=x;
		y1=y;
		x = x + dx;
		y = y + dy;
		vz_line(x1,y1,x,y,2);
		t=-t;

// line 40	
		tmp=dy;
		dy=-t*dx;
		dx=t*tmp;
		if (o>0) gosub loopy;
//		if (o>0) { loopy() }

// line 50	
		x1=x;
		y1=y;
		x=x+dx;
		y=y+dy;
		vz_line(x1,y1,x,y,2);
		if (o>0) gosub loopy;
//		if (o>0) { loopy() }

// line 60	
		tmp=dy;
		dy=-t*dx;
		dx=t*tmp;
		t=-t;

// line 70	
		x1=x;
		y1=y;
		x=x+dx;
		y=y+dy;
		vz_line(x1,y1,x,y,2);
		if (o>0) gosub loopy;

// line 80	
		tmp=dy;
		dy=-t*dx;
		dx=t*tmp;
		t=-t;
		o++;
		return;
		
	
	}

}



//4 '  HILBERT CURVE. REQUIRES
//5 '  EXTENDED BASIC FOR PLOT.
//6 ' CHANGE VALUES O,DX & DY.
//9 O=10:T=-1:DY=2:DX=0:X=60:Y=1
//10 MODE(1):GOSUB20:END
//20 O=O-1:T=-T:TMP=DY:DY=-T*DX:DX=T*TMP:IFO>0,GOSUB20
//30 X1=X:Y1=Y:X=X+DX:Y=Y+DY:PLOT(X1,Y1)TO(X,Y):T=-T
//40 TMP=DY:DY=-T*DX:DX=T*TMP:IFO>0,GOSUB20
//50 X1=X:Y1=Y:X=X+DX:Y=Y+DY:PLOT(X1,Y1)TO(X,Y):IFO>0,GOSUB20
//60 TMP=DY:DY=-T*DX:DX=T*TMP:T=-T
//70 X1=X:Y1=Y:X=X+DX:Y=Y+DY:PLOT(X1,Y1)TO(X,Y):IFO>0,GOSUB20
//80 TMP=DY:DY=-T*DX:DX=T*TMP:T=-T:O=O+1:RETURN
