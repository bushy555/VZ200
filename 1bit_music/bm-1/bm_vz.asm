;BM-1 aka BeepModular-1, a ZX Spectrum beeper engine
;by utz 02'2017

USETABLES equ 1
USEDRUMS equ 1
USELOOP equ 1
	

rest	equ 0

c0	 equ $87
cis0	 equ $8f
d0	 equ $98
dis0	 equ $a1
e0	 equ $ab
f0	 equ $b5
fis0	 equ $bf
g0	 equ $cb
gis0	 equ $d7
a0	 equ $e4
ais0	 equ $f1
b0	 equ $100
c1	 equ $10f
cis1	 equ $11f
d1	 equ $130
dis1	 equ $142
e1	 equ $155
f1	 equ $169
fis1	 equ $17f
g1	 equ $196
gis1	 equ $1ae
a1	 equ $1c7
ais1	 equ $1e2
b1	 equ $1ff
c2	 equ $21d
cis2	 equ $23e
d2	 equ $260
dis2	 equ $284
e2	 equ $2aa
f2	 equ $2d3
fis2	 equ $2fe
g2	 equ $32b
gis2	 equ $35b
a2	 equ $38f
ais2	 equ $3c5
b2	 equ $3fe
c3	 equ $43b
cis3	 equ $47b
d3	 equ $4bf
dis3	 equ $508
e3	 equ $554
f3	 equ $5a5
fis3	 equ $5fb
g3	 equ $656
gis3	 equ $6b7
a3	 equ $71d
ais3	 equ $789
b3	 equ $7fc
c4	 equ $876
cis4	 equ $8f6
d4	 equ $97f
dis4	 equ $a0f
e4	 equ $aa9
f4	 equ $b4b
fis4	 equ $bf7
g4	 equ $cad
gis4	 equ $d6e
a4	 equ $e3a
ais4	 equ $f13
b4	 equ $ff8
c5	 equ $10eb
cis5	 equ $11ed
d5	 equ $12fe
dis5	 equ $141f
e5	 equ $1551
f5	 equ $1696
fis5	 equ $17ed
g5	 equ $195a
gis5	 equ $1adc
a5	 equ $1c74
ais5	 equ $1e26
b5	 equ $1ff0
c6	 equ $21d7
cis6	 equ $23da
d6	 equ $25fb
dis6	 equ $283e
e6	 equ $2aa2
f6	 equ $2d2b
fis6	 equ $2fdb
g6	 equ $32b3
gis6	 equ $35b7
a6	 equ $38e9
ais6	 equ $3c4b
b6	 equ $3fe1
c7	 equ $43ad
cis7	 equ $47b3
d7	 equ $4bf7
dis7	 equ $507b
e7	 equ $5544
f7	 equ $5a56
fis7	 equ $5fb6
g7	 equ $6567
gis7	 equ $6b6e
a7	 equ $71d1



	


macro reset_all
	ds 10
endm

macro saw_wave		;expects paramX_7 = $0f (rrca)
	ds 6
	rrca
	ds 3
endm

macro harmonics		;expects paramX_7 = $07 (rlca)		
	rrca
	rrca
	rrca
	ds 3
	rlca
	ds 3
endm

macro noise
	rlc h
	ds 2
endm

macro noise2
	rlc h
	and h
	nop
endm

macro noise3
	rlc h
	sbc a,a
	or h
endm

macro noise4
	rlc h
	or h
	xor l
endm

macro pfm		;use on both channels for true pin pulse experience
	sbc a,a		;use iyh instead of ixh when only using on ch2
	or ixh
	add a,a
	ld ixh,a
	ds 4
endm

macro noise_vol_ch1	;expects param1_7 = $0f (rrca)
	cp ixh
	sbc a,a
	and ixl
	nop
	rrca
	rlc h
	nop
endm

macro noise_vol_ch2	;expects param2_7 = $0f (rrca)
	cp iyh
	sbc a,a
	and iyl
	nop
	rrca
	rlc h
	nop
endm

