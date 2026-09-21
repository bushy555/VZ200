	- ROM replacement Hack-A-Day article : https://hackaday.com/tag/dick-smith-vz300/
	- Youtube :  https://www.youtube.com/watch?v=wv7eaFaF7W4


Rhys Weatherley
===============
VZ200 ROM restoration/replacement info: 
https://github.com/rweather/vz200-restoration

Redrawn schematic, along with 16k RAM pack : 
https://github.com/rweather/vz200-restoration/blob/main/schematics/VZ200/PDF/VZ200.pdf





Various text replies nabbed from Facebook & google for references:

Power and RAM - Leslie Ayling & Ben Grimmett
============================================
FIRST step - Check the power supply voltages inside the VZ, are the chips getting 5 volts or 
something like 2 or 3 volts?.....fix the power and 99% of the time, the VZ (or any old computer 
console) comes back to life. REPLACE any tantalum capacitors on the VZ board, they tend to 
basically go short circuit (or at least very low impedance) which drops the 5volts supply 
downwards and the chipset stops working. Electrolytic capacitors should be replaced regardless. 
these are such old units nowadays and you can't trust the electro's to work efficiently either.
Also make sure the external plugpack is the correct voltage too, it might have recently started
 dying since you started using it.

Check failed DRAMs first. Others are of the opinion that the GA chips are more likely to 
fail first. That you can see any picture suggests the clock circuit is ok. 6847 is most 
likely working. No vestige of a welcome prompt could be wither ROMs or DRAMs (one or 
more) have failed. You can replace the 4116 drams with (easier to obtain) 4164's by 
changing some jumpers.

Also depending on the type of DRAM you have, there could be a supply rail missing on them which would 
cause that sort of screen. Usually its -5V on pin 1, +12V on pin 8, +5V on pin 9, and 0V on pin 16 for
a standard 4116 DRAM. Some DRAMs like the Hitachi HM4816 used only +5V on pin 8, so it sort of depends
on what you have in the VZ300 as to what voltages should be on the DRAM. There's a small collection of
wire jumpers next to one end of the row of DRAM that select various voltages to various pins, and then
some of the ceramic decoupling capacitors are absent for single rail DRAMs. Usually one or two wire 
links are present.


Power - Meryk Jenkins: 
======================
If it is running sometimes, and sometimes not, it could be a power issue, do you have a way of safely 
measuring the 12v and -5. If not, try reflowing q2 and q3 diodes d1 and d2 and zeners z1 and z2. 
Grid reference c8 on the vz300 tech manual, page 49 and the layout is on page 51. They are in the metal
enclosure between the ram and the GA008 chip. Also check for leaky caps in there. There are about 6. 
If they are leaky or domed, it could be screwing up your 12v or -5v rails, but since it's intermittent, 
I would think dodgy joint. A change in temperature or a knock could affect their operation and then the 
memory won't work properly if its only getting two of the three power sources. Be super careful about 
measuring the voltages at the ic's. If you slip with the probe on the 12v leg and short it to the one 
next to it - poof, no more ram chip, and maybe no more ram chips at all as you would be putting 12v on 
to the bus. You could measure 12v at capacitor c39 (in the can) and -5 at c36 (also in the can). 
Obviously you would need to measure these from the underside of the board. If its bad, I would recap 
and replace z1, z2 at a minimum, but d1 and d2 to be safe.


ROM - Geronimus: 
================
VZ200 ROM replace with either a 2364>2764 adapter or you can rewire the mainboard via jumper 
wires on the underside of the mainboard to suit a 2764. With a little hacking you can also use a 
single 27128 instead. You will need to burn a binary of the ROM file to the EPROM (or EEPROM alternative). 
FWIW garbage screen on a VZ300 is usually GA003 or GA004 but since they are impossible to source and 
require a lot of hacking to replace it pays to replace the ROM/RAM first - and cross your fingers.
The old ROM's are a common failure point on old computers and if you have a burner you can replace 
them easily. A lot of old computers have 2364 type ROM's which a lot of EPROM burners can't read 
directly because the pinouts do not match those of a 2764, but you can easily build an adaptor 
(or buy one probably) and you can use that to read a suspect 2364. A failed ROM usually has garbage or 
FF's and 00's and you can compare that to a known good binary to verify (though often it's very obvious
just looking at the data). You can also get 28C64's which are pin compatible with the 2764 but EEPROM's 
so they can quickly and easily be erased and reprogrammed - great for testing but for something permanent 
there is nothing wrong using 2764/27128's. When you get a burner/UV eraser I'm happy to guide you through 
the process of replacing the ROM's as will other people.

