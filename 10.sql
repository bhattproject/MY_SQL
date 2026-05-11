The most common way to fetch all data from a table (e.g., a "Customers" table) is:sqlSELECT * FROM Customers;


Problem: Find all employees who earn more than their direct manager.Concept: Use a Self-Join to link the table to itself.sqlSELECT e1.name AS employee_name
FROM Employees e1
JOIN Employees e2 ON e1.manager_id = e2.employee_id
WHERE e1.salary > e2.salary;



. The Nth Highest SalaryProblem: Find the 2nd highest salary in a table without using LIMIT or TOP.Concept: Use a Correlated Subquery to find the maximum salary that is not the absolute maximum.sqlSELECT MAX(salary) 
FROM Employees 
WHERE salary NOT IN (SELECT MAX(salary) FROM Employees);

Top N Records per GroupProblem: Find the top 2 highest-paid employees in each department.Concept: Use the DENSE_RANK() Window Function to rank rows within specific partitions.sqlWITH RankedEmployees AS (
    SELECT name, department_id, salary,
           DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as rnk
    FROM Employees
)
SELECT * FROM RankedEmployees WHERE rnk <= 2;


 Detecting Gaps and Islands (Streaks)Problem: Find the longest streak of consecutive days a user has logged in.Concept: Use a difference of row numbers to group consecutive dates together. By subtracting a sequence (ROW_NUMBER) from the date, all consecutive dates will result in the same "anchor date."sqlWITH GroupedLogins AS (
    SELECT user_id, login_date,
           login_date - ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date) AS grp
    FROM Logins
)
SELECT user_id, COUNT(*) AS streak_length
FROM GroupedLogins
GROUP BY user_id, grp
ORDER BY streak_length DESC
LIMIT 1;
