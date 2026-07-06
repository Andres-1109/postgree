-- ============================================================
-- SQL CHEAT SHEET
-- A reference guide for basic to intermediate SQL queries
-- Explanations in simple English, organized by section
-- ============================================================


-- ============================================================
-- 1. BASIC QUERIES (SELECT)
-- ============================================================

-- SELECT: choose which columns you want to see
SELECT column1, column2 FROM table_name;

-- SELECT *: get ALL columns (use only when you really need everything)
SELECT * FROM table_name;

-- WHERE: filter rows based on a condition
SELECT * FROM employees WHERE department = 'Sales';

-- ORDER BY: sort results (ASC = ascending, DESC = descending, default is ASC)
SELECT * FROM employees ORDER BY salary DESC;

-- LIMIT: only return a set number of rows (MySQL/PostgreSQL)
SELECT * FROM employees LIMIT 5;

-- TOP: same idea as LIMIT, but used in SQL Server
SELECT TOP 5 * FROM employees;

-- DISTINCT: remove duplicate values from results
SELECT DISTINCT department FROM employees;


-- ============================================================
-- 2. FILTERS AND LOGIC
-- ============================================================

-- Comparison operators: =, <>, >, <, >=, <=
SELECT * FROM employees WHERE salary > 3000;

-- AND: both conditions must be true
SELECT * FROM employees WHERE department = 'Sales' AND salary > 3000;

-- OR: at least one condition must be true
SELECT * FROM employees WHERE department = 'Sales' OR department = 'IT';

-- NOT: reverses a condition
SELECT * FROM employees WHERE NOT department = 'Sales';

-- BETWEEN: value falls inside a range (inclusive)
SELECT * FROM employees WHERE salary BETWEEN 2000 AND 5000;

-- IN: value matches any item in a list (shortcut for multiple ORs)
SELECT * FROM employees WHERE department IN ('Sales', 'IT', 'HR');

-- LIKE: pattern matching for text
-- % means "any number of characters", _ means "exactly one character"
SELECT * FROM employees WHERE name LIKE 'A%';      -- starts with A
SELECT * FROM employees WHERE name LIKE '%ez';     -- ends with ez
SELECT * FROM employees WHERE name LIKE '_ohn';    -- 4 letters, ends in "ohn" (John)

-- IS NULL / IS NOT NULL: checking for empty/missing values
-- NOTE: you can't use "= NULL", it doesn't work in SQL
SELECT * FROM employees WHERE manager_id IS NULL;
SELECT * FROM employees WHERE manager_id IS NOT NULL;


-- ============================================================
-- 3. AGGREGATE FUNCTIONS (summarizing data)
-- ============================================================

-- COUNT: how many rows match
SELECT COUNT(*) FROM employees;

-- SUM: adds up numeric values
SELECT SUM(salary) FROM employees;

-- AVG: average value
SELECT AVG(salary) FROM employees;

-- MIN / MAX: smallest / largest value
SELECT MIN(salary), MAX(salary) FROM employees;

-- GROUP BY: split rows into groups, then apply aggregate functions per group
-- Example: total salary PER department (not the whole company)
SELECT department, SUM(salary)
FROM employees
GROUP BY department;

