-- lab / homework

-- MVP

-- Q1.(a)

-- Find the first name, last name and team name
-- of employees who are members of teams

-- Approach:
-- use employees and teams tables 
-- join by: employees FK = team_id = tables PK = id 
-- INNER JOIN to only get people in teams
-- select employee first and last names from employees,
-- and team name from teams

SELECT 
	e.first_name, 
	e.last_name, 
	t."name" AS team_name
FROM employees AS e
	INNER JOIN teams AS t
	ON e.team_id = t.id;
-- 1000 rows

-- Q1.(b)

-- Find the first name, last name and team name 
-- of employees who are members of teams 
-- and are enrolled in the pension scheme

-- Approach:
-- as above but add WHERE condition
-- for employees table pension scheme IS TRUE

SELECT 
	e.first_name, 
	e.last_name, 
	t."name" AS team_name
FROM employees AS e
	INNER JOIN teams AS t
	ON e.team_id = t.id
WHERE e.pension_enrol IS TRUE;
-- 488 rows

-- Q1.(c) 

-- Find the first name, last name and team name 
-- of employees who are members of teams, 
-- where their team has a charge cost greater than 80

-- Approach:
-- charge cost is in teams table, so
-- use 1(a) approach, and add a WHERE condition
-- for teams.charge_cost > 80  
-- but doesn't work while charge_cost is VARCHAR type 
-- so also convert to integer using :: INTEGER
-- and in original, show charge_cost to check all above 80
-- (commented out in answer): 

SELECT 
	e.first_name, 
	e.last_name, 
	t."name" AS team_name,
	-- t.charge_cost 
FROM employees AS e
	INNER JOIN teams AS t
	ON e.team_id = t.id
WHERE t.charge_cost :: INTEGER > 80;
-- doesn't work. 
-- ERROR: operator does not exist: 
	-- character varying > integer 
-- suggests charge_cost data is wrong type?
-- schema shows it is VAR_CHAR not INT
-- make a subquery or use a postgresql function to change data type
-- found column :: INTEGER

-- Trying out how to convert VARCHAR to INTEGER:
SELECT 
	charge_cost AS "chr",
	charge_cost :: INTEGER AS "int", 
	-- from: https://www.commandprompt.com/education/how-to-convert-a-string-to-a-number-in-postgresql/
	CAST( charge_cost AS INTEGER) AS "int_cast"
	-- from: https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-cast/
FROM teams ;


-- Q2.(a)

-- Get a table of all employees details, 
-- together with their local_account_no and local_sort_code, 
-- if they have them.

-- Approach:
-- we want all employees
-- *with* the other info (from pay_details) 
-- *if* they have it, *else* include as NULLs 
-- so not totally restrictive INNER JOIN
-- instead use LEFT JOIN with employees to pay_details
-- and select only the wanted info:
   -- all from employees, only account & sort from pay

-- first, check expected rows:
SELECT *
FROM employees;
-- 1000 employees in full data

-- expect 1000 rows in result too, because
-- all 1000 employees and no more because 1:1 with pay details:
SELECT
	e.*,
	p.local_account_no,
	p.local_sort_code 
FROM employees AS e
	LEFT JOIN pay_details AS p
	ON e.pay_detail_id = p.id;
-- returns 1000 as expected

-- Q2.(b)

-- Amend your query above to also 
-- return the name of the team that each employee belongs to

-- Approach:
-- append another left join with teams (as final right-hand table)

SELECT
	e.*,
	p.local_account_no,
	p.local_sort_code,
	t."name" AS team_name
FROM employees AS e
	LEFT JOIN pay_details AS p
	ON e.pay_detail_id = p.id
	LEFT JOIN teams AS t 
	ON e.team_id = t.id;
-- also 1000 rows.


-- Q3.(a)

-- Make a table, which has each employee id 
-- along with the team that employee belongs to.

-- Approach:
-- a table with employees.id joined to teams.name only
-- Doesn't specify only employees in teams, 
-- so include employees with NULL team id
-- use LEFT JOIN with employees to teams

-- first, ask: are there any NULLs in team_id in employees?

SELECT *
FROM employees 
WHERE team_id IS NULL;
-- O records, so don't need to worry about INNER or LEFT join.

SELECT
	e.id AS employee_id,
	t."name" AS team_name
FROM employees AS e
	LEFT JOIN teams AS t 
	ON e.team_id = t.id;

-- Q3.(b)

-- Breakdown the number of employees in each of the teams.

-- APPROACH:
-- change select to return team name and count(employees using e.id)
-- include GROUP BY to group by team name

SELECT
	t."name" AS team_name,
	count(e.id) AS num_employees
FROM employees AS e
	LEFT JOIN teams AS t 
	ON e.team_id = t.id
GROUP BY t.name;

-- Q3.(c)

-- Order the table above by so that the teams 
-- with the least employees come first.

-- Approach:
-- Add ORDER BY the count of employees, ascending.

SELECT
	t."name" AS team_name,
	count(e.id) AS num_employees
FROM employees AS e
	LEFT JOIN teams AS t 
	ON e.team_id = t.id
GROUP BY t.name
ORDER BY count(e.id) ASC;


-- Q4.(a)

-- Create a table with the team id, team name and 
-- the count of the number of employees in each team.

-- Approach:
-- need to join employees and teams
-- with team as main table -- left join with teams to employees
-- using team id = employees team_id
-- and selecting the count of employee ids
-- grouped by team names
-- also select team id and team name

