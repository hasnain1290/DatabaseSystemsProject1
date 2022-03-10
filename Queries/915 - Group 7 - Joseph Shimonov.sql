/*
	Specifications for Project 1
		- each member of the group will develop 20 problem statements (propositions) and develop the 
		  solution
				use AdventureWorks2014
				use AdvertureWorksDW2014
				use NorthWinds2020TSQV6
		- problems should range from simple (5) to medium (8) to complex (7)

		- Simple queries -> should have up to 2 tables joined
		- Medium queries -> should have from 2 to 3 tables joined and use built in sql functions and 
		  group by summarization
		- Complex queries -> should have from 3 or more tables joined, custom scalar function and use
		  built-in SQL functions and group by summarization
*/


/*
	Simple Query #1
	Database: Northwinds2020TSQLV6
	Problem 01: Return all the orders that were shipped after
		the required date.
*/
USE Northwinds2020TSQLV6;
GO

SELECT o.orderid
	,od.unitprice
	,od.Quantity
	,od.DiscountPercentage
	,o.orderdate
	,o.requireddate
	,o.shiptodate
	,o.freight
FROM Sales.OrderDetail AS od
	INNER JOIN Sales.[Order] AS o 
		ON o.orderid = od.orderid
WHERE o.RequiredDate < o.ShipToDate
ORDER BY o.orderdate
FOR JSON PATH
	,ROOT('ShippedLate')
	,INCLUDE_NULL_VALUES;
/*
	Question 1 doesn't really use OrderDetail to
	show anything important about the package that was delivered
	late, instead we can substitute the columns from OrderDetail
	with od.ProductId and we can remove the freight of the order
*/
USE Northwinds2020TSQLV6;
GO
SELECT o.orderid
	,od.ProductId
	,o.orderdate
	,o.requireddate
	,o.shiptodate
FROM Sales.OrderDetail AS od
	INNER JOIN Sales.[Order] AS o 
		ON o.orderid = od.orderid
WHERE o.RequiredDate < o.ShipToDate
ORDER BY o.orderdate;

/*
	Simple Query #2
	Database: Northwinds2020TSQLV6
	Problem 02: Return all the products that have a discount percentage greater than
		0. Returns a column that shows the total price based on unit price, quantity,
		and discount percentage
*/
USE Northwinds2020TSQLV6;
GO 
SELECT DISTINCT(od.OrderId)
	, od.ProductId
	, p.ProductName
	, od.UnitPrice
	, od.Quantity
	, od.DiscountPercentage
	, (od.UnitPrice * od.Quantity) - ((od.UnitPrice * od.Quantity) * od.DiscountPercentage) AS TotalPrice 
FROM Production.Product AS p
	INNER JOIN Sales.OrderDetail AS od 
		ON p.ProductId = od.ProductId
WHERE od.DiscountPercentage > 0
ORDER BY TotalPrice;

/*
	Simple Query #3
	Database: AdventureWorksDW2017
	Problem 03: Return values where the average rate is less than the end of day rate
		for the year 2011
	Returns 560 rows
*/
USE AdventureWorksDW2017;
GO
SELECT DISTINCT(fcr.[Date])
	, ff.DepartmentGroupKey
	, fcr.AverageRate
	, fcr.EndOfDayRate
FROM dbo.FactCurrencyRate AS fcr
	INNER JOIN dbo.FactFinance AS ff
		ON fcr.DateKey = ff.DateKey
WHERE (fcr.EndOfDayRate > fcr.AverageRate)
	AND (YEAR(fcr.[Date]) = 2011)
ORDER BY (fcr.[Date])
FOR JSON PATH
	,ROOT('AverageRate')
	,INCLUDE_NULL_VALUES;


/*
	Simple Query #4
	Database: AdventureWorks2017
	Problem 04: Return all the credit card id's for cart type "Vista"
	Returns 4,665 rows
*/
USE AdventureWorks2017;
GO
SELECT pcc.CreditCardID
	, cc.CardType
	, cc.CardNumber
	, cc.ExpMonth
	, cc.ExpYear
FROM sales.PersonCreditCard AS pcc
	INNER JOIN sales.CreditCard AS cc
		ON pcc.CreditCardID = cc.CreditCardID
WHERE cc.CardType = 'Vista'
ORDER BY cc.ExpYear
FOR JSON PATH
	,ROOT('Vista')
	,INCLUDE_NULL_VALUES;

