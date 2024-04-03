-- A. Pizza Metrics
-- How many pizzas were ordered?

select count(*) as pizzas_ordered
from customer_orders;

-- How many unique customer orders were made?

select count(distinct customer_id) as unique_customers
from customer_orders;


-- How many successful orders were delivered by each runner?

select runner_id
,count(order_id) as successful_deliveries
from runner_orders
where distance not like 'null'
group by runner_id;


-- How many of each type of pizza was delivered?

select pizza_id
,count(*) as deliveries
from customer_orders as c
inner join runner_orders as r on r.order_id = c.order_id
where distance not like 'null'
group by pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?

select customer_id
, pizza_name
, count(*) as ordered
from pizza_names as n
inner join customer_orders as c
    on c.pizza_id = n.pizza_id
group by all;

-- What was the maximum number of pizzas delivered in a single order?

select count(*) as pizzas_ordered
from customer_orders
group by order_id
order by count(*) desc
limit 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

with c as (
select customer_id
,count(*) as Changes
from customer_orders
where (length (exclusions)> 0 
and exclusions not like '%null%')
or (length (extras)> 0 
and extras not like '%null%')
group by customer_id
)

, t as (
select customer_id
,count(*) as total_pizzas
from customer_orders
group by customer_id)

select c.customer_id
    ,changes
    ,total_pizzas - changes as no_changes
from t
inner join c
on c.customer_id = t.customer_id;


-- How many pizzas were delivered that had both exclusions and extras?

with changes as (
select order_id
, pizza_id
, (case
    when exclusions='null' then 0
    when exclusions='' then 0 
    when exclusions is null then 0
    else 1 end) as exclusions
, (case when extras='null' then 0
    when extras='' then 0 
    when extras is null then 0
    else 1 end) as extras 
from customer_orders)

, pizzas as(
select * 
from runner_orders as r
inner join changes as c on r.order_id = c.order_id
where distance<>'null'
)

select count(*) as both
from pizzas
where exclusions > 0 
and extras > 0;


-- What was the total volume of pizzas ordered for each hour of the day?

select date_part(hour, order_time) as hour
, count(*) as pizza_volume
from customer_orders
group by date_part(hour, order_time)
order by hour;

-- What was the volume of orders for each day of the week

select dayname(order_time) as day
, count(*) as pizza_volume
from customer_orders
group by dayname(order_time)
