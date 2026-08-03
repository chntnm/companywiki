# Dependencies

Everything companywiki's automation needs to run, in one checklist. This is
the inventory; `sync/service-account.md` has the reasoning behind the
identity design, and `DESIGN-REVIEW.md` has the open questions.

## Accounts

| Account | Platform | Purpose |
|---|---|---|
| `service_claude` (GitHub App) | GitHub | Reads diffs/PRs, opens PRs, posts scores, applies labels |
| `service_claude` (Azure AD app registration) | Microsoft Graph | Reads SharePoint content, drafts pending pages |
| Anthropic API account | Claude API | Scoring, contradiction detection, summarization, drafting |

## GitHub App permissions

| Permission | Scope | Why |
|---|---|---|
| `contents: read` | All org repos | Fetch diffs for `gh-brain` intake |
| `contents: write`, `pull_requests: write` | `companywiki` only | Open PRs, push follow-up commits (merge-log, contradiction-log) |
| `pull_requests: read` | All org repos | Read merged-PR descriptions for context |
| `issues: write` | `companywiki` only | Labels, comments |
| `metadata: read` | All org repos | Baseline for any GitHub App |

Installed org-wide so the trigger can move from the per-repo caller workflow
to an org-level webhook without a second install.

## Microsoft Graph permissions

| Permission | Scope | Why |
|---|---|---|
| `Sites.Read.All` | Application | Read tracked sites/lists via delta query |
| `Sites.Selected` (write) | Only sites registered in `sp-brain/_index.md` | Create draft pages for reverse sync, without tenant-wide write |

Both require tenant admin consent, granted once.

## Secrets

| Secret | Where it lives | Consumed by |
|---|---|---|
| `SERVICE_CLAUDE_GH_TOKEN` | **Org-level**, available to every participating repo | Caller workflows via `secrets: inherit`, plus companywiki's own workflows |
| `SERVICE_CLAUDE_ANTHROPIC_API_KEY` | Org-level, same reason | Same |

Org-level is a requirement, not a preference: `secrets: inherit` passes the
*calling* repo's secrets, so a repo-scoped secret on `companywiki` alone
would never reach the caller. That means any workflow in any participating
repo can reach a token with `contents: write` on `companywiki`. See
`DESIGN-REVIEW.md` D9.

## External APIs

| API | Used for |
|---|---|
| GitHub REST/GraphQL | Fetching diffs, opening and labeling PRs, reading PR descriptions, webhook subscriptions (Option B) |
| Microsoft Graph | Delta query, page content fetch, subscription registration and renewal, draft page creation |
| Anthropic Claude API | Conviction scoring, contradiction detection, condensing diffs and SharePoint content |

No per-merge call volume or cost estimate exists yet (`DESIGN-REVIEW.md` D10).

## Infrastructure

| Component | Notes |
|---|---|
| GitHub Actions | Hosts `gh-brain-intake.yml` and `conviction-review.yml`; no server needed for Option A |
| Per-repo caller workflow | Short file, added once per repo (`sync/gh-sync-spec.md` bootstrap) |
| Webhook receiver | Option B only. Small always-on service under `service_claude` |
| Scheduled Action | Renews Graph subscriptions roughly every 20 days, regardless of activity |

## How merges are tracked

The unit of tracking is a merge to a repo's default branch, not an
individual commit. Two layers:

1. **Trigger.** The caller workflow fires on push-to-default and PR-merge.
   This is a signal, not a record.
2. **Record.** Every merge the pipeline processes gets one line in that
   entry's `merge-log.md`, linked to the merge commit and PR. Separate from
   `decisions/`, which covers only merges judged decision-worthy.

SharePoint has no equivalent to a merge; its tracking state is the delta
token and last-renewal date (currently in `sp-brain/_index.md`, though see
`DESIGN-REVIEW.md` D8 on keeping runtime state out of reviewed files).

The wiki's own changes are tracked by `companywiki`'s PR history plus
`governance/contradiction-log.md`.

## Adoption checklist, per repo

1. Add the caller workflow file (`sync/gh-sync-spec.md` bootstrap).
2. Create `gh-brain/apps/<repo>.md` and `gh-brain/apps/<repo>/` containing
   `<repo>.md`, `conventions.md`, `decisions/`, and `merge-log.md`.
3. Add a row to `gh-brain/_index.md`.

Same steps under `gh-brain/database/<schema>/` for a schema.
