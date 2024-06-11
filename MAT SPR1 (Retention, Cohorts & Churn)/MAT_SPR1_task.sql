WITH
  newSub AS (
  SELECT
    DATE_TRUNC(subscription_start, week) AS subscription_week,
    DATE_DIFF(DATE_TRUNC(subscription_end, week), DATE_TRUNC(subscription_start, week), WEEK) AS weeks_to_sub_end,
    CASE
      WHEN subscription_end IS NULL THEN 1
    ELSE
    0
  END
    AS subscribed,
    CASE
      WHEN subscription_end IS NOT NULL THEN 1
    ELSE
    0
  END
    AS canceled,
    COUNT(1) AS customers
  FROM
    `tc-da-1.turing_data_analytics.subscriptions`
  GROUP BY
    1,
    2,
    3,
    4 ),
  customerChurn AS(
  SELECT
    subscription_week,
    weeks_to_sub_end,
    subscribed,
    canceled,
    SUM(CASE
        WHEN canceled = 1 THEN customers
      ELSE
      0
    END
      ) OVER (PARTITION BY subscription_week ORDER BY weeks_to_sub_end) AS churn,
    SUM(customers) OVER (PARTITION BY subscription_week) AS customerTotalinCohord
  FROM
    newSub )
SELECT
  subscription_week,
  weeks_to_sub_end,
  --subscribed,
  --canceled,
  churn,
  customerTotalinCohord,
  CASE
    WHEN customerTotalinCohord = 0 THEN 0
  ELSE
  churn/customerTotalinCohord
END
  AS churnRate,
  CASE
    WHEN customerTotalinCohord = 0 THEN 0
  ELSE
  1-(churn/customerTotalinCohord)
END
  AS retentionRate
FROM
  customerChurn
WHERE
  weeks_to_sub_end >=0
ORDER BY
  1