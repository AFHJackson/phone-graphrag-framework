# Family Budget Proof-of-Concept

**Project**: phone-graphrag-framework  
**POC Focus**: Family Financial Transformation  
**Created**: November 26, 2025  
**Status**: Active Development

---

## Executive Summary

This POC uses the phone-based GraphRAG framework to build a **Financial Transformation System** that enables two interconnected outcomes:

1. **Asset Transition**: Shift from salary-funded expenses to asset-funded expenses
2. **Priority Alignment**: Align actual spending with declared values

The approach is **observation-first**: we let data reveal implicit priorities before declaring explicit ones, then work to close the gap while creating space for asset building.

---

## Table of Contents

1. [The Problem](#the-problem)
2. [The Vision](#the-vision)
3. [Two Outcomes](#two-outcomes)
4. [Methodology: Observation-First](#methodology-observation-first)
5. [Entity & Relationship Model](#entity--relationship-model)
6. [Phased Approach](#phased-approach)
7. [Success Criteria](#success-criteria)
8. [Technical Architecture](#technical-architecture)

---

## The Problem

### Situation
- Household income is higher than ever
- Yet spending exceeds income or leaves no surplus
- Feeling of financial confusion despite high earnings
- Priorities as a couple are not documented or aligned
- 100% of expenses are funded by earned income (salary)
- No systematic path to financial independence

### Core Challenges
1. **Clarity Gap**: Don't fully understand where money goes
2. **Alignment Gap**: Spending doesn't reflect stated values
3. **Surplus Gap**: No margin for asset creation
4. **Visibility Gap**: Can't see progress or drift over time

### Root Cause Hypothesis
Without a clear, shared framework for financial priorities, spending decisions are made ad-hoc, driven by convenience, habit, or implicit assumptions rather than intentional alignment with long-term goals.

---

## The Vision

### Current State
```
┌─────────────────────────────────────────┐
│           CURRENT STATE                 │
│                                         │
│   Salary ─────────► Bills & Expenses    │
│     │                                   │
│     └── 100% consumed                   │
│                                         │
│   Assets: Minimal / Not producing       │
│   Surplus: Zero or negative             │
│   Priority clarity: Low                 │
└─────────────────────────────────────────┘
```

### Future State
```
┌─────────────────────────────────────────┐
│           FUTURE STATE                  │
│                                         │
│   Salary ─────────► Asset Acquisition   │
│                          │              │
│                          ▼              │
│                       Assets            │
│                          │              │
│                          ▼              │
│   Asset Proceeds ───► Bills & Expenses  │
│                                         │
│   Surplus: Positive and growing         │
│   Priority clarity: High and evolving   │
└─────────────────────────────────────────┘
```

### Transformation Path
The transition is gradual, not instant:
1. Create surplus through priority-aligned spending reduction
2. Deploy surplus to income-producing assets
3. As asset income grows, shift expense burden from salary to assets
4. Eventually, salary → 100% assets, assets → 100% expenses

---

## Two Outcomes

### Outcome 1: Asset Transition

**Definition**: Transform from a salary-dependent expense model to an asset-funded expense model.

**Key Metrics**:
- Monthly surplus (income - expenses)
- Asset acquisition rate
- Asset income as % of total income
- Asset income as % of expenses covered

**Milestones**:
| Milestone | Definition |
|-----------|------------|
| Surplus Created | Consistent positive monthly surplus |
| First Asset Deployed | Surplus used to acquire income-producing asset |
| Asset Income Started | Assets generating measurable income |
| 10% Coverage | Asset income covers 10% of expenses |
| 25% Coverage | Asset income covers 25% of expenses |
| 50% Coverage | Asset income covers 50% of expenses |
| Full Transition | Asset income covers 100% of expenses |

### Outcome 2: Priority Alignment

**Definition**: Align actual spending patterns with explicitly declared priorities as a couple.

**Key Metrics**:
- Gap between revealed vs. declared priorities
- % of spending in "aligned" categories
- % of spending in "misaligned" categories
- Priority stability (how much priorities shift month-over-month)

**Milestones**:
| Milestone | Definition |
|-----------|------------|
| Spending Mapped | All transactions categorized |
| Priorities Revealed | Implicit priorities derived from data |
| Priorities Declared | Explicit priorities documented |
| Gap Identified | Misalignment quantified |
| Adjustments Made | Spending changes implemented |
| Alignment Improved | Gap reduced by measurable amount |
| Priorities Evolved | Second iteration of priority refinement |

---

## Methodology: Observation-First

### Why Observation-First?

Traditional budgeting fails because it asks you to declare priorities before you understand your actual behavior. This leads to:
- Unrealistic budgets that are abandoned
- Guilt about "failing" to meet arbitrary targets
- No learning about what you actually value

**Our approach**: Let the data reveal implicit priorities first, then consciously decide what to change.

### The Two Priority Views

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   REVEALED PRIORITIES              DECLARED PRIORITIES          │
│   (What spending shows)            (What you say matters)       │
│                                                                 │
│   Derived from:                    Captured from:               │
│   • Spending amounts               • Your stated values         │
│   • Spending frequency             • Goals you articulate       │
│   • Category patterns              • Couple conversations       │
│   • Vendor concentrations          • Life stage needs           │
│                                                                 │
│              │                              │                   │
│              └──────────┬───────────────────┘                   │
│                         ▼                                       │
│                  GAP ANALYSIS                                   │
│           "Your spending says X,                                │
│            but you say you value Y"                             │
│                         │                                       │
│                         ▼                                       │
│              ADJUSTMENT CANDIDATES                              │
│           Specific, actionable changes                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Continuous Refinement Loop

```
    ┌─────────────────────────────────────────────────────────┐
    │                                                         │
    ▼                                                         │
┌───────┐    ┌───────────┐    ┌────────┐    ┌──────────┐     │
│OBSERVE│───►│ REFLECT   │───►│ DECLARE│───►│ COMPARE  │     │
│       │    │           │    │        │    │          │     │
│ Ingest│    │ What does │    │ What   │    │ Find the │     │
│ data  │    │ data say? │    │ do we  │    │ gaps     │     │
└───────┘    └───────────┘    │ want?  │    └────┬─────┘     │
                              └────────┘         │           │
                                                 ▼           │
┌────────┐    ┌───────────┐    ┌────────┐    ┌──────────┐   │
│ REFINE │◄───│ MONITOR   │◄───│ DEPLOY │◄───│ IDENTIFY │   │
│        │    │           │    │        │    │          │   │
│ Update │    │ Watch for │    │ Make   │    │ Find     │   │
│ model  │    │ drift     │    │ changes│    │ surplus  │   │
└───┬────┘    └───────────┘    └────────┘    └──────────┘   │
    │                                                        │
    └────────────────────────────────────────────────────────┘
```

---

## Entity & Relationship Model

### Core Entities (Observable Facts)

| Entity | Description | Attributes |
|--------|-------------|------------|
| **Account** | Container where money lives | name, type (checking/savings/credit/investment), institution |
| **Transaction** | Atomic money movement | date, amount, description, account_id |
| **Category** | Spending/income classification | name, type (income/expense/transfer), parent_category |
| **Vendor** | Who receives/sends money | name, normalized_name, category_hint |
| **Period** | Time bucket | start_date, end_date, type (month/quarter/year) |
| **Asset** | Value-producing holding | name, type, acquisition_date, cost_basis, current_value |

### Derived Entities (Interpretations)

| Entity | Description | Attributes |
|--------|-------------|------------|
| **Priority** | What matters (declared or revealed) | name, source (revealed/declared), rank, notes |
| **AlignmentScore** | How category aligns to priorities | category_id, priority_id, alignment (-1 to +1), rationale |
| **Opportunity** | Identified optimization | category_id, type (reduce/eliminate/shift), potential_savings, difficulty |
| **Milestone** | Progress checkpoint | name, target_value, current_value, target_date, status |
| **Insight** | Discovered pattern or anomaly | type, description, related_entities, action_suggested |

### Relationships

| Relationship | From | To | Purpose |
|--------------|------|-----|---------|
| `flows_from` | Transaction | Account | Money source |
| `flows_to` | Transaction | Account | Money destination |
| `categorized_as` | Transaction | Category | Classification |
| `paid_to` | Transaction | Vendor | Attribution |
| `in_period` | Transaction | Period | Time bucketing |
| `implies_priority` | Category | Priority | Revealed priority (data-derived) |
| `assigned_priority` | Category | Priority | Declared priority (user-set) |
| `child_of` | Category | Category | Category hierarchy |
| `produces_income` | Asset | Category | Asset → income linkage |
| `supports` | Category | Priority | Positive alignment |
| `conflicts` | Category | Priority | Negative alignment |
| `blocks` | Opportunity | Milestone | Dependencies |
| `enables` | Opportunity | Milestone | Contributions |

### Example Graph Structure

```
                    ┌──────────────────┐
                    │ Priority:        │
                    │ "Financial       │
                    │  Independence"   │
                    └────────▲─────────┘
                             │ supports
                    ┌────────┴─────────┐
                    │ Category:        │
                    │ "Investment      │
                    │  Contributions"  │
                    └────────▲─────────┘
                             │ categorized_as
         ┌───────────────────┼───────────────────┐
         │                   │                   │
┌────────┴───────┐  ┌────────┴───────┐  ┌───────┴────────┐
│ Transaction:   │  │ Transaction:   │  │ Transaction:   │
│ $500 to        │  │ $500 to        │  │ $200 to        │
│ Vanguard       │  │ Fidelity       │  │ Robinhood      │
└────────────────┘  └────────────────┘  └────────────────┘
```

---

## Phased Approach

### Phase 1: Observe (Week 1-2)
**Goal**: Build complete, honest picture without imposing structure

**Activities**:
- Gather all financial data sources
- Ingest into unified format
- Auto-categorize transactions
- Manual review and correction
- Create baseline spending map

**Outputs**:
- Complete transaction dataset
- Category-level spending summary
- Vendor-level spending summary
- Time-series spending trends

### Phase 2: Reflect (Week 2-3)
**Goal**: Discover implicit priorities from spending patterns

**Activities**:
- Rank categories by total spend
- Identify spending concentrations
- Analyze frequency patterns
- Look for trends (growing/shrinking)
- Generate "revealed priority" list

**Outputs**:
- Revealed Priority Map
- Category importance ranking
- Spending trend analysis
- Concentration report (top 10 vendors, etc.)

### Phase 3: Declare (Week 3-4)
**Goal**: Articulate explicit priorities

**Activities**:
- Individual priority brainstorm
- Couple conversation (structured)
- Create priority categories
- Rank priorities
- Document rationale

**Outputs**:
- Declared Priority Map v1
- Priority definitions
- Priority ranking with rationale
- Areas of agreement/disagreement

### Phase 4: Compare (Week 4)
**Goal**: Quantify the alignment gap

**Activities**:
- Map categories to priorities
- Calculate alignment scores
- Identify over-spending (low priority, high spend)
- Identify under-spending (high priority, low spend)
- Quantify total misalignment

**Outputs**:
- Alignment Gap Report
- Over-spend categories ranked
- Under-spend categories ranked
- Misalignment dollar amount

### Phase 5: Identify Space (Week 5)
**Goal**: Find asset creation surplus

**Activities**:
- Rank reduction candidates
- Estimate realistic savings
- Identify quick wins vs. hard changes
- Calculate potential monthly surplus
- Identify non-linear opportunities

**Outputs**:
- Surplus Opportunity Analysis
- Ranked reduction candidates
- Projected monthly surplus
- Opportunity difficulty assessment

### Phase 6: Deploy & Monitor (Ongoing)
**Goal**: Execute and watch for drift

**Activities**:
- Implement spending changes
- Track monthly actuals vs. baseline
- Monitor for "balloon squeeze"
- Deploy surplus to assets
- Track asset growth and income
- Refine priorities based on learning

**Outputs**:
- Monthly Progress Report
- Drift Alert Report
- Asset Growth Tracker
- Priority Evolution Log

---

## Success Criteria

### POC Success (Technical)
- [ ] Can ingest multiple data formats (CSV, Excel, PDF)
- [ ] Entities and relationships correctly extracted
- [ ] Graph database populated and queryable
- [ ] Queries return accurate, useful results
- [ ] Process is repeatable for monthly updates

### Outcome 1 Success (Asset Transition)
- [ ] Monthly surplus identified and quantified
- [ ] First asset acquisition planned
- [ ] Asset income tracking established
- [ ] Progress toward % coverage visible

### Outcome 2 Success (Priority Alignment)
- [ ] Revealed priorities documented
- [ ] Declared priorities documented
- [ ] Gap quantified in dollar terms
- [ ] At least one adjustment implemented
- [ ] Alignment improvement measurable

---

## Technical Architecture

### Data Flow
```
┌──────────────────────────────────────────────────────────────────┐
│                         LAPTOP                                   │
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────┐  │
│  │ Raw Data    │    │ Chunking    │    │ PostgreSQL + AGE    │  │
│  │ (CSV, XLSX, │───►│ & Prep      │───►│ Graph Database      │  │
│  │  PDF)       │    │ (Python)    │    │                     │  │
│  └─────────────┘    └─────────────┘    └──────────▲──────────┘  │
│                            │                      │             │
│                            │ chunks.json          │ entities    │
│                            ▼                      │ .json       │
│                     ┌─────────────────────────────┴──────┐      │
│                     │           ADB Bridge               │      │
│                     └─────────────────────────────┬──────┘      │
└───────────────────────────────────────────────────│─────────────┘
                                                    │
                                                    │ USB
                                                    ▼
┌───────────────────────────────────────────────────────────────┐
│                    SAMSUNG S25 ULTRA                          │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              GraphRAG Processor App                    │  │
│  │                                                        │  │
│  │  Gemma 3n E4B (4B params) → Entity Extraction          │  │
│  │                                                        │  │
│  │  Input: chunks.json                                    │  │
│  │  Output: entities per chunk                            │  │
│  └────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

### Key Components
1. **Data Ingestion** (Laptop/Python): Parse CSV, Excel, PDF into unified format
2. **Chunking** (Laptop/Python): Prepare text chunks for LLM processing
3. **Entity Extraction** (Phone/Gemma 3n): Extract entities and relationships
4. **Graph Loading** (Laptop/Python): Load curated entities into PostgreSQL/AGE
5. **Query Interface** (Laptop): Cypher queries for analysis
6. **Reporting** (Laptop): Generate insights and reports

---

## Appendix: Prompt Templates

### Entity Extraction Prompt (Financial)
```
Extract financial entities and relationships from this text.

Entity types to identify:
- Account: Bank accounts, credit cards, investment accounts
- Transaction: Individual money movements
- Category: Spending or income classification
- Vendor: Business or person receiving/sending money
- Amount: Dollar amounts
- Date: Transaction dates
- Person: Family members

Relationship types:
- transaction_from_account: Which account money came from
- transaction_to_vendor: Who received the money
- transaction_in_category: How the transaction is classified
- transaction_on_date: When it occurred
- transaction_amount: How much

Return JSON:
{
  "entities": [
    {"name": "...", "type": "Account|Transaction|Category|Vendor|Amount|Date|Person"}
  ],
  "relationships": [
    {"source": "...", "target": "...", "type": "..."}
  ]
}

Text:
{chunk_content}

JSON:
```

---

*Document Version: 1.0*  
*Last Updated: November 26, 2025*
