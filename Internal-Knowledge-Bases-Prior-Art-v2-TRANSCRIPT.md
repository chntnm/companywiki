# Prior Art — Speaker Transcript

**Deck:** `Internal-Knowledge-Bases-Prior-Art-v2.pptx` (24 slides)
**Runtime:** 2,083 spoken words — 14.4 min at 145 wpm, **15.4 at a measured 135**.
**Structure:** thesis stated in the first minute, companies as evidence, payoff on slide 22.

> **Revised 2026-09-03** after re-sourcing Morgan Stanley from primary text
> (`ms1.pdf`, `ms2.pdf`, `ms3.pdf` in this folder). **The deck has been
> rebuilt to match** — slides 2, 15, 16, 17, 18, 19, 23 and 24 changed, and
> the script below describes what is now on screen. The pre-fix deck is kept
> as `Internal-Knowledge-Bases-Prior-Art-v2.BACKUP-2026-09-03.pptx`. See
> "What changed in the deck" at the bottom.
>
> **Recompiled against the rebuilt deck** later the same day: the slide 24
> and slide 17 lines were still describing the old slides, and the closing
> quote section listed the same two quotes twice. All three are corrected
> below.

**On timing, plainly.** At a brisk 145 wpm this fits at 14.4. At a measured
135 it runs 15.4 and is over the window — so if you speak deliberately, the
cut list is not optional. All three cuts together recover 109 words, which is
only about 50 seconds: 14.6 min at 135, 13.6 at 145. That is the real margin.
If you know you present slowly, cut a company beat rather than trusting the
list to save you.

Diagram slides (4, 6, 8, 10, 12, 14) are deliberately two sentences each — name the shape, deliver the bottom callout, move on. Do not read the boxes. Slide 16 is the one exception: it carries the eval correction, so it gets a third beat.

---

### [Slide 1 — Prior Art]

I read the published accounts of eight companies that built an internal knowledge base. I'll give you the answer first.

One variable explains almost every difference between these systems. Not company size, not budget, not which model they picked. It's who reads the output, and what it costs when the answer is wrong.

Everything else converges. Eight teams, no coordination between them, six of the same decisions.

So here's what to listen for. As I go through the companies, notice how little varies. The interesting part of this deck is the two places where it does.

One note on the count: eight companies, seven diagrams. JPMorgan published no architecture at all, so it appears as a scale datapoint and nothing more.

### [Slide 2 — Method]

Every company was read on the same four questions. What they implemented, what they believe, how it's used, and what keeps it current.

Every claim carries a source tag. Six of the eight published a real engineering write-up. Morgan Stanley published press releases and an OpenAI case study rather than an engineering post — thinner on mechanism, but first-party and read in full. JPMorgan is trade press only.

I'm saying this now because slide 23 is a list of things in this deck that are *not* verified. I'd rather you knew the standard before you saw the exceptions.

---

### [Slide 3 — Cerebras]

Cerebras built Cerebras Knowledge. One Postgres table holds every source — Slack threads, netlists, code — all under one schema.

Their stated reason: a single source of truth, in their words, "rarely works in practice." People write where it's convenient, so they stopped fighting that and put all the intelligence into retrieval.

Two things nobody else does. They distil before they embed — an LLM turns each thread into a question, a summary and a resolution, and only that artifact is embedded, never the raw transcript. And a single reply re-fetches the whole thread and rewrites it as one row, so the record always reflects the entire conversation.

15,000 questions a day, three months after launch.

### [Slide 4 — Cerebras, how it runs]

This is one Slack message becoming an answer. The band I'd point at is the middle one: four ranking signals, not one. Full-text catches pasted error strings, embeddings catch paraphrase, IDF kills "sounds good, thanks," and age decay breaks ties toward the newer thread. Pure vector search wasn't good enough for anyone in this set.

---

### [Slide 5 — Stripe]

