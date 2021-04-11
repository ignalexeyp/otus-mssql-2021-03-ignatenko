/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID, StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%';

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT s.SupplierID, s.SupplierName
FROM Purchasing.Suppliers s  
LEFT JOIN Purchasing.PurchaseOrders o ON  o.SupplierID = s.SupplierID
group by s.SupplierID, s.SupplierName
having count(o.PurchaseOrderID) = 0;


SELECT s.SupplierID, s.SupplierName
FROM Purchasing.Suppliers s  
where not exists(select 1 from Purchasing.PurchaseOrders o where o.SupplierID = s.SupplierID);

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
/*
!!!! Не совсем ясно по условию - цена товара (UnitPrice)и количеством единиц (Quantity) для всего заказа 
или для любого товара. Запросы ниже для всего заказа
*/
----- Написал два запроса. Стоймость второго немного лучше.

SELECT o.OrderID, convert(nvarchar(16), o.OrderDate, 104) AS OrderDate, datename(mm, o.OrderDate) AS OrderMonth, datename(qq, o.OrderDate) AS OrderQuarter,
CASE
    WHEN datepart(mm, o.OrderDate) BETWEEN 1 AND 4 THEN 1
    WHEN datepart(mm, o.OrderDate) BETWEEN 5 AND 8 THEN 2
	ELSE 3 
END AS ThirdYear,
c.CustomerName
FROM Sales.Orders o
JOIN Sales.OrderLines ol ON ol.OrderID = o.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
WHERE o.PickingCompletedWhen IS NOT NULL
GROUP BY o.OrderID, o.OrderDate, c.CustomerName
HAVING SUM(ol.UnitPrice) > 100 OR COUNT(ol.Quantity) > 20
ORDER BY OrderQuarter, ThirdYear, OrderDate;

SELECT o.OrderID, convert(nvarchar(16), o.OrderDate, 104) AS OrderDate, datename(mm, o.OrderDate) AS OrderMonth, datename(qq, o.OrderDate) AS OrderQuarter,
CASE
    WHEN datepart(mm, o.OrderDate) BETWEEN 1 AND 4 THEN 1
    WHEN datepart(mm, o.OrderDate) BETWEEN 5 AND 8 THEN 2
	ELSE 3 
END AS ThirdYear,
c.CustomerName
FROM Sales.Orders o
JOIN (SELECT ol.OrderID, SUM(ol.UnitPrice) AS SumOrder,  COUNT(ol.Quantity) AS CountOrder FROM Sales.OrderLines ol GROUP BY ol.OrderID
      HAVING SUM(ol.UnitPrice) > 100 OR COUNT(ol.UnitPrice) > 20) AS olv ON olv.OrderID = o.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
WHERE o.PickingCompletedWhen IS NOT NULL
ORDER BY OrderQuarter, ThirdYear, OrderDate;

--------- Можно так. Результат тот же.  

SELECT o.OrderID, convert(nvarchar(16), o.OrderDate, 104) AS OrderDate, datename(mm, o.OrderDate) AS OrderMonth, datename(qq, o.OrderDate) AS OrderQuarter,
CASE
    WHEN datepart(mm, o.OrderDate) BETWEEN 1 AND 4 THEN 1
    WHEN datepart(mm, o.OrderDate) BETWEEN 5 AND 8 THEN 2
	ELSE 3 
END AS ThirdYear,
c.CustomerName
FROM Sales.Orders o
JOIN (SELECT ol.OrderID FROM Sales.OrderLines ol GROUP BY ol.OrderID
      HAVING SUM(ol.UnitPrice) > 100 OR COUNT(ol.UnitPrice) > 20) AS olv ON olv.OrderID = o.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
WHERE o.PickingCompletedWhen IS NOT NULL
ORDER BY OrderQuarter, ThirdYear, OrderDate;

/****Запрос когда условия для любого товара в заказе**************/

SELECT o.OrderID, convert(nvarchar(16), o.OrderDate, 104) AS OrderDate, datename(mm, o.OrderDate) AS OrderMonth, datename(qq, o.OrderDate) AS OrderQuarter,
CASE
    WHEN datepart(mm, o.OrderDate) BETWEEN 1 AND 4 THEN 1
    WHEN datepart(mm, o.OrderDate) BETWEEN 5 AND 8 THEN 2
	ELSE 3 
END AS ThirdYear,
c.CustomerName
FROM Sales.Orders o
JOIN (SELECT DISTINCT ol.OrderID FROM Sales.OrderLines ol WHERE ol.UnitPrice > 100 OR ol.UnitPrice > 20) AS olv ON olv.OrderID = o.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
WHERE o.PickingCompletedWhen IS NOT NULL
ORDER BY OrderQuarter, ThirdYear, OrderDate;


/******Пропускает первую 1000 и отображает следующие 100 записей Два вида запроса***********/