-- HAVING: like WHERE, but filters AFTER grouping (WHERE can't filter aggregates)
-- Example: only show departments where total salary > 10000
SELECT department, SUM(salary) AS total_salary
FROM employees
GROUP BY department
HAVING SUM(salary) > 10000;

-- KEY DIFFERENCE:
-- WHERE filters individual rows BEFORE grouping
-- HAVING filters groups AFTER grouping (used with GROUP BY)


-- ============================================================
-- 4. JOINS (combining data from multiple tables)
-- ============================================================

-- INNER JOIN: only returns rows that match in BOTH tables
SELECT employees.name, departments.department_name
FROM employees
INNER JOIN departments ON employees.department_id = departments.id;

-- LEFT JOIN: returns ALL rows from the left table,
-- plus matching rows from the right table (NULL if no match)
SELECT employees.name, departments.department_name
FROM employees
LEFT JOIN departments ON employees.department_id = departments.id;

-- RIGHT JOIN: returns ALL rows from the right table,
-- plus matching rows from the left table (NULL if no match)
SELECT employees.name, departments.department_name
FROM employees
RIGHT JOIN departments ON employees.department_id = departments.id;

-- SELF JOIN: joining a table with itself
-- Example: find employees and their managers (both stored in "employees" table)
SELECT e.name AS employee, m.name AS manager
FROM employees e
INNER JOIN employees m ON e.manager_id = m.id;

-- JOIN vs SUBQUERY:
-- JOIN combines columns from two tables side by side in one result.
-- A subquery runs a query INSIDE another query, usually to filter or check something,
-- without necessarily bringing in extra columns.


-- ============================================================
-- 5. SUBQUERIES (a query inside another query)
-- ============================================================

-- Subquery in WHERE: filter based on the result of another query
SELECT name FROM employees
WHERE department_id = (SELECT id FROM departments WHERE department_name = 'Sales');

-- Subquery in SELECT: bring in a calculated value per row
SELECT name,
       (SELECT AVG(salary) FROM employees) AS company_avg_salary
FROM employees;

-- EXISTS: checks if a subquery returns ANY rows (true/false), very efficient
SELECT name FROM employees e
WHERE EXISTS (
    SELECT 1 FROM departments d WHERE d.id = e.department_id
);

-- NOT EXISTS: opposite of EXISTS, checks that NO matching rows exist
SELECT name FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM departments d WHERE d.id = e.department_id
);


-- ============================================================
-- 6. USEFUL FUNCTIONS
-- ============================================================

-- String concatenation (syntax varies by database)
SELECT first_name || ' ' || last_name AS full_name FROM employees; -- PostgreSQL
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM employees; -- MySQL/SQL Server

-- Date functions (basic examples, syntax varies by database)
SELECT EXTRACT(YEAR FROM hire_date) FROM employees;  -- PostgreSQL
SELECT YEAR(hire_date) FROM employees;                -- MySQL/SQL Server

-- DATEDIFF: difference between two dates (SQL Server / MySQL style varies)
SELECT DATEDIFF(day, hire_date, CURRENT_DATE) AS days_employed FROM employees;

-- CASE WHEN: like an IF/ELSE inside a query
SELECT name,
    CASE
        WHEN salary >= 5000 THEN 'High'
        WHEN salary >= 2000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_range
FROM employees;


-- ============================================================
-- 7. MODIFYING DATA (INSERT, UPDATE, DELETE)
-- ============================================================

-- INSERT: add a new row
INSERT INTO employees (name, department, salary)
VALUES ('Andres', 'IT', 3500);

-- UPDATE: change existing data
-- WARNING: always use WHERE, or you'll update EVERY row in the table
UPDATE employees
SET salary = 4000
WHERE name = 'Andres';

-- DELETE: remove rows
-- WARNING: always use WHERE, or you'll delete EVERY row in the table
DELETE FROM employees
WHERE name = 'Andres';

-- DELETE vs TRUNCATE:
-- DELETE removes rows one by one, can use WHERE, can be rolled back (in a transaction),
-- and keeps the table structure + auto-increment counters.
-- TRUNCATE removes ALL rows at once, is faster, CANNOT use WHERE,
-- and usually resets auto-increment counters. Harder to undo.


-- ============================================================
-- 8. DATABASE DESIGN: ENTITIES, MER AND DER
-- ============================================================
-- Before writing any SQL to CREATE a database, you design it on paper first.
-- This is NOT SQL code, it's the thinking process that comes before it.

-- ENTITY: a "thing" the business needs to store data about.
-- Usually a noun: Supplier, Product, Warehouse, Customer, Order.
-- Each entity becomes ONE table.

