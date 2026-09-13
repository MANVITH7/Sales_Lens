-- ============================================================================
-- Analytical views for the sales_orders table
-- Run this file once against retail_analytics.db to create all views:
--   sqlite3 retail_analytics.db < sql/views.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- yearly_regional_sales
-- Sales/profit by region and year, with year-over-year % growth.
-- Powers: the "regional YoY trend" line chart in Power BI.
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS yearly_regional_sales;
CREATE VIEW yearly_regional_sales AS
WITH regional_totals AS (
    SELECT
        region,
        order_year,
        SUM(sales)   AS total_sales,
        SUM(profit)  AS total_profit,
        COUNT(DISTINCT order_id) AS order_count
    FROM sales_orders
    GROUP BY region, order_year
)
SELECT
    region,
    order_year,
    total_sales,
    total_profit,
    order_count,
    LAG(total_sales) OVER (PARTITION BY region ORDER BY order_year) AS prior_year_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (PARTITION BY region ORDER BY order_year))
        * 100.0 / LAG(total_sales) OVER (PARTITION BY region ORDER BY order_year),
        2
    ) AS yoy_sales_growth_pct
FROM regional_totals
ORDER BY region, order_year;

-- ----------------------------------------------------------------------------
-- top_products_by_category
-- Top 10 products by total sales within each category.
-- Powers: the "top products" bar chart in Power BI.
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS top_products_by_category;
CREATE VIEW top_products_by_category AS
WITH product_totals AS (
    SELECT
        category,
        sub_category,
        product_name,
        SUM(sales)  AS total_sales,
        SUM(profit) AS total_profit,
        SUM(quantity) AS total_quantity
    FROM sales_orders
    GROUP BY category, sub_category, product_name
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS sales_rank_in_category
    FROM product_totals
)
SELECT
    category,
    sub_category,
    product_name,
    total_sales,
    total_profit,
    total_quantity,
    sales_rank_in_category
FROM ranked
WHERE sales_rank_in_category <= 10
ORDER BY category, sales_rank_in_category;

-- ----------------------------------------------------------------------------
-- customer_segment_performance
-- Sales, profit, and order count by customer segment.
-- Powers: the "customer segment breakdown" visual in Power BI.
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS customer_segment_performance;
CREATE VIEW customer_segment_performance AS
SELECT
    segment,
    SUM(sales)                        AS total_sales,
    SUM(profit)                       AS total_profit,
    COUNT(DISTINCT order_id)          AS order_count,
    COUNT(DISTINCT customer_id)       AS customer_count,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2) AS profit_margin_pct,
    ROUND(SUM(sales) * 1.0 / COUNT(DISTINCT order_id), 2) AS avg_sales_per_order
FROM sales_orders
GROUP BY segment
ORDER BY total_sales DESC;

-- ----------------------------------------------------------------------------
-- monthly_sales_trend
-- Sales/profit by calendar month (year + month), for time series charts.
-- Powers: the "monthly sales trend" line chart in Power BI.
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS monthly_sales_trend;
CREATE VIEW monthly_sales_trend AS
SELECT
    order_year,
    order_month,
    -- ISO-sortable label for use as an X-axis field in Power BI
    printf('%04d-%02d', order_year, order_month) AS year_month,
    SUM(sales)   AS total_sales,
    SUM(profit)  AS total_profit,
    COUNT(DISTINCT order_id) AS order_count
FROM sales_orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- ----------------------------------------------------------------------------
-- discount_impact_analysis
-- Profit margin vs. discount level, bucketed.
-- Powers: the "discount vs profit margin" visual in Power BI.
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS discount_impact_analysis;
CREATE VIEW discount_impact_analysis AS
SELECT
    CASE
        WHEN discount = 0            THEN '0% (no discount)'
        WHEN discount <= 0.20        THEN '1-20%'
        WHEN discount <= 0.40        THEN '21-40%'
        WHEN discount <= 0.60        THEN '41-60%'
        ELSE '61-80%'
    END AS discount_bucket,
    COUNT(*)                         AS line_item_count,
    SUM(sales)                       AS total_sales,
    SUM(profit)                      AS total_profit,
    ROUND(AVG(profit_margin) * 100, 2) AS avg_profit_margin_pct,
    SUM(is_loss)                     AS loss_making_count
FROM sales_orders
GROUP BY discount_bucket
ORDER BY MIN(discount);
