--SIMPLE
USE AdventureWorks2017

--+ 1 The number of productIds and the locationId being less than 50 with 
--their listed price being in descending order greatest to least 
--(354 rows affected)(Worse 1 Candidate)
SELECT c.ProductID
	,C.LocationID
	,d.ListPrice
FROM [Production].[ProductInventory] AS c
INNER JOIN [Production].[ProductListPriceHistory] AS d ON c.ProductID = d.ProductID
WHERE c.LocationID < 50
ORDER BY d.ListPrice DESC
FOR JSON PATH, root('ProductsInformation'), include_null_values;
--(Fixed)
--1 The number of productIds with 
--their listed price being in descending order greatest to least 
--(583 rows affected)
--Note: Changed the locationid relevance 
--it brought nothing new to the query as well as there was no specific 
--reason behind having that constraint be there in the first place
USE AdventureWorks2017
SELECT c.ProductID
	,C.LocationID
	,d.ListPrice
FROM [Production].[ProductInventory] AS c
INNER JOIN [Production].[ProductListPriceHistory] AS d ON c.ProductID = d.ProductID
ORDER BY d.ListPrice DESC
FOR JSON PATH, root('ProductsInformation'), include_null_values;

--+ 2 which employees in human resources are still working from their hire date 
--of 1/14/2009 (870 rows affected)
USE AdventureWorks2017
SELECT e.HireDate
	,d.EndDate
FROM HumanResources.EmployeeDepartmentHistory AS d
INNER JOIN [HumanResources].[Employee] AS e ON d.StartDate = d.StartDate
WHERE e.HireDate = '20090114'
	AND d.EndDate IS NULL
FOR JSON PATH, root('CurrentHires'), include_null_values;


--+ 3 The amount of people who edited their email address 
--OR their password on the date of 10/16/2013
USE AdventureWorks2017
SELECT a.ModifiedDate
FROM person.EmailAddress AS a
INNER JOIN person.Password AS p ON a.ModifiedDate = p.ModifiedDate
WHERE a.ModifiedDate = '20131016'
FOR JSON PATH, root('InformationChangers'), include_null_values;

--+ 4 What is the amount of people in the Database of people who do not have a middle name 
--AND the date it was modified not being null (8498 rows affected)(1 Best)
USE AdventureWorks2017
SELECT DISTINCT p.FirstName
	,p.MiddleName
	,p.LastName
	,p.ModifiedDate
FROM [Person].[Person] AS p
FULL OUTER JOIN person.CountryRegion AS t ON t.ModifiedDate = p.ModifiedDate
WHERE p.MiddleName IS NULL
	AND p.ModifiedDate IS NOT NULL
--FOR JSON PATH, root('NoMiddleNames'), include_null_values;

--+ 5 What is the birthdates of customers and
--employees that have overlap before the year 1950? (4 rows affected)
USE AdventureWorksDW2017

SELECT D.BirthDate
FROM dbo.DimCustomer AS D
INNER JOIN dbo.DimEmployee AS E ON E.BirthDate = D.BirthDate
WHERE YEAR(E.BirthDate) < 1950
FOR JSON PATH, root('EmployeeCustomerBirthdateOverlap'), include_null_values;


--MEDIUM, USE BUILT IN SQL Functions, 2 - 3 JOINS 

--6  1 What are the number of orders fulfilled by the Shipping company GVSUA,where the dates that
--they were required to be shipped out was before 2015?(36 rows affected)
USE Northwinds2020TSQLV6
SELECT st.CustomerId
	,st.OrderId
	,sh.ShipperCompanyName AS ShippingCompany
	,st.ShipToDate AS ShippedDate
FROM [Sales].[Order] AS st
INNER JOIN [Sales].[Shipper] AS sh ON sh.ShipperId = st.ShipperId
WHERE sh.ShipperCompanyName = 'Shipper GVSUA'
	AND YEAR(st.ShipToDate) < 2015
