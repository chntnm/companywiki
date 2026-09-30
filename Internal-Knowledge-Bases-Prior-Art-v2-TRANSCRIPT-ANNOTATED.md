# Prior Art — Annotated Speaker Transcript

**Deck:** `Internal-Knowledge-Bases-Prior-Art-v2.pptx` (24 slides)
**Companion to:** `Internal-Knowledge-Bases-Prior-Art-v2-TRANSCRIPT.md`

> **This is not the script.** The main transcript is the 15-minute performance
> version, and its timing is measured. This one is about 9,400 words against
> its 2,083 — four and a half times longer — and is meant to be *read before*
> you present, or handed to someone who wants
> the detail without sitting through the talk. Do not read it aloud and do not
> time yourself against it. For runtime, the cut list and the timing
> checkpoints, use the main transcript — those numbers live in one place on
> purpose.
>
> Use it two ways: read it once end-to-end while preparing, then keep it open
> during Q&A as the thing you look up an answer in.

## How to read the marked passages

There are three kinds of text here, and it matters which you are reading.

**Unmarked body text** is the same standard as the deck. It traces to
`PRIOR-ART.md` and the first-party sources on slide 24. Where a company
published a number, it appears as they published it.

**Blocks headed "Plain English"** are general technical background I have
supplied so a non-specialist can follow along. Not sourced from the companies,
not a companywiki claim. Teaching aids, not evidence.

**Every other indented aside** is my own reading of the sources — why a
decision matters, what a figure does and does not support, what I would take
from it. These are argued from the published material but they are not in it.
If you quote this document externally, quote the unmarked text. If you repeat
an aside, repeat it as an opinion, because that is what it is.

Where something is unverified it is not in this document at all. That is
deliberate: a longer document is exactly where unverified colour leaks back in.

---

## The six terms that recur

Read these once. Everything else is defined where it first appears.

> **Plain English — Retrieval.** Finding the right documents to answer a
> question. Every system in this deck is, underneath, a search engine with a
> language model bolted to the end of it. When people say the hard part is
> retrieval, they mean the model is only as good as the paragraphs you hand it.

> **Plain English — RAG (Retrieval-Augmented Generation).** The dominant
> pattern here, and all eight use some version of it. Three steps: search your
> own documents for passages relevant to the question, paste those passages
> into the prompt, then ask the model to answer using only those passages. The
> model supplies fluency and reasoning. The documents supply the facts. This is
> why none of these systems needed to retrain a model to know company-specific
> things.

> **Plain English — Fine-tuning.** The alternative nobody chose. You take an
> existing model and continue training it on your own data so the knowledge
> ends up baked into the model's weights. It is expensive, it needs a large
> curated set of examples before you can start, and when the underlying facts
> change you have to do it again. RAG changes an answer by changing a document;
> fine-tuning changes an answer by retraining. Remember this — "nobody
> fine-tuned" is one of the six convergences on slide 19.

> **Plain English — Embedding.** A way of turning a piece of text into a long
> list of numbers — a coordinate — such that texts meaning similar things land
> near each other. "How do I reset my password" and "forgot my login" share
> almost no words but end up as neighbours. Cerebras uses 3,072 numbers per
> text. Searching then means: turn the question into a coordinate, find the
> nearest document coordinates. This is what lets search work on *meaning*
> rather than exact words, and it is also why it fails on exact words, which is
> the next term.

> **Plain English — Full-text / lexical search.** Old-fashioned literal word
> matching, the thing a database has done for forty years. It is exact where
> embeddings are fuzzy. If you paste an error code like `ERR_CONN_4021`,
> embeddings will helpfully find you documents about connection errors in
> general; full-text finds the one document containing that exact string. The
> repeated finding across this whole deck is that you need both, which is what
> "hybrid search" means every time it appears.

> **Plain English — LLM (Large Language Model).** GPT-4, Claude, and the rest.
> For this talk you only need one property: it is very good at producing
> fluent, plausible text, and it has no built-in way to tell you whether that
> text is true. Every architecture in this deck is a different answer to that
> single problem.

---

# The talk

### [Slide 1 — Prior Art]

I read the published accounts of eight companies that built an internal
knowledge base. I'll give you the answer first.

One variable explains almost every difference between these systems. Not
company size, not budget, not which model they picked. It's who reads the
output, and what it costs when the answer is wrong.

Everything else converges. Eight teams, no coordination between them, six of
the same decisions.

So here's what to listen for. As I go through the companies, notice how little
varies. The interesting part of this deck is the two places where it does.

One note on the count: eight companies, seven diagrams. JPMorgan published no
architecture at all, so it appears as a scale datapoint and nothing more.

> **Why "internal knowledge base" and not "chatbot."** Every one of these is a
> system for answering questions from a company's own private material —
> Slack history, wikis, code, research reports. The public chatbots are trained
> on the open internet and know nothing about your company. That gap is the
> entire problem space. Dropbox is the partial exception: Dash is a product
> they sell, but their engineering write-up is the most detailed public account
> of the architecture split, which is why it earns a place here.

---

### [Slide 2 — Method]

Every company was read on the same four questions. What they implemented, what
they believe, how it's used, and what keeps it current.

Every claim carries a source tag. Six of the eight published a real engineering
write-up. Morgan Stanley published press releases and an OpenAI case study
rather than an engineering post — thinner on mechanism, but first-party and
read in full. JPMorgan is trade press only.

I'm saying this now because slide 23 is a list of things in this deck that are
*not* verified. I'd rather you knew the standard before you saw the exceptions.

**If someone asks what the three tiers mean:**

- **First-party** — their own engineering blog, read in full and quoted
  directly. An engineer at the company describing what they built.
