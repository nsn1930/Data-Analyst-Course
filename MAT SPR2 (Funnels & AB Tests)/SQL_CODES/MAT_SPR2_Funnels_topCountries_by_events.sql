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
  COUNT(filtered_events.event_name) AS countOfEvents
FROM
  filtered_events
GROUP BY
  filtered_events.country
ORDER BY
  countOfEvents DESC
LIMIT
  3