Stripe's Kai is the opposite architectural bet. Three layers: surface-agnostic APIs, a control plane called AgentStudio, and a shared execution environment running LangChain agents on Kubernetes.

The belief underneath is that expertise is distributed by nature. The people who know Finance or Legal build their own agents. The platform team owns infrastructure, not content.

83% of the company active weekly within months of launch. Account executives using it closed 39% more deals.

### [Slide 6 — Stripe, three layers]

Three layers, deliberately separated. The detail that matters: the execution environment is shared with Stripe's customer-facing product agents, so hardening done for one benefits the other. That's how the platform team stays small while the agent count grows.

---

### [Slide 7 — Uber]

Uber's Genie is RAG over their internal wiki and their own Stack Overflow. No fine-tuning anywhere in the system. They say why plainly — time to market. Fine-tuning needs a corpus of diverse examples before anything ships.

They publish a 48.9% helpfulness rate. Not "nearly half," not rounded up into something friendlier. Flag that, because it's the most honest number in the set.

### [Slide 8 — Uber, the loop]

Three bands: index, answer, learn. The third one is the part most teams skip and it's the best idea in this deck. Their LLM judge grades the *source documents*, not the answers — so a bad answer becomes a documentation ticket instead of a prompt tweak, and the fix flows back into the index on the next ETL run. The system repairs its own corpus.

---

### [Slide 9 — Slack]

Slack's version is a thin, model-agnostic platform behind four surfaces: a bot, an assistant inside Slack's own UI, a web app, and IDE plugins. Several approved models sit behind one input/output schema, so swapping a model touches no caller.

Take the configuration lesson. Similarity thresholds are their main lever against hallucination, and the team that owns a channel owns its threshold — not the platform team.

### [Slide 10 — Slack, one thin platform]

Thin in the middle by design, so models and surfaces can each be swapped without touching the other. Note the escalation bot at the bottom — it watches 25-plus channels and routes anything needing a person to a person. That bot alone is 3,000 of their claimed 10,000 hours saved a year.

---

### [Slide 11 — Dropbox]

Dropbox Dash is the only architecture here that forks. Simple lookups go through RAG, budgeted to answer 95% of queries in one to two seconds. Complex multi-step work is handed to an agent instead.

And the agent doesn't reason in prose. The planner emits a Python-like DSL, which is statically validated and then run in a security-hardened interpreter Dropbox wrote themselves.

### [Slide 12 — Dropbox, the fork]

The fork is the whole design. Routing easy questions away from the agent is what makes the latency budget achievable. Planning in code is what makes the expensive path auditable — a wrong answer traces back to a wrong step. Their hard-won lesson, stated openly: prompts do not transfer between models.

---

### [Slide 13 — Elastic]

Elastic is the outlier, and it's the one I'd think hardest about. AI gets three named, bounded roles — a research assistant, an environment replicator, a solution editor. Not one general assistant. The failure mode of each is understood in advance.

Their line is "AI is a brilliant intern, not the CEO." Full automation is rejected outright.

Elastic publishes no adoption numbers at all. What's on offer here is a governance model, not a scale story.

### [Slide 14 — Elastic, the gate]

Everything narrows toward one accountable engineer, through a four-step gate before anything publishes. The gate is not a lack of confidence in the model. It's that accountability cannot be delegated to one.

---

### [Slide 15 — Morgan Stanley]

Two products, worth keeping apart. The Assistant serves wealth management advisors. AskResearchGPT serves the institutional side, over more than 70,000 research reports a year.

Both retrieve against Morgan Stanley's own material, never the open web. Their 2023 release is unusually blunt: they are not using ChatGPT, which answers from the public internet — they're using GPT-4 to answer exclusively from internal Morgan Stanley content. The guardrail isn't prompt engineering or model choice. The corpus was curated and edited for publication before the model ever saw it.

Over 98% of advisor teams use the Assistant daily, and the share of documents they can actually reach went from 20% to 80%.

### [Slide 16 — Morgan Stanley, the pipeline]

