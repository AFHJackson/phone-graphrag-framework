# Family Budget POC - Comprehensive Project Plan

**Project**: phone-graphrag-framework / Family Budget POC  
**Created**: November 26, 2025  
**Document Type**: Master Project Plan  
**Status**: Active

---

## Document Purpose

This is the **master planning document** for the Family Budget POC. It provides:

1. Clear definition of the two outcomes we're pursuing
2. Goals and objectives that enable those outcomes
3. Practical assessment of our starting point and challenges
4. Detailed milestones with associated accomplishments
5. Comprehensive task breakdown
6. Agent notes for maintaining context and avoiding pitfalls

**This document should be consulted at the start of each work session.**

---

# PART 1: OUTCOMES

## Outcome 1: Asset Transition

### Definition
Transform the household financial model from **salary-dependent expenses** to **asset-funded expenses**.

### Current State
- 100% of bills and expenses funded by earned income (salary)
- Minimal or no income-producing assets
- Zero or negative monthly surplus
- No systematic asset acquisition strategy

### Target State
- Earned income directed primarily toward asset acquisition
- Assets generate income that covers increasing percentage of expenses
- Clear visibility into progress toward full transition
- Sustainable, growing surplus

### Transformation Stages

| Stage | Description | Key Indicator |
|-------|-------------|---------------|
| **Stage 0: Deficit** | Spending exceeds income | Negative monthly balance |
| **Stage 1: Breakeven** | Income equals expenses | Zero monthly balance |
| **Stage 2: Surplus** | Income exceeds expenses | Positive monthly balance |
| **Stage 3: Deploying** | Surplus going to assets | Asset acquisition happening |
| **Stage 4: Producing** | Assets generating income | Asset income > $0 |
| **Stage 5: Transitioning** | Asset income covering expenses | Asset income as % of expenses growing |
| **Stage 6: Transformed** | Asset income covers all expenses | Salary → 100% to assets |

### Key Metrics
- **Monthly Surplus Rate**: (Income - Expenses) / Income
- **Asset Income**: Total income from assets per month
- **Coverage Ratio**: Asset Income / Total Expenses
- **Asset Growth Rate**: Month-over-month asset value change

---

## Outcome 2: Priority Alignment

### Definition
Align actual spending behavior with explicitly declared priorities as a couple.

### Current State
- Priorities not documented or agreed upon
- Spending driven by habit, convenience, or impulse
- Mismatch between "what we say matters" and "what spending shows"
- No framework for financial decision-making

### Target State
- Clear, documented priority framework (evolving, not fixed)
- Spending decisions guided by priority framework
- Regular comparison of actual vs. intended
- Conscious adjustment process when gaps appear

### Alignment Stages

| Stage | Description | Key Indicator |
|-------|-------------|---------------|
| **Stage 0: Blind** | Don't know where money goes | No spending visibility |
| **Stage 1: Visible** | Can see spending by category | Categorized spending data |
| **Stage 2: Revealed** | Know implicit priorities | Revealed priority map |
| **Stage 3: Declared** | Stated explicit priorities | Declared priority map |
| **Stage 4: Compared** | Know the gap | Alignment gap quantified |
| **Stage 5: Adjusting** | Making intentional changes | Active spending modifications |
| **Stage 6: Aligned** | Spending matches priorities | Gap within acceptable range |
| **Stage 7: Evolving** | Continuous refinement | Priority updates, re-alignment |

### Key Metrics
- **Alignment Score**: Weighted measure of spending-to-priority match
- **Gap Amount**: Dollar value in misaligned categories
- **High-Priority Coverage**: % of declared priorities with adequate spending
- **Low-Priority Leakage**: $ spent on items below priority threshold

---

## Outcome Interdependence

These outcomes reinforce each other:

```
Priority Alignment                    Asset Transition
      │                                     │
      │ Identifies low-priority spend       │
      │─────────────────────────────────────►
      │                                     │
      │ Creates surplus for asset deployment│
      │                                     │
      ◄─────────────────────────────────────│
      │ Asset income enables priority       │
      │ spending without salary trade-off   │
      │                                     │
```

