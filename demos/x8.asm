; Displays an X on the VZ
;
; Attempting the smallest sized code.
; VZ has 24 byte loader/overheads.
;
; X4	38 + 24 	= 62 bytes.
; x5    34 + 24		= 58 bytes.
; x7    33 + 24		= 57 bytes.
; x8    28 + 24         = 52 bytes
	
 ORG $8000
            ld          h, $70
            ld          bc, $8c83
            xor       a
each_row        
            push     af
            xor       $1f
            ld          l, a
            ld          (hl), c
            dec       hl
            ld          (hl), b
            pop       af
            ld          l, a
            ld          (hl),c
            inc        hl
            ld          (hl),b
            add       a, 34
            jr          nc, each_row
            inc        h
            inc        l
            jr          nz, each_row

loop      jr          loop