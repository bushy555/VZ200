/* VZetris by Geoff Williams (c) 1997-2002  Version 3.0 */
/*     Written on a real VZ300, ported to QBasic, now   */
/*     ported to zcc/smallC for vzem 2.0                */
/*     Thanks to Peter Bergt for debugging QBasic port. */
/*                                                      */
/* functions:                                           */
/* main()                            gameloop           */
/* drawshape3() 3 different versions|paint the shape    */
/* title()                           paint title text   */
/* getelem(startptr,shape,rot,elem)  get shape element  */
/*                                                      */
/*                                                      */
/*                                                      */
/* can't poke a single byte, it pokes two at once! FIXED*/
/* unstable: screen buffering code in progress: forgetit*/
/* TODO: Add 'Next shape' routine                       */

#define SCRSIZE 2048
/* char scr[128*64]; */
char *mem;
/*int base;
char *base;*/
int scanx,scany,scan_count;

main(argc, argv)
int argc;
int *argv;
{
int count,i, j, jj, x, y,x1,y1,test,dd,yy;
char *point;
        int shape,rot,elem,delay,loop,loopi,downcol;
        char data;
        char d[700];
        char c;
int lcol,rcol;
int score,hiscore,the_delay;




/***********************/
score=0;
/*base=&scr[0];*/

d[0]='0';d[1]='3';d[2]='1';d[3]='4';d[4]='0';d[5]='0';d[6]='3';d[7]='1';d[8]='4';
d[9]='0';d[10]='0';d[11]='3';d[12]='1';d[13]='4';d[14]='0';d[15]='0';d[16]='3';
d[17]='2';d[18]='4';d[19]='0';d[20]='3';d[21]='1';d[22]='1';d[23]='1';d[24]='4';
d[25]='3';d[26]='2';d[27]='2';d[28]='2';d[29]='4';d[30]='0';d[31]='0';d[32]='0';

/*

d[33]='0';d[34]='0';d[35]='0';d[36]='0';d[37]='0';d[38]='0';d[39]='0';d[40]='0';
d[41]='3';d[42]='1';d[43]='4';d[44]='0';d[45]='0';d[46]='3';d[47]='1';d[48]='4';
d[49]='0';d[50]='0';d[51]='3';d[52]='1';d[53]='4';d[54]='0';d[55]='0';d[56]='3';
d[57]='2';d[58]='4';d[59]='0';d[60]='3';d[61]='1';d[62]='1';d[63]='1';d[64]='4';
d[65]='3';d[66]='2';d[67]='2';d[68]='2';d[69]='4';d[70]='0';d[71]='0';d[72]='0';
d[73]='0';d[74]='0';d[75]='0';d[76]='0';d[77]='0';d[78]='0';d[79]='0';d[80]='3';
d[81]='1';d[82]='1';d[83]='4';d[84]='0';d[85]='3';d[86]='1';d[87]='2';d[88]='4';
d[89]='0';d[90]='3';d[91]='1';d[92]='4';d[93]='0';d[94]='0';d[95]='3';d[96]='2';
d[97]='4';d[98]='0';d[99]='0';d[100]='3';d[101]='1';d[102]='1';d[103]='1';d[104]='4';
d[105]='3';d[106]='2';d[107]='2';d[108]='1';d[109]='4';d[110]='0';d[111]='0';
d[112]='3';d[113]='2';d[114]='4';d[115]='0';d[116]='0';d[117]='0';d[118]='0';
d[119]='0';d[120]='0';d[121]='0';d[122]='3';d[123]='1';d[124]='4';d[125]='0';
d[126]='0';d[127]='3';d[128]='1';d[129]='4';d[130]='0';d[131]='3';d[132]='1';
d[133]='1';d[134]='4';d[135]='0';d[136]='3';d[137]='2';d[138]='2';d[139]='4';
d[140]='0';d[141]='0';d[142]='0';d[143]='0';d[144]='0';d[145]='3';d[146]='1';
d[147]='4';d[148]='0';d[149]='0';d[150]='3';d[151]='1';d[152]='1';d[153]='1';
d[154]='4';d[155]='3';d[156]='2';d[157]='2';d[158]='2';d[159]='4';d[160]='0';
d[161]='3';d[162]='1';d[163]='1';d[164]='4';d[165]='0';d[166]='3';d[167]='2';
d[168]='1';d[169]='4';d[170]='0';d[171]='0';d[172]='3';d[173]='1';d[174]='4';
d[175]='0';d[176]='0';d[177]='3';d[178]='2';d[179]='4';d[180]='0';d[181]='0';
d[182]='0';d[183]='0';d[184]='0';d[185]='0';d[186]='0';d[187]='3';d[188]='1';
d[189]='4';d[190]='3';d[191]='1';d[192]='1';d[193]='1';d[194]='4';d[195]='3';
d[196]='2';d[197]='2';d[198]='2';d[199]='4';d[200]='3';d[201]='1';d[202]='4';
d[203]='0';d[204]='0';d[205]='3';d[206]='1';d[207]='4';d[208]='0';d[209]='0';
d[210]='3';d[211]='1';d[212]='1';d[213]='4';d[214]='0';d[215]='3';d[216]='2';
d[217]='2';d[218]='4';d[219]='0';d[220]='3';d[221]='1';d[222]='1';d[223]='1';
d[224]='4';d[225]='3';d[226]='1';d[227]='2';d[228]='2';d[229]='4';d[230]='3';
d[231]='2';d[232]='4';d[233]='0';d[234]='0';d[235]='0';d[236]='0';d[237]='0';
d[238]='0';d[239]='0';d[240]='3';d[241]='1';d[242]='1';d[243]='1';d[244]='4';
d[245]='3';d[246]='2';d[247]='1';d[248]='2';d[249]='4';d[250]='0';d[251]='3';
d[252]='2';d[253]='4';d[254]='0';d[255]='0';d[256]='0';d[257]='0';d[258]='0';
d[259]='0';d[260]='0';d[261]='0';d[262]='3';d[263]='1';d[264]='4';d[265]='0';
d[266]='3';d[267]='1';d[268]='1';d[269]='4';d[270]='0';d[271]='3';d[272]='2';
d[273]='1';d[274]='4';d[275]='0';d[276]='0';d[277]='3';d[278]='2';d[279]='4';
d[280]='0';d[281]='0';d[282]='0';d[283]='0';d[284]='0';d[285]='0';d[286]='3';
d[287]='1';d[288]='4';d[289]='0';d[290]='3';d[291]='1';d[292]='1';d[293]='1';
d[294]='4';d[295]='3';d[296]='2';d[297]='2';d[298]='2';d[299]='4';d[300]='3';
d[301]='1';d[302]='0';d[303]='0';d[304]='0';d[305]='3';d[306]='1';d[307]='1';
d[308]='4';d[309]='0';d[310]='3';d[311]='1';d[312]='2';d[313]='4';d[314]='0';
d[315]='3';d[316]='2';d[317]='4';d[318]='0';d[319]='0';d[320]='0';d[321]='0';
d[322]='0';d[323]='0';d[324]='0';d[325]='0';d[326]='3';d[327]='1';d[328]='1';
d[329]='4';d[330]='3';d[331]='1';d[332]='1';d[333]='4';d[334]='4';d[335]='3';
d[336]='2';d[337]='2';d[338]='4';d[339]='0';d[340]='0';d[341]='3';d[342]='1';
d[343]='4';d[344]='0';d[345]='0';d[346]='3';d[347]='1';d[348]='1';d[349]='4';
d[350]='0';d[351]='3';d[352]='2';d[353]='1';d[354]='4';d[355]='0';d[356]='0';
d[357]='3';d[358]='2';d[359]='4';d[360]='0';d[361]='0';d[362]='0';d[363]='0';
d[364]='0';d[365]='0';d[366]='3';d[367]='1';d[368]='1';d[369]='4';d[370]='3';
d[371]='1';d[372]='1';d[373]='2';d[374]='4';d[375]='3';d[376]='2';d[377]='2';
d[378]='4';d[379]='0';d[380]='0';d[381]='3';d[382]='1';d[383]='4';d[384]='0';
d[385]='0';d[386]='3';d[387]='1';d[388]='1';d[389]='4';d[390]='0';d[391]='3';
d[392]='2';d[393]='1';d[394]='4';d[395]='0';d[396]='0';d[397]='3';d[398]='2';
d[399]='4';d[400]='3';d[401]='1';d[402]='1';d[403]='4';d[404]='0';d[405]='3';
d[406]='2';d[407]='1';d[408]='1';d[409]='4';d[410]='0';d[411]='3';d[412]='2';
d[413]='2';d[414]='4';d[415]='0';d[416]='0';d[417]='0';d[418]='0';d[419]='0';
d[420]='0';d[421]='0';d[422]='3';d[423]='1';d[424]='4';d[425]='0';d[426]='3';
d[427]='1';d[428]='1';d[429]='4';d[430]='0';d[431]='3';d[432]='1';d[433]='2';
d[434]='4';d[435]='0';d[436]='3';d[437]='2';d[438]='4';d[439]='0';d[440]='3';
d[441]='1';d[442]='1';d[443]='4';d[444]='0';d[445]='3';d[446]='2';d[447]='1';
d[448]='1';d[449]='4';d[450]='0';d[451]='3';d[452]='2';d[453]='2';d[454]='4';
d[455]='0';d[456]='0';d[457]='0';d[458]='0';d[459]='0';d[460]='0';d[461]='0';
d[462]='3';d[463]='1';d[464]='4';d[465]='0';d[466]='3';d[467]='1';d[468]='1';
d[469]='4';d[470]='0';d[471]='3';d[472]='1';d[473]='2';d[474]='4';d[475]='0';
d[476]='3';d[477]='2';d[478]='4';d[479]='0';d[480]='3';d[481]='1';d[482]='1';
d[483]='4';d[484]='0';d[485]='3';d[486]='1';d[487]='1';d[488]='4';d[489]='0';
d[490]='3';d[491]='2';d[492]='2';d[493]='4';d[494]='0';d[495]='0';d[496]='0';
d[497]='0';d[498]='0';d[499]='0';d[500]='3';d[501]='1';d[502]='1';d[503]='4';
d[504]='0';d[505]='3';d[506]='1';d[507]='1';d[508]='4';d[509]='0';d[510]='3';
d[511]='2';d[512]='2';d[513]='4';d[514]='0';d[515]='0';d[516]='0';d[517]='0';
*/

/*
d[518]='00311403114032240000003114031140322400000000314031140322400000031400311403224000000311403124032400000003114032140032400000';
*/
/*
d[518]='0';d[519]='0';d[520]='3';d[521]='1';d[522]='1';d[523]='4';d[524]='0';
d[525]='3';d[526]='1';d[527]='1';d[528]='4';d[529]='0';d[530]='3';d[531]='2';
d[532]='2';d[533]='4';d[534]='0';d[535]='0';d[536]='0';d[537]='0';d[538]='0';
d[539]='0';d[540]='3';d[541]='1';d[542]='1';d[543]='4';d[544]='0';d[545]='3';
d[546]='1';d[547]='1';d[548]='4';d[549]='0';d[550]='3';d[551]='2';d[552]='2';
d[553]='4';d[554]='0';d[555]='0';d[556]='0';d[557]='0';d[558]='0';d[559]='0';
d[560]='0';d[561]='0';d[562]='3';d[563]='1';d[564]='4';d[565]='0';d[566]='3';
d[567]='1';d[568]='1';
*/

/*
d[569]='4';d[570]='0';d[571]='3';d[572]='2';d[573]='2';
d[574]='4';d[575]='0';d[576]='0';d[577]='0';d[578]='0';d[579]='0';d[580]='0';
d[581]='3';d[582]='1';d[583]='4';d[584]='0';d[585]='0';d[586]='3';d[587]='1';
d[588]='1';d[589]='4';d[590]='0';d[591]='3';d[592]='2';d[593]='2';d[594]='4';
d[595]='0';d[596]='0';d[597]='0';d[598]='0';d[599]='0';d[600]='0';d[601]='3';
d[602]='1';d[603]='1';d[604]='4';d[605]='0';d[606]='3';d[607]='1';d[608]='2';
d[609]='4';d[610]='0';
*/

/*
d[611]='3';d[612]='2';d[613]='4';d[614]='0';d[615]='0';
d[616]='0';d[617]='0';d[618]='0';d[619]='0';d[620]='0';d[621]='3';d[622]='1';
d[623]='1';d[624]='4';d[625]='0';d[626]='3';d[627]='2';d[628]='1';d[629]='4';
d[630]='0';d[631]='0';
*/

/*
d[632]='3';d[633]='2';d[634]='4';d[635]='0';d[636]='0';
d[637]='0';d[638]='0';d[639]='0';   
*/


/******************************* Shape data ****************************************/
/* A=no dot; B=dot; C=down collision point ; D=left col; E=right col               */ 
/* This is for shapes made from a 5x4 grid, 8 shapes, 4 rotations, 20 elements(5x4)*/
data='ADBEAADBEAADBEAADCEADBBBEDCCCEAAAAAAAAAAADBEAADBEAADBEAADCEADBBBEDCCCEAAAAA';
data+='AAAAADBBEADBCEADBEAADCEAADBBBEDCCBEAADCEAAAAAAADBEAADBEADBBEADCCEAAAAADBEA';
data+='ADBBBEDCCCEADBBEADCBEAADBEAADCEAAAAAAADBEDBBBEDCCCEDBEAADBEAADBBEADCCEADBB';
data+='BEDBCCEDCEAAAAAAADBBBEDCBCEADCEAAAAAAAADBEADBBEADCBEAADCEAAAAAADBEADBBBEDC';
data+='CCEDBAAADBBEADBCEADCEAAAAAAAADBBEDBBEEDCCEAADBEAADBBEADCBEAADCEAAAAAADBBED';
data+='BBCEDCCEAADBEAADBBEADCBEAADCEDBBEADCBBEADCCEAAAAAAADBEADBBEADBCEADCEADBBEA';
data+='DCBBEADCCEAAAAAAADBEADBBEADBCEADCEADBBEADBBEADCCEAAAAAADBBEADBBEADCCEAAAAA';
data+='ADBBEADBBEADCCEAAAAAADBBEADBBEADCCEAAAAAAAADBEADBBEADCCEAAAAAADBEAADBBEADC';
data+='CEAAAAAADBBEADBCEADCEAAAAAAADBBEADCBEAADCEAAAAA';





	x=0;y=1;dd=5;	
        shape=0;rot=0;
	mode(0);
	printf("\n\n\n\n\n\n\n\n   WELCOME TO VZETRIS\n");
	




	printf("- PRESS ANY KEY TO START -\n");
	getch();
	while(inch())
        ;
	rand(0);
        mode(1);
        
asm("di\n");






/*setbase(scr);
 clean up */

for (dd=0;dd<=60;dd++) {
line (0,dd,127,dd,0);
}

/* frame */

for (dd=60;dd<=63;dd++) {
line (0,dd,127,dd,1);
}
for (dd=30;dd<=31;dd++) {
line (dd,0,dd,60,1);
}
for (dd=96;dd<=97;dd++) {
line (dd,0,dd,60,1);
}

title();
/*soundcopy(0x7000,scr,SCRSIZE,0,0);
setbase(0x7000);*/



/* Main Loop */

for (loopi=1;loopi<500;loopi++) {

i=28672+128; /*  Screen start address*/
/*i=base;     buffer start address*/
x=i+13;
shape=rand(7);rot=0;
if (shape==6) {rot=1;} /* Hack to fix shape[0] */
count=0;
the_delay=2000;
title();
for (loop=1;loop<55;loop++) {
 
/*   j=drawshape3(x,shape,rot); */


/*setbase(scr);*/ 
  elem=0;
for (y1=0;y1<=3;y1++) {
  for (x1=0;x1<=4;x1++) {
     
          c=d[(shape*80)+(rot*20)+elem];
          if (c == '1') {
             point=x+x1+128*y1;
             *point=255;
             point=x+x1+128*y1+32;
             *point=235;
             point=x+x1+128*y1+64;
             *point=235;
             point=x+x1+128*y1+96;
             *point=255;
          }
 


     elem++;          
     }      
  }
/* *base=255; */
/*soundcopy(0x7000,scr,SCRSIZE,0,0);*/


  for (delay=0;delay<the_delay;delay++) {/*time delay*/}
  for (delay=0;delay<5;delay++) { /*get keypress*/

    jj=inch();
    if (jj != 0) {j=jj;}

}
 if (j==66) {mode(0);printf ("%d \n",shape);for (delay=0;delay<50000;delay++) {}; }
  elem=0;
   for (y1=0;y1<=3;y1++) {
      for (x1=0;x1<=4;x1++) {
          c=d[(shape*80)+(rot*20)+elem];
          if (c == '1') {
            for (yy=0;yy<=96;yy+=32) {
              point=x+x1+128*y1+yy;
              *point=0;
            }
          }
      elem++;         
      }
   }

/*  scan for collision    */
  elem=0;
  downcol=0;
for (y1=0;y1<=3;y1++) {
  for (x1=0;x1<=4;x1++) {
     
          c=d[(shape*80)+(rot*20)+elem];
          point=x+x1+128*y1;
          if (c == '2' && *point != 0) {
            downcol=1;
          }
          if (c == '3' && *point != 0) {
            lcol=1;
          }
          if (c == '4' && *point != 0) {
            rcol=1;
          }

     elem++;          
     }      
  }

  if (downcol==1) {
the_delay=2000;
score+=10;
draw_score(score);
/* leave block on */
  elem=0;
for (y1=0;y1<=3;y1++) {
  for (x1=0;x1<=4;x1++) {
     
          c=d[(shape*80)+(rot*20)+elem];
          if (c == '1') {
             point=x+x1+128*y1;
             *point=255;
             point=x+x1+128*y1+32;
             *point=235;
             point=x+x1+128*y1+64;
             *point=235;
             point=x+x1+128*y1+96;
             *point=255;
          }
     elem++;          
     }      
  }
  loop=55;

  if (count==0) {
     if (score>hiscore) {
        hiscore=score;
        draw_hiscore(hiscore);
        for (dd=99;dd<=127;dd++) {line(dd,16,dd,30,0);}
     }
     score=0;    
     gameover();
   }



}

/* Scan for completed row */

scan_count=0;
for (scany=0;scany<=14;scany++) {
  for (scanx=0;scanx<=15;scanx++) {

    point=28680+scanx+scany*128;
    if (*point != 0) {scan_count++;}
  }
  if (scan_count==16) {flow(scany);}
  scan_count=0;
}



if (j==65){rot+=1;}
if (rot==4 && shape==6) {rot=1;}
if (rot==4) {rot=0;}

    if (j==44 && lcol==0){x-=1;}
    if (j==46 && rcol==0){x+=1;}
    if (j==90) {the_delay=0;}
    j=0;lcol=0;rcol=0;
                                  /*test=x+512;  *test == 0 && */


x+=128;count++; /* MOVE SHAPE DOWN ONE ROW */ 

} /*end loop*/

} /*end loopi*/
} /*end main*/

