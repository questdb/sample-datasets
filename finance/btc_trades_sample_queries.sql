-- Number of trades per minute

SELECT
        timestamp, count() AS total
FROM btc_trades
SAMPLE BY 1m ALIGN TO CALENDAR;

-- The most recent price for each trade side ('buy' / 'sell').

SELECT *
FROM btc_trades
LATEST ON timestamp PARTITION BY side;


-- Gaps longer than 1 second, without any data being ingested.

WITH trades_per_minute_interpolated AS (
    SELECT
        timestamp, count() AS total
    FROM btc_trades
    SAMPLE BY 1s FILL(NULL) ALIGN TO CALENDAR
)
SELECT *
FROM trades_per_minute_interpolated
WHERE total IS NULL;


-- 50 rows with a longer gap (time delta) with the previous row for the same side (buy/sell)
WITH time_and_prev AS (
  SELECT timestamp, side,
        first_value(timestamp::long) OVER (
          PARTITION BY side
          ORDER BY timestamp
          ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING
          ) AS prevTimestamp
FROM btc_trades
)
SELECT timestamp, side,
       PrevTimestamp::timestamp as prev,
       datediff('s', timestamp, prevTimestamp::timestamp) AS delta
FROM time_and_prev
ORDER BY delta DESC
limit 50;




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
