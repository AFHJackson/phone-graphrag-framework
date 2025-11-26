# Lessons Learned

## Overview

This document captures the key lessons learned while developing the Phone GraphRAG Framework across the Mind-Time and Budget-Optics projects.

---

## Phone-Side Processing

### MediaPipe / LiteRT Insights

#### Model Selection
**Lesson**: Gemma 3n E4B (4B params) is the sweet spot for flagship phones.
- **Why**: Fits in GPU VRAM with room for context
- **Alternative tested**: Gemma 1B was too low quality
- **Alternative considered**: Gemma 3 8B requires NPU (not publicly available)

#### Quantization Matters
**Lesson**: INT4 quantization is essential for mobile.
```
FP32: ~16 GB (impossible on phone)
INT8: ~8 GB (barely fits, no headroom)
INT4: ~4.3 GB (comfortable fit, good quality)
```

#### Library Version Pinning
**Lesson**: Always pin to specific alpha version.
```kotlin
// BAD - gets broken updates
implementation("com.google.ai.edge.litertlm:litertlm:+")

// GOOD - stable known version
implementation("com.google.ai.edge.litertlm:litertlm:0.0.0-alpha05")
```
- alpha05 is stable for GPU
- alpha06+ changes NPU APIs

#### GPU Backend Configuration
**Lesson**: Explicit GPU backend selection is required.
```kotlin
val config = EngineConfig(
    modelPath = modelPath,
    backend = Backend.GPU,  // Not auto-detected!
    maxNumTokens = 4096
)
```

### Crash Recovery

#### Native Crashes Are Unrecoverable
**Lesson**: SIGSEGV/SIGABRT from native code cannot be caught in Kotlin.
```kotlin
// This does NOT catch native crashes:
try {
    aiService.generate(prompt)
} catch (e: Exception) {
    // Never reached for SIGSEGV
}
```

**Solution**: WatchdogService foreground service that restarts the app.

#### Progress Checkpointing
**Lesson**: Save after EVERY chunk, not every N chunks.
```kotlin
// BEFORE (lost progress on crash)
if (index % 5 == 0) {
    saveProgress()
}

// AFTER (minimal loss)
saveProgress()  // After every chunk
```

#### Content Preprocessing
**Lesson**: Dense tabular data crashes GPU tokenizer.
```
CRASHES: "4130-347. 20-20 Pool Rental 24,203 33,355 30,000"
WORKS:   "Budget item 4130-347: Pool Rental with values 24203 and 33355"
```

**Solution**: Detect and convert tabular content before processing.

### Performance Optimization

#### Model Load Time
**Lesson**: First load is slow (~5 seconds), subsequent loads are fast (~0.65 seconds).
- Don't reload model between chunks
- Keep model in memory for entire session
- Wake lock prevents memory release

#### Token Generation Speed
**Measured Performance (S25 Ultra)**:
- Prefill: 1876 tok/sec
- Decode: 45 tok/sec
- Per-chunk: 30-60 seconds

**Optimization attempts that didn't help**:
- Reducing batch size
- Changing temperature
- Adjusting top_k/top_p

**What did help**:
- Shorter prompts (fewer input tokens)
- Smaller output expectations
- Preprocessing to reduce content length

---

## ADB Automation

### File Transfer
**Lesson**: Use /sdcard for app-accessible storage.
```powershell
# WORKS - external storage
adb push chunks.json /sdcard/graphrag/input/

# FAILS - app private storage (need root)
adb push chunks.json /data/data/com.app/files/
```

### Permission Handling (Android 11+)
**Lesson**: MANAGE_EXTERNAL_STORAGE requires special handling.
```powershell
# Grant via appops, not just manifest
adb shell appops set com.package MANAGE_EXTERNAL_STORAGE allow
```

### Monitoring Best Practices
```powershell
# Clear logs before starting
adb logcat -c

# Filter to specific tags
adb logcat -s GraphRAGProcessor:I LiteRT:I

# Get last N lines (after completion)
adb logcat -d | Select-Object -Last 100
```

### App Lifecycle Control
```powershell
# Force stop (clean state)
adb shell am force-stop com.package

# Start specific activity
adb shell am start -n com.package/.MainActivity

# Check if running
adb shell pidof com.package
```

---

## Database Layer

### PostgreSQL + Apache AGE

#### Graph Extension Loading
**Lesson**: Must load AGE in every session.
```sql
-- Required at start of every connection
LOAD 'age';
SET search_path = ag_catalog, "$user", public;
```

