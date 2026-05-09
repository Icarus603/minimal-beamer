---
name: minimal-beamer
description: Build a LaTeX Beamer presentation strictly from the bundled minimal Beamer template (assets/template/). Use this skill whenever the user mentions making slides, a presentation, a deck, a talk, or a Beamer/LaTeX presentation — in English ("slides", "deck", "talk", "presentation", "make me a deck about X"), 繁體中文 (「投影片」「簡報」「報告投影片」「做一份簡報」「做投影片」「做 PPT」「做 LaTeX 簡報」「Beamer 簡報」), or 简体中文 (「幻灯片」「演示文稿」「做一份演示」「做演示文稿」「做幻灯片」「做 PPT」「做 LaTeX 演示」「Beamer 演示」) — even if they just dump a topic, a paper, or some notes. Treat "PPT" / "ppt" as a request for slides regardless of whether the user actually wants a .pptx (default to Beamer; only switch if they explicitly say PowerPoint). Do NOT start writing .tex without running the clarification workflow described in this skill first; vague inputs (a bare topic word, "做一份关于 diffusion models 的简报", "做我硕士论文的 defense slides", "make a deck about X") MUST go through clarification before any frame is drafted. After every build, a mandatory revision loop engages — the number of follow-up rounds is driven by the user's feedback, not capped. Use this skill instead of inventing a Beamer setup from scratch — the template is the source of truth and must not be replaced or restyled.
---

# Minimal Beamer Presentation Skill

You are producing a Beamer slide deck **using the bundled minimal template** at
`assets/template/`. The template is the source of truth: copy it whole and edit
content inside it. Do not invent a different preamble, do not switch themes
unless the user explicitly asks, do not pull in random packages.

This skill is a **workflow**, not a one-shot generator. The first time the user
asks for slides, you almost certainly do not have enough information to produce
a deck they would actually use. Your job is to extract that information through
structured questioning, then build, then compile.

## The non-negotiable rules

These exist because every time they were skipped, the result was bad:

1. **Never write a single `\begin{frame}` until clarification is done.** Even
   if the user seems to want speed, slides built from underspecified input look
   generic and wrong, and the user will throw them away. The clarification
   conversation IS the work.
2. **Never invent facts.** If the user says "make a deck about
   [whatever — protein folding, post-quantum crypto, your lab's latest
   paper]" and you do not know the topic well enough to defend every claim
   on every slide, you must use WebSearch / WebFetch / read the source
   files before writing. Citing a paper you have not actually read is
   forbidden. If a number, date, author, or quote is uncertain, look it up
   or omit it.
3. **The template is the template.** Copy `assets/template/` into the working
   directory and edit `main.tex` in place. Keep the preamble, the title-page
   structure, the outline frame, the references frame. Add new frames
   following the existing patterns (bullet lists, two-column, table, figure,
   citation). If something requires a new package, mention it to the user
   first.
4. **Compile before declaring done.** Run `scripts/build.sh` and resolve every
   error. A `.tex` that does not produce a PDF is not a deliverable.
5. **Do Step 0 (environment check) first, every time.** If the user has no
   working LaTeX installation, nothing else in this skill matters. Detect
   their OS and tell them exactly what to install before you ask any
   clarification questions.
6. **The first PDF is a draft, never a deliverable.** After every build you
   enter a mandatory revision loop (Step 6). The user — not you — decides
   when the deck is done. "I think it's good" from your side does not exit
   the loop; only an explicit OK from the user does. Even with perfect
   input, LLMs introduce phrasing/emphasis/balance issues the user only
   spots once they see the rendered slides. Plan for revision rounds; do
   not try to skip them.

## Step 0 — Check the LaTeX environment (do this FIRST, before clarification)

Run the bundled environment-check script:

```bash
bash ~/.claude/skills/minimal-beamer/scripts/check_env.sh
```

