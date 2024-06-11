WITH cohordTab AS(
  SELECT 
  DATE_TRUNC(subscription_start, WEEK) AS week_start,
  COUNT(DISTINCT user_pseudo_id) AS newAccountStart,
  COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 1 WEEK) OR subscription_end IS NULL THEN user_pseudo_id END) AS week1,
  COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 2 WEEK) OR subscription_end IS NULL THEN user_pseudo_id END) AS week2,
  COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 3 WEEK) OR subscription_end IS NULL THEN user_pseudo_id END) AS week3,
  COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 4 WEEK) OR subscription_end IS NULL THEN user_pseudo_id END) AS week4,
  COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 5 WEEK) OR subscription_end IS NULL THEN user_pseudo_id END) AS week5,
  COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(DATE_TRUNC(subscription_start, WEEK), INTERVAL 6 WEEK) OR subscription_end IS NULL THEN user_pseudo_id END) AS week6
FROM 
  `tc-da-1.turing_data_analytics.subscriptions`
GROUP BY 
  1)

SELECT
 cohordTab.week_start,
 cohordTab.newAccountStart,
 IF (cohordTab.newAccountStart-week1!=0,week1/cohordTab.newAccountStart,NULL) AS week1retRate,
 IF (week1-week2!=0,week2/cohordTab.newAccountStart,NULL) AS week2retRate,
 IF (week2-week3!=0,week3/cohordTab.newAccountStart,NULL) AS week3retRate,
 IF (week3-week4!=0,week4/cohordTab.newAccountStart,NULL) AS week4retRate,
 IF (week4-week5!=0,week5/cohordTab.newAccountStart,NULL) AS week5retRate,
 IF (week5-week6!=0,week6/cohordTab.newAccountStart,NULL) AS week6retRate,
FROM cohordTab