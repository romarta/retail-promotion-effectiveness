# Data Understanding — Key Findings

## Dataset Overview

The assessment covers all eight tables from dunnhumby's *The Complete Journey* dataset, including 2,500 households, 2.6 million transaction lines, and 36.8 million product-store-week promotion records.

## Key Findings

- **Campaign overlap:** 884 of 1,584 campaign participants were assigned to campaigns with overlapping validity periods. Individual coupon allocation for TypeA campaigns is not available.
- **Demographic selection:** Demographics cover only 801 households. Campaign participants with demographic data were assigned more campaigns on average (5.54 vs. 3.63), raising potential selection concerns.
- **Transaction quality:** 942 baskets have zero sales, including 592 without positive quantities. Extreme quantities are concentrated in gas and miscellaneous transactions. Special product records require separate treatment.
- **Promotion granularity:** `causal_data` contains 15,245 repeated product-store-week keys with different exposure codes. Weekly records cannot establish the exact day of exposure.
- **Exposure coverage:** 21.72% of transaction lines have matching promotion records; 74.07% have no product-level match within a covered store-week; 4.21% fall outside observed store-week coverage.

## Analytical Implications

Campaign assignment, coupon redemption, and product exposure represent distinct promotional mechanisms and may overlap.

Before modeling, repeated promotion records and redundant coupon mappings must be handled without multiplying sales. Zero-value records require explicit KPI definitions rather than blanket removal.

Missing product-level promotion records within covered store-weeks may indicate no recorded exposure. This remains a modeling assumption; observations outside covered store-weeks should retain an unknown exposure status.

These limitations must be considered when designing comparison groups and estimating incremental promotional effects.