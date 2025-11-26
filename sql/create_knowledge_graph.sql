-- Phone GraphRAG Framework - Knowledge Graph Schema
-- Run after create_schema.sql

-- Load AGE (required in every session)
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Create the main knowledge graph
SELECT create_graph('knowledge_graph');

-- Create vertex labels for entities
SELECT create_vlabel('knowledge_graph', 'Entity');
-- Properties: name (required), type, description, source_chunk, confidence

SELECT create_vlabel('knowledge_graph', 'Document');
-- Properties: filename, filepath, doc_type, created_at

SELECT create_vlabel('knowledge_graph', 'Chunk');
-- Properties: chunk_id, content_preview, page, section

-- Create edge labels for relationships
SELECT create_elabel('knowledge_graph', 'RELATES_TO');
-- Properties: type (FUNDS, MANAGES, etc.), description, confidence, source_chunk

SELECT create_elabel('knowledge_graph', 'EXTRACTED_FROM');
-- Properties: extraction_time, processor_version

SELECT create_elabel('knowledge_graph', 'MENTIONS');
-- Properties: count, positions

SELECT create_elabel('knowledge_graph', 'PART_OF');
-- Properties: page, section, order

-- Create indexes for performance
-- Note: AGE automatically creates indexes on vertex/edge labels

-- Verify graph creation
DO $$
DECLARE
    graph_exists boolean;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM ag_catalog.ag_graph WHERE name = 'knowledge_graph'
    ) INTO graph_exists;
    
    IF graph_exists THEN
        RAISE NOTICE 'Knowledge graph created successfully!';
    ELSE
        RAISE EXCEPTION 'Failed to create knowledge graph';
    END IF;
END $$;

-- Show graph info
SELECT * FROM ag_catalog.ag_graph WHERE name = 'knowledge_graph';
SELECT * FROM ag_catalog.ag_label WHERE graph = (
    SELECT graphid FROM ag_catalog.ag_graph WHERE name = 'knowledge_graph'
);
