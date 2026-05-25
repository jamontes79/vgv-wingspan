# Codex Compatibility Plan

## Purpose

Make VGV Wingspan usable as a Codex plugin while preserving the existing Claude
Code plugin as much as possible.

The current repository is already a valid Claude Code plugin. A Codex-compatible
version is possible, but it is not a pure manifest rename because Codex
validates a different plugin manifest contract and has different expectations
for skills, hooks, marketplace installation, and agent behavior.

## Target Outcome

By the end of this work, the repository should support a Codex-compatible plugin
package that:

- Includes a valid `.codex-plugin/plugin.json`.
- Passes the local Codex plugin validator.
- Exposes the core Wingspan workflow skills in Codex:
  - `brainstorm`
  - `plan`
  - `build`
  - `review`
  - `hotfix`
  - `create`
  - `create-branch`
  - `create-commit`
  - `create-pr`
  - `rebase`
  - `refine-approach`
  - `plan-technical-review`
  - `debrief`
  - `elements-of-style`
- Preserves Claude compatibility or provides a clearly separated Claude package
  if one source layout cannot support both runtimes cleanly.
- Documents Codex installation and local development workflows.
- Provides a repeatable validation checklist for future changes.

## Non-Goals

- Do not rewrite Wingspan's workflow model.
- Do not remove Claude Code support.
- Do not publish to a public Codex marketplace as part of the first pass.
- Do not assume Claude hook APIs work in Codex unchanged.
- Do not introduce runtime MCP servers or apps unless they are actually needed
  and validated.
- Do not move project-specific implementation guidance into global Codex
  configuration.

## Current Repository State

The repo currently contains:

- Claude plugin manifest: `.claude-plugin/plugin.json`.
- Plugin-level guidance: `CLAUDE.md`.
- Skills: `skills/*/SKILL.md`.
- Shared skill references and scripts:
  - `skills/shared/references/*`
  - `skills/shared/scripts/*`
- Claude-style agents: `agents/**/*.md`.
- Claude hook configuration: `hooks/hooks.json`.
- Hook implementation: `hooks/recommend-plugins.sh`.
- Hook fixtures/tests: `hooks/test_recommend_plugins.sh`.
- Companion plugin recommendation data: `hooks/recommendations/*.json`.

Recent checks showed:

- `claude plugin validate .` passes with one warning.
- The warning is that `CLAUDE.md` at plugin root is not loaded as plugin context
  by Claude; plugin context should live in skills.
- Repository JSON validates with `jq`.
- Shell syntax validates with `bash -n`.
- `hooks/test_recommend_plugins.sh` passes with `42 passed, 0 failed`.

Known repo issues to address while doing this work:

- `.claude-plugin/plugin.json` has a misspelled lifecycle keyword.
- `README.md` and `hooks/recommendations/very-good-ai-flutter-plugin.json`
  reference different marketplace repo names.
- `.release-please-config.json` references `.claude-plugin/marketplace.json`,
  but that file is not present.

## Codex Compatibility Constraints

The local Codex plugin validator expects this structure:

```text
<plugin-root>/
  .codex-plugin/
    plugin.json
  skills/
    <skill-name>/
      SKILL.md
```

The Codex manifest accepts only these top-level fields:

- `id`
- `name`
- `version`
- `description`
- `skills`
- `apps`
- `mcpServers`
- `interface`
- `author`
- `homepage`
- `repository`
- `license`
- `keywords`

The Codex manifest must not include unsupported fields such as `hooks`.

If present, these manifest path fields must resolve exactly as follows:

- `skills`: `skills`
- `apps`: `.app.json`
- `mcpServers`: `.mcp.json`

Codex requires an `interface` object with:

- `displayName`
- `shortDescription`
- `longDescription`
- `developerName`
- `category`
- `capabilities`
- `defaultPrompt` or `default_prompt`

Optional interface URL fields must be absolute `https://` URLs:

- `websiteURL`
- `privacyPolicyURL`
- `termsOfServiceURL`