VZ300 ROM's are 27128 compatible. The VZ200 ROM's are 2364 pinout and have a different pinout to 2764. 
The VZ200 can be easily be modded from two 2764's (or EEPROM equivalent) to a single 27128.
For VZ200, you will need either an adapter, or to rewire the original sockets or use a single 27128 with 
a small modification (two 1n4148 diodes and a 4.7K resistor). 

VTech used a variety of DRAMs in the 300 boards, so "original" has quite a wide scope. There are the 
4116's, they also used single voltage 4816's, plus in the 66K models they used 4164/4864 or equivalent.

4116 DRAM is notoriously unreliable, at least those that require +5, +12 and -5V so avoid those. 
Better to replace with 4164 or use my guide for 4464. If you want to stay original those should work 
though, and you'll have some spares. Socket everything.


when you replace the regulator, try to clean up as much of the old solder as possible. Do a trial fit, 
if you bend the legs where they get thinner, that should be spot on. When mine snapped off, it really 
made desoldering the pins super easy. And once you have soldered the new one in, check between the legs 
with a multi-meter to make sure they aren't bridged with a sneaky filament of solder.  

Video chip is OK if something changes on the screen when you type it may be video memory, but it's unlikely. 
Check DRAM and ROM. If any of the DRAM feel hotter or colder than any other, it's probably cactus and will 
need replacing. You may need to replace all the DRAM to be certain however. Check the reset and clock 
circuit. Reset should be held low for a second or so on powerup and you should see the 3.58MHz clock 
on pin 6 (without looking IIRC) of the Z80. Video clock is fine otherwise you wouldn't have a display. 
Failing those it's likely a GA chip, they are very failure prone unfortunately. Z80 is another 
possibility. As far as replacing the memory goes, this guide I made up is very handy to made selection 
and options easier. Do check for cold solder joints just in case and make sure your power supply is at 
least 9VDC@1.5A.  (See RAM replacement guide)


The circuit, wiring and jumpers to use for a single 27128 is the same as for the other VZ200, two diodes 
(1N4148 and orientation is important) and a resistor (3.3K-4.7K will do) near the ROM. You will also need
to jumper and wire the sockets exactly as they are on the other VZ board (put them side by side to see). 
There are traces to join on the board and wires to move on the bottom. Once you have it configured exactly 
like that, download one of the 16kb VZ200 binaries, select the ROM type (type 27128 into your burner software
 to see compatible types and part numbers - there are many standard JEDEC types like 28C128, AM27C128 etc) 
then burn the file to the EPROM and it should work. Your EPROM burner does not support the 2364 types as 
fitted to the VZ so you would have to buy or make an adapter (I made one) to read them. Don't bother, all
 the VZ ROM binaries you need are available in the files section already.

2364 pinout compatible versions were/are available and there are programmers that support them. 
MCM68766 for one is 24 pin and pin compatible and there are also some new solutions that are pin compatible. 
There were and maybe still are programmers that support programming 2364 pin compatible (E)PROMs natively. 
None of the 2302-2364 chips are JEDEC compatible, the exception is the 23128 with is pin compatible with the 
JEDEC 27128. Anyway, I asked about 2364 read support simply because it would be handy to verify if a ROM is
 bad or not without having to use an adapter.


Robert Martin
That's likely a different numbered chip. The 23xx don't have PGM or Vpp pins so that can't be programmed 
except mask programmed permanently in the factory as they are not erasable or re-writeable.
There were other series and I don't remember them all but there were windowless 27xx which were OTP one 
time programmable and 25xx which were 5Volt only versions of the 27xx. Then later 28xx which are EEPROM,
 39xx and 49xx which are NOR FLASH. So there will be the one you mentioned but not this chip number and 
this particular one is even more different in that it a 24 pin 64kb chip when programmable 64kb chips 
are 28 pin. I had this dilemma with a Character ROM that I thought was 4kB (32kb) but it turned out to 
be 2kB (16kb) and I was using the /OE or /CE pin as an address line so I was reading 2kB of data and 
2kB of noise. It was marked 2302 from memory. None of these early chips were JEDEC as JEDEC wasn't a 
thing when the early 2kB / 4kB chips came out. Some were continued later and became JEDEC but some were 
not in demand by that time. With the early chips one had to build a different programmer for each series
 - it was a pain. With some you had to pulse the PGM high voltage and others the Vpp was held at the 
programming voltage and one had to pulse the /PGM pin. The early 64kb chips actually has 2 32kb dies 
that one could see through the window. I still have some of those here. Unfortunately I have about 
100 EEPROMS and I have to erase them. Mostly 27C64 but some 27C128 and 27C256.

Rom Dump Tutorial:  https://www.hp9845.net/9845/tutorials/romdump/


