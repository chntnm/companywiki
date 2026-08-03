# example-schema merge log

Audit trail, not context. Every merge affecting `example-schema`'s DDL (in
the repo holding its migrations) the intake pipeline has processed. Same
mechanism and format as `gh-brain/apps/<repo>/merge-log.md`.

## Format

```
| Date | Merge | PR | Summary | Decision doc |
|---|---|---|---|---|
| YYYY-MM-DD | [<sha>](https://github.com/<org>/<migrations-repo>/commit/<sha>) | #<n> | <one line> | <path, or "-"> |
```

## Entries

| Date | Merge | PR | Summary | Decision doc |
|---|---|---|---|---|
| 2026-01-10 | [b4d1f60](https://github.com/<org>/example-migrations/commit/b4d1f60) | #88 | Added `customer_pkg` as the sanctioned write path for `CUSTOMERS`/`ORDERS`/`ORDER_ITEMS` | `decisions/0001-writes-through-package-api.md` |
| 2026-01-29 | [3e7a2b9](https://github.com/<org>/example-migrations/commit/3e7a2b9) | #91 | Added `ix_orders_customer_id` index | - |
