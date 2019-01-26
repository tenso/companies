BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS `types` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`name`	TEXT
);
INSERT INTO `types` VALUES (0,NULL);
INSERT INTO `types` VALUES (1,'Property');
INSERT INTO `types` VALUES (2,'Bank & finance');
INSERT INTO `types` VALUES (3,'Pharmacy');
INSERT INTO `types` VALUES (4,'Biotech');
INSERT INTO `types` VALUES (5,'Computer games');
INSERT INTO `types` VALUES (6,'Betting');
INSERT INTO `types` VALUES (7,'Construction');
INSERT INTO `types` VALUES (8,'Service & education');
INSERT INTO `types` VALUES (9,'Automotive');
INSERT INTO `types` VALUES (10,'Industry & process equipment ');
INSERT INTO `types` VALUES (11,'Food');
INSERT INTO `types` VALUES (12,'Forest & paper');
INSERT INTO `types` VALUES (13,'Ore and minig');
INSERT INTO `types` VALUES (14,'Oil and gas');
INSERT INTO `types` VALUES (15,'Investment');
INSERT INTO `types` VALUES (16,'Transport');
INSERT INTO `types` VALUES (17,'Clothes');
INSERT INTO `types` VALUES (18,'Communications');
INSERT INTO `types` VALUES (19,'Consumer goods');
INSERT INTO `types` VALUES (20,'Construction and property services');
INSERT INTO `types` VALUES (21,'Medical equipment & services');
INSERT INTO `types` VALUES (22,'Industry goods & parts');
INSERT INTO `types` VALUES (23,'Construction goods & tools');
INSERT INTO `types` VALUES (24,'Insurance');
INSERT INTO `types` VALUES (25,'Conglamerate');
INSERT INTO `types` VALUES (26,'Defence');
INSERT INTO `types` VALUES (27,'Media');
INSERT INTO `types` VALUES (28,'Security');
INSERT INTO `types` VALUES (29,'Grocer');
INSERT INTO `types` VALUES (30,'Consultants');
INSERT INTO `types` VALUES (31,'Healt & personal products');
INSERT INTO `types` VALUES (32,'Chemicals & plastics');
INSERT INTO `types` VALUES (33,'Environment & Climate ');
INSERT INTO `types` VALUES (34,'Energy');
INSERT INTO `types` VALUES (35,'Hotell & Leasure');
INSERT INTO `types` VALUES (36,'Electronics & computers');
INSERT INTO `types` VALUES (37,'Advertising');
INSERT INTO `types` VALUES (38,'Business services');
INSERT INTO `types` VALUES (39,'Tech');
INSERT INTO `types` VALUES (40,'Vanity');
INSERT INTO `types` VALUES (41,'Furniture & decoration');
INSERT INTO `types` VALUES (42,'Steel & materials');
INSERT INTO `types` VALUES (43,'Other');
CREATE TABLE IF NOT EXISTS `tags` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`name`	TEXT
);
CREATE TABLE IF NOT EXISTS `share` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`cId`	INTEGER,
	`date`	TEXT,
	`sharePrice`	INTEGER,
	`owners`	INTEGER
);
CREATE TABLE IF NOT EXISTS `notes` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`cId`	INTEGER,
	`date`	TEXT,
	`note`	TEXT
);
CREATE TABLE IF NOT EXISTS `magicFormula` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`cId`	INTEGER,
	`ebit`	NUMERIC,
	`ev`	NUMERIC,
	`capitalEmployed`	NUMERIC,
	`score`	NUMERIC,
	`financialsMode`	INTEGER,
	`year`	INTEGER,
	`qId`	INTEGER
);
INSERT INTO `magicFormula` VALUES (6,1,77.8,979,136,0.326,0,2017,0);
INSERT INTO `magicFormula` VALUES (7,2,85.7,1623,111,0.412,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (8,3,1479,13887,3276,0.279,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (9,4,602,6356,1026,0.341,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (10,5,47,1656,1083,0.036,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (11,6,3711,56476,13142,0.174,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (12,7,237,2880,1324,0.131,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (14,8,330,20948,67.9,2.438,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (15,9,774,9463,489,0.832,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (16,10,12.2,296,67.4,0.111,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (19,11,235,8520,122,0.977,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (20,12,1424,32920,1915,0.393,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (21,13,1738,16370,11163,0.131,0,NULL,NULL);
INSERT INTO `magicFormula` VALUES (22,15,228,2409,1322,0.134,0,2017,0);
CREATE TABLE IF NOT EXISTS `lists` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`name`	TEXT
);
INSERT INTO `lists` VALUES (1,'First North Stockholm');
INSERT INTO `lists` VALUES (2,'Nordic MTF');
INSERT INTO `lists` VALUES (3,'AktieTorget');
INSERT INTO `lists` VALUES (4,'NGM');
INSERT INTO `lists` VALUES (5,'Xterna listan');
INSERT INTO `lists` VALUES (6,'Large Cap Stockholm');
INSERT INTO `lists` VALUES (7,'Mid Cap Stockholm');
INSERT INTO `lists` VALUES (8,'Small Cap Stockholm');
CREATE TABLE IF NOT EXISTS `financials` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`cId`	INTEGER,
	`year`	INTEGER,
	`qId`	INTEGER,
	`shares`	NUMERIC,
	`sharePrice`	NUMERIC,
	`sales`	NUMERIC,
	`ebit`	NUMERIC,
	`assetsFixed`	NUMERIC,
	`assetsFixedPpe`	NUMERIC,
	`assetsCurr`	NUMERIC,
	`assetsCurrCash`	NUMERIC,
	`equity`	NUMERIC,
	`liabLong`	NUMERIC,
	`liabLongInt`	NUMERIC,
	`liabCurr`	NUMERIC,
	`liabCurrInt`	NUMERIC,
	`interestPayed`	NUMERIC,
	`dividend`	NUMERIC,
	`managRemun`	NUMERIC,
	`debtMaturity`	NUMERIC,
	`leasingY`	NUMERIC,
	`leasingY1`	NUMERIC,
	`leasingY2Y5`	NUMERIC,
	`leasingY5Up`	NUMERIC,
	`sharesInsider`	NUMERIC,
	`sharesInst`	NUMERIC,
	`insidersOwn`	NUMERIC
);
INSERT INTO `financials` VALUES (1,1,2016,0,11.4,110,610,75,49,40.7,221.7,35,137.8,5,0,128,25.5,1.4,34,19,5,12,10,11.7,0,3.1,3.2,0.28);
INSERT INTO `financials` VALUES (2,1,2015,0,11.4,45,527,50.8,39.4,29.9,193,31.5,113.3,5,0,114,26.5,0.93,40,19,5,10,6.5,8.5,0,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (3,1,2017,0,11.4,85,680,82,62,43,250,44,153,1.2,0,157,35.7,1.1,41,18,5,13.8,11.3,13.6,1.8,2.1,3.7,0.19);
INSERT INTO `financials` VALUES (4,2,2017,0,11.3,200,491,85.6,118,43,259,105,265,0.4,0.4,102,0,1,10,14,1,6.5,6,11,2,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (5,2,2016,0,11.3,120,411,78.9,94,42,188,63,213,0.5,0.5,62,0,0.2,9,10,1,5,4.5,5,0,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (6,3,2016,0,175,75,12648,1298,4076,1384,3929,1005,3419,1063,0,3523,801,21,421,57,3,535,481,1299,610,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (7,3,2017,0,168,75,12744,1286,4024,1367,3146,473,4154,701,0,2325,0,10,505,55,3,490,432,1313,57,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (8,4,2017,0,58,70,6371,521,4963,814,1689,410,3167,1850,1702,1634,394,43,203,12.3,3,55,45.4,119.5,73.2,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (9,4,2016,0,58,77,5672,655,4830,765,1481,308,3012,2100,1942,1198,50,30,144,11.7,3,54.5,47.9,133.6,95.5,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (10,5,2017,0,13,52,4348,57,851,115,1184,61,802,562,519,671,20,26,0,14,2,104,96,304,316,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (11,5,2016,0,13,35,3870,16,874,156,1045,27,771,570,527,578,63,28,0,13.8,2,101,98,283,347,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (12,6,2017,0,576,87,39394,3790,19291,5806,16127,1872,15667,9108,4684,10643,2913,156,1114,118,3,469,418,961,291,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (13,6,2016,0,576,87,35982,3218,17169,5472,15809,1937,14365,9236,4953,9377,1494,163,944,117,3,443,406,822,255,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (14,7,2017,0,27,95,3833,216,1659,88,1974,67,1559,868,130,1206,307,6,NULL,NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (15,7,2016,0,27,95,3834,258,2256,112,3314,63,2724,911,200,1935,123,6,NULL,NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (16,8,2017,0,106,200,814,340,340,11,442,320,600,76,0,106,0,0.2,105,10,1,14,15,25,0,45,'',0.42);
INSERT INTO `financials` VALUES (17,8,2016,0,106,100,653,308,210,14,373,247,440,47,0,95,0,0.1,71,9,1,11,14,27,0,45,NULL,0.42);
INSERT INTO `financials` VALUES (18,9,2017,0,98,100,3001,848,1186,69,2052,812,1800,388,0,1050,12,9,195,33,1,36,36,99,56,NULL,64,NULL);
INSERT INTO `financials` VALUES (19,9,2016,0,98,100,2319,691,1224,60,1530,208,1411,335,0,1008,10,2,392,32,1,37,40,99,76,NULL,64,NULL);
INSERT INTO `financials` VALUES (20,10,2017,0,6,47,207,18,7.8,2.9,96,17,41,0,0,40,0,0.2,7.2,2.5,1,6,7,29,0,3.4,NULL,0);
INSERT INTO `financials` VALUES (21,10,2016,0,6,37,170,6,9.7,2.2,86,14,38,0,0,40,0,0.06,7.2,2,1,6.2,6.2,29,7,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (22,11,2017,0,55.5,140,670,284,2430,34,289,123,970,1366,1028,387,330,51,0,NULL,NULL,NULL,NULL,NULL,NULL,14,NULL,0.25);
INSERT INTO `financials` VALUES (23,11,2016,0,51,140,400,186,790,7,578,447,538,588,505,244,207,9,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (24,12,2017,0,91,322,10030,1519,8968,550,3224,305,5546,2058,1023,4588,2808,43,337,80,3,121,119,286,109,46,NULL,0.51);
INSERT INTO `financials` VALUES (25,12,2016,0,91,300,8987,1252,7397,464,2730,293,4712,1717,1120,3642,2191,41,285,71,3,94,84,211,70,46,NULL,0.51);
INSERT INTO `financials` VALUES (26,13,2017,0,108,110,14479,1946,705,220,19008,1122,6638,4553,3340,8521,2024,171,410,42,2,80,96,273,456,0.1,NULL,0);
INSERT INTO `financials` VALUES (27,13,2016,0,108,110,13492,1562,933,188,15836,619,5652,3319,2245,7799,2236,243,15,39,2,63,73,175,15,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (28,14,2017,0,39.7,29,458,74,89,1.8,186,154,230,0.9,0,44.4,0,0,5.8,5.6,1,1.4,2.4,2.5,0,13,NULL,0.33);
INSERT INTO `financials` VALUES (29,2,2018,0,'',300,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (30,15,2017,0,21,107,2856,210,847,628,1331,48,1454,97,84,627,4,4,92,27,5,58,54,123,19,NULL,NULL,NULL);
INSERT INTO `financials` VALUES (31,15,2016,0,21,90,2676,200,872,570,1097,109,1357,98,60,534,5,6,66,24,5,54,53,150,23,NULL,NULL,NULL);
CREATE TABLE IF NOT EXISTS `companyTags` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`cId`	INTEGER,
	`tagId`	INTEGER
);
CREATE TABLE IF NOT EXISTS `companies` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`name`	TEXT,
	`lId`	INTEGER,
	`tId`	INTEGER,
	`watch`	INTEGER,
	`description`	TEXT,
	`aId`	INTEGER,
	`maId`	INTEGER
);
INSERT INTO `companies` VALUES (1,'Nilörngruppen',8,17,NULL,'labels',10,6);
INSERT INTO `companies` VALUES (2,'Absolent Group',1,33,NULL,'air filters (oil)',11,7);
INSERT INTO `companies` VALUES (3,'Nobia',6,23,NULL,'kitchens',12,8);
INSERT INTO `companies` VALUES (4,'Inwido',7,23,NULL,'windows',20,9);
INSERT INTO `companies` VALUES (5,'BE group',8,29,NULL,'steel',14,10);
INSERT INTO `companies` VALUES (6,'Husqvarna',6,19,NULL,NULL,15,11);
INSERT INTO `companies` VALUES (7,'Bergman & beving',7,23,NULL,NULL,16,12);
INSERT INTO `companies` VALUES (8,'Paradox',1,5,NULL,NULL,18,14);
INSERT INTO `companies` VALUES (9,'Mycronic',7,36,NULL,NULL,19,15);
INSERT INTO `companies` VALUES (10,'Firefly',1,10,NULL,'fire supression',21,16);
INSERT INTO `companies` VALUES (11,'Catena media',7,6,NULL,NULL,23,19);
INSERT INTO `companies` VALUES (12,'Lifco',6,25,NULL,NULL,24,20);
INSERT INTO `companies` VALUES (13,'Bonava',6,7,NULL,'houses',25,21);
INSERT INTO `companies` VALUES (14,'Global gaming',1,6,NULL,NULL,27,NULL);
INSERT INTO `companies` VALUES (15,'Bulten',8,9,NULL,'fasteners for automotive',29,22);
CREATE TABLE IF NOT EXISTS `analysisResults` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`aId`	INTEGER,
	`type`	INTEGER,
	`step`	INTEGER,
	`year`	TEXT,
	`sales`	NUMERIC,
	`ebit`	NUMERIC,
	`ebitMargin`	NUMERIC,
	`salesGrowth`	NUMERIC,
	`reinvestments`	NUMERIC,
	`fcf`	NUMERIC,
	`dcf`	NUMERIC,
	`investedCapital`	NUMERIC
);
INSERT INTO `analysisResults` VALUES (424,12,1,0,'initial',12696,1397,0.11,0,26.1,1063,1063,3291);
INSERT INTO `analysisResults` VALUES (425,12,1,1,'terminal',13013,1041,0.08,0.025,83.7,728,679,3317);
INSERT INTO `analysisResults` VALUES (580,14,1,0,'initial',4109,53.4,0.013,0,27.1,14.6,14.6,1111);
INSERT INTO `analysisResults` VALUES (581,14,1,1,'terminal',4212,71.6,0.017,0.025,27.8,28.1,26.2,1138);
INSERT INTO `analysisResults` VALUES (640,15,1,0,'initial',39000,3900,0.1,0,0,3042,3042,13603);
INSERT INTO `analysisResults` VALUES (641,15,1,1,'terminal',39975,3598,0.09,0.025,349,2458,2290,13603);
INSERT INTO `analysisResults` VALUES (665,16,1,0,'initial',3834,238,0.062,0,64.2,121,121,1349);
INSERT INTO `analysisResults` VALUES (666,16,1,1,'+1',4026,250,0.062,0.05,67.4,127,117,1416);
INSERT INTO `analysisResults` VALUES (667,16,1,2,'+2',4207,261,0.062,0.045,63.4,140,118,1479);
INSERT INTO `analysisResults` VALUES (668,16,1,3,'+3',4375,271,0.062,0.04,58.6,153,118,1538);
INSERT INTO `analysisResults` VALUES (669,16,1,4,'+4',4528,281,0.062,0.035,53.1,166,118,1591);
INSERT INTO `analysisResults` VALUES (670,16,1,5,'+5',4664,289,0.062,0.03,46.9,179,117,1638);
INSERT INTO `analysisResults` VALUES (671,16,1,6,'terminal',4781,296,0.062,0.025,40,191,115,1685);
INSERT INTO `analysisResults` VALUES (881,19,1,0,'initial',2660,532,0.2,0,47.2,368,368,519);
INSERT INTO `analysisResults` VALUES (882,19,1,1,'+1',2926,585,0.2,0.1,51.9,405,370,571);
INSERT INTO `analysisResults` VALUES (883,19,1,2,'+2',3175,635,0.2,0.085,47.8,447,375,619);
INSERT INTO `analysisResults` VALUES (884,19,1,3,'+3',3397,679,0.2,0.07,42.2,488,374,661);
INSERT INTO `analysisResults` VALUES (885,19,1,4,'+4',3584,717,0.2,0.055,34.9,524,367,696);
INSERT INTO `analysisResults` VALUES (886,19,1,5,'+5',3727,745,0.2,0.04,26.4,555,356,722);
INSERT INTO `analysisResults` VALUES (887,19,1,6,'terminal',3820,764,0.2,0.025,16.9,579,340,748);
INSERT INTO `analysisResults` VALUES (911,13,1,0,'initial',6022,602,0.1,0,100,369,369,2108);
INSERT INTO `analysisResults` VALUES (912,13,1,1,'+1',6323,632,0.1,0.05,105,388,363,2213);
INSERT INTO `analysisResults` VALUES (913,13,1,2,'+2',6560,590,0.09,0.038,82,379,332,2295);
INSERT INTO `analysisResults` VALUES (914,13,1,3,'terminal',6724,538,0.08,0.025,56,364,298,2377);
INSERT INTO `analysisResults` VALUES (957,20,1,0,'initial',4500,360,0.08,0,0,281,281,767);
INSERT INTO `analysisResults` VALUES (958,20,1,1,'+1',4500,360,0.08,0,0,281,263,767);
INSERT INTO `analysisResults` VALUES (959,20,1,2,'+2',4523,353,0.078,0.005,3.856,271,238,771);
INSERT INTO `analysisResults` VALUES (960,20,1,3,'+3',4568,347,0.076,0.01,7.789,263,216,779);
INSERT INTO `analysisResults` VALUES (961,20,1,4,'+4',4636,343,0.074,0.015,11.9,256,197,791);
INSERT INTO `analysisResults` VALUES (962,20,1,5,'+5',4729,340,0.072,0.02,16.1,249,180,807);
INSERT INTO `analysisResults` VALUES (963,20,1,6,'terminal',4847,339,0.07,0.025,20.7,244,164,823);
INSERT INTO `analysisResults` VALUES (985,21,1,0,'initial',189,15.1,0.08,0,10.1,1.65,1.65,77.8);
INSERT INTO `analysisResults` VALUES (986,21,1,1,'+1',217,17.4,0.08,0.15,11.7,1.898,1.777,89.4);
INSERT INTO `analysisResults` VALUES (987,21,1,2,'+2',245,19.6,0.08,0.125,10.9,4.322,3.79,100);
INSERT INTO `analysisResults` VALUES (988,21,1,3,'+3',269,21.5,0.08,0.1,9.623,7.16,5.878,110);
INSERT INTO `analysisResults` VALUES (989,21,1,4,'+4',289,23.1,0.08,0.075,7.759,10.3,7.904,118);
INSERT INTO `analysisResults` VALUES (990,21,1,5,'+5',304,24.3,0.08,0.05,5.431,13.5,9.726,123);
INSERT INTO `analysisResults` VALUES (991,21,1,6,'terminal',311,24.9,0.08,0.025,2.783,16.6,11.2,129);
INSERT INTO `analysisResults` VALUES (1018,23,1,0,'initial',535,161,0.3,0,49.5,75.7,75.7,173);
INSERT INTO `analysisResults` VALUES (1019,23,1,1,'+1',749,225,0.3,0.4,69.3,106,100,243);
INSERT INTO `analysisResults` VALUES (1020,23,1,2,'+2',908,272,0.3,0.213,44.6,168,150,287);
INSERT INTO `analysisResults` VALUES (1021,23,1,3,'terminal',931,279,0.3,0.025,5.383,212,180,332);
INSERT INTO `analysisResults` VALUES (1064,24,1,0,'initial',10030,1304,0.13,0,151,866,866,2164);
INSERT INTO `analysisResults` VALUES (1065,24,1,1,'+1',10782,1402,0.13,0.075,162,931,873,2327);
INSERT INTO `analysisResults` VALUES (1066,24,1,2,'+2',11483,1493,0.13,0.065,150,1015,891,2476);
INSERT INTO `analysisResults` VALUES (1067,24,1,3,'+3',12115,1575,0.13,0.055,134,1095,901,2610);
INSERT INTO `analysisResults` VALUES (1068,24,1,4,'+4',12660,1646,0.13,0.045,114,1169,902,2724);
INSERT INTO `analysisResults` VALUES (1069,24,1,5,'+5',13103,1703,0.13,0.035,92.1,1237,894,2817);
INSERT INTO `analysisResults` VALUES (1070,24,1,6,'terminal',13430,1746,0.13,0.025,67.4,1294,877,2909);
INSERT INTO `analysisResults` VALUES (1098,25,1,0,'initial',13986,1455,0.104,0,277,857,857,11368);
INSERT INTO `analysisResults` VALUES (1099,25,1,1,'terminal',14336,1491,0.104,0.025,284,879,825,11646);
INSERT INTO `analysisResults` VALUES (1184,27,1,0,'initial',458,74.7,0.163,0,22.9,35.3,35.3,68.7);
INSERT INTO `analysisResults` VALUES (1185,27,1,1,'+1',687,112,0.163,0.5,34.4,53,48.2,103);
INSERT INTO `analysisResults` VALUES (1186,27,1,2,'+2',867,141,0.163,0.263,22.8,87.5,72.5,126);
INSERT INTO `analysisResults` VALUES (1187,27,1,3,'terminal',889,145,0.163,0.025,2.223,111,83.5,149);
INSERT INTO `analysisResults` VALUES (1209,10,1,0,'initial',606,72.7,0.12,0,13.6,43.1,43.1,150);
INSERT INTO `analysisResults` VALUES (1210,10,1,1,'+1',667,80,0.12,0.1,15,47.4,43.9,165);
INSERT INTO `analysisResults` VALUES (1211,10,1,2,'+2',723,86.8,0.12,0.085,13.8,53.9,46.2,178);
INSERT INTO `analysisResults` VALUES (1212,10,1,3,'+3',774,92.9,0.12,0.07,12.2,60.3,47.8,191);
INSERT INTO `analysisResults` VALUES (1213,10,1,4,'+4',816,98,0.12,0.055,10.1,66.3,48.8,201);
INSERT INTO `analysisResults` VALUES (1214,10,1,5,'+5',849,102,0.12,0.04,7.624,71.9,48.9,208);
INSERT INTO `analysisResults` VALUES (1215,10,1,6,'terminal',870,104,0.12,0.025,4.884,76.6,48.3,216);
INSERT INTO `analysisResults` VALUES (1242,18,1,0,'initial',734,330,0.45,0,18.1,240,240,91.5);
INSERT INTO `analysisResults` VALUES (1243,18,1,1,'+1',915,412,0.45,0.247,22.6,299,273,114);
INSERT INTO `analysisResults` VALUES (1244,18,1,2,'+2',1121,504,0.45,0.225,25.2,368,307,139);
INSERT INTO `analysisResults` VALUES (1245,18,1,3,'+3',1348,607,0.45,0.203,27.3,446,339,167);
INSERT INTO `analysisResults` VALUES (1246,18,1,4,'+4',1591,716,0.45,0.18,28.7,530,367,195);
INSERT INTO `analysisResults` VALUES (1247,18,1,5,'+5',1843,829,0.45,0.158,29.2,618,391,225);
INSERT INTO `analysisResults` VALUES (1248,18,1,6,'+6',2094,942,0.45,0.136,28.5,706,408,253);
INSERT INTO `analysisResults` VALUES (1249,18,1,7,'+7',2332,1049,0.45,0.114,26.5,792,417,280);
INSERT INTO `analysisResults` VALUES (1250,18,1,8,'+8',2546,1146,0.45,0.092,23.3,870,418,303);
INSERT INTO `analysisResults` VALUES (1251,18,1,9,'+9',2722,1225,0.45,0.069,18.9,937,410,322);
INSERT INTO `analysisResults` VALUES (1252,18,1,10,'+10',2851,1283,0.45,0.047,13.5,987,395,335);
INSERT INTO `analysisResults` VALUES (1253,18,1,11,'terminal',2922,1315,0.45,0.025,7.305,1018,372,349);
INSERT INTO `analysisResults` VALUES (1275,28,1,0,'initial',451,85.7,0.19,0,21.7,45.1,45.1,133);
INSERT INTO `analysisResults` VALUES (1276,28,1,1,'+1',539,102,0.19,0.195,25.9,53.9,49.2,159);
INSERT INTO `analysisResults` VALUES (1277,28,1,2,'+2',626,119,0.19,0.161,24.9,67.9,56.5,184);
INSERT INTO `analysisResults` VALUES (1278,28,1,3,'+3',705,134,0.19,0.127,22.1,82.4,62.6,206);
INSERT INTO `analysisResults` VALUES (1279,28,1,4,'+4',771,146,0.19,0.093,17.7,96.5,66.9,224);
INSERT INTO `analysisResults` VALUES (1280,28,1,5,'+5',816,155,0.19,0.059,11.9,109,69,235);
INSERT INTO `analysisResults` VALUES (1281,28,1,6,'terminal',837,159,0.19,0.025,5.162,119,68.6,247);
INSERT INTO `analysisResults` VALUES (1296,11,1,0,'initial',490,93.1,0.19,0,54.4,18.2,18.2,175);
INSERT INTO `analysisResults` VALUES (1297,11,1,1,'+1',711,135,0.19,0.45,78.9,26.4,24.1,254);
INSERT INTO `analysisResults` VALUES (1298,11,1,2,'+2',970,184,0.19,0.365,87.4,56.4,46.9,342);
INSERT INTO `analysisResults` VALUES (1299,11,1,3,'+3',1241,236,0.19,0.28,85.8,98.2,74.6,427);
INSERT INTO `analysisResults` VALUES (1300,11,1,4,'+4',1483,282,0.19,0.195,71.4,148,103,499);
INSERT INTO `analysisResults` VALUES (1301,11,1,5,'+5',1647,313,0.19,0.11,44.7,199,126,543);
INSERT INTO `analysisResults` VALUES (1302,11,1,6,'terminal',1688,321,0.19,0.025,10.4,240,138,588);
INSERT INTO `analysisResults` VALUES (1303,29,1,0,'initial',2766,230,0.083,0,88.1,90.9,90.9,1403);
INSERT INTO `analysisResults` VALUES (1304,29,1,1,'+1',2951,245,0.083,0.067,94,97,89.1,1497);
INSERT INTO `analysisResults` VALUES (1305,29,1,2,'+2',3124,259,0.083,0.059,87.1,115,97.1,1584);
INSERT INTO `analysisResults` VALUES (1306,29,1,3,'+3',3281,272,0.083,0.05,78.3,134,104,1663);
INSERT INTO `analysisResults` VALUES (1307,29,1,4,'+4',3418,284,0.083,0.042,67.9,153,109,1731);
INSERT INTO `analysisResults` VALUES (1308,29,1,5,'+5',3532,293,0.083,0.033,56.1,173,113,1787);
INSERT INTO `analysisResults` VALUES (1309,29,1,6,'terminal',3621,301,0.083,0.025,43,191,115,1843);
CREATE TABLE IF NOT EXISTS `analysis` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`cId`	INTEGER,
	`sales`	NUMERIC,
	`ebitMargin`	NUMERIC,
	`terminalEbitMargin`	NUMERIC,
	`salesGrowth`	NUMERIC,
	`terminalGrowth`	NUMERIC,
	`beta`	NUMERIC,
	`riskyCompany`	INTEGER,
	`growthYears`	INTEGER,
	`salesPerCapital`	NUMERIC,
	`riskFreeRate`	NUMERIC,
	`marketPremium`	NUMERIC,
	`wacc`	NUMERIC,
	`tax`	NUMERIC,
	`salesGrowthMode`	INTEGER,
	`ebitMarginMode`	INTEGER,
	`financialsMode`	INTEGER,
	`growthValueDiscounted`	NUMERIC,
	`terminalValueDiscounted`	NUMERIC,
	`totalValue`	NUMERIC,
	`shares`	NUMERIC,
	`sharePrice`	NUMERIC,
	`shareValue`	NUMERIC,
	`rebate`	NUMERIC,
	`year`	INTEGER,
	`qId`	INTEGER
);
INSERT INTO `analysis` VALUES (10,1,606,0.12,0.12,0.1,0.025,1,0,5,4.455,0.025,0.1,0.08,0.22,1,1,0,236,948,1183,11.4,85,104,0.221,2017,0);
INSERT INTO `analysis` VALUES (11,2,490,0.19,0.19,0.45,0.025,1,0,5,4.052,0.025,0.1,0.096,0.22,1,1,0,375,2135,2509,11.3,300,222,-0.26,2018,0);
INSERT INTO `analysis` VALUES (12,3,12696,0.11,0.08,0.008,0.025,1,0,0,3.889,0.025,0.1,0.073,0.22,1,1,0,0,15175,15175,168,75,90.3,0.204,NULL,NULL);
INSERT INTO `analysis` VALUES (13,4,6022,0.1,0.08,0.05,0.025,1,0,2,3,0.025,0.1,0.068,0.22,1,1,0,695,7412,8107,58,70,140,0.997,NULL,NULL);
INSERT INTO `analysis` VALUES (14,5,4109,0.013,0.017,0.025,0.025,1,0,0,3.791,0.025,0.1,0.07,0.22,1,1,0,0,624,624,13,52,48,-0.077,NULL,NULL);
INSERT INTO `analysis` VALUES (15,6,39000,0.1,0.09,0,0.025,1,0,0,2.867,0.025,0.1,0.073,0.22,1,1,0,0,51201,51201,576,87,88.9,0.022,NULL,NULL);
INSERT INTO `analysis` VALUES (16,7,3834,0.062,0.062,0.05,0.025,1,0,5,2.985,0.025,0.1,0.089,0.22,1,1,0,588,1950,2538,27,95,94,-0.011,NULL,NULL);
INSERT INTO `analysis` VALUES (18,8,734,0.45,0.45,0.247,0.025,1,0,10,10,0.025,0.1,0.096,0.22,1,1,0,3723,5735,9458,106,200,89.2,-0.554,2017,0);
INSERT INTO `analysis` VALUES (19,9,2660,0.2,0.2,0.1,0.025,1,0,5,5.64,0.025,0.1,0.093,0.22,1,1,0,1841,5459,7300,98,100,74.5,-0.255,NULL,NULL);
INSERT INTO `analysis` VALUES (20,4,4500,0.08,0.07,0,0.025,1,0,5,5.864,0.025,0.1,0.068,0.22,1,1,0,1093,4084,5176,58,70,89.2,0.275,NULL,NULL);
INSERT INTO `analysis` VALUES (21,10,189,0.08,0.08,0.15,0.025,1,0,5,2.795,0.025,0.1,0.068,0.22,1,1,0,29.1,278,307,6,47,51.2,0.089,NULL,NULL);
INSERT INTO `analysis` VALUES (23,11,535,0.3,0.3,0.4,0.025,1,0,2,4.323,0.025,0.1,0.057,0.22,1,1,0,250,5942,6193,55.5,140,112,-0.203,NULL,NULL);
INSERT INTO `analysis` VALUES (24,12,10030,0.13,0.13,0.075,0.025,1,0,5,4.982,0.025,0.1,0.067,0.22,1,1,0,4461,22285,26746,91,322,294,-0.087,NULL,NULL);
INSERT INTO `analysis` VALUES (25,13,13986,0.104,0.104,0.025,0.025,1,0,0,1.261,0.025,0.1,0.065,0.22,1,1,0,0,21967,21967,108,110,203,0.849,NULL,NULL);
INSERT INTO `analysis` VALUES (27,14,458,0.163,0.163,0.5,0.025,1,0,2,10,0.025,0.1,0.099,0.22,1,1,0,121,1240,1360,39.7,29,34.3,0.181,NULL,NULL);
INSERT INTO `analysis` VALUES (28,2,451,0.19,0.19,0.195,0.025,1,0,5,4.052,0.025,0.1,0.096,0.22,1,1,0,304,1058,1362,11.3,200,121,-0.397,2017,0);
INSERT INTO `analysis` VALUES (29,15,2766,0.083,0.083,0.067,0.025,1,0,5,2.103,0.025,0.1,0.089,0.22,1,1,0,512,1952,2464,21,107,117,0.097,2017,0);
COMMIT;
