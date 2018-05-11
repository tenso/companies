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
CREATE TABLE IF NOT EXISTS `quarters` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`name`	TEXT
);
INSERT INTO `quarters` VALUES (1,'FY');
INSERT INTO `quarters` VALUES (2,'Q1');
INSERT INTO `quarters` VALUES (3,'Q2');
INSERT INTO `quarters` VALUES (4,'Q3');
INSERT INTO `quarters` VALUES (5,'Q4');
CREATE TABLE IF NOT EXISTS `notes` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`cId`	INTEGER,
	`date`	TEXT,
	`note`	TEXT
);
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
	`leaingY5Up`	NUMERIC
);
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
	`description`	TEXT
);
COMMIT;
