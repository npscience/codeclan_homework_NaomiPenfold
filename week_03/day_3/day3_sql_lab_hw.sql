/* Final SQL Lab and Homework */

-- MVP

-- Q1

-- How many employee records are lacking both a grade and salary?

-- we want a count of rows (== employees)
-- where grade in NULL AND salary is NULL 
-- this info is all in employees

SELECT count(id)	
FROM employees
WHERE 
	grade IS NULL AND
	salary IS NULL;
-- answer: 2


-- Q2

-- Produce a table with the two following fields (columns):
  -- the department
  -- the employees full name (first and last name)
-- Order your resulting table alphabetically by department, 
-- and then by last name

-- all info is in employees
-- we want:
-- | department | full_name |
-- | A | Joe Adams |
-- | A | Jon Beaver |
-- | B | Jay Axel |

SELECT 
	department,
	concat(first_name, ' ', last_name) AS full_name
FROM employees 
ORDER BY department, last_name;

-- Q3

-- Find the details of the top ten highest paid employees 
-- who have a last_name beginning with ‘A’.

-- all info is in employees
-- WHERE for last_name
-- order by salary DESC, limit 10

SELECT *
FROM employees 
WHERE last_name ~ '^A+'
ORDER BY salary DESC NULLS LAST 
LIMIT 10;


-- Q4

-- Obtain a count by department of the employees 
-- who started work with the corporation in 2003.

-- all info is in employees
-- where start_date between 01/01 and 31/12 in 2003
-- count(id) group by department


SELECT department, count(id) AS num_employees
FROM employees 
WHERE start_date BETWEEN '2003-01-01' AND '2003-12-31'
GROUP BY department
ORDER BY num_employees DESC;


-- Q5

-- Obtain a table showing department, fte_hours and 
-- the number of employees in each department 
-- who work each fte_hours pattern. 
-- Order the table alphabetically by department, 
-- and then in ascending order of fte_hours.

-- all info in employees
-- we want:
-- | dept | fte_hours | count(emps) |
-- | Accounting | 0.25 | 1 |
-- | Accounting | 0.5 | 3 |
-- etc
-- | Training | 1.0 | 11 |


SELECT 
	department,
	fte_hours,
	count(id)
FROM employees 
GROUP BY department, fte_hours
ORDER BY department, fte_hours;


-- Q6

-- Provide a breakdown of the numbers of employees enrolled, 
-- not enrolled, and with unknown enrollment status 
-- in the corporation pension scheme.

-- all info is in employees
-- count(id) group by pension_status

SELECT
	pension_enrol,
	count(id) AS num_employees
FROM employees 
GROUP BY pension_enrol;

-- Q7

-- Obtain the details for the employee with the highest salary
-- in the ‘Accounting’ department 
-- who is not enrolled in the pension scheme?

-- all info in employees
-- WHERE not enrolled to FILTER
-- AND where department is accounting
-- select * all details
-- order by salary desc limit 1 to get the top person

SELECT *
FROM employees 
WHERE 
	department = 'Accounting' AND 
	pension_enrol IS FALSE 
ORDER BY salary DESC NULLS LAST 
LIMIT 1;

-- Q8

-- Get a table of country, number of employees in that country,
-- and the average salary of employees in that country 
-- for any countries in which more than 30 employees are based. 
-- Order the table by average salary descending.

-- all info in employees
-- we want:
-- | country | num_emps | avg_salary_country |
-- | country name | 31 or more | high salary |
-- | country name | 31 or more | less high salary |
-- WHERE num_emps in country > 30 - this is HAVING for GROUP BY
-- ORDER BY avg_sal DESC


SELECT 
	country,
	count(id) AS num_employees,
	avg(salary) AS avg_salary
FROM employees 
GROUP BY country
HAVING count(id) > 30
ORDER BY avg_salary DESC NULLS LAST;


-- Q9

-- Return a table containing each employees first_name, last_name, 
-- full-time equivalent hours (fte_hours), salary, 
-- and a new column effective_yearly_salary 
-- which should contain fte_hours multiplied by salary. 
-- Return only rows where effective_yearly_salary is more than 30000.

-- all info in employees
-- table looks like:
-- | first name | last name | fte_hrs | salary | effective yearly salary |
-- where EYS is fte*sal (both numeric so ok)
-- with a filter (WHERE) for EYS > 30000


SELECT 
	first_name,
	last_name,
	fte_hours,
	salary,
	fte_hours * salary AS effective_yearly_salary
FROM employees
WHERE fte_hours * salary > 30000;


-- Q10

-- Find the details of all employees in either Data Team 1 or Data Team 2

-- need to join employees and teams
-- ON e.team_id = t.id 
-- where team name is dt 1 or 2

SELECT *
FROM employees AS e
	INNER JOIN teams AS t 
	ON e.team_id = t.id
WHERE t.name IN ('Data Team 1', 'Data Team 2')
ORDER BY t.name;


-- Q11

-- Find the first name and last name of all employees who lack a local_tax_code

-- need to join employees (pay_detail_id) and pay_details (id)
-- filter WHERE local_tax_code is NULL 

SELECT e.first_name, e.last_name, pd.local_tax_code
FROM employees AS e
	LEFT JOIN pay_details AS pd 
	ON e.pay_detail_id = pd.id 
WHERE pd.local_tax_code IS NULL 
ORDER BY e.last_name ;


-- Q12

-- The expected_profit of an employee is defined as 
-- (48 * 35 * charge_cost - salary) * fte_hours, 
-- where charge_cost depends upon the team to which the employee belongs. 
-- Get a table showing expected_profit for each employee.

-- left join employees and teams
-- calculate expected_profit
-- select employee names and expected_profit


