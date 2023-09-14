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


# Dataset details

## gitlog (logs/activity)

This dataset has been generating parsing the `git log` output for three open source repositories: [QuestDB](https://github.com/questdb/questdb), [Go](https://github.com/golang/go), and [Kubernetes](https://github.com/kubernetes/kubernetes). The dataset contains all the commits (~174K rows) since the beginning of each project until `2023-09-05T07:05:52.000000Z`.

This is the table structure:
```sql
CREATE TABLE IF NOT EXISTS gitlog (
    committed_datetime TIMESTAMP,
    repo SYMBOL,
    author_name SYMBOL,
    summary STRING,
    size INT,
    insertions INT,
    deletions INT,
    lines INT,
    files INT
    ) timestamp (committed_datetime)
    PARTITION BY MONTH WAL
    DEDUP UPSERT KEYS(committed_datetime, repo, author_name);
```

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@gitlog_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@gitlog.csv "http://localhost:9000/imp?name=gitlog"
```

## Some questions you can ask this dataset

* How many commits do we have per repository?
* How many do we have per repository and month? Trivia: check out the date of Go first commit? :)
* Which is the latest registered commit for each repository?
* And the most recent contribution for each repository and author?
* What was the busiest day for each of the repos?
* Can you get an idea of the community health by tracking different contributors over the years?
* Are there any periods where we don't have any activity for each/all of the projects? Can you find the longest period
 without any activity? (hint: maybe using SAMPLE BY and FILL can help here)

Find [here](./gitlog_sample_queries.sql) some SQL answers to these questions.


# chicago dataset (IoT)

The Chicago Park District maintains sensors in the water at beaches along Chicago's Lake Michigan lakefront. These
sensors generally capture the indicated measurements hourly while the sensors are in operation during the summer. During
 other seasons and at some other times, information from the sensors may not be available.

We want to thank the City of Chicago and the [Chicago Data Portal](https://data.cityofchicago.org/) for providing the
raw datasets we are using here.

The dataset has three tables:

## chicago_sensor_locations

The locations of the Chicago Park District water and weather sensors that feed https://data.cityofchicago.org/d/qmqz-2xku and https://data.cityofchicago.org/d/k7hf-8y75

9 rows.

This is the table structure:
```sql
CREATE TABLE IF NOT EXISTS chicago_sensor_locations (
    UpdatedAt TIMESTAMP,
    SensorName SYMBOL,
    SensorType SYMBOL,
    Latitude DOUBLE,
    Longitude DOUBLE,
    G7c GEOHASH(7c)
) timestamp(UpdatedAt) PARTITION BY YEAR WAL
DEDUP UPSERT KEYS(UpdatedAt, SensorName);
```

We added the `G7c` column to the original dataset, representing a Geohash of 7chars (35 bytes), which allows for
a precision of 153m × 153m. More info at the [questdb docs](https://questdb.io/docs/concept/geohashes/).

Raw data is available at https://data.cityofchicago.org/Parks-Recreation/Beach-Water-and-Weather-Sensor-Locations/g3ip-u8rb.

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@chicago_sensor_locations_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@chicago_sensor_locations.csv "http://localhost:9000/imp?name=chicago_sensor_locations"
```


## chicago_water_sensors

About 42K rows.

This is the table structure:
```sql
CREATE TABLE IF NOT EXISTS chicago_water_sensors (
    MeasurementTimestamp TIMESTAMP,
    BeachName SYMBOL,
    WaterTemperature DOUBLE,
    Turbidity DOUBLE,
    TransducerDepth DOUBLE,
    WaveHeight DOUBLE,
    WavePeriod INT,
    BatteryLife DOUBLE,
    MeasurementTimestampLabel STRING,
    MeasurementID STRING
) timestamp(MeasurementTimestamp) PARTITION BY MONTH WAL
DEDUP UPSERT KEYS(MeasurementTimestamp, BeachName);
```

Raw data is available at https://data.cityofchicago.org/Parks-Recreation/Beach-Water-Quality-Automated-Sensors/qmqz-2xku

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@chicago_water_sensors_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@chicago_water_sensors.csv "http://localhost:9000/imp?name=chicago_water_sensors"
```

## chicago_weather_stations

About 160K rows.

This is the table structure:
```sql
CREATE TABLE IF NOT EXISTS chicago_weather_stations (
    MeasurementTimestamp TIMESTAMP,
    StationName SYMBOL,
    AirTemperature DOUBLE,
    WetBulbTemperature DOUBLE,
    Humidity INT,
    RainIntensity DOUBLE,
    IntervalRain DOUBLE,
    TotalRain DOUBLE,
    PrecipitationType INT,
    WindDirection INT,
    WindSpeed DOUBLE,
    MaximumWindSpeed DOUBLE,
    BarometricPressure DOUBLE,
    SolarRadiation INT,
    Heading INT,
    BatteryLife DOUBLE,
    MeasurementTimestampLabel STRING,
    MeasurementID STRING
) timestamp(MeasurementTimestamp) PARTITION BY MONTH WAL
DEDUP UPSERT KEYS(MeasurementTimestamp, StationName);
```

Raw data is available at https://data.cityofchicago.org/. Parks-Recreation/Beach-Weather-Stations-Automated-Sensors/k7hf-8y75

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@chicago_weather_stations_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@chicago_weather_stations.csv "http://localhost:9000/imp?name=chicago_weather_stations"
```

## Some questions you can ask this dataset

* Which are the more chatty water/weather sensors?
* Which is the latest registered row for each sensor
* Are there any periods where we don't have any activity for each/all of the sensors? Can you find the longest period
without any activity? (hint: maybe using SAMPLE BY and FILL can help here)
* Get the latest register for each weather station, together with its coordinates. (This could be then plotted on a map)
* Can you join the weather and water datasets so for each entry on the water dataset we get the closest entry for the
closest weather station? hint: Try joining each table with the locations table, downcasting the geo resolution, then
doing an ASOF join.

Find [here](./chicago_sample_queries.sql) some SQL answers to these questions.


# ecommerce_stats (ecommerce)

Due to the commercial nature of these type of data, we couldn't find a relevant public dataset, so the ecommerce_stats
are engineered just as a sample dataset. We are providing stats for number of visits, unique_visitors, sales, and
number of products purchased. There is a year (2022) worth of data –5475 rows– with daily entry per country (`DE`, `FR`, `UK`, `IT`,
 and `ES`) and category (`HOME`, `KITCHEN`, `BATHROOM`). We have engineered the dataset to simulate a growing site, so
 you will notice all the metrics get bigger over time. We also introduced some seasonality in the dataset. This is a
 good candidate sample dataset if you want to plot the data on a chart, or compare results by country.

This is the table structure:
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

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@ecommerce_stats_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@ecommerce_stats.csv "http://localhost:9000/imp?name=ecommerce_stats"
```

## Some questions you can ask this dataset

* What are the total stats for each month?
* And by category?
* And for each country?
* Can you plot the difference between UK and DE sales performance using QuestDB Console's built-in Chart functionality?
* How many products are we selling per quarter? Ordered by quarter and total of products.
* And per quarter and country?

Find [here](./ecommerce_stats_sample_queries.sql) some SQL answers to these questions.


# btc_trades (finance)

This dataset contains an hour (~5.9K rows, starting at `2023-09-05T16:00:00Z`) worth of Bitcoin/USD trades, as received using the
public Coinbase API (Thank you, Coinbase!). If you feel like joining two sample datasets, the `nasdaq_trades` dataset
below has trading information for the same hour.


This is the table structure:
```sql
CREATE TABLE IF NOT EXISTS 'btc_trades' (
    symbol SYMBOL capacity 256 CACHE,
    side SYMBOL capacity 256 CACHE,
    price DOUBLE,
    amount DOUBLE,
    timestamp TIMESTAMP
) timestamp (timestamp) PARTITION BY DAY WAL
DEDUP UPSERT KEYS(timestamp, symbol);
```

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@btc_trades_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@btc_trades.csv "http://localhost:9000/imp?name=btc_trades"
```

## Some questions you can ask this dataset

* How many entries per minute are we getting?
* Can you find any gaps bigger than 1 second in data ingestion? bigger than 2? Which is the biggest you find?
* What's the most recent price registered for each side (`buy`/`sell`)?
* Which are the minimum, maximum, and average values for each 5 minutes interval? (could be used for a candle chart)
* Can you get the Volume Weighted Average Price in 15 minutes intervals?
* Explore joining this dataset (ASOF JOIN) with the `nasdaq_trades` dataset for extra fun

Find [here](./btc_trades_sample_queries.sql) some SQL answers to these questions.

_Note_: If you want to run some queries on this same dataset, but covering months worth of data, you can visit
[https://demo.questdb.io/](https://demo.questdb.io/).


# nasdaq_trades (finance)

This dataset contains an hour (~15K rows, starting at `2023-09-05T16:00:00Z`) worth of trades for some nasdaq-listed companies
(`TSLA`, `NVDA`, `AMD`, `AVGO`, `AMZN`, `META`, `GOOGL`, `AAPL`, `MSFT`). The info was obtained from Yahoo Finance (Thank you, Yahoo!).
 If you feel like joining two sample datasets, the `btc_trades` dataset above has trading information for the same hour.

This is the table structure:
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

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@nasdaq_trades_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl  -F data=@nasdaq_trades.csv "http://localhost:9000/imp?name=nasdaq_trades"
```

## Some questions you can ask this dataset

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

# nasdaq_open_close (finance)

This dataset contains six years (~13.6K rows) worth of daily Open/High/Low/Close information for some nasdaq-listed companies (`TSLA`,
 `NVDA`, `AMD`, `AVGO`, `AMZN`, `META`, `GOOGL`, `AAPL`, `MSFT`). The info was obtained from Yahoo Finance (Thank you,
 Yahoo!). This dataset covers from `Sept 5 2017` to `Sept 5 2023`, and it overlaps with the `nasdaq_trades` and
 `btc_trades` datasets above.

This is the table structure:
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

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@nasdaq_open_close_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
 curl  -F data=@nasdaq_open_close.csv "http://localhost:9000/imp?name=nasdaq_open_close"
 ```

## Some questions you can ask this dataset

* Which was the highest/lowest value for each Ticker?
* Can you get the whole record for the highest day of each Ticker?
* Can you get a list of days with no activity? (Market was closed)
* Can you get the delta in Volume from each day and Ticker with the day before? hint: you might want to use LT JOIN ON
* Explore joining this dataset (ASOF JOIN) with the `nasdaq_trades` for extra fun

Find [here](./nasdaq_open_close_sample_queries.sql) some SQL answers to these questions.


