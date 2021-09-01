/* --------------------------------------- */
/* megademo   - dave. 25/may/2k2           */
/* --------------------------------------- */

#define SCRSIZE     2048 
char scr[128*64];
/* char *mem; */
main()

{	
	int a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z;
    	mode(1);
	asm("di\n");
	setbase(scr);
/* --------------------------------------- */
/* Intro                                   */
/* --------------------------------------- */

 	for(x=0;x<60;x++){
	   memset(scr,85,SCRSIZE);
	   vz();
 	   draw_string(x, 50, 0, "Dave");
 	   draw_string(44, -10+x, 0, "by");
	   memcpy(0x7000,scr,SCRSIZE);}
	setbase(scr);
        x=4;
 	for(y=-6;y<31;y++){
	   memset(scr,85,SCRSIZE);
 	   draw_string(60   ,50   ,0, "Dave");
 	   draw_string(44   ,50   ,0, "by");
	   vz();
 	   draw_string(x    ,y    ,3, "M G ");
 	   draw_string(x+24 ,y    ,2, "D M");
 	   draw_string(86-x ,60-y ,3, "E A ");
 	   draw_string(110-x,60-y ,2, "E O");
	   memcpy(0x7000,scr,SCRSIZE);
           x++;
           } /* for(i=0;i<10;i++){d=rand(2);}} */
	delay();
        for(x=0;x<32;x++){
	   memcpy(0x7000,scr+x,SCRSIZE-32);
	   line(x*4  ,0,x*4  ,63,1);
	   line(x*4+1,0,x*4+1,63,1);
	   line(x*4+2,0,x*4+2,63,1);
	   line(x*4+3,0,x*4+3,63,1);}

	mode(1);
	setbase(scr);
/* --------------------------------------- */
/* Start of demo                           */
/* --------------------------------------- */
	a=0;
	c=0;
	g=0;
	x=0;
	i=0;
	j=0;
        d=1;
        e=2;
        f=3;
	y=63;
        z=1;

	while(!(z==2)){
           for(g=0;g<8;g++){
           for(i=0;i<15;i++){
	   dis(63,31,c,g);
	   dis(63,30,c,g);
	   dis(63,29,c,g);
	   dis(63,28,c,g);
	   dis(62,27,c,g);
	   dis(62,26,c,g);
	   dis(62,25,c,g);
	   dis(61,24,c,g);
	   dis(60,23,c,g);
	   dis(59,22,c,g);
	   dis(58,21,c,g);
	   dis(57,21,c,g);
	   dis(56,20,c,g);
	   dis(55,20,c,g);
	   dis(54,19,c,g);
	   dis(53,19,c,g);
	   dis(52,18,c,g);
	   dis(51,18,c,g);
	   dis(50,18,c,g);
	   dis(49,17,c,g);
	   dis(48,17,c,g);
	   dis(47,17,c,g);
	   dis(46,17,c,g);
	   dis(45,17,c,g);
	   dis(44,16,c,g);
	   dis(43,16,c,g);
	   dis(42,16,c,g);
	   dis(41,16,c,g);
	   dis(40,17,c,g);
	   dis(39,17,c,g);
	   dis(38,17,c,g);
	   dis(37,17,c,g);
	   dis(36,18,c,g);
	   dis(35,18,c,g);
	   dis(34,18,c,g);
	   dis(33,19,c,g);
	   dis(32,19,c,g);
	   dis(31,19,c,g);
	   dis(30,20,c,g);
	   dis(29,20,c,g);
	   dis(28,21,c,g);
	   dis(27,21,c,g);
	   dis(26,22,c,g);
	   dis(25,23,c,g);
	   dis(24,24,c,g);
	   dis(23,25,c,g);
	   dis(22,26,c,g);
	   dis(22,27,c,g);
	   dis(21,28,c,g);
	   dis(21,29,c,g);
	   dis(21,30,c,g);
	   dis(21,31,c,g);
	   dis(21,32,c,g);
	   dis(21,33,c,g);
	   dis(22,34,c,g);
	   dis(22,35,c,g);
	   dis(22,36,c,g);
	   dis(23,37,c,g);
	   dis(23,38,c,g);
	   dis(24,39,c,g);
	   dis(25,40,c,g);
	   dis(26,41,c,g);
	   dis(27,42,c,g);
	   dis(28,42,c,g);
	   dis(29,43,c,g);
	   dis(30,43,c,g);
	   dis(31,44,c,g);
	   dis(32,44,c,g);
	   dis(33,44,c,g);
	   dis(34,44,c,g);
	   dis(35,45,c,g);
	   dis(36,45,c,g);
	   dis(37,45,c,g);
	   dis(38,45,c,g);
	   dis(39,45,c,g);
	   dis(40,46,c,g);
	   dis(41,46,c,g);
	   dis(42,46,c,g);
	   dis(43,46,c,g);
	   dis(44,45,c,g);
	   dis(45,45,c,g);
	   dis(46,45,c,g);
	   dis(47,45,c,g);
	   dis(48,45,c,g);
	   dis(49,44,c,g);
	   dis(50,44,c,g);
	   dis(51,44,c,g);
	   dis(52,44,c,g);
	   dis(53,43,c,g);
	   dis(54,43,c,g);
	   dis(55,42,c,g);
	   dis(56,42,c,g);
	   dis(57,41,c,g);
	   dis(58,40,c,g);
	   dis(59,40,c,g);
	   dis(60,39,c,g);
	   dis(61,38,c,g);
	   dis(61,37,c,g);
	   dis(62,36,c,g);
	   dis(62,35,c,g);
	   dis(62,34,c,g);
	   dis(63,33,c,g);
	   dis(63,32,c,g);
           c++;
           if (c>3) {c=0;}
   
              memcpy(0x7000,scr,SCRSIZE);
	      memset(scr,0,SCRSIZE); 
	   if (g>0){i=i*5;}
        
	}}

/* LINES -------------------------------------------------------------------------------------------------------- */

{	
    	
	
	asm("di\n");
	a=1;
	b=1;
	c=30;
	d=10;
	e=60;
	f=40;
	g=85;
	h=20;
	i=100;
	j=25;
	k=120;
	l=55;
	m=1;
	n=1;
	o=1;
	p=1;
	q=1;
	r=1;
	s=1;
	t=1;
	u=1;
	v=1;
	w=1;
	x=1;
     	for(z=0;z<4;z++){
           for(y=0;y<200;y++){
		a=a+m;
		b=b+n;
		c=c+o;
		d=d+p;
		e=e+q;
		f=f+r;
		g=g+s;
		h=h+t;
		i=i+u;
		j=j+v;
		k=k+w;
		l=l+x;
		if (a==1)   m=1;
		if (a==127) m=-1;
		if (b==1)   n=1;
		if (b==63)  n=-1;
		if (c==1)   o=1;
		if (c==127) o=-1;
		if (d==1)   p=1;
		if (d==63)  p=-1;
		if (e==1)   q=1;
		if (e==127) q=-1;
		if (f==1)   r=1;
		if (f==63)  r=-1;
		if (g==1)   s=1;
		if (g==127) s=-1;
		if (h==1)   t=1;
		if (h==63)  t=-1;
		if (i==1)   u=1;
		if (i==127) u=-1;
		if (j==1)   v=1;
		if (j==63)  v=-1;
		if (k==1)   w=1;
		if (k==127) w=-1;
		if (l==1)   x=1;
		if (l==63)  x=-1;

		if (z==0){
		   line(a,b, c,d, 2);
		   line(c,d, e,f, 2);
		   line(e,f, g,h, 2);
		   line(g,h, i,j, 2);
		   line(i,j, k,l, 2);}
		if (z==1){
		   line(a,b, c,63-d, 2);
		   line(c,d, e,63-f, 2);
		   line(e,f, g,63-h, 2);
		   line(g,h, i,63-j, 2);
		   line(i,j, k,63-l, 2);}
		if (z==2){
		   line(a,b, c,63-d, 2);
		   line(c,d, e,63-f, 2);
		   line(e,f, g,63-h, 2);
		   line(g,h, i,63-j, 2);
		   line(i,j, k,63-l, 2);
		   line(127-a,63-b, 127-c,d, 3);
		   line(127-c,63-d, 127-e,f, 3);
		   line(127-e,63-f, 127-g,h, 3);
		   line(127-g,63-h, 127-i,j, 3);
		   line(127-i,63-j, 127-k,l, 3);}
		if (z==3){
		   line(a,b, 127-c,63-d, 1);
		   line(c,d, 127-e,63-f, 1);
		   line(e,f, 127-g,63-h, 1);
		   line(g,h, 127-i,63-j, 1);
		   line(i,j, 127-k,63-l, 1);
		   line(a,b, c,63-d, 2);
		   line(c,d, e,63-f, 2);
		   line(e,f, g,63-h, 2);
		   line(g,h, i,63-j, 2);
		   line(i,j, k,63-l, 2);
		   line(127-a,63-b, 127-c,d, 3);
		   line(127-c,63-d, 127-e,f, 3);
		   line(127-e,63-f, 127-g,h, 3);
		   line(127-g,63-h, 127-i,j, 3);
		   line(127-i,63-j, 127-k,l, 3);}
		memcpy(0x7000,scr,SCRSIZE);
 		memset(scr, 0, 2048);   
		}
	}
}

/* -----------------------------------------*/
/* BARS                                     */
/* ---------------------------------------- */
	   for(a=0;a<10;a++){
              memset(scr, 108, 2048); 
              memcpy(0x7000,scr,SCRSIZE);
	      delay2();
              memset(scr, 177, 2048); 
              memcpy(0x7000,scr,SCRSIZE);
	      delay2();
              memset(scr, 198, 2048); 
              memcpy(0x7000,scr,SCRSIZE);
	      delay2();
              memset(scr, 27, 2048); 
              memcpy(0x7000,scr,SCRSIZE);
	      delay2();}
	   for(a=0;a<10;a++){
              memset(scr, 27, 2048); 
              memcpy(0x7000,scr,SCRSIZE);
	      delay2();
              memset(scr, 198, 2048); 
              memcpy(0x7000,scr,SCRSIZE);
	      delay2();
              memset(scr, 177, 2048); 
              memcpy(0x7000,scr,SCRSIZE);
	      delay2();
              memset(scr, 108, 2048); 
              memcpy(0x7000,scr,SCRSIZE);
	      delay2();}

	 for(y=-6;y<20;y++){
	   memset(scr,0,SCRSIZE);
 	   draw_string(42, y,3, "THE NED");
	   memcpy(0x7000,scr,SCRSIZE);
           for(i=0;i<50;i++){d=rand(2);}}
	   delay();
        setbase(0x7000);
 	   draw_string(42, 19,0, "THE NED");
 	   draw_string(66, 12,3, "N");
 	   draw_string(42, 19,3, "THE  ED");
	   delay();
 	   draw_string(42, 19,0, "THE NED");
 	   draw_string(42, 19,3, "THE E D");
 	   draw_string(66, 12,0, "N");
 	   draw_string(72, 12,3, "N");
	   delay();
 	   draw_string(72, 12,0, "N");
 	   draw_string(42, 19,3, "THE END");

	do{;} while(a!=1);       

        }
}


