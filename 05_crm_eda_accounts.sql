-- ============================================================
-- 05_crm_eda_accounts.sql
-- Project: CRM Sales Performance Analysis
-- Dataset: Maven Analytics — CRM Sales Opportunities
-- ============================================================
-- BUSINESS BRIEF (Enzo, Sales Manager):
-- "I want to understand who our best clients are — which sectors
-- and company sizes drive the most revenue, and where we should
-- focus our sales efforts to maximize future growth."
--
-- ANALYST QUESTIONS:
-- Q1: Which sectors generate the most revenue from closed deals?
-- Q2: Does company size (employees/revenue) correlate with deal value?
-- Q3: Which individual accounts are our most valuable clients?
-- Q4: Which sectors have the highest win rate?
--
-- SQL TECHNIQUES USED IN THIS FILE:
-- - 4-table JOIN (sales_pipeline_clean + accounts_clean + sales_teams + products)
-- - NTILE() window function — segment accounts by size
-- - DENSE_RANK over account revenue
-- - Conditional aggregation with CASE WHEN
--
-- NOTE: 'unknown' accounts excluded from all analysis in this file.
-- accounts_clean.revenue = client company revenue (not sales revenue)
-- ============================================================
-- ============================================================
-- Q1: Revenue by sector from closed deals
-- ============================================================
-- FINDING: Retail leads with $1,867,528 in revenue, followed by
-- Technology ($1,515,487) and Medical ($1,359,595).
-- Employment and Services represent the smallest revenue segments.
-- Retail and Technology combined account for ~33% of total revenue.
-- ============================================================
select
ac.sector,
sum(sp.close_value)as total_revenue
from sales_pipeline_clean sp
join accounts_clean ac  on sp.account = ac.account 
where sp.deal_stage = 'Won'
group by ac.sector
order by total_revenue desc;
-- ============================================================
-- Q2: Does company size (employees) correlate with deal revenue?
-- Accounts segmented into 4 groups using NTILE(4) by employee count.
-- ============================================================
-- FINDING: Larger companies consistently generate more revenue per account.
-- Segment 4 (avg 12,398 employees) averages $158,066 per account vs
-- Segment 1 (avg 561 employees) at $87,825 — nearly double.
-- Total revenue scales with company size: $3,319,384 (Seg 4) vs $1,932,150 (Seg 1).
-- RECOMMENDATION: Prioritize enterprise accounts for higher revenue yield.
-- ============================================================
with account_segments as (
select 
ac.account,
ac.sector,
ac.employees,
ac.revenue as company_revenue,
NTILE(4) OVER (order by ac.employees)as size_segment,
sum(sp.close_value)as total_sales_revenue
from sales_pipeline_clean sp
join accounts_clean ac on sp.account = ac.account 
where sp.deal_stage = 'Won'
and sp.account != 'unknown'
group by ac.account, ac.sector, ac.employees, ac.revenue 
)

select
size_segment,
count(distinct account) as total_account,
round(avg(employees))as avg_employees,
round(avg(total_sales_revenue))as avg_revenue_per_account,
sum(total_sales_revenue)as total_revenue
from account_segments
group by size_segment
order by size_segment;
-- ============================================================
-- Q3: Top accounts by revenue generated — DENSE_RANK
-- ============================================================
-- FINDING: Revenue is concentrated in a small number of accounts.
-- Top accounts span multiple sectors — no single sector dominates
-- the leaderboard, suggesting the business has broad enterprise appeal.
-- DENSE_RANK used to formally rank accounts by total revenue.
-- ============================================================
WITH base AS (
    SELECT
        sp.account,
        ac.sector,
        ac.employees,
        SUM(sp.close_value) AS total_revenue,
        COUNT(*) AS total_deals
    FROM sales_pipeline_clean sp
    JOIN accounts_clean ac ON sp.account = ac.account
    WHERE sp.deal_stage = 'Won'
    AND sp.account != 'unknown'
    GROUP BY sp.account, ac.sector, ac.employees
)
SELECT
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS account_rank,
    account,
    sector,
    employees,
    total_revenue,
    total_deals
FROM base
ORDER BY account_rank
LIMIT 10;
-- ============================================================
-- Q4: Win rate by sector — which industries convert best?
-- ============================================================
-- FINDING: Win rates are consistent across all sectors (61-65%),
-- suggesting conversion is driven by agent behavior and product mix
-- rather than sector-specific factors.
-- Marketing leads with 64.8% win rate (404 won / 623 total deals).
-- Finance has the lowest win rate (61.2%) despite 613 total deals —
-- worth investigating whether pricing or competition is a factor.
-- DENSE_RANK used — technology and services share rank 4 (63.4%).
-- ============================================================
WITH base AS (
    SELECT
        ac.sector,
        SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won,
        SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost,
        COUNT(*) AS total_deals
    FROM sales_pipeline_clean sp
    JOIN accounts_clean ac ON sp.account = ac.account
    WHERE sp.account != 'unknown'
    AND sp.deal_stage IN ('Won', 'Lost')
    GROUP BY ac.sector
),
rates AS (
    SELECT
        sector,
        won,
        lost,
        total_deals,
        ROUND(won * 100.0 / (won + lost), 1) AS win_rate
    FROM base
)
SELECT
    DENSE_RANK() OVER (ORDER BY win_rate DESC) AS rank,
    sector,
    won,
    lost,
    total_deals,
    win_rate
FROM rates
ORDER BY rank;