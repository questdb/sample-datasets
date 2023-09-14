# QuestDB Sample Datasets

We have curated four sample datasets —8 tables— ready to ingest into QuestDB, together with some business questions,
and the SQL queries to get the answers.

All the datasets except for one (the e-commerce table) contain real data obtained from public data sources.

The datasets are small enough, with the largest containing about 170K rows, so they should be very fast to ingest even
in smaller machines.

Each dataset features a `CREATE TABLE` statement that should be executed in your local QuestDB installation prior to
ingesting the CSV file. This step is necessary, so QuestDB can choose the right column types and designated timestamps.
If you import the CSV files directly without creating the table first, QuestDB will automatically create your tables, but
some queries might fail due to schema mismatch.

On the dataset links below, you will find instructions to execute the `CREATE TABLE` statements, and to import the CSV
files using the REST API from the command line. Note this could also be done directly via the QuestDB web console.

---

## finance dataset (Crypto/Market Data)

The finance is formed by three independent tables which overlap in time, so they can be explored individually or
using `AS OF` joins:

* `btc_trade`: 5882 rows with Bitcoin/USD trades.
* `nasdaq_trades`: 14842 rows with trades for nine nasdaq-listed companies.
* `nasdaq_open_close`: 13590 rows with historical Open/Close/Low/High information for the same nine nasdaq-listed companies.

[Info and ingestion instructions](./finance/README.md)

---

## Gitlog dataset (logs/activity)

Activity logs from three open source repositories on GitHub: [QuestDB](https://github.com/questdb/questdb), [Go](https://github.com/golang/go), and [Kubernetes](https://github.com/kubernetes/kubernetes).

Single table. ~174K rows.

[Info and ingestion instructions](./gitlog/README.md)

---

## Chicago Sensors dataset (IoT)

The Chicago Park District maintains sensors in the water at beaches along Chicago's Lake Michigan lakefront. These
sensors generally capture measurements hourly.

The dataset contains three tables:

* `chicago_sensor_locations`: 9 rows
* `chicago_water_sensors`: ~42K rows
* `chicago_weather_stations`: ~160K rows

[Info and ingestion instructions](./chicago_sensors/README.md)

---

## Ecommerce Stats dataset (ecommerce)

Synthetic statistics for an international ecommerce website. A year of data with a daily record for each country and
category.

Single table. 5475 rows.

[Info and ingestion instructions](./ecommerce_stats/README.md)

---


