'''Problem: Find the Second Highest Salary

Given an Employee table:

id	name	salary
1	Alice	5000
2	Bob	7000
3	Carol	6000
4	David	7000

Write a SQL query to find the second highest distinct salary.


  '''

Solution 1: Using MAX()
SELECT MAX(salary) AS SecondHighestSalary
FROM Employee
WHERE salary < (
    SELECT MAX(salary)
    FROM Employee
);

