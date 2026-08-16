The Problem: Find the "Top Earners Per Department" and Their Salary GapQuestion:Write a SQL query to find the employee(s) with the highest salary 
  in each department. For each of these top earners, calculate how much more they earn compared to the average salary of their respective department.
  If two employees share the highest salary, return both.Database Schemadepartments TableColumn NameTypedept_idINT (Primary Key)dept_nameVARCHARemployees 
  TableColumn NameTypeemp_idINT (Primary Key)emp_nameVARCHARsalaryDECIMALdept_idINT (Foreign Key)
