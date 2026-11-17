# Data Understanding — Key Findings

The source dataset contains **2,500 households**, **2,595,732 transaction lines**, and **36,786,524 promotion exposure rows** across eight CSV files.

## Data Quality & Coverage

- **Campaigns:** 884 of 1,584 participating households have overlapping campaign assignments. Household-level coupon allocation for TypeA campaigns is unavailable.
- **Demographics:** Available for 801 households; missingness may introduce selection bias.
- **Sales:** 942 baskets have zero recorded sales. Some departments contain atypically large quantities; KPI definitions must address these cases.
- **Promotion grain:** `causal_data` has 36,771,279 distinct product–store–week combinations (15,245 additional rows). Multiple codes can occur for one combination; exact within-week timing is unknown.
- **Exposure coverage:** 21.72% of sampled transaction lines match a recorded product–store–week promotion; 74.07% have no matching product promotion within a covered store-week; 4.21% are outside observed store-week promotion coverage.

## Analytical Implications

Campaign assignment, coupon redemption, and display/mailer records describe different, potentially overlapping mechanisms. Deduplicate coupon–product mappings and aggregate repeated promotion records **before** joining them to sales to avoid inflated totals.

The data track purchases by sampled households, **not total store sales**. No recorded product promotion is not proof of no actual exposure. These limitations constrain comparison-group construction and causal incrementality estimates.

Source exploration: [`../notebooks/01_data_understanding.ipynb`](../notebooks/01_data_understanding.ipynb).
