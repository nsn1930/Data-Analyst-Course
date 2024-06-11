WITH
  date_span AS (
  SELECT
    MIN(FORMAT_TIMESTAMP('%Y-%m-%d', TIMESTAMP_MICROS(event_timestamp))) AS first_purchase_date,
    MAX(FORMAT_TIMESTAMP('%Y-%m-%d', TIMESTAMP_MICROS(event_timestamp))) AS last_purchase_date
  FROM
    `turing_data_analytics.raw_events`
  WHERE
    event_name = 'purchase')
SELECT
  TIMESTAMP_DIFF(TIMESTAMP(date_span.last_purchase_date),TIMESTAMP(date_span.first_purchase_date), DAY) AS days_of_data
FROM
  date_span