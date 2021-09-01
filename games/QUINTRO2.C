/* --------------------------------------- */
/* Quintro #2 - dave. 25/may/2k2           */
/* --------------------------------------- */
#define SCRSIZE 2048 
#define scr1	0xe000
#define scr2	0xe800
#define scr3	0xf000
#define scr4	0xf800
char *mem;

main(argc, argv)
int argc;
int *argv;
{	int a,b,c,d,e,f,g,h,i,j,k,x,y,z;
         mode(1);

	setbase(scr1);

 	for(y=-1;y<12;y++){
 	   draw_string(0, y+0,  1, "   Daves Engineering");
 	   draw_string(0, y-6,  1, "       at  work");
 	   draw_string(0, y-12, 1, "       presents");
	   memcpy(0x7000,scr1,SCRSIZE);
	   memset(scr1,0,SCRSIZE);
           for(i=0;i<50;i++){d=rand(2);}}
 	for(y=12;y>-12;y--){
 	   draw_string(0, y+0,  1, "   Daves Engineering");
 	   draw_string(0, y-6,  1, "       at  work");
 	   draw_string(0, y-12, 1, "       presents");
	   memcpy(0x7000,scr1,SCRSIZE);
	   memset(scr1,0,SCRSIZE);}
 	for(y=-18;y<12;y++){
	   memset(scr1,0,SCRSIZE);
 	   draw_string(0, y+0,  1, "   Daves Engineering");
 	   draw_string(0, y+6,  1, "       at  work");
 	   draw_string(0, y+12, 1, "       presents");
	   memcpy(0x7000,scr1,SCRSIZE);
           for(i=0;i<50;i++){d=rand(2);}}

        setbase(scr2);
 	for(x=0;x<90;x++){
	   memcpy(scr2,scr1,SCRSIZE);
 	   draw_string(x, 45, 2, "2");
	   memcpy(0x7000,scr2,SCRSIZE);}
	   memcpy(scr1,scr2,SCRSIZE);

 	for(x=0;x<84;x++){
	   memcpy(scr2,scr1,SCRSIZE);
 	   draw_string(x, 45, 2, "#");
	   memcpy(0x7000,scr2,SCRSIZE);}
	   memcpy(scr1,scr2,SCRSIZE);

 	for(x=0;x<72;x++){
	   memcpy(scr2,scr1,SCRSIZE);
 	   draw_string(x, 45, 2, "O");
	   memcpy(0x7000,scr2,SCRSIZE);}
	   memcpy(scr1,scr2,SCRSIZE);

 	for(x=0;x<66;x++){
	   memcpy(scr2,scr1,SCRSIZE);
 	   draw_string(x, 45, 2, "R");
	   memcpy(0x7000,scr2,SCRSIZE);}
	   memcpy(scr1,scr2,SCRSIZE);

 	for(x=0;x<60;x++){
	   memcpy(scr2,scr1,SCRSIZE);
 	   draw_string(x, 45, 2, "T");
	   memcpy(0x7000,scr2,SCRSIZE);}
	   memcpy(scr1,scr2,SCRSIZE);

 	for(x=0;x<54;x++){
	   memcpy(scr2,scr1,SCRSIZE);
 	   draw_string(x, 45, 2, "N");
	   memcpy(0x7000,scr2,SCRSIZE);}
	   memcpy(scr1,scr2,SCRSIZE);

 	for(x=0;x<48;x++){
	   memcpy(scr2,scr1,SCRSIZE);
 	   draw_string(x, 45, 2, "I");
	   memcpy(0x7000,scr2,SCRSIZE);}
	   memcpy(scr1,scr2,SCRSIZE);

 	for(x=0;x<42;x++){
	   memcpy(scr2,scr1,SCRSIZE);
 	   draw_string(x, 45, 2, "U");
	   memcpy(0x7000,scr2,SCRSIZE);}
	   memcpy(scr1,scr2,SCRSIZE);

 	for(x=0;x<36;x++){
	   memcpy(scr2,scr1,SCRSIZE);
 	   draw_string(x, 45, 2, "Q");
	   memcpy(0x7000,scr2,SCRSIZE);}
	   memcpy(scr1,scr2,SCRSIZE);



        setbase(0x7000);
 	draw_string(0, 58, 3, "Loading:");


	setbase(0xe000); 
        c=0;
	   for(i=0;i<32;i++){
              line(64, 32, i*4   ,0,0);
              line(64, 32, i*4+1,0,1);
              line(64, 32, i*4+2,0,2);
              line(64, 32, i*4+3,0,3);
              line(64, 32, i*4  ,63,3);
              line(64, 32, i*4+1,63,2);
              line(64, 32, i*4+2,63,1);
              line(64, 32, i*4+3,63,0);
              c++;
              if (c>3){c=0;}}
           setbase(0x7000);
           line(0,63,16,63,3);
           setbase(0xe000);
	   for(i=0;i<16;i++){
              line(64, 32,127, i*4   ,0);
              line(64, 32,127, i*4+1,1);
              line(64, 32,127, i*4+2,2);
              line(64, 32,127, i*4+3,3);
              line(64, 32,0, i*4   ,3);
              line(64, 32,0, i*4+1,2);
              line(64, 32,0, i*4+2,1);
              line(64, 32,0, i*4+3,0);
              c++;
              if (c>3){c=0;}}
           setbase(0x7000);
           line(16,63,32,63,3);
  	   setbase(0xe800); 
	   for(i=0;i<32;i++){
              line(64, 32, i*4   ,0,1);
              line(64, 32, i*4+1,0,2);
              line(64, 32, i*4+2,0,3);
              line(64, 32, i*4+3,0,0);
              line(64, 32, i*4  ,63,0);
              line(64, 32, i*4+1,63,3);
              line(64, 32, i*4+2,63,2);
              line(64, 32, i*4+3,63,1);
              c++;
              if (c>3){c=0;}}
           setbase(0x7000);
           line(32,63,48,63,3);
  	   setbase(0xe800); 
	   for(i=0;i<16;i++){
              line(64, 32,127, i*4   ,1);
              line(64, 32,127,i*4+1,2);
              line(64, 32,127,i*4+2,3);
              line(64, 32,127,i*4+3,0);
              line(64, 32,0, i*4   ,0);
              line(64, 32,0,i*4+1,3);
              line(64, 32,0,i*4+2,2);
              line(64, 32,0,i*4+3,1);
              c++;
              if (c>3){c=0;}}
           setbase(0x7000);
           line(48,63,64,63,3);
  	   setbase(0xf000); 
	   for(i=0;i<32;i++){
              line(64, 32, i*4 ,0,2);
              line(64, 32,i*4+1,0,3);
              line(64, 32,i*4+2,0,0);
              line(64, 32,i*4+3,0,1);
              line(64, 32, i*4 ,63,1);
              line(64, 32,i*4+1,63,0);
              line(64, 32,i*4+2,63,3);
              line(64, 32,i*4+3,63,2);
              c++;
              if (c>3){c=0;}}
           setbase(0x7000);
           line(64,63,80,63,3);
  	   setbase(0xf000); 
	   for(i=0;i<16;i++){
              line(64, 32,127, i*4 ,2);
              line(64, 32,127,i*4+1,3);
              line(64, 32,127,i*4+2,0);
              line(64, 32,127,i*4+3,1);
              line(64, 32,0, i*4 ,1);
              line(64, 32,0,i*4+1,0);
              line(64, 32,0,i*4+2,3);
              line(64, 32,0,i*4+3,2);
              c++;
              if (c>3){c=0;}}
           setbase(0x7000);
           line(80,63,96,63,3);
  	   setbase(0xf800); 
	   for(i=0;i<32;i++){
              line(64, 32, i*4   ,0,3);
              line(64, 32,i*4+1,0,0);
              line(64, 32,i*4+2,0,1);
              line(64, 32,i*4+3,0,2);
              line(64, 32, i*4 ,63,2);
              line(64, 32,i*4+1,63,1);
              line(64, 32,i*4+2,63,0);
              line(64, 32,i*4+3,63,3);
              c++;
              if (c>3){c=0;}}
           setbase(0x7000);
           line(96,63,112,63,3);
  	   setbase(0xf800); 
	   for(i=0;i<16;i++){
              line(64, 32,127, i*4   ,3);
              line(64, 32,127,i*4+1,0);
              line(64, 32,127,i*4+2,1);
              line(64, 32,127,i*4+3,2);
              line(64, 32,0, i*4   ,2);
              line(64, 32,0,i*4+1,1);
              line(64, 32,0,i*4+2,0);
              line(64, 32,0,i*4+3,3);
              c++;
              if (c>3){c=0;}}
           setbase(0x7000);
           line(112,63,127,63,3);


/* -------------------------------------------- */
/* SPLIT-IN                                     */
/* -------------------------------------------- */
	for(i=1;i<1024+32;i=i+32){ 
	   memcpy(0x7800-i+1,0xe000+1024,i);
	   memcpy(0x7000    ,0xe000+1024-i+1,i);
	   for(j=0;j<10;j++){c=rand(2);}}

/* -------------------------------------------- */
/* ROTATE spiral                                */
/* -------------------------------------------- */
	for(i=0;i<20;i++){
	   memcpy(0x7000,0xe000, 2048);
	   for(j=0;j<70;j++){d=rand(2);}
	   memcpy(0x7000,0xe800, 2048);
	   for(j=0;j<70;j++){d=rand(2);}
	   memcpy(0x7000,0xf000, 2048);
	   for(j=0;j<70;j++){d=rand(2);}
	   memcpy(0x7000,0xf800, 2048);
	   for(j=0;j<70;j++){d=rand(2);}}


/* -------------------------------------------- */
/* EXPLODE goes here                            */
/* -------------------------------------------- */

	

/* -------------------------------------------- */
/* Weird screen x thing                         */
/* -------------------------------------------- */
	memset(0xe000,0,8192);
	setbase(0xE000); 
	line(0,0,127,63,1);
	line(0,63,127,0,1);
	setbase(0xE800); 
	line(0,0,127,63,2);
	line(0,63,127,0,2);
	setbase(0xF000); 
	line(0,0,127,63,3);
	line(0,63,127,0,3);
        for(z=0;z<10;z++){
  	   for(i=1;i<1024+32;i=i+32){ 
              memcpy(0x7800-i+1,0xe000+1024,i);
              memcpy(0x7000    ,0xe000+1024-i+1,i);
	      for(j=0;j<10;j++){c=rand(2);}}
	   for(i=1;i<1024+32;i=i+32){ 
              memcpy(0x7800-i+1,0xe800+1024,i);
              memcpy(0x7000    ,0xe800+1024-i+1,i);
              for(j=0;j<10;j++){c=rand(2);}}
	   for(i=1;i<1024+32;i=i+32){ 
              memcpy(0x7800-i+1,0xf000+1024,i);
              memcpy(0x7000    ,0xf000+1024-i+1,i);
              for(j=0;j<10;j++){c=rand(2);}}
        }

	setbase(scr1);
 	for(y=-6;y<15;y++){
	   memset(scr1,0,SCRSIZE);
 	   draw_string(0, 60-y,3, "       TEH END");
	   memcpy(0x7000,scr1,SCRSIZE);
           for(i=0;i<50;i++){d=rand(2);}}

 	for(y=15;y>-6;y--){
	   memset(scr1,0,SCRSIZE);
 	   draw_string(0, 60-y,3, "       TEH END");
	   memcpy(0x7000,scr1,SCRSIZE);}

 	for(y=-10;y<25;y++){
	   memset(scr1,0,SCRSIZE);
 	   draw_string(0, 60-y,3, "       THE END");
	   memcpy(0x7000,scr1,SCRSIZE);
           for(i=0;i<50;i++){d=rand(2);}}


	do{;} while(a!=1);       

}


draw_string(x,y,color,src)
int x,y,color;
char *src;
{	while (*src)	{
	   char_draw(x,y,color,*src);
	   x += 6;
           src++;	}}

