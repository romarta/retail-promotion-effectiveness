-- Aggregate sales at the product-store-week level
CREATE MATERIALIZED VIEW analytics.mv_sales_product_store_week AS
SELECT
    s.product_id,
    s.store_id,
    d.week_no,
    COUNT(*) AS sales_lines,
    SUM(s.sales_value) AS total_sales,
    SUM(s.quantity) AS total_quantity
FROM analytics.fact_sales AS s
JOIN analytics.dim_day AS d
    ON s.day = d.day
GROUP BY
    s.product_id,
    s.store_id,
    d.week_no;


-- Create a unique index for product-store-week combinations
CREATE UNIQUE INDEX idx_weekly_sales_product_store_week
ON analytics.mv_sales_product_store_week (
    product_id,
    store_id,
    week_no
);


-- Validate weekly sales aggregation
SELECT
    COUNT(*) AS product_store_weeks,
    SUM(sales_lines) AS total_sales_lines,
    ROUND(SUM(total_sales), 2) AS total_sales,
    SUM(total_quantity) AS total_quantity
FROM analytics.mv_sales_product_store_week;



-- Compare aggregated sales and quantities with the source fact table
SELECT
    (SELECT SUM(sales_value)
     FROM analytics.fact_sales) AS source_sales,
    (SELECT SUM(total_sales)
     FROM analytics.mv_sales_product_store_week) AS aggregated_sales,
    (SELECT SUM(quantity)
     FROM analytics.fact_sales) AS source_quantity,
    (SELECT SUM(total_quantity)
     FROM analytics.mv_sales_product_store_week) AS aggregated_quantity;
