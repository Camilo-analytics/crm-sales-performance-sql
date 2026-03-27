# CRM Sales Performance Analysis

<img width="2552" height="1409" alt="Screenshot 2026-03-27 at 8 35 30 pm" src="https://github.com/user-attachments/assets/acccb2d2-6e23-4115-b878-994ba85bed8e" />


## Maven Analytics — CRM Sales Opportunities

---

## Business Problem

A B2B hardware company needed to evaluate the effectiveness of its sales pipeline.

While revenue performance appeared strong, management lacked visibility into whether
this growth was being achieved efficiently or at the expense of pricing discipline,
deal quality, and long-term profitability.

---

## Business Question

**Are we generating revenue efficiently, or are we sacrificing margin and deal quality to drive sales performance?**

---

## Analytical Framework

The analysis was structured around four key pillars:

1. **Revenue Performance**  
   How much revenue is being generated and where it is coming from.

2. **Sales Efficiency**  
   How effectively agents convert opportunities into revenue.

3. **Revenue Quality (Pricing & Margin Proxy)**  
   Whether revenue is being generated at sustainable price levels.

4. **Pipeline Health**  
   How opportunities move through the funnel and where value is lost.

---
## Live Dashboard

🔗 [View Interactive Dashboard on Tableau Public](https://public.tableau.com/app/profile/camilo.barrera3824/viz/CRMsales/Dashboard3?publish=yes)
---
---
## Dataset

| Attribute | Detail |
|---|---|
| Source | Maven Analytics — CRM Sales Opportunities |
| Tables | 4 (sales_pipeline, accounts, sales_teams, products) |
| Total records | 8,800 pipeline opportunities |
| Tool | DBeaver + SQLite |

**Key cleaning decisions:**
- GTXPro → 'GTX Pro' (1,480 records — JOIN integrity fix)
- account blanks → 'unknown' (1,425 early-stage deals)
- engage_date, close_date, close_value blanks → NULL (business logic)
- sector typo 'technolgy' → 'technology'

---

## Analysis Structure

| File | Block | Focus |
|---|---|---|
| `01_crm_data_audit.sql` | Audit | Data quality across 4 tables + referential integrity |
| `02_crm_cleaning.sql` | Cleaning | Standardisation and JOIN integrity fixes |
| `03_crm_eda_revenue.sql` | Block A | Revenue by region, product, agent + pricing analysis |
| `04_crm_eda_pipeline.sql` | Block B | Pipeline distribution, cycle time, lost revenue |
| `05_crm_eda_accounts.sql` | Block C | Account segmentation, sector performance, win rates |

---

## SQL Techniques Demonstrated

- Multi-table JOINs (2, 3 and 4 tables)
- CTEs and nested CTEs
- Window functions: DENSE_RANK, LAG, NTILE, SUM OVER PARTITION
- Conditional aggregation with CASE WHEN
- Date arithmetic with JULIANDAY
- Referential integrity validation with LEFT JOIN

---

## Key Insights

### 1. Revenue ≠ Performance Quality

- Darcel Schlecht ranks #1 in revenue ($1.15M) but shows **negative pricing variance**, consistently closing deals below official price.
- Daniell Hammack generates lower revenue but leads in pricing performance.

👉 **Insight:** Revenue alone is a misleading metric — pricing discipline varies significantly across agents.

---

### 2. Growth is Volume-Driven, Not Value-Driven

- Central region closes the most deals but generates less revenue than West.
- This indicates **lower average deal value**.

👉 **Insight:** Some regions rely on volume rather than high-value deals.

---

### 3. Pricing Strategy is Inconsistent

- Agents operating at similar price levels achieve very different revenue outcomes.
- High-performing agents are not always aligned with optimal pricing.

👉 **Insight:** Lack of standardized pricing strategy across the sales team.

---

### 4. Product Mix Opportunity

- GTK 500 has the highest revenue per deal ($26,768) but only 15 deals closed.
- GTX Pro dominates revenue due to volume, not necessarily value efficiency.

👉 **Insight:** Revenue concentration may be masking underutilized high-value products.

---

### 5. Pipeline Efficiency Signals

- Win rate is 48.2% — overall healthy.
- Lost deals close faster than won deals → negotiation time matters.

👉 **Insight:** Longer sales cycles correlate with successful deal closure.

---

## Business Conclusion

Revenue growth is being driven by a subset of agents operating at lower price points,
suggesting a trade-off between volume and pricing discipline.

The current sales strategy prioritizes closing deals over maintaining pricing consistency,
which may negatively impact long-term margin performance.

## Recommendations

1. **Standardize pricing strategy across agents**  
   Reduce variability in deal pricing to improve revenue quality.

2. **Re-evaluate high-volume, low-margin agents**  
   Focus on sustainable performance, not just revenue ranking.

3. **Promote high-value products (GTK 500)**  
   Increase sales focus on underutilized premium offerings.

4. **Prioritize enterprise accounts**  
   Larger clients generate significantly higher revenue per deal.

---

## Limitations

- Dataset is fictitious — findings are illustrative, not statistically conclusive.
- 'unknown' accounts (1,425) excluded from account-level analysis.
- close_value represents one-time deal value — not recurring revenue.
- Pricing analysis uses list price as baseline — cost data not available.

---

## Author
Camilo B. Martinez — Junior Data Analyst  
Adelaide, SA, Australia
