CREATE TABLE IF NOT EXISTS chicago_water_sensors (
    MeasurementTimestamp TIMESTAMP,
    BeachName SYMBOL,
    WaterTemperature DOUBLE,
    Turbidity DOUBLE,
    TransducerDepth DOUBLE,
    WaveHeight DOUBLE,
    WavePeriod INT,
    BatteryLife DOUBLE,
    MeasurementTimestampLabel VARCHAR,
    MeasurementID VARCHAR
) timestamp(MeasurementTimestamp) PARTITION BY MONTH WAL
DEDUP UPSERT KEYS(MeasurementTimestamp, BeachName);
