#define _CRT_SECURE_NO_WARNINGS
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include <string.h>



unsigned char *xm;



int read_word(int off)
{
	return xm[off]+(xm[off+1]<<8);
}



int read_dword(int off)
{
	return xm[off]+(xm[off+1]<<8)+(xm[off+2]<<16)+(xm[off+3]<<24);
}



void cleanup(void)
{
	free(xm);
}



int main(int argc, char* argv[])
{
	const float notes[12]={2093.0f,2217.4f,2349.2f,2489.0f,2637.0f,2793.8f,2960.0f,3136.0f,3322.4f,3520.0f,3729.2f,3951.0f};
	const float cputime=275.0f;
	FILE *file;
	int size;
	int order_len;
	int order_loop;
	int channels;
	int patterns;
	int tempo;
	int bpm;
	int i,j,k,pp,patlen;
	int tag,note,ins,vol,fx,param,drum;
	int row[8],rowp[8];
	int speed;
	unsigned char freqtable[96];
	float div,step;
	char name[1024];

	if(argc<2)
	{
		printf("xm2octode v2 converter by Shiru (shiru@mail.ru) 02'11\n");
		printf("Usage: xm2octode filename.xm\n");
		exit(0);
	}

	file=fopen(argv[1],"rb");

	if(!file)
	{
		printf("Error: Can't open file %s\n",argv[1]);
		exit(-1);
	}

	fseek(file,0,SEEK_END);
	size=ftell(file);
	fseek(file,0,SEEK_SET);

	xm=(unsigned char*)malloc(size);
	fread(xm,size,1,file);
	fclose(file);

	atexit(cleanup);

	if(memcmp(xm,"Extended Module: ",17))
	{
		printf("Error: Not XM module\n");
		exit(-1);
	}

	order_len=read_word(60+4);
	order_loop=read_word(60+6);
	channels=read_word(60+8);
	patterns=read_word(60+10);
	tempo=read_word(60+16);
	bpm=read_word(60+18);

	if(!order_len)
	{
		printf("Error: Module should have at least one order position\n");
		exit(-1);
	}

	if(channels<8)
	{
		printf("Error: Module should have at least eight channels\n");
		exit(-1);
	}

	div=32;

	for(i=0;i<8;i++)
	{
		for(j=0;j<12;j++)
		{
			step=(3500000.0f/(cputime/2.0f))/(notes[j]/div);
			if(step>=240) step=0;
			freqtable[i*12+j]=(unsigned char)step;
		}
		div/=2;
	}

	strcpy(name,argv[1]);
	name[strlen(argv[1])-2]='a';
	name[strlen(argv[1])-1]='s';
	name[strlen(argv[1])  ]='m';
	name[strlen(argv[1])+1]=0;

	file=fopen(name,"wt");

	fprintf(file,"module\n");

	for(j=0;j<order_len;j++)
	{
		if(j==order_loop) fprintf(file,".loop\n");
		fprintf(file,"\tdw .p%2.2x\n",xm[60+20+j]);
	}

	fprintf(file,"\tdw 0\n\tdw .loop\n");

	for(i=0;i<patterns;i++)
	{
		for(j=0;j<8;j++)
		{
			row[j]=0;
			rowp[j]=0;
		}

		pp=60+20+256;
		for(j=0;j<i;j++) pp=pp+read_dword(pp)+read_word(pp+7);

		patlen=read_word(pp+5);
		pp+=read_dword(pp);

		for(j=0;j<patlen;j++)
		{
			for(k=0;k<channels;k++)
			{
				if(xm[pp]&0x80)
				{
					tag=xm[pp++];
					if(tag&0x01) note =xm[pp++]; else note =0;
					if(tag&0x02) ins  =xm[pp++]; else ins  =0;
					if(tag&0x04) vol  =xm[pp++]; else vol  =0;
					if(tag&0x08) fx   =xm[pp++]; else fx   =0;
					if(tag&0x10) param=xm[pp++]; else param=0;
				}
				else
				{
					note =xm[pp++];
					ins  =xm[pp++];
					vol  =xm[pp++];
					fx   =xm[pp++];
					param=xm[pp++];
				}
				if(fx==0x0f)
				{
					if(param<0x20) tempo=param; else bpm=param;
				}
			}
		}

		speed=(int)(2500.0f*(float)tempo*(3500000.0f/1000.0f/cputime)/(float)bpm)+256;
		if(!(speed&0xff)) speed++;

		if(speed<1||speed>65536)
		{
			printf("Warning: Tempo or BPM is out of range (ptn:%2.2x row:%2.2x chn:%i)\n",i,j,k);
		}

		fprintf(file,".p%2.2x\n",i);
		fprintf(file,"\tdw #%4.4x\n",speed);

		pp=60+20+256;
		for(j=0;j<i;j++) pp=pp+read_dword(pp)+read_word(pp+7);

		patlen=read_word(pp+5);
		pp+=read_dword(pp);

		for(j=0;j<patlen;j++)
		{
			drum=0;

			for(k=0;k<channels;k++)
			{
				if(xm[pp]&0x80)
				{
					tag=xm[pp++];
					if(tag&0x01) note =xm[pp++]; else note =0;
					if(tag&0x02) ins  =xm[pp++]; else ins  =0;
					if(tag&0x04) vol  =xm[pp++]; else vol  =0;
					if(tag&0x08) fx   =xm[pp++]; else fx   =0;
					if(tag&0x10) param=xm[pp++]; else param=0;
				}
				else
				{
					note =xm[pp++];
					ins  =xm[pp++];
					vol  =xm[pp++];
					fx   =xm[pp++];
					param=xm[pp++];
				}
				if(k<8)
				{
					row[k]=rowp[k];
					if(note>0&&note<97&&ins==1)
					{
						row[k]=freqtable[note-1];
						if(fx==0x0e&&(param&0xf0)==0x50)
						{
							row[k]+=(param&15)-8;
							if(row[k]<0||row[k]>=240)
							{
								if(row[k]<0) row[k]=0;
								if(row[k]>239) row[k]=239;
								printf("Warning: Note out of range (ptn:%2.2x row:%2.2x chn:%i)\n",i,j,k);
							}
						}
					}
					if(note==97) row[k]=0;
					rowp[k]=row[k];
				}
				if(ins==2)
				{
					switch(note)
					{
					case 49: drum=240; break;//C-4
					case 51: drum=241; break;//D-4
					case 53: drum=242; break;//E-4
					case 54: drum=243; break;//F-4
					case 56: drum=244; break;//G-4
					case 58: drum=245; break;//A-4
					case 60: drum=246; break;//B-4
					case 61: drum=247; break;//C-5
					}
				}
			}

			if(drum) fprintf(file,"\tdb #%2.2x,",drum); else fprintf(file,"\tdb     ");
			fprintf(file,"#%2.2x,#%2.2x,#%2.2x,#%2.2x,#%2.2x,#%2.2x,#%2.2x,#%2.2x\n",row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7]);
		}

		fprintf(file,"\tdb #ff\n");
	}

	fclose(file);

	exit(0);
}