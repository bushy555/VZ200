;VIBRA
;ZX beeper engine by utz 07'2017
;*******************************************************************************

	org $8000

looping equ 1
c0	 equ $22
cis0	 equ $24
d0	 equ $26
dis0	 equ $28
e0	 equ $2b
f0	 equ $2d
fis0	 equ $30
g0	 equ $33
gis0	 equ $36
a0	 equ $39
ais0	 equ $3c
b0	 equ $40
c1	 equ $44
cis1	 equ $48
d1	 equ $4c
dis1	 equ $50
e1	 equ $55
f1	 equ $5a
fis1	 equ $60
g1	 equ $65
gis1	 equ $6b
a1	 equ $72
ais1	 equ $79
b1	 equ $80
c2	 equ $87
cis2	 equ $8f
d2	 equ $98
dis2	 equ $a1
e2	 equ $ab
f2	 equ $b5
fis2	 equ $bf
g2	 equ $cb
gis2	 equ $d7
a2	 equ $e4
ais2	 equ $f1
b2	 equ $100
c3	 equ $10f
cis3	 equ $11f
d3	 equ $130
dis3	 equ $142
e3	 equ $155
f3	 equ $169
fis3	 equ $17f
g3	 equ $196
gis3	 equ $1ae
a3	 equ $1c7
ais3	 equ $1e2
b3	 equ $1ff
c4	 equ $21d
cis4	 equ $23e
d4	 equ $260
dis4	 equ $284
e4	 equ $2aa
f4	 equ $2d3
fis4	 equ $2fe
g4	 equ $32b
gis4	 equ $35b
a4	 equ $38f
ais4	 equ $3c5
b4	 equ $3fe
c5	 equ $43b
cis5	 equ $47b
d5	 equ $4bf
dis5	 equ $508
e5	 equ $554
f5	 equ $5a5
fis5	 equ $5fb
g5	 equ $656
gis5	 equ $6b7
a5	 equ $71d
ais5	 equ $789
b5	 equ $7fc
c6	 equ $876
cis6	 equ $8f6
d6	 equ $97f
dis6	 equ $a0f
e6	 equ $aa9
f6	 equ $b4b
fis6	 equ $bf7
g6	 equ $cad
gis6	 equ $d6e
a6	 equ $e3a
ais6	 equ $f13
b6	 equ $ff8

	
	di
	
;ix,de,bc	accu,base,mod ch1
;iy,de',bc'	accu,base,mod ch2/$fe
;hl		accu/seed noise
;hl'		stack mod
;sp		task stack/data pointer
;a'		prescaler noise
;i		timer hi

	exx
	push hl
	push iy
	ld (oldSP),sp
	
	ld hl,musicData
	ld (seqPointer),hl
	ld sp,stk_idle
	ld ix,0
	ld iy,0
	ld de,0
	ld bc,$fe
	exx
	xor a
	ld h,a
	ld l,a
	ld d,a
	ld e,a
	ld (timerLo),a
	ld (vibrInit1),a
	ld (vibrInit2),a
	ld a,32
	ld i,a
	jp task_read_seq

;*******************************************************************************
soundLoop
	add ix,de		;15		;update counter ch1
	ld a,ixh		;8		;load output state ch1
	
	exx			;4
	jp nc,skip1		;10
	
	ld hl,task_update_fx1	;10		;push update event on taskStack on counter overflow
	push hl			;11

ret1	
;	out (c),a		;12___80	;output ch1
	ld (26624), a	
	ld hl,timerLo		;10		;update timer lo-byte
	dec (hl)		;11
	jr nz,skip3		;12/7

	inc hl			;6		;= ld hl,task_update_timer
	push hl			;11		;push update event on taskStack if timer lo-byte = 0

ret3	
	add iy,de		;15		;update counter ch2
	ld a,iyh		;8		;load output state ch2
;	out (c),a		;11___80	;output ch2
	ld (26624), a
	jr nc,skip2		;12/7
	
	ld hl,task_update_fx2	;10		;push update event on taskStack on counter overflow
	push hl			;11
						
ret2	
	inc hl			;6		;timing
	exx			;4		
noiseVolume equ $+1
	ld a,$0			;7		;load output state noise channel	TODO: if we do ld a,(noiseVolume), we don't need timing adjust and can
						;						save 6t elsewhere
	cp h			;4
	sbc a,a			;4
;	out ($fe),a		;11___64
	ld (26624), a	
	ret			;11		;fetch next task from taskStack
				;224

