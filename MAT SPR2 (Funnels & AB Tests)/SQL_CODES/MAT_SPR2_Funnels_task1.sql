WITH
  ranked_events AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY rawEvents.user_pseudo_id, rawEvents.event_name ORDER BY rawEvents.event_timestamp) AS row_num
  FROM
    `turing_data_analytics.raw_events` AS rawEvents )
SELECT
  *
FROM
  ranked_events AS rankedEv
WHERE
  rankedEv.row_num = 1
ORDER BY
  user_pseudo_id