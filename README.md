# RiwiSupply Database Project

## Project Description

RiwiSupply S.A.S. is a company dedicated to the commercialization and distribution of industrial supplies at a national level. Before this project, the company managed all of its information (suppliers, products, warehouses, purchases, and inventory movements) in a single unstandardized Excel file, maintained separately by different areas of the business.

This led to several data quality problems:
- Suppliers registered multiple times under different name formats.
- Duplicated or inconsistently described products.
- Warehouses with repeated or incomplete information.
- Cities written in different formats.
- No reliable way to generate operational reports.

The goal of this project is to analyze that raw data, normalize it, design a relational data model, and implement a relational database that centralizes all of RiwiSupply's information in a consistent, reliable, and query-friendly structure.

As part of this project, the following was delivered:
- Analysis and normalization of the original dataset (1NF, 2NF, 3NF).
- An Entity-Relationship Model (MER) and its corresponding diagram (DER).
- A fully implemented relational database, including DDL, constraints, and data load scripts.
- SQL scripts for data insertion, updates, and deletion.
- Six SQL queries answering real operational needs of the business.
- Two SQL views and one stored procedure as additional functionality.

## Technologies Used

- SQL (DDL, DML, DQL)
- Relational Database Management System (see *Database Engine Used* below)
- CSV files for data loading
- Draw.io for the Entity-Relationship Diagram (DER)
- Git and GitHub for version control and documentation

## Database Engine Used

MySQL / PostgreSQL *(specify the one actually used for the final implementation)*.

## Explanation of the Normalization Process

The original dataset (a single flat Excel file) mixed information about suppliers, products, categories, warehouses, cities, purchases, and inventory movements into repeated, denormalized rows. The normalization process was applied in three stages:

### Initial Structure

The raw data contained a single wide table where every row repeated supplier information, product information, and category information together, even when the same supplier or product appeared in multiple rows. Some cells also stored multiple values separated by commas, and city/category names were written inconsistently (e.g. "Bogota", "Bogotá D.C.", "BOGOTA").

### Problems Identified

- Repeating groups and non-atomic values in some columns (violation of 1NF).
- Redundant supplier and product data repeated across many rows.
- Columns that depended only on part of a composite key rather than the whole key (violation of 2NF).
- Columns that depended on other non-key columns instead of depending directly on the primary key (violation of 3NF) — for example, category name depending on category id, which itself was just an attribute of the product.
- Inconsistent text formatting for cities and categories, which needed to be standardized before being extracted into their own tables.

### Transformations Applied

**First Normal Form (1NF):** Split any multi-valued cells into individual rows, removed repeating column groups, and ensured every table had a defined primary key with atomic (single) values in every column.

**Second Normal Form (2NF):** Identified tables with composite keys (such as purchase records depending on both supplier and product) and separated attributes that depended on only part of that key into their own tables (e.g. supplier details moved out of the purchases table into a dedicated `riwi_suppliers` table).

**Third Normal Form (3NF):** Removed transitive dependencies by extracting attributes that depended on non-key columns into their own tables. Category names were moved out of the products table into a `riwi_categories` table, and city names were moved out of the suppliers/warehouses tables into a `riwi_cities` table, with foreign keys used to reference them instead of repeating the text values.

### Final Normalized Result

The dataset was split into the following independent, related entities: Cities, Categories, Suppliers, Products, Warehouses, Purchases, and Inventory Movements. Each table stores only the data that belongs to it directly, and relationships between them are handled through foreign keys rather than repeated text values.

## Database Structure

All tables use the `riwi_` prefix and English names, as required.

| Table | Description |
|---|---|
| `riwi_cities` | Cities where suppliers and warehouses are located |
| `riwi_categories` | Product categories |
| `riwi_suppliers` | Registered suppliers and their contact information |
| `riwi_products` | Products sold/distributed by the company |
| `riwi_warehouses` | Warehouses where inventory is stored |
| `riwi_purchases` | Purchases made from suppliers (bridge table between suppliers and products) |
| `riwi_inventory_movements` | Inventory movements (in/out) per product and warehouse (bridge table between products and warehouses) |

