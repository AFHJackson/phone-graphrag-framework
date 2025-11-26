# GraphRAG Phone Framework - Handoff Document

**Date**: November 26, 2025  
**Source Project**: Mind-Time (Budget-Optics city budget processing)  
**Target Project**: phone-graphrag-framework (Family Budget proof-of-concept)

---

## Executive Summary

We successfully built an on-device GraphRAG extraction pipeline running on Samsung Galaxy S25 Ultra using Gemma 3n E4B (4B parameter INT4 model). The system extracts entities and relationships from text chunks using GPU-accelerated inference via MediaPipe LiteRT.

**Key Achievement**: Stable processing with graceful failure handling, preprocessing to avoid GPU crashes, and persistent output saving.

---

## Architecture That Works

### Hardware
- **Device**: Samsung Galaxy S25 Ultra
- **SoC**: Snapdragon 8 Elite
- **GPU**: Adreno 830
- **RAM**: 12GB

### Software Stack
```
┌─────────────────────────────────────────┐
│  GraphRAGActivity (Compose UI)          │
│  - Start/Stop buttons                   │
│  - Status display                       │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│  GraphRAGWorker (WorkManager)           │
│  - Background processing                │
│  - Survives app closure                 │
│  - Progress persistence                 │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│  LiteRTService                          │
│  - MediaPipe LlmInference               │
│  - GPU-accelerated inference            │
│  - ~45 tokens/sec decode                │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│  Gemma 3n E4B Model                     │
│  - 4B params, INT4 quantized            │
│  - 4.3GB on disk                        │
│  - Path: /data/local/tmp/               │
└─────────────────────────────────────────┘
```

### File Locations
```
/sdcard/graphrag/
├── input/
│   └── chunks.json          # Input chunks to process
├── output/
│   └── chunk_XXX.json       # Per-chunk extraction results
└── progress/
    └── current_job.json     # Progress tracking (resumable)

/data/local/tmp/
└── gemma-3n-E4B-it-int4.litertlm   # Model file (pushed via ADB)
```

---

## Critical Lessons Learned

### 1. Model Path Must Be /data/local/tmp/
```kotlin
// WRONG - causes permission issues
private val modelPath = "/sdcard/Download/model.litertlm"

// CORRECT - MediaPipe requires this location
private val modelPath = "/data/local/tmp/gemma-3n-E4B-it-int4.litertlm"
```

Push model with: `adb push model.litertlm /data/local/tmp/`

### 2. Storage Permissions After Reinstall
After every `adb install`, permissions reset. Run:
```bash
adb shell pm grant com.mindtime.app android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.mindtime.app android.permission.WRITE_EXTERNAL_STORAGE
adb shell appops set com.mindtime.app MANAGE_EXTERNAL_STORAGE allow
```

### 3. Tabular Data Crashes GPU
Dense numeric tables (financial data) cause SIGSEGV in `libllm_inference_engine_jni.so`.

**Solution**: Preprocess to strip table rows:
```kotlin
private fun stripTableRows(content: String): String {
    return content.lines().filter { line ->
        val digits = line.count { it.isDigit() }
        val ratio = digits.toFloat() / line.length.coerceAtLeast(1)
        // Skip lines that are >30% digits
        ratio <= 0.30
    }.joinToString("\n")
}
```

### 4. LLM Can Hang Indefinitely
Some content causes the model to generate forever.

**Solution**: 3-minute timeout:
```kotlin
val response = withTimeout(180_000L) {
    aiService.generateLongFormContent(prompt)
}
```

### 5. WorkManager > Service for Long Tasks
- Services get killed by Android after ~10 minutes
- WorkManager survives app closure, device sleep, low battery
- Use `ExistingWorkPolicy.REPLACE` for restart behavior

---

## Extraction Quality Observations

### What the Model Does Well
- Identifies people, places, organizations
- Creates meaningful relationship types (`has_mayor`, `located_in`, `near`)
- Infers roles from context (e.g., "City Manager" from position in list)

### What Needs Human Curation
1. **Compound entities** - "Mayor Keith Capizzi" should be:
   - Entity: Keith Capizzi (Person)
   - Entity: Mayor (Role)
   - Relationship: Keith Capizzi → Mayor (holds_role)

2. **Relationship attribution** - "City → FY2026 (fiscal_year)" should be:
   - Entity: FY2026 Budget (Document)
   - Relationship: Budget → City (budget_for)
   - Relationship: Budget → 2026 (fiscal_year)

### Recommended Workflow
1. **Extract** - LLM does first pass (~70-80% accuracy)
2. **Review** - Human reviews JSON outputs
3. **Curate** - Fix types, decompose compounds, add missing relationships
4. **Load** - Import curated data into graph database

---

## Prompt Template That Works

```
Extract entities and relationships from this text.

Return JSON with this exact structure:
{
  "entities": [
    {"name": "Entity Name", "type": "Person|Organization|Location|Document|Date|Amount|Other"}
  ],
  "relationships": [
    {"source": "Entity1", "target": "Entity2", "type": "relationship_type"}
  ]
}

Text:
{chunk_content}

JSON:
```

---

## Performance Benchmarks

| Metric | Value |
|--------|-------|
| Model load time | ~15 seconds |
| Avg chunk processing | 90-120 seconds |
| Decode speed | ~45 tokens/sec |
| Success rate | ~70% (rest timeout/fail gracefully) |
| Entities per chunk | 15-25 typical |
| Relationships per chunk | 10-20 typical |

---

## Family Budget Proof-of-Concept Goals

### Why Family Budget First
- Simpler domain (fewer entity types)
- User has deep domain knowledge
- Faster iteration cycles
- Can validate full pipeline end-to-end

### Expected Entity Types
- Person (family members)
- Account (checking, savings, credit cards)
- Category (groceries, utilities, entertainment)
- Transaction
- Budget
- Date/Period

### Expected Relationships
- `person_owns_account`
- `transaction_from_account`
- `transaction_in_category`
- `budget_for_category`
- `budget_for_period`

---

## Files to Reference

### Core Implementation (Mind-Time repo)
- `app/src/main/java/com/mindtime/app/worker/GraphRAGWorker.kt` - Main processing logic
- `app/src/main/java/com/mindtime/app/worker/GraphRAGActivity.kt` - Simple UI
- `app/src/main/java/com/mindtime/app/ai/LiteRTService.kt` - MediaPipe wrapper
- `app/src/main/java/com/mindtime/app/graphrag/GraphRAGFileManager.kt` - File I/O

### Documentation
- `GRAPHRAG-OPERATING-PROCEDURE.md` - Step-by-step usage
- `MODEL-CONFIGURATION.md` - Model setup details
- `TROUBLESHOOTING.md` - Common issues and fixes

---

## Next Steps for phone-graphrag-framework

1. **Set up new Android project** with same dependencies
2. **Copy/adapt Worker pattern** from Mind-Time
3. **Create family budget test data** (sample transactions, categories)
4. **Run extraction** on family budget data
5. **Curate results** - establish entity type conventions
6. **Build PostgreSQL/AGE loader** - import to graph database
7. **Create query interface** - natural language to Cypher
8. **Document the complete pipeline**

---

## Dependencies

```kotlin
// build.gradle.kts
implementation("androidx.work:work-runtime-ktx:2.9.0")
implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
implementation("com.google.mediapipe:tasks-genai:0.10.22")
```

---

*This document captures the learnings from the Budget-Optics (city budget) exploration to accelerate the Family Budget proof-of-concept.*