Optional color fields must use `#RRGGBB`.

For skills:

- Each `skills/<name>/SKILL.md` must exist.
- Each `SKILL.md` must start with YAML frontmatter.
- Each skill frontmatter must include non-empty `name` and `description`.
- If `disable-model-invocation` or `disable_model_invocation` is present, it
  must be absent or `false`.

Important immediate blocker:

- `skills/create-pr/SKILL.md` currently has `disable-model-invocation: true`.
- `skills/rebase/SKILL.md` currently has `disable-model-invocation: true`.
- A same-root Codex plugin will fail validation until those fields are removed,
  changed to `false`, or isolated into a Codex-specific skill copy.

## Recommended Packaging Strategy

Use a dual-manifest, single-repository strategy first:

```text
vgv-wingspan/
  .claude-plugin/
    plugin.json
  .codex-plugin/
    plugin.json
  skills/
  agents/
  hooks/
  README.md
```

This keeps the existing source tree simple and lets both plugin systems read the
same skills where possible.

However, this strategy is only acceptable if removing or changing
Claude-specific skill frontmatter does not break Claude behavior. The two known
fields to decide on are:

- `disable-model-invocation: true` in `create-pr`.
- `disable-model-invocation: true` in `rebase`.

If those fields are required for Claude behavior, use a generated Codex package
instead:

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

The generated package can contain Codex-safe copies of the skills while the
source tree preserves Claude-specific behavior. This is more work but avoids
cross-runtime compromises.

Decision rule:

- Prefer same-root dual manifest if all skills pass Codex validation after
  harmless frontmatter cleanup.
- Prefer generated Codex package if Claude requires metadata that Codex rejects
  or if Codex needs substantially different skill instructions.

## Detailed Work Plan

### Phase 0: Establish Baseline

1. Confirm current branch and worktree state.

   ```bash
   git status --short
   ```

2. Re-run the current Claude validation baseline.

   ```bash
   claude plugin validate .
   ```

3. Re-run repo JSON validation.

   ```bash
   find . -name '*.json' -not -path './node_modules/*' -print0 | xargs -0 -n1 jq empty
   ```

4. Re-run hook tests.

   ```bash
   bash hooks/test_recommend_plugins.sh
   ```

5. Re-run shell syntax checks.

   ```bash
   for f in skills/shared/scripts/*.sh hooks/*.sh; do bash -n "$f" || exit 1; done
   ```

6. Save the output summary in the PR description when this work is implemented.

Acceptance criteria:

- Baseline failures are understood before Codex changes begin.
- Existing Claude behavior is not accidentally broken during the Codex port.

### Phase 1: Create the Codex Manifest

1. Add `.codex-plugin/plugin.json`.

2. Use this draft as the starting point:

   ```json
   {
      "id": "vgv-wingspan",
      "name": "vgv-wingspan",
      "version": "0.0.2",
      "description": "VGV Wingspan - AI-native workflows following Very Good Ventures best practices.",
      "skills": "skills",
      "author": {
         "name": "Very Good Ventures",
         "url": "https://verygood.ventures"
      },
      "homepage": "https://github.com/VeryGoodOpenSource/vgv-wingspan",
      "repository": "https://github.com/VeryGoodOpenSource/vgv-wingspan",
      "license": "MIT",
      "keywords": [
         "software engineering",
         "workflow",
         "best practices",
         "flow automation",
         "code generation",
         "planning",
         "ai assisted engineering",
         "sdlc",
         "software development lifecycle"
      ],
      "interface": {
         "displayName": "VGV Wingspan",
         "shortDescription": "AI-native engineering workflows for brainstorming, planning, building, reviewing, and shipping software.",
         "longDescription": "VGV Wingspan provides structured software delivery workflows based on Very Good Ventures engineering practices. It helps teams move from idea exploration to implementation planning, code changes, quality review, pull request preparation, and post-incident debriefs.",
         "developerName": "Very Good Ventures",
         "category": "Productivity",
         "capabilities": [
            "Brainstorm feature requirements and solution approaches",
            "Create detailed implementation plans",
            "Execute plans with validation and review",
            "Review code for quality, architecture, and test coverage",
            "Prepare commits and pull requests",
            "Guide emergency hotfixes and post-incident debriefs"
         ],
         "websiteURL": "https://github.com/VeryGoodOpenSource/vgv-wingspan",
         "brandColor": "#006BFF",
         "defaultPrompt": "Use Wingspan when the user asks to brainstorm, plan, build, review, hotfix, create a branch, create a commit, create a pull request, rebase, refine an approach, or debrief an incident."
      }
   }
   ```

