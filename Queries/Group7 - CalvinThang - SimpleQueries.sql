/*
Calvin Thang
Group 7 - Project 1 - Simple Queries

Databases used for this SQL file:
	1. Northwinds2020TSQLV6
	2. AdventureWorksDW2019
	3. AdventureWorks2019
	5. ContosoRetailDW
*/

-- Proposition 1: Find names of Employee whose territory is in France and StateProvinceName starts with G in AdventureWorksDW2019
USE AdventureWorksDW2019;
SELECT DISTINCT
       e.EmployeeKey,
       e.FirstName,
       e.LastName,
       g.StateProvinceName,
       g.EnglishCountryRegionName AS Country
FROM dbo.DimEmployee AS e
    INNER JOIN dbo.DimGeography AS g
        ON g.SalesTerritoryKey = e.SalesTerritoryKey
WHERE g.EnglishCountryRegionName = 'France'
      AND g.StateProvinceName LIKE 'G%';


-- Proposition 2: In AdventureWorksDW2019, What is the name and subcategory of products that are over $500?
USE AdventureWorksDW2019;
SELECT DISTINCT
       p.ProductKey,
       p.EnglishProductName AS ProductName,
       sc.EnglishProductSubcategoryName AS SubcategoryName,
       p.ListPrice
FROM dbo.DimProduct AS p
    INNER JOIN dbo.DimProductSubcategory AS sc
        ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
WHERE p.ListPrice > 500
ORDER BY p.ListPrice ASC;

-- Proposition 3: In NorthWinds2020TSQLV6, who are the customers that didn't place any orders?
USE Northwinds2020TSQLV6;
SELECT C.CustomerId,
       C.CustomerContactName,
       O.OrderId
FROM Sales.[Customer] AS C
    LEFT OUTER JOIN Sales.[Order] AS O
        ON C.CustomerId = O.CustomerId
WHERE O.OrderId IS NULL;

-- Proposition 4:  In Northwinds2020TSQLV6, Find all orders shipped from Shipper ZHISN and to the country Germany
USE Northwinds2020TSQLV6;
SELECT O.OrderId,
       O.CustomerId,
       S.ShipperCompanyName,
       O.OrderDate,
       O.ShipToCountry
FROM Sales.[Order] AS O
    FULL OUTER JOIN Sales.[Shipper] AS S
        ON O.ShipperId = S.ShipperId
WHERE S.ShipperCompanyName = 'Shipper ZHISN'
      AND O.ShipToCountry = 'Germany'
FOR JSON PATH, ROOT('Shipper'), INCLUDE_NULL_VALUES;

-- Proposition 5: In ContosoRetailDW, find the Employee and their department and who they answer to in the company hierachy
USE ContosoRetailDW;

SELECT E1.EmployeeKey AS E1_EmployeeKey,
       CONCAT(E1.FirstName, ' ', E1.LastName) AS E1_EmployeeName,
       E1.DepartmentName AS E1_DepartmentName,
       E1.ParentEmployeeKey AS E1_ParentEmployeeKey,
       E2.EmployeeKey AS E2_EmployeeKey,
       CONCAT(E2.FirstName, ' ', E2.LastName) AS E2_ManagerName,
       E2.DepartmentName AS E2_DepartmentName
FROM dbo.DimEmployee AS E1
    INNER JOIN dbo.DimEmployee AS E2
        ON E1.ParentEmployeeKey = E2.EmployeeKey
ORDER BY E1.EmployeeKey ASC
FOR JSON PATH, ROOT('Employee'), INCLUDE_NULL_VALUES;