# service_claude account: identity and setup

`service_claude` is the single identity behind every automated action this
system takes: opening PRs, posting conviction scores, reading SharePoint,
drafting SharePoint pages. One identity, so every automated action in both
GitHub and SharePoint audit logs is attributable to the same actor and
distinguishable from human activity.

The permission tables live in `DEPENDENCIES.md`. This doc covers *why* the
identity is shaped this way and what provisioning it needs.

## GitHub side

**A GitHub App, not a personal access token.** A PAT is tied to a human and
inherits their full access; if that person leaves, the automation breaks or
keeps running under a departed account. Apps get fine-grained, repo-scoped,
auditable permissions instead.

Installed org-wide from the start, so moving to Option B in
`sync/gh-sync-spec.md` needs no second install. Option A's
reusable-workflow trigger uses the same App token via `secrets: inherit`.

Webhook subscription (Option B only): `push` and `pull_request` (closed)
events, org-wide.

## SharePoint / Microsoft Graph side

A separate Azure AD app registration, since it's a different platform, but
the same name for auditability. Permissions are **application**, not
delegated, because this runs unattended.

Write access uses `Sites.Selected` rather than tenant-wide
`Sites.ReadWrite.All`: it grants write only to specifically approved sites,
so the reverse-sync draft-page capability in `sync/sp-sync-spec.md` never
carries blanket tenant write.

`service_claude` creates Graph subscriptions on each tracked site per
`sync/sp-sync-spec.md`, with a scheduled renewal job; subscriptions expire.

## Claude API access

Its own API key and billing, separate from any individual's interactive
Claude Code usage, so automated wiki-maintenance cost is visible on its own
line item. No volume estimate exists yet; see `DESIGN-REVIEW.md` D10.

## What's out of scope for this doc

Provisioning the GitHub App and Azure AD registration requires org admin and
tenant admin action, one-time, outside what a repo can scaffold. This is the
spec for what to request, not the request itself.