skip1						;timing adjustments
	nop
	ld l,0
	jp ret1
skip2
	nop
	jr ret2
skip3
	jr ret3

;*******************************************************************************
taskStack
	ds 30
stk_idle
	dw task_idle
;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop iy
	pop hl
	exx
	ei
	ret	

;*******************************************************************************	


;*******************************************************************************
task_idle					;update noise and idle

	ex af,af'		;4'		;update noise pitch prescaler
noisePitch equ $+1
	add a,$0		;7
	jr nc,skip4		;12/7
	
	ex af,af'		;4

	add hl,hl		;11		;update noise generator
	sbc a,a			;4
	xor l			;4
	ld l,a			;4 (34)
	
ret4
	ret c			;5		;timing
	ld a,ixh		;8		;load output state ch1
;	out ($fe),a		;11__80		;output ch1
	ld (26624), a	
	exx			;4
	dec sp			;6		;correct stack offset
	dec sp			;6

	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ds 6			;24

	ld a,iyh		;8		;load output state ch2
;	out ($fe),a		;11__80		;output state ch2
	ld (26624), a	
	exx			;4
	ld a,(noiseVolume)	;13		;load output state noise
	cp h			;4
	sbc a,a			;4
	ds 7			;28
;	out ($fe),a		;11__64		;output noise state
	ld (26624), a
	jp soundLoop		;10

skip4						;timing adjustment
	ex af,af'		;4'		;swap back to AF
	nop			;4
	xor a			;4		;clear carry for following timing adjustment
	jp ret4			;10 (34)


;*******************************************************************************
timerLo	db 0					;timer lo-byte

task_update_timer				;update timer hi-byte
	xor a			;4
	ret c			;5		;timing
	in a,($fe)		;11		;read kbd
	cpl			;4
	and $1f			;7
	jp nz,exit		;10
	
	ret nz			;5		;timing
	exx			;4
	ld a,ixh		;8
;	out ($fe),a		;11___80
	ld (26624), a	
 	ld a,i			;9		;I = timer hi-byte
 	dec a			;4
 	ld i,a			;9
	jp nz,skip5		;10
	
	ld hl,task_read_ptn	;10
	push hl			;11
	
ret5	
	ds 2			;8
	ld a,iyh		;8
;	out ($fe),a		;11___80
	ld (26624), a	
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	exx			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
;	out ($fe),a		;11___64
	ld (26624), a
	jp soundLoop		;10

skip5
	ld a,r			;9		;timing
	jr ret5			;12


;*******************************************************************************	
task_update_fx1					;update vibrate/slide fx ch1
						;see task_update_fx2 for detailed comments
						
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ds 2			;8
	xor a			;4		;timing + clear carry
	ret c			;5		;timing
	ld a,ixh		;8	
vibrDir1
	inc b			;4		;vibrato initial direction
vibrSpeed1 equ $+1
	bit 2,b			;8		;vibrato speed, (see above, bit 3 -> ld b,4 | bit 2 -> ld b,2...)
	
;	out ($fe),a		;11___80
	ld (26624), a	
	ld a,e			;4
fxType1
	jp z,slideDown1		;10		;jp z = vibrato = $ca, jp = slide down = $c3, jp c = slide up = $da (fx off: C = 0)
	
	add a,c			;4		;DE += C
	ld e,a			;4
	adc a,d			;4
	sub e			;4
	ld d,a			;4 
	
	ds 3			;12
retv1
	ds 2			;8
	ld a,0			;7		;timing
	ld a,iyh		;8
;	out ($fe),a		;11___80
	ld (26624), a	
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	ds 8			;32
;	out ($fe),a		;11___64
	ld (26624), a
	jp soundLoop		;10


slideDown1
	sub c			;4		;DE -= C
	ld e,a			;4
	sbc a,a			;4    
	add a,d			;4            
	ld d,a			;4
	jr retv1		;12 


;*******************************************************************************	
task_update_fx2					;update vibrate/slide fx ch2
	exx			;4
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	nop			;4
	xor a			;4		;timing + clear carry
	ret c			;5		;timing
	ld a,ixh		;8		;load output state ch2
vibrDir2
	inc b			;4		;initial vibrato direction
vibrSpeed2 equ $+1
	bit 2,b			;8		;bit n = vibrato speed (lower is faster)
						;B must be initialized with (2^n)/2 (so bit 3 -> ld b,4 | bit 2 -> ld b,2...)	
;	out ($fe),a		;11___80	;output state ch1
	ld (26624), a	
	ld a,e			;4
