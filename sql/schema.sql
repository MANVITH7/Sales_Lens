-- ============================================================================
-- Schema documentation for the `sales_orders` table
-- ============================================================================
-- This table is created and populated by scripts/clean_data.py (pandas
-- to_sql), not by running this file. This script exists to document the
-- schema for anyone reading the project, and can be run against
-- retail_analytics.db to confirm the live schema matches what's documented
-- here (SQLite will error on CREATE TABLE if the table already exists,
-- which is expected — this file is documentation, not a migration).
-- ============================================================================

CREATE TABLE sales_orders (
    row_id             INTEGER,   -- Original row identifier from the source export (1 per line item, not per order)
    order_id           TEXT,      -- Order identifier; one order can span multiple rows (one row per line item/product)
    order_date         TIMESTAMP, -- Date the customer placed the order
    ship_date          TIMESTAMP, -- Date the order was shipped
    ship_mode          TEXT,      -- Shipping method: Standard Class, Second Class, First Class, Same Day
    customer_id        TEXT,      -- Unique customer identifier
    customer_name      TEXT,      -- Customer full name
    segment            TEXT,      -- Customer segment: Consumer, Corporate, Home Office
    country            TEXT,      -- Always "United States" in this dataset
    city               TEXT,      -- Shipping city
    state              TEXT,      -- Shipping state
    postal_code        INTEGER,   -- Shipping postal code (descriptive only; not used in KPI calculations)
    region             TEXT,      -- Sales region: East, West, Central, South
    product_id         TEXT,      -- Unique product identifier
    category           TEXT,      -- Top-level product category: Furniture, Office Supplies, Technology
    sub_category       TEXT,      -- Product sub-category, e.g. Chairs, Binders, Phones
    product_name       TEXT,      -- Full product name/description
    sales               REAL,     -- Revenue for this line item, in USD
    quantity            INTEGER,  -- Units sold in this line item
    discount             REAL,    -- Discount applied, as a decimal fraction (0.20 = 20% off)
    profit               REAL,    -- Profit for this line item, in USD (can be negative)

    -- Columns added during cleaning (scripts/clean_data.py), not present
    -- in the raw source file:
    is_loss              INTEGER, -- 1 if profit < 0, else 0. Flags loss-making line items.
    is_high_discount     INTEGER, -- 1 if discount >= 0.50, else 0. Flags heavily discounted line items.
    order_year           INTEGER, -- Calendar year extracted from order_date
    order_month          INTEGER, -- Calendar month (1-12) extracted from order_date
    profit_margin         REAL    -- profit / sales. Negative values indicate a loss-making line item.
);

-- Grain: one row = one product line item within one order.
-- To get order-level totals, GROUP BY order_id and SUM(sales)/SUM(profit).
