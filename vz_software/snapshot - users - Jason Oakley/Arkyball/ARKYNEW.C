int ball_x, ball_y, x_ball_dir, y_ball_dir, ball_max_y;
int bat_x, bat_y, bat_x_min, bat_x_max, bat_width;
int bbxdx, bbydy;
int brick_x[130], brick_y[130], hitbrick, brickhitno, brick_type[130];
int levelno, silver[70];
int Destructable_Bricks, Bricks_To_Destroy;
int i, j, z, elongate, top, letr;
int hiscore, playerscore, lives;
int bonustime, indestructo, breakout, bottombounce, bonus_bat;
char *mem;
char Level0[130],Level1[130],Level2[130],Level3[130],Level4[130],Level5[130],Level6[130];
char Level7[130],Level8[130],Level9[130],Level10[130],Level11[130],Level12[130],Level13[130];


Init_Intro()
{
	ball_x = 5;
	ball_y = 45;
	bat_x = ball_x-6;
	bat_y = 59;
	bbxdx = 1;
	bbydy = 2;
	top = 14;
	letr = 0;
}

Init_Play()
{
	bat_x = 38 + rand(10);
	bat_y = 62;
	bat_width = 8;
	bat_x_min = 0;
	bat_x_max = 103;
	
	ball_x = bat_x + (bat_width/2);
	ball_y = 60;
	
	draw_gamefield();
	
	Next_Level(levelno);
	
	x_ball_dir = 1;
	y_ball_dir = 1;

	bat_plot(bat_x,bat_y,bat_width);

	/* Hi Score Display */
	Display_Score(26, 24, hiscore, 1);


	/* Player Score Display */
	Display_Score(26, 38, playerscore, 1);


	/* Level No Display */
	Display_Score(27,52,levelno+1, 0);

	score(31 + (32 * 38),0);
	score(31 + (32 * 24),0);
}

Level_Complete()
{
int i,n,x,y,location;
	levelno++;
	if (levelno=13) {
	  levelno=0;}
	Next_Level(levelno);
	ball_erase(ball_x,ball_y);
	bat_x = 38 + rand(10);
	bat_width = 8;
	ball_x = bat_x + (bat_width/2);
	ball_y = 60;
	y_ball_dir = -1;
	x_ball_dir = 1;
	Display_Score(27,52,levelno+1, 0);
}

Next_Level(lev)
int lev;
{
	switch(lev) {
		case 0:  Display_Level(Level0); break;
		case 1:  Display_Level(Level1); break;
		case 2:  Display_Level(Level2); break;
		case 3:  Display_Level(Level3); break;
		case 4:  Display_Level(Level4); break;
		case 5:  Display_Level(Level5); break;
		case 6:  Display_Level(Level6); break;
		case 7:  Display_Level(Level7); break;
		case 8:  Display_Level(Level8); break;
		case 9:  Display_Level(Level9); break;
		case 10: Display_Level(Level10); break;
		case 11: Display_Level(Level11); break;
		case 12: Display_Level(Level12); break;
		case 13: Display_Level(Level13); break;
	}
	NL_Tune();
}

/* Erase brick */
brick_erase(n)
int n;
{
	int location;
	location = (32 * brick_y[n]) + (brick_x[n]/4) + 28672;
	brick(location,0);
}

/* Add more to score and display it */
score_add(value)
int value;
{
	playerscore += value;
	if (playerscore > 32767) playerscore =0;

	/* Player Score Display */
	Display_Score(26, 38, playerscore, 0);
	score(26 + (32 * 38) + 5,0);

	if (playerscore > hiscore) {
		hiscore = playerscore;
		/* Hi Score Display */
		Display_Score(26, 24, hiscore, 0);
		score(26 + (32 * 24) + 5,0);
	}

	if ((playerscore > bonus_bat) && (lives <3)) { lives++; bonus_bat +=2000; }
}


