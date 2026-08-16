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
Use code with caution.Explanation of the StepsDepartmentStats (CTE): Calculates the average salary for every department using GROUP BY so we have a benchmark 
  to compare against.RankedEmployees (CTE): Uses the DENSE_RANK() window function. It partitions the dataset by dept_id and ranks salaries from highest to lowest
  . If there is a tie for the highest salary, both employees get a rank of 1.Final SELECT: Joins the two CTEs and the departments table together. It filters for
  salary_rank = 1 to target only the top earners, and subtracts the department average from the employee's salary to get the exact financial gap.
