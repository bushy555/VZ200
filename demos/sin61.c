
 
 #include <vz.h>
 #include <graphics.h>
 #include <stdio.h>
 #include <sound.h>
 #include <stdlib.h>
 #include <ctype.h>
 #include <strings.h>
 #include <conio.h>
 #include <math.h>
 
 #define speed 1
 #define xcent 64
 #define ycent 32
 #define NOSTARS 15
 #define ZCONST 1
 
 #define PI 3.141592654
 double degree[360];
 double sinvals[360];
 double cosvals[360];
 
 #define getrandom( min, max ) ((rand() % (int)(((max)+1) - (min))) + (min))
 short coords[3*NOSTARS];
 
void main()
 {
     short i=1,x,y,z,counter,page;
     double radian;
     char buffer[80];
     long colors[5]= {0x000000,0x0221111,0x0332222,0x03f3333,0x03f0000};
     clg();
     printf("\nsinus stars in the sky\n");
     printf("please wait.");
     srand(1);
 
     for(counter=0;counter<360;counter++)
     {
     	radian=counter * PI / 180;
     	degree[counter]=radian;
     }
     printf(".");
     for(counter=0;counter<360;counter++)
     {
     	sinvals[counter]=sin(degree[counter*speed]);
     	cosvals[counter]=cos(degree[counter*speed]);
     }
     printf(".");
     for(counter=0;counter<NOSTARS*3;counter+=3)
     {
     	x=getrandom(-40,40);
     	y=getrandom(-40,40);
     	z=getrandom(-40,40);
     	coords[counter] = x;
     	coords[counter+1] = y;
     	coords[counter+2] = z;
     }
     printf("."); 
     vz_mode(1);
     asm("di\n");
     vz_setbase(0xa000);
//     vz_setbase(0x7000);
//     memset(0x7000,170,2048);
//     memset(0xA000,170,2048);
     while(!kbhit())
     {

//     register short x,y,z,x2,y2,z2,x3,y3,z3;
     register short x2,y2,z2,x3,y3,z3;
//     short counter,counter2,angle1,angle2,angle3;
     short counter2,angle1,angle2,angle3;
     char key;
     int coloura;
 
     for(angle1=0,angle2=0;angle1<360;angle1++)
     {
     	for(counter2=0;counter2<3*NOSTARS;counter2+=3)
 	{
// 	   x = coords[counter2];
// 	   y = coords[counter2+1];
// 	   z = coords[counter2+2];
//  	   x2= coords[counter2] * cosvals[angle1] + coords[counter2+1] * sinvals[angle1];
// 	   y2= coords[counter2] * sinvals[angle1] - coords[counter2+1] * cosvals[angle1];
 	   x3= (coords[counter2] * cosvals[angle1] + coords[counter2+1] * sinvals[angle1] * cosvals[angle1] + coords[counter2+2] * sinvals[angle1]) + xcent;
// 	   z2= coords[counter2] * cosvals[angle1] + coords[counter2+1] * sinvals[angle1] * sinvals[angle1] - coords[counter2+2] * cosvals[angle1];
 	   y3= (coords[counter2] * sinvals[angle1] - coords[counter2+1] * cosvals[angle1] * cosvals[angle1] + coords[counter2] * cosvals[angle1] + coords[counter2+1] * sinvals[angle1] * sinvals[angle1] - coords[counter2+2] * cosvals[angle1] * sinvals[angle1]) + ycent;
 	   z3= coords[counter2] * sinvals[angle1] - coords[counter2+1] * cosvals[angle1] * sinvals[angle1] - coords[counter2] * cosvals[angle1] + coords[counter2+1] * sinvals[angle1] * sinvals[angle1] - coords[counter2+2] * cosvals[angle1] * cosvals[angle1];
//  	   x3=x3/ZCONST;
// 	   y3=y3/ZCONST;
//  	   x3+=xcent;
// 	   y3+=ycent;
//   	   if(z3<0)
// 	       coloura = 1;
//  	   if(z3>0)
// 	       coloura = 2;
//      	   if(z3>50)
//  	       coloura = 3;
//	   vz_plot(x3,y3,coloura);
	   vz_plot(x3,y3,3);
 	}
//	clg();
     memcpy(0x7000,0xa000,2048);
//     memset(0xa000, 170, 2048);
     memset(0xa000, 0, 2048);
	
}


//     memcpy(0x7000,0xa000,2048);
//     memset(0xa000, 170, 2048);

}
     clg();
}
