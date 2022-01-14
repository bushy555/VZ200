nolist
write "jumpcar.vz"

;VZ header
.hstrt
db "VZF0"
db "JUMP CAR"                ;VZ Name - Up to 16 chars
ds hstrt + 17 + 4 - $
db #f1
dw start

org #7b00
.start
di
ld a,8
ld (#6800),a
xor a
ld hl,#7000
ld de,#7001
ld bc,#300
ld (hl),a
ldir
ld b,2
ld (hl),#aa
ldir
ld bc,#2ff
ld (hl),a
ldir
ld hl,main
ld bc,end_code - #7800
ldi
ldi
jp #7800

.main
org #7800
limit #83ff
ldir
ld sp,draw_text
jp begin
ds #7800 + 21 - $

.colbuff	equ #7800
.colbuff2	ds 9
.speed		dw 0
.dist		db 0
.height		db 0
.vdir		db 0
.vert		dw 0
.more_fuel	db 0
.dist_left	db 0
.start_dist	db 0
.start_time	db 0,0
.start_gap	db 0
.start_fuel	db 0,0
.num_close	db 0
.sprites	ds 32
.collisions	ds 42
.sprite		dw 0
.sprite_col	db 0
.sprite_time	db 128
.sprite_gap	db 32

list
.intrt
nolist
ld sp,draw_text
.where equ $ + 1
jp draw_text

.begin
ld hx,132
.rotlp1
call rotate
call rotate
dec hx
jr nz,rotlp1
ld de,#70c8
ld c,#55
exx
ld hl,score + 5
ld b,1
call nums	; Score
ei
halt

ds 4	; Stack space for initialisation

.draw_text
ld hl,spr_score
ld de,#7004
call spr4
ld e,#09
call spr4
inc e
call spr4
ld e,#14
call spr4
inc e
call spr4
call draw_all
ld hl,waitrout
jp go_where

.main_loop
call draw_all

ld hl,0
ld (sndper),hl

ld a,(dist_left)
or a
jr z,no_collision

ld de,collisions
ld hx,7
.collp1
ld b,6
.collp2
ld a,(de)
inc e
or a
jr z,nocoll
ld a,8
sub b
ld hl,sprites
ld c,16
.chkspr
sub (hl)
jr nc,nochk
cp #fe
jr c,nochk
; Found collision
xor a
ld (hl),a
inc l
cp (hl)
jp nz,collided
ld hl,more_fuel
ld a,(hl)
add 3
ld (hl),a
jr nocoll
.nochk
add (hl)
inc l
inc l
dec c
jr nz,chkspr
.nocoll
djnz collp2
dec hx
jr nz,collp1

.no_collision
ld hl,more_fuel
ld a,(hl)
or a
jr z,nofuel
dec (hl)
ld a,9
ld (sndper + 1),a
ld hl,(fuel)
cp h
jr nz,not99
cp l
jr z,nofuel
inc l
ld h,#ff
.not99
inc h
ld (fuel),hl
.nofuel
ld hl,timecnt
dec (hl)
jr nz,notime
ld (hl),50
ld hl,(time)
ld a,h
or a
jr nz,notout
ld a,l
or a
jp z,timeout
ld h,9
dec l
jr settime
.notout
dec h
.settime
ld (time),hl
.notime
ld hl,(speed)
ld a,(dist)
add l
ld (dist),a
ld a,h
adc 0
ld hx,a
jr z,norot
.rotlp3
call rotate
.dec_fuel equ $ + 1
ld a,15
dec a
ld (dec_fuel),a
jr nz,nodecf
ld hl,dist_left
ld a,(hl)
or a
jr z,nodd
dec (hl)
jr nz,nodd
ld hl,spr_flag
ld (sprite),hl
ld a,#ff
ld (last_spr),a
ld a,1
ld (sprite_col),a
.nodd
ld hl,(fuel)
ld a,h
or a
jr z,decfh
dec h
jr setfuel
.decfh
ld a,l
or a
jr z,setfuel
ld h,9
dec l
.setfuel
ld (fuel),hl
ld hl,score + 4
ld b,5
call upscore
.nodecf
dec hx
jr nz,rotlp3

.norot
ld a,(height)
or a
jr nz,nomove

ld hl,(fuel)
ld a,h
or l
ld c,2
jr z,goleft

ld a,(#68fb)
ld c,a
and #10
jr nz,noleft

.goleft
ld hl,(speed)
ld a,h
or l
jr nz,nocheckf
ld hl,(fuel)
ld a,h
or l
jp z,timeout
jr noleft
.nocheckf
ld de,-8
add hl,de
ld (speed),hl
ld hl,kmh + 3
ld b,3
.declp
dec hl
ld a,(hl)
or a
jr nz,enddec
ld (hl),9
djnz declp
ld a,10
.enddec
dec a
ld (hl),a

.noleft
bit 1,c
jr nz,noright

ld hl,(speed)
ld a,h
cp #06
jr z,noright
ld de,8
add hl,de
ld (speed),hl

ld hl,kmh + 3
ld b,3
.inclp
dec hl
ld a,(hl)
inc a
cp 10
jr nz,endinc
xor a
ld (hl),a
djnz inclp
.endinc
ld (hl),a

.noright
ld a,(#68bf)
and #04
jr nz,nomove

ld hl,(speed)
ld a,h
or a
jr nz,jumpok
ld a,l
cp 80
jr c,nomove

.jumpok
ld a,1
ld (vdir),a
ld hl,#8000
ld (vert),hl

.nomove
ld a,(vdir)
or a
jr z,nojump
ld c,a

ld hl,(vert)
ld a,(jump)
add l
ld (jump),a
ld a,0
adc h

dec c
jr nz,down

or a
jr z,noup

srl h
rr l
ld (vert),hl

ld hl,height
inc (hl)
ld hl,(car_pos)
ld bc,-32
add hl,bc
ld (car_pos),hl
jr nojump

.noup
bit 4,l
jr z,nojump

ld a,l
ld (vdir),a
jr nojump

.down
or a
jr z,nojump

add hl,hl
ld (vert),hl

ld hl,height
dec (hl)
ld a,(hl)

ld hl,(car_pos)
ld bc,32
add hl,bc
ld (car_pos),hl

or a
jr nz,nojump

ld (vdir),a

.nojump
.sndper equ $ + 1
ld bc,0
ld a,b
or c
call nz,sound

ei
halt

.upscore
inc (hl)
ld a,(hl)
sub 10
ret nz
ld (hl),a
dec l
ld a,b
cp 3
jr nz,ninclv
ld a,(cars)
inc a
ld (cars),a
.ninclv
djnz upscore
ret

.collided
di
ld hl,#4000
.collidelp
dec hl
ld a,h
or l
jr z,dead
ld a,(hl)
ld c,a
and 7
add 16
ld b,a
ld a,c
and #31
or #08
ld (#6800),a
djnz $
jr collidelp
.dead
xor a
ld hl,buff1a
.b1lp
ld (hl),a
inc l
jr nz,b1lp
ld h,buff2a / 256
.b2lp
ld (hl),a
inc l
jr nz,b2lp
ld h,buff3a / 256
.b3lp
ld (hl),a
inc l
jr nz,b3lp
ld h,buff4a / 256
.b4lp
ld (hl),a
inc l
jr nz,b4lp
; Speed to zero, height to 0, vdir to 0
.end_dead
ld hl,#7702
ld (car_pos),hl
xor a
ld h,a:ld l,a
ld (height),hl	; and vdir
ld (speed),hl
ld (kmh),hl
ld (kmh + 2),a
ld (sprite),hl
ld hl,cars
dec (hl)
ld hl,overrout
jr z,is_over
call resft
ld hl,main_loop
.is_over
jp go_where

.timeout
ld hl,timerout
.go_where
ld (where),hl
ei
halt

.timerout
ld ix,#75ca
ld bc,#0baa
call spaces
.time_cnt equ $ + 1
ld a,0
inc a
ld (time_cnt),a
jr z,dead
and #20
jr nz,no_tmsg
ld lx,#ca
call text
db "OUT OF ",0
ld hl,(fuel)
ld a,h
or l
ld hl,time_msg
jr nz,use_time
ld hl,fuel_msg
.use_time
call text_hl
ld b,10
call sound
.no_tmsg
ei
halt

.time_msg
db "TIME",0

.fuel_msg
db "FUEL",0

.rotate
.rothills equ $ + 1
ld a,1
xor 1
ld (rothills),a
jp nz,nohills

ld hl,hillbase + 1
ld a,(hl)
add 3
cp last / 256
ld (hl),a
jp nz,nohills
ld (hl),buff1 / 256
ld hl,#1818
ld (sndper),hl

ld hl,hillbase
ld a,(hl)
inc a
ld (hl),a
add #1f
ld e,a
ld d,buff1 / 256

.hilllp2
ld hl,colbuff
ld b,13
ld a,(hill)
or a
jr z,dohill
ld c,a
.skylp
ld a,(hl)
add a:add a
or #02
ld (hl),a
inc l
dec b
dec c
jr nz,skylp
.dohill
dec b
jr z,nohill
ld a,(snow)
sub b
jr nc,hilllp
ld c,a
.snowlp
ld a,(hl)
add a:add a
or #01
ld (hl),a
inc l
dec b
inc c
jr nz,snowlp
.hilllp
ld a,(hl)
add a:add a
or 3
ld (hl),a
inc l
djnz hilllp

.nohill
ld b,#20
ld hl,colbuff
ld c,e
ld a,(hl):inc l:ld (de),a		;1
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;2
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;3
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;4
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;5
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;6
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;7
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;8
ld a,e:add b:ld e,a:inc d
ld a,(hl):inc l:ld (de),a		;9
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;10
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;11
ld a,e:add b:ld e,a
ld a,(hl):inc l:ld (de),a		;12
ld e,c

ld hl,hill
ld a,(hl)
inc l
add (hl)
or a
jp p,nothz
xor a
ld (hl),1
.nothz
dec l
cp 13
jr c,hlt13
ld a,12
.hlt13
ld (hl),a
inc l
inc l
dec (hl)
jr nz,nonhd
dec l
call rand
rra
sbc a
or 1
ld (hl),a
inc l
call rand
and 3
add 2
ld (hl),a
.nonhd
inc l
call rand
and 1
ld b,a
call rand
and 1
add b
add 6
ld (snow),a

ld a,d
add 2
ld d,a
cp last / 256
jp nz,hilllp2

.nohills
ld hl,(road)
ld a,(road + 2)
ld b,h
rl b:rla:adc hl,hl
rl b:rla:adc hl,hl
ld (road),hl
ld (road + 2),a
ld hl,scrbase + 1
ld a,(hl)
add 3
cp last / 256 + 2
ld (hl),a
ret nz
ld (hl),buff1a / 256

ld hl,sprites
ld b,16
.movspr
ld a,(hl)
or a
jr z,nospr
dec (hl)
jr nz,nospr
inc l
inc (hl)
jp z,end_level
dec l
exx
ld hl,score + 3
ld b,4
call upscore
exx
.nospr
inc l
inc l
djnz movspr

ld hl,(sprite)
ld de,colbuff2
ld a,h
or l
ld a,(sprite_col)
jr nz,draw_sprite

ld a,(dist_left)
cp 2
jr c,no_new
ld hl,sprite_time
dec (hl)
jr z,new_sprite

.no_new
xor a
ld (de),a:inc e
ld (de),a:inc e
ld (de),a:inc e
ld (de),a:inc e
ld (de),a:inc e
ld (de),a:inc e
ld (de),a:inc e
ld (de),a
jr no_sprite

.new_sprite
ld hl,num_close
call rand
and 31
add 2
ld c,a
ld a,(hl)
cp 2
jr z,no_close
ld a,c
cp 7
jr nc,no_close
inc (hl)
ld a,c
jr close_gap

.no_close
xor a
ld (hl),a
ld a,(sprite_gap)
add c
.close_gap
ld (sprite_time),a
call rand
and 3
ld (last_spr),a
ld c,a
add a	; *2
add c	; *3
add a	; *6
add a	; *12
add a	; * 24
add spr_tank
ld l,a
ld a,spr_tank / 256
adc 0
ld h,a
ld a,3

.draw_sprite
ldi:ldi:ldi:ldi
ldi:ldi:ldi:ldi
dec a
jr nz,use_col

ld hl,sprites
ld b,15
.findfree
ld a,(hl)
or a
jr z,free
inc hl
inc hl
djnz findfree
.free
ld (hl),33
inc hl
.last_spr equ $ + 1
ld (hl),0
xor a
ld h,a
ld l,a
.use_col
ld (sprite_col),a
ld (sprite),hl

.no_sprite
ld hl,scrbase
ld a,(hl)
inc a
ld (hl),a
add #1f
ld e,a
ld d,buff1a / 256

ld lx,e
.rotsprites
ld bc,colbuff + 12
ld hl,colbuff2
ld a,(bc):rl (hl):rla:rl (hl):rla:ld (bc),a:inc c:inc l		; 1 - 15 bytes
ld (de),a:ld a,e:add #20:ld e,a
ld a,(bc):rl (hl):rla:rl (hl):rla:ld (bc),a:inc c:inc l		; 2
ld (de),a:ld a,e:add #20:ld e,a
ld a,(bc):rl (hl):rla:rl (hl):rla:ld (bc),a:inc c:inc l		; 3
ld (de),a:ld a,e:add #20:ld e,a
ld a,(bc):rl (hl):rla:rl (hl):rla:ld (bc),a:inc c:inc l		; 4
ld (de),a:ld a,e:add #20:ld e,a
ld a,(bc):rl (hl):rla:rl (hl):rla:ld (bc),a:inc c:inc l		; 5
ld (de),a:ld a,e:add #20:ld e,a
ld a,(bc):rl (hl):rla:rl (hl):rla:ld (bc),a:inc c:inc l		; 6
ld (de),a:ld a,e:add #20:ld e,a
ld a,(bc):rl (hl):rla:rl (hl):rla:ld (bc),a:inc c:inc l		; 7
ld (de),a:ld a,e:add #20:ld e,a
ld a,(bc):rl (hl):rla:rl (hl):rla:ld (bc),a			; 8
ld (de),a
ld e,lx
ld a,d
add 3
ld d,a
cp last / 256 + 2
jp nz,rotsprites
ret

.text
pop hl
call text_hl
jp (hl)

.text_hl
ld a,(hl)
or a
ret z
call char
inc hl
jr text_hl

.spaces
xor a
call usech2
djnz spaces
ret

.char
sub 32
jr z,usech
cp "'" - 32
jr nz,notqt
ld a,11
jr usech
.notqt
sub 15
cp 11
jr c,usech
sub 6
.usech
ld e,a
add a
add a
add e
.usech2
ld e,a
ld d,chars / 256
ld a,(de):and c:inc e:ld (ix + 0),a
ld a,(de):and c:inc e:ld (ix + #20),a
ld a,(de):and c:inc e:ld (ix + #40),a
ld a,(de):and c:inc e:ld (ix + #60),a
inc ix:ld a,(de):and c:ld (ix + #7f),a
ret

.draw_all
.old_car_pos equ $ + 1
ld hl,#76e2
ld bc,28
xor a
ld (hl),a:inc l
ld (hl),a:inc l
add hl,bc
inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
add hl,bc
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a
add hl,bc
dec c
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a
add hl,bc
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a
add hl,bc
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a:inc l
ld (hl),a
add hl,bc
inc l
ld (hl),a:inc l:inc l:inc l
ld (hl),a

ld hl,#73e0
.hillbase equ $ + 1
ld de,buff1
call do8
ld b,4
call doline

.scrbase equ $ + 1
ld de,buff1a
ld hl,#76e0
call do8

ld de,(road)
ld a,(road + 2)
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 3
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 6
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 9
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 12
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 15
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 18
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 21
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 24
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 27
ld (hl),d:inc l:ld (hl),e:inc l:ld (hl),a:inc l	; 30
ld (hl),d:inc l:ld (hl),e

.car_pos equ $ + 1
ld hl,#7702
ld (old_car_pos),hl

.do_collision
ld de,collisions + 2
ld bc,31
ldi					; 1
ld a,(hl):and #fc:ld (de),a		; 2
add hl,bc				; #21
ld a,e:add 4:ld e,a
ld a,(hl):and #3f:ld (de),a:inc l	; 3
ldi:ldi
ld a,e:add 3:ld e,a			; 5
add hl,bc				; #40
ld a,(hl):and #03:ld (de),a:inc l:inc e	; 6
ldi:ldi:ldi				; 9
ld a,(hl):and #c0:ld (de),a:inc e:inc e	; 10
ld c,#1c
add hl,bc				; #60
ld a,(hl):and #3f:ld (de),a:inc l:inc e	; 11
ldi:ldi:ldi:ldi				; 15
ld a,(hl):and #fc:ld (de),a:inc e	; 16
ld c,#1b
add hl,bc				; #80
ldi:ldi:ldi:ldi:ldi:ldi			; 22
ld c,#1a
add hl,bc				; #a0
ld a,(hl):and #3f:ld (de),a:inc l:inc e	; 23
ldi:ldi:ldi:ldi:ldi:inc e		; 28
ld c,#1b
add hl,bc				; #c1
ld a,(hl):and #3c:ld (de),a:inc l:inc e	; 29
inc l:inc l:inc e:inc e
ld a,(hl):and #0f:ld (de),a		; 30

.do_car		; HL is adjusted by 2 already
ld hl,(car_pos)
ld bc,28
ld (hl),#ff:inc l
ld a,(hl):and #03:or #fc:ld (hl),a:inc l
add hl,bc
inc l
ld a,(hl):and #c0:or #3f:ld (hl),a:inc l
ld (hl),#f2:inc l
ld (hl),#a2:inc l
add hl,bc
ld a,(hl):and #fc:or #03:ld (hl),a:inc l
ld (hl),#ff:inc l
ld (hl),#f2:inc l
ld (hl),#a8:inc l
ld a,(hl):and #3f:or #80:ld (hl),a
add hl,bc
dec c
ld a,(hl):and #c0:or #3f:ld (hl),a:inc l
ld (hl),#ff:inc l
ld (hl),#ff:inc l
ld (hl),#ff:inc l
ld (hl),#ff:inc l
ld a,(hl):and #03:or #f4:ld (hl),a
add hl,bc
ld (hl),#ff:inc l
ld (hl),#28:inc l
ld (hl),#ff:inc l
ld (hl),#ff:inc l
ld (hl),#ca:inc l
ld (hl),#3f
add hl,bc
ld a,(hl):and #c0:or #3c:ld (hl),a:inc l
ld (hl),#96:inc l
ld (hl),#3f:inc l
ld (hl),#ff:inc l
ld (hl),#25:inc l
ld (hl),#8f
add hl,bc
inc l
ld a,(hl):and #c3:or #28:ld (hl),a:inc l:inc l:inc l
ld a,(hl):and #f0:or #0a:ld (hl),a

.draw_score
ld de,#70c3
ld c,#55
exx
ld hl,score
ld b,5
call nums	; Score
inc l
exx
ld e,#cb
exx
ld b,1
call nums	; Cars
exx
ld e,#cf
exx
ld b,3
call nums	; Speed
ld a,(hl)	; Fuel < 10?
or a
exx
ld e,#d5
jr nz,nolowf
ld c,#ff
.nolowf
exx
ld b,2
call nums	; Fuel
ld a,(hl)
or a
exx
ld e,#da
ld c,#55
jr nz,nolowt
ld c,#ff
.nolowt
exx
ld b,2

.nums
ld a,(hl)
inc hl
exx
ld b,a
add a
add a
add b
add chars + 5
ld l,a
ld h,chars / 256
ld a,(hl):and c:inc l
ld (de),a:set 5,e
ld a,(hl):and c:inc l
ld (de),a:ld a,e:add #20:ld e,a:inc d
ld a,(hl):and c:inc l
ld (de),a:set 5,e
ld a,(hl):and c:inc l
ld (de),a:res 5,e:set 6,e
ld a,(hl):and c:ld (de),a
set 7,e:inc e:dec d
exx
djnz nums
ret

.do8
ld b,8
.doline
ld a,(de):inc e:ld (hl),a:inc l		; 22T * 31 + 24T = 706T per scan
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc l
ld a,(de):inc e:ld (hl),a:inc hl
dec b
jp nz,doline
inc d
ret

.spr4
ld bc,#1cff
ldi:ldi:ldi:ldi
push de
ld a,e:add b:ld e,a:jr nc,$ + 3:inc d
ldi:ldi:ldi:ldi
ld a,e:add b:ld e,a:jr nc,$ + 3:inc d
ldi:ldi:ldi:ldi
ld a,e:add b:ld e,a:jr nc,$ + 3:inc d
ldi:ldi:ldi:ldi
ld a,e:add b:ld e,a:jr nc,$ + 3:inc d
ldi:ldi:ldi:ldi
pop de
ret

.waitrout
ld ix,#7247
ld c,#55
call text
db "PRESS 'S' TO START",0
ld a,(#68fd)
and #02
jr nz,no_s
ld lx,#47
ld b,18
call spaces
ld ix,#718c
ld b,9
call spaces
xor a
ld h,a:ld l,a
ld (score),hl
ld (score + 2),hl
ld (score + 4),a
ld hl,#3130
ld (level),hl
ld a,40
ld (start_dist),a
ld a,3
ld (cars),a
ld a,60
ld (start_gap),a
.do_new_lev
ld hl,new_level
ld (where),hl
.no_s
ei
halt

.rand
ld a,r
rrca
rrca
neg
.seed equ $ + 1
xor 0
rrca
ld (seed),a
ret

.sound
ld d,b
.sndlp
ld a,#28
ld (#6800),a
ld b,d
djnz $
ld a,#9
ld (#6800),a
ld b,d
djnz $
dec c
jr nz,sndlp
ret

.overrout
call draw_score
ld ix,#718c
ld c,#ff
call text
db "GAME OVER",0
.dopress
ld hl,waitrout
jp go_where

.spr_tank	; 3 x 8
db #0f,#5d,#7d,#5d,#7d,#7f,#0f,#ff
db #ff,#dd,#dd,#dd,#dd,#7d,#ff,#00
db #f0,#77,#f7,#77,#f7,#75,#f0,#ff

.spr_barrels	; 3 x 8
db #0a,#0a,#08,#0a,#aa,#8a,#8a,#aa
db #a0,#a0,#a0,#a0,#2a,#2a,#2a,#2a
db #00,#00,#00,#00,#80,#80,#80,#80

.spr_small_car	; 3 x 8
db #00,#00,#01,#05,#15,#4a,#25,#0a
db #00,#55,#4a,#4a,#55,#14,#82,#00
db #00,#40,#20,#88,#55,#a1,#58,#a0

.spr_sand	; 3 x 8
db #00,#00,#00,#01,#04,#01,#14,#55
db #00,#00,#00,#10,#54,#11,#55,#51
db #00,#00,#00,#00,#00,#00,#00,#40

.spr_flag
db #40,#70,#7c,#70,#40,#40,#40,#40

list
.score		ds 6,0
.cars		db 3
.kmh		ds 3
.fuel		db 3,5
.time		db 9,0
.timecnt	db 50
.road		db #55,#ff,#ff
.jump		db 0
.hill		db 6
.hilldir	db 1
.hillcount	db 5
.snow		db 6

list
.pad1 equ -$ and #ff
nolist
ds pad1

; Character data Space, 0..9, ', A..Z
.chars
db #00,#00,#00,#00,#00	; Space
db #fc,#cc,#cc,#cc,#fc	; 0
db #30,#30,#30,#30,#30	; 1
db #fc,#0c,#fc,#c0,#fc	; 2
db #fc,#0c,#fc,#0c,#fc	; 3
db #cc,#cc,#fc,#0c,#0c	; 4
db #fc,#c0,#fc,#0c,#fc	; 5
db #fc,#c0,#fc,#cc,#fc	; 6
db #fc,#0c,#0c,#0c,#0c	; 7
db #fc,#cc,#fc,#cc,#fc	; 8
db #fc,#cc,#fc,#0c,#0c	; 9
db #0c,#0c,#00,#00,#00	; '
db #30,#cc,#fc,#cc,#cc	; A
db #f0,#cc,#f0,#cc,#f0
db #30,#cc,#c0,#cc,#30
db #f0,#cc,#cc,#cc,#f0
db #fc,#c0,#f0,#c0,#fc
db #fc,#c0,#f0,#c0,#c0
db #30,#cc,#c0,#cc,#3c
db #cc,#cc,#fc,#cc,#cc
db #fc,#30,#30,#30,#fc
db #0c,#0c,#0c,#cc,#30
db #cc,#cc,#f0,#cc,#cc
db #c0,#c0,#c0,#c0,#fc
db #cc,#fc,#cc,#cc,#cc
db #cc,#fc,#fc,#fc,#cc
db #30,#cc,#cc,#cc,#30
db #f0,#cc,#f0,#c0,#c0
db #30,#cc,#cc,#30,#0c
db #f0,#cc,#f0,#cc,#cc
db #3c,#c0,#30,#0c,#f0
db #fc,#30,#30,#30,#30
db #cc,#cc,#cc,#cc,#30
db #cc,#cc,#cc,#30,#30
db #cc,#cc,#cc,#fc,#cc
db #cc,#cc,#30,#cc,#cc
db #cc,#cc,#30,#30,#30
db #fc,#0c,#30,#c0,#fc	; Z

.spr_score
db #a2,#8a,#8a,#8a
db #82,#08,#88,#88
db #a2,#08,#8a,#0a
db #22,#08,#88,#88
db #a2,#8a,#88,#8a

.spr_cars
db #02,#8a,#8a,#8a
db #02,#08,#88,#88
db #02,#0a,#8a,#0a
db #02,#08,#88,#82
db #02,#88,#88,#8a

.spr_kmh
db #08,#88,#82,#22
db #08,#8a,#82,#22
db #0a,#08,#88,#2a
db #08,#88,#88,#22
db #08,#88,#88,#22

.spr_fuel
db #0a,#22,#28,#80
db #08,#22,#20,#80
db #0a,#22,#28,#80
db #08,#22,#20,#80
db #08,#2a,#28,#a0

.spr_time
db #0a,#88,#88,#a0
db #02,#08,#a8,#80
db #02,#08,#88,#a0
db #02,#08,#88,#80
db #02,#08,#88,#a0

.end_level
ld hl,do_lvl_snd
ld (where),hl
ld hl,level_snd
ld e,1
ei
halt

.do_lvl_snd
dec e
jr nz,cont_snd
ld d,(hl)
inc d
jp z,do_new_lev
inc l
ld e,(hl)
inc l
.cont_snd
ld a,e
cp #03
jr c,wait_int
ld c,14
.snd_lp
ld b,d
call sound
ei
jr snd_lp

.wait_int
ld bc,#300
.wait_lp
dec bc
ld a,b
or c
jr nz,wait_lp
ei
halt

.resft
ld hl,#0503
ld (fuel),hl
ld hl,#0009
ld (time),hl
ld a,128
ld (sprite_time),a
ret

.new_level
call resft
.level_cnt equ $ + 1
ld a,0
dec a
and 127
ld (level_cnt),a
ld ix,#718c
ld c,#ff
jr z,go_level
call text
db "LEVEL "
.level
db "00",0
call draw_score
ei
halt

.go_level
ld b,8
call spaces
ld hl,(level)
inc h
ld a,h
cp #3a
jr nz,nl9
ld h,#30
inc l
.nl9
ld (level),hl
ld hl,start_dist
ld a,(hl)
ld (dist_left),a
inc (hl)
ld hl,start_gap
ld a,(hl)
ld (sprite_gap),a
dec (hl)
ld hl,main_loop
jp go_where

.level_snd
db #aa,#0a,#aa,#0a,#32,#28,#ff

list
.end_code

.pad2 equ -$ and #ff
nolist
.buff1  equ end_code + pad2
.buff1a equ buff1 + #200
.buff2  equ buff1 + #300
.buff2a equ buff2 + #200
.buff3  equ buff2 + #300
.buff3a equ buff3 + #200
.buff4  equ buff3 + #300
.buff4a equ buff4 + #200

; Startup code

list
.last equ buff4 + #300
.size equ end_code - start