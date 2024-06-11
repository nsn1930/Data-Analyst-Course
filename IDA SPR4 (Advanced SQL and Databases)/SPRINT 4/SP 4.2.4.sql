WITH
  MainQuery AS (
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
    Region),
  SaleTaxes AS (
  SELECT
    DISTINCT stateprovince.CountryRegionCode AS ProvinceCountryRegionCode,
    ROUND(AVG(salestaxrate.TaxRate) OVER(PARTITION BY stateprovince.CountryRegionCode),1) AS MeanTaxRate
  FROM
    `adwentureworks_db.stateprovince` AS stateprovince
  JOIN
    `adwentureworks_db.salestaxrate` AS salestaxrate
  ON
    stateprovince.StateProvinceID = salestaxrate.StateProvinceID ),
  PercWTax AS(
  WITH
    MaxTax AS (
    SELECT
      DISTINCT StateProvinceID AS StateProvinceID,
      MAX(TaxRate) OVER (PARTITION BY StateProvinceID) AS MaxTaxRate
    FROM
      `adwentureworks_db.salestaxrate`)
  SELECT
    stateprovince.CountryRegionCode AS CountryCode,    
    --SUM(IF(MaxTaxRate IS NULL, 0, 1)) AS StatesWithTaxes, --counting how many states have known taxes
    --COUNT(MaxTax) AS TotalStates, --counting states per country
    ROUND(SUM(IF(MaxTaxRate IS NULL, 0, 1))/COUNT(MaxTax),2) AS PercProvincesWTax
  FROM
    `adwentureworks_db.stateprovince` AS stateprovince
  FULL OUTER JOIN
    MaxTax
  ON
    MaxTax.StateProvinceID = stateprovince.StateProvinceID
  GROUP BY
    stateprovince.CountryRegionCode)
SELECT
  MainQuery.OrderMonth,
  MainQuery.CountryRegionCode,
  MainQuery.Region,
  MainQuery.NumberOrders,
  MainQuery.NumberCustomer,
  MainQuery.NoSalesPerson,
  MainQuery.TotalWTax,
  RANK() OVER(PARTITION BY MainQuery.Region ORDER BY MainQuery.TotalWTax DESC) AS CountrySalesRank,
  SUM(MainQuery.TotalWTax) OVER (PARTITION BY MainQuery.Region ORDER BY MainQuery.OrderMonth) AS CumulativeSum,
  SaleTaxes.MeanTaxRate,
  PercWTax.PercProvincesWTax
FROM
  MainQuery
JOIN
  SaleTaxes
ON
  MainQuery.CountryRegionCode = SaleTaxes.ProvinceCountryRegionCode
JOIN
  PercWTax
ON
  SaleTaxes.ProvinceCountryRegionCode = PercWTax.CountryCode