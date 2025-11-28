-- ============================================================
-- PRIORITY ALIGNMENT ANALYSIS
-- Compares declared priorities vs actual spending
-- ============================================================

-- Analysis period info
SELECT 
    MIN(transaction_date) as start_date,
    MAX(transaction_date) as end_date,
    COUNT(*) as total_transactions,
    COUNT(*) FILTER (WHERE transaction_type = 'expense') as expense_count,
    SUM(ABS(amount)) FILTER (WHERE transaction_type = 'expense') as total_spending
FROM transactions;

-- ============================================================
-- SPENDING BY PRIORITY (Ranked)
-- ============================================================
WITH priority_spending AS (
    SELECT 
        p.priority_rank,
        p.priority_name,
        COUNT(t.transaction_id) as txn_count,
        SUM(ABS(t.amount)) as total_spent
    FROM priorities p
    JOIN category_priorities cp ON p.priority_id = cp.priority_id
    JOIN categories c ON cp.category_id = c.category_id
    JOIN transactions t ON t.category_id = c.category_id
    WHERE t.transaction_type = 'expense'
      AND t.is_transfer = FALSE
    GROUP BY p.priority_rank, p.priority_name
),
total AS (
    SELECT SUM(total_spent) as grand_total FROM priority_spending
)
SELECT 
    ps.priority_rank as "Rank",
    ps.priority_name as "Priority",
    ps.txn_count as "Txns",
    ROUND(ps.total_spent, 2) as "Spent",
    ROUND(100.0 * ps.total_spent / t.grand_total, 1) as "% of Categorized"
FROM priority_spending ps, total t
ORDER BY ps.priority_rank;

-- ============================================================
-- ALIGNMENT SCORE
-- Higher rank priorities should have higher % - check inversions
-- ============================================================
WITH priority_spending AS (
    SELECT 
        p.priority_rank,
        p.priority_name,
        SUM(ABS(t.amount)) as total_spent
    FROM priorities p
    JOIN category_priorities cp ON p.priority_id = cp.priority_id
    JOIN categories c ON cp.category_id = c.category_id
    JOIN transactions t ON t.category_id = c.category_id
    WHERE t.transaction_type = 'expense'
      AND t.is_transfer = FALSE
    GROUP BY p.priority_rank, p.priority_name
),
ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY total_spent DESC) as spend_rank
    FROM priority_spending
)
SELECT 
    priority_rank as "Priority Rank",
    priority_name as "Priority",
    ROUND(total_spent, 2) as "Spent",
    spend_rank as "Spend Rank",
    CASE 
        WHEN spend_rank < priority_rank THEN '⬆️ OVER-INDEXED (spending > priority)'
        WHEN spend_rank > priority_rank THEN '⬇️ UNDER-INDEXED (priority > spending)'
        ELSE '✅ ALIGNED'
    END as "Alignment"
FROM ranked
ORDER BY priority_rank;

-- ============================================================
-- UNCATEGORIZED / UNMAPPED SPENDING
-- Categories not linked to any priority
-- ============================================================
SELECT 
    c.category_name,
    COUNT(t.transaction_id) as txn_count,
    ROUND(SUM(ABS(t.amount)), 2) as total_spent
FROM transactions t
JOIN categories c ON t.category_id = c.category_id
LEFT JOIN category_priorities cp ON c.category_id = cp.category_id
WHERE t.transaction_type = 'expense'
  AND t.is_transfer = FALSE
  AND cp.category_id IS NULL
GROUP BY c.category_name
ORDER BY total_spent DESC
LIMIT 20;

-- ============================================================
-- TOP SPENDING CATEGORIES (within each priority)
-- ============================================================
SELECT 
    p.priority_rank as "Rank",
    p.priority_name as "Priority",
    c.category_name as "Category",
    COUNT(t.transaction_id) as "Txns",
    ROUND(SUM(ABS(t.amount)), 2) as "Spent"
FROM priorities p
JOIN category_priorities cp ON p.priority_id = cp.priority_id
JOIN categories c ON cp.category_id = c.category_id
JOIN transactions t ON t.category_id = c.category_id
WHERE t.transaction_type = 'expense'
  AND t.is_transfer = FALSE
GROUP BY p.priority_rank, p.priority_name, c.category_name
ORDER BY p.priority_rank, SUM(ABS(t.amount)) DESC;