- **First-party PR** — a newsroom post or a vendor case study, read in full,
  but written by communications rather than engineering. True, but selected.
  It tells you what was built and rarely how.
- **Secondary** — trade press with no engineering account behind it. A
  journalist reporting a number a company gave them. Directional only.

The distinction is not pedantry. It sets what you are allowed to conclude. A
first-party engineering post tells you the mechanism, so you can copy it. A
press release tells you the outcome, so you can only cite it.

---

### [Slide 3 — Cerebras]

Cerebras built Cerebras Knowledge. One Postgres table holds every source —
Slack threads, netlists, code — all under one schema.

> **Plain English — Postgres.** PostgreSQL, an ordinary open-source relational
> database. Rows and columns, the same kind of thing that stores a customer
> list. The point of naming it is that it is *unglamorous and already there*.
> Cerebras did not buy a specialist vector database. They used the database
> they had.

> **Plain English — Netlist.** Cerebras builds computer chips. A netlist is the
> machine-readable wiring diagram of a chip design: every component and every
> connection between them, as a text file. It is about as far from a Slack
> message as two documents can get.
>
> That is exactly why it is on the slide. A chat message and a chip wiring
> diagram landing in the same table, under the same schema, searchable through
> the same interface, is the whole "one table, many connectors" idea in one
> image. They did not build a Slack search and a chip-design search. They built
> one search.

> **Plain English — Schema.** The agreed shape of a row: which columns exist and
> what goes in them. "All under one schema" means every source, however
> different, is converted into the same shape on the way in. The variety is
> handled at the door, so everything downstream sees uniform data.

Their stated reason: a single source of truth, in their words, "rarely works in
practice." People write where it's convenient, so they stopped fighting that
and put all the intelligence into retrieval.

**How a new source gets added, because this is the transferable part.** A team
that wants its database indexed opens a pull request with a small Python module
that reads from their system and emits rows in the shared schema.

> **Plain English — Pull request.** The standard way of proposing a change to
> shared code: you submit it, colleagues review it, then it gets merged. The
> significance is governance, not plumbing. Because a connector is code in a
> pull request, adding a data source goes through exactly the same review as
> any other change. Nobody can quietly wire in a sensitive system. The audit
> trail is free, because it is the same audit trail the code already had.

Two things nobody else does. They distil before they embed — an LLM turns each
thread into a question, a summary and a resolution, and only that artifact is
embedded, never the raw transcript.

> **Why distilling first matters.** A real Slack thread is mostly noise:
> greetings, half-formed guesses, "any update?", a wrong answer, then the fix
> buried near the end. Embedding that whole mess produces a coordinate that
> represents the *average* of all of it, which points nowhere useful. So they
> have a model read the thread first and write down what the question actually
> was, what the answer turned out to be, and which systems were involved. That
> clean summary is what gets embedded. They are searching over a tidied version
> of the conversation, never the conversation itself.

And a single reply re-fetches the whole thread and rewrites it as one row, so
the record always reflects the entire conversation.

> **Why re-fetch the whole thread.** The naive design stores each message as it
> arrives, as its own row. Then a thread that ends with "ignore all that, the
> real fix was X" leaves you with rows containing the wrong answer, still
> perfectly searchable. Cerebras instead treats one reply as a signal to throw
> away the stored version and rebuild the thread from scratch as a single row.
> A conversation is never half-recorded. It costs more work on every message
> and buys correctness on every read.

15,000 questions a day, three months after launch.

---

### [Slide 4 — Cerebras, how it runs]

This is one Slack message becoming an answer. The band I'd point at is the
middle one: four ranking signals, not one. Full-text catches pasted error
strings, embeddings catch paraphrase, IDF kills "sounds good, thanks," and age
decay breaks ties toward the newer thread. Pure vector search wasn't good
enough for anyone in this set.

**The four signals, in detail.** This is the most jargon-dense slide in the
deck, so here is each one.

> **Plain English — IDF (Inverse Document Frequency).** A measure of how rare a
> word is across your whole collection. Words appearing everywhere — "the",
> "thanks", "update" — score near zero. Words appearing rarely — a specific
> flag name, an unusual error code — score high. The rule is: a word is only
> informative if it is unusual.
>
> The slide's example is the clearest one. A message reading "sounds good,
> thanks!" contains nothing rare. Its IDF score is close to zero, so it cannot
> win a search however cosily its embedding happens to sit next to your
> question. Without an IDF signal, short agreeable messages are a genuine
> menace in a Slack corpus, because there are thousands of them and they are
> bland enough to look vaguely relevant to everything.
>
> Cerebras also use it as a gate elsewhere: a run of messages only gets
> embedded separately if it clears an IDF threshold of 4.0, runs past 200
> characters, or someone reacted to it. All three are ways of asking "did this
> contain anything?"

> **Plain English — Age decay.** A deliberate thumb on the scale for newer
> documents. Where two threads answer the question equally well, the more
> recent one wins. This is a knowledge base for a company that changes, so the
> 2023 answer and the 2026 answer to the same question are not equally useful,
> even when both were true when written.

Full-text and embeddings you have already met: literal matching for exact
strings, coordinate proximity for paraphrase. The claim being made by having
all four is that no single signal is trustworthy alone, and the evidence for it
is that every company in this deck that describes retrieval in any detail
arrived at the same conclusion independently.

**How four rankings become one.** Each signal produces its own ranked list, and
those lists disagree. They are combined with reciprocal rank fusion.

> **Plain English — Reciprocal Rank Fusion (RRF).** A method for merging several
> ranked lists into one. The trick is that it uses each document's *position*
> in a list rather than its score. A document ranked first contributes
> `weight / (60 + 1)`, second contributes `weight / (60 + 2)`, and so on, and
> a document's contributions from every list are added up.
>
> Why position and not score: the four signals produce numbers on completely
> incompatible scales. An IDF score and a cosine similarity are not comparable
> quantities, and adding them is meaningless. Ranks *are* comparable — "this
> signal thought this was the best match" means the same thing regardless of
> which signal said it. RRF is the standard way out of that problem, and it is
> unglamorous and effective.

