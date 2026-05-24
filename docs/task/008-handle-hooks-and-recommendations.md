# Task 008: Handle Hooks and Companion Plugin Recommendations

## Goal

Keep Claude hook behavior intact while creating a Codex-safe path for companion plugin recommendations.

## Scope

- Do not add Claude hook config to `.codex-plugin/plugin.json`.
- Preserve `hooks/recommend-plugins.sh` behavior for Claude.
- Add a Codex-safe manual or future-adapter path for companion plugin recommendations.

## Steps

1. Keep `hooks/hooks.json` as Claude-specific unless Codex hook support is confirmed.

2. Do not add a `hooks` field to `.codex-plugin/plugin.json`.

3. Decide whether to create a manual Codex skill:

   ```text
   skills/recommend-companion-plugins/SKILL.md
   ```

4. If creating the skill, make it:

   - Read `hooks/recommendations/*.json`.
   - Explain matching rules.
   - Recommend relevant companion plugins.
   - Avoid Claude hook event output schemas.

5. Make recommendation data runtime-neutral where practical.

6. Preserve and extend hook tests.

   Existing test:

   ```bash
   bash hooks/test_recommend_plugins.sh
   ```

7. Add tests for:

   - Missing `jq`.
   - Invalid recommendation JSON.
   - Plugin names that are substrings of other plugin names.
   - Multiple marketplace names.
   - Runtime-neutral root detection.

## Acceptance Criteria

- [x] Claude hook behavior remains unchanged.
- [x] Codex manifest does not declare unsupported hooks.
- [x] Companion recommendation data remains reusable.
- [x] Codex has a documented fallback for companion plugin recommendations.
- [x] Hook tests still pass.

## Implementation Notes

- Kept `hooks/hooks.json` Claude-specific and did not add hooks to the Codex
  manifest.
- Added `skills/recommend-companion-plugins/SKILL.md` as a manual Codex-safe
  fallback that reads the same `hooks/recommendations/*.json` data.
- Hardened `hooks/recommend-plugins.sh` without changing its output schema:
  - Exits silently when `jq` is unavailable.
  - Skips invalid recommendation JSON files.
  - Checks installed plugin names exactly instead of by substring.
  - Supports `marketplace` as either a string or an array.
  - Uses hook input `cwd`/workspace fields when available, falling back to
    `PWD`, so detection can run from a runtime-provided project root.
- Extended hook tests for missing `jq`, invalid recommendation JSON, substring
  plugin names, multiple marketplace names, and project-root input detection.
- Hook tests passed with `51 passed, 0 failed`.
- Codex validation passed for `dist/codex/vgv-wingspan`.
- Claude validation passed with the known root `CLAUDE.md` warning.
