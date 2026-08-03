---
owning_team: platform
---

# example-schema: deep dive

Placeholder folder; no such schema exists yet. It's here so the
`gh-brain/database/<schema>/` structure has something concrete to point at.

## Entities and relationships

_Example: `CUSTOMERS` ← `ORDERS` ← `ORDER_ITEMS`, a paragraph on each
entity's role and how they relate. The DDL is the source of truth for
*what* the shape is; this doc explains *why* it's that shape._

## Design rationale

_Example: why a column is denormalized, why a view exists instead of joining
at the app layer, why writes go through a package API. Link the decision doc
for each._

## Where to look next

- [`conventions.md`](conventions.md): naming conventions for this schema
- [`decisions/`](decisions/): schema-level design decision log
- [`merge-log.md`](merge-log.md): audit trail of processed merges. Not
  context; don't read it to answer a question
- [`ddl/tables/`](ddl/tables/), [`ddl/views/`](ddl/views/),
  [`ddl/packages/`](ddl/packages/): authoritative object definitions
