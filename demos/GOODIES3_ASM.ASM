
;	black = 128	white   = 207
;	green = 143	cyan    = 223
; 	yellow= 159	magenta = 239
;	blue  = 175	buff    = 255
;	red   = 191

        ORG    8000h

GRAFX_MEM_BUFFER	EQU	$B000
GRAFX_MEM_VIDEO		EQU	$7000
VIDEO_OFFSET		EQU	0
video_buffer_offset	EQU	$4000	; +$7000 = buffer at : $B000 

intro:	di
;	ld 	a,8				; mode (1)
;	ld 	($6800),a

	ld	de, 0		; I
	ld	bc, 0		; k	


loopdeloop:
	ld	hl, $7000 + video_buffer_offset	; 28672	; LINE 20
	add	hl, de
	ld	ix, row1
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $701c + video_buffer_offset	; 28700
	sbc	hl, de
	ld	ix, row1
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7001 + video_buffer_offset	; 28673
	add	hl, de
	ld	ix, row1
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $701d + video_buffer_offset	; 28701
	sbc	hl, de
	ld	ix, row1
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

;---				; Line 22

	ld	hl, $71c0 + video_buffer_offset 	; 29120
	add	hl, de
	ld	ix, row1
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $71dc + video_buffer_offset	; 29148
	sbc	hl, de
	ld	ix, row1
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $71c1 + video_buffer_offset	; 29121
	add	hl, de
	ld	ix, row1
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $71dd + video_buffer_offset	; 29149
	sbc	hl, de
	ld	ix, row1
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a
; ---				; Line 24
	ld	hl, $7020 + video_buffer_offset	; 28704
	add	hl, de
	ld	ix, row2
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $703c + video_buffer_offset	; 28732
	sbc	hl, de
	ld	ix, row2
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7021 + video_buffer_offset	; 28705
	add	hl, de
	ld	ix, row2
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $703d + video_buffer_offset	; 28733
	sbc	hl, de
	ld	ix, row2
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

; ---				; Line 28

	ld	hl, $71a0 + video_buffer_offset	; 29088
	add	hl, de
	ld	ix, row2
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $71bc + video_buffer_offset	; 29116
	sbc	hl, de
	ld	ix, row2
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $71a1 + video_buffer_offset ; 29089
	add	hl, de
	ld	ix, row2
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $71bd + video_buffer_offset ; 29117
	sbc	hl, de
	ld	ix, row2
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

; ---				; Line 32
	ld	hl, $7040 + video_buffer_offset	; 28736
	add	hl, de
	ld	ix, row3
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $705c + video_buffer_offset	; 28764
	sbc	hl, de
	ld	ix, row3
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7041 + video_buffer_offset	; 28737
	add	hl, de
	ld	ix, row3
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $705d + video_buffer_offset	; 28765
	sbc	hl, de
	ld	ix, row3
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a
; ---				; Line 36
	ld	hl, $7180 + video_buffer_offset ; 29056
	add	hl, de
	ld	ix, row3
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $719c + video_buffer_offset	; 29084
	sbc	hl, de
	ld	ix, row3
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7181 + video_buffer_offset ; 29057
	add	hl, de
	ld	ix, row3
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $719d + video_buffer_offset	; 29085
	sbc	hl, de
	ld	ix, row3
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

; ---				; Line 40
	ld	hl, $7060 + video_buffer_offset	; 28768
	add	hl, de
	ld	ix, row4
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $707c + video_buffer_offset	; 28796
	sbc	hl, de
	ld	ix, row4
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7061 + video_buffer_offset	; 28769
	add	hl, de
	ld	ix, row4
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $707D + video_buffer_offset	; 28797
	sbc	hl, de
	ld	ix, row4
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

; ---				; Line 44
	ld	hl, $7160 + video_buffer_offset	; 29024
	add	hl, de
	ld	ix, row4
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $717c + video_buffer_offset	; 29052
	sbc	hl, de
	ld	ix, row4
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7161 + video_buffer_offset	; 29025
	add	hl, de
	ld	ix, row4
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $717d + video_buffer_offset	; 29053
	sbc	hl, de
	ld	ix, row4
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a
; ---				; Line 48
	ld	hl, $7080 + video_buffer_offset	; 28800
	add	hl, de
	ld	ix, row5
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $709c + video_buffer_offset	; 28828
	sbc	hl, de
	ld	ix, row5
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7081 + video_buffer_offset	; 28801
	add	hl, de
	ld	ix, row5
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $709d + video_buffer_offset	; 28829
	sbc	hl, de
	ld	ix, row5
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a
; ---				; Line 52
	ld	hl, $7140 + video_buffer_offset	; 28992
	add	hl, de
	ld	ix, row5
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $715c + video_buffer_offset	; 29020
	sbc	hl, de
	ld	ix, row5
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7141 + video_buffer_offset	; 28993
	add	hl, de
	ld	ix, row5
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $715d + video_buffer_offset	; 29021
	sbc	hl, de
	ld	ix, row5
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a
; ---				; Line 56
	ld	hl, $70a0 + video_buffer_offset	; 28832
	add	hl, de
	ld	ix, row6
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $70bc + video_buffer_offset	; 28860
	sbc	hl, de
	ld	ix, row6
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $70a1 + video_buffer_offset	; 28833
	add	hl, de
	ld	ix, row6
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $70bd + video_buffer_offset	; 28861
	sbc	hl, de
	ld	ix, row6
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