flow(y) 
int y;
{
int p;
int scany;
char *point;
char *scanx;
int c,delay,count;
/* flash completed row and remove it */

 for (c=0;c<=4;c++) {
  p=28680;
  
  for (scanx=0;scanx<=15;scanx++) {
    point=p+scanx+128*y;
    *point=255;*(point+32)=235;*(point+64)=235;*(point+96)=255;
  }
  for (scanx=0;scanx<=15;scanx++) {
    point=p+scanx+128*y;
    *point=0;*(point+32)=0;*(point+64)=0;*(point+96)=0;
  }
 }

/* this scroll code does not work it crashes vzem */

/* for (scany=y*128;scany>=0;scany-=32) {  */
 /*  for (scanx=0;scanx<=15;scanx++) { */
      for (delay=0;delay<100;delay++) {/*time delay*/}
      /* *(p+32*scany+scanx)=*(p+32*scany+32+scanx); */
     /* memcpy(p+32*scany,p+32*scany+32,32); */
  /* }  */
/* } */

/* this scroll works */

 for (c=0;c<=3;c++) { 
   count=0;
   for (scanx=28672+y*128+128+22-32;scanx>=28672+32;scanx--) {
      *scanx=*(scanx-32);
      count++;
      if (count==15) {scanx-=17;count=0;}      
   }
 }




return (0);

}

