-- Family Budget GraphRAG - Useful Graph Queries
-- These queries demonstrate the power of graph traversal for financial analysis

LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- ============================================================
-- 1. CATEGORY HIERARCHY TRAVERSAL
-- ============================================================

-- Show category tree (parent -> child relationships)
SELECT * FROM cypher('family_budget', $$
    MATCH (parent:Category)-[:PARENT_OF]->(child:Category)
    RETURN parent.category_name AS parent, child.category_name AS child
    ORDER BY parent.category_name
$$) AS (parent agtype, child agtype);


-- ============================================================
-- 2. ACCOUNT ANALYSIS
-- ============================================================

-- Transactions per account
SELECT * FROM cypher('family_budget', $$
    MATCH (t:Transaction)-[:FROM_ACCOUNT]->(a:Account)
    WITH a, count(t) AS txn_count, sum(t.amount) AS total
    RETURN a.account_name, txn_count, total
$$) AS (account agtype, txn_count agtype, total agtype);


-- ============================================================
-- 3. VENDOR ANALYSIS  
-- ============================================================

-- Find all transactions to a specific vendor (e.g., AMAZON)
SELECT * FROM cypher('family_budget', $$
    MATCH (t:Transaction)-[:TO_VENDOR]->(v:Vendor)
    WHERE v.name =~ '.*AMAZON.*'
    RETURN v.name, t.date, t.amount
    LIMIT 20
$$) AS (vendor agtype, txn_date agtype, amount agtype);


-- ============================================================
-- 4. SPENDING PATH QUERIES
-- ============================================================

-- Full path: Account -> Transaction -> Category -> Parent Category
SELECT * FROM cypher('family_budget', $$
    MATCH (a:Account)<-[:FROM_ACCOUNT]-(t:Transaction)-[:IN_CATEGORY]->(c:Category)
    OPTIONAL MATCH (p:Category)-[:PARENT_OF]->(c)
    WHERE t.amount < 0
    RETURN a.account_name, t.description, t.amount, c.category_name, p.category_name
    LIMIT 10
$$) AS (account agtype, description agtype, amount agtype, category agtype, parent_category agtype);


-- ============================================================
-- 5. TRANSFER DETECTION
-- ============================================================

-- Find transfer transactions (money moving between accounts)
SELECT * FROM cypher('family_budget', $$
    MATCH (t:Transaction)-[:FROM_ACCOUNT]->(a:Account)
    WHERE t.is_transfer = true
    RETURN a.account_name, t.description, t.amount, t.date
    LIMIT 20
$$) AS (account agtype, description agtype, amount agtype, txn_date agtype);


-- ============================================================
-- 6. CROSS-REFERENCE QUERIES
-- ============================================================

-- Find which accounts fund which categories
SELECT * FROM cypher('family_budget', $$
    MATCH (a:Account)<-[:FROM_ACCOUNT]-(t:Transaction)-[:IN_CATEGORY]->(c:Category)
    WHERE t.amount < 0 AND c.level = 1
    WITH a, c, count(t) AS txn_count
    RETURN a.account_name, c.category_name, txn_count
    ORDER BY txn_count DESC
    LIMIT 20
$$) AS (account agtype, category agtype, txn_count agtype);


-- ============================================================
-- 7. VENDOR-CATEGORY CORRELATION
-- ============================================================

-- Which vendors appear in which categories?
SELECT * FROM cypher('family_budget', $$
    MATCH (t:Transaction)-[:TO_VENDOR]->(v:Vendor),
          (t)-[:IN_CATEGORY]->(c:Category)
    WITH v, c, count(t) AS txn_count
    RETURN v.name, c.category_name, txn_count
    ORDER BY txn_count DESC
    LIMIT 20
$$) AS (vendor agtype, category agtype, txn_count agtype);
