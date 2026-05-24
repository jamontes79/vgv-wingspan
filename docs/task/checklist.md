# Codex Compatibility Task Checklist

Use this checklist to implement Codex compatibility without changing current
Claude behavior.

## Tasks

- [ ] [Task 001: Establish Compatibility Baseline](001-baseline-validation.md)
- [ ] [Task 002: Fix Existing Metadata and Release Config Issues](002-fix-metadata-and-release-config.md)
- [ ] [Task 003: Create Codex Plugin Manifest](003-create-codex-manifest.md)
- [ ] [Task 004: Decide Same-Root vs Generated Codex Package](004-decide-packaging-strategy.md)
- [ ] [Task 005: Make Skills Codex-Valid](005-make-skills-codex-valid.md)
- [ ] [Task 006: Port Plugin-Level Context Into Shared References](006-port-plugin-context.md)
- [ ] [Task 007: Adapt Claude-Style Agents for Codex Workflows](007-adapt-agents-for-codex.md)
- [ ] [Task 008: Handle Hooks and Companion Plugin Recommendations](008-handle-hooks-and-recommendations.md)
- [ ] [Task 009: Add Codex Local Install and Reinstall Documentation](009-add-codex-local-install-docs.md)
- [ ] [Task 010: Run Local Codex Smoke Tests](010-local-codex-smoke-tests.md)
- [ ] [Task 011: Update CI and Release Automation](011-update-ci-and-release.md)
- [ ] [Task 012: Add Compatibility Maintainer Checklist](012-add-compatibility-maintainer-checklist.md)

## Required Final Validation

- [ ] Claude plugin validation passes:

  ```bash
  claude plugin validate .
  ```

- [ ] Codex plugin validation passes:

  ```bash
  python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
  ```

- [ ] Hook tests pass:

  ```bash
  bash hooks/test_recommend_plugins.sh
  ```

- [ ] JSON validation passes:

  ```bash
  find . -name '*.json' -not -path './node_modules/*' -print0 | xargs -0 -n1 jq empty
  ```

- [ ] Shell syntax checks pass:

  ```bash
  for f in skills/shared/scripts/*.sh hooks/*.sh; do bash -n "$f" || exit 1; done
  ```

- [ ] Local Codex install has been tested in a new Codex thread.
- [ ] Current Claude behavior remains unchanged or any accepted difference is
      documented.
