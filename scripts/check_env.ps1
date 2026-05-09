# check_env.ps1 — detect LaTeX environment for the minimal-beamer skill.
#
# Exit codes:
#   0 — fully ready (pdflatex + xelatex + latexmk all present)
#   1 — partial (pdflatex present, but missing xelatex or latexmk)
#   2 — no LaTeX at all (no pdflatex)
#
# Output: key=value summary on stdout. Errors and hints to stderr.

param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ---------- helpers ----------
function Have($name) { return $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }
function PathOf($name) {
    $c = Get-Command $name -ErrorAction SilentlyContinue
    if ($c) { return $c.Source } else { return "" }
}

# ---------- OS detection ----------
$os = if ($IsWindows) { "windows" }
      elseif ($IsMacOS) { "macos" }
      elseif ($IsLinux) { "linux" }
      else { "unknown" }
Write-Output "os=$os"

# ---------- find binaries ----------
$bins = @("pdflatex", "xelatex", "lualatex", "latexmk", "tlmgr", "mpm", "bibtex", "biber", "pdftoppm")
foreach ($b in $bins) {
    $p = PathOf $b
    if ($p) { Write-Output "${b}=present:$p" }
    else     { Write-Output "${b}=missing" }
}

# ---------- versions (only if present) ----------
if (Have pdflatex) {
    $v = & pdflatex --version 2>$null | Select-Object -First 1
    Write-Output "pdflatex_version=$v"
}
if (Have xelatex) {
    $v = & xelatex --version 2>$null | Select-Object -First 1
    Write-Output "xelatex_version=$v"
}
if (Have latexmk) {
    $v = & latexmk --version 2>$null | Select-Object -First 1
    Write-Output "latexmk_version=$v"
}

# ---------- summarize and pick exit code ----------
$status = 0
$notes = ""

if (-not (Have pdflatex)) {
    $status = 2
    $notes += "no pdflatex on PATH; install LaTeX first. "
}

if ($status -ne 2) {
    if (-not (Have xelatex)) {
        $status = 1
        $notes += "xelatex missing — required for CJK (xeCJK) and fontspec decks. "
    }
    if (-not (Have latexmk)) {
        $status = 1
        $notes += "latexmk missing — build.sh will fall back to manual multi-pass; install for cleaner builds. "
    }
    if (-not (Have pdftoppm)) {
        $status = 1
        $notes += "pdftoppm missing — preview.ps1 (per-slide PNG self-review) won't work. Install Poppler. "
    }
}

Write-Output "status=$status"
Write-Output "notes=$($notes -replace '^\s+', '')"
if (-not $notes) { Write-Output "notes=ready" }

# ---------- install hints to stderr ----------
if ($status -eq 2) {
    $msg = @"

==> No LaTeX detected. Recommended install:

  Windows:
    Install MiKTeX:   https://miktex.org/download
    or TeX Live:      https://tug.org/texlive/windows.html
    Poppler for Windows (for preview):
      https://github.com/oschwartz10612/poppler-windows/releases

  macOS:
    brew install --cask mactex            # full, ~5GB, recommended
    # or minimal:
    brew install --cask basictex
    sudo tlmgr update --self
    sudo tlmgr install latexmk collection-fontsrecommended xetex xecjk collection-langcjk

  Linux:
    sudo apt update && sudo apt install -y texlive-full latexmk poppler-utils   # Debian/Ubuntu
    sudo dnf install -y texlive-scheme-full latexmk poppler-utils               # Fedora
    sudo pacman -S --needed texlive-meta poppler                                 # Arch

"@
    [Console]::Error.WriteLine($msg)
}
elseif ($status -eq 1) {
    $msg = @"

==> Partial LaTeX install. Missing pieces:
    $notes

  Windows (MiKTeX Console): install xecjk, latexmk, etc.; or use TeX Live's tlmgr.
  macOS: sudo tlmgr install <package>
  Linux: sudo apt install <package>  (or your distro's equivalent)

"@
    [Console]::Error.WriteLine($msg)
}

exit $status