**Priority alignment creates the surplus. Asset transition converts surplus into sustainable income.**

---

# PART 2: GOALS AND OBJECTIVES

## Strategic Goals

### Goal 1: Achieve Financial Clarity
**Objective**: Build a complete, accurate, categorized view of all household financial activity.

**Success Criteria**:
- All accounts identified and included
- All transactions from past 12 months captured
- 95%+ transactions categorized
- Spending by category, vendor, and period queryable

### Goal 2: Discover Implicit Priorities
**Objective**: Derive a priority ranking from actual spending behavior.

**Success Criteria**:
- Revealed priority map generated from data
- Top 10 spending categories identified
- Spending trends (growth/decline) identified
- Concentration analysis complete (top vendors, recurring charges)

### Goal 3: Document Explicit Priorities
**Objective**: Create a shared, declared priority framework with spouse.

**Success Criteria**:
- Individual priority lists created
- Couple conversation completed
- Merged priority list with rankings
- Priority definitions documented
- Areas of agreement/disagreement noted

### Goal 4: Quantify Alignment Gap
**Objective**: Measure the difference between revealed and declared priorities.

**Success Criteria**:
- Each category mapped to priority (supports/neutral/conflicts)
- Alignment score calculated
- Over-spend categories identified (low priority, high spend)
- Under-spend categories identified (high priority, low spend)
- Total misalignment in dollars calculated

### Goal 5: Create Asset Surplus
**Objective**: Identify and realize spending reductions to create investable surplus.

**Success Criteria**:
- Reduction candidates ranked by impact and difficulty
- Target monthly surplus defined
- Quick wins implemented
- Surplus amount tracked monthly
- Surplus deployment plan created

### Goal 6: Deploy Surplus to Assets
**Objective**: Convert surplus into income-producing assets.

**Success Criteria**:
- Asset acquisition strategy defined
- First asset purchased
- Asset income tracking established
- Coverage ratio calculated monthly

### Goal 7: Monitor and Adapt
**Objective**: Maintain visibility into progress and catch drift early.

**Success Criteria**:
- Monthly data refresh process working
- Drift alerts defined and functioning
- "Balloon squeeze" detection in place
- Priority evolution process established
- Quarterly review cadence set

---

## Technical Objectives

### Objective T1: Build Data Ingestion Pipeline
Capability to import financial data from multiple sources into unified format.

### Objective T2: Build Entity Extraction Pipeline
Use phone-based LLM to extract entities and relationships from financial text.

### Objective T3: Build Graph Database
Store entities and relationships in PostgreSQL/AGE for querying.

### Objective T4: Build Query Capability
Execute Cypher queries to answer financial questions.

### Objective T5: Build Reporting Capability
Generate human-readable reports from graph data.

### Objective T6: Build Monitoring Capability
Track metrics over time and alert on significant changes.

---

# PART 3: PROBLEM, CHALLENGES, AND STARTING POINT

## The Core Problem

**Statement**: Despite earning more than ever, the household spends at or above income level, has no systematic asset-building strategy, and lacks a shared framework for financial decision-making.

**Impact**: 
- No progress toward financial independence
- Stress from money confusion
- Missed opportunity cost (years of potential asset growth)
- Risk exposure (fully dependent on salary)

## Practical Challenges

### Data Challenges
| Challenge | Description | Mitigation |
|-----------|-------------|------------|
| **Multiple sources** | Data scattered across banks, cards, apps | Build multi-format ingestion |
| **Inconsistent formats** | CSV, Excel, PDF, different schemas | Normalize during ingestion |
| **Categorization ambiguity** | Same vendor could be multiple categories | Manual review + rules engine |
| **Missing data** | Some transactions may not be captured | Gap identification process |
| **Historical gaps** | May not have full 12 months everywhere | Work with available data |

### Technical Challenges
| Challenge | Description | Mitigation |
|-----------|-------------|------------|
| **LLM accuracy** | Entity extraction ~70-80% accurate | Curation step in pipeline |
| **GPU crashes** | Dense numeric data crashes phone | Preprocessing to strip tables |
| **Processing time** | ~90-120 sec per chunk | Batch overnight |
| **Model limitations** | 4B params, may miss nuance | Iterative prompt improvement |

