;
; *************************************************************************
; *                                              
; * Program Name : MATH.ASM                      
; * Purpose      : Test VZ200 floating point maths and conversion routines
; * Author       : Guy Thomason                  
; *                                              
; * History      : 30/3/2018   Inital Version    
; *                                              
; *************************************************************************

#define end .end
#define org .org
#define equ .equ

; 	Labels
WRA1  			equ 791Dh		; working storage for floating point 
WRA2  			equ 7927h		; used by VZ math rom routines 
ASCIIRESULT		equ 7930h		; output from FLOAT2ASCII 

; VZ ROM routines 
ASCII2DOUBLE	equ 0E65h
DOUBLEMULTIPLY	equ 0DA1h
FLOAT2ASCII		equ 0FBEh
DISPLAYCHAR		equ 033Ah
DISPLAYSTRING	equ 28A7h
BASIC			equ 1A19h

		org	8000h
		JP	START		

NUM1	.TEXT "3.141529"
		.DB 0
NUM2	.TEXT "2.542330"
		.DB 0 
DBL1	.DB 0,0,0,0,0,0,0,0 	; 8 bytes to hold double precision number
DBL2	.DB 0,0,0,0,0,0,0,0 

START	
; convert ASCII representation of NUM1 to DOUBLE and store it at DBL1 
		LD		HL, NUM1 
		CALL	ASCII2DOUBLE
		LD		DE, DBL1  
		LD		HL, WRA1
		LD		BC, 08h
		LDIR
; convert ASCII representation of NUM2 to DOUBLE and store it at DBL2	
		LD		HL, NUM2
		CALL	ASCII2DOUBLE
		LD		DE, DBL2  
		LD		HL, WRA1 
		LD		BC, 08h
		LDIR			
; multiply DBL1 by DBL2. Result will be in WRA1  		
; first move DBL1 to WRA1 and DBL2 to WRA2 		
		LD		DE, WRA1 
		LD		HL, DBL1 
		LD		BC, 08h
		LDIR	
		
		LD		DE, WRA2  
		LD		HL, DBL2 
		LD		BC, 08h
		LDIR			
	
		CALL DOUBLEMULTIPLY		; result in WRA1 
		LD		A,00h
		CALL 	FLOAT2ASCII		; convert contents of WRA1 to ASCII. Result goes to 7930h
		
		LD		HL, NUM1		; print num1 and a carriage return
		CALL	DISPLAYSTRING		
		LD A,	0DH 
		CALL 	DISPLAYCHAR 
		
		LD		HL, NUM2		; print num2 and a carriage return 
		CALL	DISPLAYSTRING
		LD A,	0DH 
		CALL 	DISPLAYCHAR  	
		
		LD		HL,ASCIIRESULT		; point to ascii result of double precision NUM1*NUM2 
		CALL	DISPLAYSTRING		; display the string 
		
		JP		BASIC
	
		end

