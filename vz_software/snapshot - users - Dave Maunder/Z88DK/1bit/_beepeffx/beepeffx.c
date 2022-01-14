
// zcc +zx -zorg=32772 -O3 -vn -m main.c mus\huby.asm -o build\main.bin -lndos
//
// zcc +vz -zorg=32768 -O3 -lm -vn -m %1.c %1.asm -o %1.vz -create-app -lndos



#include "beepeffx.h"


main () {
   while (1){

	beepeffx(0);
	beepeffx(1);
	beepeffx(2);
	beepeffx(3);
	beepeffx(4);

   }
}