/* Display Number of Lives left */
Display_Lives(life)
int life;
{
	bat_erase(105,60,6);
	bat_erase(113,60,6);
	bat_erase(121,60,6);

	if (life>0) bat_plot(105,60,6);
	if (life>1) bat_plot(113,60,6);
	if (life>2) bat_plot(121,60,6);
}

/* Player Die Routine */
Player_Die(bat_x, bat_y, bat_width)
int bat_x, bat_y, bat_width;
{
	int half_bat, i, w, x, y;
	y = bat_y;
	half_bat = bat_width/2+1;
	/* Shrink Bat */
	for (x=bat_x,w=bat_width;w>0;x++,w -= 2) {
		line(x+1,y,x + w -1, y,1);
		line(x,y+1,x + w, y+1,3);
		plot(x,y,3);
		plot(x+w, y,3);
		plot(x-1,y,0);
		plot(x-1,y+1,0);
		plot(x+w+1,y,0);
		plot(x+w+1,y+1,0);
		for (i=0;i<10;i++) {
			sound(i+200-10*w,2);
		}
	}

	bat_erase(bat_x,bat_y,bat_width);
	/* Explode Bat */
	for (x=0,y=61;x<half_bat;x++,y--) {
		plot(bat_x+half_bat-x,bat_y,3);
		plot(bat_x+half_bat-x,y,3);
		plot(bat_x+half_bat,y,3);
		plot(bat_x+half_bat+x,bat_y,3);
		plot(bat_x+half_bat+x,y,3);
		for (i=0;i<200;i++) {}
		for (i=0;i<20;i++) {
			sound(5+rand(10),1);
		}
		plot(bat_x+half_bat-x,bat_y,0);
		plot(bat_x+half_bat-x,y,0);
		plot(bat_x+half_bat,y,0);
		plot(bat_x+half_bat+x,bat_y,0);
		plot(bat_x+half_bat+x,y,0);
	}
	if (lives) NL_Tune();
	ball_erase(ball_x,ball_y);
	ball_x = bat_x + (bat_width/2);
	ball_y = 60;
	y_ball_dir = -1;
	x_ball_dir = 1;
	bat_plot(bat_x,bat_y,bat_width);
}

/* Score Display Routine */
/* 0<=x<=26 0<=y<=59 0<=n<=32767 */
Display_Score(x, y, n, l)
int x, y, n, l;
{
	int i, location;
	location = (32 * y) + x + 28672;
	if (l) score(location + 5,0);

	for (i = 4; n > 0 && i >= 0; i--)
	{
		location = (32 * y) + x + 28672;
		score(location + i, (n % 10));
		n = n / 10;
	}

}

/* Draw the current Level to the screen */
Display_Level(Lvl)
char *Lvl;
{
	char ltr;
	int i,x,y,location;

	i=0; Destructable_Bricks = 0; Bricks_To_Destroy = 0;
	for (y=0;y<39;y += 4)
	{
		for (x=0;x<26;x += 2)
		{
			brick_type[i] = Lvl[i] -0x30;
			brick_x[i] = x * 4; brick_y[i] = y;
			if ((brick_type[i] < 9) && (brick_type[i] > 0)) Destructable_Bricks++;
			if (brick_type[i] == 8) silver[i] = 3;
			location = (32 * brick_y[i]) + x + 28672;
			brick(location,brick_type[i]);
			i++;
		}
	}
	Bricks_To_Destroy = Destructable_Bricks;
}