macro supersquare_ch1
	exx
	add a,b
	ds 4
	sub b
	exx
	ds 2
endm

macro supersquare_ch2
	add a,b
	ds 5
	sub b
	ds 3
endm

macro organ_ch1		;expects param1_7 = $07 (rlca)
	add a,ixh	;recommended: ixh = $01..$0f
	or h		;use and h for slightly different sound
	rrca
	rrca
	rrca
	rlca
	ds 3
endm

macro organ_ch2		;expects param2_7 = $07 (rlca)
	add a,iyh	;recommended: iyh = $01..$0f
	or h		;use and h for slightly different sound
	rrca
	rrca
	rrca
	rlca
	ds 3
endm


macro duty_vol_ch1	;expects param1_7 = $0f (rrca)
	cp ixh
	sbc a,a
	and ixl
	nop
	rrca
	ds 3
endm

macro duty_vol_ch2	;expects param2_7 = $0f (rrca)
	cp iyh
	sbc a,a
	and iyl
	nop
	rrca
	ds 3
endm


macro sid_sound_ch1	;expects param1_7 = $9f (sbc a,a)
	sbc a,a
	add a,ixh
	ld ixh,a
	cp h
	ds 3
endm

macro sid_sound_ch2	;expects param2_7 = $9f (sbc a,a)
	sbc a,a
	add a,iyh
	ld iyh,a
	cp h
	ds 3
endm


macro fake_chord_ch1	;may also produce glitches, or nothing special at all
	xor ixl		;depending on freq_div and value in ixl
	ld h,a
	cp ixh
	sbc a,a
	ds 4
endm

macro fake_chord_ch2	;may also produce glitches, or nothing special at all
	xor iyl		;depending on freq_div and value in iyl
	ld h,a
	cp iyh
	sbc a,a
	ds 4
endm


macro phaserlike
	daa
	rlca
	cpl
	xor h
	rrca
	rrca
	ds 4
endm

macro oboe		;expects paramX_7 = $0f (rrca)
	daa
	rlca
	rlca
	cpl
	xor h
	nop
	rrca
	ds 3
endm

macro hardnheavy
	daa
	cpl
	xor h
	rrca
	ds 2
	ds 4
endm

macro phat1
	daa			;15	phat rasp
	rrca
	rrca
	cpl
	or h
	nop
	ds 4
endm

macro phat2
	daa			;16	phat 2
	rrca
	rrca
	cpl
	and h
	nop
	ds 4
endm

macro phat3
	daa			;19	phat 5
	rrca
	rrca
	cpl
	xor h
	nop
	ds 4
endm

macro phat4
	cpl			;13	rasp 1
	daa
	sbc a,a
	rlca
	and h
	nop
	ds 4
endm

macro slightly_phat
	rlca			;1b	phat 7
	rlca
	sbc a,a
	and h
	rlca
	nop
	ds 4
endm




	org $8000
	
engine_init


	call	$01c9		; VZ ROM CLS
	ld	hl, MSG1	; Print MENU
	call	$28a7		; VZ ROM Print string.

	ld	hl, MSG2	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG3	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG4	; Print MENU
	call	$28a7		; VZ ROM Print string.


	di
	exx

	push hl				;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,musicData
	ld (seqpntr),hl

;*******************************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop bc				;pattern pointer to DE
	or b
	ld (seqpntr),sp
	jr nz,rdptn0

IF USELOOP = 1	
	ld sp,mloop			;get loop point
	jr rdseq+3
ENDIF
;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

;*******************************************************************************
rdptn0
	ld (ptnpntr),bc
readPtn

IF USETABLES = 1
	ld (fxTablePtr),sp
ENDIF

;	in a,($fe)			;read kbd
;	cpl
;	and $1f
;	jr nz,exit


ptnpntr equ $+1
	ld sp,0	


	pop af				;ctrl0+drum_param (see example music.asm for data format details)
	jr z,rdseq

IF USEDRUMS = 1	
	jp pe,drum1
	jp m,drum2
ENDIF
	
