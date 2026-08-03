# Design review

Review of the workflow as specified, 2026-08-03. The question this asks is
not "what isn't built yet" (the sync scripts are declared stubs and the
workflows say so). It's: **if someone implemented every stub faithfully to
these specs, what would still be wrong?**

Findings are split into what was fixed in this pass (factual disagreements
between files, where one was simply wrong) and what needs a design decision
before implementation starts. One item, F1, sits between the two: the
disagreement is now documented in both files, but resolving it is a design
call, tracked as D7.

---

## Fixed in this pass

These were places where two files gave different answers to the same
question. No judgment call was needed; one of them was simply wrong.

| # | Was | Now |
|---|---|---|
| F1 | `gh-brain-intake.yml` said routine diffs "produce no branch/PR (logged only)"; `gh-sync-spec.md` step 3.5 says every merge gets a merge-log line | **Documented, not resolved.** Both files now name the conflict and point at D7. The workflow still gates PR creation on a branch existing, so a routine merge's merge-log line has no path to land until D7 is decided |
| F2 | `DEPENDENCIES.md` asked for `Sites.Selected`; `service-account.md` asked for `Sites.ReadWrite.All` "scoped if possible" | Both say `Sites.Selected`. One answer for the tenant admin |
| F3 | `auto_merge_conviction` sat in the deep-dive file's front-matter; both governance docs read it from the top-level file | Moved to the top-level file, which is where the governance docs look |
| F4 | `master-brain/_index.md` said humans "generally shouldn't" hand-edit; `CLAUDE.md` made it a hard constraint | Both state it as a constraint |
| F5 | The caller-workflow snippet passed no `with:` block, but `gh-brain-intake.yml` declares `source_repo` as `required: true`. Every call would have failed validation | Snippet now passes all four inputs |

---

## Needs a decision

Ordered by severity. Each is a real gap in the design, not an
implementation detail.

### D1. Bidirectional sync has no loop break

The highest-severity gap. Trace it:

```
companywiki PR merges
  -> master-brain regenerates
  -> service_claude drafts a SharePoint page edit
  -> a human publishes it
  -> Graph webhook fires
  -> sp-brain intake sees a changed page
  -> opens a companywiki PR
  -> merges
  -> master-brain regenerates
  -> drafts another SharePoint edit ...
```

Neither `sync/gh-sync-spec.md` nor `sync/sp-sync-spec.md` mentions cycle
detection. The delta-vs-last-synced check in sp-sync step 3 is close but
not sufficient: the published page genuinely differs from the last synced
version, because the pipeline itself just changed it.

**Options:** stamp bot-originated SharePoint edits with a marker property
and skip them on intake; or record a content hash at draft time and
suppress the next delta matching it; or make the reverse-sync
write-and-record in one transaction so the write is pre-acknowledged.

### D2. Contradiction detection is structurally blind to the cases that matter most

`governance/conviction-scoring.md` §1 searches `master-brain` plus the
target's own `decisions/`. Two gaps follow from that scope:

- **Cross-repo.** `master-brain/_index.md` says a page exists only once a
  topic has content in *both* brains. So a decision in `apps/repo-a` that
  contradicts one in `apps/repo-b` has nothing to be compared against, and
  is invisible to the check.
- **Concepts.** `gh-brain/concepts/` is not in the search scope at all, yet
  concepts are described as "a standing architectural decision" spanning
  multiple apps. They are the docs most likely to be contradicted.

This undercuts the system's headline promise. The search scope needs to be
all of `gh-brain/` + `sp-brain/` + `master-brain/`, which makes the
"cheap start: grep over front-matter" path in
`sync/conviction-score-workflow.md` weaker than it looks. At 100+ repos,
semantic search over `summary:` fields is closer to day-one requirement
than scale-up option.

### D3. The wiki flattens repo permissions

100+ repos with presumably varied access controls collapse into one
`companywiki` repo. Anyone who can read the wiki can read distilled context
from every repo it covers, including ones they can't clone. For a repo
under restricted access (security tooling, anything with a compliance
boundary), the wiki becomes the side channel around it.

**Needs, at minimum:** an explicit opt-out or allowlist at the repo level,
and a decision on whether restricted repos are excluded entirely or get a
separate wiki with matching access. Worth resolving before bootstrap, since
retrofitting an exclusion after 100 repos are ingested means auditing what
already leaked.

### D4. Nothing detects staleness

An LLM wiki's failure mode is not an absent answer, it's a confidently
stale one. Today a `gh-brain` doc has no freshness signal: if merges to a
repo are classified routine for six months, the deep-dive doc keeps
claiming an architecture that may have drifted, and a reading agent has no
way to discount it.

**Suggested:** a `last_verified:` front-matter field on deep-dive and
concept docs, plus a scheduled job that flags docs whose repo has seen
merges since the last verification. `CLAUDE.md`'s reader rules should tell
agents to surface the age of what they're citing.

### D5. Bot-drafted PRs score against the wrong person's seniority

