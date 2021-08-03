#define SCRSIZE     2048 
\
char scr[128*64];
char *mem;
main(argc, argv)
int argc;
int *argv;

{	
	int a,c,g,i,x,y,z;
    	mode(1);
	asm("di\n");
	setbase(scr);


/* --------------------------------------- */
/* Intro                                   */
/* --------------------------------------- */

	   memset (scr, 85, 32*20);
	   memset (scr+32*20, 170, 32*20);
	   memset (scr+(SCRSIZE-(32*20)),255,32*20); 

	   line (0,15,20,0,2);
	   line (107,0,127,15,2);
	   line (0,63-15,20,63,2);
	   line (107,63,127,63-15,2);

/*
	      memset(scr+(SCRSIZE-(32*8)),85,32*8); 
	for (i=scr+(SCRSIZE-(32*34));i<scr+(SCRSIZE-(32*8));i=i+32){
	      memset(i,255,16); 	
	      memset(i+16,170,16);
*/


 	   draw_string(20, 17, 3, "SATURDAY NIGHT");
 	   draw_string(60, 25, 3, "DEMO");
	   draw_string(4, 46, 1, "(done by silly dave)");


	   for (y=0;y<64;y++){
	      memcpy(0x7000+(y*32),scr+(y*32),32);
	      for(x=y;x<63;x++){
	         memcpy(0x7000+(x*32),scr+(y*32),32);
              }
	      delay2(); 
	   }
	delay();
 	memcpy(scr, 0x7000, SCRSIZE);
	delay();
        for(y=0;y<64;y++){
	   memcpy(0x7000   , scr+(y*32)+32,SCRSIZE-(y*32));
	   delay2(); }
	   memset (scr, 0, SCRSIZE);
/* --------------------------------------- */
/* Start of demo                           */
/* --------------------------------------- */


	
	c=0;
	a=0;
	z=1;
	while(!(z==2)){
           
	   dis( 1,1  ,  1,10, 16,10, 16,1  ,1	);
	   dis( 0,2  ,  2,11, 17,9 , 15,0  ,2	);
	   dis( 0,3  ,  3,11, 17,8 , 14,0  ,3	);
	   dis( 0,4  ,  5,12, 17,7 , 12,-1 ,4	);
	   dis(-1,5  ,  7,12, 18,6 , 10,-1 ,5	);
	   dis(-1,6  ,  9,12, 18,5 , 8,-1  ,6	);
	   dis(-1,7  , 11,12, 18,4 , 6,-1  ,7	);
	   dis(-1,8  , 13,11, 18,3 , 4,0   ,8	);
	   dis( 0,9  , 14,11, 17,2 , 3,0   ,9	);
	   dis( 0,10 , 15,11, 17,1 , 2,0   ,10	);

   
	        
	}
        
}


/* ----------------------------------------------- */
/* Subbies                                         */
/* ----------------------------------------------- */

