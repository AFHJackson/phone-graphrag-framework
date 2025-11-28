-- ============================================================
-- AMAZON PRODUCT CATEGORIZATION
-- Keyword-based category assignment for Amazon orders
-- ============================================================

-- First, let's see what we're working with
SELECT COUNT(*) as total_items, 
       ROUND(SUM(total_owed)::numeric, 2) as total_value
FROM amazon_orders;

-- Create a categorization view
DROP VIEW IF EXISTS amazon_categorized;
CREATE VIEW amazon_categorized AS
SELECT 
    order_id,
    order_date,
    product_name,
    unit_price,
    quantity,
    total_owed,
    CASE 
        -- ============================================================
        -- FAMILY & YOUTH (Priority #3)
        -- ============================================================
        WHEN product_name ILIKE '%lacrosse%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%hockey%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%basketball%' AND product_name NOT ILIKE '%shoe%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%soccer%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%football%' AND product_name NOT ILIKE '%fantasy%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%baseball%' AND product_name NOT ILIKE '%cap%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%skateboard%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%scooter%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%hoverboard%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%rollerblade%' OR product_name ILIKE '%inline skate%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%trampoline%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%nerf%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%lego%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%toy%' AND product_name NOT ILIKE '%pet%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%kid%' OR product_name ILIKE '%child%' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%boy%s %' THEN 'FAM_YOUTH'
        WHEN product_name ILIKE '%school%' THEN 'FAM_SCHOOL'
        WHEN product_name ILIKE '%backpack%' AND product_name ILIKE '%kid%' THEN 'FAM_SCHOOL'
        
        -- ============================================================
        -- HEALTH & FITNESS (Priority #2)
        -- ============================================================
        WHEN product_name ILIKE '%vitamin%' OR product_name ILIKE '%supplement%' THEN 'HEALTH_NUTRITION'
        WHEN product_name ILIKE '%protein%' AND product_name ILIKE '%powder%' THEN 'HEALTH_NUTRITION'
        WHEN product_name ILIKE '%collagen%' THEN 'HEALTH_NUTRITION'
        WHEN product_name ILIKE '%probiotic%' THEN 'HEALTH_NUTRITION'
        WHEN product_name ILIKE '%omega%' AND product_name ILIKE '%fish%' THEN 'HEALTH_NUTRITION'
        WHEN product_name ILIKE '%dumbbell%' OR product_name ILIKE '%weight%' AND product_name ILIKE '%lb%' THEN 'HEALTH_FITNESS'
        WHEN product_name ILIKE '%kettlebell%' THEN 'HEALTH_FITNESS'
        WHEN product_name ILIKE '%resistance band%' THEN 'HEALTH_FITNESS'
        WHEN product_name ILIKE '%yoga mat%' THEN 'HEALTH_FITNESS'
        WHEN product_name ILIKE '%exercise%' OR product_name ILIKE '%workout%' THEN 'HEALTH_FITNESS'
        WHEN product_name ILIKE '%treadmill%' OR product_name ILIKE '%elliptical%' THEN 'HEALTH_FITNESS'
        WHEN product_name ILIKE '%bowflex%' OR product_name ILIKE '%bench%' AND product_name ILIKE '%weight%' THEN 'HEALTH_FITNESS'
        WHEN product_name ILIKE '%fitness%' THEN 'HEALTH_FITNESS'
        WHEN product_name ILIKE '%toothbrush%' OR product_name ILIKE '%dental%' THEN 'HEALTH_PERSONAL'
        WHEN product_name ILIKE '%shampoo%' OR product_name ILIKE '%conditioner%' THEN 'HEALTH_PERSONAL'
        WHEN product_name ILIKE '%lotion%' OR product_name ILIKE '%moisturizer%' THEN 'HEALTH_PERSONAL'
        WHEN product_name ILIKE '%sunscreen%' THEN 'HEALTH_PERSONAL'
        WHEN product_name ILIKE '%first aid%' OR product_name ILIKE '%bandage%' THEN 'HEALTH_MEDICAL'
        WHEN product_name ILIKE '%thermometer%' THEN 'HEALTH_MEDICAL'
        WHEN product_name ILIKE '%blood pressure%' THEN 'HEALTH_MEDICAL'
        WHEN product_name ILIKE '%knee%brace%' OR product_name ILIKE '%ankle%brace%' THEN 'HEALTH_MEDICAL'
        WHEN product_name ILIKE '%bauerfeind%' THEN 'HEALTH_MEDICAL'
        
        -- ============================================================
        -- HOUSING (Priority #4)
        -- ============================================================
        WHEN product_name ILIKE '%mattress%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%pillow%' AND product_name NOT ILIKE '%throw%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%bedding%' OR product_name ILIKE '%sheet%' AND product_name ILIKE '%bed%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%comforter%' OR product_name ILIKE '%duvet%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%furniture%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%sofa%' OR product_name ILIKE '%couch%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%chair%' AND product_name NOT ILIKE '%office%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%table%' AND product_name NOT ILIKE '%tablet%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%lamp%' OR product_name ILIKE '%light%' AND product_name ILIKE '%ceiling%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%ceiling fan%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%curtain%' OR product_name ILIKE '%blind%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%rug%' AND product_name NOT ILIKE '%drug%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%mirror%' AND product_name ILIKE '%bathroom%' THEN 'HOUSING_FURNISH'
        WHEN product_name ILIKE '%bathroom%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%kitchen%' AND product_name NOT ILIKE '%aid%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%sink%' OR product_name ILIKE '%faucet%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%garbage disposal%' OR product_name ILIKE '%insinkerator%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%toilet%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%shower%' AND product_name NOT ILIKE '%baby%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%paint%' OR product_name ILIKE '%primer%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%drill%' OR product_name ILIKE '%saw%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%tool%' AND product_name NOT ILIKE '%garden%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%security%camera%' OR product_name ILIKE '%lorex%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%ring%doorbell%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%smoke%detector%' OR product_name ILIKE '%carbon%monoxide%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%air%filter%' OR product_name ILIKE '%hvac%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%hepa%' OR product_name ILIKE '%air%purifier%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%vacuum%' THEN 'HOUSING_REPAIRS'
        WHEN product_name ILIKE '%cleaning%' THEN 'HOUSING_REPAIRS'
        
        -- ============================================================
        -- FOOD (Priority #5) - Kitchen appliances
        -- ============================================================
        WHEN product_name ILIKE '%kitchenaid%' THEN 'FOOD_GROCERY'
        WHEN product_name ILIKE '%blender%' OR product_name ILIKE '%ninja%' THEN 'FOOD_GROCERY'
        WHEN product_name ILIKE '%juicer%' THEN 'FOOD_GROCERY'
        WHEN product_name ILIKE '%instant pot%' OR product_name ILIKE '%slow cooker%' THEN 'FOOD_GROCERY'
        WHEN product_name ILIKE '%air fryer%' THEN 'FOOD_GROCERY'
        WHEN product_name ILIKE '%coffee%maker%' OR product_name ILIKE '%espresso%' THEN 'FOOD_COFFEE'
        WHEN product_name ILIKE '%keurig%' OR product_name ILIKE '%nespresso%' THEN 'FOOD_COFFEE'
        WHEN product_name ILIKE '%snack%' OR product_name ILIKE '%candy%' OR product_name ILIKE '%chocolate%' THEN 'FOOD_GROCERY'
        
        -- ============================================================
        -- TRANSPORTATION (Priority #7)
        -- ============================================================
        WHEN product_name ILIKE '%brake%' THEN 'TRANS_PARTS'
        WHEN product_name ILIKE '%tire%' AND product_name NOT ILIKE '%retire%' THEN 'TRANS_PARTS'
        WHEN product_name ILIKE '%floor mat%' AND product_name ILIKE '%car%' THEN 'TRANS_PARTS'
        WHEN product_name ILIKE '%tesla%' AND product_name ILIKE '%mat%' THEN 'TRANS_PARTS'
        WHEN product_name ILIKE '%3d maxpider%' THEN 'TRANS_PARTS'
        WHEN product_name ILIKE '%car%seat%' AND product_name NOT ILIKE '%cover%' THEN 'TRANS_PARTS'
        WHEN product_name ILIKE '%motor%oil%' OR product_name ILIKE '%oil%filter%' THEN 'TRANS_PARTS'
        WHEN product_name ILIKE '%wiper%' THEN 'TRANS_PARTS'
        WHEN product_name ILIKE '%headlight%' OR product_name ILIKE '%taillight%' THEN 'TRANS_PARTS'
        WHEN product_name ILIKE '%car%charger%' OR product_name ILIKE '%jump%starter%' THEN 'TRANS_PARTS'
        
        -- ============================================================
        -- PETS (Priority #11)
        -- ============================================================
        WHEN product_name ILIKE '%dog%' THEN 'PET_SUPPLIES'
        WHEN product_name ILIKE '%cat%' AND product_name NOT ILIKE '%category%' AND product_name NOT ILIKE '%catch%' THEN 'PET_SUPPLIES'
        WHEN product_name ILIKE '%pet%' THEN 'PET_SUPPLIES'
        WHEN product_name ILIKE '%leash%' OR product_name ILIKE '%collar%' AND product_name NOT ILIKE '%shirt%' THEN 'PET_SUPPLIES'
        WHEN product_name ILIKE '%chew%toy%' OR product_name ILIKE '%treat%' AND product_name ILIKE '%dog%' THEN 'PET_FOOD'
        
        -- ============================================================
        -- ENTERTAINMENT (Priority #12)
        -- ============================================================
        WHEN product_name ILIKE '%TV%' OR product_name ILIKE '%television%' THEN 'ENT_MEDIA'
        WHEN product_name ILIKE '%xbox%' OR product_name ILIKE '%playstation%' OR product_name ILIKE '%nintendo%' THEN 'ENT_MEDIA'
        WHEN product_name ILIKE '%gaming%' THEN 'ENT_MEDIA'
        WHEN product_name ILIKE '%headphone%' OR product_name ILIKE '%earbuds%' OR product_name ILIKE '%airpod%' THEN 'ENT_MEDIA'
        WHEN product_name ILIKE '%speaker%' THEN 'ENT_MEDIA'
        WHEN product_name ILIKE '%echo%' AND product_name ILIKE '%amazon%' THEN 'ENT_MEDIA'
        WHEN product_name ILIKE '%projector%' THEN 'ENT_MEDIA'
        WHEN product_name ILIKE '%kayak%' OR product_name ILIKE '%paddleboard%' THEN 'ENT_RECREATION'
        WHEN product_name ILIKE '%bike%' OR product_name ILIKE '%bicycle%' THEN 'ENT_RECREATION'
        WHEN product_name ILIKE '%pool%' AND product_name NOT ILIKE '%carpool%' THEN 'ENT_RECREATION'
        WHEN product_name ILIKE '%grill%' AND product_name NOT ILIKE '%restaurant%' THEN 'ENT_RECREATION'
        WHEN product_name ILIKE '%camping%' OR product_name ILIKE '%tent%' THEN 'ENT_RECREATION'
        WHEN product_name ILIKE '%fishing%' THEN 'ENT_RECREATION'
        WHEN product_name ILIKE '%golf%' THEN 'ENT_RECREATION'
        WHEN product_name ILIKE '%ski%' OR product_name ILIKE '%snowboard%' THEN 'ENT_RECREATION'
        WHEN product_name ILIKE '%goggles%' AND product_name ILIKE '%snow%' THEN 'ENT_RECREATION'
        WHEN product_name ILIKE '%book%' AND product_name NOT ILIKE '%notebook%' AND product_name NOT ILIKE '%facebook%' THEN 'ENT_MEDIA'
        WHEN product_name ILIKE '%ring light%' OR product_name ILIKE '%diva%light%' THEN 'ENT_HOBBIES'
        
        -- ============================================================
        -- CLOTHING (Priority #10)
        -- ============================================================
        WHEN product_name ILIKE '%shirt%' OR product_name ILIKE '%t-shirt%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%pants%' OR product_name ILIKE '%jeans%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%dress%' AND product_name NOT ILIKE '%address%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%shoe%' OR product_name ILIKE '%sneaker%' OR product_name ILIKE '%boot%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%jacket%' OR product_name ILIKE '%coat%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%hat%' OR product_name ILIKE '%cap%' AND product_name NOT ILIKE '%capacity%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%sock%' OR product_name ILIKE '%underwear%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%watch%' AND product_name NOT ILIKE '%apple%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%jewelry%' OR product_name ILIKE '%necklace%' OR product_name ILIKE '%bracelet%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%sunglasses%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%backpack%' OR product_name ILIKE '%bag%' AND product_name NOT ILIKE '%trash%' THEN 'CLOTH_PURCHASE'
        WHEN product_name ILIKE '%coach%' THEN 'CLOTH_PURCHASE'
        
        -- ============================================================
        -- ELECTRONICS/SHOPPING (Priority #14)
        -- ============================================================
        WHEN product_name ILIKE '%iphone%' OR product_name ILIKE '%ipad%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%samsung%' AND product_name ILIKE '%galaxy%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%tablet%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%laptop%' OR product_name ILIKE '%computer%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%monitor%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%keyboard%' OR product_name ILIKE '%mouse%' AND product_name NOT ILIKE '%trap%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%charger%' OR product_name ILIKE '%cable%' AND product_name ILIKE '%usb%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%camera%' AND product_name NOT ILIKE '%security%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%sd card%' OR product_name ILIKE '%hard drive%' OR product_name ILIKE '%ssd%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%router%' OR product_name ILIKE '%wifi%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%apple%watch%' THEN 'SHOP_ELECTRONICS'
        WHEN product_name ILIKE '%garmin%' OR product_name ILIKE '%fitbit%' THEN 'SHOP_ELECTRONICS'
        
        -- ============================================================
        -- DEFAULT
        -- ============================================================
        ELSE 'SHOP_AMAZON'
    END as category_code
FROM amazon_orders;

-- Show categorization results
SELECT 
    category_code,
    COUNT(*) as items,
    ROUND(SUM(total_owed)::numeric, 2) as total_value
FROM amazon_categorized
GROUP BY category_code
ORDER BY total_value DESC;
