SELECT *
FROM [Project Portfolio]..[Online Retail Data Set]

-- Converting Date
SELECT InvoiceDate, CONVERT(DATE, InvoiceDate) InvoiceDateConverted
FROM [Project Portfolio]..[Online Retail Data Set]

ALTER TABLE [Project Portfolio]..[Online Retail Data Set]
ADD InvoiceDateConverted DATE

UPDATE [Project Portfolio]..[Online Retail Data Set]
SET InvoiceDateConverted = CONVERT(DATE, InvoiceDate)

-- Splitting Date to Year, Month, and Month columns
SELECT PARSENAME(REPLACE(InvoiceDateConverted, '-','.'),3) InvoiceDateYear, PARSENAME(REPLACE(InvoiceDateConverted, '-','.'),2) InvoiceDateMonth,
		PARSENAME(REPLACE(InvoiceDateConverted, '-','.'),1) InvoiceDateDay
FROM [Project Portfolio]..[Online Retail Data Set]

ALTER TABLE [Project Portfolio]..[Online Retail Data Set]
ADD InvoiceDateYear INT

UPDATE [Project Portfolio]..[Online Retail Data Set]
SET InvoiceDateYear = PARSENAME(REPLACE(InvoiceDateConverted, '-','.'),3)

ALTER TABLE [Project Portfolio]..[Online Retail Data Set]
ADD InvoiceDateMonth INT

UPDATE [Project Portfolio]..[Online Retail Data Set]
SET InvoiceDateMonth = PARSENAME(REPLACE(InvoiceDateConverted, '-','.'),2)

ALTER TABLE [Project Portfolio]..[Online Retail Data Set]
ADD InvoiceDateDay INT

UPDATE [Project Portfolio]..[Online Retail Data Set]
SET InvoiceDateDay = PARSENAME(REPLACE(InvoiceDateConverted, '-','.'),1)

-- Filling Null Values in Description 
SELECT *
FROM [Project Portfolio]..[Online Retail Data Set]
WHERE Description IS NULL

SELECT a.StockCode, a.Description, b.StockCode, b.Description, ISNULL(a.Description, b.Description)
FROM [Project Portfolio]..[Online Retail Data Set] a
JOIN [Project Portfolio]..[Online Retail Data Set] b ON b.StockCode = a.StockCode AND
		b.InvoiceNo <> a.InvoiceNo
WHERE a.Description IS NULL

UPDATE a
SET Description = ISNULL(a.Description, b.Description)
FROM [Project Portfolio]..[Online Retail Data Set] a
JOIN [Project Portfolio]..[Online Retail Data Set] b ON b.StockCode = a.StockCode AND
		b.InvoiceNo <> a.InvoiceNo
WHERE a.Description IS NULL

-- Deleting All Quantity at least below 0
SELECT *
FROM [Project Portfolio]..[Online Retail Data Set]
WHERE Quantity <=0

DELETE FROM [Project Portfolio]..[Online Retail Data Set]
WHERE Quantity <=0

SELECT *
FROM [Project Portfolio]..[Online Retail Data Set]
WHERE UnitPrice <=0

SELECT Description, COUNT(*) CountDescription
FROM [Project Portfolio]..[Online Retail Data Set]
GROUP BY Description
ORDER BY CountDescription Desc

-- Adding Sales Column
SELECT Quantity, UnitPrice, (Quantity * ROUND(UnitPrice,2)) Sales
FROM [Project Portfolio]..[Online Retail Data Set]

ALTER TABLE [Project Portfolio]..[Online Retail Data Set]
ADD Sales FLOAT

UPDATE [Project Portfolio]..[Online Retail Data Set]
SET Sales = ROUND((Quantity * UnitPrice),2)

SELECT *
FROM [Project Portfolio]..[Online Retail Data Set]

-- Top 10 Countries according to Sales
SELECT TOP 10 Country, ROUND(SUM(Sales),2) TotalSales
FROM [Project Portfolio]..[Online Retail Data Set]
GROUP BY Country
ORDER BY TotalSales DESC

-- Displays Top 10 CustomerID and their Country according to Sales
SELECT TOP 10 CustomerID, Country, ROUND(SUM(Sales),2) TotalSales
FROM [Project Portfolio]..[Online Retail Data Set]
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID, Country
ORDER BY TotalSales DESC

-- Displays Yearly Sales
SELECT InvoiceDateYear, ROUND(SUM(Sales),2) TotalSales
FROM [Project Portfolio]..[Online Retail Data Set]
GROUP BY InvoiceDateYear
ORDER BY TotalSales DESC

-- Displays Monthly Sales in the Year 2011
SELECT InvoiceDateMonth, ROUND(SUM(Sales),2) TotalSales
FROM [Project Portfolio]..[Online Retail Data Set]
WHERE InvoiceDateYear = 2011
GROUP BY InvoiceDateMonth
ORDER BY TotalSales DESC

-- Adding Quarter Column
SELECT InvoiceDateMonth, (CASE WHEN InvoiceDateMonth <= 3 THEN 1
								WHEN InvoiceDateMonth <= 6 THEN 2
								WHEN InvoiceDateMonth <= 9 THEN 3
								WHEN InvoiceDateMonth <= 12 THEN 4
								ELSE InvoiceDateMonth
							END) Quarters