3. Do not add `hooks` to the Codex manifest.

4. Do not add `apps` or `mcpServers` unless `.app.json` or `.mcp.json` is
   created and validated.

5. Keep the version aligned with `.claude-plugin/plugin.json` for the first
   pass.

Acceptance criteria:

- `.codex-plugin/plugin.json` exists.
- It uses only fields accepted by Codex validation.
- It has no `[TODO: ...]` placeholders.
- It uses strict semver.

### Phase 2: Make Skills Codex-Valid

1. Run the Codex validator against the repo root.

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

2. Fix the known immediate validation blockers:

   - In `skills/create-pr/SKILL.md`, remove `disable-model-invocation: true` or
     change it to `false`.
   - In `skills/rebase/SKILL.md`, remove `disable-model-invocation: true` or
     change it to `false`.

3. Decide whether the same files should remain shared by Claude and Codex.

   Use this decision table:

   | Question                                                                                                                                 | If yes                                                | If no                                                                        |
   | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------- |
   | Does Claude still behave correctly without `disable-model-invocation: true`?                                                             | Keep one shared `skills/` tree.                       | Create a Codex-specific generated package.                                   |
   | Does Codex tolerate Claude-oriented frontmatter such as `user-invocable`, `argument-hint`, `allowed-tools`, `when_to_use`, and `effort`? | Leave the fields unless runtime tests show confusion. | Strip them from a Codex-specific copy.                                       |
   | Does Codex expand `$ARGUMENTS` in skill bodies?                                                                                          | Keep the current skill text.                          | Rewrite instructions to refer to the user's request instead of `$ARGUMENTS`. |

4. Audit every skill for Claude-only assumptions.

   Check for:

   - Slash-command-only language.
   - `$ARGUMENTS` behavior.
   - `@agent-name` references.
   - `Task` tool assumptions.
   - Claude-specific tool names such as `Read`, `Glob`, `Grep`, and `Bash`.
   - Claude-only hook or plugin install commands.
   - Instructions to use `/clear`.

5. For each skill, classify the required change:

   | Skill                   | Expected Codex action                                                                    |
   | ----------------------- | ---------------------------------------------------------------------------------------- |
   | `brainstorm`            | Keep core workflow. Verify argument handling and `/clear` handoff text.                  |
   | `plan`                  | Keep core workflow. Replace Claude-specific agent invocation syntax if needed.           |
   | `build`                 | Keep core workflow. Verify PR creation delegation and review cleanup instructions.       |
   | `review`                | Rewrite agent orchestration instructions if Codex cannot invoke top-level `agents/*.md`. |
   | `hotfix`                | Keep workflow. Validate review step and temporary docs cleanup.                          |
   | `create`                | Rewrite companion plugin discovery if Codex marketplace commands differ.                 |
   | `create-branch`         | Keep workflow. Validate git command assumptions.                                         |
   | `create-commit`         | Keep workflow. Validate staging safety instructions.                                     |
   | `create-pr`             | Remove or adapt `disable-model-invocation`. Verify GitHub/GitLab CLI assumptions.        |
   | `rebase`                | Remove or adapt `disable-model-invocation`. Verify git command assumptions.              |
   | `refine-approach`       | Keep workflow. Verify docs discovery paths.                                              |
   | `plan-technical-review` | Rewrite `@agent` references if needed.                                                   |
   | `debrief`               | Keep workflow.                                                                           |
   | `elements-of-style`     | Keep workflow.                                                                           |