/*
	Simple Query 5
	Database: AdventureWorksDW2017
	Problem 05: Are there any birthdays that overlap between
		the customer and employee?
*/
USE AdventureWorksDW2017
GO
SELECT dc.FirstName AS CustomerFirstName
	, dc.LastName AS CustomerLastName
	, de.FirstName AS EmployeeFirstName
	, de.LastName AS EmployeeLastName
	, dc.BirthDate
FROM dbo.DimCustomer AS dc
	INNER JOIN dbo.DimEmployee AS de
		ON dc.BirthDate = de.BirthDate
FOR JSON PATH
	,ROOT('BirthdayTwins')
	,INCLUDE_NULL_VALUES;

/*
	Medium Query 1
	Database: Northwinds2020TSQLV6
	Problem 06: Return all the orders made by a customer
		where the total orders was greater than 10 and
		the year of the orders was in 2015
*/
USE Northwinds2020TSQLV6
GO
SELECT c.CustomerId
	, COUNT(o.OrderId) AS TotalOrders
FROM sales.Customer AS c
	INNER JOIN sales.[Order] AS o
		ON c.CustomerId = o.CustomerId
WHERE YEAR(o.OrderDate) = 2015
GROUP BY c.CustomerId
HAVING COUNT(o.OrderId) > 10
FOR JSON PATH
	,ROOT('TotalGreaterThan10')
	,INCLUDE_NULL_VALUES;

/*
	Medium Query 2
	Database: Northwinds2020TSQLV6
	Problem 07: Return suppliers with their respective total per
		category
	Returns 29 rows
*/
USE Northwinds2020TSQLV6
GO
SELECT s.SupplierId
	, COUNT(DISTINCT p.CategoryId) AS CategoryCount
FROM Production.Product AS p
	INNER JOIN production.Supplier AS s 
		ON p.SupplierId = s.SupplierId
GROUP BY s.SupplierId
FOR JSON PATH
	,ROOT('SupplierPerCategory')
	,INCLUDE_NULL_VALUES;

/*
	Medium Query 3
	Database: Northwinds2020TSQLV6
	Problem 08: Show all the orders, including those from
		employees table where the order was performed by a
		sales rep
*/
USE Northwinds2020TSQLV6
GO 
SELECT DISTINCT(o.orderid)
	, o.EmployeeId
	, e.EmployeeLastName
	, e.EmployeeFirstName
	, e.EmployeeTitle
FROM sales.[Order] AS o
	LEFT JOIN HumanResources.Employee AS e
		ON o.EmployeeId = e.EmployeeId
WHERE e.EmployeeTitle = 'Sales Representative'
GROUP BY o.orderid
	, o.EmployeeId
	, e.EmployeeLastName
	, e.EmployeeFirstName
	, e.EmployeeTitle
FOR JSON PATH
	,ROOT('SalesRepOrder')
	,INCLUDE_NULL_VALUES;


/*
	Medium Query 4
	Database: Northwinds2020TSQLV6
	Problem 09: Return all the orders that were shipped prior to 
		the required date. Return the order, company name, employee
		name
*/
USE Northwinds2020TSQLV6
GO
SELECT o.OrderId
	, c.CustomerCompanyName
	, e.EmployeeFirstName
	, e.EmployeeLastName
FROM sales.[order] AS o
	JOIN HumanResources.Employee AS e
		ON e.EmployeeId = o.EmployeeId
	JOIN sales.Customer AS c
		ON o.CustomerId = c.CustomerId
WHERE (MONTH(o.ShipToDate) <= MONTH(o.RequiredDate))
GROUP BY o.OrderId
	, c.CustomerCompanyName
	, e.EmployeeFirstName
	, e.EmployeeLastName
ORDER BY o.OrderId ASC
FOR JSON PATH
	,ROOT('EarlyShipment')
	,INCLUDE_NULL_VALUES;

/*
	The above query is wrong given that it doesn't take into
	account the day of the shipment as well. 
*/
USE Northwinds2020TSQLV6
GO
SELECT o.OrderId
	, c.CustomerCompanyName
	, e.EmployeeFirstName
	, e.EmployeeLastName
FROM sales.[order] AS o
	JOIN HumanResources.Employee AS e
		ON e.EmployeeId = o.EmployeeId
	JOIN sales.Customer AS c
		ON o.CustomerId = c.CustomerId
WHERE o.ShipToDate <= o.RequiredDate
GROUP BY o.OrderId
	, c.CustomerCompanyName
	, e.EmployeeFirstName
	, e.EmployeeLastName
