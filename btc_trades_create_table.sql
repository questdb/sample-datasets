CREATE TABLE IF NOT EXISTS 'btc_trades' (
    symbol SYMBOL capacity 256 CACHE,
    side SYMBOL capacity 256 CACHE,
    price DOUBLE,
    amount DOUBLE,
    timestamp TIMESTAMP
    ) timestamp (timestamp) PARTITION BY DAY WAL;
