-- ============================================================================
-- Standalone business-question queries against sales_orders / the views in
-- sql/views.sql. Run individually, e.g.:
--   sqlite3 retail_analytics.db < sql/analysis_queries.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q1: Which region had the highest year-over-year sales growth in the most
--     recent year of data?
-- ----------------------------------------------------------------------------
SELECT
    region,
    order_year,
    total_sales,
    prior_year_sales,
    yoy_sales_growth_pct
FROM yearly_regional_sales
WHERE order_year = (SELECT MAX(order_year) FROM sales_orders)
ORDER BY yoy_sales_growth_pct DESC;


-- ----------------------------------------------------------------------------
-- Q2: Which product sub-categories are unprofitable despite high sales
--     volume? (High sales, but negative or thin total profit — a classic
--     "we're selling a lot but losing money on it" red flag.)
-- ----------------------------------------------------------------------------
SELECT
    category,
    sub_category,
    SUM(sales)  AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2) AS profit_margin_pct,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM sales_orders
GROUP BY category, sub_category
HAVING total_profit < 0
ORDER BY total_sales DESC;


-- ----------------------------------------------------------------------------
-- Q3: What's the relationship between discount level and profit margin?
-- ----------------------------------------------------------------------------
SELECT
    discount_bucket,
    line_item_count,
    total_sales,
    total_profit,
    avg_profit_margin_pct,
    loss_making_count,
    ROUND(loss_making_count * 100.0 / line_item_count, 2) AS pct_loss_making
FROM discount_impact_analysis
ORDER BY total_sales DESC;


-- ----------------------------------------------------------------------------
-- Q4: Which customer segment is the most profitable per order, not just in
--     total? (Ranks segments by profit-per-order rather than raw totals, to
--     surface efficiency rather than just size.)
-- ----------------------------------------------------------------------------
SELECT
    segment,
    total_sales,
    total_profit,
    order_count,
    ROUND(total_profit * 1.0 / order_count, 2) AS profit_per_order,
    RANK() OVER (ORDER BY total_profit * 1.0 / order_count DESC) AS profit_efficiency_rank
FROM customer_segment_performance;


-- ----------------------------------------------------------------------------
-- Q5: For each category, what's the running total of sales month over month?
--     (Useful for a cumulative-sales-by-category chart.)
-- ----------------------------------------------------------------------------
WITH monthly_category_sales AS (
    SELECT
        category,
        order_year,
        order_month,
        printf('%04d-%02d', order_year, order_month) AS year_month,
        SUM(sales) AS monthly_sales
    FROM sales_orders
    GROUP BY category, order_year, order_month
)
SELECT
    category,
    year_month,
    monthly_sales,
    SUM(monthly_sales) OVER (
        PARTITION BY category
        ORDER BY year_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales
FROM monthly_category_sales
ORDER BY category, year_month;


-- ----------------------------------------------------------------------------
-- Q6: Which top-10-by-sales product in each category has the weakest profit
--     margin? (Flags "hero products" by revenue that are quietly eroding
--     margin — worth a pricing/discount review.)
-- ----------------------------------------------------------------------------
SELECT
    category,
    product_name,
    total_sales,
    total_profit,
    ROUND(total_profit * 100.0 / total_sales, 2) AS profit_margin_pct,
    sales_rank_in_category
FROM top_products_by_category
WHERE total_profit * 1.0 / total_sales < 0.10
ORDER BY category, sales_rank_in_category;
