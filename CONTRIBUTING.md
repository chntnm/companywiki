# Contributing to companywiki

## The core loop

You're working on `repo-a` and make a design decision worth remembering,
something the next person touching this code should follow without you
telling them in person. Before you're done for the day:

```
git clone git@github.com:<org>/repo-a.git         # already have this
git clone git@github.com:<org>/companywiki.git    # alongside it
```

1. Copy `templates/decision-template.md` into
   `companywiki/gh-brain/apps/repo-a/decisions/NNNN-short-slug.md` (NNNN =
   next number in that folder). Schema decisions go under
   `companywiki/gh-brain/database/<schema>/decisions/` instead.
2. Fill it in: context, the decision, consequences and tradeoffs, and links
   to the `repo-a` commits or PR that implement it.
3. Push both PRs together and link each in the other's description. They
   don't have to merge at the same instant, but they should be reviewable
   side by side.
4. Open the companywiki PR. `service_claude` will post a conviction score
   with rationale, flag any decision it contradicts, and assign a reviewer
   per `governance/review-workflow.md`.
5. Address feedback like any other PR. On merge, `master-brain` regenerates
   and the sync pipeline appends the `merge-log.md` entry. Neither is your
   job to touch.

Don't wait for `service_claude` to write the doc for you after the fact. The
automated sync (`sync/gh-sync-spec.md`) is a safety net for decisions made
without a wiki PR (verbal, Slack), and it drafts from the diff. Writing it
yourself in the moment produces a far better doc, because you still remember
the *why*.

## What belongs in gh-brain

**Does:**
- Architectural decisions future contributors need to follow
- Non-obvious conventions: naming, layout, why a dependency won over an
  alternative
- Traps already hit ("we tried X, it broke Y, don't")
- Anything that would otherwise live only in a Slack thread or a senior
  engineer's head

**Doesn't:**
- Anything derivable by reading the code. Don't re-document what a
  well-named function already says
- Task status, sprint notes, standup content
- Company-wide policy SharePoint already owns. Link it from `sp-brain`
  instead of copying it into `gh-brain`

## Review and merge rules

Full spec in `governance/review-workflow.md`. Summary: score 4-5 with no
flagged contradiction needs one approval from anyone on the repo's team;
score 1-3, or anything flagged as contradicting a prior decision, needs
sign-off from the seniority tier `governance/hierarchy.yaml` defines for
that team.

## Style

- One decision per file. Don't bundle three unrelated decisions because they
  landed in the same PR.
- Link, don't duplicate. If `sp-brain` documents a process, link it rather
  than re-explaining it in `gh-brain`.
- Write for the next contributor, who has zero memory of this conversation.
