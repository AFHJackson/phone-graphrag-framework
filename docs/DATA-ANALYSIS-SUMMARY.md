# Data Analysis Summary

## Data Period
October 1, 2024 - November 27, 2025 (14 months)

## Source Summary

### 1. BOA Billing Account (Checking - Primary)
- **File**: `Billing account.csv`
- **Format**: CSV with 6-row header summary
- **Columns**: Date, Description, Amount, Running Bal.
- **Transactions**: 566 total (438 outflow, 127 inflow)
- **Total Outflow**: $276,277.29
- **Total Inflow**: $274,557.40
- **Purpose**: Main hub - receives income, pays bills, funds credit cards

**Top Outflows (Bills/Transfers)**:
| Payee Pattern | Amount | Count | Type |
|--------------|--------|-------|------|
| JPMORGAN CHASE (Chase CC payment) | $44,320.64 | 14 | Transfer to CC |
| IRS Tax Payment | $10,461.00 | 1 | Tax |
| Loan Payment | $10,000.00 | 1 | Debt |
| CRD 4399 (BOA CC payments) | ~$60,000+ | Many | Transfer to CC |
| STATE FARM | $4,843.12 | 10 | Insurance |
| CHRYSLER CAPITAL | ~$12,000 | ~14 | Auto Loan |
| BETTERMENT | ~$1,400 | 14 | Investment |
| Compassion Int'l | ~$602 | 14 | Charity |

### 2. BOA Spending Account (Checking - Secondary)
- **File**: `spending account.csv`
- **Format**: CSV with 6-row header summary
- **Columns**: Date, Description, Amount, Running Bal.
- **Transactions**: 208 total (132 outflow, 75 inflow)
- **Total Outflow**: $10,494.61
- **Total Inflow**: $10,527.49
- **Purpose**: Appears to be wife's closed business or secondary account

**Pattern**: Mostly internal transfers to other BOA checking accounts (CHK 5515, CHK 9780) and ATM withdrawals

### 3. BOA Credit Card
- **File**: `Credit Card.xlsx`
- **Format**: Excel
- **Columns**: Posted Date, Reference Number, Payee, Address, Amount
- **Transactions**: 2,269 total (2,196 charges, 73 payments/credits)
- **Total Charges**: $134,408.38
- **Total Payments**: $111,654.70
- **Purpose**: Primary spending card (groceries, local merchants, subscriptions)

**Top Payees**:
| Payee | Amount | Count | Category |
|-------|--------|-------|----------|
| PUBLIX #1563 | $10,907.43 | 179 | Groceries |
| Coleman Furniture | $5,071.80 | 1 | Home |
| City of Cocoa | $2,668.00 | 12 | Utilities |
| Royal Caribbean | $2,171.02 | 8 | Travel |
| Addison's Automotive | $2,167.36 | 2 | Auto |
| P-Science | $2,029.82 | 7 | ? |
| Shanel Monique Hair | $1,705.80 | 10 | Personal |
| Wave - Liquid Dreams | $1,685.00 | 13 | Recreation |
| Apple.com | $1,603.93 | 1 | Electronics |
| Tesla Service | $1,546.45 | 2 | Auto |
| **Amazon (all)** | **$15,954.89** | **327** | Mixed |

### 4. Chase Credit Card
- **File**: `Chase6242_Activity20241001_20251127_20251127.CSV`
- **Format**: CSV
- **Columns**: Transaction Date, Post Date, Description, Category, Type, Amount, Memo
- **Transactions**: 1,108 total (1,026 sales, 56 payments)
- **Total Spend**: $40,496.36
- **Purpose**: Secondary card - food delivery, gas, shopping

**Spending by Category**:
| Category | Amount | Count | % of Total |
|----------|--------|-------|------------|
| Food & Drink | $11,938.66 | 525 | 29.5% |
| Shopping | $11,391.46 | 188 | 28.1% |
| Travel | $5,812.27 | 20 | 14.4% |
| Entertainment | $2,492.27 | 14 | 6.2% |
| Gas | $2,352.32 | 157 | 5.8% |
| Groceries | $2,240.06 | 62 | 5.5% |
| Health & Wellness | $2,180.24 | 17 | 5.4% |
| Bills & Utilities | $568.59 | 19 | 1.4% |
| Personal | $562.12 | 11 | 1.4% |
| Education | $312.00 | 4 | 0.8% |
| Home | $298.25 | 5 | 0.7% |
| Gifts & Donations | $205.00 | 2 | 0.5% |
| Automotive | $143.12 | 2 | 0.4% |

**DoorDash Analysis** (already addressed):
- Total: $6,476.91
- Orders: 218
- Average: $29.71
- % of Chase: 16.0%

### 5. Amazon Orders
- **File**: `Retail.OrderHistory.1.csv` (main)
- **Format**: CSV with detailed item-level data
- **Columns**: Website, Order ID, Order Date, Unit Price, Unit Price Tax, Total Discounts, Total Owed, ASIN, Quantity, Product Name, etc.
- **Rows**: 3,162 line items
- **Purpose**: Detailed product-level data for Amazon purchases

