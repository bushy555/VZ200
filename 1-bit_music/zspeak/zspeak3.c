////////////////////////////////
////////////////////////////////
//
//      SAMPLE   (wave sample)
//
////////////////////////////////
////////////////////////////////
//
#include <vz.h>
#include <conio.h>
#include <games.h>
#define Port 0x783b
#define Link_On  0//255//0x0C0 	
#define Link_Off 255 //0x0FC
#define sndbit_mask   	17	//; bit 0 (Speaker A) and 5 (Speaker B)
#define sndbit 		0
#define sndbit_port 	26624	//; this is a memory address, not a port !

int main()
{
#asm

	di
	ld    	a,(0x783b)
	ld   	(snd_tick),a
	

Start:





	ld bc,msg		;point to message
	di
	call speak
	ei
	ret

	
//-------------
speak:	

	
next:	ld a,(bc)		;load character code
		or a			;if it is 0, end of message reached
		ret z
	
		push bc			;preserve msg pointer
		ld hl,table		;point to jump table
		cp 97
		jr nc,ofs
	
		jr skip
	
ofs:		sub 97			;subtract ascii offset
		add a,a			;calculate table offset
		ld c,a
		xor a
		ld b,a
		add hl,bc		;add offset to table pointer
		ld c,(hl)		;load sample address to bc
		inc hl
		ld b,(hl)
		push bc
		pop hl			;put sample address in hl

		ld a,0xd0
		call play		;output speech
	
skip:	pop bc			;restore & increase msg pointer
		inc bc
		jr next
	ret




	 ld hl,sound    ;loads the sound data
	 ld e,(hl)      ;loads e with hl
	 inc hl         ;increases hl
	 ld d,(hl)      ;loads d with hl
	 inc hl         ;increases hl
	 ld b,128       ;stores b as 128
sloop:	 ld c,15         ;stores c as 19
loop1:	 dec c          ;decreases c
	 jr nz,loop1     ;loops until c is 0
	 rrc b          ;rotate rigth and carry b
	 jr nc,play     ;goes, if no carry, to Play
	 inc hl         ;increases hl
	 dec de         ;decreases de
	 ld a,d         ;loads a with value from d
	 or e           ;compares a with e using Boolean 'or'
	 jr z,done      ;if true, goes to Done

play:
	 ld a,(hl)      ;loads a with hl
	 and b          ;compares with b using Boolean 'and'
	 jr z,play1     ;if true, go to Play1


	ld 	a,192		//Link_On   	//;load a with the 'Link_Off' value
	ld 	(26624),a   	//;turn off the link port
        or  	sndbit_mask
        xor  	sndbit_mask
        ld   	(sndbit_port),a

	 jr 	sloop       ; go to SLoop
play1:
	ld 	a,240  		//;load a with the 'Link_On' value
	ld	(26624),a  	// ;turn on the link port
        or  	sndbit_mask
        xor  	sndbit_mask
        ld   	(sndbit_port),a


	 jr 	sloop       ; go to SLoop
done:
	 ei             ;enables interrupts
	 ret            ;returns from program


snd_tick: defb 0,0


sound:




msg:
      

	defb 0x1a,"uelkam{",0x1c,"tu{",0x20,"sedspiik{{je",0x1c
	defb "{tootelli",0x1a,"{iuus",0x1c,"less{",0x1e
	defb "end{",0x1c,"feerlii{krrepii{sed{",0x1e
	defb "eitii{spiitz",0x20,"{sintesaiser",0



table:	
	defw aa,bb,cc,dd,ee,ff,gg,hh
	defw ii,jj,kk,ll,mm,nn,oo,pp
	defw qq,rrr,ss,tt,uu,vv,ww,xx,yy,zz,gap	

aa:
	defb 0x08,0x07,0x0A,0x08,0x07,0x07,0x07
	defb 0x09,0x02,0x04,0x08,0x06,0x0B,0x08,0x07,0x07,0x07,0x09,0x02,0x04,0x08,0x06,0x0B
	defb 0x07,0x08,0x08,0x06,0x09,0x03,0x03,0x08,0x07,0x0A,0x07,0x08,0x08,0x07,0x09,0x02
	defb 0x04,0x08,0x06,0x0B,0x07,0x08,0x08,0x06,0x09,0x03,0x03,0x08,0x07,0x0B,0x07,0x07
	defb 0x09,0x06,0x09,0x03,0x03,0x08,0x07,0x0A,0x08,0x07,0x09,0x06,0x09,0x03,0x03,0x08
	defb 0x07,0x0A,0x08,0x08,0x08,0x06,0x09,0x03,0x03,0x08,0x07,0x0B,0x07,0x08,0x08,0x07
	defb 0x09,0x02,0x04,0x08,0x06,0x0B,0x07,0x08,0x08,0x07,0x09,0x02,0x04,0x08,0x07,0x0A
	defb 0x07,0x08,0x09,0x06,0x09,0x03,0x03,0x08,0x07,0x0B,0x07,0x08,0x08,0x07,0x09,0x02
	defb 0x04,0x08,0x07,0x0A,0x07,0x08,0x09,0x06,0x0A,0x02,0x04,0x07,0x07,0x0B,0x07,0x08
	defb 0x09,0x06,0x09,0x03,0x04,0x07,0x07,0x0B,0x07,0x08,0x09,0x06,0x09,0x03,0x04,0x08
	defb 0x06,0x0B,0x07,0x08,0x09,0x07,0x09,0x02,0x04,0x08,0x07,0x0B,0x06,0x09,0x09,0x06
	defb 0x09,0x03,0x04,0x07,0x07,0x0B,0x07,0x08,0x09,0x07,0x09,0x02,0x04
	defb 0
bb:
	defb 0x2B,0x20,0x26,0x22,0x2C,0x1A,0x01,0x03,0x11,0x02,0x05,0x06,0x05,0x02,0x09
	defb 0x15,0x02,0x03,0x16,0x04,0x02,0x09,0x02,0x04,0x03,0x15,0x02,0x02,0x15,0x10,0x09
	defb 0x14,0x02,0x03,0x14,0x0D,0xff
	defb 0
cc:
	defb 0x0F,0x04,0x05,0x05,0x08,0x04,0x05,0x12,0x03,0x10,0x04,0x04,0x04,0x0A,0x0A
	defb 0x10,0x04,0x04,0x05,0x1B,0x04,0x10,0x05,0x18,0x19,0x04,0x08,0x04,0x05,0x05,0x19
	defb 0x10,0x06,0x03,0x06,0x05,0x32,0x04,0x03,0x04,0x04,0x65,0x36,0x0D,0x04,0x12,0x04
	defb 0x10,0x03,0x24,0x03,0x25,0x04,0x0E,0x12,0x05,0x04,0x04,0x06,0x04,0x06,0x05,0x05
	defb 0x06,0x52,0x10,0x10,0x04,0x1D,0x0B,0x1A,0x06,0x2A,0x06,0x04,0x10,0x06,0x05,0x05
	defb 0x05,0x2D,0x04,0x09,0x04,0x07,0x03,0x11,0x05,0x05,0x3C,0x37,0x04,0x03,0x03,0x03
	defb 0x04,0x08,0x04,0x04,0x0A,0x10,0x2A,0x2A
	defb 0
dd:
	defb 0x26,0x28,0x1D,0x02,0x04,0x07,0x04,0x20,0x1D,0x04,0x0F,0x1E,0x18,0x04,0x0D
	defb 0x21,0x2D,0x18,0x02,0x02,0xff
	defb 0
ee:
	defb 0x02,0x02,0x11,0x2A,0x06,0x0E,0x01,0x02,0x12,0x0A,0x15,0x0A,0x06,0x0E,0x01
	defb 0x02,0x0F,0x0D,0x11,0x11,0x03,0x0D,0x02,0x02,0x0E,0x0E,0x10,0x0B,0x09,0x0D,0x02
	defb 0x02,0x0E,0x0F,0x0E,0x0C,0x09,0x0E,0x02,0x02,0x0E,0x0E,0x10,0x0C,0x09,0x0E,0x02
	defb 0x02,0x0D,0x0F,0x11,0x0C,0x09,0x0E,0x02,0x02,0x0E,0x2D,0x09,0x0D,0x02,0x02,0x0E
	defb 0x45,0x02,0x02,0x4A,0x0E
	defb 0
ff:
	defb 0x23,0x23,0x04,0x34,0x06,0x03,0x06,0x09,0x02,0x07,0x08,0x03,0x22,0x02,0x16
	defb 0x0F,0x04,0x08,0x08,0x2D,0x06,0x07,0x05,0x07,0x04,0x09,0x02,0x21,0x0B,0x06,0x0D
	defb 0x07,0x1A,0x08,0x07,0x1B,0x01,0x0E,0x06,0x0E,0x07,0x14,0x04,0x19,0x02,0x04,0x06
	defb 0x09,0x04,0x05,0x05,0x0B,0x06,0x06,0x02,0x0E,0x06,0x02,0x0A,0x06,0x07,0x1B,0x05
	defb 0x03,0x02,0x0A,0x13,0x11,0x01,0x0E,0x04,0x19,0x0C,0x06,0x13,0x01,0x13,0x14,0x0D
	defb 0x06,0x01,0x0C,0x05
	defb 0
gg:
	defb 0x05,0x02,0x29,0x28,0x30,0x21,0x1B,0x02,0x13,0x2C,0x21,0x2D,0x36,0x21,0xff
	defb 0
hh:
	defb 0x15,0x4B,0x08,0x09,0x02,0x09,0x1A,0x09,0x25,0x0E,0x12,0x18,0x03,0x07,0x08
	defb 0x19,0x08,0x1A,0x23,0x19,0x0B,0x03,0x07,0x04,0x12,0x08,0x06,0x07,0x05,0x08,0x09
	defb 0x08,0x0A,0x07,0x0F,0x07,0x09,0x08,0x08,0x0A,0x15,0x02,0x02,0x02,0x0C,0x08,0x06
	defb 0x0F,0x06,0x0E,0x07,0x06,0x05,0x07,0x07,0x07,0x08,0x08,0x0A,0x08,0x08,0x08,0x06
	defb 0x06,0x09,0x04,0x01,0x08,0x07,0x07,0x09,0x08,0x08,0x09,0x14,0x01,0x06,0x0B,0x07
	defb 0x0E
	defb 0
ii:
	defb 0x3D,0x10,0x02,0x02,0x3D,0x11,0x02,0x02,0x39,0x15,0x02,0x02,0x39
	defb 0x15,0x02,0x02,0x39,0x15,0x02,0x02,0x39,0x15,0x02,0x02,0x39,0x15,0x02,0x02,0x39
	defb 0x15,0x02,0x02,0x39,0x15,0x02,0x02,0x3A,0x15,0x02,0x02,0x39,0x15,0x02,0x02,0x3B
	defb 0x15,0x02,0x02,0x3A,0x15,0x02,0x02,0x3B,0x15,0x02,0x02,0x3B,0x15,0x02,0x02
	defb 0
jj:
	defb 0x06,0x0D,0x09,0x01,0x04,0x0A,0x01,0x02,0x12,0x0C,0x01,0x04,0x03,0x01,0x04
	defb 0x01,0x08,0x01,0x01,0x02,0x01,0x02,0x01,0x02,0x01,0x01,0x06,0x0D,0x01,0x07,0x08
	defb 0x01,0x06,0x06,0x03,0x02,0x01,0x06,0x0E,0x01,0x05,0x0C,0x02,0x04,0x01,0x02,0x01
	defb 0x08,0x01,0x07,0x35,0x08,0x04,0x01,0x02,0x01,0x01,0x0B,0x01,0x04,0x08,0x15,0x01
	defb 0x08,0x01,0x01,0x04,0x18,0x04,0x05,0x01,0x04,0x08,0x01,0x06,0x01,0x01,0x02,0x01
	defb 0x0A,0x07,0x0D,0x03,0x04,0x02,0x07,0x02,0x01,0x04,0x01,0x05,0x04,0x01,0x08,0x0A
	defb 0x01,0x04,0x0D,0x01,0x04,0x04,0x02,0x01,0x02,0x04,0x01,0x08,0x01,0x01,0x02,0x01
	defb 0x12,0x02,0x01,0x02,0x01,0x0B,0x1A,0x01,0x02,0x01,0x01,0x02,0x07,0x04,0x04,0x04
	defb 0x01,0x08,0x01,0x01,0x05,0x01,0x01,0x02,0x01,0x01,0x03,0x09,0x01,0x03,0x02,0x01
	defb 0x05,0x02,0x01,0x01,0x04,0x08,0x02,0x01,0x04,0x08,0x06,0x08,0x04,0x02,0x0D,0x0D
	defb 0x07,0x01,0x01,0x01,0x02,0x02,0x04,0x01,0x04,0x02,0x01,0x10,0x0E,0x04,0x08,0x01
	defb 0
kk:
	defb 255
	defb 0x02,0x05,0x02,0x05,0x02,0x05,0x02,0x02,0x02,0x05,0x02,0x12,0x02,0x04,0x03
	defb 0x04,0x03,0x04,0x02,0x04,0x04,0x03,0x03,0x0A,0x03,0x04,0x03,0x04,0x03,0x18,0x04
	defb 0x03,0x03,0x04,0x02,0x07,0x03,0x02,0x03,0x03,0x04,0x02,0x02,0x04,0x04,0x03,0x03
	defb 0x07,0x02,0x39,0x09,0x09,0x02,0x02,0x0B,0x04,0x02,0x03,0x01,0x06,0x01,0x04,0x0B
	defb 0x05,0x02,0x0E,0x02,0x04,0x02,0x05,0x02,0x09,0x03,0x02,0x03,0x03,0x06,0x05,0x02
	defb 0x04,0x04,0x02,0x04,0x02,0x03,0x03,0x01,0x02,0x03,0x04,0x01,0x03,0x02,0x02,0x02
	defb 0x0B,0x02,0x05,0x03,0x05,0x01,0x05,0x02,0x03,0x03,0x03,0x04,0x01,0x05,0x0C,0x02
	defb 0x05,0x01,0x04,0x07,0x02,0x02,0x17,0x08,0x10,0x0B,0x02,0x02,0x0C,0x02,0x07,0x03
	defb 0x02,0x05,0x02,0x02,0x13,0x01,0x02,0x02,0x24,0x04,0x03,0x01
	defb 0
ll:
	defb 0x0C,0x08,0x08,0x13,0x13,0x21,0x09,0x11,0x02,0x01,0x16,0x1A,0x0D,0x12,0x02
	defb 0x01,0x19,0x16,0x0E,0x12,0x02,0x02,0x18,0x0E,0x14,0x15,0x02,0x01,0x15,0x14,0x12
	defb 0x15,0x01,0x02,0x15,0x0D,0x19,0x15,0x01,0x02,0x15,0x1D,0x09,0x14,0x02,0x02,0x15
	defb 0
mm:
	defb 0x3F,0x15,0x3F,0x14,0x3F,0x15,0x3E,0x15,0x3F,0x15,0xE8,0x14,0x3F,0x15,0x3F
	defb 0x16,0x40,0x16
	defb 0
nn:
	defb 0x3F,0x15,0x40,0x15,0x41,0x14,0x41,0x15,0x41,0x14,0x41,0x15,0x42,0x14,0x42
	defb 0x16,0x42,0x15,0x42,0x15,0x43,0x14,0x44,0x14,0x43,0x19,0x41
	defb 0
oo:
	defb 0x0A,0x08,0x09,0x08,0x07,0x09,0x10,0x0F,0x09,0x09,0x08,0x08,0x08,0x09,0x10,0x0E
	defb 0x09,0x09,0x09,0x08,0x07,0x09,0x11,0x0E,0x09,0x09,0x08,0x09,0x07,0x09,0x11,0x0E
	defb 0x09,0x09,0x08,0x09,0x07,0x09,0x11,0x0E,0x09,0x09,0x08,0x09,0x07,0x09,0x11,0x0E
	defb 0x09,0x0A,0x08,0x08,0x08,0x09,0x11,0x0E,0x09,0x09,0x09,0x08,0x08,0x09,0x10,0x0F
	defb 0x09,0x09,0x09,0x08,0x08,0x09,0x10,0x0F,0x09,0x09,0x08,0x09,0x08,0x09,0x10,0x0F
	defb 0
pp:
	defb 0x06,0x1A,0x14,0xCA,0x0A,0x0C,0x01,0x25,0x01,0x0F,0x01,0x0F,0x0A,0x02,0x02
	defb 0x03,0x10,0x2A,0x02,0x01,0x27,0x34,0x01,0x04,0x03,0x02,0x06,0x02,0x03,0x01,0x02
	defb 0x04
	defb 255,0
qq:
	defb 0x23,0x05,0x13,0x11,0x23,0x05,0x0F,0x02,0x02,0x12,0x22,0x05,0x10,0x02
	defb 0x02,0x11,0x23,0x05,0x10,0x02,0x02,0x11,0x24,0x05,0x0F,0x02,0x02,0x12,0x24,0x05
	defb 0x0F,0x02,0x02,0x11,0x25,0x05,0x0F,0x02,0x02,0x12
	defb 0
rrr:
	defb 0x0D,0x0D,0x0B,0x0C,0x0A,0x10,0x03,0x05,0x10,0x0A,0x0D,0x0B,0x0C,0x0D,0x0A
	defb 0x10,0x03,0x04,0x11,0x0B,0x0C,0x0C,0x0B,0x0E,0x0A,0x10,0x03,0x05,0x10,0x0C,0x0E
	defb 0x0B,0x0A,0x0E,0x0A,0x10,0x03,0x05,0x11,0x0B,0x0E,0x0D,0x0A,0x0F,0x0A,0x10,0x03
	defb 0x05,0x10,0x0C,0x0E,0x0C,0x0B,0x0F,0x08,0x12,0x03,0x05,0x11,0x0C,0x0E,0x0D,0x0B
	defb 0x0F,0x0A,0x10,0x03,0x05,0x11,0x0E,0x0E,0x0C,0x0A,0x0F,0x08,0x12,0x03,0x06,0x10
	defb 0x0D,0x0F,0x0C,0x0C,0x0E,0x0A,0x10,0x03,0x06,0x10,0x0E,0x25,0x0F,0x09,0x11,0x03
	defb 0x06,0x10,0x0D,0x0E
	defb 0
ss:
	defb 0x02,0x01,0x01,0x02,0x01,0x02,0x01,0x02,0x01,0x02,0x01,0x02,0x01,0x02
	defb 0x01,0x02,0x01,0x02,0x02,0x01,0x02,0x02,0x02,0x02,0x0E,0x01,0x02,0x06,0x01,0x08
	defb 0x02,0x01,0x03,0x02,0x01,0x06,0x01,0x01,0x02,0x01,0x05,0x02,0x01,0x01,0x02,0x01
	defb 0x02,0x01,0x02,0x02,0x02,0x01,0x01,0x02,0x02,0x01,0x05,0x02,0x02,0x01,0x02,0x02
	defb 0x04,0x02,0x01,0x02,0x07,0x02,0x01,0x02,0x02,0x01,0x02,0x05,0x01,0x04,0x04,0x02
	defb 0x01,0x02,0x08,0x06,0x02,0x02,0x01,0x02,0x0D,0x01,0x01,0x02,0x01,0x01,0x02,0x02
	defb 0x01,0x02,0x04,0x09,0x02,0x05,0x04,0x01,0x08,0x01,0x02,0x02,0x01,0x01,0x02,0x01
	defb 0x02,0x01,0x01,0x04,0x02,0x01,0x05,0x01,0x06,0x01,0x02,0x01,0x04,0x04,0x01,0x06
	defb 0x01,0x03,0x05,0x06,0x01,0x04,0x01,0x06,0x04,0x02,0x01,0x02,0x01,0x03,0x01,0x02
	defb 0x03,0x08,0x01,0x08,0x01,0x08,0x01,0x06,0x01,0x01,0x02,0x05,0x04,0x05,0x01,0x02
	defb 0x01,0x05,0x01,0x02,0x05,0x01,0x02,0x01,0x02,0x01,0x02,0x01,0x01,0x05,0x01,0x02
	defb 0x02,0x01,0x02,0x01,0x02,0x02,0x01,0x02,0x02,0x01,0x02,0x05,0x01,0x04,0x06,0x02
	defb 255,0
tt:
	defb 0x02,0x20,0x02,0x02,0x01,0x03,0x01,0x0C,0x05,0x30,0x01,0x3B,0x01,0x03,0x02
	defb 0x01,0x01,0x02,0x08,0x01,0x06,0x0F,0x01,0x0C,0x01,0x0C,0x01,0x0A,0x01,0x16,0x02
	defb 0x11,0x01,0x01,0x01,0x01,0x01,0x03,0x02,0x01,0x03,0x01,0x03,0x02,0x01,0x02,0x02
	defb 0x0A,0x01,0x02,0x02,0x01,0x02,0x01,0x01,0x02,0x01,0x0A,0x02,0x03,0x02,0x01,0x02
	defb 0x01,0x01,0x05,0x02,0x03,0x01,0x03,0x01,0x02,0x01,0x03,0x01,0x02,0x01,0x01,0x04
	defb 0x01,0x01,0x03,0x03,0x02,0x01,0x01,0x01,0x02,0x02,0x04,0x02,0x01,0x05,0x0A,0x01
	defb 0x01,0x01,0x07,0x01,0x02,0x02,0x01,0x01,0x08,0x01,0x01,0x02,0x09,0x01,0x02,0x01
	defb 0x01,0x02,0x04,0x02,0x01,0x02,0x01,0x02,0x01,0x01,0x06,0x01,0x01,0x01,0x04,0x01
	defb 0x01,0x02,0x05,0x02,0x04,0x01,0x02,0x02,0x07,0x05,0x02,0x06,0x01,0x03,0x0D,0x03
	defb 0x0A,0x01,0x0A,0x01,0x06,0x02,0x02,0x01,0x0A,0x04,0x04,0x04,0x0C,0x04,0x0D,0x03
	defb 0x0E
	defb 255,0
uu:
	defb 0x37,0x11,0x37,0x12,0x38,0x12,0x38,0x13,0x38,0x12,0x1D
	defb 0x0C,0x10,0x12,0x39,0x13,0x1D,0x2E,0x1D,0x09,0x12,0x13,0x1D,0x0B,0x11,0x13,0x1D
	defb 0x0B,0x10,0x13,0x1D,0x0B,0x10,0x13,0x1D,0x0B,0x11,0x12,0x1D,0x0B,0x11,0x13,0x1D
	defb 0x0A,0x12,0x12,0x39,0x13
	defb 0
vv:
	defb 0x39,0x13,0x39,0x14,0x38,0x14,0x38,0x14,0x38,0x15,0x38,0x14,0x38,0x11,0x02
	defb 0x02,0x36,0x17,0x35,0x15,0x02,0x02,0x35,0x14,0x02,0x02,0x34,0x16,0x02,0x02,0x35
	defb 0x15,0x02,0x02,0x34,0x15,0x02,0x02,0x35,0x15,0x02,0x02,0x35,0x15,0x02,0x01,0x36
	defb 0x14,0x02,0x02,0x35,0x15,0x02,0x02
	defb 0
ww:
	defb 0xFF,0x12,0x3F,0x17,0x3D,0x16,0x3F,0x16,0x3D,0x18,0x3D,0x17,0x3D,0x17,0x3C
	defb 0x16,0x3C,0x16,0x3C,0x15,0x3D,0x14,0x3A,0x19,0x3A
	defb 0
xx:
	defb 0x07,0x1C,0x72,0x06,0x0C,0x5C,0x50,0x18,0x1C,0x0A,0x08,0x0A,0x06,0x0B,0x0A
	defb 0x0A,0x0A,0x05,0x48,0x19,0x08,0x08,0x0B,0x08,0x0A,0x09,0x0B,0x04,0x2A,0x0A,0x1A
	defb 0x08,0x0C,0x0A,0x60,0x0B,0x05,0x08,0x0D,0x07,0x08,0x0A,0x0A,0x09,0x4F,0x0A,0x0A
	defb 0x04,0x09,0x0C,0x05,0x0A,0x08,0x0A,0x14,0x2B,0x07,0x0A,0x0A,0x07,0x08,0x09,0x0A
	defb 0x2E,0x0B,0x26,0x13,0x1D,0x33,0x05,0x0A,0x0E,0x1C,0x08
	defb 0
yy:
	defb 0x18,0x1C,0x0D
	defb 0x0D,0x02,0x02,0x18,0x1C,0x0D,0x0D,0x02,0x02,0x13,0x22,0x0C,0x0E,0x02,0x02,0x13
	defb 0x21,0x0B,0x10,0x02,0x02,0x12,0x22,0x0B,0x10,0x02,0x02,0x12,0x22,0x0B,0x10,0x02
	defb 0x02,0x12,0x22,0x0B,0x10,0x02,0x02,0x12,0x22,0x0B,0x10,0x02,0x02,0x13,0x22,0x0B
	defb 0x0F,0x02,0x02,0x13,0x23,0x0B,0x0F,0x02,0x02,0x13,0x23,0x0B,0x10,0x02,0x02,0x12
	defb 0x24,0x0B,0x10,0x02,0x02,0x12,0x25,0x0A,0x10,0x02,0x02,0x13,0x25,0x0D,0x0D,0x02
	defb 0x02,0x13,0x24,0x0E,0x0C,0x03,0x02
	defb 0
zz:
	defb 0x35,0x2C,0x09,0x2C,0x32,0x48,0x16,0x01,0x0A,0x15,0x01,0x40,0x02,0x10,0x02
	defb 0x14,0x04,0x1A,0x08,0x03,0x08,0x18,0x48,0x03,0x45,0x04,0x02,0x33,0x02,0x02,0x02
	defb 0x04,0x0E,0x08,0x02,0x04,0x07,0x03,0x02,0x03,0x03,0x02,0x04,0x02,0x05,0x02,0x01
	defb 0x13,0x10,0x01,0x03,0x04,0x02,0x0A,0x02,0x09,0x01,0x08,0x03,0x03,0x43,0x04,0x02
	defb 0x0F,0x03,0x06,0x02,0x04,0x09,0x02,0x05,0x01,0x05,0x01,0x03,0x0A,0x02,0x03,0x03
	defb 0x02,0x03,0x0A,0x01,0x04,0x0B,0x05,0x01,0x02,0x09,0x02,0x07,0x03,0x1B,0x0D,0x13
	defb 0x02,0x04,0x08,0x08,0x02,0x50
	defb 0
gap:
	defb 255,255,255,0


#endasm

}