-- ATTRIBUTE: a piece of information about an entity.
-- Example: Product has attributes like id, name, price, category.
-- Each attribute becomes ONE column in that table.

-- MER (Entity-Relationship Model / "Modelo Entidad-Relacion"):
-- The full analysis: which entities exist, what attributes they have,
-- which one is the primary key, and how entities relate to each other.
-- This is the THINKING part, not the drawing itself.

-- DER (Entity-Relationship Diagram / "Diagrama Entidad-Relacion"):
-- The VISUAL drawing of the MER (boxes, lines, symbols).
-- Usually made in Draw.io, Lucidchart, etc. and exported as PDF/image.
-- In practice, most professors say "MER" when they really mean the diagram (DER),
-- because you normally deliver both together as one thing.

-- STEPS TO BUILD A MER/DER FOR A NEW DATABASE:
-- 1. Read the business requirements and underline the NOUNS -> these are your entities.
--    Example: "Suppliers", "Products", "Warehouses", "Categories", "Cities".
-- 2. For each entity, list its attributes (the data you need to store about it).
-- 3. Choose a PRIMARY KEY for each entity (usually an "id" column).
-- 4. Find the relationships between entities by looking for VERBS that connect nouns.
--    Example: a Supplier "sells" Products. A Product "belongs to" a Category.
-- 5. Define the CARDINALITY of each relationship:
--    - 1 to 1  (rare): one row in A relates to exactly one row in B.
--    - 1 to N  (common): one row in A relates to MANY rows in B.
--                        Example: one City has many Suppliers.
--    - N to M  (many to many): many rows in A relate to many rows in B.
--                        Example: a Supplier sells many Products,
--                        and a Product can be sold by many Suppliers.
--                        THIS ALWAYS REQUIRES AN INTERMEDIATE TABLE
--                        (also called a "bridge" or "junction" table),
--                        because a plain column can't hold "many" values.
-- 6. Draw it: boxes = entities, lines = relationships,
--    numbers/symbols on the lines = cardinality (1, N).

-- EXAMPLE (RiwiSupply style business):
-- City        (1) ---- (N) Supplier      -> one city has many suppliers
-- Category    (1) ---- (N) Product       -> one category has many products
-- Supplier    (N) ---- (M) Product       -> solved with bridge table "Purchase"
-- Product     (N) ---- (M) Warehouse     -> solved with bridge table "InventoryMovement"


-- ============================================================
-- 9. NORMALIZATION (1NF, 2NF, 3NF)
-- ============================================================
-- Normalization is the process of organizing data to remove duplication
-- and avoid weird update/delete problems. You apply it AFTER you have
-- a messy table (like a raw Excel export) and BEFORE creating final tables.

-- THE PROBLEM (a messy, non-normalized starting table):
-- | order_id | customer_name | customer_phone | product_name | product_price | quantity |
-- |    1     | Ana Gomez     | 300-123-4567    | Screwdriver  | 5.00          | 10       |
-- |    2     | Ana Gomez     | 300-123-4567    | Hammer       | 8.00          | 5        |
-- Problem: "Ana Gomez" and her phone are repeated every time she buys something.
-- If her phone changes, you'd have to update it in MANY rows -> risk of inconsistency.

-- 1NF (First Normal Form): "atomic values, no repeating groups"
-- Rules:
--   - Each column must hold ONE single value (not a list).
--     BAD:  products = "Screwdriver, Hammer, Nail"   (multiple values in one cell)
--     GOOD: one row per product instead.
--   - No repeating groups of columns (like product_1, product_2, product_3).
--   - Every row must be uniquely identifiable (needs a primary key).
-- After 1NF: the table above is already "atomic" (no comma-separated lists),
-- but it still repeats customer info -> that's fixed in 2NF.

