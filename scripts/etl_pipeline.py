"""
ETL Pipeline for Family Budget Data
Loads all financial data sources into a unified transaction format
"""
import pandas as pd
import os
import json
import hashlib
from datetime import datetime
from typing import Optional

DATA_DIR = r"c:\Users\afhja\phone-graphrag-framework\data\raw"
OUTPUT_DIR = r"c:\Users\afhja\phone-graphrag-framework\data\processed"


def generate_transaction_id(row: dict) -> str:
    """Generate a unique ID for a transaction based on its key fields"""
    desc = str(row.get('description', ''))[:50]
    key = f"{row['source_account']}|{row['transaction_date']}|{row['amount']}|{desc}"
    return hashlib.md5(key.encode()).hexdigest()[:12]


def load_boa_billing() -> pd.DataFrame:
    """Load BOA Billing checking account"""
    path = os.path.join(DATA_DIR, "boa", "Billing account.csv")
    df = pd.read_csv(path, skiprows=6)
    
    # Clean amount
    df['Amount'] = df['Amount'].astype(str).str.replace(',', '').astype(float)
    df['Date'] = pd.to_datetime(df['Date'])
    
    # Standardize columns
    result = pd.DataFrame({
        'transaction_date': df['Date'],
        'post_date': df['Date'],  # Same as transaction date for checking
        'description': df['Description'],
        'amount': df['Amount'],
        'source_account': 'boa_billing',
        'source_type': 'checking',
        'original_category': None,
        'raw_data': df.apply(lambda x: json.dumps(x.to_dict(), default=str), axis=1)
    })
    
    # Classify transaction type
    result['transaction_type'] = result['amount'].apply(
        lambda x: 'income' if x > 0 else 'expense'
    )
    
    return result


def load_boa_spending() -> pd.DataFrame:
    """Load BOA Spending checking account"""
    path = os.path.join(DATA_DIR, "boa", "spending account.csv")
    df = pd.read_csv(path, skiprows=6)
    
    # Clean amount
    df['Amount'] = df['Amount'].astype(str).str.replace(',', '').astype(float)
    df['Date'] = pd.to_datetime(df['Date'])
    
    # Standardize columns
    result = pd.DataFrame({
        'transaction_date': df['Date'],
        'post_date': df['Date'],
        'description': df['Description'],
        'amount': df['Amount'],
        'source_account': 'boa_spending',
        'source_type': 'checking',
        'original_category': None,
        'raw_data': df.apply(lambda x: json.dumps(x.to_dict(), default=str), axis=1)
    })
    
    result['transaction_type'] = result['amount'].apply(
        lambda x: 'income' if x > 0 else 'expense'
    )
    
    return result


def load_boa_cc() -> pd.DataFrame:
    """Load BOA Credit Card"""
    path = os.path.join(DATA_DIR, "boa", "Credit Card.xlsx")
    df = pd.read_excel(path)
    
    df['Posted Date'] = pd.to_datetime(df['Posted Date'])
    
    # Standardize columns
    result = pd.DataFrame({
        'transaction_date': df['Posted Date'],
        'post_date': df['Posted Date'],
        'description': df['Payee'] + ' ' + df['Address'].fillna(''),
        'amount': df['Amount'],  # Already negative for charges
        'source_account': 'boa_cc',
        'source_type': 'credit_card',
        'original_category': None,
        'raw_data': df.apply(lambda x: json.dumps(x.to_dict(), default=str), axis=1)
    })
    
    result['transaction_type'] = result['amount'].apply(
        lambda x: 'payment' if x > 0 else 'expense'
    )
    
    return result


def load_chase_cc() -> pd.DataFrame:
    """Load Chase Credit Card - has built-in categories!"""
    path = os.path.join(DATA_DIR, "chase", "Chase6242_Activity20241001_20251127_20251127.CSV")
    df = pd.read_csv(path)
    
    df['Transaction Date'] = pd.to_datetime(df['Transaction Date'])
    df['Post Date'] = pd.to_datetime(df['Post Date'])
    
    # Standardize columns
    result = pd.DataFrame({
        'transaction_date': df['Transaction Date'],
        'post_date': df['Post Date'],
        'description': df['Description'],
        'amount': df['Amount'],  # Negative for charges
        'source_account': 'chase_cc',
        'source_type': 'credit_card',
        'original_category': df['Category'],  # Chase provides categories!
        'raw_data': df.apply(lambda x: json.dumps(x.to_dict(), default=str), axis=1)
    })
    
    # Map Chase types to our types
    type_map = {
        'Sale': 'expense',
        'Payment': 'payment',
        'Return': 'refund',
        'Adjustment': 'adjustment',
        'Fee': 'fee'
    }
    result['transaction_type'] = df['Type'].map(type_map).fillna('expense')
    
    return result