dis(a,b,c,d,e,f,g,h,q)
int a,b,c,d,e,f,g,h,q;
{
int i,j,k,l,m,n,o,p,r,s;
	i=a;
	j=b;
	k=c;
	l=d;
	m=e;
	n=f;
	o=g;
	p=h;

	
	i=i+70;
	j=j+10;
	k=k+70;
	l=l+10;
	m=m+70;
	n=n+10;
	o=o+70;
	p=p+10;

	line(i,j,k,l, 3);
	line(k,l,m,n, 3);
	line(m,n,o,p, 3);
	line(o,p,i,j, 3);

	i=a;
	j=b;
	k=c;
	l=d;
	m=e;
	n=f;
	o=g;
	p=h;

	i=(i+10)*2-10-7+60;
	j=(j+10)*2-10-5;
	k=(k+10)*2-10-7+60;
	l=(l+10)*2-10-5;
	m=(m+10)*2-10-7+60;
	n=(n+10)*2-10-5;
	o=(o+10)*2-10-7+60;
	p=(p+10)*2-10-5;

	line(i,j,k,l, 2);
	line(k,l,m,n, 2);
	line(m,n,o,p, 2);
	line(o,p,i,j, 2);


	i=a;
	j=b;
	k=c;
	l=d;
	m=e;
	n=f;
	o=g;
	p=h;

	i=(i+25)/3+68;
	j=(j+25)/3+6;
	k=(k+25)/3+68;
	l=(l+25)/3+6;
	m=(m+25)/3+68;
	n=(n+25)/3+6;
	o=(o+25)/3+68;
	p=(p+25)/3+6;

	line(i,j,k,l, 1);
	line(k,l,m,n, 1);
	line(m,n,o,p, 1);
	line(o,p,i,j, 1);

/* --------------------------------- */
	i=a;
	j=b;
	k=c;
	l=d;
	m=e;
	n=f;
	o=g;
	p=h;

	i=(i+10)*2+20-7+20;
	j=(j+10)*2-10-5+10;
	k=(k+10)*2+20-7+20;
	l=(l+10)*2-10-5+10;
	m=(m+10)*2+20-7+20;
	n=(n+10)*2-10-5+10;
	o=(o+10)*2+20-7+20;
	p=(p+10)*2-10-5+10;

/*
	vortex
	line(i+10,j+20,((m+10-i+10)/2)+10,((n+20-j+20)/2), 2);
	line(k+10,l+20,((o+10-k+10)/2)+10,((p+20-l+20)/2), 2);
	line(m+10,n+20,((i+10-m+10)/2)+10,((j+20-n+20)/2), 2);
	line(o+10,p+20,((k+10-o+10)/2)+10,((l+20-p+20)/2), 2); */




	line(i-50,j+20,k-50,l+20, 2);
	line(k-50,l+20,m-50,n+20, 2);
	line(m-50,n+20,o-50,p+20, 2);
	line(o-50,p+20,i-50,j+20, 2);

if (q < 6){
	line(i-50,j+20, 50, 20, 2); }
if (q > 8){
	line(k-50,l+20, 50, 20, 2); }
	line(m-50,n+20, 50, 20, 2);
	line(o-50,p+20, 50, 20, 2);

	
	line(167 - i,(j/2)+25,167-70,47, 3);
	line(167 - k,(l/2)+25,167-70,47, 3);
	line(167 - m,(n/2)+25,167-70,47, 3);
	line(167 - o,(p/2)+25,167-70,47, 3);
	line(167 - i,(j/2)+35,167-70,47, 1);
	line(167 - k,(l/2)+35,167-70,47, 1);
	line(167 - m,(n/2)+35,167-70,47, 1);
	line(167 - o,(p/2)+35,167-70,47, 1);


/* box it
	line(i,j+20,k,l+20, 3);
	line(k,l+20,m,n+20, 3);
	line(m,n+20,o,p+20, 3);
	line(o,p+20,i,j+20, 3);
*/

/* long rectangular thing
	line(i+50,j+20,50,50, 2);
	line(k+50,l+20,50,50, 2);
	line(m+50,n+20,50,50, 2);
	line(o+50,p+20,50,50, 2);
*/




/* --------------------------------- */


              memcpy(0x7000,scr,SCRSIZE);
	      memset(scr,0,SCRSIZE); 
	      memset(scr+(SCRSIZE-(32*42)),85,32*8); 
	      memset(scr+(SCRSIZE-(32*8)),85,32*8); 
	for (i=scr+(SCRSIZE-(32*34));i<scr+(SCRSIZE-(32*8));i=i+32){
	      memset(i,255,16); 	
	      memset(i+16,170,16);
		
	}

	return 0;
}


delay(){int i,d;
        for(i=0;i<1000;i++){d=rand(2);}}

delay2(){int i;
        for(i=0;i<900;i++);}

draw_string(x,y,color,src)
int x,y,color;
char *src;
{	while (*src)	{
	   char_draw(x,y,color,*src);
	   x += 6;
           src++;	}}
