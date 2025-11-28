-- ============================================================
-- LINK AMAZON CATEGORIES TO TRANSACTIONS
-- Update transactions table based on Amazon product data
-- ============================================================

-- First, create a summary of Amazon spending by our new categories
WITH amazon_summary AS (
    SELECT 
        category_code,
        COUNT(*) as items,
        ROUND(SUM(total_owed)::numeric, 2) as total_value
    FROM amazon_categorized
    GROUP BY category_code
)
SELECT 
    COALESCE(c.category_name, ac.category_code) as category,
    ac.items,
    ac.total_value,
    p.priority_name,
    p.priority_rank
FROM amazon_summary ac
LEFT JOIN categories c ON ac.category_code = c.category_code
LEFT JOIN category_priorities cp ON c.category_id = cp.category_id
LEFT JOIN priorities p ON cp.priority_id = p.priority_id
ORDER BY ac.total_value DESC;

-- ============================================================
-- REVISED PRIORITY ALIGNMENT INCLUDING AMAZON BREAKDOWN
-- ============================================================

-- Get Amazon totals by priority
WITH amazon_by_priority AS (
    SELECT 
        CASE 
            WHEN ac.category_code IN ('HEALTH_NUTRITION', 'HEALTH_FITNESS', 'HEALTH_PERSONAL', 'HEALTH_MEDICAL') THEN 'Health & Fitness'
            WHEN ac.category_code IN ('FAM_YOUTH', 'FAM_SCHOOL') THEN 'Family & Education'
            WHEN ac.category_code IN ('HOUSING_FURNISH', 'HOUSING_REPAIRS') THEN 'Housing Stability'
            WHEN ac.category_code IN ('FOOD_GROCERY', 'FOOD_COFFEE') THEN 'Food & Nutrition'
            WHEN ac.category_code = 'TRANS_PARTS' THEN 'Transportation'
            WHEN ac.category_code IN ('PET_SUPPLIES', 'PET_FOOD') THEN 'Pets'
            WHEN ac.category_code IN ('ENT_MEDIA', 'ENT_RECREATION', 'ENT_HOBBIES') THEN 'Entertainment'
            WHEN ac.category_code = 'CLOTH_PURCHASE' THEN 'Personal Care'
            WHEN ac.category_code IN ('SHOP_AMAZON', 'SHOP_ELECTRONICS') THEN 'Shopping'
            ELSE 'Other'
        END as priority_name,
        SUM(total_owed) as amazon_total
    FROM amazon_categorized ac
    GROUP BY 1
),
-- Get current transaction totals by priority (excluding SHOP_AMAZON)
txn_by_priority AS (
    SELECT 
        p.priority_name,
        p.priority_rank,
        SUM(ABS(t.amount)) as txn_total
    FROM priorities p
    JOIN category_priorities cp ON p.priority_id = cp.priority_id
    JOIN categories c ON cp.category_id = c.category_id
    JOIN transactions t ON t.category_id = c.category_id
    WHERE t.transaction_type = 'expense'
      AND t.is_transfer = FALSE
      AND c.category_code != 'SHOP_AMAZON'  -- Exclude Amazon since we're re-categorizing
    GROUP BY p.priority_name, p.priority_rank
),
-- Combine
combined AS (
    SELECT 
        COALESCE(t.priority_name, a.priority_name) as priority_name,
        COALESCE(t.priority_rank, 99) as priority_rank,
        COALESCE(t.txn_total, 0) as txn_total,
        COALESCE(a.amazon_total, 0) as amazon_contribution,
        COALESCE(t.txn_total, 0) + COALESCE(a.amazon_total, 0) as revised_total
    FROM txn_by_priority t
    FULL OUTER JOIN amazon_by_priority a ON t.priority_name = a.priority_name
)
SELECT 
    priority_rank as "Rank",
    priority_name as "Priority",
    ROUND(txn_total::numeric, 2) as "Non-Amazon",
    ROUND(amazon_contribution::numeric, 2) as "Amazon Add",
    ROUND(revised_total::numeric, 2) as "Revised Total",
    ROUND(100.0 * revised_total / SUM(revised_total) OVER (), 1) as "% of Total"
FROM combined
WHERE priority_name != 'Other'
ORDER BY priority_rank;
