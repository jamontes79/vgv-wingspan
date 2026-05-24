# Task 009: Add Codex Local Install and Reinstall Documentation

## Goal

Document how to install, validate, and iterate on the Codex-compatible plugin locally.

## Scope

- Add Codex installation instructions to README.
- Document personal marketplace usage.
- Document cachebuster reinstall flow.
- Tell users to start a new Codex thread after reinstalling.

## Steps

1. Add a `Codex` subsection under installation docs.

2. Document validation:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

   Or, for generated packages:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py dist/codex/vgv-wingspan
   ```

3. Document local marketplace expectations.

   Default personal marketplace path:

   ```text
   ~/.agents/plugins/marketplace.json
   ```

4. Document reading the marketplace name.

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/read_marketplace_name.py
   ```

5. Document install.

   ```bash
   codex plugin add vgv-wingspan@<marketplace-name>
   ```

6. Document cachebuster update.

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/update_plugin_cachebuster.py <plugin-path>
   ```

7. Document reinstall and new-thread requirement.

## Acceptance Criteria

- [x] README has Codex-specific install instructions.
- [x] README keeps Claude install instructions separate.
- [x] Local validation command is documented.
- [x] Local install command is documented.
- [x] Cachebuster reinstall flow is documented.
- [x] New-thread requirement is documented.

## Implementation Notes

- Added a separate `Claude Code` installation subsection.
- Added a `Codex` installation subsection that targets the generated package at
  `dist/codex/vgv-wingspan`.
- Documented package generation, local validation, personal marketplace path,
  marketplace-name lookup, install command, cachebuster update, reinstall, and
  the new-thread requirement.
- Codex validation passed for the generated package after the README update.
