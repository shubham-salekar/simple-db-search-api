CREATE DATABASE SimpleSearchDb;
GO

USE SimpleSearchDb;
GO

CREATE TABLE Items
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    Category NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETUTCDATE()
);
GO

USE SimpleSearchDb;
GO

SET NOCOUNT ON;

-- Clear existing data (repeatable)
TRUNCATE TABLE Items;
GO

;WITH Numbers AS
(
    SELECT TOP (500000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Items (Name, Description, Category, CreatedAt)
SELECT CONCAT('Item ', n),
    CONCAT('Description for item ', n),
    CASE 
        WHEN n % 10 = 0 THEN 'Electronics'
        WHEN n % 7 = 0 THEN 'Books'
        WHEN n % 5 = 0 THEN 'Clothing'
        WHEN n % 3 = 0 THEN 'Home'
        ELSE 'Misc'
    END,
    DATEADD(DAY, - (n % 365), GETUTCDATE())
FROM Numbers;
GO

-- For partial name search
CREATE NONCLUSTERED INDEX IX_Items_Name
ON Items (Name);

-- For category filtering
CREATE NONCLUSTERED INDEX IX_Items_Category
ON Items (Category);

-- For sorting / date filtering
CREATE NONCLUSTERED INDEX IX_Items_CreatedAt
ON Items (CreatedAt);

USE SimpleSearchDb;
GO

CREATE PROCEDURE dbo.Udsp_SearchItems
(
    @Search NVARCHAR(200) = NULL,
    @Category NVARCHAR(100) = NULL,
    @From DATETIME = NULL,
    @To DATETIME = NULL,
    @Page INT = 1,
    @PageSize INT = 10,
    @SortBy NVARCHAR(50) = 'CreatedAt',
    @Desc BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Page - 1) * @PageSize;

    SELECT Id, Name, Description, Category, CreatedAt
    FROM Items
    WHERE (@Search IS NULL OR Name LIKE '%' + @Search + '%')
      AND (@Category IS NULL OR Category = @Category)
      AND (@From IS NULL OR CreatedAt >= @From)
      AND (@To IS NULL OR CreatedAt <= @To)
    ORDER BY
        CASE WHEN @SortBy = 'CreatedAt' AND @Desc = 0 THEN CreatedAt END ASC,
        CASE WHEN @SortBy = 'CreatedAt' AND @Desc = 1 THEN CreatedAt END DESC,
        CASE WHEN @SortBy = 'Name' AND @Desc = 0 THEN Name END ASC,
        CASE WHEN @SortBy = 'Name' AND @Desc = 1 THEN Name END DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO