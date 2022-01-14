; Displays an X on the VZ
;
;
; working on smallest sized code


	ORG $8000

start	LD 	HL, $7000
	LD 	DE, $7000 + 31
LP	LD 	BC, $838C	; bottom block / top block
	LD 	(HL), B		; bottom block
	LDD
	INC	L
	INC	L
	LD 	(HL), C		; top block
	LDD
	LD 	BC, 33
	ADD 	HL, BC		; add 33 to current HL loc 
	DEC 	C

;	ADD	DE, BC		
	PUSH	HL	
	PUSH	DE
	POP	HL
	ADD	HL, BC
	PUSH	HL
	POP	DE
	POP	HL
	CPHL
	jp	po, LP

loop	jp	loop

