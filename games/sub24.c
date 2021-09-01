
char *mem;
main(argc, argv)
int argc;
int *argv;
{
	int a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,x,y,x2,y2,z;
	int life,fire,fpx,fpy,dir,diver,cntr;

	m=1;a=0;life=3;x=64;y=58;	
	setbase(0x7000);
    	mode(1);
	asm("di\n");
	memset(0x7000,170,2048);
poke(0x70A1,169);poke(0x70A2,85);poke(0x70A3,86);poke(0x70A5,85);poke(0x70A6,169);poke(0x70A7,86);
poke(0x70A8,165);poke(0x70A9,85);poke(0x70AA,86);poke(0x70AC,149);poke(0x70AD,90);poke(0x70AE,165);
poke(0x70AF,86);poke(0x70B1,85);poke(0x70B2,90);poke(0x70B4,85);poke(0x70B5,85);poke(0x70B6,106);
poke(0x70B7,165);poke(0x70B8,90);poke(0x70B9,165);poke(0x70BA,106);poke(0x70BB,149);poke(0x70BD,85);
poke(0x70BE,86);poke(0x70C1,165);poke(0x70C2,90);poke(0x70C3,149);poke(0x70C5,85);poke(0x70C6,169);
poke(0x70C7,86);poke(0x70C8,165);poke(0x70C9,90);poke(0x70CA,149);poke(0x70CB,106);poke(0x70CC,149);
poke(0x70CD,86);poke(0x70CE,165);poke(0x70CF,86);poke(0x70D0,169);poke(0x70D1,86);poke(0x70D2,86);
poke(0x70D4,86);poke(0x70D5,165);poke(0x70D6,90);poke(0x70D7,165);poke(0x70D8,90);poke(0x70D9,165);
poke(0x70DA,90);poke(0x70DB,149);poke(0x70DD,85);poke(0x70E1,165);poke(0x70E2,90);poke(0x70E5,85);
poke(0x70E6,169);poke(0x70E7,86);poke(0x70E8,165);poke(0x70E9,90);poke(0x70EA,149);poke(0x70EB,106);
poke(0x70EC,149);poke(0x70ED,86);poke(0x70EE,149);poke(0x70EF,86);poke(0x70F0,169);poke(0x70F1,86);
poke(0x70F2,86);poke(0x70F4,86);poke(0x70F5,165);poke(0x70F6,90);poke(0x70F7,165);poke(0x70F8,90);
poke(0x70F9,165);poke(0x70FA,90);poke(0x70FB,85);poke(0x70FD,85);poke(0x7101,169);poke(0x7102,86);
poke(0x7105,85);poke(0x7106,169);poke(0x7107,86);poke(0x7108,165);poke(0x7109,90);poke(0x710A,149);
poke(0x710C,149);poke(0x710D,101);poke(0x710E,153);poke(0x710F,86);poke(0x7110,169);poke(0x7111,90);
poke(0x7112,150);poke(0x7114,86);poke(0x7115,165);poke(0x7116,90);poke(0x7117,165);poke(0x7118,90);
poke(0x7119,165);poke(0x711A,86);poke(0x711B,85);poke(0x711D,85);poke(0x7122,149);poke(0x7123,90);
poke(0x7125,85);poke(0x7126,169);poke(0x7127,86);poke(0x7128,165);poke(0x7129,85);poke(0x712A,90);
poke(0x712C,149);poke(0x712D,101);poke(0x712E,153);poke(0x712F,86);poke(0x7130,169);poke(0x7131,90);
poke(0x7132,150);poke(0x7134,85);poke(0x7135,86);poke(0x7137,165);poke(0x7138,90);poke(0x7139,165);
poke(0x713A,86);poke(0x713B,85);poke(0x713D,85);poke(0x713E,86);poke(0x7142,169);poke(0x7143,85);
poke(0x7145,85);poke(0x7146,169);poke(0x7147,86);poke(0x7148,165);poke(0x7149,90);poke(0x714A,149);
poke(0x714C,149);poke(0x714D,101);poke(0x714E,105);poke(0x714F,86);poke(0x7150,165);poke(0x7151,90);
poke(0x7152,149);poke(0x7154,86);poke(0x7155,165);poke(0x7157,165);poke(0x7158,90);poke(0x7159,165);
poke(0x715A,89);poke(0x715B,85);poke(0x715D,85);poke(0x7163,149);poke(0x7164,106);poke(0x7165,85);
poke(0x7166,169);poke(0x7167,86);poke(0x7168,165);poke(0x7169,90);poke(0x716A,149);poke(0x716B,106);
poke(0x716C,149);poke(0x716D,101);poke(0x716E,105);poke(0x716F,86);poke(0x7170,165);poke(0x7171,90);
poke(0x7172,149);poke(0x7174,86);poke(0x7175,165);poke(0x7176,90);poke(0x7177,165);poke(0x7178,90);
poke(0x7179,165);poke(0x717A,90);poke(0x717B,85);poke(0x717D,85);poke(0x7181,165);poke(0x7182,90);poke(0x7183,165);
poke(0x7184,106);poke(0x7185,85);poke(0x7186,169);poke(0x7187,86);poke(0x7188,165);poke(0x7189,90);
poke(0x718A,149);poke(0x718B,106);poke(0x718C,149);poke(0x718D,169);poke(0x718E,105);poke(0x718F,86);
poke(0x7190,165);poke(0x7191,85);poke(0x7192,85);poke(0x7194,86);poke(0x7195,165);poke(0x7196,90);
poke(0x7197,165);poke(0x7198,90);poke(0x7199,165);poke(0x719A,90);poke(0x719B,85);poke(0x719D,85);
poke(0x71A1,165);poke(0x71A2,90);poke(0x71A3,149);poke(0x71A4,106);poke(0x71A5,149);poke(0x71A6,169);
poke(0x71A7,90);poke(0x71A8,165);poke(0x71A9,90);poke(0x71AA,149);poke(0x71AB,106);poke(0x71AC,149);
poke(0x71AD,169);poke(0x71AE,105);poke(0x71AF,86);poke(0x71B0,165);poke(0x71B1,106);poke(0x71B2,149);
poke(0x71B4,86);poke(0x71B5,165);poke(0x71B6,90);poke(0x71B7,165);poke(0x71B8,90);poke(0x71B9,165);
poke(0x71BA,90);poke(0x71BB,149);poke(0x71BD,85);poke(0x71C2,85);poke(0x71C3,85);poke(0x71C5,165);
poke(0x71C6,85);poke(0x71C7,106);poke(0x71C8,165);poke(0x71C9,85);poke(0x71CA,85);poke(0x71CC,149);
poke(0x71CD,169);poke(0x71CE,169);poke(0x71CF,86);poke(0x71D0,149);poke(0x71D1,106);poke(0x71D2,149);
poke(0x71D3,106);poke(0x71D4,86);poke(0x71D5,165);poke(0x71D6,90);poke(0x71D7,165);poke(0x71D8,90);
poke(0x71D9,165);poke(0x71DA,90);poke(0x71DB,149);poke(0x71DD,85);poke(0x71DE,85);poke(0x725D,168);
poke(0x7299,162);poke(0x729D,162);poke(0x72D9,168);poke(0x72DD,168);poke(0x7319,162);poke(0x731D,162);
poke(0x7359,168);poke(0x735D,168);poke(0x7399,162);poke(0x741A,42);poke(0x743D,168);poke(0x7459,168);
poke(0x747D,162);poke(0x749A,42);poke(0x74BD,168);poke(0x74D9,168);poke(0x74FD,162);poke(0x757A,138);
poke(0x759E,42);poke(0x75BA,42);poke(0x75C7,166);poke(0x75C8,106);poke(0x75DD,168);poke(0x75FA,138);
poke(0x7607,166);poke(0x7608,98);poke(0x7609,42);poke(0x760D,169);poke(0x760E,106);poke(0x761E,42);
poke(0x762D,169);poke(0x763A,42);poke(0x7648,97);poke(0x7649,34);poke(0x764D,169);poke(0x7669,154);
poke(0x766C,85);poke(0x766D,85);poke(0x766E,85);poke(0x766F,86);poke(0x7688,161);poke(0x7689,33);
poke(0x768A,34);poke(0x768B,153);poke(0x768C,106);poke(0x768F,165);poke(0x76A9,154);poke(0x76AB,149);
poke(0x76AD,169);poke(0x76AE,153);poke(0x76AF,169);poke(0x76B0,106);poke(0x76BD,168);poke(0x76C9,33);
poke(0x76CA,34);poke(0x76CB,153);poke(0x76CC,106);poke(0x76CF,165);poke(0x76EC,85);poke(0x76ED,85);
poke(0x76EE,85);poke(0x76EF,86);poke(0x76FA,138);poke(0x76FE,42);poke(0x7709,162);poke(0x773A,42);
poke(0x773D,168);poke(0x777A,138);poke(0x7783,171);poke(0x7784,171);poke(0x7795,171);poke(0x7796,234);
poke(0x77A0,110);poke(0x77A3,234);poke(0x77A4,235);poke(0x77A5,234);poke(0x77A6,58);poke(0x77AA,90);
poke(0x77AB,42);poke(0x77B0,174);poke(0x77B2,42);poke(0x77B5,138);poke(0x77B6,194);poke(0x77BB,168);
poke(0x77BC,143);poke(0x77BD,224);poke(0x77BE,130);poke(0x77C0,151);poke(0x77C1,168);poke(0x77C2,84);
poke(0x77C3,50);poke(0x77C4,84);poke(0x77C5,42);poke(0x77C6,83);poke(0x77C7,252);poke(0x77C8,253);
poke(0x77C9,117);poke(0x77CA,69);poke(0x77CB,138);poke(0x77CC,191);poke(0x77CD,192);poke(0x77CE,171);
poke(0x77CF,248);poke(0x77D0,71);poke(0x77D1,129);poke(0x77D2,10);poke(0x77D4,129);poke(0x77D5,7);
poke(0x77D6,124);poke(0x77D7,22);poke(0x77D8,41);poke(0x77D9,64);poke(0x77DA,133);poke(0x77DB,85);
poke(0x77DC,75);poke(0x77DD,241);poke(0x77DE,82);poke(0x77DF,149);poke(0x77E0,169);poke(0x77E1,84);
poke(0x77E2,134);poke(0x77E3,89);poke(0x77E4,149);poke(0x77E5,9);poke(0x77E6,85);poke(0x77E7,126);
poke(0x77E8,85);poke(0x77E9,191);poke(0x77EA,9);poke(0x77EB,82);poke(0x77EC,181);poke(0x77ED,85);
poke(0x77EE,83);poke(0x77EF,213);poke(0x77F0,79);poke(0x77F1,245);poke(0x77F2,85);poke(0x77F3,165);
poke(0x77F4,133);poke(0x77F5,15);poke(0x77F6,93);poke(0x77F7,88);poke(0x77F8,86);poke(0x77F9,165);
poke(0x77FA,86);poke(0x77FC,85);poke(0x77FD,85);
draw_string(1,37,0,"Hit <s> when ready");
memcpy(0xE000,0x7000,2048);
memcpy(0xE800,0x7000,2048);

	b=1;
	f=0;
	do{
		if((mem[0x68fd] & 0x2) == 0) {j=1;break;}
		for(i=60;i<64;i++){
			memcpy(0xE800+(i*32),0xE000+1+(i*32),31);
			mem[(0xE800+31+(i*32))] = mem[(0xE800+(i*32))];
		}		
		memcpy(0xE000,0xE800,2048);
		memcpy(0xF000,0xE800,2048);
		if(b==1){
 			c++;
			if(c==14) {b=0;}
			memset(0xF000+(c*32),0,32);
		}
		if(b==0){
			c--;
			if(c==4 ) {b=1;}
 			for(i=0;i<32;i++){
				d=mem[0xF000+(c*32)+i];
/*
				if (d == 170){poke((0xF000+i)+(c*32),0);} 
				if (d == 169){poke((0xF000+i)+(c*32),1);} 
				if (d == 165){poke((0xF000+i)+(c*32),5);}
				if (d == 166){poke((0xF000+i)+(c*32),4);}
				if (d == 154){poke((0xF000+i)+(c*32),16);}
				if (d == 153){poke((0xF000+i)+(c*32),17);}
				if (d == 150){poke((0xF000+i)+(c*32),20);}
				if (d == 149){poke((0xF000+i)+(c*32),21);}
*/

				if (d==106){poke(0xF000+(c*32)+i,64);}
				if (d==105){poke(0xF000+(c*32)+i,65);}
				if (d==102){poke(0xF000+(c*32)+i,68);}
				if (d==101){poke(0xF000+(c*32)+i,69);}
				if (d==90) {poke(0xF000+(c*32)+i,80);}
				if (d==89) {poke(0xF000+(c*32)+i,81);}
				if (d==86) {poke(0xF000+(c*32)+i,84);}
			}
		}
		e++;
		if (e==5){for (i=19;i<60;i++){
				mem[0xE800+29+(i*32)+32] = mem[0x7000+29+(i*32)];
				mem[0xE800+30+(i*32)+32] = mem[0x7000+30+(i*32)];
				mem[0xE800+25+(i*32)+32] = mem[0x7000+25+(i*32)]; 
				mem[0xE800+26+(i*32)+32] = mem[0x7000+26+(i*32)]; 
				draw_string(31,37,3,"s");}}
		if (e==10){for (i=19;i<60;i++){
				mem[0xE800+29+(i*32)-32] = mem[0x7000+29+(i*32)];
				mem[0xE800+30+(i*32)-32] = mem[0x7000+30+(i*32)]; 
				mem[0xE800+25+(i*32)-32] = mem[0x7000+25+(i*32)]; 
				mem[0xE800+26+(i*32)-32] = mem[0x7000+26+(i*32)]; }}
		if (e==15){for (i=19;i<60;i++){
				mem[0xE800+29+(i*32)-64] = mem[0x7000+29+(i*32)];
				mem[0xE800+30+(i*32)-64] = mem[0x7000+30+(i*32)]; 
				mem[0xE800+25+(i*32)-64] = mem[0x7000+25+(i*32)]; 
				mem[0xE800+26+(i*32)-64] = mem[0x7000+26+(i*32)]; }
			poke(0xEE27+34,152);poke(0xEE47,102);poke(0xEE28+97,102);poke(0xEE29+127,153);
		

		}
		if (e==20){
			for (i=19;i<60;i++){
				mem[0xE800+29+(i*32)+64] = mem[0x7000+29+(i*32)];
				mem[0xE800+30+(i*32)+64] = mem[0x7000+30+(i*32)]; 
				mem[0xE800+25+(i*32)+64] = mem[0x7000+25+(i*32)]; 
				mem[0xE800+26+(i*32)+64] = mem[0x7000+26+(i*32)]; 
			}
			poke(0xEE27+34,102);poke(0xEE47,152);poke(0xEE28+97,153);poke(0xEE29+127,102);
			g++;
			e=0;
		}
		if ((g>3) && (g<34) && (f==0)){
			for(i=45;i<60;i++){memcpy(0xE800+2+(i*32)+1,  0x7000+2+(i*32), 33-g);}
		}
		if(g==36){f=1;}
		memcpy(0x7000,0xF000,2048);
		for(a=0;a<120;a++){;}
	} while (j==0);
	memcpy(0xE000,0x7000,2048);
	memset(0xE800,170     ,2048);
	setbase(0xE800);
	draw_string(15,14,1," < M >   =  LEFT");
	draw_string(15,20,1," < , >   =  RIGHT");
	draw_string(15,26,1,"< SPC >  =  FIRE");
	draw_string(15,34,1,"SCORE: ");
	draw_string(5,45,3,"HIT <SPACE> TO PLAY");



/* -------------------------------------------------------- */
/*          DO A SPLIT VERTICAL SCREEN. CENTRE OUTWARDS     */
/* -------------------------------------------------------- */
	for(i=0;i<17;i++){
		for(j=0;j<64;j++){
			memcpy(0x7000+(j*32)     ,0xE000+(j*32)+i   ,17-i);
			memcpy(0x7000+(j*32)+17-i,0xE800+(j*32)+17-i,i+1); 
			memcpy(0x7000+(j*32)+i+15,0xE000+(j*32)+15  ,17-i); 
			memcpy(0x7000+(j*32)+15  ,0xE800+(j*32)+15  ,i+1); 
		}
	}


/* -------------------------------------------------------- */
/*          INSTRUCTIONS                                    */
/* -------------------------------------------------------- */
	memcpy(0x7000,0xE800,2048);
	j=0;
	do{if((mem[0x68ef] & 16) == 0) {j=1;break;}
	} while (j==0);
	memcpy(0xF000,0x7000,2048);


/* -------------------------------------------------------- */
/*          DRAW SHIP                                       */
/* -------------------------------------------------------- */
	memset(0xE000,0,4096);

poke(0xE418,7);poke(0xE419,255);poke(0xE438,7);poke(0xE439,255);poke(0xE458,4);poke(0xE478,68);poke(0xE479,64);
poke(0xE498,21);poke(0xE4B8,4);poke(0xE4BC,1);poke(0xE4BD,252);poke(0xE4D8,4);poke(0xE4DC,1);poke(0xE4F8,4);
poke(0xE4FC,21);poke(0xE4FD,80);poke(0xE515,4);poke(0xE517,1);poke(0xE518,85);poke(0xE519,80);poke(0xE51C,1);
poke(0xE535,85);poke(0xE536,64);poke(0xE538,4);poke(0xE53C,1);poke(0xE555,4);poke(0xE558,4);poke(0xE55C,1);
poke(0xE575,4);poke(0xE578,4);poke(0xE57C,85);poke(0xE57D,84);poke(0xE595,4);poke(0xE598,4);poke(0xE59A,2);
poke(0xE59C,1);poke(0xE5B5,4);poke(0xE5B7,5);poke(0xE5B8,85);poke(0xE5B9,84);poke(0xE5BA,42);poke(0xE5BB,128);
poke(0xE5BC,1);poke(0xE5D4,1);poke(0xE5D5,85);poke(0xE5D6,80);poke(0xE5D8,4);poke(0xE5DA,22);poke(0xE5DB,128);
poke(0xE5DC,1);poke(0xE5F5,4);poke(0xE5F6,3);poke(0xE5F7,128);poke(0xE5F8,4);poke(0xE5FA,170);poke(0xE5FB,161);
poke(0xE5FC,85);poke(0xE5FD,85);poke(0xE5FF,7);poke(0xE615,4);poke(0xE616,15);poke(0xE617,224);poke(0xE618,4);
poke(0xE61A,90);poke(0xE61B,160);poke(0xE61C,1);poke(0xE61F,31);poke(0xE632,5);poke(0xE633,84);poke(0xE635,85);
poke(0xE636,74);poke(0xE637,97);poke(0xE638,85);poke(0xE639,80);poke(0xE63A,170);poke(0xE63B,96);poke(0xE63C,85);
poke(0xE63D,84);poke(0xE63F,16);poke(0xE653,21);poke(0xE654,85);poke(0xE655,85);poke(0xE656,85);poke(0xE657,85);
poke(0xE658,85);poke(0xE659,85);poke(0xE65A,85);poke(0xE65B,85);poke(0xE65C,85);poke(0xE65D,85);poke(0xE65E,85);
poke(0xE65F,64);poke(0xE673,1);poke(0xE674,85);poke(0xE675,81);poke(0xE676,81);poke(0xE677,81);poke(0xE678,81);
poke(0xE679,81);poke(0xE67A,81);poke(0xE67B,81);poke(0xE67C,81);poke(0xE67D,81);poke(0xE67E,85);poke(0xE67F,64);
poke(0xE694,5);poke(0xE695,85);memset(0xE696,21,9);poke(0xE69F,64);memset(0xE6B5,85,10);


/* ------------------------------------------------------------------------------------------ */
/* Moves the ship from the position in 'hackers delight' picture to top of right hand screen  */
/* ------------------------------------------------------------------------------------------ */

	for(j=32;j<54;j++){
		for(i=19;i<32;i++){
			memcpy((0xE000+i)+((j-32)*32), (0xE000+i)+(j*32), 1);
		}
	}
	memset(0xE000+((54-32)*32),170,(64-(54-32))*32);
	memcpy(0xE800,0xE000,2048);


/* -------------------------------------------------------- */
/*          DO A SPLIT HORIZONTAL SCREEN. CENTRE OUTWARDS   */
/* -------------------------------------------------------- */
	for(i=0;i<31;i++){
			memcpy(0x7000                 , 0xF000+32           , 1024-(i*32));  
			memcpy(0x7000+0x0400-(i*32)   , 0xE800+0x0400-(i*32), 32);
			memcpy(0x7000+0x0400+32       , 0xF000+0x0400       , 1024-(i*32));
			memcpy(0x7000+0x0400+(i*32)   , 0xE800+0x0400+(i*32), 32);
			memcpy(0xF000                 , 0x7000              , 2048);
	}


	setbase(0xE000);
	a=0;
	diver=0;
	cntr=0;
/* ------------------------------------------------------------------------------------------ */
/* Main loop                                                                                  */
/* ------------------------------------------------------------------------------------------ */
	while(life>1){
			for(j=0;j<22;j++){
				memcpy(0xE000+(j*32), 0xE000+1+(j*32), 32);
				memset(0xE000+31+(j*32), 0,1);   
			}
			a++;
			if (a>63){
				for(j=0;j<22;j++){
					memcpy(0xE000+(j*32), 0xE800+(j*32), 32);
				}
				a=0;
			}


			a++;
/*			if (a==32){memcpy(0xE000,0xF000,(54-32)*32);a=0;}       */
			memcpy(0x7000,0xE000,2048);

			if  (rand(10)>6){plot(128-((a+4)*4),22,1);}
			if ((rand(100)>95) & (diver==0)){
				x2=128-((a+4)*4);
				y2=22;
				diver=1;
			}
			if(y2>61){diver=0;y2=22;}
			if(diver==1){			
				cntr++;
				if(cntr>3){cntr=0;}
				shape(x2,y2,7,3,2,"\xff\xff\xff");
			/*
			 *	...x... ....x.. ....... ..x....
			 *	...x... ...x... .xxxxx. ...x...
			 *	...x... ..x.... ....... ....x..
			 */

				if(cntr==0){shape(x2,y2,7,3,3,"\x10\x10\x10");}
				if(cntr==1){shape(x2,y2,7,3,3,"\x08\x10\x20");}
				if(cntr==2){shape(x2,y2,7,3,3,"\x00\x7c\x00");}
				if(cntr==3){shape(x2,y2,7,3,3,"\x20\x10\x08");}
				y2++;
				
			}	
			
			memcpy(0xF000+(23*32),0xE000+(22*32),41*32);
/*			memset(0xE000+(22*32),170,29);                            */
			memset(0xE000+(22*32),170,32);                            

			memcpy(0xE000+(23*32),0xF000+(23*32),41*32);
			if (fire==1){plot(fpx,fpy,3);plot(fpx,fpy+2,2);fpy--;}
			if (fpy<22){fire=0;}

			if ((mem[0x68ef] & 0x10) == 0) {fire=1;fpx=x;fpy=56;plot(fpx,fpy,3);}    /* fire  space */
			if ((mem[0x68ef] & 0x20) == 0) {					 /* left  M */
				dir=0;
				memset(0xE000+(32*58),170,6*32);
				x=x-3;
			} 
    			if ((mem[0x68ef] & 0x08) == 0) {			 	       /* right , */
				dir=1;
				memset(0xE000+(32*58),170,6*32); 
				x=x+3;
			}     	
			if(dir==1){
			        shape(x+0,y+0,8,6,2,"\xff\xff\xff\xff\xff\xff"); /*  make blue background */
			        shape(x+8,y+0,8,6,2,"\xff\xff\xff\xff\xff\xff"); /*  make blue background */
			        shape(x+0,y+2,8,4,1,"\x01\x0A\x0E\x09");         /*  1                    */
			        shape(x+8,y+0,8,6,1,"\x30\x10\xFC\x03\x03\xFC"); /*  2                    */
			        shape(x+8,y+3,8,1,3,"\xA8");                     /*  red bits             */
			}
			if(dir==0){
			        shape(x+0,y+0,8,6,2,"\xff\xff\xff\xff\xff\xff"); /*  make blue background */
			        shape(x+8,y+0,8,6,2,"\xff\xff\xff\xff\xff\xff"); /*  make blue background */
			        shape(x+0,y+0,8,6,1,"\x0c\x08\x3f\xc0\xc0\x3f"); /*  1                    */
			        shape(x+0,y+3,8,1,3,"\x15");  			 /*  red bits             */
			        shape(x+8,y+2,8,4,1,"\x80\x50\x70\x90");         /*  2                    */
			}


					
			/*  Facing Left           Facing Right      	  */
			/*  	1	2	     1	    2		  */
			/*  						  */
			/*  						  */
			/*  22221122 22222222    22222222 22112222        */
			/*  22221222 22222222    22222222 22212222        */
			/*  22111111 12222222    22222221 11111122        */
			/*  11232323 21212222    22221212 32323211        */
			/*  11222222 21112222    22221112 22222211        */
			/*  22111111 12212222    22221221 11111122        */

}}



draw_string(x,y,color,src)
int x,y,color;
char *src;
{	while (*src)	{
	   char_draw(x,y,color,*src);
	   x += 6;
           src++;	}}
