/* SQL lab & homework */

/* MVP */
/* Q1 */
-- Find all the employees who work in the ‘Human Resources’ department.

SELECT *
FROM employees 
WHERE department = 'Human Resources';

/* Q2 */
-- Get the first_name, last_name, and country of 
-- the employees who work in the ‘Legal’ department.

SELECT first_name, last_name, country
FROM employees
WHERE department = 'Legal';

/* Q3 */
-- Count the number of employees based in Portugal.

SELECT 
	count(id)
FROM employees
WHERE country = 'Portugal';

-- Answer: 29

/* Q4 */
-- Count the number of employees based in either 
-- Portugal or Spain.

SELECT 
	count(id)
FROM employees
WHERE country IN ('Portugal', 'Spain');

-- or
SELECT 
	count(id)
FROM employees
WHERE country = 'Portugal'
OR country = 'Spain';

-- Answer: 35


/* Q5 */
-- Count the number of pay_details records 
-- lacking a local_account_no.

SELECT 
	count(id)
FROM pay_details 
WHERE local_account_no IS NULL;

-- Answer: 25

/* Q6 */
-- Are there any pay_details records lacking 
-- both a local_account_no and iban number?

SELECT *
FROM pay_details 
WHERE 
	local_account_no IS NULL
	AND iban IS NULL;

-- Answer: none

/* Q7 */
-- Get a table with employees first_name and last_name 
-- ordered alphabetically by last_name (put any NULLs last)

SELECT first_name, last_name
FROM employees 
ORDER BY last_name NULLS LAST;


/* Q8 */
-- Get a table of employees first_name, last_name and country,
-- ordered alphabetically first by country 
-- and then by last_name (put any NULLs last)

SELECT first_name, last_name, country
FROM employees 
ORDER BY 
	country NULLS LAST,
	last_name NULLS LAST;

-- LAST NULLS for hw purposes, there are none in either col

/* Q9 */
-- Find the details of the top ten highest paid employees in the corporation

SELECT *
FROM employees 
ORDER BY salary DESC NULLS LAST 
LIMIT 10;

/* Q10 */
-- Find the first_name, last_name and salary 
-- of the lowest paid employee in Hungary.

SELECT first_name, last_name, salary
FROM employees
WHERE country = 'Hungary'
ORDER BY salary NULLS LAST
LIMIT 1;

/* Q11 */
-- How many employees have a first_name beginning with ‘F’?

SELECT 
	count(id)
FROM employees 
WHERE first_name ILIKE 'F%';

-- Answer: 30 

/* Q12 */
-- Find all the details of any employees with a ‘yahoo’ email address?

SELECT *
FROM employees 
WHERE email ILIKE '_%yahoo%';

/* Q13 */
-- Count the number of pension enrolled employees 
-- not based in either France or Germany.
-- homework review: no need for first _, covered by %

SELECT 
	count(id)
FROM employees 
WHERE 
	country NOT IN ('France', 'Germany')
	AND pension_enrol IS TRUE;

-- Answer: 475

/* Q14 */
-- What is the maximum salary among those employees 
-- in the ‘Engineering’ department 
-- who work 1.0 full-time equivalent hours (fte_hours)?

SELECT 
	max(salary)
FROM employees
WHERE department = 'Engineering'
AND fte_hours = 1;

-- Answer: 83,370

/* Q15 */
-- Return a table containing each employees first_name, 
-- last_name, full-time equivalent hours (fte_hours), 
-- salary, and a new column effective_yearly_salary 
-- which should contain fte_hours multiplied by salary.

SELECT 
	first_name, last_name, fte_hours, salary,
	fte_hours * salary AS effective_yearly_salary
FROM employees;

/* Extension */

/* Q16 */
-- The corporation wants to make name badges for a forthcoming conference.
-- Return a column badge_label showing employees’ first_name and last_name 
-- joined together with their department in the following style: 
-- ‘Bob Smith - Legal’. 
-- Restrict output to only those employees with stored first_name, last_name and department.

SELECT 
	-- first_name, last_name, department,
	concat(first_name, ' ', last_name, ' - ', department) AS badge_label
	-- Note: do not use '' with colname as that sees it as string
	-- and returns it exactly as is rather than returning the data value
FROM employees 
WHERE
	first_name NOTNULL
	AND
	last_name NOTNULL
	AND
	department NOTNULL;
-- Note: NOTNULL returns same as IS NOT NULL


/* Q17 */
-- One of the conference organisers thinks it would be nice to 
-- add the year of the employees’ start_date to the badge_label 
-- to celebrate long-standing colleagues, in the following style 
-- ‘Bob Smith - Legal (joined 1998)’. 
-- Further restrict output to only those employees with a stored start_date.
-- [If you’re really keen - try adding the month as a string: 
-- ‘Bob Smith - Legal (joined July 1998)’]


-- write badge labels
SELECT 
	first_name, last_name, department, start_date,
	concat(first_name, ' ', last_name, ' - ', department, ' (joined ',
		-- use sub-query to get month
		(SELECT TO_CHAR(start_date, 'FMMonth')),
		' ', 
		-- use extract to get year
		EXTRACT(YEAR FROM start_date), ')') AS badge_label
FROM employees 
WHERE
	first_name NOTNULL
	AND
	last_name NOTNULL
	AND
	department NOTNULL
	AND 
	start_date NOTNULL;

-- note the sub-query works without FROM !!
-- note 'Mon' returns first 3 letters of month
-- while 'Month' returns 9 characters, so July + 5 spaces, or December + 1 space
-- I prefer 'Mon' for spacing reasons
-- UPDATE from homework review: 'FMMonth' gets the full month without additional spaces!!
-- "Note: In this last solution we added FM in front of Month. 
-- "When using the TO_CHAR() function, its default is to add leading and trailing spaces to the string.
-- "FM removes these spaces."
-- see postgreSQL docs: https://www.postgresql.org/docs/current/functions-formatting.html


/* Q18 */
-- Return the first_name, last_name and salary of all employees 
-- together with a new column called salary_class with a value 'low' 
-- where salary is less than 40,000 
-- and value 'high' where salary is greater than or equal to 40,000


SELECT 
	first_name, last_name, salary, 
	(CASE WHEN salary < 40000 THEN 'low' ELSE 'high' END) AS salary_class
FROM employees 
WHERE salary NOTNULL;

-- homework review - take care with NULLs, keep them in
-- homework answer:

SELECT 
  first_name, 
  last_name, 
  CASE 
    WHEN salary < 40000 THEN 'low'
    WHEN salary IS NULL THEN NULL
    ELSE 'high' 
  END AS salary_class
FROM employees;





