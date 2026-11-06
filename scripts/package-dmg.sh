#!/bin/bash
set -euo pipefail

# Usage: scripts/package-dmg.sh /absolute/path/to/Lunotch.app [output-dir] [release-label]
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
app_path="${1:?Pass the built Lunotch.app path as the first argument}"
out_dir="${2:-$repo_root/dist}"
label="${3:-v0.1.0-preview.2}"

if [[ "$(basename "$app_path")" != 'Lunotch.app' || ! -x "$app_path/Contents/MacOS/Lunotch" ]]; then
  echo 'Expected a built Lunotch.app with an executable' >&2
  exit 1
fi
if [[ ! "$label" =~ ^[[:alnum:]._-]+$ ]]; then
  echo 'Release label must contain only letters, numbers, dots, hyphens and underscores' >&2
  exit 1
fi

mkdir -p "$out_dir"
out_dir="$(cd "$out_dir" && pwd)"
filename="Lunotch-${label}-arm64.dmg"
workdir="$(mktemp -d "${TMPDIR:-/tmp/}lunotch-dmg.XXXXXX")"
trap 'rm -rf "$workdir"' EXIT

ditto "$app_path" "$workdir/Lunotch.app"
ln -s /Applications "$workdir/Applications"
hdiutil create -volname 'Lunotch' -srcfolder "$workdir" -ov -format UDZO "$out_dir/$filename"
hdiutil verify "$out_dir/$filename"
shasum -a 256 "$out_dir/$filename"
echo "DMG: $out_dir/$filename"