fxDepth2 equ $+1
	ld c,1			;7		;modification amount
fxType2	
	jp z,slideDown2		;10		;jp z = vibrato, jp = slide down, jp c = slide up (carry is always cleared at this point)
						;fx off: C = 0
	add a,c			;4		;base divider ch2 += modification amount (DE += C)
	ld e,a			;4
	adc a,d			;4
	sub e			;4
	ld d,a			;4 
	
	ds 3			;12
retv2
	nop			;4
	exx			;4
	ld a,iyh		;8		;load output state ch2
;	out ($fe),a		;11___80	;output ch2
	ld (26624), a	
	ds 2			;8
	ld a,r			;9		;timing
	exx			;4
	ld c,$fe		;7		;restore C'=$fe (needed by main sound loop)
	exx			;4
	
	ld a,(noiseVolume)	;13		;load output state noise
	cp h			;4
	sbc a,a			;4
;	out ($fe),a		;11___64	;output noise state
	ld (26624), a
	jp soundLoop		;10


slideDown2
	sub c			;4		;DE -= C
	ld e,a			;4
	sbc a,a			;4    
	add a,d			;4            
	ld d,a			;4
	jr retv2		;12 

;*******************************************************************************

		


;*******************************************************************************
task_read_seq
	ld (taskPointer_rs),sp	;20
seqPointer equ $+1
	ld sp,0			;10
	exx			;4
	inc hl			;6		;timing
	pop hl			;10
	
	ld a,ixh		;8		;load output state ch1
;	out ($fe),a		;11___80
	ld (26624), a
	
	ld a,h			;4
	or l			;4
IF looping = 0
	jp z,exit		;10
ELSE
	jp z,doLoop		;10
ENDIF
	ld (ptnPointer),hl	;16
	ld hl,task_read_ptn	;10
	
	ld a,0			;7		;timing
	ld a,iyh		;8		;load output state ch2
;	out ($fe),a		;11___80
	ld (26624), a	
	ld (seqPointer),sp	;20
taskPointer_rs equ $+1
	ld sp,0			;10
	
	push hl			;11		;push event on task stack
	
	exx			;4
	nop			;4
	ld a,h			;4		;cheating a bit with noise output
;	out ($fe),a		;11___64
	ld (26624), a
	jp soundLoop		;10		;-1t, oh well


doLoop
	ld hl,mloop		;10
	ld (seqPointer),hl	;16
	
	exx			;4
	nop			;4
	ld a,iyh		;8
;	out ($fe),a		;11___81 (+1)
	ld (26624), a
	
	ld sp,(taskPointer_rs)	;20
	dec sp			;6		;task_read_seq is already on stack, just need to adjust pos
	dec sp			;6
	
	ld a,(noiseVolume)	;13		;load noise put state
	cp h			;4
	sbc a,a			;4
;	out ($fe),a		;11___64
	ld (26624), a
	jp soundLoop		;10
check
;*******************************************************************************
IF (LOW($))!=0
	org 256*(1+(HIGH($)))
ENDIF
bitCmdLookup
	db 0
	db $48					;bit 1,b
	ds 2,$50				;bit 2,b
	ds 4,$58				;bit 3,b
	ds 8,$60				;bit 4,b
	ds $10,$68				;bit 5,b
	ds $20,$70				;bit 6,b
	db $78					;bit 7,b (engine will crash if B < $48)
	
;*******************************************************************************	
task_read_ptn					;determine which channels will be reloaded, and push events to taskStack accordingly
						;btw if possible, saving sp to hl' (ld hl,0, add hl,sp : ld sp,hl) is slightly faster than via mem (27t vs 30t)
						;also, ld hl,mem_addr, ld a,(hl), ld (hl),a is faster than ld a,(mem_addr), ld (mem_addr),a (24 vs 26t)
	ld (taskPointer_rp),sp	;20
ptnPointer equ $+1
	ld sp,0			;10
	pop af			;11
	ld i,a			;9		;timer hi
	
	ld a,ixh		;8
;	out ($fe),a		;11___80
	ld (26624), a	
	jr z,prepareSeqRead	;12/7
	
	ld (ptnPointer),sp	;20		;TODO unaccounted for timing
	
taskPointer_rp equ $+1
	ld sp,0			;10
	exx			;4
	
	jp m,noUpdateNoise	;10
	
	ld hl,task_read_noise	;10
	push hl			;11
	jp pe,noUpdateCh2	;10
	
	ld a,iyh		;8
