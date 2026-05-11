---
name: minimal-beamer
description: Build a LaTeX Beamer presentation strictly from the bundled minimal Beamer template (assets/template/). Use this skill whenever the user mentions making slides, a presentation, a deck, a talk, or a Beamer/LaTeX presentation — in English ("slides", "deck", "talk", "presentation", "make me a deck about X"), 繁體中文 (「投影片」「簡報」「報告投影片」「做一份簡報」「做投影片」「做 PPT」「做 LaTeX 簡報」「Beamer 簡報」), or 简体中文 (「幻灯片」「演示文稿」「做一份演示」「做演示文稿」「做幻灯片」「做 PPT」「做 LaTeX 演示」「Beamer 演示」) — even if they just dump a topic, a paper, or some notes. Treat "PPT" / "ppt" as a request for slides regardless of whether the user actually wants a .pptx (default to Beamer; only switch if they explicitly say PowerPoint). Do NOT start writing .tex without running the clarification workflow described in this skill first. Vague inputs (a bare topic word, "做一份关于 diffusion models 的简报", "做我硕士论文的 defense slides", "make a deck about X") MUST go through MULTI-ROUND clarification (typically 4-5 rounds) before any frame is drafted. After every build, a mandatory revision loop engages. Use this skill instead of inventing a Beamer setup from scratch — the template is the source of truth and must not be replaced or restyled.
---

# Minimal Beamer Presentation Skill

You are producing a Beamer slide deck **using the bundled minimal template** at
`assets/template/`. The template is the source of truth: copy it whole and edit
content inside it. Do not invent a different preamble, do not switch themes
unless the user explicitly asks, do not pull in random packages.

This skill is a **workflow**, not a one-shot generator. **You will spend more
turns asking than writing.** That is correct. Every LLM-default choice you
make without asking is a future revision, and revisions cost more than
questions.

## The non-negotiable rules

These exist because every time they were skipped, the user had to redo the
deck:

1. **`AskUserQuestion` is the heartbeat of this skill.** Two places it is
   mandatory and non-skippable:
   - **Before writing any `\begin{frame}`** — clarification is MULTI-ROUND
     (typically 4-5 rounds), not single-round. See Step 1.
   - **After every successful build** — the first turn you send the user
     after `build.sh` succeeds MUST include an `AskUserQuestion` call
     (Step 6). Prose-only handoff that ends with "tell me what you think"
     is a violation.

2. **DO NOT DEFAULT. ASK.** This is the most-violated rule and the cause
   of most revisions. Any decision that affects more than one frame
   (audience, depth, tone, layout style, visual style, narrative arc,
   notation convention, citation policy, mascot author name, *any of
   them*) **MUST be asked, not defaulted**. The only exception is when
   the user says explicitly "你决定" / "use your judgment" / "你看着办" —
   then you can default, AND you must list every default in Step 6.
   "I assumed you'd want X" is the failure mode this rule kills.

3. **NO COLORED BLOCKS, NO AI PLACEHOLDER HEADINGS.** Do not use
   `\begin{block}{标题}`, `\setbeamercolor{block ...}`, custom
   `intuition`/`warningblk` environments, or `tcolorbox`. Do not pepper
   the deck with placeholder section headings like 「关键洞见」「直觉」
   「核心想法」「反直觉的结论」「重要观察」. If a paragraph has a real
   conceptual subtitle (e.g. "两个致命问题", "训练循环") use a bold
   `\textbf{...}` inline lead. If it doesn't, write the paragraph
   directly. Human-written slides do not have colored callout boxes on
   every slide. AI-written slides do.

4. **DEFAULT STRUCTURE = `itemize` AND `enumerate`.** Do not pile prose
   in a slide. If a slide has 3+ ideas, they go in a list. Use ▶ /
   `itemize` for parallel points, `1.`/`enumerate` for ordered steps.
   Prose paragraphs are for transition sentences and final punchlines,
   not for content delivery.

5. **UNIFORM FONT SIZE.** Body text uses `\normalsize` throughout. Do
   NOT sprinkle `\footnotesize` / `\small` / `\scriptsize` to fit content
   on a page. **If a frame overflows, the fix is structural** (split the
   frame, cut bullet points, remove a placeholder heading, move detail
   to a follow-up frame) — not shrinking the font. The only places where
   smaller fonts are legitimate:
   - Code listings (`\scriptsize` or `\tiny` inside `lstlisting`)
   - Reference / footnote-style asides explicitly marked as such
   - The auto-generated `\AtBeginSection` TOC frame (if it exists)
   Even those should be questioned per Step 1.

