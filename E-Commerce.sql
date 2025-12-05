-- Total Sales (Revenue)
SELECT
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS total_revenue
FROM orders;

-- Total Orders (unique Order_ID)
SELECT
  COUNT(DISTINCT `Order_ID`) AS total_orders
FROM orders;

-- Units Sold (sum of Qty)
SELECT
  SUM(`Qty`) AS total_units_sold
FROM orders;

-- AOV = total revenue / total orders
SELECT
  CASE WHEN COUNT(DISTINCT `Order_ID`) = 0 THEN 0
       ELSE SUM(CAST(`Amount` AS DECIMAL(18,2))) / COUNT(DISTINCT `Order_ID`)
  END AS AOV
FROM orders;

-- Delivered % (only Delivered status)
SELECT
  100.0 * SUM(CASE WHEN `Status` = 'Delivered' THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT `Order_ID`),0) AS delivered_pct
FROM orders;


-- Fulfilled % (Delivered + Shipped)
SELECT
  100.0 * SUM(CASE WHEN `Status` IN ('Delivered','Shipped') THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT `Order_ID`),0) AS fulfilled_pct
FROM orders;


-- Daily Revenue and Order Count (grouped by date)
SELECT
  CAST(`Date` AS DATE) AS day,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS daily_revenue,
  COUNT(DISTINCT `Order_ID`) AS daily_orders
FROM orders
GROUP BY CAST(`Date` AS DATE)
ORDER BY CAST(`Date` AS DATE);


-- Revenue by state (top states, plus 'Other' grouping)
SELECT
  COALESCE(`ship-state`, 'Unknown') AS state,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS revenue
FROM orders
GROUP BY COALESCE(`ship-state`, 'Unknown')
ORDER BY revenue DESC;


-- Revenue by Category (top N)
SELECT
  COALESCE(`Category`, 'Unknown') AS category,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS total_revenue,
  SUMT(`Qty`) AS total_qty
FROM orders
GROUP BY COALESCE(`Category`, 'Unknown')
ORDER BY total_revenue DESC
LIMIT 10;

-- Category-wise table with Quantity, Avg Order Value (AOV), Total Amount
SELECT
  COALESCE(`Category`, 'Unknown') AS category,
  SUM(`Qty`) AS quantity,
  CASE WHEN COUNT(DISTINCT `Order_ID`) = 0 THEN 0
       ELSE SUM(CAST(`Amount` AS DECIMAL(18,2))) / COUNT(DISTINCT `Order_ID`)
  END AS avg_order_value,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS total_amount
FROM orders
GROUP BY COALESCE(`Category`, 'Unknown')
ORDER BY total_amount DESC;

-- Revenue by ship-service-level (Standard vs Expedited)
SELECT
  COALESCE(`ship-service-level`, 'Unknown') AS ship_service_level,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS revenue,
  COUNT(DISTINCT `Order_ID`) AS orders
FROM orders
GROUP BY COALESCE(`ship-service-level`, 'Unknown')
ORDER BY revenue DESC;


-- If profit is not present, show revenue as a proxy for comparison across delivery types
SELECT
  COALESCE(`ship-service-level`, 'Unknown') AS ship_service_level,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS revenue
FROM orders
GROUP BY COALESCE(`ship-service-level`, 'Unknown')
ORDER BY revenue DESC;


-- Waterfall: Order counts by Status
SELECT
  `Status`,
  COUNT(DISTINCT `Order_ID`) AS orders_count
FROM orders
GROUP BY `Status`
-- you may want to order rows as: Shipped, Delivered, Pending, Returned, Cancelled
ORDER BY FIELD(`Status`, 'Shipped', 'Delivered', 'Pending', 'Returned', 'Cancelled');


-- Revenue: Promotion vs No Promotion (assuming promotion-ids = 'No Promotion' when none)
SELECT
  CASE WHEN COALESCE(`promotion-ids`, '') = '' OR `promotion-ids` = 'No Promotion' THEN 'No Promotion'
       ELSE 'Promotion'
  END AS promo_flag,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS revenue,
  COUNT(DISTINCT `Order_ID`) AS orders
FROM orders
GROUP BY promo_flag;


-- Shipped vs Not Shipped (based on Status)
SELECT
  CASE WHEN `Status` IN ('Shipped','Delivered') THEN 'Shipped'
       ELSE 'Not Shipped'
  END AS shipped_flag,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS revenue,
  COUNT(DISTINCT `Order_ID`) AS orders
FROM orders
GROUP BY shipped_flag;


-- Top SKUs by quantity and revenue
SELECT
  COALESCE(`SKU`, 'Unknown') AS sku,
  COALESCE(`ASIN`, '') AS asin,
  SUM(`Qty` ) AS total_qty,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS total_revenue
FROM orders
GROUP BY COALESCE(`SKU`, 'Unknown'), COALESCE(`ASIN`, '')
ORDER BY total_qty DESC
LIMIT 20;

-- B2B vs B2C revenue & orders (assuming B2B flagged TRUE/FALSE)
SELECT
  CASE WHEN COALESCE(`B2B`, 'FALSE') IN ('TRUE', '1', 'true') THEN 'B2B' ELSE 'B2C' END AS customer_type,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS revenue,
  COUNT(DISTINCT `Order_ID`) AS orders
FROM orders
GROUP BY customer_type;


-- Courier status count and revenue
SELECT
  COALESCE(`Courier_Status`, 'Unknown') AS courier_status,
  COUNT(DISTINCT `Order_ID`) AS orders,
  SUM(CAST(`Amount` AS DECIMAL(18,2))) AS revenue
FROM orders
GROUP BY COALESCE(`Courier_Status`, 'Unknown')
ORDER BY orders DESC;





