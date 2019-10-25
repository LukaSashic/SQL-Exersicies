-- LINE_ITEM

-- Select the entire line_item table

SELECT *
  FROM line_item

-- Select only the first 10 rows from the line_item table

SELECT *
  FROM line_item
LIMIT 10

-- Select only the columns sku, unit_price and date from the line_item table (and only the first 10 rows)

SELECT sku, unit_price, date
  FROM line_item
LIMIT 10

-- Count the total number of rows of the line_item table

SELECT COUNT(*)
  FROM line_item
  
-- Count the total number of unique "sku" from the line_item table

  
SELECT COUNT(DISTINCT sku)
  FROM line_item
  
-- Generate a list with the average price of each sku
--  …now name the column of the previous query with the average price "avg_price", and sort the list that you by that column (bigger to smaller price)
  
SELECT sku, AVG(unit_price) AS avg_price
  FROM line_item
GROUP BY sku
ORDER BY avg_price DESC

-- Which products were bought in largest quantities?
-- select the 100 lines with the biggest "product quantity"


SELECT sku, product_quantity
 FROM line_item
ORDER BY product_quantity DESC
LIMIT 100
 
-- ORDERS

-- How many orders were placed in total?

SELECT COUNT(id_order)
FROM orders


-- Make a count of orders by their state

SELECT state, COUNT(id_order)
FROM orders
GROUP BY state


-- Select all the orders placed in January of 2017

SELECT id_order, created_date
FROM orders
WHERE created_date LIKE '2017-01%'
ORDER BY created_date

-- Count the number of orders of your previous select query (i.e. How many orders were placed in January of 2017?)

SELECT COUNT(id_order)
FROM orders
WHERE created_date LIKE '2017-01%'


-- How many orders were cancelled on January 4th 2017?

SELECT COUNT(id_order)
FROM orders
WHERE created_date LIKE '2017-01-04%'  AND state = 'Cancelled'

-- How many orders have been placed each month of the year?

SELECT COUNT(id_order)
FROM orders
WHERE created_date LIKE '2017-01-04%'  AND state = 'Cancelled'


-- How many orders have been placed each month of the year?

SELECT COUNT(id_order), EXTRACT(MONTH FROM created_date) as month_extracted
FROM orders
GROUP BY month_extracted
ORDER BY month_extracted

-- What is the total amount paid in all the orders?

SELECT SUM(total_paid)
FROM orders

-- What is the average amount paid per order?

SELECT SUM(total_paid)/COUNT(id_order) AS average_amount_paid
FROM orders

-- Give a result to the previous question with only 2 decimals

SELECT ROUND(SUM(total_paid)/COUNT(id_order),2) AS average_amount_paid
FROM orders

-- What is the date of the newest order? And the oldest?

SELECT MAX(created_date) AS newest_order, MIN(created_date) AS oldest_order
FROM orders

-- What is the day with the highest amount of completed orders (and how many completed orders were placed that day)?

SELECT COUNT(id_order) AS highest_number_of_orders, DATE(created_date) AS transaction_date
FROM orders
WHERE  state = "Completed"
GROUP BY transaction_date
ORDER BY highest_number_of_orders DESC
LIMIT 1

-- What is the day with the highest amount paid (and how much was paid that day)?

SELECT SUM(total_paid) AS highest_daily_total, DATE(created_date) AS transaction_date
FROM orders
WHERE  state = "Completed"
GROUP BY DATE(created_date)
ORDER BY highest_daily_total DESC
LIMIT 1

-- PRODUCTS

-- How many products are there?

SELECT COUNT(DISTINCT ProductId) AS number_of_unique_products
FROM products


-- How many brands?

SELECT COUNT(DISTINCT Brand) AS number_of_unique_brands
FROM products

-- How many categories?


SELECT COUNT(DISTINCT manual_categories) AS number_of_unique_categories
FROM products

-- How many products per brand 

SELECT Brand AS brands, COUNT(DISTINCT ProductId) AS number_of_products
FROM products
GROUP BY brands
ORDER BY number_of_products DESC

-- & products per category?

SELECT manual_categories AS unique_categories, COUNT(DISTINCT ProductId) AS number_of_products
FROM products
GROUP BY unique_categories
ORDER BY number_of_products DESC

-- What's the average price per brand 

SELECT Brand AS brand, ROUND(AVG(price),2) AS average_price
FROM products
GROUP BY brand