It detects the OS, looks for `pdflatex` / `xelatex` / `lualatex` / `latexmk`
/ `tlmgr` (or MiKTeX's `mpm`) on `PATH`, prints a JSON-ish summary, and
exits with `0` (ready), `1` (partial — e.g. has `pdflatex` but missing
`xelatex` for CJK), or `2` (no LaTeX at all).

### What to do based on the result

**Exit 0 — ready.** Note the engines available (English-only or full CJK
support) and proceed to Step 1.

**Exit 1 — partial.** You have `pdflatex` but no `xelatex`/`fontspec` →
English deck is fine, but you must warn the user before they pick CJK in
Round 1, and offer the install command for the missing piece. Or you have
no `latexmk` → fine, the build script falls back to raw `pdflatex` calls.

**Exit 2 — no LaTeX installed.** Stop. Do NOT start the clarification
workflow. Tell the user what to install based on their OS and wait for them
to confirm install is done. Recommended installations:

- **macOS** — Either:
  - Full: `brew install --cask mactex` (≈5 GB, includes everything;
    recommended for most users).
  - Minimal: `brew install --cask basictex` (≈100 MB) then
    `sudo tlmgr install latexmk collection-fontsrecommended xetex xecjk
    collection-langcjk` to add what this skill needs.
  - Without Homebrew: download the MacTeX `.pkg` installer from
    https://tug.org/mactex/ and run it.
- **Linux (Debian/Ubuntu)** —
  `sudo apt install texlive-full latexmk` (full, ≈4 GB) or
  `sudo apt install texlive-latex-base texlive-latex-extra texlive-fonts-
  recommended texlive-xetex texlive-lang-chinese latexmk` (minimal for this
  skill).
- **Linux (Fedora/RHEL)** — `sudo dnf install texlive-scheme-full latexmk`
  or the smaller `texlive-collection-latex texlive-collection-xetex
  texlive-collection-langchinese latexmk`.
- **Linux (Arch)** — `sudo pacman -S texlive-meta` or the smaller
  `texlive-basic texlive-latex texlive-latexextra texlive-xetex texlive-
  langchinese texlive-bin`.
- **Linux (any) — distro-agnostic** — Install upstream TeX Live from
  https://tug.org/texlive/quickinstall.html. This gets you the same TeX
  Live as macOS's MacTeX. Add `/usr/local/texlive/<year>/bin/<arch>` to
  `PATH`.
- **Windows** — Either:
  - **MiKTeX** (recommended for Windows) — installer at
    https://miktex.org/download. Ships with auto package install on first
    use, very Windows-friendly.
  - **TeX Live for Windows** — `install-tl-windows.exe` from
    https://tug.org/texlive/windows.html. Same TeX Live as Linux/macOS.
  - In WSL: use the Linux instructions above inside the WSL distro.

**Optional but recommended for everyone**: a SyncTeX-aware viewer (Skim on
macOS, Okular/Zathura on Linux, SumatraPDF on Windows). Not required to run
the skill — `Read` of the rasterized PNGs (Step 5) is what *you* use to
self-review.

After the user confirms install, re-run `check_env.sh` and continue.

### Why this step exists

If LaTeX is missing, every later step silently fails: the `.tex` looks
right, `build.sh` errors out, the user has no PDF, and the whole
clarification effort was wasted. Catching it up front saves the user from
investing half an hour answering questions for a deck that can't be built.

## Step 1 — Clarification workflow

Goal: end this step knowing every architectural decision the deck depends on
(audience, length, language, topic scope, takeaways, source/grounding,
depth, outline). **Architectural decisions are non-negotiable — they must be
locked before you write a single frame.** Getting any one of them wrong
means the entire deck has to be regenerated, and regeneration is much more
expensive than asking one more question. Don't trade clarification cost for
revision cost; that's the opposite of automation.

But also: don't waste the user's time asking for things they already gave
you. The cost-saving move is to **read the prompt carefully and only ask
about real gaps**, not to skip categories.

### Step 1.0 — Parse the prompt before asking anything

Before calling `AskUserQuestion`, do this silently (notes for yourself, not
shown to the user):

1. **Extract every architectural fact already in the prompt.** Walk through
   each required field below and write down what the prompt explicitly or
   strongly-implicitly says. Be honest about what's actually there vs. what
   you're inferring.

2. **Identify what's still missing or ambiguous.**

3. **Decide which "nice-to-have" fields you'll just default** (and surface
   the defaults later in Step 6a's "what I decided for you" list, where the
   user can react to them with the PDF in hand).

