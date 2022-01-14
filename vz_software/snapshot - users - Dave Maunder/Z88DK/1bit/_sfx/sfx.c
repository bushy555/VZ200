
// zcc +zx -zorg=32772 -O3 -vn -m main.c mus\huby.asm -o build\main.bin -lndos
//
// zcc +vz -zorg=32768 -O3 -lm -vn -m %1.c %1.asm -o %1.vz -create-app -lndos



#include "sfx.h"


main () {
   while (1){

	#asm

	ld a, 0
	ld (sonreq),a
	call sound

	ld a, 1
	ld (sonreq),a
	call sound

	ld a, 2
	ld (sonreq),a
	call sound

	ld a, 3
	ld (sonreq),a
	call sound

	ld a, 4
	ld (sonreq),a
	call sound

	#endasm

   }
}



