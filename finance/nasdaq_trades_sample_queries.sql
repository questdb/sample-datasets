-- How many entries per minute are we getting?

SELECT timestamp, count()
FROM nasdaq_trades
SAMPLE BY 1m ALIGN TO CALENDAR;

-- Can you find any gaps equal or bigger than 1 second in data ingestion?

WITH trades_and_gaps AS (
    SELECT
        timestamp, COUNT() AS total
    FROM nasdaq_trades
    SAMPLE BY 1s FILL(NULL) ALIGN TO CALENDAR
)
SELECT *
FROM trades_and_gaps
WHERE total IS NULL;

-- For minutes where gaps happened, how many gaps we observed per minute?

WITH trades_and_gaps AS (
    SELECT
        timestamp, COUNT() AS total
    FROM nasdaq_trades
    SAMPLE BY 1s FILL(NULL) ALIGN TO CALENDAR
)
SELECT timestamp, COUNT()
FROM trades_and_gaps
WHERE total IS NULL
SAMPLE BY 1m ALIGN TO CALENDAR;

-- Which was the latest record for each different `id`

SELECT *
FROM nasdaq_trades
LATEST ON timestamp PARTITION BY id;

-- Which company performed best in each 15 minutes interval?

WITH intervals AS (
  SELECT
    id,
    timestamp,
    max(price) AS price
  FROM
    nasdaq_trades SAMPLE BY 15m ALIGN TO CALENDAR
),
ranked AS (
  SELECT
    id,
    timestamp,
    price,
    RANK() OVER(
      PARTITION BY timestamp
      ORDER BY
        price DESC
    ) AS position
  FROM
    intervals
)
SELECT
  *
FROM
  ranked
WHERE
  position = 1

-- Which are the minimum, maximum, and average prices for each 5 minutes interval per `id`?

SELECT timestamp,
        id,
        MIN(price),
        MAX(price),
        AVG(price)
FROM nasdaq_trades
SAMPLE BY 5m ALIGN TO CALENDAR;

-- Can you calculate the delta in `DayVolume` for each record compared to the previous record with the same `id`

SELECT t1.*, t2.*, t1.dayVolume - t2.dayVolume AS delta
FROM nasdaq_trades t1
LT JOIN nasdaq_trades t2
    ON id;
