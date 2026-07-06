-- ====================================================================
-- RIWISUPPLY S.A.S. - PROJECT SQL SCRIPT
-- DDL (structure) + DML (data + operations) + REQUIRED QUERIES
-- Adjust table/column names as needed for your final version.
-- ====================================================================


-- ====================================================================
-- SECTION 1: DDL - DATABASE CREATION
-- ====================================================================

CREATE DATABASE bd_firstname_lastname_clan;
USE bd_firstname_lastname_clan;


-- ====================================================================
-- SECTION 2: DDL - TABLE CREATION (in dependency order)
-- ====================================================================

-- ---- Parent tables (no foreign keys) ----

CREATE TABLE riwi_cities (
    id_city INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE riwi_categories (
    id_category INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- ---- Tables that depend on the parent tables above ----

CREATE TABLE riwi_suppliers (
    id_supplier INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    id_city INT NOT NULL,
    FOREIGN KEY (id_city) REFERENCES riwi_cities(id_city)
);

CREATE TABLE riwi_products (
    id_product INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    id_category INT NOT NULL,
    FOREIGN KEY (id_category) REFERENCES riwi_categories(id_category)
);

CREATE TABLE riwi_warehouses (
    id_warehouse INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(200),
    id_city INT NOT NULL,
    FOREIGN KEY (id_city) REFERENCES riwi_cities(id_city)
);

-- ---- Bridge tables (resolve many-to-many relationships) ----

CREATE TABLE riwi_purchases (
    id_purchase INT PRIMARY KEY AUTO_INCREMENT,
    id_supplier INT NOT NULL,
    id_product INT NOT NULL,
    quantity INT NOT NULL,
    purchase_date DATE NOT NULL,
    total_value DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_supplier) REFERENCES riwi_suppliers(id_supplier),
    FOREIGN KEY (id_product) REFERENCES riwi_products(id_product)
);

CREATE TABLE riwi_inventory_movements (
    id_movement INT PRIMARY KEY AUTO_INCREMENT,
    id_product INT NOT NULL,
    id_warehouse INT NOT NULL,
    movement_type VARCHAR(10) NOT NULL,   -- 'IN' or 'OUT'
    quantity INT NOT NULL,
    movement_date DATE NOT NULL,
    FOREIGN KEY (id_product) REFERENCES riwi_products(id_product),
    FOREIGN KEY (id_warehouse) REFERENCES riwi_warehouses(id_warehouse)
);


-- ====================================================================
-- SECTION 3: DML - SAMPLE DATA LOAD (INSERT)
-- Order matters: parent tables first, then dependent tables.
-- ====================================================================

-- ---- Cities ----
INSERT INTO riwi_cities (name) VALUES
('Bogota'),
('Medellin'),
('Barranquilla');

-- ---- Categories ----
INSERT INTO riwi_categories (name) VALUES
('Hand Tools'),
('Safety Equipment'),
('Electrical Supplies');

-- ---- Suppliers ----
INSERT INTO riwi_suppliers (name, phone, email, id_city) VALUES
('Ferreteria Nacional', '3001234567', 'contacto@ferrenacional.com', 1),
('Suministros Andinos', '3009876543', 'ventas@suministrosandinos.com', 2),
('Industrias del Caribe', '3005551234', 'info@indcaribe.com', 3);

-- ---- Products ----
INSERT INTO riwi_products (name, unit_price, id_category) VALUES
('Screwdriver', 5.00, 1),
('Safety Helmet', 12.50, 2),
('Electrical Cable (meter)', 1.20, 3),
('Hammer', 8.00, 1);

-- ---- Warehouses ----
INSERT INTO riwi_warehouses (name, address, id_city) VALUES
('Central Warehouse', 'Calle 10 # 20-30', 1),
('North Warehouse', 'Carrera 45 # 12-08', 2);

-- ---- Purchases (Supplier <-> Product bridge) ----
INSERT INTO riwi_purchases (id_supplier, id_product, quantity, purchase_date, total_value) VALUES
(1, 1, 100, '2026-01-10', 500.00),
(1, 4, 50, '2026-02-05', 400.00),
(2, 2, 200, '2026-01-15', 2500.00),
(3, 3, 1000, '2026-03-01', 1200.00);

-- ---- Inventory Movements (Product <-> Warehouse bridge) ----
INSERT INTO riwi_inventory_movements (id_product, id_warehouse, movement_type, quantity, movement_date) VALUES
(1, 1, 'IN', 100, '2026-01-11'),
(1, 1, 'OUT', 20, '2026-01-20'),
(2, 2, 'IN', 200, '2026-01-16'),
(3, 1, 'IN', 1000, '2026-03-02'),
(3, 1, 'OUT', 300, '2026-03-10'),
(4, 2, 'IN', 50, '2026-02-06');


-- ====================================================================
-- SECTION 4: DML - INSERT / UPDATE / DELETE OPERATIONS REQUIRED BY THE TASK
-- ====================================================================

-- ---- INSERT: register a new supplier and its associated product ----
INSERT INTO riwi_suppliers (name, phone, email, id_city)
VALUES ('Distribuciones del Norte', '3012223344', 'contacto@distnorte.com', 2);

INSERT INTO riwi_products (name, unit_price, id_category)
VALUES ('Work Gloves', 6.50, 2);

-- ---- UPDATE: modify existing supplier information ----
UPDATE riwi_suppliers
SET phone = '3019998877', email = 'nuevoemail@distnorte.com'
WHERE name = 'Distribuciones del Norte';

-- ---- DELETE: remove a product that has NO associated movements ----
-- Safe pattern: only deletes if there's no matching row in inventory_movements
DELETE FROM riwi_products
WHERE id_product = (
    SELECT id_product FROM riwi_products WHERE name = 'Work Gloves'
)
AND NOT EXISTS (
    SELECT 1 FROM riwi_inventory_movements m
    WHERE m.id_product = riwi_products.id_product
);


-- ====================================================================
-- SECTION 5: REQUIRED BUSINESS QUERIES
-- ====================================================================

-- ---- Query 1: Available stock per product ----
-- Need: inventory manager wants current stock to plan future purchases.
SELECT
    p.name AS product_name,
    SUM(CASE WHEN m.movement_type = 'IN' THEN m.quantity ELSE -m.quantity END) AS current_stock
FROM riwi_products p
INNER JOIN riwi_inventory_movements m ON p.id_product = m.id_product
GROUP BY p.name;

-- ---- Query 2: Inventory movements with product and warehouse detail ----
-- Need: logistics supervisor wants to see movements per warehouse and product.
SELECT
    w.name AS warehouse_name,
    p.name AS product_name,
    m.movement_type,
    m.quantity,
    m.movement_date
FROM riwi_inventory_movements m
INNER JOIN riwi_products p ON m.id_product = p.id_product
INNER JOIN riwi_warehouses w ON m.id_warehouse = w.id_warehouse
ORDER BY w.name, m.movement_date;

-- ---- Query 3: Total purchased per supplier ----
-- Need: purchasing manager wants to know how much has been bought from each supplier.
SELECT
    s.name AS supplier_name,
    SUM(pu.total_value) AS total_purchased
FROM riwi_suppliers s
INNER JOIN riwi_purchases pu ON s.id_supplier = pu.id_supplier
GROUP BY s.name;

-- ---- Query 4: Number of movements registered per warehouse ----
-- Need: operations administrator wants to see which warehouses are most active.
SELECT
    w.name AS warehouse_name,
    COUNT(m.id_movement) AS total_movements
FROM riwi_warehouses w
INNER JOIN riwi_inventory_movements m ON w.id_warehouse = m.id_warehouse
GROUP BY w.name
ORDER BY total_movements DESC;

-- ---- Query 5: Product with the highest purchase volume ----
-- Need: analyst wants to identify the product with the greatest turnover.
SELECT
    p.name AS product_name,
    SUM(pu.quantity) AS total_quantity_purchased
FROM riwi_products p
INNER JOIN riwi_purchases pu ON p.id_product = pu.id_product
GROUP BY p.name
ORDER BY total_quantity_purchased DESC
LIMIT 1;

-- ---- Query 6: Total inventory value per warehouse ----
-- Need: operations manager wants the economic value of inventory per warehouse.
SELECT
    w.name AS warehouse_name,
    SUM(
        CASE WHEN m.movement_type = 'IN' THEN m.quantity ELSE -m.quantity END
        * p.unit_price
    ) AS total_inventory_value
FROM riwi_inventory_movements m
INNER JOIN riwi_products p ON m.id_product = p.id_product
INNER JOIN riwi_warehouses w ON m.id_warehouse = w.id_warehouse
GROUP BY w.name;


-- ====================================================================
-- SECTION 6: EXTRA POINTS - VIEWS
-- ====================================================================

-- View 1: current stock per product (reuses Query 1 logic)
CREATE VIEW riwi_view_stock_by_product AS
SELECT
    p.name AS product_name,
    SUM(CASE WHEN m.movement_type = 'IN' THEN m.quantity ELSE -m.quantity END) AS current_stock
FROM riwi_products p
INNER JOIN riwi_inventory_movements m ON p.id_product = m.id_product
GROUP BY p.name;

-- View 2: total purchased per supplier (reuses Query 3 logic)
CREATE VIEW riwi_view_total_by_supplier AS
SELECT
    s.name AS supplier_name,
    SUM(pu.total_value) AS total_purchased
FROM riwi_suppliers s
INNER JOIN riwi_purchases pu ON s.id_supplier = pu.id_supplier
GROUP BY s.name;

-- Usage:
SELECT * FROM riwi_view_stock_by_product;
SELECT * FROM riwi_view_total_by_supplier;


-- ====================================================================
-- SECTION 7: EXTRA POINTS - STORED PROCEDURE
-- ====================================================================

DELIMITER //

CREATE PROCEDURE riwi_get_supplier(IN p_supplier_id INT)
BEGIN
    IF p_supplier_id IS NULL THEN
        SELECT * FROM riwi_suppliers;
    ELSE
        SELECT * FROM riwi_suppliers WHERE id_supplier = p_supplier_id;
    END IF;
END //

DELIMITER ;

-- Usage:
CALL riwi_get_supplier(1);     -- returns only supplier with id_supplier = 1
CALL riwi_get_supplier(NULL);  -- returns all suppliers
