-- How many entries per minute are we getting?

SELECT
        timestamp, count() AS total
FROM btc_trades
SAMPLE BY 1m ALIGN TO CALENDAR;

-- Can you find any gaps bigger than 1 second in data ingestion? bigger than 2?

WITH trades_per_minute_interpolated AS (
    SELECT
        timestamp, count() AS total
    FROM btc_trades
    SAMPLE BY 1s FILL(NULL) ALIGN TO CALENDAR
)
SELECT *
FROM trades_per_minute_interpolated
WHERE total IS NULL;


-- Which is the biggest gap (in seconds) you can find?

WITH trades_per_minute_interpolated AS (
    SELECT
        timestamp, count() AS total
    FROM btc_trades
    SAMPLE BY 6s FILL(NULL) ALIGN TO CALENDAR
)
SELECT *
FROM trades_per_minute_interpolated
WHERE total IS NULL;

-- What's the most recent price registered for each side (`buy`/`sell`)?

SELECT *
FROM btc_trades
LATEST ON timestamp PARTITION BY side;


-- Which are the minimum, maximum, and average values for each 5 minutes interval?

SELECT timestamp,
    MAX(price) AS max_price,
    MIN(price) AS min_price,
    AVG(price) AS avg_price
FROM btc_trades
SAMPLE BY 5m ALIGN TO CALENDAR;


-- Can you get the Volume Weighted Average Price in 15 minutes intervals?

SELECT timestamp,
  SUM(price * amount) / SUM(amount) AS vwap_price,
  SUM(amount) AS volume
FROM btc_trades
SAMPLE BY 15m ALIGN TO CALENDAR;
