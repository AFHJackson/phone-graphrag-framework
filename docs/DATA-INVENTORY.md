# Data Inventory

**Project**: phone-graphrag-framework / Family Budget POC  
**Created**: November 27, 2025  
**Status**: In Progress

---

## Overview

This document catalogs all financial data sources available for the Family Budget analysis, their relationships, and any gaps or considerations.

### Key Insight: Account Flow Structure

The data reveals a hierarchical flow pattern:

```
INCOME SOURCES                    OUTLAY ACCOUNTS                 DESTINATION ACCOUNTS
──────────────────               ──────────────────              ──────────────────────
                                                                 
USSF Salary ─────────┐                                           ┌──► Direct Bills
BCPS Salary ─────────┼──────► BOA Billing Account ──────────────┼──► BOA Credit Card
CB Salary ───────────┘              │                            ├──► Chase Credit Card
                                    │                            └──► Amazon (as pseudo-account)
                                    │                                      │
                                    │                                      ▼
                                    └──────► BOA Spending Account    Individual Purchases
                                                   │
                                                   ▼
                                             Day-to-day expenses
```

### Transfer Reconciliation Requirement

Transfers between accounts should NOT be treated as independent expenditures. They must be reconciled:
- BOA Billing → Chase Card (should match 1:1)
- BOA Billing → Amazon payments (resolves to individual Amazon orders)
- BOA Billing → BOA Credit Card payments
- BOA Billing → BOA Spending transfers

---

## Data Sources

### 1. Income Sources

#### 1.1 USSF Leave and Earning Statement (LES)
| Attribute | Value |
|-----------|-------|
| **Description** | Representative pay stub showing gross pay, taxes, and deductions |
| **Purpose** | Explains gap between annual salary and net deposit amount |
| **Format** | PDF |
| **Date Range** | 09/26/2025 (single representative sample) |
| **Key Fields** | Gross pay, Federal tax, State tax, FICA, Retirement, TSP, Insurance, Net pay |
| **Status** | ⬜ To be collected |

#### 1.2 Income Sources Summary
| Attribute | Value |
|-----------|-------|
| **Description** | Summary of all household income sources |
| **Purpose** | Master income reference for budgeting |
| **Format** | XLSX |
| **Date Range** | 2025 (annual and monthly rates) |
| **Sources Included** | USSF, BCPS, City of Cocoa Beach |
| **Key Fields** | Source name, Annual rate, Monthly rate |
| **Status** | ⬜ To be collected |

---

### 2. Bank Accounts (Bank of America)

#### 2.1 BOA Billing Account
| Attribute | Value |
|-----------|-------|
| **Description** | Primary account for bill payments |
| **Purpose** | Bills, some expenses, transfers to other accounts |
| **Format** | CSV |
| **Date Range** | October 1, 2024 → Present |
| **Key Fields** | Date, Description, Amount, Balance (TBD after review) |
| **Outflows To** | Chase Card, Amazon, BOA Credit Card, BOA Spending, Direct bills |
| **Status** | ⬜ To be collected |

#### 2.2 BOA Spending Account
| Attribute | Value |
|-----------|-------|
| **Description** | Day-to-day spending account |
| **Purpose** | Daily expenses, small purchases |
| **Format** | CSV |
| **Date Range** | October 1, 2024 → Present |
| **Key Fields** | TBD after review |
| **Inflows From** | BOA Billing Account |
| **Status** | ⬜ To be collected |

#### 2.3 BOA Credit Card
| Attribute | Value |
|-----------|-------|
| **Description** | Credit card for expenses |
| **Purpose** | Expenses, some bills |
| **Format** | CSV |
| **Date Range** | November 11, 2024 → Present |
| **Key Fields** | TBD after review |
| **Inflows From** | BOA Billing Account (payments) |
| **Note** | Shorter date range than other BOA accounts |
| **Status** | ⬜ To be collected |

---

### 3. Credit Cards (External)

