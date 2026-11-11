--What are monthly sales, and what is the change from the previous month?
--The sales fall steeply at the end of the dataset, and Q8 shows a decline of about 40% in a single month
with monthly as ( 
	select 
		year(o.Order_Date) as Order_Year,
		month(o.Order_Date) as Order_Month,
		sum(oi.Sales) as Monthly_Sales
		from order_items oi 
		join orders o on oi.Order_Id = o.Order_Id
		group by year(o.Order_Date), month(o.Order_Date) 
)
select 
Order_Year,
Order_Month,
Monthly_Sales,

lag(Monthly_Sales) over (order by Order_Year, Order_Month) as Prev_Month_Sales,

Monthly_Sales - lag(Monthly_Sales) over (order by Order_Year, Order_Month) as Change_Dollars,

100.0 * (Monthly_Sales - lag(Monthly_Sales)  over (order by Order_Year, Order_Month)) / nullif(lag(Monthly_Sales) over (order by Order_Year, Order_Month), 0) as Change_Pct 

from monthly 
order by Order_Year, Order_Month;

----Monthly sales with a running (cumulative) total
with monthly as ( 
	select 
		year(o.Order_Date) as Order_Year,
		month(o.Order_Date) as Order_Month,
		sum(oi.Sales) as Monthly_Sales
		from order_items oi 
		join orders o on oi.Order_Id = o.Order_Id
		group by year(o.Order_Date), month(o.Order_Date) 
)
select 
Order_Year,
Order_Month,
Monthly_Sales,
sum(Monthly_Sales) over(order by Order_Year, Order_Month) as Running_Total 
from monthly
order by Order_Year, Order_Month;

--Top 3 products by sales within each market:
with Product_Sales as (
		select 
		o.Market,
		p.Product_Name,
		sum(oi.sales) as Total_Sales 
		from order_items oi 
		join orders o on oi.Order_Id = o.Order_Id 
		join products p on oi.Product_Card_Id = p.Product_Card_Id
		group by o.Market, p.Product_Name
),

	ranked as ( 
	select 
	 Market,
     Product_Name,
     Total_Sales,
	 row_number() over (partition by Market order by Total_Sales desc) as Rank_In_Market 
	 from Product_Sales
)
select 
Market,
Rank_In_Market,
Product_Name,
Total_Sales 
from ranked 
where Rank_In_Market <= 3
order by Market, Rank_In_Market asc;






		