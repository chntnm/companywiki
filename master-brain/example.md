---
title: "Example topic: synthesized view"
generated_from:
  - gh-brain/apps/example-repo/decisions/0001-job-queue-standardization.md
  - sp-brain/example-topic/refunds.md
regenerated: 2026-01-20
---

# Example topic

_Placeholder page. It shows what `master-brain` output looks like once
regeneration runs._

## Code-level (from gh-brain/apps/example-repo)

Background and scheduled jobs in `example-repo` go through the
`jobs/queue.py` wrapper, not raw cron. See
[the decision](../gh-brain/apps/example-repo/decisions/0001-job-queue-standardization.md)
for why: a raw cron job failed silently for two weeks, and retries and
alerting weren't consistent across entries.

## Process-level (from sp-brain/example-topic)

Refunds under $500 are approved by any support lead; $500 and over requires
finance sign-off. See
[refunds.md](../sp-brain/example-topic/refunds.md).

## Reconciliation notes

These two sources don't overlap in claim, one being a code convention and
the other a process policy; this page mainly demonstrates the format. A real
synthesized page must call out explicitly when its sources make competing
claims about the same fact, say which wins, and link the
`governance/contradiction-log.md` entry if it was flagged during review.
