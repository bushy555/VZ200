
Burning Ship Fractals.
======================
256x192 resolution for the super hires extended graphics Australian mod for the VZ/Laser computers.


References
-----------
https://en.wikipedia.org/wiki/Burning_Ship_fractal
http://paulbourke.net/fractals/burnship/
https://softologyblog.wordpress.com/2017/02/24/the-burning-ship-fractal/
https://spanishplus.tripod.com/maths/FractalBurningShip.htm
https://www.pythoninformer.com/generative-art/fractals/burning-ship/




Main 2: scaler = Scaler(pixel_width, pixel_height, width=3.2, startx=-2, starty=-1.8)
Ship 2: scaler = Scaler(pixel_width, pixel_height, width=0.1, startx=-1.8, starty=-0.09)



//	http://paulbourke.net/fractals/burnship/burningship.c
//	-c x y   set the center of the image.
//   	-w n     set the width of the image.
//	-i n     iteration depth.
//
//
//	Create the burning ship fractal
//	Whole ship        -w 1.7 -c 0.45 0.5
//	First small ship  -w 0.04 -c 1.755 0.03
//	Second small ship -w .04 -c 1.625 0.035
//	Tiny ship in tail -w 0.005 -c 1.941 0.004
//	Another small one -w 0.008 -c 1.861 0.005
//
// Create fractal
	for (i=0;i<N;i++) {
		for (j=0;j<N;j++) {
			p0.x = 0;
			p0.y = 0;
			c.x = midpoint.x + 2 * range * (i / (double)N - 0.5);
         c.y = midpoint.y + 2 * range * (j / (double)N - 0.5);
			for (k=0;k<iteratemax;k++) {
				p.x = p0.x*p0.x - p0.y*p0.y - c.x;
				p.y = 2 * fabs(p0.x*p0.y) - c.y;
				p0 = p;
				if (p.x*p.x + p.y*p.y > 10)
					break;
			}
			//if (k == iteratemax)
			//	image[j*N+i] = 0;
			//else
				image[j*N+i] = k;
		}
	}



' FULL SCREEN 9
'Z2=1/1750:G3=1.83:G4=0.09
0 OUT32,28:MODE(1):OUT32,29:MODE(1):OUT32,30:MODE(1):G=130
1 A=0:B=1:C=2:D=3:E=4:F=105:P=255:Q=191:S=50:T=27:H=90:M=16:R=0
2 U=28672:V=32:W=28:L=29:N=30:Z=7:Z2=1/1750:G2=8:G3=1.83:G4=.09
3 G5=1/8:G6=63:G7=192:G8=128:G9=64:FORI=RTOP:X=I*Z2-G3
8 FORJ=RTOQ:Y=J*Z2-G4:A=U+INT(I*G5)+V*(JANDG6)
10 IFJ<G7OUTV,N:IFJ<G8OUTV,L:IFJ<G9OUTV,W
12  POKEA,PEEK(A)ORC^(ZANDNOT(I)):RE=R:IM=R:K=R
20 TM=RE*RE-IM*IM+X:IM=ABS(C*RE*IM)+Y:RE=TM:K=K+B
30 IFK<M AND RE*RE+IM*IM<E,20
40 IFK<M, POKEA,PEEK(A)ANDNOT(C^(ZANDNOT(I)))
50 NEXTJ:NEXTI
60 GOTO60
