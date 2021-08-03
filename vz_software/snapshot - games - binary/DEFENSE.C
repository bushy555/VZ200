#define ENEMY_MAX			8
#define BOTTLE_MAX			16
#define SHOT_MAX			8
#define EXPLOSION_MAX		6
#define EXPLOSION_PIECES	12

#define FLAGSHIP_APPEAR 100
#define BONUSSHIP_AWARD 500

#define BOTTLE_Y        45

#define EN_FLAGSHIP     0
#define EN_SLICER		6

#define SCRSIZE     0x600

char scr[32*64];

char *mem;
char cntr;
int sound1, sound2;
int score, score0, score1, hiscore;
int speed;

/* enemies current x,y (represented in 8.8 fractional integers) */
int enemy_x[ENEMY_MAX];
int enemy_y[ENEMY_MAX];
/* enemies step x,y */
int enemy_sx[ENEMY_MAX];
int enemy_sy[ENEMY_MAX];
char enemy_flag[ENEMY_MAX];
char enemy_type[ENEMY_MAX];
char enemy_bottle[ENEMY_MAX];

/* flag ship may occur? */
char enemy_fship;

/* bottles current x,y (represented in 8.8 fractional integers) */
char bottle_x[BOTTLE_MAX];
char bottle_y[BOTTLE_MAX];
char bottle_dy[BOTTLE_MAX];
char bottle_flag[BOTTLE_MAX];
#define BOTTLE_AVAIL    0x01
#define BOTTLE_STOLEN	0x20
#define BOTTLE_FALLING  0x40
#define BOTTLE_STEAL    0x80
char bottle_cnt;
char bottle_live;

/* shots current x,y and color (colour = type) */
char shot_x[SHOT_MAX];
char shot_y[SHOT_MAX];
char shot_c[SHOT_MAX];
char enemy_shot_cnt;
char ship_shot_cnt;

/* explosions current x,y and count (>0 is size) */
char expl_x[EXPLOSION_MAX];
char expl_y[EXPLOSION_MAX];
char expl_cnt[EXPLOSION_MAX];
char expl_max[EXPLOSION_MAX];
char expl_pieces[EXPLOSION_MAX];
int expl_dx[EXPLOSION_MAX*EXPLOSION_PIECES];
int expl_dy[EXPLOSION_MAX*EXPLOSION_PIECES];
int expl_sx[EXPLOSION_MAX*EXPLOSION_PIECES];
int expl_sy[EXPLOSION_MAX*EXPLOSION_PIECES];

/* ship x,y coordinates */
int ship_x, ship_y;
char ship_explode, ships;

/* display scoring */
char add_cnt;

/**************************************************************************
 * Initialize variables
 **************************************************************************/
init_enemy()
{
	memset(enemy_flag, 0, sizeof(enemy_flag));
	enemy_fship = 0;
}

reinit_enemy()
{
	int i, b;
	for (i = 0; i < ENEMY_MAX; i++)
	{
		b = enemy_bottle[i];
		if (b >= 0)
		{
			/* put back the bottle to the floor */
			bottle_y[b] = BOTTLE_Y;
			bottle_flag[b] = BOTTLE_AVAIL;
			bottle_cnt++;
		}
		/* enemy is dead */
		enemy_flag[i] = 0;
	}
}

init_bottle()
{
	int i;
	for (i = 0; i < BOTTLE_MAX; i++)
	{
		bottle_x[i] = i * 6 + 16;
		bottle_y[i] = BOTTLE_Y;
		bottle_flag[i] = BOTTLE_AVAIL;
	}
	bottle_cnt = BOTTLE_MAX;
	bottle_live = BOTTLE_MAX;
}

init_ship()
{
	ship_x = 64;
	ship_y = BOTTLE_Y - 4;
	ship_explode = 0;
}

init_shot()
{
	memset(shot_c, 0, sizeof(shot_c));
	ship_shot_cnt = 0;
}

init_explosion()
{
	memset(expl_cnt, 0, sizeof(expl_cnt));
}

/**************************************************************************
 * Find specific slots
 **************************************************************************/
find_bottle()
{
	int i;
	i = rand(BOTTLE_MAX);
	if (bottle_flag[i] == BOTTLE_AVAIL)
		return i;
	for (i = BOTTLE_MAX; i > 0; --i)
    {
		if (bottle_flag[i] == BOTTLE_AVAIL)
			return i;
    }
	return -1;
}