;	out ($fe),a		;11__81 hmmok
	ld (26624), a	
	ld hl,task_read_ch2	;10
	push hl			;11
	jp c,noUpdateCh1	;10

	ld hl,task_read_ch1	;10
	push hl			;11
	exx			;4
	
	ld a,h			;4		;fake noise output
;	out ($fe),a		;11__71 hmmmm
	ld (26624), a
	jp soundLoop		;10
	
		
prepareSeqRead
	ld sp,(taskPointer_rp)	;20
	exx			;4
	ld hl,task_read_seq	;10
	push hl			;11
	exx			;4
	
	ld a,iyh		;8
;	out ($fe),a		;11___80
	ld (26624), a	
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	ld a,0			;7		;timing
	nop			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
;	out ($fe),a		;11__64
	ld (26624), a
	jp soundLoop		;10
	

noUpdateNoise
	jp pe,noUpdateCh2	;10
	ld hl,task_read_ch2	;10
	push hl			;11
	
	ld a,iyh		;8
;	out ($fe),a		;11__81
	ld (26624), a	
	jp c,noUpdateCh1	;10
	
	ld hl,task_read_ch1	;10
	push hl			;11
	exx			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
;	out ($fe),a		;11__67
	ld (26624), a
	jp soundLoop		;10

	
noUpdateCh2
	ld a,iyh		;8
;	out ($fe),a		;11__81
	ld (26624), a	
	jp c,noUpdateCh1	;10
	
	ld hl,task_read_ch1	;10
	push hl			;11
	exx			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
;	out ($fe),a		;11__67
	ld (26624), a
	jp soundLoop		;10	
	
	

noUpdateCh1
	ld a,r			;9	;timing
	ld a,r			;9	;timing
	exx			;4
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
;	out ($fe),a		;11__64
	ld (26624), a
	jp soundLoop		;10

;*******************************************************************************
task_read_ch1				;update ch1 data
	ld (taskPointer_c1),sp	;20
	ld sp,(ptnPointer)	;20
	pop de			;11	;fetch note divider ch1
	ld a,ixh		;8
;	out ($fe),a		;11___81
	ld (26624), a
	
	ld a,d			;4
	add a,a			;4
	jr c,noFxReloadCh1	;12/7	;if MSB of divider was set, skip fx
	
	pop bc			;11	;retrieve fx setting
	ld (ptnPointer),sp	;20
	
	ld a,b			;4
	add a,a			;4
	ld a,iyh		;8
	jr z,doSlideCh1		;12/7	;if (B != 0) && (B != $80) do vibrato
	
;	out ($fe),a		;11___80
	ld (26624), a

	ld ix,0			;14	;reset channel accu
	
taskPointer_c1 equ $+1
	ld sp,0			;10

	exx			;4
	ld hl,task_read_vib1	;10	;we can't complete vibrato setup in this round,
	push hl			;11	;so let's push another task
	exx			;4
	
;	out ($fe),a		;11___64
	ld (26624), a
	jp soundLoop		;10


noFxReloadCh1
	ccf			;4	;clear bit 15 of base divider
	rrca			;4
	ld d,a			;4
	
	ld a,r			;9	;timing
	ld (ptnPointer),sp	;20
	ld a,iyh		;8
;	out ($fe),a		;11___80
	ld (26624), a	
	ld sp,(taskPointer_c1)	;20
	ld ix,0			;14	;reset channel accu
	
vibrInit1 equ $+1
	ld b,0			;7	;reset vibrato init value
	ld a,0			;7	;timing
	nop			;4

	ld a,h			;4	;fake noise
;	out ($fe),a		;11___64	
	ld (26624), a
	jp soundLoop		;10


doSlideCh1
;	out ($fe),a		;11___85 cough cough
	ld (26624), a
	
	ld sp,(taskPointer_c1)	;20	
	jp c,doSlideUpCh1	;10	;determine slide direction
	
	ld a,$c3		;7	;jp = slide down
	ld (fxType1),a		;13

	ld a,h			;4	
;	out ($fe),a		;11___65 fake noise
	ld (26624), a
	jp soundLoop		;10
	
	
doSlideUpCh1
	ld a,$da		;7	;jp c = slide up
	ld (fxType1),a		;13
	
	ld a,h			;4	
	ld (26624), a		;11___65 fake noise
	jp soundLoop		;10	

