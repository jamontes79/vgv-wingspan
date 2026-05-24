# Task 012: Add Compatibility Maintainer Checklist

## Goal

Create a durable checklist for future changes so Claude and Codex compatibility do not drift.

## Scope

- Add a maintainer checklist to contributor docs or a dedicated compatibility doc.
- Include validation commands.
- Include guardrails for new skills and runtime-specific behavior.

## Checklist Content

Include this baseline:

```markdown
- [ ] `claude plugin validate .` passes or known warnings are documented.
- [ ] `python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .` passes.
- [ ] `bash hooks/test_recommend_plugins.sh` passes.
- [ ] JSON files validate with `jq`.
- [ ] New skills include `name` and `description`.
- [ ] New shared skills do not use `disable-model-invocation: true`.
- [ ] Claude-only instructions are isolated or have Codex-safe fallbacks.
- [ ] README install instructions are still accurate.
```

## Steps

1. Choose the checklist location:

   - `CONTRIBUTING.md`
   - `docs/codex-compatibiliy.md`
   - A new dedicated compatibility checklist document

2. Add the checklist.

3. Link it from README or CONTRIBUTING if useful.

4. Confirm the commands match the selected packaging strategy.

## Acceptance Criteria

- [ ] Maintainer checklist exists.
- [ ] Checklist includes Claude validation.
- [ ] Checklist includes Codex validation.
- [ ] Checklist includes hook tests.
- [ ] Checklist includes skill metadata guardrails.
- [ ] Checklist is linked from contributor-facing documentation.

