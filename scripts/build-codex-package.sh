#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$repo_root/dist/codex/vgv-wingspan"
force=false

if [[ "${1:-}" == "--force" ]]; then
  force=true
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--force]" >&2
  exit 64
fi

if [[ -e "$target" ]]; then
  if [[ "$force" != true ]]; then
    echo "Refusing to overwrite existing generated package: $target" >&2
    echo "Run $0 --force to regenerate it." >&2
    exit 1
  fi
  rm -rf "$target"
fi

mkdir -p "$target"
rsync -aL "$repo_root/.codex-plugin/" "$target/.codex-plugin/"
cp "$target/.codex-plugin/plugin.json" "$target/plugin.json"
rsync -aL --exclude "/shared/" "$repo_root/skills/" "$target/skills/"

find "$target/skills" -name SKILL.md -print0 |
  xargs -0 perl -0pi -e 's/^disable-model-invocation:\s*true\n//m'
