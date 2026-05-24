# Task 007: Adapt Claude-Style Agents for Codex Workflows

## Goal

Preserve review and research behavior in Codex even if top-level Claude agents are unavailable.

## Scope

- Inventory all skill references to top-level agents.
- Convert agent guidance into Codex-readable shared references or Codex-specific skill content.
- Keep existing Claude agents unless intentionally removed in a later cleanup.

## Steps

1. Inventory agent references.

   ```bash
   rg -n '@[a-z0-9-]+-agent|Task|agent' skills agents
   ```

2. Create shared agent reference files.

   Suggested layout:

   ```text
   skills/shared/references/agents/
     official-docs-research.md
     best-practices-research.md
     plan-splitting.md
     user-flow-analysis.md
     architecture-review.md
     test-quality-review.md
     pr-readiness-review.md
     vgv-review.md
     codebase-review.md
     code-simplicity-review.md
   ```

3. Move or summarize the useful instructions from `agents/**/*.md` into those references.

4. Update Codex-facing orchestrator skills:

   - `review`
   - `build`
   - `hotfix`
   - `plan`
   - `plan-technical-review`

5. Remove Codex dependency on `@agent-name` syntax.

6. Validate Codex and Claude behavior.

## Acceptance Criteria

- [x] Codex-facing review workflows do not depend on top-level Claude agent loading.
- [x] Review and research criteria remain available to Codex.
- [x] Existing Claude agents are not removed unless intentionally approved.
- [x] `review`, `build`, `hotfix`, `plan`, and `plan-technical-review` still describe complete review behavior.
- [x] Codex validation passes.

## Implementation Notes

- Inventoried agent references with:

  ```bash
  rg -n '@[a-z0-9-]+-agent|Task|agent' skills agents
  ```

- Added portable summaries under `skills/shared/references/agents/` for the
  research, analysis, review, and codebase-review agents.
- Linked the relevant agent references into orchestrator skills.
- Updated `brainstorm`, `plan`, `build`, `hotfix`, `review`, and
  `plan-technical-review` with direct fallback instructions for runtimes where
  top-level Claude agent invocation is unavailable.
- Regenerated `dist/codex/vgv-wingspan`.
- Codex validation passed for the generated package.
