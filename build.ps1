[CmdletBinding()]
param(
  [switch]$SkipPdf
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$bookDir = Join-Path $root "book"
$outputDir = Join-Path $bookDir "output"
$buildDir = Join-Path $bookDir "_build"
$manifestPath = Join-Path $bookDir "manifest.txt"
$metadataPath = Join-Path $bookDir "metadata.yaml"
$filterPath = Join-Path $bookDir "assets\mermaid-filter.lua"
$bookCss = Join-Path $bookDir "assets\book.css"
$printCss = Join-Path $bookDir "assets\print.css"
$screenRuntime = Join-Path $bookDir "assets\screen-runtime.html"
$printRuntime = Join-Path $bookDir "assets\screen-runtime.html"
$htmlOutput = Join-Path $outputDir "book.html"
$pdfOutput = Join-Path $outputDir "book.pdf"
$printHtml = Join-Path $buildDir "book-print.html"

New-Item -ItemType Directory -Force -Path $outputDir, $buildDir | Out-Null

$pandocCandidates = @(
  (Join-Path $root ".tools\pandoc-3.9.0.2\pandoc.exe"),
  (Get-Command pandoc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue)
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

if (-not $pandocCandidates) {
  throw "Pandoc is missing. Restore .tools/pandoc-3.9.0.2 or install Pandoc."
}
$pandoc = [string]($pandocCandidates | Select-Object -First 1)

if (-not (Test-Path -LiteralPath $manifestPath)) {
  throw "Missing source manifest: $manifestPath"
}

$manifestEntries = Get-Content -LiteralPath $manifestPath |
  ForEach-Object { $_.Trim() } |
  Where-Object { $_ -and -not $_.StartsWith("#") }

$duplicates = $manifestEntries | Group-Object | Where-Object Count -gt 1
if ($duplicates) {
  throw "Duplicate source path in manifest: $(($duplicates.Name) -join ', ')"
}

$sourcePaths = foreach ($entry in $manifestEntries) {
  $path = Join-Path $root ($entry -replace "/", "\")
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Manifest source does not exist: $entry"
  }
  $path
}

$sourceText = ($sourcePaths | ForEach-Object {
  Get-Content -LiteralPath $_ -Raw
}) -join [Environment]::NewLine

if ($sourceText -match '(?i)theme\s*:\s*(default|forest|dark|base)') {
  throw "A diagram overrides the book-wide neutral theme."
}

function Invoke-HandbookPandoc {
  param(
    [Parameter(Mandatory)] [string]$OutputPath,
    [Parameter(Mandatory)] [string[]]$StylePaths,
    [Parameter(Mandatory)] [string]$RuntimePath
  )

  $arguments = @()
  $arguments += $sourcePaths
  $arguments += @(
    "--from=markdown+fenced_divs+pipe_tables+header_attributes+task_lists+fenced_code_attributes+backtick_code_blocks+autolink_bare_uris",
    "--to=html5",
    "--standalone",
    "--toc",
    "--toc-depth=3",
    "--section-divs",
    "--metadata-file=$metadataPath",
    "--lua-filter=$filterPath"
  )
  foreach ($stylePath in $StylePaths) {
    $arguments += "--css=$stylePath"
  }
  $arguments += @(
    "--include-after-body=$RuntimePath",
    "--embed-resources",
    "--resource-path=$root;$bookDir",
    "--output=$OutputPath"
  )

  & $pandoc @arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Pandoc failed while creating $OutputPath"
  }
}

Write-Host "Building single-file HTML..."
Invoke-HandbookPandoc -OutputPath $htmlOutput -StylePaths @($bookCss) -RuntimePath $screenRuntime

if (-not $SkipPdf) {
  Write-Host "Building paged print HTML..."
  Invoke-HandbookPandoc -OutputPath $printHtml -StylePaths @($bookCss, $printCss) -RuntimePath $printRuntime

  $chromeCandidates = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
  ) | Where-Object { Test-Path -LiteralPath $_ }

  if (-not $chromeCandidates) {
    throw "A Chromium browser is required for vector Mermaid PDF rendering."
  }
  $chrome = [string]($chromeCandidates | Select-Object -First 1)
  $printUri = ([Uri]$printHtml).AbsoluteUri
  $profileDir = Join-Path $buildDir ("chrome-profile-" + [Guid]::NewGuid().ToString("N"))
  $stagedPdf = Join-Path $buildDir ("book-" + [Guid]::NewGuid().ToString("N") + ".pdf")
  New-Item -ItemType Directory -Force -Path $profileDir | Out-Null

  $chromeCommon = @(
    "--headless=new",
    "--no-sandbox",
    "--disable-gpu",
    "--disable-dev-shm-usage",
    "--no-first-run",
    "--run-all-compositor-stages-before-draw",
    "--disable-search-engine-choice-screen",
    "--allow-file-access-from-files",
    "--virtual-time-budget=30000",
    "--user-data-dir=$profileDir"
  )

  Write-Host "Rendering Mermaid, paginating A4 pages, and printing PDF..."
  $pdfArgument = "--print-to-pdf=$stagedPdf"
  & $chrome @chromeCommon "--no-pdf-header-footer" $pdfArgument $printUri
  if ($LASTEXITCODE -ne 0) {
    throw "Chromium failed while creating the PDF."
  }

  $stableChecks = 0
  $previousLength = -1
  for ($attempt = 0; $attempt -lt 120; $attempt++) {
    if (Test-Path -LiteralPath $stagedPdf) {
      $currentLength = (Get-Item -LiteralPath $stagedPdf).Length
      if ($currentLength -gt 10000 -and $currentLength -eq $previousLength) {
        $stableChecks++
      } else {
        $stableChecks = 0
      }
      $previousLength = $currentLength
      if ($stableChecks -ge 3) { break }
    }
    Start-Sleep -Milliseconds 500
  }
  if (-not (Test-Path -LiteralPath $stagedPdf) -or (Get-Item $stagedPdf).Length -lt 10000) {
    throw "Chromium exited without producing a complete staged PDF. The previous output was preserved."
  }
  Move-Item -LiteralPath $stagedPdf -Destination $pdfOutput -Force
}

if (-not (Test-Path -LiteralPath $htmlOutput) -or (Get-Item $htmlOutput).Length -lt 10000) {
  throw "HTML output is missing or implausibly small."
}

Write-Host ""
Write-Host "Build complete"
Write-Host "Markdown manifest: $manifestPath"
Write-Host "HTML: $htmlOutput"
if (-not $SkipPdf) {
  if (-not (Test-Path -LiteralPath $pdfOutput) -or (Get-Item $pdfOutput).Length -lt 10000) {
    throw "PDF output is missing or implausibly small."
  }
  $pdfBytes = [IO.File]::ReadAllBytes($pdfOutput)
  $pdfText = [Text.Encoding]::GetEncoding(28591).GetString($pdfBytes)
  $pageCount = ([regex]::Matches($pdfText, '/Type\s*/Page\b')).Count
  Write-Host "PDF: $pdfOutput"
  Write-Host "PDF pages: $pageCount"
}
