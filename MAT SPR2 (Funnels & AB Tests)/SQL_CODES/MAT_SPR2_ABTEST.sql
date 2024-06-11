WITH
  rawEvents AS(
  SELECT
    campaign AS Campaign,
    count (DISTINCT user_pseudo_id) AS realClicks
  FROM
    `tc-da-1.turing_data_analytics.raw_events`
  WHERE
    event_name = 'page_view'
    AND campaign IN ('NewYear_V1',
      'NewYear_V2',
      'BlackFriday_V1',
      'BlackFriday_V2')
  GROUP BY
    1 )
SELECT
  adsenseMonthly.campaign AS CampaignName,
  adsenseMonthly.Impressions AS Impressions,
  adsenseMonthly.Clicks AS estimatedClicks,
  rawEvents.realClicks
FROM
  `tc-da-1.turing_data_analytics.adsense_monthly` AS adsenseMonthly
JOIN
  rawEvents
ON
  adsenseMonthly.Campaign = rawEvents.Campaign
WHERE
  adsenseMonthly.campaign IN ('NewYear_V1',
    'NewYear_V2',
    'BlackFriday_V1',
    'BlackFriday_V2')
  AND adsenseMonthly.Month<>202111
ORDER BY
  1