SELECT o.OrderID, convert(nvarchar(16), o.OrderDate, 104) AS OrderDate, datename(mm, o.OrderDate) AS OrderMonth, datename(qq, o.OrderDate) AS OrderQuarter,
CASE
    WHEN datepart(mm, o.OrderDate) BETWEEN 1 AND 4 THEN 1
    WHEN datepart(mm, o.OrderDate) BETWEEN 5 AND 8 THEN 2
	ELSE 3 
END AS ThirdYear,
c.CustomerName
FROM Sales.Orders o
JOIN Sales.OrderLines ol ON ol.OrderID = o.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
WHERE o.PickingCompletedWhen IS NOT NULL
GROUP BY o.OrderID, o.OrderDate, c.CustomerName
HAVING SUM(ol.UnitPrice) > 100 OR COUNT(ol.Quantity) > 20
ORDER BY OrderQuarter, ThirdYear, OrderDate
OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY;



SELECT o.OrderID, convert(nvarchar(16), o.OrderDate, 104) AS OrderDate, datename(mm, o.OrderDate) AS OrderMonth, datename(qq, o.OrderDate) AS OrderQuarter,
CASE
    WHEN datepart(mm, o.OrderDate) BETWEEN 1 AND 4 THEN 1
    WHEN datepart(mm, o.OrderDate) BETWEEN 5 AND 8 THEN 2
	ELSE 3 
END AS ThirdYear,
c.CustomerName
FROM Sales.Orders o
JOIN (SELECT ol.OrderID, SUM(ol.UnitPrice) AS SumOrder,  COUNT(ol.Quantity) AS CountOrder FROM Sales.OrderLines ol GROUP BY ol.OrderID
      HAVING SUM(ol.UnitPrice) > 100 OR COUNT(ol.UnitPrice) > 20) AS olv ON olv.OrderID = o.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
WHERE o.PickingCompletedWhen IS NOT NULL
ORDER BY OrderQuarter, ThirdYear, OrderDate
OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY;


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT dm.DeliveryMethodName, po.ExpectedDeliveryDate, s.SupplierName, p.FullName AS ContactPersonName
FROM Purchasing.Suppliers s 
JOIN Purchasing.PurchaseOrders po ON po.SupplierID = s.SupplierID
JOIN Application.DeliveryMethods dm ON dm.DeliveryMethodID = po.DeliveryMethodID
JOIN Application.People p ON p.PersonID = po.ContactPersonID
WHERE po.ExpectedDeliveryDate >= '20130101' AND po.ExpectedDeliveryDate < '20130201'
AND  dm.DeliveryMethodName IN ('Air Freight', 'Refrigerated Air Freight')
AND  po.IsOrderFinalized  = 1;


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP 10 i.*, c.CustomerName, p.FullName AS SalespersonPersonName
FROM Sales.Invoices i
JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
JOIN Sales.Orders o ON o.OrderID = i.OrderID
JOIN Application.People p ON p.PersonID = o.SalespersonPersonID
ORDER BY i.InvoiceDate DESC;

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

-----Два варианта. Результат одинаков. Как считаете предпочтительно? У меня со вторым когда то были проблемы, но возможно там что то не совсем так было.

SELECT c.CustomerID, c.CustomerName, c.PhoneNumber
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON si.StockItemName = 'Chocolate frogs 250g' AND si.StockItemID = il.StockItemID
JOIN Sales.Invoices i ON i.InvoiceID = il.InvoiceID
JOIN Sales.Customers c ON c.CustomerID = i.CustomerID;

SELECT c.CustomerID, c.CustomerName, c.PhoneNumber
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON si.StockItemID = il.StockItemID   
JOIN Sales.Invoices i ON i.InvoiceID = il.InvoiceID
JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
where si.StockItemName = 'Chocolate frogs 250g';




/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/


SELECT YEAR(i.InvoiceDate) AS SalesYear, MONTH(i.InvoiceDate) AS SalesMonth, AVG(il.UnitPrice*il.Quantity) AS SalesAvg, SUM(il.UnitPrice*il.Quantity) AS SalesSum
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);


/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(i.InvoiceDate) AS SalesYear, MONTH(i.InvoiceDate) AS SalesMonth, SUM(il.UnitPrice*il.Quantity) AS SalesSum
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(il.UnitPrice*il.Quantity) > 10000
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);


/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(i.InvoiceDate) AS SalesYear, MONTH(i.InvoiceDate) AS SalesMonth, si.StockItemName,  SUM(il.UnitPrice*il.Quantity) AS SalesSum,
       MIN(i.InvoiceDate) AS SalesMinDate , SUM(il.Quantity) AS SalesProductQuantity
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
JOIN Warehouse.StockItems si ON  si.StockItemID = il.StockItemID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), si.StockItemName
HAVING SUM(il.Quantity) < 50
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

