--top 10 catagories by profit 
select top 10
cate.category_Name as Category_Name,
sum(o.Sales) as Total_Sales,
sum(o.Profit) as Total_Profit
from order_items o
join products p on o.Product_Card_Id = p.Product_Card_Id
join categories cate on p.Category_Id = cate.Category_Id
group by Category_Name 
order by Total_Profit desc 

--Which categories lose money overall?
-- Finding: no category loses money overall (all 51 are profitable in total)
select
cate.category_Name as Category_Name,
sum(o.Profit) as Total_Profit
from order_items o
join products p      on o.Product_Card_Id = p.Product_Card_Id
join categories cate      on p.Category_Id = cate.Category_Id
group by Category_Name 
having sum(o.profit) < 0;

--^follow up 1: lowest margin categorys --
-- Q5b: Categories ranked from lowest to highest profit margin
select 
cate.Category_Name as Category_Name,
sum(o.Sales) as Total_Sales,
sum(o.Profit) as Total_Profit,
sum(o.Profit) / sum(o.Sales) as Profit_Margin 
from order_items o
join products p      on o.Product_Card_Id = p.Product_Card_Id
join categories cate      on p.Category_Id = cate.Category_Id
group by Category_Name
order by Profit_Margin asc;

--^follow up 2: Products that lose money--
select
p.Product_Name as Product_Name,
sum(o.Profit) as Total_Profit
from order_items o
join products p      on o.Product_Card_Id = p.Product_Card_Id
group by p.Product_Name 
having sum(o.profit) < 0
order by Total_profit asc;


--How do customer segments compare on revenue?
select 
c.Customer_Segment,
count(distinct o.Order_Id) as Total_Orders,
sum(oi.Sales) as Gross_Revenue,
sum(oi.item_total) as Net_profit,
sum(oi.profit) as Total_Profit
from order_Items oi 
join orders o on oi.Order_Id = o.Order_Id
join customers c on o.Customer_Id = c.Customer_Id
group by c.Customer_Segment 
order by Gross_Revenue desc;

--What percentage of order items lose money? 
select 
count(*) as Total_Itmes,
sum(case when Profit <0 then 1 else 0 end) as Losing_Itmes,
 100.0 * sum(case when Profit < 0 then 1 else 0 end ) / count(*) as Pct_Losing 
 from order_items; 

--why those items lose money?
select 
o.Shipping_Mode,
100.0 *sum(case when oi.profit <0 then 1 else 0 end) / count(*) as Pcr_Losing
from order_items oi 
join orders o on oi.Order_Id = o.Order_Id
group by o.Shipping_Mode;

--checking the market to see if it explains why these items lose money fyi it dose not 
select 
o.Market,
100.0 *sum(case when oi.Profit <0 then 1 else 0 end) / count(*) as Pcr_Losing
from order_items oi 
join orders o on oi.Order_Id = o.Order_Id
group by o.Market;

--Does discount rate drive loss-making items?
--The loss rate is flat, between about 18.1% and 19.6% at every discount level, and it doesn’t rise as discounts grow. Items with no discount lose money 18.4% of the time, and items with a 25% discount lose money 18.5% of the time
select 
oi.Discount_Rate,
count(*) as Items,
100.0 *sum(case when oi.Profit <0 then 1 else 0 end) / count(*) as Pcr_Losing
from order_items oi 
group by oi.Discount_Rate
order by oi.Discount_Rate;

