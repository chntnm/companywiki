-- example-schema.CUSTOMERS
-- Authoritative DDL. See ../../example-schema.md for entity relationships
-- and ../decisions/ for rationale behind any non-obvious shape below.

CREATE TABLE customers (
    customer_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_code   VARCHAR2(32)  NOT NULL,  -- natural key, exposed via API; customer_id is not
    display_name    VARCHAR2(200) NOT NULL,
    email           VARCHAR2(320) NOT NULL,
    status          VARCHAR2(16)  NOT NULL DEFAULT 'ACTIVE'
                    CONSTRAINT chk_customers_status
                    CHECK (status IN ('ACTIVE', 'SUSPENDED', 'CLOSED')),
    created_at      TIMESTAMP     NOT NULL DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT SYSTIMESTAMP,
    CONSTRAINT uq_customers_code UNIQUE (customer_code)
);

CREATE INDEX ix_customers_email ON customers (email);
