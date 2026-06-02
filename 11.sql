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
SELECT salary
FROM (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM Employee
) t
WHERE rnk = N;

'''
Replace N with the required rank (e.g., 3 for third highest salary).

Another Popular SQL Interview Problem
Find Employees Earning More Than Their Manager

Table:

emp_id	emp_name	salary	manager_id
1	John	8000	NULL
2	Mike	6000	1
3	Sarah	9000	1
4	Tom	5000	2

Query:
  '''
SELECT e.emp_name
FROM Employee e
JOIN Employee m
    ON e.manager_id = m.emp_id
WHERE e.salary > m.salary;
'''
Output
emp_name
Sarah

Because Sarah's salary (9000) is greater than her manager John's salary (8000).



