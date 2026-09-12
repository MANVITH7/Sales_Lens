# Data Quality & Validation Report

**Dataset:** Superstore retail sales export
**Pipeline:** `scripts/clean_data.py`
**Source file:** `data/raw/superstore.csv` → `data/cleaned/superstore_cleaned.csv` → `sales_orders` table in `retail_analytics.db`

This report documents the checks run against the raw dataset during cleaning, what was found, and how each issue was handled. Full line-by-line output from the cleaning run is available in `validation/clean_data_log.txt`.

---

## 1. Row Counts

| Stage | Row Count |
|---|---|
| Raw file (`data/raw/superstore.csv`) | 9,994 |
| After deduplication | 9,994 |
| Final cleaned dataset | 9,994 |

No rows were dropped during cleaning. Every row in the source file made it into the final dataset — issues found (see below) were flagged with new columns rather than deleted, so no information is silently lost.

## 2. Duplicate Rows

- **Method:** full-row exact match check (`df.duplicated()`) after column standardization.
- **Duplicates found:** 0
- **Action taken:** none required.

## 3. Missing Values

| Column | Nulls Found | Handling |
|---|---|---|
| *(all 21 source columns)* | 0 | N/A — no missing values were present in any column of the source file |

The dataset arrived complete for this run. The pipeline still includes null-handling logic (see `handle_missing_values()` in `scripts/clean_data.py`) so it will surface and safely handle nulls if a future data pull is less clean — for example, a missing `postal_code` is filled with `0` rather than dropped, since postal code is descriptive only and not used in any KPI calculation, and any other column with nulls is flagged in the log for manual review rather than silently imputed.

## 4. Text Normalization

- **Issue found:** inconsistent whitespace in the `product_name` field (extra internal/leading/trailing spaces).
- **Rows affected:** 273
- **Action taken:** whitespace collapsed and trimmed. Key categorical fields (`ship_mode`, `segment`, `region`, `category`, `sub_category`, `country`) were also normalized to title case to prevent silent grouping errors in downstream SQL/Power BI (e.g. `"west"` vs `"West"` would otherwise be treated as two different regions).

## 5. Outliers & Data Quality Flags

Rather than removing statistical outliers, the pipeline flags them so they remain visible in analysis — a discounted or loss-making order is a real business event, not bad data.

| Flag | Definition | Rows Flagged | % of Dataset |
|---|---|---|---|
| `is_loss` | `profit < 0` | 1,871 | 18.7% |
| `is_high_discount` | `discount >= 0.50` | 922 | 9.2% |

**Notable examples surfaced by this check:**

- Three "Cubify CubeX 3D Printer" and binding-system orders account for the largest absolute losses in the dataset (from **-$6,599.98** to **-$3,701.89** profit on single orders) — high-value equipment sold at discounts of 50–80%.
- The single worst *profit margin* in the dataset is **-275%** (profit_margin = -2.75), occurring on several small-ticket items (vacuum bags, surge protectors) sold at an 80% discount — the business lost nearly 3x the sale price per unit after cost.
- No rows had `sales <= 0`, so there are no zero/negative revenue records to investigate.

**Recommendation for the business:** the 80%-discount tier (`discount = 0.80`, 300 orders) is worth a dedicated look in the dashboard's discount-vs-margin view — see `sql/views.sql` (`discount_impact_analysis`) in the next phase.

## 6. Summary Statistics

Computed on the final cleaned dataset (9,994 rows):

| Metric | Sales ($) | Profit ($) | Discount | Quantity | Profit Margin |
|---|---:|---:|---:|---:|---:|
| Min | 0.44 | -6,599.98 | 0.00 | 1 | -2.75 |
| Max | 22,638.48 | 8,399.98 | 0.80 | 14 | 0.50 |
| Mean | 229.86 | 28.66 | 0.16 | 3.79 | 0.12 |
| Median | 54.49 | 8.67 | 0.20 | 3.00 | 0.27 |

*Profit margin = profit / sales, added as a calculated column during cleaning.*

## 7. Conclusion

The source dataset was structurally clean (no duplicates, no missing values, consistent schema across all 9,994 rows). The main data-quality work was standardizing text formatting and surfacing loss-making / heavily-discounted orders as explicit flags so they can't be missed downstream, rather than treating them as errors to remove. The cleaned dataset and flags are ready for SQL analysis (Phase 4) and Power BI import (Phase 5).
