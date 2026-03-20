-- ============================================================
-- 02_crm_cleaning.sql
-- Project: CRM Sales Performance Analysis
-- Dataset: Maven Analytics — CRM Sales Opportunities
-- ============================================================
-- OBJECTIVE: Clean and standardise tables identified with issues
-- in 01_data_audit.sql. Tables without issues used as-is.
--
-- CLEANING DECISIONS:
-- sales_pipeline:
--   1. account blanks → 'unknown' (1,425 records — early stage deals)
--   2. GTXPro → 'GTX Pro' (1,480 records — JOIN integrity with products)
--   3. engage_date, close_date, close_value blanks → NULL
--      (lógica de negocio — deals not yet closed or engaged)
-- accounts:
--   1. sector 'technolgy' → 'technology' (typo correction)
--
-- TABLES WITH NO CHANGES REQUIRED:
--   sales_teams → used directly in analysis
--   products    → used directly in analysis
--
-- LIMITATIONS:
--   Dataset is fictitious — patterns are illustrative only.
--   'unknown' accounts (1,425) excluded from account-level analysis.
--   subsidiary_of blanks retained — indicate independent companies.
-- ============================================================


-- ============================================================
-- TABLE 1: sales_pipeline_clean
-- ============================================================

create table sales_pipeline_clean
   as
      select opportunity_id,
             sales_agent,
             case
                when product like 'GTXPro%' then
                   'GTX Pro'
                else
                   product
             end as product,
             case
                when account = '' then
                   'unknown'
                else
                   account
             end as account,
             deal_stage,
             case
                when engage_date = '' then
                   null
                else
                   engage_date
             end as engage_date,
             case
                when close_date = '' then
                   null
                else
                   close_date
             end as close_date,
             case
                when close_value = '' then
                   null
                else
                   close_value
             end as close_value
        from sales_pipeline;

-- VALIDATION
-- GTXPro corrected
select distinct product
  from sales_pipeline_clean;
-- unknown accounts
select count(*)
  from sales_pipeline_clean
 where account = 'unknown';
-- Result: 1,425 ✅


-- ============================================================
-- TABLE 2: accounts_clean
-- ============================================================

create table accounts_clean
   as
      select account,
             case
                when sector like 'technolgy%' then
                   'technology'
                else
                   sector
             end as sector,
             year_established,
             revenue,
             employees,
             office_location,
             subsidiary_of
        from accounts;

-- VALIDATION
select distinct sector
  from accounts_clean;
-- Result: technology (no typo) ✅