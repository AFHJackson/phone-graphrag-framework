-- ============================================================
-- Category Taxonomy Seed Data
-- Based on user brain-dump + Chase categories + observed spending
-- ============================================================

-- First, insert top-level categories
INSERT INTO categories (category_code, category_name, category_level, is_bill) VALUES
('INCOME', 'Income', 1, FALSE),
('HOUSING', 'Housing', 1, TRUE),
('TRANSPORTATION', 'Transportation', 1, FALSE),
('UTILITIES', 'Utilities', 1, TRUE),
('INSURANCE', 'Insurance', 1, TRUE),
('FOOD', 'Food', 1, FALSE),
('HEALTH', 'Health & Wellness', 1, FALSE),
('CLOTHING', 'Clothing', 1, FALSE),
('PETS', 'Pets', 1, FALSE),
('FAMILY', 'Family & Education', 1, FALSE),
('COMMUNITY', 'Community & Giving', 1, FALSE),
('ENTERTAINMENT', 'Entertainment & Recreation', 1, FALSE),
('TRAVEL', 'Travel', 1, FALSE),
('SHOPPING', 'Shopping', 1, FALSE),
('SUBSCRIPTIONS', 'Subscriptions & Memberships', 1, TRUE),
('FINANCIAL', 'Financial', 1, FALSE),
('TRANSFERS', 'Transfers', 1, FALSE);

-- INCOME subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'INCOME_MILITARY', 'Military Pay (DFAS)', category_id, 2, FALSE FROM categories WHERE category_code = 'INCOME';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'INCOME_TEACHER', 'Teacher Pay (SSC)', category_id, 2, FALSE FROM categories WHERE category_code = 'INCOME';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'INCOME_PARTTIME', 'Part-time', category_id, 2, FALSE FROM categories WHERE category_code = 'INCOME';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'INCOME_INVESTMENT', 'Investment Income', category_id, 2, FALSE FROM categories WHERE category_code = 'INCOME';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'INCOME_OTHER', 'Other Income', category_id, 2, FALSE FROM categories WHERE category_code = 'INCOME';

-- HOUSING subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HOUSING_MORTGAGE', 'Mortgage/Rent', category_id, 2, TRUE FROM categories WHERE category_code = 'HOUSING';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HOUSING_PROPTAX', 'Property Taxes', category_id, 2, TRUE FROM categories WHERE category_code = 'HOUSING';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HOUSING_HOA', 'HOA', category_id, 2, TRUE FROM categories WHERE category_code = 'HOUSING';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HOUSING_REPAIRS', 'Repairs & Maintenance', category_id, 2, FALSE FROM categories WHERE category_code = 'HOUSING';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HOUSING_FURNISH', 'Furnishing & Equipment', category_id, 2, FALSE FROM categories WHERE category_code = 'HOUSING';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HOUSING_SOLAR', 'Solar Panels (Dividend)', category_id, 2, TRUE FROM categories WHERE category_code = 'HOUSING';

-- TRANSPORTATION subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'TRANS_AUTOLOAN', 'Auto Financing', category_id, 2, TRUE FROM categories WHERE category_code = 'TRANSPORTATION';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'TRANS_GAS', 'Gas', category_id, 2, FALSE FROM categories WHERE category_code = 'TRANSPORTATION';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'TRANS_SERVICE', 'Service & Maintenance', category_id, 2, FALSE FROM categories WHERE category_code = 'TRANSPORTATION';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'TRANS_EQUIPMENT', 'Equipment & Parts', category_id, 2, FALSE FROM categories WHERE category_code = 'TRANSPORTATION';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'TRANS_PARKING', 'Parking & Tolls', category_id, 2, FALSE FROM categories WHERE category_code = 'TRANSPORTATION';

-- UTILITIES subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'UTIL_ELECTRIC', 'Electric', category_id, 2, TRUE FROM categories WHERE category_code = 'UTILITIES';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'UTIL_WATER', 'Water & Sewer', category_id, 2, TRUE FROM categories WHERE category_code = 'UTILITIES';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'UTIL_GAS', 'Natural Gas', category_id, 2, TRUE FROM categories WHERE category_code = 'UTILITIES';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'UTIL_INTERNET', 'Internet', category_id, 2, TRUE FROM categories WHERE category_code = 'UTILITIES';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'UTIL_PHONE', 'Phone/Mobile', category_id, 2, TRUE FROM categories WHERE category_code = 'UTILITIES';

