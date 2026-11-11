



-- getting the total orders = 180519, total reveneue = 33054355.91, total profit = 21743.45 (rounded up)
select 
count(Order_Id) as Total_Orders,
sum(sales - discount) as Total_Revenue,
sum(profit/(sales - discount)) as Total_Profit
from order_items;


--this is the average delivery rate for each shipping mode 
select 
    Shipping_Mode,
    avg(cast(Late_delivery_risk as float)) as Late_Delivery_Rate
from orders
group by Shipping_Mode;


--the market with the highest delivery rate 
select
Market,
avg(cast(Late_Delivery_Risk as float)) as Late_Delivery_Rate
from orders
group by Market
order by Late_Delivery_Rate desc;











