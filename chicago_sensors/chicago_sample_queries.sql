-- The most "chatty" water/weather sensors

SELECT 'weather' AS type, StationName AS name, count() AS total
FROM chicago_weather_stations
UNION
SELECT 'water' AS type, BeachName AS name, count() AS total
FROM chicago_water_sensors
ORDER by total desc;

-- The most recent record for each sensor

SELECT * FROM chicago_water_sensors
LATEST ON MeasurementTimestamp
    PARTITION BY BeachName;

SELECT * FROM chicago_weather_stations
LATEST ON MeasurementTimestamp
    PARTITION BY StationName;


-- Periods where there is no activity for each or all of the sensors

SELECT MeasurementTimestamp, count() as total
FROM chicago_weather_stations
SAMPLE BY 1M FILL(null) ALIGN TO CALENDAR;


-- 50 rows with a longer gap (time delta) with the previous row for the same StationName
WITH time_and_prev AS (
SELECT MeasurementTimestamp, StationName,
       first_value(MeasurementTimestamp::long) OVER (
          PARTITION BY StationName
          ORDER BY MeasurementTimestamp
          ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING
          ) AS PrevTimestamp
FROM chicago_weather_stations
)
SELECT MeasurementTimestamp, StationName,
       PrevTimestamp::timestamp,
       datediff('d', MeasurementTimestamp, PrevTimestamp::timestamp) AS delta
FROM time_and_prev
ORDER BY delta desc
limit 50;

-- Most recent record for each weather station, alongside its coordinates (this can then be plotted on a map)

SELECT * FROM chicago_water_sensors w
  JOIN chicago_sensor_locations s
    ON (w.BeachName = s.SensorName)
LATEST ON MeasurementTimestamp
    PARTITION BY BeachName;


-- Join weather and water datasets. For each entry on the water dataset, we should get the closest (timewise) weather station entry.

WITH cweathergeo AS (
    SELECT
        c.*,
        G7c,
        CAST(G7c AS geohash(5c)) AS geo
    FROM chicago_weather_stations c
    JOIN chicago_sensor_locations l
        ON(c.StationName=l.SensorName)
), cwatergeo AS (
    SELECT
        c.*,
        G7c,
        CAST(G7c AS geohash(5c)) AS geo
    FROM chicago_water_sensors c
    JOIN chicago_sensor_locations l
        ON(BeachName=SensorName)
)
SELECT
    we.MeasurementTimestamp,
    StationName,
    we.geo,
    we.G7c,
    wa.G7c,
    wa.MeasurementTimestamp,
    wa.BeachName,
    wa.geo
FROM cweathergeo we
ASOF JOIN cwatergeo wa
    ON(geo);
