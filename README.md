# Retail Promotion Effectiveness & Incrementality

## Objective

Evaluate retail campaign and coupon performance, product display and mailer exposure, and the feasibility of estimating incremental sales using dunnhumby's *The Complete Journey* dataset. Descriptive associations will be distinguished from causal effects.

## Data & Architecture

The dataset includes 2,500 households, 2.6 million transaction lines, and 36.8 million promotion exposure records.

- **`raw` (8 tables):** Original CSV data, retained without deduplication.
- **`analytics` (11 tables):** Sales, customer, product, campaign, and coupon model.
- **`analytics.v_promotion_exposure`:** Read-only view of `raw.causal_data` (`display` and `mailer`); no duplicated promotion dataset.
- **`analytics.mv_sales_product_store_week`:** Materialized weekly sales by product and store.

Promotion exposure is recorded at product–store–week level; campaigns and coupon redemptions operate at household/campaign level. These mechanisms require separate analytical definitions before joining.

## Tools

**PostgreSQL / pgAdmin 4** — import, modeling, validation, and aggregation  
**Python** — exploratory and statistical analysis  
**Power BI** — business reporting

## Reproducibility

1. Obtain the [dunnhumby dataset](https://www.dunnhumby.com/source-files/) and place the eight CSVs in `data/raw/` (excluded from Git).
2. Run `sql/01_create_schemas.sql` and `sql/02_create_tables.sql` in PostgreSQL.
3. Import CSVs through pgAdmin 4 following [`docs/data_import.md`](docs/data_import.md).
4. Run the remaining scripts in numeric order (`03`–`10`).

The SQL scripts build the model once; they are not intended to be rerun blindly against a populated database.

## Limitations

Transaction data cover a sampled household panel, not total store sales. Missing promotion records do not establish that a product was unexposed. Repeated exposure records must be resolved at the analysis grain to avoid multiplying sales.

See [`docs/data_understanding.md`](docs/data_understanding.md) and [`notebooks/01_data_understanding.ipynb`](notebooks/01_data_understanding.ipynb).

## Status

**Completed:** Source exploration, PostgreSQL import, validation, analytical model, and initial promotion coverage diagnostics.  
**Next:** Python analysis of campaigns, coupons, display/mailer exposure, and incrementality feasibility; then Power BI reporting.