#### Required (architectural — MUST be locked before writing .tex)

**The "5 readers" test.** For each field below, before marking it "given",
ask yourself: *"If five different people read this prompt, would they all
interpret this field the same way?"* If the answer is no — even slightly —
the field is **NOT given** and must be asked. LLMs (you included) tend to
read a long-looking prompt and feel it's complete; the 5-readers test is
the antidote. Lean toward "not given" when in doubt; one extra question
costs the user one click, while one wrong assumption costs a regenerated
deck.

| Field | What counts as "given" — be strict |
|---|---|
| **Audience** | Specific role/group AND specific prior knowledge level. Examples that count: "my lab (PhDs in NLP)", "first-year undergrads who took intro stats but no ML", "thesis defense committee", "high-school physics teachers". **Vague gestures DON'T count: "students" / "general audience" / "零基础同学" / "听众" / "the team"** — "zero background" is meaningless without "in what" (never seen the topic? seen the prerequisite but not this? domain expert in adjacent field?). Always probe prior knowledge if it's vague. |
| **Length** | A concrete number — minutes OR slide count OR a precise industry term ("5-min lightning", "20-min conference slot", "full 90-min lecture", "thesis defense ~45 min + Q&A"). **Vague framings DON'T count: "course presentation" / "组会" / "课程汇报" / "lab meeting" / "the talk"** — a course presentation can be 10, 20, or 90 minutes, and the deck looks completely different at each length. |
| **Language** | Stated outright OR prompt-language matches with no other-language signals. |
| **Topic scope** | Narrow enough that the title page writes itself AND no major sub-topic is left ambiguous. A bare topic word (e.g. "Transformer", "diffusion models", "我的硕士论文", "epidemic modeling") → NOT given. Even when the user names sub-topics ("X 的原理 + 应用 + 底层代码"), it's NOT given if (a) the sub-topics could each mean very different things to different listeners, or (b) without a length budget the trade-off between sub-topics is undetermined. Probe to narrow. |
| **Key takeaways (3–5)** | User explicitly stated 3–5 takeaways AND their relative priority (which is the headline, which is supporting), OR provided a markdown outline / paper from which you can extract candidates and confirm. **Listing 2–3 broad section areas is NOT takeaways** — sections are containers; takeaways are the specific things the audience should remember the next day. |
| **Source / grounding** | Paper(s), notes, prior slides, repo, OR an explicit "research it yourself, primary source = X". "Just research it" without scope → NOT given. |
| **Technical depth** | Specific deliverable depth: "intuition only, no derivations" / "formulas without derivations" / "with proofs" / "implementation walk-through with code" / etc. User saying "讲清楚就好,别太枯燥" → roughly given (intuition-leaning) but worth verifying in the confirmation step. |
| **Section outline** | Provided in the prompt OR will be proposed by you and confirmed. The proposal-and-confirm path counts; an unconfirmed self-generated outline does NOT. |

**Hard rule on Length and Audience specifically.** These two fields cause
the most damage when wrong (length determines slide count, pacing,
inclusion/exclusion of every section; audience determines depth on every
slide). If either is even slightly vague, mark it not-given and ask. Do
not let "the prompt is long, surely it covered length" be a substitute for
checking that the prompt actually contains a number.

#### Defaultable (nice-to-have — will appear in Step 6a's decision list)

These DON'T need to be asked up front. Default them, list them in 6a, let
the user override in the revision loop:

- Aspect ratio (default 4:3)
- Font (default template's Computer Modern; for CJK, system default via
  `xeCJK` — never hardcode `\setCJKmainfont`)
