# Task 010: Run Local Codex Smoke Tests

## Goal

Verify the Codex-compatible plugin works locally before publishing or merging.

## Scope

- Validate the plugin target.
- Install it locally.
- Start a new Codex thread.
- Exercise core workflows through natural-language prompts.
- Record results.

## Steps

1. Validate the Codex plugin target.

   Same-root:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

   Generated package:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py dist/codex/vgv-wingspan
   ```

2. Validate Claude still works from repo root.

   ```bash
   claude plugin validate .
   ```

3. Install the Codex plugin locally.

4. Verify installed plugin source.

   ```bash
   codex plugin list
   ```

5. Start a new Codex thread.

6. Run smoke prompts:

   ```text
   Use Wingspan to brainstorm adding authentication to this app.
   ```

   ```text
   Use Wingspan to plan the authentication feature.
   ```

   ```text
   Use Wingspan to review this repo.
   ```

   ```text
   Use Wingspan build flow for docs/plan/example.md.
   ```

7. Record:

   - Whether the expected skill triggered.
   - Whether Claude-only syntax leaked into Codex responses.
   - Whether generated artifacts used expected directories.
   - Whether unsupported behavior had a fallback.

## Acceptance Criteria

- [ ] Codex validation passes.
- [ ] Claude validation still passes.
- [ ] Plugin installs locally.
- [ ] New Codex thread is used for testing.
- [ ] Brainstorm smoke prompt works.
- [ ] Plan smoke prompt works.
- [ ] Review smoke prompt works.
- [ ] Build smoke prompt works or documents any expected limitation.
- [ ] Results are recorded in the PR.

