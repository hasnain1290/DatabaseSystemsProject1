--Alex Perinetti - Group 7 - Project 1
--Simple Queries
/*
	Problem 01: What are the orders for each customer in the Sales.Customer table using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

SELECT c.CustomerId
	,o.OrderDate
FROM Sales.Customer AS c
INNER JOIN Sales.[Order] AS o ON c.CustomerId = o.CustomerId
ORDER BY c.CustomerId;


--	Problem 01 fixed: No reason to join order and customer, so added company name which is only found in customer.
USE Northwinds2020TSQLV6;
GO

SELECT c.CustomerId
	,c.CustomerCompanyName
	,o.OrderDate
FROM Sales.Customer AS c
INNER JOIN Sales.[Order] AS o ON c.CustomerId = o.CustomerId
ORDER BY c.CustomerId;


/*
	Problem 02: Where are there customers but no employees using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

SELECT c.CustomerCountry AS Country
	,c.CustomerRegion AS Region
	,c.CustomerCity AS City
FROM Sales.Customer AS c

EXCEPT

SELECT e.EmployeeCountry
	,e.EmployeeRegion
	,e.EmployeeCity
FROM HumanResources.Employee AS e;


/*
	Problem 03: What are the details for the items in the shopping cart using AdventureWorks?
*/
USE AdventureWorks2017;
GO

SELECT s.ShoppingCartItemId
	,s.ProductId
	,p.[Name]
	,p.ListPrice
FROM Sales.ShoppingCartItem AS s
INNER JOIN Production.Product AS p ON s.ProductId = p.ProductId;


/*
	Problem 04: Where are there suppliers and employees using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

SELECT s.SupplierCountry AS Country
	,s.SupplierRegion AS Region
	,s.SupplierCity AS City
FROM Production.Supplier AS s

INTERSECT

SELECT e.EmployeeCountry
	,e.EmployeeRegion
	,e.EmployeeCity
FROM HumanResources.Employee AS e
ORDER BY Country
	,Region
	,City;


/*
	Problem 05: Where have orders been shipped to that have no suppliers using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

SELECT o.ShipToCountry AS Country
	,o.ShipToRegion AS Region
	,o.ShipToCity AS City
FROM Sales.[Order] AS o

INTERSECT

SELECT s.SupplierCountry
	,s.SupplierRegion
	,s.SupplierCity
FROM Production.Supplier AS s;


--Medium Queries
/*
	Problem 06: How many employees have worked in each department and how many have stopped working in that department using AdventureWorks?
*/
USE AdventureWorks2017;
GO

SELECT d.DepartmentId
	,d.[Name]
	,COUNT(dh.BusinessEntityId) AS Employees
	,COUNT(dh.EndDate) AS NoLongerInDepartment
FROM HumanResources.Department AS d
INNER JOIN HumanResources.EmployeeDepartmentHistory AS dh ON d.DepartmentId = dh.DepartmentId
GROUP BY d.DepartmentId
	,d.[Name];


/*
	Problem 07: For each order, how many types of products were ordered and what was the total quantity using AdventureWorks?
*/
USE AdventureWorks2017;
GO

SELECT po.PurchaseOrderId
	,COUNT(po.ProductId) AS NumOfProducts
	,STRING_AGG(p.[Name], ', ') AS Products
	,SUM(po.OrderQty) AS TotalQuantity
FROM Purchasing.PurchaseOrderDetail AS po
INNER JOIN Production.Product AS p ON po.ProductId = p.ProductId
GROUP BY po.PurchaseOrderId;


/*
	Problem 08: What are the total sales the previous year in each country by their currency using AdventureWorks?
*/
USE AdventureWorks2017;
GO

SELECT t.CountryRegionCode
	,c.CurrencyCode
	,SUM(t.SalesLastYear) AS TotalSalesLastYear
FROM Sales.SalesTerritory AS t
INNER JOIN Sales.CountryRegionCurrency AS c ON t.CountryRegionCode = c.CountryRegionCode
GROUP BY t.CountryRegionCode
	,c.CurrencyCode;