-- INSURANCE subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'INS_AUTO', 'Auto Insurance', category_id, 2, TRUE FROM categories WHERE category_code = 'INSURANCE';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'INS_HOME', 'Home Insurance', category_id, 2, TRUE FROM categories WHERE category_code = 'INSURANCE';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'INS_HEALTH', 'Health Insurance', category_id, 2, TRUE FROM categories WHERE category_code = 'INSURANCE';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'INS_LIFE', 'Life Insurance', category_id, 2, TRUE FROM categories WHERE category_code = 'INSURANCE';

-- FOOD subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FOOD_GROCERY', 'Groceries', category_id, 2, FALSE FROM categories WHERE category_code = 'FOOD';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FOOD_RESTAURANT', 'Restaurants', category_id, 2, FALSE FROM categories WHERE category_code = 'FOOD';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FOOD_DELIVERY', 'Delivery', category_id, 2, FALSE FROM categories WHERE category_code = 'FOOD';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FOOD_COFFEE', 'Coffee & Snacks', category_id, 2, FALSE FROM categories WHERE category_code = 'FOOD';

-- HEALTH subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HEALTH_MEDICAL', 'Medical', category_id, 2, FALSE FROM categories WHERE category_code = 'HEALTH';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HEALTH_FITNESS', 'Fitness', category_id, 2, FALSE FROM categories WHERE category_code = 'HEALTH';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HEALTH_NUTRITION', 'Nutrition', category_id, 2, FALSE FROM categories WHERE category_code = 'HEALTH';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HEALTH_PERSONAL', 'Personal Care', category_id, 2, FALSE FROM categories WHERE category_code = 'HEALTH';

-- Level 3 under HEALTH_MEDICAL
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HEALTH_APPT', 'Appointments', category_id, 3, FALSE FROM categories WHERE category_code = 'HEALTH_MEDICAL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HEALTH_RX', 'Prescriptions', category_id, 3, FALSE FROM categories WHERE category_code = 'HEALTH_MEDICAL';

-- Level 3 under HEALTH_NUTRITION
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HEALTH_VITAMINS', 'Vitamins', category_id, 3, FALSE FROM categories WHERE category_code = 'HEALTH_NUTRITION';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HEALTH_SUPPS', 'Supplements', category_id, 3, FALSE FROM categories WHERE category_code = 'HEALTH_NUTRITION';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'HEALTH_PEPTIDES', 'Peptides', category_id, 3, FALSE FROM categories WHERE category_code = 'HEALTH_NUTRITION';

-- CLOTHING subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'CLOTH_PURCHASE', 'Purchase', category_id, 2, FALSE FROM categories WHERE category_code = 'CLOTHING';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'CLOTH_MAINT', 'Maintenance', category_id, 2, FALSE FROM categories WHERE category_code = 'CLOTHING';

-- PETS subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'PET_FOOD', 'Pet Food', category_id, 2, FALSE FROM categories WHERE category_code = 'PETS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'PET_VET', 'Vet', category_id, 2, FALSE FROM categories WHERE category_code = 'PETS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'PET_GROOMING', 'Grooming', category_id, 2, FALSE FROM categories WHERE category_code = 'PETS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'PET_SUPPLIES', 'Toys & Supplies', category_id, 2, FALSE FROM categories WHERE category_code = 'PETS';

-- FAMILY subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FAM_YOUTH', 'Youth Events', category_id, 2, FALSE FROM categories WHERE category_code = 'FAMILY';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FAM_SCHOOL', 'School Expenses', category_id, 2, FALSE FROM categories WHERE category_code = 'FAMILY';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FAM_EDUCATION', 'Education Materials', category_id, 2, FALSE FROM categories WHERE category_code = 'FAMILY';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FAM_CHILDREN', 'Children Needs', category_id, 2, FALSE FROM categories WHERE category_code = 'FAMILY';

-- COMMUNITY subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'COMM_CHURCH', 'Church', category_id, 2, FALSE FROM categories WHERE category_code = 'COMMUNITY';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'COMM_CHARITY', 'Charities', category_id, 2, FALSE FROM categories WHERE category_code = 'COMMUNITY';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'COMM_GIFTS', 'Gifts & Donations', category_id, 2, FALSE FROM categories WHERE category_code = 'COMMUNITY';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'COMM_YOUTH', 'Youth Sponsorships', category_id, 2, FALSE FROM categories WHERE category_code = 'COMMUNITY';

