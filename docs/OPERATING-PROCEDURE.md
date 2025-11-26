# Operating Procedure

## Overview

This document provides step-by-step instructions for processing documents through the Phone GraphRAG Framework.

---

## Pre-Flight Checklist

### Laptop
- [ ] PostgreSQL + AGE container running (`docker ps | grep graphrag`)
- [ ] Python environment activated
- [ ] ADB installed and accessible (`adb version`)
- [ ] USB cable connected

### Phone
- [ ] USB debugging enabled
- [ ] Device authorized (`adb devices` shows "device" not "unauthorized")
- [ ] Model file present (`adb shell ls /data/local/tmp/*.litertlm`)
- [ ] GraphRAG app installed (`adb shell pm list packages | grep graphrag`)
- [ ] Storage directories exist (`adb shell ls /sdcard/graphrag/`)
- [ ] Battery > 50% or plugged in

---

## Phase 1: Document Preparation (Laptop)

### 1.1 Chunk Documents

```powershell
cd C:\Users\afhja\phone-graphrag-framework\laptop

# Activate Python environment
.\venv\Scripts\Activate.ps1

# Run chunker on your documents
python scripts/chunk_documents.py `
    --input "C:\path\to\your\documents\" `
    --output chunks.json `
    --chunk-size 2500 `
    --overlap 200
```

**Expected Output:**
```
Processing: document1.pdf
  → Created 45 chunks
Processing: document2.pdf  
  → Created 32 chunks
Total: 77 chunks written to chunks.json
```

### 1.2 Validate Chunks

```powershell
# Check chunk count and sizes
python scripts/validate_chunks.py --input chunks.json

