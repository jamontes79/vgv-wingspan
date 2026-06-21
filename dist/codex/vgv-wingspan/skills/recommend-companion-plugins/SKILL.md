---
name: recommend-companion-plugins
description: Manually checks Wingspan companion plugin recommendation data and suggests relevant companion plugins for the current project.
when_to_use: Use when the user asks which companion plugins are recommended, wants Codex-safe plugin recommendations, or wants to inspect Wingspan recommendation rules.
---

# Recommend companion plugins

Wingspan's Claude package recommends companion plugins through a Claude
`PreToolUse` hook. The Codex package uses a Codex `UserPromptSubmit` hook for
best-effort recommendation context, and this skill remains the manual fallback
for inspecting the same runtime-neutral recommendation data on demand.

## Steps

1. Locate the Wingspan plugin root and read every JSON file under
   `hooks/recommendations/`.
2. For each recommendation, parse:
   - `plugin`: companion plugin name.
   - `description`: what the plugin provides.
   - `marketplace`: one marketplace name or an array of marketplace names.
   - `detect`: one detection object or an array of detection objects.
3. Evaluate detection rules against the current project root:
   - `detect.file`: exact file path. The rule matches when the file exists and
     its contents match `detect.pattern` case-insensitively.
   - `detect.files`: shell-style glob. The rule matches when any matching file
     contains `detect.pattern` case-insensitively.
   - An array of detection rules uses OR logic.
4. Ignore invalid recommendation files, but mention that they could not be read
   if the user asked for diagnostics.
5. For every matching recommendation, tell the user:
   - The companion plugin name.
   - Why it matched.
   - What the plugin provides.
   - The marketplace install command for each marketplace.

## Output

If no recommendation matches, say that no registered Wingspan companion plugin
matched the current project.

For matches, use this format:

```markdown
Recommended companion plugins:

- `<plugin-name>`: <description>
  - Matched: `<file-or-glob>` with pattern `<pattern>`
  - Install:
    - `codex plugin add <plugin-name>@<marketplace-name>` for Codex, when that marketplace is configured.
    - `/plugin marketplace add <marketplace-name>` then `/plugin install <plugin-name>` for Claude Code.
```
