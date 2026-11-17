-- Populate the household dimension with all transaction households
INSERT INTO analytics.dim_household (
    household_key,
    classification_1,
    classification_2,
    classification_3,
    homeowner_desc,
    classification_5,
    classification_4,
    kid_category_desc
)
SELECT
    t.household_key,
    h.classification_1,
    h.classification_2,
    h.classification_3,
    h.homeowner_desc,
    h.classification_5,
    h.classification_4,
    h.kid_category_desc
FROM (
    SELECT DISTINCT household_key
    FROM raw.transaction_data
) AS t
LEFT JOIN raw.hh_demographic AS h
    ON t.household_key = h.household_key;



-- Populate the product dimension from source data
INSERT INTO analytics.dim_product (
    product_id,
    manufacturer,
    department,
    brand,
    commodity_desc,
    sub_commodity_desc,
    curr_size_of_product
)
SELECT
    product_id,
    manufacturer,
    department,
    brand,
    commodity_desc,
    sub_commodity_desc,
    curr_size_of_product
FROM raw.product;


-- Populate the store dimension with distinct store identifiers
INSERT INTO analytics.dim_store (store_id)
SELECT DISTINCT store_id
FROM raw.transaction_data;

-- Flag stores with available promotion records
UPDATE analytics.dim_store AS s
SET has_promotion_records = TRUE
FROM (
    SELECT DISTINCT store_id
    FROM raw.causal_data
) AS c
WHERE s.store_id = c.store_id;



-- Populate the day dimension using observed week assignments
INSERT INTO analytics.dim_day (
    day,
    week_no
)
SELECT
    d.day,
    t.week_no
FROM generate_series(
    1,
    (
        SELECT GREATEST(
            (SELECT MAX(day) FROM raw.transaction_data),
            (SELECT MAX(end_day) FROM raw.campaign_desc)
        )
    )
) AS d(day)
LEFT JOIN (
    SELECT DISTINCT day, week_no
    FROM raw.transaction_data
) AS t
    ON d.day = t.day;



-- Populate the sales fact table from source transactions
INSERT INTO analytics.fact_sales (
    basket_id,
    product_id,
    household_key,
    store_id,
    day,
    quantity,
    sales_value,
    retail_disc,
    coupon_disc,
    coupon_match_disc,
    trans_time
)
SELECT
    basket_id,
    product_id,
    household_key,
    store_id,
    day,
    quantity,
    sales_value,
    retail_disc,
    coupon_disc,
    coupon_match_disc,
    trans_time
FROM raw.transaction_data;



-- Populate the campaign dimension
INSERT INTO analytics.dim_campaign (
    campaign,
    description,
    start_day,
    end_day
)
SELECT
    campaign,
    description,
    start_day,
    end_day
FROM raw.campaign_desc;



-- Populate household-to-campaign assignments
INSERT INTO analytics.fact_campaign_assignment (
    household_key,
    campaign
)
SELECT
    household_key,
    campaign
FROM raw.campaign_table;



-- Populate coupon redemption events
INSERT INTO analytics.fact_coupon_redemption (
    household_key,
    day,
    coupon_upc,
    campaign
)
SELECT
    household_key,
    day,
    coupon_upc,
    campaign
FROM raw.coupon_redempt;



-- Populate unique campaign-coupon combinations
INSERT INTO analytics.dim_coupon (
    campaign,
    coupon_upc
)
SELECT DISTINCT
    campaign,
    coupon_upc
FROM raw.coupon;


-- Populate unique coupon-to-product mappings
INSERT INTO analytics.bridge_coupon_product (
    campaign,
    coupon_upc,
    product_id
)
SELECT DISTINCT
    campaign,
    coupon_upc,
    product_id
FROM raw.coupon;


-- Populate weeks from observed day-to-week assignments
INSERT INTO analytics.dim_week (
    week_no,
    first_observed_day,
    last_observed_day,
    observed_days
)
SELECT
    week_no,
    MIN(day),
    MAX(day),
    COUNT(*)
FROM analytics.dim_day
WHERE week_no IS NOT NULL
GROUP BY week_no;
