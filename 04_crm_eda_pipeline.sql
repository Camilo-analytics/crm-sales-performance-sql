-- ============================================================
-- 04_crm_eda_pipeline.sql
-- Project: CRM Sales Performance Analysis
-- Dataset: Maven Analytics — CRM Sales Opportunities
-- ============================================================
-- BUSINESS BRIEF (Enzo, Sales Manager):
-- "I want to understand how our pipeline moves — how many deals
-- are active, how long it takes to close them, and whether
-- faster deals are more likely to be won."
--
-- ANALYST QUESTIONS:
-- Q1: How many deals are in each stage of the pipeline?
-- Q2: What is the average cycle time (days) from engage to close
--     — and does it differ between Won and Lost deals?
-- Q3: Which products and agents have the shortest cycle time?
-- Q4: What is the estimated revenue lost from deals that did not close?
--
-- NOTE: Cycle time calculated as JULIANDAY(close_date) - JULIANDAY(engage_date)
-- Only deals with both engage_date and close_date are included.
-- Prospecting deals excluded — no engage_date recorded.
-- ============================================================
-- ============================================================
-- Q1: Current pipeline stage distribution
-- ============================================================
-- FINDING: Pipeline is healthy — 48.2% of all deals are Won.
-- Lost deals represent 28.1% — offset by 23.7% still active
-- (Engaging 18.1% + Prospecting 5.7%). If active deals convert
-- at the current win rate, pipeline has significant upside.
-- ============================================================

select sum(
   case
      when deal_stage = 'Won' then
         1
      else
         0
   end
) as won_deals,
       sum(
          case
             when deal_stage = 'Lost' then
                1
             else
                0
          end
       ) as lost_deals,
       sum(
          case
             when deal_stage = 'Engaging' then
                1
             else
                0
          end
       ) as engaging_deals,
       sum(
          case
             when deal_stage = 'Prospecting' then
                1
             else
                0
          end
       ) as prospecting_deals
  from sales_pipeline_clean;
-- ============================================================
-- Q2: Average cycle time — Won vs Lost deals
-- ============================================================
-- FINDING: Lost deals close faster (41.48 days) than Won deals (51.78 days).
-- Counterintuitive — longer negotiation correlates with winning.
-- However, 10+ days spent on Lost deals represents significant
-- time cost. Key opportunity: identify early signals that predict
-- whether a deal will be Won or Lost to reduce wasted pipeline time.
-- ============================================================

select deal_stage,
       round(
          avg(julianday(close_date) - julianday(engage_date)),
          2
       ) as avg_cycle_days
  from sales_pipeline_clean
 where deal_stage in ( 'Won',
                       'Lost' )
 group by deal_stage;
-- ============================================================
-- Q3a: Average cycle time by product
-- ============================================================
-- FINDING: GTX Pro closes fastest at 45.73 days — also the highest
-- revenue product. GTK 500 takes longest (53.72 days) but generates
-- the highest revenue per deal ($26,768 list price).
-- No dramatic variation across products (45-54 day range),
-- suggesting cycle time is driven more by agent behavior
-- than by product complexity.
-- ============================================================

select product,
       round(
          avg(julianday(close_date) - julianday(engage_date)),
          2
       ) as avg_cycle_days
  from sales_pipeline_clean
 where deal_stage in ( 'Won',
                       'Lost' )
 group by product
 order by avg_cycle_days;

-- ============================================================
-- Q3b: Average cycle time by agent
-- ============================================================
-- FINDING: Cycle time varies from 38.74 days (Cecily Lampkin) to
-- 56.92 days (Moses Frase). Faster cycle time does not directly
-- correlate with higher revenue — product mix is the stronger driver.
-- Cecily's speed advantage may reflect her focus on specific products
-- rather than a generalizable closing technique.
-- ============================================================

select sales_agent,
       round(
          avg(julianday(close_date) - julianday(engage_date)),
          2
       ) as avg_cycle_days
  from sales_pipeline_clean
 where deal_stage in ( 'Won',
                       'Lost' )
 group by sales_agent
 order by avg_cycle_days;
-- ============================================================
-- Q4: Estimated revenue lost from deals that did not close
-- (3-table JOIN: sales_pipeline_clean + products + sales_teams)
-- ============================================================
-- FINDING: Darcel Schlecht leads in lost revenue opportunity ($734,313)
-- — the same agent who leads in gross revenue but has negative profit.
-- Pattern suggests an aggressive pipeline strategy that opens many deals
-- but closes below official price and loses significant volume.
-- The business is inflating revenue metrics while losing margin.
-- RECOMMENDATION: Review Darcel's deal qualification and pricing discipline.
-- ============================================================
with base as (
   select sp.sales_agent,
          st.regional_office,
          sp.product,
          p.sales_price,
          sum(p.sales_price)
          over(partition by sp.sales_agent) as profit_expected
     from sales_pipeline_clean sp
     join products p
   on sp.product = p.product
     join sales_teams st
   on sp.sales_agent = st.sales_agent
    where sp.deal_stage = 'Lost'
    order by sp.sales_agent,
             sp.product
)
select sales_agent,
       regional_office,
       product,
       sales_price,
       profit_expected
  from base
 order by profit_expected desc;