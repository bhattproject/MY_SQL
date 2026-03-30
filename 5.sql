'''

RIGHT JOIN Orders
👉 Keep all rows from Orders (right table)
👉 If no match on left → fill LEFT side with NULL



LEFT JOIN Orders
👉 Keep all rows from LEFT side (the result built so far)
👉 If no match in Orders → fill RIGHT side (o.*) with NULL

  

Customers Who Bought ALL Products

Customers(customer_id)
Orders(customer_id, product_id)
Products(product_id)

📊 Example Database
🟦 Customers
+-------------+
| customer_id |
+-------------+
|     1       |
|     2       |
|     3       |
+-------------+

🟩 Products
+------------+
| product_id |
+------------+
|     A      |
|     B      |
|     C      |
+------------+

🟨 Orders
+-------------+------------+
| customer_id | product_id |
+-------------+------------+
|     1       |     A      |
|     1       |     B      |
|     1       |     C      |
|     2       |     A      |
|     2       |     B      |
|     3       |     A      |
|     3       |     C      |
+-------------+------------+


👉 Find customers who bought EVERY product
'''
SELECT o.customer_id
FROM Orders o
GROUP BY o.customer_id
HAVING COUNT(DISTINCT o.product_id) = (
    SELECT COUNT(*) FROM Products
);


SELECT c.customer_id
FROM Customers c
WHERE NOT EXISTS (
    SELECT p.product_id
    FROM Products p
    WHERE NOT EXISTS (
        SELECT 1
        FROM Orders o
        WHERE o.customer_id = c.customer_id
        AND o.product_id = p.product_id
    )
);


SELECT c.customer_id
FROM Customers c
CROSS JOIN Products p
LEFT JOIN Orders o 
    ON o.customer_id = c.customer_id 
   AND o.product_id = p.product_id
GROUP BY c.customer_id
HAVING COUNT(o.product_id) = COUNT(p.product_id);

+-------------+------------+------------+
| customer_id | product_id | matched?   |
+-------------+------------+------------+
| 1           | A          | ✔          |
| 1           | B          | ✔          |
| 1           | C          | ✔          |
| 2           | A          | ✔          |
| 2           | B          | ✔          |
| 2           | C          | ❌ NULL    |
| 3           | A          | ✔          |
| 3           | B          | ❌ NULL    |
| 3           | C          | ✔          |


-------------------------------------
(1, A)
(1, A)  if duplicates

SELECT c.customer_id
FROM Customers c
CROSS JOIN Products p
LEFT JOIN Orders o 
    ON o.customer_id = c.customer_id 
   AND o.product_id = p.product_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT o.product_id) = COUNT(DISTINCT p.product_id);
==============================================


