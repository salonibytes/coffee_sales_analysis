CREATE DATABASE Coffee_Shop
USE Coffee_Shop

--Creating table
--City

CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	[population] BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);

select * from city


--Products Table
CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);

--Customers Table
CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);

--Sales Table
CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);
--Checking all the tables
SELECT * FROM city
SELECT * FROM products
SELECT * FROM customers
SELECT * FROM sales

----------------------------------------------------------------------------------------------
--Importing the datasets
--city

BULK INSERT city
FROM 'C:\Users\salon\Downloads\city.csv'
	WITH 
	(
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR='\n'
	);
	

	--products

BULK INSERT products
FROM 'C:\Users\salon\OneDrive\Desktop\products.csv'
	WITH 
	(
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR='\n'
	);
	

	--customers

BULK INSERT customers
FROM 'C:\Users\salon\OneDrive\Desktop\customers.csv'
	WITH 
	(
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR='\n'
	);

	
	--sales
SET DATEFORMAT dmy
BULK INSERT sales
FROM 'C:\Users\salon\OneDrive\Desktop\sales.csv'
	WITH 
	(
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR='\n'
	);


--Checking all the tables
SELECT * FROM city
SELECT * FROM products
SELECT * FROM customers
SELECT * FROM sales
------------------------------------------------------------------------------------------------------------------
--Business Insights Problems 
--------------------------------------------------------------------------------------------------------------------------------------------------

--1. How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT * FROM city

SELECT 
	city_name,
	FORMAT((population *0.25),'N0') AS estimated_coffee_consumers
FROM city 
ORDER BY population *0.25 DESC

--🔍 Business Problem

--The company does not know market size in each city. Without understanding how many people could consume coffee, 
--expansion decisions become guesswork.


--💡 Business Impact

--Helps estimate potential demand per city
--Identifies cities with larger target audience
--Avoids opening stores in cities with low coffee consumption potential

--------------------------------------------------------------------------------------------------------------------------------------------------

--2. What is the total revenue generated from coffee sales across all cities in the last quarter of 2023 ?


SELECT * FROM city
--SELECT * FROM products
SELECT * FROM customers
SELECT * FROM sales


SELECT 
	city_name,
	FORMAT(SUM(total),'N0') AS revenue_generated,
	YEAR(sale_date) AS year_of_sale
FROM sales
INNER JOIN customers ON sales.customer_id=customers.customer_id
INNER JOIN city ON city.city_id=customers.city_id
WHERE YEAR(sale_date)=2023 AND DATEPART(QUARTER,sale_date)=4
GROUP BY city_name,YEAR(sale_date)
ORDER BY SUM(total) DESC

--🔍 Business Problem

--The business wants to know recent performance. Decisions should be based on current momentum, especially before expansion.

--💡 Business Impact

--Shows whether the business is growing or slowing down

--------------------------------------------------------------------------------------------------------------------------------------------------
--3. How many units of each coffee product have been sold?

SELECT * FROM products
SELECT * FROM sales

SELECT
	product_name,
	COUNT(sale_id) AS total_orders
FROM products 
INNER JOIN sales ON products.product_id=sales.product_id
GROUP BY product_name
ORDER BY total_orders DESC

--🔍 Business Problem

--The company doesn’t know which products actually drive volume. Stocking the wrong products in new stores can lead to losses.


--💡 Business Impact

--Identifies high-demand products
--Helps optimize inventory planning for new outlets
--Reduces wastage and overstocking


--------------------------------------------------------------------------------------------------------------------------------------------------
--4. What is the average sales amount per customer in each city?


SELECT 
	city_name, 
	SUM(total) AS revenue, 
	COUNT(DISTINCT sales.customer_id) AS count_of_customers,
	SUM(total)/COUNT(DISTINCT sales.customer_id) AS avg_per_customer_per_city,
	FORMAT(SUM(total)/COUNT(DISTINCT sales.customer_id),'C2','en-IN') AS avg_per_customer_per_city1
