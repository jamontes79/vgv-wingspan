# Task 001: Establish Compatibility Baseline

## Goal

Capture the current Claude plugin and repository health before adding Codex compatibility.

## Scope

- Run the existing Claude plugin validation.
- Run repository JSON validation.
- Run hook tests.
- Run shell syntax checks.
- Record any pre-existing warnings or failures.

## Steps

1. Check the worktree state.

   ```bash
   git status --short
   ```

2. Validate the Claude plugin.

   ```bash
   claude plugin validate .
   ```

3. Validate JSON files.

   ```bash
   find . -name '*.json' -not -path './node_modules/*' -print0 | xargs -0 -n1 jq empty
   ```

4. Run hook tests.

   ```bash
   bash hooks/test_recommend_plugins.sh
   ```

5. Check shell syntax.

   ```bash
   for f in skills/shared/scripts/*.sh hooks/*.sh; do bash -n "$f" || exit 1; done
   ```

6. Record results in the PR description or implementation notes.

## Acceptance Criteria

- [x] `git status --short` is reviewed before edits.
- [x] `claude plugin validate .` result is recorded.
- [x] JSON validation result is recorded.
- [x] Hook test result is recorded.
- [x] Shell syntax result is recorded.
- [x] Any pre-existing warning is documented, especially the root `CLAUDE.md` warning.

## Baseline Results

Branch:

- Current branch: `feat/codex-compatibility`.

Worktree:

- `git status --short` showed only the new untracked `docs/` compatibility planning files before baseline validation.

Claude validation:

- Command: `claude plugin validate .`
- Result: passed with one existing warning.
- Warning: root `CLAUDE.md` is not loaded as project context. Claude recommends shipping plugin context through skills instead.

JSON validation:

- Command: `find . -name '*.json' -not -path './node_modules/*' -print0 | xargs -0 -n1 jq empty`
- Result: passed.

Hook tests:

- Command: `bash hooks/test_recommend_plugins.sh`
- Result: passed, `42 passed, 0 failed`.

Shell syntax:

- Command: `for f in skills/shared/scripts/*.sh hooks/*.sh; do bash -n "$f" || exit 1; done`
- Result: passed.
