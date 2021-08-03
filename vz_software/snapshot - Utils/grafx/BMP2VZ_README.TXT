Windows Bitmap to .VZ file converter
-----------------------------------------------------------
by Juergen Buchmueller

usage: bmp2vz [options] filename<.bmp> [outfile.vz]
translate a windows 16 color bitmap to VZ graphics.

options:
-bxxxx  set hex base address for binary image (def. 7D00)
-l      put a loader in front of the image (def. off)
Keep your Windows BMP close to the original Window's
16 colours.  I use Green, Yellow, Blue, Red of the
Window's colours and it translates well.