draw_gamefield()
{
	int x, y;

	for (y=0;y<16;y++) {
		for (x=0;x<6;x++) {
			poke(28698 + 32 * y + x,85);
		}
	}

	for (y=16;y<23;y++) {
		for (x=0;x<6;x++) {
			poke(28698 + 32 * y + x,255);
		}
	}

	for (y=30;y<37;y++) {
		for (x=0;x<6;x++) {
			poke(28698 + 32 * y + x,255);
		}
	}

	for (y=44;y<51;y++) {
		for (x=0;x<6;x++) {
			poke(28698 + 32 * y + x,255);
		}
	}

	/* Arkaball Logo */
	shape(104,1,8,7,2,"\x08\x08\x14\x14\x3e\x22\x77");
	shape(112,1,8,7,2,"\x06\x02\x6a\x32\x23\x22\x77");
	shape(120,1,8,7,2,"\x00\x00\xcc\x82\x0e\x92\x6d");
	shape(104,9,8,6,3,"\x1e\x09\x0e\x09\x09\x1e");
	shape(112,9,8,6,3,"\x00\x31\x08\x38\x48\x35");
	shape(120,9,8,6,3,"\x88\x98\x88\x88\x88\xdc");

	/* Hi */
	shape(112,17,8,5,1,"\x57\x52\x72\x52\x57");

	/* Score */
	shape(104,31,8,5,1,"\x1d\x11\x1d\x05\x1d");
	shape(112,31,8,5,1,"\xdd\x15\x15\x15\xdd");
	shape(120,31,8,5,1,"\xdc\x50\xd8\x90\x5c");

	/* Level */
	shape(104,45,8,5,1,"\x11\x11\x11\x11\x1d");
	shape(112,45,8,5,1,"\xd5\x15\x95\x15\xc9");
	shape(120,45,8,5,1,"\xd0\x10\x90\x10\xdc");
}

ball_erase(ball_x,ball_y)
int ball_x, ball_y;
{
	plot(ball_x,ball_y,0);
	plot(ball_x+1,ball_y,0);
	plot(ball_x,ball_y+1,0);
	plot(ball_x+1,ball_y+1,0);
}

ball_plot(ball_x,ball_y)
int ball_x, ball_y;
{
	plot(ball_x,ball_y,2);
	plot(ball_x+1,ball_y,2);
	plot(ball_x,ball_y+1,2);
	plot(ball_x+1,ball_y+1,2);
}

bat_erase(bat_x,bat_y, bat_width)
int bat_x,bat_y,bat_width;
{
	line(bat_x,bat_y,bat_x + bat_width,bat_y,0);
	line(bat_x,bat_y+1,bat_x + bat_width,bat_y+1,0);
}

bat_plot(bat_x,bat_y,bat_width)
int bat_x,bat_y,bat_width;
{
	line(bat_x+1,bat_y,bat_x + bat_width -1,bat_y,1);
	line(bat_x,bat_y+1,bat_x + bat_width,bat_y+1,3);
	plot(bat_x,bat_y,3);
	plot(bat_x+bat_width,bat_y,3);
}