-- 2NF (Second Normal Form): "no partial dependency"
-- Applies when a table has a COMPOSITE primary key (made of 2+ columns).
-- Rule: every non-key column must depend on the WHOLE primary key, not just PART of it.
-- Example: if the key is (order_id, product_id), but "customer_name" only depends
-- on order_id (not on product_id), that's a PARTIAL dependency -> violates 2NF.
-- Fix: split into separate tables so each column depends on its own full key:
--   Customers(customer_id, customer_name, customer_phone)
--   Orders(order_id, customer_id)
--   Products(product_id, product_name, product_price)
--   OrderDetails(order_id, product_id, quantity)

-- 3NF (Third Normal Form): "no transitive dependency"
-- Rule: non-key columns must depend ONLY on the primary key,
-- not on ANOTHER non-key column.
-- Example: if Products table has (product_id, product_name, category_id, category_name),
-- then "category_name" depends on "category_id", NOT directly on "product_id".
-- That's a transitive dependency -> violates 3NF.
-- Fix: move category info to its own table:
--   Categories(category_id, category_name)
--   Products(product_id, product_name, category_id)  -- category_id is now a FOREIGN KEY

-- SIMPLE WAY TO REMEMBER THE 3 RULES:
-- 1NF: one value per cell, no repeating columns, has a primary key.
-- 2NF: (only matters with composite keys) no column depends on just PART of the key.
-- 3NF: no column depends on another NON-KEY column, only on the primary key.


-- ============================================================
-- 10. DDL: CREATING THE DATABASE STRUCTURE
-- ============================================================
-- DDL (Data Definition Language) = the commands that build the STRUCTURE
-- (tables, keys, constraints), as opposed to DML which handles the DATA
-- (INSERT/UPDATE/DELETE, covered in section 7).

-- CREATE DATABASE: makes a new, empty database
CREATE DATABASE bd_andres_giraldo_clan;

-- Then you "enter" that database before creating tables inside it
-- (syntax varies: USE in MySQL, \c in psql command line, or just select it in your tool)
USE bd_andres_giraldo_clan;

-- CREATE TABLE: defines a table's columns, types, and rules
CREATE TABLE riwi_cities (
    id INT PRIMARY KEY AUTO_INCREMENT,   -- PRIMARY KEY = unique identifier for each row
    name VARCHAR(100) NOT NULL UNIQUE    -- NOT NULL = required, UNIQUE = no duplicates allowed
);

CREATE TABLE riwi_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE riwi_suppliers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    city_id INT NOT NULL,
    -- FOREIGN KEY: links this table to another table, enforcing that
    -- city_id here MUST already exist as an id in riwi_cities.
    -- This is what protects "referential integrity".
    FOREIGN KEY (city_id) REFERENCES riwi_cities(id)
);

CREATE TABLE riwi_products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES riwi_categories(id)
);

CREATE TABLE riwi_warehouses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(200),
    city_id INT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES riwi_cities(id)
);

-- BRIDGE / JUNCTION TABLE: needed for many-to-many relationships (see section 8).
-- A "purchase" connects ONE supplier with ONE product, but overall
-- many purchases exist, so this table resolves supplier <-> product N:M.
CREATE TABLE riwi_purchases (
    id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    purchase_date DATE NOT NULL,
    total_value DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES riwi_suppliers(id),
    FOREIGN KEY (product_id) REFERENCES riwi_products(id)
);

CREATE TABLE riwi_inventory_movements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    movement_type VARCHAR(10) NOT NULL,  -- e.g. 'IN' or 'OUT'
    quantity INT NOT NULL,
    movement_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES riwi_products(id),
    FOREIGN KEY (warehouse_id) REFERENCES riwi_warehouses(id)
);