Shortest pipeline in the set, and the only one where a person is a required node rather than an escape hatch. Their Co-President puts it plainly: the advisor and their teams remain the centre of the wealth management universe.

One more beat, because it's the thing most people get wrong about this company. They run evals on every use case before deployment, and a daily regression suite as standing QA. On eval discipline Morgan Stanley belongs next to Dropbox.

---

### [Slide 17 — JPMorgan, and scale in context]

JPMorgan gets no diagram because there's no architecture to draw. There are numbers — 140,000-plus users, 450-plus production use cases — and every one of them is trade press rather than disclosure. Scale is all they have.

And this slide is deliberately not a chart. Questions per day, weekly actives, chat-turns per month, seconds to answer — no two of these companies published the same metric, and forcing them onto one axis would misrepresent how differently each chose to measure itself.

### [Slide 18 — The eight, side by side]

All eight on one grid: retrieval shape, governing idea, human gate, and how it stays fresh.

Look at the first two columns. They rhyme. Now look at the two on the right — human gate, and freshness. That's where the divergence actually lives, and those two columns carry the rest of this talk.

---

### [Slide 19 — What they all did the same way]

Six decisions, made independently, made the same way.

Nobody fine-tuned. All eight built retrieval instead.

Hybrid beat pure semantic search everywhere — lexical plus vectors, in every write-up that describes retrieval. Pure embedding search failed for all of them.

The sources stayed put. Not one attempted a migration into a single system. They built a retrieval layer over the mess, because the mess is where people actually write.

Citations do the safety work. Source links are table stakes; Uber goes further and shows you the retrieved chunk itself — cheaper than prompt engineering, and it works better.

Configuration sits at the edge. The centre owns infrastructure; the teams being indexed own their own relevance.

And freshness is a pipeline, never a policy. Differential sync, Spark ETL, incremental re-embedding, Morgan Stanley's daily regression suite. Nobody promises currency as a rule, because a rule can't be enforced and a pipeline can.

### [Slide 20 — The ideology underneath]

Three beliefs sit under all of that.

Knowledge scatters, and stays scattered. People write wherever it's easiest — a Slack thread, a PR comment, a Jira field. Every attempt to consolidate that fails. So the retrieval layer absorbs the mess and nobody sits through a migration.

Trust gets built, not claimed. None of them claim the model is reliable. They build on the assumption that it isn't, then engineer around it: cited chunks, bounded roles, inspectable plans, escalation paths, verification gates.

And governance belongs to the people with the context. The platform team owns infrastructure. Relevance, thresholds and quality belong to the team whose work is being indexed, because only they can tell a good answer from a merely plausible one.

### [Slide 21 — Where they part company]

Four real forks, and the set splits cleanly on each one.

Retrieval or orchestration. Cerebras and Uber stop at excellent search and let the client do the reasoning. Stripe and Dropbox run full agents with sandboxes and multi-step plans. Same problem, an order of magnitude apart in machinery.

Who checks the answer. Elastic gates every response on an engineer, Morgan Stanley routes findings through a person. Cerebras, Slack and Dropbox ship straight to the reader with citations attached.

Prose or code. Dropbox alone refuses natural-language planning. Everyone else plans in prose.

One surface or many. Uber ships a Slack bot and nothing else. Slack runs four. Cerebras exposes primitives over MCP and lets the agent be the surface.

---

### [Slide 22 — Why the differences fall where they do]

This is the slide.

Two axes. Across: who reads the output, internal to external. Up: what a wrong answer costs.

Bottom left — Cerebras, Slack, Uber, Stripe. Internal readers, low cost of error. They optimise for throughput. The reader is a colleague who will spot a wrong answer, and at 15,000 questions a day human review does not scale. So they don't attempt it.

Top right — Elastic and Morgan Stanley. External readers, high cost. Both put a person in front of the customer. Not from doubt about the model — because accountability cannot be handed to one.

