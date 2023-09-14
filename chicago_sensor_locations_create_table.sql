CREATE TABLE IF NOT EXISTS chicago_sensor_locations (
    UpdatedAt TIMESTAMP,
    SensorName SYMBOL,
    SensorType SYMBOL,
    Latitude DOUBLE,
    Longitude DOUBLE,
    G7c GEOHASH(7c)
) timestamp(UpdatedAt) PARTITION BY YEAR WAL
DEDUP UPSERT KEYS(UpdatedAt, SensorName);
