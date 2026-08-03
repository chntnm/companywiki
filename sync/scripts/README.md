# sync/scripts

Implementations of the pipelines in `sync/conviction-score-workflow.md`,
`sync/gh-sync-spec.md`, and `sync/sp-sync-spec.md`. The workflow files
reference these by name so the shape of the automation is concrete and
reviewable before anyone writes code against it.

## Expected scripts (not yet implemented)

- `score_pr.py`: gathers a PR diff plus related docs, calls the Claude API,
  writes `score.json`. Spec: `sync/conviction-score-workflow.md` steps 1-3.
- `post_score.py`: posts the PR comment, applies `conviction:<N>` and
  `contradiction` labels, appends `governance/contradiction-log.md` and
  pushes that commit to the PR branch. Steps 4-6.
- `assign_reviewer.py`: routes review per `governance/hierarchy.yaml` and
  `governance/review-workflow.md`.
- `gh_brain_intake.py`: GitHub-side classification and drafting from
  `sync/gh-sync-spec.md`.
- `sp_brain_intake.py`: SharePoint-side delta query, content fetch, and
  drafting from `sync/sp-sync-spec.md`.
- `regenerate_master_brain.py`: rebuilds affected `master-brain/*.md` after
  a merge, per `ARCHITECTURE.md`.

## Why these are stubs

Building them against GitHub App and Graph credentials that don't exist yet
would produce untested code nobody can run. Once `sync/service-account.md`'s
provisioning is done, implement against sandboxed test repos and sites
before pointing anything at the org.

Read `DESIGN-REVIEW.md` first. Several of these specs have unresolved design
questions that change what the code should do, notably D1 (sync loop), D2
(contradiction search scope), D5 (whose seniority is scored), and D7
(routine-merge volume).
