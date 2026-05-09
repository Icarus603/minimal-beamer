# Clarification playbook

Concrete `AskUserQuestion` examples for the four common starting situations.
Adapt — don't copy verbatim. The point is to model the *shape* of good
clarification: specific options, sensible defaults marked "(Recommended)",
no-judgement framing.

Group up to 4 related questions per `AskUserQuestion` call so the user
batches answers.

Phrase the questions in whatever language the user has been writing in. The
examples below are in English; substitute 繁體中文 / 简体中文 / etc. as
appropriate. The *structure* of the rounds is what matters, not the
language.

---

## Situation A — Vague topic ("Make me a deck about diffusion models")

This is the highest-risk input. The user has not told you anything beyond a
topic word. Without clarification you will produce a generic deck and they
will throw it away. The example below uses diffusion models for
concreteness; the same shape applies to any vague-topic prompt — replace
the topic-specific options with whatever your topic is (e.g. for a
Transformer talk, swap to attention/Q-K-V/encoder-decoder; for a protein
folding talk, swap to sequence-to-structure/AlphaFold/...; for a thesis
defense, swap to your contributions / methods / results).

### Round 1 — audience, occasion, length, language

```
Q1: Who is this presentation for?
  - Lab / research group meeting
  - Undergraduate course (one lecture)
  - Conference talk
  - Job talk / interview
  - Internal company tech share

Q2: How long is the talk?
  - 5–10 min lightning
  - 20–30 min conference / lecture slot
  - 45–60 min lecture / job talk
  - You set it, I'll detail the constraint

Q3: Roughly how many slides?
  - You decide (Recommended) — I'll use ~1 slide/min as a baseline
  - Under 10
  - 10–20
  - 20+

Q4: Slide language?
  - English (Recommended)
  - 繁體中文
  - 简体中文
  - Bilingual side-by-side
```

### Round 2 — content scope (the anti-hallucination round)

```
Q1: What are the 3–5 takeaways the audience MUST leave with?
    (This is the most important question — without a clear answer, the deck
    will end up vague. Options below are for a diffusion-models talk;
    replace with topic-specific candidates for any other topic.)
  - The forward (noising) and reverse (denoising) processes intuitively
  - The training objective (denoising score matching / ε-prediction)
  - Sampling: DDPM vs. DDIM vs. flow-matching, and why the trade-offs
  - Conditioning: classifier-free guidance, ControlNet, etc.
  - From pixel diffusion to latent diffusion (Stable Diffusion)
  - I'll describe my own takeaways (Other)

Q2: Where should the content come from?
  - You research it and verify with me as you go (Recommended) — name the
    primary source(s) you'll lean on so I can sanity-check
  - I'll hand you a paper / notes / repo
  - Adapt my old slides
  - You write freely; just flag what's verified vs. inferred

Q3: Any specific results / numbers / figures / quotes that MUST appear?
  - No, you decide
  - Yes (please describe)

Q4: Technical depth?
  - Intuition-first, minimal math (general audience)
  - Standard (key formulas, no derivations)
  - Deep (full derivations, complexity, ablations — research-grade)
```

### Round 3 — structure

Propose a draft outline so the user can edit it instead of generating one
from scratch:

```
Q1: Here's my draft outline — what should change?
    (Example outline for a diffusion-models talk; substitute sections that
    fit your topic.)
  1. Motivation (image generation, why generative models matter)
  2. Forward and reverse processes (intuition first, equations second)
  3. Training objective (denoising score matching / ε-prediction)
  4. Sampling (DDPM → DDIM → flow matching), the speed–quality trade-off
  5. Conditioning (classifier-free guidance, text-to-image)
  6. Latent diffusion (Stable Diffusion) and impact
  - Looks good
  - Drop some sections (please specify)
  - Add some sections (please specify)
  - Reorder

Q2: Want a table-of-contents slide?
  - Yes (Recommended)
  - No — go straight into content

Q3: Want section-divider slides between sections?
  - No — keep it minimal (Recommended)
  - Yes

Q4: Want a references slide?
  - Yes, I'll provide the .bib (Recommended for academic talks)
  - Yes, you build the .bib as you go
  - No
```

### Round 4 — visuals

```
Q1: Figures?
  - Draw TikZ diagrams for me (the schematic / architecture / pipeline)
    (Recommended)
  - Leave placeholders, I'll fill in later
  - Skip figures

Q2: Tables?
  - Yes — illustrative results / comparison
  - No

Q3: Math depth?
  - Key formulas with one-line intuition (Recommended)
  - Full derivations
  - No formulas at all (intuition + diagrams only)
```

### Round 5 — style polish

```
Q1: Theme?
  - default (template as-is) (Recommended)
  - metropolis (modern, sans-serif)
  - Madrid (classic blue header)

Q2: Aspect ratio?
  - 4:3 (Recommended) — template default
  - 16:9 — wide screens / projectors

Q3: Fonts?
  - Template default (Computer Modern) (Recommended)
  - Helvetica
  - Custom (please name the font)

Q4: Anything to definitely avoid?
  - All good
  - (e.g. "no emoji", "no animations", "no clip art")
```

---

## Situation B — Markdown / outline / notes input

The user has handed you content. Don't re-ask "what should we cover" — focus
on **scope** (what to keep/drop), **audience**, and **format**.

### Round 1 — fast scope check

```
Q1: Translate this 1:1 to slides, or condense / restructure?
  - 1:1, you decide pagination
  - Condense, pull out the key points
  - Restructure for spoken delivery

Q2: Audience and length? (same options as Situation A)

Q3: Anything in this input that should NOT make it onto a slide?
    (private notes, TODOs, personal reactions)
```

(Then proceed with whichever of Rounds 3/4/5 still has open questions.)

---

## Situation C — Paper / PDF / existing document input

User wants slides built from a paper.

### Round 1

```
Q1: Is this a paper walk-through, or are you using the paper as a source for
    a broader topic?
  - Paper walk-through (motivation / method / experiments / discussion)
  - Broader topic, paper is a key reference

Q2: Audience? (same options)
Q3: Length? (same options)
Q4: Can I add background context beyond the paper?
  - Yes, but cite sources
  - No — only paper content
```

### Round 2

```
Q1: Which figures / tables from the paper should I reproduce?
  - All major ones
  - You pick
  - Only X, Y

Q2: Include limitations / future work / your critique?
```

---

## Situation D — Editing an existing .tex

For small mechanical edits ("change slide 5 title to X", "add a frame about
Y after section 2") just do it. Skip clarification.

For non-trivial edits (re-target audience, change length, full restyle) run
an abbreviated clarification:

```
Q1: What's the main change?
  - Different audience (e.g. expert → general)
  - Shorten / lengthen
  - Theme / style overhaul
  - Add new section

Q2: How much existing content stays?
  - All of it, just reorder / reword
  - Significant cuts
  - Rewrite, but keep the structure

Q3: Target slide count for the new version?
```

---

## When to ask MORE rounds

- Highly technical topic in any specialized domain (ML, cryptography,
  bioinformatics, theoretical physics, formal methods, statistics, …) —
  extra disambiguation round on the sub-topic and the audience's prior
  knowledge
- User talks vaguely ("just give an intro to what we work on", "做我们组
  最近的一些工作") — force a takeaway round; do not let "you decide"
  substitute for it
- Cross-language case (e.g. English paper → Chinese slides) — extra round
  on terminology and citation conventions

## When to ask FEWER rounds

- User volunteered audience + length + theme up front
- Small edits to an existing deck
- User signals urgency ("I need this fast"). Compress to 2 dense rounds —
  but never skip the takeaway question