ORDER BY o.OrderId ASC
FOR JSON PATH
	,ROOT('EarlyShipment')
	,INCLUDE_NULL_VALUES;

/*
	Medium Query 5
	Database: Northwinds2020TSQLV6
	Problem 10: Show the count of where all the employees are located
		based on city as well as where the customer are in relation to 
		the employees
*/
USE Northwinds2020TSQLV6
GO
SELECT COUNT(DISTINCT e.EmployeeId) AS TotalEmployeeCount
	, COUNT(DISTINCT c.CustomerId) AS TotalCustomerCount
	, e.EmployeeCity AS City
FROM HumanResources.Employee AS e 
	LEFT JOIN Sales.Customer AS c 
		ON e.EmployeeCity = c.CustomerCity
GROUP BY e.EmployeeCity
FOR JSON PATH
	,ROOT('TotalInCity')
	,INCLUDE_NULL_VALUES;


/*
	Medium Query 6
	Database: Northwinds2020TSQLV6
	Problem 11: Return all the orders for each customer where
		the total orders is greater than 5
*/
USE Northwinds2020TSQLV6
GO
SELECT c.CustomerId
	, COUNT(o.orderid) AS TotalOrders
FROM sales.customer AS c
	LEFT JOIN sales.[order] AS o
		ON c.CustomerId = o.CustomerId
GROUP BY c.CustomerId
HAVING COUNT(o.orderid) > 5
FOR JSON PATH
	,ROOT('MoreOrders')
	,INCLUDE_NULL_VALUES;

/*
	Medium Query 7
	Database: AdventureWorks2017
	Problem 12: Get the product information and sales order info
		on all products. Change the color string to hex.
*/
USE AdventureWorks2017
GO 
SELECT DISTINCT(p.ProductID)
	, p.[name]
	, CONVERT(VARBINARY(5), p.Color) AS HexTextofColor
	, count(sod.OrderQty) AS totalQuantity
FROM production.Product AS p
	INNER JOIN Sales.SalesOrderDetail AS sod
		ON p.ProductID = sod.ProductID
WHERE p.color IS NOT NULL
GROUP BY p.ProductID
	, p.[name]
	, CONVERT(VARBINARY(5), p.Color)
ORDER BY p.ProductID ASC
FOR JSON PATH
	,ROOT('ColorHexText')
	,INCLUDE_NULL_VALUES;

/*
	The above query is incorrect becasue it does not actually change
	the color string to its appropriate hex value
*/

USE AdventureWorks2017
GO 
SELECT DISTINCT(p.ProductID)
	, p.[name]
	, 'Hex Color' = CASE 
						WHEN p.Color IS NULL THEN 'No Hex'
						WHEN p.color = 'Black' THEN '#000000'
						WHEN p.color = 'Blue' THEN '#0000FF'
						WHEN p.color = 'Grey' THEN '#808080'
						WHEN p.color = 'Multi' THEN 'Multi Hex'
						WHEN p.color = 'Red' THEN '#FF0000'
						WHEN p.color = 'Silver' THEN '#C0C0C0'
						WHEN p.color = 'Silver/Black' THEN '#706F6D'
						WHEN p.color = 'White' THEN '#FFFFFF'
						ELSE '#FFFF00' 
					END 
	, count(sod.OrderQty) AS totalQuantity
FROM production.Product AS p
	INNER JOIN Sales.SalesOrderDetail AS sod
		ON p.ProductID = sod.ProductID
WHERE p.color IS NOT NULL
GROUP BY p.ProductID
	, p.Color
	, p.[name]
ORDER BY p.ProductID ASC


/*
	Medium Query 8
	Database: Northwinds2020TSQLV6
	Problem 13: Show all the orders completed by employees in 
		descending order
*/
USE Northwinds2020TSQLV6
GO 
SELECT COUNT(o.OrderId) AS TotalOrders
	, CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS EmployeeName
FROM sales.[order] AS o
	INNER JOIN HumanResources.Employee AS e
		ON o.EmployeeId = e.EmployeeId
GROUP BY e.EmployeeFirstName
	, e.EmployeeLastName
ORDER BY TotalOrders DESC
FOR JSON PATH
	,ROOT('CompletedOrders')
	,INCLUDE_NULL_VALUES;


