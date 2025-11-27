"""
Accounting Sanity Check Script
Verifies that money flows balance across all accounts
"""
import pandas as pd
import os

DATA_DIR = r"c:\Users\afhja\phone-graphrag-framework\data\raw"

def load_data():
    """Load all data sources"""
    # BOA Billing
    boa_billing = pd.read_csv(os.path.join(DATA_DIR, "boa", "Billing account.csv"), skiprows=6)
    boa_billing['Amount'] = boa_billing['Amount'].astype(str).str.replace(',', '').astype(float)
    boa_billing['Date'] = pd.to_datetime(boa_billing['Date'])
    
    # BOA Spending
    boa_spending = pd.read_csv(os.path.join(DATA_DIR, "boa", "spending account.csv"), skiprows=6)
    boa_spending['Amount'] = boa_spending['Amount'].astype(str).str.replace(',', '').astype(float)
    boa_spending['Date'] = pd.to_datetime(boa_spending['Date'])
    
    # BOA CC
    boa_cc = pd.read_excel(os.path.join(DATA_DIR, "boa", "Credit Card.xlsx"))
    boa_cc['Posted Date'] = pd.to_datetime(boa_cc['Posted Date'])
    
    # Chase CC
    chase = pd.read_csv(os.path.join(DATA_DIR, "chase", "Chase6242_Activity20241001_20251127_20251127.CSV"))
    chase['Transaction Date'] = pd.to_datetime(chase['Transaction Date'])
    
    return boa_billing, boa_spending, boa_cc, chase

