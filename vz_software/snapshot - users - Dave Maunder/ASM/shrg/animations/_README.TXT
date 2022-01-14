
Super Hi-res Graphics demos for the VZ / Laser.
256x192 resolution
For use on either real VZ / Laser with the 6k video modification hack or for use on VZEM emulator.

www.yahoogroups.com/groups/vzemu


All demos mount disk 1 into drive 1 and disk 2 into drive 2
If more than 2 disks, the loader program which is always on disk 1 in drive 1, will advise which disk to then mount into whichever drive.  Every 6k frame in every demo will first load into memory, and then will be blitted to the screen tricking into looking like it is awesome animation...

dave

---------------------------------------------------------------------------

1. Find a nice animated GIF file.

2. Grab each frame and reduce it to 256x192 in a black and white (mono) colour.

3. Import each frame on to a VZ disk image through the likes of VZEM emulator 'Load Bitmap'
   This will load the (now 6k .BMP file) to 0xC000.
   BSAVE"FRAME01",C000,D800

   ...and keep doing this for each frame.
   ...you will only get 12 frames (12 x 6k) to a single floppy disk image.
   ...you will need a "Please insert disk 2" into your import program.

4. Rip off any of the existing loader displaying programs and change accordingly.

5. All credits go to Guy "Intertek" Thomason for the emulator and this animation concept on the VZ.



I use Paint Shop Pro in order to get a nice 256 .GIF --> 2 colour .BMP
There are a multitude of methods of getting the correct pixels to align correct and make a GIF look good.
In Paint Shop I use a combination of either, or both of, ctrl+shift+2 and ctrl+shift+1
ie, Changing the GIF file firstly to a 16 colour image and then to a 2 colour, or depending on the layout of the original colour palette in the GIF, go straight from the 256 colour gif to a 2 colour.
And experiment with either the weighted and un-weighted error diffusion and weighted/unweighted closest colour in both the 16 colour and 2 colour options. Some combinations will work better on some GIFs than others combinations. All dependant on the original colour palette of the GIF.


