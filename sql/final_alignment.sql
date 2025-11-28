-- ============================================================
-- FINAL PRIORITY ALIGNMENT COMPARISON
-- Before vs After Amazon categorization
-- ============================================================

WITH final_totals AS (
    SELECT 
        priority_name,
        priority_rank,
        revised_total,
        RANK() OVER (ORDER BY revised_total DESC) as spend_rank
    FROM (
        SELECT 
            COALESCE(t.priority_name, a.priority_name) as priority_name,
            COALESCE(t.priority_rank, 99) as priority_rank,
            COALESCE(t.txn_total, 0) + COALESCE(a.amazon_total, 0) as revised_total
        FROM (
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
              AND c.category_code != 'SHOP_AMAZON'
            GROUP BY p.priority_name, p.priority_rank
        ) t
        FULL OUTER JOIN (
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
        ) a ON t.priority_name = a.priority_name
    ) combined
    WHERE priority_name != 'Other'
)
SELECT 
    priority_rank as "Priority Rank",
    priority_name as "Priority",
    ROUND(revised_total::numeric, 2) as "Total Spend",
    spend_rank as "Spend Rank",
    CASE 
        WHEN spend_rank < priority_rank THEN '⬆️ OVER (spending > priority)'
        WHEN spend_rank > priority_rank THEN '⬇️ UNDER (priority > spending)'
        ELSE '✅ ALIGNED'
    END as "Alignment"
FROM final_totals
ORDER BY priority_rank;
