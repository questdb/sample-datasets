-- High/Low values for each Ticker

SELECT
    Ticker,
    MAX(High) AS MaxHigh,
    MIN(Low) AS MinLow
FROM nasdaq_open_close;

-- For each ticker, find the day that had the highest price at close. Then show the close price for that day

WITH max_highs AS (
    SELECT
        Ticker, MAX(High) AS MaxHigh
    FROM nasdaq_open_close
)
SELECT * FROM nasdaq_open_close n
INNER JOIN max_highs mh
    ON n.Ticker = mh.Ticker AND n.High = mh.MaxHigh;


-- Days with no trading activity (when the market is closed)

WITH sampled_and_interpolated_data AS (
    SELECT
        Timestamp, count() AS TotalEntries
    FROM nasdaq_open_close
    SAMPLE BY 1d FILL(NULL) ALIGN TO CALENDAR
)
SELECT TO_STR(Timestamp, 'EE') AS DayName, *
FROM sampled_and_interpolated_data
WHERE TotalEntries IS NULL;

-- Delta in trading volume from each day versus the previous day? hint: you might want to use LT JOIN ON

SELECT n1.*, n2.*, n1.Volume - n2.Volume
FROM nasdaq_open_close n1
LT JOIN nasdaq_open_close n2
    ON Ticker;