GROUP BY st.OrderId
	,st.CustomerId
	,st.ShipToDate
	,sh.ShipperCompanyName
FOR JSON PATH, root('ShipperGSVUABefore2015'), include_null_values;

--7 2 What are the Customer's names and their title, when they ordered 
--and those who have ordered a very low overall amount of freight less than 10(176 rows affected)
USE Northwinds2020TSQLV6
SELECT c.CustomerContactName AS CustomerName
	,c.CustomerContactTitle AS CustomerTitle
	,o.OrderDate
	,SUM(o.Freight) AS TotalFreightPerCustomer
FROM Sales.Customer AS c
INNER JOIN Sales.[order] AS o ON c.CustomerId = o.CustomerId
WHERE o.Freight < 10
GROUP BY o.Freight
	,c.CustomerContactName
	,c.CustomerContactTitle
	,o.OrderDate
	,o.ShipToPostalCode
FOR JSON PATH, root('OrderedLessThan10Freight'), include_null_values;


--8 3 What is the information on our largest amount of products being ordered, greater than 100Quantity and what is the 
--final price they receive and the amount of their discounts(13 rows affected)
USE Northwinds2020TSQLV6
SELECT DISTINCT (o.OrderId)
	,o.ProductId
	,p.ProductName
	,o.UnitPrice
	,o.Quantity
	,o.DiscountPercentage
	,(o.UnitPrice * o.Quantity) - ((o.UnitPrice * o.Quantity) * o.DiscountPercentage) AS FinalPrice
FROM Production.Product AS p
INNER JOIN Sales.OrderDetail AS o ON p.ProductId = o.ProductId
WHERE o.Quantity > 100
GROUP BY (o.OrderId)
	,o.ProductId
	,p.ProductName
	,o.UnitPrice
	,o.Quantity
	,o.DiscountPercentage
FOR JSON PATH, root('BiggestBuyersQuantity'), include_null_values;


--9 4 Which customers and which employees live in the same general area, 
--within the same country,in the same region,in the same city?(1 Best) 	 
USE Northwinds2020TSQLV6
SELECT c.CustomerId
	,e.EmployeeId
	,c.CustomerRegion
	,e.EmployeeRegion
	,e.EmployeeCountry
	,c.CustomerCountry
	,c.CustomerCity
	,e.EmployeeCity
FROM [HumanResources].[Employee] AS e
INNER JOIN Sales.Customer AS c ON e.EmployeeCity = c.CustomerCity
INNER JOIN Sales.[Order] AS o ON o.ShipToCity = c.CustomerCity
WHERE c.CustomerRegion IS NOT NULL
	AND e.EmployeeRegion IS NOT NULL
GROUP BY c.CustomerId
	,e.EmployeeId
	,c.CustomerRegion
	,e.EmployeeRegion
	,e.EmployeeCountry
	,c.CustomerCountry
	,c.CustomerCity
	,e.EmployeeCity
FOR JSON PATH, root('CustomerEmployeeSameArea'), include_null_values;


--10 5 What was the earliest order dates in the table and who was the supplier and 
--where were they located for shipping the order?(3 rows affected)
USE Northwinds2020TSQLV6
SELECT o.Orderid
	,o.Orderdate
	,o.CustomerId
	,o.EmployeeId
	,s.SupplierCompanyName
	,o.ShipToCountry
	,s.SupplierCountry
FROM Sales.[order] AS o
INNER JOIN Production.Supplier AS s ON o.ShiptoCountry = s.SupplierCountry
WHERE o.Orderdate = (
		SELECT MIN(O.orderdate)
		FROM Sales.[Order] AS O
		)
GROUP BY o.Orderid
	,o.Orderdate
	,o.CustomerId
	,o.EmployeeId
	,s.SupplierCompanyName
	,o.ShipToCountry
	,s.SupplierCountry
FOR JSON PATH, root('SupplierandCustomerCountry'), include_null_values;


