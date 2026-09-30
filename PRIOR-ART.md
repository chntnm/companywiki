# Prior art: how other companies built internal knowledge bases

Companies that have published something in the same genre as the Cerebras
post: a first-party account of building an internal knowledge layer for
humans and agents. Each entry follows the same four axes so they're
comparable: **Implementation**, **Philosophy**, **How it's used**,
**How it's maintained**.

Source tiers are labelled:
- `[first-party]`: the company's own engineering/product blog
- `[first-party-pr]`: company newsroom or a vendor customer story
- `[secondary]`: third-party writeup; treat numbers as unverified

Compiled 2026-08-27.

> **Verification pass, 2026-08-27.** Every entry was re-read against its
> primary source while building the companion deck
> (`Internal-Knowledge-Bases-Prior-Art.pptx`). Where the source contradicted
> this file, the source won. Corrections made: Uber's 48.9% is a
> *helpfulness* rate, not a complete-resolution rate; Slack runs *four*
> surfaces, not three; Dropbox's latency figure is *>95% of queries in 1 to 2
> seconds*, not a p95 budget; Stripe's 83% adoption came *within months* of
> the April launch, not two weeks; Dropbox also benchmarks against MS MARCO.
> Claims that could not be re-confirmed are now marked **[unverified]**
> inline rather than deleted.

---

## Cerebras: the reference post

`[first-party]` https://www.cerebras.ai/blog/how-we-built-our-knowledge-base
by Isaac Tai, Daniel Kim and Mike Gao, 15 July 2026.

> Promoted from `[secondary]` on 2026-08-27. cerebras.ai still returns HTTP
> 500 to automated fetches from this machine; the canonical post was read
> in full from a saved local copy of the page. Detail below is the post's
> own account, not a third-party read-through.

**Implementation.** The knowledge base provides three things: a platform
for collecting and storing internal data, a platform for querying it, and a
layer enforcing authentication, authorization, auditing and analytics. At
the core is a single PostgreSQL table holding embeddings, raw summaries and
metadata from every source. Sources stay where they live (Slack, wiki, code
repos, custom databases) and only the retrieval layer is unified.
Per-source ingestion is a plugin: a team opens a PR with a small Python
module that reads from its system and emits rows in the shared schema, plus
a data-source entry.

Slack has the most elaborate pipeline. A bot in Socket Mode receives every
message event over a WebSocket; the ingest consumer resolves the thread the
message belongs to, re-fetches the entire conversation and writes it back
as **one row**, so content, participants and last-activity always reflect
the whole thread. A Postgres GIN index makes raw text keyword-searchable on
landing. Distillation then has an LLM extract a one-line searchable
question, a summary, the resolution, and the systems and code references
mentioned; *that* artifact is embedded (3,072 dims), never the raw
transcript. On top, "bursting" embeds runs of consecutive messages from one
author with the thread topic prepended, gated on IDF ≥ 4.0, ≥200
characters, or reactions.

Code repos use CocoIndex with language-specific boundaries ordered coarse
to fine (class → method → smaller blocks), so one file can yield several
embeddings at different specificity. On each commit only changed chunks are
re-embedded; sync state lives in the same Postgres. Repo onboarding is a
config file with path allowlists and denylists that teams submit themselves.

Slack retrieval fuses four signals, none trusted alone: **full-text** for
pasted error strings and flag names, **embeddings** for paraphrase, **IDF**
so rare tokens beat filler, and **age decay** so the newer thread wins a
tie. Lists are fused with RRF (`weight / (60 + rank)`, default weight 1.0),
then deduplicated at source level, capped per file, cut to a top twenty,
scored 0 to 10 by a small reranker, and cut to ten. Only then is context
expanded (e.g. the two neighbouring wiki sections) so a winning chunk keeps
its heading and caveats. Queries run through **planner** (pick from
`search`, `search_slack`, `search_code`, `subsystem_index`, `recent_prs`,
`who_knows`), **executor** (fan out in parallel, normalize to a shared
evidence schema), **synthesizer** (answer with citations and caveats).

**Philosophy.** Meet the information where it already lives. The dream of
a single source of truth "rarely works in practice," because information is
generated wherever it is ergonomic to generate it. Don't force a migration
into one rigid system; build the flexible retrieval layer instead. Distil
before embedding. Expose *low-level search primitives* over MCP rather than
one "answer this question" endpoint, keeping the tools as LLM-free as
possible, so Claude Code or any MCP agent becomes the orchestration engine
and the retrieval layer doesn't depend on its decisions to serve requests.

