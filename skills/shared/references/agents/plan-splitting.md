# Plan Splitting Review

Use this during technical plan review to decide whether a plan should be split
into multiple independently mergeable pull requests.

Assess:

- Estimated lines of changed code.
- Number of architectural layers touched.
- New files, packages, or modules.
- Whether work can be split without leaving the codebase broken.
- Whether the plan bundles unrelated outcomes.

Prefer no split when splitting would be awkward or tightly coupled. Recommend a
split only when it improves reviewability, reduces merge risk, and preserves a
working codebase after each PR.
