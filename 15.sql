The Problem: Find the "Top Earners Per Department" and Their Salary GapQuestion:Write a SQL query to find the employee(s) with the highest salary 
  in each department. For each of these top earners, calculate how much more they earn compared to the average salary of their respective department.
  If two employees share the highest salary, return both.Database Schemadepartments TableColumn NameTypedept_idINT (Primary Key)dept_nameVARCHARemployees 
  TableColumn NameTypeemp_idINT (Primary Key)emp_nameVARCHARsalaryDECIMALdept_idINT (Foreign Key)

SQL Query SolutionsqlWITH DepartmentStats AS (
    -- Step 1: Calculate the average salary for each department
    SELECT 
        dept_id,
        AVG(salary) AS avg_dept_salary
    FROM employees
    GROUP BY dept_id
),
RankedEmployees AS (
    -- Step 2: Rank employees within their department by salary
    SELECT 
        emp_id,
        emp_name,
        salary,
        dept_id,
        DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS salary_rank
    FROM employees
)
-- Step 3: Fetch top earners and calculate the salary gap
SELECT 
    d.dept_name,
    e.emp_name AS top_earner,
    e.salary AS highest_salary,
    ROUND(e.salary - s.avg_dept_salary, 2) AS gap_above_average
FROM RankedEmployees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN DepartmentStats s ON e.dept_id = s.dept_id
WHERE e.salary_rank = 1
ORDER BY gap_above_average DESC;



Explanation of the StepsDepartmentStats (CTE): Calculates the average salary for every department using GROUP BY so we have a benchmark 
  to compare against.RankedEmployees (CTE): Uses the DENSE_RANK() window function. It partitions the dataset by dept_id and ranks salaries from highest to lowest
  . If there is a tie for the highest salary, both employees get a rank of 1.Final SELECT: Joins the two CTEs and the departments table together. It filters for
  salary_rank = 1 to target only the top earners, and subtracts the department average from the employee's salary to get the exact financial gap.

  2 apporach
  

  Instead of using multiple temporary tables (CTEs), this approach uses Correlated Subqueries. This means we use a small query inside our main query to
  look up the favorite product for each customer.
   The Alternative SQL Solutionsql-- Step 1: Get the customer details and their grand total spend
  
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.price_per_unit) AS grand_total_spend,
    
    -- Step 2: Use a subquery to find the name of the top product
  
    (
        SELECT oi2.product_name
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        WHERE o2.customer_id = c.customer_id
        GROUP BY oi2.product_name
        ORDER BY SUM(oi2.quantity * oi2.price_per_unit) DESC
        LIMIT 1
    ) AS favorite_product,

    -- Step 3: Use a subquery to find the amount spent on that top product
  
    (
        SELECT SUM(oi3.quantity * oi3.price_per_unit)
        FROM orders o3
        JOIN order_items oi3 ON o3.order_id = oi3.order_id
        WHERE o3.customer_id = c.customer_id
        GROUP BY oi3.product_name
        ORDER BY SUM(oi3.quantity * oi3.price_per_unit) DESC
        LIMIT 1
    ) AS money_spent_on_favorite

FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
  
-- Step 4: Filter out customers who spent $500 or less
  
HAVING SUM(oi.quantity * oi.price_per_unit) > 500
ORDER BY grand_total_spend DESC;