find_shot()
{
	int i;
	for (i = 0; i < SHOT_MAX; i++)
    {
        if (!shot_c[i])
            return i;
    }
    return 0;
}

find_explosion(x,y,p,n,m,sy)
int x,y,p,n,m,sy;
{
	int i, j, k;
	for (i = 0; i < EXPLOSION_MAX; i++)
    {
		if (expl_cnt[i] == 0)
		{
			expl_x[i] = x;
			expl_y[i] = y;
            expl_cnt[i] = 1;
			expl_max[i] = n;
			expl_pieces[i] = p;
			for (j = 0; j < p; j++)
			{
				k = i * EXPLOSION_PIECES + j;
				expl_dx[k] = 0;
				expl_dy[k] = 0;
				expl_sx[k] = (rand(256) - 128) * m;
				expl_sy[k] = (rand(256) - 128) * m + sy * 128;
			}
			return;
		}
    }
}

hit_enemy(x,y)
int x,y;
{
	int i, j, b, t;
	x *= 256;
	y *= 256;
	for (i = 0; i < ENEMY_MAX; i++)
	{
		if (enemy_flag[i] == 0)
			continue;
		if (x > enemy_x[i] - 0x300 && x < enemy_x[i] + 0x300 &&
			y > enemy_y[i] - 0x200 && y < enemy_y[i] + 0x200)
		{
			shape(enemy_x[i]/256-3,enemy_y[i]/256-1,7,3,0,"\xfe\xfe\xfe");
			if (enemy_type[i] == EN_FLAGSHIP)
			{
				t = rand(4);	/* sometimes let the slicers appear ;-) */
				for (j = 0; j < ENEMY_MAX; j++)
				{
					if (i == j || enemy_flag[j] || (rand()&1) != 0 )
						continue;
					enemy_x[j] = enemy_x[i] + rand(2048) - 1024;
					enemy_y[j] = y = enemy_y[i] + rand(1024);
                    enemy_bottle[j] = -1;
					if (t == 0)
					{
						enemy_sx[j] = 0;
						enemy_sy[j] = 128;
						enemy_flag[j] = 3;
                        enemy_type[j] = EN_SLICER;
                    }
					else
					{
						x = (rand(112) + 8) * 256;
                        enemy_sx[j] = (x - enemy_x[i]) / (48 - y/256);
						enemy_sy[j] = 128 + rand(128);
						enemy_flag[j] = 2;
						enemy_type[j] = rand(EN_SLICER-1) + 1;
					}
				}
				t = 12;
			}
			else
			if (enemy_type[i] == EN_SLICER)
			{
				t = 8;
			}
			else
			{
				t = 5;
				b = enemy_bottle[i];
				if (b >= 0)
				{
					/* he looses the claim on the bottle now */
					bottle_flag[b] &= ~BOTTLE_STEAL;
					bottle_cnt++;
					/* did the enemy already go up? */
					if (bottle_flag[b] & BOTTLE_STOLEN)
					{
						bottle_flag[b] &= ~BOTTLE_STOLEN;
						/* the bottle starts falling now */
						bottle_flag[b] |= BOTTLE_FALLING;
						/* depth 0 */
						bottle_dy[b] = 0;
					}
				}
			}
			/* don't move the enemy anymore */
            enemy_sx[i] = 0;
            enemy_sy[i] = 0;
            enemy_flag[i] = 0;
			if (enemy_type[i] != EN_FLAGSHIP)
				find_explosion(enemy_x[i]/256,enemy_y[i]/256,EXPLOSION_PIECES/2,t,4,-1);
			return t;
		}
	}
	return 0;
}

hit_ship(x,y)
int x,y;
{
	if (ship_explode)
		return 0;
	if (x > ship_x - 4 && x < ship_x + 4 && y > ship_y - 1 && y < ship_y + 4)
		return 1;
    return 0;
}

hit_bottle(x)
int x;
{
	int i;
	for (i = 0; i < BOTTLE_MAX; i++)
	{
		if ((bottle_flag[i] & BOTTLE_AVAIL) == 0)
			continue;
		if ((bottle_flag[i] & BOTTLE_FALLING) != 0)
            continue;
		if (x == bottle_x[i] && BOTTLE_Y == bottle_y[i])
		{
			/* the bottle is now broken... */
			find_explosion(bottle_x[i],BOTTLE_Y,EXPLOSION_PIECES/2,10,3,-2);
			bottle_flag[i] = 0;
			bottle_live--;
			bottle_cnt--;
            sound2 = 200;
            return 1;
		}
	}
	return 0;
}

