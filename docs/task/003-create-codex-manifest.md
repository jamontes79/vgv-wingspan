# Task 003: Create Codex Plugin Manifest

## Goal

Add a valid Codex plugin manifest without changing current Claude behavior.

## Scope

- Add `.codex-plugin/plugin.json`.
- Use Codex-supported manifest fields only.
- Point the manifest at `skills/` only if using same-root compatibility.
- Do not add hooks, apps, or MCP servers unless companion files exist and validate.

## Steps

1. Add `.codex-plugin/plugin.json`.

2. Start with these fields:

   - `id`
   - `name`
   - `version`
   - `description`
   - `skills`
   - `author`
   - `homepage`
   - `repository`
   - `license`
   - `keywords`
   - `interface`

3. Include required `interface` fields:

   - `displayName`
   - `shortDescription`
   - `longDescription`
   - `developerName`
   - `category`
   - `capabilities`
   - `defaultPrompt`

4. Do not include a `hooks` field.

5. Do not include `apps` or `mcpServers` unless `.app.json` or `.mcp.json` is added.

6. Keep the initial Codex version aligned with `.claude-plugin/plugin.json`.

7. Run Codex validation.

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

## Acceptance Criteria

- [x] `.codex-plugin/plugin.json` exists.
- [x] Manifest uses only fields accepted by Codex validation.
- [x] Manifest has no TODO placeholders.
- [x] Manifest version is strict semver.
- [x] Manifest does not declare unsupported hooks.
- [x] Codex validation reaches the skill validation stage.
- [x] Claude plugin files are not changed except for metadata fixes from Task 002.

## Implementation Notes

- Added `.codex-plugin/plugin.json` with supported Codex manifest fields only.
- Omitted hooks, apps, and MCP server declarations.
- Kept version aligned with `.claude-plugin/plugin.json` at `0.0.2`.
- Ran Codex validation:

  ```bash
  python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
  ```

- Validation reached the skill validation stage and reported these expected
  follow-up blockers:
  - `skills/create-pr/SKILL.md` has `disable-model-invocation: true`.
  - `skills/rebase/SKILL.md` has `disable-model-invocation: true`.
  - `skills/shared` is treated as a skill directory by the Codex validator and
    is missing `SKILL.md`.
