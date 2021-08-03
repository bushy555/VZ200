// eyes on red face
// monkey island style egypt dude

 #include <vz.h>
 #include <graphics.h>
 #include <stdio.h>
 #include <sound.h>
 #include <stdlib.h>
 #include <ctype.h>
 #include <strings.h>
 #include <conio.h>

#define scrn 28672
#define buffer1 0xe000

int main()
{
	int a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,x,y,z;
	int dir, dira, dirb;
    	vz_mode(1);
	i=0;
        z=0;
	dir = 1;
	dira = 1;
	dirb = 1;
	x = 64;
	y = 64;
	i = 64;
	j = 64;
	k = 2;
	a=1;
	b=1;
	c=3;
	d=3;
	e=16;
	f=32;
	g=8;
	h=32;
	vz_setbase( buffer1 );
	asm("di\n");
//	memset (0xA800, 170, 2048);
	while (z==0)
	{
//	memset (0xA800, 0, 128);
//	memset (0xA800+128, 170, 2048-128);
	

	memset (buffer1, 170, 2048);


	if (dir == 1) {k++;}
	if ((dir == 1) && (k == 25)) {dir = 0;}
	if (dir == 0) {k--;}
	if ((dir == 0) && (k == 4))  {dir = 1;}

	if ((dira ==1) && (a< 25)) {a++ ;  b=0; dira=1;}
	if ((dira ==1) && (a== 25)){a=25;  b++; dira=2;}
	if ((dira ==2) && (b< 44)) {a=25;  b++; dira=2;}
	if ((dira ==2) && (b== 44)){a-- ; b=44; dira=3;}
	if ((dira ==3) && (a> 0))  {a-- ; b=44; dira=3;}
	if ((dira ==3) && (a== 0)) {a=0 ;  b--; dira=4;}
	if ((dira ==4) && (b> 0))  {a=0 ;  b--; dira=4;}
	if ((dira ==4) && (b== 0)) {a++ ;  b=0; dira=1;}

	if ((dirb ==1) && (c<25)) {c++; d++; dirb=1;}
	if ((dirb ==1) && (c==25)) {dirb=2;}
	if ((dirb ==2) && (c>2)) {c--; d--; dirb=2;}
	if ((dirb ==2) && (c==2)) {dirb=1;}


	if (rand(255)/128 < 60) {e++;}
	if (rand(255)/128 < 60) {f--;}
	if (rand(255)/128 < 60) {e--;}
	if (rand(255)/128 < 60) {f++;}
	if (e <3)   {e=3;}
	if (e > 24) {e=24;}
	if (f <2)   {f=2;}
	if (f > 48) {f=48;}


	if (rand(255)/128 < 60) {g++;}
	if (rand(255)/128 < 60) {h--;}
	if (rand(255)/128 < 60) {g--;}
	if (rand(255)/128 < 60) {h++;}
	if (g <3)   {g=3;}
	if (g > 24) {g=24;}
	if (h <2)   {h=2;}
	if (h > 48) {h=48;}


		{
		// STAR A
		i = a+(b*32) + 0xE000;
bpoke(i+0x023,138);bpoke(i+0x043,2);bpoke(i+0x062,168);bpoke(i+0x063,0);bpoke(i+0x082,160);bpoke(i+0x083,0);
bpoke(i+0x084,42);bpoke(i+0x0A2,128);bpoke(i+0x0A3,0);bpoke(i+0x0A4,10);bpoke(i+0x0C2,0);bpoke(i+0x0C3,0);bpoke(i+0x0C4,2);
bpoke(i+0x0E0,0);bpoke(i+0x0E1,0);bpoke(i+0x0E2,0);bpoke(i+0x0E3,0);bpoke(i+0x0E4,0);bpoke(i+0x0E5,0);bpoke(i+0x0E6,2);
bpoke(i+0x100,128);bpoke(i+0x101,0);bpoke(i+0x102,0);bpoke(i+0x103,0);bpoke(i+0x104,0);bpoke(i+0x105,0);bpoke(i+0x106,10);
bpoke(i+0x120,160);bpoke(i+0x121,0);bpoke(i+0x122,0);bpoke(i+0x123,0);bpoke(i+0x124,0);bpoke(i+0x125,0);
bpoke(i+0x126,42);bpoke(i+0x141,0);bpoke(i+0x142,0);bpoke(i+0x143,0);bpoke(i+0x144,0);bpoke(i+0x145,2);bpoke(i+0x161,160);
bpoke(i+0x162,0);bpoke(i+0x163,0);bpoke(i+0x164,0);bpoke(i+0x165,42);bpoke(i+0x181,168);bpoke(i+0x182,0);bpoke(i+0x183,0);bpoke(i+0x184,0);
bpoke(i+0x1A1,160);bpoke(i+0x1A2,0);bpoke(i+0x1A3,0);bpoke(i+0x1A4,0);bpoke(i+0x1A5,42);bpoke(i+0x1C1,128);
bpoke(i+0x1C2,0);bpoke(i+0x1C3,0);bpoke(i+0x1C4,0);bpoke(i+0x1C5,10);bpoke(i+0x1E0,168);bpoke(i+0x1E1,0);bpoke(i+0x1E2,2);bpoke(i+0x1E4,0);
bpoke(i+0x1E5,0);bpoke(i+0x200,160);bpoke(i+0x201,0);bpoke(i+0x202,42);bpoke(i+0x204,160);bpoke(i+0x205,0);bpoke(i+0x206,42);
bpoke(i+0x220,128);bpoke(i+0x221,2);bpoke(i+0x225,0);bpoke(i+0x226,10);bpoke(i+0x240,0);bpoke(i+0x245,168);bpoke(i+0x246,2);



		i = (0xe800 - (23*32)) + k;

// STAR B

bpoke(i+0x023,154);bpoke(i+0x043,86);bpoke(i+0x062,169);bpoke(i+0x063,85);bpoke(i+0x082,165);bpoke(i+0x083,85);bpoke(i+0x084,106);
bpoke(i+0x0A2,149);bpoke(i+0x0A3,85);bpoke(i+0x0A4,90);bpoke(i+0x0C2,85);bpoke(i+0x0C3,85);bpoke(i+0x0C4,86);
bpoke(i+0x0E0,85);bpoke(i+0x0E1,85);bpoke(i+0x0E2,85);bpoke(i+0x0E3,85);bpoke(i+0x0E4,85);bpoke(i+0x0E5,85);bpoke(i+0x0E6,86);
bpoke(i+0x100,149);bpoke(i+0x101,85);bpoke(i+0x102,85);bpoke(i+0x103,85);bpoke(i+0x104,85);bpoke(i+0x105,85);bpoke(i+0x106,90);
bpoke(i+0x120,165);bpoke(i+0x121,85);bpoke(i+0x122,85);bpoke(i+0x123,85);bpoke(i+0x124,85);bpoke(i+0x125,85);bpoke(i+0x126,106);
bpoke(i+0x141,85);bpoke(i+0x142,85);bpoke(i+0x143,85);bpoke(i+0x144,85);bpoke(i+0x145,86);bpoke(i+0x161,165);
bpoke(i+0x162,85);bpoke(i+0x163,85);bpoke(i+0x164,85);bpoke(i+0x165,106);bpoke(i+0x181,169);bpoke(i+0x182,85);
bpoke(i+0x183,85);bpoke(i+0x184,85);bpoke(i+0x1A1,165);bpoke(i+0x1A2,85);bpoke(i+0x1A3,85);bpoke(i+0x1A4,85);bpoke(i+0x1A5,106);
bpoke(i+0x1C1,149);bpoke(i+0x1C2,85);bpoke(i+0x1C3,85);bpoke(i+0x1C4,85);bpoke(i+0x1C5,90);bpoke(i+0x1E0,169);bpoke(i+0x1E1,85);
bpoke(i+0x1E2,86);bpoke(i+0x1E4,85);bpoke(i+0x1E5,85);bpoke(i+0x200,165);bpoke(i+0x201,85);bpoke(i+0x202,106);
bpoke(i+0x204,165);bpoke(i+0x205,85);bpoke(i+0x206,106);bpoke(i+0x220,149);bpoke(i+0x221,86);bpoke(i+0x225,85);bpoke(i+0x226,90);
bpoke(i+0x240,85);bpoke(i+0x245,169);bpoke(i+0x246,86);bpoke(i+0x260,90);bpoke(i+0x266,150);

//STAR C

//		i = ((0xe000 + (32*32)) + (k/2));
		i = c + (d*32) + 0xE000;
bpoke(i+0x023,186);bpoke(i+0x043,254);bpoke(i+0x062,171);bpoke(i+0x063,255);bpoke(i+0x082,175);bpoke(i+0x083,255);bpoke(i+0x084,234);
bpoke(i+0x0A2,191);bpoke(i+0x0A3,255);bpoke(i+0x0A4,250);bpoke(i+0x0C2,255);bpoke(i+0x0C3,255);bpoke(i+0x0C4,254);
bpoke(i+0x0E0,255);bpoke(i+0x0E1,255);bpoke(i+0x0E2,255);bpoke(i+0x0E3,255);bpoke(i+0x0E4,255);bpoke(i+0x0E5,255);bpoke(i+0x0E6,254);
// EYES ON RED STAR
bpoke(i+0x100,191);bpoke(i+0x101,255);bpoke(i+0x102,95);bpoke(i+0x103,255);bpoke(i+0x104,215);bpoke(i+0x105,255);bpoke(i+0x106,250);
bpoke(i+0x120,175);bpoke(i+0x121,255);bpoke(i+0x122,95);bpoke(i+0x123,255);bpoke(i+0x124,215);bpoke(i+0x125,255);
bpoke(i+0x126,234);bpoke(i+0x141,255);bpoke(i+0x142,255);bpoke(i+0x143,255);bpoke(i+0x144,255);bpoke(i+0x145,254);
bpoke(i+0x161,175);bpoke(i+0x162,255);bpoke(i+0x163,255);bpoke(i+0x164,255);bpoke(i+0x165,234);
bpoke(i+0x181,171);bpoke(i+0x182,253);bpoke(i+0x183,253);bpoke(i+0x184,255);bpoke(i+0x1A1,175);bpoke(i+0x1A2,255);bpoke(i+0x1A3,87);
bpoke(i+0x1A4,255);bpoke(i+0x1A5,234);bpoke(i+0x1C1,191);bpoke(i+0x1C2,255);bpoke(i+0x1C3,255);bpoke(i+0x1C4,255);bpoke(i+0x1C5,250);
bpoke(i+0x1E0,171);bpoke(i+0x1E1,255);bpoke(i+0x1E2,254);bpoke(i+0x1E4,255);bpoke(i+0x1E5,255);bpoke(i+0x200,175);bpoke(i+0x201,255);
bpoke(i+0x202,234);bpoke(i+0x204,175);bpoke(i+0x205,255);bpoke(i+0x206,234);bpoke(i+0x220,191);bpoke(i+0x221,254);bpoke(i+0x225,255);
bpoke(i+0x226,250);bpoke(i+0x240,255);bpoke(i+0x245,171);bpoke(i+0x246,254);bpoke(i+0x260,250);bpoke(i+0x266,190);
                                      

		i = ((0xE000 + (31*32)) - (k/3)) - 8;

bpoke(i+0x023,154);bpoke(i+0x043,86);bpoke(i+0x062,169);bpoke(i+0x063,85);bpoke(i+0x082,165);bpoke(i+0x083,85);bpoke(i+0x084,106);
bpoke(i+0x0A2,149);bpoke(i+0x0A3,85);bpoke(i+0x0A4,90);bpoke(i+0x0C2,85);bpoke(i+0x0C3,85);bpoke(i+0x0C4,86);
bpoke(i+0x0E0,85);bpoke(i+0x0E1,85);bpoke(i+0x0E2,85);bpoke(i+0x0E3,85);bpoke(i+0x0E4,85);bpoke(i+0x0E5,85);bpoke(i+0x0E6,86);
bpoke(i+0x100,149);bpoke(i+0x101,85);bpoke(i+0x102,85);bpoke(i+0x103,85);bpoke(i+0x104,85);bpoke(i+0x105,85);bpoke(i+0x106,90);
bpoke(i+0x120,165);bpoke(i+0x121,85);bpoke(i+0x122,85);bpoke(i+0x123,85);bpoke(i+0x124,85);bpoke(i+0x125,85);bpoke(i+0x126,106);
bpoke(i+0x141,85);bpoke(i+0x142,85);bpoke(i+0x143,85);bpoke(i+0x144,85);bpoke(i+0x145,86);bpoke(i+0x161,165);
bpoke(i+0x162,85);bpoke(i+0x163,85);bpoke(i+0x164,85);bpoke(i+0x165,106);bpoke(i+0x181,169);bpoke(i+0x182,85);
bpoke(i+0x183,85);bpoke(i+0x184,85);bpoke(i+0x1A1,165);bpoke(i+0x1A2,85);bpoke(i+0x1A3,85);bpoke(i+0x1A4,85);bpoke(i+0x1A5,106);
bpoke(i+0x1C1,149);bpoke(i+0x1C2,85);bpoke(i+0x1C3,85);bpoke(i+0x1C4,85);bpoke(i+0x1C5,90);bpoke(i+0x1E0,169);bpoke(i+0x1E1,85);
bpoke(i+0x1E2,86);bpoke(i+0x1E4,85);bpoke(i+0x1E5,85);bpoke(i+0x200,165);bpoke(i+0x201,85);bpoke(i+0x202,106);
bpoke(i+0x204,165);bpoke(i+0x205,85);bpoke(i+0x206,106);bpoke(i+0x220,149);bpoke(i+0x221,86);bpoke(i+0x225,85);bpoke(i+0x226,90);
bpoke(i+0x240,85);bpoke(i+0x245,169);bpoke(i+0x246,86);bpoke(i+0x260,90);bpoke(i+0x266,150);



//star d - WAGON wheel
		i =  0xE000 + e + (f*32) - (8*64)-16;
bpoke(i+0x003,85);bpoke(i+0x004,90);bpoke(i+0x022,149);bpoke(i+0x023,85);bpoke(i+0x024,85);bpoke(i+0x025,106);
bpoke(i+0x042,85);bpoke(i+0x043,106);bpoke(i+0x044,149);bpoke(i+0x045,90);
bpoke(i+0x061,169);bpoke(i+0x062,85);bpoke(i+0x064,165);bpoke(i+0x065,86);
bpoke(i+0x081,149);bpoke(i+0x082,149);bpoke(i+0x083,106);bpoke(i+0x084,165);bpoke(i+0x085,101);bpoke(i+0x086,106);
bpoke(i+0x0A1,86);bpoke(i+0x0A2,165);bpoke(i+0x0A3,106);bpoke(i+0x0A4,165);bpoke(i+0x0A5,105);bpoke(i+0x0A6,90);
bpoke(i+0x0C1,90);bpoke(i+0x0C2,165);bpoke(i+0x0C3,106);bpoke(i+0x0C4,165);bpoke(i+0x0C6,86);
bpoke(i+0x0E0,169);bpoke(i+0x0E1,106);bpoke(i+0x0E2,169);bpoke(i+0x0E3,90);bpoke(i+0x0E4,149);bpoke(i+0x0E6,150);
bpoke(i+0x100,165);bpoke(i+0x102,169);bpoke(i+0x103,90);bpoke(i+0x104,150);bpoke(i+0x106,165);
bpoke(i+0x120,165);bpoke(i+0x123,90);bpoke(i+0x124,150);bpoke(i+0x126,165);bpoke(i+0x127,106);
bpoke(i+0x140,149);bpoke(i+0x141,90);bpoke(i+0x143,86);bpoke(i+0x144,90);bpoke(i+0x146,85);bpoke(i+0x147,106);
bpoke(i+0x160,149);bpoke(i+0x161,85);bpoke(i+0x163,150);bpoke(i+0x164,90);bpoke(i+0x165,165);bpoke(i+0x166,85);bpoke(i+0x167,90);
bpoke(i+0x180,85);bpoke(i+0x181,85);bpoke(i+0x182,90);bpoke(i+0x183,150);bpoke(i+0x184,106);bpoke(i+0x185,85);
bpoke(i+0x186,85);bpoke(i+0x187,90);bpoke(i+0x1A0,90);bpoke(i+0x1A1,169);bpoke(i+0x1A2,85);bpoke(i+0x1A3,165);
bpoke(i+0x1A4,101);bpoke(i+0x1A5,85);bpoke(i+0x1A7,90);bpoke(i+0x1C0,90);bpoke(i+0x1C2,165);bpoke(i+0x1C3,85);bpoke(i+0x1C4,85);
bpoke(i+0x1C5,106);bpoke(i+0x1C7,90);bpoke(i+0x1E0,90);bpoke(i+0x1E3,149);bpoke(i+0x1E4,106);bpoke(i+0x1E7,90);
bpoke(i+0x200,90);bpoke(i+0x202,165);bpoke(i+0x203,85);bpoke(i+0x204,85);bpoke(i+0x205,106);bpoke(i+0x207,90);
bpoke(i+0x220,90);bpoke(i+0x221,169);bpoke(i+0x222,85);bpoke(i+0x223,165);bpoke(i+0x224,101);bpoke(i+0x225,85);bpoke(i+0x227,90);
bpoke(i+0x240,85);bpoke(i+0x241,85);bpoke(i+0x242,90);bpoke(i+0x243,150);bpoke(i+0x244,106);bpoke(i+0x245,85);bpoke(i+0x246,85);
bpoke(i+0x247,90);bpoke(i+0x260,149);bpoke(i+0x261,85);bpoke(i+0x263,150);bpoke(i+0x264,90);bpoke(i+0x265,165);bpoke(i+0x266,85);
bpoke(i+0x267,90);bpoke(i+0x280,149);bpoke(i+0x281,90);bpoke(i+0x283,86);bpoke(i+0x284,90);bpoke(i+0x286,85);bpoke(i+0x287,106);
bpoke(i+0x2A0,149);bpoke(i+0x2A3,90);bpoke(i+0x2A4,150);bpoke(i+0x2A6,165);bpoke(i+0x2A7,106);bpoke(i+0x2C0,165);bpoke(i+0x2C2,169);
bpoke(i+0x2C3,90);bpoke(i+0x2C4,150);bpoke(i+0x2C6,165);bpoke(i+0x2E0,169);bpoke(i+0x2E1,106);bpoke(i+0x2E2,169);bpoke(i+0x2E3,90);
bpoke(i+0x2E4,149);bpoke(i+0x2E6,150);bpoke(i+0x301,90);bpoke(i+0x302,165);bpoke(i+0x303,106);bpoke(i+0x304,165);bpoke(i+0x306,86);
bpoke(i+0x321,86);bpoke(i+0x322,165);bpoke(i+0x323,106);bpoke(i+0x324,165);bpoke(i+0x325,105);bpoke(i+0x326,90);bpoke(i+0x341,149);
bpoke(i+0x342,85);bpoke(i+0x343,106);bpoke(i+0x344,165);bpoke(i+0x345,85);bpoke(i+0x346,106);bpoke(i+0x361,169);bpoke(i+0x362,85);
bpoke(i+0x364,165);bpoke(i+0x365,86);bpoke(i+0x382,85);bpoke(i+0x383,85);bpoke(i+0x384,85);bpoke(i+0x385,90);
bpoke(i+0x3A2,165);bpoke(i+0x3A3,85);bpoke(i+0x3A4,85);


// Spider Star
i =  0xE000 + 6 + ((((k+3)/2)*3)*32);
bpoke(i+0x003,130);bpoke(i+0x006, 10);bpoke(i+0x023,160);bpoke(i+0x026, 42);
bpoke(i+0x043,168);bpoke(i+0x046, 42);bpoke(i+0x064, 42);bpoke(i+0x065,168);
bpoke(i+0x084, 42);bpoke(i+0x085,168);
bpoke(i+0x0C0,168);bpoke(i+0x0C1,  2);bpoke(i+0x0C4,138);bpoke(i+0x0C5,162);bpoke(i+0xc8, 128);     
bpoke(i+0x0E1,128);bpoke(i+0x0E2, 42); bpoke(i+0x0E4,138);bpoke(i+0x0E5,138);   bpoke(i+0x0E7,168);bpoke(i+0x0E8, 10);  
bpoke(i+0x103,  2);bpoke(i+0x104,162);bpoke(i+0x105, 42);bpoke(i+0x106,  2);
bpoke(i+0x124,  0); bpoke(i+0x125,  2); 
bpoke(i+0x144,160);bpoke(i+0x145, 42);       
bpoke(i+0x164,  0);bpoke(i+0x165,  2);        
bpoke(i+0x183,  2);bpoke(i+0x184,162); bpoke(i+0x185, 42);bpoke(i+0x186,2);
bpoke(i+0x1a1,128);bpoke(i+0x1a2, 42); bpoke(i+0x1a4,138);bpoke(i+0x1a5,138);   bpoke(i+0x1a7,168);bpoke(i+0x1a8, 10);
bpoke(i+0x1C0,168);bpoke(i+0x1C1,2);bpoke(i+0x1C4,138);bpoke(i+0x1C5,162);bpoke(i+0x1c8, 128); 
bpoke(i+0x204-64,138);bpoke(i+0x205-64,162);
bpoke(i+0x244-64, 42);bpoke(i+0x245-64,168);
bpoke(i+0x263-64,168);bpoke(i+0x265-64,168);bpoke(i+0x283-64,160);bpoke(i+0x286-64, 42);
bpoke(i+0x2A3-64,130);bpoke(i+0x2A6-64, 10);bpoke(i+0x2C3-64,138);bpoke(i+0x2C6-64,130);















		i =  0xE000 + g + (h*32);

//stard3
bpoke(i+0x002,166);bpoke(i+0x005,90);bpoke(i+0x022,166);bpoke(i+0x024,165);bpoke(i+0x025,106);bpoke(i+0x042,149);bpoke(i+0x043,85);
bpoke(i+0x044,85);bpoke(i+0x045,106);bpoke(i+0x062,149);bpoke(i+0x063,85);bpoke(i+0x064,85);bpoke(i+0x065,106);bpoke(i+0x082,85);bpoke(i+0x083,106);
bpoke(i+0x085,85);bpoke(i+0x0A2,90);bpoke(i+0x0A5,165);bpoke(i+0x0A6,85);bpoke(i+0x0A7,86);bpoke(i+0x0C2,90);bpoke(i+0x0C5,169);
bpoke(i+0x0C6,85);bpoke(i+0x0E0,165);bpoke(i+0x0E1,85);bpoke(i+0x0E2,106);bpoke(i+0x0E6,86);bpoke(i+0x100,169);bpoke(i+0x101,85);
bpoke(i+0x106,90);bpoke(i+0x121,150);bpoke(i+0x126,150);bpoke(i+0x141,165);bpoke(i+0x146,150);bpoke(i+0x161,165);bpoke(i+0x166,149);
bpoke(i+0x181,165);bpoke(i+0x186,85);bpoke(i+0x187,106);bpoke(i+0x1A1,149);bpoke(i+0x1A2,106);bpoke(i+0x1A6,106);bpoke(i+0x1A7,90);
bpoke(i+0x1C0,85);bpoke(i+0x1C1,85);bpoke(i+0x1C2,90);bpoke(i+0x1C5,165);bpoke(i+0x1C6,106);bpoke(i+0x1E2,149);bpoke(i+0x1E3,106);bpoke(i+0x1E5,85);
bpoke(i+0x202,169);bpoke(i+0x203,85);bpoke(i+0x204,85);bpoke(i+0x205,85);bpoke(i+0x222,169);bpoke(i+0x223,85);bpoke(i+0x224,169);bpoke(i+0x225,85);
bpoke(i+0x242,169);bpoke(i+0x243,86);bpoke(i+0x245,149);bpoke(i+0x262,169);bpoke(i+0x263,106);bpoke(i+0x265,165);bpoke(i+0x282,165);bpoke(i+0x285,165);





	memcpy (scrn, buffer1 , 2048);


		}

	}
}