--	Problem 08 fixed: Since TotalSalesYear was duplicated, String_Agg gets rid of the duplicates
USE AdventureWorks2017;
GO

SELECT t.CountryRegionCode
	,STRING_AGG(c.CurrencyCode, ', ') AS Currencies
	,SUM(t.SalesLastYear) AS TotalSalesLastYear
FROM Sales.SalesTerritory AS t
INNER JOIN Sales.CountryRegionCurrency AS c ON t.CountryRegionCode = c.CountryRegionCode
GROUP BY t.CountryRegionCode;


/*
	Problem 09: How many of products with a list price between 5 and 10 dollars were bought using AdventureWorks?
*/
USE AdventureWorks2017;
GO

SELECT p.ProductId
	,p.[Name]
	,p.ListPrice
	,SUM(po.OrderQty) AS TotalSold
	,(p.ListPrice * SUM(po.OrderQty)) AS Gross
FROM Production.Product AS p
INNER JOIN Purchasing.PurchaseOrderDetail AS po ON p.ProductId = po.ProductId
WHERE p.ListPrice BETWEEN 5
		AND 10
GROUP BY p.ProductId
	,p.[Name]
	,p.ListPrice;


/*
	Problem 10: For each item ordered, what was the total quantity and the list price cost difference using AventureWorks?
*/
USE AdventureWorks2017;
GO

SELECT s.ProductId
	,SUM(s.OrderQty) AS Quantity
	,SUM(p.ListPrice) AS ListPrice
	,SUM(p.StandardCost) AS Cost
	,(SUM(p.ListPrice) - SUM(p.StandardCost)) * SUM(s.OrderQty) AS Profit
FROM Sales.SalesOrderDetail AS s
INNER JOIN Production.Product AS p ON s.ProductId = p.ProductId
GROUP BY s.ProductId
ORDER BY s.ProductId;