### Human Challenges
| Challenge | Description | Mitigation |
|-----------|-------------|------------|
| **Priority disagreement** | Spouse may have different priorities | Structured conversation process |
| **Emotional attachment** | Some spending tied to identity | Non-judgmental framing |
| **Change resistance** | Habits hard to break | Start with quick wins |
| **Time commitment** | Review and curation takes time | Streamline tooling |

### Process Challenges
| Challenge | Description | Mitigation |
|-----------|-------------|------------|
| **Sustainability** | One-time effort vs. ongoing | Build for monthly refresh |
| **Drift detection** | Changes happen slowly | Automated monitoring |
| **Priority evolution** | Values change over time | Quarterly review cadence |

## Starting Point Assessment

### What We Have
- [ ] Phone hardware (Samsung S25 Ultra) - **Available**
- [ ] Working LLM inference (Gemma 3n via MediaPipe) - **Proven in Mind-Time**
- [ ] Framework architecture pattern (WorkManager, etc.) - **Documented**
- [ ] PostgreSQL/AGE setup - **Documented**
- [ ] Raw financial data - **Partially gathered, needs inventory**

### What We Need to Build
- [ ] Android app for this project (new, separate from Mind-Time)
- [ ] Financial data ingestion scripts
- [ ] Financial-specific extraction prompts
- [ ] Curation tooling
- [ ] Reporting queries
- [ ] Monitoring system

### What We Need to Do (Non-Technical)
- [ ] Complete data gathering (identify gaps)
- [ ] Individual priority brainstorm
- [ ] Couple priority conversation
- [ ] Define asset acquisition strategy

---

# PART 4: MILESTONES AND ACCOMPLISHMENTS

## Milestone Map

```
Week 1-2        Week 2-3        Week 3-4        Week 4-5        Week 5+
   │               │               │               │               │
   ▼               ▼               ▼               ▼               ▼
┌──────┐       ┌──────┐       ┌──────┐       ┌──────┐       ┌──────┐
│ M1   │──────►│ M2   │──────►│ M3   │──────►│ M4   │──────►│ M5   │
│      │       │      │       │      │       │      │       │      │
│Data  │       │Reveal│       │Declare│      │Compare│      │Deploy │
│Ready │       │Prior │       │Prior  │      │& Plan │      │Monitor│
└──────┘       └──────┘       └──────┘       └──────┘       └──────┘
```

---

## Milestone 1: Data Ready

**Target**: End of Week 2  
**Outcome Contribution**: Foundation for both outcomes

### Definition of Done
- All financial accounts identified
- Data exported from all sources
- Data ingested into unified format
- Transactions categorized (auto + manual review)
- Baseline spending map created
- Data in graph database, queryable

### Required Accomplishments

| ID | Accomplishment | Type |
|----|----------------|------|
| A1.1 | Data source inventory complete | Process |
| A1.2 | Data export from all sources | Process |
| A1.3 | Ingestion scripts working | Technical |
| A1.4 | Categorization rules defined | Process |
| A1.5 | Manual categorization review done | Process |
| A1.6 | Graph database loaded | Technical |
| A1.7 | Basic queries returning results | Technical |

---

## Milestone 2: Priorities Revealed

**Target**: End of Week 3  
**Outcome Contribution**: Priority Alignment Stage 2

### Definition of Done
- Spending analyzed by category, vendor, period
- Trends identified (growing, shrinking, stable)
- Concentration analysis complete
- Revealed priority ranking generated
- Report: "What your spending says about priorities"

### Required Accomplishments

| ID | Accomplishment | Type |
|----|----------------|------|
| A2.1 | Category spending totals calculated | Technical |
| A2.2 | Vendor spending analysis complete | Technical |
| A2.3 | Time-series trend analysis done | Technical |
| A2.4 | Spending concentration identified | Analysis |
| A2.5 | Revealed priority algorithm designed | Technical |
| A2.6 | Revealed priority report generated | Technical |

