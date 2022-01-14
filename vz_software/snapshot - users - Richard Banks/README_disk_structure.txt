I had no idea about the VZ disk image file structure so I took a look at one and reproduced 
the general structure.  It was pretty simple and consists of (from memory, PC with the source 
code isn't turned on) IDAM block, then DAM block and the sector data along with checksum.  
Every track has an additional 16 0 bytes after it, not sure why, maybe flags for stepper phases?, 
but I left them all 0.

There aren't any files on the save and data disks.  There is a dummy directory entry in sector 0 
but that's just for disc identification.  The data is read and written via direct sector access.  
The storage area starts at track 0, sector 1.  For the data disk it is simply one contiguous block
of sectors.  For the save disk, each slot is 12288 bytes long and follows on from the final sector
of the last block.

The crude VZ file system writes a pointer to the next sector in a file in the last 2 bytes of the 
current sector, with the last sector in the file having 0:0.  The data and save game disks do not 
follow this.  The sectors to read / write are calculated as per below.  Since data starts at t0:s1 
the bam on these two disks is definitely not valid and should not be used by a quick copier that 
only copies allocated blocks.  A copier that simply reads sectors 0 to 15 on tracks 0 to 39 should 
be able to reproduce all 3 disks (vzork, data, save).

My code for the port handles the trs-80 DOS requests by using the FCB next record field, maintained 
by the interpreter for game IO but maintained by me for save IO.  Double that to get a 128 byte 
sector LBA add 1 to it to allow for the fake dir sector at 0:0, then convert that to track, sector 
and finally call the vz read / write routine twice to do the actual disk io and write or read the 
256 byte record that the interpreter expects trs-80 dos to handle.

The disk with vzork on it should be a normal VZ disk, including pointers at the end of the sectors, 
apart from the free space bitmap not being filled in, as it has to be and can be read by the DOS ROM
brun routine.

I think I built the images with a 2:1 sector interleave, was testing different interleaving for 
speed, but that shouldn't trip up any disc copy programs.

The reason for direct sector access is that the VZ native file structure, as I understand it 
described above, is completely unsuitable for random IO.  The file access would be linear from 
0 for each go, or require caching of the pointers either a pre-read of the entire file or cached 
as encountered during linear access.




