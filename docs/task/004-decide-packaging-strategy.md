# Task 004: Decide Same-Root vs Generated Codex Package

## Goal

Choose the packaging strategy that enables Codex compatibility without changing Claude behavior.

## Scope

- Evaluate whether shared `skills/` can satisfy both Claude and Codex.
- Decide whether to keep same-root dual manifests or generate a separate Codex package.

## Decision Options

### Option A: Same-Root Dual Manifest

Use this layout:

```text
vgv-wingspan/
  .claude-plugin/
    plugin.json
  .codex-plugin/
    plugin.json
  skills/
  agents/
  hooks/
```

Use this if Codex validation passes after harmless shared metadata cleanup.

### Option B: Generated Codex Package

Use this layout:

```text
dist/
  codex/
    vgv-wingspan/
      .codex-plugin/
        plugin.json
      skills/
      hooks/
      scripts/
      assets/
```

Use this if Codex requires changes that would alter Claude behavior.

## Steps

1. Run Codex validation after adding the manifest.

2. Identify validation failures caused by shared Claude skill metadata.

3. Pay special attention to:

   - `skills/create-pr/SKILL.md`
   - `skills/rebase/SKILL.md`

4. Determine whether removing or changing rejected metadata would alter Claude behavior.

5. Choose the packaging strategy.

6. Document the decision in this task file or the implementation PR.

## Acceptance Criteria

- [x] Same-root or generated-package strategy is selected.
- [x] The decision explicitly considers Claude behavior preservation.
- [x] If generated-package is selected, no Claude-facing skill metadata is changed for Codex-only reasons.
- [x] If same-root is selected, Claude validation and smoke behavior are checked after metadata changes.

## Decision

Use **Option B: Generated Codex Package**.

Codex validation after adding `.codex-plugin/plugin.json` showed that the
same-root layout would require shared-tree changes for Codex-only reasons:

- `skills/create-pr/SKILL.md` has `disable-model-invocation: true`.
- `skills/rebase/SKILL.md` has `disable-model-invocation: true`.
- `skills/shared` is a support directory, but Codex validates every direct
  subdirectory under `skills/` as a skill and therefore expects
  `skills/shared/SKILL.md`.

Changing these in place would either alter Claude-facing skill metadata or turn
the shared support directory into an exposed skill. The Codex package should
therefore be generated under `dist/codex/vgv-wingspan` with Codex-safe skill
copies and shared references placed outside the generated `skills/` directory.

The root `.codex-plugin/plugin.json` remains useful as metadata, but local
Codex validation and installation should target:

```bash
python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py dist/codex/vgv-wingspan
```
