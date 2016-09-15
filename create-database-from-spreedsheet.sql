CREATE TABLE `ead` (
  `datasource` varchar(255) NOT NULL,
  `recdate` date NOT NULL,
  `totalcount` int(11) NOT NULL,
  `positive` decimal(5,2) DEFAULT NULL,
  `net` decimal(5,2) DEFAULT NULL,
  `appappdis` decimal(5,2) DEFAULT NULL,
  `country` varchar(255) not null,
  `source` varchar(255) DEFAULT NULL,
  `timestamp` timestamp,
  `user` int,
  FOREIGN KEY (`user`)
	REFERENCES `users`(`id`),
  PRIMARY KEY (`datasource`,`recdate`,`country`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/Honduras.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';
LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/argentina.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';
LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/bolivia.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/brazil.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/chile.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/colombia.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/CostaRica.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/DominicanRepublic.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';
LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/Ecuador.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/ElSalvador.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/Gautemala.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/mexico.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';


LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/Nicaragua.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/panama.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';
LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/paraguay.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/peru.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/uruguay.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

LOAD DATA LOCAL INFILE 'C:/Users/Jack/Dropbox/Executive Approval Database/Venezuela.txt' 
INTO TABLE ead COLUMNS TERMINATED BY '\t';

SET SQL_SAFE_UPDATES = 0;
UPDATE ead SET country = TRIM(TRAILING '\r' FROM country);
UPDATE ead SET appappdis = 100 * positive/(positive + positive - Net) WHERE Net!=0 and appappdis=0;
UPDATE ead SET appappdis = NULL, Net = NULL WHERE appappdis = 0;
SET SQL_SAFE_UPDATES = 1;

CREATE TABLE `series_information` (
  `country` VARCHAR(60) NOT NULL,
  `series` VARCHAR(60) NOT NULL,
  `description` VARCHAR(256) NULL,
  `question_type` VARCHAR(45) NULL,
  `question_wording` VARCHAR(300) NULL,
  `timestamp` timestamp,
  `user` int,
  FOREIGN KEY (`user`)
	REFERENCES `users`(`id`),
  PRIMARY KEY (`country`, `series`));

LOAD DATA LOCAL INFILE 'C:/xampp/tomcat/webapps/ROOT/Executive Approval Database/series-information.txt' 
	INTO TABLE series_information CHARACTER SET 'utf8' COLUMNS TERMINATED BY '\t';
SET SQL_SAFE_UPDATES = 0;
UPDATE series_information SET question_wording = TRIM(TRAILING '\r' FROM question_wording);
SET SQL_SAFE_UPDATES = 1;
