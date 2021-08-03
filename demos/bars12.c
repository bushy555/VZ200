//	2447 bytes
//	2708 working.

 #include <vz.h>
 #include <graphics.h>
 #include <stdio.h>
 #include <sound.h>
 #include <stdlib.h>
 #include <ctype.h>
 #include <strings.h>
 #include <conio.h>
 #include <math.h>

#define PI = 3.1415926535




chaos( int i, int j, int k, int l, int m, int n)
{
#asm	
	pop	de
	pop	hl
	ld	a, l
	ld	hl, i
	ld	(hl), a
	pop	hl
	ld	a, l
	ld	hl, j
	ld	(hl), a
	pop	hl
	ld	a, l
	ld	hl, k
	ld	(hl), a
	pop	hl
	ld	a, l
	ld	hl, l
	ld	(hl), a
	pop	hl
	ld	a, l
	ld	hl, m
	ld	(hl), a
	pop	hl
	ld	a, l
	ld	hl, n
	ld	(hl), a

	push	hl


	ld	hl, m
	ld	a, (hl)
	xor	h, h
	ld	l, a
	push	hl
	ld	hl, l
	ld	a, (hl)
	xor	h, h
	ld	l, a

	push	hl
	ld	hl, k
	ld	a, (hl)
	xor	h, h
	ld	l, a
	push	hl
	ld	hl, j
	ld	a, (hl)
	xor	h, h
	ld	l, a

	push	hl
	ld	hl, i
	ld	a, (hl)
	xor	h, h
	ld	l, a
	push	hl
	push	de




intro:					// H = x    L = y
	ld	c, 255
intro2:	push	bc
	ld a,r
	rrca
	rrca
	neg
seed2:	xor 0
	rrca
	ld 	(seed2+1),a



	cp	85			//Mul8b		// HL = h*e
	jr	c,calc2
	cp	170
	jr	c,next
	ld	a, h
	push	hl
	ld	hl, i
	add	a, (hl)
	pop	hl
	ld	h, a

	ld	a, l
	push	hl
	ld	hl, j
	add	a, (hl)
	pop	hl
	ld	l, a
	jp	calc

next:
	ld	a, h
	push	hl
	ld	hl, k
	add	a, (hl)
	pop	hl
	ld	h, a

	ld	a, l
	push	hl
	ld	hl, l
	add	a, (hl)
	pop	hl
	ld	l, a

	jp	calc			// Y = 63.
calc2:
	ld	a, h
	push	hl
	ld	hl, m
	add	a, (hl)
	pop	hl
	ld	h, a

	ld	a, l
	push	hl
	ld	hl, n
	add	a, (hl)
	pop	hl
	ld	l, a

calc:	sra	h			// divide h / 2
	sra	l			// divide l / 2

	push	hl			// HL   H=x L=Y
	ld	c, h			// temporarily put bc= X
	ld	e, 32			// width of screen
	ld	h, l			//  e=32 h=Y, c=x

				

  ld d,0			// multiply:   using HL=H*E
  ld l,d                         ; clearing D and L
  ld b,8                         ; we have 8 bits
Mul8bLoop2:
  add hl,hl                      ; advancing a bit
  jp nc,Mul8bSkip2                ; if zero, we skip the addition (jp is used for speed)
  add hl,de                      ; adding to the product if necessary
Mul8bSkip2:
  djnz Mul8bLoop2

				// HL = H * E     (HL=H*Y)   (HL=H*32) 
	ld	de, 0x7000
	add	hl, de 			// add SCREEN_BASE.  HL = (Y*32) + 0x7000

	ld	a, l
	add	a, c
	ld	l, a

					// add X.            HL = 0x7000 + (Y*32) + x 
	ld	(hl), 170//10
	pop	hl
	pop	bc
	dec	c
	jp	nz,intro2
	ret

//	jp	intro

i:	defb 0
j:	defb 0
k:	defb 0
l:	defb 0
m:	defb 0
n:	defb 0


#endasm
}


main()
{
float cx, cy;
float angle;
char z,v,w, buf;
int i,j,sz,x,y,a,b,c,d,e,f,g,h,k,l,m,n,o,p;

	vz_setbase(0xe000);
	k = 1;
	vz_mode(1);
//	cx = 62;
//	cy = 31;
	cx = 28;	// is y
	cy = 16;	// is x


e=28;
f=16;
g=32;
h=18;
l=20;
o=30;
m=31;
n=29;


j=20;
l=0;
k=1;
	while (k==1){
    
		if (j>64){l=1;j=64;}

		if (j<-8) {l=0;j=-8;}

        if (l==0){
		j++;
		memset (0xe000+j*32    , 255, 96);
		memset (0xe000+j*32+96 , 85, 96);
		memset (0xe000+j*32+192, 170, 96);
		memset (0xe000+j*32+192+96, 255, 96);
		}

        if (l==1){
		j--;
		memset (0xe000+j*32    , 170, 96);
		memset (0xe000+j*32+96 , 85, 96);
		memset (0xe000+j*32+192 , 255 , 96);
		memset (0xe000+j*32+192+96 , 170 , 96);
		}



	memcpy (0x7000, 0xe000, 2048);
	memset (0xe000, 0, 2048);

        }

}
}