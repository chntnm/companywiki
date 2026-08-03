-- example-schema.ACTIVE_CUSTOMERS_V
-- Read-only convenience view. Exists so app code queries one stable view
-- instead of repeating the ACTIVE filter + join everywhere. See
-- ../../example-schema.md for rationale.

CREATE OR REPLACE VIEW active_customers_v AS
SELECT
    c.customer_id,
    c.customer_code,
    c.display_name,
    c.email,
    COUNT(o.order_id) AS open_order_count
FROM customers c
LEFT JOIN orders o
    ON o.customer_id = c.customer_id
   AND o.order_status = 'PENDING'
WHERE c.status = 'ACTIVE'
GROUP BY c.customer_id, c.customer_code, c.display_name, c.email;