/**************************************************************************
 * Draw to screen (or screen buffer)
 **************************************************************************/
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

draw_enemy_type(x,y,color,type)
int x,y,color,type;
{
	int c, s;
	char *enmy;

	c = cntr & 3;
	s = cntr & 7;
	x -= 3;
	y -= 1;
    switch (type)
	{
    case 0:
		/*
		 *	 .xxxx.. .xxxx.. .xxxx.. .xxxx..
		 *	 x...xx. xx...x. x.x..x. x..x.x.
		 *	 .xxxx.. .xxxx.. .xxxx.. .xxxx..
		 */
		switch (c)
		{
		case 0: shape(x,y,7,3,color,"\x78\x8c\x78"); break;
		case 1: shape(x,y,7,3,color,"\x78\xc4\x78"); break;
		case 2: shape(x,y,7,3,color,"\x78\xa4\x78"); break;
		case 3: shape(x,y,7,3,color,"\x78\x94\x78"); break;
        }
		switch (s)
        {
		case 0: sound2 = 60; break;
		case 1: sound1 = 62; break;
		case 2: sound2 = 40; break;
		case 3: sound1 =100; break;
		case 4: sound2 = 20; break;
		case 5: sound1 = 19; break;
		case 6: sound2 = 40; break;
		case 7: sound1 = 80; break;
        }
        break;
    case 1:
		/*
		 *	..xxx.. ..xxx.. ..xxx.. ..xxx..
		 *	xx.x.xx xx.x.xx xx.x.xx xx.x.xx
		 *	x.xxx.x ..xxx.. x.xxx.x ..xxx..
         */
        switch (c)
		{
		case 0: shape(x,y,7,3,color,"\x38\xd6\xba"); break;
		case 1: shape(x,y,7,3,color,"\x38\xd6\x38"); break;
		case 2: shape(x,y,7,3,color,"\x38\xd6\xba"); break;
		case 3: shape(x,y,7,3,color,"\x38\xd6\x38"); break;
        }
        break;
    case 2:
		/*
		 *	x.xxx.. ..xxx.. ..xxx.x ..xxx..
		 *	xxx.xxx xxx.xxx xxx.xxx xxx.xxx
		 *	..xxx.x ..xxx.. x.xxx.. ..xxx..
		 */
		switch (c)
		{
		case 0: shape(x,y,7,3,color,"\xb8\xee\x3a"); break;
		case 1: shape(x,y,7,3,color,"\x38\xee\x38"); break;
		case 2: shape(x,y,7,3,color,"\x3a\xee\xb8"); break;
		case 3: shape(x,y,7,3,color,"\x38\xee\x38"); break;
        }
        break;
	case 3:
		/*
		 *	.xx.xx. ..x.x.. .xx.xx. ..x.x..
		 *	x..x..x .x.x.x. x..x..x .x.x.x.
		 *	.xx.xx. ..x.x.. .xx.xx. ..x.x..
         */
        switch (c)
		{
		case 0: shape(x,y,7,3,color,"\x6c\x92\x6c"); break;
		case 1: shape(x,y,7,3,color,"\x28\x54\x28"); break;
		case 2: shape(x,y,7,3,color,"\x6c\x92\x6c"); break;
		case 3: shape(x,y,7,3,color,"\x28\x54\x28"); break;
        }
        break;
	case 4:
		/*
		 *	..x.x.. .xx.xx. ..x.x.. .xx.xx.
		 *	.x.x.x. xx.x.xx .x.x.x. xx.x.xx
		 *	x..x..x x..x..x x..x..x x..x..x
         */
        switch (c)
		{
		case 0: shape(x,y,7,3,color,"\x28\x54\x92"); break;
		case 1: shape(x,y,7,3,color,"\x6c\xd6\x92"); break;
		case 2: shape(x,y,7,3,color,"\x28\x54\x92"); break;
		case 3: shape(x,y,7,3,color,"\x6c\xd6\x92"); break;
        }
        break;
	case 5:
		/*
		 *	..xxx.. x.xxx.x ..xxx.. x.xxx.x
		 *	.xx.xx. .xx.xx. .xx.xx. .xx.xx.
		 *	x.xxx.x ..xxx.. x.xxx.x ..xxx..
         */
        switch (c)
		{
		case 0: shape(x,y,7,3,color,"\x38\x6c\xba"); break;
		case 1: shape(x,y,7,3,color,"\xba\x6c\x38"); break;
		case 2: shape(x,y,7,3,color,"\x38\x6c\xba"); break;
		case 3: shape(x,y,7,3,color,"\xba\x6c\x38"); break;
        }
        break;
    case EN_SLICER:
		/*
		 *	...x... ....x.. ....... ..x....
		 *	...x... ...x... .xxxxx. ...x...
		 *	...x... ..x.... ....... ....x..
		 */
        switch (c)
		{
		case 0: shape(x,y,7,3,color,"\x10\x10\x10"); break;
		case 1: shape(x,y,7,3,color,"\x08\x10\x20"); break;
		case 2: shape(x,y,7,3,color,"\x00\x7c\x00"); break;
		case 3: shape(x,y,7,3,color,"\x20\x10\x08"); break;
        }
		switch (s)
        {
		case 0: sound1 = 20; break;
		case 1: sound1 = 40; break;
		case 2: sound2 = 21; break;
		case 3: sound1 = 22; break;
		case 5: sound1 = 23; break;
		case 6: sound2 = 30; break;
        }
        break;
    }
}

