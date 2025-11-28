-- ============================================================
-- SHOPPING RECATEGORIZATION ANALYSIS
-- Suggesting proper category for "Shopping" transactions
-- ============================================================

-- Group by likely correct category
SELECT 
    CASE 
        -- TRANSFERS (should not be expenses!)
        WHEN normalized_vendor ILIKE '%JPMORGAN%' THEN 'TRANSFER (CC payment)'
        WHEN normalized_vendor ILIKE '%ALLY%' THEN 'TRANSFER (Auto loan)'
        WHEN description ILIKE '%Ext Trnsfr%' THEN 'TRANSFER'
        
        -- CHURCH / CHARITY
        WHEN normalized_vendor ILIKE '%COASTLINECHURCH%' THEN 'Faith & Community (CHURCH)'
        WHEN normalized_vendor ILIKE '%LIVEACTION%' THEN 'Faith & Community (CHARITY)'
        WHEN description ILIKE '%JESUS%' THEN 'Faith & Community'
        
        -- FOOD / RESTAURANTS
        WHEN normalized_vendor ILIKE '%PANERA%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%SHOYU%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%THAI THAI%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%FLAVOUR KITCHEN%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%SIMPLY DELICIOUS%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%JOHNATHAN%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%COSY ISLAND%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%GREGORYS%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%COA STEAKHOUSE%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%FLORIDA%GRILL%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%VILLA PALMA%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%DESTINATION FOOD%' THEN 'Food (RESTAURANT)'
        WHEN normalized_vendor ILIKE '%NESPRESSO%' THEN 'Food (COFFEE)'
        WHEN normalized_vendor ILIKE '%INSTACART%' THEN 'Food (GROCERY)'
        WHEN normalized_vendor ILIKE '%WINN-DIXIE%' THEN 'Food (GROCERY)'
        
        -- UTILITIES
        WHEN normalized_vendor ILIKE '%T-MOBILE%' THEN 'Utilities (PHONE)'
        WHEN normalized_vendor ILIKE '%ATT%BILL%' THEN 'Utilities (PHONE)'
        WHEN normalized_vendor ILIKE '%FLORIDACITY GAS%' THEN 'Utilities (GAS)'
        
        -- TRANSPORTATION
        WHEN normalized_vendor ILIKE '%TESLA%' THEN 'Transportation (SERVICE/PARTS)'
        WHEN normalized_vendor ILIKE '%ENTERPRISE RENT%' THEN 'Transportation'
        WHEN normalized_vendor ILIKE '%UBER%TRIP%' THEN 'Transportation (RIDESHARE)'
        
        -- HEALTH
        WHEN normalized_vendor ILIKE '%LABCORP%' THEN 'Health (MEDICAL)'
        WHEN normalized_vendor ILIKE '%HFSS%' OR normalized_vendor ILIKE '%MYCHART%' THEN 'Health (MEDICAL)'
        WHEN normalized_vendor ILIKE '%JOI WOMENS%' THEN 'Health (WELLNESS)'
        WHEN normalized_vendor ILIKE '%BLOKES%' THEN 'Health (WELLNESS)'
        WHEN normalized_vendor ILIKE '%OBAGI%' THEN 'Health (PERSONAL)'
        WHEN normalized_vendor ILIKE '%HERSCAN%' THEN 'Health (MEDICAL)'
        WHEN normalized_vendor ILIKE '%BRILLIANT SMILES%' THEN 'Health (DENTAL)'
        
        -- PERSONAL CARE / CLOTHING
        WHEN normalized_vendor ILIKE '%SHANEL MONIQUE%' THEN 'Personal Care (HAIR)'
        WHEN normalized_vendor ILIKE '%HOLLYWOOD NAILS%' THEN 'Personal Care (NAILS)'
        WHEN normalized_vendor ILIKE '%MAGIC CLEANERS%' THEN 'Clothing (DRY CLEANING)'
        WHEN normalized_vendor ILIKE '%TOUCH OF CLASS%' THEN 'Clothing (DRY CLEANING)'
        WHEN normalized_vendor ILIKE '%LILLY PULITZER%' THEN 'Clothing (PURCHASE)'
        WHEN normalized_vendor ILIKE '%ANN TAYLOR%' THEN 'Clothing (PURCHASE)'
        WHEN normalized_vendor ILIKE '%WINDSOR FASHIONS%' THEN 'Clothing (PURCHASE)'
        WHEN normalized_vendor ILIKE '%MACYS%' THEN 'Clothing (PURCHASE)'
        WHEN normalized_vendor ILIKE '%NORDSTROM%' THEN 'Clothing (PURCHASE)'
        WHEN normalized_vendor ILIKE '%DILLARDS%' THEN 'Clothing (PURCHASE)'
        WHEN normalized_vendor ILIKE '%SEPHORA%' THEN 'Personal Care'
        WHEN normalized_vendor ILIKE '%ULTA%' THEN 'Personal Care'
        
        -- FAMILY & EDUCATION
        WHEN normalized_vendor ILIKE '%JOSTENS%' THEN 'Family (SCHOOL - yearbook)'
        WHEN normalized_vendor ILIKE '%BCS%BREVARD%' THEN 'Family (SCHOOL SPORTS)'
        WHEN normalized_vendor ILIKE '%LACROSSE%' THEN 'Family (YOUTH SPORTS)'
        WHEN normalized_vendor ILIKE '%CCM HOCKEY%' THEN 'Family (YOUTH SPORTS)'
        WHEN normalized_vendor ILIKE '%OFFICE DEPOT%' THEN 'Family (SCHOOL SUPPLIES)'
        
        -- PETS
        WHEN normalized_vendor ILIKE '%WOOF GANG%' THEN 'Pets (GROOMING)'
        WHEN normalized_vendor ILIKE '%ISLAND ANIMAL%' THEN 'Pets (VET)'
        
        -- ENTERTAINMENT
        WHEN normalized_vendor ILIKE '%ABC FINE%' THEN 'Entertainment (ALCOHOL)'
        WHEN normalized_vendor ILIKE '%4TH STREET%' THEN 'Entertainment (BAR)'
        WHEN normalized_vendor ILIKE '%CORK%' THEN 'Entertainment (BAR/WINE)'
        WHEN normalized_vendor ILIKE '%PINEAPPLE POINTE%' THEN 'Entertainment'
        
        -- SHOPPING (actual shopping)
        WHEN normalized_vendor ILIKE '%DOLLAR GENERAL%' THEN 'Shopping (HOUSEHOLD)'
        WHEN normalized_vendor ILIKE '%TINY TURTLE%' THEN 'Shopping (GIFTS)'
        WHEN normalized_vendor ILIKE '%POSHMARK%' THEN 'Shopping (CLOTHING-RESALE)'
        WHEN normalized_vendor ILIKE '%TIKTOK%' THEN 'Shopping (MISC)'
        WHEN normalized_vendor ILIKE '%MERCARI%' THEN 'Shopping (RESALE)'
        WHEN normalized_vendor ILIKE '%SAMSUNG%' THEN 'Shopping (ELECTRONICS)'
        WHEN normalized_vendor ILIKE '%GARMIN%' THEN 'Shopping (ELECTRONICS/FITNESS)'
        WHEN normalized_vendor ILIKE '%BESTBUY%' THEN 'Shopping (ELECTRONICS)'
        WHEN normalized_vendor ILIKE '%HOME DEPOT%' THEN 'Housing (REPAIRS)'
        WHEN normalized_vendor ILIKE '%AAFES%' THEN 'Shopping (MILITARY PX)'
        WHEN normalized_vendor ILIKE '%RON JON%' THEN 'Shopping (RETAIL)'
        
        -- TRAVEL
        WHEN normalized_vendor ILIKE '%WESTGATE%' THEN 'Travel (HOTEL)'
        
        -- APPLE CASH (P2P transfers)
        WHEN normalized_vendor ILIKE '%APPLE CASH%' THEN 'Transfer (P2P)'
        
        ELSE 'REVIEW NEEDED'
    END as suggested_category,
    COUNT(*) as txn_count,
    ROUND(SUM(ABS(amount)), 2) as total_spent
FROM transactions t
JOIN categories c ON t.category_id = c.category_id
WHERE c.category_code = 'SHOPPING'
  AND t.transaction_type = 'expense'
GROUP BY 1
ORDER BY total_spent DESC;
