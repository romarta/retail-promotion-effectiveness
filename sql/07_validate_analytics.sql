-- Validate household dimension coverage
SELECT
    COUNT(*) AS total_households,
    COUNT(classification_1) AS households_with_demographics,
    COUNT(*) - COUNT(classification_1) AS households_without_demographics
FROM analytics.dim_household;


-- Validate product dimension completeness
SELECT
    (SELECT COUNT(*) FROM raw.product) AS source_products,
    (SELECT COUNT(*) FROM analytics.dim_product) AS dimension_products;


-- Check for products missing from the analytical dimension
SELECT COUNT(*) AS missing_products
FROM raw.product AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM analytics.dim_product AS d
    WHERE d.product_id = p.product_id
);


-- Validate store dimension and promotion data coverage
SELECT
    COUNT(*) AS total_stores,
    COUNT(*) FILTER (
        WHERE has_promotion_records
    ) AS stores_with_promotion_records,
    COUNT(*) FILTER (
        WHERE NOT has_promotion_records
    ) AS stores_without_promotion_records
FROM analytics.dim_store;



-- Validate day dimension coverage
SELECT
    COUNT(*) AS total_days,
    MIN(day) AS first_day,
    MAX(day) AS last_day,
    COUNT(week_no) AS days_with_known_week,
    COUNT(*) FILTER (WHERE week_no IS NULL) AS days_without_known_week,
    MAX(week_no) AS last_observed_week
FROM analytics.dim_day;


-- Check day-to-week assignments against source transactions
SELECT
    COUNT(*) AS mismatched_day_weeks
FROM (
    SELECT DISTINCT day, week_no
    FROM raw.transaction_data
) AS t
LEFT JOIN analytics.dim_day AS d
    ON t.day = d.day
WHERE d.day IS NULL
   OR d.week_no IS DISTINCT FROM t.week_no;


-- Check whether all campaign boundaries exist in the day dimension
SELECT
    COUNT(*) AS missing_campaign_boundaries
FROM raw.campaign_desc AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM analytics.dim_day AS d
    WHERE d.day = c.start_day
)
OR NOT EXISTS (
    SELECT 1
    FROM analytics.dim_day AS d
    WHERE d.day = c.end_day
);



-- Validate sales fact table completeness
SELECT
    (SELECT COUNT(*) FROM raw.transaction_data) AS source_records,
    (SELECT COUNT(*) FROM analytics.fact_sales) AS fact_records;


-- Compare sales and discount totals between source and fact tables
SELECT
    'raw' AS data_source,
    SUM(sales_value) AS total_sales,
    SUM(retail_disc) AS total_retail_disc,
    SUM(coupon_disc) AS total_coupon_disc,
    SUM(coupon_match_disc) AS total_coupon_match_disc
FROM raw.transaction_data

UNION ALL

SELECT
    'analytics',
    SUM(sales_value),
    SUM(retail_disc),
    SUM(coupon_disc),
    SUM(coupon_match_disc)
FROM analytics.fact_sales;


-- Validate the number of distinct baskets
SELECT
    COUNT(DISTINCT basket_id) AS unique_baskets
FROM analytics.fact_sales;



-- Validate the campaign dimension
SELECT
    COUNT(*) AS total_campaigns,
    COUNT(*) FILTER (
        WHERE description = 'TypeA'
    ) AS type_a,
    COUNT(*) FILTER (
        WHERE description = 'TypeB'
    ) AS type_b,
    COUNT(*) FILTER (
        WHERE description = 'TypeC'
    ) AS type_c
FROM analytics.dim_campaign;



-- Validate household campaign assignments
SELECT
    COUNT(*) AS total_assignments,
    COUNT(DISTINCT household_key) AS assigned_households,
    COUNT(DISTINCT campaign) AS campaigns_with_assignments
FROM analytics.fact_campaign_assignment;



-- Validate coupon redemption fact completeness
SELECT
    (SELECT COUNT(*) FROM raw.coupon_redempt) AS source_redemptions,
    (SELECT COUNT(*) FROM analytics.fact_coupon_redemption) AS fact_redemptions;



-- Check for coupon redemption events missing from the fact table
SELECT COUNT(*) AS missing_redemptions
FROM raw.coupon_redempt AS r
WHERE NOT EXISTS (
    SELECT 1
    FROM analytics.fact_coupon_redemption AS f
    WHERE f.household_key = r.household_key
      AND f.day = r.day
      AND f.coupon_upc = r.coupon_upc
      AND f.campaign = r.campaign
);


-- Validate repeated redemptions across different days
SELECT
    COUNT(*) - COUNT(
        DISTINCT (household_key, campaign, coupon_upc)
    ) AS repeated_redemptions
FROM analytics.fact_coupon_redemption;


-- Validate campaign-coupon dimension completeness
SELECT
    (SELECT COUNT(DISTINCT (campaign, coupon_upc))
     FROM raw.coupon) AS source_coupons,
    (SELECT COUNT(*)
     FROM analytics.dim_coupon) AS dimension_coupons;



-- Validate coupon-to-product bridge completeness
SELECT
    COUNT(*) AS total_mappings,
    COUNT(DISTINCT (campaign, coupon_upc, product_id)) AS unique_mappings
FROM analytics.bridge_coupon_product;



-- Check for source mappings missing from the analytical bridge
SELECT COUNT(*) AS missing_mappings
FROM (
    SELECT DISTINCT campaign, coupon_upc, product_id
    FROM raw.coupon
) AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM analytics.bridge_coupon_product AS b
    WHERE b.campaign = c.campaign
      AND b.coupon_upc = c.coupon_upc
      AND b.product_id = c.product_id
);


-- Validate observed week coverage
SELECT
    COUNT(*) AS total_weeks,
    MIN(week_no) AS first_week,
    MAX(week_no) AS last_week,
    SUM(observed_days) AS total_observed_days,
    COUNT(*) FILTER (WHERE observed_days < 7) AS partial_weeks
FROM analytics.dim_week;
