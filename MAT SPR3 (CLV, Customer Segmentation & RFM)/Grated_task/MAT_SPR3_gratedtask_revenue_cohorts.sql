WITH
  raw_events AS (
  SELECT
    DATE(FORMAT_TIMESTAMP('%Y-%m-%d', TIMESTAMP_MICROS(event_timestamp))) AS converted_datespamp,
    *
  FROM
    `tc-da-1.turing_data_analytics.raw_events`),
  user_first_purchase AS(
  SELECT
    DISTINCT user_pseudo_id,
    DATE_TRUNC(raw_events.converted_datespamp, WEEK) AS week_start
  FROM
    raw_events
  WHERE
    event_name = 'first_visit'),
  cohord_sales AS(
  SELECT
    user_first_purchase.week_start AS week_start,
    raw_event.user_pseudo_id,
    raw_event.converted_datespamp,
    DATE_DIFF(DATE_TRUNC(raw_event.converted_datespamp, WEEK), user_first_purchase.week_start, WEEK) AS cohort_age,
    raw_event.purchase_revenue_in_usd AS purchase_revenue_in_usd
  FROM
    raw_events AS raw_event
  JOIN
    user_first_purchase AS user_first_purchase
  ON
    raw_event.user_pseudo_id = user_first_purchase.user_pseudo_id )
SELECT
  week_start,
  cohort_age,
  SUM(purchase_revenue_in_usd) AS total_revenue
FROM
  cohord_sales
GROUP BY
  week_start,
  cohort_age
ORDER BY
  week_start,
  cohort_age