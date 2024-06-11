WITH
  AgentID AS (
  SELECT
    salesorderheader.SalesPersonID AS SalesPersonID,
    SUM(salesorderheader.TotalDue) AS TotalDue,
    COUNT(salesorderheader.OrderDate) AS CountOfSales
  FROM
    `adwentureworks_db.salesorderheader` AS salesorderheader
  GROUP BY
    SalesPersonID)

SELECT
  AgentID.SalesPersonID AS SalesPersonID,
  ROUND(AgentID.TotalDue,2) AS TotalDue,
  AgentID.CountOfSales AS CountOfSales,
  ROUND(SUM(salesorderheader.TotalDue)/COUNT(salesorderheader.OrderDate),0) AS AVGDuePerSale
FROM
  `adwentureworks_db.salesorderheader` AS salesorderheader
JOIN
  AgentID
ON
  AgentID.SalesPersonID = salesorderheader.SalesPersonID
GROUP BY
  AgentID.SalesPersonID,
  AgentID.TotalDue,
  AgentID.CountOfSales
ORDER BY
  TotalDue DESC