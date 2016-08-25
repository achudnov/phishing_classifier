SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `pages`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `pages` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `pages` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `registered_on` DATETIME NULL ,
  `updated_on` DATETIME NULL ,
  `expires_on` DATETIME NULL ,
  `ttl` INT UNSIGNED NULL ,
  `as_number` INT UNSIGNED NULL ,
  `ip_address_for_hostname` TINYINT(1)  NULL ,
  `num_host_components` INT UNSIGNED NULL ,
  `url_length` INT UNSIGNED NULL ,
  `redirects` TINYINT(1)  NULL ,
  `outbound_links` DOUBLE NULL ,
  `has_password` TINYINT(1)  NULL ,
  `has_iframes` TINYINT(1)  NULL ,
  `phishing` TINYINT(1)  NULL ,
  `hostname_length` INT NULL ,
  `url` TEXT NULL ,
  `html_error` TINYINT(1)  NULL DEFAULT 0 ,
  `url_error` TINYINT(1)  NULL DEFAULT 0 ,
  `whois_error` TINYINT(1)  NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `registrars`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `registrars` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `registrars` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` TEXT NULL ,
  `page_id` INT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `registrants`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `registrants` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `registrants` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` TEXT NULL ,
  `page_id` INT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `tlds`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tlds` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `tlds` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `tld` VARCHAR(45) NULL ,
  `page_id` INT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `country_codes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `country_codes` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `country_codes` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `code` VARCHAR(10) NULL ,
  `page_id` INT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `words`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `words` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `words` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `word` TEXT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `url_word_frequencies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `url_word_frequencies` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `url_word_frequencies` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `frequency` DOUBLE NOT NULL ,
  `word_id` INT NOT NULL ,
  `page_id` INT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `page_word_frequencies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `page_word_frequencies` ;

SHOW WARNINGS;
CREATE  TABLE IF NOT EXISTS `page_word_frequencies` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `frequency` DOUBLE NOT NULL ,
  `word_id` INT NOT NULL ,
  `page_id` INT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;

SHOW WARNINGS;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
