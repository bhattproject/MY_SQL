'''Second Highest Salary Per Department
Employee(id, name, salary, dept_id)
Department(id, dept_name)
📊 Example Data
Employee
+----+------+--------+---------+
| id | name | salary | dept_id|
+----+------+--------+---------+
| 1  | A    | 100    | 1       |
| 2  | B    | 200    | 1       |
| 3  | C    | 300    | 1       |
| 4  | D    | 400    | 2       |
| 5  | E    | 500    | 2       |
+----+------+--------+---------+
Department
+----+-----------+
| id | dept_name |
+----+-----------+
| 1  | HR        |
| 2  | IT        |
+----+-----------+
🧠 Steps
Rank salaries within department

Pick rank = 2

'''
WITH ranked AS (
    SELECT 
        e.*, 
        DENSE_RANK() OVER (
            PARTITION BY dept_id 
            ORDER BY salary DESC
        ) AS rnk
    FROM Employee e
)
SELECT d.dept_name, r.salary
FROM ranked r
JOIN Department d 
ON r.dept_id = d.id
WHERE r.rnk = 2;



=========================================
'''Self-Join
  Time Complexity: nlogn
 (with indexing).
Space Complexity: n
 to hold the temporary joined results.
Performance: High. Most efficient for large datasets because it processes rows in batches.
  '''
SELECT e.name AS employee
FROM Employee e
JOIN Employee m ON e.manager_id = m.id
WHERE e.salary > m.salary;

===========================================


sql
SELECT name AS employee
FROM Employee e
WHERE salary > (SELECT salary FROM Employee WHERE id = e.manager_id);

'''Correlated Subquery
  This "looks up" the managers salary for every single employee row one by one.
Time Complexity: n2 or nlogn
 (worst case) or 
 (with indexing).
Space Complexity: 1
 extra space beyond the base table.
Performance: Low to Moderate. It can be slow because the inner query might run once for every row in the outer table (row-by-row overhead
'''
================================