6. Re-run validation after every meaningful skill metadata change.

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

Acceptance criteria:

- The Codex validator passes.
- The skill list exposed to Codex matches the expected core workflows.
- Any Claude-specific behavior either still works or is isolated from the Codex
  package.

### Phase 3: Port Plugin-Level Context

Codex will not automatically load Claude's root `CLAUDE.md` as plugin context.
The current Claude validator warns about this too.

1. Split `CLAUDE.md` content into reusable references:

   ```text
   skills/shared/references/wingspan-philosophy.md
   skills/shared/references/workflow-conventions.md
   skills/shared/references/output-directories.md
   skills/shared/references/quality-standards.md
   ```

2. Update the relevant skills to explicitly reference those files:

   - `brainstorm`
   - `plan`
   - `build`
   - `review`
   - `hotfix`
   - `create-pr`
   - `debrief`

3. Keep `CLAUDE.md` as a convenience document for Claude users, but treat the
   shared references as the source of truth for plugin behavior.

4. Add a short note to `CLAUDE.md` pointing maintainers to the shared references
   to avoid drift.

Acceptance criteria:

- Core Wingspan philosophy and workflow rules are available through skills, not
  only `CLAUDE.md`.
- Claude and Codex instructions do not drift across separate documents.

### Phase 4: Convert or Replace Claude-Style Agents

The repo currently has top-level Claude-style agents under `agents/**/*.md`. The
Codex plugin validator does not validate or expose these top-level agents as
part of the plugin contract.

1. Inventory agent usage in skills.

   Search for:

   ```bash
   rg -n '@[a-z0-9-]+-agent|Task|agent' skills agents
   ```

2. Map each agent to a Codex-compatible representation.

   | Current agent                   | Current role                | Codex-compatible path                                                                             |
   | ------------------------------- | --------------------------- | ------------------------------------------------------------------------------------------------- |
   | `official-docs-research-agent`  | Research official docs      | Convert to a shared reference used by `plan`, or a separate skill if direct invocation is useful. |
   | `best-practices-research-agent` | Research best practices     | Convert to a shared reference used by `plan`.                                                     |
   | `plan-splitting-agent`          | Assess large plans          | Convert to reference used by `plan-technical-review`.                                             |
   | `user-flow-analysis-agent`      | Find requirements gaps      | Convert to reference used by `brainstorm`, `plan`, or `plan-technical-review`.                    |
   | `architecture-review-agent`     | Review architecture         | Convert to reference used by `review`, `build`, and `hotfix`.                                     |
   | `test-quality-review-agent`     | Review tests                | Convert to reference used by `review`, `build`, and `hotfix`.                                     |
   | `pr-readiness-review-agent`     | Check PR readiness          | Convert to reference used by `create-pr` and `build`.                                             |
   | `vgv-review-agent`              | Broad VGV code review       | Convert to reference used by `review`, `build`, and `hotfix`.                                     |
   | `codebase-review-agent`         | Discover codebase patterns  | Convert to reference used by `plan` and `review`.                                                 |
   | `code-simplicity-review-agent`  | YAGNI and simplicity review | Convert to reference used by `review`, `build`, and `plan-technical-review`.                      |

3. Prefer shared references first.

   Example target layout:

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

4. Update orchestrating skills to describe the review passes directly instead of
   relying on `@agent-name` syntax.

5. If Codex supports plugin-provided agent manifests in the future, add them
   later as a separate enhancement rather than blocking the first compatibility
   pass.

Acceptance criteria:

- `review`, `build`, `hotfix`, `plan`, and `plan-technical-review` still have
  access to the same review and research criteria.
- No core workflow depends exclusively on top-level Claude agent loading.
- Claude can continue using `agents/**/*.md` if those files remain useful.

### Phase 5: Handle Hooks and Companion Plugin Recommendations

The current hook system is Claude-specific:

