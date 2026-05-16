
 --- run each part of code sepratlly , running whole code at once might not wotk !!!
 -------------------------------------------------------------1--- kpi_analysis
select

sum (o.sales) as totall_revenue ,
sum (o.profit ) as totall_profit , 
count(distinct order_id ) as  totall_orders ,
count( distinct c.customer_id ) as totall_customer ,
avg (sales ) as avg_order_value

from orders as o
left join customers as c 
on o.customer_id = c.customer_id 


go

------------------------------------------------------2----geographical_analysis
select top 5 

c.country , 
sum(o.sales ) as toatll_sales ,
sum(o.profit ) as  totall_profit ,
count(distinct o.order_id ) as totall_order 



from orders as o 
left join customers as c
on o.customer_id = c.customer_id 
group by c.country 
order by sum(o.sales ) desc, sum(o.profit ) desc


go
----------------------------------------------------3-------------customer_lifetime_value

select
c.customer_id,
coalesce(trim(c.first_name),'')+' '+coalesce(trim(c.last_name),'') as customer_name , 
count (distinct order_id ) as totall_order ,
sum (sales ) as totall_spending ,
sum (profit ) as totall_profit ,
rank () over (order by sum (profit ) desc ) as customer_rank


from orders as o
left join customers as c
on o.customer_id = c.customer_id 
group by c.customer_id, coalesce(trim(c.first_name),'')+' '+coalesce(trim(c.last_name),'')

go
--------------------------------------------------------4-----------------------------monthly_sales_growth 
with cte_sales_detail as (
select

order_id , 
year(order_date) as year ,
month(order_date) as month ,
sum(sales) as totall_sales

from orders
group by year(order_date) ,month(order_date) ,order_id

)

select 

csd.year ,
csd.month,
csd.totall_sales ,

LAG(csd.totall_sales,1) 
OVER (PARTITION BY csd.year ORDER BY csd.month) 
AS previous_month_sales ,
CAST(((csd.totall_sales - LAG(csd.totall_sales,1) OVER (PARTITION BY csd.year ORDER BY csd.month))* 100.0)   /

NULLIF(LAG(csd.totall_sales,1) OVER (PARTITION BY csd.year ORDER BY csd.month),0)AS DECIMAL(10,2)) AS growth_percentage



from orders as o
left join cte_sales_detail as csd
on o.order_id = csd.order_id



go
--------------------------------------------------------------5----------------product_performance_analysis






select

p.category ,
p.product_name ,
sum(o.sales ) as totall_sales ,
sum(o.profit ) as totall_profit ,
sum(o.quantity) as totall_quantity ,
row_number () over (partition by p.category order by sum(o.sales ) desc ,sum(o.profit ) desc) as ranking

from orders as o
left join order_items as oi
on o.order_id = oi.order_id 
left join products as p
on oi.product_id = p.product_id
group by p.category ,p.product_name
order by sum(o.sales ) desc ,sum(o.profit ) desc, sum(o.quantity) desc

go
-------------------------------------------------6----------------------------------return_rate_analysis

select

order_status,
sum( distinct order_id ) as totall_orders  ,
cast(count(distinct order_id) * 100.0 / sum(count(distinct order_id))over ()  as decimal(10,2)) as percentage_of_total

from orders
group by order_status

-------------------------------------------------------------------------------highest_return_by country 

go

with cte_retu_coun as (
select 
o.order_status ,
c.country ,
case when o.order_status = 'Returned' then 1 else 0 end as flag 

from orders as o
left join customers as c
on o.customer_id = c.customer_id
where case when o.order_status = 'Returned' then 1 else 0 end = 1
) 

select
country ,
count (*) highest_return 

from cte_retu_coun
group by country
order by country desc   

-----------------------------------------------> 1 ) USA | 406  , 2) UK | 252



go

--highest_product _returend

with cte_retu_coun as (
select 
o.order_status ,
p.product_name ,
case when o.order_status = 'Returned' then 1 else 0 end as flag 

from orders as o
left join order_items as oi
on o.order_id = oi.order_id
left join products as p
on oi.product_id = p.product_id
where case when o.order_status = 'Returned' then 1 else 0 end = 1
) 

select
product_name ,
count (*) highest_return 

from cte_retu_coun
group by product_name
order by product_name desc

------------------------------------------------------> 1 ) PRODUCT_99 | 41  , 2) PRODUCT_98 | 20



go


-----------------------------------------------------7--------------shipping_performance_analysis

select

ship_mode ,
datediff (day ,sh.ship_date,sh.delivery_date) as avg_delivery_days , 
count (o.order_id) as totall_orders ,
case 
when datediff (day ,sh.ship_date,sh.delivery_date) >= 5 then 'Delayed orders'
else 'Normal shipping'
end as delayed_orders

from shipping as sh
left join orders as o
on sh.order_id = o.order_id
group by ship_mode , datediff (day ,ship_date,delivery_date) 



-----------------------------------------------------------8---cohort_retention_analysis


-
go





WITH first_purchase AS (

SELECT
 customer_id,
 MIN(order_date) AS first_order_date

FROM orders
GROUP BY customer_id

)



,cohort_table AS (

SELECT

    o.customer_id,

    DATEFROMPARTS(YEAR(fp.first_order_date),MONTH(fp.first_order_date),1) AS cohort_month,
    DATEFROMPARTS( YEAR(o.order_date),MONTH(o.order_date), 1) AS order_month

FROM orders o
JOIN first_purchase fp
ON o.customer_id = fp.customer_id

)

,cohort_data AS (

SELECT
cohort_month,
DATEDIFF( MONTH, cohort_month,order_month) AS month_number,
COUNT(DISTINCT customer_id) AS customers

FROM cohort_table

GROUP BY

    cohort_month, DATEDIFF(MONTH,cohort_month, order_month)
    

)




SELECT

    cohort_month,
    month_number,
    customers,

    FIRST_VALUE(customers) OVER (PARTITION BY cohort_month ORDER BY month_number) AS cohort_size,

    ROUND(customers * 100.0 / FIRST_VALUE(customers) OVER (PARTITION BY cohort_month ORDER BY month_number),2) AS retention_rate

FROM cohort_data

ORDER BY

    cohort_month,
    month_number




