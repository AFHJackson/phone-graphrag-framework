LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Count PARENT_OF edges
SELECT * FROM cypher('family_budget', $$
    MATCH ()-[r:PARENT_OF]->()
    RETURN count(r)
$$) AS (cnt agtype);

-- Show some parent-child
SELECT * FROM cypher('family_budget', $$
    MATCH (p:Category)-[r:PARENT_OF]->(c:Category)
    RETURN p.category_id, c.category_id
    LIMIT 5
$$) AS (parent_id agtype, child_id agtype);
