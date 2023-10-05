USE CompAccInc_DWTeamBryan;


-- Query 1: Top 5 employee --
SELECT
    e.First_Name + ' ' + e.Last_Name AS Staff_Name,
    SUM(sf.Unit_Price * sf.Quantity) AS Total_Sales_Amount,
    CAST((SUM(sf.Unit_Price * sf.Quantity) * 100.0 / t.Total_Sales) AS DECIMAL(7,2)) AS Percentage_of_Total_Sales
FROM
    Sales_Fact sf
    INNER JOIN Employees_DIM e ON sf.Employee_ID = e.Employee_ID
    CROSS JOIN (
        SELECT SUM(sf2.Unit_Price * sf2.Quantity) AS Total_Sales
        FROM Sales_Fact sf2
    ) t
GROUP BY
    e.First_Name,
    e.Last_Name,
    t.Total_Sales
ORDER BY
    Total_Sales_Amount DESC
OFFSET 0 ROWS
FETCH NEXT 5 ROWS ONLY;



-- Query 2 --
SELECT
    Sales_Year,
	Total_Yearly_Earnings,
    Best_Sales_Month,
    Best_Month_Sales_Amount,
    Worst_Sales_Month,
    Worst_Month_Sales_Amount
    
FROM (
    SELECT
        Sales_Year,
		SUM(Monthly_Sales_Amount) AS Total_Yearly_Earnings,
        MAX(CASE WHEN Monthly_Sales_Amount = MaxSalesAmount THEN DateName(month , DateAdd( month , Sales_Month , 0 ) - 1 ) END) AS Best_Sales_Month,
        MAX(Monthly_Sales_Amount) AS Best_Month_Sales_Amount,
        MAX(CASE WHEN Monthly_Sales_Amount = MinSalesAmount THEN DateName(month , DateAdd( month , Sales_Month , 0 ) - 1 ) END) AS Worst_Sales_Month,
        MIN(Monthly_Sales_Amount) AS Worst_Month_Sales_Amount
    FROM (
        SELECT
            YEAR(t.Date) AS Sales_Year,
            MONTH(t.Date) AS Sales_Month,
            SUM(sf.Unit_Price * sf.Quantity) AS Monthly_Sales_Amount,
            MAX(SUM(sf.Unit_Price * sf.Quantity)) OVER (PARTITION BY YEAR(t.Date)) AS MaxSalesAmount,
            MIN(SUM(sf.Unit_Price * sf.Quantity)) OVER (PARTITION BY YEAR(t.Date)) AS MinSalesAmount
        FROM
            Sales_Fact sf
            INNER JOIN Time_DIM t ON sf.Time_ID = t.Time_ID
        GROUP BY
            YEAR(t.Date), MONTH(t.Date)
    ) AS MonthlySales
    GROUP BY
        Sales_Year
) AS YearlySales
ORDER BY
    Sales_Year;


-- Query 3 --
SELECT
    p.Product_Name,
    COUNT(DISTINCT sf.Order_ID) AS Total_Orders,
    SUM(sf.Quantity) AS Total_Quantity,
    SUM(sf.Unit_Price * sf.Quantity) AS Total_Sales_Amount,
    SUM(sf.Unit_Price * sf.Quantity) / SUM(sf.Quantity) AS Price_Per_Item
FROM
    Sales_Fact sf
    INNER JOIN Products_DIM p ON sf.Product_ID = p.Product_ID
    INNER JOIN Orders_DIM o ON sf.Order_ID = o.Order_ID
GROUP BY
    p.Product_Name
ORDER BY
    Total_Sales_Amount DESC;

-- Query 4 --
SELECT
    c.CustName AS Customer_Name,
    p.Product_Name,
    COUNT(DISTINCT sf.Order_ID) AS Total_Orders,
    SUM(sf.Quantity) AS Total_Quantity,
    SUM(sf.Unit_Price * sf.Quantity) AS Total_Sales_Amount
FROM
    Sales_Fact sf
    INNER JOIN Customers_DIM c ON sf.Customer_ID = c.Customer_ID
    INNER JOIN Products_DIM p ON sf.Product_ID = p.Product_ID
GROUP BY
    c.CustName,
    p.Product_Name
ORDER BY
    Total_Sales_Amount DESC;

-- Query 5 --

-- V1
SELECT
    Year,
    Quarter,
    Product_Name,
    Stocks,
    TotalSales - LAG(TotalSales, 1, 0) OVER (PARTITION BY Product_Name ORDER BY Date) AS 'Sales Trend',
    TotalSales AS 'Total Sales',
    Selling_Price AS 'Selling Price',
    Cost_Price AS 'Cost Price',
    Profit
FROM
    (
        SELECT
            t.Year,
            t.Quarter,
            p.Product_Name,
            s.Stocks,
            sf.Quantity AS TotalSales,
            sf.Unit_Price AS Selling_Price,
            sf.Standard_Cost AS Cost_Price,
            (sf.Unit_Price * SUM(sf.Quantity) OVER (PARTITION BY p.Product_ID, t.Year, t.Quarter)) - (sf.Standard_Cost * s.Stocks) AS Profit,
            t.Date
        FROM
            Products_DIM p
        INNER JOIN
            Stocks s ON p.Product_ID = s.Product_ID
        INNER JOIN
            Sales_Fact sf ON p.Product_ID = sf.Product_ID
        INNER JOIN
            Time_DIM t ON sf.Time_ID = t.Time_ID
    ) AS ProfitInfo
ORDER BY
    Product_Name, Year, Quarter;

-- V2
WITH ProfitInfo AS (
    SELECT
        t.Year,
        t.Quarter,
        p.Product_Name,
        s.Stocks,
        sf.Quantity AS TotalSales,
        sf.Unit_Price AS Selling_Price,
        sf.Standard_Cost AS Cost_Price,
        (sf.Unit_Price * sf.Quantity) - (sf.Standard_Cost * s.Stocks) AS Profit,
        t.Date,
        ROW_NUMBER() OVER (PARTITION BY p.Product_ID ORDER BY t.Date) AS RowNum
    FROM
        Products_DIM p
    INNER JOIN
        Stocks s ON p.Product_ID = s.Product_ID
    INNER JOIN
        Sales_Fact sf ON p.Product_ID = sf.Product_ID
    INNER JOIN
        Time_DIM t ON sf.Time_ID = t.Time_ID
)
SELECT
    Year,
    Quarter,
    Product_Name,
    Stocks,
    TotalSales - LAG(TotalSales, 1, 0) OVER (PARTITION BY Product_Name ORDER BY Date) AS 'Sales Trend',
    TotalSales AS 'Total Sales',
    Selling_Price AS 'Selling Price',
    Cost_Price AS 'Cost Price',
    Profit
FROM
    ProfitInfo
WHERE
    Product_Name IN (
        SELECT TOP 5 Product_Name
        FROM ProfitInfo
        WHERE RowNum > 1 -- Excluding the first row to calculate the sales trend correctly
        GROUP BY Product_Name
        ORDER BY SUM(Profit) DESC
    )
ORDER BY
    Product_Name, Year, Quarter;