**How it's used.** 15,000+ questions/day within three months of launch,
making it one of the most-adopted internal tools at the company. Used by
humans, automations, and agents alike.

**How it's maintained.** Every Slack channel is its own data source, so
freshness is tunable per channel (a busy incident channel can be ingested
more often). "Projects" are lightweight named bundles of sources (channels,
repos, databases, doc spaces) referenced by many projects rather than
duplicated; new hires pick or create a default at onboarding, stored on the
user profile, so queries are scoped from day one. Ingestion plugins are
code-reviewed like any other PR. Differential sync keeps code fresh without
full reindexing.

---

## Stripe: Kai (Knowledge AI Platform)

`[first-party]` https://stripe.dev/blog/meet-stripes-knowledge-ai-platform

**Implementation.** Three layers. (1) Surface-agnostic APIs: one shared
service behind a web app, Slack, Chrome extensions, and direct API
embeds. (2) **AgentStudio**, a control plane where domain teams build,
test, and monitor their own agents, skills, and tool selections, with
built-in usage analytics. (3) Execution environment: LangChain
`deepagents`, Kubernetes sandboxing, multi-tenant virtual filesystems,
secure code execution, access-control frameworks. 1,000+ skills and tools
across internal systems, selected by a hybrid RAG/LLM approach rather than
a predefined folder hierarchy.

**Philosophy.** Three stated principles:
1. *Distributed expertise*: domain knowledge lives in specialist teams
   (GTM, Finance, Legal, Data Science), not a central platform team.
2. *Meet users in their workflows*: embed agents into existing apps rather
   than pulling people into a standalone product.
3. *Enforce implicit guardrails*: task-level isolation (e.g. no unrelated
   customer data inside one analysis) that code-based guardrails can't express.

**[unverified]** An earlier note records that they explicitly rejected two
predecessors: a no-code agent builder that hit 4,000+ agents of wildly
inconsistent quality, and coding agents (security risk when non-engineers
edit workflows). The 2026-08-27 re-read did not surface this. Confirm before
repeating it.

**How it's used.** 83% weekly active users org-wide within months of the
April launch; near-universal in GTM. 5,000+ daily data-analysis sessions.
Sessions run deep, with one reaching 932 turns. Use cases: account research,
revenue modeling, compliance review, data analysis, troubleshooting.

**How it's maintained.** Self-service. AgentStudio gives domain owners
usage data and quality signals per asset, so they tune without platform-team
involvement. Sharing the execution environment with customer-facing agents
creates a flywheel, because infra work benefits both.

**Metrics.** AEs in active-use weeks: 2x sales activity, 17% more
opportunities, 39% more deals closed. ~25,000 hours/year shifted from admin
to revenue work. **[unverified]** New hires use Kai 2.7x the cohort average.

---

## Uber: Genie (on-call copilot)

`[first-party]` https://www.uber.com/gb/en/blog/genie-ubers-gen-ai-on-call-copilot/

