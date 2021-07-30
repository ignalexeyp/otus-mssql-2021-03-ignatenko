ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO

ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'D:\WORKSD\MSSQL2017\WideWorldImporters\Yeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO


CREATE PARTITION FUNCTION [fnYearPartition](DATETIME2) AS RANGE RIGHT FOR VALUES
('20120101','20130101','20140101','20150101','20160101', '20170101',
 '20180101', '20190101', '20200101', '20210101');																																																									
GO


CREATE PARTITION SCHEME [schmYearPartition] AS PARTITION [fnYearPartition] 
ALL TO ([YearData]);
GO


CREATE TABLE [Warehouse].[StockItemTransactionsPart](
	[StockItemTransactionID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[TransactionTypeID] [int] NOT NULL,
	[CustomerID] [int] NULL,
	[InvoiceID] [int] NULL,
	[SupplierID] [int] NULL,
	[PurchaseOrderID] [int] NULL,
	[TransactionOccurredWhen] [datetime2](7) NOT NULL,
	[Quantity] [decimal](18, 3) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
) ON [schmYearPartition]([TransactionOccurredWhen]);
GO

ALTER TABLE [Warehouse].[StockItemTransactionsPart] ADD CONSTRAINT PK_Warehouse_StockItemTransactionsPart
PRIMARY KEY CLUSTERED  (TransactionOccurredWhen, StockItemTransactionID, StockItemID)
 ON [schmYearPartition]([TransactionOccurredWhen]);


DECLARE @FirstDate DATETIME2,
        @LastDate DATETIME2 

SET @FirstDate = '20110101';
SET  @LastDate = '20120101';
 
WHILE @LastDate < '20210101'
BEGIN
BEGIN TRAN
 INSERT INTO  [Warehouse].[StockItemTransactionsPart](
	[StockItemTransactionID], [StockItemID], [TransactionTypeID], [CustomerID], [InvoiceID], [SupplierID],
	[PurchaseOrderID], [TransactionOccurredWhen], [Quantity], [LastEditedBy], [LastEditedWhen])
 SELECT [StockItemTransactionID], [StockItemID], [TransactionTypeID], [CustomerID], [InvoiceID], [SupplierID],
	[PurchaseOrderID], [TransactionOccurredWhen], [Quantity], [LastEditedBy], [LastEditedWhen]
 FROM [Warehouse].[StockItemTransactions]
 WHERE [TransactionOccurredWhen] >= @FirstDate AND  [TransactionOccurredWhen] < @LastDate; 		 

SET @FirstDate = DATEADD(YY, 1, @FirstDate);
SET @LastDate = DATEADD(YY, 1, @LastDate);

COMMIT TRAN
END

select COUNT(*) from [Warehouse].[StockItemTransactions];

select COUNT(*) from [Warehouse].[StockItemTransactionsPart];

select distinct t.name
from sys.partitions p
inner join sys.tables t
	on p.object_id = t.object_id
where p.partition_number <> 1;


SELECT  $PARTITION.fnYearPartition(TransactionOccurredWhen) AS Partition
		, COUNT(*) AS [COUNT]
		, MIN(TransactionOccurredWhen)
		,MAX(TransactionOccurredWhen) 
FROM [Warehouse].[StockItemTransactionsPart]
GROUP BY $PARTITION.fnYearPartition(TransactionOccurredWhen) 
ORDER BY Partition ;  
