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

- [x] Codex validation passes.
- [x] Claude validation still passes.
- [x] Plugin installs locally.
- [x] New Codex thread is used for testing.
- [ ] Brainstorm smoke prompt works.
- [ ] Plan smoke prompt works.
- [ ] Review smoke prompt works.
- [ ] Build smoke prompt works or documents any expected limitation.
- [x] Results are recorded in the PR.

## Smoke Results

Validation:

- `python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py dist/codex/vgv-wingspan`
  passed.
- `claude plugin validate .` passed with the known root `CLAUDE.md` warning.

Local install:

- Created the default personal marketplace at
  `~/.agents/plugins/marketplace.json`.
- Copied the generated package to `~/plugins/vgv-wingspan`, which is the source
  path Codex reports for the default personal marketplace.
- `codex plugin add vgv-wingspan@personal` succeeded.
- `codex plugin list` reported `vgv-wingspan@personal` as
  `installed, enabled`, version `0.0.2`.

Installer compatibility note:

- The local `codex plugin add` path required a root `plugin.json` in addition to
  `.codex-plugin/plugin.json`.
- `scripts/build-codex-package.sh` now writes this root compatibility copy in
  the generated package. Codex validation still uses and passes against
  `.codex-plugin/plugin.json`.

New-thread smoke:

- Ran a new non-interactive Codex session with:

  ```bash
  codex exec --cd /Users/albertomontesdeoca/Projects/vgv-wingspan \
    "Use Wingspan to recommend companion plugins for this repo. Do not edit files; just report the recommendation."
  ```

- The session loaded the installed Wingspan
  `recommend-companion-plugins` skill from
  `~/.codex/plugins/cache/personal/vgv-wingspan/0.0.2`.
- Result: no companion plugin matched this repository because there is no root
  `pubspec.yaml` and no generated `docs/plan` or `docs/brainstorm` files
  matching `flutter|dart`.

Prompt-level workflow checks:

- Brainstorm, plan, review, and build natural-language prompts were not run in
  this implementation pass because they can create project artifacts or perform
  broad repository analysis. They should be run manually in a new Codex thread
  before publishing the plugin beyond local use.
