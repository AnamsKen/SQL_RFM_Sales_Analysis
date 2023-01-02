 CREATE DATABASE Retail_DB;
 
 USE Retail_DB;

 -- Data for this project was imported into the SQL table using import wizard
 
 SELECT * FROM sales;
 
 
 #Checking unique values across major columns
 
SELECT DISTINCT(status) 
FROM sales;
 
SELECT DISTINCT(year_id) 
FROM sales;

SELECT DISTINCT(productline) 
FROM sales;

SELECT DISTINCT(dealsize)
FROm sales;


-- Sales by product line

SELECT PRODUCTLINE, SUM(sales) Revenue
FROM sales
GROUP BY PRODUCTLINE
ORDER BY Revenue desc;


-- Sales by year
SELECT year_id, SUM(sales) Revenue
FROM sales
GROUP BY year_id
ORDER BY Revenue desc;


-- The sales of 2005 seem to be less, we need to look into this and try how to figure out the reason
SELECT DISTINCT(month_id) 
FROM SALES
WHERE year_id = 2005;

-- As we can see, for year 2005, they company only opearated for 5 month, this is not same for 2004 below, this is the reason the sales volume for 2005 is low

SELECT DISTINCT(month_id)
FROM SALES
WHERE year_id = 2004;


-- Revenue by dealsize

SELECT dealsize, SUM(sales) Revenue
FROM SALES
GROUP BY dealsize
ORDER BY Revenue desc;


-- November seems to be the best month
SELECT month_id, SUM(sales) Revenue, COUNT(ordernumber) Frequency
FROM SALES 
WHERE year_id = 2004
GROUP BY month_id
ORDER BY Revenue desc;


-- What product sales the most in November year 2023

SELECT month_id, productline, SUM(sales) Revenue, COUNT(ordernumber) Frequency
FROM SALES
WHERE month_id = 11 AND year_id = 2003
GROUP BY month_id, productline
ORDER BY Revenue desc;


-- CALCULATING OUR BEST CUSTOMER USING RFM

-- For this, we will use RFM to categorize our customers as potential churn, local custoers, or lost customers
-- Recency - How long ago did they make a purchase ?
-- How often do they make a purchase ?
-- How much purchase did they make ?

SELECT 
	customername, 
    SUM(sales) Monetary_value,
    AVG(sales) Avg_monetary_value,
    COUNT(ordernumber) Frequency, 
    max(orderdate) last_order_date,
    (select max(orderdate) from sales) max_order_date
FROM Sales
GROUP BY customername;
	

-- Creating a view out of this data

CREATE VIEW rf AS
SELECT 
	customername, 
    SUM(sales) Monetary_value,
    AVG(sales) Avg_monetary_value,
    COUNT(ordernumber) Frequency, 
    max(orderdate) last_order_date,
    (select max(orderdate) from sales) max_order_date
FROM Sales
GROUP BY customername;


-- Using view

SELECT 
	*,
	NTILE(4) OVER (order by frequency) rfm_frequency,
    NTILE(4) OVER (order by Avg_monetary_value) rfm_monetary
 from rf;
 
 -- The NTILE function categorized our data into 4 groups, we can see from the "rfm_frequency", the high the frequency, the higher the rfm number
 
CREATE VIEW new_rf AS
SELECT 
	*,
	rfm_frequency + rfm_monetary as rf_cell
FROM	
(
	SELECT 
		*,
		NTILE(4) OVER (order by frequency) rfm_frequency,
		NTILE(4) OVER (order by Avg_monetary_value) rfm_monetary
	from rf
 ) AS rffm;
 
 -- We will do some analysis to gather categorical data, so we can use them as a criterial to judge cutsomer loyalty.alter
 
 SELECT
	customername, 
    rfm_frequency,
    rfm_monetary,
    rf_cell,
CASE
	WHEN rf_cell IN (1, 2) then 'lost customer'
	WHEN rf_cell IN (3, 4, 5) then 'potential churn'
     WHEN rf_cell IN (6, 7, 8) then 'loyal customer'  
     
end customer_segment
 from new_rf;
 
 -- Selecting & exporting the whole dataset for dashboard creation
 
 SELECT * FROM sales;
 
 
 
 
 
 