# Expected:
# Total chunks: 77
# Avg size: 2847 chars
# Min: 534 chars, Max: 3299 chars
# Tabular content: 12 chunks (15%)
```

### 1.3 Push to Phone

```powershell
# Clear previous data
adb shell rm -rf /sdcard/graphrag/input/*
adb shell rm -rf /sdcard/graphrag/output/*
adb shell rm -rf /sdcard/graphrag/progress/*

# Push new chunks
adb push chunks.json /sdcard/graphrag/input/chunks.json

# Verify
adb shell ls -lh /sdcard/graphrag/input/
```

---

## Phase 2: Phone Processing

### 2.1 Launch Processor

```powershell
# Clear logs
adb logcat -c

# Force stop any existing instance
adb shell am force-stop com.graphrag.processor

# Start processing
adb shell am start -n com.graphrag.processor/.MainActivity
```

### 2.2 Monitor Progress

**Option A: Real-time monitoring (recommended)**
```powershell
# Open new terminal
adb logcat -s GraphRAGProcessor:I | ForEach-Object {
    if ($_ -match "Progress: (\d+)%") {
        Write-Progress -Activity "Processing" -PercentComplete $matches[1]
    }
    $_
}
```

**Option B: Periodic check**
```powershell
# Every 30 seconds
while ($true) {
    $checkpoint = adb shell cat /sdcard/graphrag/progress/checkpoint.json 2>$null
    if ($checkpoint) {
        $p = $checkpoint | ConvertFrom-Json
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - $($p.completed)/$($p.total) chunks ($($p.percent)%)"
    }
    Start-Sleep -Seconds 30
}
```

### 2.3 Estimated Time

| Chunks | Estimated Time |
|--------|----------------|
| 10 | 5-10 minutes |
| 50 | 30-45 minutes |
| 100 | 1-1.5 hours |
| 200 | 2-3 hours |

### 2.4 Handle Crashes

If processing stops unexpectedly:

```powershell
# Check if app is still running
adb shell pidof com.graphrag.processor

# If not running, check last logs
adb logcat -d | Select-String "SIGSEGV|SIGABRT|crash" | Select-Object -Last 10

# Restart (will auto-resume from checkpoint)
adb shell am start -n com.graphrag.processor/.MainActivity
```

---

## Phase 3: Result Retrieval (Laptop)

### 3.1 Pull Results

```powershell
# Wait for completion indicator
adb logcat -d | Select-String "Job complete"

# Pull results
adb pull /sdcard/graphrag/output/results.json

# Verify
$results = Get-Content results.json | ConvertFrom-Json
Write-Host "Total chunks: $($results.totalChunks)"
Write-Host "Successful: $($results.results | Where-Object {$_.status -eq 'SUCCESS'} | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Host "Failed: $($results.results | Where-Object {$_.status -eq 'FAILED'} | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Host "Skipped: $($results.results | Where-Object {$_.status -eq 'SKIPPED'} | Measure-Object | Select-Object -ExpandProperty Count)"
```

### 3.2 Quick Validation

```powershell
# Count entities
$entityCount = ($results.results | ForEach-Object { $_.entities.Count } | Measure-Object -Sum).Sum
Write-Host "Total entities extracted: $entityCount"

# Count relationships
$relCount = ($results.results | ForEach-Object { $_.relationships.Count } | Measure-Object -Sum).Sum  
Write-Host "Total relationships extracted: $relCount"

# Average processing time
$avgTime = ($results.results | ForEach-Object { $_.processingTimeMs } | Measure-Object -Average).Average / 1000
Write-Host "Average time per chunk: $([math]::Round($avgTime, 1)) seconds"
```

---

## Phase 4: Database Loading (Laptop)

### 4.1 Load into PostgreSQL

```powershell
# Ensure database is running
docker ps | Select-String "graphrag-db"

# Load results
python scripts/load_to_postgres.py --input results.json

# Expected output:
# Connected to database
# Loading 77 chunks...
# Created 156 entities
# Created 89 relationships
# ✅ Load complete
```

### 4.2 Verify Load

```powershell
# Connect to database
docker exec -it graphrag-db psql -U graphrag -d knowledge_base

# In psql:
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Count entities
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity) RETURN count(e)
$$) AS (count agtype);

-- Count relationships
SELECT * FROM cypher('knowledge_graph', $$
    MATCH ()-[r]->() RETURN count(r)
$$) AS (count agtype);

\q
```

---

## Phase 5: Query & Insights

### 5.1 Basic Queries

```powershell
# Run query script
python scripts/query_insights.py --query "What organizations are mentioned?"
```

### 5.2 Interactive Exploration

```sql
-- Top entities by connection count
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (e:Entity)-[r]-(other)
    RETURN e.name, e.type, count(r) as connections
    ORDER BY connections DESC
    LIMIT 20
$$) AS (name agtype, type agtype, connections agtype);

-- Funding relationships
SELECT * FROM cypher('knowledge_graph', $$
    MATCH (funder)-[r:RELATES_TO {type: 'FUNDS'}]->(funded)
    RETURN funder.name, r.description, funded.name
$$) AS (funder agtype, description agtype, funded agtype);
```

### 5.3 Generate Report

```powershell
python scripts/generate_report.py `
    --output report.md `
    --include-stats `
    --include-top-entities 20 `
    --include-graph-viz
```

---

## Troubleshooting Quick Reference

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| "unauthorized" in adb devices | USB debugging prompt not accepted | Check phone screen, tap "Allow" |
| Model load timeout | Large model, slow storage | Wait 60 seconds, check logs |
| SIGSEGV crash | Problematic chunk content | App auto-restarts, skips bad chunks |
| Progress stuck at X% | App crashed without restart | Manually restart: `adb shell am start -n ...` |
| 0 entities extracted | Prompt issue or parsing failure | Check raw response in debug logs |
| Database connection refused | Container not running | `docker-compose up -d` |

---

## Cleanup

### After Successful Processing
```powershell
# Phone cleanup (optional)
adb shell rm -rf /sdcard/graphrag/input/*
adb shell rm -rf /sdcard/graphrag/progress/*
# Keep output for reference

# Stop phone app
adb shell am force-stop com.graphrag.processor
```

### Full Reset
```powershell
# Phone - clear all data
adb shell rm -rf /sdcard/graphrag/*
adb shell mkdir -p /sdcard/graphrag/{input,output,progress}

# Database - drop and recreate graph
docker exec -it graphrag-db psql -U graphrag -d knowledge_base -c "
    SELECT drop_graph('knowledge_graph', true);
    SELECT create_graph('knowledge_graph');
"
```
