-- Phone GraphRAG Framework - Common Graph Queries
-- Load AGE first: LOAD 'age'; SET search_path = ag_catalog, "$user", public;

-- ============================================
-- BASIC ENTITY QUERIES
-- ============================================

-- Count all entities
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)
    RETURN count(e) as total_entities
$$) AS (total_entities agtype);

-- List all entities with their types
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)
    RETURN e.name, e.type, e.description
    ORDER BY e.type, e.name
$$) AS (name agtype, type agtype, description agtype);

-- Count entities by type
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)
    RETURN e.type, count(e) as count
    ORDER BY count DESC
$$) AS (type agtype, count agtype);

-- Find specific entity by name (case-insensitive)
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)
    WHERE toLower(e.name) CONTAINS 'transportation'
    RETURN e.name, e.type, e.description
$$) AS (name agtype, type agtype, description agtype);

-- ============================================
-- RELATIONSHIP QUERIES
-- ============================================

-- Count all relationships
SELECT * FROM cypher('knowledge_graph', $$
    MATCH ()-[r]->()
    RETURN count(r) as total_relationships
$$) AS (total_relationships agtype);

-- List all relationships with types
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (s:Entity)-[r:RELATES_TO]->(t:Entity)
    RETURN s.name, r.type, t.name, r.description
    ORDER BY r.type
$$) AS (source agtype, rel_type agtype, target agtype, description agtype);

-- Count relationships by type
SELECT * FROM cypher('knowledge_graph', $$
    MATCH ()-[r:RELATES_TO]->()
    RETURN r.type, count(r) as count
    ORDER BY count DESC
$$) AS (type agtype, count agtype);

-- Find funding relationships
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (funder:Entity)-[r:RELATES_TO {type: 'FUNDS'}]->(funded:Entity)
    RETURN funder.name, funder.type, funded.name, funded.type, r.description
$$) AS (funder_name agtype, funder_type agtype, funded_name agtype, funded_type agtype, description agtype);

-- Find management relationships
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (manager:Entity)-[r:RELATES_TO {type: 'MANAGES'}]->(managed:Entity)
    RETURN manager.name, managed.name, r.description
$$) AS (manager agtype, managed agtype, description agtype);

-- ============================================
-- CONNECTIVITY QUERIES
-- ============================================

-- Most connected entities (by relationship count)
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)-[r]-(other)
    RETURN e.name, e.type, count(r) as connections
    ORDER BY connections DESC
    LIMIT 20
$$) AS (name agtype, type agtype, connections agtype);

-- Find all entities connected to a specific entity
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity {name: 'Department of Transportation'})-[r]-(connected:Entity)
    RETURN connected.name, connected.type, type(r), r.type
$$) AS (name agtype, type agtype, edge_label agtype, rel_type agtype);

-- Find entities with no relationships (orphans)
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)
    WHERE NOT (e)-[]-()
    RETURN e.name, e.type
$$) AS (name agtype, type agtype);

-- ============================================
-- PATH QUERIES
-- ============================================

-- Find shortest path between two entities
SELECT * FROM cypher('knowledge_graph', $$
    MATCH path = shortestPath(
        (start:Entity {name: 'City Council'})-[*]-(end:Entity {name: 'Parks Department'})
    )
    RETURN path
$$) AS (path agtype);

-- Find all paths up to 3 hops from an entity
SELECT * FROM cypher('knowledge_graph', $$
    MATCH path = (start:Entity {name: 'City Council'})-[*1..3]-(end:Entity)
    RETURN nodes(path), relationships(path)
    LIMIT 50
$$) AS (nodes agtype, relationships agtype);

-- ============================================
-- AGGREGATION QUERIES
-- ============================================

-- Organizations and their total funding relationships
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (org:Entity {type: 'ORGANIZATION'})-[r:RELATES_TO {type: 'FUNDS'}]->(recipient)
    RETURN org.name, count(recipient) as funding_count
    ORDER BY funding_count DESC
$$) AS (organization agtype, funding_count agtype);

-- Entities by source chunk
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)
    RETURN e.source_chunk, count(e) as entity_count
    ORDER BY entity_count DESC
$$) AS (source_chunk agtype, entity_count agtype);

-- ============================================
-- DATA QUALITY QUERIES
-- ============================================

-- Entities with missing types
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)
    WHERE e.type IS NULL OR e.type = 'OTHER'
    RETURN e.name, e.type
$$) AS (name agtype, type agtype);

-- Duplicate entity names
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e1:Entity), (e2:Entity)
    WHERE e1.name = e2.name AND id(e1) < id(e2)
    RETURN e1.name, count(*) + 1 as occurrences
$$) AS (name agtype, occurrences agtype);

-- Self-referential relationships (potential errors)
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)-[r:RELATES_TO]->(e)
    RETURN e.name, r.type, r.description
$$) AS (name agtype, rel_type agtype, description agtype);