;*******************************************************************************
task_read_vib1
	ld a,$ca		;7	;jp z = vibrato
	ld (fxType1),a		;13
	
	exx			;4
	dec hl			;6	;timing
	ld hl,(ptnPointer)	;16
	
	nop			;4
	ld a,ixh		;8
	ld (26624), a		;11___80
	
	dec hl			;6
	ld a,(hl)		;7	;peek at vibrato init setting
	ld h,HIGH(bitCmdLookup)	;7	;look up bit x,b command patch
	ld l,a			;4
	
	ld (vibrInit1),a	;13	;store vibrato init setting for later
	ld a,(hl)		;7
	ld (vibrSpeed1),a	;13
	
	exx			;4
	ld a,iyh		;8
	ld (26624), a		;11___80
	
	ds 8			;32
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	ld (26624), a		;11___64
	jp soundLoop		;10

;*******************************************************************************
task_read_ch2				;update ch2 data
	ld (taskPointer_c2),sp	;20
	ld sp,(ptnPointer)	;20
	exx			;4
	pop de			;11	;fetch note divider ch2
	ld a,ixh		;8
	ld (26624), a		;11___85
	
	ld a,d			;4
	add a,a			;4
	jr c,noFxReloadCh2	;12/7	;if MSB of divider was set, skip fx
	
	pop hl			;11	;retrieve fx setting
	ld (ptnPointer),sp	;20
	
	ld a,h			;4
	ld b,a			;4
	add a,a			;4
	ld a,iyh		;8
	jr z,doSlideCh2		;12/7	;if (B != 0) && (B != $80) do vibrato
	
	ld (26624), a		;11___84

	ld a,l			;4
	ld (fxDepth2),a		;13
	ld iyh,0		;11	;el cheapo accu reset
	
taskPointer_c2 equ $+1
	ld sp,0			;10

	ld hl,task_read_vib2	;10	;we can't complete vibrato setup in this round,
	push hl			;11	;so let's push another task
	exx			;4
	
	ld (26624), a		;11___74 hrrm
	jp soundLoop		;10


noFxReloadCh2
	ccf			;4	;clear bit 15 of base divider
	rrca			;4
	ld d,a			;4
	
	ld a,r			;9	;timing
	ld (ptnPointer),sp	;20
	ld a,iyh		;8
	ld (26624), a		;11___80
	
	ld sp,(taskPointer_c2)	;20
	ld iy,0			;14	;reset channel accu
	
vibrInit2 equ $+1
	ld b,0			;7	;reset vibrato init value
	ld a,0			;7	;timing
	exx			;4

	ld a,h			;4	;fake noise
	ld (26624), a		;11___64	
	jp soundLoop		;10


doSlideCh2
	ld (26624), a		;11___85 cough cough
	
	exx			;4
	ld sp,(taskPointer_c2)	;20	
	jr nc,doSlideDownCh2	;12/7	;determine slide direction
	ld a,$da		;7	;jp c = slide up
	ld (fxType2),a		;13
	
	ld a,h			;4	
	ld (26624), a		;11___66 fake noise
	jp soundLoop		;10

doSlideDownCh2	
	ld a,$c3		;7	;jp = slide down
	ld (fxType2),a		;13
	
	ld (26624), a		;11___67 fake noise (A = $c3, so will always output 0)
	jp soundLoop		;10	

;*******************************************************************************
task_read_vib2
	ld a,$ca		;7	;jp z = vibrato
	ld (fxType2),a		;13
	
	exx			;4
	dec hl			;6	;timing
	ld hl,(ptnPointer)	;16
	
	nop			;4
	ld a,ixh		;8
	ld (26624), a		;11___80
	
	dec hl			;6
	ld a,(hl)		;7	;peek at vibrato init setting
	ld h,HIGH(bitCmdLookup)	;7	;look up bit x,b command patch
	ld l,a			;4
	
	ld (vibrInit2),a	;13	;store vibrato init setting for later
	ld a,(hl)		;7
	ld (vibrSpeed2),a	;13
	
	exx			;4
	ld a,iyh		;8
	ld (26624), a		;11___80
	
	ds 8			;32
	ld a,(noiseVolume)	;13
	cp h			;4
	sbc a,a			;4
	ld (26624), a		;11___64
	jp soundLoop		;10

