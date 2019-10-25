-- Query 1  What is the employee id of the highest paid employee?


SELECT emp_id AS employee, salary AS highest_salary
FROM salaries
HAVING salary = (SELECT MAX(salary) AS highest_salary FROM salaries)


-- Query 2 What is the name of youngest employee?

SELECT first_name, last_name, birth_date
FROM employees
ORDER BY birth_date DESC
LIMIT 1


-- Query 3 What is the name of the first hired employee? 

SELECT first_name, last_name, hire_date
FROM employees
ORDER BY hire_date
LIMIT 1

-- Query 4 What percentage of employees are Female?

SELECT (SELECT COUNT(*) AS Cnt FROM employees WHERE gender = 'F')/count(*)*100 AS Percentage_of_Female_Employees
FROM employees


-- Query 5 Show the employee count by department name wise, sorted alphabetically on department name.

SELECT dept_name, COUNT(emp_id) AS Total
FROM departments d
JOIN dept_emp de
ON d.dept_no = de.dept_no
GROUP BY d.dept_name
ORDER BY d.dept_name

-- Query 6  Count the number of employees by each calendar year ( take the value of year from from_date)

SELECT EXTRACT(year from from_date) AS calendar_year, COUNT(*) AS Total
FROM dept_emp
GROUP BY calendar_year
ORDER BY calendar_year

-- Query 7 Count the number of employees by each calendar year (take the value of year from from_date) ordered by calendar year exlcuding all years before 1990. Divide the employee count based on gender.

SELECT EXTRACT(year from de.from_date) AS calendar_year, COUNT(*) AS Total, e.gender
FROM dept_emp de
JOIN employees e
ON de.emp_id=e.emp_id

GROUP BY calendar_year, e.gender
ORDER BY calendar_year, e.gender



-- Query 8 What is the number of managers hired each calendar year. 

-- Query 9 What will be the department wise break up of managers ?

-- Query 10 What is the number of male managers and female managers hired each calendar year from the year 1990 onwards?