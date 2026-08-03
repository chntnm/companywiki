# gh-brain index

Code-heavy brain, three top-level categories:

```
gh-brain/
├── apps/          apps/<repo>.md (top-level summary)
│                  + apps/<repo>/ (deep dive, conventions, decisions, merge-log)
├── database/      database/<schema>.md (top-level)
│                  + database/<schema>/ (same, plus ddl/)
└── concepts/      cross-cutting, spanning more than one app or schema
```

Every entry uses the same two-tier pattern: a short top-level file for the
quick scan, a same-named deep dive one folder down for someone about to work
in that repo or schema. `concepts/` is flat, since a concept isn't scoped to
one entry to begin with.

## apps/

| Repo | Owning team | Auto-merge conviction | Top-level | Deep dive |
|---|---|---|---|---|
| example-repo | platform | unset | [apps/example-repo.md](apps/example-repo.md) | [apps/example-repo/](apps/example-repo/) |

## database/

| Schema | Owning team | Auto-merge conviction | Top-level | Deep dive |
|---|---|---|---|---|
| example-schema | platform | unset | [database/example-schema.md](database/example-schema.md) | [database/example-schema/](database/example-schema/) |

## concepts/

See [concepts/_index.md](concepts/_index.md).

## Adding an entry

- **New repo:** create `apps/<repo>.md` plus `apps/<repo>/` containing
  `<repo>.md`, `conventions.md`, `decisions/`, and `merge-log.md`. Add a row
  above, same PR.
- **New schema:** same under `database/<schema>/`, plus
  `ddl/{tables,views,packages}/`.
- **New concept:** see `concepts/_index.md`.

`auto_merge_conviction` belongs in the **top-level** file's front-matter;
that's where `governance/review-workflow.md` reads it. `merge-log.md` is
seeded empty and maintained by the sync pipeline; don't write to it by hand.