-- WHAT EACH CONSTRAINT MEANS (cheat list):
-- PRIMARY KEY   -> uniquely identifies each row in THIS table. Cannot repeat, cannot be NULL.
-- FOREIGN KEY   -> a column that points to a PRIMARY KEY in ANOTHER table.
--                  Guarantees you can't reference something that doesn't exist
--                  (e.g. can't insert a product with a category_id that doesn't exist).
-- NOT NULL      -> this column is required, can't be left empty.
-- UNIQUE        -> no two rows can have the same value in this column
--                  (but unlike PRIMARY KEY, it CAN be NULL, and a table can have several UNIQUE columns).
-- AUTO_INCREMENT / SERIAL (PostgreSQL) -> automatically generates the next number (1, 2, 3...) for the id.

-- ALTER TABLE: modify a table AFTER it's already created
ALTER TABLE riwi_products ADD COLUMN description VARCHAR(255);   -- add a new column
ALTER TABLE riwi_products DROP COLUMN description;               -- remove a column
ALTER TABLE riwi_products RENAME COLUMN unit_price TO price;      -- rename a column

-- DROP TABLE: deletes the entire table (structure + data). Be very careful.
DROP TABLE riwi_products;


-- ============================================================
-- 11. VIEWS (saved, reusable queries)
-- ============================================================
-- A VIEW is like a "virtual table": it saves a SELECT query under a name,
-- so instead of rewriting a complex query every time, you just query the view
-- like it was a normal table. It does NOT store data itself, it just
-- runs the underlying query each time you use it.

-- CREATE VIEW: define it once
CREATE VIEW riwi_stock_by_product AS
SELECT p.name AS product_name,
       SUM(CASE WHEN m.movement_type = 'IN' THEN m.quantity ELSE -m.quantity END) AS current_stock
FROM riwi_products p
INNER JOIN riwi_inventory_movements m ON p.id = m.product_id
GROUP BY p.name;

-- Using the view afterwards is as simple as querying a table:
SELECT * FROM riwi_stock_by_product;

-- Why use views:
-- - Simplifies repeated complex queries (write the JOIN/GROUP BY logic once).
-- - Can restrict access to only certain columns/rows (a form of security).
-- - Keeps your reporting queries organized and named clearly.


-- ============================================================
-- 12. STORED PROCEDURES (reusable blocks of SQL logic)
-- ============================================================
-- A STORED PROCEDURE is a saved "mini program" made of SQL statements
-- that you can call by name, optionally passing parameters to it.
-- Useful for logic you'll run often, like "get supplier info by id,
-- or all suppliers if no id is given".

-- Example (MySQL syntax) -- a procedure that receives a supplier id,
-- and if that id is NULL, returns ALL suppliers instead:
DELIMITER //

CREATE PROCEDURE riwi_get_supplier(IN p_supplier_id INT)
BEGIN
    IF p_supplier_id IS NULL THEN
        SELECT * FROM riwi_suppliers;
    ELSE
        SELECT * FROM riwi_suppliers WHERE id = p_supplier_id;
    END IF;
END //

DELIMITER ;

-- How to call/execute it:
CALL riwi_get_supplier(3);      -- returns only the supplier with id = 3
CALL riwi_get_supplier(NULL);   -- returns ALL suppliers

-- Why use stored procedures:
-- - Reuse logic without repeating the same SQL block everywhere.
-- - Can accept parameters, making them flexible (like a function in programming).
-- - Common exam/project request: "make a procedure that does X depending on the input".


-- ============================================================
-- QUICK REFERENCE: ORDER OF EXECUTION (how SQL actually processes a query)
-- ============================================================
-- This is NOT the order you write it, but the order SQL evaluates it:
-- 1. FROM       -- pick the table(s)
-- 2. JOIN       -- combine tables
-- 3. WHERE      -- filter individual rows
-- 4. GROUP BY   -- group rows
-- 5. HAVING     -- filter groups
-- 6. SELECT     -- choose columns
-- 7. ORDER BY   -- sort results
-- 8. LIMIT      -- cut down number of rows returned

-- This matters because it explains WHY you can't filter an aggregate with WHERE
-- (aggregates don't exist yet when WHERE runs) -- that's what HAVING is for.
