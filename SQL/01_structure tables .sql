/* =====================================================================
   01_create_tables.sql
   Splits the raw DataCo import into 6 normalized tables.

   BEFORE RUNNING: replace  dbo.DataCoSupplyChainDataset  (Ctrl+H)
   with the name of YOUR imported table, as shown in Object Explorer.
   ===================================================================== */

USE supply_chain;
GO

/* ---------- 1. Drop tables (children first) so the script can rerun ---------- */
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS departments;
GO

/* ---------- 2. Create tables (parents first) ---------- */
CREATE TABLE departments (
    Department_Id    INT           PRIMARY KEY,
    Department_Name  NVARCHAR(50)  NOT NULL
);

CREATE TABLE categories (
    Category_Id      INT           PRIMARY KEY,
    Category_Name    NVARCHAR(50)  NOT NULL,
    Department_Id    INT           NOT NULL FOREIGN KEY REFERENCES departments(Department_Id)
);

CREATE TABLE products (
    Product_Card_Id  INT            PRIMARY KEY,
    Product_Name     NVARCHAR(100)  NOT NULL,
    Category_Id      INT            NOT NULL FOREIGN KEY REFERENCES categories(Category_Id),
    Product_Price    DECIMAL(10,2)  NOT NULL,
    Product_Status   BIT            NOT NULL      -- 1 = not available, 0 = available
);

CREATE TABLE customers (
    Customer_Id       INT           PRIMARY KEY,
    Customer_Fname    NVARCHAR(50),
    Customer_Lname    NVARCHAR(50),
    Customer_Segment  NVARCHAR(50),
    Customer_Street   NVARCHAR(100),
    Customer_City     NVARCHAR(50),
    Customer_State    NVARCHAR(50),
    Customer_Country  NVARCHAR(50),
    Customer_Zipcode  INT
);

CREATE TABLE orders (
    Order_Id                     INT           PRIMARY KEY,
    Customer_Id                  INT           NOT NULL FOREIGN KEY REFERENCES customers(Customer_Id),
    Order_Date                   DATETIME2(0)  NOT NULL,
    Shipping_Date                DATETIME2(0),
    Payment_Type                 NVARCHAR(20),
    Order_Status                 NVARCHAR(30),
    Shipping_Mode                NVARCHAR(30),
    Delivery_Status              NVARCHAR(30),
    Late_Delivery_Risk           BIT,
    Days_Shipping_Real           INT,
    Days_Shipping_Scheduled      INT,
    Market                       NVARCHAR(30),
    Order_Region                 NVARCHAR(50),
    Order_Country                NVARCHAR(50),
    Order_State                  NVARCHAR(50),
    Order_City                   NVARCHAR(50)
);

CREATE TABLE order_items (
    Order_Item_Id     INT            PRIMARY KEY,
    Order_Id          INT            NOT NULL FOREIGN KEY REFERENCES orders(Order_Id),
    Product_Card_Id   INT            NOT NULL FOREIGN KEY REFERENCES products(Product_Card_Id),
    Quantity          INT            NOT NULL,
    Unit_Price        DECIMAL(10,2)  NOT NULL,
    Discount          DECIMAL(10,2),
    Discount_Rate     DECIMAL(6,4),
    Sales             DECIMAL(10,2),  -- price x quantity, before discount
    Item_Total        DECIMAL(10,2),  -- sales after discount
    Profit            DECIMAL(10,2),
    Profit_Ratio      DECIMAL(8,4)
);
GO

/* ---------- 3. Fill tables from the raw import (parents first) ---------- */
INSERT INTO departments (Department_Id, Department_Name)
SELECT DISTINCT Department_Id, Department_Name
FROM dbo.DataCoSupplyChainDataset;

INSERT INTO categories (Category_Id, Category_Name, Department_Id)
SELECT DISTINCT Category_Id, Category_Name, Department_Id
FROM dbo.DataCoSupplyChainDataset;

INSERT INTO products (Product_Card_Id, Product_Name, Category_Id, Product_Price, Product_Status)
SELECT DISTINCT Product_Card_Id, Product_Name, Product_Category_Id, Product_Price, Product_Status
FROM dbo.DataCoSupplyChainDataset;

INSERT INTO customers (Customer_Id, Customer_Fname, Customer_Lname, Customer_Segment,
                       Customer_Street, Customer_City, Customer_State, Customer_Country, Customer_Zipcode)
SELECT DISTINCT Customer_Id, Customer_Fname, Customer_Lname, Customer_Segment,
                Customer_Street, Customer_City, Customer_State, Customer_Country, Customer_Zipcode
FROM dbo.DataCoSupplyChainDataset;

INSERT INTO orders (Order_Id, Customer_Id, Order_Date, Shipping_Date, Payment_Type, Order_Status,
                    Shipping_Mode, Delivery_Status, Late_Delivery_Risk, Days_Shipping_Real,
                    Days_Shipping_Scheduled, Market, Order_Region, Order_Country, Order_State, Order_City)
SELECT DISTINCT Order_Id, Order_Customer_Id, order_date_DateOrders, shipping_date_DateOrders, [Type], Order_Status,
                Shipping_Mode, Delivery_Status, Late_delivery_risk, Days_for_shipping_real,
                Days_for_shipment_scheduled, Market, Order_Region, Order_Country, Order_State, Order_City
FROM dbo.DataCoSupplyChainDataset;

INSERT INTO order_items (Order_Item_Id, Order_Id, Product_Card_Id, Quantity, Unit_Price, Discount,
                         Discount_Rate, Sales, Item_Total, Profit, Profit_Ratio)
SELECT Order_Item_Id, Order_Id, Order_Item_Cardprod_Id, Order_Item_Quantity, Order_Item_Product_Price,
       Order_Item_Discount, Order_Item_Discount_Rate, Sales, Order_Item_Total,
       Order_Profit_Per_Order, Order_Item_Profit_Ratio
FROM dbo.DataCoSupplyChainDataset;
GO

/* ---------- 4. Check row counts ----------
   Expected: departments 11, categories 51, products 118,
             customers 20652, orders 65752, order_items 180519 */
SELECT 'departments' AS table_name, COUNT(*) AS row_count FROM departments
UNION ALL SELECT 'categories',  COUNT(*) FROM categories
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'customers',   COUNT(*) FROM customers
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;