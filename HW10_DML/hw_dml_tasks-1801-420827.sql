/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/


SELECT CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, 
	PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, 
	AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays,
	PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode,
	PostalAddressLine1, PostalPostalCode, LastEditedBy INTO Sales.Customers_COPY
FROM Sales.Customers WHERE 1=2;

INSERT INTO  Sales.Customers(CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, 
	PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, 
	AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays,
	PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode,
	PostalAddressLine1, PostalPostalCode, LastEditedBy)
OUTPUT inserted.CustomerID, inserted.CustomerName, inserted.BillToCustomerID, inserted.CustomerCategoryID, inserted.BuyingGroupID, 
	inserted.PrimaryContactPersonID, inserted.AlternateContactPersonID, inserted.DeliveryMethodID, inserted.DeliveryCityID, inserted.PostalCityID, 
	inserted.AccountOpenedDate, inserted.StandardDiscountPercentage, inserted.IsStatementSent, inserted.IsOnCreditHold, inserted.PaymentDays,
	inserted.PhoneNumber, inserted.FaxNumber, inserted.WebsiteURL, inserted.DeliveryAddressLine1, inserted.DeliveryAddressLine2, inserted.DeliveryPostalCode,
	inserted.PostalAddressLine1, inserted.PostalPostalCode, inserted.LastEditedBy
INTO Sales.Customers_COPY(CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, 
	PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, 
	AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays,
	PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode,
	PostalAddressLine1, PostalPostalCode, LastEditedBy)
VALUES
	(NEXT VALUE FOR Sequences.CustomerID,'Tailspin Toys (Office 1, NY)', 1, 5, 1,
	 1123, 1124, 3, 13800, 13800,
     '2020-02-01', 0.0, 0, 0, 7, 
	 '(212)555-0803', '(212)555-0804', 'http://www.tailspintoys.com/Office1', 'Shop 308', '105 Fi Road', '90240',
	 'PO Box 4278', '90240', 1),
	 (NEXT VALUE FOR Sequences.CustomerID,'Tailspin Toys (Office 2, NY)', 1, 5, 1,
	 1245, 1246, 3, 29371, 29371,
     '2020-03-01', 0.0, 0, 0, 7, 
	 '(212)555-0808', '(212)555-0809', 'http://www.tailspintoys.com/Office2', 'Shop 309', '54 Ti Road', '90241',
	 'PO Box 4279', '90241', 1),
	 (NEXT VALUE FOR Sequences.CustomerID,'Tailspin Toys (Office 3, NY)', 401, 5, 2,
	 2253, 2254, 3, 16741, 16741,
     '2020-04-01', 0.0, 0, 0, 7, 
	 '(212)555-0408', '(212)555-0409', 'http://www.tailspintoys.com/Office3', 'Shop 310', '812 Re Road', '90242',
	 'PO Box 4280', '90242', 8),
	 (NEXT VALUE FOR Sequences.CustomerID,'Tailspin Toys (Office 4, NY)', 401, 5, 2,
	 2297, 2298, 3, 18446, 18446,
     '2020-05-01', 0.0, 0, 0, 7, 
	 '(212)555-1408', '(212)555-1409', 'http://www.tailspintoys.com/Office4', 'Shop 311', '390 1 Road', '90244',
	 'PO Box 4281', '90243', 8),
	 (NEXT VALUE FOR Sequences.CustomerID,'Tailspin Toys (Office 5, NY)', 401, 5, 2,
	 2349, 2350, 3, 34512, 32512,
     '2020-06-01', 0.0, 0, 0, 7, 
	 '(212)555-7408', '(212)555-7409', 'http://www.tailspintoys.com/Office5', 'Shop 312', '305 1 Road', '90243',
	 'PO Box 4282', '90244', 8);


