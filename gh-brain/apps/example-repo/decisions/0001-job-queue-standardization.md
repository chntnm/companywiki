---
title: Standardize background jobs on the jobs/ queue wrapper instead of raw cron
repo: example-repo
date: 2026-01-15
author: example-senior
author_level: 3
summary: All background/scheduled work must go through jobs/queue.py, not raw cron entries or ad-hoc schedulers, because raw cron jobs had no shared retry/alerting and failed silently.
supersedes: none
superseded_by: none
related_commits:
  - example-repo@a1b2c3d
related_prs:
  - example-repo#412
---

## Context

Three separate raw cron entries had accumulated in this repo over a year,
each with its own ad-hoc retry logic (one had none). One of them silently
stopped running for two weeks after a host migration and nobody noticed
until a downstream report went stale.

## Decision

All background/scheduled work goes through the shared `jobs/queue.py`
wrapper, which provides retry-with-backoff, failure alerting to the
platform team's on-call channel, and a `jobs/registry.md` listing every
active job. No new raw cron entries.

## Alternatives considered

- **Keep raw cron, add monitoring per-entry**: rejected. Still requires
  remembering to add monitoring every time, which is exactly the failure
  mode that caused this.
- **Move to a hosted scheduler (e.g. a managed cron service)**: rejected
  for now. Real fix, but bigger lift than the immediate problem justified;
  revisit if `jobs/queue.py` itself becomes a bottleneck.

## Consequences

- New jobs have a small amount of boilerplate (registering with the queue
  wrapper) that raw cron didn't require.
- All job failures now page platform on-call instead of failing silently.
  Expect a short-term increase in alert volume as existing flaky jobs
  surface.

## Notes for future contributors

If you're adding a new scheduled task, start from `jobs/registry.md`'s
existing entries as a template rather than writing a new cron line. That's
the whole point of this decision.
