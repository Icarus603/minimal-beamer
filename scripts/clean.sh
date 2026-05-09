#!/usr/bin/env bash
# clean.sh — wipe build artifacts for a deck.
#
# Usage:
#   clean.sh path/to/deck-dir          # remove deck-dir/build/
#   clean.sh path/to/deck-dir --all    # also remove stray .aux/.log/etc next to .tex

set -u

if [ $# -lt 1 ]; then
    echo "usage: $0 path/to/deck-dir [--all]" >&2
    exit 64
fi

deck_dir="$1"
mode="${2:-default}"

if [ ! -d "$deck_dir" ]; then
    echo "error: $deck_dir is not a directory" >&2
    exit 66
fi

deck_dir="$(cd "$deck_dir" && pwd)"

# always blow away build/
if [ -d "$deck_dir/build" ]; then
    rm -rf "$deck_dir/build"
    echo "[clean] removed $deck_dir/build/"
else
    echo "[clean] no build/ to remove in $deck_dir"
fi

# --all also clears stray intermediates that may have leaked next to .tex
# (e.g. from someone running pdflatex by hand without -output-directory)
if [ "$mode" = "--all" ]; then
    shopt -s nullglob
    removed=0
    for ext in aux log toc nav snm out bbl blg fls fdb_latexmk synctex.gz vrb run.xml bcf; do
        for f in "$deck_dir"/*."$ext"; do
            rm -f "$f"
            removed=$((removed + 1))
        done
    done
    echo "[clean] --all: removed $removed stray intermediate file(s) next to .tex"
fi

echo "[clean] done. main.tex and source files untouched."