clear_enemy()
{
	int i, x, y;

    for (i = 0; i < ENEMY_MAX; i++)
    {
		if (enemy_flag[i] == 0)
			continue;
		x = enemy_x[i] / 256;
		y = enemy_y[i] / 256;
		shape(x-3,y-1,7,3,0,"\xfe\xfe\xfe");
		if (enemy_type[i] == EN_SLICER && y == (BOTTLE_Y + 1))
        {
            /* did the slicer hit a bottle? */
			if (hit_bottle(x))
				enemy_flag[i] = 0;
        }
    }
}

init_ship_explosion()
{
	find_explosion(ship_x,ship_y+3,EXPLOSION_PIECES,30,3,-4);
	ship_explode = 1;
}

draw_enemy()
{
	int i, b, j, x, y;

    for (i = 0; i < ENEMY_MAX; i++)
	{
		if (enemy_flag[i] == 0)
		{
			/* eventually create a new enemy */
			if (rand(0x7fff) > 0x7fc0 - sqrt(score))
			{
				/* start at a random x offset between 32...95 */
				enemy_x[i] = 256 * (rand(64) + 32);
				enemy_y[i] = 0;
				enemy_type[i] = rand(EN_SLICER-1) + 1;
				enemy_bottle[i] = -1;  /* no bottle */
                /* the fewer bottles left, the more likely slicers appear */
				if (rand(bottle_cnt*2) == 0)
					enemy_type[i] = EN_SLICER;

				/* time for a flagship occurance? */
				if (enemy_fship)
				{
                    enemy_x[i] = 0x0200;
					enemy_y[i] = 0x0c00;
					enemy_type[i] = EN_FLAGSHIP;
					enemy_sx[i] = 128;		/* move right */
					enemy_sy[i] = 0;		/* horizontally only */
					enemy_flag[i] = 2;		/* blue */
					enemy_fship = 0;
                }
				else
				if (enemy_type[i] == EN_SLICER)
				{
					enemy_sx[i] = 0;		/* don't move horizontally */
					enemy_sy[i] = 128;		/* half speed down */
					enemy_flag[i] = 3;		/* red */
                }
				else
				{
					int dy;
					dy = BOTTLE_Y - enemy_y[i] / 256;
					x = (rand(64) + 32) * 256;
					if (bottle_cnt > 0)
					{
						b = find_bottle();		/* find a target bottle */
						enemy_bottle[i] = b;	/* set target */
						if (b >= 0)
						{
							bottle_flag[b] |= BOTTLE_STEAL;
							bottle_cnt--;
							x = bottle_x[b] * 256;
							if (x > enemy_x[i])
								x = enemy_x[i] + rand(x - enemy_x[i]);
							else
								x = x + rand(enemy_x[i] - x);
							dy = bottle_y[b] - enemy_y[i] / 256;
						}
					}
					enemy_sx[i] = (x - enemy_x[i]) / dy;
					enemy_sy[i] = speed;
					enemy_flag[i] = 2;		/* blue */
                }
			}
			else
				continue;
		}
		enemy_x[i] += enemy_sx[i];
		enemy_y[i] += enemy_sy[i];
		x = enemy_x[i] / 256;
		y = enemy_y[i] / 256;
		b = enemy_bottle[i];

        if (hit_ship(x,y) || hit_ship(x-2,y) || hit_ship(x+2,y))
		{

			enemy_flag[i] = 0;
			init_ship_explosion();
			continue;
        }

		if (y < -4 || y >= 48)	/* off the screen? */
		{
			enemy_flag[i] = 0;	/* ship is gone now */
			/* is the bottle gone too? */
			if (b >= 0 && (bottle_flag[b] & BOTTLE_STOLEN) != 0)
				bottle_flag[b] = 0;
			continue;
		}

        if (enemy_type[i] == EN_FLAGSHIP && x > 123)
		{
			enemy_flag[i] = 0;	/* ship is gone now */
            continue;
        }

        draw_enemy_type(x,y,enemy_flag[i],enemy_type[i]);

        if (y == BOTTLE_Y/3)     /* upper third of the screen? */
        {
			if (enemy_shot_cnt < 5 && rand(256-speed) == 0)
			{
				int s;

				s = find_shot();
				shot_c[s] = 2;
				shot_x[s] = x;
				shot_y[s] = y+1;
                enemy_shot_cnt++;
				for (s = 10; s < 250; s += 40)
					sound(s,4);
            }
		}
        else
		if (y == BOTTLE_Y/2)	 /* middle of the screen? */
		{
			/* got a bottle? */
			if (b >= 0 && (bottle_flag[b] & BOTTLE_STOLEN) != 0)
			{
				/* fly away vertically */
				enemy_sx[i] = 0;
				enemy_sy[i] = -speed;
			}
			else
			if (bottle_flag[b] & BOTTLE_STEAL)	 /* steal a bottle? */
			{
				int bx, dx, dy;
				/* fly to target bottle */
				bx = bottle_x[b] * 256;
				if (bx > enemy_x[i])
				{
					dx = bx - enemy_x[i];
					dx = enemy_x[i] + dx*3/4 + rand(dx/4);
				}
				else
				{
					dx = enemy_x[i] - bx;
					dx = bx + rand(dx/4);
				}
				dy = BOTTLE_Y - enemy_y[i] / 256;
				enemy_sx[i] = (dx - enemy_x[i]) / dy;
                enemy_sy[i] = speed;
			}
		}
		else
		/* normal enemy reached the row above the bottles now? */
		if (y == (BOTTLE_Y - 2) && b >= 0 && (bottle_flag[b] & BOTTLE_STEAL) != 0)
		{
			if (x == bottle_x[b])
			{
				/* take it up or drop the bottle now */
				bottle_flag[b] ^= BOTTLE_STOLEN;
				j = 256 * (rand(64) + 32);
				enemy_sx[i] = (j - enemy_x[i]) / (BOTTLE_Y/2);
				enemy_sy[i] = -speed;
			}
			else
			{
				int bx;
				bx = bottle_x[b] * 256;
				enemy_sx[i] = (bx - enemy_x[i]) / 128;
				if (bx < enemy_x[i])
					enemy_sx[i] -= 128;
				else
					enemy_sx[i] += 128;
				enemy_sy[i] = 0;
			}
		}
		else
		/* slicer reached the bottom row? */
		if (y == (BOTTLE_Y + 1) && enemy_type[i] == EN_SLICER)
		{
			if (x < 1)
				enemy_sx[i] = speed;
			else
			if (x > 125)
				enemy_sx[i] = -speed;
			else
			{
				if (enemy_sx[i] == 0)
					enemy_sx[i] = rand(1) ? -speed : speed;
				enemy_sy[i] = 0;
			}
		}
		if (bottle_flag[b] & BOTTLE_STOLEN)    /* bottle stolen? */
		{
			bottle_x[b] = x;		/* move bottle with */
			bottle_y[b] = y + 2;	/* ship (below center) */
		}
	}
}

