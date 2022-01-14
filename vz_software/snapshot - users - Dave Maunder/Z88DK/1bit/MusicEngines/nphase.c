//
//
// Set Z88DK compiler environment variables: 
// Example:
//    SET Z80_OZFILES = C:\progra~1\Z88DK\lib\
//    SET ZCCCFG      = C:\progra~1\Z88DK\lib\config\
//    SET PATH        = C:\progra~1\Z88DK\bin;%PATH%
//
//
// Build all of this with:
//   zcc +vz -zorg=32768 -O3 -vn -m %1.c %1.asm -o %1.vz -create-app -lndos




void main(){
	printf ("...calling nphase\n\n");

	nphase();

	printf ("AND WE'RE BACK BABY\n\n");
}