/**************************************************************************
* The main loop
**************************************************************************/
main(ac,av)
int ac;
char *av;
{
	int dly;
	/* Define the Levels - Hoo BOY! This is huuuuuge */
	strcpy(Level0,"0000000000000888888888888855555555555554444444444444333333333333322222222222221111111111111");
	strcat(Level0,"000000000000000000000000000000000000000");
	strcpy(Level1,"1000000000000120000000000012300000000001234000000000123450000000012345600000001234567000000");
	strcat(Level1,"123456710000012345671200008888888888883");
	strcpy(Level2,"0000000000000666666666666611111111111115555555555555111111111111144444444444443331111111111");
	strcat(Level2,"222222222222211111111112220000000000000");
	strcpy(Level3,"0765840321760065843017658005843207658400843210658430043218058432003218408432100218430432180");
	strcat(Level3,"018432032184008432102184300432170184320");
	strcpy(Level4,"0001000001000000010001000000088888880000088288828800088888888888008888888888800888888888880");
	strcat(Level4,"080888888808008080000080800000880880000");
	strcpy(Level5,"0000000000000305060706050330506070605033050607060503305060706050330949494949033050607060503");
	strcat(Level5,"305060706050340409040904043050607060503");
	strcpy(Level6,"0000044500000000044556000000044556670000004556677000004556677110000556677112000006677112000");
	strcat(Level6,"000677112200000007112200000000012200000");
	strcpy(Level7,"0009090909000090000000009009909010909900000002000000000909390900000090040090000000005000000");
	strcat(Level7,"099090609099009000000000900009090909000");
	strcpy(Level8,"0000000000000009090009090000939000939000094900094900009990009990000000000000000000511160000");
	strcat(Level8,"000052226000000005333600000000544460000");
	strcpy(Level9,"0000000000000000000000000000900000200000090000212000009000213120000900213831200090002131200");
	strcat(Level9,"009000021200000900000200000099999999999");
	strcpy(Level10,"0000000000000088888888888008000000000800808888888080080800000808008080888080800808000008080");
	strcat(Level10,"080888888808008000000000800888888888880");
	strcpy(Level11,"9999999999999000090000090009109009009000900900900920090395090690009009009009000900904900900");
	strcat(Level11,"092090090090009000009000070999999999999");
	strcpy(Level12,"0000000000000077701110777006660222066600555033305550044404440444003330555033300222066602220");
	strcat(Level12,"011107770111000000000000000000000000000");
	
	asm("di\n");
	mem = 0;

	hiscore = 2000;

	setbase(0x7000);

	for (;;) {

		Funky_Intro();

		levelno = 0;

		playerscore = 0;

		lives = 3;

		mode(1);

		Init_Play();

		Display_Lives(lives);

		x_ball_dir = 1;
		y_ball_dir = 1;


		do {

			Ball_Move();

			Ball_Bounce();

			Brick_Bounce();

			Bat_Move();

			Bat_Move();

			for (dly=0;dly<200;dly++) {};

		} while (lives);

		ball_erase(ball_x,ball_y);
		draw_string(27, 40, 3, "G m  O e ");
		draw_string(27, 40, 1, " a e  v r");
		GO_Tune();
		for (j=0;j<100;j++) {dly = 50;
			do {
				dly--;
			} while(dly);
		};
	}
}

Ball_Bounce()
{
	/* Ball hit sides or top? */
	if ((ball_x + x_ball_dir <0) || (ball_x + x_ball_dir >102)) {x_ball_dir = -x_ball_dir; sound(25,7);}
	if (ball_y + y_ball_dir <0) {y_ball_dir = -y_ball_dir; sound(25,7);}

	/* Ball hit bat? */
	if ((ball_y == 60) && (ball_x > bat_x -1) && (ball_x < bat_x + bat_width )) {y_ball_dir = -1; sound(75,15);}

	/* Hit edge of bat? */
	if ((ball_y == 60) && ((ball_x == bat_x - 1) || (ball_x == bat_x -2))) {
		if (ball_x<100) {	ball_erase(ball_x,ball_y);ball_x-=2; }
		y_ball_dir = -1;
		x_ball_dir = -1;
		sound(75,15);
	}
	if ((ball_y == 60) && ((ball_x == bat_x + bat_width ) || (ball_x == bat_x + bat_width +1))) {
		if (ball_x>2) { ball_erase(ball_x,ball_y);ball_x+=2;}
		y_ball_dir = -1;
		x_ball_dir = +1;
		sound(75,15);
	}
	/* Oops! Dropped the ball! */
	if (ball_y > 60) {
	  ball_erase(ball_x,ball_y);
	  lives--; Display_Lives(lives);
	  Player_Die(bat_x, bat_y, bat_width);
	}
}