- `hooks/hooks.json` declares a `PreToolUse` hook.
- The matcher references Claude tools: `Read|Glob|Grep`.
- The command uses `${CLAUDE_PLUGIN_ROOT}`.
- The output schema uses `hookSpecificOutput.hookEventName` and
  `additionalContext`.

Codex manifest validation does not accept a `hooks` field. The first
Codex-compatible version should not claim active hook support unless Codex has a
matching hook contract.

1. Keep `hooks/recommend-plugins.sh` as a script asset for now.

2. Create a Codex compatibility note in the hook file or README:

   - Claude automatically runs this via `hooks/hooks.json`.
   - Codex compatibility is pending a confirmed Codex hook event contract.
   - The recommendation data files remain useful and can be consumed by a Codex
     skill or future hook.

3. Add a manual Codex skill path for companion plugin recommendations if
   automatic hooks are not available.

   Candidate skill:

   ```text
   skills/recommend-companion-plugins/SKILL.md
   ```

   Purpose:

   - Read `hooks/recommendations/*.json`.
   - Detect project type.
   - Recommend relevant Codex-compatible companion plugins.
   - Avoid depending on Claude hook events.

4. If Codex hook support is confirmed, implement a Codex-specific hook adapter
   instead of changing the Claude hook in place.

   Candidate layout:

   ```text
   hooks/codex/
     hooks.json
     recommend-plugins.sh
   hooks/claude/
     hooks.json
     recommend-plugins.sh
   ```

5. Make the recommendation script runtime-neutral where practical:

   - Replace hard dependency on `${CLAUDE_PLUGIN_ROOT}` with fallback root
     detection.
   - Keep JSON recommendation files runtime-neutral.
   - Make output formatting runtime-specific at the boundary only.

6. Preserve and extend tests.

   Current test:

   ```bash
   bash hooks/test_recommend_plugins.sh
   ```

   Add tests for:

   - Missing `jq`.
   - Invalid recommendation JSON.
   - Plugin names that are substrings of other plugin names.
   - Multiple marketplace names.
   - Runtime-neutral root detection.

Acceptance criteria:

- Codex compatibility does not depend on an unvalidated Claude hook schema.
- Companion recommendation data remains reusable.
- Claude hook behavior remains covered by tests.

### Phase 6: Add Codex Marketplace Development Flow

For local development, Codex can use the personal marketplace file:

```text
~/.agents/plugins/marketplace.json
```

1. Decide whether this repo should include a repo-local marketplace file.

   Recommended first pass:

   - Do not commit a repo-local Codex marketplace file.
   - Document the personal marketplace flow instead.
   - Only create or update `~/.agents/plugins/marketplace.json` when explicitly
     installing locally.

2. Add Codex install documentation to `README.md`.

   Include:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

   For local marketplace-backed install, document the generated marketplace
   entry shape:

   ```json
   {
      "name": "vgv-wingspan",
      "source": {
         "source": "local",
         "path": "./plugins/vgv-wingspan"
      },
      "policy": {
         "installation": "AVAILABLE",
         "authentication": "ON_INSTALL"
      },
      "category": "Productivity"
   }
   ```

3. For local iteration, use the Codex cachebuster helper:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/update_plugin_cachebuster.py .
   ```

4. Read the personal marketplace name:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/read_marketplace_name.py
   ```

5. Reinstall from the marketplace name:

   ```bash
   codex plugin add vgv-wingspan@<marketplace-name>
   ```

6. Tell testers to start a new Codex thread after reinstalling so Codex picks up
   new skills and tools.

Acceptance criteria:

- Codex installation is documented separately from Claude installation.
- Local development does not require hand-editing marketplace files unless
  explicitly chosen.
- Reinstall behavior is repeatable.

### Phase 7: Runtime Smoke Tests in Codex

After validation passes and the plugin is locally installable, run practical
tests in a new Codex thread.

#### Local Testing Strategy

Yes, Codex compatibility can be tested locally before publishing anything. The
local testing strategy depends on the packaging decision:

