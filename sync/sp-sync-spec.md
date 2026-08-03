# SharePoint → sp-brain sync spec

## Problem

SharePoint holds context no repo carries (policy, process, org-level
how-to), and it doesn't merge or push; it's edited in place. We need to
detect meaningful changes and turn them into reviewed `sp-brain` PRs, the
same way pushes become `gh-brain` PRs.

## Detection mechanism

Graph offers two relevant primitives:

1. **Webhooks (Graph subscriptions)** fire on item create/update/delete, but
   expire (~30 days for most resource types) and carry no content diff, only
   "this item changed."
2. **Delta query** (`GET /sites/{id}/drive/root/delta`) returns exactly what
   changed since the last token, with metadata, and polls cheaply.

**Use the webhook as the trigger and the delta query as the source of
truth.** The webhook is a wake-up signal; `service_claude` then runs a delta
query for the actual changed set. A scheduled Action re-registers the
subscription every 20 days, independent of activity.

## Pipeline (`sp-brain-intake`)

1. **Webhook fires** (or the scheduled poll runs as a backstop for a missed
   or expired subscription) → delta query against tracked sites/lists.
2. **Fetch changed content** per delta entry via Graph
   (`/sites/{id}/pages/{id}`, or drive item content for documents).
3. **Classify**: substantive change (policy update, new how-to) or noise
   (metadata touch, permissions change, a no-diff re-save)? Diff against the
   last-synced version of the corresponding `sp-brain` doc.

   This check does not distinguish a human edit from a page the reverse-sync
   just published, so the two directions currently form a loop. See
   `DESIGN-REVIEW.md` D1.
4. **Draft/update** `sp-brain/<topic>/*.md`: condensed summary plus a link
   to the live page. Never a full transcription (`CLAUDE.md`, condensation
   rule).
5. **Cross-check `master-brain`**: does this topic have a `gh-brain`
   counterpart the change might make stale? Flag it in the PR description
   for the reviewer to judge. `service_claude` proposes the flag; it does
   not edit `gh-brain` from an SP-sourced change.
6. **Contradiction check and conviction score**, same as the GitHub path.
7. **Open PR**. Review proceeds per `governance/review-workflow.md`,
   identically regardless of source.

## Scope of tracked sites

Only sites and lists explicitly registered in `sp-brain/_index.md` are in
scope, which keeps `service_claude`'s read surface deliberate rather than
tenant-wide. Registering a new site is a PR to that index, reviewed like
anything else.

That file currently also holds runtime state (delta token, last renewal),
which changes on every sync and does not belong in a reviewed file. See
`DESIGN-REVIEW.md` D8.

## Reverse direction (wiki → live SharePoint)

Once a `gh-brain` or `sp-brain` PR merges and `master-brain` regenerates, if
the affected page has a live SharePoint counterpart, `service_claude` drafts
the corresponding edit and creates it as a **draft page** (Graph supports
draft state) rather than publishing. A human with publish rights reviews and
publishes.

Same propose/dispose asymmetry as the code path, using SharePoint's own
draft mechanism instead of a PR.