After fusion the list is deduplicated, capped so no single file can dominate,
cut to a top twenty, scored 0 to 10 by a small reranker, and cut to ten.

> **Plain English — Reranker.** A second, more careful scoring pass over a short
> list. The first stage is fast and approximate over millions of documents; you
> cannot afford to be careful at that scale. Once twenty candidates survive,
> you can afford a slower model that reads each one properly against the
> question. Cheap-and-wide, then expensive-and-narrow, is the standard shape of
> every serious search system.

Only then is the surrounding text pulled in, so a winning paragraph arrives
with its heading and its caveats attached rather than stranded on its own.

**The three-stage answering path** — planner, executor, synthesizer — is worth
a sentence each. The planner is a light model pass that reads your question and
decides which search tools to call. The executor runs those calls in parallel
and normalises every result into one common format. The synthesizer writes the
final answer with citations.

> **Plain English — MCP (Model Context Protocol).** An open standard for
> exposing tools to an AI agent, so any compliant agent can call them. Cerebras
> publish their individual search tools over MCP rather than publishing one
> "answer my question" endpoint.
>
> The consequence is on the slide and worth catching: over MCP, the synthesizer
> step is skipped entirely, and whatever agent called in does the writing. They
> are deliberately shipping ingredients rather than a meal. It means their
> retrieval layer does not depend on their own model choices to be useful to
> somebody else.

Code takes a different path from conversation: repositories are split at class,
then method, then smaller blocks, and each commit re-embeds only the chunks
that changed.

> **Plain English — Chunking, and why the boundaries matter.** Documents are too
> big to embed whole, so they get cut into pieces. Where you cut determines
> what you can find. Cutting code every 500 characters would slice through the
> middle of functions and produce fragments that mean nothing. Cutting at class
> and method boundaries means each piece is a self-contained unit that
> retrieves sensibly. Re-embedding only changed chunks is what keeps a 40
> GB repository current without reprocessing it nightly.

---

### [Slide 5 — Stripe]

Stripe's Kai is the opposite architectural bet. Three layers: surface-agnostic
APIs, a control plane called AgentStudio, and a shared execution environment
running LangChain agents on Kubernetes.

That sentence is four pieces of jargon in a row, so here is each layer with
what it actually is and what it actually does.

**Layer one — surface-agnostic APIs.**

> **Plain English — API.** The interface one piece of software uses to talk to
> another. Not a user interface; a machine one.

> **Plain English — Surface.** A place a human can reach the system from. Kai
> has four: a full web app, Slack, a Chrome extension, and direct embeds where
> other internal products call it.

> **Plain English — Surface-agnostic, which is the term you asked about.** One
> single backend service that does not know or care which of those four front
> doors a request came through. The alternative — the thing most companies
> accidentally build — is a Slack integration with its own logic, then a web
> app with its own slightly different logic, then a Chrome extension with a
> third. Three copies that drift apart, three places to fix a bug.
>
> Stripe built one service and four thin front doors. The payoff is on slide 6:
> adding a surface does not mean adding a stack. A new front door is a new way
> in to the same machine, not a new machine.

**Layer two — AgentStudio, the control plane.**

> **Plain English — Control plane.** Borrowed from networking. The control plane
> is where you configure and observe a system; the data plane is where the work
> actually happens. A thermostat is a control plane, the boiler is the data
> plane. AgentStudio is where agents get defined and watched, not where they
> run.

> **Plain English — Agent.** A model that can take actions in a loop, rather
> than just answering once. It reads a request, decides to call a tool, reads
> the result, decides what to do next, and keeps going until it is done or
> stopped. That loop is the difference between "answer this question" and "go
> find out and report back".

> **Plain English — Skill.** A capability an agent can invoke — query this
> database, look up that account, run this report. Stripe has more than 1,000
> skills and tools registered across their internal systems.

AgentStudio is a build, test and monitor console, and the users are domain
teams rather than the platform team. Someone in Finance who knows how revenue
modelling actually works assembles their own agent: picks the skills, picks the
tools, tests the behaviour, and watches the usage and quality signals for the
thing they own.

With a thousand-plus skills, choosing which to use is itself a retrieval
problem, and they solve it with a hybrid RAG and LLM approach rather than
making people navigate a fixed folder hierarchy. The system searches its own
tools the way it searches documents.

**Layer three — the shared execution environment.**

> **Plain English — LangChain.** A widely used open-source framework for
> building applications on top of language models. It supplies the plumbing
> everyone would otherwise write themselves: calling models, chaining steps,
> managing tools. `deepagents` is LangChain's library for agents that run long
> multi-step tasks. Stripe using it is a "we did not build this ourselves"
> signal.

> **Plain English — Kubernetes.** The industry-standard system for running
> software across a fleet of machines. You hand it a workload; it decides which
> machine runs it, restarts it when it dies, and adds more copies under load.
> Almost every large company already runs it.
>
> The phrase on slide 6 is "scheduled as ordinary cluster workloads", and
> *ordinary* is the whole point. An AI agent here is not a special snowflake
> needing bespoke infrastructure. It is a job on the same cluster as everything
> else, benefiting from the same monitoring, the same restarts, the same
> capacity planning. Twelve years of operational tooling comes free.