- If Codex compatibility is added in the repo root, validate and install the
  repo root.
- If Codex compatibility is generated separately to avoid changing Claude
  behavior, validate and install the generated Codex package, for example
  `dist/codex/vgv-wingspan`.

The safer first implementation is the generated-package path because it lets us
adapt Codex metadata and skill frontmatter without touching the Claude-facing
source files.

Recommended local testing flow:

1. Build or prepare the Codex-compatible plugin target.

   Same-root target:

   ```text
   .
   ```

   Generated-package target:

   ```text
   dist/codex/vgv-wingspan
   ```

2. Validate the Codex plugin target.

   Same-root target:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

   Generated-package target:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py dist/codex/vgv-wingspan
   ```

3. Validate that Claude behavior still passes from the repo root.

   ```bash
   claude plugin validate .
   ```

   This check matters even if the Codex package is generated separately, because
   the source repo must remain a working Claude plugin.

4. Run existing repo-level checks.

   ```bash
   find . -name '*.json' -not -path './node_modules/*' -print0 | xargs -0 -n1 jq empty
   bash hooks/test_recommend_plugins.sh
   for f in skills/shared/scripts/*.sh hooks/*.sh; do bash -n "$f" || exit 1; done
   ```

5. Install the Codex-compatible plugin locally.

   Preferred local development approach:

   - Use the personal Codex marketplace at `~/.agents/plugins/marketplace.json`.
   - Point its plugin entry at the local Codex-compatible package.
   - Do not publish or add a public marketplace during local testing.

   If using the standard personal marketplace flow, read the marketplace name:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/read_marketplace_name.py
   ```

   Then install:

   ```bash
   codex plugin add vgv-wingspan@<marketplace-name>
   ```

6. Start a new Codex thread.

   Codex loads plugin skills and tools at thread start. After installing or
   reinstalling the plugin, use a new thread for smoke testing.

7. Reinstall after local edits.

   Update the Codex plugin version cachebuster:

   Same-root target:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/update_plugin_cachebuster.py .
   ```

   Generated-package target:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/update_plugin_cachebuster.py dist/codex/vgv-wingspan
   ```

   Read the marketplace name again if needed:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/read_marketplace_name.py
   ```

   Reinstall:

   ```bash
   codex plugin add vgv-wingspan@<marketplace-name>
   ```

   Then start another new Codex thread.

8. Verify the installed plugin appears in Codex.

   ```bash
   codex plugin list
   ```

   Confirm that the listed plugin source points to the local package being
   tested. If it points to a different marketplace or remote source, stop and
   fix the marketplace entry before continuing.

9. Run smoke prompts in the new Codex thread.

   Minimum smoke prompts:

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

10. Record results in the PR.

Include:

- Codex validator result.
- Claude validator result.
- Hook test result.
- Which local package was installed.
- Which marketplace name was used.
- Whether a new thread was used after install.
- Smoke prompt results.
- Any unsupported Codex behavior and the fallback used.

#### Local Testing Guardrails

- Do not modify shared Claude-facing skill metadata just to make Codex
  validation pass unless Claude behavior has been re-tested.
- If Codex requires metadata changes that affect Claude behavior, use a
  generated Codex package.
- Do not add a `hooks` field to `.codex-plugin/plugin.json`.
- Do not assume Claude `hooks/hooks.json` runs in Codex.
- Do not assume top-level Claude agents under `agents/**/*.md` are available in
  Codex.
- Do not hand-edit global Codex config when the personal marketplace flow can be
  used.
- Always test Codex in a new thread after install or reinstall.
- Always keep `claude plugin validate .` in the local test checklist.

Test matrix:

| Scenario      | Prompt                                                          | Expected result                                                                                     |
| ------------- | --------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Brainstorm    | `Use Wingspan to brainstorm adding authentication to this app.` | Codex activates or follows the brainstorm workflow and produces a `docs/brainstorm/` artifact plan. |
| Plan          | `Use Wingspan to plan the authentication feature.`              | Codex creates a structured implementation plan under `docs/plan/`.                                  |
| Review        | `Use Wingspan to review this repo.`                             | Codex performs quality review without relying on unavailable Claude agents.                         |
| Hotfix        | `Use Wingspan hotfix flow for this failing test.`               | Codex follows minimal-fix workflow with validation and review.                                      |
| Create commit | `Use Wingspan to create a conventional commit.`                 | Codex stages only appropriate files and proposes a conventional commit.                             |
| Rebase        | `Use Wingspan to rebase this branch.`                           | Codex validates branch state before running git operations.                                         |
| Create PR     | `Use Wingspan to create a PR.`                                  | Codex validates checks and prepares PR content without Claude-only command assumptions.             |

For each test, record:

- Whether the expected skill triggered.
- Whether the instructions were understandable in Codex.
- Whether any Claude-only syntax leaked into the response.
- Whether generated artifacts used the expected directories.
- Whether tool calls matched Codex's available tools.

Acceptance criteria:

- All core workflows can be invoked by natural language.
- No workflow blocks on Claude-only plugin behavior.
- Any unsupported feature has a documented fallback.

### Phase 8: Documentation Updates

Update `README.md` with a new `Codex Installation` section.

Recommended structure:

```markdown
## Installation

