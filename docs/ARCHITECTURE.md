# Architecture Deep Dive

## Overview

This document provides a comprehensive technical architecture for the Phone GraphRAG Framework - a hybrid laptop+phone system for building knowledge graphs using on-device AI processing.

## System Components

### 1. Laptop Components

#### Document Chunking Pipeline
```
Documents → Text Extraction → Semantic Chunking → JSON Export
   │              │                  │                │
   │              │                  │                └── chunks.json
   │              │                  └── ~3000 chars/chunk
   │              └── PDF, DOCX, TXT support
   └── Any document type
```

**Chunking Strategy**:
- Target size: 2500-3000 characters per chunk
- Overlap: 200 characters between chunks
- Boundaries: Respect paragraph/section breaks
- Metadata: Include source file, page numbers, section headers

#### PostgreSQL + Apache AGE Database
```sql
-- Knowledge graph schema
CREATE EXTENSION IF NOT EXISTS age;
SET search_path TO ag_catalog;

SELECT create_graph('knowledge_graph');

-- Vertex labels
SELECT create_vlabel('knowledge_graph', 'Entity');
SELECT create_vlabel('knowledge_graph', 'Document');
SELECT create_vlabel('knowledge_graph', 'Chunk');

-- Edge labels  
SELECT create_elabel('knowledge_graph', 'RELATES_TO');
SELECT create_elabel('knowledge_graph', 'EXTRACTED_FROM');
SELECT create_elabel('knowledge_graph', 'MENTIONS');
```

#### Insight Generation (Ollama)
- Local LLM for query processing
- Graph-aware prompting
- Context retrieval from AGE

### 2. Phone Components

#### MediaPipe LLM Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                    MediaPipe LLM Inference                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Tokenizer  │→ │  Prefill    │→ │  Decode Loop            │  │
│  │  (SentenceP)│  │  (1876t/s)  │  │  (45 tok/sec)           │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
│                           │                                      │
│                           ▼                                      │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              Adreno 830 GPU (OpenCL)                         ││
│  │  • 4GB VRAM allocation for 4B model                          ││
│  │  • INT4 quantization for memory efficiency                   ││
│  │  • Batched attention for throughput                          ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

#### Entity Extraction Prompt Design
```kotlin
const val ENTITY_EXTRACTION_PROMPT = """
Extract ALL entities and relationships from this text.

Return a complete JSON object with two arrays: entities and relationships.

Entity types: ORGANIZATION, PROGRAM, PROJECT, PERSON, LOCATION, 
              BUDGET_ITEM, METRIC, OTHER
Relationship types: FUNDS, MANAGES, IMPLEMENTS, BENEFITS, DEPENDS_ON,
                   LOCATED_IN, MEASURES, ALLOCATES_TO, OTHER

TEXT:
{chunk_content}

Return complete JSON with this exact structure:
{"entities":[...],"relationships":[...]}
"""
```

#### Crash Recovery System
```kotlin
class WatchdogService : Service() {
    // Foreground service with PARTIAL_WAKE_LOCK
    // Monitors GraphRAGProcessor health
    // Auto-restarts app after native crashes
    // Maintains progress checkpoint
}
```

### 3. ADB Communication Layer

#### Data Flow
```
PUSH: Laptop → Phone
  chunks.json → /sdcard/graphrag/input/chunks.json
  
PULL: Phone → Laptop
  /sdcard/graphrag/output/results.json → results.json
  /sdcard/graphrag/progress/checkpoint.json → checkpoint.json

MONITORING:
  adb logcat -s GraphRAGProcessor:I
  adb shell am start -n com.graphrag.processor/.MainActivity
```

#### Automation Scripts
```powershell
# monitor_phone.ps1
param([int]$PollInterval = 5)

while ($true) {
    $progress = adb shell cat /sdcard/graphrag/progress/checkpoint.json 2>$null
    if ($progress) {
        $p = $progress | ConvertFrom-Json
        Write-Host "Progress: $($p.completed)/$($p.total) chunks"
    }
    Start-Sleep -Seconds $PollInterval
}
```

## Data Structures

### Chunk Format (Input)
```json
{
  "chunks": [
    {
      "id": "chunk_001",
      "content": "The Department of Transportation allocated...",
      "metadata": {
        "source": "budget_2024.pdf",
        "page": 12,
        "section": "Transportation"
      }
    }
  ]
}
```

### Result Format (Output)
```json
{
  "jobId": "job_1732567890123",
  "totalChunks": 192,
  "processedChunks": 192,
  "results": [
    {
      "chunkId": "chunk_001",
      "entities": [
        {
          "name": "Department of Transportation",
          "type": "ORGANIZATION",
          "description": "Federal agency"
        }
      ],
      "relationships": [
        {
          "source": "Department of Transportation",
          "target": "Highway Trust Fund",
          "type": "FUNDS",
          "description": "Allocated $50B"
        }
      ],
      "processingTimeMs": 45234,
      "status": "SUCCESS"
    }
  ]
}
```

## Performance Characteristics

### Phone Processing
| Metric | Value |
|--------|-------|
| Model Size | 4.3 GB |
| Token Prefill | 1876 tok/sec |
| Token Decode | 45 tok/sec |
| Per-chunk Time | 30-60 seconds |
| Memory Usage | ~5 GB peak |
| GPU Utilization | 85-95% |

### Laptop Operations
| Metric | Value |
|--------|-------|
| Chunking | ~1000 chunks/minute |
| DB Insert | ~100 entities/second |
| Graph Query | <100ms simple, <1s complex |

## Error Handling

### Native Crash Recovery
1. **Detection**: SIGSEGV/SIGABRT caught by system
2. **WatchdogService**: Detects process death
3. **Restart**: App relaunched in 1-2 seconds
4. **Resume**: Loads checkpoint, skips completed chunks

### Problematic Content Handling
```kotlin
// Preprocessing pipeline
fun preprocessContent(content: String): String {
    // 1. Detect tabular content (causes GPU tokenizer issues)
    if (isTabularContent(content)) {
        content = convertToNarrative(content)
    }
    
    // 2. Normalize text
    content = normalizeForLLM(content)
    
    // 3. Truncate if needed
    if (content.length > 3000) {
        content = content.take(3000)
    }
    
    return content
}
```

## Security Considerations

- All processing is on-device (no cloud API calls)
- Data stays on local network (USB only)
- No network permissions required
- Model weights stored in protected app storage

## Scaling

### Multiple Phones (Future)
```
Laptop
  │
  ├─── Phone 1 (chunks 0-63)
  ├─── Phone 2 (chunks 64-127)
  └─── Phone 3 (chunks 128-191)
```

### Larger Models (Future)
- Gemma 3n E8B (NPU Early Access Program)
- Llama 3.2 3B (when MediaPipe support available)

## Limitations

1. **Phone Dependency**: Processing blocked if phone unavailable
2. **Sequential Processing**: One chunk at a time per phone
3. **Tabular Data**: Dense financial tables require preprocessing
4. **Context Window**: 1024 tokens limits chunk complexity
5. **Battery**: Continuous processing drains battery (~20%/hour)
