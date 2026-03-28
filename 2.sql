
  CREATE DATABASE company_db;
USE company_db;

CREATE TABLE Employee (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    salary INT
);
INSERT INTO Employee (id, name, salary) VALUES
(1, 'A', 100),
(2, 'B', 200),
(3, 'C', 300),
(4, 'D', 300),
(5, 'E', 150);

'''find the second highest distinct salary from the table.'''
SELECT DISTINCT salary
FROM Employee
ORDER BY salary DESC
LIMIT 1 OFFSET 1;

'''or'''
SELECT MAX(salary) AS second_highest
FROM Employee
WHERE salary < (
    SELECT MAX(salary)
    FROM Employee
);

''' Nth highest salary'''
SELECT DISTINCT salary
FROM Employee
ORDER BY salary DESC
LIMIT 1 OFFSET N-1;

'''you are asking for the 2nd and 3rd highest salaries'''
SELECT DISTINCT salary
FROM Employee
ORDER BY salary DESC
LIMIT 2 OFFSET 1;