> **Plain English — Sandbox.** A restricted environment where code runs without
> being able to touch anything outside it. Per-session sandboxing means each
> conversation gets its own sealed box.
>
> This is where the guardrail actually lives, and it is a genuinely important
> point for a governance audience. Stripe's stated rule is that two unrelated
> customer contexts must never appear in one analysis. You cannot enforce that
> by asking a model nicely in a prompt, because a model can be talked out of
> anything. You enforce it by isolating the session so the second customer's
> data is not reachable from inside the box. The prompt is a request; the
> sandbox is a wall.

> **Plain English — Multi-tenant virtual filesystem.** A fake filesystem the
> agent can read and write to as though it were a real disk, with each tenant's
> files invisible to every other tenant. It is what lets a session accumulate
> working state — intermediate results, files it has written — across a very
> long task without that state leaking sideways. One recorded session ran to
> 932 turns, which is only possible if the session can keep notes somewhere.

The belief underneath all three layers is that expertise is distributed by
nature. The people who know Finance or Legal build their own agents. The
platform team owns infrastructure, not content.

83% of the company active weekly within months of launch. Account executives
using it closed 39% more deals.

> **On that 39%, if you are asked.** It is a comparison of active-use weeks
> against other weeks, which is correlation and not a controlled trial. High
> performers may simply adopt new tools faster. Stripe published it as a
> published figure and I am repeating it as one. Slide 23 makes the general
> version of this point about every productivity number in the deck.

---

### [Slide 6 — Stripe, three layers]

Three layers, deliberately separated. The detail that matters: the execution
environment is shared with Stripe's customer-facing product agents, so
hardening done for one benefits the other. That's how the platform team stays
small while the agent count grows.

> **What "shared execution environment" is really claiming.** Stripe sells
> AI agent features to customers. Those product agents and these internal
> employee agents run on the same sandboxing, the same isolation, the same
> access-control machinery.
>
> Two consequences. First, the internal tool inherits security work done to a
> standard set by paying customers and external audit — a higher bar than most
> internal tools ever get held to. Second, every improvement is paid for once
> and lands in both places. That is why a small platform team can support a
> growing agent count: they are not maintaining an internal system at all, they
> are maintaining one system that has an internal audience.
>
> It also carries a real risk worth naming if someone pushes: a defect in the
> shared runtime is now a defect in both. Shared fate cuts both ways.

---

### [Slide 7 — Uber]

Uber's Genie is RAG over their internal wiki and their own Stack Overflow. No
fine-tuning anywhere in the system. They say why plainly — time to market.
Fine-tuning needs a corpus of diverse examples before anything ships.

> **Plain English — Internal Stack Overflow.** Stack Overflow is the public
> question-and-answer site programmers live on. Large engineering organisations
> run private instances for questions that cannot be asked publicly. It is a
> uniquely good corpus for this purpose: already in question-and-answer form,
> already voted on, already curated by the people who understand it.

**The stack, named, since it comes up.** OpenAI embeddings, LangChain for
chunking, Sia — Uber's in-house vector database — and Terrablob for storage.

> **Plain English — Vector database.** A database built for one job: storing
> embeddings and finding the nearest ones to a query, fast, across many
> millions of entries. Note the contrast with Cerebras, who deliberately used
> ordinary Postgres instead. Both work. Uber operates at a scale where the
> specialist tool earns its keep; Cerebras decided theirs did not.

Their security position is one line and worth stealing: only pre-curated,
widely-accessible sources are embedded at all, so sensitive material never
enters the index. The access-control problem is solved by not creating it.

They publish a 48.9% helpfulness rate. Not "nearly half," not rounded up into
something friendlier. Flag that, because it's the most honest number in the
set.

> **What 48.9% actually means, since it sounds bad.** Just under half of
> answered questions were rated helpful by the person who asked. That is a
> genuinely useful system — the alternative was interrupting an on-call
> engineer — and it is nowhere near the impression created by a demo. Every
> other company in this deck published a number that flattered them. Uber
> published the one that did not. When you are estimating what your own system
> will achieve, this is the honest anchor.

---

### [Slide 8 — Uber, the loop]

Three bands: index, answer, learn. The third one is the part most teams skip
and it's the best idea in this deck. Their LLM judge grades the *source
documents*, not the answers — so a bad answer becomes a documentation ticket
instead of a prompt tweak, and the fix flows back into the index on the next
ETL run. The system repairs its own corpus.

> **Plain English — LLM-as-judge.** Using one language model to grade the output
> of another, against a rubric, at a scale no human review could reach. It is
> now a standard evaluation technique.

> **Plain English — ETL (Extract, Transform, Load).** The standard name for a
> data pipeline: pull data out of source systems, reshape it, load it into the
> destination. Uber's runs on Spark, a framework for processing large datasets
> across many machines, and it runs continuously and incrementally — updating
> what changed rather than rebuilding everything.

**Why grading documents rather than answers is the good idea.** When an answer
is wrong, the reflex is to blame the model and edit the prompt. But most wrong
answers in a RAG system are not the model's fault. The model was handed a
document that was ambiguous, outdated, or silent on the question, and it did
what it was built to do with bad inputs.

Uber's judge therefore scores the source documents and suggests improvements to
them. A wrong answer becomes a documentation defect with a ticket attached.
Fix the document, and the fix propagates to every future question touching that
document, permanently. Fix the prompt, and you have papered over one symptom.

The second-order effect is the interesting one. The knowledge base improves the
wiki. Most companies expect the wiki to improve the knowledge base and are
disappointed when nobody writes documentation. Uber pointed the arrow the other
way.

Feedback flows through buttons on every answer — resolved, helpful, not
helpful, not relevant — streamed into dashboards, and every response offers a
next step, including escalating to a human. The system always leaves you a way
out.

---

### [Slide 9 — Slack]

