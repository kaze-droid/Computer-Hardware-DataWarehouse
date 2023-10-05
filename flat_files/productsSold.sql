SELECT p.Product_ID, SUM(ISNULL(oi.Quantity,0)) AS total_qty_sold
FROM Products p
LEFT JOIN Order_items oi
ON p.Product_id = oi.Product_id
GROUP BY p.Product_id
FOR JSON PATH, INCLUDE_NULL_VALUES;

