SELECT * FROM super_store.super_store;

-- 1. Find the Total_Sales , Total_Profit  AND the Average_Sales , Average_Profit By Year:

SELECT 
  SUBSTRING(Order_Date, 7, 4) AS Year,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit,
  ROUND(AVG(Sales), 2) AS Average_Sales,
  ROUND(AVG(Profit), 2) AS Average_Profit
FROM 
	super_store
GROUP BY Year
ORDER BY Year DESC;

-- 2. Find the month with the highest Sales and Profit:
SELECT 
	SUBSTRING(Order_Date, 4, 2) AS Month, 
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM super_store 
GROUP BY Month 
ORDER BY Total_Sales DESC;

-- 3. Find the Quarterly sales:
SELECT 
    CONCAT('Q', QUARTER(Order_Date)) AS Quarter,
    ROUND(SUM(Sales), 2) AS Quarterly_Sales
FROM super_store
GROUP BY Quarter
ORDER BY Quarter DESC;

-- 4. Find the percentage of total sales for each category :

WITH CategorySales AS (
    SELECT Category, ROUND(SUM(Sales), 2) AS Total_Sales
    FROM super_store
    GROUP BY Category)
SELECT Category, Total_Sales, 
       (Total_Sales / SUM(Total_Sales) OVER ()) * 100 AS Sales_Percentage
FROM CategorySales;  

  -- 5. Find the total profit by category:

WITH CategoryProfits AS (
    SELECT Category, SUM(Profit) AS Total_Profit
    FROM super_store
    GROUP BY Category)
SELECT * FROM CategoryProfits;

-- 6. Find segment-wise counts of orders, average discount, total sales, and average profit.

SELECT
  Segment,
  ROUND(COUNT(Order_ID), 3) AS OrderCount, 
  ROUND(AVG(Discount), 3) AS AvgDiscount, 
  ROUND(SUM(Sales), 3) AS TotalSales, 
  ROUND(AVG(Profit), 3) AS AvgProfit
FROM super_store
GROUP BY Segment;

-- 7. Find the Frequency of each shipping mode:

SELECT Ship_Mode, COUNT(*) AS Frequency 
FROM super_store 
GROUP BY Ship_Mode 
ORDER BY Frequency DESC;

-- 7(1). Identify the most common shipping mode:

SELECT Ship_Mode, COUNT(*) AS ShipModeCount 
FROM super_store 
GROUP BY Ship_Mode 
ORDER BY ShipModeCount DESC LIMIT 1;

-- 8. Find the average profit for each shipping mode:

SELECT
    Ship_Mode,
    AVG(Profit) AS Average_Profit
FROM
    super_store
GROUP BY
    Ship_Mode;

-- 9. Find the top 10 customers ranked by sales and having the highest profit:

SELECT Customer_Name, SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit
FROM super_store
GROUP BY Customer_Name
ORDER BY TotalSales DESC, TotalProfit DESC
LIMIT 10;

-- 10. Find the top 3 cities with the highest average sales, average profit, and average profit percentage:

SELECT City,
       ROUND(AVG(Sales), 2) AS Avg_Sales,
       ROUND(AVG(Profit), 2) AS Avg_Profit,
       ROUND((AVG(Profit) / AVG(Sales)) * 100, 2) AS Avg_Profit_Percentage
FROM super_store
GROUP BY City
ORDER BY Avg_Sales DESC, Avg_Profit DESC
LIMIT 3;

-- 11. Find the customer who made the most orders:

SELECT Customer_Name, COUNT(DISTINCT Order_ID) AS OrderCount 
FROM super_store 
GROUP BY Customer_Name 
ORDER BY OrderCount DESC LIMIT 1;

-- 11(1). Find the order with the highest profit:

SELECT * 
FROM super_store 
WHERE Profit = (SELECT MAX(Profit) FROM super_store);

-- 12. Find the customer with the highest number of orders along with the total sales and total profit:
SELECT Customer_ID, CUSTOMER_NAME, COUNT(Order_ID) AS OrderCount, SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit
FROM super_store
GROUP BY Customer_ID, CUSTOMER_NAME
ORDER BY OrderCount DESC
LIMIT 1;

-- 13. Find Category-wise counts of orders, average discount, total sales, and average profit.

SELECT 
	Category, 
	ROUND(COUNT(Order_ID), 2) AS OrderCount, 
	ROUND(AVG(Discount), 2) AS AvgDiscount, 
	ROUND(SUM(Sales), 2) AS TotalSales, 
	ROUND(AVG(Profit), 2) AS AvgProfit 
