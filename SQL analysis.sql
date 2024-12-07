---------------------------- finding top 10 highest profit generating products ------------------------------
select top 10 product_id,ROUND((profit*quantity),2) as total_profit,region from all_orders
order by total_profit desc


---------------------------- finding top 5 highest selling products in each region --------------------------
with sales as (
		select *,
			   ROUND((sale_price*quantity),2) as total_sales,
			   CASE 
				   WHEN sale_price = 0 THEN '0%'
				   ELSE STR(ROUND((profit / sale_price), 2) * 100)+'%'
			   END AS profit_margin,
			   ROW_NUMBER() OVER(PARTITION BY region ORDER BY ROUND((sale_price*quantity),2) DESC) AS rn
		from all_orders)

select region,product_id,total_sales,profit_margin
from sales
where rn<=5
group by region,product_id,total_sales,profit_margin
order by region,total_sales desc


---------------------- finding month over month growth comparison for 2022 vs 2023 ------------------------

with comparison as (
select year(order_date) as order_year,month(order_date) as order_month,
ROUND((sale_price*quantity),2) as total_sales
from all_orders
group by year(order_date),month(order_date),ROUND((sale_price*quantity),2)
	)
select order_month
, sum(case when order_year=2022 then total_sales else 0 end) as sales_2022
, sum(case when order_year=2023 then total_sales else 0 end) as sales_2023
from comparison 
group by order_month
order by order_month


---------------------- for each category which month has the highest sales -------------------------------

WITH cte AS (
    -- Aggregating total sales by category and month
    SELECT category,
           FORMAT(order_date, 'yyyy-MM') AS order_year_month,
           SUM(ROUND((sale_price * quantity), 2)) AS sales,
		   ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(ROUND((sale_price * quantity), 2)) DESC) AS rn
    FROM all_orders
    GROUP BY category, FORMAT(order_date, 'yyyy-MM')
)
-- Ranking the categories based on the sales per month
SELECT category,order_year_month,sales
from cte
WHERE rn = 1
ORDER BY sales DESC;


---------------------- for each sub_category which month has the highest sales -------------------------------

WITH cte as (
			 select sub_category,
					FORMAT(order_date,'yyyy-MM') as order_year_month,
					SUM(ROUND((sale_price*quantity),2)) as sales,
					ROW_NUMBER() OVER(PARTITION BY sub_category
									  ORDER BY SUM(ROUND((sale_price*quantity),2)) DESC) as rn
			 from all_orders
			 group by sub_category,FORMAT(order_date,'yyyy-MM')
)

select sub_category,order_year_month,sales
from cte
where rn = 1
order by sales desc

---------------------- comparison by category for 2022 vs 2023 ------------------------

with category_comparison as (
select year(order_date) as order_year,month(order_date) as order_month,
ROUND((sale_price*quantity),2) as total_sales,category
from all_orders
group by year(order_date),month(order_date),ROUND((sale_price*quantity),2),category
	)
select category
, sum(case when order_year=2022 then total_sales else 0 end) as sales_2022
, sum(case when order_year=2023 then total_sales else 0 end) as sales_2023
from category_comparison 
group by category

---------------------- comparison by sub_category for 2022 vs 2023 ------------------------

with sub_category_comparison as (
select year(order_date) as order_year,month(order_date) as order_month,
ROUND((sale_price*quantity),2) as total_sales,sub_category
from all_orders
group by year(order_date),month(order_date),ROUND((sale_price*quantity),2),sub_category

	)
select sub_category
, sum(case when order_year=2022 then total_sales else 0 end) as sales_2022
, sum(case when order_year=2023 then total_sales else 0 end) as sales_2023
from sub_category_comparison 
group by sub_category

---------------------- comparison by category for 2022 vs 2023 (sales, profit, profit margin) ------------------------

WITH category_comparison AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        ROUND(SUM(sale_price * quantity), 2) AS total_sales,
        ROUND(SUM(profit * quantity), 2) AS total_profit,
        category
    FROM all_orders
    GROUP BY YEAR(order_date), MONTH(order_date), category
)

SELECT 
    category,
    SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_2023,
    SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
    SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023,
    CASE
        WHEN SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) = 0 THEN 0
        ELSE ROUND(
            (SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) /
            SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END)) * 100, 2
        )
    END AS profit_margin_2022,
    CASE
        WHEN SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) = 0 THEN 0
        ELSE ROUND(
            (SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) /
            SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END)) * 100, 2
        )
    END AS profit_margin_2023
FROM category_comparison
GROUP BY category
ORDER BY category;



---------------------- comparison by sub_category for 2022 vs 2023 (sales, profit, profit margin) ------------------------

WITH sub_category_comparison AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        ROUND(SUM(sale_price * quantity), 2) AS total_sales,
        ROUND(SUM(profit * quantity), 2) AS total_profit,
        sub_category
    FROM all_orders
    GROUP BY YEAR(order_date), MONTH(order_date), sub_category
)

SELECT 
    sub_category,
    SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_2023,
    SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
    SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023,
    CASE
        WHEN SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) = 0 THEN 0
        ELSE ROUND(
            (SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) /
            SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END)) * 100, 2
        )
    END AS profit_margin_2022,
    CASE
        WHEN SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) = 0 THEN 0
        ELSE ROUND(
            (SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) /
            SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END)) * 100, 2
        )
    END AS profit_margin_2023
FROM sub_category_comparison
GROUP BY sub_category
ORDER BY sub_category;

