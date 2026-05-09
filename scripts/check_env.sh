#!/usr/bin/env bash
# check_env.sh — detect LaTeX environment for the minimal-beamer skill.
#
# Exit codes:
#   0 — fully ready (pdflatex + xelatex + latexmk all present)
#   1 — partial (pdflatex present, but missing xelatex or latexmk)
#   2 — no LaTeX at all (no pdflatex)
#
# Output: a key=value summary on stdout (one entry per line), suitable for
# eyeballing or piping into grep. Errors and hints go to stderr.

set -u

# ---------- OS detection ----------
case "$(uname -s)" in
    Darwin)  os="macos" ;;
    Linux)
        os="linux"
        if grep -qi microsoft /proc/version 2>/dev/null; then
            os="wsl"
        fi
        # try to capture distro family
        if [ -r /etc/os-release ]; then
            # shellcheck disable=SC1091
            . /etc/os-release
            distro="${ID:-unknown}"
        else
            distro="unknown"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*) os="windows" ;;
    *) os="unknown" ;;
esac

echo "os=$os"
[ "${distro:-}" ] && echo "distro=$distro"

# ---------- find binaries ----------
have() { command -v "$1" >/dev/null 2>&1; }
path_of() { command -v "$1" 2>/dev/null || echo ""; }

for bin in pdflatex xelatex lualatex latexmk tlmgr mpm bibtex biber pdftoppm; do
    p="$(path_of "$bin")"
    if [ -n "$p" ]; then
        echo "${bin}=present:${p}"
    else
        echo "${bin}=missing"
    fi
done

# ---------- versions (cheap, only if present) ----------
if have pdflatex; then
    v=$(pdflatex --version 2>/dev/null | head -1)
    echo "pdflatex_version=${v}"
fi
if have xelatex; then
    v=$(xelatex --version 2>/dev/null | head -1)
    echo "xelatex_version=${v}"
fi
if have latexmk; then
    v=$(latexmk --version 2>/dev/null | head -1)
    echo "latexmk_version=${v}"
fi

# ---------- summarize and pick exit code ----------
status=0
notes=""

if ! have pdflatex; then
    status=2
    notes+="no pdflatex on PATH; install LaTeX first. "
fi

if [ "$status" -ne 2 ]; then
    if ! have xelatex; then
        status=1
        notes+="xelatex missing — required for CJK (xeCJK) and fontspec decks. "
    fi
    if ! have latexmk; then
        status=1
        notes+="latexmk missing — build.sh will fall back to manual multi-pass; install for cleaner builds. "
    fi
    if ! have pdftoppm; then
        # not strictly fatal but preview.sh needs it
        status=1
        notes+="pdftoppm missing — preview.sh (per-slide PNG self-review) won't work. Install Poppler. "
    fi
fi

echo "status=$status"
echo "notes=${notes:-ready}"

# ---------- install hints to stderr (only if missing) ----------
if [ "$status" -eq 2 ]; then
    {
        echo
        echo "==> No LaTeX detected. Recommended install:"
        case "$os" in
            macos)
                echo "  brew install --cask mactex            # full, ~5GB, recommended"
                echo "  # or minimal:"
                echo "  brew install --cask basictex"
                echo "  sudo tlmgr update --self"
                echo "  sudo tlmgr install latexmk collection-fontsrecommended xetex xecjk collection-langcjk"
                ;;
            linux|wsl)
                case "${distro:-}" in
                    ubuntu|debian)
                        echo "  sudo apt update && sudo apt install -y texlive-full latexmk poppler-utils"
                        ;;
                    fedora|rhel|centos)
                        echo "  sudo dnf install -y texlive-scheme-full latexmk poppler-utils"
                        ;;
                    arch|manjaro)
                        echo "  sudo pacman -S --needed texlive-meta poppler"
                        ;;
                    *)
                        echo "  Install your distro's full TeX Live package + latexmk + poppler-utils."
                        echo "  Or use upstream: https://tug.org/texlive/quickinstall.html"
                        ;;
                esac
                ;;
            windows)
                echo "  Install MiKTeX:   https://miktex.org/download"
                echo "  or TeX Live:      https://tug.org/texlive/windows.html"
                echo "  Poppler for Windows (for preview): https://github.com/oschwartz10612/poppler-windows/releases"
                ;;
            *)
                echo "  Unknown OS. See https://www.latex-project.org/get/"
                ;;
        esac
    } >&2
elif [ "$status" -eq 1 ]; then
    {
        echo
        echo "==> Partial LaTeX install. Missing pieces:"
        echo "    $notes"
        case "$os" in
            macos)
                echo "  Add what's missing with:  sudo tlmgr install <package>"
                echo "  CJK support:              sudo tlmgr install xetex xecjk collection-langcjk"
                echo "  Poppler (preview):        brew install poppler"
                ;;
            linux|wsl)
                case "${distro:-}" in
                    ubuntu|debian)
                        echo "  sudo apt install -y texlive-xetex texlive-lang-chinese latexmk poppler-utils"
                        ;;
                    fedora|rhel|centos)
                        echo "  sudo dnf install -y texlive-xetex texlive-collection-langchinese latexmk poppler-utils"
                        ;;
                    arch|manjaro)
                        echo "  sudo pacman -S --needed texlive-xetex texlive-langchinese poppler"
                        ;;
                esac
                ;;
            windows)
                echo "  In MiKTeX Console: install xecjk, latexmk, etc.; or use TeX Live's tlmgr."
                ;;
        esac
    } >&2
fi

exit "$status"