--11 6 What is the contact information of the customer only in a country where employees exist, in alphabetical order of country?(20 rows affected)
USE Northwinds2020TSQLV6
SELECT c.CustomerCountry
	,c.CustomerPhoneNumber
	,c.CustomerFaxNumber
FROM Sales.Customer AS c
OUTER APPLY HumanResources.Employee AS hr 
WHERE c.CustomerCountry IN(
		SELECT E.[EmployeeCountry]
		FROM [HumanResources].[Employee] AS E
		)
GROUP BY c.CustomerCountry
	,c.CustomerPhoneNumber
	,c.CustomerFaxNumber
ORDER BY c.CustomerCountry
FOR JSON PATH, root('CustomerinEmployeeCountry'), include_null_values;



--12 7 What is the contact information of the customer in a country where there are no employees, in alphabetical order of country?(71 rows affected)(Worse 2 Candidate)
USE Northwinds2020TSQLV6
SELECT c.CustomerCountry
        ,c.CustomerPhoneNumber
        ,c.CustomerFaxNumber
FROM Sales.Customer AS c
OUTER APPLY HumanResources.Employee
WHERE c.CustomerCountry NOT IN (
                SELECT E.[EmployeeCountry]
                FROM [HumanResources].[Employee] AS E
                )
GROUP BY c.CustomerCountry
        ,c.CustomerPhoneNumber
        ,c.CustomerFaxNumber
ORDER BY c.CustomerCountry
FOR JSON PATH, root('CustomerinNOTEmployeeCountry'), include_null_values;
SELECT * FROM Sales.Customer AS c
OUTER APPLY HumanResources.Employee AS e

--(Fixed)
--12 What is the contact information of the customer and the id and last name of the employee in a country in alphabetical order of country?(819 rows affected)(Worse 2 Candidate)
--Note: Was just a reversed version of the previous query so to change it up and make it make more sense,
--this time I made it be the contact information as well as the country in which there are orders,
--this query also includes the employeeid and employee last name if you needed more information on how
--to contact them
USE Northwinds2020TSQLV6
SELECT c.CustomerCountry
        ,c.CustomerPhoneNumber
        ,c.CustomerFaxNumber
		,e.EmployeeId
		,e.EmployeeLastName
FROM Sales.Customer AS c
OUTER APPLY HumanResources.Employee AS e
GROUP BY c.CustomerCountry
        ,c.CustomerPhoneNumber
        ,c.CustomerFaxNumber
		,e.EmployeeId
		,e.EmployeeLastName
ORDER BY c.CustomerCountry
FOR JSON PATH, root('CustomerinNOTEmployeeCountry'), include_null_values;


--13 8 How many orders did each customer make across 2 quarters in Q2 and Q3 in 2014? (43 rows affected)
USE Northwinds2020TSQLV6
SELECT c.CustomerId
	,COUNT(o.OrderId) AS OrderAmount
FROM Sales.Customer AS c
INNER JOIN Sales.[Order] AS o ON c.CustomerId = o.CustomerId
WHERE o.OrderDate BETWEEN '20140401'
		AND '20140930'
GROUP BY c.CustomerId
FOR JSON PATH, root('NumOrdersQ2Q32014'), include_null_values;

--Complex, USE BUILT IN SQL FUNCTIONS, 3 joins ATLEAST
USE Northwinds2020TSQLV6;

--14 1 What are the Regions in which there exists both a customer and a Employee, allows NULLS but must 
--specify if the NULL is one or both Regions, Otherwise return if they are equal or not
USE Northwinds2020TSQLV6
DROP FUNCTION
IF EXISTS dbo.CustomerEmployeeRegion 
GO
	CREATE FUNCTION dbo.CustomerEmployeeRegion (
		@customerRegion NVARCHAR(15)
		,@employeeRegion NVARCHAR(15)
		)
	RETURNS NVARCHAR(80)
	AS
	BEGIN
		IF (
				@customerRegion IS NULL
				AND @employeeRegion IS NULL
				)
			RETURN 'Both are unknown';
		ELSE IF (
				@customerRegion IS NULL
				OR @employeeRegion IS NULL
				)
			RETURN 'One is unknown'

		IF (@customerRegion = @employeeRegion)
			RETURN 'Employee and Customer are in the same Region';

		RETURN 'Employee and Customer are not in the same Region';
	END;
