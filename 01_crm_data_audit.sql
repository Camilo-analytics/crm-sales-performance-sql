-- ============================================================
-- 01_crm_data_audit.sql
-- Project: CRM Sales Performance Analysis
-- Dataset: Maven Analytics — CRM Sales Opportunities
-- ============================================================
-- OBJECTIVE: Assess data quality across all 4 tables before cleaning.
-- Tables: sales_pipeline | accounts | sales_teams | products
-- ============================================================

-- ============================================================
-- AUDIT FINDINGS SUMMARY
-- ============================================================
-- TABLE: sales_pipeline (8,800 rows)
-- FINDING 1: account — 1,425 blanks (1,088 Engaging + 337 Prospecting)
--   DECISION: Replace blanks with 'unknown' — business decision,
--   early-stage deals without identified account.
-- FINDING 2: engage_date — 500 blanks (all Prospecting)
--   DECISION: Leave as NULL — no engagement occurred yet.
-- FINDING 3: close_date + close_value — 2,089 blanks each (Engaging + Prospecting)
--   DECISION: Leave as NULL — deals not yet closed, valid business state.
-- FINDING 4: GTXPro in product column — 1,480 records
--   DECISION: Correct to 'GTX Pro' to match products table — JOIN integrity.
-- No duplicates detected. ✅
--
-- TABLE: accounts (85 rows)
-- FINDING 5: sector — typo 'technolgy'
--   DECISION: Correct to 'technology'.
-- No NULLs or duplicates detected. ✅
--
-- TABLE: sales_teams (35 rows)
-- No issues detected. ✅
--
-- TABLE: products (7 rows)
-- No issues detected. ✅
--
-- REFERENTIAL INTEGRITY:
-- FINDING 6: 'GTXPro' in sales_pipeline does not match 'GTX Pro' in products.
--   Affects 1,480 deals — revenue analysis would lose these records without fix.
--   DECISION: Corrected in cleaning via CASE WHEN.
--
-- LIMITATIONS:
-- Dataset is fictitious — business patterns are illustrative only.
-- 'unknown' accounts (1,425) excluded from account-level analysis.
-- close_value represents deal value at close — not recurring revenue.
-- ============================================================


-- ============================================================
-- TABLE 1: sales_pipeline
-- ============================================================

-- 1.1 Row count
select count(*) as total_rows
  from sales_pipeline;

-- 1.2 Distinct values — categorical columns
select distinct deal_stage
  from sales_pipeline;
select distinct product
  from sales_pipeline;

-- 1.3 NULL / blank check per column
select count(*) as total_rows,
       sum(
          case
             when opportunity_id = ''
                 or opportunity_id is null then
                1
             else
                0
          end
       ) as null_opportunity_id,
       sum(
          case
             when sales_agent = ''
                 or sales_agent is null then
                1
             else
                0
          end
       ) as null_sales_agent,
       sum(
          case
             when product = ''
                 or product is null then
                1
             else
                0
          end
       ) as null_product,
       sum(
          case
             when account = ''
                 or account is null then
                1
             else
                0
          end
       ) as null_account,
       sum(
          case
             when deal_stage = ''
                 or deal_stage is null then
                1
             else
                0
          end
       ) as null_deal_stage,
       sum(
          case
             when engage_date = ''
                 or engage_date is null then
                1
             else
                0
          end
       ) as null_engage_date,
       sum(
          case
             when close_date = ''
                 or close_date is null then
                1
             else
                0
          end
       ) as null_close_date,
       sum(
          case
             when close_value = ''
                 or close_value is null then
                1
             else
                0
          end
       ) as null_close_value
  from sales_pipeline;

-- 1.4 Duplicate check
select opportunity_id,
       count(*) as occurrences
  from sales_pipeline
 group by opportunity_id
having occurrences > 1;

-- 1.5 Blank accounts — validate deal stage distribution
select deal_stage,
       count(*) as total
  from sales_pipeline
 where account = ''
    or account is null
 group by deal_stage;

-- 1.6 Validate close_date and close_value blanks by deal stage
select deal_stage,
       count(*) as total
  from sales_pipeline
 where close_date = ''
    or close_date is null
 group by deal_stage;


-- ============================================================
-- TABLE 2: accounts
-- ============================================================

-- 2.1 Row count
select count(*) as total_rows
  from accounts;

-- 2.2 NULL / blank check
select count(*) as total_rows,
       sum(
          case
             when account = ''
                 or account is null then
                1
             else
                0
          end
       ) as null_account,
       sum(
          case
             when sector = ''
                 or sector is null then
                1
             else
                0
          end
       ) as null_sector,
       sum(
          case
             when revenue = ''
                 or revenue is null then
                1
             else
                0
          end
       ) as null_revenue,
       sum(
          case
             when employees = ''
                 or employees is null then
                1
             else
                0
          end
       ) as null_employees,
       sum(
          case
             when office_location = ''
                 or office_location is null then
                1
             else
                0
          end
       ) as null_office_location
  from accounts;

-- 2.3 Distinct sectors
select distinct sector
  from accounts;


-- ============================================================
-- TABLE 3: sales_teams
-- ============================================================

-- 3.1 Row count
select count(*) as total_rows
  from sales_teams;

-- 3.2 NULL / blank check
select count(*) as total_rows,
       sum(
          case
             when sales_agent = ''
                 or sales_agent is null then
                1
             else
                0
          end
       ) as null_sales_agent,
       sum(
          case
             when manager = ''
                 or manager is null then
                1
             else
                0
          end
       ) as null_manager,
       sum(
          case
             when regional_office = ''
                 or regional_office is null then
                1
             else
                0
          end
       ) as null_regional_office
  from sales_teams;

-- 3.3 Distinct regions
select distinct regional_office
  from sales_teams;


-- ============================================================
-- TABLE 4: products
-- ============================================================

-- 4.1 Row count
select count(*) as total_rows
  from products;

-- 4.2 NULL / blank check
select count(*) as total_rows,
       sum(
          case
             when product = ''
                 or product is null then
                1
             else
                0
          end
       ) as null_product,
       sum(
          case
             when series = ''
                 or series is null then
                1
             else
                0
          end
       ) as null_series,
       sum(
          case
             when sales_price = ''
                 or sales_price is null then
                1
             else
                0
          end
       ) as null_sales_price
  from products;

-- 4.3 All products and prices
select *
  from products;


-- ============================================================
-- REFERENTIAL INTEGRITY
-- ============================================================

-- 5.1 Accounts in pipeline not found in accounts table
select distinct sp.account
  from sales_pipeline sp
  left join accounts a
on sp.account = a.account
 where a.account is null
   and ( sp.account != ''
   and sp.account is not null );

-- 5.2 Sales agents in pipeline not found in sales_teams
select distinct sp.sales_agent
  from sales_pipeline sp
  left join sales_teams st
on sp.sales_agent = st.sales_agent
 where st.sales_agent is null;

-- 5.3 Products in pipeline not found in products table
select distinct sp.product
  from sales_pipeline sp
  left join products p
on sp.product = p.product
 where p.product is null;