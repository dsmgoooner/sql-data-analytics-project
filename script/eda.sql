/*
=======================================================================
    
      Exploratory Data Analysis Using SQL
     
=======================================================================

**/


-- Explore All Objects in the Database

SELECT *
FROM INFORMATION_SCHEMA.TABLES; 

-- Explore All columns in the Database

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;


-- Dimension Exploration

/* 
 * Identifying the Unique Values in each dimensions.
 * Recognizing how data might be grouped or segmented,
 * which is useful for later analysis.
 * For that we use the keyword DISTINCT.
 */

-- Explore All countries our customers come from.

SELECT DISTINCT(country)
FROM gold.dim_customers ;

-- Explore All Categories "The major Divisions"

SELECT DISTINCT
category,
subcategory,
product_name
FROM gold.dim_product
ORDER BY 1,2,3;


-- Date Exploration

/*
 * Identify the earliest and latest dates(boundaries).
 * Understand the scope of data and the timespan.
 * For that we use MAX/MIN.
 */

SELECT *
FROM gold.fact_sales ;

-- Find the date of the first and last order
-- How many years of sales are available

SELECT 
MIN(order_date) AS first_order, 
MAX(order_date) AS last_order,
DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

--  Find the youngest and the oldest customer



SELECT 
  MAX(age) AS max_age,
  MIN(age) AS min_age
FROM (
  SELECT 
    DATEDIFF(YEAR, birth_date, GETDATE()) AS age
  FROM gold.dim_customers
) AS t;

 
-- Measure Exploration


/* 
 * Calculate the key metrics of the business
 * Highest level of Aggregation 
 * For this we use SUM, AVG
 */


-- Find the total number of customers that has placed an order

SELECT COUNT(DISTINCT(customer_key))
FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' AS measure_name, SUM(sales) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales 
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure_name, COUNT(DISTINCT(order_number)) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure_name, COUNT(product_key) AS measure_value FROM gold.dim_product
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers;


/*
 * Magnitude Analysis
 * Compare the measure values by categories
 * [Measure] By [Dimensions]
 * Total Sales by Country
 * Total Quantity by Category
 * Average Price by Product
 * Total Orders by Customers
 */

--- Find total customers by gender

SELECT 
gender,
COUNT(customer_id) AS total_customer
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customer DESC;

-- Find total products by category

SELECT
category,
COUNT(product_id) as total_product
FROM gold.dim_product
GROUP BY category
ORDER BY total_product DESC;


-- Find the average costs in each category

SELECT 
category,
AVG(cost) AS avg_cost
FROM gold.dim_product
GROUP BY category
ORDER BY avg_cost DESC;

-- What is the total revenue generated for each category?

SELECT 
p.category,
SUM(f.sales) total_revenue
FROM gold.fact_sales f
LEFT JOIN  gold.dim_product p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;


-- What is the total revenue generted by each customer?


SELECT
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC;


/*
 * Ranking Analysis
 * Order the values of dimensions by measure
 * Top N performers / Bottom N performers
 * Rank [Dimension] By [Measure]
 * Rank Countries By total Sales
 * Top 5 products by quantity
  */

-- Which 5 products generate the highest revenue?

SELECT
*
FROM 
	(SELECT
	p.product_name,
	SUM(f.sales) total_revenue,
	ROW_NUMBER() OVER(ORDER BY SUM(f.sales) DESC) AS rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_product p
	ON p.product_key = f.product_key
	GROUP BY p.product_name
	) t
WHERE rank_products < =5


-- What are the 5 worst-performing products in terms of sales?

SELECT TOP 5
*
FROM 
	(SELECT
	p.product_name,
	SUM(f.sales) total_revenue,
	ROW_NUMBER() OVER(ORDER BY SUM(f.sales) DESC) AS rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_product p
	ON p.product_key = f.product_key
	GROUP BY p.product_name
	) t
ORDER BY rank_products DESC;