GO

SELECT c.CustomerId
	,e.EmployeeId
	,c.CustomerRegion
	,e.EmployeeRegion
	,dbo.CustomerEmployeeRegion(c.CustomerRegion, e.EmployeeRegion) AS [Location]
FROM Sales.Customer AS c
LEFT OUTER JOIN Sales.[Order] AS o ON c.CustomerId = o.CustomerId
LEFT OUTER JOIN HumanResources.Employee AS e ON o.EmployeeId = e.EmployeeId
LEFT OUTER JOIN Sales.OrderDetail AS od ON o.OrderId = od.OrderId
GROUP BY c.CustomerId
	,e.EmployeeId
	,c.CustomerRegion
	,e.EmployeeRegion
	,dbo.CustomerEmployeeRegion(c.CustomerRegion, e.EmployeeRegion)
ORDER BY c.CustomerId
FOR JSON PATH, root('EmployeeCustomerRegionEquivalences'), include_null_values;


--15 2 There is a sugar shortage in your town and you must find out how to get sugar, 
--identify which products are confections and which aren't 
--and then which suppliers deliver those products and which do not ship confections,
--it is life or death(77 rows affected)(Worse 3 Candidate)
USE Northwinds2020TSQLV6
GO

DROP FUNCTION

IF EXISTS Production.Confection 
GO
	CREATE FUNCTION Production.Confection (
		@SupplierName NVARCHAR(15)
		,@Categoryid NVARCHAR(15)
		)
	RETURNS NVARCHAR(60)
	AS
	BEGIN
		IF (
				@Categoryid = 3
				AND @SupplierName = 'Supplier BWGYE'
				)
			RETURN 'This is a confection product and confection supplier #1'
		ELSE IF (
				@Categoryid = 3
				AND @SupplierName = 'Supplier ELCRN'
				)
			RETURN 'This is a confection product and confection supplier #3'
		ELSE IF (
				@Categoryid = 3
				AND @SupplierName = 'Supplier FNUXM'
				)
			RETURN 'This is a confection product and confection supplier #4'
		ELSE IF (
				@Categoryid = 3
				AND @SupplierName = 'Supplier GQRCV'
				)
			RETURN 'This is a confection product and confection supplier #5'
		ELSE IF (
				@Categoryid = 3
				AND @SupplierName = 'Supplier OGLRK'
				)
			RETURN 'This is a confection product and confection supplier #6'
		ELSE IF (
				@Categoryid = 3
				AND @SupplierName = 'Supplier ZPYVS'
				)
			RETURN 'This is a confection product and confection supplier #2'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName = 'Supplier BWGYE'
				)
			RETURN 'This is NOT a confection product but is confection supplier #1'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName = 'Supplier ELCRN'
				)
			RETURN 'This is NOT a confection product but is confection supplier #3'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName = 'Supplier FNUXM'
				)
			RETURN 'This is NOT confection product but is confection supplier #4'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName = 'Supplier GQRCV'
				)
			RETURN 'This is NOT confection product but is confection supplier #5'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName = 'Supplier OGLRK'
				)
			RETURN 'This is NOT confection product but is confection supplier #6'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName = 'Supplier ZPYVS'
				)
			RETURN 'This is NOT confection product but is confection supplier #2'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName <> 'Supplier BWGYE'
				)
			RETURN 'This is NOT a confection product nor a confection supplier'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName <> 'Supplier ELCRN'
				)
			RETURN 'This is NOT a confection product nor a confection supplier'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName <> 'Supplier FNUXM'
				)
			RETURN 'This is NOT a confection product nor a confection supplier'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName <> 'Supplier GQRCV'
				)
			RETURN 'This is NOT a confection product nor a confection supplier'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName <> 'Supplier OGLRK'
				)
			RETURN 'This is NOT a confection product nor a confection supplier'
		ELSE IF (
				@Categoryid <> 3
				AND @SupplierName = 'Supplier ZPYVS'
				)
			RETURN 'This is NOT a confection product nor a confection supplier'

		RETURN 'Done'
	END;
