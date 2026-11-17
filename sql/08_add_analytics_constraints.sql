-- Link coupon redemptions to the coupon dimension
ALTER TABLE analytics.fact_coupon_redemption
ADD CONSTRAINT fk_redemption_coupon
FOREIGN KEY (campaign, coupon_upc)
REFERENCES analytics.dim_coupon(campaign, coupon_upc);



-- Link observed transaction days to the week dimension
ALTER TABLE analytics.dim_day
ADD CONSTRAINT fk_day_week
FOREIGN KEY (week_no)
REFERENCES analytics.dim_week(week_no);