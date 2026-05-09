# build.ps1 — compile a Beamer .tex file produced from the minimal template.
#
# Usage:  build.ps1 path/to/main.tex
#
# Picks the engine based on what the source uses:
#   - if the file contains \usepackage{xeCJK} or \usepackage{fontspec} → xelatex
#   - otherwise → pdflatex
#
# Prefers `latexmk` when available. Falls back to manual multi-pass.
# On failure, prints the last ~40 lines of the .log file plus diagnosis.
# Also writes a .gitignore into the deck directory if missing.

param(
    [Parameter(Mandatory=$true)]
    [string]$TexPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $TexPath)) {
    Write-Error "error: $TexPath not found"
    exit 66
}

$texDir = (Resolve-Path (Split-Path $TexPath -Parent)).Path
$texFile = Split-Path $TexPath -Leaf
$job = [System.IO.Path]::GetFileNameWithoutExtension($texFile)

$buildDir = Join-Path $texDir "build"
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

Push-Location $texDir
try {
    # ---------- ensure .gitignore ----------
    $gitignore = Join-Path $texDir ".gitignore"
    if (-not (Test-Path $gitignore)) {
        @"
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
"@ | Out-File -Encoding utf8 -FilePath $gitignore
        Write-Output "[build] wrote $gitignore"
    }

    # ---------- pick engine ----------
    $engine = "pdflatex"
    $content = Get-Content $texFile -Raw
    if ($content -match '\\usepackage(\[[^]]*\])?\{(xeCJK|fontspec|ctex)\}') {
        $engine = "xelatex"
    }
    Write-Output "[build] engine=$engine"
    Write-Output "[build] source=$texDir\$texFile"
    Write-Output "[build] output=$buildDir"

    function Have($n) { return $null -ne (Get-Command $n -ErrorAction SilentlyContinue) }

    if (-not (Have $engine)) {
        Write-Error "[build] ERROR: $engine not found on PATH."
        Write-Error "[build] Run scripts/check_env.ps1 for install instructions."
        exit 127
    }

    # ---------- compile ----------
    $commonArgs = @("-interaction=nonstopmode", "-halt-on-error", "-file-line-error",
                     "-output-directory=$buildDir")
    $status = 0

    if (Have latexmk) {
        if ($engine -eq "xelatex") {
            & latexmk -xelatex @commonArgs $texFile
        } else {
            & latexmk -pdf @commonArgs $texFile
        }
        $status = $LASTEXITCODE
    } else {
        Write-Output "[build] latexmk not found, falling back to manual multi-pass"
        & $engine @commonArgs $texFile
        $status = $LASTEXITCODE
        if ($status -eq 0 -and $content -match '\\bibliography\b') {
            if (Have bibtex) {
                Push-Location $buildDir
                try { & bibtex $job 2>$null } finally { Pop-Location }
            } else {
                Write-Warning "[build] bibtex not found; bibliography skipped"
            }
            & $engine @commonArgs $texFile
            & $engine @commonArgs $texFile
            $status = $LASTEXITCODE
        }
    }

    $log = Join-Path $buildDir "$job.log"

    if ($status -ne 0) {
        Write-Output ""
        Write-Output "[build] FAILED (exit $status). Diagnosis:"
        if (Test-Path $log) {
            $logContent = Get-Content $log
            $firstErr = $logContent | Select-String -Pattern '^! |^.*:[0-9]+: ' | Select-Object -First 1
            if ($firstErr) { Write-Output "  -> $($firstErr.Line)" }
            $missingPkg = $logContent | Select-String -Pattern "! LaTeX Error: File \`.*\.sty' not found" | Select-Object -First 1
            if ($missingPkg) { Write-Output "  -> Missing package — install via tlmgr/MiKTeX Console" }
            $missingFile = $logContent | Select-String -Pattern "LaTeX Error: File \`.*' not found" | Select-Object -First 1
            if ($missingFile -and -not $missingPkg) { Write-Output "  -> $($missingFile.Line)" }
            $undefinedRef = $logContent | Select-String -Pattern "Reference \`.*' on page .* undefined|Citation \`.*' on page .* undefined" | Select-Object -First 1
            if ($undefinedRef) { Write-Output "  -> $($undefinedRef.Line) (run again or check .bib)" }
            $fontErr = $logContent | Select-String -Pattern "fontspec.*could not|Cannot find font|kpathsea.*fontmap" | Select-Object -First 1
            if ($fontErr) { Write-Output "  -> Font issue: $($fontErr.Line)" }
            Write-Output ""
            Write-Output "[build] last 40 lines of $log :"
            $logContent | Select-Object -Last 40 | ForEach-Object { Write-Output $_ }
        } else {
            Write-Output "  -> no log file produced; engine may have crashed before writing"
        }
        exit $status
    }

    # ---------- success ----------
    $pdf = Join-Path $buildDir "$job.pdf"
    if (Test-Path $pdf) {
        Write-Output "[build] OK  -> $pdf"
    } else {
        Write-Warning "[build] build reported success but $pdf not found"
        exit 1
    }
}
finally {
    Pop-Location
}
