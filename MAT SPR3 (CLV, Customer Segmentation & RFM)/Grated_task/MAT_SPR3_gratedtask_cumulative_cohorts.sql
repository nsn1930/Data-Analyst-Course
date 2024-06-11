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
  WHERE event_name = 'first_visit'),
  cohord_sales AS(
  SELECT
    user_first_purchase.week_start AS week_start,
    raw_event.user_pseudo_id AS user_pseudo_id,
    raw_event.converted_datespamp AS converted_datespamp,
    DATE_TRUNC(raw_event.converted_datespamp, WEEK) AS purchase_week,
    DATE_DIFF(DATE_TRUNC(raw_event.converted_datespamp, WEEK), user_first_purchase.week_start, WEEK) AS cohort_age,
    raw_event.purchase_revenue_in_usd AS purchase_revenue_in_usd
  FROM
    raw_events AS raw_event
  JOIN
    user_first_purchase AS user_first_purchase
  ON
    raw_event.user_pseudo_id = user_first_purchase.user_pseudo_id ),
  cumulative_revenue AS(
  SELECT
    cohort_sales.week_start AS week_start,
    cohort_sales.cohort_age AS cohort_age,
    cohort_sales.purchase_week AS purchase_week,
    SUM(cohort_sales.purchase_revenue_in_usd) AS weekly_revenue,
    SUM(SUM(cohort_sales.purchase_revenue_in_usd)) OVER (PARTITION BY cohort_sales.week_start ORDER BY cohort_sales.purchase_week) AS cumulative_revenue
  FROM
    cohord_sales AS cohort_sales
  GROUP BY
    cohort_sales.week_start,
    cohort_sales.cohort_age,
    cohort_sales.purchase_week )
SELECT
  cumul_revenue.week_start,
  cumul_revenue.cohort_age,
  cumul_revenue.purchase_week,
  cumul_revenue.weekly_revenue,
  cumul_revenue.cumulative_revenue
FROM
  cumulative_revenue AS cumul_revenue
ORDER BY
  cumul_revenue.week_start,
  cumul_revenue.cohort_age