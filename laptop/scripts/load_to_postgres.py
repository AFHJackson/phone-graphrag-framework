#!/usr/bin/env python3
"""
Load GraphRAG phone results into PostgreSQL + Apache AGE database.

Usage:
    python load_to_postgres.py --input results.json
    python load_to_postgres.py --input results.json --job-name "Budget Analysis"
"""

import json
import argparse
from pathlib import Path
from datetime import datetime
import os

try:
    import psycopg2
    from psycopg2.extras import Json
except ImportError:
    print("Missing psycopg2. Run: pip install psycopg2-binary")
    exit(1)


def get_connection():
    """Get database connection from environment or defaults."""
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        database=os.getenv("PGDATABASE", "knowledge_base"),
        user=os.getenv("PGUSER", "graphrag"),
        password=os.getenv("PGPASSWORD", "graphrag_secure_password")
    )


def escape_cypher_string(s: str) -> str:
    """Escape a string for use in Cypher queries."""
    if s is None:
        return ""
    return s.replace("\\", "\\\\").replace("'", "''").replace('"', '\\"')


def load_results(results_path: Path, job_name: str = None):
    """Load results JSON into PostgreSQL + AGE database."""
    
    with open(results_path, 'r', encoding='utf-8') as f:
        results = json.load(f)
    
    conn = get_connection()
    cur = conn.cursor()
    
    try:
        # Load AGE extension
        cur.execute("LOAD 'age'")
        cur.execute('SET search_path = ag_catalog, "$user", public')
        
        job_id = results.get('jobId', f"job_{datetime.now().strftime('%Y%m%d_%H%M%S')}")
        total_chunks = results.get('totalChunks', 0)
        processed_chunks = results.get('processedChunks', 0)
        
        print(f"Loading job: {job_id}")
        print(f"Total chunks: {total_chunks}")
        
        # Insert or update job record
        cur.execute("""
            INSERT INTO processing_jobs (job_id, total_chunks, processed_chunks, source_file, status)
            VALUES (%s, %s, %s, %s, 'LOADING')
            ON CONFLICT (job_id) DO UPDATE SET
                processed_chunks = EXCLUDED.processed_chunks,
                status = 'LOADING'
            RETURNING id
        """, (job_id, total_chunks, processed_chunks, str(results_path)))
        
        job_uuid = cur.fetchone()[0]
        
        # Counters
        entity_count = 0
        relationship_count = 0
        success_count = 0
        failed_count = 0
        skipped_count = 0
        
        # Process each chunk result
        for chunk_result in results.get('results', []):
            chunk_id = chunk_result.get('chunkId', 'unknown')
            status = chunk_result.get('status', 'UNKNOWN')
            
            if status == 'SUCCESS':
                success_count += 1
            elif status == 'FAILED':
                failed_count += 1
            elif status == 'SKIPPED':
                skipped_count += 1
            
            # Insert raw chunk result
            cur.execute("""
                INSERT INTO chunk_results (
                    job_id, chunk_id, entities, relationships,
                    processing_time_ms, status, error_message
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (job_id, chunk_id) DO UPDATE SET
                    entities = EXCLUDED.entities,
                    relationships = EXCLUDED.relationships,
                    processing_time_ms = EXCLUDED.processing_time_ms,
                    status = EXCLUDED.status,
                    error_message = EXCLUDED.error_message
            """, (
                job_id,
                chunk_id,
                Json(chunk_result.get('entities', [])),
                Json(chunk_result.get('relationships', [])),
                chunk_result.get('processingTimeMs', 0),
                status,
                chunk_result.get('errorMessage')
            ))
            
            # Insert entities into graph
            for entity in chunk_result.get('entities', []):
                entity_name = escape_cypher_string(entity.get('name', ''))
                entity_type = escape_cypher_string(entity.get('type', 'OTHER'))
                description = escape_cypher_string(entity.get('description', ''))
                
                if not entity_name:
                    continue
                
                try:
                    cur.execute(f"""
                        SELECT * FROM cypher('knowledge_graph', $$
                            MERGE (e:Entity {{name: '{entity_name}'}})
                            ON CREATE SET 
                                e.type = '{entity_type}',
                                e.description = '{description}',
                                e.source_chunk = '{chunk_id}',
                                e.job_id = '{job_id}'
                            RETURN e
                        $$) AS (e agtype)
                    """)
                    entity_count += 1
                except Exception as e:
                    print(f"  Warning: Failed to insert entity '{entity_name}': {e}")
            
            # Insert relationships into graph
            for rel in chunk_result.get('relationships', []):
                source = escape_cypher_string(rel.get('source', ''))
                target = escape_cypher_string(rel.get('target', ''))
                rel_type = escape_cypher_string(rel.get('type', 'RELATES_TO'))
                description = escape_cypher_string(rel.get('description', ''))
                
                if not source or not target:
                    continue
                
                try:
                    cur.execute(f"""
                        SELECT * FROM cypher('knowledge_graph', $$
                            MATCH (s:Entity {{name: '{source}'}}), 
                                  (t:Entity {{name: '{target}'}})
                            MERGE (s)-[r:RELATES_TO {{type: '{rel_type}'}}]->(t)
                            ON CREATE SET 
                                r.description = '{description}',
                                r.source_chunk = '{chunk_id}',
                                r.job_id = '{job_id}'
                            RETURN r
                        $$) AS (r agtype)
                    """)
                    relationship_count += 1
                except Exception as e:
                    print(f"  Warning: Failed to insert relationship {source}->{target}: {e}")
        
        # Update job status
        cur.execute("""
            UPDATE processing_jobs SET
                status = 'COMPLETED',
                completed_at = CURRENT_TIMESTAMP,
                successful_chunks = %s,
                failed_chunks = %s,
                skipped_chunks = %s
            WHERE job_id = %s
        """, (success_count, failed_count, skipped_count, job_id))
        
        conn.commit()
        
        print()
        print("✅ Load complete!")
        print(f"   Entities created: {entity_count}")
        print(f"   Relationships created: {relationship_count}")
        print(f"   Chunks: {success_count} success, {failed_count} failed, {skipped_count} skipped")
        
    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        cur.close()
        conn.close()


def main():
    parser = argparse.ArgumentParser(description='Load GraphRAG results into PostgreSQL')
    parser.add_argument('--input', '-i', required=True, help='Path to results.json')
    parser.add_argument('--job-name', help='Optional job name')
    
    args = parser.parse_args()
    
    results_path = Path(args.input)
    if not results_path.exists():
        print(f"Error: File not found: {results_path}")
        exit(1)
    
    load_results(results_path, args.job_name)


if __name__ == '__main__':
    main()