;*******************************************************************************
task_read_noise
	ld (taskPointer_n),sp	;20
	ld sp,(ptnPointer)	;20
	pop hl			;11
	ld a,ixh		;8
	ld (26624), a		;11___81
	
	ld (ptnPointer),sp	;20
	ld a,h			;4
	ld (noisePitch),a	;13
	
	ld a,l			;4
	ld (noiseVolume),a	;13
	
	ld a,0			;7	;timing
	ld a,iyh		;8
	ld (26624), a		;11___80
	
	ld a,0			;7	;timing
	ex af,af'		;4
	ld a,h			;4	;update prescaler
	ex af,af'		;4
taskPointer_n equ $+1
	ld sp,0			;10	
	ld hl,1			;10
	
	xor a			;4
	ld (26624), a		;11___64
	jp soundLoop		;10

;*******************************************************************************


;*******************************************************************************
musicData

mloop
	dw ptn0
	dw ptn1
	dw 0
	
ptn0
	dw $2004, fis3, $0204, 0
	dw $0884, $8000|a3
	dw $1884, $8000|b3
	
	dw $2081, fis3, $0204
	dw $0881, $8000|a3
	dw $1881, $8000|b3
	
	dw $0884, $8000|d4
	dw $0884, $8000|b3
	dw $0884, $8000|a3
	dw $0884, $8000|fis3
	dw $1084, $8000|e3
	
	dw $0881, $8000|d4
	dw $0881, $8000|b3
	dw $0881, $8000|a3
	dw $0881, $8000|fis3
	dw $2081, $8000|e3
	
	dw $0880, $8000|d3, d2, $0104
	dw $0880, $8000|e3, $8000|e2
	dw $0880, $8000|fis3, $8000|fis2
	dw $0880, $8000|a3, $8000|a2
	dw $1080, $8000|e3, $8000|e2
	dw $0880, $8000|e3, $8000|e2
	dw $0880, $8000|fis3, $8000|fis2
	dw $0880, $8000|d3, $8000|d2
	dw $0880, $8000|e3, $8000|e2

	dw $0800, $8000|b2, $8000|b1, $4060
	dw $0805, $4030
	dw $0805, $4018
	dw $0805, $400c
	dw $0805, $ff60
	dw $0805, $ff30
	dw $0805, $ff18
	dw $0805, $ff0c
	
	dw $0040

ptn1	
	dw $0804, fis3, $0204, $4060
	dw $0805, $4030
	dw $0805, $4018
	dw $0805, $400c
	dw $0804, $8000|a3, $ff60
	dw $0804, $8000|b3, $ff30
	dw $0805, $ff18
	dw $0805, $ff0c
	
	dw $0801, fis3, $0204, $4060
	dw $0805, $4030
	dw $0805, $4018
	dw $0805, $400c
	dw $0801, $8000|a3, $ff60
	dw $0801, $8000|b3, $ff30
	dw $0805, $ff18
	dw $0805, $ff0c
	
	dw $0804, $8000|d4, $4060
	dw $0804, $8000|b3, $4030
	dw $0804, $8000|a3, $4018
	dw $0804, $8000|fis3, $400c
	dw $0804, $8000|e3, $ff60
	dw $0805, $ff30
	
	dw $0801, $8000|d4, $ff18
	dw $0801, $8000|b3, $ff0c
	dw $0801, $8000|a3, $4060
	dw $0801, $8000|fis3, $4030
	dw $0801, $8000|e3, $4018
	dw $0805, $400c
;	
	dw $0805, $ff60
	dw $0805, $ff30
	dw $0800, $8000|d3, d2, $0104, $ff18
	dw $0800, $8000|e3, $8000|e2, $ff0c
	dw $0800, $8000|fis3, $8000|fis2, $4060
	dw $0800, $8000|a3, $8000|a2, $4030
	dw $0800, $8000|e3, $8000|e2, $4018
	dw $0805, $400c
	dw $0800, $8000|e3, $8000|e2, $ff60
	dw $0800, $8000|fis3, $8000|fis2, $ff30
	dw $0800, $8000|d3, $8000|d2, $ff18
	dw $0800, $8000|e3, $8000|e2, $ff0c
	dw $0800, $8000|b2, $8000|b1, $4060
	dw $0805, $4030
	dw $0805, $4018
	dw $0805, $400c
	dw $0805, $ff60
	dw $0805, $ff30
	dw $0805, $ff18
	dw $0805, $ff0c

	dw $1000, b2, $0208, b1, $8004, $ff06
	dw $1004, b2, $0210, $ff03
	dw $1004, b2, $0218, 0
	dw $1084, b2, $0220
	dw $1084, b2, $0128
	dw $1084, b2, $0130
	dw $1084, b2, $0138
	dw $1084, b2, $0140
	
	dw $0040

	
