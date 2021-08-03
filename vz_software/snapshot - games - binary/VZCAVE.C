/* Dave. 12th - 15th, July, 2002 */
/* Run:	vzem -f vzcave.vz	 */
/*********************************/

/*	if((mem[0x68fe] & 0x10) == 0) {y=y+2;}			; up    Q 
		0x68fe  & 0x10     0    ;Q
	      	0x68fb  & 0x04	   0   	;shift 
		0x68ef  & 0x20	   0 	;M 
  		0x68ef  & 0x08     0 	;, 
      		0x68ef  & 0x10     0   	;space 
		0x68bf	& 0x10     0    ;P						
		0x68fd  & 0x02     0    ;S						
See page -6- of VZ200 tech manual					
*/


char 	*mem;
char    scr[32*64];
main(argc, argv)
int 	argc;
int 	*argv;
{	
	int a,b,c,i,j,x,x2,x3,y,y2,z, sc1,sc2,sc3,sc4;
	int lives,won,end,speed;

    	mode(1);
    	asm("di\n");
	z=0;speed=0;sc1=0;sc2=0;sc3=0;
	while(z==0){
	end=0;	a=17;	b=45;	y=31;	lives=3;  won=0; 
	setbase(0x7000);
	poke(0x7083,80);poke(0x7086,5);poke(0x7087,80);poke(0x7088,21);poke(0x7089,85);poke(0x708A,85);poke(0x708B,85);
	poke(0x708C,85);poke(0x708D,80);poke(0x7090,21);poke(0x7091,85);poke(0x7092,84);poke(0x70A2,5);poke(0x70A3,80);
	poke(0x70A6,85);poke(0x70A7,64);poke(0x70A8,85);poke(0x70A9,85);poke(0x70AA,85);poke(0x70AB,85);poke(0x70AC,85);
	poke(0x70AD,64);poke(0x70AF,21);poke(0x70B0,85);poke(0x70B1,85);poke(0x70B2,80);poke(0x70C2,21);poke(0x70C3,80);
	poke(0x70C5,1);poke(0x70C6,85);poke(0x70C7,1);poke(0x70C8,85);poke(0x70C9,85);poke(0x70CA,85);poke(0x70CB,85);
	poke(0x70CC,80);poke(0x70CE,1);poke(0x70CF,85);poke(0x70D0,85);poke(0x70D1,85);poke(0x70D2,80);poke(0x70E2,21);
	poke(0x70E3,80);poke(0x70E5,5);poke(0x70E6,80);poke(0x70EA,1);poke(0x70EB,84);poke(0x70EE,21);poke(0x70EF,85);
	poke(0x70F1,21);poke(0x70F2,64);poke(0x7102,21);poke(0x7103,80);poke(0x7105,85);poke(0x7106,64);poke(0x710A,21);
	poke(0x710D,1);poke(0x710E,85);poke(0x710F,64);poke(0x7113,1);poke(0x7114,85);poke(0x7115,84);poke(0x7117,85);
	poke(0x711A,84);poke(0x711C,21);poke(0x711D,85);poke(0x711E,64);poke(0x7122,21);poke(0x7123,80);poke(0x7124,1);
	poke(0x7125,84);poke(0x7129,5);poke(0x712A,80);poke(0x712D,21);poke(0x712E,84);poke(0x7133,85);poke(0x7134,85);
	poke(0x7135,85);poke(0x7136,1);poke(0x7137,85);poke(0x7139,5);poke(0x713A,84);poke(0x713B,5);poke(0x713C,85);
	poke(0x713D,85);poke(0x713E,80);poke(0x7142,21);poke(0x7143,80);poke(0x7144,5);poke(0x7145,80);poke(0x7149,85);
	poke(0x714D,85);poke(0x714E,64);poke(0x7152,21);poke(0x7153,85);poke(0x7154,85);poke(0x7155,84);poke(0x7156,1);
	poke(0x7157,85);poke(0x7159,85);poke(0x715A,64);poke(0x715B,85);poke(0x715C,85);poke(0x715D,85);poke(0x715E,80);
	poke(0x7162,21);poke(0x7163,80);poke(0x7164,85);poke(0x7165,64);poke(0x7168,5);poke(0x7169,64);poke(0x716C,1);
	poke(0x716D,85);poke(0x7172,85);poke(0x7173,64);poke(0x7174,1);poke(0x7175,84);poke(0x7177,85);poke(0x7178,69);
	poke(0x7179,85);poke(0x717A,1);poke(0x717B,85);poke(0x717D,21);poke(0x717E,64);poke(0x7182,21);poke(0x7183,81);
	poke(0x7184,84);poke(0x7187,1);poke(0x7188,84);poke(0x718C,5);poke(0x718D,84);poke(0x7190,21);poke(0x7191,1);
	poke(0x7192,84);poke(0x7194,5);poke(0x7195,80);poke(0x7197,85);poke(0x7198,85);poke(0x7199,80);poke(0x719A,5);
	poke(0x719B,80);poke(0x719C,85);poke(0x719D,84);poke(0x71A2,21);poke(0x71A3,85);poke(0x71A4,80);poke(0x71A7,21);
	poke(0x71A8,64);poke(0x71AC,5);poke(0x71AD,85);poke(0x71AF,5);poke(0x71B0,85);poke(0x71B1,5);poke(0x71B2,84);
	poke(0x71B4,21);poke(0x71B5,64);poke(0x71B7,85);poke(0x71B8,85);poke(0x71B9,64);poke(0x71BA,21);poke(0x71BB,85);
	poke(0x71BC,85);poke(0x71C2,21);poke(0x71C3,85);poke(0x71C6,1);poke(0x71C7,85);poke(0x71C8,85);poke(0x71C9,85);
	poke(0x71CA,85);poke(0x71CB,84);poke(0x71CC,5);poke(0x71CD,85);poke(0x71CE,85);poke(0x71CF,85);poke(0x71D0,84);
	poke(0x71D1,5);poke(0x71D2,85);poke(0x71D3,85);poke(0x71D4,85);poke(0x71D5,64);poke(0x71D7,85);poke(0x71D8,84);
	poke(0x71DA,21);poke(0x71DB,85);poke(0x71DC,85);poke(0x71DD,85);poke(0x71DE,64);poke(0x71E2,21);poke(0x71E3,84);
	poke(0x71E6,21);poke(0x71E7,85);poke(0x71E8,85);poke(0x71E9,85);poke(0x71EA,85);poke(0x71EB,84);poke(0x71EC,5);
	poke(0x71ED,85);poke(0x71EE,85);poke(0x71EF,85);poke(0x71F1,5);poke(0x71F2,85);poke(0x71F3,85);poke(0x71F4,85);
	poke(0x71F5,64);poke(0x71F7,85);poke(0x71F8,80);poke(0x71FA,5);poke(0x71FB,85);poke(0x71FC,85);poke(0x71FD,85);
	poke(0x7202,5);poke(0x7203,64);poke(0x7206,21);poke(0x7207,85);poke(0x7208,85);poke(0x7209,85);poke(0x720A,85);
	poke(0x720B,80);poke(0x720D,85);poke(0x720E,85);poke(0x7212,85);poke(0x7213,84);poke(0x7214,21);poke(0x7217,21);
	poke(0x721A,1);poke(0x721B,85);poke(0x721C,85);poke(0x721D,64);poke(0x75EA,1);poke(0x75F1,16);poke(0x75F7,21);
	poke(0x75F8,1);poke(0x75F9,84);poke(0x760A,4);poke(0x7611,64);poke(0x7616,1);poke(0x7617,64);poke(0x7618,4);
	poke(0x762A,4);poke(0x7631,64);poke(0x7636,1);poke(0x7638,4);poke(0x7643,21);poke(0x7645,80);poke(0x7646,85);
	poke(0x7647,80);poke(0x7648,21);poke(0x764A,5);poke(0x764B,80);poke(0x764C,5);poke(0x764D,5);poke(0x764E,80);
	poke(0x764F,84);poke(0x7650,21);poke(0x7651,64);poke(0x7652,1);poke(0x7653,81);poke(0x7654,84);poke(0x7656,1);
	poke(0x7657,84);poke(0x7658,5);poke(0x7659,80);poke(0x765A,80);poke(0x765B,5);poke(0x765C,4);poke(0x765D,20);
	poke(0x765E,84);poke(0x7663,81);poke(0x7664,5);poke(0x7665,17);poke(0x7666,68);poke(0x7667,17);poke(0x7668,85);
	poke(0x766A,16);poke(0x766B,16);poke(0x766C,81);poke(0x766D,16);poke(0x766E,5);poke(0x766F,85);poke(0x7670,65);
	poke(0x7672,5);poke(0x7673,17);poke(0x7674,68);poke(0x7677,4);poke(0x7678,16);poke(0x7679,1);poke(0x767B,81);
	poke(0x767C,4);poke(0x767D,21);poke(0x767E,84);poke(0x7683,65);poke(0x7684,4);poke(0x7685,17);poke(0x7686,4);
	poke(0x7687,17);poke(0x7688,64);poke(0x768A,16);poke(0x768B,16);poke(0x768C,65);poke(0x768D,5);poke(0x768E,5);
	poke(0x768F,1);poke(0x7690,1);poke(0x7692,4);poke(0x7693,17);poke(0x7694,4);poke(0x7697,4);poke(0x7698,16);
	poke(0x7699,4);poke(0x769B,65);poke(0x769C,4);poke(0x769D,69);poke(0x76A3,69);poke(0x76A4,4);poke(0x76A5,20);
	poke(0x76A6,20);poke(0x76A7,17);poke(0x76A8,5);poke(0x76AA,16);poke(0x76AB,64);poke(0x76AC,65);poke(0x76AD,1);
	poke(0x76AE,68);poke(0x76AF,21);poke(0x76B0,5);poke(0x76B2,4);poke(0x76B3,65);poke(0x76B4,4);poke(0x76B7,16);
	poke(0x76B8,64);poke(0x76B9,4);poke(0x76BA,64);poke(0x76BB,65);poke(0x76BC,5);poke(0x76BD,4);poke(0x76BE,20);
	poke(0x76C3,84);poke(0x76C4,5);poke(0x76C5,68);poke(0x76C6,16);poke(0x76C7,65);poke(0x76C8,84);poke(0x76CA,85);
	poke(0x76CC,84);poke(0x76CD,85);poke(0x76CE,5);poke(0x76CF,81);poke(0x76D0,84);poke(0x76D2,5);poke(0x76D3,4);
	poke(0x76D4,16);poke(0x76D6,21);poke(0x76D7,64);poke(0x76D8,64);poke(0x76D9,5);poke(0x76DA,64);poke(0x76DB,84);
	poke(0x76DC,4);poke(0x76DD,5);poke(0x76DE,80);poke(0x76E3,4);poke(0x7703,16);poke(0x7722,5);poke(0x7723,64);

   	draw_string(0, 20, 2, "CONTROLS:");
   	draw_string(0, 26, 2, "Q   = UP");
   	draw_string(0, 32, 2, "ESC = EXIT");
   	draw_string(80, 20, 2, "SPEED:");
	score((0x7000+29)+(32*20),speed);
   	draw_string(85, 26, 2, "0=Fast");
   	draw_string(85, 32, 2, "5=Slow");
   	draw_string(12, 40, 2, "PRESS <S> TO START");
   	draw_string(5, 59, 3, "Last score:");
	score((0x7000+20)+(32*59),sc1);
	score((0x7000+19)+(32*59),sc2);
	score((0x7000+18)+(32*59),sc3);
   	draw_string(110, 59, 3, "/DM");
	j=0;   sc1=0;	sc2=0;	sc3=0;
      	do{	score((0x7000+29)+(32*20),speed);
		draw_string(54, 40, 2, "S");
		for(i=0;i<500;i++){
			if((mem[0x68fd] & 0x2) == 0) {j=1;break;}
			if(inch()=='0') {speed=0;}
			if(inch()=='1') {speed=1;}
			if(inch()=='2') {speed=2;}
			if(inch()=='3') {speed=3;}
			if(inch()=='4') {speed=4;}
			if(inch()=='5') {speed=5;}

/*			if((mem[0x68df] & 0x10)== 0) {speed=0;}
			if((mem[0x68f7] & 0x10)== 0) {speed=1;}
			if((mem[0x68f7] & 0x2) == 0) {speed=2;}
			if((mem[0x68f7] & 0x8) == 0) {speed=3;}
			if((mem[0x68f7] & 0x20)== 0) {speed=4;}
			if((mem[0x68f7] & 0x00)== 0) {speed=5;}  */   }

		score((0x7000+29)+(32*20),speed);
		draw_string(54, 40, 0, "S");
		for(i=0;i<500;i++){
			if((mem[0x68fd] & 0x2) == 0) {j=1;break;}
			if(inch()=='0') {speed=0;}
			if(inch()=='1') {speed=1;}
			if(inch()=='2') {speed=2;}
			if(inch()=='3') {speed=3;}
			if(inch()=='4') {speed=4;}
			if(inch()=='5') {speed=5;}
			}
	} while (j==0);
	memset(scr,0,2048);
	memset(0x7000,0,2048);
	setbase(0x7000);
   	draw_string(6, 59, 1, "Score: ");
   	draw_string(74, 59, 1, "Lives: ");
	setbase(scr);
	while((end==0)||(won==0)){
		for(i=-1;i<(speed*50);i++){;}
		c=rand(6);
		if (c==1) {a++;b++;}
		if (c==2) {a--;b--;}
		if (a<5) {a=5;b=(43-15);}
		if (b>57) {a=34;b=57;}	

		for(i=0;i<a;i++){mem[(scr+31)+(i*32)]=170;}
		for(i=b;i<59;i++){mem[(scr+31)+(i*32)]=170;}
		mem[(scr+31)+(a*32)]=255;
		mem[(scr+31)+(b*32)]=255;

		if ((mem[0x68fe] & 0x10) == 0) {y=y-2;}						/* Q = up */
		y++;
		x++;
/*		x2++;			    */
/*		if(x2>100){a++;b--;x2=0;}   */
/*		if(c==3){a--;b++;}          */
/*		if((b-a)<15){a--;b++;}	    */							/* minimum distance between walls */
		if(x>40) {sc1++;x=0;}								/* score                  */
		if(sc1>9){sc2++;sc1=0;}
		if(sc2>9){sc3++;sc2=0;}
		if(sc3>9){sc4++;sc3=0;}
		if(sc4==1){won=1;}								/* if score=1000 then won! */
		if(c==3){j=rand(b-a);mem[(scr+31)+32+((a*32)+(j*32))]=170;}			/* blue blocks - in tunnel */
		if(c==4){mem[(scr+31)+(rand(a))*32]=255;}					/* red blocks - top	   */
		if(c==5){mem[((scr+31)+(b*32))+((rand(b-a))*32)]=255;}				/* red blocks - bottom     */
		mem[(scr+6)+(y*32)]=85;							/* draw ship               */
 		for (i=0;i<64;i++){mem[scr+(i*32)]=0;} 					/* stops overscroll        */
		score((0x7000+12)+(32*59),sc1);
		score((0x7000+11)+(32*59),sc2);
		score((0x7000+10)+(32*59),sc3);
		score((0x7000+28)+(32*59),lives);
		memcpy(0x7000,scr+1,2048-32*5);
		memcpy(scr,0x7000,2048-32*5);
		if((scr[7+(y*32)]!=0)||(scr[7+((y+1)*32)]!=0)||(scr[7+((y-1)*32)]!=0)){		/* blow up detection */
			lives--;
			score((0x7000+28)+(32*59),lives);
			setbase(0x7000);
			for(i=0;i<100;i++){							/* and blow up */
				for(j=0;j<4;j++){
					line(30,y,rand(45)+10,rand(50)+(y-25),j);}}
			for(i=0;i<6000;i++){;}
			memset(scr,0,2048); 
			setbase(0x7000);
			memset(0x7000+(58*32),0,6*32);
		   	draw_string(6, 59, 1, "Score: ");
		   	draw_string(74, 59, 1, "Lives: ");
			setbase(scr);
			y=31;
		}
		if(lives==0){end=1;break;}
	}
	a=15;	b=48;
	for(x=0;x<100;x++){
		setbase(scr);
		c=rand(6);
		if (c==1) {a++;b++;}
		if (c==2) {a--;b--;}
		if (a<5) {a=5;b=(43-15);}
		if (b>57) {a=34;b=57;}	
		for(i=0;i<a;i++){mem[(scr+31)+(i*32)]=170;}
		for(i=b;i<64;i++){mem[(scr+31)+(i*32)]=170;}
		mem[(scr+31)+(a*32)]=255;
		mem[(scr+31)+(b*32)]=255;
		if(c==3){j=rand(b-a);mem[(scr+31)+32+((a*32)+(j*32))]=170;}			/* blue blocks - in tunnel */
		if(c==4){mem[(scr+31)+(rand(a))*32]=255;}					/* red blocks - top	   */
		if(c==5){mem[((scr+31)+(b*32))+((rand(b-a))*32)]=255;}				/* red blocks - bottom     */
 		for (i=0;i<64;i++){mem[scr+(i*32)]=0;} 					/* stops overscroll        */
		memcpy(0xE000,scr+1,2048);
		memcpy(scr,0xE000,2048);
		setbase(0xE000);
		draw_string(0,  20, 1, "YOU CRASHED.BIG TIME!");
		if(won==1)  {draw_string(0,  20, 1, "YOU WIN . BIG TIME!  ");}
		draw_string(20, 40, 1, "YOUR SCORE: ");
		score((0xE000+23)+(32*40),sc1);
		score((0xE000+22)+(32*40),sc2);
		score((0xE000+21)+(32*40),sc3);
		memcpy(0x7000,0xE000,2048);
	}
	won=0;end=0;
	memset(scr,0,2048); 
	memset(0xE000,0,2048); 
	memset(0x7000,0,2048); 

}
}

 
draw_string(x,y,color,src)
int x,y,color;
char *src;
{	while (*src)	{
	   char_draw(x,y,color,*src);
	   x += 6;
           src++;	}}

