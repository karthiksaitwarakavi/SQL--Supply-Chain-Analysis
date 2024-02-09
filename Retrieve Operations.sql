/*Tables*/

SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM shipping;

/*Identify total number of categories*/
SELECT COUNT(DISTINCT(Category_Id)) as Distinct_category_Ids 
FROM categories;

/* Identify details of customers who belongs to New York*/
SELECT * FROM customers WHERE customer_city LIKE "New York";

/* To How many Countries does company belongs to */
SELECT COUNT(DISTINCT(Customer_Country)) FROM customers;

/* Identify top 5 countries with highest customer base*/
SELECT Order_Country, COUNT(distinct (o.Customer_Id)) as Total_Customers 
FROM orders o
JOIN customers c on o.Customer_Id=c.Customer_Id
GROUP BY Order_Country
ORDER BY Total_Customers DESC
Limit 5;

/*In how many countries Company has its presence*/
SELECT COUNT(distinct(Order_Country)) as Number_of_Countries FROM Orders;

/* How many customers are in each segment*/
SELECT Customer_segment, count(customer_Id) as Total_Customers
FROM customers GROUP BY Customer_segment;

/* Which customer state has highest number of customers*/

SELECT Customer_Country,Customer_state,  COUNT(Customer_Id) as Highest_customers
FROM Customers GROUP BY Customer_State,Customer_Country
ORDER BY COUNT(Customer_state) DESC LIMIT 1;

/* What are the top 5 countries from which orders come?*/
SELECT Order_Country, COUNT(Order_Id) as Total_Orders
FROM orders GROUP BY Order_Country ORDER BY Total_Orders DESC
LIMIT 5

/* How many Categories are in each Department*/

SELECT d.Department_Name,count(Category_Name) as Number_of_categories
FROM categories c JOIN Departments d on c.Department_Id=d.Department_Id
GROUP BY Department_Name
ORDER BY Number_of_categories DESC;

/* Which Countries have more than Average sales*/
SELECT * FROM
(SELECT order_country,sum(sales) as total_sales FROM
(SELECT o.order_country, oi.sales FROM orders o JOIN order_items oi
on o.Order_Id =oi.Order_Id) data 
GROUP BY order_country) grouped_sales
WHERE total_sales>(SELECT avg(sales) FROM order_items);

/*Identify top 5 customers with highest number of orders*/

SELECT Customer_Id, count(Order_Id) as Total_Orders
FROM orders group by Customer_Id
ORDER BY Total_Orders DESC
LIMIT 5;

/* Rank the departments based on their total order volume?*/

SELECT
    d.Department_Name,
    COUNT(o.Order_Id) AS Total_Orders,
    RANK() OVER ( ORDER BY COUNT(o.Order_Id) DESC) AS RNK
FROM
    order_items oi
    JOIN products p ON oi.Product_Card_Id = p.Product_Card_Id
    JOIN orders o ON oi.Order_Id = o.Order_Id
    JOIN customers c ON o.Customer_Id = c.Customer_Id
    JOIN departments d ON p.Department_id = d.Department_Id
GROUP BY
    d.Department_Name;
    
/* Identify Top 5 products in terms of Sales*/
WITH Ranked_Products AS (
SELECT  p.Product_Name,round(sum(oi.sales),0) as Total_Sales,
rank() over(ORDER BY round(sum(oi.sales),0) DESC) as Rnk 
FROM products p
JOIN order_items oi ON p.Product_Card_Id= oi.Product_Card_Id
GROUP BY p.Product_Name
ORDER BY Total_Sales DESC)

SELECT Product_Name, Total_Sales,Rnk
FROM Ranked_Products
WHERE Rnk<=5
ORDER BY Rnk;

/* Identify departments with less than Average Net profit and create a view*/
CREATE VIEW Departments_Below_Avg_Net_Profit AS
WITH Total_Net_Profit_Table AS (
    SELECT 
        d.Department_Name,
        round(SUM((Sales - (Sales * Order_item_Discount_Rate) * Order_Item_Profit_Ratio)),0) AS Total_Net_Profit 
    FROM 
        order_items
    JOIN products p ON order_items.Product_Card_Id = p.Product_Card_Id
    JOIN departments d ON p.Department_Id = d.Department_Id
    GROUP BY d.Department_Name
), Average_Net_Profit AS (
    SELECT 
        AVG(Total_Net_Profit) AS Avg_Net_Profit 
    FROM 
        Total_Net_Profit_Table
)
SELECT 
    t.Department_Name, 
    t.Total_Net_Profit 
FROM 
    Total_Net_Profit_Table t, 
    Average_Net_Profit a
WHERE 
    t.Total_Net_Profit < a.Avg_Net_Profit;

/* Create stored procedure for regions and their sales*/
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sales_by_order_region`(o_r varchar(255))
BEGIN
    SELECT 
        o.Order_Region, 
        FORMAT(sum(Sales), 0) as Sales 
    FROM 
        orders o 
        JOIN order_items oi ON o.Order_Id = oi.Order_Id
    WHERE 
        o.Order_Region = o_r
    GROUP BY 
        o.Order_Region;	
END $$

DELIMITER ;

/* Show the shipping_modes and their count of eaerly and late delivery instances by using Temporary tables*/

CREATE TEMPORARY TABLE delivery_counts AS
WITH late_delivery_days_details AS (
    SELECT
        Shipping_Mode,
        (Days_for_shipment_scheduled - Days_for_shipping_real) AS late_delivery_days
    FROM
        shipping
)
SELECT
    Shipping_Mode,
    SUM(CASE WHEN late_delivery_days < 0 THEN 1 ELSE 0 END) AS early_delivery,
    SUM(CASE WHEN late_delivery_days > 0 THEN 1 ELSE 0 END) AS late_delivered
FROM
    late_delivery_days_details
GROUP BY
    Shipping_Mode;
Select * from delivery_counts;

/* How does the total product price vary between each department, and what is the sequential price difference from one department to the next?*/

    SELECT *, (Total_Price-next_product_price) as price_difference FROM
(with Department_product_price AS(
SELECT d.Department_Name,sum(p.Product_Price) as Total_Price 
FROM departments d JOIN products p
ON d.Department_Id=p.Department_Id
GROUP BY d.Department_Name, d.department_id
)
select *, lead(Total_Price,1,0) over() as next_product_price 
FROM Department_product_price ) price_difference_table

/*Calculate discount difference of previous product*/

WITH previous_order_discount_table as (
SELECT *, lag(Order_discount,1,0) over() as previous_order_discount,
ROW_NUMBER() OVER() as row_num
 FROM 
(SELECT  p.Product_Name,avg(round((oi.Order_Item_Discount_Rate)*100,2)) as Order_discount
FROM order_items oi JOIN products p ON
oi.Product_Card_Id= p.Product_Card_Id
GROUP BY p.Product_Name) avg_order_discount)

SELECT Product_Name, round((Order_discount-previous_order_discount),3) as discount_difference
FROM previous_order_discount_table
WHERE row_num > 1



