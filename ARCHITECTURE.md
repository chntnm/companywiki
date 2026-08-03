# Architecture

## The three brains

```mermaid
flowchart LR
    subgraph Sources
        GH[100+ GitHub repos]
        SP[SharePoint sites]
    end

    subgraph companywiki
        GHB[gh-brain\ncode-heavy, repo-scoped]
        SPB[sp-brain\ntop-level, end-user-scoped]
        MB[master-brain\nsynthesized, cross-referenced]
    end

    GH -- push / PR merge --> GHB
    SP -- page edit --> SPB
    GHB -- merge --> MB
    SPB -- merge --> MB
    MB -- relevant diff --> SP
    MB -- relevant diff --> GHB
```

`gh-brain` and `sp-brain` are the two inputs. `master-brain` is the only
place topics get unified, and the layer most queries should hit.

### Why keep gh-brain and sp-brain separate

Different depth, different audience, different owner:

- **gh-brain** is code-heavy: the architecture of a service, why a schema is
  shaped as it is, a decision log per repo. For someone about to touch that
  repo's code. Sourced from pushes and PRs.
- **sp-brain** is top-level: how to use a system, process and policy, org
  context with no natural home in any one repo. For someone who needs the
  *what/how*, not the *why this line of code*. Sourced from SharePoint.

One flat wiki would mean every query wades through the wrong depth half the
time. Keeping them apart lets each stay tuned to its audience;
`master-brain` stitches them per topic when a query spans both.

### Why master-brain is synthesized, not hand-written

"How does the billing service work" has a code-level answer in
`gh-brain/apps/billing-service/` and a policy-level answer in
`sp-brain/billing-process/`. `master-brain/billing.md` cites and reconciles
both. Generating it beats hand-maintaining it, because keeping a third copy
manually in sync with two live sources is exactly the staleness this system
exists to prevent.

## Data flow: GitHub → wiki → SharePoint

```mermaid
sequenceDiagram
    participant Repo as Any GH repo
    participant Bot as service_claude sync bot
    participant Wiki as companywiki (PR)
    participant Human as Reviewer
    participant SP as SharePoint

    Repo->>Bot: push to default branch / PR merged
    Bot->>Bot: summarize diff, draft/update gh-brain doc
    Bot->>Wiki: open PR: gh-brain/apps/<repo>/... + conviction score
    Bot->>Wiki: check master-brain for contradictions
    Wiki->>Human: assign reviewer per governance/review-workflow.md
    Human->>Wiki: approve / request changes
    Wiki->>Wiki: merge -> regenerate affected master-brain page(s)
    Wiki->>Bot: if the page has an sp-brain counterpart, draft SP delta
    Bot->>SP: open draft page for human sign-off
```

**Key point:** the bot never publishes to SharePoint. It drafts; a human
with publish rights accepts. Same asymmetry as code review: automation
proposes, a human with standing disposes.

## Data flow: SharePoint → wiki → GitHub (only when code-relevant)

```mermaid
sequenceDiagram
    participant SP as SharePoint
    participant Bot as service_claude sync bot
    participant Wiki as companywiki (PR)
    participant Human as Reviewer

    SP->>Bot: Graph delta query detects page change
    Bot->>Bot: summarize change, draft/update sp-brain doc
    Bot->>Wiki: open PR: sp-brain/<topic>/... + conviction score
    Bot->>Wiki: check master-brain for a gh-brain counterpart
    alt topic touches a repo's documented behavior
        Bot->>Wiki: also flag gh-brain/apps/<repo>/... as possibly stale
    end
    Wiki->>Human: review (same workflow as GitHub-sourced PRs)
    Human->>Wiki: approve / request changes
    Wiki->>Wiki: merge -> regenerate master-brain page(s)
```

These two flows form a cycle, and nothing currently breaks it: a wiki merge
drafts a SharePoint edit, publishing it fires the webhook, and the resulting
delta looks like a fresh human change. See `DESIGN-REVIEW.md` D1 before
implementing either direction.