**Relationships:**
- One `city` has many `suppliers` (1:N).
- One `city` has many `warehouses` (1:N).
- One `category` has many `products` (1:N).
- Many `suppliers` sell many `products`, resolved through `riwi_purchases` (N:M).
- Many `products` are stored in many `warehouses`, resolved through `riwi_inventory_movements` (N:M).

## Entity-Relationship Model (MER / DER)

The Entity-Relationship Model was designed by identifying the business entities (Cities, Categories, Suppliers, Products, Warehouses, Purchases, Inventory Movements), their attributes, primary keys, and the cardinality of each relationship between them.

The visual diagram (DER) was built in Draw.io and is included in this repository as a PDF file: `/diagrams/riwisupply_der.pdf`.

## Instructions to Create the Database

1. Open your MySQL/PostgreSQL client (Workbench, pgAdmin, DBeaver, or the command line).
2. Create the database:
   ```sql
   CREATE DATABASE bd_[firstname]_[lastname]_[clan];
   ```
3. Select the database:
   ```sql
   USE bd_[firstname]_[lastname]_[clan];
   ```
4. Run the DDL script provided in `/sql/ddl.sql`, which creates all tables in the correct order (parent tables before tables with foreign keys), along with primary keys, foreign keys, `NOT NULL`, and `UNIQUE` constraints.

## Instructions to Load Data

1. Make sure the tables have already been created using the DDL script above.
2. Load the data in the following order to respect foreign key dependencies:
   `riwi_cities` → `riwi_categories` → `riwi_suppliers` → `riwi_products` → `riwi_warehouses` → `riwi_purchases` → `riwi_inventory_movements`.
3. Data can be loaded using either method:
   - **CSV files:** import each CSV file located in `/data` using your database client's import wizard, or the `LOAD DATA INFILE` (MySQL) / `COPY` (PostgreSQL) command.
   - **SQL scripts:** run the `INSERT` statements provided in `/sql/data_load.sql`.
4. A subset of representative records was selected for the data load (rather than the full raw Excel file) in order to clearly demonstrate that the normalized 3NF structure stores data correctly and maintains referential integrity between all related tables.

## Explanation of Each SQL Query

**Query 1 — Available stock per product**
Shows current stock for each product by calculating the difference between "in" and "out" inventory movements. Used by the inventory manager to plan future purchases.

**Query 2 — Inventory movements with product and warehouse detail**
Joins inventory movements with products and warehouses to show which products moved through which warehouse. Used by the logistics supervisor to track warehouse activity.

**Query 3 — Total purchased per supplier**
Groups purchases by supplier and sums the total value, showing how much has been bought from each one. Used by the purchasing manager to evaluate supplier spend.

**Query 4 — Number of movements registered per warehouse**
Counts inventory movements grouped by warehouse to identify which warehouses are the most active. Used by the operations administrator.

**Query 5 — Product with the highest purchase volume**
Identifies which product has the highest total quantity purchased across all suppliers, ordered from highest to lowest. Used by the analytics team to detect the product with the greatest turnover.

**Query 6 — Total inventory value per warehouse**
Multiplies stock quantity by unit price and sums it per warehouse, showing the total economic value of inventory stored at each location. Used by the operations manager.

## Additional Features (+20 pts)

- **Views:** `riwi_stock_by_product` (current stock per product) and a second view summarizing purchases per supplier, located in `/sql/views.sql`.
- **Stored Procedure:** `riwi_get_supplier(p_supplier_id)`, which returns a specific supplier when an id is provided, or all suppliers when `NULL` is passed. Located in `/sql/procedures.sql`.

## Developer Information

- **Full Name:** Andrés Felipe Giraldo Acosta
- **Clan:** *(add your clan name here)*