def load_amazon_orders() -> pd.DataFrame:
    """Load Amazon order history for product-level details"""
    path = os.path.join(DATA_DIR, "amazon", "Retail.OrderHistory.1", "Retail.OrderHistory.1.csv")
    
    if not os.path.exists(path):
        # Check for direct file
        alt_path = os.path.join(DATA_DIR, "amazon", "Retail.OrderHistory.1.csv")
        if os.path.exists(alt_path):
            path = alt_path
        else:
            print("Warning: Amazon order history not found, skipping")
            return pd.DataFrame()
    
    df = pd.read_csv(path)
    df['Order Date'] = pd.to_datetime(df['Order Date'], format='ISO8601')
    
    # Clean price columns
    for col in ['Unit Price', 'Total Owed', 'Shipment Item Subtotal']:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col].astype(str).str.replace('$', '').str.replace(',', '').str.replace("'", ""), errors='coerce')
    
    # Create product-level records (not transactions - these link to CC charges)
    result = pd.DataFrame({
        'order_date': df['Order Date'],
        'order_id': df['Order ID'],
        'product_name': df['Product Name'],
        'unit_price': df.get('Unit Price', 0),
        'quantity': df.get('Quantity', 1),
        'total_owed': df.get('Total Owed', 0),
        'asin': df.get('ASIN', ''),
        'order_status': df.get('Order Status', ''),
        'ship_date': pd.to_datetime(df.get('Ship Date'), format='ISO8601', errors='coerce')
    })
    
    return result


def identify_transfers(df: pd.DataFrame) -> pd.DataFrame:
    """Identify and tag transfer transactions"""
    transfer_patterns = [
        # BOA internal transfers
        (r'Online Banking transfer', 'internal_transfer'),
        (r'Online Banking payment to CRD', 'cc_payment'),
        # Chase payments from BOA
        (r'JPMORGAN CHASE.*CHASE ACH', 'cc_payment'),
        (r'CHASE CREDIT CRD.*EPAY', 'cc_payment'),
        # Investment transfers
        (r'BETTERMENT.*TRANSFER', 'investment'),
        # ATM
        (r'ATM.*WITHDRWL', 'atm_withdrawal'),
        # Zelle
        (r'Zelle payment', 'p2p_transfer'),
    ]
    
    df['is_transfer'] = False
    df['transfer_type'] = None
    
    for pattern, transfer_type in transfer_patterns:
        mask = df['description'].str.contains(pattern, case=False, na=False)
        df.loc[mask, 'is_transfer'] = True
        df.loc[mask, 'transfer_type'] = transfer_type
        if transfer_type in ['cc_payment', 'investment', 'internal_transfer']:
            df.loc[mask, 'transaction_type'] = 'transfer'
    
    return df


def normalize_vendors(df: pd.DataFrame) -> pd.DataFrame:
    """Normalize vendor names for consistency"""
    vendor_patterns = [
        # Food delivery
        (r'DD \*DOORDASH.*', 'DoorDash'),
        (r'DOORDASH.*', 'DoorDash'),
        (r'UBER EATS.*', 'Uber Eats'),
        (r'GRUBHUB.*', 'Grubhub'),
        
        # Grocery
        (r'PUBLIX.*', 'Publix'),
        (r'WALMART.*', 'Walmart'),
        (r'TARGET.*', 'Target'),
        (r'COSTCO.*', 'Costco'),
        (r'SAMS CLUB.*', 'Sams Club'),
        
        # Gas
        (r'SHELL.*', 'Shell'),
        (r'CHEVRON.*', 'Chevron'),
        (r'EXXON.*', 'Exxon'),
        (r'BP.*', 'BP'),
        (r'WAWA.*', 'Wawa'),
        (r'RACETRAC.*', 'RaceTrac'),
        
        # Restaurants
        (r'CHICK-FIL-A.*', 'Chick-fil-A'),
        (r'MCDONALDS.*', 'McDonalds'),
        (r'STARBUCKS.*', 'Starbucks'),
        (r'DUNKIN.*', 'Dunkin'),
        (r'JIMMY JOHNS.*', 'Jimmy Johns'),
        (r'ZAXBYS.*', 'Zaxbys'),
        (r'PAPA ?JOHNS.*', 'Papa Johns'),
        
        # Amazon
        (r'AMAZON\.COM.*', 'Amazon'),
        (r'AMAZON RETA\*.*', 'Amazon'),
        (r'AMZN MKTP.*', 'Amazon Marketplace'),
        (r'AMAZON PRIME.*', 'Amazon Prime'),
        
        # Auto
        (r'TESLA.*', 'Tesla'),
        (r'CHRYSLER.*', 'Chrysler Capital'),
        
        # Insurance
        (r'STATE FARM.*', 'State Farm'),
        
        # Streaming/Subscriptions
        (r'NETFLIX.*', 'Netflix'),
        (r'SPOTIFY.*', 'Spotify'),
        (r'DISNEY PLUS.*', 'Disney+'),
        (r'HULU.*', 'Hulu'),
        (r'APPLE\.COM.*', 'Apple'),
        (r'GOOGLE \*.*', 'Google'),
        
        # Utilities
        (r'FPL.*|FLORIDA POWER.*', 'FPL'),
        
        # Financial
        (r'BETTERMENT.*', 'Betterment'),
        (r'IRS.*USATAXPYMT.*', 'IRS'),
        
        # Charity
        (r'COMPASSION.*', 'Compassion International'),
    ]
    
    df['normalized_vendor'] = df['description']
    
    for pattern, vendor in vendor_patterns:
        mask = df['description'].str.contains(pattern, case=False, na=False, regex=True)
        df.loc[mask, 'normalized_vendor'] = vendor
    
    # For non-matched, try to extract first meaningful part
    def extract_vendor(desc):
        if pd.isna(desc):
            return 'Unknown'
        # Remove common prefixes
        desc = str(desc)
        for prefix in ['SQ *', 'TST*', 'TST* ', 'PP*', 'PAYPAL *']:
            if desc.upper().startswith(prefix.upper()):
                desc = desc[len(prefix):]
        # Take first part before location info
        parts = desc.split()
        if len(parts) >= 2:
            return ' '.join(parts[:2])
        return parts[0] if parts else 'Unknown'
    
    # Apply extraction only to non-normalized entries
    mask = df['normalized_vendor'] == df['description']
    df.loc[mask, 'normalized_vendor'] = df.loc[mask, 'description'].apply(extract_vendor)
    
    return df


