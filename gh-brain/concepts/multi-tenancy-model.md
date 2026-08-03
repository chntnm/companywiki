---
title: Multi-tenancy model
spans:
  - apps/example-repo
  - database/example-schema
date: 2026-01-18
author: example-manager
author_level: 4
summary: Tenant isolation is enforced at the schema layer via a mandatory tenant_id column plus row-level security, not by giving each tenant a separate schema or database.
supersedes: none
superseded_by: none
---

# Multi-tenancy model

_Placeholder concept doc. It shows what belongs in `concepts/` rather than
one app's or schema's docs: this topic touches both `apps/example-repo` (how
the app sets tenant context per request) and `database/example-schema` (how
isolation is enforced at the data layer), so it has no single natural home._

## Context

Early prototypes gave each tenant a separate schema. That stopped scaling
once tenant count passed the double digits: every schema migration became
an N-times operation, and cross-tenant reporting required querying N
schemas.

## Decision (the shape of the concept)

Every tenant-scoped table carries a `tenant_id` column, and row-level
security policies (see `database/example-schema/ddl/tables/` for where this
is applied) enforce that a session can only see rows for its own tenant.
Application code (see `apps/example-repo/`) sets tenant context once per
request at the top of the request lifecycle; nothing below that layer needs
to remember to filter by tenant manually.

## Consequences

- A single missed row-level security policy on a new table is a real
  cross-tenant data leak risk. New tables in any tenant-scoped schema must
  add the policy as part of the same PR that adds the table, not as a
  follow-up.
- Migrations are now single-schema operations again, and cross-tenant
  reporting is a single query with a `GROUP BY tenant_id` instead of N
  queries.

## Notes for future contributors

If you're adding a new tenant-scoped table anywhere, the row-level security
policy is the entire enforcement mechanism this concept depends on, not
optional boilerplate. Check `database/example-schema/ddl/tables/` for the
pattern before adding a new one.
