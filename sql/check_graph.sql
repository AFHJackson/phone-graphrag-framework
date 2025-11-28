-- Check graph status
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Count nodes by type
SELECT * FROM cypher('family_budget', $$
    MATCH (n)
    RETURN labels(n)[0] AS node_type, count(*) AS node_count
$$) AS (node_type agtype, node_count agtype);

-- Count edges by type
SELECT * FROM cypher('family_budget', $$
    MATCH ()-[r]->()
    RETURN type(r) AS edge_type, count(*) AS edge_count
$$) AS (edge_type agtype, edge_count agtype);

-- Sample: Get 5 transactions with their accounts and categories
SELECT * FROM cypher('family_budget', $$
    MATCH (t:Transaction)-[:FROM_ACCOUNT]->(a:Account),
          (t)-[:IN_CATEGORY]->(c:Category)
    RETURN t.description, t.amount, a.account_name, c.category_name
    LIMIT 5
$$) AS (description agtype, amount agtype, account agtype, category agtype);