---

## Milestone 3: Priorities Declared

**Target**: End of Week 4  
**Outcome Contribution**: Priority Alignment Stage 3

### Definition of Done
- Individual priority lists created
- Couple priority conversation completed
- Merged priority list with rankings
- Priority definitions documented
- Declared priority map in graph database

### Required Accomplishments

| ID | Accomplishment | Type |
|----|----------------|------|
| A3.1 | Priority conversation guide created | Process |
| A3.2 | Individual priority brainstorm done | Process |
| A3.3 | Couple conversation completed | Process |
| A3.4 | Priority ranking merged | Process |
| A3.5 | Priority definitions written | Process |
| A3.6 | Declared priorities loaded to graph | Technical |

---

## Milestone 4: Gap Quantified & Plan Created

**Target**: End of Week 5  
**Outcome Contribution**: Priority Alignment Stage 4, Asset Transition Stage 2-3

### Definition of Done
- Each category mapped to priorities
- Alignment scores calculated
- Gap quantified in dollars
- Reduction candidates ranked
- Target surplus defined
- Initial adjustments identified
- Asset deployment plan drafted

### Required Accomplishments

| ID | Accomplishment | Type |
|----|----------------|------|
| A4.1 | Category-to-priority mapping done | Process |
| A4.2 | Alignment scoring algorithm working | Technical |
| A4.3 | Gap report generated | Technical |
| A4.4 | Over-spend analysis complete | Analysis |
| A4.5 | Reduction candidate ranking done | Process |
| A4.6 | Target surplus defined | Process |
| A4.7 | Quick wins identified | Process |
| A4.8 | Asset deployment strategy drafted | Process |

---

## Milestone 5: Deployed & Monitoring

**Target**: End of Week 6+  
**Outcome Contribution**: Both outcomes progressing

### Definition of Done
- At least one spending adjustment implemented
- Monthly data refresh process working
- Metrics being tracked
- Drift detection in place
- First asset acquisition planned or executed
- Quarterly review scheduled

### Required Accomplishments

| ID | Accomplishment | Type |
|----|----------------|------|
| A5.1 | First adjustment implemented | Process |
| A5.2 | Month 2 data ingested | Technical |
| A5.3 | Month-over-month comparison working | Technical |
| A5.4 | Drift alerts configured | Technical |
| A5.5 | Asset acquisition executed or planned | Process |
| A5.6 | Progress dashboard created | Technical |
| A5.7 | Quarterly review scheduled | Process |

---

# PART 5: COMPREHENSIVE TASK BREAKDOWN

## Phase 0: Project Infrastructure

### 0.1 Development Environment
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T0.1.1 | Create GitHub repository | ✅ | AFHJackson/phone-graphrag-framework |
| T0.1.2 | Create feature/family-budget branch | ✅ | Working branch |
| T0.1.3 | Set up Android Studio project | ⬜ | Kotlin + Compose |
| T0.1.4 | Configure Gradle dependencies | ⬜ | WorkManager, MediaPipe, Serialization |
| T0.1.5 | Create project package structure | ⬜ | ai/, worker/, ui/, data/ |
| T0.1.6 | Test empty app builds and runs | ⬜ | Sanity check |

### 0.2 Documentation
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T0.2.1 | Create PROJECT-TODOS.md | ✅ | Task tracking |
| T0.2.2 | Create FAMILY-BUDGET-POC.md | ✅ | Methodology doc |
| T0.2.3 | Create this plan document | ✅ | Master plan |
| T0.2.4 | Update README for family budget focus | ⬜ | |

### 0.3 Device Setup
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T0.3.1 | Verify Gemma 3n model on phone | ⬜ | /data/local/tmp/ |
| T0.3.2 | Create permission grant script | ⬜ | Run after each install |
| T0.3.3 | Test ADB file push/pull | ⬜ | Verify paths work |

---

## Phase 1: Data Ingestion (Milestone 1)

