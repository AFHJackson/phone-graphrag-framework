-- Priority Alignment: Before vs After Amazon Integration

WITH amazon_by_priority AS (
    SELECT 
        CASE 
            WHEN category_code IN ('HEALTH_NUTRITION', 'HEALTH_FITNESS', 'HEALTH_PERSONAL', 'HEALTH_MEDICAL') THEN 'Health & Fitness'
            WHEN category_code IN ('FAM_YOUTH', 'FAM_SCHOOL') THEN 'Family & Education'
            WHEN category_code IN ('HOUSING_FURNISH', 'HOUSING_REPAIRS') THEN 'Housing Stability'
            WHEN category_code IN ('FOOD_GROCERY', 'FOOD_COFFEE') THEN 'Food & Nutrition'
            WHEN category_code = 'TRANS_PARTS' THEN 'Transportation'
            WHEN category_code IN ('PET_SUPPLIES', 'PET_FOOD') THEN 'Pets'
            WHEN category_code IN ('ENT_MEDIA', 'ENT_RECREATION', 'ENT_HOBBIES') THEN 'Entertainment'
            WHEN category_code = 'CLOTH_PURCHASE' THEN 'Personal Care'
            WHEN category_code IN ('SHOP_AMAZON', 'SHOP_ELECTRONICS') THEN 'Shopping'
            ELSE 'Shopping'
        END as priority_name,
        SUM(total_owed) as amazon_total
    FROM amazon_categorized
    GROUP BY 1
),
txn_totals AS (
    SELECT p.priority_name, p.priority_rank, SUM(ABS(t.amount)) as txn_total
    FROM priorities p
    JOIN category_priorities cp ON p.priority_id = cp.priority_id
    JOIN categories c ON cp.category_id = c.category_id
    JOIN transactions t ON t.category_id = c.category_id
    WHERE t.transaction_type = 'expense' AND t.is_transfer = FALSE
    GROUP BY p.priority_name, p.priority_rank
),
combined AS (
    SELECT 
        t.priority_rank,
        t.priority_name,
        t.txn_total,
        t.txn_total + COALESCE(a.amazon_total, 0) as revised_total
    FROM txn_totals t
    LEFT JOIN amazon_by_priority a ON t.priority_name = a.priority_name
)
SELECT 
    priority_rank as "Declared",
    priority_name,
    RANK() OVER (ORDER BY txn_total DESC) as "Before",
    RANK() OVER (ORDER BY revised_total DESC) as "After",
    ABS(RANK() OVER (ORDER BY revised_total DESC)::int - priority_rank::int) as "Gap"
FROM combined
ORDER BY priority_rank;