clear_bottle()
{
	int i, x, y, s;

	for (i = 0; i < BOTTLE_MAX; i++)
    {
		if (bottle_flag[i] == 0)
			continue;
		x = bottle_x[i];
		y = bottle_y[i];
		shape(x-1,y,3,3,0,"\x40\xe0\xe0");
		/* bottle falling? */
		if (bottle_flag[i] & BOTTLE_FALLING)
        {
			bottle_y[i] += 1;
			bottle_dy[i] += 1;	/* depth */
            /* ship catched a falling bottle? */
			if (bottle_dy[i] > 8 && hit_ship(x,y))
            {
                bottle_y[i] = BOTTLE_Y;
				bottle_flag[i] &= ~BOTTLE_FALLING;
				draw_score(25);
				for (s = 10; s < 120; s += 10)
					sound(s,5);
            }
            else
			if (bottle_y[i] >= BOTTLE_Y)
            {
				bottle_y[i] = BOTTLE_Y;
				bottle_flag[i] &= ~BOTTLE_FALLING;
                /* bottle fell too fast? darn.. smash it.. */
				if (bottle_dy[i] > 8)
                {
					find_explosion(bottle_x[i],BOTTLE_Y,EXPLOSION_PIECES/2,10,2,-3);
					bottle_flag[i] = 0;
                    bottle_cnt--;
					bottle_live--;
                    sound2 = 10;
                    continue;
                }
            }
        }
    }
}

