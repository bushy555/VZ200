extern int __FASTCALL__ beepeffx(int sfxData)
{
#asm

;data is pushed using the L register, but is pushed using HL pair
;playBasic:
ld a,L ;L ;ld a,0
play:
ld hl,sfxData ;address of sound effects data
; di; disabling interupts here cause issues with sprite redraw
push ix
push iy
ld b,0
ld c,a
add hl,bc
add hl,bc
ld e,(hl)
inc hl
ld d,(hl)
push de
pop ix ;put it into ix
; ld a,(23624) ;get border color from BASIC vars to keep it unchanged
rra
rra
rra
and 7
ld (sfxRoutineToneBorder +1),a
ld (sfxRoutineNoiseBorder +1),a
ld (sfxRoutineSampleBorder+1),a
readData:
ld a,(ix+0) ;read block type
ld c,(ix+1) ;read duration 1
ld b,(ix+2)
ld e,(ix+3) ;read duration 2
ld d,(ix+4)
push de
pop iy
dec a
jr z,sfxRoutineTone
dec a
jr z,sfxRoutineNoise
dec a
jr z,sfxRoutineSample
pop iy
pop ix
;; ei ; enabling interupts here cause issues with sprite redraw
ret
;play sample
sfxRoutineSample:
ex de,hl
sfxRS0:
ld e,8
ld d,(hl)
inc hl
sfxRS1:
ld a,(ix+5)
sfxRS2:
dec a
jr nz,sfxRS2
rl d
sbc a,a
and 33
sfxRoutineSampleBorder:
or 0
ld (26624), a
dec e
jr nz,sfxRS1
dec bc
ld a,b
or c
jr nz,sfxRS0
ld c,6
nextData:
add ix,bc ;skip to the next block
jr readData
;generate tone with many parameters
sfxRoutineTone:
ld e,(ix+5) ;freq
ld d,(ix+6)
ld a,(ix+9) ;duty
ld (sfxRoutineToneDuty+1),a
ld hl,0
sfxRT0:
push bc
push iy
pop bc
sfxRT1:
add hl,de
ld a,h
sfxRoutineToneDuty:
cp 0
sbc a,a
and 33
sfxRoutineToneBorder:
or 0
ld (26624), a
dec bc
ld a,b
or c
jr nz,sfxRT1
ld a,(sfxRoutineToneDuty+1) ;duty change
add a,(ix+10)
ld (sfxRoutineToneDuty+1),a
ld c,(ix+7) ;slide
ld b,(ix+8)
ex de,hl
add hl,bc
ex de,hl
pop bc
dec bc
ld a,b
or c
jr nz,sfxRT0
ld c,11
jr nextData
;generate noise with two parameters
sfxRoutineNoise:
ld e,(ix+5) ;pitch
ld d,1
ld h,d
ld l,d
sfxRN0:
push bc
push iy
pop bc
sfxRN1:
ld a,(hl)
and 33
sfxRoutineNoiseBorder:
or 0
ld (26624), a
dec d
jr nz,sfxRN2
ld d,e
inc hl
ld a,h
and 31
ld h,a
sfxRN2:
dec bc
ld a,b
or c
jr nz,sfxRN1
ld a,e
add a,(ix+6) ;slide
ld e,a
pop bc
dec bc
ld a,b
or c
jr nz,sfxRN0
ld c,7
jr nextData

sfxData: 
SoundEffectsData: 	defw SoundEffect0Data
			defw SoundEffect1Data
SoundEffect0Data: 	defb 1 ;tone
			defw 10,400,200,2,767
			defb 0
SoundEffect1Data: 	defb 1 ;tone
			defw 10,400,200,65526,33279
			defb 0
SoundEffect2Data: 	defb 1 ;tone
			defw 10,400,200,32686,18000
			defb 0
SoundEffect3Data: 	defb 1 ;tone
			defw 10,400,100,65526,33279
			defb 0
SoundEffect4Data: 	defb 1 ;tone
			defw 10,400,100,32686,18000
			defb 0

#endasm
}