6. **Never write a single `\begin{frame}` until clarification is done.**
   See Step 1. Slides built from underspecified input look generic and
   wrong, and the user will throw them away.

7. **Never invent facts.** If you do not know the topic well enough to
   defend every claim on every slide, use WebSearch / WebFetch / read
   the source files before writing. Citing a paper you have not actually
   read is forbidden.

8. **The template is the template.** Copy `assets/template/` into the
   working directory and edit `main.tex` in place. Keep the preamble
   structure. Add frames following existing patterns. If something
   requires a new package, ask the user first.

9. **Compile before declaring done.** Run `scripts/build.sh` and resolve
   every error.

10. **Do Step 0 (environment check) first, every time.**

11. **The first PDF is a draft, never a deliverable.** The user — not
    you — decides when the deck is done.

## Script compatibility

All bundled scripts are **bash** (`check_env.sh`, `build.sh`, `preview.sh`,
`clean.sh`). They run directly on **macOS and Linux**. On **Windows**: use
WSL (recommended) or Git Bash; native PowerShell / CMD not supported.

## Step 0 — Check the LaTeX environment (FIRST, every time)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/check_env.sh
```

Exits with `0` (ready), `1` (partial), or `2` (no LaTeX at all).

- **Exit 0**: proceed.
- **Exit 1**: note what's missing; offer install if CJK needed.
- **Exit 2**: stop. Tell the user what to install:
  - macOS: `brew install --cask mactex` (full) or `basictex` + `sudo
    tlmgr install latexmk collection-fontsrecommended xetex xecjk
    collection-langcjk`
  - Linux Debian/Ubuntu: `sudo apt install texlive-full latexmk`
  - Linux Fedora/Arch: `texlive-scheme-full` / `texlive-meta`
  - Linux distro-agnostic: install upstream TeX Live from
    https://tug.org/texlive/quickinstall.html
  - Windows: MiKTeX (https://miktex.org/download) or TeX Live for
    Windows; in WSL use Linux instructions

Re-run after install.

## Step 1 — Multi-round clarification (typically 4-5 rounds)

**The core principle: ASK, DO NOT DEFAULT.**

A LLM-default choice that turns out wrong costs a regeneration. A question
costs the user one click. **The math is always in favor of asking.**

### Step 1.0 — Parse the prompt; extract what's explicitly given

Before asking anything, walk through every field below and write down what
the prompt explicitly states. Be honest: extract only what's there, don't
infer or assume.

The 5-readers test: *"If five people read this prompt, would they all
interpret this field the same way?"* If no — the field is **not given**,
ask.

If the user wrote "你决定" / "use your judgment" / "你看着办" — only then
may you default the remaining fields, AND you must list every default in
the Step 6 handoff so the user can override.

### Step 1.1 — The fields you must ask about

This list is intentionally long. Most decks need to clarify ~15-20 of
these before drafting. Do not skip any whose answer isn't in the prompt
verbatim.

#### Group A — Speaker

- **Speaker role**: faculty / TA / student / industry practitioner /
  thesis defender / interview candidate / other
- **Speaker–audience relationship**: authority (teaching down) / peer
  (presenting alongside) / candidate (being evaluated) — this changes
  every "我们 / 你 / 大家" choice
- **Author name(s) for the title page**: one person or several? Any
  affiliation? Or leave blank for the user to fill?

#### Group B — Audience

- **Audience role/group**: be specific (e.g. "intro stats class with no
  ML background", "thesis committee", "5 classmates in our course")
- **Prior knowledge**: by topic. Don't accept "zero background" alone —
  zero in *what*?
- **Audience size**: ~5 (small room) / ~30 (classroom) / 100+ (lecture
  hall) / online streamed — affects density and visual scale
- **Interaction**: monologue / mid-talk Q&A / discussion-style /
  workshop — affects pacing and content density

#### Group C — Occasion, length, location

- **Length in minutes** (numeric, not "course presentation")
- **Q&A buffer included?** If 30 min talk includes 10 min Q&A, content
  is 20 min not 30
- **Pacing — minutes per slide expectation**: ~30 sec/slide (fast
  overview) / ~1 min/slide (standard) / ~2 min/slide (dense technical)
  — this fixes total slide count
- **Venue / medium**: projector + large screen / laptop screen / Zoom
  share / handout-only — affects font size and contrast choices

#### Group D — Content scope

- **Main topic + sub-topics**: narrow enough that the title writes itself
- **3–5 key takeaways**: what the audience should remember the next day.
  Section names are NOT takeaways.
- **Source / grounding**: papers, repo, notes, "research it yourself
  (with a primary source)", or original work?
- **Technical depth**: at the granularity of specific terms. Don't
  accept "intuition-leaning"; ask "can I use the word *linear
  transformation* without explanation?" "is *softmax* assumed?" etc.
- **Mathematical notation conventions**:
  - Vectors: column or row by default?
  - Notation style: LaTeX standard or matching a specific paper/textbook?
- **Citations / References**: include `\cite{}` calls and a References
  frame? **DEFAULT IS NO** unless user explicitly says they want them.
- **Narrative arc**: linear technical walkthrough / story with hook /
  contrast/debate / chronological history / problem-solution

#### Group E — Visual style

- **Block style**: colored callout boxes vs plain text. **DEFAULT IS
  PLAIN TEXT** — colored blocks (`\begin{block}`, custom intuition
  environments, tcolorbox) read as AI-generated. Only use if user
  explicitly asks.
- **List style**: `itemize` (▶ bullets) / `enumerate` (1. 2. 3.) /
  prose paragraphs? — default to itemize + enumerate; never prose-only
- **Section transitions**: TOC at chapter starts? Section dividers?
  Just continuous flow?
- **Section numbering visible**: "第一章 / Chapter 1" prefix vs plain
  section titles?
- **TOC style**: decorative (with shading/icons) vs plain list?
- **Title page elements**: subtitle? date? institute? logo? Pick each
  individually — do not default any of them in.
- **Closing slide**: 「谢谢 + 提问」/「Q&A」/ blank / contact info?
- **Footer / page number / nav bar**: show page number? show nav dots
  at the top? footer text? — Beamer defaults often look cluttered;
  ask explicitly
- **Aspect ratio**: 4:3 / 16:9
- **Theme / colors**: default Beamer / specific institutional palette /
  no color
- **Figure style**: schematic (drawn with TikZ by me) / real screenshots
  user will provide / both / no figures
- **Real product screenshots**: OK to embed ChatGPT/Claude/etc. UI
  screenshots? Some venues prohibit; ask

#### Group F — Tone and cultural fit

- **Tone**: formal academic / casual peer / corporate / pedagogical
- **Humor / memes**: allowed? Internet slang / "(bushi)"-style asides
  OK? Conservative? — affects every illustrative example
- **Example choices**: cultural sensitivity. Names of dictators,
  political figures, religious figures, contested topics — do you want
  to use them as analogies, or stay neutral (e.g. king/queen, cat/dog)?
- **Language conventions**:
  - Punctuation: full-width (，：；！？) or half-width — for CJK,
    full-width is standard but ask
  - Quote style: 中文“…” / 「…」 / English `` `'…'' `` — pick one and
    enforce throughout
