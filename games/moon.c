/* Dave. 12th - 15th, July, 2002 */
/* Run:	vzem -f vzcave.vz	 */
/*                               */
/*                               */
/*                               */
/*                               */
/*   Surface RUNHA               */
/*                               */
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
	int d1, d2, d3;
	int lives,won,end,speed;

    	mode(1);
    	asm("di\n");
	z=0;speed=0;sc1=0;sc2=0;sc3=0;
	while(z==0){
	end=0;	a=17;	b=45;	y=31;	lives=3;  won=0; 
	d1=14;  d2=35;  d3=55;
	setbase(0x7000);

   	draw_string(0, 20, 2, "CONTROLS:");
   	draw_string(0, 26, 2, "Q = Top ATV");
   	draw_string(0, 32, 2, "A = Middle ATV");
   	draw_string(0, 38, 2, "Z = Bottom ATV");
   	draw_string(0, 44, 2, "ESC = EXIT");
   	draw_string(90, 20, 2, "SPEED:");
	score((0x7000+31)+(32*20),speed);
   	draw_string(92, 26, 2, "0=Fast");
   	draw_string(92, 32, 2, "5=Slow");
   	draw_string(12, 54, 2, "PRESS <S> TO START");
   	draw_string(5, 59, 3, "Last score:");
	score((0x7000+20)+(32*59),sc1);
	score((0x7000+19)+(32*59),sc2);
	score((0x7000+18)+(32*59),sc3);
   	draw_string(110, 59, 3, "/DM");
	j=0;   sc1=0;	sc2=0;	sc3=0;
      	do{	score((0x7000+31)+(32*20),speed);
		draw_string(54, 54, 2, "S");
		for(i=0;i<500;i++){
			if((mem[0x68fd] & 0x2) == 0) {j=1;break;}
			if(inch()=='0') {speed=0;}
			if(inch()=='1') {speed=1;}
			if(inch()=='2') {speed=2;}
			if(inch()=='3') {speed=3;}
			if(inch()=='4') {speed=4;}
			if(inch()=='5') {speed=5;}}

		score((0x7000+31)+(32*20),speed);
		draw_string(54, 54, 0, "S");
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

/*
display holes
		c=rand(6);
		if (rand(15)==3) {a++;b++;}
		if (rand(20)==3)  {a--;b--;}
		if (rand(20)==3)  {a=5;b=(43-15);
*/

		mem[(scr+31)+(32*15)]=170;
		mem[(scr+31)+(32*36)]=170;
		mem[(scr+31)+(32*56)]=170;

		if ((mem[0x68fe] & 0x10) == 0) {d1=d1-2;}				/* Q = up */
		if ((mem[0x68ef] & 0x20) == 0) {d2=d2-2;}				/* m = up */
		if ((mem[0x68ef] & 0x8) == 0)  {d3=d3-2;}				/* , = up */
		y++;
		x++;
		mem[(scr+6)+(d1*32)]=85;						/* draw ship               */
		mem[(scr+6)+(d2*32)]=85;						/* draw ship               */
		mem[(scr+6)+(d3*32)]=85;						/* draw ship               */
 		for (i=0;i<64;i++){mem[scr+(i*32)]=0;} 					/* stops overscroll        */
		score((0x7000+12)+(32*59),sc1);
		score((0x7000+11)+(32*59),sc2);
		score((0x7000+10)+(32*59),sc3);
		score((0x7000+28)+(32*59),lives);
		memcpy(0x7000,scr+1,2048-32*5);
		memcpy(scr,0x7000,2048-32*5);
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

