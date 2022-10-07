
--INSTRUCTIONS:
--Write a SQL query to identify which category the product should fall:
--Add a column called Sales_Volume where “High Sales, High Quantity” = Quantity Sold > 100  and Total Sales 
-->$500 a given month, “High Sales, Low Quantity” = Quantity Sold <100  and Total Sales > $500 within a given 
--month,“Low Sales, Low Quantity” = Quantity Sold < 100  and Total Sales < $500 within a given month, “Low 
--Sales, High Quantity" = Quantity Sold > 100 and Total Sales <$500 within a given month
--Add a column called ‘Frequent_Buyer’ for Customers/Companies who also bought more than 20 unique products 
--within a given month
--Add a column called “Days_Ordered_Shipped” that calculates the number of days between the order date 
--and ship date. 
--Add a column called “Shipping_Speed” the products that shipped within 5 days of the order date, those >5 
--days, or orders that have not shipped at all
--Dataset should include the following columns/information as well as those above:
--Category Name
--Order Date
--Total Quantity 
--Total Sales (before and after discount) - 2 separate columns
--Customer: Company Name, Country, and Region
--Shipper: Company Name
--Export results to a CSV
--Using the CSV file, create a dashboard in Tableau of your findings.
--Be sure to include at least 3 charts.

select *
from shippers s 

select * 
from customers c

select * 
from order_details od 


select ordermonth, orderyear, category_name, totalquantity, TotalSalesBeforeDiscount, LineTotalSales, a.CustomerName, country, region, shippername,
	ProductCount, Days_ordered_shipped,
case when totalquantity >= 100 and linetotalsales >= 500 then 'High Sales, High Quantity'
	when totalquantity < 100 and linetotalsales >= 500 then 'High Sales, Low Quantity'
	when totalquantity < 100 and linetotalsales < 500 then 'Low Sales, Low Quantity'
	when totalquantity >= 100 and linetotalsales < 500 then 'Low Sales, High Quantity' else 'error' end as Sales_Volume,
case when productcount >= 20 then 'Yes'
	 else 'No' end as FrequentBuyer,
case when days_ordered_shipped <= interval '5 day' then 'Fast Shipment'
 	when days_ordered_shipped > interval '5 day' then 'Slow Shipment'
 	when days_ordered_shipped isnull then 'Not Shipped'
 	else 'error' end as ShippingSpeed
from
(
select extract(year from o.order_date) as orderyear,extract(month from o.order_date) as ordermonth, c.category_name, o.order_date, 
	sum(od.quantity) as TotalQuantity, sum(od.quantity*od.unit_price) as TotalSalesBeforeDiscount, 
	sum((od.quantity*od.unit_price)-(od.quantity*od.unit_price*od.discount)) as LineTotalSales,
	c2.company_name as CustomerName, c2.country, c2.region, s.company_name as ShipperName, 
	((shipped_date::timestamp)- (order_date::timestamp)) as Days_Ordered_Shipped
from products p 
join categories c on p.category_id = c.category_id 
join order_details od on od.product_id = p.product_id 
join orders o on o.order_id = od.order_id 
join customers c2  on c2.customer_id = o.customer_id 
join shippers s on s.shipper_id = o.ship_via 
group by extract(year from o.order_date), extract(month from o.order_date), c.category_name,
	od.quantity, c2.company_name, c2.country, c2.region, s.company_name, od.unit_price, od.discount, o.order_date, o.shipped_date
)a,
(
select c.company_name as Customername, count(distinct od.product_id) as productcount
from order_details od
join orders o on od.order_id =o.order_id 
join customers c on o.customer_id = c.customer_id 
join products p on p.product_id = od.product_id 
group by c.company_name
)b
where a.customername = b.customername
order by a.customername

--select c.company_name as Customer, count(distinct od.product_id)
--from order_details od
--join orders o on od.order_id =o.order_id 
--join customers c on o.customer_id = c.customer_id 
--join products p on p.product_id = od.product_id 
--group by c.company_name
--having count(distinct od.product_id) >= 20



--on a.shipmonth = b.shipmonth and a.CustomerName = b.CustomerName

--REFERENCE
--DATE SYNTAX
--select date_trunc('month',o.shipped_date), count(o.shipped_date)
--from orders o 
--group by date_trunc('month',o.shipped_date)

--SELECT aggregate_function (name_of_column), EXTRACT(MONTH FROM name_of_column) FROM name_of_table GROUP BY EXTRACT (MONTH FROM name_of_column);

--Select DATE_TRUNC (‘month’, name_of_column) count (name_of_column) from name_of_table GROUP BY DATE_TRUNC (‘month’, name_of_column);
--CASE SYNTAX EXAMPLE
--select a.Artist, sum(t.Unitprice) totalprice
--from
--(
--Select a.artistid, a.Name as Artist,
--Case When Count(a2.title) between 0 and 5 then '5 Albums or Less'
--When Count(a2.title) between 6 and 10 then '6-10 Albums'
--Else 'More than 10 Albums' end as Album_Group
--From artist a
--Inner join album a2 on a.ArtistId = a2.ArtistId
--Group by a.name, a.artistid
--)a
--join album aa on aa.ArtistId = a.artistid
--join track t on t.AlbumId = aa.AlbumId
--where a.album_group = '6-10 Albums'
--group by a.artistid (edited) 






