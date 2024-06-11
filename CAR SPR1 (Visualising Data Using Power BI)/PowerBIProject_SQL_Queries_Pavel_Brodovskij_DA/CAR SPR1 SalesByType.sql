WITH
  OnlineSale AS(
  SELECT
    LAST_DAY(CAST(salesorderheader.OrderDate AS date)) AS OrderMonth,
    SUM(salesorderheader.TotalDue) AS TotalDue
  FROM
    `adwentureworks_db.salesorderheader` AS salesorderheader
  WHERE
    salesorderheader.OrderDate BETWEEN '2001-07-01'
    AND '2004-06-30'
    AND salesorderheader.SalesPersonID > 0
  GROUP BY
    OrderMonth ),

  OfflineSale AS(
  SELECT
    LAST_DAY(CAST(salesorderheader.OrderDate AS date)) AS OrderMonth,
    SUM(salesorderheader.TotalDue) AS TotalDue
  FROM
    `adwentureworks_db.salesorderheader` AS salesorderheader
  WHERE
    salesorderheader.OrderDate BETWEEN '2001-07-01'
    AND '2004-06-30'
    AND salesorderheader.SalesPersonID IS NULL
  GROUP BY
    OrderMonth )
    
SELECT
  OnlineSale.OrderMonth,
  OnlineSale.TotalDue AS OnlineSales,
  OfflineSale.TotalDue AS OfflineSales
FROM
  OnlineSale
JOIN
  OfflineSale
ON
  OnlineSale.OrderMonth = OfflineSale.OrderMonth
ORDER BY
  OnlineSale.OrderMonth ASC