---
title: All writes to example-schema go through a PL/SQL package API, never direct DML
repo: example-schema
date: 2026-01-10
author: example-ic
author_level: 2
summary: Application code must call ddl/packages/customer_pkg.sql procedures for all writes to example-schema tables; direct INSERT/UPDATE/DELETE from app code is disallowed, because uncontrolled direct writes had bypassed validation and left orphaned ORDER_ITEMS rows.
supersedes: none
superseded_by: none
related_commits: []
related_prs: []
---

## Context

Two different app teams wrote directly to `ORDERS`/`ORDER_ITEMS` with
slightly different validation logic. One of them skipped a check the other
had, producing orphaned `ORDER_ITEMS` rows with no parent `ORDER` after a
partial failure.

## Decision

All writes to `example-schema` tables go through
`ddl/packages/customer_pkg.sql` (and future package specs for other
entities). The package enforces validation and transactional integrity in
one place. No application code issues direct DML against these tables.

## Alternatives considered

- **Enforce via DB constraints/triggers only**: rejected. Constraints catch
  some cases but not cross-table transactional integrity; triggers become
  hard to reason about across multiple write paths.
- **Shared application-layer library instead of a DB package**: rejected.
  Still requires every app in every language/runtime to adopt it correctly;
  a DB-level package is the one place all writes must pass through
  regardless of caller.

## Consequences

- New write paths require a package procedure to exist first, slightly
  slower to add a brand-new write pattern than raw SQL would be.
- Schema changes that affect writes now have exactly one place to update
  (the package), not N call sites across app repos.

## Notes for future contributors

If you're tempted to write directly to a table in this schema from app
code, that's the signal this decision was violated. Check
`ddl/packages/` first for an existing procedure, and if none fits, add one
here rather than bypassing it.
