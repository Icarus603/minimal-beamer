# minimal-beamer

Build a LaTeX Beamer presentation from the bundled minimal template. Use whenever you mention making slides, a presentation, a deck, a talk, or a Beamer/LaTeX presentation — in English ("slides", "deck", "talk"), 繁體中文 (「投影片」「簡報」「做 PPT」), or 简体中文 (「幻灯片」「演示」「做幻灯片」).

**Install in 30 seconds** (Claude Code CLI / VS Code / JetBrains):

```text
/plugin marketplace add Icarus603/minimal-beamer
/plugin install minimal-beamer
```

## Prerequisites

The skill runs an environment check on first use. If LaTeX is missing, it prints OS-specific install instructions. You need a working `pdflatex` (English) or `xelatex` (CJK / fontspec), plus `latexmk` (recommended) and `pdftoppm` from Poppler (for per-slide visual self-review).

- **macOS**: `brew install --cask mactex poppler`
- **Linux**: `sudo apt install texlive-full latexmk poppler-utils`
- **Windows**: [MiKTeX](https://miktex.org/download) or TeX Live, plus [Poppler](https://github.com/oschwartz10612/poppler-windows/releases)

## License

MIT
