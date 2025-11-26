# Phone GraphRAG Framework - SQL Scripts

This directory contains PostgreSQL + Apache AGE SQL scripts for the knowledge graph database.

## Files

| File | Purpose |
|------|---------|
| `create_schema.sql` | Initial database and extension setup |
| `create_knowledge_graph.sql` | Graph schema with vertex and edge labels |
| `graph_queries.sql` | Common Cypher queries for exploration |

## Usage

```bash
# Run all setup scripts
docker exec -i graphrag-db psql -U graphrag -d knowledge_base < create_schema.sql
docker exec -i graphrag-db psql -U graphrag -d knowledge_base < create_knowledge_graph.sql
```

## AGE Notes

Apache AGE requires explicit loading in each session:
```sql
LOAD 'age';
SET search_path = ag_catalog, "$user", public;
```
