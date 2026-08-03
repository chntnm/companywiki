# GitHub → gh-brain sync spec

## Problem

100+ repos, growing. `service_claude` needs to know whenever any of them
merges to its default branch, without hand-maintaining bespoke automation
per repo.

## Two options, and which to start with

### Option A: thin reusable-workflow caller in every repo (recommended to start)

`companywiki` hosts a reusable workflow (`.github/workflows/gh-brain-intake.yml`,
`on: workflow_call`). Every source repo adds a short caller workflow:

```yaml
# <any-repo>/.github/workflows/notify-companywiki.yml
name: notify companywiki
on:
  push:
    branches: [main]
  pull_request:
    types: [closed]
jobs:
  notify:
    if: github.event_name == 'push' || github.event.pull_request.merged == true
    uses: <org>/companywiki/.github/workflows/gh-brain-intake.yml@main
    with:
      source_repo: ${{ github.repository }}
      sha_before:  ${{ github.event.before || github.event.pull_request.base.sha }}
      sha_after:   ${{ github.sha }}
      pr_number:   ${{ github.event.pull_request.number || '' }}
    secrets: inherit
```

Pure GitHub Actions, no external infra. One-time cost: adding this file to
100+ repos (scriptable, see bootstrap below). Ongoing cost: zero. New repos
get it at creation via the org's repo template.

`secrets: inherit` passes the *calling* repo's secrets, so
`SERVICE_CLAUDE_GH_TOKEN` must exist as an org-level secret available to
every participating repo. See `DESIGN-REVIEW.md` D9 for the blast-radius
question that raises.

### Option B: GitHub App + org-level webhook (scale-up path)

A GitHub App installed org-wide subscribes to `push` and `pull_request`
events for every repo with zero per-repo file footprint. Requires a webhook
receiver (small Azure Function / Lambda under `service_claude`) that
triggers the intake pipeline via `repository_dispatch`.

Move to this once Option A's per-repo file becomes a maintenance burden
(opt-out repos, non-standard default branches, per-repo Actions minutes).
The pipeline below is identical either way; only the trigger changes.

### Bootstrap for Option A

A one-time script that lists all org repos via
`gh api /orgs/<org>/repos --paginate`, opens an identical PR to each adding
the caller workflow, and lets repo owners merge on their own time.

## Intake pipeline (`gh-brain-intake.yml`, runs in companywiki)

Triggered with the source repo name, SHA range, and PR number as inputs.

1. **Fetch diff** for the merged PR (or push to default branch, treated the
   same way).
2. **Classify**: decision-worthy, or routine (dependency bump, formatting,
   typo)? `service_claude` makes the call. Both paths continue to step 3.5;
   only decision-worthy diffs also run step 3.
3. **Draft/update** `gh-brain/apps/<repo>/decisions/NNNN-*.md` from
   `templates/decision-template.md`, filled from the diff, PR description,
   and commit messages. Also updates the deep-dive `<repo>.md`, the
   top-level `apps/<repo>.md` (rarely), or `conventions.md` if the diff
   establishes a standing convention rather than a one-off call. Diffs to
   migration/DDL files route to the matching `gh-brain/database/<schema>/`
   tree instead.
4. **Append a merge-log entry** to that entry's `merge-log.md` for every
   merge processed, decision-worthy or not: date, merge commit link, PR
   number, one-line summary, and the step-3 decision doc if there was one.
   See `gh-brain/apps/example-repo/merge-log.md` for the format. Whether
   routine merges reach this file by PR or by direct commit is unresolved;
   see `DESIGN-REVIEW.md` D7.
5. **Contradiction check** against `master-brain` and existing `decisions/`
   (per `governance/conviction-scoring.md`). Skipped for routine merges,
   which have no decision doc to check.
6. **Open PR** to `companywiki` carrying the conviction score and
   contradiction findings (scoring mechanics in
   `sync/conviction-score-workflow.md`, same bot as the human-authored
   path). Review proceeds per `governance/review-workflow.md`.

## Note on developer-authored decision docs

When a developer writes the decision doc themselves alongside their code
change (the preferred path, see `CONTRIBUTING.md`), this pipeline still runs
on merge, but step 3 finds the existing draft and treats it as confirmation
rather than drafting from scratch. This pipeline is the safety net for
decisions made without a companion wiki PR, not the primary authoring path.
