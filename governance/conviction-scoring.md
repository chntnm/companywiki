# Conviction scoring rubric

Every PR against `companywiki` gets a score from 1 (high risk, needs close
review) to 5 (low risk, safe to fast-track), computed by `service_claude`
and posted as a PR comment. Mechanics in
`sync/conviction-score-workflow.md`.

**The score is advisory, not authority.** It exists to tell the human
reviewer where to spend attention, and to set the routing rule in
`governance/review-workflow.md`.

## Inputs

1. **Contradiction check**: does this conflict with an existing,
   non-superseded decision?
   - No overlap → neutral
   - Extends or agrees with an existing decision → positive
   - Contradicts one → strongly negative, and the PR description must say so
     explicitly (hard rule for `service_claude`, see `CLAUDE.md`)

   Search scope today is `master-brain` plus the target's own `decisions/`,
   which cannot see cross-repo or `concepts/` contradictions. See
   `DESIGN-REVIEW.md` D2.

2. **Author seniority vs. the author of the decision being contradicted**
   (applies only when #1 found one), from `governance/hierarchy.yaml`.
   - Author's level ≥ the original author's → less negative. A senior person
     overriding a junior's earlier call is lower-risk than the reverse
   - Author's level < the original author's → strongly negative. This is the
     "junior contradicts a manager" case that must be flagged hard

3. **Blast radius**: how many other pages link to or depend on what's being
   changed. A decision nobody references is lower risk than one load-bearing
   for five repos' conventions.

4. **Change type**: a new decision doc with no conflicts is lower risk than
   an edit altering or removing an existing decision's conclusion.

## Score bands

| Score | Meaning | Typical case |
|---|---|---|
| 5 | Safe, additive, no conflicts | New decision doc, no overlap, any author |
| 4 | Safe, minor edit or low blast radius | Convention update or clarity fix, no conflicts |
| 3 | Needs a look | Overlaps an existing decision without contradicting, or meaningful blast radius |
| 2 | Contradicts an equal-or-senior author's decision, or high blast radius | Rewriting a decision's conclusion |
| 1 | Contradicts a *more senior* author's decision | Junior-authored PR reversing a manager's documented call |

## What the score does not do

- It doesn't auto-merge anything by default. Auto-merge is opt-in per entry;
  see `governance/review-workflow.md`.
- It doesn't replace the contradiction flag. A 3 with a flagged
  contradiction is still blocked from fast-track.
