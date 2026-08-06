[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string]$BundlePath
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$resolvedBundle = (Resolve-Path -LiteralPath $BundlePath).Path
$content = [IO.File]::ReadAllText($resolvedBundle, [Text.Encoding]::UTF8)
$pattern = '(?ms)^<!-- FILE: ([^\r\n]+) -->\r?\n(.*?)(?=^<!-- FILE: |\z)'
$matches = [regex]::Matches($content, $pattern)

if ($matches.Count -eq 0) {
  throw "No FILE markers found in $resolvedBundle"
}

$encoding = [Text.UTF8Encoding]::new($false)
foreach ($match in $matches) {
  $relativePath = $match.Groups[1].Value.Trim() -replace '/', '\'
  $targetPath = [IO.Path]::GetFullPath((Join-Path $root $relativePath))
  if (-not $targetPath.StartsWith((Join-Path $root "book\chapters"), [StringComparison]::OrdinalIgnoreCase)) {
    throw "Bundle target is outside book/chapters: $relativePath"
  }
  if (-not (Test-Path -LiteralPath $targetPath)) {
    throw "Bundle target does not exist: $relativePath"
  }
  $chapter = $match.Groups[2].Value.TrimEnd() + [Environment]::NewLine
  [IO.File]::WriteAllText($targetPath, $chapter, $encoding)
}

Write-Host "Updated $($matches.Count) chapter files from $resolvedBundle"
