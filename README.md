# minimal-beamer

A Claude Code plugin for building LaTeX Beamer presentations from a bundled minimal template.

## Features

- **Multi-round clarification workflow** — asks the right questions before writing a single frame, so the deck gets it right the first time
- **Bundled minimal template** — clean, academic Beamer template, copied per-project, never overwritten
- **Automatic engine selection** — `pdflatex` for English, `xelatex` when CJK/`fontspec` detected
- **Visual self-review** — rasterizes the PDF to per-slide PNGs and visually checks for overflow, tofu, layout bugs, and citation errors BEFORE showing you
- **Mandatory revision loop** — first draft is never the last. An `AskUserQuestion` loop keeps going until you're satisfied
- **Clean build structure** — compile artifacts isolated in `build/`, source files stay clean, `.gitignore` auto-written
- **Cross-platform** — auto-detects macOS/Linux/Windows/WSL and gives install instructions when LaTeX is missing

## Prerequisites

The skill checks your LaTeX environment on every run. If missing, it tells you exactly what to install:

- **macOS**: `brew install --cask mactex` (or `basictex` for minimal)
- **Linux**: `sudo apt install texlive-full latexmk poppler-utils` (Debian/Ubuntu) or equivalent
- **Windows**: [MiKTeX](https://miktex.org/download) or [TeX Live for Windows](https://tug.org/texlive/windows.html)

Poppler (`pdftoppm`) is required for the per-slide visual self-review step. The installer instructions cover this.

## Installation

```bash
claude plugins install minimal-beamer
```

Or manually:

```bash
git clone https://github.com/Icarus603/minimal-beamer.git
claude plugins install ./minimal-beamer
```

## Usage

Just ask Claude to make a presentation:

> 幫我做一份關於 Transformer 的 Beamer 簡報

> Make me slides for my thesis defense

> 幫我把這份筆記做成投影片 [...]

The skill triggers on any mention of slides/deck/talk/presentation in English, 繁體中文, or 简体中文. It then:

1. Checks your LaTeX environment
2. Clarifies audience, length, takeaways, depth, structure, and visuals through `AskUserQuestion`
3. Researches uncertain facts (WebSearch) and builds from the template
4. Compiles the PDF and visually self-reviews every slide
5. Enters a revision loop — you review the draft, give feedback, and iterate until done

## Template

The bundled template is a minimal academic Beamer setup:

- Default theme, clean layout
- Title page, outline, sections, bullet lists, two-column slides
- Figures, tables (booktabs), BibTeX citations
- 4:3 aspect ratio, Computer Modern fonts

Source: `assets/template/`

## Output structure

```
my-talk/
├── .gitignore          auto-written
├── main.tex            your slides
├── references.bib      bibliography
├── figures/            your images
├── tables/             your tables
└── build/              all compile artifacts (safe to delete)
    ├── main.pdf        the deliverable
    └── _preview/       per-slide PNGs (internal QA)
```

## License

MIT
