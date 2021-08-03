
char *mem;
main(argc, argv)
int argc;
int *argv;
{
	int a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,x,y,z;

	x=64;y=58;	
	setbase(0xF000);
    	mode(1);
	asm("di\n");

	for(i=0 ;i<10 ;i++){		memset(0xE000+(i*32),170,32);}
	for(i=10;i<20;i++){		memset(0xE000+(i*32),255,32);}
	for(i=20;i<30;i++){		memset(0xE000+(i*32),170,32);}
	for(i=30;i<40;i++){		memset(0xE000+(i*32),255,32);}
	for(i=40;i<50;i++){		memset(0xE000+(i*32),170,32);}
	for(i=50;i<60;i++){		memset(0xE000+(i*32),255,32);}
	for(i=60;i<64;i++){		memset(0xE000+(i*32),170,32);}
	z=1;
	a=32;b=18;k=1;l=1;
	c=40;d=24;m=1;n=1;
	e=48;f=30;o=1;p=1;
	g=56;h=36;q=1;r=1;
	while(z==1){
		for(j=0;j<4;j++){

		for(i=0;i<10;i++){			memset(0xE000+(i*32)+31,255,1);					}
		for(i=10;i<20;i++){			memset(0xE000+(i*32)   ,170,1);					}	
		for(i=20;i<30;i++){			memset(0xE000+(i*32)+31,255,1);					}
		for(i=30;i<40;i++){			memset(0xE000+(i*32)   ,170,1);					}	
		for(i=40;i<50;i++){			memset(0xE000+(i*32)+31,255,1);					}
		for(i=50;i<60;i++){			memset(0xE000+(i*32)   ,170,1);					}	
		for(i=60;i<64;i++){			memset(0xE000+(i*32)+31,255,1);					}

		for(i=0;i<10;i++){			memcpy(0xE800+(i*32),0xE000+1+(i*32),31);			}
		for(i=10;i<20;i++){			memcpy(0xE800+1+(i*32),0xE000+(i*32),31);			}
		for(i=20;i<30;i++){			memcpy(0xE800+(i*32),0xE000+1+(i*32),31);			}	
		for(i=30;i<40;i++){			memcpy(0xE800+1+(i*32),0xE000+(i*32),31);			}		
		for(i=40;i<50;i++){			memcpy(0xE800+(i*32),0xE000+1+(i*32),31);			}	
		for(i=50;i<60;i++){			memcpy(0xE800+1+(i*32),0xE000+(i*32),31);			}		
		for(i=60;i<64;i++){			memcpy(0xE800+(i*32),0xE000+1+(i*32),31);			}	
		
		memcpy(0xF000,0xE800,2048);
		memcpy(0xE000,0xE800,2048);

	a=a+k;
	b=b+l;
	if(a>120){k=-1;}
	if(a<10){k=1;}
	if(b>50){l=-1;}
	if(b<10){l=1;}

	c=c+m;
	d=d+n;
	if(c>120){m=-1;}
	if(c<10){m=1;}
	if(d>50){n=-1;}
	if(d<10){n=1;}

	e=e+o;
	f=f+p;
	if(e>120){o=-1;}
	if(e<10){o=1;}
	if(f>50){p=-1;}
	if(f<10){p=1;}

	g=g+q;
	h=h+r;
	if(g>120){q=-1;}
	if(g<10){q=1;}
	if(h>50){r=-1;}
	if(h<10){r=1;}

	draw_string(a,b,1,"V");
	draw_string(c,d,1,"Z");

		memcpy(0x7000,0xF000,2048);
		}


		for(j=0;j<4;j++){

		for(i=0;i<10;i++){			memset(0xE000+(i*32)+31,170,1);					}
		for(i=10;i<20;i++){			memset(0xE000+(i*32)   ,255,1);					}	
		for(i=20;i<30;i++){			memset(0xE000+(i*32)+31,170,1);					}
		for(i=30;i<40;i++){			memset(0xE000+(i*32)   ,255,1);					}	
		for(i=40;i<50;i++){			memset(0xE000+(i*32)+31,170,1);					}
		for(i=50;i<60;i++){			memset(0xE000+(i*32)   ,255,1);					}	
		for(i=60;i<64;i++){			memset(0xE000+(i*32)+31,170,1);					}

		for(i=0;i<10;i++){			memcpy(0xE800+(i*32),0xE000+1+(i*32),31);			}
		for(i=10;i<20;i++){			memcpy(0xE800+1+(i*32),0xE000+(i*32),31);			}
		for(i=20;i<30;i++){			memcpy(0xE800+(i*32),0xE000+1+(i*32),31);			}	
		for(i=30;i<40;i++){			memcpy(0xE800+1+(i*32),0xE000+(i*32),31);			}		
		for(i=40;i<50;i++){			memcpy(0xE800+(i*32),0xE000+1+(i*32),31);			}	
		for(i=50;i<60;i++){			memcpy(0xE800+1+(i*32),0xE000+(i*32),31);			}		
		for(i=60;i<64;i++){			memcpy(0xE800+(i*32),0xE000+1+(i*32),31);			}	
		
		memcpy(0xF000,0xE800,2048);
		memcpy(0xE000,0xE800,2048);

	a=a+k;
	b=b+l;
	if(a>120){k=-1;}
	if(a<10){k=1;}
	if(b>50){l=-1;}
	if(b<10){l=1;}

	c=c+m;
	d=d+n;
	if(c>120){m=-1;}
	if(c<10){m=1;}
	if(d>50){n=-1;}
	if(d<10){n=1;}

	e=e+o;
	f=f+p;
	if(e>120){o=-1;}
	if(e<10){o=1;}
	if(f>50){p=-1;}
	if(f<10){p=1;}

	g=g+q;
	h=h+r;
	if(g>120){q=-1;}
	if(g<10){q=1;}
	if(h>50){r=-1;}
	if(h<10){r=1;}

	draw_string(a,b,1,"D");
	draw_string(c,d,1,"E");
	draw_string(e,f,1,"M");
	draw_string(g,h,1,"O");
		memcpy(0x7000,0xF000,2048);
	
		}
	}
}



draw_string(x,y,color,src)
int x,y,color;
char *src;
{	while (*src)	{
	   char_draw(x,y,color,*src);
	   x += 6;
           src++;	}}