- **English term handling in CJK deck**: keep original (e.g. "Attention")
  / translate fully (e.g. "注意力机制") / bilingual on first occurrence
  (e.g. "注意力(Attention)") then one style?
- **English proper nouns**: bilingual on first occurrence / always
  original (e.g. names like Chomsky, Skinner, GPT-4)?

#### Group G — Delivery & output

- **Speaker behavior**:
  - **Animated reveal** (`\pause` / `\onslide`) — bullets appear one by
    one as you click? Or whole page at once? — changes source structure
    significantly
  - **Speaker notes** (`\note{...}`) — write spoken-notes alongside
    slides? (Generates a separate notes PDF.)
- **Deliverables**:
  - PDF only / PDF + `.tex` source / handout PDF (no animations,
    multiple slides per page) / all of above
  - **File size constraints** (conference upload limits, e.g. 50 MB)?
- **Versioning**: single deck / variants for different audiences (e.g.
  short version + long version)?

#### Group H — Code listings (only if the deck contains code)

- **Listing package**: `lstlisting` (works everywhere) / `minted`
  (prettier, needs `--shell-escape` and Pygments)?
- **Line numbers**: show / hide / only on lines being referenced?
- **Syntax highlighting**: colored / monochrome / minimal?
- **Languages used**: Python / C++ / Rust / pseudo-code — set up
  language modes
