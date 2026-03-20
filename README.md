# CRM Sales Performance Analysis
## Maven Analytics — CRM Sales Opportunities

---

## Business Problem

A B2B hardware company needed to understand how its sales pipeline
was performing across regions, products, and agents. Sales management
required clarity on where revenue was coming from, which agents were
truly delivering value, and where opportunities were being lost.

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
| `03_crm_eda_revenue.sql` | Block A | Revenue by region, product, agent + profit analysis |
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

## Key Findings

### Revenue & Products
- GTX Pro leads revenue ($3,510,578 / 729 deals) — agents who
  prioritize it disproportionately increase their total revenue.
- GTK 500 is the highest revenue-per-deal product ($26,768 list price)
  but only 15 deals closed — significant untapped opportunity.
- West region leads revenue ($3,568,647) with fewer deals than Central
  (1,438 vs 1,629) — Central closes lower-value deals on average.

### Agent Performance
- Darcel Schlecht ranks #1 in gross revenue ($1,153,214) but has
  **negative total profit** — consistently closing below official price.
- Daniell Hammack leads in profit despite ranking mid-tier in revenue —
  gross revenue is a misleading performance metric without margin analysis.
- Lajuana Vencill has the lowest win rate (54.98%) — priority coaching target.
- Hayden Neloms leads win rate (70.39%) but ranks mid-tier in revenue —
  win rate and revenue are not correlated.

### Pipeline Health
- 48.2% of all deals are Won — pipeline is healthy.
- Lost deals close faster (41.48 days) than Won deals (51.78 days) —
  longer negotiation correlates with winning.
- Darcel Schlecht leads in lost revenue opportunity ($734,313) —
  same agent with negative profit, suggesting a high-volume low-margin strategy.

### Account Segmentation
- Enterprise accounts (Segment 4) generate nearly double the revenue
  per account vs small companies ($158,066 vs $87,825).
- Win rates are consistent across all sectors (61–65%) — conversion
  is driven by agent behavior, not sector-specific factors.
- Retail leads sector revenue ($1,867,528) followed by Technology and Medical.

---

## Recommendations

1. **Review Darcel Schlecht's pricing discipline** — leads in gross
   revenue but has negative profit and highest lost revenue opportunity.
   High volume with below-price closes is hurting margins.

2. **Increase GTK 500 focus** — highest revenue per deal product with
   only 15 closes. Targeted GTK 500 campaigns could significantly
   lift total revenue.

3. **Coach Lajuana Vencill** — lowest win rate in the team (54.98%).
   Nearly 1 in 2 deals lost represents significant pipeline waste.

4. **Prioritize enterprise accounts** — Segment 4 companies generate
   double the revenue per account. Sales effort should weight toward
   larger clients.

---

## Limitations

- Dataset is fictitious — findings are illustrative, not statistically conclusive.
- 'unknown' accounts (1,425) excluded from account-level analysis.
- close_value represents one-time deal value — not recurring revenue.
- Profit analysis uses list price as baseline — actual cost of goods not available.

---

## Author
Camilo B. Martinez — Junior Data Analyst
Adelaide, SA, Australia
https://github.com/Camilo-analytics/crm-sales-performance-sql