drumRet
	ld (timerLo),a
	jr c,skipAllUpdates
	
	exx
	
	pop af				;ctrl1+patch1_7
	jr c,skipUpdateCh1
	jr z,skipPatchUpdateCh1
		
	ld (patch1_7),a
	
	pop hl				;patch_ptr
	
	jp pe,skipPatchUpdate1_6

	ld de,patch1_1
	ld bc,6
	ldir
	
skipPatchUpdate1_6
	jp m,skipPatchUpdate8_11
	
	ld de,patch1_8
	ld bc,4
	ldir
	
skipPatchUpdate8_11	
skipPatchUpdateCh1
	pop de				;note_div_ch1
	rlc d				;if bit 7 of D is set, parameter follows
	jr nc,skipParamUpdateCh1

	ccf				;clear bit 7 of D on the following rotate
	pop ix				;generic_param1

skipParamUpdateCh1
	rr d
	ld hl,0				;reset ch1_accu

skipUpdateCh1
	exx


	pop af				;ctrl2+patch2_7
	jr c,skipUpdateCh2
	jr z,skipPatchUpdateCh2
		
	ld (patch2_7),a
	
	pop hl				;patch_ptr
	
	jp pe,skipPatchUpdate2_1_6

	ld de,patch2_1
	ld bc,6
	ldir
	
skipPatchUpdate2_1_6
	jp m,skipPatchUpdate2_8_11
	
	ld de,patch2_8
	ld bc,4
	ldir
	
skipPatchUpdate2_8_11	
skipPatchUpdateCh2
	pop de				;note_div_ch2
	rlc d				;check if parameter follows
	jr nc,skipParamUpdateCh2

	ccf
	pop iy				;generic_param2

skipParamUpdateCh2
	rr d
	ld hl,0				;reset ch2_accu

skipUpdateCh2
skipAllUpdates

	pop af

IF USETABLES = 1
	jr z,skipTblPtrUpdate

	pop bc
	ld (fxTablePtr),bc

skipTblPtrUpdate	
	ld (ptnpntr),sp
	
fxTablePtr equ $+1
	ld sp,0
ENDIF

	exx	
timerLo equ $+2
	ld bc,$00fe			;port|timer lo

	exx

	ld c,$fe			;port
	ld b,a				;timer hi
;*******************************************************************************
	exx
playNote
	add hl,de	;11		;ch1_accu += note_div_ch1
	ld a,h		;4		;without further modifications, this
					;will output a 50:50 square wave
patch1_1
	nop		;4
patch1_2
	nop		;4
patch1_3
	nop		;4
patch1_4
	nop		;4	
patch1_5
	nop		;4
patch1_6
	nop		;4
	
;	out (c),a	;12__64		;ch1 volume 1
	and 33
	ld (26624), a
patch1_7
	nop		;4
;	out (c),a	;12__16		;ch1 volume 2
	and 33
	ld (26624), a
patch1_8
	nop		;4
patch1_9
	nop		;4
patch1_10
	nop		;4
patch1_11
	nop		;4
	
	nop		;4
;	out (c),a	;12__32		;ch1 volume 4
	and 33
	ld (26624), a
	
	
	exx		;4
	
	add hl,de	;11		;ch2_accu += note_div_ch2
	ld a,h		;4

patch2_1
	nop		;4
patch2_2
	nop		;4
patch2_3
	nop		;4
patch2_4
	nop		;4
patch2_5
	nop		;4
patch2_6
	nop		;4
		
	jp _skip	;10
_skip			
;	out ($fe),a	;11__64		;ch2 volume 1
	and 33
	ld (26624), a
patch2_7
	nop		;4
;	out (c),a	;12__16		;ch2 volume 2
	and 33
	ld (26624), a
patch2_8
	nop		;4
patch2_9
	nop		;4
patch2_10
	nop		;4
patch2_11
	nop		;4
	
	exx		;4
;	out (c),a	;12__32		;ch2 volume 4	
	and 33
	ld (26624), a

	djnz playNote	;13
			;224

