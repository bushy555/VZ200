#include <stdio.h>

int tape_monitor() __naked {   
   #asm

   di   

   ld bc, 31+16+8+1
   ld hl, $6800

loop:  
   bit 6, (hl)  ; read tape bit        
   jr nz, iszero

isone:   
   ld (hl), c 
   jr loop

iszero:   
   ld (hl), b
   jr loop
     
   #endasm 
}


int main() {   
   vz_clrscr();
   printf("TAPE MONITOR\n\n");
   printf("WRITTEN BY NINO PORCINO\n\n");   
   tape_monitor();
}
