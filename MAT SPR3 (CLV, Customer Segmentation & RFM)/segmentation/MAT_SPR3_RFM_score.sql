WITH
  rfm_main_table AS (
  SELECT
    *,
    DATE(InvoiceDate) AS simplyfied_date
  FROM
    `tc-da-1.turing_data_analytics.rfm`
  WHERE
    InvoiceDate >= '2010-12-01'
    AND InvoiceDate <'2011-12-01' ),
  --Compute FOR F & M rf_table AS (
SELECT
  CustomerID,
  Country,
  MAX(simplyfied_date) AS last_purchase_date,
  COUNT(DISTINCT InvoiceNo) AS frequency,
  SUM(UnitPrice*quantity) AS monetary
FROM
  rfm_main_table
GROUP BY
  CustomerID,
  Country ),
  --Compute FOR R r_table AS (
SELECT
  *,
  DATE_DIFF(reference_date, last_purchase_date, DAY) AS recency
FROM (
  SELECT
    *,
    DATE('2011-12-01') AS reference_date
  FROM
    rf_table ) ),
  --Determine quintiles FOR RFM quintiles_table AS (
SELECT
  rTable.*,
  monetary_quintiles.percentiles[
OFFSET
  (25)] AS m25,
  monetary_quintiles.percentiles[
OFFSET
  (50)] AS m50,
  monetary_quintiles.percentiles[
OFFSET
  (75)] AS m75,
  monetary_quintiles.percentiles[
OFFSET
  (100)] AS m100,
  frequency_quintiles.percentiles[
OFFSET
  (25)] AS f25,
  frequency_quintiles.percentiles[
OFFSET
  (50)] AS f50,
  frequency_quintiles.percentiles[
OFFSET
  (75)] AS f75,
  frequency_quintiles.percentiles[
OFFSET
  (100)] AS f100,
  recency_quintiles.percentiles[
OFFSET
  (25)] AS r25,
  recency_quintiles.percentiles[
OFFSET
  (50)] AS r50,
  recency_quintiles.percentiles[
OFFSET
  (75)] AS r75,
  recency_quintiles.percentiles[
OFFSET
  (100)] AS r100
FROM
  r_table AS rTable,
  (
  SELECT
    APPROX_QUANTILES(monetary, 100) percentiles
  FROM
    r_table) AS monetary_quintiles,
  (
  SELECT
    APPROX_QUANTILES(frequency, 100) percentiles
  FROM
    r_table) AS frequency_quintiles,
  (
  SELECT
    APPROX_QUANTILES(recency, 100) percentiles
  FROM
    r_table) AS recency_quintiles ),
  --Assign scores FOR R
  AND combined FM rfm_score AS (
  SELECT
    *,
    CAST(ROUND((f_score + m_score) / 2, 0) AS INT64) AS fm_score
  FROM (
    SELECT
      *,
      CASE
        WHEN monetary <= m25 THEN 1
        WHEN monetary <= m50
      AND monetary > m25 THEN 2
        WHEN monetary <= m75 AND monetary > m50 THEN 3
        WHEN monetary <= m100
      AND monetary > m75 THEN 4
    END
      AS m_score,
      CASE
        WHEN frequency <= f25 THEN 1
        WHEN frequency <= f50
      AND frequency > f25 THEN 2
        WHEN frequency <= f75 AND frequency > f50 THEN 3
        WHEN frequency <= f100
      AND frequency > f75 THEN 4
    END
      AS f_score,
      --Recency scoring IS reversed
      CASE
        WHEN recency <= r25 THEN 4
        WHEN recency <= r50
      AND recency > r25 THEN 3
        WHEN recency <= r75 AND recency > r50 THEN 2
        WHEN recency <= r100
      AND recency > r75 THEN 1
    END
      AS r_score,
    FROM
      quintiles_table ) ),
  --Define RFM segments rfm_segments AS (
SELECT
  CustomerID,
  Country,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  fm_score,
  CASE
    WHEN (r_score = 5 AND fm_score = 5) OR (r_score = 5 AND fm_score = 4) OR (r_score = 4 AND fm_score = 5) THEN 'Champions'
    WHEN (r_score = 5
    AND fm_score =3)
  OR (r_score = 4
    AND fm_score = 4)
  OR (r_score = 3
    AND fm_score = 5)
  OR (r_score = 3
    AND fm_score = 4) THEN 'Loyal Customers'
    WHEN (r_score = 5 AND fm_score = 2) OR (r_score = 4 AND fm_score = 2) OR (r_score = 3 AND fm_score = 3) OR (r_score = 4 AND fm_score = 3) THEN 'Potential Loyalists'
    WHEN r_score = 5
  AND fm_score = 1 THEN 'Recent Customers'
    WHEN (r_score = 4 AND fm_score = 1) OR (r_score = 3 AND fm_score = 1) THEN 'Promising'
    WHEN (r_score = 3
    AND fm_score = 2)
  OR (r_score = 2
    AND fm_score = 3)
  OR (r_score = 2
    AND fm_score = 2) THEN 'Customers Needing Attention'
    WHEN r_score = 2 AND fm_score = 1 THEN 'About to Sleep'
    WHEN (r_score = 2
    AND fm_score = 5)
  OR (r_score = 2
    AND fm_score = 4)
  OR (r_score = 1
    AND fm_score = 3) THEN 'At Risk'
    WHEN (r_score = 1 AND fm_score = 5) OR (r_score = 1 AND fm_score = 4) THEN 'Cant Lose Them'
    WHEN r_score = 1
  AND fm_score = 2 THEN 'Hibernating'
    WHEN r_score = 1 AND fm_score = 1 THEN 'Lost'
END
  AS rfm_segment
FROM
  rfm_score )
SELECT
  rfm_scores,
  COUNT(rfm_scores) AS n
FROM (
  SELECT
    r_score||f_score||m_score AS rfm_scores
  FROM
    rfm_segments)
GROUP BY
  rfm_scores