### Claude Code

...

### Codex

...
```

Document:

- Codex support status.
- Local validation command.
- Local install command.
- Reinstall/cachebuster flow.
- New thread requirement after reinstall.
- Any unsupported or partially supported features.

Update `CONTRIBUTING.md` with:

- How to validate Claude compatibility.
- How to validate Codex compatibility.
- How to add a new skill without breaking either runtime.
- How to update companion plugin recommendations.

Update `CHANGELOG.md` when Codex compatibility lands.

Acceptance criteria:

- Users can install and test the Codex-compatible plugin without reading
  implementation files.
- Contributors know which validation commands to run.

### Phase 9: CI and Release Automation

1. Add a Codex validation check to CI if the repo has GitHub Actions.

   Candidate command:

   ```bash
   python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
   ```

   If CI cannot rely on local Codex skill scripts, vendor a minimal validation
   script or document manual validation.

2. Update release automation.

   Current `.release-please-config.json` updates:

   - `.claude-plugin/plugin.json`
   - `.claude-plugin/marketplace.json`

   Problems:

   - `.claude-plugin/marketplace.json` is not present.
   - `.codex-plugin/plugin.json` will also need version updates.

3. Proposed release config changes:

   - Keep `.claude-plugin/plugin.json` version update.
   - Add `.codex-plugin/plugin.json` version update.
   - Remove or add the missing `.claude-plugin/marketplace.json` intentionally.
   - If a Codex marketplace file is added later, update it intentionally with
     the correct JSON paths.

4. Fix the manifest typo:

   - Change the misspelled lifecycle keyword to `software development lifecycle`.

5. Reconcile marketplace repo names:

   - Pick one canonical Claude marketplace repo name.
   - Update `README.md`.
   - Update `hooks/recommendations/very-good-ai-flutter-plugin.json` if needed.

Acceptance criteria:

- Releases update both Claude and Codex manifests.
- Release automation does not reference missing files.
- Docs and recommendation metadata point to the same marketplace naming scheme.

### Phase 10: Compatibility Policy for Future Changes

Add a maintainer checklist:

```markdown
Before merging plugin changes:

- [ ] `claude plugin validate .` passes or known warnings are documented.
- [ ] `python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .`
      passes.
- [ ] `bash hooks/test_recommend_plugins.sh` passes.
- [ ] JSON files validate with `jq`.
- [ ] New skills include `name` and `description`.
- [ ] New skills do not use `disable-model-invocation: true` in shared skill
      files.
