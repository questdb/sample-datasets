# Finance dataset

The finance is formed by three independent tables which overlap in time, so they can be explored individually or
using `AS OF` joins.

* `btc_trades`: 5882 rows with Bitcoin/USD trades.
* `nasdaq_trades`: 14842 rows with trades for nine nasdaq-listed companies.
* `nasdaq_open_close`: 13590 rows with historical Open/Close/Low/High information for the same nine nasdaq-listed companies.

---

## btc_trades table

This table contains an hour (~5.9K rows, starting at `2023-09-05T16:00:00Z`) worth of Bitcoin/USD trades, as received using the
public Coinbase API (Thank you, Coinbase!). If you feel like joining two sample tables, the `nasdaq_trades` table
below has trading information for the same hour.


### Table structure

```sql
CREATE TABLE IF NOT EXISTS 'btc_trades' (
    symbol SYMBOL capacity 256 CACHE,
    side SYMBOL capacity 256 CACHE,
    price DOUBLE,
    amount DOUBLE,
    timestamp TIMESTAMP
) timestamp (timestamp) PARTITION BY DAY WAL
DEDUP UPSERT KEYS(timestamp, symbol, price, amount);

### Importing this table using the command line

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@btc_trades_create_table.sql http://localhost:9000/exec
```

The table can be now ingested via:
```bash
curl -F data=@btc_trades.csv "http://localhost:9000/imp?name=btc_trades"
```

## Some questions you can ask this table

* How many entries per minute are we getting?
* Can you find any gaps bigger than 1 second in data ingestion? bigger than 2? Which is the biggest you find?
* What's the most recent price registered for each side (`buy`/`sell`)?
* Which are the minimum, maximum, and average values for each 5 minutes interval? (could be used for a candle chart)
* Can you get each row price together with the moving average for the price on each side?
* And the average only for the minute before this row?
* Can you get the Volume Weighted Average Price in 15 minutes intervals?
* Explore joining this dataset (ASOF JOIN) with the `nasdaq_trades` dataset for extra fun

Find [here](./btc_trades_sample_queries.sql) some SQL answers to these questions.

_Note_: If you want to run some queries on this same table, but covering months worth of data, you can visit
[https://demo.questdb.io/](https://demo.questdb.io/).


---

## nasdaq_trades table

This table contains an hour (~15K rows, starting at `2023-09-05T16:00:00Z`) worth of trades for some nasdaq-listed companies
(`TSLA`, `NVDA`, `AMD`, `AVGO`, `AMZN`, `META`, `GOOGL`, `AAPL`, `MSFT`). The info was obtained from Yahoo Finance (Thank you, Yahoo!).
 If you feel like joining two sample tables, the `btc_trades` table above has trading information for the same hour.


### Table structure

```sql
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
) TIMESTAMP (timestamp) PARTITION BY DAY WAL
DEDUP UPSERT KEYS(timestamp, id);
```

### Importing this table using the command line

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@nasdaq_trades_create_table.sql http://localhost:9000/exec
```

The table can be now ingested via:
```bash
curl  -F data=@nasdaq_trades.csv "http://localhost:9000/imp?name=nasdaq_trades"
```

## Some questions you can ask this table

* How many entries per minute are we getting?
* Can you find any gaps equal or bigger than 1 second in data ingestion?
* For minutes where gaps happened, how many gaps we observed per minute?
* Which was the latest record for each different `id`
* Which company performed best in each 15 minutes interval? hint: you might need to do first a CTE with SAMPLE BY, then a query using rank()
* Which are the minimum, maximum, and average prices for each 5 minutes interval per `id`? (could be used for a candle chart)
* Can you calculate the delta in `DayVolume` for each record compared to the previous record with the same `id`?
hint: you might want to use LT JOIN ON
* Explore joining this dataset (ASOF JOIN) with the `btc_trades` or `nasdaq_open_close` datasets for extra fun

Find [here](./nasdaq_trades_sample_queries.sql) some SQL answers to these questions.

---

## nasdaq_open_close table

This table contains six years (~13.6K rows) worth of daily Open/High/Low/Close information for some nasdaq-listed companies (`TSLA`,
 `NVDA`, `AMD`, `AVGO`, `AMZN`, `META`, `GOOGL`, `AAPL`, `MSFT`). The info was obtained from Yahoo Finance (Thank you,
 Yahoo!). This table covers from `Sept 5 2017` to `Sept 5 2023`, and it overlaps with the `nasdaq_trades` and
 `btc_trades` tables above.

### Table structure

```sql
CREATE TABLE IF NOT EXISTS nasdaq_open_close (
        Ticker SYMBOL capacity 256 CACHE,
        Open DOUBLE,
        High DOUBLE,
        Low DOUBLE,
        Close DOUBLE,
        AdjClose DOUBLE,
        Volume LONG,
        Timestamp TIMESTAMP
) timestamp (Timestamp) PARTITION BY MONTH WAL
DEDUP UPSERT KEYS(Timestamp, Ticker);
```

### Importing this table using the command line

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@nasdaq_open_close_create_table.sql http://localhost:9000/exec
```

The table can be now ingested via:
```bash
 curl  -F data=@nasdaq_open_close.csv "http://localhost:9000/imp?name=nasdaq_open_close"
 ```

## Some questions you can ask this table

* Which was the highest/lowest value for each Ticker?
* Can you get the whole record for the highest day of each Ticker?
* Can you get a list of days with no activity? (Market was closed)
* Can you get the delta in Volume from each day and Ticker with the day before? hint: you might want to use LT JOIN ON
* Explore joining this dataset (ASOF JOIN) with the `nasdaq_trades` for extra fun

Find [here](./nasdaq_open_close_sample_queries.sql) some SQL answers to these questions.