Brick_Bounce()
{
	int startscan;
	if (ball_y <=6) startscan = 0;
	if ((ball_y > 6) && (ball_y <=10)) startscan = 13;
	if ((ball_y >10) && (ball_y <=14)) startscan = 26;
	if ((ball_y >14) && (ball_y <=18)) startscan = 39;
	if ((ball_y >18) && (ball_y <=22)) startscan = 52;
	if ((ball_y >22) && (ball_y <=26)) startscan = 65;
	if ((ball_y >26) && (ball_y <=30)) startscan = 78;
	if ((ball_y >30) && (ball_y <=34)) startscan = 91;
	if ((ball_y >34) && (ball_y <=38)) startscan = 104;
	if (ball_y >38) startscan = 117;

	/* Hit a brick? */
	for (z=startscan;z<startscan+27;z++) {

		if (brick_type[z]) {


			/* Hit bottom-left of brick? */
			 if ((ball_y - 1 == brick_y[z] + 2) && (ball_x + 2 == brick_x[z]))
				{ hitbrick = 1;
					brickhitno = z;
			  y_ball_dir = +1; x_ball_dir = -1;
			  ball_erase(ball_x,ball_y); ball_y += y_ball_dir; ball_x += x_ball_dir;
			  }


			/* Hit bottom-right of brick? */
			 if ((ball_y - 1 == brick_y[z] + 2) && (ball_x == brick_x[z] + 7))
				{ hitbrick = 1;
					brickhitno = z;
			  y_ball_dir = +1; x_ball_dir = +1;
			  ball_erase(ball_x,ball_y); ball_y += y_ball_dir; ball_x += x_ball_dir;
			  }

		       /* Hit top-left of brick? */
			  if ((ball_y +2 == brick_y[z]) && (ball_x + 3 == brick_x[z]))
				{ hitbrick = 1;
					brickhitno = z;
			  y_ball_dir = -1; x_ball_dir = -1;
			  ball_erase(ball_x,ball_y); ball_y += y_ball_dir; ball_x += x_ball_dir;
			  }

			/* Hit top-right of brick? */
			  if ((ball_y +2 == brick_y[z]) && (ball_x == brick_x[z] + 7))
				{ hitbrick = 1;
					brickhitno = z;
			  y_ball_dir = -1; x_ball_dir = +1;
			  ball_erase(ball_x,ball_y); ball_y += y_ball_dir; ball_x += x_ball_dir;
			  }

			/* Hit bottom of Brick?  */
			  if ((ball_y - 1 == brick_y[z] + 2) && (ball_x + 3 > brick_x[z]) && (ball_x < brick_x[z] + 7))
				{ hitbrick = 1;
					brickhitno = z;
			  y_ball_dir = +1;
			  ball_erase(ball_x,ball_y); ball_y += y_ball_dir;
			  }


			/* Hit Left of Brick? */
			if (!hitbrick) {
			  if ((ball_x + 2 == brick_x[z]) && (ball_y + 1 > brick_y[z]) && (ball_y < brick_y[z] + 3))
				{ hitbrick = 1;
					brickhitno = z;
			  x_ball_dir = -1;
			  ball_erase(ball_x,ball_y); ball_x += x_ball_dir;
			  }
			  }


			/* Hit right of Brick? */
			if (!hitbrick) {
			  if ((ball_x - 1 == brick_x[z] + 6) && (ball_y + 3 > brick_y[z]) && (ball_y < brick_y[z] + 3))
				{ hitbrick = 1;
					brickhitno = z;
			  x_ball_dir = +1;
			  ball_erase(ball_x,ball_y); ball_x += x_ball_dir;
			  }
			  }

			/* Hit top of Brick? */
			if (!hitbrick) {
			  if ((ball_y + 1 == brick_y[z]) && (ball_x + 3 > brick_x[z]) && (ball_x < brick_x[z] + 7))
				{ hitbrick = 1;
					brickhitno = z;
			  y_ball_dir = -1;
			  ball_y += y_ball_dir; ball_erase(ball_x,ball_y);
			  }
			  }

		}
	}

	if (hitbrick)	{ hitbrick = 0;

		if (brick_type[brickhitno] == 9) sound(120,10);
		if (brick_type[brickhitno] == 8) {
			silver[brickhitno]--;
			if (!silver[brickhitno]) {
				score_add(12);
				brick_erase(brickhitno);
				brick_type[brickhitno] = 0;
				Bricks_To_Destroy--;
				if (!Bricks_To_Destroy) {
				   bat_erase(bat_x,bat_y);
				   ball_erase(ball_x,ball_y);
				  Level_Complete();
				}
				sound(100,12);
			}
			else { sound(130,10); }
		}

		if ((brick_type[brickhitno]  < 8) && (brick_type[brickhitno] > 0)) {
			brick_erase(brickhitno);
			Bricks_To_Destroy--;
				if (!Bricks_To_Destroy) {
				   bat_erase(bat_x,bat_y);
				   ball_erase(ball_x,ball_y);
				  Level_Complete();
				}
		}
		/* Rand bonuses go in here */
		switch(brick_type[brickhitno]) {
			case 1: { score_add(3);  sound(50,15); brick_type[brickhitno] = 0; break;}
			case 2: { score_add(4);  sound(50,15); brick_type[brickhitno] = 0; break;}
			case 3: { score_add(5);  sound(50,15); brick_type[brickhitno] = 0; break;}
			case 4: { score_add(6);  sound(50,15); brick_type[brickhitno] = 0; break;}
			case 5: { score_add(7);  sound(50,15); brick_type[brickhitno] = 0; break;}
			case 6: { score_add(8);  sound(50,15); brick_type[brickhitno] = 0; break;}
			case 7: { score_add(9);  sound(50,15); brick_type[brickhitno] = 0; break;}
		}

	}
}

