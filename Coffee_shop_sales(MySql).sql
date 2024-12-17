CREATE DATABASE coffee_shop_sales_database;
USE coffee_shop_sales_database;
RENAME TABLE `coffee shop sales` TO coffee_shop_sales;
SELECT * FROM coffee_shop_sales;
DESCRIBE coffee_shop_sales;

-- Change data types
UPDATE coffee_shop_sales 
SET transaction_date = STR_TO_DATE(transaction_date,'%m/%d/%Y');
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%h:%i:%s %p');
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

-- Date analysis
SELECT ROUND(SUM(transaction_qty * unit_price),2) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 3; -- Month in numbers

SELECT MONTH(transaction_date) AS Months,
ROUND(SUM(transaction_qty * unit_price)) AS total_sales,
(SUM(transaction_qty * unit_price) - LAG(SUM(transaction_qty * unit_price),1) OVER (ORDER BY MONTH(transaction_date))) /
LAG(SUM(transaction_qty * unit_price),1) OVER (ORDER BY MONTH(transaction_date)) * 100 AS mon_incease_percent
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)  -- (previous month,current month)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

SELECT COUNT(transaction_id) AS total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;

SELECT MONTH(transaction_date) AS Month, ROUND(COUNT(transaction_id)) AS Total_orders,
(COUNT(transaction_id) - LAG(COUNT(transaction_id),1) OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id),1) 
OVER (ORDER BY MONTH(transaction_date)) * 100 AS mnth_increase_percent
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

SELECT SUM(transaction_qty) AS total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 6;

SELECT MONTH(transaction_date) AS Month, ROUND(SUM(transaction_qty)) AS Total_orders,
(SUM(transaction_qty) - LAG(SUM(transaction_qty),1) OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty),1) 
OVER (ORDER BY MONTH(transaction_date)) * 100 AS mnth_increase_percent
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

SELECT CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS Total_sales,
CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS Total_qty,
CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS Total_orders
FROM coffee_shop_sales
WHERE transaction_date = '2023-03-27';

SELECT CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends' ELSE 'Weekdays' END AS Day_Type,
CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'k') AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends' ELSE 'Weekdays' END;

SELECT store_location, CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC; 

SELECT CONCAT(ROUND(AVG(Total_sales)/1000,1),'K') AS Avg_sales FROM
(SELECT SUM(transaction_qty * unit_price) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY transaction_date) AS Internal_query;  -- AVG Sales line

SELECT DAY(transaction_date) AS Day_of_mnth, SUM(transaction_qty * unit_price) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date);

SELECT
	Day_of_month,
	CASE 
		WHEN total_sales > avg_sales THEN 'Above Average'
		WHEN total_sales < avg_sales THEN 'Below Average'
		ELSE 'Equal to Average'
	END AS Sales_status,
	total_sales
FROM (
	SELECT  
		DAY(transaction_date) AS Day_of_month,
	SUM(unit_price * transaction_qty) AS total_sales,
	AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
FROM coffee_shop_sales 
WHERE MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date)
) AS sales_data; 

SELECT product_category,CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC; -- Sales by product 

SELECT product_type,CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
limit 10; -- Top 10 product by sales

SELECT SUM(unit_price * transaction_qty) AS Total_sales, SUM(transaction_qty) AS Total_qty, COUNT(*) AS Total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 
AND DAYOFWEEK(transaction_date) = 1
AND HOUR(transaction_time) = 14; -- Sales by Day an Hour

SELECT HOUR(transaction_time), SUM(unit_price * transaction_qty) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);

SELECT 
	CASE
		WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Sunday'
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        ELSE 'Saturday'
	END AS 'Day_of_week',
    ROUND(SUM(unit_price * transaction_qty)) AS Total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY 
		CASE
			WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Sunday'
			WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
			WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
			WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
			WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
			WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
			ELSE 'Saturday'
		END;  -- sales by day
    

