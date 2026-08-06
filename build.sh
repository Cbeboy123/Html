#!/usr/bin/env bash
set -euo pipefail

repo_dir="${BASH_SOURCE[0]%/*}"
if [[ "$repo_dir" == "${BASH_SOURCE[0]}" ]]; then
  repo_dir="."
fi
cd "$repo_dir"
repo_dir="$PWD"
powershell.exe -NoProfile -ExecutionPolicy Bypass \
  -File "$repo_dir/build.ps1"
