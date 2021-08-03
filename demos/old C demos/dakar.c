

main(argc, argv)
int argc;
int *argv;
{
	int a[2],b[2],c[2],d[2],e[2],f[2],g[2],h[2],i[2],j[2],k[2],l[2];
	int a1[2],b1[2],c1[2],d1[2],e1[2],f1[2],g1[2],h1[2],i1[2],j1[2],k1[2],l1[2];
	int y[7];

	int m,n,o,p,z;



    	mode(1);
	asm("di\n");



poke(0xE031,160);poke(0xE090,10);poke(0xE091,168);poke(0xE0B1,2);poke(0xE0C3,10);poke(0xE0C4,170);poke(0xE0C5,170);
poke(0xE0C6,128);poke(0xE0E6,42);poke(0xE0E7,170);poke(0xE0E8,170);poke(0xE109,170);poke(0xE10A,170);poke(0xE10B,160);
poke(0xE110,10);poke(0xE111,168);poke(0xE12A,2);poke(0xE12B,128);poke(0xE12F,2);poke(0xE130,170);poke(0xE131,170);
poke(0xE132,128);poke(0xE14F,42);poke(0xE150,160);poke(0xE151,34);poke(0xE152,168);poke(0xE16F,160);poke(0xE171,32);
poke(0xE172,10);poke(0xE173,170);poke(0xE18E,42);poke(0xE18F,168);poke(0xE191,32);poke(0xE192,10);poke(0xE193,170);
poke(0xE194,160);poke(0xE1AE,42);poke(0xE1AF,168);poke(0xE1B0,8);poke(0xE1B1,40);poke(0xE1B2,170);poke(0xE1B3,2);
poke(0xE1B4,170);poke(0xE1B5,128);poke(0xE1CE,171);poke(0xE1CF,234);poke(0xE1D0,10);poke(0xE1D1,136);poke(0xE1D2,162);
poke(0xE1D4,170);poke(0xE1D5,168);poke(0xE1ED,128);poke(0xE1EE,175);poke(0xE1EF,254);poke(0xE1F0,130);poke(0xE1F1,168);
poke(0xE1F2,162);poke(0xE1F4,10);poke(0xE1F5,250);poke(0xE1F6,128);poke(0xE20C,10);poke(0xE20D,130);poke(0xE20E,191);
poke(0xE20F,255);poke(0xE210,160);poke(0xE211,170);poke(0xE212,168);poke(0xE213,2);poke(0xE214,162);poke(0xE215,175);
poke(0xE216,170);poke(0xE22C,10);poke(0xE22D,162);poke(0xE22E,255);poke(0xE22F,255);poke(0xE230,250);poke(0xE231,42);
poke(0xE232,42);poke(0xE233,130);poke(0xE234,168);poke(0xE235,43);poke(0xE236,250);poke(0xE237,170);poke(0xE238,128);
poke(0xE23B,128);poke(0xE24C,42);poke(0xE24D,234);poke(0xE24E,170);poke(0xE24F,171);poke(0xE250,250);poke(0xE251,10);
poke(0xE252,160);poke(0xE253,170);poke(0xE254,168);poke(0xE255,43);poke(0xE256,255);poke(0xE257,250);poke(0xE258,170);
poke(0xE259,160);poke(0xE25B,128);poke(0xE267,10);poke(0xE268,170);poke(0xE269,128);poke(0xE26C,43);poke(0xE26D,254);
poke(0xE26E,170);poke(0xE26F,170);poke(0xE270,254);poke(0xE271,138);poke(0xE272,160);poke(0xE273,32);poke(0xE274,130);
poke(0xE275,175);poke(0xE276,250);poke(0xE277,170);poke(0xE278,170);poke(0xE279,170);poke(0xE27A,160);poke(0xE27B,160);
poke(0xE289,42);poke(0xE28A,160);poke(0xE28C,175);poke(0xE28D,255);poke(0xE28E,255);poke(0xE28F,254);poke(0xE290,191);
poke(0xE291,130);poke(0xE292,168);poke(0xE293,10);poke(0xE294,130);poke(0xE295,191);poke(0xE296,234);poke(0xE297,254);
poke(0xE298,170);poke(0xE299,170);poke(0xE29A,170);poke(0xE29B,40);poke(0xE2AB,40);poke(0xE2AC,175);poke(0xE2AD,255);
poke(0xE2AE,255);poke(0xE2AF,255);poke(0xE2B0,174);poke(0xE2B1,170);poke(0xE2B2,170);poke(0xE2B3,170);poke(0xE2B4,170);
poke(0xE2B5,255);poke(0xE2B6,171);poke(0xE2B7,255);poke(0xE2B8,255);poke(0xE2B9,234);poke(0xE2BA,162);poke(0xE2BB,170);
poke(0xE2C4,42);poke(0xE2C5,128);poke(0xE2CB,42);poke(0xE2CC,191);poke(0xE2CD,170);poke(0xE2CE,170);poke(0xE2CF,191);
poke(0xE2D0,239);poke(0xE2D1,255);poke(0xE2D2,254);poke(0xE2D3,174);poke(0xE2D4,175);poke(0xE2D5,254);poke(0xE2D6,175);
poke(0xE2D7,250);poke(0xE2D8,170);poke(0xE2D9,170);poke(0xE2DA,162);poke(0xE2DB,170);poke(0xE2E5,10);poke(0xE2E6,168);
poke(0xE2EB,8);poke(0xE2EC,175);poke(0xE2ED,170);poke(0xE2EE,170);poke(0xE2EF,191);poke(0xE2F0,235);poke(0xE2F1,255);
poke(0xE2F2,255);poke(0xE2F3,255);poke(0xE2F4,255);poke(0xE2F5,250);poke(0xE2F6,255);poke(0xE2F7,170);poke(0xE2F8,170);
poke(0xE2F9,170);poke(0xE2FA,170);poke(0xE2FB,168);poke(0xE306,2);poke(0xE307,170);poke(0xE308,128);poke(0xE30B,10);
poke(0xE30C,170);poke(0xE30D,138);poke(0xE30E,136);poke(0xE30F,175);poke(0xE310,250);poke(0xE311,170);poke(0xE312,170);
poke(0xE313,170);poke(0xE314,170);poke(0xE315,170);poke(0xE316,250);poke(0xE317,130);poke(0xE318,170);poke(0xE319,128);
poke(0xE31A,2);poke(0xE31B,128);poke(0xE328,170);poke(0xE329,128);poke(0xE32B,10);poke(0xE32C,170);poke(0xE32D,10);
poke(0xE32E,168);poke(0xE32F,42);poke(0xE330,254);poke(0xE331,191);poke(0xE332,255);poke(0xE333,255);poke(0xE334,255);
poke(0xE335,255);poke(0xE336,234);poke(0xE337,2);poke(0xE338,42);poke(0xE33A,2);poke(0xE33B,128);poke(0xE349,32);
poke(0xE34B,2);poke(0xE34C,170);poke(0xE34D,42);poke(0xE34F,10);poke(0xE350,191);poke(0xE351,255);poke(0xE352,255);
poke(0xE353,255);poke(0xE354,255);poke(0xE355,254);poke(0xE356,160);poke(0xE357,2);poke(0xE358,168);poke(0xE35A,2);
poke(0xE36B,10);poke(0xE36C,128);poke(0xE36D,168);poke(0xE36E,32);poke(0xE370,171);poke(0xE371,255);
poke(0xE372,255);poke(0xE373,255);poke(0xE374,250);poke(0xE375,170);poke(0xE376,130);poke(0xE377,138);
poke(0xE378,40);poke(0xE37A,10);poke(0xE38D,170);poke(0xE38E,128);
poke(0xE390,42);poke(0xE391,170);poke(0xE392,170);poke(0xE393,170);poke(0xE394,170);poke(0xE395,160);
poke(0xE396,42);poke(0xE397,170);poke(0xE398,168);poke(0xE3AC,8);poke(0xE3AD,160);
poke(0xE3AE,128);poke(0xE3B0,2);poke(0xE3B1,170);poke(0xE3B2,170);poke(0xE3B3,170);
poke(0xE3B4,170);poke(0xE3B5,138);poke(0xE3B6,170);poke(0xE3B7,169);poke(0xE3B8,106);
poke(0xE3C3,2);poke(0xE3C4,160);poke(0xE3CA,10);poke(0xE3CB,170);poke(0xE3CC,170);poke(0xE3CD,170);poke(0xE3CE,128);
poke(0xE3D1,170);poke(0xE3D2,170);poke(0xE3D3,170);poke(0xE3D4,168);poke(0xE3D5,42);poke(0xE3D6,169);poke(0xE3D7,85);
poke(0xE3D8,86);poke(0xE3D9,128);poke(0xE3E3,42);poke(0xE3E4,128);poke(0xE3E9,2);
poke(0xE3EA,170);poke(0xE3EB,170);poke(0xE3EC,170);poke(0xE3ED,170);
poke(0xE3F2,10);poke(0xE3F3,170);poke(0xE3F4,128);poke(0xE3F5,170);
poke(0xE3F6,149);poke(0xE3F7,85);poke(0xE3F8,86);poke(0xE3F9,128);poke(0xE403,168);poke(0xE406,10);
poke(0xE409,170);poke(0xE40A,170);poke(0xE40B,149);poke(0xE40C,85);poke(0xE40D,86);
poke(0xE40E,128);poke(0xE411,170);poke(0xE412,170);poke(0xE413,170);
poke(0xE414,138);poke(0xE415,170);poke(0xE416,85);poke(0xE417,85);poke(0xE418,86);poke(0xE419,128);
poke(0xE422,2);poke(0xE423,160);poke(0xE426,42);poke(0xE428,2);poke(0xE429,170);poke(0xE42A,170);poke(0xE42B,85);
poke(0xE42C,85);poke(0xE42D,85);poke(0xE42E,160);poke(0xE430,170);poke(0xE431,170);
poke(0xE432,160);poke(0xE434,10);poke(0xE435,165);poke(0xE436,85);poke(0xE437,85);poke(0xE438,86);poke(0xE439,128);
poke(0xE442,2);poke(0xE443,128);poke(0xE446,168);poke(0xE448,42);poke(0xE449,170);
poke(0xE44A,85);poke(0xE44B,85);poke(0xE44C,85);poke(0xE44D,85);poke(0xE44E,160);poke(0xE44F,2);
poke(0xE450,170);poke(0xE451,128);poke(0xE454,170);poke(0xE455,165);
poke(0xE456,106);poke(0xE457,149);poke(0xE458,90);poke(0xE459,128);
poke(0xE462,10);poke(0xE465,2);poke(0xE466,128);poke(0xE467,2);
poke(0xE468,170);poke(0xE469,169);poke(0xE46A,86);poke(0xE46B,165);poke(0xE46C,85);poke(0xE46D,85);
poke(0xE46E,104);poke(0xE470,128);poke(0xE473,2);
poke(0xE474,170);poke(0xE475,86);poke(0xE476,190);poke(0xE477,149);poke(0xE478,90);poke(0xE479,128);
poke(0xE482,8);poke(0xE483,2);poke(0xE485,10);poke(0xE487,2);poke(0xE488,170);poke(0xE489,85);poke(0xE48A,107);
poke(0xE48B,250);poke(0xE48C,149);poke(0xE48D,85);poke(0xE48E,168);
poke(0xE492,128);poke(0xE493,2);poke(0xE494,169);poke(0xE495,91);poke(0xE496,175);poke(0xE497,85);poke(0xE498,90);
poke(0xE4A2,8);poke(0xE4A3,10);poke(0xE4A5,40);poke(0xE4A7,42);poke(0xE4A8,165);poke(0xE4A9,85);
poke(0xE4AA,191);poke(0xE4AB,175);poke(0xE4AC,149);poke(0xE4AD,85);poke(0xE4AE,160);
poke(0xE4B1,2);poke(0xE4B2,128);poke(0xE4B3,2);poke(0xE4B4,165);poke(0xE4B5,110);
poke(0xE4B6,174);poke(0xE4B7,85);poke(0xE4B8,168);poke(0xE4C3,40);poke(0xE4C5,160);poke(0xE4C7,170);
poke(0xE4C8,165);poke(0xE4C9,86);poke(0xE4CA,170);poke(0xE4CB,170);poke(0xE4CC,149);poke(0xE4CD,85);
poke(0xE4CE,160);poke(0xE4D1,2);poke(0xE4D2,128);poke(0xE4D3,10);
poke(0xE4D4,149);poke(0xE4D5,111);poke(0xE4D6,250);poke(0xE4D7,86);poke(0xE4D8,160);poke(0xE4E3,40);
poke(0xE4E5,160);poke(0xE4E6,2);poke(0xE4E7,170);poke(0xE4E8,149);poke(0xE4E9,91);poke(0xE4EA,254);poke(0xE4EB,171);
poke(0xE4EC,149);poke(0xE4ED,86);poke(0xE4EE,160);poke(0xE4F1,2);
poke(0xE4F3,42);poke(0xE4F4,85);poke(0xE4F5,86);poke(0xE4F6,165);poke(0xE4F7,86);poke(0xE4F8,160);poke(0xE503,32);
poke(0xE505,160);poke(0xE506,2);poke(0xE507,170);poke(0xE508,85);poke(0xE509,91);
poke(0xE50A,174);poke(0xE50B,254);poke(0xE50C,149);poke(0xE50D,106);poke(0xE50E,128);
poke(0xE510,40);poke(0xE511,2);poke(0xE513,170);poke(0xE514,85);poke(0xE515,85);
poke(0xE516,85);poke(0xE517,106);poke(0xE523,32);poke(0xE525,160);poke(0xE526,2);poke(0xE527,169);
poke(0xE528,85);poke(0xE529,86);poke(0xE52A,187);poke(0xE52B,250);poke(0xE52C,85);poke(0xE52D,106);
poke(0xE530,160);poke(0xE531,2);poke(0xE533,169);poke(0xE534,85);poke(0xE535,85);poke(0xE536,85);poke(0xE537,168);
poke(0xE543,40);poke(0xE545,160);poke(0xE546,2);poke(0xE547,169);poke(0xE548,85);poke(0xE549,85);poke(0xE54A,170);
poke(0xE54B,165);poke(0xE54C,85);poke(0xE54D,170);poke(0xE550,160);poke(0xE551,2);
poke(0xE553,169);poke(0xE554,85);poke(0xE555,86);poke(0xE556,170);poke(0xE557,160);
poke(0xE563,8);poke(0xE565,32);poke(0xE566,2);poke(0xE567,169);poke(0xE568,85);poke(0xE569,85);
poke(0xE56A,85);poke(0xE56B,85);poke(0xE56C,106);poke(0xE56D,160);
poke(0xE570,32);poke(0xE571,2);poke(0xE573,41);poke(0xE574,90);poke(0xE575,170);poke(0xE576,170);poke(0xE577,160);
poke(0xE583,2);poke(0xE585,40);poke(0xE586,2);poke(0xE587,169);
poke(0xE588,85);poke(0xE589,85);poke(0xE58A,85);poke(0xE58B,86);poke(0xE58C,170);
poke(0xE590,8);poke(0xE592,128);poke(0xE593,42);poke(0xE594,170);poke(0xE595,168);poke(0xE596,128);poke(0xE5A5,10);
poke(0xE5A7,170);poke(0xE5A8,85);poke(0xE5A9,85);poke(0xE5AA,85);poke(0xE5AB,90);
poke(0xE5AC,170);poke(0xE5AD,42);poke(0xE5AE,170);poke(0xE5AF,168);poke(0xE5B1,2);
poke(0xE5B2,128);poke(0xE5B3,10);poke(0xE5B4,170);poke(0xE5B5,160);poke(0xE5C7,42);poke(0xE5C8,106);poke(0xE5C9,85);
poke(0xE5CA,86);poke(0xE5CB,170);poke(0xE5CC,170);poke(0xE5CD,170);poke(0xE5CE,170);poke(0xE5CF,170);
poke(0xE5E7,10);poke(0xE5E8,170);poke(0xE5E9,170);poke(0xE5EA,170);poke(0xE5EB,170);poke(0xE5EC,170);poke(0xE5ED,160);
poke(0xE5EE,2);poke(0xE5EF,170);poke(0xE608,170);poke(0xE609,170);poke(0xE60A,170);poke(0xE60B,170);
poke(0xE60C,128);poke(0xE60E,42);poke(0xE60F,168);poke(0xE629,10);
poke(0xE62A,170);poke(0xE62B,128);poke(0xE62D,2);poke(0xE62E,170);poke(0xE62F,128);
poke(0xE63A,170);poke(0xE63B,170);poke(0xE63C,170);poke(0xE63D,170);
poke(0xE648,2);poke(0xE649,170);poke(0xE64A,160);poke(0xE64D,10);poke(0xE64E,168);
poke(0xE657,42);poke(0xE658,170);poke(0xE659,170);
poke(0xE65A,170);poke(0xE65B,170);poke(0xE65C,170);poke(0xE65D,170);poke(0xE65E,170);poke(0xE65F,160);
poke(0xE668,170);poke(0xE669,168);poke(0xE66D,170);poke(0xE66E,128);
poke(0xE675,42);poke(0xE676,170);poke(0xE677,170);poke(0xE678,170);poke(0xE679,170);poke(0xE67A,128);poke(0xE67D,42);
poke(0xE67E,170);poke(0xE67F,160);poke(0xE687,42);poke(0xE688,170);poke(0xE68C,2);poke(0xE68D,168);
poke(0xE693,42);poke(0xE694,170);poke(0xE695,170);poke(0xE696,160);poke(0xE69F,160);poke(0xE6A6,2);poke(0xE6A7,170);
poke(0xE6A8,128);poke(0xE6AC,42);poke(0xE6AD,160);poke(0xE6B1,42);poke(0xE6B2,170);poke(0xE6B3,170);poke(0xE6B4,160);
poke(0xE6C6,170);poke(0xE6C7,160);poke(0xE6CC,170);poke(0xE6CF,2);poke(0xE6D0,170);poke(0xE6D1,170);poke(0xE6D2,168);
poke(0xE6E5,10);poke(0xE6E6,170);poke(0xE6EC,168);poke(0xE6EE,42);poke(0xE6EF,170);poke(0xE6F0,170);poke(0xE6F1,128);
poke(0xE705,170);poke(0xE706,128);poke(0xE70C,170);poke(0xE70D,170);poke(0xE70E,170);poke(0xE70F,160);
poke(0xE724,10);poke(0xE725,168);poke(0xE72C,170);poke(0xE72D,170);poke(0xE72E,128);poke(0xE744,10);poke(0xE745,128);

	for (z=0;z<5;z++) {
	   a[z]=30;
	   c[z]=42;
	   e[z]=56;
           g[z]=78;
   	   i[z]=82;
	   k[z]=100;
	};

	y[0] = 15; /* Y param of first box */
	y[1] = 29;
	y[2] = 33;
	y[3] = 48;
	y[4] = 53; /* Y param of second box */
	y[5] = 60;
	
	for (z=0;z<5;z++) {
	   b[z]=y[0];
	   d[z]=y[1];
	   f[z]=y[2];
           h[z]=y[3];
           j[z]=y[4];
           l[z]=y[5];
         
	   y[0]=y[0]-3;
	   y[1]=y[1]-3;
	   y[2]=y[2]-3;
	   y[3]=y[3]-3;
	   y[4]=y[4]-3;
	   y[5]=y[5]-3;
	   y[6]=y[6]-3;
	   y[7]=y[7]-3;
	};

	for (z=0;z<5;z++) {
	a1[z]=1;
	b1[z]=1;
	c1[z]=1;
	d1[z]=1;
	e1[z]=1;
	f1[z]=1;
	g1[z]=1;
	h1[z]=1;
	i1[z]=1;
	j1[z]=1;
	k1[z]=1;
	l1[z]=1;
	};

	m=1;
	while(m==1){
	        for(n=0;n<64;n++){
			memcpy(0x7000   , 0xE800-(n*32)-32,32+n*32);
			for (o=0;o<400;o++);					}
	        for(n=0;n<64;n++){
			memcpy(0x7000+(n*32)+32   , 0xE000,2048-n*32);
			for (o=0;o<400;o++);			}
	        for(n=0;n<64;n++){
			memcpy(0x7000   , 0xE800-(n*32)-32,32+n*32);
			for (o=0;o<400;o++);					}
	        for(n=0;n<32;n++){
			memcpy(0x7000+n   , 0xE000,2048);
			for (o=0;o<200;o++);				}	
	        for(n=0;n<64;n++){
			memcpy(0x7000   , 0xE000+(n*32)+32,2048-n*32);
			for (o=0;o<400;o++);					}
		
		memcpy(0xE800,0xE000, 2048);
	p=1;
	setbase(0xE800);
	while(p==1){
	a[0]=a[0]+a1[0];
	b[0]=b[0]+b1[0];
	c[0]=c[0]+c1[0];
	d[0]=d[0]+d1[0];
	e[0]=e[0]+e1[0];
	f[0]=f[0]+f1[0];
	g[0]=g[0]+g1[0];
	h[0]=h[0]+h1[0];
	i[0]=i[0]+i1[0];
	j[0]=j[0]+j1[0];
	k[0]=k[0]+k1[0];
	l[0]=l[0]+l1[0];

	a[1]=a[1]+a1[1];
	b[1]=b[1]+b1[1];
	c[1]=c[1]+c1[1];
	d[1]=d[1]+d1[1];
	e[1]=e[1]+e1[1];
	f[1]=f[1]+f1[1];
	g[1]=g[1]+g1[1];
	h[1]=h[1]+h1[1];
	i[1]=i[1]+i1[1];
	j[1]=j[1]+j1[1];
	k[1]=k[1]+k1[1];
	l[1]=l[1]+l1[1];

	
	line(a[0],b[0], c[0],d[0], 1);
	line(c[0],d[0], e[0],f[0], 1);
	line(e[0],f[0], g[0],h[0], 1);
	line(g[0],h[0], i[0],j[0], 1);
	line(i[0],j[0], k[0],l[0], 1);

	line(a[1],b[1], c[1],d[1], 2);
	line(c[1],d[1], e[1],f[1], 2);
	line(e[1],f[1], g[1],h[1], 2);
	line(g[1],h[1], i[1],j[1], 2);
	line(i[1],j[1], k[1],l[1], 2);


	memcpy(0x7000,0xE800,2048);
	memcpy(0xE800,0XE000,2048); 

	if (a[0]<1)    a1[0]=1;
	if (a[0]>126)  a1[0]=-1;
	if (b[0]<1)    b1[0]=1;
	if (b[0]>62)   b1[0]=-1;
	if (c[0]<1)    c1[0]=1;
	if (c[0]>126)  c1[0]=-1;
	if (d[0]<1)    d1[0]=1;
	if (d[0]>62)   d1[0]=-1;
	if (e[0]<1)    e1[0]=1;
	if (e[0]>126)  e1[0]=-1;
	if (f[0]<1)    f1[0]=1;
	if (f[0]>62)   f1[0]=-1;
	if (g[0]<1)    g1[0]=1;
	if (g[0]>126)  g1[0]=-1;
	if (h[0]<1)    h1[0]=1;
	if (h[0]>62)   h1[0]=-1;
	if (i[0]<1)    i1[0]=1;
	if (i[0]>126)  i1[0]=-1;
	if (j[0]<1)    j1[0]=1;
	if (j[0]>62)   j1[0]=-1;
	if (k[0]<1)    k1[0]=1;
	if (k[0]>126)  k1[0]=-1;
	if (l[0]<1)    l1[0]=1;
	if (l[0]>62)   l1[0]=-1;

	if (a[1]<1)    a1[1]=1;
	if (a[1]>126)  a1[1]=-1;
	if (b[1]<1)    b1[1]=1;
	if (b[1]>62)   b1[1]=-1;
	if (c[1]<1)    c1[1]=1;
	if (c[1]>126)  c1[1]=-1;
	if (d[1]<1)    d1[1]=1;
	if (d[1]>62)   d1[1]=-1;
	if (e[1]<1)    e1[1]=1;
	if (e[1]>126)  e1[1]=-1;
	if (f[1]<1)    f1[1]=1;
	if (f[1]>62)   f1[1]=-1;
	if (g[1]<1)    g1[1]=1;
	if (g[1]>126)  g1[1]=-1;
	if (h[1]<1)    h1[1]=1;
	if (h[1]>62)   h1[1]=-1;
	if (i[1]<1)    i1[1]=1;
	if (i[1]>126)  i1[1]=-1;
	if (j[1]<1)    j1[1]=1;
	if (j[1]>62)   j1[1]=-1;
	if (k[1]<1)    k1[1]=1;
	if (k[1]>126)  k1[1]=-1;
	if (l[1]<1)    l1[1]=1;
	if (l[1]>62)   l1[1]=-1;


	}




	}		
}



