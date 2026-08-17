/*
  Reconciliation Summary Query — PayFlowNG Portfolio Project
  Purpose: Compares internal transaction records (paysim_30day_sample) against
  a mock bank statement (bank_statement) to identify reconciliation breaks —
  missing records, amount mismatches, and duplicate bank entries — and
  produces a summary count per break category, with a totals row.
*/

SELECT 
    COALESCE(reconciliation_status, 'Total') AS reconciliation_status, 
    -- ROLLUP leaves the totals row's label blank (NULL); COALESCE fills it in as 'Total'
    COUNT(*) AS count
FROM (
    -- Step 1: Identify any transaction_id that appears more than once in bank_statement.
    -- This catches duplicate/double-settled transactions before checking anything else,
    -- since a duplicate would otherwise still pass the amount-match check below and
    -- get mislabeled as 'Matched'.
    WITH duplicate_check AS (
        SELECT transaction_id, COUNT(*) AS occurrence_count
        FROM bank_statement
        GROUP BY transaction_id
        HAVING COUNT(*) > 1
    )

    -- Step 2: Compare each internal transaction against its bank record.
    -- LEFT JOIN is used (not INNER JOIN) so that internal transactions with
    -- no matching bank record are still returned — visible as 'Missing from Bank' —
    -- rather than silently dropped, which is the entire point of reconciliation.
    SELECT 
        p.transaction_id, 
        p.type, 
        p.amount AS internal_amount, 
        b.amount AS bank_amount,

        -- Order matters here: duplicate check runs first, since a duplicated
        -- transaction would otherwise pass the amount-match check and be
        -- incorrectly labeled 'Matched'. Missing-record check runs next,
        -- then amount mismatch, with 'Matched' as the fallback if none apply.
        CASE
            WHEN d.transaction_id IS NOT NULL THEN 'Duplicate in Bank'
            WHEN b.transaction_id IS NULL THEN 'Missing from Bank'
            WHEN p.amount != b.amount THEN 'Amount Mismatch'
            ELSE 'Matched'
        END AS reconciliation_status

    FROM paysim_30day_sample p
    LEFT JOIN bank_statement b ON p.transaction_id = b.transaction_id
    LEFT JOIN duplicate_check d ON p.transaction_id = d.transaction_id

) AS results

-- Step 3: Roll up individual transaction-level results into category counts,
-- with an automatic totals row appended (handled by ROLLUP, labeled via COALESCE above).
GROUP BY reconciliation_status WITH ROLLUP;
