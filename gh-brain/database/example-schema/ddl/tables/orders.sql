-- example-schema.ORDERS / ORDER_ITEMS
-- Authoritative DDL. See ../../example-schema.md for entity relationships
-- and ../decisions/0001-writes-through-package-api.md for why writes to
-- these tables must go through ddl/packages/customer_pkg.sql, not direct DML.

CREATE TABLE orders (
    order_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id     NUMBER NOT NULL REFERENCES customers (customer_id),
    order_status    VARCHAR2(16)  NOT NULL DEFAULT 'PENDING'
                    CONSTRAINT chk_orders_status
                    CHECK (order_status IN ('PENDING', 'FULFILLED', 'CANCELLED')),
    placed_at       TIMESTAMP     NOT NULL DEFAULT SYSTIMESTAMP
);

CREATE TABLE order_items (
    order_item_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id        NUMBER NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    sku             VARCHAR2(64)  NOT NULL,
    quantity        NUMBER        NOT NULL CHECK (quantity > 0),
    unit_price_cents NUMBER       NOT NULL CHECK (unit_price_cents >= 0)
);

CREATE INDEX ix_orders_customer_id ON orders (customer_id);
CREATE INDEX ix_order_items_order_id ON order_items (order_id);
