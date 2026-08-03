# Conviction-score bot: mechanics

The shared step both sync specs call into, and the logic behind
`.github/workflows/conviction-review.yml` for human-opened PRs. One
implementation, three trigger paths.

## Trigger

A PR opened or synchronized against `companywiki`, from any source: human,
`gh-brain` intake, `sp-brain` intake.

## Steps

1. **Gather the diff**: files touched, added, removed.
2. **Retrieve context**:
   - Current content of the target file(s), if this is an edit
   - Any existing `Supersedes`/`Superseded-by` chain
   - Related content across `master-brain/` and the target's existing docs
     (see the search note below)
3. **Call Claude** with the diff, the retrieved docs, the PR description,
   and the author's `governance/hierarchy.yaml` entry. Ask for:
   ```json
   {
     "summary": "...",
     "contradicts": [{"path": "...", "author": "...", "author_level": N, "reason": "..."}],
     "conviction_score": 1-5,
     "rationale": "..."
   }
   ```
   For intake-drafted PRs this should use the *source* PR's author, not
   `service_claude`. It currently doesn't; see `DESIGN-REVIEW.md` D5.
4. **Post** summary, score, and rationale as a PR comment.
5. **Label** `conviction:<N>`, plus `contradiction` if `contradicts` is
   non-empty.
6. **On a contradiction**, append to `governance/contradiction-log.md`
   (status `open`) as a follow-up commit to the PR branch, so the log entry
   ships with the PR it describes.
7. **Assign a reviewer** per `governance/review-workflow.md`.

## Implementation note: searching the wiki

Step 2's related-doc search has to scale past grep as the wiki grows. Two
approaches:

- **Cheap start**: keyword match over doc titles and front-matter tags. Fine
  while the wiki is young.
- **Scale-up**: embed each doc's `summary:` field (not full text) and do
  vector similarity search over the resulting index. Standard chunk, embed,
  query; the `summary:` field exists in every template precisely so this
  stays cheap when we need it.

The cheap start is weaker than it looks: it can't catch cross-repo or
cross-concept contradictions, which are the ones this system most needs to
catch. See `DESIGN-REVIEW.md` D2 before committing to it.

## Identity

Runs as `service_claude` (`sync/service-account.md`). Comments, labels, and
commits post under that account, never a human's, so the PR timeline always
shows which activity was automated.
