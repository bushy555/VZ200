/* vzread - version 0.1							*/
/* Convert an audio file or live audio input into a VZ200 casette image */
/* Copyright (C) 1999 - Brian Murray, brian@proximity.com.au            */
/* Released under the terms of the GNU General Public Licence           */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <mmsystem.h>
#include <audio.h>
#include <audiofile.h>
#include "vzfile.h"

AFfilehandle af;
ALport ap;

double sampleRate;
int window;
int verbose = 0;
int readingFile;

#define BUFFER_SIZE 1024

#define MIN_AMPLITUDE 3000
#define CYCLE_SHORT 0.0006
#define CYCLE_LONG 0.0012


int bufferPage = 0;
int bufferStart = 0;
int bufferEnd = 0;
short buffer[BUFFER_SIZE];

int
readBuffer(void)
{
    int start = bufferPage * BUFFER_SIZE / 2;
    int len = BUFFER_SIZE / 2;

    if (readingFile)    
	len = AFreadframes(af, AF_DEFAULT_TRACK, &buffer[start], len);
    else
	ALreadsamps(ap, &buffer[start], len);

    bufferPage = !bufferPage;
    return len;
}

#define ERROR_END -1
#define ERROR_NULL -2

int
measureCycle(void)
{
    int count, extreme, length;
    int p;
    short extremeValue;
    short s;
    
    /*
     * Ensure there are at least window's worth of samples in
     * the sample buffer.
     */
    if ( ((BUFFER_SIZE + bufferEnd - bufferStart) % BUFFER_SIZE) < window) {

	length = readBuffer();
	if (length < window)
	    return ERROR_END;
	    
	bufferEnd += length;
	bufferEnd %= BUFFER_SIZE;
    }

    /*
     * Look forward to find the next minimum extreme.
     */
    count = (int) (CYCLE_SHORT * 1.1 * sampleRate);
    p = bufferStart;
    extreme = -1;
    extremeValue = buffer[p++] - MIN_AMPLITUDE;
    if (p == BUFFER_SIZE)
	p = 0;
	
    while (count-- > 0) {
	s = buffer[p];
	    
	if (s < extremeValue) {
	    extremeValue = s;
	    extreme = p;
	}

	if (++p == BUFFER_SIZE)
	    p = 0;
    }
    
    if (extreme == -1) {
	bufferStart += window/4;
	bufferStart %= BUFFER_SIZE;
	return ERROR_NULL;
    }
	
    /*
     * Look forward to find the next maximum extreme.
     */
    count = (int) (CYCLE_SHORT * 1.1 * sampleRate);
    p = extreme;
    extreme = -1;
    extremeValue += MIN_AMPLITUDE;
	
    while (count-- > 0) {
	s = buffer[p];
	    
	if (s > extremeValue) {
	    extremeValue = s;
	    extreme = p;
	}
	if (++p == BUFFER_SIZE)
	    p = 0;
    }
    
    if (extreme == -1) {
	bufferStart += window/4;
	bufferStart %= BUFFER_SIZE;
	return ERROR_NULL;
    }

    length = (BUFFER_SIZE + extreme - bufferStart) % BUFFER_SIZE;
    bufferStart = extreme;
    
    return (length < (int) ((CYCLE_SHORT + CYCLE_LONG) / 2.0 * sampleRate));
}

int
readBit(void)
{
    int cycle;
    cycle = measureCycle();
    if (cycle == ERROR_END)
	return ERROR_END;
	
    if (cycle != 1)
	return ERROR_NULL;
	
    cycle = measureCycle();
    if (cycle == 1) {
	cycle = measureCycle();
	if (cycle == 0)
	    return ERROR_NULL;
    }
    
    return cycle;
}

int readByte(void)
{
    int i;
    int byte = 0;
    int bit;
    for (i=0; i<8; i++) {
	bit = readBit();
	if (bit == ERROR_NULL && i == 7)
	    bit = 0;
	    
	if (bit < 0)
	    return 0;
	
	byte = (byte << 1) | bit;
    }
    
    return byte;
}


