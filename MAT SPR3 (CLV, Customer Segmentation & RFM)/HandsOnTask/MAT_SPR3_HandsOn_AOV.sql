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
    purchase_table )
SELECT
  total_money_spend/count_of_purchases AS AOV
FROM
  user_spend_table