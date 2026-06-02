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
Explanation
Inner query finds the highest salary (7000).
Outer query finds the maximum salary less than 7000.
Result: 6000.
Solution 2: Using DENSE_RANK() (Modern SQL)
SELECT salary
FROM (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM Employee
) t
WHERE rnk = 2;


'''
Explanation

Ranking:

salary	rnk
7000	1
7000	1
6000	2
5000	3

The query returns 6000.

Follow-up Interview Question
Find the Nth Highest Salary
  '''
