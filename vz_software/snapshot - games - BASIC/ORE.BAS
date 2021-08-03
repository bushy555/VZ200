10 Mines = INT(RND(1) * 3 + 5)
20 workers = INT(RND(1) * 60 + 40)
30 Dollars = INT(RND(1) * 50 + 10) * workers
40 FP = INT(RND(1) * 40 + 80)
50 Tons = INT(RND(1) * 40 + 80)
60 Ore = 0
70 Satisfaction = 1
80 Year = 1
90 Mines
91 Food
100 Ore
110 CLS
120 PRINT "Year:"; Year
130 PRINT
140 PRINT "There are "; workers; " Workers in the colony.";
150 PRINT "You have "; Mines; " Mines, and $"; Dollars
160 PRINT "Satisfaction factor:"; Satisfaction
180 PRINT "Your mines produced "; Tons; " tons each."
190 Ore = Ore + Tons * Mines
200 PRINT "Ore in store: "; Ore; "tons."
210 PRINT "Selling:"
220 PRINT "Ore selling price: "; Ore
230 PRINT "Mines selling price:"; Mines
231 PRINT
240 INPUT "How much ore to sell "; Ore
260 IF ((Ore
280 Dollars = Dollars + (Ore
290 INPUT "How many mines to sell "; Mines
310 IF ((Mines
320 Mines = Mines - Mines
330 Dollars = Dollars + Mines
340 CLS
349 PRINT "Year:"; Year
350 PRINT "You have $"; Dollars
360 PRINT "You have "; workers; " Workers."
361 PRINT "Yor have "; Mines; " mines left"
362 PRINT "Satisfaction Factor:"; Satisfaction
363 PRINT "$ "; Mines
370 PRINT "Buying:"
380 INPUT "How much to spend on food "; Food
400 IF Food
410 Dollars = Dollars - Food
420 IF ((Food
430 IF ((Food
440 INPUT "How many more mines to buy "; Mines
460 IF (Mines
470 Mines=Mines+(Mines
480 Dollars = Dollars - (Mines
490 IF (Satisfaction < .6) THEN 660
500 IF (Satisfaction > 1.1) THEN Tons = Tons + INT(RND(1) * 20 + 1)
510 IF (Satisfaction < .9) THEN Tons = Tons - INT(RND(1) * 20 + 1)
520 IF ((workers / Mines) < 10) THEN 680
530 IF (Satisfaction > 1.1) THEN workers = workers + INT(RND(1) * 10 + 1)
540 IF (Satisfaction < .9) THEN workers = workers - INT(RND(0) * 10 + 1)
550 IF (workers < 30) THEN 700
560 IF (RND(1) > .01) THEN 590
570 PRINT "A huge radioactive leak occured and many workers died."
580 workers = INT(workers / 2)
590 IF (Tons < 150) THEN 620
600 PRINT "The price of Ore halves due to an Ore market crash."
610 Tons = INT(Tons / 2)
620 Year = Year + 1
630 IF (Year < 99) THEN 90
640 PRINT "You have turned old and grey and have decided to retire to a better life.": END
660 PRINT "The workers revolted.": END
680 PRINT "Yov have overworked everyone": END
700 PRINT "There are not enough people left to work for the company.": END






10 L = INT(RND(0) * 3 + 5)
20 workers = INT(RND(0) * 60 + 40)
30 M = INT(RND(0) * 50 + 10) * P
40 FP = INT(RND(0) * 40 + 80)
50 tons = INT(RND(0) * 40 + 80)
60 C = 0
70 S = 1
80 Y = 1
90 LP = INT(RND(0) * 2000 + 2000)
100 CP = INT(RND(0) * 12 + 7)
110 CLS
120 PRINT "YEAR:"; Year
130 PRINT
140 PRINT "There are "; workers; " workers in the colony.";
150 PRINT "You have "; L; " mines, and $"; M
160 PRINT "Satisfaction factor:"; S
180 PRINT "Your mines produced "; tons; " tons each."
190 C = C + tons * L
200 PRINT "Ore in store="; C; "tons"
210 PRINT "Selling:"
220 PRINT "Ore selling price="; CP
230 PRINT "Mines selling price="; LP; "Mine"
231 PRINT
240 INPUT "How much ore to sell "; CS
260 IF CS < 0 OR CS > C THEN 240
280 M = M + CS * CP
290 INPUT "How many mines to sell "; LS
310 IF LS < 0 OR LS > L THEN 240
320 L = L - LS
330 M = M + LS * LP
340 CLS
349 PRINT "Yaer:"; Year
350 PRINT "YOU HAVE $"; M
360 PRINT "YOU HAVE ;workers;"; WORKERS.; ""
361 PRINT "YOU HAVE "; L; "MINES LEFT"
362 PRINT "SATISFACTION FACTOR:"; S
363 PRINT "$ "; LP; "/PER MINE"
370 PRINT "BUYING:"
380 INPUT "HOW MUCH TO SPEND ON FOOD "; FB
400 IF FB < 0 OR FB > M THEN 380
410 M = M - FB
420 IF FB / workers > 100 THEN S = S + .1
430 IF FB / workers < 80 THEN S = S - .2
440 INPUT "HOW MANY MORE MINES TO BUY "; LB
460 IF LB < 0 OR LB * LP > M THEN 440
470 L = L + LB
480 M = M - LB * LP
490 IF S < .6 THEN 660
500 IF S > 1.1 THEN tons = tons + INT(RND(0) * 20 + 1)
510 IF S < .9 THEN tons = tons - INT(RND(0) * 20 + 1)
520 IF workers / L < 10 THEN 680
530 IF S > 1.1 THEN workers = workers + INT(RND(1) * 10 + 1)
540 IF S < .9 THEN workers = workers - INT(RND(1) * 10 + 1)
550 IF workers < 30 THEN 700
560 IF RND(1) > .01 THEN 590
570 PRINT "Radioactive leak... Many of your workers die."
580 workers = INT(workers / 2)
590 IF tons < 150 THEN 620
600 PRINT "The Stock Market crashes, price of Ore is halved."
610 tons = INT(tons / 2)
620 Y = Y + 1
630 GOTO 90
660 PRINT "The workers revolted.": END
680 PRINT "You have overworked everyone.": END
700 PRINT "There are not enough workers left.": END