/*
	Complex Query 1
	Database: AdventureWorks2017
	Problem 14: Find the reviews for products that were sold. Make sure to
		capture the color hex value for the product
*/
USE AdventureWorks2017
GO
DROP FUNCTION IF EXISTS dbo.ProductColorHex 
GO
CREATE FUNCTION dbo.ProductColorHex (
      @colorVal NVARCHAR(15)
)
RETURNS NVARCHAR(80)
AS
BEGIN
	-- colors that exist include black, blue, grey, multi, red, silver, silver/black, white, yellow
	-- null
	IF (@colorVal IS NULL)
		RETURN 'No Hex'
	-- black
	ELSE IF (@colorVal = 'Black')
		RETURN '#000000'
	-- blue
	ELSE IF (@colorVal = 'Blue')
		RETURN '#0000FF'
	-- grey
	ELSE IF (@colorVal = 'Grey')
		RETURN '#808080'
	-- multi
	ELSE IF (@colorVal = 'Multi')
		RETURN 'Multi Hex'
	-- red
	ELSE IF (@colorVal = 'Red')
		RETURN '#FF0000'
	-- silver
	ELSE IF (@colorVal = 'Silver')
		RETURN '#C0C0C0'
	-- silver/black
	ELSE IF (@colorVal = 'Silver/Black')
		RETURN '#706F6D'
	-- white
	ELSE IF (@colorVal = 'White')
		RETURN '#FFFFFF'
	-- yellow
	RETURN '#FFFF00';  
END;
GO

USE AdventureWorks2017
GO 
SELECT DISTINCT(p.ProductID)
	, p.[name]
	, dbo.ProductColorHex(p.Color) AS ColorHex
	, p.SellStartDate
	, pr.ReviewDate
	, pr.Rating
	, pr.Comments
	, count(sod.OrderQty) AS totalQuantitySold
FROM production.Product AS p
	JOIN Sales.SalesOrderDetail AS sod
		ON p.ProductID = sod.ProductID
	LEFT JOIN production.ProductReview AS pr
		ON p.ProductID = pr.ProductID
GROUP BY p.ProductID
	, p.[name]
	, dbo.ProductColorHex(p.Color)
	, p.SellStartDate
	, pr.ReviewDate
	, pr.Rating
	, pr.Comments
ORDER BY p.ProductID ASC
FOR JSON PATH
	,ROOT('HexLiteral')
	,INCLUDE_NULL_VALUES;



/*
	Complex Query 2
	Database: Northwinds2020TSQLV6
	Problem 15: Find out which generation the employees were born 
		in and which generation did they receive their job in
*/
USE Northwinds2020TSQLV6
GO
DROP FUNCTION IF EXISTS dbo.GenerationBorn 
GO
CREATE FUNCTION dbo.GenerationBorn (
      @BirthDate Date
)
RETURNS NVARCHAR(80)
AS
BEGIN
	IF (@BirthDate IS NULL)
		RETURN 'Unknown Generation'
	ELSE IF (YEAR(@BirthDate) <= 1945)
		RETURN 'Silent Generation'
	ELSE IF (YEAR(@BirthDate) <= 1964)
		RETURN 'Baby Boomer'
	ELSE IF (YEAR(@BirthDate) <= 1976)
		RETURN 'Generation X'
	ELSE IF (YEAR(@BirthDate) <= 1995)
		RETURN 'Millennial'
	RETURN 'Gen Z';
END
GO

SELECT o.OrderId
	, c.CustomerContactName
	, dbo.GenerationBorn(e.BirthDate) AS EmployeeBirthedGeneration
	, dbo.GenerationBorn(e.HireDate) AS EmployeeHiredGeneration
	, o.OrderDate
FROM sales.[order] AS o 
	LEFT JOIN HumanResources.Employee AS e
		ON e.EmployeeId = o.EmployeeId
	LEFT JOIN sales.Customer AS c
		ON o.CustomerId = c.CustomerId
GROUP BY o.OrderId
	, c.CustomerContactName
	, dbo.GenerationBorn(e.BirthDate)
	, dbo.GenerationBorn(e.HireDate)
	, o.OrderDate
ORDER BY o.orderid ASC
FOR JSON PATH
	,ROOT('Generation')
	,INCLUDE_NULL_VALUES;



/*
	Complex Query 3
	Database: Northwinds2020TSQLV6
	Problem 16: Find which continent the supplier 
		for the product is coming from. Make sure to show
		the quantity that was supplied for that product
*/
USE Northwinds2020TSQLV6
GO
DROP FUNCTION IF EXISTS dbo.SupplierContinent 
GO
CREATE FUNCTION dbo.SupplierContinent (
      @Country VARCHAR(20)
)
RETURNS NVARCHAR(80)
AS
BEGIN
	IF (@Country = 'Australia')
		RETURN 'Australia'
	ELSE IF (@Country = 'USA' OR @Country = 'Canada' OR @Country = 'Mexico')
		RETURN 'North America'
	ELSE IF (@Country = 'Japan' OR @Country = 'Singapore')
		RETURN 'Asia'
	ELSE IF (@Country = 'Brazil')
		RETURN 'South America'
	RETURN 'Europe';