#### 3.1 Chase Credit Card
| Attribute | Value |
|-----------|-------|
| **Description** | Credit card paid from BOA Billing |
| **Purpose** | Expenses (purpose unclear from BOA view alone) |
| **Format** | XLSX |
| **Date Range** | October 1, 2024 → Present |
| **Key Fields** | TBD after review |
| **Inflows From** | BOA Billing Account (should match 1:1) |
| **Reconciliation** | Chase payments in BOA Billing should match Chase statement |
| **Status** | ⬜ To be collected |

---

### 4. Marketplace Accounts

#### 4.1 Amazon Orders
| Attribute | Value |
|-----------|-------|
| **Description** | Detailed order history from Amazon |
| **Purpose** | Resolves "Amazon" line items from BOA into actual purchases |
| **Format** | Mixed (PDF, Excel, Images, JSON) |
| **Date Range** | Extensive history (back to 2004), but focus on Oct 2024+ |
| **Key Fields** | Order date, Items, Categories, Amounts |
| **Reconciliation** | Amazon charges in BOA should map to specific orders |
| **Status** | ⬜ To be collected |

##### Amazon Account Types (Important Distinction)

| Type | Description | Treatment |
|------|-------------|-----------|
| **Amazon Marketplace** | Third-party purchases via Amazon | Treat as "transfer to Amazon pseudo-account" → individual purchases |
| **Amazon Services** | Amazon's own products (Music, Audible, Prime, etc.) | Treat as direct expense TO Amazon |

---

## Date Range Coverage

| Source | Start Date | End Date | Months |
|--------|------------|----------|--------|
| BOA Billing | Oct 1, 2024 | Present | ~14 |
| BOA Spending | Oct 1, 2024 | Present | ~14 |
| BOA Credit Card | Nov 11, 2024 | Present | ~12.5 |
| Chase Credit Card | Oct 1, 2024 | Present | ~14 |
| Amazon Orders | 2004 | Present | Focus Oct 2024+ |
| Income Summary | 2025 | 2025 | 12 (rates) |
| LES | Sep 26, 2025 | Sep 26, 2025 | 1 sample |

### Coverage Gap
- **BOA Credit Card** starts Nov 11, 2024 (missing Oct 1 - Nov 10, 2024)
- **Income data** is 2025 only; if income changed in late 2024, we may need to note this

---

## Reconciliation Requirements

### Transfer Matching

These transfers should match 1:1 and should NOT be counted as independent expenses:

| From | To | Reconciliation Method |
|------|-----|----------------------|
| BOA Billing | Chase Card | Match transfer amounts to Chase payments received |
| BOA Billing | BOA Credit Card | Internal BOA transfer matching |
| BOA Billing | BOA Spending | Internal BOA transfer matching |
| BOA Billing | Amazon | Match to Amazon order totals |
| BOA Credit Card | Amazon | Match to Amazon order totals |

### Double-Counting Prevention

When loading to graph:
1. **Transfers** create `transfer_to` relationships but are NOT categorized as expenses
2. **Terminal expenses** (actual purchases/bills) ARE categorized
3. **Amazon marketplace purchases** are the terminal expense, not the BOA→Amazon transfer

---

## Entity Types Emerging from Data

Based on this inventory, we can identify these entity types:

| Entity Type | Examples | Source |
|-------------|----------|--------|
| **IncomeSource** | USSF, BCPS, City of Cocoa Beach | Income Summary |
| **Account** | BOA Billing, BOA Spending, BOA CC, Chase CC | All transaction files |
| **PseudoAccount** | Amazon | Conceptual - for marketplace purchases |
| **Transaction** | Individual line items | All transaction files |
| **Vendor** | Amazon, Netflix, Electric Company, etc. | Transaction descriptions |
| **Category** | Bills, Groceries, Entertainment, etc. | To be designed |
| **Deduction** | Federal Tax, FICA, TSP, Insurance | LES |
| **AmazonOrder** | Individual Amazon purchases | Amazon Orders |
| **AmazonService** | Music, Audible, Prime | Amazon Orders |

---

## Relationship Types Emerging from Data