;*******************************************************************************
IF USETABLES = 1			
tblNext					;run fx table
	pop af				;tbl_ctrl0
	jr z,stopTableExec
	jr c,stopTableExec+1
	jp m,tableJump
	ret pe				;exec tbl code

tblStdUpdate	
	pop af				;tbl_ctrl1
	
	jr z,noTblDiv1
	
	pop de
noTblDiv1	
	jr c,noTblParam1
	
	pop ix
noTblParam1	
	jp m,noTblDiv2
	exx
	pop de
	exx
noTblDiv2	
	jp pe,noTblParam2
	
	pop iy
	
noTblParam2	
noTableExec
ENDIF		
	exx
	djnz playNote-1
	
	jp readPtn


IF USETABLES = 1	
stopTableExec
	dec sp
	dec sp
	exx
	djnz playNote-1
	jp readPtn
	
tableJump
	ld a,h
	ld c,l
	pop hl
	ld sp,hl
	ld h,a
	ld l,c
	ld c,$fe
	jp tblNext
ENDIF	
	

;*******************************************************************************
IF USEDRUMS = 1
drum1						;kick
	ld (deRest),de
	ld (hlRest),hl

	ld d,a					;A = start_pitch<<1
	ld e,0
	ld h,e
	ld l,e
	
	ex af,af'
	
	srl d					;set start pitch
	rl e
	
	ld c,$3					;length
	
xlllp
	add hl,de
	jr c,_noUpd
	ld a,e
_slideSpeed equ $+1
	sub $10					;speed
	ld e,a
	sbc a,a
	add a,d
	ld d,a
_noUpd
	ld a,h
;	and $ff					;border
;	out ($fe),a
	and 33
	ld (26624), a
	djnz xlllp
	dec c
	jr nz,xlllp

						;45680 (/224 = 203.9)
deRest equ $+1
	ld de,0
	
	ex af,af'	
	ld a,$34				;correct speed offset

drumEnd
hlRest equ $+1
	ld hl,0
	
	jp drumRet		
	

	
drum2						;noise
	ld (hlRest),hl
	
	ld b,a
	ex af,af'
	
	ld a,b
	ld hl,1					;$1 (snare) <- 1011 -> $1237 (hat)
	rlca
	jr c,setVol
	ld hl,$1237

setVol
	ld (dvol),a	
				
	ld bc,$ff03				;length
sloop
	add hl,hl		;11
	sbc a,a			;4
	xor l			;4
	ld l,a			;4

dvol equ $+1	
	cp $80			;7		;volume
	sbc a,a			;4
	
;	and $ff			;7		;border
;	out ($fe),a		;11
	and 33
	ld (26624), a
	djnz sloop		;13/7 : 65 * 256 * B : B=3 -> 49920 (/224 = 222.8)

	dec c			;4
	jr nz,sloop		;12 : (16 - 6) * B : B=3 -> +30
				;			+load/wrap
				;49903 w/ b=$ff (/224 = 222.8)
	ex af,af'
	ld a,$21		;correct speed offset
	
	jr drumEnd
ENDIF
	
MSG1	db "BM-1 MUSIC PLAYER",0,0
MSG2	db $0d,$0d,"MORE LIKE SKRILLEX USES",0,0
MSG3	db $0d,"A VZ TO MAKE HIS TUNES.",0,0
MSG4	db $0d,$0d,"...JUST SAYING",0,0


	
;*******************************************************************************	
musicData
;	include "music.asm"



;example song for bm-1 beeper engine

;************************************************************************************************************************************************
;song sequence

mloop			;sequence loop point (mandatory)
	dw ptn0		;list of patterns
	dw ptn1
	dw ptn2
	dw ptnA
	dw 0		;sequence end marker (mandatory)
	
