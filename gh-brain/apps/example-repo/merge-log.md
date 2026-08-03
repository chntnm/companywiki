# example-repo merge log

Audit trail, not context. Every merge to `example-repo`'s default branch the
intake pipeline has processed (`sync/gh-sync-spec.md`), decision-worthy or
not, one line each. Appended automatically; not part of the
`CONTRIBUTING.md` loop.

`decisions/` covers only merges judged decision-worthy. Agents answering
questions should read that, not this (`CLAUDE.md`, reader rule 4).

## Format

```
| Date | Merge | PR | Summary | Decision doc |
|---|---|---|---|---|
| YYYY-MM-DD | [<sha>](https://github.com/<org>/example-repo/commit/<sha>) | #<n> | <one line> | <path, or "-"> |
```

## Entries

| Date | Merge | PR | Summary | Decision doc |
|---|---|---|---|---|
| 2026-01-15 | [a1b2c3d](https://github.com/<org>/example-repo/commit/a1b2c3d) | #412 | Standardized background jobs on the `jobs/queue.py` wrapper, no more raw cron | `decisions/0001-job-queue-standardization.md` |
| 2026-01-22 | [f9e8d7c](https://github.com/<org>/example-repo/commit/f9e8d7c) | #418 | Bumped `lodash` 4.17.20 to 4.17.21 | - |
| 2026-02-03 | [7c2a9e1](https://github.com/<org>/example-repo/commit/7c2a9e1) | #423 | Added a `jobs/registry.md` entry for the nightly export job | - |
