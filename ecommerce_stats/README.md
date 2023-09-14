# e-commerce_stats (ecommerce)

Due to the commercial nature of these type of data, we couldn't find a relevant public dataset, so the ecommerce_stats
are engineered just as a sample dataset.

We are providing stats for number of `visits`, `unique_visitors`, `sales`, and `number_of_products` purchased. There is
a year (2022) worth of data –5475 rows– with a daily record per country (`DE`, `FR`, `UK`, `IT`,
 and `ES`) and category (`HOME`, `KITCHEN`, `BATHROOM`).

 We have engineered the dataset to simulate a growing site, so you will notice all the metrics get bigger over time.
 We also introduced some seasonality in the dataset. This is a good candidate sample dataset if you want to plot the
 data on a chart, or compare results by country.

---

## Table structure

```sql
CREATE TABLE IF NOT EXISTS ecommerce_stats(
  ts TIMESTAMP,
  country SYMBOL capacity 256 CACHE,
  category SYMBOL capacity 256 CACHE,
  visits LONG,
  unique_visitors LONG,
  sales DOUBLE,
  number_of_products INT
) timestamp (ts) PARTITION BY DAY WAL
DEDUP UPSERT KEYS(ts, country, category);
```

---

## Importing the dataset using the command line

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@ecommerce_stats_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@ecommerce_stats.csv "http://localhost:9000/imp?name=ecommerce_stats"
```

---

## Some questions you can ask this dataset

* What are the total stats for each month?
* And by category?
* And for each country?
* Can you plot the difference between UK and DE sales performance using QuestDB Console's built-in Chart functionality?
* How many products are we selling per quarter? Ordered by quarter and total of products.
* And per quarter and country?

Find [here](./ecommerce_stats_sample_queries.sql) some SQL answers to these questions.