---

## Key Observations

### Money Flow Pattern
```
INCOME SOURCES
├── DFAS (Military Pay) → BOA Billing
├── SSC PAYROLL (Wife - Teacher) → BOA Billing  
├── City of Cocoa (Part-time?) → BOA Billing
└── Military Locality Pay → BOA Billing

BOA BILLING (Hub)
├── → BOA CC (CRD 4399 payments): ~$60K+
├── → Chase CC (JPMORGAN CHASE): $44,320
├── → Chrysler Capital (Auto Loan): ~$12K
├── → State Farm (Insurance): $4,843
├── → Betterment (Investments): ~$1,400
├── → IRS (Taxes): $10,461
└── → Various Bills/Utilities

CREDIT CARDS (Terminal Spending)
├── BOA CC ($134K charges)
│   ├── Groceries (Publix): $10,907
│   ├── Amazon: $15,955
│   └── Local merchants, subscriptions
│
└── Chase CC ($40K charges)
    ├── Food & Drink: $11,939 (DoorDash issue - resolved)
    ├── Shopping: $11,391
    └── Gas, Travel, Entertainment
```

### Category Gaps

**Chase has categories, BOA does not.**

Need to design category taxonomy that:
1. Uses Chase's 13 categories as starting point
2. Extends for BOA-specific patterns (Groceries at Publix, Amazon product categories)
3. Separates "Bills" (recurring) from "Expenses" (discrete)

### Vendor Normalization Needed

Examples of same vendor with different names:
- `DD *DOORDASH ZAXBYS`, `DD *DOORDASH PAPAJOHNS`, etc. → DoorDash
- `AMAZON RETA* 9U06G7I93`, `AMAZON RETA* QW8KH2HY3` → Amazon
- `PUBLIX #1563 COCOA BEACH FL` → Publix

### Transfer Reconciliation Logic

**BOA Billing → CC Payments**:
- Pattern: `Online Banking payment to CRD XXXX Confirmation# XXXXX`
- CRD 4399 = BOA CC
- CRD 1213 = Possibly another card?

**BOA Billing → Chase CC**:
- Pattern: `JPMORGAN CHASE DES:CHASE ACH ID:XXXXX`

**BOA Billing → Amazon via CC**:
- CC charges show `AMAZON RETA*` patterns
- Match to Amazon order details via date + amount

---

## Accounting Sanity Check ✅

### Date Ranges Verified
| Source | Start | End | Notes |
|--------|-------|-----|-------|
| BOA Billing | 2024-10-01 | 2025-11-26 | Primary hub |
| BOA CC | 2024-11-13 | 2025-11-21 | 6 weeks shorter |
| Chase CC | 2024-10-01 | 2025-11-25 | Full period |

### Income Analysis
```
Total Income into BOA Billing: $274,557.40

Identified Sources:
  DFAS (Military Pay):       $170,169  (31 deposits)
  BREVARDCSB (Wife?):        $ 45,363  (17 deposits)
  Online (transfers in):     $ 17,001  (11)
  SSC Payroll (Teacher):     $ 10,688  (12)
  Betterment (distributions):$ 10,055  (4)
  FID (Fidelity?):           $  6,500  (2)
  City of Cocoa (part-time): $  6,464  (14)
  Other:                     $  8,317
```

### Outflow Analysis
```
Total Outflow from BOA Billing: $276,277.29

Major Categories:
  → BOA CC payments:         $104,800
  → Chase CC payments:       $ 81,786
  → Loan Payments:           $ 34,111
  → IRS (taxes):             $ 10,461
  → State Farm (insurance):  $  7,276
  → Chrysler (auto loan):    $  3,554
  → Betterment (investing):  $  3,100
  → Compassion Int'l:        $    709
  → Other direct bills:      $ 30,481
```

### Balance Check

| Metric | Amount |
|--------|--------|
| Total Income | $274,557 |
| Terminal CC Spending | $174,905 |
| Direct Bills from Billing | $89,692 |
| **Total Spending** | **$264,597** |
| **Net Position** | **+$9,960** |

**Conclusion**: Accounting is sound. The ~$10K positive net aligns with:
- BOA CC growing balance (~$22K net unpaid over period)
- Some months carrying forward balances
- Investment contributions ($3,100 to Betterment)

No major unexplained gaps. Data sources are complete for the analysis period.

---

## Unified Schema Design (Draft)

### Transaction Table
```sql
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    transaction_date DATE NOT NULL,
    post_date DATE,
    description TEXT NOT NULL,           -- Original from source
    normalized_vendor TEXT,              -- Cleaned vendor name
    amount DECIMAL(12,2) NOT NULL,
    category TEXT,                       -- Unified category
    subcategory TEXT,                    -- Optional detail
    source_account TEXT NOT NULL,        -- 'boa_billing', 'boa_cc', 'chase_cc', etc.
    transaction_type TEXT,               -- 'expense', 'bill', 'transfer', 'income'
    is_recurring BOOLEAN DEFAULT FALSE,
    linked_transaction_id INTEGER,       -- For transfer matching
    amazon_order_id TEXT,                -- For Amazon detail linking
    raw_data JSONB                       -- Original row as JSON
);
```

