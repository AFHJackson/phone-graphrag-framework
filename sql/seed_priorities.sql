-- ============================================================
-- Priority Seed Data
-- Based on user's declared priorities from brain-dump
-- ============================================================

-- Clear existing
DELETE FROM category_priorities;
DELETE FROM priorities;

-- Insert priorities ranked by importance (1 = highest)
INSERT INTO priorities (priority_name, priority_rank, description) VALUES
('Faith & Community', 1, 'Church, charities, youth sponsorships - giving back'),
('Health & Fitness', 2, 'Physical health, fitness, nutrition, medical care'),
('Family & Education', 3, 'Sons activities, school, education materials'),
('Housing Stability', 4, 'Mortgage, repairs, maintaining the home'),
('Food & Nutrition', 5, 'Groceries (quality food), balanced meals'),
('Financial Security', 6, 'Debt payoff, savings, investments, taxes'),
('Transportation', 7, 'Reliable vehicles, maintenance, fuel'),
('Utilities', 8, 'Essential services - water, electric, internet'),
('Insurance', 9, 'Protection - auto, home, health'),
('Personal Care', 10, 'Clothing, grooming, personal needs'),
('Pets', 11, 'Pet care - food, vet, supplies'),
('Entertainment', 12, 'Recreation, streaming, hobbies - discretionary'),
('Travel', 13, 'Cruises, flights, hotels - optional'),
('Shopping', 14, 'General retail, Amazon - lowest priority');

-- Link priorities to categories
-- Priority 1: Faith & Community
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('COMMUNITY', 'COMM_CHURCH', 'COMM_CHARITY', 'COMM_GIFTS', 'COMM_YOUTH')
  AND p.priority_name = 'Faith & Community';

-- Priority 2: Health & Fitness  
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('HEALTH', 'HEALTH_MEDICAL', 'HEALTH_RX', 'HEALTH_FITNESS', 'HEALTH_GYM', 'HEALTH_NUTRITION', 'HEALTH_PEPTIDES', 'HEALTH_PERSONAL')
  AND p.priority_name = 'Health & Fitness';

-- Priority 3: Family & Education
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('FAMILY', 'FAM_YOUTH', 'FAM_SCHOOL', 'FAM_EDUCATION', 'FAM_CHILDREN')
  AND p.priority_name = 'Family & Education';

-- Priority 4: Housing Stability
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('HOUSING', 'HOUSING_MORTGAGE', 'HOUSING_REPAIRS', 'HOUSING_FURNISH', 'HOUSING_PROPTAX', 'HOUSING_HOA', 'HOUSING_SOLAR')
  AND p.priority_name = 'Housing Stability';

-- Priority 5: Food & Nutrition
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('FOOD', 'FOOD_GROCERY', 'FOOD_RESTAURANT', 'FOOD_DELIVERY', 'FOOD_COFFEE')
  AND p.priority_name = 'Food & Nutrition';

-- Priority 6: Financial Security
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('FINANCIAL', 'FIN_DEBT', 'FIN_AUTOLOAN', 'FIN_INVESTMENT', 'FIN_TAX_FED', 'FIN_TAX_STATE')
  AND p.priority_name = 'Financial Security';

-- Priority 7: Transportation
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('TRANSPORTATION', 'TRANS_AUTOLOAN', 'TRANS_GAS', 'TRANS_SERVICE', 'TRANS_PARTS', 'TRANS_PARKING')
  AND p.priority_name = 'Transportation';

-- Priority 8: Utilities
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('UTILITIES', 'UTIL_ELECTRIC', 'UTIL_WATER', 'UTIL_GAS', 'UTIL_INTERNET', 'UTIL_PHONE')
  AND p.priority_name = 'Utilities';

-- Priority 9: Insurance
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('INSURANCE', 'INS_AUTO', 'INS_HOME', 'INS_HEALTH', 'INS_LIFE')
  AND p.priority_name = 'Insurance';

-- Priority 10: Personal Care
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('CLOTHING', 'CLOTH_PURCHASE', 'CLOTH_MAINTAIN')
  AND p.priority_name = 'Personal Care';

-- Priority 11: Pets
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('PETS', 'PET_FOOD', 'PET_VET', 'PET_GROOMING', 'PET_SUPPLIES')
  AND p.priority_name = 'Pets';

-- Priority 12: Entertainment
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('ENTERTAINMENT', 'ENT_EVENTS', 'ENT_MEDIA', 'ENT_RECREATION', 'ENT_HOBBIES', 'ENT_SOCIAL')
  AND p.priority_name = 'Entertainment';

-- Priority 13: Travel
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('TRAVEL', 'TRAVEL_FLIGHTS', 'TRAVEL_HOTELS', 'TRAVEL_CRUISES', 'TRAVEL_GROUND', 'TRAVEL_OTHER')
  AND p.priority_name = 'Travel';

-- Priority 14: Shopping (lowest)
INSERT INTO category_priorities (category_id, priority_id, weight)
SELECT c.category_id, p.priority_id, 1.0
FROM categories c, priorities p
WHERE c.category_code IN ('SHOPPING', 'SHOP_AMAZON', 'SHOP_ELECTRONICS', 'SHOP_HOUSEHOLD', 'SHOP_GENERAL')
  AND p.priority_name = 'Shopping';

-- Verify
SELECT p.priority_rank, p.priority_name, COUNT(cp.category_id) as categories_linked
FROM priorities p
LEFT JOIN category_priorities cp ON p.priority_id = cp.priority_id
GROUP BY p.priority_rank, p.priority_name
ORDER BY p.priority_rank;