Ball_Move()
{
	ball_erase(ball_x,ball_y);

	ball_x += x_ball_dir;
	ball_y += y_ball_dir;

	ball_plot(ball_x,ball_y);
}

Bat_Move()
{
	if ((mem[0x68ef] & 0x20) == 0)	/* left (M) ? */
	{
		if (bat_x > bat_x_min) {
			bat_erase(bat_x,bat_y,bat_width);
			bat_x--;
			bat_plot(bat_x,bat_y,bat_width);
		}
	}
	else
	if ((mem[0x68ef] & 0x08) == 0)	/* right (,) ? */
	{
		if (bat_x < bat_x_max - bat_width) {
			bat_erase(bat_x,bat_y,bat_width);
			bat_x++;
			bat_plot(bat_x,bat_y,bat_width);
		}
	}
	else
	if ((mem[0x68bf] & 0x10) == 0)	/* pause (p) ? */
	{
	  do { }
	  while ((mem[0x68ef] & 0x10) != 0);  /* unpause (spc) ? */
	  }
	if ((mem[0x68fe] & 0x10) == 0)	/* quit (q) ? */
	{
	  lives = 0;
	}
}

Funky_Intro()
{
	int x,y,bbb,dly,start;
	mode(1);
	
	Init_Intro();
	
	/* Draw blocks */
	for (x=8;x<111;x+=14)
	{
		line(x,top,x+12,top,2);
		line(x,top,x,top+11,2);
		line(x,top+12,x+12,top+12,2);
		line(x+12,top,x+12,top+12,2);
	}
	
	for (x=10;x<110;x+=14)
	{
		for (y=top+2;y<top+11;y++)
		{
			line(x,y,x+8,y,2);
		}
	}
	start = 0;
	for (bbb=0;bbb<243;bbb++) {
		if ((inch() != 'S') && (!start)) ball_Bounce();
		else start =1;
	}
	shape(bat_x,61,16,3,0,"\xff\xff\xff\xff\xff\xff");
	shape(ball_x,ball_y,4,4,0,"\xff\xff\xff\xff");
	draw_string(19, 32, 3, "By Jason Oakley");
	draw_string(17, 42, 2, "Press S to Start");
	draw_string(40, 52, 1, "(C) 2000");
	do
	{
	} while ((inch() != 'S') && (!start));
}