-- and the average price per category?

SELECT manual_categories AS categories, ROUND(AVG(price),2) AS average_price
FROM products
GROUP BY categories

--  	What's the name and description of the most expensive product per brand and per category?

SELECT name_en as product_name, short_desc_en AS description, p.brand, price
FROM ( SELECT brand, MAX(price) as maxprice FROM products p GROUP BY brand) AS temp
INNER JOIN products AS p 
ON p.brand = temp.brand AND p.price=temp.maxprice
ORDER BY temp.maxprice DESC

SELECT name_en as product_name, short_desc_en AS description, p.manual_categories, price
FROM ( SELECT manual_categories, MAX(price) as maxprice FROM products p GROUP BY manual_categories) AS temp
INNER JOIN products AS p 
ON p.manual_categories = temp.manual_categories AND p.price=temp.maxprice
ORDER BY temp.maxprice DESC

-- JOINS

-- Query 1. Our first query should return the "sku", "product_quantity", "date" and "unit_price" from the line_item table together with the "name" and the "price" of each product from the "products" table. We want only products present in both tables.

SELECT p.name_en, l.product_quantity AS quantity, l.date, l.unit_price,  p.price, l.sku
FROM line_item l
INNER JOIN products p
ON l.sku = p.sku
LIMIT 100

-- Query 2. You might notice that the unit_price from the line_item table and the price from the product table is not the same. Let's investigate that! Extend your previous query by adding a column with the difference in price. Name that column price_difference.

SELECT p.name_en, l.product_quantity AS quantity, l.date, l.unit_price,  p.price, p.price - l.unit_price AS price_difference, l.sku
FROM line_item l
INNER JOIN products p
ON l.sku = p.sku
LIMIT 100

-- Query 3. Build a query that outputs the price difference that you just calculated, grouping products by category. Round the result.

SELECT  p.manual_categories, AVG(p.price - l.unit_price) AS price_difference
FROM line_item l
INNER JOIN products p
ON l.sku = p.sku
GROUP BY p.manual_categories


-- Query 4. Create the same query as before (calculating the price difference between the line_item and the products tables, but now grouping by brands instead of categories.

SELECT  p.brand, AVG(p.price - l.unit_price) AS price_difference
FROM line_item l
INNER JOIN products p
ON l.sku = p.sku
GROUP BY p.brand


-- Query 5. Let's focus on the brands with a big price difference: run the same query as before, but now limiting the results to only brands with an avg_price_dif of more than 50000. Order the results by avg_price_dif (bigger to smaller).

SELECT  p.brand, AVG(p.price - l.unit_price) AS avg_price_difference
FROM line_item l
INNER JOIN products p
ON l.sku = p.sku
GROUP BY p.brand
HAVING AVG(p.price - l.unit_price) > 50000
ORDER BY avg_price_difference DESC

-- Query 6. First, we will connect each product (sku) from the line_item table to the orders table. We only want sku that have been in any order. This table will contain duplicates, and we're ok with that. We will group and count this information later.

SELECT l.sku
FROM line_item l
JOIN orders o
ON l.id_order = o.id_order
LIMIT 100

-- Query 7. Now, add to the previous query the brand and the category from the products table to this query.

SELECT p.brand, p.manual_categories, l.sku
FROM line_item l
JOIN orders o
ON l.id_order = o.id_order
JOIN products p
ON l.sku=p.sku
LIMIT 100

-- Query 8. Let's keep working on the same query: now we want to keep only Cancelled orders. Modify this query to group the results from the previous query, first by category and then by brand, adding in both cases a count so we know which categories and which brands are most times present in Cancelled orders.

SELECT p.manual_categories, COUNT(o.id_order) AS Cnt, o.state
FROM line_item l
JOIN orders o
ON l.id_order = o.id_order
JOIN products p
ON l.sku=p.sku
GROUP BY p.manual_categories, o.state
HAVING o.state = "Cancelled" AND Cnt > 200
ORDER BY Cnt DESC

SELECT p.brand, COUNT(o.id_order) AS Cnt, o.state
FROM line_item l
JOIN orders o
ON l.id_order = o.id_order
JOIN products p
ON l.sku=p.sku
GROUP BY p.brand, o.state
HAVING o.state = "Cancelled" AND Cnt > 200
ORDER BY Cnt DESC