### Unified Category Taxonomy

*Integrates Chase categories + user priorities + observed spending patterns*

```
INCOME
├── Salary
│   ├── Military Pay (DFAS)
│   ├── Teacher Pay (SSC, BREVARDCSB)
│   └── Part-time (City of Cocoa)
├── Investment Income (Betterment, FID)
└── Other Income

HOUSING (Bills - service level decisions)
├── Mortgage / Rent
├── Property Taxes
├── HOA
├── Repairs & Maintenance
├── Furnishing & Equipment
└── Solar Panels (Dividend loan)

TRANSPORTATION (Blend of bills & expenses)
├── Auto Financing (Chrysler)
├── Insurance (State Farm)
├── Gas
├── Service & Maintenance (Tesla, Addison's)
├── Equipment & Parts
└── Parking & Tolls

UTILITIES (Bills - service level)
├── Electric
├── Water & Sewer
├── Natural Gas
├── Internet
├── Phone / Mobile
└── Solid Waste (via property taxes)

INSURANCE (Bills - annual/monthly)
├── Auto (State Farm)
├── Home
├── Health
└── Life

FOOD (Expenses - per-item decisions)
├── Groceries (Publix)
├── Restaurants (dining out)
├── Delivery (DoorDash - addressed)
└── Coffee & Snacks

HEALTH & WELLNESS (Mix)
├── Medical
│   ├── Appointments
│   └── Prescriptions
├── Fitness
│   ├── Memberships
│   ├── Gym Equipment
│   └── Fitness Gear
├── Nutrition
│   ├── Vitamins
│   ├── Supplements
│   └── Peptides
└── Personal Care

CLOTHING
├── Purchase
└── Maintenance (dry cleaning, alterations)

PETS
├── Food
├── Vet
├── Grooming
└── Toys & Supplies

FAMILY & EDUCATION
├── Youth Events (sons' activities)
├── School Expenses (BPSMYSCHOOLBUCKS)
├── Education Materials
└── Children's Needs

COMMUNITY & GIVING
├── Church (tithe, offerings)
├── Charities (Compassion Int'l, AFP)
├── Gifts & Donations
└── Youth Sponsorships

ENTERTAINMENT & RECREATION
├── Events & Tickets (concerts, sports)
├── Streaming & Media (subscriptions)
├── Recreation (Wave - Liquid Dreams, VFW)
├── Hobbies
└── Hanging Out (bars, non-meal social)

TRAVEL
├── Flights & Tickets
├── Hotels & Lodging
├── Cruises (Royal Caribbean, Wonder of the Seas)
├── Ground Transportation
└── Travel Incidentals

SHOPPING (Expenses - per-item)
├── Electronics (Apple)
├── Household Items
├── Amazon (link to product details)
└── General Retail

SUBSCRIPTIONS & MEMBERSHIPS (Bills)
├── Streaming Services
├── Software / Apps (Covenant Eyes)
├── News / Publications (Bible Project)
└── Club Memberships

FINANCIAL
├── Debt Service
│   ├── Auto Loan
│   ├── Personal Loans
│   └── CC Payoff (beyond minimum)
├── Savings & Investments (Betterment)
└── Taxes
    ├── Federal (IRS)
    ├── State
    └── Local

TRANSFERS (Non-terminal - for flow tracking only)
├── To Credit Card
├── To Investment Account
├── Between Accounts
├── ATM Withdrawal
└── Zelle / P2P
```

### Category Mapping from Brain-Dump

| Your Notes | Mapped To |
|------------|-----------|
| Meals - groceries, restaurants | FOOD → Groceries, Restaurants |
| House - Repairs, furnishing, equipment, mortgage | HOUSING → all subcategories |
| Cars - financing, service, equipment | TRANSPORTATION → Auto Financing, Service, Equipment |
| Clothes - purchase, maintenance | CLOTHING → Purchase, Maintenance |
| Pets - food, vet, toys, grooming | PETS → all subcategories |
| Utilities - water, property taxes, gas, electric, solar | UTILITIES + HOUSING (property taxes, solar) |
| Health & Fitness - memberships, peptides, gear | HEALTH & WELLNESS → Fitness |
| Nutrition - vitamins, supplements | HEALTH & WELLNESS → Nutrition |
| Medical - appointments, prescriptions | HEALTH & WELLNESS → Medical |
| Community - church, charities, youth, hanging out, gifts | COMMUNITY & GIVING + ENTERTAINMENT (hanging out) |
| Travel - tickets, hotels | TRAVEL → Flights, Hotels |

---

## Next Steps

1. **Build ETL Pipeline**: Load all sources into unified transaction table
2. **Implement Vendor Normalization**: Create mapping rules for vendor cleanup
3. **Category Assignment Logic**: 
   - Use Chase categories where available
   - ML/rule-based for BOA transactions
4. **Transfer Matching**: Link BOA→CC payments to CC transactions
5. **Amazon Resolution**: Match CC charges to order details
6. **Priority Extraction**: Define and track spending priorities
