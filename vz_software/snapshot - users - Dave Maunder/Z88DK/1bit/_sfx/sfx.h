//Steve Turner / Hewson Cons
//sfx engine
extern void __FASTCALL__ SFX(unsigned char fx)
{
#asm
ld a, l ;32763
;//z88dk passes the L register from unsigned char
ld (sonreq),a ;32764
;//32991 shows 0
;//ld (sonnow),a//added
play_sound:
call sound ;32767
ld a,(sonnow) ;32770
or a ;32773
jr nz, play_sound;32774
ret ;32776
;//return back to C
sound:
ld a,(sonreq) ;play new sound? ;32777
;//loads contents of 32991 into register A
; 32991 shows 0
and a ;32780
jr z,nonew ;NO
;jumps to nonew

;YES
ld (sonnow),a
dec a
jr z,noise ;#01 noise
ld hl,sfxData
dec a
add a,a
add a,a
add a,a
ld e,a
xor a
ld (sonreq),a
ld d,a
add hl,de
ld bc, 8
ld de,sonfrq ;33245 <--start freq
ldir ;32809
jr process
nonew:
ld a,(sonnow);32813


;//and the old sound is?
;//loads contents of 32990 into register A
;// 32990 shows which SFX called with
;//main.c
and a
ret z
dec a ;//continue noise?
jr nz,process ;//continue sound
jr cnois
noise:
ld a,0xA
ld (sonlen),a
xor a
ld (sonreq),a
cnois:
ld b,0x30
gain:
call random
and 33
ld (26624), a
ld c,2
make:
dec c
jr nz,make
djnz gain
ld hl,sonlen
dec (hl)
ret nz
xor a
ld (sonnow),a
ret
process:
ld a,(sonfrq) ;<--start freq
ld h,a
ld a,33
ld d,0xff
sonlp:
ld e,h
ld (26624), a
xor 33
freq:
dec d
jr z,mod
dec e
jr nz,freq
jr sonlp
mod:
ld a,(soncfg)
add a,h
ld (sonfrq),a ; <--start freq
ld hl,sonmod
dec (hl)
ret nz
ld hl,sonlen
dec (hl)
jr nz,modify
xor a
ld (sonnow),a
ld a,(sonnex)
and a
ret z
ld (sonreq),a
ret
modify:
ld a,(sobrsf)
ld c,a
ld a,(sontyp)
and a
jr z,reset
dec a
jr z,typ1
dec a
jr z,typ2
typoth:
ld a,(soncfg)
neg
ld (soncfg),a
jr mode
typ2:
inc c
inc c
ld a,c
ld (sobrsf),a
jr reset
typ1:
dec c
dec c
ld a,c
ld (sobrsf),a
jr reset
reset:
ld a,c
ld (sonfrq),a ;<--start freq
mode:
ld a,(sonrnd)
ld (sonmod),a
ret
random:
push hl
ld hl,(rnseed)
inc hl
ld a,h
and 3
ld h,a
rok:
ld (rnseed),a
ld a,r
xor (hl)
pop hl
ret
rnseed: defw 0x1000
sonfrq: defb sfxData
;start frequency
soncfg: defb sfxData + 1
;frequency change
sonmod: defb sfxData+2
;change times
sonlen: defb sfxData+3
;repeat times
sontyp: defb sfxData+4
;modulate type
;0 sawtooth
;1 2nd mod down
;2 2nd mod up
;3+ triangle
sobrsf: defb sfxData+5
;reset frequency
sonrnd: defb sfxData+6
;change reset temp
sonnex: defb sfxData+7
;linked sfx
sonnow: defb 0 ;which effect playing
sonreq: defb 0 ;we have an effect
;//start freq 1
;//freq change 2
;//sound mods 3
;//sound reps 4
;//modulate type 5
;//reset freq 6
;//change temp link 7
;//link to SFX 8
;here all sounds excepts number 1
;reserved for random noise
sfxData:
;START AT 2
;testers
;effect 2
defb 13, 9, 11, 5, 3, 13, 15, 0
;effect 3
defb 0, 2, 30, 1, 0, 0, 0, 0
;effect 4
defb 0, 2, 11, 1, 3, 0, 12, 0
;effect 5
defb 0, 2, 30, 1, 1, 1, 10, 3
;effect 6
defb 0, 2, 15, 5, 15, 5, 10, 0
#endasm
}