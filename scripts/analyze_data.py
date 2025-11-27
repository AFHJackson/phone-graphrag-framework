"""
Data Analysis Script for Family Budget POC
Analyzes all data sources to inform schema design
"""
import pandas as pd
import os

DATA_DIR = r"c:\Users\afhja\phone-graphrag-framework\data\raw"

def analyze_boa_billing():
    """Analyze BOA Billing account"""
    print("\n" + "="*60)
    print("BOA BILLING ACCOUNT ANALYSIS")
    print("="*60)
    
    path = os.path.join(DATA_DIR, "boa", "Billing account.csv")
    
    # Read skipping the summary header (first 6 lines), actual data starts at line 7
    df = pd.read_csv(path, skiprows=6)
    
    print(f"\nColumns: {df.columns.tolist()}")
    print(f"Rows: {len(df)}")
    
    # Convert Amount to numeric
    df['Amount'] = df['Amount'].astype(str).str.replace(',', '').str.replace('"', '').astype(float)
    
    # Separate inflows and outflows
    outflows = df[df['Amount'] < 0].copy()
    inflows = df[df['Amount'] > 0].copy()
    
    print(f"\nOutflow transactions: {len(outflows)}")
    print(f"Inflow transactions: {len(inflows)}")
    print(f"\nTotal outflow: ${outflows['Amount'].abs().sum():,.2f}")
    print(f"Total inflow: ${inflows['Amount'].sum():,.2f}")
    
    # Top payees by outflow
    print("\n--- Top 15 Payees (Outflows) ---")
    outflows['Amount'] = outflows['Amount'].abs()
    top_payees = outflows.groupby('Description')['Amount'].agg(['sum', 'count']).sort_values('sum', ascending=False).head(15)
    print(top_payees.to_string())
    
    return df

def analyze_boa_spending():
    """Analyze BOA Spending account"""
    print("\n" + "="*60)
    print("BOA SPENDING ACCOUNT ANALYSIS")
    print("="*60)
    
    path = os.path.join(DATA_DIR, "boa", "spending account.csv")
    
    # Read skipping the summary header
    df = pd.read_csv(path, skiprows=6)
    
    print(f"\nColumns: {df.columns.tolist()}")
    print(f"Rows: {len(df)}")
    
    # Convert Amount to numeric
    df['Amount'] = df['Amount'].astype(str).str.replace(',', '').str.replace('"', '').astype(float)
    
    # Separate inflows and outflows
    outflows = df[df['Amount'] < 0].copy()
    inflows = df[df['Amount'] > 0].copy()
    
    print(f"\nOutflow transactions: {len(outflows)}")
    print(f"Inflow transactions: {len(inflows)}")
    print(f"\nTotal outflow: ${outflows['Amount'].abs().sum():,.2f}")
    print(f"Total inflow: ${inflows['Amount'].sum():,.2f}")
    
    # Top payees by outflow
    print("\n--- Top 15 Payees (Outflows) ---")
    outflows['Amount'] = outflows['Amount'].abs()
    top_payees = outflows.groupby('Description')['Amount'].agg(['sum', 'count']).sort_values('sum', ascending=False).head(15)
    print(top_payees.to_string())
    
    return df

def analyze_boa_cc():
    """Analyze BOA Credit Card"""
    print("\n" + "="*60)
    print("BOA CREDIT CARD ANALYSIS")
    print("="*60)
    
    path = os.path.join(DATA_DIR, "boa", "Credit Card.xlsx")
    
    df = pd.read_excel(path)
    
    print(f"\nColumns: {df.columns.tolist()}")
    print(f"Rows: {len(df)}")
    
    # Separate charges and payments
    charges = df[df['Amount'] < 0].copy()
    payments = df[df['Amount'] > 0].copy()
    
    print(f"\nCharges: {len(charges)} transactions")
    print(f"Payments/Credits: {len(payments)} transactions")
    print(f"\nTotal charges: ${charges['Amount'].abs().sum():,.2f}")
    print(f"Total payments: ${payments['Amount'].sum():,.2f}")
    
    # Top payees by spend
    print("\n--- Top 20 Payees (Charges) ---")
    charges['Amount'] = charges['Amount'].abs()
    top_payees = charges.groupby('Payee')['Amount'].agg(['sum', 'count']).sort_values('sum', ascending=False).head(20)
    print(top_payees.to_string())
    
    # Look for Amazon specifically
    print("\n--- Amazon Charges ---")
    amazon = charges[charges['Payee'].str.contains('AMAZON', case=False, na=False)]
    print(f"Amazon transactions: {len(amazon)}")
    print(f"Amazon total: ${amazon['Amount'].sum():,.2f}")
    
    return df

def analyze_chase():
    """Analyze Chase Credit Card"""
    print("\n" + "="*60)
    print("CHASE CREDIT CARD ANALYSIS")
    print("="*60)
    
    path = os.path.join(DATA_DIR, "chase", "Chase6242_Activity20241001_20251127_20251127.CSV")
    
    df = pd.read_csv(path)
    
    print(f"\nColumns: {df.columns.tolist()}")
    print(f"Rows: {len(df)}")
    
    # Separate sales and payments
    sales = df[df['Type'] == 'Sale'].copy()
    payments = df[df['Type'] == 'Payment'].copy()
    
    print(f"\nSales: {len(sales)} transactions")
    print(f"Payments: {len(payments)} transactions")
    
    # Total spend
    sales['Amount'] = sales['Amount'].abs()
    print(f"\nTotal spend: ${sales['Amount'].sum():,.2f}")
    
    # By category
    print("\n--- By Category ---")
    cat_summary = sales.groupby('Category')['Amount'].agg(['sum', 'count']).sort_values('sum', ascending=False)
    print(cat_summary.to_string())
    
    return df

def analyze_amazon():
    """Analyze Amazon orders"""
    print("\n" + "="*60)
    print("AMAZON ORDERS ANALYSIS")
    print("="*60)
    
    amazon_dir = os.path.join(DATA_DIR, "amazon")
    
    # Look for order history specifically
    order_history_path = os.path.join(amazon_dir, "Retail.OrderHistory.1")
    
    if os.path.isdir(order_history_path):
        for fname in os.listdir(order_history_path):
            if fname.endswith('.csv'):
                fpath = os.path.join(order_history_path, fname)
                print(f"\n--- {fname} ---")
                try:
                    df = pd.read_csv(fpath)
                    print(f"Columns: {df.columns.tolist()}")
                    print(f"Rows: {len(df)}")
                    
                    # Look for price/total columns
                    for col in df.columns:
                        if 'price' in col.lower() or 'total' in col.lower() or 'amount' in col.lower():
                            print(f"\n{col} sample: {df[col].head(5).tolist()}")
                except Exception as e:
                    print(f"Error: {e}")
    else:
        # Check if it's a file
        for fname in os.listdir(amazon_dir):
            fpath = os.path.join(amazon_dir, fname)
            if os.path.isdir(fpath):
                print(f"\n--- Folder: {fname} ---")
                for subfile in os.listdir(fpath)[:3]:
                    print(f"  - {subfile}")
            elif fname.endswith('.csv'):
                print(f"\n--- {fname} ---")
                try:
                    df = pd.read_csv(fpath)
                    print(f"Columns: {df.columns.tolist()}")
                except Exception as e:
                    print(f"Error reading: {e}")

def main():
    print("="*60)
    print("FAMILY BUDGET DATA ANALYSIS")
    print("="*60)
    
    analyze_boa_billing()
    analyze_boa_spending()
    analyze_boa_cc()
    analyze_chase()
    analyze_amazon()

if __name__ == "__main__":
    main()