Slack's version is a thin, model-agnostic platform behind four surfaces: a bot,
an assistant inside Slack's own UI, a web app, and IDE plugins. Several
approved models sit behind one input/output schema, so swapping a model touches
no caller.

> **Plain English — Model-agnostic, and the I/O schema.** Every approved model
> is put behind one agreed request-and-response format. Callers send the same
> shape of request and get the same shape back, whichever model actually
> serves it.
>
> The reason this is worth engineering deliberately: models are replaced
> constantly, and a better one ships every few months. If fifty internal tools
> each call a model directly, every swap is fifty migrations, and in practice
> you stop upgrading. Behind a schema, a swap is a configuration change and no
> caller notices. Slack lists "keeping pace with model releases" as a standing
> cost, and this is the architecture that makes that cost survivable.

> **Plain English — IDE plugin.** An IDE is the editor programmers write code
> in. A plugin puts the assistant inside it, so an engineer never leaves the
> tool they are already in. 65% of surveyed engineers preferred this surface —
> the lesson being that reach beats sophistication.

Take the configuration lesson. Similarity thresholds are their main lever
against hallucination, and the team that owns a channel owns its threshold —
not the platform team.

> **Plain English — Similarity threshold.** A minimum score a retrieved document
> must clear to be used at all. Set it low and the system always finds
> something, including when nothing relevant exists — and a model handed
> irrelevant context will confidently write nonsense from it. Set it high and
> the system more often says it does not know.
>
> That is the actual hallucination dial, and notice what it is: not a cleverer
> prompt, not a better model, but a number controlling whether the system is
> willing to answer at all. Slack's insight is that the right value differs per
> channel, and only the team living in that channel can judge it. So they
> pushed the setting outward. This is the same "governance at the edge"
> principle as Stripe's AgentStudio, arrived at independently.

---

### [Slide 10 — Slack, one thin platform]

Thin in the middle by design, so models and surfaces can each be swapped
without touching the other. Note the escalation bot at the bottom — it watches
25-plus channels and routes anything needing a person to a person. That bot
alone is 3,000 of their claimed 10,000 hours saved a year.

> **Why the escalation bot is the sleeper result.** It does not answer
> questions. It reads what is posted in a channel, classifies it, and routes
> the things needing a human to a human. It is a triage system, not an oracle.
>
> And it is the single largest measured win in the deck — nearly a third of
> Slack's total claimed saving. Worth sitting with, because it suggests the
> highest-value use of a language model in an operations context may be
> deciding who should look at something, not attempting to resolve it. It is a
> much easier problem, and classification failures are far cheaper than
> confidently wrong answers.

---

### [Slide 11 — Dropbox]

Dropbox Dash is the only architecture here that forks. Simple lookups go
through RAG, budgeted to answer 95% of queries in one to two seconds. Complex
multi-step work is handed to an agent instead.

> **Plain English — Why a fork is necessary at all.** An agent is slow. It runs
> a loop, calls tools, reads results, decides again — many model calls, tens of
> seconds. That is fine for "analyse this quarter's contracts" and absurd for
> "what's the wifi password". Route everything through the agent and simple
> questions become unusable. Route nothing through it and hard questions become
> unanswerable. Dropbox's answer is to classify first and send each question
> down the path that fits it.
>
> Note also what the latency figure is and is not: it is a *budget* they
> designed to, over 95% of queries in one to two seconds, not a measured
> percentile. That distinction is flagged in `PRIOR-ART.md` and is worth
> keeping straight if someone asks.

And the agent doesn't reason in prose. The planner emits a Python-like DSL,
which is statically validated and then run in a security-hardened interpreter
Dropbox wrote themselves.

> **Plain English — DSL (Domain-Specific Language).** A small programming
> language built for one narrow job, rather than a general-purpose one. Dropbox
> had their planner emit plans in a Python-like DSL they designed.

> **Plain English — Static validation and static analysis.** Checking a program
> by reading it, before running it. Because the plan is code rather than
> prose, it can be checked mechanically for illegal operations and rejected
> before anything executes. You cannot statically analyse a paragraph of
> English.

> **Plain English — Interpreter, and why they wrote their own.** An interpreter
> executes a program step by step. Dropbox built their own rather than using
> Python's, because a standard interpreter will happily do anything the code
> asks — read files, open network connections. Theirs only permits what they
> allow, with runtime type enforcement, and it is the enforcement point for
> everything the agent is not allowed to do.

---

### [Slide 12 — Dropbox, the fork]

The fork is the whole design. Routing easy questions away from the agent is
what makes the latency budget achievable. Planning in code is what makes the
expensive path auditable — a wrong answer traces back to a wrong step. Their
hard-won lesson, stated openly: prompts do not transfer between models.

> **Why planning in code is the deep idea, and it is the one I would take.**
> When an agent reasons in prose, its plan is a paragraph of English. If the
> final answer is wrong you cannot say which sentence caused it. You cannot
> test the plan, you cannot diff two plans, and you cannot mechanically forbid
> anything. You are left re-reading English and guessing.
>
> A plan that is code inverts every one of those. It can be checked before it
> runs. A wrong answer traces to a specific step. Two plans can be compared.
> Illegal operations can be rejected by a validator rather than discouraged by
> a prompt. Dropbox's own phrase is that it lets the system "show the work" —
> reasoning becomes inspectable, debuggable, and deterministically testable.
>
> That last word is the one to hold on to. *Deterministic* means the same plan
> run twice does the same thing. Almost nothing else about a language model has
> that property, and it is why this is how you get an auditable agent without
> putting a human in front of every answer. Look at slide 22 and you will see
> this is exactly the trick that lets Dropbox sit where it does.

