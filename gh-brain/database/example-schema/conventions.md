# example-schema conventions

Non-obvious conventions for this schema. Don't restate anything visible in
the DDL, only what someone would otherwise have to be told.

- _Example: "All tables use a `_ID` numeric surrogate key plus a separate
  natural-key unique constraint. Never expose the surrogate key in an API
  response."_
- _Example: "Writes go through `ddl/packages/`, never direct DML against
  tables from application code; see
  `decisions/0001-writes-through-package-api.md`."_

Add an entry when a decision doc establishes a standing convention rather
than a one-off call, and link back to the decision that justifies it.
