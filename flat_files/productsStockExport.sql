SELECT p.Product_ID, p.Product_Name, w.Warehouse_ID, w.Warehouse_Name, l.Location_ID, l.Address, c.Country_Name, r.Region_Name, i.Quantity
FROM Inventories i
INNER JOIN Products p
ON p.Product_ID = i.Product_ID
INNER JOIN Warehouses w
ON w.Warehouse_ID = i.Warehouse_ID
INNER JOIN Locations l
ON l.Location_ID = w.Location_ID
INNER JOIN Countries c
ON l.Country_ID = c.Country_ID
INNER JOIN Regions r
ON r.Region_ID = c.Region_ID
FOR JSON PATH, INCLUDE_NULL_VALUES;