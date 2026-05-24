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

- [ ] `.codex-plugin/plugin.json` exists.
- [ ] Manifest uses only fields accepted by Codex validation.
- [ ] Manifest has no TODO placeholders.
- [ ] Manifest version is strict semver.
- [ ] Manifest does not declare unsupported hooks.
- [ ] Codex validation reaches the skill validation stage.
- [ ] Claude plugin files are not changed except for metadata fixes from Task 002.