SELECT 
	e.first_name, e.last_name,
	-- t.charge_cost, e.salary, e.fte_hours, -- to check calc
	(48 * 35 * CAST(t.charge_cost AS INT) - e.salary) * e.fte_hours AS expected_project
FROM employees AS e
	LEFT JOIN teams AS t 
	ON e.team_id = t.id 
ORDER BY expected_project DESC NULLS LAST;


-- Q13

-- Find the first_name, last_name and salary of 
-- the lowest paid employee 
-- in Japan 
-- who works the 
	-- least common full-time equivalent hours across the corporation.

-- use employees for all
-- find the least common fte hrs across all -- do sub query or a WITH
-- filter for people who work this least common fte bracket
-- filter for japan
-- order by salary ASC NULLS LAST and limit 1 to get lowest paid
-- select first name, last name, salary


WITH least_common_fte_hrs AS
	(SELECT fte_hours, count(id) -- 0.5 is least common
	FROM employees 
	GROUP BY fte_hours
	ORDER BY count(id) ASC
	LIMIT 1)	
SELECT 
	-- fte_hours, country, -- to check
	first_name, last_name, salary
FROM employees 
WHERE 
	country = 'Japan' AND 
	fte_hours = (SELECT fte_hours FROM least_common_fte_hrs) --; 6 people
ORDER BY salary ASC NULLS LAST
LIMIT 1; -- lowest paid person


-- Q14

-- Obtain a table showing any departments 
-- in which there are two or more employees lacking a stored first name. 
-- Order the table in 
-- descending order of the number of employees lacking a first name, 
-- and then in alphabetical order by department.

-- using all info in employees
-- select department column 
-- WHERE 
	-- (count(emp) where first name is null) >= 2
-- ORDER BY same calc DESC, then dept ASC

-- first: (count(emp) where first name is null) >= 2

WITH null_names AS (
	SELECT 
		department, 
		count(id) AS num_employees
	FROM employees 
	WHERE first_name IS NULL
	GROUP BY department
	)
SELECT *
FROM null_names
WHERE num_employees >= 2
ORDER BY num_employees DESC, department;


-- Q15

-- Return a table of those employee first_names shared by more than one employee, 
-- together with a count of the number of times each first_name occurs. 
-- Omit employees without a stored first_name from the table. 
-- Order the table descending by count, and then alphabetically by first_name

-- count(first_name) group by first_name
-- look for count(first_name) >= 2 to find duplicate names - HAVING after GROUP BY
-- omit any NULLS using a WHERE filter
-- order by count DESC then by name ASC

SELECT 
	first_name,
	count(first_name) AS frequency
FROM employees 
WHERE first_name IS NOT NULL
GROUP BY first_name
HAVING count(first_name) >= 2
ORDER BY frequency DESC, first_name ASC;


-- Q16

-- Find the proportion of employees in each department who are grade 1.

-- all info is in employees
-- A = number employees in each department
-- B = number employees in each dept who are grade 1
-- proportion = B/A
-- do 2 WITHs for A and B then use these to calculate proportion

-- the table we need to do the calcs:
SELECT 
	department,
	grade,
	count(id)
FROM employees 
GROUP BY department, grade;

-- we to make another table using this one with:
-- department
-- sum(count) by department -- can use a OVER PARTITION BY
-- and count where grade 1
-- and then B/A 




-- Try with the hint: 
-- You can write an expression in a SELECT statement, e.g. grade = 1. 
   -- This would result in BOOLEAN values.
-- If you could convert BOOLEAN to INTEGER 1 and 0, you could sum them. 
  -- The CAST() function lets you convert data types.
-- In SQL, an INTEGER divided by an INTEGER yields an INTEGER.
  -- To get a REAL value, you need to convert the top, bottom or both sides 
  -- of the division to REAL.

-- this makes a table of department, and 1 if grade 1 or 0 otherwise
-- can sum grade1_TF to get num employees at grade 1


-- Most efficient answer with hint:
SELECT 
	department,
	-- CAST(sum(CAST(grade = 1 AS INT)) AS REAL) AS num_grade1,
	-- count(id) AS total_in_dept,
	CAST(sum(CAST(grade = 1 AS INT)) AS REAL) / count(id) AS proportion
FROM employees 
GROUP BY department;


-- A longer way round with hint:
WITH grade1s AS (
			SELECT
				department,
				CAST(sum(CAST(grade = 1 AS INT)) AS REAL) AS num_grade1
			FROM employees
			GROUP BY department
			),
	totals AS (SELECT
					department,
					CAST(count(id) AS REAL) AS total
				FROM employees 
				GROUP BY department
			)
SELECT 
	g1.department, 
	g1.num_grade1, 
	t.total,
	g1.num_grade1 / t.total AS proportion
FROM grade1s AS g1
	LEFT JOIN totals AS t
	ON g1.department = t.department;


-- the even longer way round, that produces duplicate entries for every department
-- not using hint:
WITH depts_grades AS (
	SELECT 
		department,
		grade,
		count(id) AS num_employees
	FROM employees 
	GROUP BY department, grade
	),
	depts_grade1 AS (
	SELECT department, num_employees
	FROM depts_grades 
	WHERE grade = 1
	),
	depts_grades_freq AS (
	SELECT 
		dg.department,
		sum(dg.num_employees) OVER (PARTITION BY dg.department) AS dept_total,
		d1.num_employees AS dept_grade1
	FROM depts_grades AS dg
		INNER JOIN depts_grade1 AS d1
		ON dg.department = d1.department
	)
SELECT
	department,
	dept_grade1,
	dept_total,
	dept_grade1 / dept_total AS proportion
FROM depts_grades_freq
ORDER BY proportion ASC;



