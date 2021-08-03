// Bushy Snow.

#include <vz.h>

main()
{
        int x[128], y[64], z[64], speed[64];
        int i,j,loop;

        loop = 1;
	vz_mode(1);
        	
   #asm
   di
   ld	hl, 0x7000
   ld	de, 0x7001
   ld	(hl), 170	; SET blue background.
   ld	bc, 1888
   ldir	
   ld	hl, 0x7740 	; Set yellow ground at line 58
   ld	de, 0x7741 
   ld	(hl), 85
   ld	bc, 31
   ldir
   ld	hl, line1	; DO "BUSHY SNOW"
   ld	de, $7760
   ld	bc, 13
   ldir
   ld	hl, line2
   ld	de, $7780
   ld	bc, 13
   ldir
   ld	hl, line3
   ld	de, $77A0
   ld	bc, 13
   ldir
   ld	hl, line4
   ld	de, $77C0
   ld	bc, 13
   ldir
   ld	hl, line5
   ld	de, $77e0 
   ld	bc, 13
   ldir
   jp	continue	; JMP OVER "BUSHY SNOW" data.
line1: defb $FE,$BA,$EF,$FB,$AE,$EB,$AA,$BF,$EE,$BB,$FE,$EA,$c0
line2: defb $EB,$BA,$EE,$AB,$AE,$EB,$AA,$BA,$AF,$BB,$AE,$EA,$c0
line3: defb $EE,$BA,$EB,$EB,$FE,$BE,$AA,$AF,$AE,$FB,$AE,$EE,$c0
line4: defb $EB,$BA,$EA,$BB,$AE,$AE,$AA,$AA,$EE,$FB,$AE,$FB,$c0
line5: defb $FE,$AF,$AF,$FB,$AE,$AE,$AA,$BF,$EE,$BB,$FE,$EA,$c0
continue:	

   #endasm

   for (i=1;i != 58; i++) {		// Pre-calc snow x,y,z,speed.
      x[i]=rand()%126+1;
      y[i]=rand()%25+1;
      z[i]=58;
      speed[i]=rand()%2+1;
   }
	
   while (loop=1) { 			// do snow effect.
      y[i] -= speed[i];
      for (i = 1 ; i < 58; i ++) {
         y[i] += speed[i];
         if (y[i] > z[i]) {
            x[i] = rand()%126+1;
            y[i] = rand()%25+1;
	    speed[i] = rand()%2+1;
 	    if (speed[i] == 1) {z[i] --;}  //build up ground.
         }
         vz_plot( x[i], (y[i] - speed[i]), 2);
         vz_plot( x[i], y[i], 1);			
      }
   }
}