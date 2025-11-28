-- ============================================================
-- Family Budget GraphRAG Database Schema
-- PostgreSQL + Apache AGE + pgvector
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS age;
CREATE EXTENSION IF NOT EXISTS vector;

-- Load Apache AGE (for graph queries later)
LOAD 'age';

-- ============================================================
-- RELATIONAL TABLES (Source of Truth) - in public schema
-- ============================================================

-- Accounts (checking, credit cards, investment)
CREATE TABLE IF NOT EXISTS accounts (
    account_id SERIAL PRIMARY KEY,
    account_code VARCHAR(50) UNIQUE NOT NULL,  -- 'boa_billing', 'chase_cc', etc.
    account_name VARCHAR(200) NOT NULL,
    institution VARCHAR(100),
    account_type VARCHAR(50) NOT NULL,  -- 'checking', 'credit_card', 'investment'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories (hierarchical)
CREATE TABLE IF NOT EXISTS categories (
    category_id SERIAL PRIMARY KEY,
    category_code VARCHAR(100) UNIQUE NOT NULL,
    category_name VARCHAR(200) NOT NULL,
    parent_category_id INTEGER REFERENCES categories(category_id),
    category_level INTEGER DEFAULT 1,  -- 1=top, 2=sub, 3=sub-sub
    is_bill BOOLEAN DEFAULT FALSE,  -- True = recurring/service-level
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vendors (normalized)
CREATE TABLE IF NOT EXISTS vendors (
    vendor_id SERIAL PRIMARY KEY,
    normalized_name VARCHAR(200) UNIQUE NOT NULL,
    display_name VARCHAR(200),
    default_category_id INTEGER REFERENCES categories(category_id),
    vendor_type VARCHAR(50),  -- 'merchant', 'utility', 'government', 'charity', etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transactions (unified from all sources)
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    transaction_date DATE NOT NULL,
    post_date DATE,
    description TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    
    -- Foreign keys
    account_id INTEGER REFERENCES accounts(account_id),
    vendor_id INTEGER REFERENCES vendors(vendor_id),
    category_id INTEGER REFERENCES categories(category_id),
    
    -- Classification
    transaction_type VARCHAR(20) NOT NULL,  -- 'income', 'expense', 'transfer', 'payment', 'refund'
    is_transfer BOOLEAN DEFAULT FALSE,
    transfer_type VARCHAR(50),
    
    -- Linking
    linked_transaction_id VARCHAR(20),  -- For matching transfers
    amazon_order_id VARCHAR(50),        -- For Amazon product details
    
    -- Metadata
    original_category VARCHAR(100),     -- From source (e.g., Chase categories)
    normalized_vendor VARCHAR(200),
    raw_data JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Amazon Orders (product-level detail)
CREATE TABLE IF NOT EXISTS amazon_orders (
    order_item_id SERIAL PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    product_name TEXT,
    asin VARCHAR(20),
    unit_price DECIMAL(10,2),
    quantity INTEGER DEFAULT 1,
    total_owed DECIMAL(10,2),
    order_status VARCHAR(50),
    ship_date DATE,
    
    -- Linking to transaction
    transaction_id VARCHAR(20) REFERENCES transactions(transaction_id),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Priorities (declared family priorities)
CREATE TABLE IF NOT EXISTS priorities (
    priority_id SERIAL PRIMARY KEY,
    priority_name VARCHAR(200) NOT NULL,
    priority_rank INTEGER,  -- 1 = highest priority
    description TEXT,
    target_monthly_amount DECIMAL(10,2),
    target_percentage DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Category-Priority mapping
CREATE TABLE IF NOT EXISTS category_priorities (
    category_id INTEGER REFERENCES categories(category_id),
    priority_id INTEGER REFERENCES priorities(priority_id),
    weight DECIMAL(3,2) DEFAULT 1.0,  -- How much this category contributes to priority
    PRIMARY KEY (category_id, priority_id)
);

-- Monthly Summaries (for trend analysis)
CREATE TABLE IF NOT EXISTS monthly_summaries (
    summary_id SERIAL PRIMARY KEY,
    year_month VARCHAR(7) NOT NULL,  -- '2024-10'
    category_id INTEGER REFERENCES categories(category_id),
    account_id INTEGER REFERENCES accounts(account_id),
    total_amount DECIMAL(12,2),
    transaction_count INTEGER,
    avg_transaction DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year_month, category_id, account_id)
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_account ON transactions(account_id);
CREATE INDEX idx_transactions_category ON transactions(category_id);
CREATE INDEX idx_transactions_vendor ON transactions(vendor_id);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_amazon_orders_order_id ON amazon_orders(order_id);
CREATE INDEX idx_amazon_orders_date ON amazon_orders(order_date);

-- ============================================================
-- APACHE AGE GRAPH SCHEMA
-- ============================================================

-- Create the graph (requires ag_catalog search path)
DO $$
BEGIN
    SET search_path = ag_catalog, "$user", public;
    PERFORM create_graph('family_budget');
EXCEPTION WHEN OTHERS THEN
    -- Graph may already exist, that's OK
    NULL;
END;
$$;

-- ============================================================
-- GRAPH NODE LABELS (Entity Types)
-- ============================================================

-- Account nodes
-- Properties: account_code, account_name, institution, account_type

-- Category nodes  
-- Properties: category_code, category_name, level, is_bill

-- Vendor nodes
-- Properties: normalized_name, display_name, vendor_type

-- Transaction nodes
-- Properties: transaction_id, date, amount, description, type

-- Priority nodes
-- Properties: priority_name, rank, target_amount

-- Month nodes (for time-based traversal)
-- Properties: year_month, year, month

-- ============================================================
-- GRAPH EDGE LABELS (Relationship Types)
-- ============================================================

-- Transaction relationships:
--   (Transaction)-[:FROM_ACCOUNT]->(Account)
--   (Transaction)-[:PAID_TO]->(Vendor)
--   (Transaction)-[:CATEGORIZED_AS]->(Category)
--   (Transaction)-[:IN_MONTH]->(Month)
--   (Transaction)-[:TRANSFERRED_TO]->(Transaction)  -- for transfer matching

-- Category relationships:
--   (Category)-[:SUBCATEGORY_OF]->(Category)
--   (Category)-[:SUPPORTS]->(Priority)

-- Vendor relationships:
--   (Vendor)-[:DEFAULT_CATEGORY]->(Category)

-- Monthly relationships:
--   (Month)-[:FOLLOWS]->(Month)

-- ============================================================
-- VECTOR EMBEDDINGS TABLE (for semantic search)
-- ============================================================

CREATE TABLE IF NOT EXISTS transaction_embeddings (
    transaction_id VARCHAR(20) PRIMARY KEY REFERENCES transactions(transaction_id),
    embedding vector(384),  -- all-MiniLM-L6-v2 dimension
    description_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transaction_embeddings ON transaction_embeddings 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Function to get category hierarchy path
CREATE OR REPLACE FUNCTION get_category_path(cat_id INTEGER)
RETURNS TEXT AS $$
DECLARE
    path TEXT := '';
    current_id INTEGER := cat_id;
    cat_name TEXT;
BEGIN
    WHILE current_id IS NOT NULL LOOP
        SELECT category_name, parent_category_id 
        INTO cat_name, current_id
        FROM categories 
        WHERE category_id = current_id;
        
        IF path = '' THEN
            path := cat_name;
        ELSE
            path := cat_name || ' > ' || path;
        END IF;
    END LOOP;
    RETURN path;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate monthly spending by category
CREATE OR REPLACE FUNCTION get_monthly_spending(year_month_param VARCHAR(7))
RETURNS TABLE(
    category_name VARCHAR(200),
    total_amount DECIMAL(12,2),
    transaction_count BIGINT,
    percentage DECIMAL(5,2)
) AS $$
DECLARE
    total_spend DECIMAL(12,2);
BEGIN
    -- Get total spend for the month
    SELECT COALESCE(SUM(ABS(amount)), 0) INTO total_spend
    FROM transactions
    WHERE TO_CHAR(transaction_date, 'YYYY-MM') = year_month_param
    AND transaction_type = 'expense';
    
    RETURN QUERY
    SELECT 
        c.category_name,
        SUM(ABS(t.amount)) as total_amount,
        COUNT(*) as transaction_count,
        CASE WHEN total_spend > 0 
            THEN ROUND((SUM(ABS(t.amount)) / total_spend * 100)::numeric, 2)
            ELSE 0 
        END as percentage
    FROM transactions t
    JOIN categories c ON t.category_id = c.category_id
    WHERE TO_CHAR(t.transaction_date, 'YYYY-MM') = year_month_param
    AND t.transaction_type = 'expense'
    GROUP BY c.category_id, c.category_name
    ORDER BY total_amount DESC;
END;
$$ LANGUAGE plpgsql;
