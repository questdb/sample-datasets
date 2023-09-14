-- Which are the more chatty water/weather sensors?

SELECT 'weather' AS type, StationName AS name, count() AS total
FROM chicago_weather_stations
UNION
SELECT 'water' AS type, BeachName AS name, count() AS total
FROM chicago_water_sensors
ORDER by total desc;

-- Which is the latest registered row for each sensor

SELECT * FROM chicago_water_sensors
LATEST ON MeasurementTimestamp
    PARTITION BY BeachName;

SELECT * FROM chicago_weather_stations
LATEST ON MeasurementTimestamp
    PARTITION BY StationName;


-- Are there any periods where we don't have any activity for each/all of the sensors?

SELECT MeasurementTimestamp, count() as total
FROM chicago_weather_stations
SAMPLE BY 1M FILL(null) ALIGN TO CALENDAR;


-- Can you find the longest period without any activity? (hint: maybe using SAMPLE BY and FILL can help here)

WITH sampled_and_interpolated AS (
  SELECT MeasurementTimestamp, count() AS total
  FROM chicago_weather_stations
  SAMPLE BY 11M FILL(null) ALIGN TO CALENDAR
)
SELECT *
FROM sampled_and_interpolated
WHERE total IS NULL;

-- Get the latest register for each weather station, together with its coordinates. (This could be then plotted on a map)

SELECT * FROM chicago_water_sensors w
  JOIN chicago_sensor_locations s
    ON (w.BeachName = s.SensorName)
LATEST ON MeasurementTimestamp
    PARTITION BY BeachName;


-- Can you join the weather and water datasets so for each entry on the water dataset we get the closest entry for the closest weather station? hint: Try joining each table with the locations table, downcasting the geo resolution, then doing an ASOF join.

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