GO

SELECT pc.CategoryId
	,pc.CategoryName
	,pp.ProductId
	,ps.SupplierCompanyName
	,Production.Confection(ps.SupplierCompanyName, pc.CategoryId) AS ConfectionSupplierInformation
FROM Production.Category AS pc
LEFT OUTER JOIN Production.Product AS pp ON pp.CategoryId = pc.CategoryId
LEFT OUTER JOIN Production.Supplier AS ps ON ps.SupplierId = pp.SupplierId
GROUP BY pc.CategoryId
	,pc.CategoryName
	,pp.ProductId
	,ps.SupplierCompanyName
	,Production.Confection(ps.SupplierCompanyName, pc.CategoryId)
ORDER BY ps.SupplierCompanyName
--FOR JSON PATH, root('ConfectionCrazedTown - ProductAndSupplier'), include_null_values;
--(Fixed)
--15 2 There is a sugar shortage in your town and you must find out how to get sugar, 
--identify which products are confections and which aren't 
--and then which suppliers deliver those products and which do not ship confections,
--it is life or death(77 rows affected)
--Note: I had added another level of verification that was not necessary, it had to 
--do with the understanding of the statements I had already suggested, pretty much 
--I was unncessarily doubly checking if a supplier or category id was 3 or a supplier 
--who supplies convections and then checking to make sure they were not the same categoryid 
--nor a supplier who never supplied convections, by removing my last set of cases that had 
--to do with <> categoryid 3 and <> a certain supplier, and replace the 'done' final return as
--'This is NOT a confection product nor a confection supplier', it properly filled all the same
--cases and allowed the answers to be exactly the same despite less lines of code
USE Northwinds2020TSQLV6
GO

DROP FUNCTION

IF EXISTS Production.Confection2
GO
	CREATE FUNCTION Production.Confection2 (
		@SupplierName NVARCHAR(15)
		,@Categoryid NVARCHAR(15)
		)
	RETURNS NVARCHAR(60)
	AS
	BEGIN
		IF (@Categoryid = 3AND @SupplierName = 'Supplier BWGYE')
			RETURN 'This is a confection product and confection supplier #1'
		ELSE IF (@Categoryid = 3 AND @SupplierName = 'Supplier ELCRN')
			RETURN 'This is a confection product and confection supplier #3'
		ELSE IF (@Categoryid = 3 AND @SupplierName = 'Supplier FNUXM')
			RETURN 'This is a confection product and confection supplier #4'
		ELSE IF (@Categoryid = 3 AND @SupplierName = 'Supplier GQRCV')
			RETURN 'This is a confection product and confection supplier #5'
		ELSE IF (@Categoryid = 3 AND @SupplierName = 'Supplier OGLRK')
			RETURN 'This is a confection product and confection supplier #6'
		ELSE IF (@Categoryid = 3 AND @SupplierName = 'Supplier ZPYVS')
			RETURN 'This is a confection product and confection supplier #2'
		ELSE IF (@Categoryid <> 3 AND @SupplierName = 'Supplier BWGYE')
			RETURN 'This is NOT a confection product but is confection supplier #1'
		ELSE IF (@Categoryid <> 3 AND @SupplierName = 'Supplier ELCRN')
			RETURN 'This is NOT a confection product but is confection supplier #3'
		ELSE IF (@Categoryid <> 3 AND @SupplierName = 'Supplier FNUXM')
			RETURN 'This is NOT confection product but is confection supplier #4'
		ELSE IF (@Categoryid <> 3 AND @SupplierName = 'Supplier GQRCV')
			RETURN 'This is NOT confection product but is confection supplier #5'
		ELSE IF (@Categoryid <> 3 AND @SupplierName = 'Supplier OGLRK')
			RETURN 'This is NOT confection product but is confection supplier #6'
		ELSE IF (@Categoryid <> 3 AND @SupplierName = 'Supplier ZPYVS')
			RETURN 'This is NOT confection product but is confection supplier #2'
			RETURN 'This is NOT a confection product nor a confection supplier'
	END;
