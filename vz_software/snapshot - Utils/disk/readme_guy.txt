8/10/2008

These are the small utilities I wrote to transfer the extended basic disk. They ask for a start/end track and dump it to memory starting from 8000h

In Ripper, once the track reads are finished the start/end address is poked to 30884/5 and 30969/70. You need to do a CSAVE and capture the wav file. 

I saved the files as 

Trk0-7.wav
Trk8-15.wav
Trk16-23.wav
Trk24-31.wav
Trk32-39.wav

Then I used wav2vz to convert each wavfile to a snapshot, loaded them into the emulator, did a NEW to clear out the pointers, loaded the WriteTrk snapshot and wrote the tracks back to a disk image. 

It’s ugly but can be used on disks that do direct sector reads like the extended basic. 