| Relationship | From | To | Meaning |
|--------------|------|-----|---------|
| `deposits_to` | IncomeSource | Account | Salary deposits |
| `transfer_to` | Account | Account | Money movement (not expense) |
| `payment_to` | Account | Vendor | Terminal expense |
| `resolves_to` | Transaction | AmazonOrder[] | BOA Amazon charge → actual orders |
| `categorized_as` | Transaction | Category | Expense classification |
| `deducted_as` | Deduction | IncomeSource | Pre-deposit deductions |

---

## Questions / Gaps - RESOLVED

### User Responses (Nov 27, 2025)

1. **BOA Credit Card gap**: This is as far back as BOA will provide without a special request.
   - **Decision**: Normalize all data to trailing 12 months (Nov 27, 2024 → Nov 27, 2025) for clean analysis.

2. **Income changes**: USSF and BCPS salaries escalate annually. CB Commissioner salary stays flat.
   - **Decision**: Use 2025 rates as baseline. Note that salaries trend upward over time.

3. **Other income**: No other income sources to include currently.

4. **Savings/Investment accounts**: Has Betterment and Fidelity accounts, but defer until Phase 4 (Asset Strategy).
   - **Decision**: Focus on cash flow first. Add investment accounts when planning asset deployment.

5. **Amazon format**: User did a data request from Amazon; received significant volume of mixed formats.
   - **Decision**: I will review and identify most useful formats.

6. **Recurring bills**: User has a manual list including giving/donations. Variable bills (electric, water) averaged over 12 months.
   - **Decision**: Will compare data-derived bills to user's manual list.

---

## Bills vs Expenses Framework

**User's valuable distinction** - incorporated into category taxonomy design:

| Type | Definition | Characteristics | Adjustment Mechanism |
|------|------------|-----------------|---------------------|
| **Bills** | Recurring, lump-sum within a period | Limited per-transaction control; must dial back service level | Change subscription tier, reduce usage over time, cancel service |
| **Expenses** | Discrete purchases with visible cost-to-value | Fine-grain transaction decisions; independent choices | Choose cheaper option per transaction, buy less frequently |

### Examples

| Bills (Recurring, Service-Level Adjustments) | Expenses (Discrete, Transaction-Level Decisions) |
|---------------------------------------------|--------------------------------------------------|
| Electric utility | Groceries |
| Water utility | Restaurant meals |
| Streaming subscriptions | Retail purchases |
| Insurance premiums | Gas/fuel |
| Giving/donations (committed) | Entertainment |
| Phone/internet service | Amazon marketplace items |

### Implication for Analysis
- **Bills**: Identify total monthly commitment, look for service-level reduction opportunities
- **Expenses**: Analyze per-transaction patterns, look for volume/choice optimization

---

## Data Normalization Decision

**Analysis Window**: Trailing 12 months (November 27, 2024 → November 27, 2025)

This provides:
- Full 12-month cycle (captures seasonal patterns)
- Aligns with most limited data source (BOA CC)
- Clean year-over-year comparability for future analysis

---

## Next Steps

1. [x] User to place files in `/data/raw/` folder structure
2. [ ] Review each file's actual schema (columns, formats)
3. [ ] Analyze Amazon data dump to identify useful formats
4. [ ] Create sample extracts for schema design
5. [ ] Design unified transaction schema
6. [ ] Design reconciliation logic for transfers
7. [ ] Design Amazon order resolution logic
8. [ ] Compare data-derived recurring items to user's manual bill list

---

## File Collection Structure

```
/data/raw/
├── amazon/          # Amazon data dump files
├── boa/             # BOA Billing, Spending, CC exports
├── chase/           # Chase CC export
└── income/          # LES sample, Income Summary
```

### File Checklist

| Source | Target Folder | Collected | Notes |
|--------|---------------|-----------|-------|
| LES | `/income/` | ⬜ | Single PDF sample |
| Income Summary | `/income/` | ⬜ | XLSX with rates |
| BOA Billing | `/boa/` | ⬜ | CSV |
| BOA Spending | `/boa/` | ⬜ | CSV |
| BOA Credit Card | `/boa/` | ⬜ | CSV |
| Chase Credit Card | `/chase/` | ⬜ | XLSX |
| Amazon Orders | `/amazon/` | ⬜ | Multiple formats |

---

*Last Updated: November 27, 2025*
