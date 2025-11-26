# Phone GraphRAG Framework - Setup Complete

## What Was Created

A new standalone project at `C:\Users\afhja\phone-graphrag-framework\` that consolidates all learning from Mind-Time and Budget-Optics projects.

### Repository Structure
```
phone-graphrag-framework/
├── README.md                 # Project overview and quick start
├── .gitignore               # Git ignore patterns
├── docs/
│   ├── ARCHITECTURE.md      # System architecture deep dive
│   ├── PHONE-SETUP.md       # Samsung S25 Ultra setup guide
│   ├── DATABASE-SETUP.md    # PostgreSQL + Apache AGE setup
│   ├── OPERATING-PROCEDURE.md # Step-by-step workflow
│   └── LESSONS-LEARNED.md   # Everything we learned
├── config/
│   ├── phone_specs.json     # Your S25 Ultra specifications
│   └── model_config.json    # Gemma 3n E4B configuration
├── laptop/
│   ├── docker-compose.yml   # PostgreSQL + AGE database
│   ├── requirements.txt     # Python dependencies
│   └── scripts/
│       ├── chunk_documents.py
│       ├── load_to_postgres.py
│       └── monitor_phone.py
├── sql/
│   ├── create_schema.sql
│   ├── create_knowledge_graph.sql
│   └── graph_queries.sql
└── phone-app/               # (To be populated from Mind-Time)
```

### Branches
- `main` - Stable framework (generic, reusable)
- `project/budget-optics` - City budget analysis (current)
- (Future) `project/family-finance` - Personal finance

## Code Fixes Applied to Mind-Time

### 1. Preprocessing Pipeline (GraphRAGProcessor.kt)
- **Tabular content detection**: Identifies chunks with >30% tabular data
- **Text normalization**: Removes non-ASCII, collapses whitespace
- **Budget line conversion**: Transforms financial tables to narrative text
- **Auto-skip**: Chunks >70% tabular are skipped to prevent crashes

### 2. Checkpoint Frequency
- Already saving after every chunk (verified in code)
- Skip logic saves progress immediately

### 3. Dynamic Skip Detection
- `shouldSkipChunk()` function checks both hardcoded list AND content analysis
- Prevents crashes from dense numerical data

## Next Steps

### To Resume Budget-Optics Processing:
1. Open VS Code in Mind-Time project
2. Build and deploy: `.\gradlew assembleDebug; adb install -r app\build\outputs\apk\debug\app-debug.apk`
3. Clear previous progress: `adb shell rm -rf /sdcard/graphrag/progress/*`
4. Launch: `adb shell am start -n com.mindtime.app/.MainActivity`
5. Monitor: `adb logcat -s GraphRAGProcessor:I`

### To Continue Framework Development:
1. Open `C:\Users\afhja\phone-graphrag-framework` in VS Code
2. Copy phone-app code from Mind-Time (when stable)
3. Create GitHub repo and push
4. Test end-to-end with new simple dataset first

## Key Learnings Captured

1. **Gemma 3n E4B** is the right model size for S25 Ultra
2. **LiteRT alpha05** is stable for GPU (pin this version!)
3. **Dense tables crash GPU** - preprocessing is essential
4. **Save after every chunk** - minimizes crash data loss
5. **WatchdogService** provides automatic crash recovery
6. **Separate framework from domain** - reduces debugging confusion

## Project Philosophy

This framework enables a **laptop + phone partnership**:
- **Laptop**: Storage, Python, PostgreSQL, orchestration
- **Phone**: GPU power for 4B parameter LLM inference

The framework is generic - Budget-Optics is just one application.
Future projects (family finance, research papers, etc.) branch from main.
