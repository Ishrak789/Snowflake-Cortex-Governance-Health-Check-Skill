-- Snowflake Cortex Governance Health Check Project
-- Demo Environment Setup
-- This file recreates a safe demo environment used to test the Data Governance Health Check skill.
-- Do not include production data or credentials in this file.

-- -----------------------------------------------------------------------------
-- 1. Create demo database and schemas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE DATABASE GOVERNANCE_DEMO;

CREATE OR REPLACE SCHEMA GOVERNANCE_DEMO.RAW;
CREATE OR REPLACE SCHEMA GOVERNANCE_DEMO.SECURITY;
CREATE OR REPLACE SCHEMA GOVERNANCE_DEMO.PUBLIC;

-- -----------------------------------------------------------------------------
-- 2. Create demo tables
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE GOVERNANCE_DEMO.RAW.CUSTOMERS (
    CUSTOMER_ID NUMBER(38,0),
    CUSTOMER_NAME VARCHAR,
    EMAIL VARCHAR,
    PHONE VARCHAR,
    ACCOUNT_BALANCE NUMBER(12,2),
    REGION VARCHAR,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE GOVERNANCE_DEMO.RAW.ORDERS (
    ORDER_ID NUMBER(38,0),
    CUSTOMER_ID NUMBER(38,0),
    ORDER_STATUS VARCHAR,
    TOTAL_PRICE NUMBER(12,2),
    ORDER_DATE DATE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE GOVERNANCE_DEMO.RAW.REGION_ACCESS (
    ROLE_NAME VARCHAR,
    REGION VARCHAR,
    ACCESS_LEVEL VARCHAR,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- -----------------------------------------------------------------------------
-- 3. Insert small demo data
-- -----------------------------------------------------------------------------
INSERT INTO GOVERNANCE_DEMO.RAW.CUSTOMERS
    (CUSTOMER_ID, CUSTOMER_NAME, EMAIL, PHONE, ACCOUNT_BALANCE, REGION)
VALUES
    (1, 'Demo Customer One', 'customer1@example.com', '555-0101', 1200.50, 'NORTH'),
    (2, 'Demo Customer Two', 'customer2@example.com', '555-0102', 875.25, 'SOUTH'),
    (3, 'Demo Customer Three', 'customer3@example.com', '555-0103', 2140.00, 'WEST');

INSERT INTO GOVERNANCE_DEMO.RAW.ORDERS
    (ORDER_ID, CUSTOMER_ID, ORDER_STATUS, TOTAL_PRICE, ORDER_DATE)
VALUES
    (101, 1, 'SHIPPED', 150.00, CURRENT_DATE()),
    (102, 2, 'PENDING', 89.99, CURRENT_DATE()),
    (103, 3, 'CANCELLED', 45.50, CURRENT_DATE());

INSERT INTO GOVERNANCE_DEMO.RAW.REGION_ACCESS
    (ROLE_NAME, REGION, ACCESS_LEVEL)
VALUES
    ('GOVERNANCE_DEMO_ANALYST', 'NORTH', 'READ'),
    ('GOVERNANCE_DEMO_ANALYST', 'SOUTH', 'READ'),
    ('GOVERNANCE_DEMO_ANALYST', 'WEST', 'READ');

-- -----------------------------------------------------------------------------
-- 4. Create governance tags
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TAG GOVERNANCE_DEMO.SECURITY.SENSITIVITY
    COMMENT = 'Sensitivity classification for demo governance health checks';

CREATE OR REPLACE TAG GOVERNANCE_DEMO.SECURITY.DATA_DOMAIN
    COMMENT = 'Business domain classification for demo governance health checks';

-- -----------------------------------------------------------------------------
-- 5. Apply demo tags
-- -----------------------------------------------------------------------------
ALTER TABLE GOVERNANCE_DEMO.RAW.CUSTOMERS
    SET TAG GOVERNANCE_DEMO.SECURITY.DATA_DOMAIN = 'CUSTOMER';

ALTER TABLE GOVERNANCE_DEMO.RAW.ORDERS
    SET TAG GOVERNANCE_DEMO.SECURITY.DATA_DOMAIN = 'ORDER';

ALTER TABLE GOVERNANCE_DEMO.RAW.CUSTOMERS MODIFY COLUMN EMAIL
    SET TAG GOVERNANCE_DEMO.SECURITY.SENSITIVITY = 'HIGH';

ALTER TABLE GOVERNANCE_DEMO.RAW.CUSTOMERS MODIFY COLUMN PHONE
    SET TAG GOVERNANCE_DEMO.SECURITY.SENSITIVITY = 'HIGH';

ALTER TABLE GOVERNANCE_DEMO.RAW.CUSTOMERS MODIFY COLUMN CUSTOMER_NAME
    SET TAG GOVERNANCE_DEMO.SECURITY.SENSITIVITY = 'MEDIUM';

ALTER TABLE GOVERNANCE_DEMO.RAW.CUSTOMERS MODIFY COLUMN ACCOUNT_BALANCE
    SET TAG GOVERNANCE_DEMO.SECURITY.SENSITIVITY = 'LOW';

-- Intentionally leave ORDERS.TOTAL_PRICE without a SENSITIVITY tag
-- so the skill can detect incomplete sensitivity tagging.

-- -----------------------------------------------------------------------------
-- 6. Create a demo analyst role and broad grants
-- -----------------------------------------------------------------------------
CREATE OR REPLACE ROLE GOVERNANCE_DEMO_ANALYST;

GRANT USAGE ON DATABASE GOVERNANCE_DEMO TO ROLE GOVERNANCE_DEMO_ANALYST;
GRANT USAGE ON SCHEMA GOVERNANCE_DEMO.RAW TO ROLE GOVERNANCE_DEMO_ANALYST;
GRANT USAGE ON SCHEMA GOVERNANCE_DEMO.PUBLIC TO ROLE GOVERNANCE_DEMO_ANALYST;
GRANT USAGE ON SCHEMA GOVERNANCE_DEMO.SECURITY TO ROLE GOVERNANCE_DEMO_ANALYST;

GRANT SELECT ON ALL TABLES IN SCHEMA GOVERNANCE_DEMO.RAW TO ROLE GOVERNANCE_DEMO_ANALYST;
GRANT SELECT ON FUTURE TABLES IN SCHEMA GOVERNANCE_DEMO.RAW TO ROLE GOVERNANCE_DEMO_ANALYST;

-- Note: This demo intentionally does not create masking policies or row access policies.
-- That lets the skill surface missing or unvalidated protection coverage as a finding.
