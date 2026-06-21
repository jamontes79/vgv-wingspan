#!/usr/bin/env bash
set -euo pipefail

# UserPromptSubmit hook: add Codex-visible context about companion plugins.
#
# This is intentionally separate from recommend-plugins.sh. The Claude hook is
# triggered by Claude tool names and checks Claude settings; this hook uses the
# Codex hook input contract and PLUGIN_ROOT.

INPUT=$(cat)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_EVENT_NAME=$(printf "%s" "$INPUT" | jq -r '.hook_event_name // "UserPromptSubmit"' 2>/dev/null || echo "UserPromptSubmit")
PROJECT_ROOT=$(printf "%s" "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)

if [[ -n "$PROJECT_ROOT" && -d "$PROJECT_ROOT" ]]; then
  cd "$PROJECT_ROOT"
fi

PROJECT_HASH=$(pwd | shasum | cut -d' ' -f1)
MARKER="/tmp/wingspan-codex-recommend-plugins-$PROJECT_HASH"

if [[ -f "$MARKER" ]]; then
  exit 0
fi

RECOMMENDATIONS_DIR="$SCRIPT_DIR/recommendations"

if [[ ! -d "$RECOMMENDATIONS_DIR" ]]; then
  exit 0
fi

RECOMMENDATIONS=()

for rec_file in "$RECOMMENDATIONS_DIR"/*.json; do
  [[ -f "$rec_file" ]] || continue

  plugin=$(jq -r '.plugin' "$rec_file")
  marketplace=$(jq -r '.marketplace' "$rec_file")
  description=$(jq -r '.description' "$rec_file")

  detect_type=$(jq -r '.detect | type' "$rec_file")
  if [[ "$detect_type" == "array" ]]; then
    detect_entries=$(jq -c '.detect[]' "$rec_file")
  else
    detect_entries=$(jq -c '.detect' "$rec_file")
  fi

  matched=false
  while IFS= read -r entry; do
    entry_file=$(echo "$entry" | jq -r '.file // empty')
    entry_files=$(echo "$entry" | jq -r '.files // empty')
    entry_pattern=$(echo "$entry" | jq -r '.pattern')

    if [[ -n "$entry_file" ]]; then
      if [[ -f "$entry_file" ]] && grep -qiE "$entry_pattern" "$entry_file" 2>/dev/null; then
        matched=true
        break
      fi
    elif [[ -n "$entry_files" ]]; then
      for gf in $entry_files; do
        if [[ -f "$gf" ]] && grep -qiE "$entry_pattern" "$gf" 2>/dev/null; then
          matched=true
          break 2
        fi
      done
    fi
  done <<< "$detect_entries"

  if [[ "$matched" != "true" ]]; then
    continue
  fi

  RECOMMENDATIONS+=("Wingspan detected this project may benefit from the '${plugin}' companion plugin. It provides: ${description} If this companion is available in your Codex plugin marketplace, install it with: codex plugin add ${plugin}@<marketplace-name>. Claude Code marketplace source: ${marketplace}.")
done

if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
  touch "$MARKER"
  newline=$'\n'
  message=""
  for rec in "${RECOMMENDATIONS[@]}"; do
    if [[ -n "$message" ]]; then
      message="$message${newline}${newline}$rec"
    else
      message="$rec"
    fi
  done

  jq -n \
    --arg event "$HOOK_EVENT_NAME" \
    --arg ctx "$message" \
    '{
      hookSpecificOutput: {
        hookEventName: $event,
        additionalContext: $ctx
      }
    }'
fi
