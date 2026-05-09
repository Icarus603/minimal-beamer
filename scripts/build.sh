#!/usr/bin/env bash
# build.sh — compile a Beamer .tex file produced from the minimal template.
#
# Usage:  build.sh path/to/main.tex [build_dir]
#
# Default build_dir is `<tex_dir>/build/` — all intermediate files (.aux,
# .log, .toc, .nav, .snm, .out, .bbl, .blg, .fls, .fdb_latexmk, .synctex.gz)
# AND the final main.pdf land there. Source files (.tex, .bib, figures/,
# tables/) stay clean.
#
# Picks the engine based on what the source uses:
#   - if the file contains \usepackage{xeCJK|fontspec|ctex} → xelatex
#   - otherwise → pdflatex
#
# Prefers `latexmk` when available (handles bib + multi-pass automatically).
# Falls back to a manual pdflatex/xelatex + bibtex + pdflatex + pdflatex sweep.
#
# On failure, prints the last ~40 lines of the .log file plus a one-line
# summary of the most likely cause (parsed from common LaTeX error patterns).
#
# Also writes a .gitignore into the deck directory (if missing) so the
# build/ directory and stray intermediate files won't get committed if the
# user runs `git init`.

set -u

if [ $# -lt 1 ]; then
    echo "usage: $0 path/to/main.tex [build_dir]" >&2
    exit 64
fi

tex_path="$1"
if [ ! -f "$tex_path" ]; then
    echo "error: $tex_path not found" >&2
    exit 66
fi

tex_dir="$(cd "$(dirname "$tex_path")" && pwd)"
tex_file="$(basename "$tex_path")"
job="${tex_file%.tex}"

# resolve build directory (default: <tex_dir>/build)
if [ $# -ge 2 ]; then
    build_dir="$2"
    case "$build_dir" in
        /*) ;;                                  # absolute, leave it
        *) build_dir="$tex_dir/$build_dir" ;;   # make relative-to-tex absolute
    esac
else
    build_dir="$tex_dir/build"
fi
mkdir -p "$build_dir"

cd "$tex_dir" || exit 1

# ---------- ensure .gitignore ----------
gitignore="$tex_dir/.gitignore"
if [ ! -f "$gitignore" ]; then
    cat > "$gitignore" <<'EOF'
# minimal-beamer skill: build artifacts live in build/, source stays clean.
build/

# Stray intermediates (in case anything ends up next to .tex)
*.aux
*.log
*.toc
*.nav
*.snm
*.out
*.bbl
*.blg
*.fls
*.fdb_latexmk
*.synctex.gz
*.vrb
*.run.xml
*.bcf
EOF
    echo "[build] wrote $gitignore"
fi

# ---------- pick engine ----------
engine="pdflatex"
if grep -qE '\\usepackage(\[[^]]*\])?\{(xeCJK|fontspec|ctex)\}' "$tex_file"; then
    engine="xelatex"
fi
echo "[build] engine=$engine"
echo "[build] source=$tex_dir/$tex_file"
echo "[build] output=$build_dir"

have() { command -v "$1" >/dev/null 2>&1; }

if ! have "$engine"; then
    echo "[build] ERROR: $engine not found on PATH." >&2
    echo "[build] Run scripts/check_env.sh for install instructions." >&2
    exit 127
fi

# ---------- compile ----------
status=0
common_args=(-interaction=nonstopmode -halt-on-error -file-line-error \
             -output-directory="$build_dir")

if have latexmk; then
    case "$engine" in
        pdflatex) latexmk -pdf "${common_args[@]}" "$tex_file" ;;
        xelatex)  latexmk -xelatex "${common_args[@]}" "$tex_file" ;;
    esac
    status=$?
else
    echo "[build] latexmk not found, falling back to manual multi-pass"
    "$engine" "${common_args[@]}" "$tex_file"
    status=$?
    if [ "$status" -eq 0 ] && grep -q '\\bibliography\b' "$tex_file"; then
        if have bibtex; then
            # bibtex needs to run in the output dir to find the .aux file
            (cd "$build_dir" && bibtex "$job") || true
        else
            echo "[build] WARN: bibtex not found; bibliography skipped" >&2
        fi
        "$engine" "${common_args[@]}" "$tex_file"
        "$engine" "${common_args[@]}" "$tex_file"
        status=$?
    fi
fi

log="$build_dir/$job.log"

if [ "$status" -ne 0 ]; then
    echo
    echo "[build] FAILED (exit $status). Diagnosis:"
    if [ -f "$log" ]; then
        first_err=$(grep -m1 -E '^! |^.*:[0-9]+: ' "$log" || true)
        if [ -n "$first_err" ]; then
            echo "  -> $first_err"
        fi
        missing_pkg=$(grep -m1 -E "! LaTeX Error: File \`.*\.sty' not found" "$log" || true)
        [ -n "$missing_pkg" ] && echo "  -> Missing package — install via tlmgr/apt/MiKTeX"
        missing_file=$(grep -m1 -E "LaTeX Error: File \`.*' not found" "$log" || true)
        [ -n "$missing_file" ] && [ -z "$missing_pkg" ] && echo "  -> $missing_file"
        undefined_ref=$(grep -m1 -E "Reference \`.*' on page .* undefined|Citation \`.*' on page .* undefined" "$log" || true)
        [ -n "$undefined_ref" ] && echo "  -> $undefined_ref (run again or check .bib)"
        font_err=$(grep -m1 -E "fontspec.*could not|Cannot find font|kpathsea.*fontmap" "$log" || true)
        [ -n "$font_err" ] && echo "  -> Font issue: $font_err"
        echo
        echo "[build] last 40 lines of $log:"
        tail -40 "$log"
    else
        echo "  -> no log file produced; engine may have crashed before writing"
    fi
    exit "$status"
fi

# success
pdf="$build_dir/$job.pdf"
if [ -f "$pdf" ]; then
    echo "[build] OK  -> $pdf"
else
    echo "[build] WARN: build reported success but $pdf not found" >&2
    exit 1
fi
