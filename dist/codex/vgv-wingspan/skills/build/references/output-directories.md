# Output Directories

Use these directories for Wingspan artifacts:

- `docs/brainstorm/` for brainstorm documents.
- `docs/plan/` for implementation plans.
- `docs/reviews/` for build review reports. This directory is ephemeral and
  can be cleaned by the build workflow.
- `docs/hotfix-review/` for hotfix review reports. This directory is ephemeral
  and can be cleaned by the hotfix workflow.
- `docs/code-review/` for standalone review reports. This directory is
  user-managed.
- `docs/debriefs/` for post-incident debrief documents.

Generated artifacts should be named with readable, date-aware slugs when the
skill does not define a stricter naming convention.
