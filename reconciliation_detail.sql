WITH duplicate_check AS (
    SELECT transaction_id, COUNT(*) AS occurrence_count
    FROM bank_statement
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
)
SELECT 
    p.transaction_id, 
    p.type, 
    p.amount AS internal_amount, 
    b.amount AS bank_amount,
    CASE
        WHEN d.transaction_id IS NOT NULL THEN 'Duplicate in Bank'
        WHEN b.transaction_id IS NULL THEN 'Missing from Bank'
        WHEN p.amount != b.amount THEN 'Amount Mismatch'
        ELSE 'Matched'
    END AS reconciliation_status
FROM paysim_30day_sample p
LEFT JOIN bank_statement b ON p.transaction_id = b.transaction_id
LEFT JOIN duplicate_check d ON p.transaction_id = d.transaction_id;
