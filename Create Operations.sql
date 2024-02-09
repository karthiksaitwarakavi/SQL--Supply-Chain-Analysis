
CREATE TABLE departments(
	Department_Id VARCHAR(55),
    Department_Name VARCHAR(55),
    PRIMARY KEY (Department_Id)
    );

CREATE TABLE categories (
    Category_Id VARCHAR(10),
    Department_Id VARCHAR(55),
    Category_Name VARCHAR(255),
    PRIMARY KEY (Category_Id),
    FOREIGN KEY (Department_Id) REFERENCES departments(Department_Id)
);

CREATE TABLE products(
	Product_Card_Id VARCHAR(10),
    Department_Id VARCHAR(10),
    Product_Name VARCHAR(255),
    Product_Price DECIMAL(10,2),
    Product_Status INT,
    Category_Id VARCHAR(10),
    PRIMARY KEY (Product_Card_Id),
    FOREIGN KEY (Category_Id) REFERENCES categories(Category_Id)
    );

ALTER TABLE products
MODIFY Product_Card_Id VARCHAR(55);
CREATE TABLE customers
(
	Customer_Id VARCHAR(10),
    Customer_Fname VARCHAR(255),
    Customer_Lname VARCHAR(255),
    Customer_City VARCHAR(255),
    Customer_Country VARCHAR(255),
	Customer_Segment VARCHAR(255),
    Customer_State VARCHAR(255),
    Customer_Street VARCHAR(255),
    Customer_Zipcode DOUBLE,
    PRIMARY KEY  (Customer_Id)
);



CREATE TABLE orders(
	Order_Id VARCHAR(10),
    Customer_Id VARCHAR(10),
    Order_City VARCHAR(255),
    Order_Country VARCHAR(255),
    Order_Customer_Id VARCHAR(10),
    Order_date_DateOrders DATETIME,
    shipping_date_DateOrders DATETIME,
    Order_State VARCHAR(255),
    Market VARCHAR(255),
    Order_Region VARCHAR(255),
    Latitude DOUBLE,
    Longitude DOUBLE,
    Order_Status VARCHAR(255),
    PRIMARY KEY (Order_Id),
    foreign key (Customer_Id) REFERENCES customers(Customer_Id)
    );
    
CREATE TABLE order_items(
	Order_Item_Id VARCHAR(10),
    Order_Id VARCHAR(10),
    Order_Item_Total DOUBLE,
    Order_Item_Product_Price DOUBLE,
    Order_Item_Quantity DOUBLE,
    Product_Card_Id VARCHAR(55),
    Order_Item_Discount DOUBLE,
    Order_Item_Discount_Rate DOUBLE,
    Order_Item_Profit_Ratio DOUBLE,
    Sales DOUBLE,
    PRIMARY KEY (Order_Item_Id),
    FOREIGN KEY (Order_Id) REFERENCES orders(Order_Id),
    FOREIGN KEY (Product_Card_Id) REFERENCES products(Product_Card_Id) 
    );

ALTER TABLE order_items
MODIFY Product_Card_Id VARCHAR(55);
    
    
CREATE TABLE shipping(
	Shipping_Id VARCHAR(10),
    Order_Id VARCHAR(10),
    Shipping_Mode VARCHAR(55),
    Days_for_shipping_real INT,
    Days_for_shipment_scheduled INT,
    Delivery_Status VARCHAR(55),
    Late_delivery_risk INT,
    PRIMARY KEY (Shipping_Id),
    FOREIGN KEY (Order_Id) REFERENCES orders(Order_Id)
    );
    

  
SHOW VARIABLES LIKE 'secure_file_priv';
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/departments.csv'
INTO TABLE departments
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 



LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



SET FOREIGN_KEY_CHECKS=0;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET FOREIGN_KEY_CHECKS=1;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS=0;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_Id, Order_City, Customer_Id, Order_Country, Order_Customer_Id, order_date_DateOrders, shipping_date_DateOrders, Order_State, Market, Order_Region, Latitude, Longitude, Order_Status)

SET order_date_DateOrders = STR_TO_DATE(@var1, '%m/%d/%Y'),
    shipping_date_DateOrders = STR_TO_DATE(@var2, '%m/%d/%Y');
SET FOREIGN_KEY_CHECKS=1

---The SET clause in the LOAD DATA INFILE command is used to convert date strings from the CSV file to the DATETIME format required by MySQL using the STR_TO_DATE function---
SET FOREIGN_KEY_CHECKS=0;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
SET FOREIGN_KEY_CHECKS=1;

SET FOREIGN_KEY_CHECKS=0;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shipping.csv'
INTO TABLE shipping
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
SET FOREIGN_KEY_CHECKS=1;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv'
IGNORE
INTO TABLE order_items
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS



    
    
    