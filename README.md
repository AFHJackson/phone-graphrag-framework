# Phone GraphRAG Framework

**A laptop + flagship phone approach to building GraphRAG knowledge bases using on-device AI processing.**

## Overview

This framework enables building GraphRAG (Graph Retrieval-Augmented Generation) knowledge bases by leveraging the GPU power of flagship Android phones for entity extraction, while using a laptop for orchestration, database management, and insight generation.

### Why This Approach?

| Component | Laptop | Flagship Phone |
|-----------|--------|----------------|
| **Strength** | Storage, PostgreSQL, Python tooling | GPU/NPU, 4B param LLM inference |
| **Weakness** | Limited GPU (or none) | Limited storage, no Python |
| **Role** | Orchestration, DB, queries | Heavy AI lifting (entity extraction) |

### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           LAPTOP (Orchestrator)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │  Document    │  │  PostgreSQL  │  │  Insight Generation       │  │
│  │  Chunking    │  │  + AGE Graph │  │  (Ollama / Local LLM)    │  │
│  │  (Python)    │  │  Database    │  │                          │  │
│  └──────┬───────┘  └───────▲──────┘  └──────────────────────────┘  │
│         │                  │                                        │
│         │ chunks.json      │ entities.json                         │
│         ▼                  │                                        │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    ADB Bridge (USB)                           │  │
│  │        adb push chunks.json → /sdcard/graphrag/input/         │  │
│  │        adb pull /sdcard/graphrag/output/results.json          │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ USB
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    PHONE (GPU Processing Engine)                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                  GraphRAG Processor App                       │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐   │  │
│  │  │ File I/O    │  │ MediaPipe   │  │ WatchdogService     │   │  │
│  │  │ Manager     │  │ LLM (GPU)   │  │ (crash recovery)    │   │  │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘   │  │
│  │                                                               │  │
│  │  Model: Gemma 3n E4B (4B params, INT4 quantized)             │  │
│  │  Performance: 45 tok/sec decode, 1876 tok/sec prefill        │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- **Laptop**: Windows/Mac/Linux with Python 3.10+, PostgreSQL 15+, Apache AGE
- **Phone**: Android 14+ flagship (tested on Samsung Galaxy S25 Ultra)
- **ADB**: Android Debug Bridge installed and configured
- **Model**: Gemma 3n E4B model file on phone

### Setup

```powershell
# 1. Clone this repo
git clone https://github.com/AFHJackson/phone-graphrag-framework.git
cd phone-graphrag-framework

# 2. Set up laptop environment
cd laptop
pip install -r requirements.txt
docker-compose up -d  # PostgreSQL + Apache AGE

# 3. Build and deploy phone app
cd ../phone-app
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk

# 4. Verify phone setup
adb shell ls /data/local/tmp/gemma-3n-E4B-it-int4.litertlm
```

### Usage Workflow

```powershell
# 1. Chunk your documents (laptop)
python scripts/chunk_documents.py --input data/my_docs.pdf --output chunks.json

# 2. Push to phone
adb push chunks.json /sdcard/graphrag/input/

# 3. Launch phone processor
adb shell am start -n com.graphrag.processor/.MainActivity

# 4. Monitor progress
adb logcat -s GraphRAGProcessor:I

# 5. Pull results when complete
adb pull /sdcard/graphrag/output/results.json

# 6. Load into database (laptop)
python scripts/load_to_postgres.py --input results.json

# 7. Query your knowledge graph
python scripts/query_insights.py "What are the main relationships?"
```

## Project Structure

```
phone-graphrag-framework/
├── README.md                    # This file
├── docs/
│   ├── ARCHITECTURE.md          # Detailed architecture
│   ├── PHONE-SETUP.md           # Phone configuration guide
│   ├── DATABASE-SETUP.md        # PostgreSQL + AGE setup
│   ├── OPERATING-PROCEDURE.md   # Step-by-step workflow
│   ├── TROUBLESHOOTING.md       # Common issues
│   └── LESSONS-LEARNED.md       # What we learned
├── phone-app/                   # Android app source
│   ├── app/
│   │   └── src/main/java/
│   │       └── com/graphrag/processor/
│   │           ├── MainActivity.kt
│   │           ├── GraphRAGProcessor.kt
│   │           ├── GraphRAGFileManager.kt
│   │           └── WatchdogService.kt
│   ├── build.gradle.kts
│   └── settings.gradle.kts
├── laptop/
│   ├── requirements.txt
│   ├── docker-compose.yml       # PostgreSQL + AGE
│   └── scripts/
│       ├── chunk_documents.py
│       ├── load_to_postgres.py
│       ├── query_insights.py
│       └── monitor_phone.py
├── sql/
│   ├── create_schema.sql
│   ├── create_knowledge_graph.sql
│   └── graph_queries.sql
├── tests/
│   ├── e2e/                     # End-to-end phone tests
│   │   ├── test_chunk_processing.py
│   │   └── adb_test_runner.py
│   └── integration/
└── config/
    ├── phone_specs.json         # Device specifications
    └── model_config.json        # Model parameters
```

## Branching Strategy

This repo uses a **project-per-branch** approach:

- `main` - Stable framework (generic, reusable)
- `project/budget-optics` - City budget analysis
- `project/family-finance` - Personal finance tracking
- `project/research-papers` - Academic paper analysis

Successful projects can spin off into their own repositories.

## Phone Specifications (Tested)

**Samsung Galaxy S25 Ultra**
- **SoC**: Qualcomm Snapdragon 8 Elite
- **GPU**: Adreno 830 (excellent for LLM inference)
- **RAM**: 12 GB
- **Storage**: 256 GB
- **Android**: 15

**Model Performance**:
- Gemma 3n E4B (4B params, INT4): 45 tok/sec decode
- Per-chunk processing: 30-60 seconds
- 192 chunks: ~2-3 hours total

## Key Technologies

### Phone Side
- **MediaPipe LLM Inference API** (v0.10.27)
- **LiteRT** (formerly TensorFlow Lite) - alpha05
- **Gemma 3n E4B** - 4B parameter model optimized for mobile
- **Kotlin** + Jetpack Compose

### Laptop Side
- **PostgreSQL 15** + **Apache AGE** (graph database)
- **Python 3.10+** with LangChain, Ollama integration
- **ADB** for phone communication
- **Docker** for database containerization

## Contributing

1. Fork the repository
2. Create a project branch (`git checkout -b project/my-project`)
3. Make your changes
4. Test thoroughly
5. Submit a PR to merge improvements back to `main`

## License

MIT License - See [LICENSE](LICENSE)

## Acknowledgments

- Google AI Edge team for MediaPipe/LiteRT
- Apache AGE for graph database extensions
- The Mind-Time and Budget-Optics projects where this approach was developed