;************************************************************************************************************************************************
;pattern data
;
;DATA FORMAT:	ctrl0/drum param|0 (Z = end, C=no updates, PV = drum1, M = drum2)
;		ctrl1/patch1_7 (Z = no patch update, PV = skip patch 1-6, S = skip patch 8-11, C = skip all)
;			[patch_ptr, div1, [(if div1&0x8000) param1]]
;		ctrl2/patch2_7 (Z = no patch update, PV = skip patch 1-6, S = skip patch 8-11, C = skip all)
;			[patch_ptr, div2, [(if div2&0x8000) param2]]
;		ctrl3/speed (Z = no tbl_ptr update)
;
;
;          dr_cfg p1_7   patch1  div1   par1    p2_7   patch2  div2   par2    speed  tbl_ptr
;          ctrl0  ctrl1                         ctrl2                         ctrl3

ptn0	;basic pattern with example patch usage
	dw $1004, $0f00, patch2, c0,		$0000, patch0, rest,	      $1000, stopfx
	dw $0000, $0040,	 c1,		$0001,			      $1040
	dw $4080, $0000, patch1, c0/2,		$0001,			      $1040
	dw $0000, $0040,	 c0,		$0001,			      $1040
	db $40											;pattern end
	
ptn1	;patch with parameter and volume table
	dw $1004, $0f00, patch4, $810f,	$2010,	$0001,			      $1000, voltab1	;$801f = $8000|c1
	dw $0000, $0040,	 c2,		$0001,			      $1040
	dw $4080, $0040,	 c1,		$0001,			      $1040
	dw $0000, $0040,	 c2,		$0001,			      $1040
	db $40
	
ptn2	;sid sound and noise test
	dw $1004, $9f00, patch3, $810f,	$2000,	$0001,			      $1000, stopfx
	dw $0000, $0040,	 c2,		$0001,			      $1040
	dw $4080, $0040,	 c1,		$0001,			      $1040
	dw $0000, $0040,	 c2,		$0004, patch5, $2174,	      $1040
	db $40											;pattern end

ptnA	;table with code execution
	dw $1004, $0000, patch0, c0/2,		$0000, patch0, rest,	      $1000, tblCodeEx
	dw $0000, $0040,	 c0,		$0001,			      $1040
	dw $4080, $0000, patch1, c0/2,		$0001,			      $1040
	dw $0000, $0040,	 c0,		$0001,			      $1040
	db $40											;pattern end
	
;************************************************************************************************************************************************
;patch data
;4, 6, or 10 bytes of code, depending on ctrl1/ctrl2
	
patch0
	reset_all		;macro supplied by patches.h

patch1
	rrca			;patchX_1
	or h			;patchX_2
	ds 8

patch2
	saw_wave

patch3
	sid_sound_ch1

patch4
	duty_vol_ch1
	
patch5
	noise

;************************************************************************************************************************************************
;fx table data
;
;tbl_flags: Z = stop tbl_exec, C= no update, S = tbl_jump, PV = execute function (addr follows)
;if no flags set or function executed that jumps to tblStdUpdate, second ctrlbyte follows: Z = skip freq_div1, C=skip generic_param1, 
;											   S = skip freq_div2, PV = skip generic_param2
;data follows in order: freq_div1, generic_param1, freq_div2, generic_param2

stopfx
	db $40
	
voltab1
	db $01				;no update on this tick
	db $01
	dw $0000, $00c4, $2020		;skip div1, set param1, skip div2, skip param2
	db $01
	db $01
	dw $0000, $00c4, $2030
	db $01
	db $01
	dw $0000, $00c4, $2040
	db $01
	db $01
	dw $0000, $00c4, $2050
	db $01
	db $01
	dw $0000, $00c4, $2060
	db $01
	db $01
	dw $0000, $00c4, $2070
	dw $0080, voltab1		;jump to beginning of table
	
tblCodeEx
	dw $0004, runtimeMod
	db $40
	
;************************************************************************************************************************************************
;functions
;
;triggered by table execution
;each function must end with "jp noTableExec" or "jp tblStdUpdate"

runtimeMod
	ld a,$07			;rlca
	ld (patch1_7),a
	jp noTableExec

;************************************************************************************************************************************************


