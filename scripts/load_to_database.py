"""
Database Loader for Family Budget GraphRAG
Loads unified transactions into PostgreSQL + Apache AGE
"""
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values, Json
import os
import json
from typing import Optional, Dict, List, Tuple
import re

# Configuration - for WSL PostgreSQL via Unix socket
import sys
RUNNING_IN_WSL = '/mnt/c/' in sys.prefix if hasattr(sys, 'prefix') else False

# WSL paths
WSL_DATA_DIR = "/mnt/c/Users/afhja/phone-graphrag-framework/data/processed"
WSL_SQL_DIR = "/mnt/c/Users/afhja/phone-graphrag-framework/sql"

# Windows paths
WIN_DATA_DIR = r"c:\Users\afhja\phone-graphrag-framework\data\processed"
WIN_SQL_DIR = r"c:\Users\afhja\phone-graphrag-framework\sql"

# Use appropriate paths
DATA_DIR = WSL_DATA_DIR if RUNNING_IN_WSL or '/mnt/c' in __file__ else WIN_DATA_DIR
SQL_DIR = WSL_SQL_DIR if RUNNING_IN_WSL or '/mnt/c' in __file__ else WIN_SQL_DIR

DB_CONFIG = {
    'database': 'family_budget',
    'user': 'postgres',
    # No password needed for Unix socket auth
}


def get_connection():
    """Get database connection"""
    return psycopg2.connect(**DB_CONFIG)


def init_database():
    """Initialize database schema"""
    conn = get_connection()
    cur = conn.cursor()
    
    # Read and execute schema
    with open(os.path.join(SQL_DIR, "schema.sql"), 'r') as f:
        schema_sql = f.read()
    
    try:
        cur.execute(schema_sql)
        conn.commit()
        print("✓ Schema created successfully")
    except Exception as e:
        print(f"Schema error (may be OK if already exists): {e}")
        conn.rollback()
    
    # Seed categories
    with open(os.path.join(SQL_DIR, "seed_categories.sql"), 'r') as f:
        seed_sql = f.read()
    
    try:
        cur.execute(seed_sql)
        conn.commit()
        print("✓ Categories seeded successfully")
    except Exception as e:
        print(f"Seed error (may be OK if already exists): {e}")
        conn.rollback()
    
    cur.close()
    conn.close()


