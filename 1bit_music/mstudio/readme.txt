THE MUSIC STUDIO FOR Z80 TI CALCULATORS

Original Code by Saša Pušica 1989
Modified for Beepola by Chris Cowley 2010
Modified for TI by utz 2012


Usage:

1) Compose music with Beepola/Music Studio engine.
2) Export as "Song Data Only (.asm)"
3) Remove all : from the label names
4) Copy the music data (starting at label TEMPO) to mstudio\music.asm
5) Set calculator model and looping options in studioti.asm

6a) For TI82: Compile with CrASHSDK (requires real DOS or DOSBox). Syntax: crasm ti1bit\mstudio\tistudio
6b) For TI83: Compile with devpac83 (requires real DOS or DOSBox). Syntax: asm83 ti1bit\mstudio\tistudio

Alternatively, you can of course use another linking utility such as bin2var.

You can rename tistudio.asm as you wish, and put your song title into the code header.