-- ENTERTAINMENT subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'ENT_EVENTS', 'Events & Tickets', category_id, 2, FALSE FROM categories WHERE category_code = 'ENTERTAINMENT';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'ENT_MEDIA', 'Streaming & Media', category_id, 2, TRUE FROM categories WHERE category_code = 'ENTERTAINMENT';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'ENT_RECREATION', 'Recreation', category_id, 2, FALSE FROM categories WHERE category_code = 'ENTERTAINMENT';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'ENT_HOBBIES', 'Hobbies', category_id, 2, FALSE FROM categories WHERE category_code = 'ENTERTAINMENT';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'ENT_SOCIAL', 'Hanging Out', category_id, 2, FALSE FROM categories WHERE category_code = 'ENTERTAINMENT';

-- TRAVEL subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'TRAVEL_FLIGHTS', 'Flights & Tickets', category_id, 2, FALSE FROM categories WHERE category_code = 'TRAVEL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'TRAVEL_HOTELS', 'Hotels & Lodging', category_id, 2, FALSE FROM categories WHERE category_code = 'TRAVEL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'TRAVEL_CRUISES', 'Cruises', category_id, 2, FALSE FROM categories WHERE category_code = 'TRAVEL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'TRAVEL_GROUND', 'Ground Transportation', category_id, 2, FALSE FROM categories WHERE category_code = 'TRAVEL';

-- SHOPPING subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'SHOP_ELECTRONICS', 'Electronics', category_id, 2, FALSE FROM categories WHERE category_code = 'SHOPPING';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'SHOP_HOUSEHOLD', 'Household Items', category_id, 2, FALSE FROM categories WHERE category_code = 'SHOPPING';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'SHOP_AMAZON', 'Amazon', category_id, 2, FALSE FROM categories WHERE category_code = 'SHOPPING';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'SHOP_GENERAL', 'General Retail', category_id, 2, FALSE FROM categories WHERE category_code = 'SHOPPING';

-- SUBSCRIPTIONS subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'SUB_STREAMING', 'Streaming Services', category_id, 2, TRUE FROM categories WHERE category_code = 'SUBSCRIPTIONS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'SUB_SOFTWARE', 'Software/Apps', category_id, 2, TRUE FROM categories WHERE category_code = 'SUBSCRIPTIONS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'SUB_NEWS', 'News/Publications', category_id, 2, TRUE FROM categories WHERE category_code = 'SUBSCRIPTIONS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'SUB_CLUBS', 'Club Memberships', category_id, 2, TRUE FROM categories WHERE category_code = 'SUBSCRIPTIONS';

-- FINANCIAL subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FIN_AUTOLOAN', 'Auto Loan', category_id, 2, TRUE FROM categories WHERE category_code = 'FINANCIAL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FIN_PERSONALLOAN', 'Personal Loans', category_id, 2, TRUE FROM categories WHERE category_code = 'FINANCIAL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FIN_CCPAYOFF', 'CC Payoff', category_id, 2, FALSE FROM categories WHERE category_code = 'FINANCIAL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FIN_INVESTMENT', 'Savings & Investments', category_id, 2, FALSE FROM categories WHERE category_code = 'FINANCIAL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FIN_TAX_FED', 'Federal Tax', category_id, 2, FALSE FROM categories WHERE category_code = 'FINANCIAL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FIN_TAX_STATE', 'State Tax', category_id, 2, FALSE FROM categories WHERE category_code = 'FINANCIAL';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'FIN_TAX_LOCAL', 'Local Tax', category_id, 2, FALSE FROM categories WHERE category_code = 'FINANCIAL';

-- TRANSFERS subcategories
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'XFER_CC', 'To Credit Card', category_id, 2, FALSE FROM categories WHERE category_code = 'TRANSFERS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'XFER_INVEST', 'To Investment', category_id, 2, FALSE FROM categories WHERE category_code = 'TRANSFERS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'XFER_INTERNAL', 'Between Accounts', category_id, 2, FALSE FROM categories WHERE category_code = 'TRANSFERS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'XFER_ATM', 'ATM Withdrawal', category_id, 2, FALSE FROM categories WHERE category_code = 'TRANSFERS';
INSERT INTO categories (category_code, category_name, parent_category_id, category_level, is_bill) 
SELECT 'XFER_P2P', 'Zelle/P2P', category_id, 2, FALSE FROM categories WHERE category_code = 'TRANSFERS';

-- ============================================================
-- Account Seed Data
-- ============================================================

INSERT INTO accounts (account_code, account_name, institution, account_type) VALUES
('boa_billing', 'BOA Billing Checking', 'Bank of America', 'checking'),
('boa_spending', 'BOA Spending Checking', 'Bank of America', 'checking'),
('boa_cc', 'BOA Credit Card', 'Bank of America', 'credit_card'),
('chase_cc', 'Chase Sapphire', 'Chase', 'credit_card'),
('betterment', 'Betterment Investment', 'Betterment', 'investment');