GO
SELECT pc.CategoryId,pc.CategoryName,pp.ProductId,ps.SupplierCompanyName,Production.Confection2(ps.SupplierCompanyName, pc.CategoryId) AS ConfectionSupplierInformation
FROM Production.Category AS pc
LEFT OUTER JOIN Production.Product AS pp ON pp.CategoryId = pc.CategoryId
LEFT OUTER JOIN Production.Supplier AS ps ON ps.SupplierId = pp.SupplierId
GROUP BY pc.CategoryId,pc.CategoryName,pp.ProductId,ps.SupplierCompanyName,Production.Confection(ps.SupplierCompanyName, pc.CategoryId)
ORDER BY ps.SupplierCompanyName
FOR JSON PATH, root('ConfectionCrazedTown - ProductAndSupplier'), include_null_values;

-- 16 3 Find all of the orders ordered by CustomerId and show the orderid included with the information of the employee 
--as well as if they are male or female or not sure(7470 rows affected)
USE Northwinds2020TSQLV6
DROP FUNCTION IF EXISTS dbo.CheckGender
GO
CREATE FUNCTION dbo.CheckGender (
		@TitleofCourtesy NVARCHAR(5)
		)
	RETURNS NVARCHAR(15)
	AS
	BEGIN
	If(@TitleofCourtesy = 'Mr.')
	RETURN 'Male'
	IF(@TitleofCourtesy = 'Mrs.' OR @TitleofCourtesy = 'Ms.')
	RETURN 'Female'
	IF(@TitleofCourtesy = 'Dr.')
	RETURN 'Not sure'
	RETURN 'Something is wrong I can feel it'
	END
	GO
SELECT hr.EmployeeId,sc.CustomerId,so.OrderId,hr.EmployeeFirstName,hr.EmployeeLastName,hr.EmployeeTitleOfCourtesy,dbo.CheckGender(hr.EmployeeTitleOfCourtesy) AS Gender
FROM Sales.[Order] AS so
INNER JOIN [HumanResources].[Employee] AS hr
ON so.EmployeeId = so.EmployeeId
INNER JOIN Sales.Customer AS sc
ON sc.CustomerId = so.CustomerId
GROUP BY hr.EmployeeId,sc.CustomerId,so.OrderId,hr.EmployeeFirstName,hr.EmployeeLastName,hr.EmployeeTitleOfCourtesy,dbo.CheckGender(hr.EmployeeTitleOfCourtesy)
ORDER BY sc.CustomerId
FOR JSON PATH, root('GenderChecker'), include_null_values;


--17 4 Where is the country located in which we have to shipto and the order date and orderid of the company that ordered within the entire year of 2016?
USE Northwinds2020TSQLV6