> **On "prompts do not transfer between models."** The instructions painstakingly
> tuned for one model frequently perform worse on its successor. Every model
> upgrade means re-testing and often rewriting your prompts. It is a real
> maintenance cost that budgets routinely omit, and Dropbox stating it plainly
> is a kindness. It is also why they re-run model selection against public
> benchmarks with their own judges scoring correctness and completeness rather
> than assuming the newest model is the best one for their job.

---

### [Slide 13 — Elastic]

Elastic is the outlier, and it's the one I'd think hardest about. AI gets three
named, bounded roles — a research assistant, an environment replicator, a
solution editor. Not one general assistant. The failure mode of each is
understood in advance.

**The three roles, specifically:**

- **Research assistant.** Synthesises documentation and case history into
  hypotheses, which an engineer must then validate against official sources.
  It proposes; it does not conclude.
- **Environment replication.** Generates synthetic test data and mock configs
  mirroring a customer's setup, so an engineer can reproduce a problem locally.
  Their rule here is excellent and portable: *the output must replicate the
  shape of the customer's system, not the customer's data.* You get a
  realistic environment without ever copying real customer information into a
  test system.
- **Solution editor.** Improves clarity, grammar and formatting — and only
  after the technical content has been validated. The model is allowed near the
  prose, never near the correctness.

> **Why bounding roles is a different strategy from everything else here.**
> Every other company built one assistant and then worked on making it more
> reliable. Elastic asked instead where a model can fail safely, and let it
> operate only there. A research assistant that proposes a wrong hypothesis
> costs an engineer some time, because validation is built into the role. A
> general assistant that publishes a wrong answer to a customer costs
> something else entirely.
>
> The trade is real and worth naming: they get less leverage than the others.
> They have chosen a lower ceiling in exchange for a much higher floor.

Their line is "AI is a brilliant intern, not the CEO." Full automation is
rejected outright.

Elastic publishes no adoption numbers at all. What's on offer here is a
governance model, not a scale story.

---

### [Slide 14 — Elastic, the gate]

Everything narrows toward one accountable engineer, through a four-step gate
before anything publishes. The gate is not a lack of confidence in the model.
It's that accountability cannot be delegated to one.

**The four steps, if asked:** check the self-service history first, establish
the core problem and the desired outcome, verify against the existing knowledge
base and official documentation, and reproduce in a controlled environment
where that is feasible. Every response is reviewed, validated and refined by an
engineer before a customer sees it.

---

### [Slide 15 — Morgan Stanley]

Two products, worth keeping apart. The Assistant serves wealth management
advisors. AskResearchGPT serves the institutional side, over more than 70,000
research reports a year.

> **Why the separation matters more than it looks.** These are different
> systems, for different users, launched eighteen months apart, over different
> corpora. AI @ Morgan Stanley Assistant went to wealth-management advisors
> from March 2023. AskResearchGPT went to Institutional Securities in October
> 2024. Third-party coverage routinely blends them and attributes one's figures
> to the other. The deck previously did the same, and it is corrected here.

Both retrieve against Morgan Stanley's own material, never the open web. Their
2023 release is unusually blunt: they are not using ChatGPT, which answers from
the public internet — they're using GPT-4 to answer exclusively from internal
Morgan Stanley content. The guardrail isn't prompt engineering or model choice.
The corpus was curated and edited for publication before the model ever saw it.

> **"The corpus is the control" — the cleanest idea on this slide.** Everyone
> else in this deck engineers trust after the fact: cite sources, gate on a
> human, sandbox the execution, show the retrieved chunk. Morgan Stanley's
> primary control sits earlier. The only thing the model can retrieve is
> published research that already went through the firm's editorial and
> compliance process before anyone thought about AI.
>
> The material was vetted for a different reason, and the AI system inherits
> that vetting for free. If your organisation already has an editorial pipeline
> — a research function, a legal review, a published-documentation process —
> that is the single highest-leverage thing you own, and this is the design
> that exploits it.

Over 98% of advisor teams use the Assistant daily, and the share of documents
they can actually reach went from 20% to 80%.

> **What the 20-to-80 figure is measuring.** Not that documents were missing —
> they were sitting in the corpus the whole time. It is that only about a fifth
> of them were *findable* in practice by an advisor with a question, and after
> the assistant, four fifths were. The value delivered was retrieval over an
> archive the firm already owned and had already paid to produce. That is worth
> saying aloud to anyone who thinks a project like this starts with acquiring
> content.

---

### [Slide 16 — Morgan Stanley, the pipeline]

Shortest pipeline in the set, and the only one where a person is a required
node rather than an escape hatch. Their Co-President puts it plainly: the
advisor and their teams remain the centre of the wealth management universe.

One more beat, because it's the thing most people get wrong about this company.
They run evals on every use case before deployment, and a daily regression
suite as standing QA. On eval discipline Morgan Stanley belongs next to
Dropbox.

> **Plain English — Eval.** A test set for a model: a collection of inputs with
> known-good outputs, run to measure whether the system is actually performing.
> The equivalent of a unit test, for a component that is not deterministic.

> **Plain English — Regression suite.** A fixed set of test cases re-run
> continuously to catch things that used to work and have quietly stopped. In
> ordinary software this is routine. For an AI system it is more important, not
> less, because nothing announces a regression: a model update or an index
> change can silently degrade answers with no error anywhere. Morgan Stanley
> runs a daily set of sample questions as standing QA, which is how you find
> that out on the day rather than from a complaint.

**The detail behind "evals on every use case":** summarization evals graded by
both advisors and prompt engineers, translation evals for multilingual client
communication, and retrieval methods tuned with OpenAI against the results.
Domain experts grade, not just engineers.

> **Why this correction changed the deck.** The previous version of this slide
> said Morgan Stanley had no public account of eval cadence or drift handling,
> making them the least documented of the first-party set. Reading the OpenAI
> case study in full disproved that. They are now one of two companies here
> with published eval discipline, alongside Dropbox. If you present this deck
> to anyone who saw the earlier version, that is the change to mention.

