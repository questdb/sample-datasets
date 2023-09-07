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

This dataset has been generating parsing the `git log` output for three open source repositories: [QuestDB](https://github.com/questdb/questdb), [Go](https://github.com/golang/go), and [Kubernetes](https://github.com/kubernetes/kubernetes). The dataset contains all the commits since the beginning of each project until `2023-09-05T07:05:52.000000Z`.

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
    SensorName SYMBOL,
    SensorType SYMBOL,
    Latitude DOUBLE,
    Longitude DOUBLE,
    G7c GEOHASH(7c)
    );
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
    ) timestamp(MeasurementTimestamp) PARTITION BY MONTH WAL;
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
    ) timestamp(MeasurementTimestamp) PARTITION BY MONTH WAL;
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

# ecommerce_stats (ecommerce)

Due to the commercial nature of these type of data, we couldn't find a relevant public dataset, so the ecommerce_stats
are engineered just as a sample dataset. We are providing stats for number of visits, unique_visitors, sales, and
number of products purchased. There is a year (2022) worth of data, with daily entry per country (`DE`, `FR`, `UK`, `IT`,
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
) timestamp (ts) PARTITION BY DAY WAL DEDUP UPSERT KEYS(ts, country, category);
```

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@ecommerce_stats_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@ecommerce_stats.csv "http://localhost:9000/imp?name=ecommerce_stats"
```


# btc_trades (finance)

This dataset contains an hour (starting at `2023-09-05T16:00:00Z`) worth of Bitcoin/USD trades, as received using the
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
    ) timestamp (timestamp) PARTITION BY DAY WAL;
```

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@btc_trades_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@btc_trades.csv "http://localhost:9000/imp?name=btc_trades"
```

# nasdaq_trades (finance)

This dataset contains an hour (starting at `2023-09-05T16:00:00Z`) worth of trades for some nasdaq-listed companies
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
    ) TIMESTAMP (timestamp) PARTITION BY DAY WAL;
```

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@nasdaq_trades_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl  -F data=@nasdaq_trades.csv "http://localhost:9000/imp?name=nasdaq_trades"
```



# nasdaq_open_close (finance)

This dataset contains six years worth of daily Open/High/Low/Close information for some nasdaq-listed companies (`TSLA`,
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
) timestamp (Timestamp) PARTITION BY MONTH WAL;
```

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@nasdaq_open_close_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
 curl  -F data=@nasdaq_open_close.csv "http://localhost:9000/imp?name=nasdaq_open_close"
 ```





