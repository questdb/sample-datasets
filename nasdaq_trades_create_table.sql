CREATE TABLE IF NOT EXISTS nasdaq_trades(
    timestamp TIMESTAMP,
    'id' SYMBOL capacity 256 CACHE,
    exchange SYMBOL capacity 256 CACHE,
    quoteType LONG,
    price DOUBLE,
    marketHours LONG,
    changePercent DOUBLE,
    dayVolume DOUBLE,
    change DOUBLE,
    priceHint LONG
    ) TIMESTAMP (timestamp) PARTITION BY DAY WAL;
