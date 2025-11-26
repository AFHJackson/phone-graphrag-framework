# Phone GraphRAG Framework - Project Tasks

**Project**: phone-graphrag-framework  
**Started**: November 26, 2025  
**Goal**: Build on-device GraphRAG extraction framework for Family Financial Transformation

**Two Outcomes**:
1. **Asset Transition**: Shift from salary-funded to asset-funded expenses
2. **Priority Alignment**: Align spending with declared priorities

**Related Documents**:
- [FAMILY-BUDGET-POC.md](docs/FAMILY-BUDGET-POC.md) - Methodology and entity model
- [FAMILY-BUDGET-PLAN.md](docs/FAMILY-BUDGET-PLAN.md) - Comprehensive plan with all tasks

---

## Status Legend
- ⬜ Not Started
- 🟡 In Progress
- ✅ Completed
- ❌ Blocked

---

## Quick Links to Milestones

| Milestone | Target | Status | Outcome Contribution |
|-----------|--------|--------|---------------------|
| [M1: Data Ready](#milestone-1-data-ready) | Week 2 | ⬜ | Foundation |
| [M2: Priorities Revealed](#milestone-2-priorities-revealed) | Week 3 | ⬜ | Alignment Stage 2 |
| [M3: Priorities Declared](#milestone-3-priorities-declared) | Week 4 | ⬜ | Alignment Stage 3 |
| [M4: Gap & Plan](#milestone-4-gap-quantified--plan-created) | Week 5 | ⬜ | Both outcomes |
| [M5: Deploy & Monitor](#milestone-5-deployed--monitoring) | Week 6+ | ⬜ | Continuous |

---

## Phase 0: Project Infrastructure

### 0.1 Repository & Documentation
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ✅ | Create GitHub repository | Repo exists at AFHJackson/phone-graphrag-framework |
| ✅ | Initialize with README | README.md describes project purpose and setup |
| ✅ | Create PROJECT-TODOS.md | This document exists and tracks all tasks |
| ✅ | Create `feature/family-budget` branch | Branch exists for POC development |
| ✅ | Set up .gitignore for Android | Excludes build/, .gradle/, local.properties, etc. |
| ✅ | Create FAMILY-BUDGET-POC.md | Methodology and entity model documented |
| ✅ | Create FAMILY-BUDGET-PLAN.md | Comprehensive plan with milestones and tasks |

### 0.2 Android Project Scaffolding
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create new Android project | Kotlin + Jetpack Compose, min SDK 26, target SDK 34 |
| ⬜ | Configure build.gradle with dependencies | WorkManager, Serialization, MediaPipe tasks-genai |
| ⬜ | Set up project package structure | com.afhjackson.graphrag with ai/, worker/, ui/, data/ packages |
| ⬜ | Add AndroidManifest permissions | Storage, Internet, Foreground Service permissions |
| ⬜ | Create basic MainActivity | Empty Compose scaffold that launches |

### 0.3 Device Setup
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

### 1.5 Entity Extraction
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create extraction prompt template | JSON output format for entities/relationships |
| ⬜ | Implement parseExtractionResponse() | Extracts JSON from LLM response |
| ⬜ | Define Entity data class | name, type, metadata fields |
| ⬜ | Define Relationship data class | source, target, type, metadata fields |
| ⬜ | Handle malformed JSON | Graceful fallback for bad LLM output |

---

## Milestone 1: Data Ready

**Target**: End of Week 2  
**Outcome Contribution**: Foundation for both outcomes

### M1.1 Data Inventory & Export
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | List all bank/checking accounts | Complete inventory |
| ⬜ | List all credit cards | Complete inventory |
| ⬜ | List all investment accounts | Complete inventory |
| ⬜ | List other data sources (Amazon, etc.) | Complete inventory |
| ⬜ | Identify date ranges and gaps | Document coverage |
| ⬜ | Export all account transactions | Raw data files collected |

### M1.2 Data Ingestion Pipeline (Laptop)
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create unified transaction schema | date, amount, description, account, category |
| ⬜ | Write CSV parser | Handles multiple bank formats |
| ⬜ | Write Excel parser | If needed |
| ⬜ | Write Amazon order parser | If needed |
| ⬜ | Create normalization layer | All sources → unified format |
| ⬜ | Output unified transactions.json | Ready for processing |

### M1.3 Categorization
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Define category taxonomy | Hierarchical structure |
| ⬜ | Create vendor → category rules | Auto-categorization |
| ⬜ | Run auto-categorization | First pass complete |
| ⬜ | Manual categorization review | 95%+ coverage |
| ⬜ | Update rules from review | Improved automation |

### M1.4 Chunking & Extraction
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Design chunk format for financial data | Appropriate for LLM |
| ⬜ | Create chunking script | Generates chunks.json |
| ⬜ | Preprocess (strip numeric tables) | Avoid GPU crashes |
| ⬜ | Create financial extraction prompt | Tuned for budget domain |
| ⬜ | Push chunks to phone | In /sdcard/graphrag/input/ |
| ⬜ | Run extraction on phone | All chunks processed |
| ⬜ | Pull and curate results | Entities ready for graph |

### M1.5 Graph Loading
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Start PostgreSQL + AGE (Docker) | Database running |
| ⬜ | Create financial graph schema | Node labels, edge types |
| ⬜ | Write graph loader script | Python |
| ⬜ | Load entities and relationships | Data in graph |
| ⬜ | Validate with test queries | Queries return expected results |

---

## Milestone 2: Priorities Revealed

**Target**: End of Week 3  
**Outcome Contribution**: Priority Alignment Stage 2

### M2.1 Spending Analysis
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Query: Total spend by category | Working query |
| ⬜ | Query: Total spend by vendor | Working query |
| ⬜ | Query: Spend by month | Working query |
| ⬜ | Query: Category trends over time | Working query |
| ⬜ | Query: Top 10 vendors | Working query |
| ⬜ | Query: Recurring transactions | Working query |

### M2.2 Revealed Priority Analysis
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Design revealed priority algorithm | Documented approach |
| ⬜ | Implement priority scoring | Working calculation |
| ⬜ | Generate revealed priority ranking | List generated |
| ⬜ | Create revealed priority report | Human-readable document |
| ⬜ | Review and annotate findings | Personal notes added |

---

## Milestone 3: Priorities Declared

**Target**: End of Week 4  
**Outcome Contribution**: Priority Alignment Stage 3

### M3.1 Conversation Preparation
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create priority brainstorm template | Individual exercise ready |
| ⬜ | Create couple conversation guide | Discussion structure |
| ⬜ | Complete individual brainstorm (self) | Personal list done |
| ⬜ | Complete individual brainstorm (spouse) | Spouse list done |

### M3.2 Priority Documentation
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Conduct couple conversation | Discussion completed |
| ⬜ | Merge priority lists | Combined list created |
| ⬜ | Create priority ranking | Ordered by importance |
| ⬜ | Write priority definitions | Each priority explained |
| ⬜ | Note disagreement areas | Documented for revisit |
| ⬜ | Load declared priorities to graph | Data in database |

---

## Milestone 4: Gap Quantified & Plan Created

**Target**: End of Week 5  
**Outcome Contribution**: Priority Alignment Stage 4, Asset Transition Stage 2-3

### M4.1 Alignment Analysis
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Map categories to priorities | supports/neutral/conflicts |
| ⬜ | Design alignment scoring | Algorithm documented |
| ⬜ | Calculate alignment scores | Scores generated |
| ⬜ | Identify over-spend categories | Low priority, high spend |
| ⬜ | Identify under-spend categories | High priority, low spend |
| ⬜ | Generate alignment gap report | Document created |

### M4.2 Surplus Planning
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Rank reduction candidates | By impact and difficulty |
| ⬜ | Estimate realistic savings | Per item |
| ⬜ | Calculate potential monthly surplus | Total amount |
| ⬜ | Identify quick wins | Easy, high impact |
| ⬜ | Define target surplus amount | Goal set |
| ⬜ | Create surplus action plan | Steps documented |

### M4.3 Asset Strategy
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Research asset options | Options documented |
| ⬜ | Define asset acquisition criteria | Decision framework |
| ⬜ | Create deployment plan | What to buy, when |
| ⬜ | Set up asset tracking in graph | Schema ready |

---

## Milestone 5: Deployed & Monitoring

**Target**: End of Week 6+  
**Outcome Contribution**: Both outcomes progressing

### M5.1 First Adjustments
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Implement quick win #1 | Change made |
| ⬜ | Implement quick win #2 | Change made |
| ⬜ | Track adjustment impact | Metrics captured |

### M5.2 Asset Deployment
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Execute first asset purchase | Or plan if not ready |
| ⬜ | Record in graph database | Tracked |
| ⬜ | Set up income tracking | Ready for future income |

### M5.3 Monitoring System
| Status | Task | Acceptance Criteria |
|--------|------|---------------------|
| ⬜ | Create monthly data refresh process | Documented procedure |
| ⬜ | Build month-over-month comparison | Working queries |
| ⬜ | Define drift thresholds | Documented |
| ⬜ | Create drift alert queries | Working |
| ⬜ | Build progress dashboard | Summary view |
| ⬜ | Schedule quarterly review | Calendar event |

---

## Backlog / Future Ideas
- [ ] Curation UI (review/edit extractions on device)
- [ ] Support multiple model formats (GGUF, etc.)
- [ ] Batch processing optimization
- [ ] Real-time extraction streaming
- [ ] Cloud sync for curated data
- [ ] Graph visualization on device
- [ ] Natural language to Cypher queries
- [ ] Family member budget allocation views
- [ ] Automated categorization learning

---

## Progress Log

### November 26, 2025
- Project initiated
- Created GitHub repository (AFHJackson/phone-graphrag-framework)
- Created `main` and `feature/family-budget` branches
- Created PROJECT-TODOS.md (this document)
- Created FAMILY-BUDGET-POC.md - Methodology and entity model
- Created FAMILY-BUDGET-PLAN.md - Comprehensive plan with outcomes, goals, milestones, tasks
- Defined two outcomes: Asset Transition and Priority Alignment
- Established observation-first methodology
- Documented agent notes and reminders for continuity

---

*Last Updated: November 26, 2025*