FROM sales
INNER JOIN customers ON sales.customer_id=customers.customer_id
INNER JOIN city ON city.city_id=customers.city_id
GROUP BY city_name
ORDER BY SUM(total)/COUNT(DISTINCT sales.customer_id) DESC

--🔍 Business Problem

-- The business needs to know how much an average customer spends in each city.

--💡 Business Impact

--Identifies cities with high-spending customers
--Helps design pricing and promotion strategies

----------------------------------------------------------------------------------------------------------------------------------------------
--5. Provide a list of cities along with their populations and estimated coffee consumers with unique customers.



SELECT 
	city_name,
	FORMAT((population *0.25),'N0') AS estimated_coffee_consumers,
	FORMAT(CAST(population AS BIGINT),'N0') AS total_population,
	COUNT(DISTINCT customer_id) AS total_customers
FROM city 
INNER JOIN customers ON city.city_id=customers.city_id
GROUP BY city_name,population
ORDER BY population *0.25 DESC


--🔍 Business Problem

--A city may have low sales but a very large population.

--💡 Business Impact

--Got idea of  market size
--Helps prioritize cities with future growth opportunity

----------------------------------------------------------------------------------------------------------------------------------------------
--6. What are the top 3 selling products in each city based on sales volume?

WITH CTE AS (
SELECT 
	city_name, 
	product_name,
	COUNT(sales.sale_id) AS total_orders,
	DENSE_RANK() OVER(PARTITION BY city_name ORDER BY COUNT(sales.sale_id) DESC) AS RNK
FROM products 
INNER JOIN sales ON sales.product_id=.products.product_id
INNER JOIN customers ON customers.customer_id=sales.customer_id
INNER JOIN city ON city.city_id=customers.city_id
GROUP BY city_name,product_name
)
SELECT * FROM CTE 
WHERE RNK <=3

--🔍 Business Problem
--Top 3 Selling Products in Each City


--💡 Business Impact

--Enables city-specific product strategy
--inventory stock planning
--Increases customer satisfaction and repeat purchases


------------------------------------------------------------------------------------------------------------------------------------
--7. How many unique customers are there in each city who have purchased coffee products?


SELECT 
	city_name,
	COUNT(DISTINCT customer_name) as Unique_customer
FROM products 
INNER JOIN sales ON sales.product_id=products.product_id
INNER JOIN customers ON customers.customer_id=sales.customer_id
INNER JOIN city ON city.city_id=customers.city_id
WHERE products.product_id BETWEEN 1 AND 28
GROUP BY city_name
ORDER BY Unique_customer DESC

--🔍 Business Problem
--How many different customers are actually purchasing coffee products in each city?


--💡 Business Impact
--The company can measure customer reach and market penetration.
--It helps evaluate brand popularity across cities.
--It supports better marketing and expansion decisions.

------------------------------------------------------------------------------------------------------------------------------------
--8. Find each city and their average sale per customer and avg rent per customer

WITH city_table AS 
(
SELECT 
	city_name, 
	SUM(total) AS revenue, 
	COUNT(DISTINCT sales.customer_id) AS count_of_customers,
	--SUM(total)/COUNT(DISTINCT sales.customer_id) AS avg_per_customer_per_city,
	FORMAT(SUM(total)/COUNT(DISTINCT sales.customer_id),'C2','en-IN') AS avg_per_customer_per_city
FROM sales
INNER JOIN customers ON sales.customer_id=customers.customer_id
INNER JOIN city ON city.city_id=customers.city_id
GROUP BY city_name
),

rent_table AS
(
SELECT 
	city_name,
	estimated_rent
FROM city
)

SELECT
	city_table.city_name,
	city_table.revenue,
	city_table.count_of_customers,
	city_table.avg_per_customer_per_city,
	rent_table.estimated_rent,
	FORMAT((rent_table.estimated_rent / city_table.count_of_customers),'C2','en-IN') AS avg_rent_per_customer
FROM city_table
INNER JOIN rent_table ON city_table.city_name=rent_table.city_name
ORDER BY revenue DESC