### 1.1 Data Inventory
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T1.1.1 | List all bank/checking accounts | ⬜ | |
| T1.1.2 | List all credit cards | ⬜ | |
| T1.1.3 | List all investment accounts | ⬜ | |
| T1.1.4 | List other financial data sources | ⬜ | Amazon, PayPal, etc. |
| T1.1.5 | Identify date ranges available | ⬜ | Target: 12 months |
| T1.1.6 | Identify gaps in data | ⬜ | |
| T1.1.7 | Document export procedures per source | ⬜ | |

### 1.2 Data Export
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T1.2.1 | Export checking account transactions | ⬜ | |
| T1.2.2 | Export savings account transactions | ⬜ | |
| T1.2.3 | Export credit card 1 transactions | ⬜ | |
| T1.2.4 | Export credit card 2 transactions | ⬜ | |
| T1.2.5 | Export investment account activity | ⬜ | |
| T1.2.6 | Export Amazon order history | ⬜ | |
| T1.2.7 | Export any other sources | ⬜ | |
| T1.2.8 | Organize exports in /data/raw/ | ⬜ | |

### 1.3 Ingestion Pipeline
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T1.3.1 | Create unified transaction schema | ⬜ | date, amount, description, account, category |
| T1.3.2 | Write CSV parser | ⬜ | Handle multiple bank formats |
| T1.3.3 | Write Excel parser | ⬜ | |
| T1.3.4 | Write Amazon parser | ⬜ | |
| T1.3.5 | Create normalization layer | ⬜ | Convert all to unified schema |
| T1.3.6 | Output unified transactions.json | ⬜ | |
| T1.3.7 | Validate ingestion (spot check) | ⬜ | |

### 1.4 Categorization
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T1.4.1 | Define category taxonomy | ⬜ | Hierarchical categories |
| T1.4.2 | Create vendor → category mapping rules | ⬜ | Auto-categorization |
| T1.4.3 | Run auto-categorization | ⬜ | |
| T1.4.4 | Generate uncategorized list | ⬜ | |
| T1.4.5 | Manual categorization review | ⬜ | |
| T1.4.6 | Update rules from manual review | ⬜ | |
| T1.4.7 | Validate categorization coverage | ⬜ | Target: 95%+ |

### 1.5 Chunking for LLM
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T1.5.1 | Design chunk format | ⬜ | What text to feed LLM |
| T1.5.2 | Create chunking script | ⬜ | |
| T1.5.3 | Generate chunks.json | ⬜ | |
| T1.5.4 | Preprocess chunks (strip numeric tables) | ⬜ | Avoid GPU crash |

### 1.6 Entity Extraction (Phone)
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T1.6.1 | Create financial extraction prompt | ⬜ | Tuned for budget domain |
| T1.6.2 | Push chunks to phone | ⬜ | /sdcard/graphrag/input/ |
| T1.6.3 | Run extraction worker | ⬜ | |
| T1.6.4 | Pull results from phone | ⬜ | |
| T1.6.5 | Curate extraction results | ⬜ | Fix entity types, merge duplicates |

### 1.7 Graph Loading
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T1.7.1 | Start PostgreSQL + AGE | ⬜ | Docker |
| T1.7.2 | Create graph schema | ⬜ | Node labels, edge types |
| T1.7.3 | Write graph loader script | ⬜ | |
| T1.7.4 | Load entities and relationships | ⬜ | |
| T1.7.5 | Validate with test queries | ⬜ | |

---

## Phase 2: Analysis & Revelation (Milestone 2)

### 2.1 Spending Analysis Queries
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T2.1.1 | Query: Total spend by category | ⬜ | |
| T2.1.2 | Query: Total spend by vendor | ⬜ | |
| T2.1.3 | Query: Spend by month | ⬜ | |
| T2.1.4 | Query: Category trends over time | ⬜ | |
| T2.1.5 | Query: Top 10 vendors | ⬜ | |
| T2.1.6 | Query: Recurring transactions | ⬜ | |
| T2.1.7 | Query: Large one-time expenses | ⬜ | |

