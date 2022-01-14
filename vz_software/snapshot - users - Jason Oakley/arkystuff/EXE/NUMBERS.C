/* Same as BASIC MODE(X) command */
void mode(char mod)
{
	asm{
		LD A,(IX-01)
		AND 01h
		LD HL,rbkt1						; Point HL at a ')' to keep ROM Routine happy.
		CALL 2E68h						; call MODE() Routine
rbkt1:
		.BYTE 29h						; ')'
		.BYTE 00h
	};
}

void Display(int location, int value) {
	asm{
		LD      L,(IX-04)       ; HL = location
		LD      H,(IX-03)
		LD		A,05h
		LD		(counter),A
		LD      A,(IX-02)       ; A = number
		CP 		00H
		LD		DE,numbers
		JR		Z,showit
countit: INC		DE
		INC	DE
		INC	DE
		INC	DE
		INC	DE
		DEC	A
		JR	NZ,countit
showit:
		LD	A,(DE)
		INC	DE
		LD	(HL),A
		LD		BC,0020h			 ; A line's length
		ADD	HL,BC
		LD	A,(counter)
		DEC	A
		LD	(counter),A
		JR	NZ,showit
		RET
		
counter: .BYTE 00h
numbers:
		; 0
		.BYTE 3Fh
		.BYTE 33h
		.BYTE 33h
		.BYTE 33h
		.BYTE 3Fh
		
		; 1
		.BYTE 3Ch
		.BYTE 0Ch
		.BYTE 0Ch
		.BYTE 0Ch
		.BYTE 3Fh
		
		; 2
		.BYTE 3Fh
		.BYTE 03h
		.BYTE 0Ch
		.BYTE 30h
		.BYTE 3Fh
		
		; 3
		.BYTE 3Fh
		.BYTE 03h
		.BYTE 0Fh
		.BYTE 03h
		.BYTE 3Fh
		
		; 4
		.BYTE 33h
		.BYTE 33h
		.BYTE 3Fh
		.BYTE 03h
		.BYTE 03h
		
		; 5
		.BYTE 3Fh
		.BYTE 30h
		.BYTE 0Ch
		.BYTE 03h
		.BYTE 3Fh
		
		; 6
		.BYTE 3Fh
		.BYTE 30h
		.BYTE 3Fh
		.BYTE 33h
		.BYTE 3Fh
		
		; 7
		.BYTE 3Fh
		.BYTE 03h
		.BYTE 03h
		.BYTE 03h
		.BYTE 03h
		
		; 8
		.BYTE 3Fh
		.BYTE 33h
		.BYTE 0Ch
		.BYTE 33h
		.BYTE 3Fh
		
		; 9
		.BYTE 3Fh
		.BYTE 33h
		.BYTE 3Fh
		.BYTE 03h
		.BYTE 3Fh
	};
}

/* Score display routine - displays numbers 0 - 655,350 */
/* 0<= number <65536.  Output 'number' + '0' */
/* Display at (0<=x<=27,0<=y<=59) */
void Score(int x, int y, int number)
{
	int location, value, temp;
	location = 28678 + 32*y + x;
	value=0;
	Display(location,value);
	location--;
	value = (number % 10);
	Display(location,value);
	location--;
	temp = number / 10;
	value = (temp % 10);
	Display(location,value);
	location--;
	temp = number / 100;
	value = (temp % 10);
	Display(location,value);
	location--;
	temp = number / 1000;
	value = (temp % 10);
	Display(location,value);
	location--;
	temp = number / 10000;
	value = (temp % 10);
	Display(location,value);
}

void main()
{
	mode(1);
	int x,y,score;
	score = 12345;
	x = 0;
	y = 0;
	Score(x,y,score);
	for (;;) {}
}

