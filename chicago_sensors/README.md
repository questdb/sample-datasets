# Chicago Sensors dataset (IoT)

The Chicago Park District maintains sensors in the water at beaches along Chicago's Lake Michigan lakefront. These
sensors generally capture the indicated measurements hourly while the sensors are in operation during the summer. During
 other seasons and at some other times, information from the sensors may not be available.

We want to thank the City of Chicago and the [Chicago Data Portal](https://data.cityofchicago.org/) for providing the
raw datasets we are using here.

This dataset has three tables, with some data overlapping in time:

* `chicago_sensor_locations`: (9 rows) The locations of the Chicago Park District water and weather sensors that feed https://data.cityofchicago.org/d/qmqz-2xku and https://data.cityofchicago.org/d/k7hf-8y75
* `chicago_water_sensors`: ~42K rows. Water data from sensors at some beaches
* `chicago_weather_stations`: ~160K rows. Data from sensors at weather stations

---

##  Table structure

### chicago_sensor_locations

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

### chicago_water_sensors

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

### chicago_weather_stations

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

---

## Importing the dataset using the command line

### chicago_sensor_locations

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@chicago_sensor_locations_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@chicago_sensor_locations.csv "http://localhost:9000/imp?name=chicago_sensor_locations"
```


### chicago_water_sensors

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@chicago_water_sensors_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@chicago_water_sensors.csv "http://localhost:9000/imp?name=chicago_water_sensors"
```

### chicago_weather_stations

The table can be created from the command line (change host/port as appropriate) via:
```bash
curl -G --data-urlencode query@chicago_weather_stations_create_table.sql http://localhost:9000/exec
```

The dataset can be now ingested via:
```bash
curl -F data=@chicago_weather_stations.csv "http://localhost:9000/imp?name=chicago_weather_stations"
```

---

## Some questions you can ask this dataset

* Which are the more chatty water/weather sensors?
* Which is the latest record for each sensor
* Are there any periods where we don't have any activity for each/all of the sensors? Can you find the longest period
without any activity? (hint: maybe using SAMPLE BY and FILL can help here)
* Get the latest record for each weather station, together with its coordinates. (This could be then plotted on a map)
* Can you join the weather and water datasets so for each entry on the water dataset we get the closest entry for the
closest weather station? hint: Try joining each table with the locations table, downcasting the geo resolution, then
doing an ASOF join.

Find [here](./chicago_sample_queries.sql) some SQL answers to these questions.


