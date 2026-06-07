-- Snowflake Cortex Governance Health Check Project
-- Read-Only Governance Checks
-- These are safe metadata queries that can support the Data Governance Health Check skill.

-- -----------------------------------------------------------------------------
-- 1. Current context
-- -----------------------------------------------------------------------------
SELECT
    CURRENT_ROLE() AS current_role,
    CURRENT_DATABASE() AS current_database,
    CURRENT_SCHEMA() AS current_schema,
    CURRENT_WAREHOUSE() AS current_warehouse;

-- -----------------------------------------------------------------------------
-- 2. Check that the demo database exists and list schemas
-- -----------------------------------------------------------------------------
SHOW DATABASES LIKE 'GOVERNANCE_DEMO';
SHOW SCHEMAS IN DATABASE GOVERNANCE_DEMO;

-- -----------------------------------------------------------------------------
-- 3. List tables in the demo environment
-- -----------------------------------------------------------------------------
SHOW TABLES IN DATABASE GOVERNANCE_DEMO;

-- -----------------------------------------------------------------------------
-- 4. Describe key tables
-- -----------------------------------------------------------------------------
DESCRIBE TABLE GOVERNANCE_DEMO.RAW.CUSTOMERS;
DESCRIBE TABLE GOVERNANCE_DEMO.RAW.ORDERS;
DESCRIBE TABLE GOVERNANCE_DEMO.RAW.REGION_ACCESS;

-- -----------------------------------------------------------------------------
-- 5. List governance tags
-- -----------------------------------------------------------------------------
SHOW TAGS IN DATABASE GOVERNANCE_DEMO;

-- -----------------------------------------------------------------------------
-- 6. Get tag references for demo objects
-- -----------------------------------------------------------------------------
SELECT
    TAG_DATABASE,
    TAG_SCHEMA,
    TAG_NAME,
    TAG_VALUE,
    LEVEL,
    OBJECT_DATABASE,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COLUMN_NAME
FROM TABLE(GOVERNANCE_DEMO.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('GOVERNANCE_DEMO.RAW.CUSTOMERS', 'TABLE'))
ORDER BY OBJECT_NAME, COLUMN_NAME, TAG_NAME;

SELECT
    TAG_DATABASE,
    TAG_SCHEMA,
    TAG_NAME,
    TAG_VALUE,
    LEVEL,
    OBJECT_DATABASE,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COLUMN_NAME
FROM TABLE(GOVERNANCE_DEMO.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('GOVERNANCE_DEMO.RAW.ORDERS', 'TABLE'))
ORDER BY OBJECT_NAME, COLUMN_NAME, TAG_NAME;

-- -----------------------------------------------------------------------------
-- 7. List masking policies if available
-- -----------------------------------------------------------------------------
SHOW MASKING POLICIES IN DATABASE GOVERNANCE_DEMO;

-- -----------------------------------------------------------------------------
-- 8. List row access policies if available
-- Some Snowflake accounts/editions may not support this feature.
-- If unsupported, record it as a limitation rather than failing the review.
-- -----------------------------------------------------------------------------
SHOW ROW ACCESS POLICIES IN DATABASE GOVERNANCE_DEMO;

-- -----------------------------------------------------------------------------
-- 9. Review grants to the demo analyst role
-- -----------------------------------------------------------------------------
SHOW GRANTS TO ROLE GOVERNANCE_DEMO_ANALYST;

-- -----------------------------------------------------------------------------
-- 10. Identify sensitive-looking columns from metadata
-- -----------------------------------------------------------------------------
SELECT
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM GOVERNANCE_DEMO.INFORMATION_SCHEMA.COLUMNS
WHERE LOWER(COLUMN_NAME) LIKE '%email%'
   OR LOWER(COLUMN_NAME) LIKE '%phone%'
   OR LOWER(COLUMN_NAME) LIKE '%name%'
   OR LOWER(COLUMN_NAME) LIKE '%customer%'
   OR LOWER(COLUMN_NAME) LIKE '%account%'
   OR LOWER(COLUMN_NAME) LIKE '%balance%'
   OR LOWER(COLUMN_NAME) LIKE '%price%'
ORDER BY TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME;
