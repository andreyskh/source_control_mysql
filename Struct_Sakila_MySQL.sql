
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE sakila;

--
-- Create table `country`
--
CREATE TABLE country (
  country_id smallint UNSIGNED NOT NULL AUTO_INCREMENT,
  country varchar(50) NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (country_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 110,
AVG_ROW_LENGTH = 150,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create table `city`
--
CREATE TABLE city (
  city_id smallint UNSIGNED NOT NULL AUTO_INCREMENT,
  city varchar(50) NOT NULL,
  country_id smallint UNSIGNED NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (city_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 601,
AVG_ROW_LENGTH = 81,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_fk_country_id` on table `city`
--
ALTER TABLE city
ADD INDEX idx_fk_country_id (country_id);

--
-- Create foreign key
--
ALTER TABLE city
ADD CONSTRAINT fk_city_country FOREIGN KEY (country_id)
REFERENCES country (country_id) ON UPDATE CASCADE;

--
-- Create table `address`
--
CREATE TABLE address (
  address_id smallint UNSIGNED NOT NULL AUTO_INCREMENT,
  address varchar(50) NOT NULL,
  address2 varchar(50) DEFAULT NULL,
  district varchar(20) NOT NULL,
  city_id smallint UNSIGNED NOT NULL,
  postal_code varchar(10) DEFAULT NULL,
  phone varchar(20) NOT NULL,
  location geometry NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (address_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 606,
AVG_ROW_LENGTH = 163,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_fk_city_id` on table `address`
--
ALTER TABLE address
ADD INDEX idx_fk_city_id (city_id);

--
-- Create index `idx_location` on table `address`
--
ALTER TABLE address
ADD SPATIAL INDEX idx_location (location);

--
-- Create foreign key
--
ALTER TABLE address
ADD CONSTRAINT fk_address_city FOREIGN KEY (city_id)
REFERENCES city (city_id) ON UPDATE CASCADE;

--
-- Create table `store`
--
CREATE TABLE store (
  store_id tinyint UNSIGNED NOT NULL AUTO_INCREMENT,
  manager_staff_id tinyint UNSIGNED NOT NULL,
  address_id smallint UNSIGNED NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (store_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_unique_manager` on table `store`
--
ALTER TABLE store
ADD UNIQUE INDEX idx_unique_manager (manager_staff_id);

--
-- Create index `idx_fk_address_id` on table `store`
--
ALTER TABLE store
ADD INDEX idx_fk_address_id (address_id);

--
-- Create foreign key
--
ALTER TABLE store
ADD CONSTRAINT fk_store_address FOREIGN KEY (address_id)
REFERENCES address (address_id) ON UPDATE CASCADE;

--
-- Create table `customer`
--
CREATE TABLE customer (
  customer_id smallint UNSIGNED NOT NULL AUTO_INCREMENT,
  store_id tinyint UNSIGNED NOT NULL,
  first_name varchar(45) NOT NULL,
  last_name varchar(45) NOT NULL,
  email varchar(50) DEFAULT NULL,
  address_id smallint UNSIGNED NOT NULL,
  active tinyint(1) NOT NULL DEFAULT 1,
  create_date datetime NOT NULL,
  last_update timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (customer_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 600,
AVG_ROW_LENGTH = 136,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_fk_store_id` on table `customer`
--
ALTER TABLE customer
ADD INDEX idx_fk_store_id (store_id);

--
-- Create index `idx_fk_address_id` on table `customer`
--
ALTER TABLE customer
ADD INDEX idx_fk_address_id (address_id);

--
-- Create index `idx_last_name` on table `customer`
--
ALTER TABLE customer
ADD INDEX idx_last_name (last_name);

--
-- Create foreign key
--
ALTER TABLE customer
ADD CONSTRAINT fk_customer_address FOREIGN KEY (address_id)
REFERENCES address (address_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE customer
ADD CONSTRAINT fk_customer_store FOREIGN KEY (store_id)
REFERENCES store (store_id) ON UPDATE CASCADE;

DELIMITER $$

--
-- Create trigger `customer_create_date`
--
CREATE 
	DEFINER = 'root'@'localhost'
TRIGGER customer_create_date
	BEFORE INSERT
	ON customer
	FOR EACH ROW
SET NEW.create_date = NOW()
$$

DELIMITER ;

--
-- Create view `customer_list`
--
CREATE
DEFINER = 'root'@'localhost'
VIEW customer_list
AS
SELECT
  `cu`.`customer_id` AS `ID`,
  CONCAT(`cu`.`first_name`, _utf8mb3 ' ', `cu`.`last_name`) AS `name`,
  `a`.`address` AS `address`,
  `a`.`postal_code` AS `zip code`,
  `a`.`phone` AS `phone`,
  `city`.`city` AS `city`,
  `country`.`country` AS `country`,
  IF(`cu`.`active`, _utf8mb3 'active', _utf8mb3 '') AS `notes`,
  `cu`.`store_id` AS `SID`
FROM (((`customer` `cu`
  JOIN `address` `a`
    ON ((`cu`.`address_id` = `a`.`address_id`)))
  JOIN `city`
    ON ((`a`.`city_id` = `city`.`city_id`)))
  JOIN `country`
    ON ((`city`.`country_id` = `country`.`country_id`)));

--
-- Create table `staff`
--
CREATE TABLE staff (
  staff_id tinyint UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name varchar(45) NOT NULL,
  last_name varchar(45) NOT NULL,
  address_id smallint UNSIGNED NOT NULL,
  picture blob DEFAULT NULL,
  email varchar(50) DEFAULT NULL,
  store_id tinyint UNSIGNED NOT NULL,
  active tinyint(1) NOT NULL DEFAULT 1,
  username varchar(16) NOT NULL,
  password varchar(40) binary CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (staff_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 32768,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_fk_store_id` on table `staff`
--
ALTER TABLE staff
ADD INDEX idx_fk_store_id (store_id);

--
-- Create index `idx_fk_address_id` on table `staff`
--
ALTER TABLE staff
ADD INDEX idx_fk_address_id (address_id);

--
-- Create foreign key
--
ALTER TABLE staff
ADD CONSTRAINT fk_staff_address FOREIGN KEY (address_id)
REFERENCES address (address_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE staff
ADD CONSTRAINT fk_staff_store FOREIGN KEY (store_id)
REFERENCES store (store_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE store
ADD CONSTRAINT fk_store_staff FOREIGN KEY (manager_staff_id)
REFERENCES staff (staff_id) ON UPDATE CASCADE;

--
-- Create view `staff_list`
--
CREATE
DEFINER = 'root'@'localhost'
VIEW staff_list
AS
SELECT
  `s`.`staff_id` AS `ID`,
  CONCAT(`s`.`first_name`, _utf8mb3 ' ', `s`.`last_name`) AS `name`,
  `a`.`address` AS `address`,
  `a`.`postal_code` AS `zip code`,
  `a`.`phone` AS `phone`,
  `city`.`city` AS `city`,
  `country`.`country` AS `country`,
  `s`.`store_id` AS `SID`
FROM (((`staff` `s`
  JOIN `address` `a`
    ON ((`s`.`address_id` = `a`.`address_id`)))
  JOIN `city`
    ON ((`a`.`city_id` = `city`.`city_id`)))
  JOIN `country`
    ON ((`city`.`country_id` = `country`.`country_id`)));

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
-- Create index `idx_title` on table `film`
--
ALTER TABLE film
ADD INDEX idx_title (title);

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
-- Create table `inventory`
--
CREATE TABLE inventory (
  inventory_id mediumint UNSIGNED NOT NULL AUTO_INCREMENT,
  film_id smallint UNSIGNED NOT NULL,
  store_id tinyint UNSIGNED NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (inventory_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4582,
AVG_ROW_LENGTH = 39,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_fk_film_id` on table `inventory`
--
ALTER TABLE inventory
ADD INDEX idx_fk_film_id (film_id);

--
-- Create index `idx_store_id_film_id` on table `inventory`
--
ALTER TABLE inventory
ADD INDEX idx_store_id_film_id (store_id, film_id);

--
-- Create foreign key
--
ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_film FOREIGN KEY (film_id)
REFERENCES film (film_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_store FOREIGN KEY (store_id)
REFERENCES store (store_id) ON UPDATE CASCADE;

--
-- Create table `rental`
--
CREATE TABLE rental (
  rental_id int NOT NULL AUTO_INCREMENT,
  rental_date datetime NOT NULL,
  inventory_id mediumint UNSIGNED NOT NULL,
  customer_id smallint UNSIGNED NOT NULL,
  return_date datetime DEFAULT NULL,
  staff_id tinyint UNSIGNED NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (rental_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 16050,
AVG_ROW_LENGTH = 99,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `rental_date` on table `rental`
--
ALTER TABLE rental
ADD UNIQUE INDEX rental_date (rental_date, inventory_id, customer_id);

--
-- Create index `idx_fk_inventory_id` on table `rental`
--
ALTER TABLE rental
ADD INDEX idx_fk_inventory_id (inventory_id);

--
-- Create index `idx_fk_customer_id` on table `rental`
--
ALTER TABLE rental
ADD INDEX idx_fk_customer_id (customer_id);

--
-- Create index `idx_fk_staff_id` on table `rental`
--
ALTER TABLE rental
ADD INDEX idx_fk_staff_id (staff_id);

--
-- Create foreign key
--
ALTER TABLE rental
ADD CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id)
REFERENCES customer (customer_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE rental
ADD CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id)
REFERENCES inventory (inventory_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE rental
ADD CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id)
REFERENCES staff (staff_id) ON UPDATE CASCADE;

DELIMITER $$

--
-- Create trigger `rental_date`
--
CREATE 
	DEFINER = 'root'@'localhost'
TRIGGER rental_date
	BEFORE INSERT
	ON rental
	FOR EACH ROW
SET NEW.rental_date = NOW()
$$

--
-- Create function `inventory_in_stock`
--
CREATE
DEFINER = 'root'@'localhost'
FUNCTION inventory_in_stock (p_inventory_id int)
RETURNS tinyint(1)
READS SQL DATA
BEGIN
  DECLARE v_rentals int;
  DECLARE v_out int;




  SELECT
    COUNT(*) INTO v_rentals
  FROM rental
  WHERE inventory_id = p_inventory_id;

  IF v_rentals = 0 THEN
    RETURN TRUE;
  END IF;

  SELECT
    COUNT(rental_id) INTO v_out
  FROM inventory
    LEFT JOIN rental USING (inventory_id)
  WHERE inventory.inventory_id = p_inventory_id
  AND rental.return_date IS NULL;

  IF v_out > 0 THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END
$$

--
-- Create procedure `film_not_in_stock`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE film_not_in_stock (IN p_film_id int, IN p_store_id int, OUT p_film_count int)
READS SQL DATA
BEGIN
  SELECT
    inventory_id
  FROM inventory
  WHERE film_id = p_film_id
  AND store_id = p_store_id
  AND NOT inventory_in_stock(inventory_id);

  SELECT
    FOUND_ROWS() INTO p_film_count;
END
$$

--
-- Create procedure `film_in_stock`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE film_in_stock (IN p_film_id int, IN p_store_id int, OUT p_film_count int)
READS SQL DATA
BEGIN
  SELECT
    inventory_id
  FROM inventory
  WHERE film_id = p_film_id
  AND store_id = p_store_id
  AND inventory_in_stock(inventory_id);

  SELECT
    FOUND_ROWS() INTO p_film_count;
END
$$

--
-- Create function `inventory_held_by_customer`
--
CREATE
DEFINER = 'root'@'localhost'
FUNCTION inventory_held_by_customer (p_inventory_id int)
RETURNS int(11)
READS SQL DATA
BEGIN
  DECLARE v_customer_id int;
  DECLARE EXIT HANDLER FOR NOT FOUND RETURN NULL;

  SELECT
    customer_id INTO v_customer_id
  FROM rental
  WHERE return_date IS NULL
  AND inventory_id = p_inventory_id;

  RETURN v_customer_id;
END
$$

DELIMITER ;

--
-- Create table `payment`
--
CREATE TABLE payment (
  payment_id smallint UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id smallint UNSIGNED NOT NULL,
  staff_id tinyint UNSIGNED NOT NULL,
  rental_id int DEFAULT NULL,
  amount decimal(5, 2) NOT NULL,
  payment_date datetime NOT NULL,
  last_update timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (payment_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 16050,
AVG_ROW_LENGTH = 98,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_fk_staff_id` on table `payment`
--
ALTER TABLE payment
ADD INDEX idx_fk_staff_id (staff_id);

--
-- Create index `idx_fk_customer_id` on table `payment`
--
ALTER TABLE payment
ADD INDEX idx_fk_customer_id (customer_id);

--
-- Create foreign key
--
ALTER TABLE payment
ADD CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id)
REFERENCES customer (customer_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE payment
ADD CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id)
REFERENCES rental (rental_id) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE payment
ADD CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id)
REFERENCES staff (staff_id) ON UPDATE CASCADE;

DELIMITER $$

--
-- Create trigger `payment_date`
--
CREATE 
	DEFINER = 'root'@'localhost'
TRIGGER payment_date
	BEFORE INSERT
	ON payment
	FOR EACH ROW
SET NEW.payment_date = NOW()
$$

--
-- Create function `get_customer_balance`
--
CREATE
DEFINER = 'root'@'localhost'
FUNCTION get_customer_balance (p_customer_id int, p_effective_date datetime)
RETURNS decimal(5, 2)
DETERMINISTIC
READS SQL DATA
BEGIN








  DECLARE v_rentfees decimal(5, 2);
  DECLARE v_overfees integer;
  DECLARE v_payments decimal(5, 2);

  SELECT
    IFNULL(SUM(film.rental_rate), 0) INTO v_rentfees
  FROM film,
       inventory,
       rental
  WHERE film.film_id = inventory.film_id
  AND inventory.inventory_id = rental.inventory_id
  AND rental.rental_date <= p_effective_date
  AND rental.customer_id = p_customer_id;

  SELECT
    IFNULL(SUM(IF((TO_DAYS(rental.return_date) - TO_DAYS(rental.rental_date)) > film.rental_duration,
    ((TO_DAYS(rental.return_date) - TO_DAYS(rental.rental_date)) - film.rental_duration), 0)), 0) INTO v_overfees
  FROM rental,
       inventory,
       film
  WHERE film.film_id = inventory.film_id
  AND inventory.inventory_id = rental.inventory_id
  AND rental.rental_date <= p_effective_date
  AND rental.customer_id = p_customer_id;


  SELECT
    IFNULL(SUM(payment.amount), 0) INTO v_payments
  FROM payment

  WHERE payment.payment_date <= p_effective_date
  AND payment.customer_id = p_customer_id;

  RETURN v_rentfees + v_overfees - v_payments;
END
$$

--
-- Create procedure `rewards_report`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE rewards_report (IN min_monthly_purchases tinyint UNSIGNED
, IN min_dollar_amount_purchased decimal(10, 2) UNSIGNED
, OUT count_rewardees int)
READS SQL DATA
COMMENT 'Provides a customizable report on best customers'
proc:
  BEGIN

    DECLARE last_month_start date;
    DECLARE last_month_end date;


    IF min_monthly_purchases = 0 THEN
      SELECT
        'Minimum monthly purchases parameter must be > 0';
      LEAVE proc;
    END IF;
    IF min_dollar_amount_purchased = 0.00 THEN
      SELECT
        'Minimum monthly dollar amount purchased parameter must be > $0.00';
      LEAVE proc;
    END IF;


    SET last_month_start = DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH);
    SET last_month_start = STR_TO_DATE(CONCAT(YEAR(last_month_start), '-', MONTH(last_month_start), '-01'), '%Y-%m-%d');
    SET last_month_end = LAST_DAY(last_month_start);


    CREATE TEMPORARY TABLE tmpCustomer (
      customer_id smallint UNSIGNED NOT NULL PRIMARY KEY
    );


    INSERT INTO tmpCustomer (customer_id)
      SELECT
        p.customer_id
      FROM payment AS p
      WHERE DATE(p.payment_date) BETWEEN last_month_start AND last_month_end
      GROUP BY customer_id
      HAVING SUM(p.amount) > min_dollar_amount_purchased
      AND COUNT(customer_id) > min_monthly_purchases;


    SELECT
      COUNT(*)
    FROM tmpCustomer INTO count_rewardees;


    SELECT
      c.*
    FROM tmpCustomer AS t
      INNER JOIN customer AS c
        ON t.customer_id = c.customer_id;


    DROP TABLE tmpCustomer;
  END
  $$

DELIMITER ;

--
-- Create view `sales_by_store`
--
CREATE
DEFINER = 'root'@'localhost'
VIEW sales_by_store
AS
SELECT
  CONCAT(`c`.`city`, _utf8mb3 ',', `cy`.`country`) AS `store`,
  CONCAT(`m`.`first_name`, _utf8mb3 ' ', `m`.`last_name`) AS `manager`,
  SUM(`p`.`amount`) AS `total_sales`
FROM (((((((`payment` `p`
  JOIN `rental` `r`
    ON ((`p`.`rental_id` = `r`.`rental_id`)))
  JOIN `inventory` `i`
    ON ((`r`.`inventory_id` = `i`.`inventory_id`)))
  JOIN `store` `s`
    ON ((`i`.`store_id` = `s`.`store_id`)))
  JOIN `address` `a`
    ON ((`s`.`address_id` = `a`.`address_id`)))
  JOIN `city` `c`
    ON ((`a`.`city_id` = `c`.`city_id`)))
  JOIN `country` `cy`
    ON ((`c`.`country_id` = `cy`.`country_id`)))
  JOIN `staff` `m`
    ON ((`s`.`manager_staff_id` = `m`.`staff_id`)))
GROUP BY `s`.`store_id`
ORDER BY `cy`.`country`, `c`.`city`;

--
-- Create table `category`
--
CREATE TABLE category (
  category_id tinyint UNSIGNED NOT NULL AUTO_INCREMENT,
  name varchar(25) NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (category_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 17,
AVG_ROW_LENGTH = 1024,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create table `film_category`
--
CREATE TABLE film_category (
  film_id smallint UNSIGNED NOT NULL,
  category_id tinyint UNSIGNED NOT NULL,
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id, category_id)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 65,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create foreign key
--
ALTER TABLE film_category
ADD CONSTRAINT fk_film_category_category FOREIGN KEY (category_id)
REFERENCES category (category_id) ON UPDATE CASCADE;

--
-- Create foreign key
--
ALTER TABLE film_category
ADD CONSTRAINT fk_film_category_film FOREIGN KEY (film_id)
REFERENCES film (film_id) ON UPDATE CASCADE;

--
-- Create view `sales_by_film_category`
--
CREATE
DEFINER = 'root'@'localhost'
VIEW sales_by_film_category
AS
SELECT
  `c`.`name` AS `category`,
  SUM(`p`.`amount`) AS `total_sales`
FROM (((((`payment` `p`
  JOIN `rental` `r`
    ON ((`p`.`rental_id` = `r`.`rental_id`)))
  JOIN `inventory` `i`
    ON ((`r`.`inventory_id` = `i`.`inventory_id`)))
  JOIN `film` `f`
    ON ((`i`.`film_id` = `f`.`film_id`)))
  JOIN `film_category` `fc`
    ON ((`f`.`film_id` = `fc`.`film_id`)))
  JOIN `category` `c`
    ON ((`fc`.`category_id` = `c`.`category_id`)))
GROUP BY `c`.`name`
ORDER BY `total_sales` DESC;

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

--
-- Create view `nicer_but_slower_film_list`
--
CREATE
DEFINER = 'root'@'localhost'
VIEW nicer_but_slower_film_list
AS
SELECT
  `film`.`film_id` AS `FID`,
  `film`.`title` AS `title`,
  `film`.`description` AS `description`,
  `category`.`name` AS `category`,
  `film`.`rental_rate` AS `price`,
  `film`.`length` AS `length`,
  `film`.`rating` AS `rating`,
  GROUP_CONCAT(CONCAT(CONCAT(UPPER(SUBSTR(`actor`.`first_name`, 1, 1)), LOWER(SUBSTR(`actor`.`first_name`, 2, LENGTH(`actor`.`first_name`))), _utf8mb3 ' ', CONCAT(UPPER(SUBSTR(`actor`.`last_name`, 1, 1)), LOWER(SUBSTR(`actor`.`last_name`, 2, LENGTH(`actor`.`last_name`)))))) SEPARATOR ', ') AS `actors`
FROM ((((`category`
  LEFT JOIN `film_category`
    ON ((`category`.`category_id` = `film_category`.`category_id`)))
  LEFT JOIN `film`
    ON ((`film_category`.`film_id` = `film`.`film_id`)))
  JOIN `film_actor`
    ON ((`film`.`film_id` = `film_actor`.`film_id`)))
  JOIN `actor`
    ON ((`film_actor`.`actor_id` = `actor`.`actor_id`)))
GROUP BY `film`.`film_id`,
         `category`.`name`;

--
-- Create view `film_list`
--
CREATE
DEFINER = 'root'@'localhost'
VIEW film_list
AS
SELECT
  `film`.`film_id` AS `FID`,
  `film`.`title` AS `title`,
  `film`.`description` AS `description`,
  `category`.`name` AS `category`,
  `film`.`rental_rate` AS `price`,
  `film`.`length` AS `length`,
  `film`.`rating` AS `rating`,
  GROUP_CONCAT(CONCAT(`actor`.`first_name`, _utf8mb3 ' ', `actor`.`last_name`) SEPARATOR ', ') AS `actors`
FROM ((((`category`
  LEFT JOIN `film_category`
    ON ((`category`.`category_id` = `film_category`.`category_id`)))
  LEFT JOIN `film`
    ON ((`film_category`.`film_id` = `film`.`film_id`)))
  JOIN `film_actor`
    ON ((`film`.`film_id` = `film_actor`.`film_id`)))
  JOIN `actor`
    ON ((`film_actor`.`actor_id` = `actor`.`actor_id`)))
GROUP BY `film`.`film_id`,
         `category`.`name`;

--
-- Create view `actor_info`
--
CREATE
DEFINER = 'root'@'localhost'
SQL SECURITY INVOKER
VIEW actor_info
AS
SELECT
  `a`.`actor_id` AS `actor_id`,
  `a`.`first_name` AS `first_name`,
  `a`.`last_name` AS `last_name`,
  GROUP_CONCAT(DISTINCT CONCAT(`c`.`name`, ': ', (SELECT
      GROUP_CONCAT(`f`.`title` ORDER BY `f`.`title` ASC SEPARATOR ', ')
    FROM ((`film` `f`
      JOIN `film_category` `fc`
        ON ((`f`.`film_id` = `fc`.`film_id`)))
      JOIN `film_actor` `fa`
        ON ((`f`.`film_id` = `fa`.`film_id`)))
    WHERE ((`fc`.`category_id` = `c`.`category_id`)
    AND (`fa`.`actor_id` = `a`.`actor_id`)))) ORDER BY `c`.`name` ASC SEPARATOR '; ') AS `film_info`
FROM (((`actor` `a`
  LEFT JOIN `film_actor` `fa`
    ON ((`a`.`actor_id` = `fa`.`actor_id`)))
  LEFT JOIN `film_category` `fc`
    ON ((`fa`.`film_id` = `fc`.`film_id`)))
  LEFT JOIN `category` `c`
    ON ((`fc`.`category_id` = `c`.`category_id`)))
GROUP BY `a`.`actor_id`,
         `a`.`first_name`,
         `a`.`last_name`;

--
-- Create table `film_text`
--
CREATE TABLE film_text (
  film_id smallint NOT NULL,
  title varchar(255) NOT NULL,
  description text DEFAULT NULL,
  PRIMARY KEY (film_id)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 180,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Create index `idx_title_description` on table `film_text`
--
ALTER TABLE film_text
ADD FULLTEXT INDEX idx_title_description (title, description);

DELIMITER $$

--
-- Create trigger `upd_film`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER upd_film
AFTER UPDATE
ON film
FOR EACH ROW
BEGIN
  IF (old.title != new.title)
    OR (old.description != new.description)
    OR (old.film_id != new.film_id) THEN
    UPDATE film_text
    SET title = new.title,
        description = new.description,
        film_id = new.film_id
    WHERE film_id = old.film_id;
  END IF;
END
$$

--
-- Create trigger `ins_film`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER ins_film
AFTER INSERT
ON film
FOR EACH ROW
BEGIN
  INSERT INTO film_text (film_id, title, description)
    VALUES (new.film_id, new.title, new.description);
END
$$

--
-- Create trigger `del_film`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER del_film
AFTER DELETE
ON film
FOR EACH ROW
BEGIN
  DELETE
    FROM film_text
  WHERE film_id = old.film_id;
END
$$

DELIMITER ;

