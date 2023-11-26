-- Number of trades per minute

SELECT
        timestamp, count() AS total
FROM btc_trades
SAMPLE BY 1m ALIGN TO CALENDAR;

-- Gaps longer than 1 (and then 2) second(s), without any data being ingested.

WITH trades_per_minute_interpolated AS (
    SELECT
        timestamp, count() AS total
    FROM btc_trades
    SAMPLE BY 1s FILL(NULL) ALIGN TO CALENDAR
)
SELECT *
FROM trades_per_minute_interpolated
WHERE total IS NULL;


-- Gaps longer than 1 (and then 2) second(s), without any data being ingested.

WITH trades_per_minute_interpolated AS (
    SELECT
        timestamp, count() AS total
    FROM btc_trades
    SAMPLE BY 6s FILL(NULL) ALIGN TO CALENDAR
)
SELECT *
FROM trades_per_minute_interpolated
WHERE total IS NULL;

-- Gaps longer than 1 (and then 2) second(s), without any data being ingested.

SELECT *
FROM btc_trades
LATEST ON timestamp PARTITION BY side;


-- High/low and average for trades, during a 5-minute interval

SELECT timestamp,
    MAX(price) AS max_price,
    MIN(price) AS min_price,
    AVG(price) AS avg_price
FROM btc_trades
SAMPLE BY 5m ALIGN TO CALENDAR;

-- Fetch the price for a given day alongside the moving average (on each trade side buy/sell)

SELECT timestamp, symbol, side, price, AVG(price) OVER (PARTITION BY side ORDER BY TIMESTAMP)
FROM btc_trades;

-- Fetch the price for a given day, alongside the moving average for the past minute (on each trade side buy/sell)

SELECT timestamp, symbol, side, price, AVG(price) OVER (PARTITION BY side ORDER BY TIMESTAMP RANGE BETWEEN 1 MINUTE PRECEDING AND CURRENT ROW)
FROM btc_trades;

-- Volume weighted average price (VWAP) in 15-minute intervals

SELECT timestamp,
  vwap(price,amount) AS vwap_price,
  SUM(amount) AS volume
FROM btc_trades
SAMPLE BY 15m ALIGN TO CALENDAR;
