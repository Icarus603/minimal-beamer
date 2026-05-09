# Beamer patterns cheatsheet

Drawn from the bundled template (`assets/template/main.tex`). Read this when
you need to add a frame type or tweak preamble. Stick to these patterns
unless the user explicitly asks for something else — they keep the deck
visually consistent with the template.

## Preamble (do not casually rewrite)

```latex
\documentclass{beamer}                  % default class — minimal, clean
\usepackage[english]{babel}             % swap "english" if needed
\usepackage[utf8x]{inputenc}            % drop this if switching to xelatex
\mode<presentation>{
  \usetheme{default}
  \usecolortheme{default}
  \usefonttheme{default}
  \setbeamertemplate{caption}[numbered]
}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{hyperref}
```

For 16:9: `\documentclass[aspectratio=169]{beamer}`.

For CJK: switch to `xelatex` and replace inputenc with:
```latex
\usepackage{xeCJK}              % default font; do NOT add \setCJKmainfont
                                % unless user picked one
```
For ctex (alternative, more 简体-friendly defaults):
```latex
\usepackage[UTF8]{ctex}
```

## Title page

```latex
\title{...}
\author{...}
\institute{...}
\date{\today}

\begin{frame}
  \titlepage
\end{frame}
```

## Outline

```latex
\begin{frame}{Outline}
  \tableofcontents
\end{frame}
```

To highlight current section automatically at each section start:
```latex
\AtBeginSection[]{%
  \begin{frame}{Outline}
    \tableofcontents[currentsection]
  \end{frame}
}
```

## Bullets

```latex
\begin{frame}{Title}
  Lead-in sentence.
  \begin{itemize}
    \item Point one
    \item Point two
  \end{itemize}
\end{frame}
```

Numbered: `\begin{enumerate}`. Description: `\begin{description}\item[term] ...`.

Incremental reveal — add `\pause` between items, or `[<+->]`:
```latex
\begin{itemize}[<+->]
  \item Appears on click 1
  \item Appears on click 2
\end{itemize}
```

## Two columns

```latex
\begin{frame}{Title}
  \begin{columns}
    \column{.5\textwidth}
    Left content.

    \column{.5\textwidth}
    Right content.
  \end{columns}
\end{frame}
```

For text + figure side-by-side, use `.45\textwidth` columns to leave a small
gutter and avoid the figure crashing into the text.

## Figure

```latex
\begin{frame}{Title}
  \begin{figure}
    \centering
    \includegraphics[width=.6\textwidth]{figures/foo.png}
    \caption{Caption.}
    \label{fig:foo}
  \end{figure}
\end{frame}
```

Notes:
- Drop the `[H]` placement specifier the template uses in its tables example
  if you didn't load `float` — Beamer's frame is already a fixed canvas.
- Use `width=` not `scale=` so the figure adapts to aspect ratio changes.

## Table

Put the table in `tables/tableN.tex` (one file per table) following the
template style:

```latex
\begin{table}
\centering
\caption{Caption}
\label{tab:foo}
\begin{tabular}{@{}lcc@{}}
\toprule
\textbf{Col1} & \textbf{Col2} & \textbf{Col3} \\ \midrule
Row1 & ... & ... \\
\bottomrule
\end{tabular}
\end{table}
```

Then in the frame:
```latex
\begin{frame}{Title}
  \input{tables/tableN.tex}
\end{frame}
```

For tables that don't fit, scale: `\resizebox{\textwidth}{!}{...}`.

## Citations and bibliography

In `references.bib`:
```bibtex
@article{Key2024a,
  author = {Last, First},
  title = {{Paper Title}},
  journal = {Journal},
  year = {2024},
  ...
}
```

In a frame:
```latex
This was shown by \cite{Key2024a}.
```

Bibliography frame (already in the template):
```latex
\begin{frame}[allowframebreaks]{References}
  \tiny\bibliography{references}
  \bibliographystyle{apalike}
\end{frame}
```

Other common styles: `plain`, `alpha`, `ieeetr`, `acm`. For natbib-style
author-year, use `\usepackage{natbib}` and `\bibliographystyle{plainnat}`.

## Blocks (call-out boxes)

```latex
\begin{block}{Title}
  Regular block.
\end{block}

\begin{alertblock}{Warning}
  Red-tinted block.
\end{alertblock}

\begin{exampleblock}{Example}
  Green-tinted block.
\end{exampleblock}
```

## Math

Inline `$E = mc^2$`. Display:
```latex
\[
  \mathcal{L}(\theta) = -\sum_i \log p_\theta(y_i \mid x_i)
\]
```

For numbered/aligned equations: `\usepackage{amsmath}` and `align`/`equation`.

## allowframebreaks

When a frame's content would overflow, add the option and Beamer auto-splits
across multiple physical slides:

```latex
\begin{frame}[allowframebreaks]{Long content}
  ... lots of bullets / paragraphs ...
\end{frame}
```

The frame title gets `(1/2)`, `(2/2)` suffixes automatically.

## Theme alternatives (only if user asks)

| Theme | Look | Note |
|---|---|---|
| `default` | minimal, no bars | what the template uses |
| `metropolis` | modern, sans-serif, dark accents | needs `\usepackage{metropolis}` (CTAN) and decent fonts; pairs with `xelatex` |
| `Madrid` | classic blue header | sober, popular for academic talks |
| `Boadilla` | sober, no headers | similar to default but with footline |
| `CambridgeUS` | red/grey, footer info | classic |
| `Berlin` | navigation bar at top | for long structured talks |

Color themes: `default`, `crane`, `dolphin`, `seagull`, `wolverine`,
`whale`, `orchid`, `rose`. Apply with `\usecolortheme{...}`.
