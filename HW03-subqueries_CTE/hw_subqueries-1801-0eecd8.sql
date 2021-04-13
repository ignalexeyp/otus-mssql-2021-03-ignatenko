/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT p.PersonID, p.FullName
FROM Application.People p
WHERE p.IsSalesperson = 1
AND NOT EXISTS (SELECT 1 FROM Sales.Invoices i WHERE i.SalespersonPersonID = p.PersonID AND  i.InvoiceDate = '20150704');

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

/**!!!! Т.К. УТОЧНЕНИЯ НЕТ, СЧИТАЕМ ЦЕНУ ТОВАРА НА СКЛАДЕ***********/

SELECT si.StockItemID, si.StockItemName, si.UnitPrice
FROM Warehouse.StockItems si
WHERE si.UnitPrice = (SELECT MIN(UnitPrice) FROM Warehouse.StockItems);

SELECT si.StockItemID, si.StockItemName, si.UnitPrice
FROM Warehouse.StockItems si
WHERE si.UnitPrice IN (SELECT MIN(UnitPrice) FROM Warehouse.StockItems);

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

SELECT * FROM Application.TransactionTypes;
/***
1	Customer Invoice	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
2	Customer Credit Note	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
3	Customer Payment Received	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
4	Customer Refund	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
5	Supplier Invoice	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
6	Supplier Credit Note	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
7	Supplier Payment Issued	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
8	Supplier Refund	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
9	Stock Transfer	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
10	Stock Issue	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
11	Stock Receipt	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
12	Stock Adjustment at Stocktake	1	2013-01-01 00:00:00.0000000	9999-12-31 23:59:59.9999999
13	Customer Contra	9	2016-01-01 16:05:00.0000000	9999-12-31 23:59:59.9999999
****/

/**** В запросе используем 3	Customer Payment Received  TransactionTypeID = 3  **/

SELECT TOP 5 ct.TransactionAmount FROM Sales.CustomerTransactions ct WHERE ct.TransactionTypeID IN (3) ORDER BY ct.TransactionAmount DESC;
/***
-13.80
-14.95
-14.95
-14.95
-14.95
Суммы в проводке со знаком "-". Нужно брать порядок ASC
***/
SELECT TOP 5 ct.TransactionAmount FROM Sales.CustomerTransactions ct WHERE ct.TransactionTypeID IN (3) ORDER BY ct.TransactionAmount ASC;
/****
-169387.42
-158226.74
-152416.47
-150095.64
-146661.00
****/

---- SELECT * FROM Sales.CustomerTransactions WHERE TransactionAmount <= -146661.00 

SELECT DISTINCT c.CustomerID, c.CustomerName 
FROM Sales.Customers c
JOIN Sales.CustomerTransactions t ON t.CustomerID = c.CustomerID
WHERE t.TransactionAmount IN (SELECT TOP 5 ct.TransactionAmount FROM Sales.CustomerTransactions ct WHERE ct.TransactionTypeID IN (3) ORDER BY ct.TransactionAmount ASC);   

SELECT DISTINCT  c.CustomerID, c.CustomerName 
FROM Sales.Customers c
JOIN Sales.CustomerTransactions t ON t.CustomerID = c.CustomerID
WHERE t.TransactionAmount <= ANY (SELECT TOP 5 ct.TransactionAmount FROM Sales.CustomerTransactions ct WHERE ct.TransactionTypeID IN (3) ORDER BY ct.TransactionAmount ASC);   


SELECT DISTINCT  c.CustomerID, c.CustomerName 
FROM Sales.Customers c
JOIN  (SELECT TOP 5 ct.CustomerID,  ct.TransactionAmount FROM Sales.CustomerTransactions ct WHERE ct.TransactionTypeID IN (3) ORDER BY ct.TransactionAmount ASC) AS ct
ON ct.CustomerID = c.CustomerID;   


WITH CustomerTransactionsCTE AS
(
SELECT TOP 5 ct.CustomerID,  ct.TransactionAmount FROM Sales.CustomerTransactions ct
WHERE ct.TransactionTypeID IN (3) ORDER BY ct.TransactionAmount ASC
)
SELECT DISTINCT c.CustomerID, c.CustomerName 
FROM Sales.Customers c
JOIN CustomerTransactionsCTE AS ct ON c.CustomerID = ct.CustomerID;


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

/********ТРИ ВИДА ЗАПРОСА*******/

SELECT DISTINCT c.DeliveryCityID, ci.CityName, p.FullName as PackedName
FROM Sales.Invoices i 
JOIN (SELECT DISTINCT il.InvoiceID FROM Sales.InvoiceLines il
JOIN (SELECT TOP 3 StockItemID FROM Warehouse.StockItems  ORDER BY UnitPrice DESC) AS si
ON il.StockItemID = si.StockItemID) AS di
ON di.InvoiceID =	i.InvoiceID
JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
JOIN Application.Cities ci ON ci.CityID = c.DeliveryCityID
JOIN Application.People p ON p.PersonID = i.PackedByPersonID;

SELECT DISTINCT c.DeliveryCityID, ci.CityName, p.FullName as PackedName
FROM Sales.Invoices i 
JOIN (SELECT DISTINCT il.InvoiceID FROM Sales.InvoiceLines il WHERE il.StockItemID IN 
(SELECT TOP 3 StockItemID FROM Warehouse.StockItems  ORDER BY UnitPrice DESC)) AS di
ON di.InvoiceID = i.InvoiceID
JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
JOIN Application.Cities ci ON ci.CityID = c.DeliveryCityID
JOIN Application.People p ON p.PersonID = i.PackedByPersonID;

WITH InvoicesStockMax(InvoiceID) AS
(SELECT DISTINCT il.InvoiceID FROM Sales.InvoiceLines il WHERE il.StockItemID IN 
(SELECT TOP 3 StockItemID FROM Warehouse.StockItems  ORDER BY UnitPrice DESC))
SELECT DISTINCT c.DeliveryCityID, ci.CityName, p.FullName as PackedName
FROM Sales.Invoices i 
JOIN InvoicesStockMax di
ON di.InvoiceID = i.InvoiceID
JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
JOIN Application.Cities ci ON ci.CityID = c.DeliveryCityID
JOIN Application.People p ON p.PersonID = i.PackedByPersonID;


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

/*****Выполнять два запроса одновременно для оценки статистики****************************/

SET STATISTICS IO, TIME ON;

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;

-- --
/***
 Запрос выбирает ID продажи, дату продажи, имя продажника, сумму по продажам более 27000, сумму по заказу, соответствующему 
 продаже для которого дата завершения сбора не NULL. Сортировка по сумме продажи от большего к меньшему.    
***/

/********Запрос с CTE для улучшения читаемости***********/

WITH SumInvoiceCTE AS 
(
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000
)	
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	sm.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN   SumInvoiceCTE sm
		ON Invoices.InvoiceID = sm.InvoiceID
ORDER BY TotalSumm DESC;

SET STATISTICS IO, TIME OFF;

/*****************************************************************************/

SET STATISTICS IO, TIME ON;

WITH SumInvoiceCTE AS 
(
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000
)	
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
    p.FullName AS SalesPersonName,
	sm.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN  SumInvoiceCTE sm ON Invoices.InvoiceID = sm.InvoiceID
	JOIN  Application.People p ON p.PersonID = Invoices.SalespersonPersonID
ORDER BY TotalSumm DESC;

SET STATISTICS IO, TIME OFF;

/*****Затраты практически такие же*****/