/*
	Problem 11: Which customers have over 10 orders in 2016 using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

SELECT c.CustomerId
	,c.CustomerCompanyName
	,COUNT(o.OrderId) AS NumOfOrders
FROM Sales.Customer AS c
INNER JOIN Sales.[Order] AS o ON c.CustomerId = o.CustomerId
WHERE YEAR(o.OrderDate) = '2016'
GROUP BY c.CustomerId
	,c.CustomerCompanyName
HAVING COUNT(o.OrderId) > 10;


/*
	Problem 12: Which orders had more than 3 items in 2015 using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

SELECT o.OrderId
	,COUNT(od.ProductId) AS NumOfItems
FROM Sales.[Order] AS o
INNER JOIN Sales.OrderDetail AS od ON o.OrderId = od.OrderId
WHERE YEAR(o.OrderDate) = '2015'
GROUP BY o.OrderId
HAVING COUNT(DISTINCT od.ProductId) > 3
ORDER BY o.OrderId;


/*
	Problem 13: How many orders did employees make in QI 2015 using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

SELECT e.EmployeeId
	,COUNT(o.OrderId) AS NumOfOrders
FROM HumanResources.Employee AS e
INNER JOIN Sales.[Order] AS o ON e.EmployeeId = o.EmployeeId
WHERE o.OrderDate BETWEEN '20150101'
		AND '20150331'
GROUP BY e.EmployeeId;


--Complex Queries
/*
	Problem 14: What are the hexadecimal values of Customer Ids, and how many orders did each customer place, and how many products for those orders using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION

IF EXISTS dbo.IntToHex;
GO
	CREATE FUNCTION dbo.IntToHex (@num INT)
	RETURNS VARCHAR(30)
	AS
	BEGIN
		DECLARE @hex VARCHAR(30);

		WHILE @num > 0
		BEGIN
			SET @hex = CONCAT (
					CASE 
						WHEN @num % 16 < 10
							THEN CAST(@num % 16 AS VARCHAR)
						WHEN @num % 16 = 10
							THEN 'A'
						WHEN @num % 16 = 11
							THEN 'B'
						WHEN @num % 16 = 12
							THEN 'C'
						WHEN @num % 16 = 13
							THEN 'D'
						WHEN @num % 16 = 14
							THEN 'E'
						WHEN @num % 16 = 15
							THEN 'F'
						END
					,@hex
					);
			SET @num = @num / 16;
		END;

		RETURN @hex;
	END;
GO

SELECT dbo.IntToHex(c.CustomerId) AS CustomerId
	,COUNT(o.OrderId) AS NumberOfOrders
	,SUM(o.OrderDetail) AS NumberOfProducts
FROM Sales.Customer AS c
LEFT OUTER JOIN (
	SELECT o.OrderId
		,o.CustomerId
		,COUNT(od.ProductId) AS OrderDetail
	FROM Sales.[Order] AS o
	INNER JOIN Sales.OrderDetail AS od ON o.OrderId = od.OrderId
	GROUP BY o.OrderId
		,o.CustomerId
	) AS o ON c.CustomerId = o.CustomerId
GROUP BY c.CustomerId
ORDER BY CustomerId;


/*
	Problem 15: What is the name of each employee, and how many orders did they sell and with how many items using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION

IF EXISTS dbo.ConcatName;
GO
	CREATE FUNCTION dbo.ConcatName (
		@FirstName NVARCHAR(30)
		,@LastName NVARCHAR(30)
		)
	RETURNS NVARCHAR(62)
	AS
	BEGIN
		DECLARE @Result NVARCHAR(62);

		SELECT @Result = CASE 
				WHEN @FirstName IS NULL
					OR @LastName IS NULL
					THEN 'Error in data'
				ELSE CONCAT (
						@LastName
						,', '
						,@FirstName
						)
				END;

		RETURN @Result;
	END;
GO

SELECT dbo.ConcatName(e.EmployeeFirstName, e.EmployeeLastName) AS [Name]
	,COUNT(o.OrderId) AS Orders
	,SUM(o.NumOfProducts) AS Products
FROM HumanResources.Employee AS e
INNER JOIN (
	SELECT o.OrderId
		,o.EmployeeId
		,COUNT(od.ProductId) AS NumOfProducts
	FROM Sales.[Order] AS o
	INNER JOIN Sales.OrderDetail AS od ON o.OrderId = od.OrderId
	GROUP BY o.OrderId
		,o.EmployeeId
	) AS o ON e.EmployeeId = o.EmployeeId
GROUP BY dbo.ConcatName(e.EmployeeFirstName, e.EmployeeLastName);


/*
	Problem 16: What are the octal values of geography keys, and how many employees are assigned to their area and how many customers are located there using AdventureWorksDW?
*/
USE AdventureWorksDW2017;
GO

DROP FUNCTION

IF EXISTS dbo.IntToOct;
GO
	CREATE FUNCTION dbo.IntToOct (@num INT)
	RETURNS VARCHAR(30)
	AS
	BEGIN
		DECLARE @oct VARCHAR(30);

		WHILE @num > 0
		BEGIN
			SET @oct = CONCAT (
					@num % 8
					,@oct
					);
			SET @num = @num / 8;
		END;

		RETURN @oct;
	END;
GO

SELECT dbo.IntToOct(g.GeographyKey) AS GeographyKey
	,g.EnglishCountryRegionName
	,g.StateProvinceName
	,g.City
	,g.SalesTerritoryKey
	,COUNT(DISTINCT c.CustomerKey) AS NumOfCustomers
	,COUNT(DISTINCT e.EmployeeKey) AS NumOfEmployees
FROM (
	dbo.DimGeography AS g LEFT OUTER JOIN dbo.DimCustomer AS c ON c.GeographyKey = g.GeographyKey
	)
LEFT OUTER JOIN dbo.DimEmployee AS e ON g.SalesTerritoryKey = e.SalesTerritoryKey
GROUP BY dbo.IntToOct(g.GeographyKey)
	,g.EnglishCountryRegionName
	,g.StateProvinceName
	,g.City
	,g.SalesTerritoryKey
