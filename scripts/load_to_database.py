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

# Configuration
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'family_budget',
    'user': 'postgres',
    'password': 'postgres'  # Change this!
}

DATA_DIR = r"c:\Users\afhja\phone-graphrag-framework\data\processed"
SQL_DIR = r"c:\Users\afhja\phone-graphrag-framework\sql"


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
    # Income patterns
    (r'DFAS.*FED SALARY', 'INCOME_MILITARY'),
    (r'SSC PAYROLL', 'INCOME_TEACHER'),
    (r'CITY OF COCOA.*PAYROLL', 'INCOME_PARTTIME'),
    (r'BETTERMENT.*TRANSFER.*', 'INCOME_INVESTMENT'),
    
    # Housing
    (r'Loan Payment', 'HOUSING_MORTGAGE'),
    (r'DIVIDEND', 'HOUSING_SOLAR'),
    (r'COLEMAN FURNITURE', 'HOUSING_FURNISH'),
    
    # Transportation
    (r'CHRYSLER.*CAPITAL', 'TRANS_AUTOLOAN'),
    (r'SHELL|CHEVRON|EXXON|BP|WAWA|RACETRAC|SUNOCO', 'TRANS_GAS'),
    (r'TESLA SERVICE|ADDISONS AUTO', 'TRANS_SERVICE'),
    
    # Utilities
    (r'FPL|FLORIDA POWER', 'UTIL_ELECTRIC'),
    (r'CITY OF COCOA.*ECOMM', 'UTIL_WATER'),
    
    # Insurance
    (r'STATE FARM', 'INS_AUTO'),
    
    # Food
    (r'PUBLIX|WALMART.*GROC|COSTCO|ALDI|KROGER', 'FOOD_GROCERY'),
    (r'DOORDASH|UBER EATS|GRUBHUB|POSTMATES', 'FOOD_DELIVERY'),
    (r'STARBUCKS|DUNKIN|COFFEE', 'FOOD_COFFEE'),
    (r'CHICK-FIL-A|MCDONALDS|WENDYS|BURGER|TACO|ZAXBY|JIMMY JOHNS|PAPA JOHNS', 'FOOD_RESTAURANT'),
    
    # Health
    (r'CVS|WALGREENS|PHARMACY', 'HEALTH_RX'),
    (r'P-SCIENCE|PEPTIDE', 'HEALTH_PEPTIDES'),
    (r'GYM|FITNESS|PLANET FIT', 'HEALTH_FITNESS'),
    
    # Pets
    (r'CHEWY|PETSMART|PETCO', 'PET_FOOD'),
    
    # Family/Education
    (r'BPSMYSCHOOLBUCKS|SCHOOL', 'FAM_SCHOOL'),
    
    # Community
    (r'COMPASSION', 'COMM_CHARITY'),
    (r'AFP.*Raising', 'COMM_CHARITY'),
    (r'BIBLE.*PROJ', 'COMM_CHURCH'),
    
    # Entertainment
    (r'NETFLIX|HULU|DISNEY|SPOTIFY|APPLE.*TV|HBO|PARAMOUNT', 'ENT_MEDIA'),
    (r'STUBHUB|TICKETMASTER|VIVID', 'ENT_EVENTS'),
    (r'VFW|WAVE.*LIQUID|JAZZYS', 'ENT_RECREATION'),
    
    # Travel
    (r'ROYAL CARIBBEAN|CARNIVAL|NORWEGIAN|WONDER OF THE SEAS', 'TRAVEL_CRUISES'),
    (r'HOTEL|MARRIOTT|HILTON|HYATT|IHG', 'TRAVEL_HOTELS'),
    (r'UNITED|DELTA|AMERICAN|SOUTHWEST|FRONTIER', 'TRAVEL_FLIGHTS'),
    
    # Shopping
    (r'AMAZON|AMZN', 'SHOP_AMAZON'),
    (r'APPLE\.COM|APPLE STORE', 'SHOP_ELECTRONICS'),
    (r'TARGET|WALMART(?!.*GROC)', 'SHOP_GENERAL'),
    
    # Subscriptions
    (r'COVENANT EYES', 'SUB_SOFTWARE'),
    
    # Financial
    (r'IRS.*USATAXPYMT', 'FIN_TAX_FED'),
    (r'BETTERMENT.*SEC', 'FIN_INVESTMENT'),
    
    # Transfers
    (r'Online Banking payment to CRD', 'XFER_CC'),
    (r'JPMORGAN CHASE.*ACH|CHASE CREDIT CRD', 'XFER_CC'),
    (r'Online Banking transfer', 'XFER_INTERNAL'),
    (r'ATM.*WITHDRWL', 'XFER_ATM'),
    (r'Zelle', 'XFER_P2P'),
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
    
    print(f"Loading {len(df):,} transactions...")
    
    conn = get_connection()
    cur = conn.cursor()
    
    # Get account mapping
    cur.execute("SELECT account_code, account_id FROM accounts")
    account_map = {row[0]: row[1] for row in cur.fetchall()}
    
    # Get category mapping
    cur.execute("SELECT category_code, category_id FROM categories")
    category_map = {row[0]: row[1] for row in cur.fetchall()}
    
    # Prepare data
    records = []
    for _, row in df.iterrows():
        # Map category
        category_code = map_category(row['description'], row.get('original_category'))
        category_id = category_map.get(category_code, category_map.get('SHOPPING'))
        
        # Get account
        account_id = account_map.get(row['source_account'])
        
        records.append((
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
        ))
    
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
    df['order_date'] = pd.to_datetime(df['order_date'])
    df['ship_date'] = pd.to_datetime(df['ship_date'], errors='coerce')
    
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


def build_graph():
    """Build Apache AGE graph from relational data"""
    conn = get_connection()
    cur = conn.cursor()
    
    # Load AGE
    cur.execute("LOAD 'age';")
    cur.execute("SET search_path = ag_catalog, \"$user\", public;")
    
    print("Building graph nodes and edges...")
    
    # Create Account nodes
    cur.execute("""
        SELECT * FROM cypher('family_budget', $$
            MATCH (a:Account) DELETE a
        $$) AS (result agtype);
    """)
    
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
        SELECT * FROM cypher('family_budget', $$
            MATCH (c:Category) DELETE c
        $$) AS (result agtype);
    """)
    
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
    
    print("1. Initializing database schema...")
    init_database()
    print()
    
    print("2. Loading transactions...")
    load_transactions()
    print()
    
    print("3. Loading Amazon orders...")
    load_amazon_orders()
    print()
    
    print("4. Building graph...")
    try:
        build_graph()
    except Exception as e:
        print(f"  Graph building skipped (AGE may not be installed): {e}")
    print()
    
    print("=" * 60)
    print("DATABASE LOAD COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()
