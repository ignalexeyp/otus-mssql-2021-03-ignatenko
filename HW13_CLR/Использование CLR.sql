----- Регулярные выражения

SELECT * FROM Warehouse.StockItems WHERE SQL#.RegEx_CaptureGroup(StockItemName,'(\d+) (mm|XL)', 2, NULL, 1, 10, '') = 'mm'
OR SQL#.RegEx_CaptureGroup(StockItemName,'(\d+)(mm|XL)', 2, NULL, 20, 20, '') = 'XL'

----- Математические функции

SELECT StockItemID, StockItemName, UnitPrice, RecommendedRetailPrice, SQL#.Math_RoundToEvenFloat(RecommendedRetailPrice, 0) AS EvenFloat
FROM Warehouse.StockItems;