ORDER BY GeographyKey;


/*
	Problem 17: What are the binary values of the employee ids and their manager's, and how many orders has each employee made using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION

IF EXISTS dbo.IntToBin;
GO
	CREATE FUNCTION dbo.IntToBin (@num INT)
	RETURNS VARCHAR(30)
	AS
	BEGIN
		DECLARE @bin VARCHAR(30);

		WHILE @num > 0
		BEGIN
			SET @bin = CONCAT (
					@num % 2
					,@bin
					);
			SET @num = @num / 2;
		END;

		RETURN @bin;
	END;
GO

SELECT dbo.IntToBin(e.EmployeeId) AS EmployeeId
	,e.EmployeeFirstName
	,e.EmployeeLastName
	,dbo.IntToBin(m.EmployeeId) AS ManagerId
	,COUNT(DISTINCT o.OrderId) AS NumOfOrders
FROM (
	HumanResources.Employee AS e LEFT OUTER JOIN HumanResources.Employee AS m ON e.EmployeeManagerId = m.EmployeeId
	)
INNER JOIN Sales.[Order] AS o ON e.EmployeeId = o.EmployeeId
GROUP BY dbo.IntToBin(e.EmployeeId)
	,e.EmployeeFirstName
	,e.EmployeeLastName
	,m.EmployeeId;


--	Problem 17 fixed: Gets rid of the useless self join of the Employees table and adds a second join to orders to get the manager order count as well.
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION

IF EXISTS dbo.IntToBin;
GO
	CREATE FUNCTION dbo.IntToBin (@num INT)
	RETURNS VARCHAR(30)
	AS
	BEGIN
		DECLARE @bin VARCHAR(30);

		WHILE @num > 0
		BEGIN
			SET @bin = CONCAT (
					@num % 2
					,@bin
					);
			SET @num = @num / 2;
		END;

		RETURN @bin;
	END;
GO

SELECT dbo.IntToBin(e.EmployeeId) AS EmployeeId
	,e.EmployeeFirstName
	,e.EmployeeLastName
	,dbo.IntToBin(e.EmployeeManagerId) AS ManagerId
	,COUNT(DISTINCT o.OrderId) AS NumOfOrders
	,COUNT(DISTINCT om.OrderId) AS ManagerOrders
FROM HumanResources.Employee AS e
INNER JOIN Sales.[Order] AS o ON e.EmployeeId = o.EmployeeId
LEFT OUTER JOIN Sales.[Order] AS om ON e.EmployeeManagerId = om.EmployeeId
GROUP BY e.EmployeeId
	,e.EmployeeFirstName
	,e.EmployeeLastName
	,e.EmployeeManagerId;


--
/*
	Problem 18: How long ago was the newest order for each customer, and which employee placed the order with them using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION

IF EXISTS Sales.YearsAgo;
GO
	CREATE FUNCTION Sales.YearsAgo (@date DATE)
	RETURNS NVARCHAR(40)
	AS
	BEGIN
		DECLARE @yeardiff INT = DATEDIFF(YEAR, @date, SYSDATETIME());

		RETURN CASE 
				WHEN @yeardiff = 0
					THEN 'The last order was this year'
				WHEN @yeardiff = 1
					THEN 'The last order was 1 year ago'
				ELSE CONCAT (
						'The last order was '
						,@yeardiff
						,' years ago'
						)
				END;
	END;
GO

SELECT c.CustomerId
	,c.OrderDate
	,Sales.YearsAgo(c.OrderDate) AS LastOrder
	,o.OrderId
	,dbo.ConcatName(e.EmployeeFirstName, e.EmployeeLastname) AS EmployeeName
FROM Sales.Customer AS s
CROSS APPLY (
	SELECT c.CustomerId
		,MAX(o.OrderDate) AS OrderDate
	FROM Sales.Customer AS c
	INNER JOIN Sales.[Order] AS o ON c.CustomerId = s.CustomerId
		AND c.CustomerId = o.CustomerId
	GROUP BY c.CustomerId
	) AS c
INNER JOIN Sales.[Order] AS o ON c.OrderDate = o.OrderDate
	AND c.CustomerId = o.CustomerId
INNER JOIN HumanResources.Employee AS e ON o.EmployeeId = e.EmployeeId
ORDER BY c.CustomerId;


/*
	Problem 19: What quarter was each order placed, and how many items were in the order, what was its cost, and who supplier the items using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION

IF EXISTS Sales.YearQuarter;
GO
	CREATE FUNCTION Sales.YearQuarter (@date DATE)
	RETURNS VARCHAR(30)
	AS
	BEGIN
		DECLARE @year INT = YEAR(@date);
		DECLARE @month INT = MONTH(@date);
		DECLARE @qrt VARCHAR(30) = CASE 
				WHEN @month BETWEEN 1
						AND 3
					THEN CONCAT (
							'QI-'
							,@year
							)
				WHEN @month BETWEEN 4
						AND 6
					THEN CONCAT (
							'QII-'
							,@year
							)
				WHEN @month BETWEEN 7
						AND 9
					THEN CONCAT (
							'QIII-'
							,@year
							)
				WHEN @month BETWEEN 10
						AND 12
					THEN CONCAT (
							'QIV-'
							,@year
							)
				ELSE 'You got some problems'
				END;

		RETURN @qrt;
	END;
GO

SELECT o.OrderId
	,Sales.YearQuarter(o.OrderDate) AS Qtr
	,COUNT(od.ProductId) AS NumOfItems
	,SUM(od.UnitPrice * od.Quantity) AS CostWithoutDiscount
	,STRING_AGG(p.SupplierId, ',') AS Suppliers
FROM Sales.[Order] AS o
INNER JOIN Sales.OrderDetail AS od ON o.OrderId = od.OrderId
INNER JOIN Production.Product AS p ON od.ProductId = p.ProductId
GROUP BY O.OrderId
	,Sales.YearQuarter(o.OrderDate)
ORDER BY o.OrderId;


/*
	Problem 20: What are the individual orders each customer made and how many items did they get with each order, and are they located where the employee who handled the order is using Northwinds?
*/
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION

