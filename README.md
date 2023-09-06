# QuestDB Sample Datasets

We have curated, mostly from open datasets and in some cases generating synthetic data, a collection of datasets in CSV format which can be easily ingested into QuestDB.

Some of the datasets have been truncated, so they can be imported even in small machines.

Each dataset features a `CREATE TABLE` statement that should be executed in your local QuestDB installation prior to ingesting the CSV file. This step is necessary, so QuestDB can choose the right type of column and which is the designated timestamp. If you import the files directly without creating the table first, QuestDB will still automatically create your tables, but some queries will fail.

We are providing instructions to execute the `CREATE TABLE` statements and to import the files using the REST API, but you could also use the web interface if you prefer it.

The datasets we are providing are:
* `gitlog`: Activity logs from three open source repositories on GitHub: QuestDB, the Go programming language, and Kubernetes (Single table, repo name as one of the columns).
* `chicago_*` (three tables): Chicago water quality and weather sensor data. The weather and water quality datasets overlap in time, and there is a master table with sensors geolocation information.
* `ecommerce_stats`: Synthetic statistics for an international ecommerce website (Single table, one entry per day for each country and category).
* `btc_trades`: One hour worth of trading data for 'BTC-USD', at about one second intervals, as received from the Coinbase API (The hour interval is the same as in the `nasdaq_trades` dataset).
* `nasdaq_trades`: One hour worth of trading data for several Nasdaq-listed companies, as received from Yahoo Finance (The hour interval is the same as in the `btc_trades` dataset, and the symbols as the same as in the `nasdaq_open_low` dataset).
* `nasdaq_open_low`: Open/High/Low/Close information for several Nasdaq-listed companies (The same symbols as in the `nasdaq_trades` dataset).
