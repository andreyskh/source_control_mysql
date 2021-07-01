-- Проверяем если есть БД. В ней Таблицы Actor,Language,Film,Film_actor, а в таблицах данные - ничего делать не надо, просто переходим к сьемке ролика
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE sakila;

--
-- Create table `language`
--
CREATE TABLE language (
  language_id tinyint UNSIGNED NOT NULL AUTO_INCREMENT,
  name char(20) NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (language_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 7,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create table `film`
--
CREATE TABLE film (
  film_id smallint UNSIGNED NOT NULL AUTO_INCREMENT,
  title varchar(255) NOT NULL,
  description text DEFAULT NULL,
  release_year year DEFAULT NULL,
  language_id tinyint UNSIGNED NOT NULL,
  original_language_id tinyint UNSIGNED DEFAULT NULL,
  rental_duration tinyint UNSIGNED NOT NULL DEFAULT 3,
  rental_rate decimal(4, 2) NOT NULL DEFAULT 4.99,
  length smallint UNSIGNED DEFAULT NULL,
  replacement_cost decimal(5, 2) NOT NULL DEFAULT 19.99,
  rating enum ('G', 'PG', 'PG-13', 'R', 'NC-17') DEFAULT 'G',
  special_features set ('Trailers', 'Commentaries', 'Deleted Scenes', 'Behind the Scenes') DEFAULT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1001,
AVG_ROW_LENGTH = 196,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_fk_language_id` on table `film`
--
ALTER TABLE film
ADD INDEX idx_fk_language_id (language_id);

--
-- Create index `idx_fk_original_language_id` on table `film`
--
ALTER TABLE film
ADD INDEX idx_fk_original_language_id (original_language_id);

--
-- Create index `idx_title` on table `film`
--
ALTER TABLE film
ADD INDEX idx_title (title);

--
-- Create foreign key
--
ALTER TABLE film
ADD CONSTRAINT fk_film_language FOREIGN KEY (language_id)
REFERENCES language (language_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE film
ADD CONSTRAINT fk_film_language_original FOREIGN KEY (original_language_id)
REFERENCES language (language_id) ON UPDATE CASCADE;

--
-- Create table `actor`
--
CREATE TABLE actor (
  actor_id smallint UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name varchar(45) NOT NULL,
  last_name varchar(45) NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 201,
AVG_ROW_LENGTH = 81,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_actor_last_name` on table `actor`
--
ALTER TABLE actor
ADD INDEX idx_actor_last_name (last_name);

--
-- Create table `film_actor`
--
CREATE TABLE film_actor (
  actor_id smallint UNSIGNED NOT NULL,
  film_id smallint UNSIGNED NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id, film_id)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 35,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_fk_film_id` on table `film_actor`
--
ALTER TABLE film_actor
ADD INDEX idx_fk_film_id (film_id);

--
-- Create foreign key
--
ALTER TABLE film_actor
ADD CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id)
REFERENCES actor (actor_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE film_actor
ADD CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id)
REFERENCES film (film_id) ON UPDATE CASCADE;