`sync/conviction-score-workflow.md` step 3 passes "the author's
`governance/hierarchy.yaml` entry." For intake-drafted PRs the GitHub
author is `service_claude`, which has no roster entry, so
`default_level: 1` applies and every bot PR routes to manager review. The
seniority weighting in `conviction-scoring.md` §2 is silently inert on the
entire automated path.

**Fix:** score against the *source* PR's author, not the wiki PR's author.
Requires the intake pipeline to carry the source author through as an
explicit input.

### D6. No deletion, rename, or archive story

Not addressed on either side:

- A repo is archived or renamed. Its `apps/<repo>/` tree stays, still
  authoritative-looking.
- A schema is dropped.
- A SharePoint page is deleted. `sp-sync-spec.md` notes delete events fire,
  then never handles them.
- A decision is reversed by simply removing the code, with no superseding
  decision doc written.

Stale context is worse than absent context here, because the reading agent
has no way to know it's stale (see D4).

### D7. Routine merges: PR-per-merge does not scale

Coupled to F1. The spec currently implies a routine merge opens a
companywiki PR touching only `merge-log.md`. At 100+ repos that is
plausibly hundreds of PRs a day, each firing `conviction-review.yml` and an
Anthropic API call, to review a line nobody reads.

**Recommended:** routine merges append to `merge-log.md` via a direct
commit to `main` by `service_claude`; only decision-worthy merges open a
PR. That needs an explicit written carve-out from `CLAUDE.md`'s "never
merge a companywiki PR yourself," on the grounds that merge-log is
machine-owned append-only audit data rather than reviewed content. State
the carve-out; don't let it be implicit.

### D8. merge-log has a write-contention and a growth problem

- **Contention:** two merges to the same repo in the same window produce
  two branches appending to the same file. The second conflicts. Batching
  per repo per window, or sharding by month
  (`merge-log/2026-08.md`), bounds this.
- **Growth:** a busy repo does thousands of merges a year. An agent reading
  `apps/<repo>/` could pull a 5,000-line audit log into the context window
  the README explicitly frames as scarce. `CLAUDE.md`'s reader section
  never mentions merge-log; it should say plainly that it is an audit
  trail, not context, and should not be read to answer questions.

### D9. `secrets: inherit` is a wider grant than it looks

In a caller workflow, `secrets: inherit` passes the *calling repo's*
secrets. So `SERVICE_CLAUDE_GH_TOKEN` has to be an org-level secret visible
to all 100+ repos, and any workflow in any of those repos can then use a
token holding `contents: write` on `companywiki`. That is an undocumented
dependency and a real blast radius.

Also unverified: whether a private `companywiki` needs "accessible from
repositories in the organization" enabled for cross-repo reusable-workflow
calls to resolve at all.

### D10. No volume or cost model

`DEPENDENCIES.md` lists three APIs and no numbers. At 100+ repos the first
question from anyone approving this is Anthropic API spend per month.
Needs a per-merge token estimate times observed merge volume, plus the
Actions-minutes figure for the per-repo caller workflow.

### D11. hierarchy.yaml has no owner or refresh cadence

It's declared human-owned and never edited by `service_claude`, which is
right, but nothing says who maintains it or how often. Consequences:

- A new hire opens a wiki PR before being added, gets `default_level: 1`,
  and any contradiction they raise scores 1 and routes to a manager.
- People on two teams, contractors, and cross-team transfers have no
  representation; the file assumes exactly one team per person.
- Nothing reconciles it against the org's actual identity source.

### D12. Supersession is specified as a rule but not as a mechanism

`hierarchy.yaml` states a decision can only be overridden by one at the
same level or higher. `review-workflow.md`'s "supersede" resolution path
never checks that rule mechanically; it relies on the reviewer remembering
it. And superseding requires editing the *old* doc to add `Superseded-by:`,
which is itself a companywiki change that gets its own conviction score,
against a doc it is by definition contradicting.

### D13. Concurrent decision numbering collides

`NNNN-short-slug.md` where NNNN is "next number in that repo's decisions
folder" breaks the moment two people branch at once: both compute `0002`,
both merge, and the folder has two `0002-` files or a merge conflict.
Date-prefixed or ULID-style filenames avoid it, at some cost to
readability.

### D14. Concepts have no template of their own

`templates/decision-template.md` requires `repo:`, but `concepts/` entries
need `spans:`. `concepts/_index.md` tells authors to mutate the template by
hand every time. A separate concept template is cheaper and less error-prone.

### D15. The repo-to-schema mapping is undefined

`sync/gh-sync-spec.md` step 3 says a diff to migration or DDL files "routes
to the matching `gh-brain/database/<schema>/` tree." Nothing anywhere
defines that mapping. Which repo's migrations belong to which schema has to
live somewhere the pipeline can read, most naturally as a
`migrations_repo:` field in each schema's top-level front-matter.

### D16. The conviction scale reads backwards

1 = alarming, 5 = safe is the opposite of the intuition most people bring to
a 1-5 scale. It is used consistently everywhere, so this is a documentation
concern rather than a defect, but expect to re-explain it to every new
contributor. Worth considering a label (`risk: high/low`) alongside the
number.
