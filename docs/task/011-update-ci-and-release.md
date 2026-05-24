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

- [x] Release automation updates `.codex-plugin/plugin.json`.
- [x] Release automation does not reference missing files unintentionally.
- [x] CI or manual validation path for Codex is documented.
- [x] Claude validation remains part of the release checklist.
- [x] Changelog entry is prepared when implementation lands.

## Implementation Notes

- Added `scripts/validate-codex-plugin.py` so CI does not depend on a local
  `~/.codex` skill install.
- Added a `codex-plugin-validate` CI job that regenerates
  `dist/codex/vgv-wingspan` and validates it with the repo-local validator.
- Kept the existing Claude `plugin-validate` CI job.
- Updated `.release-please-config.json` to version:
  - `.claude-plugin/plugin.json`
  - `.codex-plugin/plugin.json`
  - `dist/codex/vgv-wingspan/.codex-plugin/plugin.json`
  - `dist/codex/vgv-wingspan/plugin.json`
- Confirmed release-please no longer references missing
  `.claude-plugin/marketplace.json` files.
- Added an unreleased changelog entry for Codex compatibility.
- Repo-local Codex validation, local Codex plugin validation, and JSON
  validation passed.
