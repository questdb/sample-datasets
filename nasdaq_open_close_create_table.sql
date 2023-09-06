CREATE TABLE IF NOT EXISTS nasdaq_open_close (
        Ticker SYMBOL capacity 256 CACHE,
        Open DOUBLE,
        High DOUBLE,
        Low DOUBLE,
        Close DOUBLE,
        AdjClose DOUBLE,
        Volume LONG,
        Timestamp TIMESTAMP
) timestamp (Timestamp) PARTITION BY MONTH WAL;
