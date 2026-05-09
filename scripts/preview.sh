#!/usr/bin/env bash
# preview.sh — rasterize a built Beamer PDF into per-slide PNGs for visual QA.
#
# Usage:  preview.sh path/to/main.pdf [dpi]
#
# Outputs PNGs to <pdf-dir>/_preview/slide-NN.png at the requested DPI
# (default 150 — high enough to read text and catch layout problems, low
# enough to keep file sizes manageable for `Read`).
#
# Requires `pdftoppm` (Poppler). On macOS: brew install poppler. On Linux:
# apt install poppler-utils / dnf install poppler-utils. On Windows: see
# https://github.com/oschwartz10612/poppler-windows/releases.

set -u

if [ $# -lt 1 ]; then
    echo "usage: $0 path/to/main.pdf [dpi]" >&2
    exit 64
fi

pdf="$1"
dpi="${2:-150}"

if [ ! -f "$pdf" ]; then
    echo "error: $pdf not found" >&2
    exit 66
fi

if ! command -v pdftoppm >/dev/null 2>&1; then
    echo "error: pdftoppm not found. Install Poppler:" >&2
    case "$(uname -s)" in
        Darwin) echo "  brew install poppler" >&2 ;;
        Linux)  echo "  sudo apt install poppler-utils  (or your distro's equivalent)" >&2 ;;
        *)      echo "  https://poppler.freedesktop.org/" >&2 ;;
    esac
    exit 127
fi

pdf_dir="$(cd "$(dirname "$pdf")" && pwd)"
pdf_name="$(basename "$pdf" .pdf)"
out_dir="$pdf_dir/_preview"

mkdir -p "$out_dir"
# clean stale output so leftover PNGs from a longer prior deck don't confuse review
rm -f "$out_dir"/slide-*.png

# pdftoppm output prefix: writes <prefix>-<page>.png
pdftoppm -png -r "$dpi" "$pdf" "$out_dir/slide" || {
    echo "error: pdftoppm failed" >&2
    exit 1
}

# normalize page numbering to zero-padded 2-digit (pdftoppm uses minimum width
# already, but pad explicitly so sort order is stable in directory listings)
shopt -s nullglob
for f in "$out_dir"/slide-*.png; do
    base=$(basename "$f" .png)
    num="${base#slide-}"
    if [ "${#num}" -eq 1 ]; then
        mv "$f" "$out_dir/slide-0$num.png"
    fi
done

count=$(ls "$out_dir"/slide-*.png 2>/dev/null | wc -l | tr -d ' ')
echo "[preview] wrote $count PNGs to $out_dir/ at ${dpi} DPI"
echo "[preview] read them with the Read tool to visually QA the deck"
