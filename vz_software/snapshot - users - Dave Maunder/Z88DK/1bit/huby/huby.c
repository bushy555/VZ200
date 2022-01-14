
// Huby 1-bit player engine.
// Song : 1943
// 
// Build with:
// zcc +vz -zorg=32768 -O3 -vn -m huby.c huby.asm -o huby.vz -create-app -lndos
//
// After setting Z88DK compiler environment. 
// Example:
//    SET Z80_OZFILES = C:\progra~1\Z88DK\lib\
//    SET ZCCCFG      = C:\progra~1\Z88DK\lib\config\
//    SET PATH        = C:\progra~1\Z88DK\bin;%PATH%
//


main () {
   huby();
}

