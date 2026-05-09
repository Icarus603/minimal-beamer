# Compile troubleshooting

When `build.sh` exits non-zero, read the diagnosis it printed first, then
this file. Don't blindly add packages — diagnose the actual cause.

## Engine selection

| Symptom | Cause | Fix |
|---|---|---|
| `! Package inputenc Error: Unicode character ...` | Used `pdflatex` on a CJK source | Add `\usepackage{xeCJK}` (forces `build.sh` to switch to xelatex) and remove `\usepackage[utf8x]{inputenc}` |
| `! LaTeX Error: File 'fontspec.sty' not found` on pdflatex | `fontspec` only works with xelatex/lualatex | Make sure source has `\usepackage{xeCJK}` or `\usepackage{fontspec}` so `build.sh` picks `xelatex` |
| Tofu (□□□) instead of CJK characters in PDF | xelatex compiled but no CJK font available | On macOS this is rare; on Linux install `fonts-noto-cjk` (`apt`) or equivalent. Or set `\setCJKmainfont{Noto Sans CJK SC}` etc. |

## Missing packages

| Error | Fix |
|---|---|
| `LaTeX Error: File 'metropolis.sty' not found` | macOS: `sudo tlmgr install beamertheme-metropolis`; apt: `apt install texlive-latex-extra`; MiKTeX: auto-prompt or `mpm --install=metropolis` |
| `File 'xeCJK.sty' not found` | macOS: `sudo tlmgr install xecjk`; apt: `apt install texlive-lang-chinese` |
| `File 'ctex.sty' not found` | macOS: `sudo tlmgr install ctex`; apt: `apt install texlive-lang-chinese` |
| Generic `File 'XYZ.sty' not found` | Most likely the package containing it: macOS: `tlmgr search --global --file XYZ.sty` then `tlmgr install <pkg>`; apt: `apt-file search XYZ.sty` |

## Frame overflow

| Symptom | Fix |
|---|---|
| Content overflows the frame, log shows `Overfull \vbox` | Add `[allowframebreaks]` to the frame, or split into two frames, or shrink content (smaller `\textwidth` figure, fewer bullets) |
| Footer crashes into content (especially 4:3) | Reduce content; switch to 16:9; or `\setbeamertemplate{footline}{}` to hide footer |

## Citations

| Symptom | Fix |
|---|---|
| `Citation 'Foo2024' on page X undefined` | Verify the key exists in `references.bib`. Run `latexmk` again (it auto-handles bibtex), or manually `bibtex main && pdflatex main && pdflatex main` |
| `[?]` in the PDF | Same as above — bib hasn't been processed. If using `biblatex` instead of `bibtex`, the build needs `biber` not `bibtex` |
| `\bibliographystyle` undefined | Forgot to `\usepackage{natbib}` if using `plainnat`/`apalike` styles in older configurations. The default `apalike` works without natbib though |

## Figures

| Symptom | Fix |
|---|---|
| `Cannot determine size of graphic` | The image format isn't supported by the engine. `pdflatex` accepts pdf/png/jpg, NOT eps. Convert eps→pdf with `epstopdf foo.eps`. `xelatex` accepts the same set |
| `! LaTeX Error: File 'figures/foo.png' not found` | Check the path. `\includegraphics` paths are relative to the source `.tex`. Linux is case-sensitive — `Figures/Foo.PNG` ≠ `figures/foo.png` |
| Figure too big / off-page | Use `width=.5\textwidth` instead of original size. Never use both `width=` and `height=` unless `keepaspectratio` is set |

## Math

| Symptom | Fix |
|---|---|
| `! Missing $ inserted` | An underscore `_` or caret `^` outside math mode. Wrap in `$...$` or escape `\_`/`\^{}` |
| `! Undefined control sequence \align` | `align` requires `\usepackage{amsmath}` |

## Beamer-specific

| Symptom | Fix |
|---|---|
| `! Argument of \beamer@doifinframe has an extra }.` | Unmatched braces inside a frame, often a `\textbf{...}` missing its `}`. Read the line number in the error — it's usually accurate |
| Overlay specifier `<2->` doing nothing | Some commands (e.g. `\section`) don't honor overlays. Use `\onslide<2->{...}` or `\pause` |
| `\pause` mid-itemize doesn't reveal one item at a time | Use `\begin{itemize}[<+->]` instead — it's the canonical Beamer way |

## When nothing else works

1. Run with verbose mode: `pdflatex -interaction=errorstopmode main.tex` and
   step through the prompts to find which line is offending.
2. Comment out half the document, see if it compiles. Bisect.
3. Check the `.log` file — it has more detail than what `build.sh` prints.
   Look for the *first* `! ` error; subsequent ones are usually cascade
   damage.
4. If the compile succeeded but the PDF looks wrong, that's a Step 5 issue
   (visual review), not a compile issue. Read the per-slide PNGs.
