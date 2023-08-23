--*************************************************************************--
-- Title: Assignment07
-- Author: NUpadhyay
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2023-08-23,NUpadhyay,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_NUpadhyay')
	 Begin 
	  Alter Database [Assignment07DB_NUpadhyay] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_NUpadhyay;
	 End
	Create Database Assignment07DB_NUpadhyay;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_NUpadhyay;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

SELECT ProductName, 
       FORMAT(UnitPrice, 'C', 'en-US') AS FormattedPrice
FROM vProducts
ORDER BY ProductName;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- Assuming 'Categories' has columns 'CategoryID' and 'CategoryName'
-- and 'Products' has columns 'CategoryID', 'ProductName', and 'Price'

SELECT c.CategoryName, 
       p.ProductName, 
       UnitPrice = FORMAT(p.UnitPrice, 'C', 'en-US') 
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

SELECT p.ProductName,
       FORMAT(i.InventoryDate, 'MMMM, yyyy') AS FormattedDate,
       i.Count AS InventoryCount
FROM vProducts p
JOIN vInventories i ON p.ProductID = i.ProductID
ORDER BY p.ProductName, i.InventoryDate;
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date. (Note: The result is the same as the previous question) 

-- Drop the existing view if it exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vProductInventories')
    DROP VIEW vProductInventories;
GO

-- Create the new view without the ORDER BY clause (since ORDER BY is not allowed in view creation)
CREATE VIEW vProductInventories AS
SELECT 
    p.ProductName,
    FORMAT(i.InventoryDate, 'MMMM, yyyy') AS FormattedDate,
    i.[Count] AS InventoryCount
FROM 
    vProducts p
JOIN 
    vInventories i ON p.ProductID = i.ProductID;
GO

-- Test to fetch data from the view in the desired order:
SELECT * FROM vProductInventories
ORDER BY ProductName, FormattedDate;
GO

-- Check that it works: Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Drop the existing view if it exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vCategoryInventories')
    DROP VIEW vCategoryInventories;
GO

-- Create the new view
CREATE VIEW vCategoryInventories AS
SELECT 
    c.CategoryName,
    FORMAT(i.InventoryDate, 'MMMM, yyyy') AS FormattedDate,
    SUM(i.[Count]) AS TotalInventoryCount
FROM 
    vCategories c
JOIN 
    vProducts p ON c.CategoryID = p.CategoryID
JOIN 
    vInventories i ON p.ProductID = i.ProductID
GROUP BY 
    c.CategoryName, i.InventoryDate;
GO

-- Test to fetch data from the view in the desired order:
SELECT * FROM vCategoryInventories
ORDER BY CategoryName, FormattedDate;
GO

-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

CREATE VIEW vProductInventoriesWithPreviouMonthCounts AS
SELECT
    ProductName,
    FormattedDate,
    InventoryCount,
    CASE
        WHEN MONTH(prodInv.FormattedDate) = 1
            THEN 0 
            ELSE COALESCE(LAG(InventoryCount) OVER (PARTITION BY ProductName ORDER BY FormattedDate), 0)
    END AS PreviousMonthCount
FROM
    vProductInventories AS prodInv;
go

SELECT *
FROM vProductInventoriesWithPreviouMonthCounts
ORDER BY ProductName, FormattedDate;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs AS
SELECT
    ProductName,
    FormattedDate,
    InventoryCount,
    PreviousMonthCount,
    CASE
        WHEN InventoryCount > PreviousMonthCount THEN 1    -- If the current count is greater than the previous month
        WHEN InventoryCount = PreviousMonthCount THEN 0    -- If the counts are the same
        ELSE -1                                           -- If the current count is less than the previous month
    END AS KPI
FROM
    vProductInventoriesWithPreviouMonthCounts;

GO

SELECT * 
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
ORDER BY ProductName, FormattedDate;
GO 
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product Names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ProductName,
        FormattedDate,
        InventoryCount,
        PreviousMonthCount,
        CASE
            WHEN InventoryCount > PreviousMonthCount THEN 1    -- If the current count is greater than the previous month
            WHEN InventoryCount = PreviousMonthCount THEN 0    -- If the counts are the same
            ELSE -1                                           -- If the current count is less than the previous month
        END AS KPI
    FROM 
        vProductInventoriesWithPreviousMonthCountsWithKPIs
);

GO

SELECT * 
FROM dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs()
ORDER BY ProductName, FormattedDate;

GO


/* Check that it works:
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1) Order By 1, 2,3;

SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0) Order By 1, 2,3;

SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1) Order By 1, 2,3;


*/
go

/***************************************************************************************/