/* ----------------------------------------------- */
/* Subbies                                         */
/* ----------------------------------------------- */

dis(x,y,c,g)
int x,y,c,g;
{
int d,e,f,h;
	d=e=f=c;
           d++;
           e++;
           f++;
           if (d>3) {d=0;}
           if (e>3) {e=0;}
           if (f>3) {f=0;}

           e++;
           f++;
           if (e>3) {e=0;}
           if (f>3) {f=0;}

           f++;
           if (f>3) {f=0;}
	   

	if (g==0){
           plot(x,y-15,c);
	   plot(127-x,63-y+15,d);
	   plot(127-x,y-15,e);
           plot(x,63-y+15,f);
           line ((63-(x/2)), (31-(y/2)),(52-(x/4)), (23-(y/4)),e);
	   line ((63+(x/2)), (31+(y/2)),(74+(x/4)), (39+(y/4)),d);
	   line ((63+(x/2)), (31-(y/2)),(74+(x/4)), (23-(y/4)),f);
	   line ((63-(x/2)), (31+(y/2)),(52-(x/4)), (39+(y/4)),c);
	}
	if (g==1){line (x+16+c, y-d, 58,31,3); } 
	if (g==2){line (x+16, y, 100-x,63-y, 3); }
	if (g==3){
           line (x+16,        y, 48+(x/4),24+(y/4),3);
	   line (100-x,    63-y, 68-(x/4),39-(y/4),3);
           line (48+(x/4), 24+(y/4), 58,31,2);
	   line ( 68-(x/4), 39-(y/4),58,31,2); }	
	if (g==4){
           line (x+16, y, 100-x,63-y, 3);
           line (48+(x/4), 39-(y/4), 58,31,2);
	   line ( 68-(x/4), 24+(y/4),58,31,2);}
	if (g==5){
           line (x+16,        y, 48+(x/4),24+(y/4),3);
	   line (100-x,    63-y, 68-(x/4),39-(y/4),3);
           line (48+(x/4), 24+(y/4), 58,31,2);
	   line ( 68-(x/4), 39-(y/4),58,31,2);
           line (100-x,y,  68-(x/4), 24+(y/4), 3);
           line (x+16,63-y, 48+(x/4), 39-(y/4), 3);
           line (48+(x/4), 39-(y/4), 58,31,2);
	   line ( 68-(x/4), 24+(y/4),58,31,2);
           line (x+16-30,        y-16,      48+(x/4)-30, 24+(y/4)-16,3);
	   line (100-x-30,    63-y-16,      68-(x/4)-30, 39-(y/4)-16,3);
           line (48+(x/4)-30, 24+(y/4)-16,  58-30,       31-16,1);
	   line ( 68-(x/4)-30, 39-(y/4)-16, 58-30,       31-16,1);
           line (48+(x/4)-30, 39-(y/4)-16,  58-30,       31-16,2);
	   line ( 68-(x/4)-30, 24+(y/4)-16, 58-30,       31-16,2);
           line (x+16+30,        y+16,      48+(x/4)+30, 24+(y/4)+16,3);
	   line (100-x+30,    63-y+16,      68-(x/4)+30, 39-(y/4)+16,3);
           line (48+(x/4)+30, 24+(y/4)+16,  58+30,       31+16,2);
	   line ( 68-(x/4)+30, 39-(y/4)+16, 58+30,       31+16,2);
           line (48+(x/4)+30, 39-(y/4)+16,  58+30,       31+16,1);
	   line ( 68-(x/4)+30, 24+(y/4)+16, 58+30,       31+16,1); 
	   draw_string(x+57     ,48-y     ,1   ,"R");
	   draw_string(78+(x/2) ,32-(y/2) ,2   ,"E");
	   draw_string(99       ,16       ,3   ,"S");
	   draw_string(120-(x/2),1+(y/2)  ,2   ,"A");
	   draw_string(141-x    ,y-15     ,1   ,"L");
	   draw_string((x/2)    ,32+(y/2) ,2   ,"V");
	   draw_string(42-(x/2) ,63-(y/2) ,2   ,"Z");}
   	if(g==6){
           memset(scr     ,85 ,1024);
           memset(scr+1024,170,1024);
	   draw_string(x-10     ,y+10     ,1   ,"V");
	   draw_string(11+(x/2) ,26+(y/2) ,1   ,"Z");
	   draw_string(32       ,41       ,3   ,"2");
	   draw_string(53-(x/2) ,57-(y/2) ,0   ,"0");
	   draw_string(74-x     ,73-y     ,0   ,"0");
	   draw_string(x+42     ,y+10     ,1   ,"V");
	   draw_string(63+(x/2) ,26+(y/2) ,1   ,"Z");
	   draw_string(84       ,41       ,3   ,"3");
	   draw_string(105-(x/2),57-(y/2) ,0   ,"0");
	   draw_string(126-x    ,73-y     ,0   ,"0");
	   if (c>1){
		draw_string(x+16     ,y-15     ,2   ,"L");
		draw_string(37+(x/2) ,1+(y/2)  ,3   ,"A");
		draw_string(58       ,16       ,0   ,"S");
		draw_string(79-(x/2) ,32-(y/2) ,2   ,"E");
		draw_string(100-x    ,48-y     ,3   ,"R");}
	   else{        
		draw_string(x+16     ,48-y     ,2   ,"L");
		draw_string(37+(x/2) ,32-(y/2) ,3   ,"A");
		draw_string(58       ,16       ,0   ,"S");
		draw_string(79-(x/2) ,1+(y/2)  ,2   ,"E");
		draw_string(100-x    ,y-15     ,3   ,"R");}}
	if (g==7){
           line (x+16+4, y,            63,63,3);
           line (100-x+4,63-y,         63,63,3);
           line (48+(x/4)+4, 39-(y/4), 63,63,2);
	   line ( 68-(x/4)+4, 24+(y/4),63,63,2);
           line (x+16+4, y,            63,0,3);
           line (100-x+4,63-y,         63,0,3);
           line (48+(x/4)+4, 39-(y/4), 63,0,2);
	   line ( 68-(x/4)+4, 24+(y/4),63,0,2);
           line (x+16+4, y,            0,31, 3);
           line (100-x+4,63-y,         0,31,3);
           line (48+(x/4)+4, 39-(y/4), 0,31,2);
	   line ( 68-(x/4)+4, 24+(y/4),0,31,2);
           line (x+16+4, y,            127,31, 3);
           line (100-x+4,63-y,         127,31,3);
           line (48+(x/4)+4, 39-(y/4), 127,31,2);
	   line ( 68-(x/4)+4, 24+(y/4),127,31,2);}
	if (g>0) {  
	   memcpy(0x7000,scr,SCRSIZE);
 	   memset(scr    ,0  ,2048);}
	return 0;
}


draw_string(x,y,color,src)
int x,y,color;
char *src;
{	while (*src)	{
	   char_draw(x,y,color,*src);
	   x += 6;
           src++;	}}


delay(){int i,d;
        for(i=0;i<1000;i++){d=rand(2);}}

delay2(){int i;
        for(i=0;i<900;i++);}

vz(){	   line(40,10,50,25,3);
	   line(41,10,51,25,3);
	   line(59,10,50,25,3);
	   line(60,10,51,25,3);
	   line(66,10,86,10,3);
	   line(66,11,86,11,3);
	   line(85,10,66,25,3);
	   line(86,10,67,25,3);
	   line(66,24,86,24,3);
	   line(66,25,86,25,3);}
