-- Statistics for each month

SELECT
  ts,
  SUM(visits) AS total_visits,
  SUM(unique_visitors) AS total_unique_visitors,
  SUM(sales) AS total_sales,
  SUM(number_of_products) AS total_number_of_products
FROM ecommerce_stats
SAMPLE BY 1M ALIGN TO CALENDAR;

-- Statistics for each month, per category

SELECT
  ts,
  category,
  SUM(visits) AS total_visits,
  SUM(unique_visitors) AS total_unique_visitors,
  SUM(sales) AS total_sales,
  SUM(number_of_products) AS total_number_of_products
FROM ecommerce_stats
SAMPLE BY 1M ALIGN TO CALENDAR;

-- Statistics for each month, per category, and per country

SELECT
  ts,
  country,
  category,
  SUM(visits) AS total_visits,
  SUM(unique_visitors) AS total_unique_visitors,
  SUM(sales) AS total_sales,
  SUM(number_of_products) AS total_number_of_products
FROM ecommerce_stats
SAMPLE BY 1M ALIGN TO CALENDAR;


-- Plot the difference between UK and DE sales performance (using QuestDB Console's built-in Chart functionality or time-series dashboards such as Grafana)

WITH sales_de AS (
    (
    SELECT
        ts,
        SUM(sales) AS total_sales
    FROM ecommerce_stats
    WHERE country = 'DE'
    ) timestamp(ts)
)
SELECT
    uk.ts,
    SUM(uk.sales) AS total_uk_sales,
    SUM(de.total_sales) AS total_de_sales
FROM ecommerce_stats uk
    ASOF JOIN sales_de AS de
WHERE country = 'UK'
  ;

-- Number of products sold per quarter

SELECT
  ts,
  SUM(number_of_products) AS total_number_of_products
FROM ecommerce_stats
SAMPLE BY 3M ALIGN TO CALENDAR;

-- Number of products sold per quarter and country, ordered by quarter and products

SELECT
  ts,
  country,
  SUM(number_of_products) AS total_number_of_products
FROM ecommerce_stats
SAMPLE BY 3M ALIGN TO CALENDAR
ORDER BY ts, total_number_of_products DESC;
