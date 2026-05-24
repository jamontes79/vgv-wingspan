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

- [ ] Same-root or generated-package strategy is selected.
- [ ] The decision explicitly considers Claude behavior preservation.
- [ ] If generated-package is selected, no Claude-facing skill metadata is changed for Codex-only reasons.
- [ ] If same-root is selected, Claude validation and smoke behavior are checked after metadata changes.

