WITH
  customerCount AS(
  SELECT
    COUNT(DISTINCT salesorderheader.CustomerID) AS CusCount
  FROM
    `adwentureworks_db.salesorderheader` AS salesorderheader
  WHERE
    salesorderheader.OrderDate BETWEEN '2001-07-01'AND '2004-06-30')

SELECT
  ROUND(SUM(salesorderheader.TotalDue)/MAX(customerCount.CusCount),2) AS AVGProfitPerCustomer
FROM
  `adwentureworks_db.salesorderheader` AS salesorderheader,
  customerCount
WHERE
  salesorderheader.OrderDate BETWEEN '2001-07-01'
  AND '2004-06-30'