/*----------------------------------------------------------*/
/* Star War by Geoff Williams (c) 2001 */

/*
	[0x68fe] & 0x10) == 0)	---  Up    (Q)
	[0x68fb] & 0x04) == 0)  ---  Down  (shift)   [Whats A ???]
	[0x68ef] & 0x20) == 0)	---  Left  (M) 
	[0x68ef] & 0x08) == 0)	---  Right (,)
	[0x68ef] & 0x10) != 0)  ---  Fire  (space)       
	[0x68bf] & 0x10) == 0)	---  (P) 

+ Top line is damage from Enemy fire on to you.   (kind of works)
+ First row on right is number of Enemies remaining. (Dont work).
+ Second row on right is number of your lives left. (Dont work).
+ Keys kinda work reasonable ok.
+ Needs better explosion, ie: Jurgens 'Defence' explosions are awesome!
+ Needs stars.
+ Screen buffering needs fixing properly.


*/

#define SCRSIZE     2048
char scr[128*64];
char *mem;
main(argc, argv)
int argc;
int *argv;
{
   int i, j, x, y, z, xmv, ymv, d, dmv, loop, lives, enemies, damage;
   char k;
   x=64;y=32;d=5;xmv=1;ymv=1;dmv=1;lives=5;enemies=5;damage=127;loop=1;
   setbase(0x7000);
   clrscr();
   printf("\n\n\n");
   printf("      WELCOME TO STAR WAR");
   printf("\n\n      PREPARE FOR BATTLE");
   printf("\n\n\n <Q> = UP          <M> = LEFT");
   printf("\n <SHIFT> = DOWN    <,> = RIGHT");
   printf("\n\nMOVE YOUR SHIP AROUND USING");
   printf("\nTHE KEYS TO LINE UP ENEMY SHIPS");
   printf("\nAND BLOW THEM AWAY.");
   printf("\n\n\n  - PRESS ANY KEY TO START -");
   getch();
   while(inch());
   rand(0);
   mode(1);
   asm("di\n");

/* Main Loop */
   for (i = 0; i < 5000; i++) {
      setbase(scr); 
      draw_enemy(x,y,d);
      draw_target();
      j = rand(30);
      if (j == 5) {
         enemy_fire(x,y);
         damage--;}
      j = rand(20);
      if (j == 5) {xmv=rand(2)-1;}
      j = rand(20);
      if (j == 5) {ymv=rand(2)-1;}
      j = rand(15);
      if (j == 5) {dmv=rand(2)-1;}
      if ((mem[0x68fe] & 0x10) == 0) {y=y+2;}	/* up    Q */
      if ((mem[0x68fb] & 0x04) == 0) {y=y-2;}	/* down  shift */
      if ((mem[0x68ef] & 0x20) == 0) {x=x+2;}	/* left  M */
      if ((mem[0x68ef] & 0x08) == 0) {x=x-2;}	/* right , */
      if ((mem[0x68ef] & 0x10) == 0) {		/* fire  space */
         fire();
	 if ((x>62)&&(x<66)&&(y>30)&&(y<34)){	/* detect if hit */
            enemies--;
            blowup(x,y,d);}
         };
                    
      if (d<1)   {dmv=1;}
      if (d>26)  {dmv=-1; sound (100,6);}
      if (x<15)  {x=x+95;}
      if (x>110) {x=x-90;}
      if (y<10)  {y=y+43;}
      if (y>53)  {y=y-43;}
      x=x+xmv;
      y=y+ymv;
      d=d+dmv;                                               
      loop++;
      if (loop == 15) {
         setbase(scr);
         draw_lives(lives);
         draw_enemies(enemies);
         draw_damage(damage);
         loop=0;
         soundcopy(0x7000,scr,SCRSIZE,0,0); }
   }
   sound(100,6);
   getch();
   mode(0);
   bgrd(0);
   return 0;
}


fire() {
   int i;
   setbase(scr);
   line (7,1,64,32,3);
   line (120,1,64,32,3);
   line (7,63,64,32,3);
   line (120,63,64,32,3);
   soundcopy(0x7000,scr,SCRSIZE,5000,1);
   line (7,1,64,32,0);
   line (120,1,64,32,0);
   line (7,63,64,32,0);
   line (120,63,64,32,0);
   return 0;
}


