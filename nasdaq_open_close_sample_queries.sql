-- Which was the highest/lowest value for each Ticker?

SELECT Ticker, MAX(High) AS MaxHigh, MIN(Low) AS MinLow
FROM nasdaq_open_close;

-- Can you get the whole record for the highest day of each Ticker?

WITH max_highs AS (
SELECT Ticker, MAX(High) AS MaxHigh
FROM nasdaq_open_close
)
SELECT * FROM nasdaq_open_close n
INNER JOIN max_highs mh
ON n.Ticker = mh.Ticker AND n.High = mh.MaxHigh;


-- Can you get a list of days with no activity? (Market was closed)

WITH sampled_and_interpolated_data AS (
SELECT Timestamp, count() AS TotalEntries
FROM nasdaq_open_close
SAMPLE BY 1d FILL(NULL) ALIGN TO CALENDAR
)
SELECT TO_STR(Timestamp, 'EE') AS DayName, * FROM sampled_and_interpolated_data
WHERE TotalEntries IS NULL;

-- Can you get the delta in Volume from each day and Ticker with the day before?

SELECT n1.*, n2.*, n1.Volume - n2.Volume
FROM nasdaq_open_close n1
LT JOIN nasdaq_open_close n2
ON Ticker;
