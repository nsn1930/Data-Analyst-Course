SELECT
  CAST(MAX(salesorderheader.OrderDate) AS date) AS OrderMonth,
  salesterritory.CountryRegionCode AS CountryRegionCode,
  salesterritory.Name AS Region,
  COUNT(DISTINCT salesorderheader.SalesOrderID) AS NumberOrders,
  COUNT(DISTINCT salesorderheader.CustomerID) AS NumberCustomer,
  COUNT(DISTINCT salesorderheader.SalesPersonID) AS NoSalesPerson,
  CAST(SUM(salesorderheader.TotalDue) AS INT) AS TotalWTax
FROM
  `adwentureworks_db.salesorderheader` AS salesorderheader
JOIN
  `adwentureworks_db.salesterritory` AS salesterritory
ON
  salesorderheader.TerritoryID = salesterritory.TerritoryID
GROUP BY
  DATE_TRUNC(salesorderheader.OrderDate, month),
  CountryRegionCode,
  Region