### 2.2 Revealed Priority Analysis
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T2.2.1 | Design revealed priority algorithm | ⬜ | Spend amount + frequency |
| T2.2.2 | Implement priority scoring | ⬜ | |
| T2.2.3 | Generate revealed priority ranking | ⬜ | |
| T2.2.4 | Create revealed priority report | ⬜ | Human-readable |
| T2.2.5 | Review and annotate findings | ⬜ | |

---

## Phase 3: Priority Declaration (Milestone 3)

### 3.1 Conversation Preparation
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T3.1.1 | Create priority brainstorm template | ⬜ | Individual exercise |
| T3.1.2 | Create couple conversation guide | ⬜ | Structured discussion |
| T3.1.3 | Complete individual brainstorm (self) | ⬜ | |
| T3.1.4 | Complete individual brainstorm (spouse) | ⬜ | |

### 3.2 Priority Documentation
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T3.2.1 | Conduct couple conversation | ⬜ | |
| T3.2.2 | Merge priority lists | ⬜ | |
| T3.2.3 | Create priority ranking | ⬜ | |
| T3.2.4 | Write priority definitions | ⬜ | |
| T3.2.5 | Note disagreement areas | ⬜ | |
| T3.2.6 | Load declared priorities to graph | ⬜ | |

---

## Phase 4: Gap Analysis & Planning (Milestone 4)

### 4.1 Alignment Analysis
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T4.1.1 | Map categories to priorities | ⬜ | supports/neutral/conflicts |
| T4.1.2 | Design alignment scoring | ⬜ | |
| T4.1.3 | Calculate alignment scores | ⬜ | |
| T4.1.4 | Identify over-spend categories | ⬜ | Low priority, high spend |
| T4.1.5 | Identify under-spend categories | ⬜ | High priority, low spend |
| T4.1.6 | Generate alignment gap report | ⬜ | |

### 4.2 Surplus Planning
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T4.2.1 | Rank reduction candidates | ⬜ | By impact and difficulty |
| T4.2.2 | Estimate realistic savings per item | ⬜ | |
| T4.2.3 | Calculate potential monthly surplus | ⬜ | |
| T4.2.4 | Identify quick wins | ⬜ | Easy, high impact |
| T4.2.5 | Define target surplus amount | ⬜ | |
| T4.2.6 | Create surplus action plan | ⬜ | |

### 4.3 Asset Strategy
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T4.3.1 | Research asset options | ⬜ | Index funds, dividend stocks, etc. |
| T4.3.2 | Define asset acquisition criteria | ⬜ | |
| T4.3.3 | Create deployment plan | ⬜ | What to buy, when |
| T4.3.4 | Set up asset tracking in graph | ⬜ | |

---

## Phase 5: Execution & Monitoring (Milestone 5)

### 5.1 First Adjustments
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T5.1.1 | Implement quick win #1 | ⬜ | |
| T5.1.2 | Implement quick win #2 | ⬜ | |
| T5.1.3 | Track adjustment impact | ⬜ | |

### 5.2 Asset Deployment
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T5.2.1 | Execute first asset purchase | ⬜ | |
| T5.2.2 | Record in graph database | ⬜ | |
| T5.2.3 | Set up income tracking | ⬜ | |

### 5.3 Monitoring System
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| T5.3.1 | Create monthly data refresh process | ⬜ | |
| T5.3.2 | Build month-over-month comparison | ⬜ | |
| T5.3.3 | Define drift thresholds | ⬜ | |
| T5.3.4 | Create drift alert queries | ⬜ | |
| T5.3.5 | Build progress dashboard | ⬜ | |
| T5.3.6 | Schedule quarterly review | ⬜ | |

---

## Android App Tasks (Technical)

### App Infrastructure
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| TA.1 | Create Android project | ⬜ | |
| TA.2 | Configure build.gradle | ⬜ | |
| TA.3 | Set up package structure | ⬜ | |
| TA.4 | Add manifest permissions | ⬜ | |
| TA.5 | Create MainActivity | ⬜ | |

### LiteRT Integration
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| TA.6 | Create LiteRTService | ⬜ | MediaPipe wrapper |
| TA.7 | Implement model loading | ⬜ | /data/local/tmp/ |
| TA.8 | Implement text generation | ⬜ | |
| TA.9 | Add timeout handling | ⬜ | 3 minutes |
| TA.10 | Test with simple prompt | ⬜ | |