int
vzDecode(FILE* outfile)
{
    int byte, count;
    struct vzfile vzf;
    unsigned short vz_start, vz_end;
    unsigned short sum, check;
    char* progress;
    int progressNum;
    
    window = (int) (CYCLE_LONG * 2.0 * sampleRate);
    
    if (verbose)
	fprintf(stderr, "Waiting ...\n");
    
    /*
     * sync up to leader
     */

    progress = "while waiting for leader";
    while (1) {
	byte = readByte();
	if (byte == ERROR_END)
	    goto dataend;
	   
	if (byte == ERROR_NULL)
	    continue;
	
	/*
	 * A successful sync byte, now wait for preamble
	 */
	if (byte == 0x80)
	    break;
	
	/*
	 * Try delaying one bit and syncing again
	 */
	if (readBit() == ERROR_END)
	    goto dataend;
    }

    /*
     * Wait for preamble bytes
     */
    
    if (verbose)
	fprintf(stderr, "Synched to leader ...\n");


    progress = "in leader, waiting for preamble";     
    while (1) {
	byte = readByte();
	if (byte == ERROR_END)
	    goto dataend;
	    
	if (byte == 0xfe)
	    break;
    }

    progress = "in preamble, byte %d";
    count = 4;
    while (count--) {
	progressNum = 4 - count;
	byte = readByte();
	if (byte < 0)
	    goto dataend;
	    
	if (byte != 0xfe) {
	    fprintf(stderr, "DATA ERROR: incorrect preamble bytes\n");
	    return(1);
	}
    }
    
    if ((byte = readByte()) < 0) goto dataend;
    vzf.vzf_type = byte;
    bzero(vzf.vzf_filename, 17);
    count = 0;
    
    progress = "in filename, byte %d";
    while (count < 17) {
	progressNum = count;
	if ((byte = readByte()) < 0) goto dataend;

	vzf.vzf_filename[count++] = byte;
	if (byte == 0)
	    break;
    }

    /*
     * There will be a delay here, so expect some null bits
     */
    progress = "in start addr lsb";
    while ((byte = readByte()) == ERROR_NULL);
    if (byte == ERROR_END)
	goto dataend;
    vzf.vzf_startaddr_l = vz_start = byte;
    sum = byte;
    
    progress = "in start addr msb";
    if ((byte = readByte()) < 0) goto dataend;
    vz_start |= byte << 8;
    vzf.vzf_startaddr_h = byte;
    sum += byte;
        
    progress = "in end addr lsb";
    if ((byte = readByte()) < 0) goto dataend;
    vz_end = byte;
    sum += byte;
    
    progress = "in end addr msb";
    if ((byte = readByte()) < 0) goto dataend;
    vz_end |= byte << 8;
    sum += byte;
    
    vzf.vzf_magic = VZF_MAGIC;
    fwrite(&vzf, sizeof(vzf), 1, outfile);

    count = vz_end - vz_start;

    if (verbose) {
	int time = count / 71;
	
	fprintf(stderr, "Found file: %s\n", vzf.vzf_filename);
	fprintf(stderr, "Type = 0x%02x, Start = 0x%04x, Length = 0x%04x\n", 
	    vzf.vzf_type, vzf.vzf_startaddr, count);
	if (!readingFile)
	    fprintf(stderr, "Estimated load time = %d:%02d\n", 
		time / 60, time % 60);
    }
    
    progress = "in data, byte %d";
    progressNum = 0;
    while (count--) {
	byte = readByte();
	if (byte == ERROR_END)
	    goto dataend;
	progressNum++;
	if (byte == ERROR_NULL)
	    continue;
	    
	putc(byte, outfile);
	sum += byte;
    }
    
    progress = "in checksum";
    if ((byte = readByte()) < 0) goto dataend;
    check = byte;
    
    if ((byte = readByte()) < 0) goto dataend;
    check |= byte << 8;
    
    if (check != sum) {
	fprintf(stderr, "DATA ERROR: bad checksum, expected 0x%04x, got 0x%04x\n", check, sum);
	return(1);
    }
    
    if (verbose)
	fprintf(stderr, "Loaded successfully.\n");
    
    return(0);

dataend:
    fprintf(stderr, "DATA ERROR: premature end of audio ");
    fprintf(stderr, progress, progressNum);
    putc('\n', stderr);
    return(1);
}


main (int argc, char *argv[])
{
    int c;
    extern char *optarg;
    extern int optind;
    int errflag = 0;
    char *infile = NULL;
    int exitStatus;
    FILE* outfile;
    
    while ((c = getopt(argc, argv, "i:v")) != EOF)
	switch (c) {
	    case 'i':
		infile = optarg;
		break;
	    case 'v':
		verbose++;
		break;
	    case '?':
		errflag++;
    }
    
    if (optind + 1 != argc)
	errflag++;
    
    if (errflag) {
	fprintf(stderr, "Decode a VZ200 audio cassette file\n");
	fprintf(stderr, "Usage: %s [-v] [-i <audiofile.aifc>] <vzfile.vz>\n", argv[0]);
	exit(1);
    }
    
    if (infile) {
	if (!(af = AFopenfile(infile, "r", NULL))) {
	    fprintf(stderr, "%s: %s: %s", argv[0], infile, strerror(errno));
	    exit(1);
	}
	
	if (AFgetchannels(af, AF_DEFAULT_TRACK) != 1) {
	    fprintf(stderr, "%s: Audio file must be mono, sorry\n", argv[0]);
	    exit(1);
	}
    
	sampleRate = AFgetrate(af, AF_DEFAULT_TRACK);
	
	readingFile = 1;
    } else {
	ALconfig config;
	long params[2];
	
	params[0] = AL_INPUT_RATE;
	ALgetparams(AL_DEFAULT_DEVICE, params, 2);
	sampleRate = (double) params[1];
	
	config = ALnewconfig();
	ALsetwidth(config, AL_SAMPLE_16);
	ALsetchannels(config, 1);
	ap = ALopenport("vzread", "r", config);
	
	readingFile = 0;
    }

    outfile = fopen(argv[optind], "wb");
    
    exitStatus = vzDecode(outfile);

    fclose(outfile);

    if (readingFile) {
	AFclosefile(af);
    } else {
	ALcloseport(ap);
    }
    
    exit(exitStatus);
}

