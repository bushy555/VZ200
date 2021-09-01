
/* Star War by Geoff Williams (c) 2001 */

main(argc, argv)
int argc;
int *argv;
{
      int i, j, x, y, xmv, ymv, d, dmv, loop, lives, enemies;
      x=64;y=32;d=5;xmv=1;ymv=1;dmv=1;lives=5;enemies=5;      
        setbase(0x7000);
      mode(0);
      printf("\n\n\n\n\n\n\n\n   WELCOME TO STAR WAR\n");
      printf("   PREPARE FOR BATTLE\n\n");
      printf("- PRESS ANY KEY TO START -\n");
      getch();
      while(inch())
        ;
      rand(0);
        mode(1);



/* Main Loop */

      for (i = 0; i < 5000; i++) {
            draw_enemy(x,y,d);
            draw_target();
            j = rand(30);
                if (j == 5) {
                   enemy_fire(x,y);
                }
            j = rand(30);
                if (j == 5) {
                   fire();
                }
            j = rand(20);
                if (j == 5) {
                   xmv=rand(4)-2;
                }
            j = rand(20);
                if (j == 5) {
                   ymv=rand(4)-2;
            }
            j = rand(10);
                if (j == 5) {
                   dmv=rand(2)-1;
                }
                if (d<1) {dmv=1;}
                if (d>30) {dmv=-1; sound (100,6);}
                if (x<10) {x=x+110;}
                if (x>120) {x=x-100;}
            if (y<10) {y=y+50;}
            if (y>60) {y=y-50;}
                x=x+xmv;
                y=y+ymv;
      
      d=d+dmv;                                               
            loop++;
                if (loop == 50) {

                  draw_lives(lives);
                  draw_enemies(enemies);
                  loop=0;
                }

        }

      sound(100,6);
      getch();
        mode(0);
        bgrd(0);
        return 0;
}

fire() {

        int i;

            line (0,1,64,32,3);
            line (127,1,64,32,3);
            line (0,63,64,32,3);
            line (127,63,64,32,3);

            sound(5000,1);

            line (0,1,64,32,0);
            line (127,1,64,32,0);
            line (0,63,64,32,0);
            line (127,63,64,32,0);
      

      return 0;
}

enemy_fire(x,y) 

int x,y;

{
        int i;
      for (i=1;i<3;i++) { 
            
            
            line (x,y,64,32,3);
              sound(30,2);
            line (x,y,64,32,0);
            
      }
      return 0;
}

draw_enemy(x,y,d) 

int x,y,d;

{

      int delay;

      line(x-d,y,x,y-d, 1);
      line(x,y-d,x+d,y, 1);
      line(x+d,y,x,y+d, 1);
      line(x,y+d,x-d,y, 1);
      line(x-d,y-d,x-d,y+d, 1);
      line(x+d,y-d,x+d,y+d, 1);

      
      for (delay = 0; delay < 2; delay++)
      {

        }

      line(x-d,y,x,y-d, 0);
      line(x,y-d,x+d,y, 0);
      line(x+d,y,x,y+d, 0);
      line(x,y+d,x-d,y, 0);
      line(x-d,y-d,x-d,y+d, 0);
      line(x+d,y-d,x+d,y+d, 0);


      return 0;
}

draw_target() {

      line(64,25,64,30,2);
      line(64,34,64,39,2);
      line(55,32,60,32, 2);
      line(68,32,73,32, 2);


      return 0;
}

draw_lives(lives)
int lives;

{

      line (5,0,50,0,0);
      line (5,1,50,1,0);

      line (5,0,50,0,2);
      line (5,1,50,1,2);


      return 0;
}

draw_enemies(enemies)
int enemies;

{

line (64,0,120,0,0);
line (64,1,120,1,0);

line (64,0,120,0,1);
line (64,1,120,1,1);

return 0;
}