FROM super_store 
GROUP BY Category;

-- 14. Find the Sub-category-wise highest profit, sales, and quantity Sold (ordered by highest profit):

SELECT Sub_Category,
       MAX(Profit) AS HighestProfit,
       MAX(Sales) AS Sales,
       MAX(Quantity) AS QuantitySold
FROM super_store
GROUP BY Sub_Category
ORDER BY HighestProfit DESC;

-- 15. Find the yearly average sales growth rate based on the order date
SELECT
    Year,
    AVG(Growth_Rate) AS Average_Growth_Rate
FROM (
    SELECT
        EXTRACT(YEAR FROM STR_TO_DATE(ORDER_DATE, '%d-%m-%y')) AS Year,
        (SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY MIN(ORDER_DATE))) / LAG(SUM(Sales)) OVER (ORDER BY MIN(ORDER_DATE)) * 100 AS Growth_Rate
    FROM
        super_store
    GROUP BY
        Year
) AS GrowthRates
GROUP BY
    Year
ORDER BY
    Year;
    
-- 16. Identify the correlation between discount and profit:

SELECT
    AVG(Discount) AS Average_Discount,
    AVG(Profit) AS Average_Profit,
    (SUM(Discount * Profit) - SUM(Discount) * SUM(Profit) / COUNT(*)) / 
    SQRT((SUM(Discount * Discount) - POW(SUM(Discount), 2) / COUNT(*)) *
    (SUM(Profit * Profit) - POW(SUM(Profit), 2) / COUNT(*))) AS Correlation
FROM
    super_store;
    
-- 17. Identify the top 5 customers who have made purchases in multiple product categories and regions, along with the total sales for each:
    SELECT
    Customer_Name,
    COUNT(DISTINCT Category) AS UniqueCategories,
    COUNT(DISTINCT Region) AS UniqueRegions,
    SUM(Sales) AS TotalSales
FROM
    super_store
GROUP BY
    Customer_Name
HAVING
    UniqueCategories > 1 AND UniqueRegions > 1
ORDER BY
    TotalSales DESC
LIMIT 5;

-- 18. Find the average profit margin for each product category and sub-category.
SELECT
    Category,
    Sub_Category,
    AVG((Profit / Sales) * 100) AS AvgProfitMargin
FROM
    super_store
WHERE
    Quantity > (SELECT AVG(Quantity) FROM super_store)
GROUP BY
    Category, Sub_Category
ORDER BY
    AvgProfitMargin DESC;

-- 19. Identify the months with the highest and lowest total sales, including the percentage change compared to the previous month:
WITH MonthlySales AS (
    SELECT
        EXTRACT(MONTH FROM Order_Date) AS OrderMonth,
        SUM(Sales) AS TotalSales
    FROM
        super_store
    GROUP BY
        OrderMonth)
SELECT
    MS.OrderMonth,
    MS.TotalSales,
    ((MS.TotalSales - LAG(MS.TotalSales) OVER (ORDER BY MS.OrderMonth)) / LAG(MS.TotalSales) OVER (ORDER BY MS.OrderMonth)) * 100 AS SalesChangePercentage
FROM
    MonthlySales MS
WHERE
    MS.TotalSales = (SELECT MAX(TotalSales) FROM MonthlySales)
    OR MS.TotalSales = (SELECT MIN(TotalSales) FROM MonthlySales);
    
-- 20. Identifies customers with the highest total spending, along with the corresponding category of maximum spending.
WITH CustomerSpending AS (
    SELECT
        Customer_ID,
        Customer_Name,
        SUM(Sales) AS TotalSpending
    FROM super_store
    GROUP BY Customer_ID, Customer_Name)
SELECT
    CS.Customer_ID,
    CS.Customer_Name,
    CS.TotalSpending,
    CT.MaxCategory AS MaxSpendingCategory
FROM
    CustomerSpending CS
JOIN (
    SELECT
        CS.Customer_ID,
        CS.Customer_Name,
        CT.Category AS MaxCategory,
        ROW_NUMBER() OVER (PARTITION BY CS.Customer_ID ORDER BY SUM(CT.Sales) DESC) AS MaxCategoryRank
    FROM
        CustomerSpending CS
    JOIN
        super_store CT ON CS.Customer_ID = CT.Customer_ID
    GROUP BY
        CS.Customer_ID, CS.Customer_Name, CT.Category
) CT ON CS.Customer_ID = CT.Customer_ID
WHERE
    CT.MaxCategoryRank = 1
ORDER BY
    CS.TotalSpending DESC
LIMIT 5;