---

### [Slide 17 — JPMorgan, and scale in context]

JPMorgan gets no diagram because there's no architecture to draw. There are
numbers — 140,000-plus users, 450-plus production use cases — and every one of
them is trade press rather than disclosure. Scale is all they have.

And this slide is deliberately not a chart. Questions per day, weekly actives,
chat-turns per month, seconds to answer — no two of these companies published
the same metric, and forcing them onto one axis would misrepresent how
differently each chose to measure itself.

> **Why refusing to chart it is the right call.** Cerebras publishes questions
> per day. Stripe publishes weekly active users. Slack publishes chat-turns per
> month. Dropbox publishes a latency budget. Elastic publishes nothing. These
> are not the same quantity in different units — they are answers to different
> questions. A bar chart would imply an ordering that does not exist, and the
> visual would be more persuasive than the data supporting it. The dots carry
> source tier instead, which is the honest comparison available.

---

### [Slide 18 — The eight, side by side]

All eight on one grid: retrieval shape, governing idea, human gate, and how it
stays fresh.

Look at the first two columns. They rhyme. Now look at the two on the right —
human gate, and freshness. That's where the divergence actually lives, and
those two columns carry the rest of this talk.

---

### [Slide 19 — What they all did the same way]

Six decisions, made independently, made the same way.

Nobody fine-tuned. All eight built retrieval instead.

Hybrid beat pure semantic search everywhere — lexical plus vectors, in every
write-up that describes retrieval. Pure embedding search failed for all of
them.

The sources stayed put. Not one attempted a migration into a single system.
They built a retrieval layer over the mess, because the mess is where people
actually write.

Citations do the safety work. Source links are table stakes; Uber goes further
and shows you the retrieved chunk itself — cheaper than prompt engineering, and
it works better.

> **Why showing the chunk beats a link.** A link asks the reader to go and check.
> Nobody goes and checks. Showing the actual retrieved paragraph next to the
> answer means a wrong answer is visibly unsupported by the text sitting
> directly beneath it. It converts verification from an action someone has to
> take into something they cannot help noticing.

Configuration sits at the edge. The centre owns infrastructure; the teams being
indexed own their own relevance.

And freshness is a pipeline, never a policy. Differential sync, Spark ETL,
incremental re-embedding, Morgan Stanley's daily regression suite. Nobody
promises currency as a rule, because a rule can't be enforced and a pipeline
can.

> **Plain English — Differential and incremental.** Both mean the same
> discipline: process only what changed. Re-embed the paragraphs that were
> edited, not the whole repository. It is what makes daily freshness affordable
> rather than a nightly full rebuild nobody can pay for.

---

### [Slide 20 — The ideology underneath]

Three beliefs sit under all of that.

Knowledge scatters, and stays scattered. People write wherever it's easiest — a
Slack thread, a PR comment, a Jira field. Every attempt to consolidate that
fails. So the retrieval layer absorbs the mess and nobody sits through a
migration.

Trust gets built, not claimed. None of them claim the model is reliable. They
build on the assumption that it isn't, then engineer around it: cited chunks,
bounded roles, inspectable plans, escalation paths, verification gates.

And governance belongs to the people with the context. The platform team owns
infrastructure. Relevance, thresholds and quality belong to the team whose work
is being indexed, because only they can tell a good answer from a merely
plausible one.

---

### [Slide 21 — Where they part company]

Four real forks, and the set splits cleanly on each one.

Retrieval or orchestration. Cerebras and Uber stop at excellent search and let
the client do the reasoning. Stripe and Dropbox run full agents with sandboxes
and multi-step plans. Same problem, an order of magnitude apart in machinery.

Who checks the answer. Elastic gates every response on an engineer, Morgan
Stanley routes findings through a person. Cerebras, Slack and Dropbox ship
straight to the reader with citations attached.

Prose or code. Dropbox alone refuses natural-language planning. Everyone else
plans in prose.

One surface or many. Uber ships a Slack bot and nothing else. Slack runs four.
Cerebras exposes primitives over MCP and lets the agent be the surface.

---

### [Slide 22 — Why the differences fall where they do]

This is the slide.

Two axes. Across: who reads the output, internal to external. Up: what a wrong
answer costs.

Bottom left — Cerebras, Slack, Uber, Stripe. Internal readers, low cost of
error. They optimise for throughput. The reader is a colleague who will spot a
wrong answer, and at 15,000 questions a day human review does not scale. So
they don't attempt it.

Top right — Elastic and Morgan Stanley. External readers, high cost. Both put a
person in front of the customer. Not from doubt about the model — because
accountability cannot be handed to one.

Then Dropbox, which is the case that proves the rule. External users, high
cost, but they can't staff a reviewer per query. So they engineer the audit
instead: a readable code plan, and an interpreter they own.

Elastic could not run Cerebras' design. Cerebras would drown under Elastic's
review gate. Both are correct.

So when you're deciding what to build, don't start with the retrieval stack.
Start with who reads the output and what it costs when it's wrong. That fixes
the gate, and the gate determines everything above it.

> **Positions on this slide are interpretive.** The claim is the ordering, not
> the coordinates. Nobody published a number for "cost of a wrong answer". If
> someone challenges a specific placement, concede the point and hold the
> ordering — that is what the slide is actually asserting.

---

### [Slide 23 — What is not verified]

Before anyone quotes this deck externally.

Top item: the claim that Morgan Stanley advisors may not forward assistant
output to clients. That's refuted, not merely unconfirmed. It appears only in
third-party writeups, and the October 2024 release states the opposite
mechanism — a patented one-click export moves findings into an email draft, in
their words, ready to be modified and customized before sharing with clients. A
person edits before sending. That's the constraint, not a bar on sending.