ball_Bounce()
{
	int dly;
	shape(ball_x,ball_y,4,4,0,"\xff\xff\xff\xff");

	if (ball_x > 123) { bbxdx = -bbxdx; sound(25,7);}
	if (ball_y > 55) { bbydy = -bbydy;
		if (ball_x > 10) {sound(120,10);}
	}
	if (ball_y < top+14) { bbydy = -bbydy;
		for (dly=100;dly>70;dly--) {sound(dly,1);}
		letr++;
	Show_Letter(letr); }
	
	ball_x +=bbxdx;
	ball_y +=bbydy;
	
	plot(ball_x+1,ball_y,2);
	plot(ball_x+2,ball_y,2);
	plot(ball_x,ball_y+1,2);
	plot(ball_x+1,ball_y+1,2);
	plot(ball_x+2,ball_y+1,1);
	plot(ball_x+3,ball_y+1,2);
	plot(ball_x,ball_y+2,2);
	plot(ball_x+1,ball_y+2,2);
	plot(ball_x+2,ball_y+2,2);
	plot(ball_x+3,ball_y+2,2);
	plot(ball_x+1,ball_y+3,2);
	plot(ball_x+2,ball_y+3,2);
	
	bat_Move();
	for (j=0;j<500;j++) {};
}



bat_Move()
{
	shape(bat_x,61,16,3,0,"\xff\xff\xff\xff\xff\xff");
	if ((ball_x <117) && (ball_x > 5)) bat_x = ball_x-6;
	
	shape(bat_x,61,16,1,1,"\x3f\xfe");
	shape(bat_x,62,16,2,3,"\x7f\xff\x7f\xff");
	plot(bat_x+1,61,3);
	plot(bat_x+15,61,3);
}

Show_Letter(lett)
int lett;
{
	switch(lett) {
		case 1: {shape(24,top+3,8,7,1,"\x7c\x22\x22\x3c\x24\x22\x73"); break;}
		case 2: {shape(52,top+3,8,7,1,"\x08\x08\x14\x14\x3e\x22\x77"); break;}
		case 3: {shape(80,top+3,8,7,1,"\x08\x08\x14\x14\x3e\x22\x77"); break;}
		case 4: {shape(108,top+3,8,7,1,"\x70\x20\x20\x20\x20\x21\x7f"); break;}
		case 5: {shape(94,top+3,8,7,1,"\x70\x20\x20\x20\x20\x21\x7f"); break;}
		case 6: {shape(66,top+3,8,7,1,"\x7c\x22\x22\x3e\x21\x21\x7e"); break;}
		case 7: {shape(38,top+3,8,7,1,"\x77\x22\x24\x38\x24\x22\x77"); break;}
		case 8: {shape(10,top+3,8,7,1,"\x08\x08\x14\x14\x3e\x22\x77"); break;}
	}
}

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

GO_Tune()
{
	int dely;
	sound(160,50);
	sound(190,50);
	sound(175,50);
	sound(160,50);
	for (dely=0;dely<200;dely++) {};
	sound(180,50);
	sound(210,50);
	sound(195,50);
	sound(180,50);
	for (dely=0;dely<200;dely++) {};
	sound(240,50);
	for (dely=0;dely<30;dely++) {};
	sound(240,50);
	for (dely=0;dely<30;dely++) {};
	sound(240,50);
	for (dely=0;dely<30;dely++) {};
	sound(240,150);
}

NL_Tune()
{
	int dely;
	sound(200,50);
	for (dely=0;dely<1000;dely++) {};
	sound(200,50);
	
	sound(170,150);
	for (dely=0;dely<1000;dely++) {};
	sound(170,50);
	
	sound(180,50);
	
	sound(210,50);
	
	sound(180,50);
	
	sound(200,150);
}
