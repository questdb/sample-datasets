CREATE TABLE IF NOT EXISTS ecommerce_stats(
  ts TIMESTAMP,
  country SYMBOL capacity 256 CACHE,
  category SYMBOL capacity 256 CACHE,
  visits LONG,
  unique_visitors LONG,
  sales DOUBLE,
  number_of_products INT
) timestamp (ts) PARTITION BY DAY WAL DEDUP UPSERT KEYS(ts, country, category);
