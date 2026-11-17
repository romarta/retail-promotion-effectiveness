-- Enforce valid product references in the coupon table
ALTER TABLE raw.coupon
ADD CONSTRAINT fk_coupon_product
FOREIGN KEY (product_id)
REFERENCES raw.product(product_id);