-- Create the campaign reference table
CREATE TABLE IF NOT EXISTS raw.campaign_desc (
    campaign INTEGER PRIMARY KEY,
    description TEXT NOT NULL,
    start_day INTEGER NOT NULL,
    end_day INTEGER NOT NULL
);


-- Create the household-to-campaign assignment table
CREATE TABLE IF NOT EXISTS raw.campaign_table (
    description TEXT NOT NULL,
    household_key INTEGER NOT NULL,
    campaign INTEGER NOT NULL,
    PRIMARY KEY (household_key, campaign),
    FOREIGN KEY (campaign) REFERENCES raw.campaign_desc(campaign)
);


-- Create the campaign coupon-product mapping table
CREATE TABLE IF NOT EXISTS raw.coupon (
    coupon_upc BIGINT NOT NULL,
    product_id INTEGER NOT NULL,
    campaign INTEGER NOT NULL,
    FOREIGN KEY (campaign) REFERENCES raw.campaign_desc(campaign)
);


-- Create the coupon redemption table
CREATE TABLE IF NOT EXISTS raw.coupon_redempt (
    household_key INTEGER NOT NULL,
    day INTEGER NOT NULL,
    coupon_upc BIGINT NOT NULL,
    campaign INTEGER NOT NULL,
    PRIMARY KEY (household_key, day, coupon_upc, campaign),
    FOREIGN KEY (household_key, campaign) REFERENCES raw.campaign_table(household_key, campaign)
);


-- Create the product reference table
CREATE TABLE IF NOT EXISTS raw.product (
    product_id INTEGER PRIMARY KEY,
    manufacturer INTEGER NOT NULL,
    department TEXT NOT NULL,
    brand TEXT NOT NULL,
    commodity_desc TEXT NOT NULL,
    sub_commodity_desc TEXT NOT NULL,
    curr_size_of_product TEXT NOT NULL
);


-- Create the household demographics reference table
CREATE TABLE IF NOT EXISTS raw.hh_demographic (
    classification_1 TEXT NOT NULL,
    classification_2 TEXT NOT NULL,
    classification_3 TEXT NOT NULL,
    homeowner_desc TEXT NOT NULL,
    classification_5 TEXT NOT NULL,
    classification_4 TEXT NOT NULL,
    kid_category_desc TEXT NOT NULL,
    household_key INTEGER PRIMARY KEY
);


-- Create the retail transaction table
CREATE TABLE IF NOT EXISTS raw.transaction_data (
    household_key INTEGER NOT NULL,
    basket_id BIGINT NOT NULL,
    day INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    sales_value NUMERIC NOT NULL,
    store_id INTEGER NOT NULL,
    retail_disc NUMERIC NOT NULL,
    trans_time INTEGER NOT NULL,
    week_no INTEGER NOT NULL,
    coupon_disc NUMERIC NOT NULL,
    coupon_match_disc NUMERIC NOT NULL,
    PRIMARY KEY (basket_id, product_id),
    FOREIGN KEY (product_id) REFERENCES raw.product(product_id)
);


-- Create the product-store-week promotion exposure table
CREATE TABLE IF NOT EXISTS raw.causal_data (
    product_id INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    week_no INTEGER NOT NULL,
    display TEXT NOT NULL,
    mailer TEXT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES raw.product(product_id)
);