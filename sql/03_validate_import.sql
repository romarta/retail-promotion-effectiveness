-- Validate row counts in all source tables
SELECT 'campaign_desc' AS table_name, COUNT(*) AS row_count
FROM raw.campaign_desc

UNION ALL

SELECT 'campaign_table', COUNT(*)
FROM raw.campaign_table

UNION ALL

SELECT 'coupon', COUNT(*)
FROM raw.coupon

UNION ALL

SELECT 'coupon_redempt', COUNT(*)
FROM raw.coupon_redempt

UNION ALL

SELECT 'product', COUNT(*)
FROM raw.product

UNION ALL

SELECT 'hh_demographic', COUNT(*)
FROM raw.hh_demographic

UNION ALL

SELECT 'transaction_data', COUNT(*)
FROM raw.transaction_data

UNION ALL

SELECT 'causal_data', COUNT(*)
FROM raw.causal_data;



-- Validate repeated campaign-coupon-product mappings
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT (campaign, coupon_upc, product_id)) AS unique_mappings,
    COUNT(*) - COUNT(DISTINCT (campaign, coupon_upc, product_id)) AS repeated_mappings
FROM raw.coupon;


-- Validate repeated product-store-week combinations
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT (product_id, store_id, week_no)) AS unique_combinations,
    COUNT(*) - COUNT(DISTINCT (product_id, store_id, week_no)) AS repeated_combinations
FROM raw.causal_data;



-- Validate transaction coverage and time ranges
SELECT
    COUNT(DISTINCT household_key) AS unique_households,
    COUNT(DISTINCT basket_id) AS unique_baskets,
    MIN(day) AS min_day,
    MAX(day) AS max_day,
    MIN(week_no) AS min_week,
    MAX(week_no) AS max_week
FROM raw.transaction_data;


-- Check for coupon products missing from the product catalog
SELECT
    COUNT(*) AS missing_product_references
FROM raw.coupon AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM raw.product AS p
    WHERE p.product_id = c.product_id
);


-- Check whether redeemed coupons belong to their campaigns
SELECT
    COUNT(*) AS unmatched_redemptions
FROM raw.coupon_redempt AS r
WHERE NOT EXISTS (
    SELECT 1
    FROM raw.coupon AS c
    WHERE c.campaign = r.campaign
      AND c.coupon_upc = r.coupon_upc
);



-- Check coupon redemptions outside campaign periods
SELECT
    COUNT(*) AS redemptions_outside_campaign
FROM raw.coupon_redempt AS r
JOIN raw.campaign_desc AS c
    ON r.campaign = c.campaign
WHERE r.day NOT BETWEEN c.start_day AND c.end_day;



-- Check consistency of campaign types across source tables
SELECT
    COUNT(*) AS mismatched_campaign_types
FROM raw.campaign_table AS ct
JOIN raw.campaign_desc AS cd
    ON ct.campaign = cd.campaign
WHERE ct.description IS DISTINCT FROM cd.description;


-- Check whether each day belongs to one week
SELECT COUNT(*) AS days_with_multiple_weeks
FROM (
    SELECT day
    FROM raw.transaction_data
    GROUP BY day
    HAVING COUNT(DISTINCT week_no) > 1
) AS t;


-- Check the relationship between day and week numbers
SELECT COUNT(*) AS mismatched_weeks
FROM (
    SELECT DISTINCT day, week_no
    FROM raw.transaction_data
) AS t
WHERE week_no <> (day - 1) / 7 + 1;


-- Examine actual week boundaries in transaction data
SELECT
    week_no,
    MIN(day) AS first_day,
    MAX(day) AS last_day,
    COUNT(*) AS observed_days
FROM (
    SELECT DISTINCT day, week_no
    FROM raw.transaction_data
) AS t
GROUP BY week_no
ORDER BY week_no;