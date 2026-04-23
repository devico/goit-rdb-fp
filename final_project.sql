-- =========================================================
-- Final Project: Relational Databases
-- =========================================================

-- 1. Create schema and select it
CREATE SCHEMA IF NOT EXISTS pandemic;
USE pandemic;

-- ---------------------------------------------------------
-- IMPORTANT:
-- Before running import the file infectious_cases.csv into table infectious_cases using Table Data Import Wizard in MySQL Workbench.
-- ---------------------------------------------------------

-- 2. Check how many rows were imported
SELECT COUNT(*) AS total_rows
FROM infectious_cases;

-- 3. Normalization to 3NF
DROP TABLE IF EXISTS infectious_cases_normalized;
DROP TABLE IF EXISTS entities;

CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255) NOT NULL,
    code VARCHAR(50) NULL,
    UNIQUE KEY uq_entity_code (entity, code)
);

INSERT INTO entities (entity, code)
SELECT DISTINCT
    TRIM(Entity) AS entity,
    NULLIF(TRIM(Code), '') AS code
FROM infectious_cases;

CREATE TABLE infectious_cases_normalized (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    year INT NOT NULL,
    Number_yaws TEXT,
    polio_cases TEXT,
    cases_guinea_worm TEXT,
    Number_rabies TEXT,
    Number_malaria TEXT,
    Number_hiv TEXT,
    Number_tuberculosis TEXT,
    Number_smallpox TEXT,
    Number_cholera_cases TEXT,
    CONSTRAINT fk_entity_id
        FOREIGN KEY (entity_id) REFERENCES entities(id)
);

INSERT INTO infectious_cases_normalized (
    entity_id,
    year,
    Number_yaws,
    polio_cases,
    cases_guinea_worm,
    Number_rabies,
    Number_malaria,
    Number_hiv,
    Number_tuberculosis,
    Number_smallpox,
    Number_cholera_cases
)
SELECT
    e.id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e
    ON TRIM(ic.Entity) = e.entity
   AND NULLIF(TRIM(ic.Code), '') <=> e.code;

-- Check normalized tables
SELECT COUNT(*) AS entities_count
FROM entities;

SELECT COUNT(*) AS normalized_count
FROM infectious_cases_normalized;

-- Optional preview
SELECT *
FROM entities
LIMIT 10;

SELECT *
FROM infectious_cases_normalized
LIMIT 10;

-- 4. Analysis of Number_rabies
SELECT
    e.id AS entity_id,
    e.entity,
    e.code,
    ROUND(AVG(CAST(n.Number_rabies AS DECIMAL(20,4))), 2) AS avg_rabies,
    MIN(CAST(n.Number_rabies AS DECIMAL(20,4))) AS min_rabies,
    MAX(CAST(n.Number_rabies AS DECIMAL(20,4))) AS max_rabies,
    SUM(CAST(n.Number_rabies AS DECIMAL(20,4))) AS sum_rabies
FROM infectious_cases_normalized n
JOIN entities e
    ON n.entity_id = e.id
WHERE n.Number_rabies IS NOT NULL
  AND TRIM(n.Number_rabies) <> ''
GROUP BY
    e.id,
    e.entity,
    e.code
ORDER BY avg_rabies DESC
LIMIT 10;

-- 5. Built-in SQL functions:
SELECT
    entity_id,
    year,
    STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d') AS first_january_date,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    ) AS year_difference
FROM infectious_cases_normalized
LIMIT 10;

-- 6. Custom function:
DROP FUNCTION IF EXISTS year_difference_by_year;

DELIMITER //

CREATE FUNCTION year_difference_by_year(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    );
END //

DELIMITER ;

-- Use custom function
SELECT
    year,
    year_difference_by_year(year) AS year_difference
FROM infectious_cases_normalized
LIMIT 10;