Then Dropbox, which is the case that proves the rule. External users, high cost, but they can't staff a reviewer per query. So they engineer the audit instead: a readable code plan, and an interpreter they own.

Elastic could not run Cerebras' design. Cerebras would drown under Elastic's review gate. Both are correct.

So when you're deciding what to build, don't start with the retrieval stack. Start with who reads the output and what it costs when it's wrong. That fixes the gate, and the gate determines everything above it.

---

### [Slide 23 — What is not verified]

Before anyone quotes this deck externally.

Top item: the claim that Morgan Stanley advisors may not forward assistant output to clients. That's refuted, not merely unconfirmed. It appears only in third-party writeups, and the October 2024 release states the opposite mechanism — a patented one-click export moves findings into an email draft, in their words, ready to be modified and customized before sharing with clients. A person edits before sending. That's the constraint, not a bar on sending.

Second: two Morgan Stanley figures are trade press. The 3x question volume and the tenfold turnaround are CNBC interview claims that appear in neither press release. The corpus size, the 98% and the eval framework are first-party.

"Hours saved" is a self-reported estimate everywhere it appears. Uber's 13,000, Slack's 10,000 a year, Stripe's 25,000, JPMorgan's three to six a week. None measured against a control. None comparable across companies.

### [Slide 24 — Sources]

Every claim on a company slide traces back to one of these. Six first-party engineering write-ups, three Morgan Stanley sources read in full — two press releases and OpenAI's case study — and trade press for JPMorgan.

If you take one thing from this: nobody fine-tuned, nobody migrated, and everybody engineered around a model they don't trust. What separated them was who was going to read the answer.

Questions.

---

## Timing checkpoints

| At slide | Elapsed |
|---|---|
| 3 (Cerebras) | ~1:20 |
| 11 (Dropbox) | ~6:15 |
| 18 (table) | ~9:15 |
| 22 (the payoff) | ~12:15 |
| 24 (close) | ~14:15 |

**Cut list, in order** — 109 words, about 50 seconds at 135 wpm:

1. Slide 6 entirely (Stripe's diagram; slide 5 already carries the idea).
2. The fourth fork on slide 21 ("one surface or many").
3. Slide 17's second paragraph (the not-a-chart explanation).

Do **not** cut slide 15's 98% / 20-to-80 figures to save time. They are the newly-verified first-party numbers and the fix to the deck's misattribution — the most defensible content on that slide.

---

## What changed in the deck

Applied 2026-09-03 after `ms1/ms2/ms3.pdf` were read in full. 31 run-level
text edits across 8 slides; no shape was moved, resized, recoloured or
deleted, so the layout is byte-for-byte the original. All 8 changed slides
were rendered and checked visually. Pre-fix copy:
`Internal-Knowledge-Bases-Prior-Art-v2.BACKUP-2026-09-03.pptx`.

| Slide | Was | Now |
|---|---|---|
| 2 | Tier defined as "a newsroom post we could not open" | "A newsroom post or vendor case study, read in full, but not an engineering account" |
| 2 | "Morgan Stanley blocked automated fetches… search results" | "published press releases and an OpenAI case study instead, read in full but thinner on mechanism" |
| 15, 16 | Badge `FIRST-PARTY PR / SEARCH-SURFACED` | `FIRST-PARTY PR` |
| 15 | Subtitle "AskResearchGPT." | "Assistant and AskResearchGPT." — the two products no longer conflated |
| 15 | Maintenance: "no public account of reindexing, eval cadence or drift handling… least documented of the first-party set" | **The false claim is gone.** Replaced with the eval framework and the daily regression suite |
| 15 | Stats `3x` / `~10x` at first-party tier | `80%` documents reachable and `daily` regression suite — both first-party |
| 15 | ">98% of advisor teams active (press figure)" | "of advisor teams use the Assistant daily" — correct product, first-party |
| 15 | 3x and 10x presented as fact | Now labelled in-slide as CNBC interview figures rather than disclosure |
| 15 | Philosophy: generic "a human is always in the path" | Saperstein's actual line about the advisor remaining the centre |
| 16 | "reconstructed from press releases… mechanics not published" | Names the eval framework as first-party; keeps the honest limit on internal mechanics |
| 17 | ">98% of advisor teams active (reported)" | "(Assistant)" — names the product |
| 18 | MS "Kept fresh by: the firm's research pipeline" | "Research pipeline, daily regression suite" |
| 19 | Freshness list | Adds "a daily regression suite" |
| 23 | "advisors may not forward output" as unconfirmed | "…is refuted", with the contradicting first-party mechanism quoted |
| 23 | "Morgan Stanley's figures are search-surfaced, not fetched" | "two figures are trade press, not disclosure" — the precise, still-true caveat |
| 24 | "First-party PR, search-surfaced (bodies not fetchable)" | "First-party PR and vendor case study, read in full"; OpenAI entry no longer marked HTTP 403 |

**One thing in the deck is still wrong.** Slide 15's *speaker note* — not the
slide, the note — still reads "these figures are search-surfaced… openai.com
returned 403… Verify before external use." That is the claim the rebuild
disproved, and it is presenter-facing, so anyone reading their notes would be
contradicting their own slide. PowerPoint had the file open when this
recompile ran, so it could not be written. All 24 notes were checked; slide 15
is the only bad one.

To fix it — close PowerPoint first, or the open copy overwrites this on save:

```python
from pptx import Presentation
p = r"Internal-Knowledge-Bases-Prior-Art-v2.pptx"
prs = Presentation(p)
list(prs.slides)[14].notes_slide.notes_text_frame.text = (
    "All three first-party sources were read in full on 3 September 2026 "
    "(ms1/ms2/ms3.pdf in this folder): both Morgan Stanley press releases and "
    "the OpenAI case study. The corpus size, the >98% adoption and the eval "
    "framework are first-party. The 3x question volume and the tenfold "
    "turnaround are CNBC interview figures and are labelled as such on the "
    "slide.")
prs.save(p)
```

Or retype the note by hand in PowerPoint's notes pane on slide 15 — it is one
paragraph and carries no formatting.

**Net effect on the argument:** Morgan Stanley moves from the least-documented
first-party entry to one of the two companies in the set with a published eval
discipline, alongside Dropbox. Its position on slide 22 does not move — the new
material supports it. Nothing in the thesis breaks.

**Deliberate omission.** Debrief (Whisper + GPT-4 meeting summaries) lost its
line on slide 15 to make room for the eval framework. It survives in
`PRIOR-ART.md`. If asked about it, it turns consented Zoom recordings into CRM
notes and draft follow-ups, with the advisor reviewing before anything is
finalised — which is the same human-gate pattern as the rest of the slide.

## First-party Morgan Stanley quotes

**On the slides, so say them close to verbatim:**

- "Morgan Stanley Wealth Management is using GPT-4 to generate responses exclusively from internal Morgan Stanley content, with appropriate controls." *(14 Mar 2023 release — slide 15, Implementation. The cleanest evidence for "the corpus is the control.")*
- "The Financial Advisor and their teams will remain the center of our wealth management universe." *(Andy Saperstein, Co-President and Head of MSWM — slide 15, Philosophy; spoken on slide 16.)*

**Deliberately not on the slides — for questions only:**

- "We went from being able to answer 7,000 questions to a place where we can now effectively answer any question from a corpus of 100,000 documents." *(David Wu, Head of Firmwide AI Product & Architecture Strategy.)* The 100,000 is Wu's framing of retrieval reach, not a published inventory count, so it is kept off the slide rather than shown as a firm figure. See "Not on the slide, deliberately" in `PRIOR-ART.md`.
- "What can we change about our retrieval methods to help the accuracy we need at Morgan Stanley?" *(Kaitlin Elliott, Head of Firmwide Generative AI Solutions.)* Useful if someone asks how the eval loop actually fed back into the system.
