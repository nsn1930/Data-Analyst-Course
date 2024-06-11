WITH
  purchase_table AS (
  SELECT
    user_pseudo_id AS user_id,
    event_value_in_usd AS money_spend
  FROM
    `turing_data_analytics.raw_events`
  WHERE
    event_name = 'purchase'),
  user_spend_table AS (
  SELECT
    COUNT(user_id) AS count_of_purchases,
    SUM(money_spend) AS total_money_spend
  FROM
    purchase_table ),
  date_span AS (
  SELECT
    MIN(FORMAT_TIMESTAMP('%Y-%m-%d', TIMESTAMP_MICROS(event_timestamp))) AS first_purchase_date,
    MAX(FORMAT_TIMESTAMP('%Y-%m-%d', TIMESTAMP_MICROS(event_timestamp))) AS last_purchase_date
  FROM
    `turing_data_analytics.raw_events`
  WHERE
    event_name = 'purchase'),
  days_of_data AS(
  SELECT
    TIMESTAMP_DIFF(TIMESTAMP(date_span.last_purchase_date),TIMESTAMP(date_span.first_purchase_date), DAY) AS days_of_data
  FROM
    date_span)
SELECT
  user_spend_table.count_of_purchases/days_of_data.days_of_data AS PF_purchase_frequency
FROM
  user_spend_table
CROSS JOIN
  days_of_data