def run_etl():
    """Run the full ETL pipeline"""
    print("=" * 70)
    print("FAMILY BUDGET ETL PIPELINE")
    print("=" * 70)
    print()
    
    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Load all sources
    print("Loading data sources...")
    boa_billing = load_boa_billing()
    print(f"  BOA Billing:  {len(boa_billing):,} transactions")
    
    boa_spending = load_boa_spending()
    print(f"  BOA Spending: {len(boa_spending):,} transactions")
    
    boa_cc = load_boa_cc()
    print(f"  BOA CC:       {len(boa_cc):,} transactions")
    
    chase_cc = load_chase_cc()
    print(f"  Chase CC:     {len(chase_cc):,} transactions")
    
    amazon = load_amazon_orders()
    print(f"  Amazon:       {len(amazon):,} order items")
    print()
    
    # Combine transaction sources
    print("Combining transactions...")
    all_transactions = pd.concat([
        boa_billing, boa_spending, boa_cc, chase_cc
    ], ignore_index=True)
    print(f"  Total raw transactions: {len(all_transactions):,}")
    
    # Identify transfers
    print("Identifying transfers...")
    all_transactions = identify_transfers(all_transactions)
    transfer_count = all_transactions['is_transfer'].sum()
    print(f"  Transfers identified: {transfer_count:,}")
    
    # Normalize vendors
    print("Normalizing vendors...")
    all_transactions = normalize_vendors(all_transactions)
    unique_vendors = all_transactions['normalized_vendor'].nunique()
    print(f"  Unique vendors: {unique_vendors:,}")
    
    # Generate transaction IDs
    print("Generating transaction IDs...")
    all_transactions['transaction_id'] = all_transactions.apply(
        lambda row: generate_transaction_id(row.to_dict()), axis=1
    )
    
    # Sort by date
    all_transactions = all_transactions.sort_values('transaction_date').reset_index(drop=True)
    
    # Save unified transactions
    print()
    print("Saving processed data...")
    
    # CSV for easy viewing
    csv_path = os.path.join(OUTPUT_DIR, "unified_transactions.csv")
    all_transactions.drop(columns=['raw_data']).to_csv(csv_path, index=False)
    print(f"  Saved: {csv_path}")
    
    # JSON for full data with raw
    json_path = os.path.join(OUTPUT_DIR, "unified_transactions.json")
    all_transactions.to_json(json_path, orient='records', date_format='iso', indent=2)
    print(f"  Saved: {json_path}")
    
    # Save Amazon separately (product-level data)
    if len(amazon) > 0:
        amazon_path = os.path.join(OUTPUT_DIR, "amazon_orders.csv")
        amazon.to_csv(amazon_path, index=False)
        print(f"  Saved: {amazon_path}")
    
    # Summary stats
    print()
    print("=" * 70)
    print("ETL SUMMARY")
    print("=" * 70)
    print()
    print(f"Total transactions: {len(all_transactions):,}")
    print(f"Date range: {all_transactions['transaction_date'].min().date()} to {all_transactions['transaction_date'].max().date()}")
    print()
    print("By source account:")
    print(all_transactions.groupby('source_account').size().to_string())
    print()
    print("By transaction type:")
    print(all_transactions.groupby('transaction_type').size().to_string())
    print()
    print("Top 10 normalized vendors by transaction count:")
    print(all_transactions['normalized_vendor'].value_counts().head(10).to_string())
    print()
    
    # Financial summary
    print("Financial Summary:")
    expenses = all_transactions[all_transactions['transaction_type'] == 'expense']['amount'].sum()
    income = all_transactions[all_transactions['transaction_type'] == 'income']['amount'].sum()
    transfers = all_transactions[all_transactions['transaction_type'] == 'transfer']['amount'].sum()
    print(f"  Total Income:    ${income:>12,.2f}")
    print(f"  Total Expenses:  ${expenses:>12,.2f}")
    print(f"  Total Transfers: ${transfers:>12,.2f}")
    
    return all_transactions, amazon


if __name__ == "__main__":
    transactions, amazon = run_etl()
