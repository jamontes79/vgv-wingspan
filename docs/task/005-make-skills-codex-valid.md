# Task 005: Make Skills Codex-Valid

## Goal

Ensure all Codex-exposed skills pass Codex validation while preserving Claude behavior.

## Scope

- Fix Codex validation blockers in skill frontmatter.
- Audit skill bodies for Claude-only assumptions.
- Use generated Codex copies if shared edits would change Claude behavior.

## Known Validation Blockers

Codex validation rejects `disable-model-invocation: true`.

Known affected skills:

- `skills/create-pr/SKILL.md`
- `skills/rebase/SKILL.md`

## Steps

1. Run the Codex validator.

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

   Or, for a generated package:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py dist/codex/vgv-wingspan
   ```

2. Fix validation blockers according to the packaging strategy:

   - Same-root: only change shared frontmatter if Claude behavior remains correct.
   - Generated package: strip or adapt Codex-invalid fields in the generated copy.

3. Audit every skill for these assumptions:

   - Slash-command-only language.
   - `$ARGUMENTS` behavior.
   - `@agent-name` references.
   - Claude `Task` tool assumptions.
   - Claude tool names such as `Read`, `Glob`, `Grep`, and `Bash`.
   - Claude-only `/clear` handoff instructions.
   - Claude-only plugin install commands.

4. Update Codex-facing skill copies where needed.

5. Re-run Codex validation.

6. Re-run Claude validation if shared files changed.

## Acceptance Criteria

- [x] Codex validation passes skill metadata checks.
- [x] `create-pr` no longer blocks Codex validation.
- [x] `rebase` no longer blocks Codex validation.
- [x] Shared Claude behavior is not changed without validation.
- [x] Any Codex-only skill adaptation is isolated in the generated package if required.
- [x] Claude validation still passes if shared files changed.

## Implementation Notes

- Added `scripts/build-codex-package.sh`.
- Generated `dist/codex/vgv-wingspan`.
- The generated package:
  - Copies `.codex-plugin/plugin.json`.
  - Copies all first-class skills except `skills/shared`.
  - Dereferences shared-reference symlinks into each generated skill.
  - Removes `disable-model-invocation: true` only from generated skill copies.
- Root Claude-facing skill files were not changed for Codex-only validation.
- Codex validation passed:

  ```bash
  python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py dist/codex/vgv-wingspan
  ```

- Claude validation still passed with the known root `CLAUDE.md` warning.