blowup(x,y,d) 
int x,y,d;
{
   int i,z;

      setbase(0x7000); 
      for (i=1;i<4;i++) { 
      for (z=(x-d);z<(x+d);z=z+2){  line(64,32,z,y-d, i);}
      for (z=(y-d);z<(y+d);z=z+2){  line(64,32,x+d,z, i);}
      for (z=(x+d);z>(x-d);z=z-2){  line(64,32,z,y+d, i);}
      for (z=(y+d);z>(y-d);z=z-2){  line(64,32,x-d,z, i);}
      }
      setbase(scr);
      sound(250,50);
      for (z=(x-d);z<(x+d);z=z+2){  line(64,32,z,y-d, 0);}
      for (z=(y-d);z<(y+d);z=z+2){  line(64,32,x+d,z, 0);}
      for (z=(x+d);z>(x-d);z=z-2){  line(64,32,z,y+d, 0);}
      for (z=(y+d);z>(y-d);z=z-2){  line(64,32,x-d,z, 0);}
   return 0;
}


enemy_fire(x,y) 
int x,y;
{
   int i;
   setbase(scr);
   for (i=1;i<3;i++) { 
      line (x,y,64,32,3);
      soundcopy(0x7000,scr,SCRSIZE,200,200);
      line (x,y,64,32,0);}
   return 0;
}


draw_enemy(x,y,d) 
int x,y,d;
{
   setbase(scr); 
   line(x-d,y,x,y-d, 1);
   line(x,y-d,x+d,y, 1);
   line(x+d,y,x,y+d, 1);
   line(x,y+d,x-d,y, 1);
   line(x-d,y-d,x-d,y+d, 1);
   line(x+d,y-d,x+d,y+d, 1);
   plot(x,y,3);
   if (d>20){
      line(x-2,y-2,x+2,y-2,3);
      line(x-2,y+2,x+2,y+2,3);}
   if (d>9){
      line(x-2,y-1,x+2,y-1,3);
      line(x-2,y,x+2,y,3);
      line(x-2,y+1,x+2,y+1,3);}
   soundcopy(0x7000,scr,SCRSIZE,0,0);
   line(x-d,y,x,y-d, 0);
   line(x,y-d,x+d,y, 0);
   line(x+d,y,x,y+d, 0);
   line(x,y+d,x-d,y, 0);
   line(x-d,y-d,x-d,y+d, 0);
   line(x+d,y-d,x+d,y+d, 0);  
   plot(x,y,0);
   if (d>20){
      line(x-2,y-2,x+2,y-2,0);
      line(x-2,y+2,x+2,y+2,0);}
   if (d>9){
      line(x-2,y-1,x+2,y-1,0);
      line(x-2,y,x+2,y,0);
      line(x-2,y+1,x+2,y+1,0);}
   return 0;
}


draw_target() {
   setbase(scr); 
   line(64,25,64,30, 2);
   line(64,34,64,39, 2);
   line(55,32,61,32, 2);
   line(67,32,73,32, 2);
   plot(62,30,2);
   plot(66,34,2);
   plot(62,34,2);
   plot(66,30,2);
   plot(61,31,2);
   plot(67,33,2);
   plot(61,33,2);
   plot(67,31,2);

   return 0;
}


draw_lives(lives)
int lives;
{  
   int i;
   setbase(scr); 
   for (i=0;i<lives;i++){
      line (125,2+(i*4),127,2+(i*4),0);
      plot (124,2+((i*4)+1),0);
      plot (127,2+((i*4)+1),0);
      line (123,2+((i*4)+2),127,2+((i*4)+2),0);

      line (125,2+(i*4),127,2+(i*4),2);
      plot (124,2+((i*4)+1),2);
      plot (127,2+((i*4)+1),2);
      line (123,2+((i*4)+2),127,2+((i*4)+2),2);
      }
   return 0; 
}


draw_enemies(enemies)
int enemies;
{
   int i;
   setbase(scr); 
   for (i=0;i<enemies;i++){
      plot (120,2+(i*4)    ,0);
      plot (122,2+(i*4)    ,0);
      plot (121,2+((i*4)+1),0);
      plot (120,2+((i*4)+2),0);
      plot (122,2+((i*4)+2),0);

      plot (120,2+(i*4)    ,1);
      plot (122,2+(i*4)    ,1);
      plot (121,2+((i*4)+1),3);
      plot (120,2+((i*4)+2),1);
      plot (122,2+((i*4)+2),1);
      }
   return 0;
}


draw_damage(damage)
int damage;
{
   setbase(scr); 
   line (0,0,127,0,0);
   line (0,0,damage,0,1);
   return 0;
}
/*----------------------------------------------------------*/