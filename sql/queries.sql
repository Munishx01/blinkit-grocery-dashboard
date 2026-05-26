-- ============================================================
-- Blinkit Grocery Sales Analytics Dashboard — SQL Queries
-- Author: Grocery BI Analytics Project
-- Database: PostgreSQL / MySQL / SQL Server compatible
-- ============================================================

-- ─────────────────────────────────────────
-- 1. DATABASE & TABLE SETUP
-- ─────────────────────────────────────────

CREATE TABLE grocery_sales (
    order_id         VARCHAR(20)    PRIMARY KEY,
    order_date       DATE           NOT NULL,
    city             VARCHAR(50),
    category         VARCHAR(80),
    sub_category     VARCHAR(80),
    quantity         INT,
    unit_price       DECIMAL(10,2),
    total_sales      DECIMAL(12,2),
    payment_method   VARCHAR(30),
    outlet_type      VARCHAR(30),
    customer_type    VARCHAR(20),    -- New / Repeat / Loyal
    delivery_status  VARCHAR(20),    -- On-time / Delayed
    delivery_time_mins INT,
    return_flag      CHAR(3)         -- Yes / No
);

-- ─────────────────────────────────────────
-- 2. KPI CARDS
-- ─────────────────────────────────────────

-- Total Sales (Current Period: Apr 1 – May 19, 2025)
SELECT
    ROUND(SUM(total_sales) / 10000000, 2) AS total_sales_cr
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19';

-- Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19';

-- Total Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19';

-- Average Order Value
SELECT ROUND(AVG(total_sales), 2) AS avg_order_value
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19';

-- On-time Delivery Rate
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN delivery_status = 'On-time' THEN 1 ELSE 0 END)
        / COUNT(*), 1
    ) AS on_time_delivery_pct
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19';

-- Return Rate
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN return_flag = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS return_rate_pct
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19';

-- MoM Growth Comparison
SELECT
    current_period.total_sales AS current_sales,
    previous_period.total_sales AS prev_sales,
    ROUND(
        100.0 * (current_period.total_sales - previous_period.total_sales)
        / previous_period.total_sales, 1
    ) AS mom_growth_pct
FROM
    (SELECT SUM(total_sales) AS total_sales FROM grocery_sales
     WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19') AS current_period,
    (SELECT SUM(total_sales) AS total_sales FROM grocery_sales
     WHERE order_date BETWEEN '2025-03-01' AND '2025-03-31') AS previous_period;


-- ─────────────────────────────────────────
-- 3. SALES OVER TIME (Daily / Weekly / Monthly)
-- ─────────────────────────────────────────

-- Daily Sales Trend
SELECT
    order_date,
    ROUND(SUM(total_sales), 2) AS daily_sales
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY order_date
ORDER BY order_date;

-- Weekly Sales Trend
SELECT
    DATE_TRUNC('week', order_date) AS week_start,
    ROUND(SUM(total_sales), 2) AS weekly_sales
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY DATE_TRUNC('week', order_date)
ORDER BY week_start;


-- ─────────────────────────────────────────
-- 4. SALES BY CATEGORY
-- ─────────────────────────────────────────

SELECT
    category,
    ROUND(SUM(total_sales), 2) AS category_sales,
    ROUND(100.0 * SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 1) AS pct_share
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY category
ORDER BY category_sales DESC;


-- ─────────────────────────────────────────
-- 5. TOP 10 SUB-CATEGORIES BY SALES
-- ─────────────────────────────────────────

SELECT
    sub_category,
    category,
    ROUND(SUM(total_sales) / 100000, 2) AS sales_lakh
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY sub_category, category
ORDER BY SUM(total_sales) DESC
LIMIT 10;


-- ─────────────────────────────────────────
-- 6. SALES BY CITY (Heatmap — City x Week)
-- ─────────────────────────────────────────

SELECT
    city,
    DATE_PART('week', order_date) - DATE_PART('week', '2025-04-01'::DATE) + 1 AS week_no,
    ROUND(SUM(total_sales), 2) AS sales
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY city, week_no
ORDER BY city, week_no;


-- ─────────────────────────────────────────
-- 7. ORDERS BY PAYMENT METHOD
-- ─────────────────────────────────────────

SELECT
    payment_method,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_share
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY payment_method
ORDER BY order_count DESC;


-- ─────────────────────────────────────────
-- 8. DELIVERY PERFORMANCE OVER TIME
-- ─────────────────────────────────────────

SELECT
    order_date,
    ROUND(
        100.0 * SUM(CASE WHEN delivery_status = 'On-time' THEN 1 ELSE 0 END) / COUNT(*), 1
    ) AS on_time_pct,
    ROUND(
        100.0 * SUM(CASE WHEN delivery_status = 'Delayed' THEN 1 ELSE 0 END) / COUNT(*), 1
    ) AS delayed_pct
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY order_date
ORDER BY order_date;


-- ─────────────────────────────────────────
-- 9. CUSTOMER SEGMENTATION
-- ─────────────────────────────────────────

SELECT
    customer_type,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(100.0 * COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER (), 1) AS pct_share
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY customer_type;


-- ─────────────────────────────────────────
-- 10. REVENUE BY OUTLET TYPE
-- ─────────────────────────────────────────

SELECT
    outlet_type,
    ROUND(SUM(total_sales), 2) AS revenue,
    ROUND(100.0 * SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 1) AS pct_share
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY outlet_type
ORDER BY revenue DESC;


-- ─────────────────────────────────────────
-- 11. PEAK ORDER HOURS ANALYSIS
-- ─────────────────────────────────────────

SELECT
    EXTRACT(HOUR FROM order_time) AS hour_of_day,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_sales), 2) AS hourly_revenue
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- ─────────────────────────────────────────
-- 12. REPEAT CUSTOMER REVENUE CONTRIBUTION
-- ─────────────────────────────────────────

SELECT
    customer_type,
    ROUND(SUM(total_sales), 2) AS total_revenue,
    ROUND(AVG(total_sales), 2) AS avg_order_value,
    COUNT(*) AS total_orders
FROM grocery_sales
WHERE order_date BETWEEN '2025-04-01' AND '2025-05-19'
GROUP BY customer_type
ORDER BY total_revenue DESC;
