# clean.ps1 — wipe build artifacts for a deck.
#
# Usage:
#   clean.ps1 path/to/deck-dir
#   clean.ps1 path/to/deck-dir -All   # also remove stray .aux/.log/etc next to .tex

param(
    [Parameter(Mandatory=$true)]
    [string]$DeckDir,
    [switch]$All
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $DeckDir -PathType Container)) {
    Write-Error "error: $DeckDir is not a directory"
    exit 66
}

$deckDir = (Resolve-Path $DeckDir).Path

# always blow away build/
$buildDir = Join-Path $deckDir "build"
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
    Write-Output "[clean] removed $buildDir"
} else {
    Write-Output "[clean] no build/ to remove in $deckDir"
}

# -All: also clear stray intermediates that may have leaked next to .tex
if ($All) {
    $exts = @("aux", "log", "toc", "nav", "snm", "out", "bbl", "blg",
              "fls", "fdb_latexmk", "synctex.gz", "vrb", "run.xml", "bcf")
    $removed = 0
    foreach ($ext in $exts) {
        Get-ChildItem $deckDir -Filter "*.$ext" | ForEach-Object {
            Remove-Item $_.FullName -Force
            $removed++
        }
    }
    Write-Output "[clean] --all: removed $removed stray intermediate file(s) next to .tex"
}

Write-Output "[clean] done. main.tex and source files untouched."
