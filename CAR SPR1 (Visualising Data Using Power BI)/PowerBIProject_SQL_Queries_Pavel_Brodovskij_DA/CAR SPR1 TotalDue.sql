SELECT
  ROUND(SUM(salesorderheader.TotalDue),2) AS TotalDue
FROM
  `adwentureworks_db.salesorderheader` AS salesorderheader
WHERE
  salesorderheader.OrderDate BETWEEN '2001-07-01'
  AND '2004-06-30'