--Overview

--Total Sales 
select sum(sales) as Total_Sales
from orders;

--Total Profit
select sum(profit) as Total_Profit
from orders;

--Profit Ratio
select sum(profit)/count(order_id) as Profit_per_order
from orders;

--Profit per order
select sum(profit)/count(order_id) as profit
from orders ;

--Sales per customer
select sum(sales)/count( distinct customer_id) as sales
from orders;

--Avg. Discount
select avg(discount)*100 as avg_discount
from orders;

--Monthly Sales by Segment 
select extract (month from order_date) as month, 
 sum(case when segment = 'Home Office' then sales end) as home_office,
 sum(case when segment = 'Corporate' then sales end) as corporate,
 sum(case when segment = 'Consumer' then sales end) as consumer
from orders
group by month
order by month;

--Sales by Product Category
select category, sum(sales) as sales
from orders
group by category;

--Sales and profit by customer
select customer_id, customer_name,sum(sales) as sales,sum(profit) as profit
from orders
group by customer_id,customer_name;

--Customer Ranking
select customer_id,customer_name,sum(sales) as top_sales
from orders
group by customer_id,customer_name
order by top_sales desc;

--Sales per region
select region, sum(sales) as sales
from orders 
group by region;
