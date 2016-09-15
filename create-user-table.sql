CREATE TABLE `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(100) NOT NULL,
  `password_hash` VARCHAR(32) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `referral` INT,
  FOREIGN KEY (`referral`)
	REFERENCES `users`(`id`),
  UNIQUE INDEX `username` (`username` ASC),
  PRIMARY KEY (`id`));
INSERT INTO `users` (`username`, `password_hash`, `name`, `email`, `referral`) VALUES ("administrator", "21232f297a57a5a743894a0e4a801fc3", "The Administrator", "dummy@dummy.dummy", 1);
CREATE TABLE `referral` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user` INT NOT NULL,
  `code` VARCHAR(32) NOT NULL,
  `timestamp` TIMESTAMP,
  FOREIGN KEY (`user`)
	REFERENCES `users`(`id`),
  UNIQUE INDEX `code` (`code` ASC),
  PRIMARY KEY (`id`));