END
GO

SELECT od.OrderId
	, p.ProductName
	, dbo.SupplierContinent(s.SupplierCountry) AS SupplierContinent
	, od.Quantity
FROM Production.Product AS p
	INNER JOIN Production.Supplier AS s
		ON p.SupplierId = s.SupplierId
	INNER JOIN Sales.OrderDetail AS od
		ON p.productid = od.productid
GROUP BY od.OrderId
	, p.ProductName
	, dbo.SupplierContinent(s.SupplierCountry)
	, od.Quantity
ORDER BY od.OrderId ASC
FOR JSON PATH
	,ROOT('SupplierContinent')
	,INCLUDE_NULL_VALUES;

/*
	Complex Query 4
	Database: Northwinds2020TSQLV6
	Problem 17: Yearly earnings are right around the corner
		people are interested to know how many orders were placed
		in the past year on a quarterly basis. Just remember that 
		all these companies began their quarters at the start of July.
		Show the returns from the shipper companies from 2014 Q! to 2015 Q4.
*/
USE Northwinds2020TSQLV6
GO
DROP FUNCTION IF EXISTS dbo.QuarterOrdered 
GO
CREATE FUNCTION dbo.QuarterOrdered (
      @OrderDate Date
)
RETURNS NVARCHAR(80)
AS
BEGIN
	IF (@OrderDate IS NULL)
		RETURN 'Nan'
	ELSE IF (MONTH(@OrderDate) BETWEEN 7 AND 9)
		RETURN 'Q1'
	ELSE IF (MONTH(@OrderDate) BETWEEN 10 AND 12)
		RETURN 'Q2'
	ELSE IF (MONTH(@OrderDate) BETWEEN 1 AND 3)
		RETURN 'Q3'
	RETURN 'Q4';
END
GO
SELECT s.ShipperCompanyName
	, dbo.QuarterOrdered(o.OrderDate) AS QuarterOrdered 
	, (od.Quantity*od.UnitPrice) AS TotalPrice
FROM Sales.OrderDetail AS od
	INNER JOIN Sales.[Order] AS o
		ON od.OrderId = o.OrderId
	INNER JOIN Sales.Shipper AS s
		ON o.ShipperId = s.ShipperId
WHERE YEAR(o.OrderDate) = 2014 OR YEAR(o.OrderDate) = 2015
GROUP BY dbo.QuarterOrdered(o.OrderDate)
	, s.ShipperCompanyName
	, (od.Quantity*od.UnitPrice)
ORDER BY QuarterOrdered
FOR JSON PATH
	,ROOT('QuarterlyEarnings')
	,INCLUDE_NULL_VALUES;
-- Incorrect because in order to find the year's quarter return,
-- you need a where clause to check the months too, here is the 
-- corrected version
SELECT DISTINCT(s.ShipperCompanyName)
	, dbo.QuarterOrdered(o.OrderDate) AS QuarterOrdered 
	, (od.Quantity*od.UnitPrice) AS TotalPrice
FROM Sales.OrderDetail AS od
	INNER JOIN Sales.[Order] AS o
		ON od.OrderId = o.OrderId
	RIGHT JOIN Sales.Shipper AS s
		ON o.ShipperId = s.ShipperId
WHERE (YEAR(o.OrderDate) = 2014 AND MONTH(o.OrderDate) BETWEEN 7 AND 12) 
		OR (YEAR(o.OrderDate) = 2015 AND MONTH(o.OrderDate) BETWEEN 1 AND 6)
GROUP BY dbo.QuarterOrdered(o.OrderDate)
	, s.ShipperCompanyName
	, (od.Quantity*od.UnitPrice)
ORDER BY QuarterOrdered;



