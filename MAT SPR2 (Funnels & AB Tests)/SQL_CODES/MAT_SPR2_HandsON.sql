SELECT
  Campaign,
  Impressions,
  Clicks
FROM
  `turing_data_analytics.adsense_monthly`
WHERE
  campaign IN ('NewYear_V1',
    'NewYear_V2',
    'BlackFriday_V1',
    'BlackFriday_V2')
  AND Month<>202111
ORDER BY
  1