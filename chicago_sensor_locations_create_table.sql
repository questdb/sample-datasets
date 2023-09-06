CREATE TABLE IF NOT EXISTS chicago_sensor_locations (
    SensorName SYMBOL,
    SensorType SYMBOL,
    Latitude DOUBLE,
    Longitude DOUBLE,
    G7c GEOHASH(7c)
    );