- Theme / color theme (default `default`)
- Outline frame inclusion (default yes for ≥10-slide decks, no for lightning)
- Section divider frames (default no)
- References frame (default yes if there's any citation, no otherwise)
- Speaker name / institute / date format (default user's GitHub handle or
  ask in Step 6a)
- Speaker notes (default off)
- Handout mode (default off)
- Branding (logo, institutional colors) — default none, surface as flag in 6a

The reason these are defaultable: they're truly local replacements (one
preamble line, or one frame). Changing them in Step 6 doesn't cascade — the
content stays valid.

The reason architectural fields are NOT defaultable: getting audience or
depth wrong means the content itself is wrong on every slide. You can't
"swap audiences" in revision the way you can swap fonts.

### Step 1.1 — Pick the path based on what's missing

After parsing:

- **All 8 architectural fields locked from the prompt** → 0 rounds. Skip
  straight to Step 2 (research if needed) and Step 3 (build). Do mention in
  Step 6a what you read out of their prompt so they can correct you if you
  misread.
- **1–3 architectural fields ambiguous or missing** → 1 `AskUserQuestion`
  call that targets exactly those (up to 4 questions per call). Don't pad
  with questions about defaultable items.
- **4+ architectural fields missing** → multi-round flow below, but only
  the rounds whose fields are still missing. Skip rounds whose fields are
  already locked.
- **Topic scope itself is ambiguous AND user seems unsure** ("做個介紹一
  下我們研究的東西") → BEFORE asking, do brief research (WebSearch / their
  cwd / their git history) and `AskUserQuestion` with concrete proposed
  framings as options, plus an "Other" path. Don't make the user invent a
  framing from scratch when you can propose a few.

### Step 1.2 — Ask only what's missing

Group questions into the fewest `AskUserQuestion` calls possible (up to 4
questions per call). For each question, set strong sensible defaults marked
"(Recommended)". Phrase questions in the user's language.

The category templates below are reference material — DO NOT mechanically
ask all of them. Skip any whose answer you already extracted in Step 1.0.

### Reference question templates (use only for fields actually missing)

The blocks below are templates for when you DO need to ask. Skip entire
blocks if the corresponding fields are already locked from the prompt.

#### Audience, occasion, length, language

You cannot pick the right depth or tone without these.
- Who is the audience? (lab group / conference / class / general public /
  client / interview committee — be specific)
- What is the occasion? (weekly meeting / 20-min conference talk / 5-min
  lightning / job talk / lecture / pitch)
- How long is the talk and how many slides do they want? (give them a default:
  ~1 slide per minute for technical content, ~2 minutes per slide for dense
  material)
- What language should the slides be in? English / 繁體中文 / 简体中文 /
  bilingual? This affects `babel` and fontspec choices and forces `xelatex`
  for CJK. If the user just says 中文, ask 繁體 vs. 简体. **Font default for
  CJK is the system default that `xeCJK` picks up — same spirit as the
  English template, which uses Beamer's default Computer Modern.** Do not
  hardcode a CJK font unless the user asks; only bring fonts up in Round 5
  as an optional knob.

#### Content scope and source material

This is the round that prevents hallucination.
- What are the 3–5 key takeaways the audience must leave with? (Force the user
  to articulate this. If they cannot, they do not know what the talk is about
  yet, and you should say so.)
- What source material should you draw from? (paper PDFs, their own notes,
  prior slides, a GitHub repo, a blog post, nothing — they want you to
  research it)
- If they say "research it yourself": confirm scope and that you will
  WebSearch. Tell them you will not assert anything you have not verified.
- Are there any specific results, numbers, figures, or quotes that MUST be on
  the slides?

#### Structure and depth

- Roughly what sections do they want? (Offer a draft outline based on what you
  have heard, ask them to edit it.)
- What level of technical depth — equations and proofs, or intuition only?
- Do they want a table-of-contents/outline frame? (Default: yes, the template
  has one.)
- Do they want section-divider frames between sections? (Default: no, keep it
  minimal.)

#### Visuals, tables, citations