# Category mapping rules
CATEGORY_RULES = [
    # ============================================================
    # TRANSFERS (must be first - these are NOT expenses)
    # ============================================================
    (r'Online Banking payment to CRD', 'XFER_CC'),
    (r'JPMORGAN CHASE.*ACH|CHASE CREDIT CRD', 'XFER_CC'),
    (r'JPMORGAN CHASE.*Ext Trnsfr', 'XFER_CC'),
    (r'Online Banking transfer', 'XFER_INTERNAL'),
    (r'ATM.*WITHDRWL', 'XFER_ATM'),
    (r'Zelle', 'XFER_P2P'),
    (r'APPLE CASH', 'XFER_P2P'),
    (r'ALLY DES:ALLY', 'TRANS_AUTOLOAN'),  # This is auto loan payment
    (r'FID BKG.*MONEYLINE', 'XFER_INTERNAL'),  # Fidelity transfer
    
    # ============================================================
    # INCOME
    # ============================================================
    (r'DFAS.*FED SALARY', 'INCOME_MILITARY'),
    (r'SSC PAYROLL', 'INCOME_TEACHER'),
    (r'CITY OF COCOA.*PAYROLL', 'INCOME_PARTTIME'),
    (r'BETTERMENT.*TRANSFER.*', 'INCOME_INVESTMENT'),
    (r'BREVARDCSB', 'INCOME_TEACHER'),
    
    # ============================================================
    # FAITH & COMMUNITY (Priority #1)
    # ============================================================
    (r'COMPASSION', 'COMM_CHARITY'),
    (r'LIVEACTION', 'COMM_CHARITY'),
    (r'AFP.*Raising', 'COMM_CHARITY'),
    (r'COASTLINECHURCH', 'COMM_CHURCH'),
    (r'BIBLE.*PROJ', 'COMM_CHURCH'),
    (r'JESUS LOVES YOU', 'COMM_CHARITY'),
    
    # ============================================================
    # HEALTH & FITNESS (Priority #2)
    # ============================================================
    (r'CVS|WALGREENS|PHARMACY', 'HEALTH_RX'),
    (r'P-SCIENCE|PEPTIDE', 'HEALTH_PEPTIDES'),
    (r'GYM|FITNESS|PLANET FIT', 'HEALTH_FITNESS'),
    (r'LABCORP', 'HEALTH_MEDICAL'),
    (r'HFSS|MYCHART', 'HEALTH_MEDICAL'),
    (r'HERSCAN', 'HEALTH_MEDICAL'),
    (r'BRILLIANT SMILES', 'HEALTH_MEDICAL'),
    (r'JOI WOMENS|BLOKES', 'HEALTH_FITNESS'),  # Wellness clinics
    (r'OBAGI', 'HEALTH_PERSONAL'),
    (r'SEPHORA|ULTA', 'HEALTH_PERSONAL'),
    
    # ============================================================
    # FAMILY & EDUCATION (Priority #3)
    # ============================================================
    (r'BPSMYSCHOOLBUCKS', 'FAM_SCHOOL'),
    (r'JOSTENS', 'FAM_SCHOOL'),  # Yearbook
    (r'BCS.*BREVARD', 'FAM_YOUTH'),  # Brevard County Schools sports
    (r'LACROSSE', 'FAM_YOUTH'),
    (r'CCM HOCKEY', 'FAM_YOUTH'),
    (r'OFFICE DEPOT', 'FAM_SCHOOL'),
    
    # ============================================================
    # HOUSING (Priority #4)
    # ============================================================
    (r'Loan Payment', 'HOUSING_MORTGAGE'),
    (r'DIVIDEND|DVDND', 'HOUSING_SOLAR'),
    (r'COLEMAN FURNITURE', 'HOUSING_FURNISH'),
    (r'HOME DEPOT|LOWES|ACE HARDWARE', 'HOUSING_REPAIRS'),
    (r'ACE HANDIMAN', 'HOUSING_REPAIRS'),
    
    # ============================================================
    # FOOD & NUTRITION (Priority #5)
    # ============================================================
    # Grocery
    (r'PUBLIX|WALMART.*GROC|COSTCO|ALDI|KROGER', 'FOOD_GROCERY'),
    (r'WINN-DIXIE', 'FOOD_GROCERY'),
    (r'INSTACART', 'FOOD_GROCERY'),
    
    # Delivery
    (r'DOORDASH|UBER EATS|GRUBHUB|POSTMATES', 'FOOD_DELIVERY'),
    
    # Coffee
    (r'STARBUCKS|DUNKIN|COFFEE', 'FOOD_COFFEE'),
    (r'NESPRESSO', 'FOOD_COFFEE'),
    
    # Restaurants (expanded)
    (r'CHICK-FIL-A|MCDONALDS|WENDYS|BURGER|TACO|ZAXBY|JIMMY JOHNS|PAPA JOHNS', 'FOOD_RESTAURANT'),
    (r'PANERA|CHIPOTLE|SUBWAY|FIREHOUSE', 'FOOD_RESTAURANT'),
    (r'SHOYU|HIBACHI', 'FOOD_RESTAURANT'),
    (r'THAI THAI', 'FOOD_RESTAURANT'),
    (r'FLAVOUR KITCHEN', 'FOOD_RESTAURANT'),
    (r'SIMPLY DELICIOUS', 'FOOD_RESTAURANT'),
    (r'JOHNATHAN.*PUB', 'FOOD_RESTAURANT'),
    (r'COSY ISLAND', 'FOOD_RESTAURANT'),
    (r'GREGORYS STEAK', 'FOOD_RESTAURANT'),
    (r'COA STEAKHOUSE', 'FOOD_RESTAURANT'),
    (r'FLORIDA.*FRESH.*GRILL', 'FOOD_RESTAURANT'),
    (r'VILLA PALMA', 'FOOD_RESTAURANT'),
    (r'DESTINATION FOOD', 'FOOD_RESTAURANT'),
    (r'PINEAPPLE POINTE', 'FOOD_RESTAURANT'),
    
    # ============================================================
    # FINANCIAL (Priority #6)
    # ============================================================
    (r'IRS.*USATAXPYMT', 'FIN_TAX_FED'),
    (r'BETTERMENT.*SEC', 'FIN_INVESTMENT'),
    
    # ============================================================
    # TRANSPORTATION (Priority #7)
    # ============================================================
    (r'CHRYSLER.*CAPITAL', 'TRANS_AUTOLOAN'),
    (r'SHELL|CHEVRON|EXXON|BP|WAWA|RACETRAC|SUNOCO', 'TRANS_GAS'),
    (r'TESLA', 'TRANS_SERVICE'),  # Tesla payments/service
    (r'ADDISONS AUTO', 'TRANS_SERVICE'),
    (r'ENTERPRISE RENT', 'TRANS_SERVICE'),
    (r'UBER.*TRIP', 'TRANS_SERVICE'),  # Rideshare
    (r'BREVARD VEHICLE', 'TRANS_SERVICE'),  # Vehicle registration
    
    # ============================================================
    # UTILITIES (Priority #8)
    # ============================================================
    (r'FPL|FLORIDA POWER', 'UTIL_ELECTRIC'),
    (r'CITY OF COCOA.*ECOMM', 'UTIL_WATER'),
    (r'T-MOBILE', 'UTIL_PHONE'),
    (r'ATT.*BILL', 'UTIL_PHONE'),
    (r'FLORIDACITY GAS', 'UTIL_GAS'),
    
    # ============================================================
    # INSURANCE (Priority #9)
    # ============================================================
    (r'STATE FARM', 'INS_AUTO'),
    
    # ============================================================
    # PERSONAL CARE (Priority #10) 
    # ============================================================
    (r'SHANEL MONIQUE', 'HEALTH_PERSONAL'),  # Hair salon
    (r'HOLLYWOOD NAILS', 'HEALTH_PERSONAL'),  # Nails
    (r'MAGIC CLEANERS|TOUCH OF CLASS', 'CLOTH_MAINTAIN'),  # Dry cleaning
    (r'LILLY PULITZER|ANN TAYLOR|WINDSOR FASHIONS', 'CLOTH_PURCHASE'),
    (r'MACYS|NORDSTROM|DILLARDS', 'CLOTH_PURCHASE'),
    
    # ============================================================
    # PETS (Priority #11)
    # ============================================================
    (r'CHEWY|PETSMART|PETCO', 'PET_FOOD'),
    (r'WOOF GANG', 'PET_GROOMING'),
    (r'ISLAND ANIMAL', 'PET_VET'),
    
    # ============================================================
    # ENTERTAINMENT (Priority #12)
    # ============================================================
    (r'NETFLIX|HULU|DISNEY|SPOTIFY|APPLE.*TV|HBO|PARAMOUNT', 'ENT_MEDIA'),
    (r'STUBHUB|TICKETMASTER|VIVID', 'ENT_EVENTS'),
    (r'VFW|WAVE.*LIQUID|JAZZYS', 'ENT_RECREATION'),
    (r'ABC FINE', 'ENT_RECREATION'),  # Liquor store
    (r'4TH STREET', 'ENT_RECREATION'),  # Bar
    (r'CORK', 'ENT_RECREATION'),  # Wine bar
    
    # ============================================================
    # TRAVEL (Priority #13)
    # ============================================================
    (r'ROYAL CARIBBEAN|CARNIVAL|NORWEGIAN|WONDER OF THE SEAS', 'TRAVEL_CRUISES'),
    (r'HOTEL|MARRIOTT|HILTON|HYATT|IHG', 'TRAVEL_HOTELS'),
    (r'WESTGATE', 'TRAVEL_HOTELS'),
    (r'UNITED|DELTA|AMERICAN|SOUTHWEST|FRONTIER', 'TRAVEL_FLIGHTS'),
    
    # ============================================================
    # SHOPPING (Priority #14 - lowest)
    # ============================================================
    (r'AMAZON|AMZN', 'SHOP_AMAZON'),
    (r'APPLE\.COM|APPLE STORE', 'SHOP_ELECTRONICS'),
    (r'SAMSUNG', 'SHOP_ELECTRONICS'),
    (r'BESTBUY', 'SHOP_ELECTRONICS'),
    (r'GARMIN', 'SHOP_ELECTRONICS'),
    (r'TARGET|WALMART(?!.*GROC)', 'SHOP_GENERAL'),
    (r'DOLLAR GENERAL', 'SHOP_HOUSEHOLD'),
    (r'TINY TURTLE', 'SHOP_GENERAL'),  # Gift shop
    (r'POSHMARK|MERCARI', 'CLOTH_PURCHASE'),  # Resale clothing
    (r'TIKTOK SHOP', 'SHOP_GENERAL'),
    (r'AAFES|PATRICK', 'SHOP_GENERAL'),  # Military PX
    (r'RON JON', 'SHOP_GENERAL'),
    
    # Subscriptions
    (r'COVENANT EYES', 'SUB_SOFTWARE'),
]



