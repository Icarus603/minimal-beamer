# preview.ps1 — rasterize a built Beamer PDF into per-slide PNGs for visual QA.
#
# Usage:  preview.ps1 path/to/main.pdf [dpi]
#
# Outputs PNGs to <pdf-dir>/_preview/slide-NN.png at the requested DPI
# (default 150).
#
# Requires pdftoppm (Poppler).

param(
    [Parameter(Mandatory=$true)]
    [string]$PdfPath,
    [int]$Dpi = 150
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $PdfPath)) {
    Write-Error "error: $PdfPath not found"
    exit 66
}

if (-not (Get-Command pdftoppm -ErrorAction SilentlyContinue)) {
    $msg = "error: pdftoppm not found. Install Poppler:"
    if ($IsWindows) {
        $msg += "`n  https://github.com/oschwartz10612/poppler-windows/releases"
    } elseif ($IsMacOS) {
        $msg += "`n  brew install poppler"
    } elseif ($IsLinux) {
        $msg += "`n  sudo apt install poppler-utils  (or your distro's equivalent)"
    }
    Write-Error $msg
    exit 127
}

$pdfDir = (Resolve-Path (Split-Path $PdfPath -Parent)).Path
$outDir = Join-Path $pdfDir "_preview"

New-Item -ItemType Directory -Force -Path $outDir | Out-Null
# clean stale PNGs from a prior (possibly longer) deck
Remove-Item (Join-Path $outDir "slide-*.png") -Force -ErrorAction SilentlyContinue

& pdftoppm -png -r $Dpi $PdfPath (Join-Path $outDir "slide")
if ($LASTEXITCODE -ne 0) {
    Write-Error "error: pdftoppm failed"
    exit 1
}

# normalize to zero-padded two-digit numbering
Get-ChildItem $outDir -Filter "slide-?.png" | ForEach-Object {
    $newName = $_.Name -replace '^slide-(\d)\.png$', 'slide-0$1.png'
    Rename-Item $_.FullName -NewName $newName
}

$count = (Get-ChildItem $outDir -Filter "slide-*.png").Count
Write-Output "[preview] wrote $count PNGs to $outDir\ at ${Dpi} DPI"
Write-Output "[preview] read them with the Read tool to visually QA the deck"
