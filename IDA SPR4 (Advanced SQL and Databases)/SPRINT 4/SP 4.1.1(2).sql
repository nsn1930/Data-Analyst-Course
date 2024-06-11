WITH
  SalesInfo AS (
  SELECT
    CustomerID,
    COUNT(SalesOrderID) AS NumberOfOrders,
    ROUND(SUM(TotalDue),2) AS Totaldue,
    MAX(OrderDate) AS LastOrderDate
  FROM
    `adwentureworks_db.salesorderheader`
  GROUP BY
    CustomerID ),
  MaxAddress AS(
  SELECT
    CustomerID,
    MAX(AddressID) AS MaxAddressID
  FROM
    `adwentureworks_db.customeraddress`
  GROUP BY
    CustomerID )
SELECT
  customer.CustomerID,
  contact.Firstname,
  contact.LastName,
  contact.Firstname|| " " ||contact.LastName AS full_name,
IF
  (contact.Title IS NULL, "Dear", contact.Title)||" "||contact.LastName AS addressing_title,
  contact.Emailaddress,
  contact.Phone,
  customer.AccountNumber,
  customer.CustomerType,
  address.city,
  address.AddressLine1,
  address.AddressLine2,
  stateprovince.Name AS State,
  countryregion.Name AS Country,
  SalesInfo.NumberOfOrders,
  SalesInfo.Totaldue,
  SalesInfo.LastOrderDate AS LastOrderDate
FROM
  `adwentureworks_db.customer` AS customer
JOIN
  `adwentureworks_db.individual` AS individual
ON
  customer.CustomerID = individual.CustomerID
JOIN
  `adwentureworks_db.contact` AS contact
ON
  individual.ContactID = contact.ContactID
JOIN
  MaxAddress
ON
  customer.CustomerID = maxaddress.CustomerID
JOIN
  `adwentureworks_db.address` AS address
ON
  maxaddress.MaxAddressID = address.AddressID
JOIN
  `adwentureworks_db.stateprovince` AS stateprovince
ON
  address.StateProvinceID = stateprovince.StateProvinceID
JOIN
  `adwentureworks_db.countryregion` AS countryregion
ON
  stateprovince.CountryRegionCode = countryregion.CountryRegionCode
JOIN
  SalesInfo
ON
  Customer.CustomerID = SalesInfo.CustomerID
ORDER BY
  SalesInfo.Totaldue DESC,
  LastOrderDate
  --LIMIT 200