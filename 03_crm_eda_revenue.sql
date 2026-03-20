-- ============================================================
-- 03_crm_eda_revenue.sql
-- Project: CRM Sales Performance Analysis
-- Dataset: Maven Analytics — CRM Sales Opportunities
-- ============================================================
-- BUSINESS BRIEF (Enzo, Sales Manager):
-- "I need to understand where our revenue is coming from —
-- which regions and products drive the most closed deals,
-- and which agents are our top performers."
--
-- ANALYST QUESTIONS:
-- Q1: What is total revenue and deal volume by region?
-- Q2: What is total revenue and deal volume by product?
-- Q3: Which agents are closing the most deals and revenue?
-- Q3a:Which products does the top agent sell vs the second-ranked agent?
-- Q4: Where we are losing opportunities?
-- Q5: Are agents closing deals above or below the official product price?
--
-- NOTE: Revenue calculated on Won deals only.
-- ============================================================


-- ============================================================
-- Q1: Total revenue and deal volume by region
-- ============================================================
-- FINDING: Revenue is evenly distributed across all three regions.
-- West leads in revenue ($3,568,647) with fewer deals than Central (1,438 vs 1,629).
-- Central closed ~200 more deals than West but generated less revenue —
-- suggesting Central closes lower-value deals on average.
-- East trails slightly in both revenue and volume.
-- ============================================================

select st.regional_office as region,
       sum(sp.close_value) as total_revenue,
       count(*) as total_deals
  from sales_pipeline_clean sp
  join sales_teams st
on sp.sales_agent = st.sales_agent
 where sp.deal_stage = 'Won'
 group by st.regional_office
 order by total_revenue desc;
 -- ============================================================
-- Q2: Total revenue and deal volume by product
-- ============================================================
-- FINDING: GTX Pro leads revenue ($3,510,578 / 729 deals) followed by
-- GTX Plus Pro ($2,629,651 / 479 deals). Both GTX premium products
-- drive the majority of revenue with moderate deal volume.
-- MG Advanced ranks 3rd in revenue but required 654 deals to get there.
-- GTX Basic and MG Special show high deal volume but low revenue —
-- low unit price limits their revenue contribution.
-- GTK 500 is the standout opportunity: only 15 deals closed but
-- $400,612 revenue — highest revenue per deal in the dataset.
-- Increasing GTK 500 sales volume could significantly impact total revenue.
-- ============================================================
select sp.product,
       sum(sp.close_value) as total_revenue,
       count(*) as total_sales
  from sales_pipeline_clean sp
  join sales_teams st
on sp.sales_agent = st.sales_agent
 where sp.deal_stage = 'Won'
 group by sp.product
 order by total_revenue desc;
-- ============================================================
-- Q3: Top agents by revenue and deals closed — with ranking
-- ============================================================
-- FINDING: Darcel Schlecht ranks #1 with $1,153,214 revenue and 349 deals
-- — nearly double the #2 agent (Vicki Laflamme at $478,396).
-- DENSE_RANK used to formally rank agents by revenue —
-- agents with equal revenue receive the same rank without gaps.
-- Most agents cluster between ranks 3–15 suggesting consistent
-- mid-tier performance across the team.
-- ============================================================

with base as (
   select sp.sales_agent as agents,
          sum(sp.close_value) as total_revenue,
          count(*) as total_sales
     from sales_pipeline_clean sp
     join sales_teams st
   on sp.sales_agent = st.sales_agent
    where sp.deal_stage = 'Won'
    group by agents
    order by total_revenue desc
)
select dense_rank()
       over(
    order by total_revenue desc
       ) as revenue_rank,
       agents,
       total_revenue,
       total_sales
  from base
 order by revenue_rank;

-- ============================================================
-- Q3a: Product breakdown — Darcel Schlecht vs Vicki Laflamme
-- ============================================================
-- FINDING: Darcel's revenue advantage is driven primarily by GTX Pro.
-- Darcel closed 160 GTX Pro deals ($773,129) vs Vicki's 76 ($189,026).
-- GTX Pro is the highest-revenue product — agents who prioritize it
-- disproportionately increase their total revenue.
-- Recommendation: coach other agents to increase GTX Pro deal focus.
-- ============================================================

select sp.sales_agent as agents,
       st.regional_office as region,
       sp.product as products,
       sum(sp.close_value) as total_revenue,
       count(*) as total_sales
  from sales_pipeline_clean sp
  join sales_teams st
on sp.sales_agent = st.sales_agent
 where sp.deal_stage = 'Won'
   and ( sp.sales_agent = 'Darcel Schlecht'
    or sp.sales_agent = 'Vicki Laflamme' )
 group by agents,
          products
 order by products desc;
-- ============================================================
-- Q4: Agent win rate ranking — DENSE_RANK
-- ============================================================
-- FINDING: Hayden Neloms leads win rate (70.39%, rank #1) but ranks
-- mid-tier in revenue. Darcel Schlecht ranks #18 in win rate (63.11%)
-- but #1 in revenue — suggests a high-value deal focus strategy
-- over volume or conversion rate optimization.
-- Lajuana Vencill ranks last in win rate (54.98%) — nearly 1 in 2
-- deals lost. Priority coaching target.
-- ============================================================
with base as (
   select sp.sales_agent as agents,
          sum(sp.close_value) as total_revenue,
          sum(
             case
                when deal_stage = 'Won' then
                   1
                else
                   0
             end
          ) as sells,
          sum(
             case
                when deal_stage = 'Lost' then
                   1
                else
                   0
             end
          ) as lost_opp
     from sales_pipeline_clean sp
     join sales_teams st
   on sp.sales_agent = st.sales_agent
    group by agents
),pct_performance as (
   select agents,
          total_revenue,
          sells,
          lost_opp,
          sells - lost_opp as performance,
          round(
             sells * 100.0 /(sells + lost_opp),
             2
          ) as pct_sells,
          round(
             lost_opp * 100.0 /(sells + lost_opp),
             2
          ) as pct_lost
     from base
    order by pct_sells desc
)
select agents,
       total_revenue,
       sells,
       lost_opp,
       dense_rank()
       over(
           order by pct_sells desc
       ) as rank_sells,
       pct_sells,
       pct_lost
  from pct_performance;

-- ============================================================
-- Q5: Deal profit analysis — close_value vs official sales_price
-- (3-table JOIN: sales_pipeline_clean + products + sales_teams)
-- ============================================================
-- FINDING: Revenue ranking does not equal profit ranking.
-- Darcel Schlecht leads in revenue ($1,153,214) but has negative
-- total profit — consistently closing deals below official price.
-- Daniell Hammack leads in profit ($5,213) with far less revenue ($364,229).
-- RECOMMENDATION: Enzo should review Darcel's discounting behavior —
-- high volume at below-price deals may be hurting margins.
-- ============================================================
with base as (
   select sp.sales_agent,
          st.regional_office,
          sp.product,
          sp.close_value,
          p.sales_price,
          sp.close_value - p.sales_price as simple_profit,
          sum(sp.close_value - p.sales_price)
          over(partition by sp.sales_agent) as total_profit_agent
     from sales_pipeline_clean sp
     join products p
   on sp.product = p.product
     join sales_teams st
   on sp.sales_agent = st.sales_agent
    where sp.deal_stage = 'Won'
    order by sp.sales_agent,
             sp.product
)
select sales_agent,
       regional_office,
       product,
       close_value,
       sales_price,
       simple_profit,
       total_profit_agent
  from base
 order by total_profit_agent desc;