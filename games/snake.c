 
#define scrsize	2048
#define	video	0x7000

char 	*mem;
char    scr[32*64];
main(argc, argv)
int 	argc;
int 	*argv;
{	
	int a,b,c,d,e,f,g,h,i,j,k,l,x,y,z;
	int lives, die, die2, rot, rot2;
	z=1;
	y=2;
	x=5;
    	mode(1);
	setbase(scr);
    	asm("di\n");
	memset(scr,0,2048);
	line(0,0,127,0,1);
	line(0,63,127,63,1);
	line(0,0,0,63,1);
	line(127,0,127,63,1);
	line(111,63,127,63,3);
	for(i=0;i<45;i++){
		plot(63,i,1);
		plot(95,i,1);
		plot(24,i,1);
		plot(79,i+18,1);
		plot(47,i+18,1);
		plot(111,i+18,1);
	}
	memcpy(0x7000,scr,2048);

	while(z==1){
		if ((mem[0x68fe] & 0x10) == 0) {a=-1;b=0;}	/* up    Q */
		if ((mem[0x68fb] & 0x04) == 0) {a=1;b=0;}     	/* down  shift */
	    	if ((mem[0x68ef] & 0x20) == 0) {b=-1;a=0;}     	/* left  M */
	    	if ((mem[0x68ef] & 0x08) == 0) {b=1;a=0;}     	/* right , */
		x=x+b;
		y=y+a;
                
		plot(x,y,2);
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

