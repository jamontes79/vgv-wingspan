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

- [ ] Codex validation passes skill metadata checks.
- [ ] `create-pr` no longer blocks Codex validation.
- [ ] `rebase` no longer blocks Codex validation.
- [ ] Shared Claude behavior is not changed without validation.
- [ ] Any Codex-only skill adaptation is isolated in the generated package if required.
- [ ] Claude validation still passes if shared files changed.

