# Task 011: Update CI and Release Automation

## Goal

Ensure Codex compatibility remains validated and released alongside Claude compatibility.

## Scope

- Add Codex validation to CI if practical.
- Update release automation to version `.codex-plugin/plugin.json`.
- Remove or fix stale release-please references.

## Steps

1. Check existing GitHub Actions workflows.

2. Decide how CI should run Codex validation.

   Preferred command:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

3. If CI cannot rely on local Codex skill scripts, choose one:

   - Vendor a minimal validator script.
   - Add a documented manual validation step.
   - Defer CI validation until an official CI-safe validator exists.

4. Update `.release-please-config.json` to version:

   - `.claude-plugin/plugin.json`
   - `.codex-plugin/plugin.json`

5. Remove or fix references to missing `.claude-plugin/marketplace.json`.

6. Update `CHANGELOG.md` when compatibility lands.

## Acceptance Criteria

- [ ] Release automation updates `.codex-plugin/plugin.json`.
- [ ] Release automation does not reference missing files unintentionally.
- [ ] CI or manual validation path for Codex is documented.
- [ ] Claude validation remains part of the release checklist.
- [ ] Changelog entry is prepared when implementation lands.

