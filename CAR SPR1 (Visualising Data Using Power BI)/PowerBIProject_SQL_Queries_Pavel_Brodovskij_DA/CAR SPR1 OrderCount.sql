SELECT
  COUNT(salesorderheader.orderdate) AS OrderCount
FROM
  `adwentureworks_db.salesorderheader` AS salesorderheader
WHERE
  salesorderheader.OrderDate BETWEEN '2001-07-01'
  AND '2004-06-30'