 # PayFlowNG: 30-Day Payment Reconciliation Analysis

## Problem Statement
This project demonstrates how I would approach payment reconciliation analysis using SQL and Excel, by building a dataset with deliberately known breaks so I could prove my understanding of reconciliation — not just that a query runs, but that it correctly and completely identifies every discrepancy type a real reconciliation analyst would need to catch.

## Data Source
- **PaySim** (Kaggle) — a real, publicly available synthetic financial transaction dataset simulating fintech payment activity.
- **bank_statement discrepancies** — deliberately introduced by me, for demonstration purposes, to create a controlled test of the reconciliation logic against known, documented breaks.

## Tools Used
MySQL, Excel

## Methodology
I sampled 10,000 transactions from a 30-day window, then introduced controlled breaks into a copy of the data to simulate a real bank statement:
- 15 missing records
- 10 amount mismatches
- 3 duplicated transactions, appearing as 6 entries in the bank statement
  
## Verification
I verified my reconciliation query caught all of them by cross-checking the query's flagged results against a documented list of the introduced breaks — using a `transaction_id` comparison to confirm the missing records, and a dedicated `amount_mismatch_original` audit table (capturing original amounts before alteration) to confirm the mismatches.

[Reconciliation Dashboard Summary](verification_screenshot.png 1, verification_screenshot.png 2)
## Key Findings
- 10,003 total line items
- 99.86% reconciled by value
- ₦3,647.92 in amount mismatches
- 15 missing transactions
- 3 duplicated transactions, appearing as 6 entries in the bank statement

## Files in this Repo
- `reconciliation_query.sql` — the SQL reconciliation logic, with full comments
- `reconciliation_dashboard.xlsx` — Excel dashboard with summary metrics and conditional formatting
- `README.md` — this file