draw_bottle()
{
	int i;

	for (i = 0; i < BOTTLE_MAX; i++)
	{
		/* bottle is gone? */
		if (bottle_flag[i] == 0)
			continue;
		shape(bottle_x[i]-1,bottle_y[i],3,3,1,"\x40\xe0\xe0");
		plot(bottle_x[i],bottle_y[i]+2,cntr&3);
    }
}

clear_ship()
{
	shape(ship_x-3,ship_y,7,4,0,"\xfe\xfe\xfe\xfe");
}

draw_ship()
{
	static int dir, shot;

	if (ship_explode)
		return;

    if ((mem[0x68ef] & 0x20) == 0)  /* left (M) ? */
	{
		dir = (dir > 0) ? 0 : dir - 1;
		if (ship_x > 3)
			ship_x--;
		if (dir < -2 && ship_x > 3)
			ship_x--;
		if (dir < -7 && ship_x > 3)
            ship_x--;
    }
	else
	if( dir < 0 )
        dir = 0;
	if ((mem[0x68ef] & 0x08) == 0)	/* right (,) ? */
	{
		dir = (dir < 0) ? 0 : dir + 1;
		if (ship_x < 124)
			ship_x++;
		if (dir > +2 && ship_x < 124)
			ship_x++;
		if (dir > +7 && ship_x < 124)
            ship_x++;
    }
	else
	if( dir > 0 )
        dir = 0;
	if ((mem[0x68fb] & 0x04) == 0)	/* shoot (CTRL) ? */
    {
		if (!shot && ship_shot_cnt < 3)
		{
			int s;

			shot = 1;
			s = find_shot();
            shot_c[s] = 3;
			ship_shot_cnt++;
			shot_x[s] = ship_x;
			shot_y[s] = ship_y;
			for (s = 1; s < 512; s <<= 1)
				sound(s,3);
		}
	}
	else
		shot = 0;
	/*	...x...
	 *	..xxx..
	 *	.xxxxx.
	 *	xxx.xxx
	 */
	shape(ship_x-3,ship_y,7,4,2,"\x10\x38\x7c\xee");
	if (ship_shot_cnt < 3)
		plot(ship_x,ship_y,3);
}

clear_shot()
{
	int i,x,y;
	for (i = 0; i < SHOT_MAX; i++)
	{
		if (!shot_c[i])
			continue;
		x = shot_x[i];
		y = shot_y[i];
		plot(x,y,0);
		plot(x,y+1,0);
		plot(x,y+2,0);
	}
}

