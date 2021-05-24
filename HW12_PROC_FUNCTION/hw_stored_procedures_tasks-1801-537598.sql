/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ( 'Sales.fiaCustomerMaxInvoice', 'F' ) IS NOT NULL   
    DROP FUNCTION Sales.fiaCustomerMaxInvoice; 

CREATE FUNCTION Sales.fiaCustomerMaxInvoice()
RETURNS int
WITH EXECUTE AS CALLER
AS
BEGIN

   DECLARE @CustomerIdMaxInvoice int;

SET   @CustomerIdMaxInvoice =  (SELECT TOP 1 c.CustomerId
   FROM Sales.Customers c
   JOIN Sales.Invoices i ON i.CustomerID = c.CustomerID
   JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
   GROUP BY c.CustomerId, i.InvoiceID
   ORDER BY SUM(il.UnitPrice*il.Quantity) DESC);

   RETURN @CustomerIdMaxInvoice;

END;
GO

SELECT Sales.fiaCustomerMaxInvoice() AS CustomerIdMaxInvoice;

/***
   SELECT c.CustomerId, i.InvoiceID,  SUM(il.UnitPrice*il.Quantity)  AS CustInvSum
   FROM Sales.Customers c
   JOIN Sales.Invoices i ON i.CustomerID = c.CustomerID
   JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
   GROUP BY c.CustomerId, i.InvoiceID
   ORDER BY CustInvSum DESC
****/


/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

----  !!!!! ИЗ УСЛОВИЯ НЕ ЯСНО - СУММА ВСЕХ ПОКУПОК КЛИЕНТА ИЛИ СУММА ДЛЯ КАЖДОЙ ПОКУПКИ КЛИЕНТА 
----  РЕАЛИЗОВАНО ОБА ВАРИАНТА

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ( 'Sales.piaCustomerInvoice1', 'P' ) IS NOT NULL   
    DROP PROCEDURE Sales.piaCustomerInvoice1; 
GO

CREATE PROCEDURE Sales.piaCustomerInvoice1(@pСustomerID INT)
WITH EXECUTE AS CALLER
AS
BEGIN

   SET NOCOUNT ON;

   SELECT i.InvoiceID, SUM(il.UnitPrice*il.Quantity)  AS CustInvSum
   FROM Sales.Customers c
   JOIN Sales.Invoices i ON i.CustomerID = c.CustomerID
   JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
   WHERE c.CustomerID = @pСustomerID
   GROUP BY i.InvoiceID
   ORDER BY CustInvSum DESC;

END;
GO

EXEC Sales.piaCustomerInvoice1 71;
GO

IF OBJECT_ID ( 'Sales.piaCustomerInvoice2', 'P' ) IS NOT NULL   
    DROP PROCEDURE Sales.piaCustomerInvoice2; 
GO

CREATE PROCEDURE Sales.piaCustomerInvoice2(@pСustomerID INT)
WITH EXECUTE AS CALLER
AS
BEGIN

   SET NOCOUNT ON;

   SELECT SUM(il.UnitPrice*il.Quantity)  AS CustInvSum
   FROM Sales.Customers c
   JOIN Sales.Invoices i ON i.CustomerID = c.CustomerID
   JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
   WHERE c.CustomerID = @pСustomerID;
   

END;
GO

EXEC Sales.piaCustomerInvoice2 71;
GO

IF OBJECT_ID ( 'Sales.piaCustomerInvoice3', 'P' ) IS NOT NULL   
    DROP PROCEDURE Sales.piaCustomerInvoice3;
GO

----!!! В этой хранимой процедуре по другому реализован возврат значения
CREATE PROCEDURE Sales.piaCustomerInvoice3(@pСustomerID INT, @pCustInvSum decimal(18,2) OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

   SET NOCOUNT ON;

   SET @pCustInvSum = (SELECT SUM(il.UnitPrice*il.Quantity)
   FROM Sales.Customers c
   JOIN Sales.Invoices i ON i.CustomerID = c.CustomerID
   JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
   WHERE c.CustomerID = @pСustomerID);
   
END;
GO

DECLARE @vСustomerID int = 71,
        @vCustInvSum decimal(18,2);          
EXEC Sales.piaCustomerInvoice3 @vСustomerID, @vCustInvSum OUT;
SELECT @vCustInvSum;
GO


IF OBJECT_ID ( 'Sales.piaCustomerInvoice4', 'P' ) IS NOT NULL   
    DROP PROCEDURE Sales.piaCustomerInvoice4;
GO

CREATE PROCEDURE Sales.piaCustomerInvoice4(@pСustomerID INT, @pCustInvSum decimal(18,2) OUT)
WITH EXECUTE AS CALLER
AS
BEGIN

   SET NOCOUNT ON;

   SELECT @pCustInvSum = SUM(il.UnitPrice*il.Quantity)
   FROM Sales.Customers c
   JOIN Sales.Invoices i ON i.CustomerID = c.CustomerID
   JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
   WHERE c.CustomerID = @pСustomerID;
   

END;
GO


DECLARE @vСustomerID int = 71,
        @vCustInvSum decimal(18,2);          
EXEC Sales.piaCustomerInvoice4 @vСustomerID, @vCustInvSum OUT;
SELECT @vCustInvSum;
GO



/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
---- !!!!! Функция аналогичная предыдущей (Sales.piaCustomerInvoice4) хранимой процедуре

IF OBJECT_ID ( 'Sales.fiaCustomerInvoice2', 'F' ) IS NOT NULL   
    DROP FUNCTION Sales.fiaCustomerInvoice2; 
GO

CREATE FUNCTION Sales.fiaCustomerInvoice2 (@pСustomerID int)
RETURNS decimal(18,2)
WITH EXECUTE AS CALLER

AS
BEGIN
   
   DECLARE @CustSum decimal(18,2);

   SELECT @CustSum = SUM(il.UnitPrice*il.Quantity)
   FROM Sales.Customers c
   JOIN Sales.Invoices i ON i.CustomerID = c.CustomerID
   JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
   WHERE c.CustomerID = @pСustomerID;
   
   RETURN @CustSum;
END;
GO

---  !!! Вызов функции и процедуры одинаковые по используемому запросу

set statistics time, io on

SELECT  Sales.fiaCustomerInvoice2 (71) AS CustSum;

DECLARE @vCustInvSum decimal(18,2);          
EXEC Sales.piaCustomerInvoice4 71, @vCustInvSum OUT;
SELECT @vCustInvSum;

GO

------  !!! Функция выполняется быстрее. У функции более простая реализация. 


/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

/***
 Все ид и имена клиентов и их контактные телефоны,
которые покупали товар 
***/

IF OBJECT_ID ( 'Sales.fiaInvoiceLinesStock', 'F' ) IS NOT NULL   
    DROP FUNCTION Sales.fiaInvoiceLinesStock; 
GO

CREATE FUNCTION Sales.fiaInvoiceLinesStock (@pStockItemName nvarchar(100))
RETURNS TABLE AS
RETURN
(
SELECT c.CustomerID, c.CustomerName, c.PhoneNumber
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON si.StockItemID = il.StockItemID   
JOIN Sales.Invoices i ON i.InvoiceID = il.InvoiceID
JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
where si.StockItemName = @pStockItemName
);
GO

SELECT * FROM Sales.fiaInvoiceLinesStock  (N'DBA joke mug - it depends (White)');

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/

---!!! В процедурах и функция я бы использовал уровень изоляции READ COMMITTED (по умолчанию в MS SQL Server).
--- Процедуры м функции выполняются быстро. Модификации данных отсутствуют.