SELECT * FROM Sales.Customers_COPY;
SELECT  * FROM Sales.Customers;

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Sales.Customers
WHERE CustomerID = 1066;


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE  Sales.Customers
SET WebsiteURL = 'http://www.tailspintoys.com/OfficeNew2'
WHERE CustomerID = 1067;

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Sales.Customers AS target 
	USING (SELECT CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, 
	PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, 
	AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays,
	PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode,
	PostalAddressLine1, PostalPostalCode, LastEditedBy
			FROM Sales.Customers_COPY
			WHERE CustomerID = 1066
			) 
			AS source (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, 
	PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, 
	AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays,
	PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode,
	PostalAddressLine1, PostalPostalCode, LastEditedBy) ON
		 (target.CustomerName = source.CustomerName) 
	WHEN MATCHED 
		THEN UPDATE SET PhoneNumber = source.PhoneNumber,
						FaxNumber = source.FaxNumber,
						WebsiteURL = source.WebsiteURL,
						DeliveryAddressLine1 = source.DeliveryAddressLine1,
						DeliveryAddressLine2 = source.DeliveryAddressLine2,
						DeliveryPostalCode = source.DeliveryPostalCode
	WHEN NOT MATCHED 
		THEN INSERT ( CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, 
	PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, 
	AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays,
	PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode,
	PostalAddressLine1, PostalPostalCode, LastEditedBy) 
			 VALUES (source. CustomerName, source.BillToCustomerID, source.CustomerCategoryID, source.BuyingGroupID, 
	source.PrimaryContactPersonID, source.AlternateContactPersonID, source.DeliveryMethodID, source.DeliveryCityID, source.PostalCityID, 
	source.AccountOpenedDate, source.StandardDiscountPercentage, source.IsStatementSent, source.IsOnCreditHold, source.PaymentDays,
	source.PhoneNumber, source.FaxNumber, source.WebsiteURL, source.DeliveryAddressLine1, source.DeliveryAddressLine2, source.DeliveryPostalCode,
	source.PostalAddressLine1, source.PostalPostalCode, source.LastEditedBy) 
		OUTPUT deleted.*, $action, inserted.*;

select * from Sales.Customers;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

EXEC sp_configure 'show advanced options', 1;  
GO  

RECONFIGURE;  
GO  

EXEC sp_configure 'xp_cmdshell', 1;  
GO  

RECONFIGURE;  
GO  

DROP TABLE IF EXISTS Sales.Customers_bcp;

SELECT * INTO Sales.Customers_bcp from Sales.Customers WHERE 1=2;

/****
exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers" out  "D:\WORKSD\bcp_file\customer1.txt" -T -w -t"@eu&$1&" -S DESKTOP-O64T8QV\MSSQLSERVER2017'

BULK INSERT [WideWorldImporters].[Sales].[Customers_bcp]
     FROM "D:\WORKSD\bcp_file\customer1.txt"
	  WITH 
		 (
			BATCHSIZE = 1000, 
			DATAFILETYPE = 'widechar',
			FIELDTERMINATOR = '@eu&$1&',
			ROWTERMINATOR ='\n',
			KEEPNULLS,
			TABLOCK        
		  );

!!! ТАК НЕ ОТРАБАТЫВАЕТ. ВОЗМОЖНО ИЗ-ЗА ТОГО ЧТО У МЕНЯ УСТАНОВЛЕН MS SQL Server и ASE Sybase (нашел такоей взгляд в интеренете)
!!! СДЕЛАЛ ТАК, КАК ДЕЛАЛ ВСЕГДА - ЧЕРЕЗ BAT. 
!!! BAT - файлы прилагаю

****/

---- OUT.BAT
---- "C:\Program Files\Microsoft SQL Server\110\Tools\Binn\bcp.exe" WideWorldImporters.Sales.Customers out  "D:\WORKSD\bcp_file\customer.txt" -w -t "@eu&$1&" -T -S DESKTOP-O64T8QV\MSSQLSERVER2017

---- IN.BAT
----"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\bcp.exe" WideWorldImporters.Sales.Customers_bcp in "D:\WORKSD\bcp_file\customer.txt" -w -t "@eu&$1&" -T -S DESKTOP-O64T8QV\MSSQLSERVER2017

SELECT * FROM Sales.Customers_bcp;