def map_category(description: str, original_category: Optional[str] = None) -> str:
    """Map a transaction description to a category code"""
    if pd.isna(description):
        return 'SHOPPING'  # Default
    
    desc_upper = description.upper()
    
    # First, try our custom rules
    for pattern, category_code in CATEGORY_RULES:
        if re.search(pattern, desc_upper, re.IGNORECASE):
            return category_code
    
    # Fall back to Chase category mapping if available
    if original_category and not pd.isna(original_category):
        chase_map = {
            'Food & Drink': 'FOOD_RESTAURANT',
            'Groceries': 'FOOD_GROCERY',
            'Gas': 'TRANS_GAS',
            'Travel': 'TRAVEL',
            'Entertainment': 'ENTERTAINMENT',
            'Shopping': 'SHOPPING',
            'Health & Wellness': 'HEALTH',
            'Bills & Utilities': 'UTILITIES',
            'Personal': 'HEALTH_PERSONAL',
            'Education': 'FAM_EDUCATION',
            'Home': 'HOUSING',
            'Gifts & Donations': 'COMM_GIFTS',
            'Automotive': 'TRANS_SERVICE',
        }
        if original_category in chase_map:
            return chase_map[original_category]
    
    return 'SHOPPING'  # Ultimate default


def load_transactions():
    """Load unified transactions into database"""
    # Load processed data
    df = pd.read_csv(os.path.join(DATA_DIR, "unified_transactions.csv"))
    df['transaction_date'] = pd.to_datetime(df['transaction_date'])
    df['post_date'] = pd.to_datetime(df['post_date'])
    
    # Filter out invalid rows
    initial_count = len(df)
    df = df[df['transaction_date'].notna()]  # Must have transaction date
    df = df[df['description'].notna() & (df['description'] != 'NaN')]  # Must have description
    df = df[df['amount'].notna()]  # Must have amount
    filtered_count = initial_count - len(df)
    if filtered_count > 0:
        print(f"  (Filtered out {filtered_count} invalid rows)")
    
    print(f"Loading {len(df):,} transactions...")
    
    conn = get_connection()
    cur = conn.cursor()
    
    # Get account mapping
    cur.execute("SELECT account_code, account_id FROM accounts")
    account_map = {row[0]: row[1] for row in cur.fetchall()}
    
    # Get category mapping
    cur.execute("SELECT category_code, category_id FROM categories")
    category_map = {row[0]: row[1] for row in cur.fetchall()}
    
    # Prepare data (dedupe by transaction_id)
    records_dict = {}  # Use dict to dedupe
    for _, row in df.iterrows():
        # Map category
        category_code = map_category(row['description'], row.get('original_category'))
        category_id = category_map.get(category_code, category_map.get('SHOPPING'))
        
        # Get account
        account_id = account_map.get(row['source_account'])
        
        # Dedupe by transaction_id
        records_dict[row['transaction_id']] = (
            row['transaction_id'],
            row['transaction_date'].date() if pd.notna(row['transaction_date']) else None,
            row['post_date'].date() if pd.notna(row['post_date']) else None,
            row['description'],
            float(row['amount']),
            account_id,
            category_id,
            row['transaction_type'],
            bool(row['is_transfer']) if pd.notna(row.get('is_transfer')) else False,
            row.get('transfer_type'),
            row.get('original_category'),
            row.get('normalized_vendor')
        )
    
    records = list(records_dict.values())
    print(f"  (Deduplicated to {len(records):,} unique transactions)")
    
    # Insert
    insert_sql = """
        INSERT INTO transactions (
            transaction_id, transaction_date, post_date, description, amount,
            account_id, category_id, transaction_type, is_transfer, transfer_type,
            original_category, normalized_vendor
        ) VALUES %s
        ON CONFLICT (transaction_id) DO UPDATE SET
            category_id = EXCLUDED.category_id,
            normalized_vendor = EXCLUDED.normalized_vendor
    """
    
    execute_values(cur, insert_sql, records, page_size=500)
    conn.commit()
    
    print(f"✓ Loaded {len(records):,} transactions")
    
    # Summary
    cur.execute("""
        SELECT c.category_name, COUNT(*), SUM(ABS(t.amount))
        FROM transactions t
        JOIN categories c ON t.category_id = c.category_id
        WHERE t.transaction_type = 'expense'
        GROUP BY c.category_name
        ORDER BY SUM(ABS(t.amount)) DESC
        LIMIT 15
    """)
    
    print("\nTop categories by spend:")
    for row in cur.fetchall():
        print(f"  {row[0]:<30} {row[1]:>5} txns  ${row[2]:>12,.2f}")
    
    cur.close()
    conn.close()