draw_shot()
{
	int i, x, y, t;

    for (i = 0; i < SHOT_MAX; i++)
	{
		x = shot_x[i];
		y = shot_y[i];
		if (shot_c[i] == 2) /* enemy drop bombs */
		{
			if ((y += 2) >= BOTTLE_Y)
			{
				shot_c[i] = 0;
			}
			else
			{
				if (!ship_explode && hit_ship(x,y))
				{
					shot_c[i] = 0;
					enemy_shot_cnt--;
					init_ship_explosion();
                }
				else
				{
					shot_y[i] = y;
					plot(x,y,2);
					plot(x,y+1,2);
				}
            }
		}
		else
		if (shot_c[i] == 3) /* ship shots */
		{
			if ((y -= 3) < 0)
			{
                shot_c[i] = 0;
				ship_shot_cnt--;
			}
			else
			{
				t = hit_enemy(x,y);
				if (t == 0) t = hit_enemy(x,y+1);
				if (t == 0) t = hit_enemy(x,y+2);
				if (t)
				{
					shot_c[i] = 0;
					ship_shot_cnt--;
					draw_score(t);
				}
				else
				{
					shot_y[i] = y;
					plot(x,y,3);
					plot(x,y+1,3);
					plot(x,y+2,3);
				}
			}
        }
	}
}

clear_explosion()
{
	int i, j, k, x, y, c;
	for (i = 0; i < EXPLOSION_MAX; i++)
	{
		c = expl_cnt[i];
		if (!c)
			continue;
		expl_cnt[i] = c + 1;
		x = expl_x[i];
		y = expl_y[i];
		for (j = 0; j < expl_pieces[i]; j++)
		{
			k = i * EXPLOSION_PIECES + j;
			plot(x+expl_dx[k]/256,y+expl_dy[k]/256,0);
			if (y+expl_dy[k]/256 >= 47)
				expl_sy[k] = -expl_sy[k];
			expl_dx[k] += expl_sx[k];
			expl_dy[k] += expl_sy[k];
			if (expl_sy[k] < 0)
				expl_sy[k] /= 2;
			expl_sy[k] += 32;
        }
    }
}

draw_explosion()
{
	int i, j, k, x, y, c;
	for (i = 0; i < EXPLOSION_MAX; i++)
	{
		c = expl_cnt[i];
		if (c == 0)
			continue;
		if (c > expl_max[i])
		{
			expl_cnt[i] = 0;
			continue;
		}
        sound2 = c * 8;
		x = expl_x[i];
		y = expl_y[i];
		for (j = 0; j < expl_pieces[i]; j++)
        {
			k = i * EXPLOSION_PIECES + j;
			plot(x+expl_dx[k]/256,y+expl_dy[k]/256,(j&2)|1);
        }
    }
}

clear_score_add()
{
	int i;
	if (--add_cnt == 0)
	{
		setbase(0x7000);
		char_draw(76+5*6, 52, 0, '0');
		for (i = 4; i >= 0; i--)
			char_draw(76+i*6, 52, 0, 0x7f);  /* erase character */
		setbase(scr);
	}
}

draw_hiscore()
{
    int i, n;
	n = hiscore;
	setbase(0x7000);
	char_draw(2+5*6, 58, 3, '0');
	for (i = 4; n > 0 && i >= 0; i--)
	{
		char_draw(2+i*6, 58, 0, 0x7f);	/* erase character */
		char_draw(2+i*6, 58, 3, 0x30 + (n % 10));
		n = n / 10;
    }
	setbase(scr);
}

draw_score(add)
int add;
{
    int i, n;
	score += add;
    n = score;

	if (score >= score0)
	{
		score0 += FLAGSHIP_APPEAR;
		enemy_fship = 1;
	}
	if (score >= score1)
	{
		score1 += BONUSSHIP_AWARD;
		ships++;
		draw_ships();
    }
	if (score > hiscore)
    {
		hiscore = score;
        draw_hiscore();
    }
    setbase(0x7000);
	char_draw(2+5*6, 52, 3, '0');
	for (i = 4; n > 0 && i >= 0; i--)
    {
		char_draw(2+i*6, 52, 0, 0x7f);	/* erase character */
		char_draw(2+i*6, 52, 3, 0x30 + (n % 10));
        n = n / 10;
    }
	if (add > 0)
	{
		n = add;
		char_draw(76+5*6, 52, 2, '0');
		for (i = 4; n > 0 && i >= 0; i--)
		{
			char_draw(76+i*6, 52, 0, 0x7f);  /* erase character */
			char_draw(76+i*6, 52, 2, 0x30 + (n % 10));
			n = n / 10;
		}
        add_cnt = 5;
	}
    setbase(scr);
}

