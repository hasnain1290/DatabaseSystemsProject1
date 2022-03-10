/*
Calvin Thang
Group 7 - Project 1 - Medium Queries

Databases used for this SQL file:
	1. Northwinds2020TSQLV6
	2. AdventureWorksDW2019
	3. AdventureWorks2019
	5. ContosoRetailDW
*/

-- Proposition 6: In AdventureWorks2019, What are the top 10 best selling products?
USE AdventureWorks2019;

SELECT TOP (10)
       p.ProductID AS ProductID,
       p.Name AS ProductName,
       COUNT(sod.SalesOrderDetailID) AS NumberOfProductsSold
FROM Sales.SalesOrderDetail AS sod
    INNER JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
GROUP BY p.Name,
         p.ProductID
ORDER BY COUNT(sod.SalesOrderDetailID) DESC,
         p.Name
FOR JSON PATH, ROOT('Sales'), INCLUDE_NULL_VALUES;

-- Proposition 7: In AdventureWorks2019, what are the top 5 highest gross products?
USE AdventureWorks2019;

SELECT TOP (5)
       p.ProductID,
       p.Name,
       p.ListPrice,
       SUM(od.OrderQty) AS TotalOrders,
       SUM(od.UnitPrice * od.OrderQty) AS TotalGrossAmount
FROM Production.Product AS p
    INNER JOIN Sales.SalesOrderDetail AS od
        ON p.ProductID = od.ProductID
WHERE p.ListPrice > 0
GROUP BY p.Name,
         p.ProductID,
         p.ListPrice
ORDER BY TotalGrossAmount DESC
FOR JSON PATH, ROOT('Gross'), INCLUDE_NULL_VALUES;

-- Proposition 8: In AdventureWorksDW2019, find the Product, its' subcategory, and its category 
--	sorted by its' profit which is ListPrice - StandardCost
USE AdventureWorksDW2019;
SELECT p.ProductKey,
       p.EnglishProductName,
       sc.EnglishProductSubcategoryName,
       pc.EnglishProductCategoryName,
       SUM(p.ListPrice - p.StandardCost) AS Profit
FROM dbo.DimProduct AS p
    INNER JOIN dbo.DimProductSubcategory AS sc
        ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory AS pc
        ON sc.ProductCategoryKey = pc.ProductCategoryKey
WHERE p.ListPrice
BETWEEN 150 AND 350
GROUP BY p.ProductKey,
         p.EnglishProductName,
         p.EnglishProductName,
         sc.EnglishProductSubcategoryName,
         pc.EnglishProductCategoryName
ORDER BY Profit ASC
FOR JSON PATH, ROOT('Products'), INCLUDE_NULL_VALUES;


-- Proposition 9: In NorthWinds2020TSQLV6, find the amount of products sold in each category that is shipped to Argentina
USE Northwinds2020TSQLV6;
SELECT c.CategoryName,
       COUNT(od.OrderId) AS ProductsSold,
       o.ShipToCountry
FROM Production.Category AS c
    INNER JOIN Production.Product AS p
        ON p.CategoryId = c.CategoryId
    INNER JOIN Sales.OrderDetail AS od
        ON p.ProductId = od.ProductId
    INNER JOIN Sales.[Order] AS o
        ON o.OrderId = od.OrderId
WHERE o.ShipToCountry = 'Argentina'
GROUP BY c.CategoryName,
         o.ShipToCountry
FOR JSON PATH, ROOT('Products'), INCLUDE_NULL_VALUES;

-- Proposition 10: In AdventureWorksDW2019, How many unique resellers are in each Country?
USE AdventureWorksDW2019;
SELECT g.EnglishCountryRegionName AS Country,
       COUNT(DISTINCT r.ResellerKey) AS NumberOfResellers
FROM dbo.DimReseller AS r
    INNER JOIN dbo.DimGeography AS g
        ON r.GeographyKey = g.GeographyKey
GROUP BY g.EnglishCountryRegionName
ORDER BY COUNT(r.ResellerKey) ASC;

-- Proposition 11: In AdventureWorksDW2019, How many products are in each category?
USE AdventureWorksDW2019;

SELECT c.EnglishProductCategoryName AS CategoryName,
       COUNT(DISTINCT p.ProductKey) AS NumberOfProductsInCategory
FROM dbo.DimProduct AS p
    INNER JOIN dbo.DimProductSubcategory AS sc
        ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory AS c
        ON sc.ProductCategoryKey = c.ProductCategoryKey
GROUP BY c.EnglishProductCategoryName
FOR JSON PATH, ROOT('Category'), INCLUDE_NULL_VALUES;

-- Proposition 12: In AdventureWorks2019, what is the aggregate sales, cost, and gross profit for each sub-Category of products?
-- Proposition 12: In AdventureWorks2019, what is the aggregate sales, cost, and gross profit for each sub-Category of products?
USE AdventureWorks2019;

SELECT sc.Name,
       SUM(od.UnitPrice * od.OrderQty) AS TotalSales,
       SUM(p.StandardCost) AS TotalCost,
       SUM(od.UnitPrice * od.OrderQty) - SUM(p.StandardCost) AS GrossProfit
FROM Production.Product AS p
    INNER JOIN Sales.SalesOrderDetail AS od
        ON p.ProductID = od.ProductID
    INNER JOIN Production.ProductSubcategory AS sc
        ON p.ProductSubcategoryID = sc.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS c
        ON sc.ProductCategoryID = c.ProductCategoryID
GROUP BY sc.Name
ORDER BY GrossProfit DESC
FOR JSON PATH, ROOT('Category'), INCLUDE_NULL_VALUES;

-- Proposition 13: In AdventureWorks2019, what is the average cost for each Mountain Bike
USE AdventureWorks2019;

SELECT p.ProductID AS ProductId,
       sc.Name AS SubcategoryName,
       AVG(p.StandardCost) AS AverageCost
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS sc
        ON p.ProductSubcategoryID = sc.ProductSubcategoryID
WHERE sc.Name = 'Mountain Bikes'
GROUP BY sc.Name,
         p.ProductID
ORDER BY AVG(p.StandardCost) ASC
FOR JSON PATH, ROOT('AvgCost'), INCLUDE_NULL_VALUES;



-- Proposition 14: In AdventureWorksDW2019, what are the organization names that has total amount from the FactFinance table?
USE AdventureWorksDW2019;

SELECT TOP (3)
       o.OrganizationName,
       d.FiscalYear,
       SUM(f.Amount) AS TotalAmount
FROM dbo.DimOrganization AS o
    RIGHT OUTER JOIN dbo.FactFinance AS f
        ON o.OrganizationKey = f.OrganizationKey
    INNER JOIN dbo.DimDate AS d
        ON d.DateKey = f.DateKey
GROUP BY o.OrganizationName,
         d.FiscalYear
ORDER BY TotalAmount DESC
FOR JSON PATH, ROOT('TotalAmount'), INCLUDE_NULL_VALUES;
