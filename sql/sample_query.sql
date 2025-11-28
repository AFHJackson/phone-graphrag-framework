-- Sample graph traversal
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Show some transactions with their categories
SELECT * FROM cypher('family_budget', $$
    MATCH (t:Transaction)-[:IN_CATEGORY]->(c:Category)
    RETURN t.amount, c.category_name
    LIMIT 10
$$) AS (amount agtype, category agtype);
