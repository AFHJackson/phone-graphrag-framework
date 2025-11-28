-- ============================================================
-- SHOPPING BREAKDOWN ANALYSIS
-- What's actually in the generic "Shopping" category?
-- ============================================================

-- Top 50 vendors in Shopping category
SELECT 
    COALESCE(normalized_vendor, LEFT(description, 40)) as vendor,
    COUNT(*) as txn_count,
    ROUND(SUM(ABS(amount)), 2) as total_spent,
    ROUND(AVG(ABS(amount)), 2) as avg_txn
FROM transactions t
JOIN categories c ON t.category_id = c.category_id
WHERE c.category_code = 'SHOPPING'
  AND t.transaction_type = 'expense'
GROUP BY COALESCE(normalized_vendor, LEFT(description, 40))
ORDER BY total_spent DESC
LIMIT 50;

-- Sample transactions from Shopping to see patterns
SELECT 
    transaction_date,
    LEFT(description, 60) as description,
    amount,
    normalized_vendor
FROM transactions t
JOIN categories c ON t.category_id = c.category_id
WHERE c.category_code = 'SHOPPING'
  AND t.transaction_type = 'expense'
ORDER BY ABS(amount) DESC
LIMIT 100;
