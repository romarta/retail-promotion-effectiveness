# PostgreSQL Data Import

The dunnhumby *The Complete Journey* CSVs were imported into `retail_promotion_db` using **pgAdmin 4 → Import/Export Data**. The original records remain in the `raw` schema.

## Import Procedure

1. Run `sql/01_create_schemas.sql` and `sql/02_create_tables.sql`.
2. Import all eight CSVs in this order: `campaign_desc`, `campaign_table`, `coupon`, `coupon_redempt`, `product`, `hh_demographic`, `transaction_data`, `causal_data`.
3. Use CSV format, UTF-8 encoding, header enabled, comma delimiter, `"` quote/escape, `\N` as NULL string, and *Stop* on error. Verify column order.
4. Run `sql/03_validate_import.sql` and `sql/04_add_constraints.sql`.
5. Run `sql/05_create_analytics_tables.sql` through `sql/10_promotion_diagnostics.sql` in numeric order.

Source CSVs are kept locally in `data/raw/` and excluded from Git. The `analytics` schema contains sales, campaign, and coupon tables; `v_promotion_exposure` reads `raw.causal_data` without copying it. Only weekly sales are materialized in `mv_sales_product_store_week`.
