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
	`financialsMode`	INTEGER
);
INSERT INTO `magicFormula` VALUES (6,1,77.8,979,136,0.326,0);
INSERT INTO `magicFormula` VALUES (7,2,85.7,1623,111,0.412,0);
INSERT INTO `magicFormula` VALUES (8,3,1479,13887,3276,0.279,0);
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
	`leasingY5Up`	NUMERIC
);
INSERT INTO `financials` VALUES (1,1,2016,0,11.4,110,610,75,49,40.7,221.7,35,137.8,5,0,128,25.5,1.4,34,19,5,12,10,11.7,0);
INSERT INTO `financials` VALUES (2,1,2015,0,11.4,45,527,50.8,39.4,29.9,193,31.5,113.3,5,0,114,26.5,0.93,40,19,5,10,6.5,8.5,0);
INSERT INTO `financials` VALUES (3,1,2017,0,11.4,85,680,82,62,43,250,44,153,1.2,0,157,35.7,1.1,41,18,5,13.8,11.3,13.6,1.8);
INSERT INTO `financials` VALUES (4,2,2017,0,11.3,150,491,85.6,118,43,259,105,265,0.4,0.4,102,0,1,10,14,1,6.5,6,11,2);
INSERT INTO `financials` VALUES (5,2,2016,0,11.3,120,411,78.9,94,42,188,63,213,0.5,0.5,62,0,0.2,9,10,1,5,4.5,5,0);
INSERT INTO `financials` VALUES (6,3,2016,0,175,75,12648,1298,4076,1384,3929,1005,3419,1063,0,3523,801,21,421,57,3,535,481,1299,610);
INSERT INTO `financials` VALUES (7,3,2017,0,168,75,12744,1286,4024,1367,3146,473,4154,701,0,2325,0,10,505,55,3,490,432,1313,57);
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
INSERT INTO `companies` VALUES (1,'Nilörngruppen',8,17,NULL,NULL,10,6);
INSERT INTO `companies` VALUES (2,'Absolent Group',1,33,NULL,NULL,11,7);
INSERT INTO `companies` VALUES (3,'Nobia',7,23,NULL,NULL,12,8);
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
INSERT INTO `analysisResults` VALUES (377,10,1,0,'initial',606,72.7,0.12,0,13.6,43.1,43.1,150);
INSERT INTO `analysisResults` VALUES (378,10,1,1,'+1',667,80,0.12,0.1,15,47.4,43.9,165);
INSERT INTO `analysisResults` VALUES (379,10,1,2,'+2',723,86.8,0.12,0.085,13.8,53.9,46.2,178);
INSERT INTO `analysisResults` VALUES (380,10,1,3,'+3',774,92.9,0.12,0.07,12.2,60.3,47.8,191);
INSERT INTO `analysisResults` VALUES (381,10,1,4,'+4',816,98,0.12,0.055,10.1,66.3,48.8,201);
INSERT INTO `analysisResults` VALUES (382,10,1,5,'+5',849,102,0.12,0.04,7.624,71.9,48.9,208);
INSERT INTO `analysisResults` VALUES (383,10,1,6,'terminal',870,104,0.12,0.025,4.884,76.6,48.3,216);
INSERT INTO `analysisResults` VALUES (398,11,1,0,'initial',490,93.1,0.19,0,18.1,54.5,54.5,139);
INSERT INTO `analysisResults` VALUES (399,11,1,1,'+1',564,107,0.19,0.15,20.9,62.7,57.2,160);
INSERT INTO `analysisResults` VALUES (400,11,1,2,'+2',634,120,0.19,0.125,19.6,74.4,61.9,179);
INSERT INTO `analysisResults` VALUES (401,11,1,3,'+3',697,132,0.19,0.1,17.2,86.1,65.4,197);
INSERT INTO `analysisResults` VALUES (402,11,1,4,'+4',750,142,0.19,0.075,13.9,97.2,67.4,211);
INSERT INTO `analysisResults` VALUES (403,11,1,5,'+5',787,150,0.19,0.05,9.713,107,67.6,220);
INSERT INTO `analysisResults` VALUES (404,11,1,6,'terminal',807,153,0.19,0.025,4.978,115,66.1,230);
INSERT INTO `analysisResults` VALUES (424,12,1,0,'initial',12696,1397,0.11,0,26.1,1063,1063,3291);
INSERT INTO `analysisResults` VALUES (425,12,1,1,'terminal',13013,1041,0.08,0.025,83.7,728,679,3317);
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
	`rebate`	NUMERIC
);
INSERT INTO `analysis` VALUES (10,1,606,0.12,0.12,0.1,0.025,1,0,5,4.455,0.025,0.1,0.08,0.22,1,1,0,236,948,1183,11.4,85,104,0.221);
INSERT INTO `analysis` VALUES (11,2,490,0.19,0.19,0.15,0.025,1,0,5,4.052,0.025,0.1,0.096,0.22,1,1,0,320,1021,1340,11.3,150,119,-0.209);
INSERT INTO `analysis` VALUES (12,3,12696,0.11,0.08,0.008,0.025,1,0,0,3.889,0.025,0.1,0.073,0.22,1,1,0,0,15175,15175,168,75,90.3,0.204);
COMMIT;