**Implementation.** RAG over internal wiki (Engwiki), internal Stack
Overflow, and engineering docs. OpenAI embeddings, LangChain chunking, Sia
(Uber's in-house vector DB), Terrablob for storage. A Knowledge Service
converts queries to embeddings and retrieves chunks; responses always carry
source URLs and the retrieved sub-contexts.

They chose RAG over fine-tuning for one reason they name outright: time to
market. Fine-tuning would have needed a corpus of diverse examples first.

**Philosophy.** Ground hard: instruct the model to answer *exclusively* from
provided context, and show the retrieved sub-contexts alongside the answer
so users can check it. Preserve user autonomy, so every answer offers
next-step buttons (ask follow-up, mark resolved, escalate to a human).

**How it's used.** 154 Slack channels, 70,000+ questions answered, 48.9%
helpfulness rate on answered questions, ~13,000 engineering hours saved.
**[unverified]** ~45,000 questions/month across support channels.

**How it's maintained.** A Spark ETL pipeline continuously updates: pull
from APIs, generate embeddings via PySpark UDFs, push to Terrablob.
Incremental, with no retraining. Feedback buttons (Resolved / Helpful / Not
Helpful / Not Relevant) stream through Kafka to Hive and into dashboards.
Teams run custom evals for hallucination and relevancy. Notably, an
**LLM-as-judge scores the source documents themselves** and suggests
improvements. The assistant improves the docs, not just answers from them.

**Security.** Only pre-curated, widely-accessible sources get embedded, so
sensitive material never enters the index.

---

## Slack: internal engineering assistant

`[first-party]` https://slack.engineering/empowering-engineers-with-ai/

**Implementation.** A unified internal LLM platform holding several approved
models behind one defined I/O schema, so models swap cleanly. Amazon Bedrock
Knowledge Bases vectorizes internal docs. **Four** surfaces: an emoji-triggered
Slack bot, a custom AI assistant inside Slack's own UI, a web app, and IDE
plugins. Plus a dedicated escalation bot that monitors channels and classifies
what gets posted. An earlier reading of the same post recorded six named
categories (announcements, how-to, human-action-needed, PR reviews, service
issues, unknown); the 2026-08-27 re-read confirmed the bot and the
classification but did not re-enumerate the categories.

Knowledge sources: technical documentation, historical Slack posts pulled
via the message search API, and Canvas documents.

**Philosophy.** Balance capability against security/compliance, and
customize *per team*: configurable prompts, response length, and similarity
thresholds per channel, which is their main hallucination lever.

**How it's used.** Web app carries 37% of LLM traffic, the in-Slack assistant
14%, and 65% of surveyed engineers prefer the IDE plugin surface. 4,000+
chat-turns/month at >70% satisfaction. The escalation bot runs in 25+
channels with 30% of its interactions rated five stars. ~3,000 engineering
hours/year saved from the bot alone, 10,000+ across all tooling.

**How it's maintained.** Channel-specific filters and similarity-score
thresholds are tuned per team to suppress irrelevant retrieval.

**Lessons they call out.** Hallucination and weak multi-step reasoning still
constrain complex technical use. Integrating third-party knowledge takes
substantial tuning. Keeping pace with model releases is a standing cost.

---

## Dropbox: Dash

`[first-party]` https://dropbox.tech/machine-learning/building-dash-rag-multi-step-ai-agents-business-users

Product rather than purely internal, but the architecture write-up is the
most detailed public treatment of the RAG-vs-agent split.

**Implementation.** Two tiers. Simple lookups go through RAG: hybrid
lexical search plus on-the-fly chunking and embedding-based reranking,
budgeted to answer over 95% of queries in 1 to 2 seconds. Complex multi-step
work goes to agents that **plan in code**: the planner emits a
Dropbox-internal Python-like DSL, which is validated and run in a custom
security-hardened interpreter with runtime type enforcement and static
analysis.

**Philosophy.** They built their own interpreter specifically to keep
security control and to "show the work", so agent reasoning becomes
inspectable, debuggable, and deterministically testable. The three named
trade-offs: latency vs. quality, data freshness vs. scalability, budget vs.
UX.

**How it's used.** Answers across scattered emails, docs, notes, and task
tools, spanning mixed modalities (text, images, audio, video).

**How it's maintained.** Model selection is re-run against public
benchmarks (Natural Questions, MuSiQue, MS MARCO) with custom LLM judges
scoring correctness and completeness. They stay deliberately model-agnostic.
Key lesson: prompts do not transfer between models.

---

## Elastic: Support Assistant

`[first-party]` https://www.elastic.co/blog/how-elastic-support-uses-ai-human-in-the-loop

The clearest articulation of the human-in-the-loop position.

**Implementation.** AI plays three bounded roles rather than one general
one. **(A) Research assistant**: synthesizes docs and case history into
hypotheses an engineer must validate against official sources. **(B)
Environment replication**: generates synthetic test data and mock configs
mirroring a customer's system. **(C) Solution editor**: polishes clarity,
grammar, and formatting, only *after* technical validation. **[unverified]**
The 27+ countries and 13+ languages figures.

**Philosophy.** "AI is a brilliant intern, not the CEO." Full automation is
rejected outright: AI is a co-pilot and humans keep decision authority. And
on role B, a good rule worth stealing: *AI output must replicate the shape of
the customer's system, not the customer's data.* An earlier reading of the
same post also recorded "AI provides the speed, but our human engineers
provide the nuanced judgment and accountability"; the brilliant-intern line
is the one confirmed on 2026-08-27.

**How it's maintained.** A four-step verification gate before anything is
published: check self-service history, then establish the core problem and
desired outcome, then verify against the existing knowledge base and official
documentation, then reproduce in a controlled environment where feasible.
Every response is reviewed, validated, and refined by an engineer.

---

## Morgan Stanley: AI @ Morgan Stanley Assistant / AskResearchGPT

`[first-party]` — all three read in full on 2026-09-03.
- https://www.morganstanley.com/press-releases/morgan-stanley-research-announces-askresearchgpt (23 Oct 2024)
- https://www.morganstanley.com/press-releases/key-milestone-in-innovation-journey-with-openai (14 Mar 2023)
- https://openai.com/index/morgan-stanley/ ("Morgan Stanley uses AI evals to shape the future of financial services")

> **Tier upgraded 2026-09-03.** These three pages still refuse automated
> fetch from this machine (morganstanley.com resets the connection,
> openai.com returns 403), but all three were opened in a browser and
> captured to PDF. Everything below is now read from the primary text, not
> search-surfaced. Two claims in the previous version of this section were
> wrong and are corrected below.

### Two products, not one — do not conflate them

The earlier note ran these together. They are separate systems with separate
corpora, audiences and dates.

| | AI @ Morgan Stanley Assistant | AskResearchGPT |
|---|---|---|
| Division | Wealth Management | Institutional Securities |
| Users | Financial advisors and staff | Investment Banking, Sales & Trading, Research |
| Announced | 14 Mar 2023; rolled out over the following year | 23 Oct 2024 |
| Corpus | "a corpus of 100,000 documents" (Wu, OpenAI page — his phrasing, not an inventory count) | 70,000+ proprietary research reports published annually |
| Adoption | **over 98% of advisor teams** | 3x question volume vs the predecessor tool `[secondary]` |

The >98% figure belongs to the **Assistant**, not AskResearchGPT. The deck
currently attributes it to AskResearchGPT. That is a citation error.

**Implementation.** GPT-4 retrieving against curated internal collections,
never the open web. The 2023 release is unusually explicit about the
boundary: "The solutions that Morgan Stanley Wealth Management are building
do not use ChatGPT, which leverages GPT-3.5 and generates responses from the
public internet. Morgan Stanley Wealth Management is using GPT-4 to generate
responses exclusively from internal Morgan Stanley content, with appropriate
controls." AskResearchGPT extends the earlier AskResearch chatbot by
synthesising unstructured data across multiple research products. It ships
with a Morgan-Stanley-patented one-click workflow moving findings into an
email draft, "ready to be modified and customized before sharing with their
clients," with hyperlinks to citations of the source research. **Debrief**
(Whisper + GPT-4) turns consented Zoom recordings into client notes written
straight into CRM, plus draft follow-ups; advisors review and adjust before
finalising. OpenAI operates zero data retention for them.

> Corpus figures, and how far each is load-bearing. 70,000+ reports/year is
> Research, stated flatly in the Oct 2024 release — solid. The 100,000 figure
> is Wealth Management and comes from one quote by David Wu: "We went from
> being able to answer 7,000 questions to a place where we can now
> effectively answer any question from a corpus of 100,000 documents." Read
> it carefully: the sentence is about retrieval capability improving, and
> "a corpus of 100,000 documents" is his framing of what the system can now
> handle — **not necessarily a current inventory count.** Attribute it to Wu
> rather than asserting it as the corpus size.
>
> This does partly rehabilitate the 100k figure the old note dismissed. The
> old note claimed third-party aggregators had invented it (100k vs 350k) and
> told readers to discard it in favour of 70,000. Two errors there: the two
> numbers describe different corpora, and 100k traces to a first-party quote.
> The 350k figure remains unsourced.
>
> **Not on the slide, deliberately.** Because the 100k figure is only as firm
> as Wu's phrasing, the rebuilt deck (2026-09-03) does not show it. Slide 15
> carries 70,000+ reports/year and the 20%→80% document-access jump instead,
> both of which are stated flatly rather than framed inside a quote. The
> figure is recorded here so it is available if asked; it is not missing from
> the deck by oversight.

**Philosophy.** The curated, pre-vetted corpus is the control, not prompt
engineering or model choice. Human authority is stated directly by Andy
Saperstein, Co-President and Head of MSWM: "We believe trust-based
relationships and human advice will always be valued by clients, and the
Financial Advisor and their teams will remain the center of our wealth
management universe." Every answer carries links back to the underlying
research so a claim can be checked before it is repeated.

**How it's used.** Partnership announced March 2023; Assistant rolled out to
WM advisors over the following year; AskResearchGPT to Institutional
Securities from October 2024. Over 98% of advisor teams actively use the
Assistant daily. Document access rose from 20% to 80% `[first-party, OpenAI
page]`. Staff ask roughly 3x the questions they asked of the 2017-era
predecessor tool, and a salesperson answers the average client inquiry in
about a tenth of the time — **both figures are CNBC (23 Oct 2024), sourced
from interview, and appear in neither press release.** `[secondary]`

**Maintenance — this corrects the previous entry.** The old note said "there
is no public account of reindexing, eval cadence or drift handling, making
this the least documented of the first-party set." **That is false.** The
OpenAI page documents an eval framework applied to every AI use case before
deployment:

- **Summarization evals** — advisors and prompt engineers grade responses for
  accuracy and coherence, feeding prompt refinement.
- **Translation evals**, added later for multilingual clients.
- **Retrieval tuning with OpenAI** against eval results: "What can we change
  about our retrieval methods to help the accuracy we need at Morgan
  Stanley?" (Kaitlin Elliott, Head of Firmwide Generative AI Solutions).
- **A daily regression suite of sample questions** as standing QA.
- **Per-product eval datasets** — for Debrief, datasets representing meeting
  types, testing capture of action items without introducing errors.

A daily regression suite is a concrete freshness-and-drift mechanism. Morgan
Stanley belongs alongside Dropbox as one of the two companies in this set
with an explicit, published eval discipline — not at the bottom of it.

**Named sources.** Katy Huberty (Global Director of Research, Co-Chair AI
Steering Committee); Eden Kidner (Head of Technology Strategy, MS Research);
Andy Saperstein (Co-President, Head of MSWM); Jeff McMillan (Head of
Firmwide AI; Head of Analytics, Data & Innovation for MSWM in 2023); David
Wu (Head of Firmwide AI Product & Architecture Strategy); Kaitlin Elliott
(Head of Firmwide Generative AI Solutions).

**`[refuted]` — previously "worth chasing".** Third-party writeups
(compelframework.org, aiexpert.network) claim advisors are barred from
forwarding assistant output to clients. No first-party source says this, and
the Oct 2024 release states the opposite mechanism directly: a patented
one-click transfer of findings into an email draft "ready to be modified and
customized before sharing with their clients." The constraint is that a
person edits before sending, not that output cannot be sent. Do not repeat
the third-party version.

---

## JPMorgan Chase: LLM Suite

`[secondary]`: no first-party engineering writeup found; the below is from
trade press (CIO Dive, The Digital Banker). Treat as directional.

Firm-wide generative AI toolset launched 2024, scaled from ~60,000 users
mid-2024 to 140,000+, reportedly 200,000 daily across 450+ production use
cases. Model-agnostic (OpenAI and Anthropic both selectable). Wired into
document stores, call records, and knowledge graphs via secure APIs.
Reported saving of 3 to 6 hours/week per user.

Included as a scale datapoint. If you want a bank case study with real
technical substance, Morgan Stanley is the better-documented one.

---

## Patterns worth stealing for companywiki

**1. One table, many connectors, with the connector as reviewed code.**
Cerebras' single embeddings table plus per-source Python plugin submitted
by PR is directly analogous to what `gh-brain`/`sp-brain` sync is doing.
The insight is that the *ingestion module*, not just the content, goes
through review.

**2. Summarize before embedding.** Cerebras summarizes Slack threads and
extracts structured JSON before indexing. This is the same claim as
companywiki's "condense, don't transcribe" rule, but they apply it at
ingestion time, automatically, not only at authoring time. Worth
considering for the SharePoint pipeline.

**3. Cite sub-contexts, not just source links.** Uber shows the retrieved
chunks alongside the answer. Cheaper and more effective as an
anti-hallucination measure than most prompt engineering.

**4. LLM-as-judge on the *documents*.** Uber scores source docs and suggests
improvements. This is a natural fit for the conviction-scoring machinery
already in `governance/`. The same scorer could flag decaying entries, not
just incoming PRs.

**5. Distribute governance, centralize infrastructure.** Stripe's AgentStudio
is the strongest version of this. companywiki's hierarchy.yaml routing is
the same instinct; the missing piece is per-asset usage/quality analytics
handed to the owning team.

**6. Scoped defaults at onboarding.** Cerebras' "projects": new hires pick
their scope on day one so retrieval is filtered from the start. Cheap,
underrated, and relevant to a three-brain layout where an agent otherwise
searches everything.

**7. Expose primitives over MCP, not endpoints.** Cerebras publishes
low-level search tools and lets Claude Code orchestrate. Given companywiki
is explicitly built for agent consumption, this is probably the right
interface shape.

**8. Freshness is a pipeline, not a policy.** Uber's Spark ETL and Cerebras'
differential sync both make currency mechanical. companywiki's README
promises "kept current automatically". These are the two reference
implementations of what that costs.
