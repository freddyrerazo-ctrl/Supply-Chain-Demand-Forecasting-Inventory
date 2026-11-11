/* =====================================================================
   03_create_page_views.sql
   Adds the website clickstream (access logs) as a 7th table,
   linked to products by product name.

   BEFORE RUNNING: replace  dbo.tokenized_access_logs  (Ctrl+H)
   with the name of YOUR imported access-logs table, as shown in Object Explorer.
   Run 01_create_tables.sql first (this table depends on products).
   ===================================================================== */

USE supply_chain;
GO

SET DATEFORMAT mdy;   -- log dates look like 9/1/2017 6:00
GO

/* ---------- 1. Drop and create ---------- */
DROP TABLE IF EXISTS page_views;
GO

CREATE TABLE page_views (
    View_Id          INT IDENTITY(1,1) PRIMARY KEY,   -- auto-numbered, logs have no ID
    Product_Card_Id  INT           NOT NULL FOREIGN KEY REFERENCES products(Product_Card_Id),
    View_Date        DATETIME2(0)  NOT NULL,
    View_Hour        TINYINT,
    IP_Address       NVARCHAR(45),
    Url              NVARCHAR(400)
);
GO

/* ---------- 2. Fill it ----------
   Join on the trimmed product name to get each view's Product_Card_Id.
   Views whose product isn't in the sales data (about 8%) are dropped by the join.
   Category and Department from the logs are skipped on purpose: they're unreliable. */
INSERT INTO page_views (Product_Card_Id, View_Date, View_Hour, IP_Address, Url)
SELECT p.Product_Card_Id,
       TRY_CONVERT(DATETIME2(0), l.[Date]),
       l.[Hour],
       l.ip,
       l.url
FROM dbo.tokenized_access_logs AS l
JOIN products AS p
  ON TRIM(l.Product) = TRIM(p.Product_Name)
WHERE TRY_CONVERT(DATETIME2(0), l.[Date]) IS NOT NULL;
GO

/* ---------- 3. Checks ---------- */
-- Expect about 433,000 rows
SELECT COUNT(*) AS page_view_rows FROM page_views;

-- Expect roughly 2017-09-01 to 2018-01-31
SELECT MIN(View_Date) AS first_view, MAX(View_Date) AS last_view FROM page_views;

-- How many views were dropped because the product name had no match
SELECT COUNT(*) AS unmatched_views
FROM dbo.tokenized_access_logs AS l
WHERE NOT EXISTS (SELECT 1 FROM products p WHERE TRIM(p.Product_Name) = TRIM(l.Product));