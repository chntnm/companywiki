# companywiki

The company's LLM wiki: a living, reviewed, queryable second brain for AI
agents and humans working across every repo and SharePoint site the company
runs.

## Why this exists

An LLM's context window is small and expensive relative to everything a
company knows, so you don't feed agents raw source. You feed them a
**condensed, curated, high-signal layer** that tells the agent what matters:
decisions made, reasons why, conventions to follow, traps already hit. This
holds the distilled memory that survives after the raw diff is old news. It
is not a cache of the repos or the SharePoint sites.

Two things make that layer trustworthy rather than a mess:

1. **It's reviewed like code.** Every change goes through a PR, gets an
   automated conviction score, and a human sign-off scaled to that score, so
   contradicting decisions can't silently pile up.
2. **It's kept current automatically.** Repo merges and SharePoint edits
   produce proposed wiki updates on their own, but nothing lands without
   review.

## The three brains

```
gh-brain/      code-heavy. Three subcategories:
                 apps/       one entry per GitHub repo
                 database/   one entry per DB schema
                 concepts/   cross-cutting, spanning more than one app/schema
sp-brain/      top-level, end-user-scoped. From SharePoint: how to use
               things, process, policy, org context repos don't carry.
master-brain/  the merged view. Reconciles both into single topic pages, so
               an agent asking "how does X work" gets one page, not two
               contradicting ones.
```

`gh-brain/_index.md` has the full layout. [ARCHITECTURE.md](ARCHITECTURE.md)
covers how the three interact and how sync flows both directions.

## Using this as a developer

```
git clone git@github.com:<org>/repo-a.git
git clone git@github.com:<org>/companywiki.git
```

`repo-a` gives you the code. `companywiki/gh-brain/apps/repo-a/` gives you
the context you'd otherwise have to ask a teammate for: why the auth layer
is shaped the way it is, what was tried and rejected, what conventions this
repo holds you to.

When you make a design decision future contributors should follow, add a
decision doc under `gh-brain/apps/repo-a/decisions/` in the **same PR
cycle** as the code change. See [CONTRIBUTING.md](CONTRIBUTING.md).

## For AI agents

Read [CLAUDE.md](CLAUDE.md) first. It defines how to navigate the three
brains, how to propose an update, and the rules you must not violate.

## Map

| Path | Purpose |
|---|---|
| `gh-brain/` | Per-app and per-schema code context, decisions, conventions, merge logs, plus cross-cutting concepts |
| `sp-brain/` | Per-topic end-user and process context from SharePoint |
| `master-brain/` | Synthesized cross-brain topic pages |
| `governance/` | Hierarchy roster, conviction rubric, review workflow, contradiction log |
| `sync/` | How GitHub and SharePoint changes propagate into the wiki and back |
| `templates/` | Decision doc and PR templates |
| `.github/workflows/` | Conviction-scoring and contradiction-check automation |
| `DEPENDENCIES.md` | Accounts, access, APIs, secrets, infrastructure |
| `DESIGN-REVIEW.md` | Known gaps and open design decisions. Read before implementing |
