/*
Galactic Raiders.


um, yeah, lost interest in finishing this off, which is a shame, coz it could have 
been something half-decent.

Maybe one day I will finish it, or at least start the actual 'fun' bit of the so-called
game. How about I just write it down on my lengthy "to do" list?

---------------------------------------------------------------------------------- */ 


#define scrsize	2048
#define	video	0x7000
#define lines	3					/* No. lines that dont scroll.*/

char 	*mem;
char    scr[32*64];
main(argc, argv)
int 	argc;
int 	*argv;

{	
	int a,b,c,d,e,f,g,h,i,j,k,l,x,y,z;
	int lives, die, die2, rot, rot2;

    rand(0);                                    /* Setup intro stars */
    for(i=0;i<100;i++){
        a=rand(32);
        b=rand(64);
        c=rand(4);
        if (c==1) c=64;
        if (c==2) c=128;
        if (c==3) c=192;
        scr[(b*32)+a]=c;}
    mode(1);
    asm("di\n");
    memcpy(0xe000,scr-i,2048);
    setbase(0xe000);
    draw_string(10, 25, 2, "GALACTIC RAIDERS");
    draw_string(11, 26, 1, "GALACTIC RAIDERS");
    memcpy(0x7000,0xe000,2048);
    setbase(scr);
    j=100;k=200;                                /* play intro music */
    for(z=0;z<10;z++){
        j++; if (j==200)j=100;  sound(j,20);
        k--; if (k==100)k=200;  sound(k,10);}
    j=90;k=180;for(z=0;z<10;z++){
        j++; if (j==180)j=90;   sound(j,20);
        k--; if (k==100)k=180;  sound(k,10);}
    j=70;k=150;for(z=0;z<10;z++){
        j++; if (j==150)j=70;   sound(j,20);
        k--; if (k==100)k=150;  sound(k,20);}
    j=90;k=180;for(z=0;z<10;z++){
        j++; if (j==180)j=90;   sound(j,20);
        k--; if (k==100)k=150;  sound(k,20);}
    j=80;k=140;l=160;for(z=0;z<10;z++){
        j++; if (j==140)j=80;   sound(j,20);
        k--; if (k==80)k=140;   sound(k,20);
        l--; if (k==110)l=160;  sound(k,20);}

    for (g=0;g<80;g++){                         /* show stars */
        memcpy(0xe000,scr-i,2048);
        i++;
        setbase(0xe000);
        draw_string(10, 25, 2, "GALACTIC RAIDERS");
        draw_string(11, 26, 1, "GALACTIC RAIDERS");
        memcpy(0x7000,0xe000,2048);
        setbase(scr);
        for (j=0;j<10;j++){;}
    }
    mode(1);
	die=63;
	die2=0;
	lives=3;
	c=0;
	a=0;
	z=1;
	x=60;
	y=50;
	g=1;
	i=0;
	h=0;						/* X, bullet fired? */
	i=0;						/* Y, bullet */
	line(0,lines,127,lines,2);
	line(b,lines,c,lines,1);
	b=30;
	c=97;



while(lives>0){
	line(0,lines,127,lines,2);
	a=rand(4);
	srand(a);
	f=rand(3);
	g=rand(3);	
	if (a==1&&f==1){plot(rand(b),lines,3);}		/* left  side red rocks */
	if (a==1&&f==2){plot(rand(127-c)+c,lines,3);}	/* right side red rocks */
	if (f==1&&g==1){				/* centre blue chunky rocks */
		k = rand(c-b)+b;	
		plot(k,lines,2);
		plot(k,lines+1,2);
		plot(k+1,lines,2);
		plot(k+1,lines+1,2);}

	if (a==1){b=b+f;c=c+g;}				/* make random sides */
	if (a==2){b=b-f;c=c-g;}
	if (a==3){b=b+f;c=c-g;}
	if (a==4){b=b-f;c=c+g;}
	if (b<10) {b=10;}				/* if min or max, then stay there */
	if (b>50) {b=50;}
	if (c<70) {c=70;}
	if (c>116){c=116;}
	line(b,lines,c,lines,1);
	plot(b,lines,3);					/* side rocks */
	plot(c,lines,3);


	if ((mem[0x68fe] & 0x10) == 0) {y=y-1;}		/* up    Q */
    if ((mem[0x68fb] & 0x04) == 0) {y=y+1;}     /* down  shift */
    if ((mem[0x68ef] & 0x20) == 0) {x=x-1;}     /* left  M */
    if ((mem[0x68ef] & 0x08) == 0) {x=x+1;}     /* right , */
    if ((mem[0x68ef] & 0x10) == 0) {    /* fire  space */
    h=x;                /* turn bullet on, X of bullet */
    i=y;                /* y of bullet */
	}

	if (die < 2){
		if (die2 == 1){
			die2=0;		
            x=((c-b)/2)+b;                      /* reset X of ship */
		}


         /*                                     draw ship
         *  ........    00000000  00000000
         *  ...x....    00010000  00010000
         *  ...x....    00010000  00010000
         *  ..xxx...    00111000  00111000
         *  .xxxxx..    01111100  01222100
         *  ..x.x...    00101000  00303000
         *  ........    00000000  00000000
         *  ........    00000000  00000000
		 */
        shape(x-3,y+0,8,8,1,"\xff\xff\xff\xff\xff\xff\xff\xff");
        shape(x-3,y+1,8,4,0,"\x10\x10\x38\x44");
        shape(x-3,y+4,8,1,2,"\x38");
        shape(x-3,y+5,8,1,3,"\x28");



	if (y<20){y=20;}				/* limit Y axis */
	if (y>58){y=58;}
	if ((rot==0)&&(y<58)){y++;}			/* increase ship Y slowly every fourth scroll */
	if ((x<b+5)||(x>c-5)){				/* detect side hit */
		lives--;
		k=0;
		while(k<600){				/* blow up ship and start again. */
			plot(x+rand(k/25),y+3+rand(k/25),3);
			plot(x+rand(k/25),y+3-rand(k/25),3);
			plot(x-rand(k/25),y+3+rand(k/25),3);
			plot(x-rand(k/25),y+3-rand(k/25),3);
			k=k+20;
			memcpy(0x7000,scr,scrsize);	/* dump screen */
		}
		die=63;
		die2=1;
        j=20;k=70;l=40;                             /* bunch of sound */
        for(i=0;i<80;i++){
            j++; if (j==60)j=20;  sound(j,5);
            k--; if (k==30)k=70;  sound(k,5);}

   }   

	if (h>0){					/* bullet is on if true */
		i--;
		if (x==b) {h=0;}			/* turn bullet off */
		plot (h,i+1,1);				/* remove old bullet */
		plot (h,i+2,1);				/* remove old bullet */
		plot (h,i,3);				/* draw bullet */
	}
	}	/* of while die < 2 */
	
	die--;
	if(die<2){die=0;}

	memset(scr, 0, 96);

	if (lives>0){line(121,0,121,2,1);}		/* display lives left */
	if (lives>1){line(123,0,123,2,1);}
	if (lives>2){line(125,0,125,2,1);}

	plot(1,1,3);
	if(rot==0){plot(0,0,3);
		plot(2,2,3);}
	if(rot==1){plot(1,0,3);
		plot(1,2,3);}
	if(rot==2){plot(2,0,3);
		plot(0,2,3);}
	if(rot==3){plot(0,1,3);
		plot(2,1,3);}
	plot(6,1,2);
	if(rot2==0){plot(6,0,2);}
	if(rot2==1){plot(7,0,2);}
	if(rot2==2){plot(7,1,2);}
	if(rot2==3){plot(7,2,2);}
	if(rot2==4){plot(6,2,2);}
	if(rot2==5){plot(5,2,2);}
	if(rot2==6){plot(5,1,2);}
	if(rot2==7){plot(5,0,2);}
	rot++;	
	if (rot==4){rot=0;}
	rot2++;	
	if (rot2==8){rot2=0;}

	
	memcpy(0x7000,scr,scrsize);			/* dump screen */
	memcpy(scr+32,0x7000,2048-32);			/* scroll screen */
	

}
	/* no lives left */

}




 
draw_string(x,y,color,src)
int x,y,color;
char *src;
{	while (*src)	{
	   char_draw(x,y,color,*src);
	   x += 6;
           src++;	}}

