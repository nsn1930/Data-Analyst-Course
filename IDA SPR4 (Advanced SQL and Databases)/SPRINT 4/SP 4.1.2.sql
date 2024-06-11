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
  `adwentureworks_db.customeraddress` AS customeraddress
ON
  customer.CustomerID = customeraddress.CustomerID
JOIN
  `adwentureworks_db.address` AS address
ON
  customeraddress.AddressID = address.AddressID
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
WHERE 
  DATE_DIFF((
    SELECT
      MAX(OrderDate) AS lod
    FROM
      `adwentureworks_db.salesorderheader` ), SalesInfo.LastOrderDate, day)>365 --filter to find orders made ovr 365 days ago
ORDER BY
  SalesInfo.Totaldue DESC,
  LastOrderDate
LIMIT
  200