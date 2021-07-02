
--  CОЗДАНИЕ БАЗЫ ДАННЫХ ИНТЕРНЕ МАГАЗИНА

/*
 
Кратккое описание деятельности - занимается онлайн торговлей электротехнической продукции, инфраструктура бизнеса:
1 покупатели (физические лица)
2 поставщики
3 отгрузка:
 - со своих складов
 - складов поставщиков 

*/

-- СОЗДАЕМ СТРУКТУРУ БД

-- Покупатели 

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
id SERIAL PRIMARY KEY,
surname VARCHAR(100) COMMENT 'фамилия покупателя',
name VARCHAR(100) COMMENT 'имя покупателя',
phone VARCHAR(100) NOT NULL UNIQUE COMMENT 'телефон покупателя',
e_mail VARCHAR(100) NOT NULL UNIQUE COMMENT 'мэйл',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Персональные данные покупателей

DROP TABLE IF EXISTS data_customers;
CREATE TABLE data_customers (
user_id BIGINT UNSIGNED NOT NULL  COMMENT 'ссылка на пользователя',
gender ENUM('male','female') COMMENT 'пол',
birthday DATE COMMENT 'день рождение',
address VARCHAR(255) NOT NULL UNIQUE COMMENT 'адрес проживания',
area VARCHAR(150) COMMENT 'регион',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


--  Каталог продукции

DROP TABLE IF EXISTS 
;
CREATE TABLE catalogs (
id SERIAL PRIMARY KEY,
name VARCHAR(100) COMMENT 'название категории товара',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Наименование товаров

DROP TABLE IF EXISTS products;
CREATE TABLE products (
id SERIAL PRIMARY KEY,
name VARCHAR(100) COMMENT 'Название товара',
price DECIMAL (10,2) COMMENT ' Стоимость товара',
catalog_id BIGINT UNSIGNED NOT NULL COMMENT 'Ссылка на категорию товара',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Перечень заказов

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
id SERIAL PRIMARY KEY,
customer_id BIGINT UNSIGNED COMMENT 'Ссылка на покупателя',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Состав заказа

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
id SERIAL PRIMARY KEY,
orders_id BIGINT UNSIGNED COMMENT 'Ссылка на заказы',
products_id BIGINT UNSIGNED COMMENT 'Ссылка на товары',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Наименование складов

DROP TABLE IF EXISTS storehouse;
CREATE TABLE storehouse (
id SERIAL PRIMARY KEY,
name VARCHAR(100) COMMENT 'Название склада',
address VARCHAR(150) COMMENT 'Адрес склада',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Наличие товаров на складе

DROP TABLE IF EXISTS storehouse_remaining;
CREATE TABLE storehouse_remaining (
id SERIAL PRIMARY KEY,
storehouse_id BIGINT UNSIGNED COMMENT 'Ссылка на склад',
products_id BIGINT UNSIGNED COMMENT 'Ссылка на товары',
remains INT UNSIGNED COMMENT 'Остатки на складе',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица хранит историю удалений клиентов

DROP TABLE IF EXISTS customers_backup;
CREATE TABLE customers_backup(
id BIGINT,
surname VARCHAR(100) COMMENT 'фамилия покупателя',
name VARCHAR(100) COMMENT 'имя покупателя',
phone VARCHAR(100) NOT NULL UNIQUE COMMENT 'телефон покупателя',
e_mail VARCHAR(100) NOT NULL UNIQUE COMMENT 'мэйл',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP);

DROP TABLE IF EXISTS data_customers_backup;
CREATE TABLE data_customers_backup (
user_id BIGINT UNSIGNED NOT NULL  COMMENT 'ссылка на пользователя',
gender CHAR(1) COMMENT 'пол',
birthday DATE COMMENT 'день рождение',
address VARCHAR(255) NOT NULL UNIQUE COMMENT 'адрес проживания',
area VARCHAR(150) COMMENT 'регион',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- СОЗДАЕМ ВНЕШНИЕ КЛЮЧИ

 ALTER TABLE data_customers
 	ADD CONSTRAINT data_customers_user_id_fk
 		FOREIGN KEY (user_id) REFERENCES customers(id)
 		ON UPDATE CASCADE;

ALTER TABLE products 
	ADD CONSTRAINT products_catalog_id_fk
		FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
		ON UPDATE CASCADE;

ALTER TABLE orders 
	ADD CONSTRAINT orders_customer_id_fk
		FOREIGN KEY (customer_id) REFERENCES customers(id)
		ON DELETE SET NULL 
		ON UPDATE CASCADE;
			
ALTER TABLE orders_products 
	ADD CONSTRAINT orders_products_orders_id_fk
		FOREIGN KEY (orders_id) REFERENCES orders(id)
		ON DELETE SET NULL 
		ON UPDATE CASCADE;
	
ALTER TABLE orders_products 
	ADD CONSTRAINT orders_products_products_id_fk
		FOREIGN KEY (products_id) REFERENCES products(id)
		ON DELETE SET NULL 
		ON UPDATE CASCADE;
	
		
ALTER TABLE storehouse_remaining 
	ADD CONSTRAINT storehouse_remaining_storehouse_id_fk
		FOREIGN KEY (storehouse_id) REFERENCES storehouse(id)
		ON DELETE SET NULL 
		ON UPDATE CASCADE;
	
ALTER TABLE storehouse_remaining 
	ADD CONSTRAINT storehouse_remaining_products_id_fk
		FOREIGN KEY (products_id) REFERENCES products(id)
		ON DELETE SET NULL 
		ON UPDATE CASCADE;
		
-- СОЗДАЕМ ИНДЕКСЫ
	
CREATE INDEX customers_surname_idx ON customers(surname, name);	
CREATE INDEX products_name_idx ON products (name);


-- СОЗДАЕМ ТРИГЕРЫ

-- При удаление данных из таблицы customers данные будут копироваться в таблицу history \backup

CREATE TRIGGER customers_backup BEFORE DELETE ON customers
FOR EACH ROW 
INSERT INTO customers_backup SET id=OLD.id, surname=OLD.surname, phone=OLD.phone, e_mail =OLD.e_mail;

-- При удаление данных из таблицы customers данные будут копироваться в таблицу history \backup

CREATE TRIGGER data_customers_backup BEFORE DELETE ON data_customers
FOR EACH ROW 
INSERT INTO 
data_customers_backup SET user_id=OLD.user_id,gender=OLD.gender,birthday=OLD.birthday,address=OLD.address,area=OLD.area;

-- ТЕСТИРУЕМ ТАБЛИЦЫ ПОСЛЕ ЗАГРУЗКИ ТЕСТОВЫХ ДАННЫХ

SELECT * FROM customers;

-- Исправляем столбец phone
UPDATE customers SET phone = CONCAT_WS('-','+7', FLOOR(1+RAND()*1000), FLOOR(10+RAND()*1000),FLOOR(10+RAND()*100), FLOOR(10+RAND()*90));

SELECT * FROM data_customers;
SELECT * FROM catalogs;
SELECT * FROM products;

-- Исправляем столбец catalog_id, конвертируем сортировку в случайную 
UPDATE products SET catalog_id = FLOOR(1+RAND()*9); 
DELETE FROM catalogs WHERE id >10;

SELECT * FROM orders;
-- Исправляем столбец customer_id, конвертируем сортировку в случайную 
UPDATE orders SET customer_id = FLOOR(1+RAND()*100); 

SELECT * FROM orders_products;

-- Исправляем столбец orders_id products_id, конвертируем сортировку в случайную 
UPDATE orders_products SET orders_id = FLOOR(1+RAND()*100);
UPDATE orders_products SET products_id = FLOOR(1+RAND()*100);

SELECT * FROM storehouse;
-- Уменьшаем кол-во экземпляров до 8
DELETE FROM storehouse WHERE id > 8;

SELECT * FROM storehouse_remaining;

-- Исправляем столбец orders_id products_id, конвертируем сортировку в случайную 

UPDATE storehouse_remaining SET storehouse_id = FLOOR(1+RAND()*8);
UPDATE storehouse_remaining SET products_id = FLOOR(1+RAND()*100);

-- Тестируем агрегацию

SELECT surname, COUNT(orders_id) AS total_orders FROM orders 
	LEFT JOIN customers 
	ON orders.customer_id  = customers.id
	LEFT JOIN orders_products 
	ON orders.id = orders_products.orders_id
	GROUP BY customer_id 
	WHERE ;

SELECT CONCAT(surname, ' ',customers.name) AS surname, COUNT(orders_id) AS total, MAX(price) AS max_price FROM orders 
	LEFT JOIN customers 
	ON orders.customer_id  = customers.id
	LEFT JOIN orders_products
	ON orders.id  = orders_products.orders_id
	LEFT JOIN products 
	ON products.id = orders_products.products_id
	LEFT JOIN catalogs 
	ON catalogs.id = products.catalog_id
	WHERE catalogs.id = 1
	GROUP BY orders.id;

SELECT CONCAT(surname, ' ',customers.name) AS surname, products.name, products.price 
FROM orders 
LEFT JOIN customers 
	ON orders.customer_id  = customers.id
LEFT JOIN orders_products
	ON orders.id  = orders_products.orders_id
LEFT JOIN products 
	ON products.id = orders_products.products_id
LEFT JOIN catalogs 
	ON catalogs.id = products.catalog_id
WHERE catalogs.id = 8 ;

SELECT customers.surname, AVG(products.price) AS average, SUM(products.price) AS total
FROM orders_products 
LEFT JOIN products 
	ON products.id = products_id
LEFT JOIN orders 
	ON orders.id = orders_id 
LEFT JOIN customers 
	ON customers.id = orders.customer_id 
GROUP BY orders_products.orders_id ;

--  Используя оконные функции

SELECT DISTINCT customers.surname, 
AVG(products.price) OVER w AS average,
SUM(products.price) OVER w AS total,
MAX(products.price) OVER w AS max_price,
COUNT(products.price) OVER w AS total_goods,
ROUND((SUM(products.price) OVER w / SUM(products.price) OVER() * 100),2) AS '%%'
FROM orders_products 
LEFT JOIN products 
	ON products.id = products_id
LEFT JOIN orders 
	ON orders.id = orders_id 
LEFT JOIN customers 
	ON customers.id = orders.customer_id
	WINDOW w AS (PARTITION BY orders_products.orders_id);
       
--  Создадим представление
SELECT @price_max:= MAX(price) FROM products;
SELECT @avg_price:= AVG(price) FROM products;


CREATE VIEW customers_detail AS SELECT surname, name, phone FROM customers;
SELECT * FROM customers_detail ;

CREATE VIEW products_decade AS SELECT id, name, price 
FROM products
WHERE price < 100000;

SELECT * FROM products_decade;


