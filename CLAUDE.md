# Instructions for AI agents operating on companywiki

You are either (a) an agent reading this wiki to answer a question, or
(b) `service_claude` proposing an update. The rules differ. Read the one
that applies.

## If you are reading this wiki to answer a question

1. **Start at `master-brain/_index.md`.** It's the synthesized layer and the
   fastest path to a correct answer. Drop into `gh-brain/apps/<repo>/`,
   `gh-brain/database/<schema>/`, `gh-brain/concepts/`, or
   `sp-brain/<topic>/` only when you need detail master-brain summarized but
   didn't reproduce.
2. **Prefer the wiki's condensed answer over reading the raw repo.** If a
   `decisions/` entry covers the question, that entry *is* the answer. Don't
   re-derive it from source. The wiki exists so you don't have to.
3. **Check supersession.** Every decision doc has `Supersedes` /
   `Superseded-by`. If the doc you found has been superseded, use the
   superseding one.
4. **Never read `merge-log.md` to answer a question.** It's an append-only
   audit trail of what the pipeline has processed, not context. It can run
   to thousands of lines and will crowd out the docs that hold the answer.
5. **If two docs conflict and neither marks the other superseded**, that's a
   live contradiction review missed. Don't silently pick one. Surface it,
   and log it in `governance/contradiction-log.md` if you're able to.
6. **Never treat `sp-brain` and `gh-brain` as interchangeable depth.**
   `sp-brain` answers "how do I use this / what's the policy"; `gh-brain`
   answers "why is the code shaped this way." Don't cite one for a question
   belonging to the other.

## If you are `service_claude` proposing a wiki update

1. **You never write directly to `master-brain/`.** It's regenerated after a
   `gh-brain` or `sp-brain` PR lands. Propose changes to those only.
2. **You never treat your own conviction score as final.** You compute and
   post it (see `governance/conviction-scoring.md`) as a recommendation. A
   human merges. The one exception is the opt-in auto-merge path in
   `governance/review-workflow.md`, and even those are logged.
3. **Search for contradictions before drafting.** Query `master-brain/` and
   the relevant `decisions/` for existing decisions on the subject first. If
   you find a conflict, say so in the PR description. Don't bury it in the
   diff for the human to find.
4. **Use `templates/decision-template.md` for every decision doc**, and fill
   `Context` and `Consequences` honestly, tradeoffs included. A doc that
   records "we did X" without "because Y, at the cost of Z" fails its
   purpose.
5. **Condense, don't transcribe.** An entry sourced from a 40-file diff or a
   long SharePoint page should be a short, high-signal summary plus a link
   back to the source. If you can't compress it, you haven't understood it.
6. **Route review per `governance/hierarchy.yaml` and
   `governance/review-workflow.md`.** Don't self-select a reviewer.
7. **Flag contradictions with a more senior author's prior decision; don't
   resolve them.** You may propose the change, but lower the conviction
   score accordingly and name whose decision it contradicts and why you
   think it should change. Resolution is a human call.

## Hard constraints (both modes)

- Never fabricate a decision, convention, or SharePoint source. If the wiki
  is silent on something, say it's silent. Don't present inference as
  recorded fact.
- Never merge a companywiki PR yourself, outside the opt-in auto-merge path.
- Never edit `governance/hierarchy.yaml`; it is human-owned.
