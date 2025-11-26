-- Phone GraphRAG Framework - Initial Schema Setup
-- Run this first to set up the database

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS age;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Load AGE
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Processing jobs table (relational)
CREATE TABLE IF NOT EXISTS processing_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id TEXT UNIQUE NOT NULL,
    total_chunks INTEGER NOT NULL,
    processed_chunks INTEGER DEFAULT 0,
    successful_chunks INTEGER DEFAULT 0,
    failed_chunks INTEGER DEFAULT 0,
    skipped_chunks INTEGER DEFAULT 0,
    status TEXT DEFAULT 'PENDING',
    source_file TEXT,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    error_log TEXT,
    metadata JSONB
);

-- Raw chunk results table (JSON storage for debugging/audit)
CREATE TABLE IF NOT EXISTS chunk_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id TEXT REFERENCES processing_jobs(job_id),
    chunk_id TEXT NOT NULL,
    entities JSONB,
    relationships JSONB,
    processing_time_ms INTEGER,
    status TEXT,
    error_message TEXT,
    raw_response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(job_id, chunk_id)
);

-- Source documents table
CREATE TABLE IF NOT EXISTS source_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    filename TEXT NOT NULL,
    filepath TEXT,
    doc_type TEXT,
    chunk_count INTEGER,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_chunk_results_job ON chunk_results(job_id);
CREATE INDEX IF NOT EXISTS idx_chunk_results_status ON chunk_results(status);
CREATE INDEX IF NOT EXISTS idx_chunk_results_entities ON chunk_results USING gin(entities);
CREATE INDEX IF NOT EXISTS idx_processing_jobs_status ON processing_jobs(status);

-- Comment the schema
COMMENT ON TABLE processing_jobs IS 'Tracks GraphRAG processing jobs from phone';
COMMENT ON TABLE chunk_results IS 'Raw results from entity extraction per chunk';
COMMENT ON TABLE source_documents IS 'Source documents that were chunked and processed';

-- Verify setup
DO $$
BEGIN
    RAISE NOTICE 'Schema setup complete!';
    RAISE NOTICE 'Tables created: processing_jobs, chunk_results, source_documents';
END $$;