DROP FUNCTION
IF EXISTS dbo.CountryLocationChecker
GO
	CREATE FUNCTION dbo.CountryLocationChecker (@ShipCountry NVARCHAR(20))
	RETURNS NVARCHAR(50)
	AS
	BEGIN
		IF (
				@ShipCountry = 'Canada'
				OR @ShipCountry = 'USA'
				OR @ShipCountry = 'Mexico'
				)
			RETURN 'Country is in North America'

		ELSE IF (
				@ShipCountry = 'Argentina'
				OR @ShipCountry = 'Brazil'
				OR @ShipCountry = 'Venezuela'
				)
			RETURN 'Country is in South America'

		ELSE IF (
				@ShipCountry = 'Austria'
				OR @ShipCountry = 'Belgium'
				OR @ShipCountry = 'Denmark'
				OR @ShipCountry = 'Finland'
				OR @ShipCountry = 'France'
				OR @ShipCountry = 'Germany'
				OR @ShipCountry = 'Ireland'
				OR @ShipCountry = 'Italy'
				OR @ShipCountry = 'Norway'
				OR @ShipCountry = 'Portugal'
				OR @ShipCountry = 'Spain'
				OR @ShipCountry = 'Sweden'
				OR @ShipCountry = 'UK'
				OR @ShipCountry = 'Switzerland'
				OR @ShipCountry = 'Poland'
				)
			RETURN 'Country is in Europe'

		RETURN 'Country does not exist'
	END
GO

SELECT so.OrderId
	,sc.CustomerCompanyName
	,so.OrderDate
	,so.ShipToCountry
	,dbo.CountryLocationChecker(so.ShipToCountry) AS CountryLocated
FROM Sales.[Order] AS so
INNER JOIN [HumanResources].[Employee] AS hr ON so.EmployeeId = so.EmployeeId
INNER JOIN Sales.Customer AS sc ON sc.CustomerId = so.CustomerId
WHERE YEAR(so.OrderDate) = '2016'
GROUP BY so.OrderId
	,sc.CustomerCompanyName
	,so.OrderDate
	,so.ShipToCountry
	,dbo.CountryLocationChecker(so.ShipToCountry)
ORDER BY so.OrderDate
FOR JSON PATH, root('CountryLocationChecker'), include_null_values;

--18 5 Find the number of orders made in Decembers by the HighestLevelImportance in order by the orderdate(15 rows affected)(3 Best)
USE Northwinds2020TSQLV6

DROP FUNCTION

IF EXISTS dbo.CustomerTitleImportance 
GO
	CREATE FUNCTION dbo.CustomerTitleImportance (
	@CustomerContactTitle NVARCHAR(30))
	RETURNS NVARCHAR(40)
	AS
	BEGIN
		IF (
				@CustomerContactTitle = 'Owner'
				OR @CustomerContactTitle = 'Order Administrator'
				)
			RETURN 'Highest Level Importance'

		IF (
				@CustomerContactTitle = 'Accounting Manager'
				OR @CustomerContactTitle = 'Marketing Manager'
				OR @CustomerContactTitle = 'Sales Manager'
				)
			RETURN 'Intermediate Level Importance'

		IF (
				@CustomerContactTitle = 'Sales Associate'
				OR @CustomerContactTitle = 'Assistant Sales Agent'
				OR @CustomerContactTitle = 'Marketing Assistant'
				OR @CustomerContactTitle = 'Assistant Sales Representative'
				OR @CustomerContactTitle = 'Sales Representative'
				OR @CustomerContactTitle = 'Sales Agent'
				)
			RETURN 'Lower Level Importance'

		RETURN 'Mixed Importance'
	END
GO

SELECT so.OrderId
	,so.OrderDate
	,so.EmployeeId
	,sc.CustomerContactTitle
	,dbo.CustomerTitleImportance(sc.CustomerContactTitle) AS 'Relative Importance Level'
FROM Sales.[Order] AS so
INNER JOIN [HumanResources].[Employee] AS hr ON hr.EmployeeId = so.EmployeeId
INNER JOIN Sales.Customer AS sc ON sc.CustomerId = so.CustomerId
WHERE dbo.CustomerTitleImportance(sc.CustomerContactTitle) = 'Highest Level Importance'
	AND MONTH(so.OrderDate) = 12
