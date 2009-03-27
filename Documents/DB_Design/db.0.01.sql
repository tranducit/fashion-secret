SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `fashion` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `fashion`;

-- -----------------------------------------------------
-- Table `fashion`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `fashion`.`user` ;

CREATE  TABLE IF NOT EXISTS `fashion`.`user` (
  `user_id` INT NOT NULL ,
  `email` VARCHAR(200) NOT NULL ,
  `nickname` VARCHAR(45) NOT NULL ,
  `password` VARCHAR(45) NOT NULL COMMENT 'saved in encrypted form' ,
  `gender` TINYINT NULL ,
  `register_time` DATETIME NULL ,
  `last_login_time` DATETIME NULL ,
  `birthday` DATE NULL ,
  `location` VARCHAR(45) NULL ,
  `city` VARCHAR(45) NULL ,
  `description` VARCHAR(500) NULL ,
  `blog` VARCHAR(45) NULL COMMENT 'url' ,
  `icon` VARCHAR(500) NULL COMMENT 'the PATH to the image' ,
  `is_public` TINYINT NULL COMMENT '0 = private, 1 = public, 2 = only friends' ,
  PRIMARY KEY (`user_id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `fashion`.`dress`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `fashion`.`dress` ;

CREATE  TABLE IF NOT EXISTS `fashion`.`dress` (
  `dress_id` INT NOT NULL ,
  `dress_name` VARCHAR(500) NULL ,
  `type` VARCHAR(45) NULL COMMENT '类型' ,
  `gender` TINYINT NULL COMMENT '0=female; 1=male; 2=neutral' ,
  `colors` VARCHAR(45) NULL COMMENT 'TODO' ,
  `seasons` VARCHAR(45) NULL ,
  `size` VARCHAR(45) NULL COMMENT 'S/M/L/XL/XXL/XS/....\n42\'\n\nTODO' ,
  `price` DECIMAL(10) NULL ,
  `image` VARCHAR(500) NULL COMMENT 'PATH to the image' ,
  `owner` INT NULL ,
  `buy_from` VARCHAR(45) NULL COMMENT 'shopping or e-shopping\n' ,
  PRIMARY KEY (`dress_id`) ,
  CONSTRAINT `fk_dress_user`
    FOREIGN KEY (`owner` )
    REFERENCES `fashion`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX fk_dress_user ON `fashion`.`dress` (`owner` ASC) ;


-- -----------------------------------------------------
-- Table `fashion`.`user_dress_tag`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `fashion`.`user_dress_tag` ;

CREATE  TABLE IF NOT EXISTS `fashion`.`user_dress_tag` (
  `id` INT NOT NULL ,
  `tag` VARCHAR(45) NULL ,
  `user_id` INT NULL ,
  `dress_id` INT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
