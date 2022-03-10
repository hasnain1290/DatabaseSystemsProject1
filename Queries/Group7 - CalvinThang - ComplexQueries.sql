/*
Calvin Thang
Group 7 - Project 1 - Complex Queries

Databases used for this SQL file:
	1. Northwinds2020TSQLV6
	2. AdventureWorksDW2019
	3. AdventureWorks2019
*/

-- Proposition 15: Create an alert message if product inventory reaches reorder point
DROP FUNCTION

IF EXISTS dbo.udf_AlertReorderForProduct;GO
	CREATE FUNCTION dbo.udf_AlertReorderForProduct (
		@ProductKey INT
		,@UnitsBalance INT
		,@ReorderPoint SMALLINT
		)
	RETURNS NVARCHAR(50)
	AS
	BEGIN
		DECLARE @Alert NVARCHAR(50);

		IF (@UnitsBalance <= @ReorderPoint)
			SET @Alert = N'ALERT! Reorder immediately';
		ELSE
			SET @Alert = N'No need to reorder at this moment';

		RETURN @Alert;
	END;
GO

USE AdventureWorksDW2019;

SELECT DISTINCT p.ProductKey
	,p.EnglishProductName
	,sc.EnglishProductSubcategoryName
	,i.UnitsBalance
	,p.ReorderPoint
	,i.MovementDate
	,SUBSTRING((CAST(i.DateKey AS NVARCHAR(50))), 0, 5) AS YearOfDate
	,dbo.udf_AlertReorderForProduct(p.ProductKey, i.UnitsBalance, p.ReorderPoint)
FROM dbo.DimProduct AS p
INNER JOIN dbo.FactProductInventory AS i ON i.ProductKey = p.ProductKey
LEFT OUTER JOIN dbo.DimProductSubcategory AS sc ON sc.ProductSubcategoryKey = p.ProductSubcategoryKey
WHERE i.MovementDate LIKE '2014-01-18'
	AND i.UnitsBalance >= 0
ORDER BY p.ProductKey DESC
	,p.EnglishProductName
FOR JSON PATH
	,ROOT('Category')
	,INCLUDE_NULL_VALUES;

