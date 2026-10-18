;	DMITRY MILK's BEEPERDRIVE.
;	Released at DieHard 2026 Winter compo.  https://events.retroscene.org/dh2026winter/beeper
;	~Jan 2026.
; 	Mind blowing 1-bit audio.
;
;	Ported to the VZ/Laser by Dave Aug 26, but does require a DAC hanging on the printer port.
;	Need to :get a VZ/Laser printer interfaceface (PI-20 or PI30 or whatever that name is), 
;		:make a resistor ladder circuit. Simple or complicated. Or use a 4050 IC chip DAC.
;		:cut Printer interface ribbon cable and connect D0-D7 to input of DAC.
;		: possible use a 2.2uf cap in both output lines to an amplified speaker.
;		: Run this!
;
;		This uses Port 12 which drives the printer interface.  Ports ~10-1A drives the printer interface.
;
;
;	Use SJASMPLUS to assemble to an object file.
;	Use the VZ/Laser header linker utility "RBINARY.EXE" by Guy Thomason, to object link to the .VZ file.
;	<OR> add the 24byte header to this below, which I really should just add. But cant be bothered. You be on your own.
;


	output "BEEPERDR.VZ"


;  ================
;	VZ HEADER
;  ================
				;      ==========================================
origin	equ  $8000		; <==  ONLY THING NEED TO CHANGE.  $7B00 or $8000
				;      ==========================================

	org		origin - 24

	defb		'VZF1'					; file type ID
	defb		"BEEPER DRIVE    ",   0	; zero padded file name
	defb		$f1					; Binary or BASIC?
	defw		START					; start address
	
	org		origin
START:


	di
	
	ld	sp, zeros + 400h
	ld	hl, 0
	ld	c, 0
fill_zeros:
	push	hl
	push	hl
	dec	c
	jp nz,	fill_zeros
	
	ld      bc, 0		; init voice 4 phase
	ld      de, 0		; init voice 5 phase
	exx
	ld      de, 0		; init voice 1 phase
	ld      ix, 0		; init voice 2 phase
	ld      iy, 0		; init voice 3 phase
	
	ld      bc, zeros	; init drum pointer and loop counter
	
	ld	sp, frmexit + 2
	ld      hl, nextframe
	push	hl		; init frmexit
	ld	hl, zeros
	push	hl		; init wave1
	push	hl		; init wave5
	push	hl		; init wave4
	push	hl		; init wave3
	push	hl		; init wave2
	ld	hl, 100h
	push	hl		; init freq5
	push	hl		; init freq4
	push	hl		; init freq3
	push	hl		; init freq2
	push	hl		; init freq1
	
	ld	hl, seq_default
	ld	(seqptr), hl
	
	ld      hl, section_main
	ld      (notesptr), hl
	
	sub     a
	ex      af, af'
	sub     a
	
	ld	hl, addrtbl
	jp      nextnote
	
exit:
	jp	0

	
; Since interframe logic is too long, form a fake pulse, corresponding to the zero-level (86 tacts)
; Timing for fake zero pulse:
;
;---     start of linterframe
;--- 38 = 48 - 10  /  ( due to additional RET at the end of frame )
;---     start of pulse (0)
;--- 86
;---     end of pulse (1)
;--- 82
;---     iloop
nextframe:
	; timing changed to ( 39, 84, 83 ) due to lack of balances
	ex      af, af'		;= 4, save previous sample value
frmptr	equ $ + 1
	ld	sp, qframe0	;= 10
	pop	hl		;= 10
	sub	a		;= 4
	out     (12), a	;= 11, start fake pulse
	
	cp	l		;= 4
	jp z,	nextnote	;= 10
	ld      c, framepad	;= 7
nextframe_inner:
frmdst2	equ $ + 1
	ld	(wave2+1), hl	;= 16
frmdst3	equ $ + 1
	ld	(wave3), hl	;= 16
	pop	hl		;= 10
	dec	sp		;= 6
	cpl			;= 4
	out     (12), a	;= 11, end fake pulse
	
frmdst4	equ $ + 1
	ld	(wave4+1), hl	;= 16
frmdst5	equ $ + 1
	ld	(wave5), hl	;= 16
	pop	af		;= 10
frmdst1	equ $ + 1
	ld	(wave1+1), a	;= 13
	ld	(frmptr), sp	;= 20
	inc     b		;= 4
	ex      af, af'		;= 4, restore previous sample value
iloop:
	include 'core/iloop.asm'

nextnote:
notesptr equ $ + 1
	ld	sp, section_main	;= 10
nextnote_inner:
	pop	hl		;= 10
	dec	sp		;= 6
	or	l		;= 4
	jp p,	storfrmseq	;= 10
	ld	h, addrtbl/256	;= 7
	ld	a, (hl)		;= 7
	inc	h		;= 4
	ld	h, (hl)		;= 7
	ld	l, a		;= 4
	jp	(hl)		;= 4

noteexit:
	pop	hl		;= 10
	dec	sp		;= 6
storfrmseq:
	ld	a, $ff		;= 7
	out     (12), a	;= 11, end fake pulse
	
	ld	h, addrtbl/256	;= 7
	ld	a, (hl)		;= 7
	inc	h		;= 4
	ld	h, (hl)		;= 7
	ld	l, a		;= 4
	ld	(nwfrmptr), hl	;= 16
	ld	(notesptr), sp	;= 20
sequencer:
seqptr  equ $ + 1
	ld	sp, seq_default	;= 10
	pop	bc		;= 10
	pop     hl		;= 10
seqdst	equ $ + 1
	ld      (fakevar), hl	;= 16
	ld      (seqptr), sp	;= 20
nwfrmptr equ $ + 1
	ld	sp, qframe0	;= 10
	sub	a		;= 4
	out     (12), a	;= 11, start fake pulse
	
	pop	hl		;= 10
internote_frmptr equ $ + 1
	jp	nextframe_inner	;= 10
	
	include 'codegen/pulses.asm'
	include 'codegen/notecode.asm'

	include 'codegen/notedata.asm'
	include 'codegen/sequences.asm'
	include 'codegen/frames.asm'


;============== VARS ===============================================
fakevar	dw	0
callsave1 dw	0
callsave2 dw	0
callsave3 dw	0
	include 'core/vars.asm'

;============== ALIGNED DATA =======================================
	align   256
	include 'codegen/pulsestbl.asm'
	include 'codegen/addrtbl.asm'
waveforms:
	include 'codegen/waves.asm'
	include 'codegen/samples.asm'
zeros:
end:
;	labelslist 'build/main.lbl'
	
