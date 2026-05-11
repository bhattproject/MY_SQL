The most common way to fetch all data from a table (e.g., a "Customers" table) is:sqlSELECT * FROM Customers;
Problem: Find all employees who earn more than their direct manager.Concept: Use a Self-Join to link the table to itself.sqlSELECT e1.name AS employee_name
FROM Employees e1
JOIN Employees e2 ON e1.manager_id = e2.employee_id
WHERE e1.salary > e2.salary;
