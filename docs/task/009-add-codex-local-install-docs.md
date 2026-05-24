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

- [ ] README has Codex-specific install instructions.
- [ ] README keeps Claude install instructions separate.
- [ ] Local validation command is documented.
- [ ] Local install command is documented.
- [ ] Cachebuster reinstall flow is documented.
- [ ] New-thread requirement is documented.

