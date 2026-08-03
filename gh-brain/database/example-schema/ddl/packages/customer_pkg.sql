-- example-schema.CUSTOMER_PKG
-- The only sanctioned write path into CUSTOMERS / ORDERS / ORDER_ITEMS.
-- See ../../decisions/0001-writes-through-package-api.md for why direct DML
-- from application code is disallowed.

CREATE OR REPLACE PACKAGE customer_pkg AS

    PROCEDURE create_customer(
        p_customer_code IN customers.customer_code%TYPE,
        p_display_name  IN customers.display_name%TYPE,
        p_email         IN customers.email%TYPE,
        p_customer_id   OUT customers.customer_id%TYPE
    );

    PROCEDURE place_order(
        p_customer_id   IN orders.customer_id%TYPE,
        p_order_id      OUT orders.order_id%TYPE
    );

    PROCEDURE add_order_item(
        p_order_id      IN order_items.order_id%TYPE,
        p_sku           IN order_items.sku%TYPE,
        p_quantity      IN order_items.quantity%TYPE,
        p_unit_price_c  IN order_items.unit_price_cents%TYPE
    );

END customer_pkg;
/

-- Package body intentionally omitted from this example; implement per
-- decisions/0001-writes-through-package-api.md: validation + transactional
-- integrity across ORDERS/ORDER_ITEMS lives here, not in calling app code.
