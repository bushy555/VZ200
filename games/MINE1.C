/*                                                                           */
/*                                                                           */
/*    Minefield.                                                             */
/*    By dave. Started around 01 March 04                                    */
/*    Original idea from Waulok's father years ago.                          */
/*                                                                           */
/*                                                                           */

 
#define scrsize	2048
#define	video	0xE800

char 	*mem;
char    scr[32*64];
main(argc, argv)
int 	argc;
int 	*argv;
{	
	int a,b,c,d,e,f,g,h,i,j,k,l,x,y,z;
	int lives, die, die2, rot, rot2;
	z=1;
    y=5;
	x=5;
	c=2;
    	mode(1);
	setbase(scr);
    	asm("di\n");
				/* Intro screen */
	memset(0xE800,170,2048);

poke(0xE804,154);poke(0xE823,169);poke(0xE824,85);poke(0xE838,234);poke(0xE83C,171);poke(0xE83D,255);
poke(0xE843,150);poke(0xE844,154);poke(0xE845,86);poke(0xE857,175);poke(0xE85C,255);poke(0xE85D,255);
poke(0xE85E,234);poke(0xE862,165);poke(0xE863,106);poke(0xE864,154);poke(0xE865,165);poke(0xE866,106);
poke(0xE876,171);poke(0xE877,250);poke(0xE87B,175);poke(0xE87C,255);poke(0xE87D,255);poke(0xE87E,254);
poke(0xE882,150);poke(0xE886,90);poke(0xE896,190);poke(0xE89B,191);poke(0xE89C,254);poke(0xE89E,254);
poke(0xE8A2,90);poke(0xE8A6,150);poke(0xE8B5,171);poke(0xE8B6,234);poke(0xE8BB,175);poke(0xE8BC,250);
poke(0xE8BE,191);poke(0xE8C1,169);poke(0xE8C2,106);poke(0xE8C6,165);poke(0xE8D5,254);poke(0xE8D9,175);
poke(0xE8DA,234);poke(0xE8DC,250);poke(0xE8DE,175);poke(0xE8E1,169);poke(0xE8E6,169);poke(0xE8E7,106);
poke(0xE8F4,175);poke(0xE8F8,171);poke(0xE8F9,255);poke(0xE8FA,234);poke(0xE8FC,254);poke(0xE8FE,175);
poke(0xE8FF,234);poke(0xE901,169);poke(0xE907,106);poke(0xE913,171);poke(0xE914,250);poke(0xE918,191);
poke(0xE919,255);poke(0xE91A,234);poke(0xE91C,254);poke(0xE91E,171);poke(0xE91F,234);poke(0xE921,166);
poke(0xE924,154);poke(0xE927,106);poke(0xE933,190);poke(0xE938,191);poke(0xE939,254);poke(0xE93C,191);
poke(0xE93E,171);poke(0xE93F,234);poke(0xE941,166);poke(0xE944,154);poke(0xE947,154);poke(0xE952,175);
poke(0xE953,234);poke(0xE957,186);poke(0xE958,191);poke(0xE959,254);poke(0xE95C,191);poke(0xE95E,171);
poke(0xE95F,250);poke(0xE961,154);poke(0xE967,154);poke(0xE972,250);poke(0xE976,175);poke(0xE977,250);
poke(0xE979,191);poke(0xE97C,175);poke(0xE97E,171);poke(0xE97F,250);poke(0xE981,154);poke(0xE987,154);
poke(0xE991,191);poke(0xE996,255);poke(0xE997,254);poke(0xE999,191);poke(0xE99C,175);poke(0xE99D,234);
poke(0xE99E,171);poke(0xE99F,250);poke(0xE9A1,90);poke(0xE9A4,154);poke(0xE9A7,150);poke(0xE9B0,171);
poke(0xE9B1,234);poke(0xE9B5,191);poke(0xE9B6,255);poke(0xE9B7,254);poke(0xE9B9,175);poke(0xE9BB,171);
poke(0xE9BC,239);poke(0xE9BD,234);poke(0xE9BE,175);poke(0xE9BF,234);poke(0xE9C0,165);poke(0xE9C1,86);
poke(0xE9C3,90);poke(0xE9C4,86);poke(0xE9C5,150);poke(0xE9C6,169);poke(0xE9C7,85);poke(0xE9D0,190);
poke(0xE9D4,171);poke(0xE9D5,255);poke(0xE9D6,254);poke(0xE9D7,191);poke(0xE9D9,175);poke(0xE9DA,234);
poke(0xE9DB,171);poke(0xE9DC,235);poke(0xE9DD,250);poke(0xE9DE,191);poke(0xE9DF,234);poke(0xE9E1,154);
poke(0xE9E4,154);poke(0xE9E7,150);poke(0xE9EF,175);poke(0xE9F0,234);poke(0xE9F4,175);poke(0xE9F5,255);
poke(0xE9F7,191);poke(0xE9F9,175);poke(0xE9FA,234);poke(0xE9FB,171);poke(0xE9FC,251);poke(0xE9FD,255);
poke(0xE9FE,255);poke(0xEA01,154);poke(0xEA07,154);poke(0xEA0F,250);poke(0xEA13,191);poke(0xEA14,235);
poke(0xEA15,254);poke(0xEA16,171);poke(0xEA17,174);poke(0xEA19,171);poke(0xEA1A,250);poke(0xEA1B,171);
poke(0xEA1C,250);poke(0xEA1D,255);poke(0xEA1E,254);poke(0xEA21,166);poke(0xEA27,154);poke(0xEA2E,191);
poke(0xEA32,171);poke(0xEA33,255);poke(0xEA34,234);poke(0xEA35,191);poke(0xEA36,175);poke(0xEA37,234);
poke(0xEA39,171);poke(0xEA3A,250);poke(0xEA3C,251);poke(0xEA3D,255);poke(0xEA3E,234);poke(0xEA41,166);
poke(0xEA44,154);poke(0xEA47,90);poke(0xEA4D,171);poke(0xEA4E,234);poke(0xEA52,255);poke(0xEA53,255);
poke(0xEA55,175);poke(0xEA56,171);poke(0xEA57,234);poke(0xEA5A,250);poke(0xEA5B,175);poke(0xEA5C,255);
poke(0xEA5D,254);poke(0xEA61,169);poke(0xEA64,154);poke(0xEA67,106);poke(0xEA6D,254);poke(0xEA71,171);
poke(0xEA72,255);poke(0xEA73,250);poke(0xEA75,175);poke(0xEA76,239);poke(0xEA77,250);poke(0xEA7A,254);
poke(0xEA7B,255);poke(0xEA7C,254);poke(0xEA81,169);poke(0xEA86,169);poke(0xEA87,106);poke(0xEA8C,175);
poke(0xEA91,171);poke(0xEA92,255);poke(0xEA93,250);poke(0xEA95,175);poke(0xEA96,255);poke(0xEA97,250);
poke(0xEA98,186);poke(0xEA9A,255);poke(0xEA9B,255);poke(0xEA9C,234);poke(0xEAA1,169);poke(0xEAA2,106);
poke(0xEAA6,165);poke(0xEAAC,250);poke(0xEAB0,171);poke(0xEAB1,250);poke(0xEAB2,234);poke(0xEAB3,254);
poke(0xEAB5,171);poke(0xEAB6,255);poke(0xEAB7,250);poke(0xEAB8,254);poke(0xEAB9,171);poke(0xEABA,255);
poke(0xEABB,254);poke(0xEAC2,90);poke(0xEAC4,154);poke(0xEAC6,150);poke(0xEACB,191);poke(0xEAD0,255);
poke(0xEAD1,250);poke(0xEAD3,254);poke(0xEAD5,171);poke(0xEAD6,250);poke(0xEAD7,254);poke(0xEAD8,190);
poke(0xEAD9,175);poke(0xEADA,255);poke(0xEAE2,150);poke(0xEAE4,154);poke(0xEAE6,90);poke(0xEAEA,171);
poke(0xEAEB,234);poke(0xEAEF,175);poke(0xEAF0,255);poke(0xEAF1,250);poke(0xEAF3,190);poke(0xEAF6,250);
poke(0xEAF8,191);poke(0xEAF9,175);poke(0xEAFA,250);poke(0xEAFF,234);poke(0xEB02,165);poke(0xEB03,106);
poke(0xEB04,154);poke(0xEB05,165);poke(0xEB06,106);poke(0xEB0A,254);poke(0xEB0E,171);poke(0xEB0F,255);
poke(0xEB10,254);poke(0xEB11,254);poke(0xEB13,191);poke(0xEB16,254);poke(0xEB18,255);poke(0xEB1E,175);
poke(0xEB23,149);poke(0xEB24,85);poke(0xEB25,86);poke(0xEB29,175);poke(0xEB2E,191);poke(0xEB2F,255);
poke(0xEB30,234);poke(0xEB31,254);poke(0xEB33,191);poke(0xEB36,254);poke(0xEB37,175);poke(0xEB38,255);
poke(0xEB39,234);poke(0xEB3D,171);poke(0xEB3E,250);poke(0xEB43,169);poke(0xEB44,85);poke(0xEB48,171);
poke(0xEB49,250);poke(0xEB4D,186);poke(0xEB4E,191);poke(0xEB4F,250);poke(0xEB51,190);poke(0xEB53,175);
poke(0xEB54,234);poke(0xEB56,191);poke(0xEB57,255);poke(0xEB58,254);poke(0xEB5D,190);poke(0xEB64,154);
poke(0xEB68,190);poke(0xEB6C,175);poke(0xEB6D,250);poke(0xEB6E,175);poke(0xEB6F,250);poke(0xEB70,174);
poke(0xEB73,175);poke(0xEB74,234);poke(0xEB76,191);poke(0xEB77,255);poke(0xEB78,234);poke(0xEB7C,175);
poke(0xEB7D,234);poke(0xEB84,154);poke(0xEB87,171);poke(0xEB88,234);poke(0xEB8C,255);poke(0xEB8D,254);
poke(0xEB8F,254);poke(0xEB90,191);poke(0xEB93,171);poke(0xEB94,234);poke(0xEB96,255);poke(0xEB97,250);
poke(0xEB9C,250);poke(0xEBA7,254);poke(0xEBAB,191);poke(0xEBAC,255);poke(0xEBAD,254);poke(0xEBAF,190);
poke(0xEBB0,175);poke(0xEBB3,171);poke(0xEBB4,251);poke(0xEBB5,250);poke(0xEBB6,255);poke(0xEBBB,191);
poke(0xEBC6,175);poke(0xEBCA,171);poke(0xEBCB,255);poke(0xEBCC,254);poke(0xEBCD,191);poke(0xEBCF,191);
poke(0xEBD0,255);poke(0xEBD1,234);poke(0xEBD3,171);poke(0xEBD4,255);poke(0xEBD5,254);poke(0xEBDA,171);
poke(0xEBDB,234);poke(0xEBE5,171);poke(0xEBE6,250);poke(0xEBEA,175);poke(0xEBEB,255);poke(0xEBED,191);
poke(0xEBEF,191);poke(0xEBF0,255);poke(0xEBF1,234);poke(0xEBF3,175);poke(0xEBF4,255);poke(0xEBF5,250);
poke(0xEBFA,190);poke(0xEC05,190);poke(0xEC0A,255);poke(0xEC0B,254);poke(0xEC0C,171);poke(0xEC0D,174);
poke(0xEC0F,175);poke(0xEC10,251);poke(0xEC11,234);poke(0xEC13,255);poke(0xEC14,255);poke(0xEC19,175);
poke(0xEC1A,234);poke(0xEC24,175);poke(0xEC25,234);poke(0xEC29,191);poke(0xEC2A,254);poke(0xEC2B,191);
poke(0xEC2C,175);poke(0xEC2D,234);poke(0xEC2F,175);poke(0xEC30,235);poke(0xEC31,234);poke(0xEC33,255);
poke(0xEC34,234);poke(0xEC39,250);poke(0xEC44,250);poke(0xEC49,191);poke(0xEC4A,250);poke(0xEC4B,175);
poke(0xEC4C,171);poke(0xEC4D,234);poke(0xEC4F,171);poke(0xEC50,234);poke(0xEC53,190);poke(0xEC58,191);
poke(0xEC63,191);poke(0xEC68,234);poke(0xEC69,191);poke(0xEC6A,250);poke(0xEC6B,175);poke(0xEC6C,239);
poke(0xEC6D,250);poke(0xEC6F,171);poke(0xEC70,250);poke(0xEC77,171);poke(0xEC78,234);poke(0xEC82,171);
poke(0xEC83,234);poke(0xEC87,175);poke(0xEC88,250);poke(0xEC8A,254);poke(0xEC8B,175);poke(0xEC8C,255);
poke(0xEC8D,250);poke(0xEC8E,186);poke(0xEC8F,171);poke(0xEC90,250);poke(0xEC91,250);poke(0xEC97,254);
poke(0xECA2,190);poke(0xECA7,191);poke(0xECA8,254);poke(0xECAA,254);poke(0xECAB,171);poke(0xECAC,255);
poke(0xECAD,250);poke(0xECAE,254);poke(0xECB0,255);poke(0xECB1,254);poke(0xECB6,175);poke(0xECC1,175);
poke(0xECC2,234);poke(0xECC5,171);poke(0xECC6,254);poke(0xECC7,191);poke(0xECC8,255);poke(0xECCA,190);
poke(0xECCB,171);poke(0xECCC,250);poke(0xECCD,254);poke(0xECCE,190);poke(0xECCF,171);poke(0xECD0,255);
poke(0xECD1,250);poke(0xECD5,171);poke(0xECD6,250);poke(0xECE1,250);poke(0xECE5,191);poke(0xECE6,254);
poke(0xECE8,255);poke(0xECE9,250);poke(0xECEA,191);poke(0xECEC,250);poke(0xECEE,191);poke(0xECEF,175);
poke(0xECF0,255);poke(0xECF5,190);poke(0xED00,175);poke(0xED04,175);poke(0xED05,255);poke(0xED06,250);
poke(0xED08,255);poke(0xED09,254);poke(0xED0A,175);poke(0xED0C,254);poke(0xED0E,255);poke(0xED0F,171);
poke(0xED10,250);poke(0xED14,175);poke(0xED15,234);poke(0xED24,191);poke(0xED25,255);poke(0xED28,254);
poke(0xED29,255);poke(0xED2A,175);poke(0xED2B,234);poke(0xED2C,254);poke(0xED2D,175);poke(0xED2E,255);
poke(0xED2F,234);poke(0xED34,250);poke(0xED43,191);poke(0xED44,191);poke(0xED45,255);poke(0xED48,190);
poke(0xED49,191);poke(0xED4A,239);poke(0xED4B,234);poke(0xED4C,191);poke(0xED4D,255);poke(0xED4E,254);
poke(0xED53,191);poke(0xED63,255);poke(0xED64,174);poke(0xED65,175);poke(0xED66,234);poke(0xED68,191);
poke(0xED69,175);poke(0xED6A,255);poke(0xED6B,234);poke(0xED6C,191);poke(0xED6D,255);poke(0xED6E,234);
poke(0xED72,171);poke(0xED73,234);poke(0xED83,255);poke(0xED85,175);poke(0xED86,234);poke(0xED88,175);
poke(0xED8A,255);poke(0xED8B,250);poke(0xED8C,255);poke(0xED8D,250);poke(0xED92,190);poke(0xEDA1,186);
poke(0xEDA3,255);poke(0xEDA5,171);poke(0xEDA6,234);poke(0xEDA8,175);poke(0xEDA9,234);poke(0xEDAA,191);
poke(0xEDAB,250);poke(0xEDAC,255);poke(0xEDB1,175);poke(0xEDB2,234);poke(0xEDC0,171);poke(0xEDC1,250);
poke(0xEDC3,255);poke(0xEDC5,171);poke(0xEDC6,250);poke(0xEDC8,175);poke(0xEDC9,234);poke(0xEDCA,175);
poke(0xEDCB,254);poke(0xEDD1,250);poke(0xEDE0,175);poke(0xEDE1,254);poke(0xEDE3,255);poke(0xEDE4,234);
poke(0xEDE5,171);poke(0xEDE6,250);poke(0xEDE8,171);poke(0xEDE9,234);poke(0xEDEA,171);poke(0xEDEB,254);
poke(0xEDF0,191);poke(0xEE00,175);poke(0xEE01,255);poke(0xEE03,251);poke(0xEE04,234);poke(0xEE06,254);
poke(0xEE08,171);poke(0xEE09,255);poke(0xEE0B,250);poke(0xEE0F,171);poke(0xEE10,234);poke(0xEE21,255);
poke(0xEE22,234);poke(0xEE23,251);poke(0xEE24,250);poke(0xEE26,254);poke(0xEE29,255);poke(0xEE2A,234);
poke(0xEE2F,254);poke(0xEE41,255);poke(0xEE42,250);poke(0xEE43,251);poke(0xEE44,250);poke(0xEE46,190);
poke(0xEE48,171);poke(0xEE49,255);poke(0xEE4A,234);poke(0xEE4E,175);poke(0xEE61,191);poke(0xEE62,254);
poke(0xEE63,250);poke(0xEE64,250);poke(0xEE66,191);poke(0xEE67,191);poke(0xEE68,171);poke(0xEE69,254);
poke(0xEE6D,171);poke(0xEE6E,250);poke(0xEE81,191);poke(0xEE82,255);poke(0xEE83,250);poke(0xEE84,254);
poke(0xEE86,191);poke(0xEE87,255);poke(0xEE88,234);poke(0xEE8D,190);poke(0xEEA1,191);poke(0xEEA2,191);
poke(0xEEA3,250);poke(0xEEA4,190);poke(0xEEA6,255);poke(0xEEA7,255);poke(0xEEAC,175);poke(0xEEAD,234);
poke(0xEEC1,175);poke(0xEEC2,175);poke(0xEEC3,250);poke(0xEEC4,191);poke(0xEEC5,175);poke(0xEEC6,255);
poke(0xEEC7,250);poke(0xEECC,250);poke(0xEEE1,175);poke(0xEEE2,235);poke(0xEEE3,250);poke(0xEEE4,191);
poke(0xEEE5,255);poke(0xEEE6,254);poke(0xEEEB,191);poke(0xEF01,171);poke(0xEF02,234);poke(0xEF03,234);
poke(0xEF04,255);poke(0xEF05,251);poke(0xEF06,234);poke(0xEF0A,171);poke(0xEF0B,234);poke(0xEF21,171);
poke(0xEF22,250);poke(0xEF24,255);poke(0xEF25,234);poke(0xEF2A,190);poke(0xEF41,171);poke(0xEF42,251);
poke(0xEF44,254);poke(0xEF49,175);poke(0xEF4A,234);poke(0xEF62,255);poke(0xEF63,234);poke(0xEF69,250);
poke(0xEF81,171);poke(0xEF82,255);poke(0xEF83,234);poke(0xEF88,191);poke(0xEFA1,171);poke(0xEFA2,255);
poke(0xEFA7,171);poke(0xEFA8,234);poke(0xEFC2,234);poke(0xEFC7,190);
/*
----
@Fill proc near                ;From Virtual to VGA...
        push    06000h                ;From top to bottom with "fill" feature
        pop     ds
        mov     bp, 63680
@@_L0:  mov     bx, bp
        mov     si, bx
        mov     dx, si
@@_L1:  sub     bx, 320         ; top add gives
        mov     di, bx          ; bottom add gives
        mov     cx, 80
        rep     movsd
        mov     si, dx
        cmp     bx, 0;64320;4160
        je      @@_L2
        mov     di, bx          ; bottom add gives
        mov     cx, 80
        rep     movsd
        mov     si, dx
        cmp     bx, 0;64320;4160
        jne     @@_L1
@@_L2:  sub     bp, 320;640;160
        cmp     bp, 0;64000
        jne     @@_L0
        xor     ax, ax
        int     16h
        jmp     @RUN
@Fill endp

---
  */
	for(i=0;i<31;i++){
			memcpy(0x7000                 , 0xF000+32           , 1024-(i*32));  
			memcpy(0x7000+0x0400-(i*32)   , 0xE800+0x0400-(i*32), 32);
			memcpy(0x7000+0x0400+32       , 0xF000+0x0400       , 1024-(i*32));
			memcpy(0x7000+0x0400+(i*32)   , 0xE800+0x0400+(i*32), 32);
			memcpy(0xF000                 , 0x7000              , 2048);
	}


	draw_string(1,37,0,"Hit <s> when ready");
	while ((mem[0x68fd] & 0x2) > 0) {};

	memset(scr,0,2048);

	for(j=0;j<15;j++){plot(rand(128), rand(63), 2);}

	line(0,0,0,63,1);
	line(127,0,127,63,1);

	plot(10,5,3);plot(11,5,3);				/* tank 1 */
	plot(9,6,3); plot(10,6,2);plot(11,6,3);plot(12,6,3);
	plot(9,7,3); plot(10,7,3);plot(11,7,2);plot(12,7,3);
	plot(10,8,3);plot(11,8,3);plot(12,8,2);plot(13,8,2);

	line(20,5,20,7,3);					/* tank #2 */
	line(21,5,21,8,2);
	line(22,5,22,7,3);

	line(65,5,65,7,3);					/* tank #3 */
	line(66,5,66,8,2);
	line(67,5,67,7,3);

	plot(110,5,3);plot(111,5,3);				/* tank 4 */
	plot(109,6,3);plot(110,6,3);plot(111,6,2);plot(112,6,3);
	plot(109,7,3);plot(110,7,2);plot(111,7,3);plot(112,7,3);
	plot(109,8,2);plot(110,8,3);plot(111,8,3);plot(108,9,2);



	memcpy(0x7000,scr,2048);

	while(z==1){
        if ((mem[0x68fe] & 0x10) == 0) {a=-1;b=0;x=x+b;y=y+a;c=1;}      /* up    Q */
        if ((mem[0x68fb] & 0x04) == 0) {a=+1;b=0;x=x+b;y=y+a;c=2;}      /* down  shift */
        if ((mem[0x68ef] & 0x20) == 0) {b=-1;a=0;x=x+b;y=y+a;c=3;}      /* left  M */
        if ((mem[0x68ef] & 0x08) == 0) {b=+1;a=0;x=x+b;y=y+a;c=4;}      /* right , */
       /* x=x+b; */
       /* y=y+a; */
		if(x<3)   {x==3;}
		if(x>124) {x==124;}
		if(y<3)   {y==3;}
        if(y>60)  {y==60;}
                	
        if (c==1) {
               line(x-2,y-2,x+2,y-2,0);line(x-2,y+2,x+2,y+2,0);
               line(x-2,y-2,x-2,y+2,0);line(x+2,y-2,x+2,y+2,0);
               line(x-2,y+3,x+2,y+3,0);
               plot(x-1,y-1,2);plot(x-1,y,2);plot(x-1,y+1,2);
			   plot(x,y+1,3);plot(x,y,3);plot(x,y-1,3);plot(x,y-2,3);
			   plot(x+1,y-1,2);plot(x+1,y,2);plot(x+1,y+1,2);}

        if (c==2) {
               line(x-2,y-2,x+2,y-2,0);line(x-2,y+2,x+2,y+2,0);
               line(x-2,y-2,x-2,y+2,0);line(x+2,y-2,x+2,y+2,0);
               line(x-2,y-3,x+2,y-3,0);
               plot(x-1,y-1,2);plot(x-1,y,2);plot(x-1,y+1,2);
			   plot(x,y+1,3);plot(x,y,3);plot(x,y-1,3);plot(x,y+2,3);
			   plot(x+1,y-1,2);plot(x+1,y,2);plot(x+1,y+1,2);}

        if (c==3) {
               line(x-2,y-2,x+2,y-2,0);line(x-2,y+2,x+2,y+2,0);
               line(x-2,y-2,x-2,y+2,0);line(x+2,y-2,x+2,y+2,0);
               line(x+3,y-2,x+3,y+2,0);
               plot(x-1,y-1,2);plot(x,y-1,2);plot(x+1,y-1,2);
               plot(x-1,y,3);plot(x,y,3);plot(x+1,y,3);plot(x-2,y,3);
			   plot(x-1,y+1,2);plot(x,y+1,2);plot(x+1,y+1,2);}

        if (c==4) {
               line(x-2,y-2,x+2,y-2,0);line(x-2,y+2,x+2,y+2,0);
               line(x-2,y-2,x-2,y+2,0);line(x+2,y-2,x+2,y+2,0);
               line(x-3,y-2,x-3,y+2,0);
               plot(x-1,y-1,2);plot(x,y-1,2);plot(x+1,y-1,2);
               plot(x-1,y,3);plot(x,y,3);plot(x+1,y,3);plot(x+2,y,3);
			   plot(x-1,y+1,2);plot(x,y+1,2);plot(x+1,y+1,2);}


        memcpy(0x7000,scr,2048);
	}
}




 
draw_string(x,y,color,src)
int x,y,color;
char *src;
{	while (*src)	{
	   char_draw(x,y,color,*src);
	   x += 6;
           src++;	}}