; ---				; Line 60
	ld	hl, $7120 + video_buffer_offset	; 28960
	add	hl, de
	ld	ix, row6
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $713c + video_buffer_offset	; 28988
	sbc	hl, de
	ld	ix, row6
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7121 + video_buffer_offset	; 28961
	add	hl, de
	ld	ix, row6
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $713d + video_buffer_offset	; 28989
	sbc	hl, de
	ld	ix, row6
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

; ---				; Line 64
	ld	hl, $70c0 + video_buffer_offset	; 28864
	add	hl, de
	ld	ix, row7
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $70dc + video_buffer_offset ; 28892
	sbc	hl, de
	ld	ix, row7
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $70c1 + video_buffer_offset	; 28865
	add	hl, de
	ld	ix, row7
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $70dd + video_buffer_offset ; 28893
	sbc	hl, de
	ld	ix, row7
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

; ---				; Line 66
	ld	hl, $7100 + video_buffer_offset	; 28928
	add	hl, de
	ld	ix, row7
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $711c + video_buffer_offset	; 28956
	sbc	hl, de
	ld	ix, row7
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $7101 + video_buffer_offset	; 28929
	add	hl, de
	ld	ix, row7
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $711d + video_buffer_offset	; 28957
	sbc	hl, de
	ld	ix, row7
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

; ---				; Line 70
	ld	hl, $70e0 + video_buffer_offset	; 28896
	add	hl, de
	ld	ix, row8
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $70fc + video_buffer_offset	; 28924
	sbc	hl, de
	ld	ix, row8
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $70e1 + video_buffer_offset	; 28897
	add	hl, de
	ld	ix, row8
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a

	ld	hl, $70fd + video_buffer_offset ; 28925
	sbc	hl, de
	ld	ix, row8
	add	ix, bc
	ld	a, (ix)
	ld	(hl), a


	LD 	hl,0x6800
sync2:	BIT 	7,(hl)			; fancy wait retrace.
	jr	NZ,sync2

	push	de
	push	bc
	ld	hl, $b000
	ld	de, $7000
	ld	bc, 2048
	ldir
	pop	bc
	pop	de

	inc	bc				; K=k+1
	inc	de				; inc i
	inc	de				; inc i  (STEP 2)
	ld	a, e
	cp 	15				; cp i=15
	jr	nc, here1
	jp	loopdeloop			; jump i<15
here1:
	ld	bc, 1				; i=15, so k=1. 
	ld	de, 0				; i=15, so i=0. JMP.


;	rowtemp(1-8)=row8(1-8)
;	row8(1-8)=row7(1-8)
;	row7(1-8)=row6(1-8)
;	row6(1-8)=row5(1-8)
;	row5(1-8)=row4(1-8)
;	row4(1-8)=row3(1-8)
;	row3(1-8)=row2(1-8)
;	row2(1-8)=row1(1-8)
;	row1(1-8)=rowtemp(1-8)


;her:  jp her


	push	de
	push	bc
	push	hl
	ld	hl, row8
	ld	de, rowtemp
	ld	bc, 8
	ldir
	ld	hl, row7
	ld	de, row8
	ld	bc, 8
	ldir
	ld	hl, row6
	ld	de, row7
	ld	bc, 8
	ldir
	ld	hl, row5
	ld	de, row6
	ld	bc, 8
	ldir
	ld	hl, row4
	ld	de, row5
	ld	bc, 8
	ldir
	ld	hl, row3
	ld	de, row4
	ld	bc, 8
	ldir
	ld	hl, row2
	ld	de, row3
	ld	bc, 8
	ldir
	ld	hl, row1
	ld	de, row2
	ld	bc, 8
	ldir
	ld	hl, rowtemp
	ld	de, row1
	ld	bc, 8
	ldir
		
	pop	hl
	pop	bc
	pop	de	

	jp	loopdeloop


row1	defb	239,143,223,159,207,128,175,191
row2	defb	143,223,159,207,128,175,191,239
row3	defb	223,159,207,128,175,191,239,143
row4	defb	159,207,128,175,191,239,143,223
row5	defb	207,128,175,191,239,143,223,159
row6	defb	128,175,191,239,143,223,159,207
row7	defb	175,191,239,143,223,159,207,128
row8	defb	191,239,143,223,159,207,128,175
rowtemp defb	000,000,000,000,000,000,000,000

.END
