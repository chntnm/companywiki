# companywiki PR review workflow

## Automated steps

Run on every PR, per `.github/workflows/conviction-review.yml`.

1. `service_claude` diffs the PR against `master-brain` and the target's
   existing docs, looking for contradictions
   (`governance/conviction-scoring.md` §1).
2. Computes a conviction score and posts it with rationale: what it checked
   against, what it found.
3. Applies a `conviction:N` label.
4. On a contradiction: applies the `contradiction` label, appends an entry
   to `governance/contradiction-log.md` (status `open`), and pings the
   step-5 reviewer directly rather than leaving it to be noticed.
5. Assigns a reviewer, by the PR author's team in
   `governance/hierarchy.yaml`:
   - Score ≥ 4, no contradiction → any team member other than the author
   - Score ≤ 3, or `contradiction` present, or the target is marked
     `decided_by_level: manager` → the team's manager
   - Contradiction against a decision authored *above* the author's level →
     escalate one level past that (manager → director tier), not sideways to
     a peer manager

   For bot-drafted PRs the GitHub author is `service_claude`, which has no
   roster entry, so this currently routes everything to manager review. See
   `DESIGN-REVIEW.md` D5.

## Human step

The reviewer reads the PR and the automated comment. The comment is a
starting point, not a substitute for reading the decision doc.

- **Score 4-5, no contradiction:** single approval merges.
- **Score 1-3, or `contradiction` label:** the reviewer must resolve the
  contradiction one of three ways before merging, and say which in the
  approval:
  1. **Supersede.** The new decision replaces the old. Add `Superseded-by:`
     to the old doc and `Supersedes:` to the new one.
  2. **Reject.** Close the PR, or request changes removing the
     contradicting claim.
  3. **Scope-split.** Both stand, because they apply to genuinely different
     contexts (different environments, different repos) the PR didn't make
     explicit. Require the PR to add that scoping language first.

  Then update the `governance/contradiction-log.md` entry to `resolved` with
  the resolution and date.

Merging is a human action, except the opt-in path below.

## Opt-in auto-merge

An owning team may set `auto_merge_conviction: 5` in an entry's **top-level**
front-matter (`gh-brain/apps/<repo>.md` or
`gh-brain/database/<schema>.md`). A PR touching only that entry's deep-dive
subtree, scored 5, with zero contradiction flags, then merges
automatically. Every auto-merge is logged on the merged PR (number, score,
timestamp); there is no silent auto-merge.

`sp-brain`, `master-brain`, and `gh-brain/concepts/` are never eligible,
regardless of the setting. Concepts span more than one owner by definition,
so no single team's opt-in covers them.

## Escalation ceiling

If a contradiction is flagged against a decision authored at
`director_plus` (level 5), no automated routing applies. The PR goes
directly to that author or, if they're unavailable, stays open with the
`contradiction` label until a level-5 reviewer is. This is the one case the
workflow does not try to route around.