draw_ships()
{
	int i;
    setbase(0x7000);
	for (i = 0; i < 7; i++)
		char_draw(44+i*6, 52, (i < ships) ? 2 : 0, 0x5e);
    setbase(scr);
}

update_once(enemies)
int enemies;
{
	cntr++;
	if (cntr == 0 && speed < 256)
		speed++;
    setbase(scr);
	/* remove sprites from screen buffer */
	if (enemies)
		clear_enemy();
	clear_bottle();
	clear_ship();
	clear_shot();
	clear_explosion();
	/* draw sprites to screen buffer */
	if (enemies)
		draw_enemy();	/* move and draw enemies */
	draw_bottle();		/* move and draw bottles */
	draw_ship();		/* move and draw ship */
	draw_shot();		/* move and draw shots */
	draw_explosion();
	if (add_cnt > 0)
		clear_score_add();
    setbase(0x7000);
	soundcopy(0x7000,scr,SCRSIZE,sound1,sound2);
    sound1 = 0;
	sound2 = 0;
}

greeting()
{
	int y;
	setbase(scr);
	memset(scr,0x00,SCRSIZE);
	if (cntr < 66)
		y = 48 - cntr;
	else
		y = -18;
	draw_string(2, y+ 0, 2, " Juergen Buchmueller ");
	draw_string(2, y+ 6, 2, "  proudly presents:  ");
	draw_string(2, y+12, 2, "    THE RETURN OF    ");
	draw_string(2, y+18, (cntr&2)|1, "-* DEFENSE COMMAND *-");
    if( cntr < 0 || cntr >= 96)
    {
        if (cntr < 0)
        {
            cntr++;
			draw_string(38, 32, 3, "Game Over");
        }
        else
			draw_string(8, 32, 2, "Press 'S' to start!");
        setbase(0x7000);
        soundcopy(0x7000,scr,SCRSIZE,sound1,sound2);
    }
	else
    if (cntr < 48)
	{
        cntr++;
		sound1 = 7 + rand(12);
		sound1 *= sound1;
		if (y & 1)
			sound2 = 100;
		setbase(0x7000);
		soundcopy(0x7000,scr,SCRSIZE,sound1,sound2);
		sound1 = 0;
		sound2 = 0;
    }
	else
	if (cntr < 66)
	{
		setbase(0x7000);
        soundcopy(0x7000,scr,SCRSIZE,sound1,sound2);
        cntr++;
    }
	else
	if (cntr < 96)
	{
		if (!(cntr & 2))
			draw_string(8, 32, 2, "Press 'S' to start!");
        setbase(0x7000);
        soundcopy(0x7000,scr,SCRSIZE,sound1,sound2);
		cntr++;
    }
}

/**************************************************************************
 * The main loop
 **************************************************************************/
main(ac,av)
int ac;
char *av;
{
	int i;

    mem = 0;
	srand(0);

	hiscore = 1000;

	mode(1);
    setbase(0x7000);

    line(  0,48,127,48,2);
	line(  0,49,127,49,3);
	line(  0,50,127,50,1);

    speed = 196;

	asm("di\n");
	cntr = 0;
    for (;;)
	{
        do
		{
			greeting();
		} while (inch() != 'S');

        memset(scr,0x00,SCRSIZE);
        init_enemy();
		init_bottle();
		init_ship();
		init_shot();
		init_explosion();
        score = 0;
		score0 = FLAGSHIP_APPEAR;
		score1 = BONUSSHIP_AWARD;
		ships = 3;

		while (ships > 0)
		{
			draw_hiscore();
			draw_score(0);
            draw_ships();
            do
			{
				update_once(1);
				if (inch() == 3)
				{
					ships = 0;
					break;
				}
				if (bottle_live == 0)
				{
					ships = 0;
					ship_explode = 1;
				}
            } while (!ship_explode);
			if (ship_explode)
			{
				ships -= 1;
				draw_ships();
				/* let the ship explosion happen */
				for (i = 0; i < 30; i++)
				{
					if (ships == 0)
						draw_string(38, 32, 3, "Game Over");
					update_once(1);
				}
				if (ships > 0)
				{
					setbase(scr);
                    clear_bottle();
					clear_enemy();
					reinit_enemy();
					/* update another 30 frames */
					for (i = 0; i < 30; i++)
						update_once(0);
                }
				init_ship();
            }
		}
		cntr = -128;
    }
}
