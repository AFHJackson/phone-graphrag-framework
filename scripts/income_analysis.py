"""
Income Analysis - Check for overlap/double-counting
"""
import pandas as pd

# Load billing
boa_billing = pd.read_csv(r'c:\Users\afhja\phone-graphrag-framework\data\raw\boa\Billing account.csv', skiprows=6)
boa_billing['Amount'] = boa_billing['Amount'].astype(str).str.replace(',', '').astype(float)
boa_billing['Date'] = pd.to_datetime(boa_billing['Date'])
inflows = boa_billing[boa_billing['Amount'] > 0].copy()

print("=" * 70)
print("INCOME SOURCE ANALYSIS")
print("=" * 70)
print()

# Check if DFAS and FED are overlapping (same deposits)
dfas = inflows[inflows['Description'].str.contains('DFAS', case=False, na=False)]
fed = inflows[inflows['Description'].str.contains('FED PAYMNT|FED SALARY', case=False, na=False)]

print("=== DFAS Deposits (sample) ===")
print(dfas[['Date', 'Amount']].head(5).to_string())
print(f"Count: {len(dfas)}, Total: ${dfas['Amount'].sum():,.2f}")
print()

print("=== Fed Payment/Salary (sample) ===")
print(fed[['Date', 'Amount']].head(5).to_string())
print(f"Count: {len(fed)}, Total: ${fed['Amount'].sum():,.2f}")
print()

# The issue: DFAS entries CONTAIN "FED SALARY" in description!
print("=== Overlap Check ===")
dfas_with_fed = dfas[dfas['Description'].str.contains('FED SALARY', case=False, na=False)]
print(f"DFAS entries that also match 'FED SALARY': {len(dfas_with_fed)}")
print()

# Let's look at unique income patterns
print("=== All Income Patterns ===")
inflows['Pattern'] = inflows['Description'].apply(lambda x: x.split(' ')[0] if pd.notna(x) else 'Unknown')
by_pattern = inflows.groupby('Pattern')['Amount'].agg(['sum', 'count']).sort_values('sum', ascending=False)
print(by_pattern.head(20).to_string())
print()
print(f"Total all inflows: ${inflows['Amount'].sum():,.2f}")