-- Proposition 16: Write a message in NorthWinds2020TSQLV6 indicating that a product has been Discontinued
DROP FUNCTION IF EXISTS dbo.udf_ReturnDiscontinuedStatus;
GO
CREATE FUNCTION dbo.udf_ReturnDiscontinuedStatus
(
    @Discontinued BIT
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Output NVARCHAR(50);
    IF (@Discontinued = 1)
        SET @Output = N'TRUE';
    ELSE
        SET @Output = N'FALSE';

    RETURN @Output;
END;
GO
USE Northwinds2020TSQLV6;
SELECT p.ProductName,
       s.SupplierCompanyName,
       c.CategoryName,
       dbo.udf_ReturnDiscontinuedStatus(p.Discontinued) AS Discontinued
FROM Production.Product AS p
    INNER JOIN Production.Supplier AS s
        ON s.SupplierId = p.SupplierId
    INNER JOIN Production.Category AS c
        ON c.CategoryId = p.CategoryId
WHERE p.Discontinued = 1
GROUP BY s.SupplierCompanyName,
         p.ProductName,
         c.CategoryName,
         dbo.udf_ReturnDiscontinuedStatus(p.Discontinued)
		 FOR JSON PATH, ROOT('Discontinued'), INCLUDE_NULL_VALUES; 

-- Proposition 17: In Northwinds2020TSQLV6, this is a scalar function that returns Continent for suppliers
DROP FUNCTION IF EXISTS dbo.udf_ReturnContinent;
GO
;
CREATE FUNCTION dbo.udf_ReturnContinent
(
    @SupplierCountryInput AS NVARCHAR(15)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @continent NVARCHAR(50);

    SET @continent
        = CASE
              WHEN @SupplierCountryInput IN ( 'USA', 'Canada' ) THEN
                  'North America'
              WHEN @SupplierCountryInput IN ( 'Brazil' ) THEN
                  'South America'
              WHEN @SupplierCountryInput IN ( 'Finland', 'Italy', 'Denmark', 'Netherlands', 'Spain', 'Germany',
                                              'France', 'Norway', 'Sweden', 'UK'
                                            ) THEN
                  'Europe'
              WHEN @SupplierCountryInput IN ( 'Japan', 'Singapore' ) THEN
                  'Asia'
              WHEN @SupplierCountryInput IN ( 'Australia' ) THEN
                  'Australia'
          END;

    RETURN @continent;
END;
GO
;
USE Northwinds2020TSQLV6;
SELECT p.ProductName,
       c.CategoryName,
       s.SupplierCompanyName,
       dbo.udf_ReturnContinent(s.SupplierCountry) AS Continent,
       CONCAT(s.SupplierAddress, ', ', s.SupplierCity, ',  Zip ', s.SupplierPostalCode) AS TotalAddress
FROM Production.Product AS p
    INNER JOIN Production.Supplier AS s
        ON s.SupplierId = p.SupplierId
    INNER JOIN Production.Category AS c
        ON c.CategoryId = p.CategoryId
		FOR JSON PATH, ROOT('Production'), INCLUDE_NULL_VALUES; 

-- Proposition 18: In Northwinds2020TSQLV6, categorize the price range
DROP FUNCTION IF EXISTS dbo.udf_FreightPriceRange;
GO
;
CREATE FUNCTION dbo.udf_FreightPriceRange
(
    @PriceInput MONEY
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @UnitPriceOutput NVARCHAR(50);

    SET @UnitPriceOutput = CASE
                               WHEN @PriceInput = 0 THEN
                                   'Product is free!'
                               WHEN @PriceInput < 50 THEN
                                   'Product is under $50'
                               WHEN @PriceInput >= 50
                                    AND @PriceInput < 100 THEN
                                   'Product is greater than or equal to $50 but under $100'
                               WHEN @PriceInput >= 100
                                    AND @PriceInput < 250 THEN
                                   'Product is under $250'
                               ELSE
                                   'Product is over $250'
                           END;
    RETURN @UnitPriceOutput;
END;
GO
;
USE Northwinds2020TSQLV6;

SELECT p.ProductId
	,p.ProductName
	,p.UnitPrice
	,c.CategoryName
	,c.Description
	,dbo.udf_FreightPriceRange(p.UnitPrice) AS ProductPriceRange
FROM Production.Product AS p
INNER JOIN Production.Category AS c ON p.CategoryId = c.CategoryId
LEFT OUTER JOIN Sales.Note AS n ON n.ProductId = p.ProductId
FOR

JSON PATH
	,ROOT('Product')
	,INCLUDE_NULL_VALUES;


-- Proposition 19: In AdventureWorks2019, find the amount of days product have been active on the market
DROP FUNCTION IF EXISTS dbo.udf_ActiveDaysOnMarket;
GO
;
CREATE FUNCTION dbo.udf_ActiveDaysOnMarket
(
    @SellStartDate DATETIME,
    @SellEndDate DATETIME
)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @SellStartDate, @SellEndDate);
END;

GO
;
USE AdventureWorks2019;
SELECT TOP (20)
       p.ProductID,
       p.Name AS ProductName,
       psc.Name,
       p.SellStartDate,
       p.SellEndDate,
       SUM(pInventory.Quantity) AS TotalQuantity,
       dbo.udf_ActiveDaysOnMarket(p.SellStartDate, p.SellEndDate) AS ActiveDaysOnMarket
FROM Production.Product AS p
    INNER JOIN Production.ProductInventory AS pInventory
        ON pInventory.ProductID = p.ProductID
    INNER JOIN Production.ProductSubcategory AS psc
        ON psc.ProductSubcategoryID = p.ProductSubcategoryID
WHERE p.SellEndDate IS NOT NULL
GROUP BY p.Name,
         p.ProductID,
         p.SellStartDate,
         p.SellEndDate,
         psc.Name
ORDER BY ActiveDaysOnMarket DESC;

-- Proposition 20: In AdventureWorks2019, find the amount of days between order date and ship date
DROP FUNCTION IF EXISTS dbo.udf_DifferenceBetweenOrderAndShip;
GO
;
CREATE FUNCTION dbo.udf_DifferenceBetweenOrderAndShip
(
    @OrderDate DATETIME,
    @ShipDate DATETIME
)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @OrderDate, @ShipDate);
END;

GO
USE AdventureWorks2019;
SELECT DISTINCT
       oh.TerritoryID,
       SUM(od.OrderQty) AS TotalQtyOfOrders,
       AVG(DISTINCT dbo.udf_DifferenceBetweenOrderAndShip(oh.OrderDate, oh.ShipDate)) AS AvgDifferenceOfDaysBetweenOrderAndShip
FROM Sales.SalesOrderDetail AS od
    INNER JOIN Sales.SalesOrderHeader AS oh
        ON oh.SalesOrderID = od.SalesOrderID
    INNER JOIN Sales.SalesTerritory AS st
        ON st.TerritoryID = oh.TerritoryID
GROUP BY oh.TerritoryID
ORDER BY oh.TerritoryID ASC
FOR JSON PATH, ROOT('territory'), INCLUDE_NULL_VALUES; 