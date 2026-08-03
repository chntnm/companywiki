# Contradiction log

Every contradiction the conviction-review bot has flagged between a proposed
change and an existing decision. Appended automatically by
`.github/workflows/conviction-review.yml`; status updated by the human
reviewer on resolution.

Don't delete resolved entries. This log is itself part of the wiki's memory:
repeated contradictions on one topic signal that the underlying decision is
genuinely unsettled or under-documented, and that pattern is only visible if
the history stays.

## Format

```
### <PR #>: <short title>
- Date opened: YYYY-MM-DD
- Author: <github handle> (level N, team)
- Contradicts: <path to existing decision doc> (author: <handle>, level N)
- Conviction score at flag time: N
- Status: open | resolved
- Resolution (once resolved): supersede | reject | scope-split
- Resolution note: <one line, what was decided and why>
- Resolved by: <github handle>, YYYY-MM-DD
```

## Entries

_Seeded empty; grows as the bot runs._