/*
	Complex Query 5
	Database: Northwinds2020TSQLV6
	Problem 18: Determine the status of the good given the price paid for its totality.
		To ensure that your calculation is correct, also calculate the total price in 
		the results.
*/
USE Northwinds2020TSQLV6
GO
DROP FUNCTION IF EXISTS dbo.QualityGood 
GO
CREATE FUNCTION dbo.QualityGood (
      @Price MONEY,
	  @Qty INT
)
RETURNS NVARCHAR(80)
AS
BEGIN
	DECLARE @Total MONEY = @Price * @Qty

	IF (@Total BETWEEN 0 AND 50)
		RETURN 'Inferior Good'
	ELSE IF (@Total BETWEEN 51 AND 150)
		RETURN 'Normal Good'
	RETURN 'Luxury Good';
END
GO
SELECT p.ProductName
	, c.CategoryId
	, (od.UnitPrice * od.Quantity) AS TotalPrice
	, dbo.QualityGood(od.UnitPrice, od.Quantity) AS GoodStatus
FROM Sales.OrderDetail as od
		INNER JOIN Production.Product as p
			on od.productid = p.productid
		INNER JOIN Production.Category as c
			on p.categoryid = c.categoryid
GROUP BY od.OrderId
	, od.ProductId
	, p.ProductName
	, c.CategoryId
	, (od.UnitPrice * od.Quantity)
	, dbo.QualityGood(od.UnitPrice, od.Quantity)
FOR JSON PATH
	,ROOT('GoodStatus')
	,INCLUDE_NULL_VALUES;

/*
	Complex Query 6
	Database: Northwinds2020TSQLV6
	Problem 19: Create a scalar function that processes the first letter of the last 
		name and determine the appropriate status rank for the employee. After that 
		determine the id of the Employee and which Orders the Employee is able to 
		facilitate. To do this, order the rows based on the last name of the 
		employee.
*/
USE Northwinds2020TSQLV6
GO
DROP FUNCTION IF EXISTS dbo.NameSplicing 
GO
CREATE FUNCTION dbo.NameSplicing (
      @Name VARCHAR(20)
)
RETURNS NVARCHAR(80)
AS
BEGIN
	IF (@Name LIKE '[A-E]%')
		RETURN 'Diamond Rank'
	ELSE IF (@Name LIKE '[F-J]%')
		RETURN 'Platinum Rank'
	ELSE IF (@Name LIKE '[K-O]%')
		RETURN 'Gold Rank'
	ELSE IF (@Name LIKE '[P-T]%')
		RETURN 'Silver Rank'
	RETURN 'Bronze Rank';
END
GO
SELECT DISTINCT(o.EmployeeId)
	, od.OrderId
	, CONCAT(e.EmployeeLastName, ', ', e.EmployeeFirstName) AS FullName
	, dbo.NameSplicing(e.EmployeeLastName) AS EmployeeGroup
FROM Sales.OrderDetail as od
		INNER JOIN Sales.[Order] as o
			on od.orderid = o.orderid
				INNER JOIN HumanResources.Employee as e
					on o.employeeid = e.employeeid
GROUP BY od.OrderId
	, o.EmployeeId
	, e.EmployeeLastName
	, e.EmployeeFirstName
	, dbo.NameSplicing(e.EmployeeLastName)
ORDER BY FullName
FOR JSON PATH
	,ROOT('EmployeeRank')
	,INCLUDE_NULL_VALUES;

/*
	Complex Query 7
	Database: Northwinds2020TSQLV6
	Problem 20: Create a scalar function that concatenates the first and last name 
		and then return orders that took place between the employee and customer on 
		the basis of that OrderId.
*/
USE Northwinds2020TSQLV6
GO
DROP FUNCTION IF EXISTS dbo.FullNameConcat
GO
CREATE FUNCTION dbo.FullNameConcat (
      @FirstName VARCHAR(20),
	  @LastName varchar(20)
)
RETURNS NVARCHAR(80)
AS
BEGIN
	IF (@FirstName IS NULL OR @LastName IS NULL)
		RETURN 'No Name'
	RETURN CONCAT(@FirstName, ' ', @LastName)
END
GO
SELECT o.OrderId
	, dbo.FullNameConcat(e.EmployeeFirstName, e.EmployeeLastName) AS EmployeeName
	, c.CustomerContactName
FROM sales.[Order] AS o
	INNER JOIN Sales.Customer AS c
		ON o.CustomerId = c.CustomerId
	INNER JOIN HumanResources.Employee AS e
		ON o.EmployeeId = e.EmployeeId
GROUP BY o.OrderId 
	, dbo.FullNameConcat(e.EmployeeFirstName, e.EmployeeLastName)
	, c.CustomerContactName
ORDER BY o.OrderId
FOR JSON PATH
	,ROOT('FullNameConcat')
	,INCLUDE_NULL_VALUES;