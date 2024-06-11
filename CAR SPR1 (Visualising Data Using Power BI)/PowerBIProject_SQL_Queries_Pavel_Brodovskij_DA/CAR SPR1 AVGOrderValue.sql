SELECT
  ROUND(SUM(salesorderheader.TotalDue)/COUNT(salesorderheader.orderdate),2) AS AVGOrderValue
FROM
  `adwentureworks_db.salesorderheader` AS salesorderheader
WHERE
  salesorderheader.OrderDate BETWEEN '2001-07-01'
  AND '2004-06-30'