FROM [Project Portfolio]..[Online Retail Data Set]
GROUP BY InvoiceDateMonth
ORDER BY InvoiceDateMonth

ALTER TABLE [Project Portfolio]..[Online Retail Data Set]
ADD Quarters INT

UPDATE [Project Portfolio]..[Online Retail Data Set]
SET Quarters = CASE WHEN InvoiceDateMonth <= 3 THEN 1
								WHEN InvoiceDateMonth <= 6 THEN 2
								WHEN InvoiceDateMonth <= 9 THEN 3
								WHEN InvoiceDateMonth <= 12 THEN 4
								ELSE InvoiceDateMonth
							END

-- Quarter ranked according to Sales
SELECT Quarters, ROUND(SUM(Sales),2) TotalSales
FROM [Project Portfolio]..[Online Retail Data Set]
GROUP BY Quarters
ORDER BY TotalSales DESC

-- Displays Total Sales and Top 10 Products in Sales that contributed per Quarter
WITH QuarterTotalSales AS (SELECT Quarters, ROUND(SUM(Sales), 2) TotalSales
    FROM [Project Portfolio]..[Online Retail Data Set]
    GROUP BY Quarters
),
TopProductsPerQuarter AS (SELECT q.Quarters, p.Description, ROUND(SUM(p.Sales), 2) ProductSales,
						RANK() OVER (PARTITION BY q.Quarters ORDER BY ROUND(SUM(p.Sales),2) DESC) AS SalesRank
    FROM [Project Portfolio]..[Online Retail Data Set] p
    JOIN QuarterTotalSales q ON p.Quarters = q.Quarters
    GROUP BY q.Quarters, p.Description
)
SELECT t.Quarters,t.Description, t.ProductSales, q.TotalSales
FROM TopProductsPerQuarter t
JOIN QuarterTotalSales q ON t.Quarters = q.Quarters
WHERE t.SalesRank <= 10
ORDER BY t.Quarters DESC, t.SalesRank;

-- Displays Total Sales on the Month of December in the Year 2010 and 2011
With TotalSales2011 AS (SELECT InvoiceDateMonth, (ROUND(SUM(Sales),2)) TotalSales2011
FROM [Project Portfolio]..[Online Retail Data Set]
WHERE InvoiceDateYear = 2011
GROUP BY InvoiceDateMonth),
	TotalSales2010 AS(SELECT InvoiceDateMonth, (ROUND(SUM(Sales),2)) TotalSales2010
		FROM [Project Portfolio]..[Online Retail Data Set]
		WHERE InvoiceDateYear = 2010
		GROUP BY InvoiceDateMonth)
SELECT a.InvoiceDateMonth, a.TotalSales2010, b.TotalSales2011
FROM TotalSales2010 a
JOIN TotalSales2011 b ON b.InvoiceDateMonth = a.InvoiceDateMonth

-- Displays the Top Customer and their Sales for each of the Top 10 Countries by Sales
WITH Top10Countries AS (SELECT TOP 10 Country, ROUND(SUM(Sales),2) CountrySales
	FROM [Project Portfolio]..[Online Retail Data Set]
	GROUP BY Country
	ORDER BY CountrySales DESC),
	TopCustomers AS (
		SELECT c.Country, c.CustomerID TopCustomer, ROUND(SUM(c.Sales),2) CustomerAmount,
			ROW_NUMBER() OVER (PARTITION BY c.Country ORDER BY ROUND(SUM(c.Sales),2) DESC) CustomerRank
		FROM [Project Portfolio]..[Online Retail Data Set] c
		JOIN Top10Countries tc ON tc.Country = c.Country
		WHERE c.CustomerID IS NOT NULL
		GROUP BY c.Country, c.CustomerID)
SELECT t.Country, t.TopCustomer, t.CustomerAmount, tc.CountrySales
FROM TopCustomers t
JOIN Top10Countries tc ON tc.Country = t.Country
WHERE t.CustomerRank = 1
ORDER BY tc.CountrySales DESC

-- Displays Top Customers and their Sales contribution per Quarter
WITH QuarterSales AS(SELECT Quarters, ROUND(SUM(Sales),2) QuarterSales
	FROM [Project Portfolio]..[Online Retail Data Set]
	GROUP BY Quarters),
	TopCustomerQuarter AS(SELECT tc.Quarters, tc.Country, tc.CustomerID, ROUND(SUM(Sales),2) TotalSales,
						ROW_NUMBER() OVER (PARTITION BY tc.Quarters ORDER BY ROUND(SUM(tc.Sales),2) DESC) CustomerRank
		FROM [Project Portfolio]..[Online Retail Data Set] tc
		JOIN QuarterSales q ON q.Quarters = tc.Quarters
		WHERE CustomerID IS NOT NULL
		GROUP BY tc.Quarters, tc.Country, tc.CustomerID )
SELECT tc.Quarters, tc.CustomerID, tc.Country, tc.TotalSales, q.QuarterSales
FROM TopCustomerQuarter tc
JOIN QuarterSales q ON q.Quarters = tc.Quarters
WHERE CustomerRank = 1
ORDER BY QuarterSales DESC

SELECT *
FROM [Project Portfolio]..[Online Retail Data Set]