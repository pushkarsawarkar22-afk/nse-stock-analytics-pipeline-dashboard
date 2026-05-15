# ============================================================
#  Script 01 — EXTRACT
#  NSE Stock Market Analytics | DWBI Project
#  RCOEM Nagpur — VI Semester CSE (Data Science)
# ============================================================
#  Downloads historical OHLCV data for 5 major NSE stocks
#  from Yahoo Finance API and saves as CSV (Bronze Layer).
#
#  Stocks : RELIANCE.NS | TCS.NS | INFY.NS | HDFCBANK.NS | WIPRO.NS
#  Period : 2020-01-01 → today
#  Output : data/bronze_stock_raw.csv
# ============================================================

import yfinance as yf
import pandas as pd
import os
from datetime import datetime

# ── Configuration ─────────────────────────────────────────
STOCKS = [
    "RELIANCE.NS",   # Reliance Industries  — Energy
    "TCS.NS",        # Tata Consultancy Services — IT
    "INFY.NS",       # Infosys               — IT
    "HDFCBANK.NS",   # HDFC Bank             — Banking
    "WIPRO.NS",      # Wipro Limited         — IT
]

START_DATE = "2020-01-01"
END_DATE   = datetime.today().strftime("%Y-%m-%d")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "data")

# ── Download ──────────────────────────────────────────────
print("=" * 55)
print("  NSE Stock Data Extractor — Yahoo Finance API")
print("=" * 55)
print(f"  Period : {START_DATE}  →  {END_DATE}")
print(f"  Stocks : {len(STOCKS)} companies")
print("=" * 55)

all_data = []

for symbol in STOCKS:
    print(f"\n  Downloading {symbol} ...")
    try:
        df = yf.download(
            symbol,
            start=START_DATE,
            end=END_DATE,
            progress=False,
            auto_adjust=True
        )

        if df.empty:
            print(f"  ⚠  WARNING: No data returned for {symbol}. Skipping.")
            continue

        # Flatten multi-level columns returned by newer yfinance versions
        df.columns = [
            col[0] if isinstance(col, tuple) else col
            for col in df.columns
        ]

        df = df.reset_index()
        df.columns = df.columns.str.lower().str.replace(" ", "_")
        df["symbol"] = symbol

        # Rename to project schema
        df = df.rename(columns={
            "date":  "dt",
            "open":  "open_price",
            "high":  "high_price",
            "low":   "low_price",
            "close": "close_price",
        })

        df = df[[
            "symbol", "dt",
            "open_price", "high_price", "low_price",
            "close_price", "volume"
        ]]

        all_data.append(df)
        print(f"  ✅ Downloaded {len(df):,} rows for {symbol}")

    except Exception as e:
        print(f"  ❌ ERROR downloading {symbol}: {e}")

# ── Save ──────────────────────────────────────────────────
print("\n" + "=" * 55)

if all_data:
    combined = pd.concat(all_data, ignore_index=True)
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    output_path = os.path.join(OUTPUT_DIR, "bronze_stock_raw.csv")
    combined.to_csv(output_path, index=False)

    print(f"  ✅ Total rows saved : {len(combined):,}")
    print(f"  ✅ Output file      : {output_path}")
    print(f"  ✅ Stocks extracted : {combined['symbol'].nunique()}")
    print("=" * 55)
    print("\n  Next step → Upload bronze_stock_raw.csv to Google BigQuery")
    print("              Run the SQL in sql/02_transform_gold.sql\n")
else:
    print("  ❌ No data was downloaded. Check your internet connection.")
    print("=" * 55)