--🔍 Business Problem
--How much money we earn from each customer And how much cost (rent) is involved per customer

--💡 Business Impact
--The company can compare earning vs cost in each city
--It helps find cities where profit margins are better
--It prevents opening stores in cities where rent is high but customer spending is low



------------------------------------------------------------------------------------------------------------------------------------
--9. Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
--Sales_growth_rate :- ((monthly_revenue - previous_month_sales ) /previous_month_sales )*100.0

WITH monthly_sales AS 
(
SELECT 
	city_name,
	YEAR(sale_date) AS year_sale,
	MONTH(sale_date) AS month_sale,
	SUM(total) AS monthly_revenue
FROM sales
INNER JOIN customers ON sales.customer_id=customers.customer_id
INNER JOIN city ON city.city_id=customers.city_id
GROUP BY city_name,YEAR(sale_date),MONTH(sale_date)
),
previous_month AS
(
SELECT 
	city_name,
	year_sale,
	month_sale,
	monthly_revenue,
	LAG(monthly_revenue) OVER (PARTITION BY city_name ORDER BY year_sale,month_sale) AS previous_month_sales
FROM monthly_sales
)
SELECT 
	city_name,
	year_sale,
	month_sale,
	monthly_revenue,
	previous_month_sales,
	ROUND(((monthly_revenue-previous_month_sales) / previous_month_sales ) *100.0,2) AS Sales_growth_rate
FROM previous_month


--🔍 Business Problem
--Which cities are growing month by month And which cities are losing demand.


--💡 Business Impact
--The company can identify cities where demand is increasing
--It can avoid cities where sales are dropping
--It helps decide the right time to expand


----------------------------------------------------------------------------------------------------------------------------------------
-- 10. Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

--✅ city_name
--✅ total_sales
--✅ total_rent
--✅ total_customers
--✅ estimated_coffee_consumers (25% population)
--✅ avg_per_customer_per_city
--✅ avg_rent_per_customer
--✅ Top 3 cities based on highest sales



WITH city_table AS 
(
SELECT 
	city_name, 
	SUM(total) AS revenue, 
	COUNT(DISTINCT sales.customer_id) AS count_of_customers,
	--SUM(total)/COUNT(DISTINCT sales.customer_id) AS avg_per_customer_per_city,
	FORMAT(SUM(total)/COUNT(DISTINCT sales.customer_id),'C2','en-IN') AS avg_per_customer_per_city
FROM sales
INNER JOIN customers ON sales.customer_id=customers.customer_id
INNER JOIN city ON city.city_id=customers.city_id
GROUP BY city_name
),

rent_table AS
(
SELECT 
	city_name,
	estimated_rent,
	FORMAT((population * 0.25),'N0') AS estimated_coffee_consumers
FROM city
)

SELECT
	city_table.city_name,
	city_table.revenue,
	city_table.count_of_customers,
	estimated_coffee_consumers,
	city_table.avg_per_customer_per_city,
	rent_table.estimated_rent,
	FORMAT((rent_table.estimated_rent / city_table.count_of_customers),'C2','en-IN') AS avg_rent_per_customer
FROM city_table
INNER JOIN rent_table ON city_table.city_name=rent_table.city_name
ORDER BY revenue DESC



--Final Recommendation 

--City 1 :- Pune 

--🔥 Highest revenue
--💰 Strong average spend per customer
--🏠 Moderate rent
--📊 Good customer base


--City 2 :- Chennai 

--💵 Second highest revenue
--📊 Good customer base
--🏠 Rent manageable 
--⚖ Balanced earning vs cost



--City 3 :- Jaipur

--👥 Highest customer count (69)
--💸 Lowest rent per customer
--📈 Strong revenue compared to cost
--⚖ Very efficient unit economics

❌ Why Not Bangalore?

---Rent is too high
--Avg rent per customer is highest
--Profit margin risk


❌ Why Not Delhi?

--Huge market size
--But revenue per customer is lower
--Rent is relatively high




