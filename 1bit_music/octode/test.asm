    device zxspectrum48

	org #c000

begin
	ld hl,musicData
	call octode.play
	jp begin


	include "octode.asm"

musicData
	include "music.asm"

end
	display /d,end-begin

	savesna "test.sna",begin