#### Cypher Syntax Quirks
**Lesson**: AGE Cypher has subtle differences from Neo4j.
```sql
-- Neo4j style (FAILS in AGE)
MATCH (n:Entity) RETURN n.name

-- AGE style (WORKS)
SELECT * FROM cypher('graph_name', $$
    MATCH (n:Entity) RETURN n.name
$$) AS (name agtype);
```

#### String Escaping
**Lesson**: Single quotes must be escaped in Cypher strings.
```python
# BAD
name = "O'Connor"
cypher = f"CREATE (n:Person {{name: '{name}'}})"  # Syntax error!

# GOOD
name = "O'Connor".replace("'", "''")
cypher = f"CREATE (n:Person {{name: '{name}'}})"
```

### Entity Deduplication
**Lesson**: Same entity extracted from multiple chunks needs MERGE.
```sql
-- CREATE creates duplicates
CREATE (e:Entity {name: 'Acme Corp'})

-- MERGE deduplicates
MERGE (e:Entity {name: 'Acme Corp'})
ON CREATE SET e.type = 'ORGANIZATION'
```

---

## Prompt Engineering

### Entity Extraction Prompt
**What Works**:
```
Extract ALL entities and relationships from this text.
Return a complete JSON object with two arrays: entities and relationships.
Entity types: ORGANIZATION, PROGRAM, PROJECT, PERSON, LOCATION...
```

**What Doesn't Work**:
- Asking for markdown output (model defaults to code blocks)
- Complex nested JSON schemas
- Multiple output formats in one prompt

### JSON Output Reliability
**Lesson**: Always request explicit JSON structure in prompt.
```
Return complete JSON with this exact structure:
{"entities":[...],"relationships":[...]}
```

**Lesson**: Always clean markdown from response.
```kotlin
val cleanJson = response
    .removePrefix("```json")
    .removePrefix("```")
    .removeSuffix("```")
    .trim()
```

### Temperature Settings
**Tested Values**:
- 0.0: Too deterministic, misses entities
- 0.5: Good balance (recommended)
- 0.8: More creative, sometimes hallucinates
- 1.0: Unreliable output format

---

## Project Organization

### Separating Concerns
**Lesson**: Don't mix framework development with domain projects.

**Problem we had**: Developing phone processing (framework) while doing city budget analysis (domain) in same project caused confusion about source of errors.

**Solution**: 
1. Framework repo (stable, tested, reusable)
2. Project branches (domain-specific, can fail independently)

### Documentation Strategy
**What helped**:
- One document per component
- Step-by-step procedures with exact commands
- Troubleshooting sections with real error messages

**What didn't help**:
- Mixing architecture docs with procedures
- Outdated commands without dates
- Assumptions about reader knowledge

---

## E2E Testing

### Phone Test Automation
**Working approach**:
```powershell
# 1. Deploy app
adb install -r app.apk

# 2. Push test data
adb push test_chunks.json /sdcard/graphrag/input/chunks.json

# 3. Launch and wait
adb shell am start -n com.package/.MainActivity
Start-Sleep -Seconds 120  # Wait for processing

# 4. Check results
$result = adb pull /sdcard/graphrag/output/results.json
$json = Get-Content results.json | ConvertFrom-Json
if ($json.results.Count -eq 0) { throw "No results" }
```

### Test Data Design
**Good test chunks**: Simple sentences with clear entities
```json
{"content": "John Smith works for Acme Corp in New York."}
```

**Bad test chunks**: Dense financial tables
```json
{"content": "4130-347. 20-20 Pool Rental 24,203 33,355"}
```

---

## Hardware Considerations

### Thermal Throttling
**Observation**: After ~30 minutes continuous processing, phone heats up.
- GPU clock speed drops ~15%
- Processing time increases from 40s to 55s per chunk

**Mitigation**:
- Keep phone on cool surface
- Add 5-second delay every 10 chunks
- Monitor with `adb shell cat /sys/class/thermal/thermal_zone*/temp`

### Battery Usage
**Measured**: ~20% battery per hour of continuous processing.
- USB connection required anyway (for ADB)
- USB charging compensates for usage
- Still see ~10% net drain per hour

### Memory Pressure
**When it happens**: Background apps competing for RAM.
**Symptoms**: Model reload, longer processing time.
**Solution**: 
```powershell
# Kill other apps before long processing
adb shell am kill-all
```

---

## Key Takeaways

1. **Phone GPU is viable** for batch AI processing
2. **Preprocessing is essential** for reliable results
3. **Crash recovery must be automatic** (WatchdogService)
4. **Save progress constantly** (every chunk)
5. **Separate framework from projects** early
6. **Pin library versions** explicitly
7. **Test with simple data first** before complex documents
8. **Document exact commands** including error cases