- [ ] Claude-only instructions are isolated or have Codex-safe fallbacks.
- [ ] README install instructions are still accurate.
```

Acceptance criteria:

- Future maintainers have a clear compatibility contract.
- New features do not silently regress one runtime.

## Implementation Order

Recommended order of actual code changes:

1. Fix low-risk metadata issues:
   - Manifest typo.
   - Marketplace naming mismatch.
   - Release-please missing marketplace reference.

2. Add `.codex-plugin/plugin.json`.

3. Run Codex validator and fix required schema issues.

4. Resolve `disable-model-invocation: true` in shared skills or choose generated
   Codex package strategy.

5. Move shared `CLAUDE.md` behavior into skill-accessible shared references.

6. Convert agent-dependent skill instructions to Codex-safe references.

7. Add Codex install docs.

8. Add CI/manual validation checklist.

9. Perform Codex runtime smoke tests.

10. Update changelog and release notes.

## Risk Register

| Risk                                                               | Impact                                                          | Mitigation                                                                                           |
| ------------------------------------------------------------------ | --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Codex rejects shared skill metadata that Claude uses.              | Same-root dual compatibility fails.                             | Use generated Codex package with cleaned skill copies.                                               |
| Removing `disable-model-invocation: true` changes Claude behavior. | Claude command behavior may regress.                            | Test Claude workflows or isolate Codex copies.                                                       |
| Top-level Claude agents are not available in Codex.                | Review/build/plan workflows lose depth.                         | Convert agents into shared references consumed by skills.                                            |
| Claude hook system has no Codex equivalent.                        | Automatic companion plugin recommendations do not run in Codex. | Provide manual recommendation skill and keep future hook adapter separate.                           |
| Marketplace docs diverge.                                          | Users install from wrong source.                                | Document Claude and Codex installation separately and validate commands before release.              |
| Release automation references missing files.                       | Release PR fails.                                               | Fix `.release-please-config.json` before adding Codex manifest version management.                   |
| Validator script path is local to developer machines.              | CI cannot run validation directly.                              | Vendor a minimal validator or document manual validation until an official CI-safe validator exists. |

## Acceptance Criteria for Codex Compatibility

The work is done when all of these are true:

- `.codex-plugin/plugin.json` exists and passes Codex validation.
- `python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .`
  passes.
- `claude plugin validate .` still passes, or any warning is documented and
  accepted.
- Core Wingspan skills are available in Codex.
- `create-pr` and `rebase` no longer block Codex validation.
- Codex workflows do not depend on top-level Claude agents.
- Codex workflows do not depend on Claude hook events.
- README includes Codex-specific install and local iteration instructions.
- Release automation updates `.codex-plugin/plugin.json`.
- Hook tests still pass.
- A new Codex thread can invoke at least `brainstorm`, `plan`, `review`, and
  `build` workflows successfully.

## Open Questions

1. Should the first Codex version preserve the exact same skill names as Claude
   slash commands, or should some workflows be renamed for natural-language
   Codex usage?
2. Is `disable-model-invocation: true` required for Claude's `create-pr` and
   `rebase` behavior, or can those fields be safely removed?
3. Should Codex support be same-root or generated under
   `dist/codex/vgv-wingspan`?
4. Should companion plugin recommendations become a manual Codex skill until
   Codex hook support is confirmed?
5. Should top-level Claude agents remain in the repo indefinitely, or should
   their content be migrated entirely into shared skill references?
6. Should the typo in this file path be kept for continuity or corrected before
   linking it from README/CONTRIBUTING?

## Suggested First PR Scope

Keep the first PR small enough to review safely:

- Add `.codex-plugin/plugin.json`.
- Fix `disable-model-invocation` validation blockers or choose generated package
  strategy.
- Add Codex validation instructions.
- Fix release-please references for `.codex-plugin/plugin.json`.
- Do not port hooks yet.
- Do not remove top-level agents yet.

Suggested first PR title:

```text
feat: add Codex plugin compatibility manifest
```

Suggested follow-up PRs:

1. `refactor: move Wingspan context into shared skill references`
2. `refactor: make review agents available to Codex workflows`
3. `feat: add Codex companion plugin recommendation flow`
4. `ci: validate Claude and Codex plugin manifests`
