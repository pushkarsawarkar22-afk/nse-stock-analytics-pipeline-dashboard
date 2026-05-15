<div align="center">

# 📈 NSE Stock Market Analytics
### Enterprise-Grade DWBI Pipeline for Indian Equity Markets

[![Python](https://img.shields.io/badge/Python-3.9%2B-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![BigQuery](https://img.shields.io/badge/Google_BigQuery-Cloud_DW-4285F4?style=for-the-badge&logo=googlebigquery&logoColor=white)](https://cloud.google.com/bigquery)
[![Looker Studio](https://img.shields.io/badge/Looker_Studio-BI_Dashboard-4285F4?style=for-the-badge&logo=googleanalytics&logoColor=white)](https://lookerstudio.google.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![RCOEM](https://img.shields.io/badge/RCOEM_Nagpur-DWBI_Project-orange?style=for-the-badge)](https://rknec.edu)

<br/>

> **A complete end-to-end Data Warehousing & Business Intelligence pipeline that extracts, transforms, and visualizes 6+ years of NSE stock market data — built entirely with free, open-source, cloud-native tools.**

<br/>

![Dashboard Preview](docs/dashboard_preview.png)

</div>

---

## 🌟 What This Project Does

This project builds a **production-grade DWBI pipeline** for analyzing historical stock market data of 5 major NSE-listed companies. It covers the **complete data engineering lifecycle** — from raw API extraction to interactive cloud dashboards — without any paid software.

```
Yahoo Finance API  →  Python Script  →  BigQuery (Bronze)  →  SQL Transform  →  BigQuery (Gold)  →  Looker Studio Dashboard
     [Source]           [Extract]          [Load]              [Transform]          [Serve]              [Visualize]
```

### 📊 Stocks Covered

| Stock | Company | Sector | Exchange |
|-------|---------|--------|----------|
| `RELIANCE.NS` | Reliance Industries Ltd. | Energy | NSE |
| `TCS.NS` | Tata Consultancy Services | Information Technology | NSE |
| `INFY.NS` | Infosys Limited | Information Technology | NSE |
| `HDFCBANK.NS` | HDFC Bank Limited | Banking & Finance | NSE |
| `WIPRO.NS` | Wipro Limited | Information Technology | NSE |

> **Data period:** January 1, 2020 → Present &nbsp;|&nbsp; **Total rows:** ~7,760+ &nbsp;|&nbsp; **Update frequency:** On-demand

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        MEDALLION ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│   🌐 Yahoo Finance API                                               │
│          │                                                            │
│          ▼                                                            │
│   🐍 Python (scripts/01_extract.py)                                  │
│      yfinance → pandas → CSV                                         │
│          │                                                            │
│          ▼                                                            │
│   ☁️  Google BigQuery — BRONZE LAYER                                 │
│      bronze_stock_raw                                                │
│      [symbol | dt | open | high | low | close | volume]              │
│          │                                                            │
│          ▼  SQL Window Functions (sql/02_transform_gold.sql)         │
│                                                                       │
│   ☁️  Google BigQuery — GOLD LAYER                                   │
│      gold_stock_analytics                                            │
│      [+ sma_7 | sma_21 | volatility_7 |                             │
│         close_normalized | daily_return_pct]                         │
│          │                                                            │
│          ▼                                                            │
│   📊 Google Looker Studio Dashboard                                  │
│      5 interactive charts | Stock filter | Date range control        │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

| Component | Technology | Purpose | Cost |
|-----------|-----------|---------|------|
| **Extraction** | Python 3.x + `yfinance` | Download NSE OHLCV data from Yahoo Finance | Free |
| **Data Warehouse** | Google BigQuery | Cloud-hosted data warehouse (Bronze + Gold layers) | Free tier (10GB) |
| **Transformation** | BigQuery SQL Window Functions | SMA, Volatility, Normalized Price, Daily Returns | Free tier |
| **Visualization** | Google Looker Studio | Interactive BI dashboard connected to BigQuery | Free |
| **Development** | Windows / macOS / Linux Terminal | Run extraction script locally | Built-in |

**Total infrastructure cost: ₹0 / $0** ✅

---

## 📐 Data Schema

### Bronze Layer — `bronze_stock_raw`
Raw data as extracted from Yahoo Finance.

| Column | Type | Description |
|--------|------|-------------|
| `symbol` | STRING | NSE ticker symbol (e.g., `RELIANCE.NS`) |
| `dt` | DATE | Trading date |
| `open_price` | FLOAT64 | Opening price (INR) |
| `high_price` | FLOAT64 | Day's highest price (INR) |
| `low_price` | FLOAT64 | Day's lowest price (INR) |
| `close_price` | FLOAT64 | Adjusted closing price (INR) |
| `volume` | INT64 | Total shares traded |

### Gold Layer — `gold_stock_analytics`
Enriched analytics-ready table with computed financial indicators.

| Column | Type | Description | Formula |
|--------|------|-------------|---------|
| `sma_7` | FLOAT64 | 7-day Simple Moving Average | `AVG(close) OVER 7 days` |
| `sma_21` | FLOAT64 | 21-day Simple Moving Average | `AVG(close) OVER 21 days` |
| `volatility_7` | FLOAT64 | 7-day rolling standard deviation | `STDDEV(close) OVER 7 days` |
| `close_normalized` | FLOAT64 | Price relative to first trading day | `close / FIRST_VALUE(close)` |
| `daily_return_pct` | FLOAT64 | Daily % change vs previous day | `(close - prev_close) / prev_close × 100` |

---

## 🚀 Quick Start

### Prerequisites

- Python 3.9 or higher
- A Google account (for BigQuery + Looker Studio — both free)
- Git

### Step 1 — Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/nse-dwbi-project.git
cd nse-dwbi-project
```

### Step 2 — Install Python Dependencies

```bash
pip install -r requirements.txt
```

### Step 3 — Run the Data Extraction Script

```bash
python scripts/01_extract.py
```

**Expected output:**
```
═══════════════════════════════════════════════════════
  NSE Stock Data Extractor — Yahoo Finance API
═══════════════════════════════════════════════════════
  Period : 2020-01-01  →  2026-04-09
  Stocks : 5 companies
═══════════════════════════════════════════════════════

  Downloading RELIANCE.NS ...
  ✅ Downloaded 1,552 rows for RELIANCE.NS

  Downloading TCS.NS ...
  ✅ Downloaded 1,552 rows for TCS.NS

  ...

  ✅ Total rows saved : 7,760
  ✅ Output file      : data/bronze_stock_raw.csv
```

### Step 4 — Upload to Google BigQuery

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Open **BigQuery** → Create a dataset named `nse_stocks`
3. Create a table → Upload `data/bronze_stock_raw.csv` → Table name: `bronze_stock_raw` → ✅ Auto-detect schema

### Step 5 — Run the SQL Transformation

Open **BigQuery Query Editor** and run:

```bash
# Copy and paste the contents of:
sql/02_transform_gold.sql
```

This creates the `gold_stock_analytics` table with all financial indicators computed.

### Step 6 — Connect Looker Studio

1. Go to [lookerstudio.google.com](https://lookerstudio.google.com)
2. Create Report → Add Data → BigQuery → `nse_stocks.gold_stock_analytics`
3. Build your dashboard using the charts described below!

---

## 📊 Dashboard Visualizations

The Looker Studio dashboard includes 5 interactive charts:

### 1. 📈 Simple Moving Averages Chart
Dual-axis time series showing `sma_7`, `sma_21`, and `close_price` from 2020 to present. Identify **Golden Cross** (SMA7 crosses above SMA21 = bullish) and **Death Cross** (SMA7 crosses below SMA21 = bearish) signals visually.

### 2. 🏔️ Stock Price History (Stacked Area)
Cumulative price contribution of all 5 stocks. Shows the relative scale of each stock and the overall market growth trajectory including the COVID-19 dip in early 2020 and the subsequent recovery.

### 3. 🟩 Daily Return Treemap
Color-coded treemap using a red→green gradient to show average daily returns per stock. **Green = positive average daily return. Red = negative/lower returns.** Tile size represents relative data volume.

### 4. 🫧 Market Volatility Bubble Chart
Scatter plot with bubble size = `volatility_7`. X-axis = `daily_return_pct`, Y-axis = `close_price`. Instantly shows the **risk-return profile** of each stock — bigger bubble means higher volatility.

### 5. 📊 Stocks Volume Bar Chart
Horizontal bar chart comparing total trading volume across all 5 stocks. HDFCBANK.NS leads with ~40 billion total shares traded, while TCS.NS has the lowest volume due to its high per-share price.

---

## 🔍 SQL Analytics Queries

Beyond the dashboard, `sql/03_analytics_queries.sql` includes 6 pre-built analytical queries:

| Query | Description |
|-------|-------------|
| **Summary Statistics** | Min, Max, Avg price, volatility, volume per stock |
| **Best & Worst Days** | Top gain and worst loss day per stock |
| **Monthly Averages** | Month-by-month price and volatility trends |
| **SMA Crossover Signals** | Automatic Golden Cross / Death Cross detection |
| **Yearly Performance** | Annual high, low, average, return per stock |
| **Most Volatile Days** | Top 10 highest volatility trading days across all stocks |

---

## 📂 Project Structure

```
nse-dwbi-project/
│
├── 📄 README.md                    ← You are here
├── 📄 requirements.txt             ← Python dependencies
├── 📄 .gitignore
│
├── 📁 scripts/
│   └── 01_extract.py              ← Data extraction (Yahoo Finance → CSV)
│
├── 📁 sql/
│   ├── 01_create_bronze.sql       ← BigQuery Bronze table schema
│   ├── 02_transform_gold.sql      ← Bronze → Gold transformation (Window Functions)
│   └── 03_analytics_queries.sql   ← Advanced analytical SQL queries
│
├── 📁 data/
│   └── .gitkeep                   ← Folder tracked by Git (CSVs are gitignored)
│
├── 📁 docs/
│   └── dashboard_preview.png      ← Dashboard screenshot
│
└── 📁 notebooks/
    └── (Jupyter notebooks — optional exploration)
```

---

## 📈 Key Findings

From the dashboard analysis across January 2020 — April 2026:

- 🟢 **RELIANCE.NS & INFY.NS** showed the strongest average daily returns, appearing as the largest green tiles in the Daily Return treemap.
- 🔵 **HDFCBANK.NS** had the highest trading liquidity (~40B shares), making it the easiest stock to trade in and out of.
- 🟡 **TCS.NS** had the highest absolute price volatility (largest bubble in the volatility chart) but the lowest trading volume due to its high per-share price.
- 📉 All 5 stocks showed a sharp COVID-19 dip in **March 2020**, followed by a strong recovery to new all-time highs by **2022–2024**.
- 📊 The SMA7 / SMA21 crossover signals are clearly visible in the Moving Averages chart, providing actionable buy/sell timing signals.

---

## 🎓 Academic Context

| Field | Details |
|-------|---------|
| **College** | Shri Ramdeobaba College of Engineering & Management (RCOEM), Nagpur |
| **Course** | Data Warehousing and Business Intelligence (DWBI) |
| **Program** | B.Tech — Computer Science & Engineering (Data Science) |
| **Semester** | VI Semester |
| **Academic Year** | 2025–2026 |

---

## 🤝 Contributing

Contributions are welcome! Here are some ideas to extend this project:

- [ ] Add more NSE stocks (expand to NIFTY 50)
- [ ] Add ARIMA / LSTM price forecasting using BigQuery ML
- [ ] Automate daily data refresh using Cloud Scheduler + Cloud Functions
- [ ] Add fundamental data (P/E ratio, EPS, Revenue) from public APIs
- [ ] Build a portfolio optimization module using Modern Portfolio Theory
- [ ] Add sector-level aggregation views (IT vs Banking vs Energy)

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [yfinance](https://github.com/ranaroussi/yfinance) — Yahoo Finance market data downloader
- [Google BigQuery](https://cloud.google.com/bigquery) — Cloud data warehouse
- [Google Looker Studio](https://lookerstudio.google.com) — Free BI platform
- [National Stock Exchange of India](https://www.nseindia.com) — Market data source
- [ngods-stocks](https://github.com/zsvoboda/ngods-stocks) — Architecture inspiration

---

<div align="center">

**Made with ❤️ at RCOEM Nagpur**

⭐ Star this repo if you found it useful! ⭐

[![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/nse-dwbi-project?style=social)](https://github.com/YOUR_USERNAME/nse-dwbi-project)

</div>