IF EXISTS Sales.EmpCustCity;
GO
	CREATE FUNCTION Sales.EmpCustCity (
		@custCity NVARCHAR(15)
		,@empCity NVARCHAR(15)
		)
	RETURNS NVARCHAR(80)
	AS
	BEGIN
		IF (
				@custCity IS NULL
				OR @empCity IS NULL
				)
			RETURN 'Unknown';

		IF (@custCity = @empCity)
			RETURN 'Employee and Customer are in the same city';

		RETURN 'Employee and Customer are not in the same city';
	END;
GO

SELECT c.CustomerId
	,e.EmployeeId
	,c.CustomerCity
	,Sales.EmpCustCity(c.CustomerCity, e.EmployeeCity) AS [Location]
	,o.OrderId
	,COUNT(od.ProductId) AS NumofItems
FROM Sales.Customer AS c
LEFT OUTER JOIN Sales.[Order] AS o ON c.CustomerId = o.CustomerId
LEFT OUTER JOIN HumanResources.Employee AS e ON o.EmployeeId = e.EmployeeId
LEFT OUTER JOIN Sales.OrderDetail AS od ON o.OrderId = od.OrderId
GROUP BY c.CustomerId
	,e.EmployeeId
	,c.CustomerCity
	,Sales.EmpCustCity(c.CustomerCity, e.EmployeeCity)
	,o.OrderId
ORDER BY c.CustomerId;


--Cleanup
USE Northwinds2020TSQLV6;
GO

DROP FUNCTION IF EXISTS Sales.EmpCustCity
	,Sales.YearQuarter
	,Sales.YearsAgo
	,dbo.IntToBin
	,dbo.ConcatName
	,dbo.IntToHex;
GO

USE AdventureWorks2017;
GO

DROP FUNCTION IF EXISTS dbo.IntToOct;