def load_amazon_orders():
    """Load Amazon order details"""
    amazon_path = os.path.join(DATA_DIR, "amazon_orders.csv")
    if not os.path.exists(amazon_path):
        print("No Amazon orders to load")
        return
    
    df = pd.read_csv(amazon_path)
    df['order_date'] = pd.to_datetime(df['order_date'], format='mixed', utc=True)
    df['ship_date'] = pd.to_datetime(df['ship_date'], format='mixed', utc=True, errors='coerce')
    
    print(f"Loading {len(df):,} Amazon order items...")
    
    conn = get_connection()
    cur = conn.cursor()
    
    records = []
    for _, row in df.iterrows():
        records.append((
            row['order_id'],
            row['order_date'].date() if pd.notna(row['order_date']) else None,
            row.get('product_name'),
            row.get('asin'),
            float(row['unit_price']) if pd.notna(row.get('unit_price')) else None,
            int(row['quantity']) if pd.notna(row.get('quantity')) else 1,
            float(row['total_owed']) if pd.notna(row.get('total_owed')) else None,
            row.get('order_status'),
            row['ship_date'].date() if pd.notna(row.get('ship_date')) else None,
        ))
    
    insert_sql = """
        INSERT INTO amazon_orders (
            order_id, order_date, product_name, asin, unit_price,
            quantity, total_owed, order_status, ship_date
        ) VALUES %s
        ON CONFLICT DO NOTHING
    """
    
    execute_values(cur, insert_sql, records, page_size=500)
    conn.commit()
    
    print(f"✓ Loaded {len(records):,} Amazon order items")
    
    cur.close()
    conn.close()


