# Database Setup Guide

## Overview

This guide covers setting up PostgreSQL with Apache AGE extension for storing and querying knowledge graphs created by the Phone GraphRAG Framework.

## Stack Overview

| Component | Version | Purpose |
|-----------|---------|---------|
| PostgreSQL | 15+ | Relational database foundation |
| Apache AGE | 1.4+ | Graph database extension (Cypher support) |
| Docker | 24+ | Container orchestration |
| Python | 3.10+ | Database interaction scripts |

## Quick Start with Docker

### docker-compose.yml
```yaml
version: '3.8'

services:
  postgres-age:
    image: apache/age:latest
    container_name: graphrag-db
    environment:
      POSTGRES_USER: graphrag
      POSTGRES_PASSWORD: graphrag_secure_password
      POSTGRES_DB: knowledge_base
    ports:
      - "5432:5432"
    volumes:
      - graphrag_data:/var/lib/postgresql/data
      - ./sql:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U graphrag -d knowledge_base"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  graphrag_data:
```

### Start the Database
```powershell
cd laptop
docker-compose up -d

# Verify running
docker ps | Select-String "graphrag-db"

# Check logs
docker logs graphrag-db
```

## Manual Installation (Without Docker)

### Install PostgreSQL
```bash
# Ubuntu/Debian
sudo apt install postgresql-15 postgresql-contrib

# macOS
brew install postgresql@15

# Windows - Download from postgresql.org
```

### Install Apache AGE
```bash
# Build from source
git clone https://github.com/apache/age.git
cd age
make
sudo make install

# Add to shared_preload_libraries in postgresql.conf:
# shared_preload_libraries = 'age'
```

## Database Schema

### Initial Setup
```sql
-- Enable AGE extension
CREATE EXTENSION IF NOT EXISTS age;
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Create knowledge graph
SELECT create_graph('knowledge_graph');
```

### Create Vertex Labels
```sql
-- Entity vertex (from phone extraction)
SELECT create_vlabel('knowledge_graph', 'Entity');
-- Properties: name, type, description, source_chunk

-- Document vertex (source documents)  
SELECT create_vlabel('knowledge_graph', 'Document');
-- Properties: filename, filepath, doc_type, created_at

-- Chunk vertex (text chunks)
SELECT create_vlabel('knowledge_graph', 'Chunk');
-- Properties: chunk_id, content, page, section
```

### Create Edge Labels
```sql
-- Relationships from entity extraction
SELECT create_elabel('knowledge_graph', 'RELATES_TO');
-- Properties: type, description, confidence

-- Document structure relationships
SELECT create_elabel('knowledge_graph', 'EXTRACTED_FROM');
-- Properties: extraction_time

SELECT create_elabel('knowledge_graph', 'MENTIONS');
-- Properties: count, positions

SELECT create_elabel('knowledge_graph', 'PART_OF');
-- Properties: page, section
```

### Supporting Tables (Relational)
```sql
-- Processing jobs table
CREATE TABLE IF NOT EXISTS processing_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id TEXT UNIQUE NOT NULL,
    total_chunks INTEGER NOT NULL,
    processed_chunks INTEGER DEFAULT 0,
    successful_chunks INTEGER DEFAULT 0,
    failed_chunks INTEGER DEFAULT 0,
    status TEXT DEFAULT 'PENDING',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    error_log TEXT
);

-- Raw results table (JSON storage)
CREATE TABLE IF NOT EXISTS chunk_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id TEXT REFERENCES processing_jobs(job_id),
    chunk_id TEXT NOT NULL,
    entities JSONB,
    relationships JSONB,
    processing_time_ms INTEGER,
    status TEXT,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast lookup
CREATE INDEX idx_chunk_results_job ON chunk_results(job_id);
CREATE INDEX idx_chunk_results_status ON chunk_results(status);
```

## Loading Data from Phone Results

