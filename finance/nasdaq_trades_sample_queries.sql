-- Number of trades per minute

SELECT timestamp, count()
FROM nasdaq_trades
SAMPLE BY 1m ALIGN TO CALENDAR;

-- Gaps longer than 1 second, without any data being ingested

WITH trades_and_gaps AS (
    SELECT
        timestamp, COUNT() AS total
    FROM nasdaq_trades
    SAMPLE BY 1s FILL(NULL) ALIGN TO CALENDAR
)
SELECT *
FROM trades_and_gaps
WHERE total IS NULL;

-- Gaps observed per minute (with gaps of more than 1 minute)

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

-- The most recent record for each ID

SELECT *
FROM nasdaq_trades
LATEST ON timestamp PARTITION BY id;

-- The company that performed best during each 15-minute interval

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

-- High/low and average for trades per ID, during a 5-minute interval

SELECT timestamp,
        id,
        MIN(price),
        MAX(price),
        AVG(price)
FROM nasdaq_trades
SAMPLE BY 5m ALIGN TO CALENDAR;

-- Delta in 'DayVolume' for each trade compared to the previous trade

SELECT t1.*, t2.*, t1.dayVolume - t2.dayVolume AS delta
FROM nasdaq_trades t1
LT JOIN nasdaq_trades t2
    ON id;
