#define SCRSIZE     	2048 
#define stars		40
char scr[128*64];
/* char scr2[128*64*2]; */
char *mem;
main(argc, argv)
int argc;
int *argv;

{	
	int a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,x,y,z;
	int s[stars];
	int t[stars];
	int u[stars];
	int v[stars];
	int w[stars];
    	mode(1);

	i=0;
        z=1;
	for (i=0;i<stars;i++){
	   s[i]=63;
	   t[i]=32;
	   u[i]=rand(4);
	   v[i]=rand(5);
	   w[i]=rand(4);}
	setbase(scr); 
	asm("di\n");
	bgrd(1);
	while(!(z==2)){          
	   i++;
	   if (i>(stars-1)){
	      i=0;
	      memcpy(0x7000,scr,2048);
 	      memset (scr, 0 , 2048); 
	       }

 	   if ((s[i]<0)||(s[i]>127)||(t[i]<0)||(t[i]>63)){
	      s[i]= 63;
	      t[i]= 31;

	      u[i]=rand(4);
	      v[i]=rand(4)+1;
	      w[i]=rand(3)+1;}
     
           if (u[i]==0){
	      s[i]=s[i]-v[i];
	      t[i]=t[i]-w[i];}
	   if (u[i]==1){
	      s[i]=s[i]+v[i];
	      t[i]=t[i]-w[i];}
	   if (u[i]==2){
	      s[i]=s[i]-v[i];
	      t[i]=t[i]+w[i];}
	   if (u[i]==3){
	      s[i]=s[i]+v[i];
	      t[i]=t[i]+w[i];}
	
	   plot (s[i]  ,t[i]  ,3);

	}	
}
}