### Python Script: load_to_postgres.py
```python
#!/usr/bin/env python3
"""
Load GraphRAG phone results into PostgreSQL + AGE database.
"""

import json
import psycopg2
from psycopg2.extras import execute_values
import argparse
from pathlib import Path

def connect_db():
    """Connect to PostgreSQL database."""
    return psycopg2.connect(
        host="localhost",
        port=5432,
        database="knowledge_base",
        user="graphrag",
        password="graphrag_secure_password"
    )

def load_results(results_file: Path, conn):
    """Load results JSON into database."""
    with open(results_file, 'r') as f:
        results = json.load(f)
    
    cur = conn.cursor()
    
    # Load AGE
    cur.execute("LOAD 'age'")
    cur.execute("SET search_path = ag_catalog, \"$user\", public")
    
    job_id = results['jobId']
    
    # Insert job record
    cur.execute("""
        INSERT INTO processing_jobs (job_id, total_chunks, processed_chunks)
        VALUES (%s, %s, %s)
        ON CONFLICT (job_id) DO UPDATE SET processed_chunks = EXCLUDED.processed_chunks
    """, (job_id, results['totalChunks'], results['processedChunks']))
    
    # Process each chunk result
    for chunk_result in results.get('results', []):
        chunk_id = chunk_result['chunkId']
        
        # Insert raw result
        cur.execute("""
            INSERT INTO chunk_results (job_id, chunk_id, entities, relationships, 
                                       processing_time_ms, status, error_message)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            job_id,
            chunk_id,
            json.dumps(chunk_result.get('entities', [])),
            json.dumps(chunk_result.get('relationships', [])),
            chunk_result.get('processingTimeMs', 0),
            chunk_result.get('status', 'UNKNOWN'),
            chunk_result.get('errorMessage')
        ))
        
        # Insert entities into graph
        for entity in chunk_result.get('entities', []):
            entity_name = entity['name'].replace("'", "''")
            entity_type = entity.get('type', 'OTHER')
            description = (entity.get('description') or '').replace("'", "''")
            
            cur.execute(f"""
                SELECT * FROM cypher('knowledge_graph', $$
                    MERGE (e:Entity {{name: '{entity_name}'}})
                    ON CREATE SET e.type = '{entity_type}',
                                  e.description = '{description}',
                                  e.source_chunk = '{chunk_id}'
                    RETURN e
                $$) AS (e agtype)
            """)
        
        # Insert relationships into graph
        for rel in chunk_result.get('relationships', []):
            source = rel['source'].replace("'", "''")
            target = rel['target'].replace("'", "''")
            rel_type = rel.get('type', 'RELATES_TO')
            description = (rel.get('description') or '').replace("'", "''")
            
            cur.execute(f"""
                SELECT * FROM cypher('knowledge_graph', $$
                    MATCH (s:Entity {{name: '{source}'}}), 
                          (t:Entity {{name: '{target}'}})
                    MERGE (s)-[r:RELATES_TO {{type: '{rel_type}'}}]->(t)
                    ON CREATE SET r.description = '{description}',
                                  r.source_chunk = '{chunk_id}'
                    RETURN r
                $$) AS (r agtype)
            """)
    
    # Update job status
    cur.execute("""
        UPDATE processing_jobs 
        SET status = 'COMPLETED', 
            completed_at = CURRENT_TIMESTAMP,
            successful_chunks = (SELECT COUNT(*) FROM chunk_results 
                                WHERE job_id = %s AND status = 'SUCCESS')
        WHERE job_id = %s
    """, (job_id, job_id))
    
    conn.commit()
    print(f"✅ Loaded {len(results.get('results', []))} chunks into database")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="Path to results.json")
    args = parser.parse_args()
    
    conn = connect_db()
    try:
        load_results(Path(args.input), conn)
    finally:
        conn.close()
```

## Querying the Knowledge Graph

### Cypher Queries via AGE
```sql
-- Load AGE
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Find all entities
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)
    RETURN e.name, e.type
    ORDER BY e.type, e.name
$$) AS (name agtype, type agtype);

-- Find relationships between entities
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (s:Entity)-[r:RELATES_TO]->(t:Entity)
    RETURN s.name, r.type, t.name
    LIMIT 100
$$) AS (source agtype, relationship agtype, target agtype);

-- Find all entities related to a specific entity
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity {name: 'Department of Transportation'})-[r]-(connected:Entity)
    RETURN connected.name, type(r), r.type
$$) AS (connected_name agtype, edge_label agtype, relationship_type agtype);

-- Find funding relationships
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (funder:Entity)-[r:RELATES_TO {type: 'FUNDS'}]->(funded:Entity)
    RETURN funder.name, r.description, funded.name
$$) AS (funder agtype, description agtype, funded agtype);

-- Path finding (2 hops)
SELECT * FROM cypher('knowledge_graph', $$
    MATCH path = (start:Entity {name: 'City Council'})-[*1..2]-(end:Entity)
    RETURN nodes(path), relationships(path)
    LIMIT 20
$$) AS (nodes agtype, relationships agtype);
```

### Statistics Queries
```sql
-- Entity counts by type
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)
    RETURN e.type, count(e) as count
    ORDER BY count DESC
$$) AS (type agtype, count agtype);

-- Relationship counts
SELECT * FROM cypher('knowledge_graph', $$
    MATCH ()-[r:RELATES_TO]->()
    RETURN r.type, count(r) as count
    ORDER BY count DESC
$$) AS (type agtype, count agtype);

-- Most connected entities
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)-[r]-(other)
    RETURN e.name, e.type, count(r) as connections
    ORDER BY connections DESC
    LIMIT 20
$$) AS (name agtype, type agtype, connections agtype);
```

## Backup and Restore

### Backup
```bash
# Full database dump
docker exec graphrag-db pg_dump -U graphrag knowledge_base > backup.sql

# Just the graph
docker exec graphrag-db psql -U graphrag -d knowledge_base -c \
  "SELECT * FROM ag_catalog.ag_dump('knowledge_graph')" > graph_backup.sql
```

### Restore
```bash
# Restore full database
docker exec -i graphrag-db psql -U graphrag -d knowledge_base < backup.sql
```

## Performance Optimization

### Indexes for Common Queries
```sql
-- Text search on entity names
CREATE INDEX idx_entity_name ON ag_catalog.knowledge_graph_entity USING gin (properties);

-- Entity type filtering
CREATE INDEX idx_chunk_results_entities ON chunk_results USING gin (entities);
```

### Connection Pooling
For production, use PgBouncer:
```yaml
# Add to docker-compose.yml
pgbouncer:
  image: edoburu/pgbouncer
  environment:
    DATABASE_URL: postgres://graphrag:password@postgres-age:5432/knowledge_base
    POOL_MODE: transaction
  ports:
    - "6432:5432"
```

## Python Requirements

```
# requirements.txt
psycopg2-binary>=2.9.9
python-dotenv>=1.0.0
```