GROUP BY so.OrderId
	,so.OrderDate
	,so.EmployeeId
	,sc.CustomerContactTitle
	,dbo.CustomerTitleImportance(sc.CustomerContactTitle)
ORDER BY so.OrderDate
FOR JSON PATH, root('BuyerImportanceGauger'), include_null_values;


--19 6 Return the set of letters that the first name and the last name fall into as well as the employeesID and their managersID
USE Northwinds2020TSQLV6

DROP FUNCTION

IF EXISTS dbo.AlphabetNameIdentifier 
GO
	CREATE FUNCTION dbo.AlphabetNameIdentifier (@Names NVARCHAR(20))
	RETURNS NVARCHAR(40)
	AS
	BEGIN
		IF (@Names LIKE '[ABCDEF]%')
			RETURN 'A to E'

		IF (@Names LIKE '[GHJIJKL]%')
			RETURN 'F to L'

		IF (@Names LIKE '[MNOPQR]%')
			RETURN 'M to S'

		IF (@Names LIKE '[STUVWXYZ]%')
			RETURN 'G to Z'

		RETURN 'Wrong'
	END
GO

SELECT DISTINCT e.EmployeeManagerId
	,e.EmployeeId
	,o.OrderId
	,dbo.AlphabetNameIdentifier(e.EmployeeFirstName) AS FirstName
	,dbo.AlphabetNameIdentifier(e.EmployeeLastName) AS LastName
FROM Sales.[Order] AS o
LEFT OUTER JOIN HumanResources.Employee AS e ON o.EmployeeId = e.EmployeeId
LEFT OUTER JOIN Sales.OrderDetail AS od ON o.OrderId = od.OrderId
GROUP BY e.EmployeeManagerId
	,e.EmployeeId
	,o.OrderId
	,dbo.AlphabetNameIdentifier(e.EmployeeFirstName)
	,dbo.AlphabetNameIdentifier(e.EmployeeLastName)
FOR JSON PATH, root('EmployeeNameRangeIdentifier'), include_null_values;

----20 7 Return whether or not the first character of each address is numerical 
--or alphabetical and then break the numerical into 2 halfs 1 and 2 from 0 to 9 
--and then break Alphabetical into 4 quarters for A to Z respectively 
USE Northwinds2020TSQLV6

DROP FUNCTION

IF EXISTS dbo.AddressIdentifier
GO
	CREATE FUNCTION dbo.AddressIdentifier (@ShipAddress NVARCHAR(20))
	RETURNS NVARCHAR(40)
	AS
	BEGIN
		IF (@ShipAddress LIKE '[0-5]%')
			RETURN 'Numerical Address Section 1'

		IF (@ShipAddress LIKE '[6-9]%')
			RETURN 'Numerical Address Section 2'

		IF (@ShipAddress LIKE '[A-F]%')
			RETURN 'Alphabetical Address Section 1'

		IF (@ShipAddress LIKE '[G-L]%')
			RETURN 'Alphabetical Address Section 2'

		IF (@ShipAddress LIKE '[M-R]%')
			RETURN 'Alphabetical Address Section 3'

		IF (@ShipAddress LIKE '[S-Z]%')
			RETURN 'Alphabetical Address Section 4'

		RETURN 'Out of Bounds'
	END
GO




SELECT DISTINCT o.ShipToAddress
	,e.EmployeeId
	,dbo.AddressIdentifier(o.ShipToAddress) AS AddressSpecification
FROM Sales.[Order] AS o
LEFT OUTER JOIN HumanResources.Employee AS e ON o.EmployeeId = e.EmployeeId
LEFT OUTER JOIN Sales.OrderDetail AS od ON o.OrderId = od.OrderId
GROUP BY o.ShipToAddress
	,e.EmployeeId
	,dbo.AddressIdentifier(o.ShipToAddress)
ORDER BY o.ShipToAddress
FOR JSON PATH
	,root('NumAlphaAddressSorter')
	,include_null_values;

