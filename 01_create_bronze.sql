-- ============================================================
--  SQL 01 — CREATE BRONZE TABLE
--  NSE Stock Market Analytics | DWBI Project
--  Run this in: Google BigQuery → Query Editor
-- ============================================================
--  Creates the raw Bronze layer table schema.
--  After running this, upload bronze_stock_raw.csv via:
--  BigQuery Console → your dataset → Create Table → Upload CSV
-- ============================================================

CREATE TABLE IF NOT EXISTS `nse_stocks.bronze_stock_raw` (
  symbol       STRING    OPTIONS(description="NSE ticker symbol e.g. RELIANCE.NS"),
  dt           DATE      OPTIONS(description="Trading date"),
  open_price   FLOAT64   OPTIONS(description="Opening price in INR"),
  high_price   FLOAT64   OPTIONS(description="Day high price in INR"),
  low_price    FLOAT64   OPTIONS(description="Day low price in INR"),
  close_price  FLOAT64   OPTIONS(description="Adjusted closing price in INR"),
  volume       INT64     OPTIONS(description="Total shares traded")
)
OPTIONS(
  description="Bronze layer — raw NSE OHLCV data extracted from Yahoo Finance API",
  labels=[("layer", "bronze"), ("project", "nse-dwbi")]
);