def escape_cypher(s):
    """Escape a string for use in Cypher queries"""
    if s is None:
        return ''
    s = str(s)
    # Escape backslashes first, then single quotes
    s = s.replace('\\', '\\\\')
    s = s.replace("'", "\\'")
    return s


def build_graph():
    """Build Apache AGE graph from relational data"""
    conn = get_connection()
    cur = conn.cursor()
    
    # Load AGE
    cur.execute("LOAD 'age';")
    cur.execute("SET search_path = ag_catalog, \"$user\", public;")
    
    print("Building graph nodes and edges...")
    
    # Clear all nodes and edges first (DETACH DELETE removes edges too)
    cur.execute("""
        SELECT * FROM cypher('family_budget', $$
            MATCH (n) DETACH DELETE n
        $$) AS (result agtype);
    """)
    print("  Cleared existing graph data")
    
    # Create Account nodes
    cur.execute("""
        SELECT a.account_id, a.account_code, a.account_name, a.account_type
        FROM accounts a
    """)
    accounts = cur.fetchall()
    
    for acc in accounts:
        cur.execute(f"""
            SELECT * FROM cypher('family_budget', $$
                CREATE (a:Account {{
                    account_id: {acc[0]},
                    account_code: '{acc[1]}',
                    account_name: '{acc[2]}',
                    account_type: '{acc[3]}'
                }})
            $$) AS (result agtype);
        """)
    
    print(f"  Created {len(accounts)} Account nodes")
    
    # Create Category nodes
    cur.execute("""
        SELECT c.category_id, c.category_code, c.category_name, c.category_level, c.is_bill
        FROM categories c
    """)
    categories = cur.fetchall()
    
    for cat in categories:
        is_bill_str = 'true' if cat[4] else 'false'
        cur.execute(f"""
            SELECT * FROM cypher('family_budget', $$
                CREATE (c:Category {{
                    category_id: {cat[0]},
                    category_code: '{cat[1]}',
                    category_name: '{cat[2]}',
                    level: {cat[3]},
                    is_bill: {is_bill_str}
                }})
            $$) AS (result agtype);
        """)
    
    print(f"  Created {len(categories)} Category nodes")
    
    # Create Category hierarchy edges (PARENT_OF)
    cur.execute("""
        SELECT c.category_id, p.category_id
        FROM categories c
        JOIN categories p ON c.parent_category_id = p.category_id
        WHERE c.parent_category_id IS NOT NULL
    """)
    cat_parents = cur.fetchall()
    
    for child_id, parent_id in cat_parents:
        cur.execute(f"""
            SELECT * FROM cypher('family_budget', $$
                MATCH (parent:Category {{category_id: {parent_id}}}),
                      (child:Category {{category_id: {child_id}}})
                CREATE (parent)-[:PARENT_OF]->(child)
            $$) AS (result agtype);
        """)
    
    print(f"  Created {len(cat_parents)} Category hierarchy edges")
    
    # Create Vendor nodes from normalized vendors in transactions
    # Create Vendor nodes from normalized vendors in transactions
    cur.execute("""
        SELECT DISTINCT normalized_vendor
        FROM transactions
        WHERE normalized_vendor IS NOT NULL 
          AND normalized_vendor != ''
          AND normalized_vendor != 'NaN'
    """)
    vendors = cur.fetchall()
    
    for i, (vendor_name,) in enumerate(vendors):
        safe_name = escape_cypher(vendor_name)
        cur.execute(f"""
            SELECT * FROM cypher('family_budget', $$
                CREATE (v:Vendor {{
                    vendor_id: {i + 1},
                    name: '{safe_name}'
                }})
            $$) AS (result agtype);
        """)
    
    print(f"  Created {len(vendors)} Vendor nodes")
    
    # Create Transaction nodes (top 2000 by amount for performance)
    cur.execute("""
        SELECT t.transaction_id, t.transaction_date, t.description, 
               t.amount, t.transaction_type, t.is_transfer,
               t.account_id, t.category_id, t.normalized_vendor
        FROM transactions t
        ORDER BY ABS(t.amount) DESC
        LIMIT 2000
    """)
    transactions = cur.fetchall()
    
    for txn in transactions:
        txn_id, txn_date, desc, amount, txn_type, is_transfer, acc_id, cat_id, vendor = txn
        safe_desc = escape_cypher(desc)[:100] if desc else ''
        date_str = txn_date.isoformat() if txn_date else ''
        is_transfer_str = 'true' if is_transfer else 'false'
        
        cur.execute(f"""
            SELECT * FROM cypher('family_budget', $$
                CREATE (t:Transaction {{
                    transaction_id: '{txn_id}',
                    date: '{date_str}',
                    description: '{safe_desc}',
                    amount: {amount},
                    type: '{txn_type}',
                    is_transfer: {is_transfer_str}
                }})
            $$) AS (result agtype);
        """)
    
    print(f"  Created {len(transactions)} Transaction nodes")
    
    # Create Transaction -> Account edges (FROM_ACCOUNT)
    edge_count = 0
    for txn in transactions:
        txn_id, _, _, _, _, _, acc_id, cat_id, vendor = txn
        if acc_id:
            cur.execute(f"""
                SELECT * FROM cypher('family_budget', $$
                    MATCH (t:Transaction {{transaction_id: '{txn_id}'}}),
                          (a:Account {{account_id: {acc_id}}})
                    CREATE (t)-[:FROM_ACCOUNT]->(a)
                $$) AS (result agtype);
            """)
            edge_count += 1
    
    print(f"  Created {edge_count} Transaction->Account edges")
    
    # Create Transaction -> Category edges (IN_CATEGORY)
    edge_count = 0
    for txn in transactions:
        txn_id, _, _, _, _, _, acc_id, cat_id, vendor = txn
        if cat_id:
            cur.execute(f"""
                SELECT * FROM cypher('family_budget', $$
                    MATCH (t:Transaction {{transaction_id: '{txn_id}'}}),
                          (c:Category {{category_id: {cat_id}}})
                    CREATE (t)-[:IN_CATEGORY]->(c)
                $$) AS (result agtype);
            """)
            edge_count += 1
    
    print(f"  Created {edge_count} Transaction->Category edges")
    
    # Create Transaction -> Vendor edges (TO_VENDOR)
    edge_count = 0
    for txn in transactions:
        txn_id, _, _, _, _, _, acc_id, cat_id, vendor = txn
        if vendor and vendor != 'NaN':
            safe_vendor = escape_cypher(vendor)
            cur.execute(f"""
                SELECT * FROM cypher('family_budget', $$
                    MATCH (t:Transaction {{transaction_id: '{txn_id}'}}),
                          (v:Vendor {{name: '{safe_vendor}'}})
                    CREATE (t)-[:TO_VENDOR]->(v)
                $$) AS (result agtype);
            """)
            edge_count += 1
    
    print(f"  Created {edge_count} Transaction->Vendor edges")
    
    conn.commit()
    cur.close()
    conn.close()
    
    print("✓ Graph built successfully")


def main():
    """Main entry point"""
    print("=" * 60)
    print("FAMILY BUDGET DATABASE LOADER")
    print("=" * 60)
    print()
    
    # Skip init - schema and categories already loaded via psql
    print("1. Schema already initialized (skipping)")
    # init_database()
    print()
    
    print("2. Reloading transactions with updated category rules...")
    load_transactions()
    print()
    
    print("3. Loading Amazon orders... (already loaded, skipping)")
    # load_amazon_orders()  # Already loaded 3,162
    print()
    
    print("4. Rebuilding graph with updated data...")
    try:
        build_graph()
    except Exception as e:
        print(f"  Graph building error: {e}")
        import traceback
        traceback.print_exc()
    print()
    
    print("=" * 60)
    print("DATABASE LOAD COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()
