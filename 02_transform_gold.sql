-- ============================================================
--  SQL 02 — TRANSFORM BRONZE → GOLD
--  NSE Stock Market Analytics | DWBI Project
--  Run this in: Google BigQuery → Query Editor
-- ============================================================
--  Reads raw OHLCV data from the Bronze layer and computes
--  5 financial indicators using BigQuery SQL Window Functions:
--
--    sma_7            → 7-day  Simple Moving Average
--    sma_21           → 21-day Simple Moving Average
--    volatility_7     → 7-day  Rolling Standard Deviation
--    close_normalized → Normalized price (base = 1.0 on first day)
--    daily_return_pct → Daily percentage return vs previous day
--
--  Output: nse_stocks.gold_stock_analytics  (Gold Layer)
-- ============================================================

CREATE OR REPLACE TABLE `nse_stocks.gold_stock_analytics`
OPTIONS(
  description="Gold layer — NSE OHLCV data enriched with financial indicators",
  labels=[("layer", "gold"), ("project", "nse-dwbi")]
)
AS

WITH base AS (
  -- ── Bronze: select and validate raw data ──────────────────
  SELECT
    symbol,
    dt,
    open_price,
    high_price,
    low_price,
    close_price,
    volume
  FROM `nse_stocks.bronze_stock_raw`
  WHERE
    close_price IS NOT NULL
    AND dt IS NOT NULL
    AND symbol IS NOT NULL
),

with_indicators AS (
  SELECT
    symbol,
    dt,
    open_price,
    high_price,
    low_price,
    close_price,
    volume,

    -- ── 7-day Simple Moving Average ──────────────────────────
    -- Average closing price over the past 7 trading days
    ROUND(
      AVG(close_price) OVER (
        PARTITION BY symbol
        ORDER BY dt
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ), 4
    ) AS sma_7,

    -- ── 21-day Simple Moving Average ─────────────────────────
    -- Average closing price over the past 21 trading days
    ROUND(
      AVG(close_price) OVER (
        PARTITION BY symbol
        ORDER BY dt
        ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
      ), 4
    ) AS sma_21,

    -- ── 7-day Rolling Volatility (Standard Deviation) ────────
    -- Measures price volatility over a 7-day rolling window
    ROUND(
      STDDEV(close_price) OVER (
        PARTITION BY symbol
        ORDER BY dt
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ), 6
    ) AS volatility_7,

    -- ── Normalized Close Price ────────────────────────────────
    -- Price relative to each stock's first trading day (base = 1.0)
    -- Enables direct comparison of growth rates across stocks
    ROUND(
      close_price / FIRST_VALUE(close_price) OVER (
        PARTITION BY symbol
        ORDER BY dt
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
      ), 6
    ) AS close_normalized,

    -- ── Daily Return Percentage ───────────────────────────────
    -- Percentage change in close price vs the previous trading day
    ROUND(
      SAFE_DIVIDE(
        close_price - LAG(close_price) OVER (PARTITION BY symbol ORDER BY dt),
        LAG(close_price) OVER (PARTITION BY symbol ORDER BY dt)
      ) * 100,
      4
    ) AS daily_return_pct

  FROM base
)

SELECT
  *
FROM with_indicators
ORDER BY symbol, dt;

-- ============================================================
--  Verification queries — run after creating the Gold table
-- ============================================================

-- Check row counts per stock
-- SELECT symbol, COUNT(*) AS rows, MIN(dt) AS from_date, MAX(dt) AS to_date
-- FROM `nse_stocks.gold_stock_analytics`
-- GROUP BY symbol
-- ORDER BY symbol;

-- Preview Gold table
-- SELECT * FROM `nse_stocks.gold_stock_analytics`
-- WHERE symbol = 'RELIANCE.NS'
-- ORDER BY dt DESC
-- LIMIT 10;