### File Management
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| TA.11 | Create GraphRAGFileManager | ⬜ | |
| TA.12 | Implement readChunks() | ⬜ | |
| TA.13 | Implement writeResult() | ⬜ | |
| TA.14 | Implement progress tracking | ⬜ | |

### Worker
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| TA.15 | Create GraphRAGWorker | ⬜ | |
| TA.16 | Implement doWork() | ⬜ | |
| TA.17 | Add notifications | ⬜ | |
| TA.18 | Implement graceful failure | ⬜ | |
| TA.19 | Add resume capability | ⬜ | |

### Preprocessing
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| TA.20 | Create ChunkPreprocessor | ⬜ | |
| TA.21 | Implement stripTableRows() | ⬜ | |
| TA.22 | Implement truncation | ⬜ | |

### UI
| Task ID | Task | Status | Notes |
|---------|------|--------|-------|
| TA.23 | Create GraphRAGActivity | ⬜ | |
| TA.24 | Add start/stop buttons | ⬜ | |
| TA.25 | Add status display | ⬜ | |
| TA.26 | Add progress indicator | ⬜ | |

---

# PART 6: AGENT NOTES AND REMINDERS

## Critical Technical Reminders

### Model Path
```
ALWAYS use: /data/local/tmp/gemma-3n-E4B-it-int4.litertlm
NEVER use: /sdcard/ for model files
```

### Permissions After Install
```bash
# Run after EVERY adb install:
adb shell pm grant <package> android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant <package> android.permission.WRITE_EXTERNAL_STORAGE
adb shell appops set <package> MANAGE_EXTERNAL_STORAGE allow
```

### GPU Crash Prevention
- Strip lines with >30% digits before sending to LLM
- Financial data is HIGH RISK for this issue
- Always preprocess transaction data

### Timeout Handling
- 3-minute timeout on LLM inference
- Some prompts cause infinite generation
- Graceful failure, save error, continue

## Process Reminders

### Observation Before Judgment
**Don't rush to declare priorities.** Let the data speak first. The user explicitly wants to discover implicit priorities before stating explicit ones.

### Priorities Are Mutable
**Nothing is a monument.** The priority framework will evolve. Build for change, not permanence.

### Watch for Balloon Squeeze
When cutting in one category, watch for unexpected increases in others. The problem doesn't disappear, it shifts.

### Two Transformations
Remember there are TWO parallel transformations:
1. Revenue source (salary → assets)
2. Expense alignment (current → priority-aligned)

Don't conflate them. Track them separately.

### Non-Linear Opportunities
Stay alert for causal relationships:
- "We spend $X on Y because of constraint Z"
- Addressing Z might unlock more than just cutting Y
- The graph should help surface these connections

## Conversation Notes

### User Context
- Couple household
- Higher income than ever, but no surplus
- Feeling of confusion/frustration about finances
- Goal: financial independence (assets funding expenses)
- Wants both clarity AND action
- Values understanding WHY, not just WHAT

### User Preferences
- Methodical, structured approach
- Wants to see progress tracked
- Values documentation
- Open to evolving understanding
- Wants framework that supports spouse involvement

## Success Indicators

### Signs We're On Track
- User can see where money goes
- User can articulate revealed vs. declared priority gap
- Monthly surplus is positive and growing
- At least one asset acquisition made
- Drift detection catching issues before they compound

### Signs We're Off Track
- Data gathering stalled
- Categorization incomplete
- Priority conversation not happening
- Surplus not materializing
- "Balloon squeeze" not being caught

## Questions to Revisit

1. What asset types will provide best income-to-effort ratio?
2. How to handle spouse priority disagreements constructively?
3. What's the minimum viable monitoring frequency?
4. How to make quarterly priority evolution systematic?
5. What non-financial factors affect spending (time, convenience, emotions)?

---

*Document Version: 1.0*  
*Last Updated: November 26, 2025*  
*Next Review: After Milestone 1 completion*
