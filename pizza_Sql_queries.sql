create database pizza_DB;
use pizza_DB;

SELECT COLUMN_NAME, DATA_TYPE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'pizza_db'  -- Replace with your database name
  AND TABLE_NAME = 'pizza_sales'
  AND COLUMN_NAME = 'order_date';
  
SET SQL_SAFE_UPDATES = 0;

UPDATE pizza_sales
SET order_time = cast(order_time as time);

SELECT order_date FROM pizza_sales WHERE STR_TO_DATE(order_date, '%Y-%m-%d');


select * from pizza_sales;



-- KPI REQUIREMENTS

-- total revenue -> sum of total prize of all pizza order

select sum(total_price) as total_revenue from pizza_sales;

/* average order value -> avg amount spent per order, calculated by dividing 
 the total revenue by the total no. of orders */
 
 select sum(total_price)/ count(distinct order_id) as avg_order_value from pizza_sales;

-- total pizzas sold -> sum of the quantities of all pizzas sold

select sum(quantity) as total_pizza_sold from pizza_sales;

-- total no. of order placed

select count(distinct(order_id)) as total_order_placed from pizza_sales;

/* Avg pizza per order -> calculated by dividing
 total no. of pizza by total no. of orders */ 
 
 select sum(quantity)/count(distinct(order_id)) as avg_pizza_per_order from pizza_sales; 
 
 /* typecasting */
 
select cast(sum(quantity)/count(distinct(order_id)) as decimal(10,2)) as avg_pizza_per_order from pizza_sales;


-- hourly trend for total pizzas sold

select extract(hour from order_time) as order_hour, sum(quantity) 
as total_pizzas_sold from pizza_sales
group by extract(hour from order_time)
order by extract(hour from order_time);

-- weekly trend for total orders

SELECT subquery.order_week, subquery.order_year, subquery.total_pizzas_sold
FROM (
    SELECT WEEK(order_time, 3) AS order_week, IFNULL(YEAR(order_date), 0) AS order_year, COUNT(DISTINCT order_id) AS total_pizzas_sold
    FROM pizza_sales
    GROUP BY WEEK(order_time, 3), order_year
) AS subquery
WHERE subquery.order_week IS NOT NULL
ORDER BY subquery.order_week, subquery.order_year;
/*
SELECT COLUMN_NAME, DATA_TYPE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'pizza_db'  -- Replace with your database name
  AND TABLE_NAME = 'pizza_sales'
  AND COLUMN_NAME = 'order_date';
  
SET SQL_SAFE_UPDATES = 0;

UPDATE pizza_sales
SET order_time = cast(order_time as time);

SELECT order_date FROM pizza_sales WHERE STR_TO_DATE(order_date, '%Y-%m-%d');
SELECT order_time FROM pizza_sales
WHERE order_date IS NULL OR DATE(order_time) IS NULL;
*/

-- % of sales by pizza category -> pizza category_sales_sum/total pizza_sales_sum * 100

select pizza_category, sum(total_price) as total_sales, sum(total_price)*100/ (select sum(total_price) from pizza_sales ) -- where month(order_date)=1)
as Percentage_of_sales from pizza_sales
-- where month(order_date)=1
-- where extract(quarter from order_date)=2
group by pizza_category;


/*   % of pizza sales by pizza sizes */
  
select pizza_size, cast( sum(total_price) as decimal(10,2)) as total_sales, cast(sum(total_price)*100/ (select sum(total_price) from pizza_sales)
as decimal(10,2)) as Percentage_of_sales from pizza_sales
group by pizza_size
order by Percentage_of_sales;

/*  top 5 best sellers by revenue, total quantity, and total orders */

select pizza_name, sum(total_price) as total_revenue from pizza_sales
group  by pizza_name
order by total_revenue desc
limit 5;

select pizza_name, sum(quantity) as total_quantity from pizza_sales
group  by pizza_name
order by total_quantity desc
limit 5;

select pizza_name, count(distinct(order_id)) as total_orders from pizza_sales
group  by pizza_name
order by total_orders desc
limit 5;

