/* Dave. 12th - 15th, July, 2002 */
/* Run:	vzem -f vzcave.vz	 */
/*********************************/

/*	if((mem[0x68fe] & 0x10) == 0) {y=y+2;}			; up    Q 
		0x68fe  & 0x10     0    ;Q
	      	0x68fb  & 0x04	   0   	;shift 
		0x68ef  & 0x20	   0 	;M 
  		0x68ef  & 0x08     0 	;, 
      		0x68ef  & 0x10     0   	;space 
		0x68bf	& 0x10     0    ;P						
		0x68fd  & 0x02     0    ;S						
See page -6- of VZ200 tech manual					
*/


char 	*mem;
char    scr[32*64];
main(argc, argv)
int 	argc;
int 	*argv;
{	
	int a,b,c,i,j,x,x2,x3,y,y2,z, sc1,sc2,sc3,sc4;
	int lives,won,end,speed;

    	mode(1);
    	asm("di\n");
	z=0;speed=0;sc1=0;sc2=0;sc3=0;
	while(z==0){
	end=0;	a=17;	b=45;	y=31;	lives=3;  won=0; 
	setbase(0x7000);
i=7000;

bpoke(i+0x000,170);bpoke(i+0x001,170);bpoke(i+0x002,170);bpoke(i+0x003,170);bpoke(i+0x004,170);bpoke(i+0x005,170);
bpoke(i+0x006,170);bpoke(i+0x007,170);bpoke(i+0x008,170);bpoke(i+0x009,170);bpoke(i+0x00A,170);bpoke(i+0x00B,170);
bpoke(i+0x00C,170);bpoke(i+0x00D,170);bpoke(i+0x00E,170);bpoke(i+0x00F,170);bpoke(i+0x010,170);bpoke(i+0x011,170);
bpoke(i+0x012,170);bpoke(i+0x013,170);bpoke(i+0x014,170);bpoke(i+0x015,170);bpoke(i+0x016,170);bpoke(i+0x017,170);
bpoke(i+0x018,170);bpoke(i+0x019,170);bpoke(i+0x01A,170);bpoke(i+0x01B,170);bpoke(i+0x01C,170);bpoke(i+0x01D,170);
bpoke(i+0x01E,170);bpoke(i+0x01F,170);bpoke(i+0x020,170);bpoke(i+0x021,170);bpoke(i+0x022,170);bpoke(i+0x023,170);
bpoke(i+0x024,170);bpoke(i+0x025,170);bpoke(i+0x026,170);bpoke(i+0x027,170);bpoke(i+0x028,170);bpoke(i+0x029,170);
bpoke(i+0x02A,170);bpoke(i+0x02B,170);bpoke(i+0x02C,170);bpoke(i+0x02D,170);bpoke(i+0x02E,170);bpoke(i+0x02F,170);
bpoke(i+0x030,170);bpoke(i+0x031,170);bpoke(i+0x032,170);bpoke(i+0x033,170);bpoke(i+0x034,170);bpoke(i+0x035,170);
bpoke(i+0x036,170);bpoke(i+0x037,170);bpoke(i+0x038,170);bpoke(i+0x039,170);bpoke(i+0x03A,170);bpoke(i+0x03B,170);
bpoke(i+0x03C,170);bpoke(i+0x03D,170);bpoke(i+0x03E,170);bpoke(i+0x03F,170);bpoke(i+0x040,170);bpoke(i+0x041,170);
bpoke(i+0x042,170);bpoke(i+0x043,170);bpoke(i+0x044,170);bpoke(i+0x045,170);bpoke(i+0x046,170);bpoke(i+0x047,170);
bpoke(i+0x048,170);bpoke(i+0x049,170);bpoke(i+0x04A,170);bpoke(i+0x04B,170);bpoke(i+0x04C,170);bpoke(i+0x04D,170);
bpoke(i+0x04E,170);bpoke(i+0x04F,170);bpoke(i+0x050,170);bpoke(i+0x051,170);bpoke(i+0x052,170);bpoke(i+0x053,170);
bpoke(i+0x054,170);bpoke(i+0x055,170);bpoke(i+0x056,170);bpoke(i+0x057,170);bpoke(i+0x058,170);bpoke(i+0x059,170);
bpoke(i+0x05A,170);bpoke(i+0x05B,170);bpoke(i+0x05C,170);bpoke(i+0x05D,170);bpoke(i+0x05E,170);bpoke(i+0x05F,170);
bpoke(i+0x060,170);bpoke(i+0x061,170);bpoke(i+0x062,170);bpoke(i+0x063,170);bpoke(i+0x064,170);bpoke(i+0x065,170);
bpoke(i+0x066,170);bpoke(i+0x067,170);bpoke(i+0x068,165);bpoke(i+0x069,85);bpoke(i+0x06A,106);bpoke(i+0x06B,170);
bpoke(i+0x06C,170);bpoke(i+0x06D,170);bpoke(i+0x06E,149);bpoke(i+0x06F,85);bpoke(i+0x070,169);bpoke(i+0x071,85);
bpoke(i+0x072,85);bpoke(i+0x073,85);bpoke(i+0x074,85);bpoke(i+0x075,85);bpoke(i+0x076,90);bpoke(i+0x077,170);
bpoke(i+0x078,170);bpoke(i+0x079,170);bpoke(i+0x07A,170);bpoke(i+0x07B,170);bpoke(i+0x07C,170);bpoke(i+0x07D,170);
bpoke(i+0x07E,170);bpoke(i+0x07F,170);bpoke(i+0x080,170);bpoke(i+0x081,170);bpoke(i+0x082,170);bpoke(i+0x083,170);
bpoke(i+0x084,170);bpoke(i+0x085,170);bpoke(i+0x086,170);bpoke(i+0x087,170);bpoke(i+0x088,169);bpoke(i+0x089,85);
bpoke(i+0x08A,90);bpoke(i+0x08B,170);bpoke(i+0x08C,170);bpoke(i+0x08D,170);bpoke(i+0x08E,149);bpoke(i+0x08F,86);
bpoke(i+0x090,169);bpoke(i+0x091,85);bpoke(i+0x092,85);bpoke(i+0x093,85);bpoke(i+0x094,85);bpoke(i+0x095,85);
bpoke(i+0x096,90);bpoke(i+0x097,170);bpoke(i+0x098,170);bpoke(i+0x099,170);bpoke(i+0x09A,170);bpoke(i+0x09B,170);
bpoke(i+0x09C,170);bpoke(i+0x09D,170);bpoke(i+0x09E,170);bpoke(i+0x09F,170);bpoke(i+0x0A0,170);bpoke(i+0x0A1,170);
bpoke(i+0x0A2,170);bpoke(i+0x0A3,170);bpoke(i+0x0A4,170);bpoke(i+0x0A5,170);bpoke(i+0x0A6,170);bpoke(i+0x0A7,170);
bpoke(i+0x0A8,170);bpoke(i+0x0A9,85);bpoke(i+0x0AA,86);bpoke(i+0x0AB,170);bpoke(i+0x0AC,170);bpoke(i+0x0AD,170);
bpoke(i+0x0AE,85);bpoke(i+0x0AF,86);bpoke(i+0x0B0,169);bpoke(i+0x0B1,85);bpoke(i+0x0B2,85);bpoke(i+0x0B3,85);
bpoke(i+0x0B4,85);bpoke(i+0x0B5,85);bpoke(i+0x0B6,90);bpoke(i+0x0B7,170);bpoke(i+0x0B8,170);bpoke(i+0x0B9,170);
bpoke(i+0x0BA,170);bpoke(i+0x0BB,170);bpoke(i+0x0BC,170);bpoke(i+0x0BD,170);bpoke(i+0x0BE,170);bpoke(i+0x0BF,170);
bpoke(i+0x0C0,170);bpoke(i+0x0C1,170);bpoke(i+0x0C2,170);bpoke(i+0x0C3,170);bpoke(i+0x0C4,170);bpoke(i+0x0C5,170);
bpoke(i+0x0C6,170);bpoke(i+0x0C7,170);bpoke(i+0x0C8,170);bpoke(i+0x0C9,149);bpoke(i+0x0CA,86);bpoke(i+0x0CB,170);
bpoke(i+0x0CC,170);bpoke(i+0x0CD,169);bpoke(i+0x0CE,85);bpoke(i+0x0CF,90);bpoke(i+0x0D0,170);bpoke(i+0x0D1,170);
bpoke(i+0x0D2,170);bpoke(i+0x0D3,170);bpoke(i+0x0D4,149);bpoke(i+0x0D5,85);bpoke(i+0x0D6,106);bpoke(i+0x0D7,170);
bpoke(i+0x0D8,170);bpoke(i+0x0D9,170);bpoke(i+0x0DA,170);bpoke(i+0x0DB,170);bpoke(i+0x0DC,170);bpoke(i+0x0DD,170);
bpoke(i+0x0DE,170);bpoke(i+0x0DF,170);bpoke(i+0x0E0,170);bpoke(i+0x0E1,170);bpoke(i+0x0E2,170);bpoke(i+0x0E3,170);
bpoke(i+0x0E4,170);bpoke(i+0x0E5,170);bpoke(i+0x0E6,170);bpoke(i+0x0E7,170);bpoke(i+0x0E8,170);bpoke(i+0x0E9,149);
bpoke(i+0x0EA,85);bpoke(i+0x0EB,170);bpoke(i+0x0EC,170);bpoke(i+0x0ED,165);bpoke(i+0x0EE,85);bpoke(i+0x0EF,106);
bpoke(i+0x0F0,170);bpoke(i+0x0F1,170);bpoke(i+0x0F2,170);bpoke(i+0x0F3,169);bpoke(i+0x0F4,85);bpoke(i+0x0F5,86);
bpoke(i+0x0F6,170);bpoke(i+0x0F7,170);bpoke(i+0x0F8,170);bpoke(i+0x0F9,170);bpoke(i+0x0FA,170);bpoke(i+0x0FB,170);
bpoke(i+0x0FC,170);bpoke(i+0x0FD,170);bpoke(i+0x0FE,170);bpoke(i+0x0FF,170);bpoke(i+0x100,170);bpoke(i+0x101,170);
bpoke(i+0x102,170);bpoke(i+0x103,170);bpoke(i+0x104,170);bpoke(i+0x105,170);bpoke(i+0x106,170);bpoke(i+0x107,170);
bpoke(i+0x108,170);bpoke(i+0x109,165);bpoke(i+0x10A,85);bpoke(i+0x10B,106);bpoke(i+0x10C,170);bpoke(i+0x10D,165);
bpoke(i+0x10E,85);bpoke(i+0x10F,170);bpoke(i+0x110,170);bpoke(i+0x111,170);bpoke(i+0x112,170);bpoke(i+0x113,149);
bpoke(i+0x114,85);bpoke(i+0x115,90);bpoke(i+0x116,170);bpoke(i+0x117,170);bpoke(i+0x118,170);bpoke(i+0x119,170);
bpoke(i+0x11A,170);bpoke(i+0x11B,170);bpoke(i+0x11C,170);bpoke(i+0x11D,170);bpoke(i+0x11E,170);bpoke(i+0x11F,170);
bpoke(i+0x120,170);bpoke(i+0x121,170);bpoke(i+0x122,170);bpoke(i+0x123,170);bpoke(i+0x124,170);bpoke(i+0x125,170);
bpoke(i+0x126,170);bpoke(i+0x127,170);bpoke(i+0x128,170);bpoke(i+0x129,169);bpoke(i+0x12A,85);bpoke(i+0x12B,106);
bpoke(i+0x12C,170);bpoke(i+0x12D,149);bpoke(i+0x12E,85);bpoke(i+0x12F,170);bpoke(i+0x130,170);bpoke(i+0x131,170);
bpoke(i+0x132,170);bpoke(i+0x133,85);bpoke(i+0x134,85);bpoke(i+0x135,170);bpoke(i+0x136,170);bpoke(i+0x137,170);
bpoke(i+0x138,170);bpoke(i+0x139,170);bpoke(i+0x13A,170);bpoke(i+0x13B,170);bpoke(i+0x13C,170);bpoke(i+0x13D,170);
bpoke(i+0x13E,170);bpoke(i+0x13F,170);bpoke(i+0x140,170);bpoke(i+0x141,170);bpoke(i+0x142,170);bpoke(i+0x143,170);
bpoke(i+0x144,170);bpoke(i+0x145,170);bpoke(i+0x146,170);bpoke(i+0x147,170);bpoke(i+0x148,170);bpoke(i+0x149,170);
bpoke(i+0x14A,85);bpoke(i+0x14B,90);bpoke(i+0x14C,170);bpoke(i+0x14D,149);bpoke(i+0x14E,86);bpoke(i+0x14F,170);
bpoke(i+0x150,170);bpoke(i+0x151,170);bpoke(i+0x152,165);bpoke(i+0x153,85);bpoke(i+0x154,90);bpoke(i+0x155,170);
bpoke(i+0x156,170);bpoke(i+0x157,170);bpoke(i+0x158,170);bpoke(i+0x159,170);bpoke(i+0x15A,170);bpoke(i+0x15B,170);
bpoke(i+0x15C,170);bpoke(i+0x15D,170);bpoke(i+0x15E,170);bpoke(i+0x15F,170);bpoke(i+0x160,170);bpoke(i+0x161,170);
bpoke(i+0x162,170);bpoke(i+0x163,170);bpoke(i+0x164,170);bpoke(i+0x165,170);bpoke(i+0x166,170);bpoke(i+0x167,170);
bpoke(i+0x168,170);bpoke(i+0x169,170);bpoke(i+0x16A,85);bpoke(i+0x16B,86);bpoke(i+0x16C,170);bpoke(i+0x16D,85);
bpoke(i+0x16E,90);bpoke(i+0x16F,170);bpoke(i+0x170,170);bpoke(i+0x171,170);bpoke(i+0x172,149);bpoke(i+0x173,85);
bpoke(i+0x174,106);bpoke(i+0x175,170);bpoke(i+0x176,170);bpoke(i+0x177,170);bpoke(i+0x178,170);bpoke(i+0x179,170);
bpoke(i+0x17A,170);bpoke(i+0x17B,170);bpoke(i+0x17C,170);bpoke(i+0x17D,170);bpoke(i+0x17E,170);bpoke(i+0x17F,170);
bpoke(i+0x180,170);bpoke(i+0x181,170);bpoke(i+0x182,170);bpoke(i+0x183,170);bpoke(i+0x184,170);bpoke(i+0x185,170);
bpoke(i+0x186,170);bpoke(i+0x187,170);bpoke(i+0x188,170);bpoke(i+0x189,170);bpoke(i+0x18A,149);bpoke(i+0x18B,86);
bpoke(i+0x18C,169);bpoke(i+0x18D,85);bpoke(i+0x18E,106);bpoke(i+0x18F,170);bpoke(i+0x190,170);bpoke(i+0x191,169);
bpoke(i+0x192,85);bpoke(i+0x193,86);bpoke(i+0x194,170);bpoke(i+0x195,170);bpoke(i+0x196,170);bpoke(i+0x197,170);
bpoke(i+0x198,170);bpoke(i+0x199,170);bpoke(i+0x19A,170);bpoke(i+0x19B,170);bpoke(i+0x19C,170);bpoke(i+0x19D,170);
bpoke(i+0x19E,170);bpoke(i+0x19F,170);bpoke(i+0x1A0,170);bpoke(i+0x1A1,170);bpoke(i+0x1A2,170);bpoke(i+0x1A3,170);
bpoke(i+0x1A4,170);bpoke(i+0x1A5,170);bpoke(i+0x1A6,170);bpoke(i+0x1A7,170);bpoke(i+0x1A8,170);bpoke(i+0x1A9,170);
bpoke(i+0x1AA,165);bpoke(i+0x1AB,85);bpoke(i+0x1AC,165);bpoke(i+0x1AD,85);bpoke(i+0x1AE,106);bpoke(i+0x1AF,170);
bpoke(i+0x1B0,170);bpoke(i+0x1B1,149);bpoke(i+0x1B2,85);bpoke(i+0x1B3,90);bpoke(i+0x1B4,170);bpoke(i+0x1B5,170);
bpoke(i+0x1B6,170);bpoke(i+0x1B7,170);bpoke(i+0x1B8,170);bpoke(i+0x1B9,170);bpoke(i+0x1BA,170);bpoke(i+0x1BB,170);
bpoke(i+0x1BC,170);bpoke(i+0x1BD,170);bpoke(i+0x1BE,170);bpoke(i+0x1BF,170);bpoke(i+0x1C0,170);bpoke(i+0x1C1,170);
bpoke(i+0x1C2,170);bpoke(i+0x1C3,170);bpoke(i+0x1C4,170);bpoke(i+0x1C5,170);bpoke(i+0x1C6,170);bpoke(i+0x1C7,170);
bpoke(i+0x1C8,170);bpoke(i+0x1C9,170);bpoke(i+0x1CA,165);bpoke(i+0x1CB,85);bpoke(i+0x1CC,101);bpoke(i+0x1CD,85);
bpoke(i+0x1CE,170);bpoke(i+0x1CF,170);bpoke(i+0x1D0,169);bpoke(i+0x1D1,85);bpoke(i+0x1D2,85);bpoke(i+0x1D3,170);
bpoke(i+0x1D4,170);bpoke(i+0x1D5,170);bpoke(i+0x1D6,170);bpoke(i+0x1D7,170);bpoke(i+0x1D8,170);bpoke(i+0x1D9,170);
bpoke(i+0x1DA,170);bpoke(i+0x1DB,170);bpoke(i+0x1DC,170);bpoke(i+0x1DD,170);bpoke(i+0x1DE,170);bpoke(i+0x1DF,170);
bpoke(i+0x1E0,170);bpoke(i+0x1E1,170);bpoke(i+0x1E2,170);bpoke(i+0x1E3,170);bpoke(i+0x1E4,170);bpoke(i+0x1E5,170);
bpoke(i+0x1E6,170);bpoke(i+0x1E7,170);bpoke(i+0x1E8,170);bpoke(i+0x1E9,170);bpoke(i+0x1EA,169);bpoke(i+0x1EB,85);
bpoke(i+0x1EC,85);bpoke(i+0x1ED,86);bpoke(i+0x1EE,170);bpoke(i+0x1EF,170);bpoke(i+0x1F0,165);bpoke(i+0x1F1,85);
bpoke(i+0x1F2,90);bpoke(i+0x1F3,170);bpoke(i+0x1F4,170);bpoke(i+0x1F5,170);bpoke(i+0x1F6,170);bpoke(i+0x1F7,170);
bpoke(i+0x1F8,170);bpoke(i+0x1F9,170);bpoke(i+0x1FA,170);bpoke(i+0x1FB,170);bpoke(i+0x1FC,170);bpoke(i+0x1FD,170);
bpoke(i+0x1FE,170);bpoke(i+0x1FF,170);bpoke(i+0x200,170);bpoke(i+0x201,170);bpoke(i+0x202,170);bpoke(i+0x203,170);
bpoke(i+0x204,170);bpoke(i+0x205,170);bpoke(i+0x206,170);bpoke(i+0x207,170);bpoke(i+0x208,170);bpoke(i+0x209,170);
bpoke(i+0x20A,170);bpoke(i+0x20B,85);bpoke(i+0x20C,85);bpoke(i+0x20D,90);bpoke(i+0x20E,170);bpoke(i+0x20F,170);
bpoke(i+0x210,149);bpoke(i+0x211,85);bpoke(i+0x212,106);bpoke(i+0x213,170);bpoke(i+0x214,170);bpoke(i+0x215,170);
bpoke(i+0x216,170);bpoke(i+0x217,170);bpoke(i+0x218,170);bpoke(i+0x219,170);bpoke(i+0x21A,170);bpoke(i+0x21B,170);
bpoke(i+0x21C,170);bpoke(i+0x21D,170);bpoke(i+0x21E,170);bpoke(i+0x21F,170);bpoke(i+0x220,170);bpoke(i+0x221,170);
bpoke(i+0x222,170);bpoke(i+0x223,170);bpoke(i+0x224,170);bpoke(i+0x225,170);bpoke(i+0x226,170);bpoke(i+0x227,170);
bpoke(i+0x228,170);bpoke(i+0x229,170);bpoke(i+0x22A,170);bpoke(i+0x22B,85);bpoke(i+0x22C,85);bpoke(i+0x22D,90);
bpoke(i+0x22E,170);bpoke(i+0x22F,170);bpoke(i+0x230,149);bpoke(i+0x231,85);bpoke(i+0x232,85);bpoke(i+0x233,85);
bpoke(i+0x234,85);bpoke(i+0x235,85);bpoke(i+0x236,86);bpoke(i+0x237,170);bpoke(i+0x238,170);bpoke(i+0x239,170);
bpoke(i+0x23A,170);bpoke(i+0x23B,170);bpoke(i+0x23C,170);bpoke(i+0x23D,170);bpoke(i+0x23E,170);bpoke(i+0x23F,170);
bpoke(i+0x240,170);bpoke(i+0x241,170);bpoke(i+0x242,170);bpoke(i+0x243,170);bpoke(i+0x244,170);bpoke(i+0x245,170);
bpoke(i+0x246,170);bpoke(i+0x247,170);bpoke(i+0x248,170);bpoke(i+0x249,170);bpoke(i+0x24A,170);bpoke(i+0x24B,149);
bpoke(i+0x24C,85);bpoke(i+0x24D,106);bpoke(i+0x24E,170);bpoke(i+0x24F,170);bpoke(i+0x250,149);bpoke(i+0x251,85);
bpoke(i+0x252,85);bpoke(i+0x253,85);bpoke(i+0x254,85);bpoke(i+0x255,85);bpoke(i+0x256,86);bpoke(i+0x257,170);
bpoke(i+0x258,170);bpoke(i+0x259,170);bpoke(i+0x25A,170);bpoke(i+0x25B,170);bpoke(i+0x25C,170);bpoke(i+0x25D,170);
bpoke(i+0x25E,170);bpoke(i+0x25F,170);bpoke(i+0x260,170);bpoke(i+0x261,170);bpoke(i+0x262,170);bpoke(i+0x263,170);
bpoke(i+0x264,170);bpoke(i+0x265,170);bpoke(i+0x266,170);bpoke(i+0x267,170);bpoke(i+0x268,170);bpoke(i+0x269,170);
bpoke(i+0x26A,170);bpoke(i+0x26B,170);bpoke(i+0x26C,170);bpoke(i+0x26D,170);bpoke(i+0x26E,170);bpoke(i+0x26F,170);
bpoke(i+0x270,170);bpoke(i+0x271,170);bpoke(i+0x272,170);bpoke(i+0x273,170);bpoke(i+0x274,170);bpoke(i+0x275,170);
bpoke(i+0x276,170);bpoke(i+0x277,170);bpoke(i+0x278,170);bpoke(i+0x279,170);bpoke(i+0x27A,254);bpoke(i+0x27B,170);
bpoke(i+0x27C,170);bpoke(i+0x27D,170);bpoke(i+0x27E,170);bpoke(i+0x27F,170);bpoke(i+0x280,170);bpoke(i+0x281,170);
bpoke(i+0x282,170);bpoke(i+0x283,170);bpoke(i+0x284,170);bpoke(i+0x285,170);bpoke(i+0x286,170);bpoke(i+0x287,170);
bpoke(i+0x288,170);bpoke(i+0x289,170);bpoke(i+0x28A,170);bpoke(i+0x28B,170);bpoke(i+0x28C,170);bpoke(i+0x28D,170);
bpoke(i+0x28E,170);bpoke(i+0x28F,170);bpoke(i+0x290,170);bpoke(i+0x291,170);bpoke(i+0x292,170);bpoke(i+0x293,170);
bpoke(i+0x294,170);bpoke(i+0x295,170);bpoke(i+0x296,170);bpoke(i+0x297,170);bpoke(i+0x298,170);bpoke(i+0x299,175);
bpoke(i+0x29A,254);bpoke(i+0x29B,170);bpoke(i+0x29C,170);bpoke(i+0x29D,170);bpoke(i+0x29E,170);bpoke(i+0x29F,170);
bpoke(i+0x2A0,170);bpoke(i+0x2A1,170);bpoke(i+0x2A2,170);bpoke(i+0x2A3,170);bpoke(i+0x2A4,170);bpoke(i+0x2A5,170);
bpoke(i+0x2A6,170);bpoke(i+0x2A7,170);bpoke(i+0x2A8,170);bpoke(i+0x2A9,170);bpoke(i+0x2AA,170);bpoke(i+0x2AB,170);
bpoke(i+0x2AC,170);bpoke(i+0x2AD,170);bpoke(i+0x2AE,170);bpoke(i+0x2AF,170);bpoke(i+0x2B0,170);bpoke(i+0x2B1,170);
bpoke(i+0x2B2,170);bpoke(i+0x2B3,170);bpoke(i+0x2B4,170);bpoke(i+0x2B5,170);bpoke(i+0x2B6,170);bpoke(i+0x2B7,170);
bpoke(i+0x2B8,170);bpoke(i+0x2B9,171);bpoke(i+0x2BA,255);bpoke(i+0x2BB,170);bpoke(i+0x2BC,170);bpoke(i+0x2BD,170);
bpoke(i+0x2BE,170);bpoke(i+0x2BF,170);bpoke(i+0x2C0,170);bpoke(i+0x2C1,170);bpoke(i+0x2C2,170);bpoke(i+0x2C3,170);
bpoke(i+0x2C4,170);bpoke(i+0x2C5,170);bpoke(i+0x2C6,170);bpoke(i+0x2C7,170);bpoke(i+0x2C8,170);bpoke(i+0x2C9,170);
bpoke(i+0x2CA,170);bpoke(i+0x2CB,170);bpoke(i+0x2CC,170);bpoke(i+0x2CD,170);bpoke(i+0x2CE,170);bpoke(i+0x2CF,170);
bpoke(i+0x2D0,170);bpoke(i+0x2D1,170);bpoke(i+0x2D2,170);bpoke(i+0x2D3,170);bpoke(i+0x2D4,170);bpoke(i+0x2D5,170);
bpoke(i+0x2D6,171);bpoke(i+0x2D7,255);bpoke(i+0x2D8,170);bpoke(i+0x2D9,170);bpoke(i+0x2DA,255);bpoke(i+0x2DB,234);
bpoke(i+0x2DC,170);bpoke(i+0x2DD,170);bpoke(i+0x2DE,170);bpoke(i+0x2DF,170);bpoke(i+0x2E0,170);bpoke(i+0x2E1,170);
bpoke(i+0x2E2,170);bpoke(i+0x2E3,170);bpoke(i+0x2E4,170);bpoke(i+0x2E5,170);bpoke(i+0x2E6,170);bpoke(i+0x2E7,170);
bpoke(i+0x2E8,170);bpoke(i+0x2E9,170);bpoke(i+0x2EA,170);bpoke(i+0x2EB,170);bpoke(i+0x2EC,170);bpoke(i+0x2ED,170);
bpoke(i+0x2EE,170);bpoke(i+0x2EF,170);bpoke(i+0x2F0,170);bpoke(i+0x2F1,170);bpoke(i+0x2F2,170);bpoke(i+0x2F3,170);
bpoke(i+0x2F4,170);bpoke(i+0x2F5,170);bpoke(i+0x2F6,171);bpoke(i+0x2F7,255);bpoke(i+0x2F8,254);bpoke(i+0x2F9,170);
bpoke(i+0x2FA,191);bpoke(i+0x2FB,250);bpoke(i+0x2FC,170);bpoke(i+0x2FD,170);bpoke(i+0x2FE,170);bpoke(i+0x2FF,170);
bpoke(i+0x300,170);bpoke(i+0x301,170);bpoke(i+0x302,170);bpoke(i+0x303,170);bpoke(i+0x304,170);bpoke(i+0x305,170);
bpoke(i+0x306,170);bpoke(i+0x307,170);bpoke(i+0x308,170);bpoke(i+0x309,170);bpoke(i+0x30A,170);bpoke(i+0x30B,170);
bpoke(i+0x30C,170);bpoke(i+0x30D,170);bpoke(i+0x30E,170);bpoke(i+0x30F,170);bpoke(i+0x310,170);bpoke(i+0x311,170);
bpoke(i+0x312,170);bpoke(i+0x313,170);bpoke(i+0x314,191);bpoke(i+0x315,255);bpoke(i+0x316,170);bpoke(i+0x317,171);
bpoke(i+0x318,255);bpoke(i+0x319,250);bpoke(i+0x31A,175);bpoke(i+0x31B,254);bpoke(i+0x31C,170);bpoke(i+0x31D,170);
bpoke(i+0x31E,170);bpoke(i+0x31F,170);bpoke(i+0x320,170);bpoke(i+0x321,170);bpoke(i+0x322,170);bpoke(i+0x323,170);
bpoke(i+0x324,170);bpoke(i+0x325,170);bpoke(i+0x326,170);bpoke(i+0x327,170);bpoke(i+0x328,170);bpoke(i+0x329,170);
bpoke(i+0x32A,170);bpoke(i+0x32B,170);bpoke(i+0x32C,170);bpoke(i+0x32D,170);bpoke(i+0x32E,170);bpoke(i+0x32F,170);
bpoke(i+0x330,170);bpoke(i+0x331,170);bpoke(i+0x332,170);bpoke(i+0x333,171);bpoke(i+0x334,255);bpoke(i+0x335,255);
bpoke(i+0x336,255);bpoke(i+0x337,170);bpoke(i+0x338,175);bpoke(i+0x339,255);bpoke(i+0x33A,235);bpoke(i+0x33B,254);
bpoke(i+0x33C,170);bpoke(i+0x33D,170);bpoke(i+0x33E,170);bpoke(i+0x33F,170);bpoke(i+0x340,170);bpoke(i+0x341,170);
bpoke(i+0x342,170);bpoke(i+0x343,170);bpoke(i+0x344,170);bpoke(i+0x345,170);bpoke(i+0x346,170);bpoke(i+0x347,170);
bpoke(i+0x348,170);bpoke(i+0x349,170);bpoke(i+0x34A,170);bpoke(i+0x34B,170);bpoke(i+0x34C,170);bpoke(i+0x34D,170);
bpoke(i+0x34E,170);bpoke(i+0x34F,170);bpoke(i+0x350,170);bpoke(i+0x351,170);bpoke(i+0x352,175);bpoke(i+0x353,239);
bpoke(i+0x354,250);bpoke(i+0x355,175);bpoke(i+0x356,255);bpoke(i+0x357,250);bpoke(i+0x358,170);bpoke(i+0x359,191);
bpoke(i+0x35A,255);bpoke(i+0x35B,255);bpoke(i+0x35C,170);bpoke(i+0x35D,170);bpoke(i+0x35E,170);bpoke(i+0x35F,170);
bpoke(i+0x360,170);bpoke(i+0x361,170);bpoke(i+0x362,170);bpoke(i+0x363,170);bpoke(i+0x364,170);bpoke(i+0x365,170);
bpoke(i+0x366,170);bpoke(i+0x367,170);bpoke(i+0x368,170);bpoke(i+0x369,170);bpoke(i+0x36A,170);bpoke(i+0x36B,170);
bpoke(i+0x36C,170);bpoke(i+0x36D,170);bpoke(i+0x36E,170);bpoke(i+0x36F,170);bpoke(i+0x370,170);bpoke(i+0x371,170);
bpoke(i+0x372,191);bpoke(i+0x373,255);bpoke(i+0x374,234);bpoke(i+0x375,170);bpoke(i+0x376,191);bpoke(i+0x377,254);
bpoke(i+0x378,170);bpoke(i+0x379,170);bpoke(i+0x37A,255);bpoke(i+0x37B,255);bpoke(i+0x37C,234);bpoke(i+0x37D,170);
bpoke(i+0x37E,170);bpoke(i+0x37F,170);bpoke(i+0x380,170);bpoke(i+0x381,170);bpoke(i+0x382,170);bpoke(i+0x383,170);
bpoke(i+0x384,170);bpoke(i+0x385,170);bpoke(i+0x386,170);bpoke(i+0x387,170);bpoke(i+0x388,170);bpoke(i+0x389,170);
bpoke(i+0x38A,170);bpoke(i+0x38B,170);bpoke(i+0x38C,170);bpoke(i+0x38D,170);bpoke(i+0x38E,170);bpoke(i+0x38F,170);
bpoke(i+0x390,170);bpoke(i+0x391,170);bpoke(i+0x392,171);bpoke(i+0x393,255);bpoke(i+0x394,234);bpoke(i+0x395,170);
bpoke(i+0x396,171);bpoke(i+0x397,255);bpoke(i+0x398,234);bpoke(i+0x399,170);bpoke(i+0x39A,170);bpoke(i+0x39B,255);
bpoke(i+0x39C,250);bpoke(i+0x39D,170);bpoke(i+0x39E,170);bpoke(i+0x39F,170);bpoke(i+0x3A0,170);bpoke(i+0x3A1,170);
bpoke(i+0x3A2,170);bpoke(i+0x3A3,170);bpoke(i+0x3A4,170);bpoke(i+0x3A5,170);bpoke(i+0x3A6,170);bpoke(i+0x3A7,170);
bpoke(i+0x3A8,170);bpoke(i+0x3A9,170);bpoke(i+0x3AA,170);bpoke(i+0x3AB,170);bpoke(i+0x3AC,170);bpoke(i+0x3AD,170);
bpoke(i+0x3AE,170);bpoke(i+0x3AF,255);bpoke(i+0x3B0,255);bpoke(i+0x3B1,255);bpoke(i+0x3B2,170);bpoke(i+0x3B3,191);
bpoke(i+0x3B4,254);bpoke(i+0x3B5,170);bpoke(i+0x3B6,170);bpoke(i+0x3B7,255);bpoke(i+0x3B8,234);bpoke(i+0x3B9,170);
bpoke(i+0x3BA,170);bpoke(i+0x3BB,191);bpoke(i+0x3BC,250);bpoke(i+0x3BD,170);bpoke(i+0x3BE,170);bpoke(i+0x3BF,170);
bpoke(i+0x3C0,170);bpoke(i+0x3C1,170);bpoke(i+0x3C2,170);bpoke(i+0x3C3,170);bpoke(i+0x3C4,170);bpoke(i+0x3C5,170);
bpoke(i+0x3C6,170);bpoke(i+0x3C7,170);bpoke(i+0x3C8,170);bpoke(i+0x3C9,170);bpoke(i+0x3CA,170);bpoke(i+0x3CB,170);
bpoke(i+0x3CC,170);bpoke(i+0x3CD,170);bpoke(i+0x3CE,251);bpoke(i+0x3CF,255);bpoke(i+0x3D0,239);bpoke(i+0x3D1,255);
bpoke(i+0x3D2,250);bpoke(i+0x3D3,171);bpoke(i+0x3D4,255);bpoke(i+0x3D5,234);bpoke(i+0x3D6,170);bpoke(i+0x3D7,255);
bpoke(i+0x3D8,234);bpoke(i+0x3D9,170);bpoke(i+0x3DA,170);bpoke(i+0x3DB,191);bpoke(i+0x3DC,254);bpoke(i+0x3DD,170);
bpoke(i+0x3DE,170);bpoke(i+0x3DF,170);bpoke(i+0x3E0,170);bpoke(i+0x3E1,170);bpoke(i+0x3E2,170);bpoke(i+0x3E3,170);
bpoke(i+0x3E4,170);bpoke(i+0x3E5,170);bpoke(i+0x3E6,170);bpoke(i+0x3E7,170);bpoke(i+0x3E8,170);bpoke(i+0x3E9,170);
bpoke(i+0x3EA,170);bpoke(i+0x3EB,170);bpoke(i+0x3EC,170);bpoke(i+0x3ED,175);bpoke(i+0x3EE,255);bpoke(i+0x3EF,250);
bpoke(i+0x3F0,170);bpoke(i+0x3F1,175);bpoke(i+0x3F2,255);bpoke(i+0x3F3,170);bpoke(i+0x3F4,255);bpoke(i+0x3F5,255);
bpoke(i+0x3F6,255);bpoke(i+0x3F7,255);bpoke(i+0x3F8,170);bpoke(i+0x3F9,170);bpoke(i+0x3FA,175);bpoke(i+0x3FB,255);
bpoke(i+0x3FC,250);bpoke(i+0x3FD,170);bpoke(i+0x3FE,170);bpoke(i+0x3FF,170);bpoke(i+0x400,170);bpoke(i+0x401,170);
bpoke(i+0x402,170);bpoke(i+0x403,170);bpoke(i+0x404,170);bpoke(i+0x405,170);bpoke(i+0x406,170);bpoke(i+0x407,170);
bpoke(i+0x408,170);bpoke(i+0x409,170);bpoke(i+0x40A,170);bpoke(i+0x40B,170);bpoke(i+0x40C,170);bpoke(i+0x40D,170);
bpoke(i+0x40E,255);bpoke(i+0x40F,250);bpoke(i+0x410,170);bpoke(i+0x411,170);bpoke(i+0x412,255);bpoke(i+0x413,234);
bpoke(i+0x414,175);bpoke(i+0x415,255);bpoke(i+0x416,175);bpoke(i+0x417,234);bpoke(i+0x418,170);bpoke(i+0x419,170);
bpoke(i+0x41A,170);bpoke(i+0x41B,250);bpoke(i+0x41C,170);bpoke(i+0x41D,170);bpoke(i+0x41E,170);bpoke(i+0x41F,170);
bpoke(i+0x420,170);bpoke(i+0x421,170);bpoke(i+0x422,170);bpoke(i+0x423,170);bpoke(i+0x424,170);bpoke(i+0x425,170);
bpoke(i+0x426,170);bpoke(i+0x427,170);bpoke(i+0x428,170);bpoke(i+0x429,170);bpoke(i+0x42A,175);bpoke(i+0x42B,255);
bpoke(i+0x42C,254);bpoke(i+0x42D,170);bpoke(i+0x42E,191);bpoke(i+0x42F,254);bpoke(i+0x430,170);bpoke(i+0x431,170);
bpoke(i+0x432,191);bpoke(i+0x433,250);bpoke(i+0x434,170);bpoke(i+0x435,255);bpoke(i+0x436,250);bpoke(i+0x437,170);
bpoke(i+0x438,170);bpoke(i+0x439,170);bpoke(i+0x43A,170);bpoke(i+0x43B,170);bpoke(i+0x43C,170);bpoke(i+0x43D,170);
bpoke(i+0x43E,170);bpoke(i+0x43F,170);bpoke(i+0x440,170);bpoke(i+0x441,170);bpoke(i+0x442,170);bpoke(i+0x443,170);
bpoke(i+0x444,170);bpoke(i+0x445,175);bpoke(i+0x446,255);bpoke(i+0x447,170);bpoke(i+0x448,170);bpoke(i+0x449,175);
bpoke(i+0x44A,255);bpoke(i+0x44B,255);bpoke(i+0x44C,255);bpoke(i+0x44D,234);bpoke(i+0x44E,171);bpoke(i+0x44F,255);
bpoke(i+0x450,234);bpoke(i+0x451,170);bpoke(i+0x452,191);bpoke(i+0x453,250);bpoke(i+0x454,170);bpoke(i+0x455,175);
bpoke(i+0x456,255);bpoke(i+0x457,170);bpoke(i+0x458,170);bpoke(i+0x459,170);bpoke(i+0x45A,170);bpoke(i+0x45B,170);
bpoke(i+0x45C,170);bpoke(i+0x45D,170);bpoke(i+0x45E,170);bpoke(i+0x45F,170);bpoke(i+0x460,170);bpoke(i+0x461,170);
bpoke(i+0x462,170);bpoke(i+0x463,170);bpoke(i+0x464,190);bpoke(i+0x465,170);bpoke(i+0x466,255);bpoke(i+0x467,250);
bpoke(i+0x468,170);bpoke(i+0x469,175);bpoke(i+0x46A,254);bpoke(i+0x46B,170);bpoke(i+0x46C,191);bpoke(i+0x46D,254);
bpoke(i+0x46E,170);bpoke(i+0x46F,191);bpoke(i+0x470,255);bpoke(i+0x471,255);bpoke(i+0x472,255);bpoke(i+0x473,250);
bpoke(i+0x474,170);bpoke(i+0x475,170);bpoke(i+0x476,255);bpoke(i+0x477,234);bpoke(i+0x478,170);bpoke(i+0x479,170);
bpoke(i+0x47A,170);bpoke(i+0x47B,170);bpoke(i+0x47C,170);bpoke(i+0x47D,170);bpoke(i+0x47E,170);bpoke(i+0x47F,170);
bpoke(i+0x480,170);bpoke(i+0x481,170);bpoke(i+0x482,170);bpoke(i+0x483,255);bpoke(i+0x484,255);bpoke(i+0x485,234);
bpoke(i+0x486,175);bpoke(i+0x487,255);bpoke(i+0x488,170);bpoke(i+0x489,175);bpoke(i+0x48A,254);bpoke(i+0x48B,171);
bpoke(i+0x48C,255);bpoke(i+0x48D,255);bpoke(i+0x48E,234);bpoke(i+0x48F,171);bpoke(i+0x490,255);bpoke(i+0x491,255);
bpoke(i+0x492,254);bpoke(i+0x493,170);bpoke(i+0x494,170);bpoke(i+0x495,170);bpoke(i+0x496,190);bpoke(i+0x497,170);
bpoke(i+0x498,170);bpoke(i+0x499,170);bpoke(i+0x49A,170);bpoke(i+0x49B,170);bpoke(i+0x49C,170);bpoke(i+0x49D,170);
bpoke(i+0x49E,170);bpoke(i+0x49F,170);bpoke(i+0x4A0,170);bpoke(i+0x4A1,170);bpoke(i+0x4A2,255);bpoke(i+0x4A3,255);
bpoke(i+0x4A4,254);bpoke(i+0x4A5,170);bpoke(i+0x4A6,171);bpoke(i+0x4A7,255);bpoke(i+0x4A8,234);bpoke(i+0x4A9,170);
bpoke(i+0x4AA,170);bpoke(i+0x4AB,255);bpoke(i+0x4AC,250);bpoke(i+0x4AD,255);bpoke(i+0x4AE,250);bpoke(i+0x4AF,170);
bpoke(i+0x4B0,255);bpoke(i+0x4B1,250);bpoke(i+0x4B2,170);bpoke(i+0x4B3,170);bpoke(i+0x4B4,170);bpoke(i+0x4B5,170);
bpoke(i+0x4B6,170);bpoke(i+0x4B7,170);bpoke(i+0x4B8,170);bpoke(i+0x4B9,170);bpoke(i+0x4BA,170);bpoke(i+0x4BB,170);
bpoke(i+0x4BC,170);bpoke(i+0x4BD,170);bpoke(i+0x4BE,170);bpoke(i+0x4BF,170);bpoke(i+0x4C0,170);bpoke(i+0x4C1,255);
bpoke(i+0x4C2,255);bpoke(i+0x4C3,250);bpoke(i+0x4C4,170);bpoke(i+0x4C5,170);bpoke(i+0x4C6,170);bpoke(i+0x4C7,191);
bpoke(i+0x4C8,254);bpoke(i+0x4C9,170);bpoke(i+0x4CA,171);bpoke(i+0x4CB,254);bpoke(i+0x4CC,170);bpoke(i+0x4CD,175);
bpoke(i+0x4CE,255);bpoke(i+0x4CF,170);bpoke(i+0x4D0,175);bpoke(i+0x4D1,255);bpoke(i+0x4D2,170);bpoke(i+0x4D3,170);
bpoke(i+0x4D4,170);bpoke(i+0x4D5,170);bpoke(i+0x4D6,170);bpoke(i+0x4D7,170);bpoke(i+0x4D8,170);bpoke(i+0x4D9,170);
bpoke(i+0x4DA,191);bpoke(i+0x4DB,234);bpoke(i+0x4DC,170);bpoke(i+0x4DD,170);bpoke(i+0x4DE,170);bpoke(i+0x4DF,170);
bpoke(i+0x4E0,170);bpoke(i+0x4E1,255);bpoke(i+0x4E2,254);bpoke(i+0x4E3,170);bpoke(i+0x4E4,170);bpoke(i+0x4E5,170);
bpoke(i+0x4E6,170);bpoke(i+0x4E7,171);bpoke(i+0x4E8,255);bpoke(i+0x4E9,234);bpoke(i+0x4EA,171);bpoke(i+0x4EB,255);
bpoke(i+0x4EC,170);bpoke(i+0x4ED,191);bpoke(i+0x4EE,255);bpoke(i+0x4EF,234);bpoke(i+0x4F0,170);bpoke(i+0x4F1,255);
bpoke(i+0x4F2,250);bpoke(i+0x4F3,170);bpoke(i+0x4F4,170);bpoke(i+0x4F5,170);bpoke(i+0x4F6,170);bpoke(i+0x4F7,170);
bpoke(i+0x4F8,170);bpoke(i+0x4F9,170);bpoke(i+0x4FA,191);bpoke(i+0x4FB,254);bpoke(i+0x4FC,170);bpoke(i+0x4FD,170);
bpoke(i+0x4FE,170);bpoke(i+0x4FF,170);bpoke(i+0x500,170);bpoke(i+0x501,175);bpoke(i+0x502,255);bpoke(i+0x503,170);
bpoke(i+0x504,170);bpoke(i+0x505,255);bpoke(i+0x506,234);bpoke(i+0x507,170);bpoke(i+0x508,255);bpoke(i+0x509,254);
bpoke(i+0x50A,170);bpoke(i+0x50B,255);bpoke(i+0x50C,255);bpoke(i+0x50D,255);bpoke(i+0x50E,170);bpoke(i+0x50F,170);
bpoke(i+0x510,170);bpoke(i+0x511,175);bpoke(i+0x512,250);bpoke(i+0x513,170);bpoke(i+0x514,170);bpoke(i+0x515,170);
bpoke(i+0x516,170);bpoke(i+0x517,170);bpoke(i+0x518,170);bpoke(i+0x519,170);bpoke(i+0x51A,171);bpoke(i+0x51B,255);
bpoke(i+0x51C,234);bpoke(i+0x51D,170);bpoke(i+0x51E,170);bpoke(i+0x51F,170);bpoke(i+0x520,170);bpoke(i+0x521,170);
bpoke(i+0x522,255);bpoke(i+0x523,251);bpoke(i+0x524,255);bpoke(i+0x525,255);bpoke(i+0x526,250);bpoke(i+0x527,170);
bpoke(i+0x528,175);bpoke(i+0x529,255);bpoke(i+0x52A,170);bpoke(i+0x52B,175);bpoke(i+0x52C,255);bpoke(i+0x52D,234);
bpoke(i+0x52E,170);bpoke(i+0x52F,170);bpoke(i+0x530,170);bpoke(i+0x531,170);bpoke(i+0x532,170);bpoke(i+0x533,170);
bpoke(i+0x534,170);bpoke(i+0x535,170);bpoke(i+0x536,170);bpoke(i+0x537,170);bpoke(i+0x538,170);bpoke(i+0x539,170);
bpoke(i+0x53A,170);bpoke(i+0x53B,255);bpoke(i+0x53C,254);bpoke(i+0x53D,170);bpoke(i+0x53E,170);bpoke(i+0x53F,170);
bpoke(i+0x540,170);bpoke(i+0x541,170);bpoke(i+0x542,191);bpoke(i+0x543,255);bpoke(i+0x544,255);bpoke(i+0x545,250);
bpoke(i+0x546,170);bpoke(i+0x547,170);bpoke(i+0x548,170);bpoke(i+0x549,255);bpoke(i+0x54A,250);bpoke(i+0x54B,170);
bpoke(i+0x54C,170);bpoke(i+0x54D,170);bpoke(i+0x54E,170);bpoke(i+0x54F,170);bpoke(i+0x550,170);bpoke(i+0x551,170);
bpoke(i+0x552,170);bpoke(i+0x553,170);bpoke(i+0x554,170);bpoke(i+0x555,170);bpoke(i+0x556,170);bpoke(i+0x557,170);
bpoke(i+0x558,170);bpoke(i+0x559,171);bpoke(i+0x55A,255);bpoke(i+0x55B,255);bpoke(i+0x55C,255);bpoke(i+0x55D,170);
bpoke(i+0x55E,170);bpoke(i+0x55F,170);bpoke(i+0x560,170);bpoke(i+0x561,170);bpoke(i+0x562,171);bpoke(i+0x563,255);
bpoke(i+0x564,250);bpoke(i+0x565,170);bpoke(i+0x566,170);bpoke(i+0x567,170);bpoke(i+0x568,170);bpoke(i+0x569,175);
bpoke(i+0x56A,255);bpoke(i+0x56B,170);bpoke(i+0x56C,170);bpoke(i+0x56D,170);bpoke(i+0x56E,170);bpoke(i+0x56F,170);
bpoke(i+0x570,170);bpoke(i+0x571,170);bpoke(i+0x572,170);bpoke(i+0x573,170);bpoke(i+0x574,170);bpoke(i+0x575,170);
bpoke(i+0x576,170);bpoke(i+0x577,170);bpoke(i+0x578,170);bpoke(i+0x579,191);bpoke(i+0x57A,255);bpoke(i+0x57B,175);
bpoke(i+0x57C,255);bpoke(i+0x57D,250);bpoke(i+0x57E,170);bpoke(i+0x57F,170);bpoke(i+0x580,170);bpoke(i+0x581,170);
bpoke(i+0x582,170);bpoke(i+0x583,191);bpoke(i+0x584,254);bpoke(i+0x585,170);bpoke(i+0x586,170);bpoke(i+0x587,170);
bpoke(i+0x588,170);bpoke(i+0x589,170);bpoke(i+0x58A,170);bpoke(i+0x58B,170);bpoke(i+0x58C,170);bpoke(i+0x58D,170);
bpoke(i+0x58E,170);bpoke(i+0x58F,170);bpoke(i+0x590,170);bpoke(i+0x591,170);bpoke(i+0x592,170);bpoke(i+0x593,170);
bpoke(i+0x594,170);bpoke(i+0x595,170);bpoke(i+0x596,170);bpoke(i+0x597,170);bpoke(i+0x598,170);bpoke(i+0x599,255);
bpoke(i+0x59A,250);bpoke(i+0x59B,170);bpoke(i+0x59C,175);bpoke(i+0x59D,255);bpoke(i+0x59E,170);bpoke(i+0x59F,170);
bpoke(i+0x5A0,170);bpoke(i+0x5A1,170);bpoke(i+0x5A2,170);bpoke(i+0x5A3,171);bpoke(i+0x5A4,255);bpoke(i+0x5A5,234);
bpoke(i+0x5A6,170);bpoke(i+0x5A7,170);bpoke(i+0x5A8,170);bpoke(i+0x5A9,170);bpoke(i+0x5AA,170);bpoke(i+0x5AB,170);
bpoke(i+0x5AC,170);bpoke(i+0x5AD,170);bpoke(i+0x5AE,170);bpoke(i+0x5AF,170);bpoke(i+0x5B0,170);bpoke(i+0x5B1,170);
bpoke(i+0x5B2,175);bpoke(i+0x5B3,234);bpoke(i+0x5B4,170);bpoke(i+0x5B5,170);bpoke(i+0x5B6,171);bpoke(i+0x5B7,255);
bpoke(i+0x5B8,234);bpoke(i+0x5B9,191);bpoke(i+0x5BA,250);bpoke(i+0x5BB,170);bpoke(i+0x5BC,171);bpoke(i+0x5BD,255);
bpoke(i+0x5BE,234);bpoke(i+0x5BF,170);bpoke(i+0x5C0,170);bpoke(i+0x5C1,170);bpoke(i+0x5C2,170);bpoke(i+0x5C3,170);
bpoke(i+0x5C4,255);bpoke(i+0x5C5,254);bpoke(i+0x5C6,170);bpoke(i+0x5C7,170);bpoke(i+0x5C8,170);bpoke(i+0x5C9,170);
bpoke(i+0x5CA,170);bpoke(i+0x5CB,170);bpoke(i+0x5CC,170);bpoke(i+0x5CD,170);bpoke(i+0x5CE,170);bpoke(i+0x5CF,170);
bpoke(i+0x5D0,170);bpoke(i+0x5D1,170);bpoke(i+0x5D2,191);bpoke(i+0x5D3,254);bpoke(i+0x5D4,170);bpoke(i+0x5D5,175);
bpoke(i+0x5D6,255);bpoke(i+0x5D7,255);bpoke(i+0x5D8,250);bpoke(i+0x5D9,191);bpoke(i+0x5DA,254);bpoke(i+0x5DB,170);
bpoke(i+0x5DC,170);bpoke(i+0x5DD,191);bpoke(i+0x5DE,254);bpoke(i+0x5DF,170);bpoke(i+0x5E0,170);bpoke(i+0x5E1,170);
bpoke(i+0x5E2,170);bpoke(i+0x5E3,170);bpoke(i+0x5E4,175);bpoke(i+0x5E5,255);bpoke(i+0x5E6,234);bpoke(i+0x5E7,170);
bpoke(i+0x5E8,170);bpoke(i+0x5E9,170);bpoke(i+0x5EA,170);bpoke(i+0x5EB,170);bpoke(i+0x5EC,170);bpoke(i+0x5ED,170);
bpoke(i+0x5EE,170);bpoke(i+0x5EF,170);bpoke(i+0x5F0,170);bpoke(i+0x5F1,170);bpoke(i+0x5F2,175);bpoke(i+0x5F3,234);
bpoke(i+0x5F4,170);bpoke(i+0x5F5,175);bpoke(i+0x5F6,255);bpoke(i+0x5F7,250);bpoke(i+0x5F8,170);bpoke(i+0x5F9,171);
bpoke(i+0x5FA,255);bpoke(i+0x5FB,234);bpoke(i+0x5FC,170);bpoke(i+0x5FD,191);bpoke(i+0x5FE,255);bpoke(i+0x5FF,234);
bpoke(i+0x600,170);bpoke(i+0x601,170);bpoke(i+0x602,170);bpoke(i+0x603,170);bpoke(i+0x604,170);bpoke(i+0x605,250);
bpoke(i+0x606,170);bpoke(i+0x607,170);bpoke(i+0x608,170);bpoke(i+0x609,170);bpoke(i+0x60A,170);bpoke(i+0x60B,170);
bpoke(i+0x60C,170);bpoke(i+0x60D,170);bpoke(i+0x60E,170);bpoke(i+0x60F,191);bpoke(i+0x610,255);bpoke(i+0x611,170);
bpoke(i+0x612,170);bpoke(i+0x613,175);bpoke(i+0x614,250);bpoke(i+0x615,170);bpoke(i+0x616,255);bpoke(i+0x617,254);
bpoke(i+0x618,170);bpoke(i+0x619,170);bpoke(i+0x61A,191);bpoke(i+0x61B,255);bpoke(i+0x61C,255);bpoke(i+0x61D,255);
bpoke(i+0x61E,190);bpoke(i+0x61F,170);bpoke(i+0x620,170);bpoke(i+0x621,170);bpoke(i+0x622,170);bpoke(i+0x623,170);
bpoke(i+0x624,170);bpoke(i+0x625,170);bpoke(i+0x626,170);bpoke(i+0x627,170);bpoke(i+0x628,170);bpoke(i+0x629,170);
bpoke(i+0x62A,170);bpoke(i+0x62B,170);bpoke(i+0x62C,170);bpoke(i+0x62D,170);bpoke(i+0x62E,255);bpoke(i+0x62F,255);
bpoke(i+0x630,255);bpoke(i+0x631,254);bpoke(i+0x632,170);bpoke(i+0x633,175);bpoke(i+0x634,255);bpoke(i+0x635,170);
bpoke(i+0x636,175);bpoke(i+0x637,255);bpoke(i+0x638,170);bpoke(i+0x639,170);bpoke(i+0x63A,171);bpoke(i+0x63B,255);
bpoke(i+0x63C,255);bpoke(i+0x63D,250);bpoke(i+0x63E,170);bpoke(i+0x63F,170);bpoke(i+0x640,170);bpoke(i+0x641,170);
bpoke(i+0x642,170);bpoke(i+0x643,170);bpoke(i+0x644,170);bpoke(i+0x645,170);bpoke(i+0x646,170);bpoke(i+0x647,170);
bpoke(i+0x648,170);bpoke(i+0x649,170);bpoke(i+0x64A,170);bpoke(i+0x64B,170);bpoke(i+0x64C,170);bpoke(i+0x64D,255);
bpoke(i+0x64E,255);bpoke(i+0x64F,250);bpoke(i+0x650,171);bpoke(i+0x651,255);bpoke(i+0x652,234);bpoke(i+0x653,170);
bpoke(i+0x654,255);bpoke(i+0x655,250);bpoke(i+0x656,170);bpoke(i+0x657,255);bpoke(i+0x658,250);bpoke(i+0x659,170);
bpoke(i+0x65A,170);bpoke(i+0x65B,170);bpoke(i+0x65C,170);bpoke(i+0x65D,170);bpoke(i+0x65E,170);bpoke(i+0x65F,170);
bpoke(i+0x660,170);bpoke(i+0x661,170);bpoke(i+0x662,170);bpoke(i+0x663,170);bpoke(i+0x664,170);bpoke(i+0x665,170);
bpoke(i+0x666,170);bpoke(i+0x667,170);bpoke(i+0x668,170);bpoke(i+0x669,170);bpoke(i+0x66A,170);bpoke(i+0x66B,170);
bpoke(i+0x66C,175);bpoke(i+0x66D,255);bpoke(i+0x66E,250);bpoke(i+0x66F,170);bpoke(i+0x670,170);bpoke(i+0x671,255);
bpoke(i+0x672,234);bpoke(i+0x673,170);bpoke(i+0x674,175);bpoke(i+0x675,255);bpoke(i+0x676,170);bpoke(i+0x677,175);
bpoke(i+0x678,255);bpoke(i+0x679,170);bpoke(i+0x67A,170);bpoke(i+0x67B,170);bpoke(i+0x67C,170);bpoke(i+0x67D,170);
bpoke(i+0x67E,170);bpoke(i+0x67F,170);bpoke(i+0x680,170);bpoke(i+0x681,170);bpoke(i+0x682,170);bpoke(i+0x683,170);
bpoke(i+0x684,170);bpoke(i+0x685,170);bpoke(i+0x686,170);bpoke(i+0x687,170);bpoke(i+0x688,170);bpoke(i+0x689,170);
bpoke(i+0x68A,170);bpoke(i+0x68B,170);bpoke(i+0x68C,170);bpoke(i+0x68D,255);bpoke(i+0x68E,250);bpoke(i+0x68F,170);
bpoke(i+0x690,171);bpoke(i+0x691,255);bpoke(i+0x692,255);bpoke(i+0x693,170);bpoke(i+0x694,171);bpoke(i+0x695,255);
bpoke(i+0x696,234);bpoke(i+0x697,171);bpoke(i+0x698,255);bpoke(i+0x699,234);bpoke(i+0x69A,170);bpoke(i+0x69B,170);
bpoke(i+0x69C,170);bpoke(i+0x69D,170);bpoke(i+0x69E,170);bpoke(i+0x69F,170);bpoke(i+0x6A0,170);bpoke(i+0x6A1,170);
bpoke(i+0x6A2,170);bpoke(i+0x6A3,170);bpoke(i+0x6A4,170);bpoke(i+0x6A5,170);bpoke(i+0x6A6,170);bpoke(i+0x6A7,170);
bpoke(i+0x6A8,170);bpoke(i+0x6A9,170);bpoke(i+0x6AA,170);bpoke(i+0x6AB,170);bpoke(i+0x6AC,170);bpoke(i+0x6AD,191);
bpoke(i+0x6AE,255);bpoke(i+0x6AF,170);bpoke(i+0x6B0,255);bpoke(i+0x6B1,255);bpoke(i+0x6B2,255);bpoke(i+0x6B3,255);
bpoke(i+0x6B4,170);bpoke(i+0x6B5,191);bpoke(i+0x6B6,254);bpoke(i+0x6B7,170);bpoke(i+0x6B8,191);bpoke(i+0x6B9,234);
bpoke(i+0x6BA,170);bpoke(i+0x6BB,170);bpoke(i+0x6BC,170);bpoke(i+0x6BD,170);bpoke(i+0x6BE,170);bpoke(i+0x6BF,170);
bpoke(i+0x6C0,170);bpoke(i+0x6C1,170);bpoke(i+0x6C2,170);bpoke(i+0x6C3,170);bpoke(i+0x6C4,170);bpoke(i+0x6C5,170);
bpoke(i+0x6C6,170);bpoke(i+0x6C7,170);bpoke(i+0x6C8,170);bpoke(i+0x6C9,170);bpoke(i+0x6CA,170);bpoke(i+0x6CB,170);
bpoke(i+0x6CC,170);bpoke(i+0x6CD,171);bpoke(i+0x6CE,255);bpoke(i+0x6CF,255);bpoke(i+0x6D0,255);bpoke(i+0x6D1,250);
bpoke(i+0x6D2,171);bpoke(i+0x6D3,255);bpoke(i+0x6D4,234);bpoke(i+0x6D5,171);bpoke(i+0x6D6,255);bpoke(i+0x6D7,234);
bpoke(i+0x6D8,170);bpoke(i+0x6D9,170);bpoke(i+0x6DA,170);bpoke(i+0x6DB,170);bpoke(i+0x6DC,170);bpoke(i+0x6DD,170);
bpoke(i+0x6DE,170);bpoke(i+0x6DF,170);bpoke(i+0x6E0,170);bpoke(i+0x6E1,170);bpoke(i+0x6E2,170);bpoke(i+0x6E3,170);
bpoke(i+0x6E4,170);bpoke(i+0x6E5,170);bpoke(i+0x6E6,170);bpoke(i+0x6E7,170);bpoke(i+0x6E8,170);bpoke(i+0x6E9,170);
bpoke(i+0x6EA,170);bpoke(i+0x6EB,170);bpoke(i+0x6EC,170);bpoke(i+0x6ED,170);bpoke(i+0x6EE,191);bpoke(i+0x6EF,255);
bpoke(i+0x6F0,234);bpoke(i+0x6F1,170);bpoke(i+0x6F2,170);bpoke(i+0x6F3,255);bpoke(i+0x6F4,250);bpoke(i+0x6F5,170);
bpoke(i+0x6F6,191);bpoke(i+0x6F7,170);bpoke(i+0x6F8,170);bpoke(i+0x6F9,170);bpoke(i+0x6FA,170);bpoke(i+0x6FB,170);
bpoke(i+0x6FC,170);bpoke(i+0x6FD,170);bpoke(i+0x6FE,170);bpoke(i+0x6FF,170);bpoke(i+0x700,170);bpoke(i+0x701,170);
bpoke(i+0x702,170);bpoke(i+0x703,170);bpoke(i+0x704,170);bpoke(i+0x705,170);bpoke(i+0x706,170);bpoke(i+0x707,170);
bpoke(i+0x708,170);bpoke(i+0x709,170);bpoke(i+0x70A,170);bpoke(i+0x70B,170);bpoke(i+0x70C,170);bpoke(i+0x70D,170);
bpoke(i+0x70E,171);bpoke(i+0x70F,255);bpoke(i+0x710,234);bpoke(i+0x711,170);bpoke(i+0x712,170);bpoke(i+0x713,255);
bpoke(i+0x714,250);bpoke(i+0x715,170);bpoke(i+0x716,170);bpoke(i+0x717,170);bpoke(i+0x718,170);bpoke(i+0x719,170);
bpoke(i+0x71A,170);bpoke(i+0x71B,170);bpoke(i+0x71C,170);bpoke(i+0x71D,170);bpoke(i+0x71E,170);bpoke(i+0x71F,170);
bpoke(i+0x720,170);bpoke(i+0x721,170);bpoke(i+0x722,170);bpoke(i+0x723,170);bpoke(i+0x724,170);bpoke(i+0x725,170);
bpoke(i+0x726,170);bpoke(i+0x727,170);bpoke(i+0x728,170);bpoke(i+0x729,170);bpoke(i+0x72A,170);bpoke(i+0x72B,170);
bpoke(i+0x72C,170);bpoke(i+0x72D,170);bpoke(i+0x72E,170);bpoke(i+0x72F,191);bpoke(i+0x730,254);bpoke(i+0x731,170);
bpoke(i+0x732,191);bpoke(i+0x733,255);bpoke(i+0x734,234);bpoke(i+0x735,170);bpoke(i+0x736,170);bpoke(i+0x737,170);
bpoke(i+0x738,170);bpoke(i+0x739,170);bpoke(i+0x73A,170);bpoke(i+0x73B,170);bpoke(i+0x73C,170);bpoke(i+0x73D,170);
bpoke(i+0x73E,170);bpoke(i+0x73F,170);bpoke(i+0x740,170);bpoke(i+0x741,170);bpoke(i+0x742,170);bpoke(i+0x743,170);
bpoke(i+0x744,170);bpoke(i+0x745,170);bpoke(i+0x746,170);bpoke(i+0x747,170);bpoke(i+0x748,170);bpoke(i+0x749,170);
bpoke(i+0x74A,170);bpoke(i+0x74B,170);bpoke(i+0x74C,170);bpoke(i+0x74D,170);bpoke(i+0x74E,170);bpoke(i+0x74F,175);
bpoke(i+0x750,255);bpoke(i+0x751,255);bpoke(i+0x752,255);bpoke(i+0x753,254);bpoke(i+0x754,170);bpoke(i+0x755,170);
bpoke(i+0x756,170);bpoke(i+0x757,170);bpoke(i+0x758,170);bpoke(i+0x759,170);bpoke(i+0x75A,170);bpoke(i+0x75B,170);
bpoke(i+0x75C,170);bpoke(i+0x75D,170);bpoke(i+0x75E,170);bpoke(i+0x75F,170);bpoke(i+0x760,170);bpoke(i+0x761,170);
bpoke(i+0x762,170);bpoke(i+0x763,170);bpoke(i+0x764,170);bpoke(i+0x765,170);bpoke(i+0x766,170);bpoke(i+0x767,170);
bpoke(i+0x768,170);bpoke(i+0x769,170);bpoke(i+0x76A,170);bpoke(i+0x76B,170);bpoke(i+0x76C,170);bpoke(i+0x76D,170);
bpoke(i+0x76E,170);bpoke(i+0x76F,170);bpoke(i+0x770,255);bpoke(i+0x771,255);bpoke(i+0x772,254);bpoke(i+0x773,170);
bpoke(i+0x774,170);bpoke(i+0x775,170);bpoke(i+0x776,170);bpoke(i+0x777,170);bpoke(i+0x778,170);bpoke(i+0x779,170);
bpoke(i+0x77A,170);bpoke(i+0x77B,170);bpoke(i+0x77C,170);bpoke(i+0x77D,170);bpoke(i+0x77E,170);bpoke(i+0x77F,170);
bpoke(i+0x780,170);bpoke(i+0x781,170);bpoke(i+0x782,170);bpoke(i+0x783,170);bpoke(i+0x784,170);bpoke(i+0x785,170);
bpoke(i+0x786,170);bpoke(i+0x787,170);bpoke(i+0x788,170);bpoke(i+0x789,170);bpoke(i+0x78A,170);bpoke(i+0x78B,170);
bpoke(i+0x78C,170);bpoke(i+0x78D,170);bpoke(i+0x78E,170);bpoke(i+0x78F,170);bpoke(i+0x790,175);bpoke(i+0x791,250);
bpoke(i+0x792,170);bpoke(i+0x793,170);bpoke(i+0x794,170);bpoke(i+0x795,170);bpoke(i+0x796,170);bpoke(i+0x797,170);
bpoke(i+0x798,170);bpoke(i+0x799,170);bpoke(i+0x79A,170);bpoke(i+0x79B,170);bpoke(i+0x79C,170);bpoke(i+0x79D,170);
bpoke(i+0x79E,170);bpoke(i+0x79F,170);bpoke(i+0x7A0,170);bpoke(i+0x7A1,170);bpoke(i+0x7A2,170);bpoke(i+0x7A3,170);
bpoke(i+0x7A4,170);bpoke(i+0x7A5,170);bpoke(i+0x7A6,170);bpoke(i+0x7A7,170);bpoke(i+0x7A8,170);bpoke(i+0x7A9,170);
bpoke(i+0x7AA,170);bpoke(i+0x7AB,170);bpoke(i+0x7AC,170);bpoke(i+0x7AD,170);bpoke(i+0x7AE,170);bpoke(i+0x7AF,170);
bpoke(i+0x7B0,170);bpoke(i+0x7B1,170);bpoke(i+0x7B2,170);bpoke(i+0x7B3,170);bpoke(i+0x7B4,170);bpoke(i+0x7B5,170);
bpoke(i+0x7B6,170);bpoke(i+0x7B7,170);bpoke(i+0x7B8,170);bpoke(i+0x7B9,170);bpoke(i+0x7BA,170);bpoke(i+0x7BB,170);
bpoke(i+0x7BC,170);bpoke(i+0x7BD,170);bpoke(i+0x7BE,170);bpoke(i+0x7BF,170);bpoke(i+0x7C0,170);bpoke(i+0x7C1,170);
bpoke(i+0x7C2,170);bpoke(i+0x7C3,170);bpoke(i+0x7C4,170);bpoke(i+0x7C5,170);bpoke(i+0x7C6,170);bpoke(i+0x7C7,170);
bpoke(i+0x7C8,170);bpoke(i+0x7C9,170);bpoke(i+0x7CA,170);bpoke(i+0x7CB,170);bpoke(i+0x7CC,170);bpoke(i+0x7CD,170);
bpoke(i+0x7CE,170);bpoke(i+0x7CF,170);bpoke(i+0x7D0,170);bpoke(i+0x7D1,170);bpoke(i+0x7D2,170);bpoke(i+0x7D3,170);
bpoke(i+0x7D4,170);bpoke(i+0x7D5,170);bpoke(i+0x7D6,170);bpoke(i+0x7D7,170);bpoke(i+0x7D8,170);bpoke(i+0x7D9,170);
bpoke(i+0x7DA,170);bpoke(i+0x7DB,170);bpoke(i+0x7DC,170);bpoke(i+0x7DD,170);bpoke(i+0x7DE,170);bpoke(i+0x7DF,170);
bpoke(i+0x7E0,170);bpoke(i+0x7E1,170);bpoke(i+0x7E2,170);bpoke(i+0x7E3,170);bpoke(i+0x7E4,170);bpoke(i+0x7E5,170);
bpoke(i+0x7E6,170);bpoke(i+0x7E7,170);bpoke(i+0x7E8,170);bpoke(i+0x7E9,170);bpoke(i+0x7EA,170);bpoke(i+0x7EB,170);
bpoke(i+0x7EC,170);bpoke(i+0x7ED,170);bpoke(i+0x7EE,170);bpoke(i+0x7EF,170);bpoke(i+0x7F0,170);bpoke(i+0x7F1,170);
bpoke(i+0x7F2,170);bpoke(i+0x7F3,170);bpoke(i+0x7F4,170);bpoke(i+0x7F5,170);bpoke(i+0x7F6,170);bpoke(i+0x7F7,170);
bpoke(i+0x7F8,170);bpoke(i+0x7F9,170);bpoke(i+0x7FA,170);bpoke(i+0x7FB,170);bpoke(i+0x7FC,170);bpoke(i+0x7FD,170);
bpoke(i+0x7FE,170);bpoke(i+0x7FF,170);

   	draw_string(0, 20, 2, "CONTROLS:");
   	draw_string(0, 26, 2, "Q   = UP");
   	draw_string(0, 32, 2, "ESC = EXIT");
   	draw_string(80, 20, 2, "SPEED:");
	score((0x7000+29)+(32*20),speed);
   	draw_string(85, 26, 2, "0=Fast");
   	draw_string(85, 32, 2, "5=Slow");
   	draw_string(12, 40, 2, "PRESS <S> TO START");
   	draw_string(5, 59, 3, "Last score:");
	score((0x7000+20)+(32*59),sc1);
	score((0x7000+19)+(32*59),sc2);
	score((0x7000+18)+(32*59),sc3);
   	draw_string(110, 59, 3, "/DM");
	j=0;   sc1=0;	sc2=0;	sc3=0;
      	do{	score((0x7000+29)+(32*20),speed);
		draw_string(54, 40, 2, "S");
		for(i=0;i<500;i++){
			if((mem[0x68fd] & 0x2) == 0) {j=1;break;}
			if(inch()=='0') {speed=0;}
			if(inch()=='1') {speed=1;}
			if(inch()=='2') {speed=2;}
			if(inch()=='3') {speed=3;}
			if(inch()=='4') {speed=4;}
			if(inch()=='5') {speed=5;}

/*			if((mem[0x68df] & 0x10)== 0) {speed=0;}
			if((mem[0x68f7] & 0x10)== 0) {speed=1;}
			if((mem[0x68f7] & 0x2) == 0) {speed=2;}
			if((mem[0x68f7] & 0x8) == 0) {speed=3;}
			if((mem[0x68f7] & 0x20)== 0) {speed=4;}
			if((mem[0x68f7] & 0x00)== 0) {speed=5;}  */   }

		score((0x7000+29)+(32*20),speed);
		draw_string(54, 40, 0, "S");
		for(i=0;i<500;i++){
			if((mem[0x68fd] & 0x2) == 0) {j=1;break;}
			if(inch()=='0') {speed=0;}
			if(inch()=='1') {speed=1;}
			if(inch()=='2') {speed=2;}
			if(inch()=='3') {speed=3;}
			if(inch()=='4') {speed=4;}
			if(inch()=='5') {speed=5;}
			}
	} while (j==0);
	memset(scr,0,2048);
	memset(0x7000,0,2048);
	setbase(0x7000);
   	draw_string(6, 59, 1, "Score: ");
   	draw_string(74, 59, 1, "Lives: ");
	setbase(scr);
	while((end==0)||(won==0)){
		for(i=-1;i<(speed*50);i++){;}
		c=rand(6);
		if (c==1) {a++;b++;}
		if (c==2) {a--;b--;}
		if (a<5) {a=5;b=(43-15);}
		if (b>57) {a=34;b=57;}	

		for(i=0;i<a;i++){mem[(scr+31)+(i*32)]=170;}
		for(i=b;i<59;i++){mem[(scr+31)+(i*32)]=170;}
		mem[(scr+31)+(a*32)]=255;
		mem[(scr+31)+(b*32)]=255;

		if ((mem[0x68fe] & 0x10) == 0) {y=y-2;}						/* Q = up */
		y++;
		x++;
/*		x2++;			    */
/*		if(x2>100){a++;b--;x2=0;}   */
/*		if(c==3){a--;b++;}          */
/*		if((b-a)<15){a--;b++;}	    */							/* minimum distance between walls */
		if(x>40) {sc1++;x=0;}								/* score                  */
		if(sc1>9){sc2++;sc1=0;}
		if(sc2>9){sc3++;sc2=0;}
		if(sc3>9){sc4++;sc3=0;}
		if(sc4==1){won=1;}								/* if score=1000 then won! */
		if(c==3){j=rand(b-a);mem[(scr+31)+32+((a*32)+(j*32))]=170;}			/* blue blocks - in tunnel */
		if(c==4){mem[(scr+31)+(rand(a))*32]=255;}					/* red blocks - top	   */
		if(c==5){mem[((scr+31)+(b*32))+((rand(b-a))*32)]=255;}				/* red blocks - bottom     */
		mem[(scr+6)+(y*32)]=85;							/* draw ship               */
 		for (i=0;i<64;i++){mem[scr+(i*32)]=0;} 					/* stops overscroll        */
		score((0x7000+12)+(32*59),sc1);
		score((0x7000+11)+(32*59),sc2);
		score((0x7000+10)+(32*59),sc3);
		score((0x7000+28)+(32*59),lives);
		memcpy(0x7000,scr+1,2048-32*5);
		memcpy(scr,0x7000,2048-32*5);
		if((scr[7+(y*32)]!=0)||(scr[7+((y+1)*32)]!=0)||(scr[7+((y-1)*32)]!=0)){		/* blow up detection */
			lives--;
			score((0x7000+28)+(32*59),lives);
			setbase(0x7000);
			for(i=0;i<100;i++){							/* and blow up */
				for(j=0;j<4;j++){
					line(30,y,rand(45)+10,rand(50)+(y-25),j);}}
			for(i=0;i<6000;i++){;}
			memset(scr,0,2048); 
			setbase(0x7000);
			memset(0x7000+(58*32),0,6*32);
		   	draw_string(6, 59, 1, "Score: ");
		   	draw_string(74, 59, 1, "Lives: ");
			setbase(scr);
			y=31;
		}
		if(lives==0){end=1;break;}
	}
	a=15;	b=48;
	for(x=0;x<100;x++){
		setbase(scr);
		c=rand(6);
		if (c==1) {a++;b++;}
		if (c==2) {a--;b--;}
		if (a<5) {a=5;b=(43-15);}
		if (b>57) {a=34;b=57;}	
		for(i=0;i<a;i++){mem[(scr+31)+(i*32)]=170;}
		for(i=b;i<64;i++){mem[(scr+31)+(i*32)]=170;}
		mem[(scr+31)+(a*32)]=255;
		mem[(scr+31)+(b*32)]=255;
		if(c==3){j=rand(b-a);mem[(scr+31)+32+((a*32)+(j*32))]=170;}			/* blue blocks - in tunnel */
		if(c==4){mem[(scr+31)+(rand(a))*32]=255;}					/* red blocks - top	   */
		if(c==5){mem[((scr+31)+(b*32))+((rand(b-a))*32)]=255;}				/* red blocks - bottom     */
 		for (i=0;i<64;i++){mem[scr+(i*32)]=0;} 					/* stops overscroll        */
		memcpy(0xE000,scr+1,2048);
		memcpy(scr,0xE000,2048);
		setbase(0xE000);
		draw_string(0,  20, 1, "YOU CRASHED.BIG TIME!");
		if(won==1)  {draw_string(0,  20, 1, "YOU WIN . BIG TIME!  ");}
		draw_string(20, 40, 1, "YOUR SCORE: ");
		score((0xE000+23)+(32*40),sc1);
		score((0xE000+22)+(32*40),sc2);
		score((0xE000+21)+(32*40),sc3);
		memcpy(0x7000,0xE000,2048);
	}
	won=0;end=0;
	memset(scr,0,2048); 
	memset(0xE000,0,2048); 
	memset(0x7000,0,2048); 

}
}

 
draw_string(x,y,color,src)
int x,y,color;
char *src;
{	while (*src)	{
	   char_draw(x,y,color,*src);
	   x += 6;
           src++;	}}