gameover() {

int d,c,scanx,count,delay;

for (d=0;d<=14;d++) {
 for (c=0;c<=3;c++) { 
   count=0;
   for (scanx=28672+14*128+128+22-32;scanx>=28672+32;scanx--) {
      *scanx=*(scanx-32);
      count++;
      if (count==15) {scanx-=17;count=0;}      
   }
  }
 }

/*exit(1);*/

draw_string(50,25,2,"GAME");
draw_string(50,37,2,"OVER");

for (delay=0;delay<3000;delay++) {/*time delay*/}

for (d=0;d<=14;d++) {
 for (c=0;c<=3;c++) { 
   count=0;
   for (scanx=28672+14*128+128+22-32;scanx>=28672+32;scanx--) {
      *scanx=*(scanx-32);
      count++;
      if (count==15) {scanx-=17;count=0;}      
   }
  }
 }



}

title () {

/******plot VZETRIS name *****/
char_draw(0, 10, 1, 86);
char_draw(0, 16, 2, 90);
char_draw(5, 18, 3, 69);
char_draw(10, 20, 1, 84);
char_draw(14, 22, 2, 82);
char_draw(18, 25, 3, 73);
char_draw(23, 27, 1, 83);
/*VZETRIS=ASCII{86906984827383} */

draw_string(99,10,3,"Score");
draw_string(99,40,2,"High");
draw_string(99,46,2,"Score");
}

getelem(shape,rot,elem) 
int shape,rot,elem;
  {
     /*return d[(shape*80)+(rot*20)+elem];*/
  } /*end getelem()*/


draw_string(x,y,color,src)
int x,y,color;
char *src;
{
	while (*src)
	{
		char_draw(x,y,color,*src);
		x += 6;
		src++;
	}
}

draw_score(add)
int add;
{
 

   int i, n;
    n = add;

	for (i = 4; n > 0 && i >= 0; i--)
    {
		char_draw(99+i*6, 17, 0, 0x7f);	
		char_draw(99+i*6, 17, 3, 0x30 + (n % 10));
        n = n / 10;
    }
	
}

draw_hiscore(add)
int add;
{
 

   int i, n;
    n = add;

	for (i = 4; n > 0 && i >= 0; i--)
    {
		char_draw(99+i*6, 53, 0, 0x7f);	
		char_draw(99+i*6, 53, 2, 0x30 + (n % 10));
        n = n / 10;
    }
	
}