
CREATE TABLE sales_stores (
transaction_id VARCHAR(15),
customer_id VARCHAR(15),
customer_name VARCHAR(30),
customer_age VARCHAR(15),
gander VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR(15),
quantity INT,
price FLOAT,
payment_mode VARCHAR(15),
purchase_date VARCHAR(15),
time_of_purchase TIME,
status VARCHAR (15)
);

SELECT * FROM sales_store

--IMPORT DATA TO BULK INSERT METHOD--

BULK INSERT sales_store
FROM 'C:\Users\HP\Downloads\archive\sales.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR='\n'
	);

	SELECT * FROM sales_store

	     -- DATA CLEANING--

		 -- STEP1:- TO REMOVE DUPLICATES--

	SELECT transaction_id, COUNT(transaction_id) as count_of_transaction_id
	from sales_store
	group by transaction_id
	having count(transaction_id)  > 1 

 


WITH CTE AS (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM sales_store
)
--DELETE FROM CTE
--WHERE Row_Num=2

SELECT * FROM CTE
WHERE transaction_id IN ('TXN240646',
'TXN342128',
'TXN855235',
'TXN981773')

--STEP 2 :- Correction of Headers


 EXEC sp_rename'sales_store.gander','gender','column'

 --STEP 3 :- TO CHECK DATATYPE--

 SELECT COLUMN_NAME, DATA_TYPE
 FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_NAME = 'sales_store'



--STEP 4 :- TO CHECK NULL VALUES

    -- TO CHECK NULL COUNT--

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
	'SELECT ''' + COLUMN_NAME + ''' AS ColumnName,
	COUNT(*) AS NullCount
	FROM ' +QUOTENAME(TABLE_SCHEMA) + '.sales_store
	WHERE ' +QUOTENAME(COLUMN_NAME) + 'IS NULL',
	' UNION ALL '

)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales_store';

-- Execute the dynamic SQL--
EXEC sp_executesql @SQL;

                                            -- TREATING NULL VALUES--

SELECT *
FROM sales_store
where transaction_id IS NULL
OR 
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
product_id IS NULL
OR
product_name IS NULL
OR 
product_category IS NULL
OR 
quantity IS NULL
OR
gender IS NULL
OR 
PRICE IS NULL
OR 
payment_mode IS NULL
OR 
purchase_date IS NULL
OR 
time_of_purchase IS NULL
OR 
status IS NULL

DELETE FROM sales_store
WHERE transaction_id IS NULL

SELECT * FROM sales_store
WHERE customer_name = 'Ehsaan Ram' 

UPDATE sales_store
SET customer_id = 'CUST9494'
WHERE transaction_id = 'TXN977900'

SELECT * FROM sales_store
WHERE customer_name = 'Damini Raju'


UPDATE sales_store
SET customer_id = 'CUST1401'
WHERE transaction_id = 'TXN985663'


SELECT * FROM sales_store
WHERE customer_id = 'CUST1003'


UPDATE sales_store
SET customer_name = 'Mahika Saini',customer_age=35,gender ='MALE'
WHERE transaction_id = 'TXN432798'



-- STEP 5 :- DATA CLEANING --

SELECT DISTINCT gender
FROM sales_store
	
UPDATE sales_store
SET gender = 'M'
WHERE gender = 'Male'

UPDATE sales_store
SET gender = 'F'
WHERE gender = 'Female'

select distinct payment_mode
from sales_store

update sales_store
set payment_mode = 'Credit Card'
where payment_mode = 'CC'

  
SELECT * FROM SALES_STORE

-- DATA ANALYSIS--

--Q 1. What are the Top 5 selling product by quantity?
  
  SELECT TOP 5 PRODUCT_NAME, SUM(quantity) AS total_quantity_sold
  FROM sales_store
  WHERE STATUS = 'delivered'
  GROUP BY product_name
  ORDER BY total_quantity_sold DESC 

--Q 2. Which product aremost frequently cancelled?
  SELECT TOP 5 product_name, COUNT(*) AS total_cancelled
  FROM sales_store
  WHERE status = 'cancelled'
  GROUP BY product_name 
  ORDER BY total_cancelled  DESC

-- Q 3. What time of the day has the highest number of purchase?

select * from sales_store

			SELECT 
				CASE 
					WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
					WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
					WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
					WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
				END AS time_of_day,
				count(*) as total_orders
			from sales_store
			group by 
				CASE
					WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
					WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
					WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
					WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
                END
		order by total_orders desc

--Q 4. What are the top  highest spending customers?

select top 5 customer_name, 
      FORMAT(sum(price*quantity),'C0','en-IN') AS total_spend
from sales_store
group by customer_name
order by sum(price*quantity) desc 

--Q 5. which product category generate the highest revenue?

select product_category,
format(sum(price*quantity), 'C0','en-IN') as revenue 
from sales_store
group by product_category
order by sum(price*quantity) desc 

-- Q 6 What is the return/cancellation reta per product cateory?

SELECT product_category,
	FORMAT(count(case when status='cancelled' then 1 end)*100.0/count(*),'N3')+' %' AS cancelled_perscent
FROM sales_store
GROUP BY product_category
order by cancelled_perscent DESC

--Return

SELECT product_category,
	FORMAT(count(case when status='returned' then 1 end)*100.0/count(*),'N3')+' %' AS returned_perscent
FROM sales_store
GROUP BY product_category
order by returned_perscent DESC

--Q 7. What is the most preferred payment mode?

SELECT payment_mode, COUNT(payment_mode) as total_count
from sales_store
group by payment_mode
order by total_count desc

--Q 8. How does age group affect purchasing behaviour?

SELECT 
	CASE
		WHEN Customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN Customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN Customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END AS customer_age,
	FORMAT(SUM(price*quantity),'C0', 'en-IN') AS total_purchase
FROM sales_store
GROUP BY CASE
		WHEN Customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN Customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN Customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END
ORDER BY sum(price*quantity) DESC