SELECT 
	t.id AS team_id,
	t.name AS team_name,
	count(e.id) AS num_employees
FROM teams AS t
	LEFT JOIN employees AS e
	ON t.id = e.team_id 
GROUP BY t.id;
-- Returns 10 rows, for 10 teams
-- Note: have to group by t.id in order to also include t.name
-- Won't let me group by t.name and also include t.id
-- Works if t.id is not selected, though



-- Q4.(b)

-- The total_day_charge of a team is defined as 
-- the charge_cost of the team multiplied by 
-- the number of employees in the team. 
-- Calculate the total_day_charge for each team.

-- Approach:
-- multiply team size * charge_cost to get total_day_charge
-- we want a table of team name with this total_day_charge
-- this sounds like making a new col with a calculation
-- within a join (teams <- employees) to get count of employees per team
-- 4.(a) already does this join
-- so for (b), add the calculation as a new col in select
-- and remember need to convert charge_cost to INTEGER (as earlier)


SELECT 
	t.id AS team_id,
	t.name AS team_name,
	count(e.id) AS num_employees,
	t.charge_cost AS cost_per_employee,
	count(e.id) * (t.charge_cost :: INTEGER) AS total_day_charge
FROM teams AS t
	LEFT JOIN employees AS e
	ON t.id = e.team_id 
GROUP BY t.id;
-- returns 10 rows (10 teams)




-- 4.(c)

-- How would you amend your query from above to 
-- show only those teams with 
-- a total_day_charge greater than 5000

-- Approach:
-- this means adding a condition, within a GROUP BY summary table
-- so use HAVING with the calculation (not yet assigned)

SELECT 
	t.id AS team_id,
	t.name AS team_name,
	count(e.id) AS num_employees,
	t.charge_cost AS cost_per_employee,
	count(e.id) * (t.charge_cost :: INTEGER) AS total_day_charge
FROM teams AS t
	LEFT JOIN employees AS e
	ON t.id = e.team_id 
GROUP BY t.id
	HAVING (count(e.id) * (t.charge_cost :: INTEGER)) > 5000;
-- returns 5 rows, a subset of the 10 teams


-- Extension

-- Q5

-- How many of the employees serve on one or more committees?


/* 
 * Approach (after reading HINT)
 * just count distinct e.ids in the employees_committees table
 */


SELECT
	count(DISTINCT(employee_id))
FROM employees_committees;
-- 22 employees

-- longer route:
SELECT 
	employee_id,
	count(committee_id)
FROM employees_committees
GROUP BY employee_id;
-- 22 employees, 2 with 2 involvements each.


/*
 * Approach (before reading HINT):
 * 1. join employees and committees via employees_committees
 * (many-to-many with join table)
 * use employee INNER JOIN join table ON e.id = ec.employee_id
 * then LEFT JOIN committee table ON ec.committee_id = c.id
 * 2. count number of committees per employee
 * so we want full employee rows with added committee involvement
 * then a summary table of employee id to count(committees)
 * 3. filter for count(committees) > 1 
 * to find number of rows
 * and then count(employee id) to get this through code?
 */

-- ANSWER:
SELECT 	e.id, e.first_name, e.last_name, 
		count(e.id) AS num_committees 
FROM employees AS e
	INNER JOIN employees_committees AS ec 
	ON e.id = ec.employee_id
	LEFT JOIN committees AS c
	ON ec.committee_id = c.id
GROUP BY e.id
	HAVING count(e.id) > 1;
-- 2 employees, both on 2 committees each.

-- WORKINGS:

-- First, explore:

SELECT *
FROM committees;
-- there are 5 committees

SELECT *
FROM employees_committees ;
-- there are 24 committee involvements

SELECT 
	distinct(employee_id)
FROM employees_committees ;
-- there are 22 distinct employee ids in involvements

-- Then, build it up step-by-step as per approach.
-- Step 1: join:
SELECT 	e.*,
		c.*
FROM employees AS e
	INNER JOIN employees_committees AS ec 
	ON e.id = ec.employee_id
	LEFT JOIN committees AS c
	ON ec.committee_id = c.id;
-- returns 24 rows - all involvements, some employees listed multiple times

-- step 2. count number of times employee appears in the table
-- to find their number of involvements
SELECT 	e.id, e.first_name, e.last_name, 
		count(e.id) AS num_committees 
FROM employees AS e
	INNER JOIN employees_committees AS ec 
	ON e.id = ec.employee_id
	LEFT JOIN committees AS c
	ON ec.committee_id = c.id
GROUP BY e.id
	HAVING count(e.id) > 1;
-- first returns 22 employees, because 1 or 2 have >1 involvement
-- use HAVING to filter for count calculation > 1
-- now returns 2 employees, on 2 committees each


-- Q6

-- How many of the employees do not serve on a committee?

-- Approach:
-- join with the nulls, then count the nulls where each count is unique employee
-- LEFT JOIN employees to involvements; filter (group by employee having committee.id is null)

SELECT count(e.id)
FROM employees AS e
	LEFT JOIN employees_committees AS ec 
	ON e.id = ec.employee_id
-- 1002 rows: 1000 employees + 2 employees with another involvement each
-- Note: with some c.ids as NULL; we want to filter for these:
WHERE ec.id IS NULL;
-- 978 rows, select count() to just return the total.
