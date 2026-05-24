# Task 006: Port Plugin-Level Context Into Shared References

## Goal

Make Wingspan's plugin-level guidance available to Codex without relying on root `CLAUDE.md`.

## Scope

- Split reusable `CLAUDE.md` content into shared skill references.
- Update core skills to reference the shared guidance.
- Keep `CLAUDE.md` as a Claude-facing convenience document.

## Proposed New References

```text
skills/shared/references/wingspan-philosophy.md
skills/shared/references/workflow-conventions.md
skills/shared/references/output-directories.md
skills/shared/references/quality-standards.md
```

## Steps

1. Extract reusable guidance from `CLAUDE.md`.

2. Create the shared reference files.

3. Update relevant skills to reference them:

   - `brainstorm`
   - `plan`
   - `build`
   - `review`
   - `hotfix`
   - `create-pr`
   - `debrief`

4. Add a note to `CLAUDE.md` that shared references are the source of truth for portable plugin behavior.

5. Validate both plugin modes.

## Acceptance Criteria

- [ ] Core Wingspan philosophy is available outside root `CLAUDE.md`.
- [ ] Workflow conventions are available to Codex-facing skills.
- [ ] Output directory rules are available to Codex-facing skills.
- [ ] Quality standards are available to Codex-facing skills.
- [ ] `CLAUDE.md` remains present for Claude users.
- [ ] Claude validation still passes.
- [ ] Codex validation still passes.

