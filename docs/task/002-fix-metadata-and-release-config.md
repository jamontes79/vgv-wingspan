# Task 002: Fix Existing Metadata and Release Config Issues

## Goal

Resolve low-risk repository inconsistencies before introducing Codex files.

## Scope

- Fix the typo in `.claude-plugin/plugin.json`.
- Reconcile marketplace naming between README and recommendation metadata.
- Fix or intentionally remove release-please references to missing marketplace files.

## Steps

1. Fix the manifest keyword typo.

   Change:

   ```text
   software development lifecyle
   ```

   To:

   ```text
   software development lifecycle
   ```

2. Decide the canonical Claude marketplace repository name.

   Current mismatch:

   - `README.md`: `VeryGoodOpenSource/very_good_claude_marketplace`
   - `hooks/recommendations/very-good-ai-flutter-plugin.json`: `VeryGoodOpenSource/very_good_claude_code_marketplace`

3. Update the incorrect marketplace reference.

4. Inspect `.release-please-config.json`.

   It currently references:

   ```text
   .claude-plugin/marketplace.json
   ```

   That file is not present.

5. Choose one release-please fix:

   - Add the missing marketplace file if it is intentionally part of the release process.
   - Remove the missing marketplace file entries if they are stale.
   - Defer marketplace version updates to a later release task and document why.

6. Re-run JSON validation.

## Acceptance Criteria

- [x] `.claude-plugin/plugin.json` no longer contains `lifecyle`.
- [x] README and recommendation metadata use the same canonical marketplace naming scheme.
- [x] `.release-please-config.json` no longer references missing files unintentionally.
- [x] JSON validation passes.
- [x] Claude validation still passes with no new warnings.

## Implementation Notes

Metadata typo:

- Fixed `.claude-plugin/plugin.json` keyword from `software development lifecyle` to `software development lifecycle`.

Marketplace references:

- Reviewed the apparent marketplace mismatch.
- No code change was made because the references are for different plugin flows:
  - `README.md` installs `vgv-wingspan` from `VeryGoodOpenSource/very_good_claude_marketplace`.
  - `hooks/recommendations/very-good-ai-flutter-plugin.json` recommends the companion `very-good-ai-flutter-plugin` from `VeryGoodOpenSource/very_good_claude_code_marketplace`.
- Treat these as intentionally separate unless a later verification against the actual marketplace repositories proves otherwise.

Release config:

- Removed stale `.release-please-config.json` extra-file entries for `.claude-plugin/marketplace.json`.
- That marketplace file is not present in the repository, so keeping those entries would make release automation reference a missing file.

Validation:

- JSON validation passed.
- `claude plugin validate .` passed with the same known root `CLAUDE.md` warning and no new warnings.
