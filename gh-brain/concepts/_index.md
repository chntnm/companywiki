# concepts index

Cross-cutting engineering concepts spanning more than one app or schema:
"how multi-tenancy works across services," "the event-driven backbone," "the
auth token flow." A concept living entirely inside one repo belongs in that
repo's `apps/<repo>/` docs. This folder is for knowledge with no single
natural home.

Concept docs are structured like decision docs, because most cross-cutting
concepts *are* a standing architectural decision, just one touching several
apps rather than one repo.

| Concept | Spans | Doc |
|---|---|---|
| Multi-tenancy model | apps/example-repo, database/example-schema | [multi-tenancy-model.md](multi-tenancy-model.md) |

To add one: create `concepts/<slug>.md` from
`../../templates/decision-template.md`, replacing front-matter `repo:` with
a `spans:` list, and add a row here. (A dedicated concept template would be
cheaper than hand-editing the decision one each time; see
`DESIGN-REVIEW.md` D14.)

Note that `concepts/` is not currently in the contradiction check's search
scope, which is a gap given these are the decisions most likely to be
contradicted. See `DESIGN-REVIEW.md` D2.
