Octode v2 beeper music engine by Shiru (shiru@mail.ru) 02'11


Features

The engine allows to use eight channels of tone, with interrupting drum channel, and per-pattern tempo. Drums are not use ROM data or samples. Overall design of the player is intended to be compact and easy to use, to allow it's use in games, although music data is rather large.

Note that this is version 2. Version 1 had more limited frequency range, version 2 reduces detuning in higher notes, thus making version 1 obsolete.


How to make music

There is no dedicated editor for the engine. You can make music using any tracker with XM format support. You have to follow certain limitations. You can hear sound while editing using template module provided, it has sounds sampled from the engine, so the sound is somewhat similar to the end result, although not much. After you have made a song, you can convert it to an assembly source file with data in needed format.

You can use patterns with arbitrary lengths in your song. Module should have no less than eight channels. You can loop the order list to any position. You can use both tempo and BPM to change speed.

To set speed, you can use global tempo and BPM settings, or use Fxx effects on the first row of a pattern. Every pattern can have own speed. The speed will be recalculated as needed, to closest possible in the player.

You can use any notes, however, there is a lot of detune in higher octaves. You can also use effect E5x on the notes (finetune). x is 0..8..F, 8 means no change in the note frequency, 7 means a bit higher frequency, 9 means a bit lower frequency. This could be used to produce 'fat' sounds by putting the same note on two channels, and using E59 on every note of one of the channels. Be careful if you use E57 or lower on low notes, it could move frequency out of range. Converter will show you warning messages in this case.

You can put drums to any channel, only one drum can be played on a row. Different drum sounds assigned to notes C-4,D-4,E-4,F-4,G-4,A-4,B-4,C-5 (eight sounds).


Music data format

List of 16-bit pointers to patterns, LSB/MSB
0
16-bit pointer to loop point (in the list of the patterns above)
Patterns data


Pattern data format

Tempo 1..65535
Eight bytes of 8-bit note dividers per row, optional preceding byte is 255 for end of the pattern, or 240..254 for drums

Note divider 0 is note cut