These can mix architectural and defaultable. Citations + figures the user
wants to provide ARE architectural (you can't fabricate them later).
Whether to add a TikZ diagram or leave a placeholder is more local — can
go either way; defer to Step 6a if unsure.

- Do they have figures they want to include? (Get file paths. If not, ask
  whether you should generate diagrams via TikZ, leave placeholders, or skip
  visuals.)
- Tables: do they have data, or should you make illustrative ones?
- Citations: do they have a `.bib` file? If yes, get the path. If they want
  citations but have no bib, offer to write one as you go (each cited work
  must be a real paper you have verified).
- Figure license / source — make sure they own or can use any image they
  hand you.

#### Style polish (DEFAULTABLE — usually skip and surface in Step 6a)

The template is intentionally minimal; only deviate if the user asks. These
items are easy to swap in Step 6 (single preamble lines), so the default is
to use template settings and let the user react to the rendered PDF. Only
ask up front if (a) the user mentioned style preferences in their original
prompt, or (b) the deck is for a context that strongly implies non-default
style (e.g. "投資人 pitch" probably wants 16:9 + a colored theme).
- Theme: keep `\usetheme{default}` (recommended for minimal look) or switch?
  (Common alternatives: `metropolis`, `Madrid`, `Boadilla`, `CambridgeUS`.
  `metropolis` requires the package and a working font.)
- Color theme: default / a specific palette / institutional colors?
- Fonts: **default is the template's own font — Computer Modern for English
  decks (what Beamer ships with), and for CJK decks whatever `xeCJK` picks
  as the system default (no `\setCJKmainfont` line). If the user does not
  say otherwise, fall back to this and do not touch the font setup.** Still
  ASK in this round, because some users care. Alternatives:
  - English: Helvetica via `\usepackage{helvet}`, Latin Modern via
    `\usepackage{lmodern}`, or full custom via `fontspec` (forces
    `xelatex`/`lualatex`).
  - CJK: 繁體 → `Noto Sans CJK TC` / `PingFang TC` / `Source Han Sans TC`;
    简体 → `Noto Sans CJK SC` / `PingFang SC` / `Source Han Sans SC`. Only
    add `\setCJKmainfont{...}` if the user explicitly picks one.
- Aspect ratio: 4:3 (default) or 16:9 (`\documentclass[aspectratio=169]
  {beamer}`)?
- Anything they hate? (Common: "no clip art", "no emoji", "no gradients", "no
  reveal animations".)

### When to stop asking

### Step 1.3 — Stop condition

Stop asking when ALL the architectural fields are answered without
guessing:
- Audience, length, language locked.
- Topic scope unambiguous (you could write the title page without
  inventing).
- 3–5 takeaways stated or extractable from given material with user
  confirmation.
- Source / grounding plan clear (what to cite, what to research, what to
  leave out).
- Technical depth chosen.
- Section outline approved.

Defaultable fields (style polish, speaker name, etc.) do NOT block stopping
— defer to Step 6a. The user will react better to seeing them in the PDF
than to abstract questions about them up front.

If any architectural item still feels hand-wavy, ask one more focused
round. Better to ask one extra question than to build the wrong deck —
revising architectural choices means regenerating the whole deck, which is
much more expensive than one extra question.

## Step 2 — Research, only if needed

If the user delegated content research to you, do it now, **before** writing
.tex. Use `WebSearch` and `WebFetch`. Take notes in scratch (not in the .tex
file) so you can cite sources when writing slides. For library / framework /
API questions, prefer the `context7` MCP if available — it returns current
docs.

Rules:
- Every non-trivial claim on a slide must be traceable to a source you read.
- Numbers, dates, author names, paper titles: verify before writing.
- If after searching you still cannot confirm something the user wants on the
  slide, tell them and ask whether to drop it or change it — do not paper
  over uncertainty.

## Step 3 — Build the deck from the template

### Source / build separation

The skill keeps source files clean and isolates compile artifacts in a
`build/` subdirectory of the deck. After Step 4 the deck directory looks
like:

```
<deck-name>/
├── .gitignore        ← auto-written by build.sh, ignores build/
├── main.tex          ← edit this
├── references.bib    ← edit this
├── figures/          ← drop new figures here
├── tables/           ← drop new tables here
└── build/            ← created by build.sh, do NOT edit
    ├── main.pdf      ← the deliverable
    ├── main.aux/.log/.toc/.nav/...   (intermediates)
    └── _preview/
        └── slide-NN.png  ← from preview.sh, for self-review in Step 5
```

Why: keeps the deck dir scannable, plays nicely with `git init`, and lets
`scripts/clean.sh` blow away `build/` without ever touching source.

### Building it

1. Copy the template into the working directory:
   ```bash
   cp -r ~/.claude/skills/minimal-beamer/assets/template/ ./<deck-name>/
   ```
   Use a sensible directory name based on the talk title.
2. Edit `main.tex` in place. Update `\title`, `\author`, `\institute`,
   `\date`. Replace the example sections with the user-approved outline.
3. Use the existing frame patterns (see `references/beamer-patterns.md` for
   the catalog: bullet list, two-column, table, figure, citation,
   `[allowframebreaks]`, blocks, `\pause` for incremental reveal).
4. Put figures in `figures/`, tables in `tables/` (one per `.tex` file,
   matching the existing `tables/table1.tex` style), citations in
   `references.bib`. Keep this layout — it is what the template assumes.
5. If the user picked a non-default theme, change exactly the lines required
   (`\usetheme{...}`, `\usecolortheme{...}`, `\usefonttheme{...}`, optional
   `\usepackage{...}` for the theme). Do not silently rewrite the preamble.
6. If the language is non-English: adjust `babel` accordingly and, for CJK,
   switch the build engine to `xelatex` and add `\usepackage{xeCJK}` to the
   preamble. **Do not add `\setCJKmainfont{...}` by default** — let `xeCJK`
   pick the system default, which mirrors how the English template uses
   Beamer's default Computer Modern. Only set a CJK font if the user
   explicitly chose one in Round 5. The build script auto-detects `xeCJK` /
   `fontspec` and switches to `xelatex` for you.

Keep slides genuinely minimal: short bullets, one idea per frame, ample
whitespace. If a frame is overflowing, split it or add `[allowframebreaks]`.

## Step 4 — Compile

Run the build script and fix anything it reports:

```bash
bash ~/.claude/skills/minimal-beamer/scripts/build.sh ./<deck-name>/main.tex
```

The PDF lands at `./<deck-name>/build/main.pdf`. All intermediate files
(`.aux`, `.log`, `.toc`, `.nav`, `.snm`, `.out`, `.bbl`, etc.) also live
under `build/`, keeping the source dir clean. The script also drops a
`.gitignore` into the deck dir on first run if one doesn't already exist.

If `latexmk` is not installed, fall back to `pdflatex` runs (the script
handles this). If a CJK or `fontspec` deck is needed, the script auto-
detects and uses `xelatex`. Read the log on failure, fix the actual error
(don't just add `\usepackage` until something compiles), and re-run.

To wipe build artifacts (e.g. before sharing the source):
```bash
bash ~/.claude/skills/minimal-beamer/scripts/clean.sh ./<deck-name>/
# or  ... clean.sh ./<deck-name>/ --all   # also removes stray intermediates next to .tex
```

## Step 5 — Visually self-review the PDF

A clean compile is necessary but not sufficient — slides can compile fine and
still look broken (overflowing text, wrong language rendering as boxes,
figures off-page, footer crashing into content, tiny text on a 16:9 frame).
You MUST visually check the output before declaring done. You are multimodal
and can read PNGs directly with the `Read` tool.

Use the bundled rasterizer to convert the PDF to per-slide PNGs. Point it
at the built PDF (which lives under `build/`):

```bash
bash ~/.claude/skills/minimal-beamer/scripts/preview.sh ./<deck-name>/build/main.pdf
```

This drops PNGs into `./<deck-name>/build/_preview/slide-NN.png` (one per
slide, ~150 DPI). Then `Read` each PNG and check for:

- **Overflow**: text running off the slide edges, frames that should have used
  `[allowframebreaks]` or been split.
- **Tofu / boxes (□□□)**: CJK characters rendering as rectangles → wrong
  font / wrong engine. Fix `xeCJK` font choice and recompile.
- **Layout collisions**: title overlapping content, footer/page-number eating
  into the bottom line, two-column content overlapping at the seam.
- **Image issues**: figures missing, wildly mis-sized, low-res, or with
  caption truncated.
- **Empty or near-empty frames**: a frame title with one bullet — usually a
  sign you split content too aggressively.
- **Math**: equations cut off, oversized, or rendered as raw `$...$`.
- **Citation / reference glitches**: `[?]` in place of a citation (bib didn't
  resolve), broken `\ref{}` showing `??`.

For long decks (>20 slides) it is fine to scan a representative subset
(title + each section's first frame + the last frame + any frame you suspect
is risky), not literally every page. For short decks, look at every slide.

Fix issues and recompile. Iterate until the PDF actually looks right. Only
then report to the user.

## Step 6 — Hand off the FIRST DRAFT, then enter the revision loop

The PDF you just built is a **first draft**, not a deliverable. Treat it
that way. There is no "done" until the user explicitly says they're 100%
satisfied.

Why this matters: even with perfect input, an LLM-generated deck has
randomness — phrasing the user wouldn't use, content they didn't ask for
slipping in, balance/emphasis decisions that only feel wrong once the user
sees them rendered. The user usually does not know what they actually want
until they see the first draft. **Skipping the revision loop is the single
fastest way to ship a deck the user throws away.**

### Step 6a — Present the draft

Send the user:

1. **The PDF path** (and tell them to open it — they MUST look at the actual
   PDF, not just trust your description).
2. **A "what I decided for you" list** — every implicit choice you made:
   tone, depth, what you cut from their input, what you added, theme/font
   choices you defaulted, figures you generated vs. left as placeholders,
   citations you picked. Keep it bulleted and scannable. The user should
   be able to skim this and instantly spot decisions they want to push back
   on.
3. **An honest flag list** — anything you suspect is off but couldn't fix
   alone. Placeholder figures, numbers you weren't able to verify, sections
   you padded because the input didn't cover them, etc.

### Step 6b — Enter the revision loop (mandatory)

Use `AskUserQuestion` to ask the user how the draft looks. Phrase it so
"no changes" is a real, easy option — but if they pick anything else, you
are committed to drilling in. Example shape:

```
Q: First-draft PDF is ready (path above). Please open it and look through
   it — anything you want changed?
  - Looks good, let's wrap up (no changes needed)
  - A few small tweaks (specify below)
  - Major direction needs adjusting
  - Specific slide(s) have issues (say which)
```

Add 1–3 more `AskUserQuestion` items in the SAME call targeting the most
likely failure points for this specific deck — e.g. "Is the technical depth
right?", "Are there enough figures/diagrams?", "Is the section order OK?",
"Too much text per slide?". Pre-empt the review instead of waiting for the
user to find issues themselves.

Phrase the questions in whatever language matches the conversation (the
examples above are English; if the user has been speaking 繁體中文 / 简体
中文, mirror that). The structure is what matters — easy "no changes" path,
but specific follow-ups when the user does want changes.

### Step 6c — The drill-in sub-loop (non-negotiable)

**If the user picks anything other than "no changes" → you are now in a
drill-in sub-loop. You do NOT get to fix-and-reroll immediately. You
must first understand every change request concretely before touching
the .tex.**

1. **Parse the feedback into distinct items.** Read the user's response
   carefully. If they listed multiple things ("slide 3 is too dense, also
   the color scheme feels wrong, and I want to add a limitations section
   after the results"), these are separate items that may each need their
   own follow-up.

2. **Drill into each item until it's actionable.** Use `AskUserQuestion` —
   as many calls as it takes, no artificial limit — to pin down:
   - **Which slide(s) exactly?** (slide number, section name, or "all of
     them")
   - **What's wrong with it?** (too much text / wrong tone / missing X /
     too technical / factually wrong / ugly layout / ...)
   - **What does "right" look like?** (concrete: "shorter, max 4 bullets",
     "drop the math, keep the intuition", "swap the figure for one I'll
     upload", etc.)

   One `AskUserQuestion` call can cover multiple related items (max 4
   questions per call). But if the user has 5+ distinct change requests,
   or if any single request needs deeper disambiguation, use multiple
   calls. **The number of calls is driven by the user's feedback, not by
   a fixed budget.** Group related follow-ups, but don't squash unrelated
   ones into the same call just to save rounds.

3. **Vague feedback MUST be decomposed.**
   If the user is vague ("this slide feels off", "something's not right",
   "講不太上來,就是怪怪的"), do NOT silently re-roll. Keep asking until
   you have something actionable. Vague feedback + blind rewrite = the
   deck gets worse and the user gets frustrated. Try asking the user to
   point at specific things they see — "is it the amount of text? the
   pacing? the phrasing? the order?" — giving concrete options often
   helps a user who can't articulate from scratch.

4. **Only after ALL items are actionable → make the changes.** Fix
   everything at once, recompile, re-run preview, visually self-review
   (Step 5), and **return to Step 6a with the new draft**. The outer
   revision loop continues.

### Step 6d — Exit condition

The ONLY way to leave this loop is the user explicitly saying some version
of "done" / "OK" / "looks good" / "ship it" / "可以了" / "好了" / "完美" /
"就这样" — or an `AskUserQuestion` answer of "no changes needed" with no
other change requests.

Until then, every cycle ends with another `AskUserQuestion` asking if it's
done. **Do not assume finality.** Do not say "I think we're done" and stop
asking. The user signals exit, not you.

If the user goes silent or sends an unrelated message, you can pause the
loop and confirm before exiting:
> You haven't responded on the latest draft — want to keep iterating, or
> is this version good as-is?

### When the user wants to edit an existing deck

This is just the revision loop without Steps 1–5 in front. Read the
existing `.tex`, make the edit, recompile, preview, self-review, and enter
the revision loop at Step 6a. Same exit condition.

For small mechanical edits ("change slide 4 title", "add a frame about X
after section 2") you can do the edit first then ask if anything else
needs adjusting in one round — but you still ask. For non-trivial edits
(re-target audience, change length) run an abbreviated Round 1
clarification (audience + new length + what to cut/keep), then build, then
revision loop.

## When you are tempted to skip the workflow

Don't. The reason this skill exists is that without the clarification AND
revision loop, the resulting deck is generic, factually shaky, and the
user discards it. Clarification gets you a draft that's in the right
neighborhood; the revision loop is what gets it across the line. Both are
the work. The .tex is just the artifact.

## Reference files

- `references/beamer-patterns.md` — frame patterns and Beamer syntax
  cheatsheet (themes, columns, blocks, overlays, figures, tables, citations,
  CJK setup)
- `references/clarification-playbook.md` — example question sets for
  different starting inputs (vague topic, paper, markdown notes, edit-existing)
- `references/compile-troubleshooting.md` — common LaTeX/Beamer error
  patterns and fixes
- `assets/template/` — the canonical template; copy this, do not rewrite it
- `scripts/check_env.sh` — Step 0: detects OS + which TeX engines and
  helpers are on PATH; exit 0 = ready, 1 = partial, 2 = missing
- `scripts/build.sh` — compile entry point; picks `pdflatex` vs `xelatex`
  based on detected `xeCJK`/`fontspec` in the source, prefers `latexmk`
  when present, falls back to a manual multi-pass; writes all outputs
  (PDF + intermediates) to `<deck>/build/`, auto-creates `.gitignore`,
  parses log on failure
- `scripts/preview.sh` — rasterize the built PDF (`<deck>/build/main.pdf`)
  into per-slide PNGs at `<deck>/build/_preview/slide-NN.png`, so you can
  `Read` them and visually QA the deck (uses `pdftoppm` from Poppler)
- `scripts/clean.sh` — wipe `<deck>/build/`. Pass `--all` to also remove
  any stray `.aux`/`.log`/etc. siblings of `main.tex`. Source files are
  never touched.
