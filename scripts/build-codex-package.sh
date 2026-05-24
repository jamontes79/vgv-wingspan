#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$repo_root/dist/codex/vgv-wingspan"

if [[ -e "$target" ]]; then
  echo "Refusing to overwrite existing generated package: $target" >&2
  echo "Remove it first, then rerun this script." >&2
  exit 1
fi

mkdir -p "$target"
rsync -aL "$repo_root/.codex-plugin/" "$target/.codex-plugin/"
rsync -aL --exclude "/shared/" "$repo_root/skills/" "$target/skills/"

find "$target/skills" -name SKILL.md -print0 |
  xargs -0 perl -0pi -e 's/^disable-model-invocation:\s*true\n//m'
