WITH
  ranked_events AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY rawEvents.user_pseudo_id, rawEvents.event_name ORDER BY rawEvents.event_timestamp) AS row_num
  FROM
    `turing_data_analytics.raw_events` AS rawEvents ),
  filtered_events AS(
  SELECT
    *
  FROM
    ranked_events AS rankedEv
  WHERE
    rankedEv.row_num = 1
  ORDER BY
    user_pseudo_id)
SELECT
  filtered_events.country,
  filtered_events.event_name,
  COUNT(filtered_events.event_name) AS countOfEvents
FROM
  filtered_events
WHERE
  filtered_events.country IN ('United States',
    'India',
    'Canada')
  AND filtered_events.event_name IN ('page_view',
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'add_payment_info',
    'purchase')
GROUP BY
  filtered_events.country,
  filtered_events.event_name
ORDER BY
  filtered_events.country,
  countOfEvents DESC