-- Create the household dimension
CREATE TABLE IF NOT EXISTS analytics.dim_household (
    household_key INTEGER PRIMARY KEY,
    classification_1 TEXT,
    classification_2 TEXT,
    classification_3 TEXT,
    homeowner_desc TEXT,
    classification_5 TEXT,
    classification_4 TEXT,
    kid_category_desc TEXT
);


-- Create the product dimension
CREATE TABLE IF NOT EXISTS analytics.dim_product (
    product_id INTEGER PRIMARY KEY,
    manufacturer INTEGER NOT NULL,
    department TEXT NOT NULL,
    brand TEXT NOT NULL,
    commodity_desc TEXT NOT NULL,
    sub_commodity_desc TEXT NOT NULL,
    curr_size_of_product TEXT NOT NULL
);


-- Create the store dimension with promotion coverage information
CREATE TABLE IF NOT EXISTS analytics.dim_store (
    store_id INTEGER PRIMARY KEY,
    has_promotion_records BOOLEAN NOT NULL DEFAULT FALSE
);



-- Create the day dimension
CREATE TABLE IF NOT EXISTS analytics.dim_day (
    day INTEGER PRIMARY KEY,
    week_no INTEGER
);



-- Create the sales fact table at basket-product level
CREATE TABLE IF NOT EXISTS analytics.fact_sales (
    basket_id BIGINT NOT NULL,
    product_id INTEGER NOT NULL,
    household_key INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    day INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    sales_value NUMERIC NOT NULL,
    retail_disc NUMERIC NOT NULL,
    coupon_disc NUMERIC NOT NULL,
    coupon_match_disc NUMERIC NOT NULL,
    trans_time INTEGER NOT NULL,
    PRIMARY KEY (basket_id, product_id),
    FOREIGN KEY (product_id) REFERENCES analytics.dim_product(product_id),
    FOREIGN KEY (household_key) REFERENCES analytics.dim_household(household_key),
    FOREIGN KEY (store_id) REFERENCES analytics.dim_store(store_id),
    FOREIGN KEY (day) REFERENCES analytics.dim_day(day)
);


-- Create the campaign dimension
CREATE TABLE IF NOT EXISTS analytics.dim_campaign (
    campaign INTEGER PRIMARY KEY,
    description TEXT NOT NULL,
    start_day INTEGER NOT NULL,
    end_day INTEGER NOT NULL
);



-- Create the campaign assignment fact table
CREATE TABLE IF NOT EXISTS analytics.fact_campaign_assignment (
    household_key INTEGER NOT NULL,
    campaign INTEGER NOT NULL,
    PRIMARY KEY (household_key, campaign),
    FOREIGN KEY (household_key) REFERENCES analytics.dim_household(household_key),
    FOREIGN KEY (campaign) REFERENCES analytics.dim_campaign(campaign)
);


-- Create the coupon redemption fact table
CREATE TABLE IF NOT EXISTS analytics.fact_coupon_redemption (
    household_key INTEGER NOT NULL,
    day INTEGER NOT NULL,
    coupon_upc BIGINT NOT NULL,
    campaign INTEGER NOT NULL,
    PRIMARY KEY (household_key, day, coupon_upc, campaign),
    FOREIGN KEY (household_key) REFERENCES analytics.dim_household(household_key),
    FOREIGN KEY (day) REFERENCES analytics.dim_day(day),
    FOREIGN KEY (campaign) REFERENCES analytics.dim_campaign(campaign)
);



-- Create the coupon dimension
CREATE TABLE IF NOT EXISTS analytics.dim_coupon (
    campaign INTEGER NOT NULL,
    coupon_upc BIGINT NOT NULL,
    PRIMARY KEY (campaign, coupon_upc),
    FOREIGN KEY (campaign) REFERENCES analytics.dim_campaign(campaign)
);

-- Create the coupon-to-product bridge table
CREATE TABLE IF NOT EXISTS analytics.bridge_coupon_product (
    campaign INTEGER NOT NULL,
    coupon_upc BIGINT NOT NULL,
    product_id INTEGER NOT NULL,
    PRIMARY KEY (campaign, coupon_upc, product_id),
    FOREIGN KEY (campaign, coupon_upc) REFERENCES analytics.dim_coupon(campaign, coupon_upc),
    FOREIGN KEY (product_id) REFERENCES analytics.dim_product(product_id)
);


-- Create a week dimension using observed transaction periods
CREATE TABLE IF NOT EXISTS analytics.dim_week (
    week_no INTEGER PRIMARY KEY,
    first_observed_day INTEGER NOT NULL,
    last_observed_day INTEGER NOT NULL,
    observed_days INTEGER NOT NULL
);

-- Expose promotion data without duplicating source records
CREATE OR REPLACE VIEW analytics.v_promotion_exposure AS
SELECT
    product_id,
    store_id,
    week_no,
    display,
    mailer
FROM raw.causal_data;