Second: two Morgan Stanley figures are trade press. The 3x question volume and
the tenfold turnaround are CNBC interview claims that appear in neither press
release. The corpus size, the 98% and the eval framework are first-party.

"Hours saved" is a self-reported estimate everywhere it appears. Uber's 13,000,
Slack's 10,000 a year, Stripe's 25,000, JPMorgan's three to six a week. None
measured against a control. None comparable across companies.

> **How to talk about "hours saved" if pressed.** These are internally modelled
> figures — an estimate of time per task multiplied by task volume — not
> measured against a group that did without the tool. The direction is
> probably right; the magnitude is marketing. Cite them as claims, never as
> findings, and never add two companies' figures together.

The slide also carries two items I skip for time: an unverified note about
Stripe rejecting earlier approaches, which the re-read did not confirm and
which stays off the Stripe slides entirely, and the fact that every JPMorgan
figure is trade press with no engineering account behind it.

---

### [Slide 24 — Sources]

Every claim on a company slide traces back to one of these. Six first-party
engineering write-ups, three Morgan Stanley sources read in full — two press
releases and OpenAI's case study — and trade press for JPMorgan.

If you take one thing from this: nobody fine-tuned, nobody migrated, and
everybody engineered around a model they don't trust. What separated them was
who was going to read the answer.

Questions.

---

## Glossary, alphabetical

For looking up during Q&A. The definitions are mine. Where an entry names a
specific company figure — Cerebras' 3,072 dimensions, Stripe's 1,000+ skills —
that part traces to `PRIOR-ART.md` like the rest of the deck.

| Term | What it is |
|---|---|
| **Agent** | A model that acts in a loop — calls a tool, reads the result, decides again — rather than answering once. |
| **AgentStudio** | Stripe's console where domain teams build, test and monitor their own agents. A control plane, not a runtime. |
| **API** | The interface one piece of software uses to call another. |
| **Age decay** | A ranking signal favouring newer documents, so the recent answer wins a tie. |
| **Chunking** | Splitting documents into pieces small enough to embed. Where you cut determines what you can find. |
| **Control plane** | Where a system is configured and observed, as distinct from where the work runs. |
| **Deterministic** | Same input, same output, every time. Rare in AI systems and the reason Dropbox plans in code. |
| **DSL** | A small programming language built for one narrow purpose. |
| **Embedding** | Text converted to a list of numbers so that similar meanings sit near each other. Cerebras uses 3,072 numbers per text. |
| **ETL** | Extract, transform, load. The standard shape of a data pipeline. |
| **Eval** | A test set with known-good answers, run to measure whether a model is performing. |
| **Fine-tuning** | Retraining a model on your own data so knowledge lives in its weights. Nobody in this deck did it. |
| **Full-text search** | Literal word matching. Exact where embeddings are fuzzy. |
| **Hybrid search** | Full-text and embeddings together. The universal finding of this deck. |
| **IDE plugin** | The assistant embedded in the editor a programmer already works in. |
| **IDF** | Inverse document frequency. Rare words score high, common words near zero. Why "sounds good, thanks!" never wins a search. |
| **Interpreter** | The thing that executes a program step by step. Dropbox wrote their own to control what agent code may do. |
| **Kubernetes** | The standard system for running workloads across a fleet of machines. |
| **LangChain** | Open-source framework for building applications on language models. `deepagents` is its long-running-agent library. |
| **LLM** | Large language model. Fluent, plausible, with no built-in sense of what is true. |
| **LLM-as-judge** | Using one model to grade another's output at a scale humans cannot review. |
| **MCP** | Model Context Protocol. An open standard for exposing tools to any AI agent. |
| **Multi-tenant** | One shared system serving many isolated customers or teams, none able to see another's data. |
| **Netlist** | The machine-readable wiring list of a chip design. Cerebras is a chip company; theirs sit in the same table as Slack threads. |
| **Postgres** | An ordinary open-source relational database. Cerebras used it instead of a specialist vector database. |
| **Pull request** | A reviewed, auditable proposal to change shared code. Cerebras makes every data connector one. |
| **RAG** | Retrieval-augmented generation. Search your documents, paste the results into the prompt, answer only from those. |
| **Reranker** | A slower, more careful second scoring pass over a shortlist. |
| **Regression suite** | Fixed test cases re-run continuously to catch what used to work and quietly stopped. |
| **RRF** | Reciprocal rank fusion. Merges ranked lists using position rather than score, because the scores are not comparable. |
| **Sandbox** | An isolated environment where code runs unable to reach anything outside it. Where guardrails are actually enforced. |
| **Schema** | The agreed shape of a record: which fields exist and what goes in them. |
| **Similarity threshold** | The minimum score a document must clear to be used. The real hallucination dial. |
| **Skill** | A capability an agent can invoke. Stripe has 1,000+. |
| **Static analysis** | Checking a program by reading it, before it runs. Possible for code, impossible for prose. |
| **Surface** | A place a human reaches the system from: web app, Slack, browser extension, IDE. |
| **Surface-agnostic** | One backend behind many front doors, so adding a front door adds no new stack. |
| **Vector database** | A database specialised in storing embeddings and finding the nearest ones fast. |

---

## What to do if someone asks a question you cannot answer

Say the deck is silent on it. Seven of these companies published what they
chose to publish, and all seven left things out — none published cost, none
published headcount, and only Uber published a helpfulness rate that did not
flatter them. The gaps are real gaps, not omissions from this reading, and
`PRIOR-ART.md` records which is which.

That is also the honest position for the deck overall. It reports what eight
companies said about themselves. It is not an audit of what they built.
