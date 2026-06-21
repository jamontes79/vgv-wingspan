# Workflow Conventions

Wingspan's main workflow moves through `brainstorm`, `plan`, `build`, and
`review`. Supporting workflows cover `hotfix`, `debrief`, branch creation,
commits, pull requests, rebases, and approach refinement.

Persist phase outputs under `docs/` so future phases can resume from a cold
start. When a user-invocable skill has a forward transition, present
"Clear context and [next step]" as the first handoff option. If selected, show
the clear-context handoff for the next step and stop.

When invoked by another skill, return control to the caller instead of offering
handoff choices.

Prefer natural-language task execution in Codex-compatible contexts. Treat
slash commands, `$ARGUMENTS`, and Claude-specific tool names as invocation
examples, not as the only way the workflow can run.
