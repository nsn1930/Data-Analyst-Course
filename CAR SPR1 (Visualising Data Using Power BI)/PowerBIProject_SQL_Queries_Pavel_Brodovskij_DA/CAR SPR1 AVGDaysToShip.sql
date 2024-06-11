SELECT
  ROUND(AVG(DATE_DIFF(CAST(salesorderheader.ShipDate AS DATE),CAST(salesorderheader.OrderDate AS DATE),day)),0) AS AVGDaysToShip
FROM
  `adwentureworks_db.salesorderheader` AS salesorderheader
WHERE
  salesorderheader.OrderDate BETWEEN '2001-07-01'
  AND '2004-06-30'