def analyze_money_flow():
    """Analyze money flow and check for balance"""
    boa_billing, boa_spending, boa_cc, chase = load_data()
    
    print("=" * 70)
    print("ACCOUNTING SANITY CHECK - Money Flow Analysis")
    print("=" * 70)
    print()
    
    # === BOA BILLING (Hub Account) ===
    print("--- BOA BILLING (Primary Checking - Income Hub) ---")
    billing_in = boa_billing[boa_billing['Amount'] > 0]['Amount'].sum()
    billing_out = boa_billing[boa_billing['Amount'] < 0]['Amount'].abs().sum()
    print(f"  Total IN:  ${billing_in:>12,.2f}")
    print(f"  Total OUT: ${billing_out:>12,.2f}")
    print(f"  Net:       ${billing_in - billing_out:>12,.2f}")
    print()
    
    # Break down income sources
    print("  Income Sources:")
    inflows = boa_billing[boa_billing['Amount'] > 0].copy()
    
    dfas = inflows[inflows['Description'].str.contains('DFAS', case=False, na=False)]['Amount'].sum()
    ssc = inflows[inflows['Description'].str.contains('SSC PAYROLL', case=False, na=False)]['Amount'].sum()
    city = inflows[inflows['Description'].str.contains('CITY OF COCOA', case=False, na=False)]['Amount'].sum()
    fed_pay = inflows[inflows['Description'].str.contains('FED PAYMNT|FED SALARY', case=False, na=False)]['Amount'].sum()
    
    print(f"    DFAS (Military):     ${dfas:>12,.2f}")
    print(f"    SSC (Wife Teacher):  ${ssc:>12,.2f}")
    print(f"    City of Cocoa:       ${city:>12,.2f}")
    print(f"    Fed Payment/Salary:  ${fed_pay:>12,.2f}")
    identified_income = dfas + ssc + city + fed_pay
    print(f"    Other income:        ${billing_in - identified_income:>12,.2f}")
    print()
    
    # Break down major outflows
    print("  Major Outflows from Billing:")
    outflows = boa_billing[boa_billing['Amount'] < 0].copy()
    outflows['Amount'] = outflows['Amount'].abs()
    
    # Credit card payments
    chase_pmts = outflows[outflows['Description'].str.contains('JPMORGAN CHASE', case=False, na=False)]['Amount'].sum()
    chase_epay = outflows[outflows['Description'].str.contains('CHASE CREDIT CRD', case=False, na=False)]['Amount'].sum()
    boa_cc_pmts = outflows[outflows['Description'].str.contains('CRD 4399', case=False, na=False)]['Amount'].sum()
    boa_cc_1213 = outflows[outflows['Description'].str.contains('CRD 1213', case=False, na=False)]['Amount'].sum()
    
    print(f"    → Chase CC (ACH):    ${chase_pmts:>12,.2f}")
    print(f"    → Chase CC (EPAY):   ${chase_epay:>12,.2f}")
    print(f"    → BOA CC 4399:       ${boa_cc_pmts:>12,.2f}")
    print(f"    → BOA CC 1213:       ${boa_cc_1213:>12,.2f}")
    
    # Other major bills
    chrysler = outflows[outflows['Description'].str.contains('CHRYSLER', case=False, na=False)]['Amount'].sum()
    state_farm = outflows[outflows['Description'].str.contains('STATE FARM', case=False, na=False)]['Amount'].sum()
    betterment = outflows[outflows['Description'].str.contains('BETTERMENT', case=False, na=False)]['Amount'].sum()
    irs = outflows[outflows['Description'].str.contains('IRS|USATAXPYMT', case=False, na=False)]['Amount'].sum()
    loan_pmts = outflows[outflows['Description'].str.contains('Loan Payment', case=False, na=False)]['Amount'].sum()
    compassion = outflows[outflows['Description'].str.contains('COMPASSION', case=False, na=False)]['Amount'].sum()
    
    print(f"    Chrysler Capital:    ${chrysler:>12,.2f}")
    print(f"    State Farm:          ${state_farm:>12,.2f}")
    print(f"    Betterment:          ${betterment:>12,.2f}")
    print(f"    IRS:                 ${irs:>12,.2f}")
    print(f"    Loan Payments:       ${loan_pmts:>12,.2f}")
    print(f"    Compassion Int'l:    ${compassion:>12,.2f}")
    
    identified_out = chase_pmts + chase_epay + boa_cc_pmts + boa_cc_1213 + chrysler + state_farm + betterment + irs + loan_pmts + compassion
    print(f"    Other outflows:      ${billing_out - identified_out:>12,.2f}")
    print()
    
    # === CREDIT CARD RECONCILIATION ===
    print("=" * 70)
    print("CREDIT CARD RECONCILIATION")
    print("=" * 70)
    print()
    
    # Chase CC
    print("--- CHASE CREDIT CARD ---")
    chase_charges = chase[chase['Type'] == 'Sale']['Amount'].abs().sum()
    chase_credits = chase[chase['Type'] == 'Payment']['Amount'].sum()
    chase_returns = chase[chase['Type'] == 'Return']['Amount'].sum() if 'Return' in chase['Type'].values else 0
    
    print(f"  Charges on card:       ${chase_charges:>12,.2f}")
    print(f"  Payments received:     ${chase_credits:>12,.2f}")
    print(f"  Returns/credits:       ${chase_returns:>12,.2f}")
    print(f"  Net balance change:    ${chase_charges - chase_credits - chase_returns:>12,.2f}")
    print()
    print(f"  Payments from Billing: ${chase_pmts + chase_epay:>12,.2f}")
    print(f"  Difference:            ${(chase_pmts + chase_epay) - chase_credits:>12,.2f}")
    print()
    
    # BOA CC
    print("--- BOA CREDIT CARD ---")
    cc_charges = boa_cc[boa_cc['Amount'] < 0]['Amount'].abs().sum()
    cc_payments = boa_cc[boa_cc['Amount'] > 0]['Amount'].sum()
    
    print(f"  Charges on card:       ${cc_charges:>12,.2f}")
    print(f"  Payments received:     ${cc_payments:>12,.2f}")
    print(f"  Net balance change:    ${cc_charges - cc_payments:>12,.2f}")
    print()
    print(f"  Payments from Billing: ${boa_cc_pmts + boa_cc_1213:>12,.2f}")
    print(f"  Difference:            ${(boa_cc_pmts + boa_cc_1213) - cc_payments:>12,.2f}")
    print()
    
    # === OVERALL ACCOUNTING ===
    print("=" * 70)
    print("OVERALL ACCOUNTING SUMMARY")
    print("=" * 70)
    print()
    
    # True terminal spending (CC charges that weren't transfers)
    total_cc_terminal = chase_charges + cc_charges
    total_cc_payments_from_billing = chase_pmts + chase_epay + boa_cc_pmts + boa_cc_1213
    
    # Non-CC outflows from billing
    non_cc_outflows = billing_out - total_cc_payments_from_billing
    
    print("Income (into Billing):")
    print(f"  Total income:          ${billing_in:>12,.2f}")
    print()
    
    print("Terminal Spending:")
    print(f"  Credit card charges:   ${total_cc_terminal:>12,.2f}")
    print(f"  Direct from billing:   ${non_cc_outflows:>12,.2f}")
    print(f"  TOTAL SPENDING:        ${total_cc_terminal + non_cc_outflows:>12,.2f}")
    print()
    
    gap = billing_in - (total_cc_terminal + non_cc_outflows)
    print(f"Gap (Income - Spending): ${gap:>12,.2f}")
    print()
    
    if abs(gap) > 5000:
        print("⚠️  SIGNIFICANT GAP DETECTED")
        print()
        print("Possible explanations:")
        print("  1. CC payments counted twice (in billing AND on CC statement)")
        print("  2. Missing income source")
        print("  3. Missing expense source")
        print("  4. Date range mismatch between accounts")
    
    # Double-counting check
    print()
    print("=" * 70)
    print("DOUBLE-COUNTING ANALYSIS")
    print("=" * 70)
    print()
    
    print("The issue: CC payments appear as:")
    print("  - Outflows from BOA Billing (we counted these)")
    print("  - Inflows on CC statements (payments received)")
    print()
    print("Correct calculation should be:")
    print(f"  Income:                ${billing_in:>12,.2f}")
    print(f"  - Direct bills:        ${non_cc_outflows:>12,.2f}")
    print(f"  - CC terminal spend:   ${total_cc_terminal:>12,.2f}")
    print(f"  = Net position:        ${billing_in - non_cc_outflows - total_cc_terminal:>12,.2f}")
    print()
    
    # But CC charges include balance carried forward?
    print("Note: If CC data includes beginning balance or prior period,")
    print("      charges may exceed actual period spending.")

if __name__ == "__main__":
    analyze_money_flow()
