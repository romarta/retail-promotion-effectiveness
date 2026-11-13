# Retail Promotion Effectiveness & Incrementality

## Project Overview

An end-to-end retail analytics project evaluating promotional campaigns, customer purchasing behavior, and incremental sales using the dunnhumby *The Complete Journey* dataset.

## Business Objective

Assess whether promotional campaigns generate additional sales or primarily shift existing purchasing behavior.

## Analytical Scope

- Retail sales and customer purchasing behavior
- Promotional campaign and coupon effectiveness
- Incremental sales estimation and causal inference
- Product cannibalization and purchase timing
- Business recommendations for promotional decisions

## Tools & Technologies

- **PostgreSQL:** Data preparation, validation, and analytical queries
- **Python:** Exploratory data analysis and statistical modeling
- **Power BI:** Business performance reporting and visualization

## Data Source

[dunnhumby — The Complete Journey](https://www.dunnhumby.com/source-files/)

## Data Understanding

The initial data assessment covers all eight source tables, including 2.6 million transaction lines and 36.8 million product-store-week promotion records.

Key findings:
- Overlapping campaign periods and multiple campaign assignments per household.
- Limited demographic coverage and potential selection bias.
- Zero-value transactions, special product records, and department-specific quantity scales.
- Repeated promotion records with different display codes for the same product, store, and week.
- Promotional exposure coverage limitations and assumptions required to identify non-exposed products.

Detailed exploration: [`01_data_understanding.ipynb`](notebooks/01_data_understanding.ipynb)

Data quality findings and analytical implications: [`docs/data_understanding.md`](docs/data_understanding.md)

## Project Status

**Completed:** Project setup and source data understanding.

**Next:** PostgreSQL database setup, data import, and data quality validation.