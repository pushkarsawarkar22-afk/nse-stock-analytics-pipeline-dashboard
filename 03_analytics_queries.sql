-- ============================================================
--  SQL 03 — ANALYTICS QUERIES
--  NSE Stock Market Analytics | DWBI Project
--  Run these in: Google BigQuery → Query Editor
-- ============================================================
--  A collection of useful analytical SQL queries on the
--  Gold table for deeper insights beyond the dashboard.
-- ============================================================


-- ── Query 1: Overall Summary Statistics ──────────────────────
-- Returns key stats per stock across the full observation period
SELECT
  symbol,
  COUNT(*)                        AS total_trading_days,
  MIN(dt)                         AS start_date,
  MAX(dt)                         AS end_date,
  ROUND(MIN(close_price), 2)      AS min_close,
  ROUND(MAX(close_price), 2)      AS max_close,
  ROUND(AVG(close_price), 2)      AS avg_close,
  ROUND(AVG(volatility_7), 2)     AS avg_volatility,
  ROUND(AVG(daily_return_pct), 4) AS avg_daily_return_pct,
  SUM(volume)                     AS total_volume
FROM `nse_stocks.gold_stock_analytics`
GROUP BY symbol
ORDER BY avg_close DESC;


-- ── Query 2: Best and Worst Trading Days per Stock ────────────
SELECT
  symbol,
  dt,
  close_price,
  daily_return_pct,
  CASE
    WHEN daily_return_pct = MAX(daily_return_pct) OVER (PARTITION BY symbol)
    THEN 'Best Day'
    WHEN daily_return_pct = MIN(daily_return_pct) OVER (PARTITION BY symbol)
    THEN 'Worst Day'
    ELSE NULL
  END AS day_type
FROM `nse_stocks.gold_stock_analytics`
WHERE daily_return_pct IN (
  SELECT MAX(daily_return_pct) FROM `nse_stocks.gold_stock_analytics` GROUP BY symbol
  UNION ALL
  SELECT MIN(daily_return_pct) FROM `nse_stocks.gold_stock_analytics` GROUP BY symbol
)
ORDER BY symbol, daily_return_pct DESC;


-- ── Query 3: Monthly Average Close Price ──────────────────────
SELECT
  symbol,
  FORMAT_DATE('%Y-%m', dt)        AS month,
  ROUND(AVG(close_price), 2)      AS avg_monthly_close,
  ROUND(AVG(sma_7), 2)            AS avg_sma7,
  ROUND(AVG(volatility_7), 4)     AS avg_volatility
FROM `nse_stocks.gold_stock_analytics`
GROUP BY symbol, month
ORDER BY symbol, month;


-- ── Query 4: SMA Crossover Signals (Golden/Death Cross) ───────
-- A Golden Cross occurs when SMA7 crosses ABOVE SMA21 (buy signal)
-- A Death Cross occurs when SMA7 crosses BELOW SMA21 (sell signal)
WITH crossover AS (
  SELECT
    symbol,
    dt,
    sma_7,
    sma_21,
    close_price,
    LAG(sma_7)  OVER (PARTITION BY symbol ORDER BY dt) AS prev_sma7,
    LAG(sma_21) OVER (PARTITION BY symbol ORDER BY dt) AS prev_sma21
  FROM `nse_stocks.gold_stock_analytics`
  WHERE sma_7 IS NOT NULL AND sma_21 IS NOT NULL
)
SELECT
  symbol,
  dt,
  close_price,
  ROUND(sma_7, 2)  AS sma_7,
  ROUND(sma_21, 2) AS sma_21,
  CASE
    WHEN sma_7 > sma_21 AND prev_sma7 <= prev_sma21 THEN '🟢 Golden Cross (BUY)'
    WHEN sma_7 < sma_21 AND prev_sma7 >= prev_sma21 THEN '🔴 Death Cross  (SELL)'
    ELSE NULL
  END AS signal
FROM crossover
WHERE
  (sma_7 > sma_21 AND prev_sma7 <= prev_sma21)
  OR (sma_7 < sma_21 AND prev_sma7 >= prev_sma21)
ORDER BY symbol, dt;


-- ── Query 5: Yearly Performance Summary ──────────────────────
SELECT
  symbol,
  EXTRACT(YEAR FROM dt)           AS year,
  ROUND(MIN(close_price), 2)      AS yearly_low,
  ROUND(MAX(close_price), 2)      AS yearly_high,
  ROUND(AVG(close_price), 2)      AS avg_close,
  ROUND(AVG(daily_return_pct), 4) AS avg_daily_return,
  ROUND(AVG(volatility_7), 4)     AS avg_volatility,
  SUM(volume)                     AS total_volume
FROM `nse_stocks.gold_stock_analytics`
GROUP BY symbol, year
ORDER BY symbol, year;


-- ── Query 6: Top 10 Most Volatile Days ───────────────────────
SELECT
  symbol,
  dt,
  close_price,
  ROUND(volatility_7, 4)     AS volatility_7,
  ROUND(daily_return_pct, 4) AS daily_return_pct
FROM `nse_stocks.gold_stock_analytics`
ORDER BY volatility_7 DESC
LIMIT 10;