- **Line length limit**: how much to fit per line (affects which
  examples you can use verbatim)

### Step 1.2 — Round structure

**Do not cram all questions into one `AskUserQuestion` call.** Each
call holds at most 4 questions; trying to fit 30+ in one round produces
a wall the user won't engage with. Plan for **5–7 rounds**.

Suggested grouping (adapt to what's missing):
- **Round 1**: speaker role + audience + author name + relationship
  (Group A + B core)
- **Round 2**: length + Q&A buffer + pacing + venue (Group C)
- **Round 3**: topic scope + takeaways + source + technical depth
  (Group D core)
- **Round 4**: narrative arc + notation conventions + citations
  (Group D continued)
- **Round 5**: block style + list style + TOC/section dividers + title
  page elements + closing slide + nav/footer (Group E core)
- **Round 6**: aspect ratio + theme + figure style + screenshots
  (Group E continued)
- **Round 7**: tone + humor/memes + example sensitivity + punctuation
  + quote style + English-term handling (Group F)
- **Round 8** (if needed): animation/pause + speaker notes +
  deliverables + file size (Group G)
- **Round 9** (only if deck has code): code listing setup (Group H)

If a field's answer is already in the prompt, skip it. If everything
in a round is already given, skip the round. **But every field with
ambiguity gets its own question.**

### Step 1.3 — Stop condition

Stop only when EVERY field in the list above is either (a) answered
explicitly, (b) given in the original prompt, or (c) the user said
"你决定" and is willing to react to the result. Anything else is "still
ambiguous" — keep asking.

If you find yourself thinking "they probably want X" — that's not an
answer. Ask.

## Step 2 — Research, only if needed

If the user delegated content research to you, do it now, **before**
writing .tex. Use `WebSearch` and `WebFetch`. Take notes in scratch (not
in the .tex file).

Rules:
- Every non-trivial claim must be traceable to a source you read.
- Numbers, dates, author names: verify before writing.
- If you can't confirm something, tell the user and ask whether to drop
  or change it.

## Step 3 — Build the deck from the template

### Source / build separation

```
<deck-name>/
├── .gitignore
├── main.tex
├── references.bib       ← only if the user said they want citations
├── figures/
├── tables/
└── build/               ← created by build.sh; do NOT edit
    ├── main.pdf
    ├── main.aux/.log/... (intermediates)
    └── _preview/
        └── slide-NN.png  ← from preview.sh
```

### Build steps

1. `cp -r ${CLAUDE_PLUGIN_ROOT}/assets/template/ ./<deck-name>/`
2. Edit `main.tex` in place. Title page elements (title, subtitle,
   author, institute, date) — **set exactly what the user said in Step
   1**. If they said "no date" or "leave author blank", do that — do
   NOT put `\today` or your GitHub handle default.
3. Use existing frame patterns. See `references/beamer-patterns.md` for
   the catalog.
4. **Body content style** (enforces rules 3, 4, 5 above):
   - No `\begin{block}{...}` unless user asked for colored callouts
   - No `intuition` / `warningblk` / `tcolorbox` environments
   - No placeholder subtitle like 「直觉」「关键洞见」「核心观察」 unless
     they correspond to actual conceptual subsections
   - Use `itemize` / `enumerate` by default for 3+ parallel ideas
   - Body text in `\normalsize`; do not sprinkle smaller sizes
5. References: **only include if the user explicitly said yes**. If yes,
   add `\bibliography{references}` frame at the end and a `references.bib`
   file. If no, remove the References frame from the template and
   remove `\cite{}` calls.
6. CJK: add `\usepackage{xeCJK}`; **do NOT add `\setCJKmainfont`** by
   default — let `xeCJK` pick system default. Only set a CJK font if
   the user explicitly chose one.

Keep slides genuinely minimal: short bullets, one idea per frame, ample
whitespace. If a frame overflows, **split it or trim — never shrink the
font**.

## Step 4 — Compile

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/build.sh ./<deck-name>/main.tex
```

PDF lands at `./<deck-name>/build/main.pdf`. All intermediates also go
under `build/`.

If `latexmk` is missing, the script falls back to `pdflatex`. For CJK /
`fontspec`, it auto-detects and uses `xelatex`. Read the log on failure,
fix the actual error (don't keep adding `\usepackage` until something
compiles), re-run.

To wipe build artifacts:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/clean.sh ./<deck-name>/
```

## Step 5 — Visually self-review the PDF

A clean compile is necessary but not sufficient. You MUST visually check
every frame before going to Step 6.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/preview.sh ./<deck-name>/build/main.pdf
```

`Read` each PNG and check for:

- **Overflow** — text running off frame edges. **Fix structurally:
  split the frame, cut bullets, remove a heading. Do NOT shrink the
  font.**
- **Tofu / boxes (□□□)** — CJK rendering as rectangles → wrong font /
  wrong engine. Fix `xeCJK` font and recompile.
- **Layout collisions** — title overlapping content, footer eating
  bottom line, two-column overlap.
- **Image issues** — figures missing, mis-sized, low-res.
- **Empty / near-empty frames** — usually means over-split content.
- **Math** — equations cut off, oversized, raw `$...$`.
- **Forbidden elements**: any `\begin{block}` colored boxes you forgot
  to remove? Any 「直觉」「关键洞见」placeholder headings? Any
  `\footnotesize` body text? Fix them.
- **Punctuation consistency**: CJK paragraphs should use the punctuation
  style the user chose. No mixing.

For >20-slide decks, scan a representative subset. For short decks,
look at every slide.

> **Checkpoint**: Step 5 ends when the PDF actually looks right. Your
> next action is **not** to write a prose summary — it is to invoke
> `AskUserQuestion` (Step 6).

## Step 6 — Handoff: ONE atomic action

After Step 5 succeeds, your reply has THREE parts in a single turn:

1. **PDF path** (one line). Tell them to open it.
2. **"What I decided for you" list** — every implicit choice you made.
   If you followed rule #2 strictly, this list should be EMPTY or near-
   empty. If it's long, you violated rule #2 — but document it anyway
   so the user can correct.
3. **An `AskUserQuestion` tool call** — non-negotiable.

**Q1: the gate question** with "no changes" first-class:

```
Q: First-draft PDF is ready. Please open it. Anything to change?
  - Looks good, wrap up
  - A few small tweaks
  - Major direction needs adjusting
  - Specific slide(s) have issues
```

**Q2–Q4: 1–3 targeted follow-ups** about the most likely failure points
for THIS deck. Don't template — look at what you built and ask about
what's hardest to judge without seeing the PDF.

### Drill-in sub-loop (non-negotiable)

If the user picks anything other than "no changes":

1. Parse the feedback into distinct items.
2. Drill into each with `AskUserQuestion` until actionable:
   - Which slide(s)?
   - What's wrong?
   - What does "right" look like?
3. Vague feedback ("怪怪的") MUST be decomposed — keep asking with
   concrete options.
4. Only after ALL items are actionable → fix, recompile, preview, then
   return to Step 6 top.

### Exit condition

The user — and only the user — exits this loop. Explicit "done" / "ok"
/ "可以了" / "好了" / "完美" or `AskUserQuestion` "no changes" answer.

### Editing an existing deck

Revision loop without Steps 1–5. Read existing `.tex`, edit, recompile,
preview, then re-enter Step 6. For non-trivial edits (re-target
audience, change length, change style) run abbreviated clarification
first.

## When you are tempted to skip the workflow

Don't. The most common skip mode: finishing Step 5, feeling a strong
"now I report to the user" instinct, and writing a long prose handoff
that ends with "let me know what you think". **That is not Step 6.**
Step 6 is the `AskUserQuestion` tool call. Prose alone never exits this
skill.

The second most common skip mode: asking 1 round of questions and
calling Step 1 "done". **It is not done.** Step 1 is multi-round. If
you wrote a frame before going through 4-5 rounds, you skipped Step 1.

## Reference files

- `references/beamer-patterns.md` — frame patterns, Beamer syntax
- `references/clarification-playbook.md` — example `AskUserQuestion`
  sets
- `references/compile-troubleshooting.md` — common errors and fixes
- `assets/template/` — canonical template
- `scripts/check_env.sh` — Step 0
- `scripts/build.sh` — Step 4
- `scripts/preview.sh` — Step 5
- `scripts/clean.sh` — wipe `<deck>/build/`
