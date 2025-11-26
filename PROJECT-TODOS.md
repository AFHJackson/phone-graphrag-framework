# Phone GraphRAG Framework - Project Tasks

**Project**: phone-graphrag-framework  
**Started**: November 26, 2025  
**Goal**: Build reusable on-device GraphRAG extraction framework for Android

---

## Status Legend
- ⬜ Not Started
- 🟡 In Progress
- ✅ Completed
- ❌ Blocked

---

## Phase 1: Project Setup

### 1.1 Repository & Documentation
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ✅ | Create GitHub repository | Repo exists at AFHJackson/phone-graphrag-framework |
| ✅ | Initialize with README | README.md describes project purpose and setup |
| ✅ | Create PROJECT-TODOS.md | This document exists and tracks all tasks |
| ⬜ | Create `feature/family-budget` branch | Branch exists for POC development |
| ⬜ | Set up .gitignore for Android | Excludes build/, .gradle/, local.properties, etc. |

### 1.2 Android Project Scaffolding
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create new Android project | Kotlin + Jetpack Compose, min SDK 26, target SDK 34 |
| ⬜ | Configure build.gradle with dependencies | WorkManager, Serialization, MediaPipe tasks-genai |
| ⬜ | Set up project package structure | com.afhjackson.graphrag with ai/, worker/, ui/, data/ packages |
| ⬜ | Add AndroidManifest permissions | Storage, Internet, Foreground Service permissions |
| ⬜ | Create basic MainActivity | Empty Compose scaffold that launches |

### 1.3 Device Setup Documentation
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Document model download steps | Where to get Gemma 3n E4B, how to push to device |
| ⬜ | Create ADB setup script | Script to push model and grant permissions |
| ⬜ | Test model loads on device | LiteRT can initialize model without crash |

---

## Phase 2: Core Infrastructure

### 2.1 LiteRT/MediaPipe Integration
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create LiteRTService class | Wrapper around MediaPipe LlmInference |
| ⬜ | Implement model initialization | Load model from /data/local/tmp/ |
| ⬜ | Implement text generation | generateContent() returns response string |
| ⬜ | Add 3-minute timeout | Gracefully handles hung inference |
| ⬜ | Test with simple prompt | "Hello, world" returns valid response |

### 2.2 File Management
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create GraphRAGFileManager | Handles all /sdcard/graphrag/ operations |
| ⬜ | Implement readChunks() | Parses input/chunks.json |
| ⬜ | Implement writeResult() | Saves per-chunk JSON to output/ |
| ⬜ | Implement progress tracking | Saves/loads current_job.json for resume |
| ⬜ | Add directory initialization | Creates folders if missing |

### 2.3 Preprocessing Pipeline
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create ChunkPreprocessor | Cleans chunks before LLM |
| ⬜ | Implement stripTableRows() | Removes lines >30% digits |
| ⬜ | Implement truncateToTokenLimit() | Keeps chunks under model context |
| ⬜ | Add content validation | Skips empty/invalid chunks |

### 2.4 WorkManager Worker
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create GraphRAGWorker | Extends CoroutineWorker |
| ⬜ | Implement doWork() | Processes chunks sequentially |
| ⬜ | Add progress notifications | Shows current chunk in notification |
| ⬜ | Implement graceful failure | Failed chunks saved with error, continues |
| ⬜ | Add resume capability | Skips already-processed chunks |

### 2.5 Entity Extraction
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create extraction prompt template | JSON output format for entities/relationships |
| ⬜ | Implement parseExtractionResponse() | Extracts JSON from LLM response |
| ⬜ | Define Entity data class | name, type, metadata fields |
| ⬜ | Define Relationship data class | source, target, type, metadata fields |
| ⬜ | Handle malformed JSON | Graceful fallback for bad LLM output |

---

## Phase 3: Family Budget Proof-of-Concept

### 3.1 Test Data Creation
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Define family budget schema | Document entity types and relationships |
| ⬜ | Create sample accounts data | 3-5 accounts (checking, savings, credit) |
| ⬜ | Create sample transactions | 20-30 realistic transactions |
| ⬜ | Create sample categories | 10-15 budget categories |
| ⬜ | Format as chunks.json | Ready for extraction pipeline |

### 3.2 Domain-Specific Prompt
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create family budget prompt | Tailored entity types for domain |
| ⬜ | Test prompt on sample data | Returns expected entity types |
| ⬜ | Iterate on prompt quality | >80% accuracy on test set |

### 3.3 End-to-End Test
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Push test data to device | chunks.json in /sdcard/graphrag/input/ |
| ⬜ | Run extraction pipeline | All chunks processed |
| ⬜ | Review extraction quality | Document accuracy observations |
| ⬜ | Identify curation needs | List common extraction errors |

---

## Phase 4: Curation Tools

### 4.1 Extraction Review UI
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create ReviewActivity | Shows extraction results |
| ⬜ | Display entities list | Grouped by type |
| ⬜ | Display relationships list | Source → Target with type |
| ⬜ | Add edit capability | Can modify entity types, names |
| ⬜ | Add merge capability | Combine duplicate entities |

### 4.2 Curation Export
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Export curated JSON | Clean format for graph loading |
| ⬜ | Generate curation statistics | Entity counts, relationship counts |
| ⬜ | Create curation log | Track changes made during review |

---

## Phase 5: Graph Database Loading

### 5.1 PostgreSQL/AGE Setup
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create Docker compose for PostgreSQL+AGE | Database runs locally |
| ⬜ | Design graph schema | Node labels, edge types |
| ⬜ | Create initialization SQL | Creates graph and base structure |

### 5.2 Data Loader
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create Python loader script | Reads curated JSON |
| ⬜ | Implement entity upsert | Creates/updates nodes |
| ⬜ | Implement relationship creation | Creates edges between nodes |
| ⬜ | Add idempotency | Can re-run without duplicates |

### 5.3 Query Interface
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create sample Cypher queries | Common graph traversals |
| ⬜ | Document query patterns | How to explore the graph |
| ⬜ | (Stretch) Natural language to Cypher | LLM translates questions to queries |

---

## Phase 6: Documentation & Polish

### 6.1 User Documentation
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Complete README.md | Full setup and usage instructions |
| ⬜ | Create ARCHITECTURE.md | System design documentation |
| ⬜ | Create TROUBLESHOOTING.md | Common issues and solutions |
| ⬜ | Create OPERATING-PROCEDURE.md | Step-by-step usage guide |

### 6.2 Code Quality
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Add KDoc comments | All public APIs documented |
| ⬜ | Create unit tests | Core logic has test coverage |
| ⬜ | Code review pass | Clean, consistent code style |

---

## Backlog / Future Ideas
- [ ] Support multiple model formats (GGUF, etc.)
- [ ] Batch processing optimization
- [ ] Real-time extraction streaming
- [ ] Cloud sync for curated data
- [ ] Multi-device coordination
- [ ] Custom entity type configuration
- [ ] Graph visualization on device

---

## Progress Log

### November 26, 2025
- Project initiated
- Created PROJECT-TODOS.md
- Reviewed handoff document from Mind-Time project

---

*Last Updated: November 26, 2025*
