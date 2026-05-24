# Official Docs Research

Use this when a plan needs official documentation, version-specific constraints,
API behavior, or implementation patterns.

Process:

1. Identify the framework, library, API, or package and the version used by the
   project.
2. For external APIs and services, check deprecation, sunset, and breaking
   change notices before recommending an approach.
3. Prioritize official documentation. Use project lock files and manifests to
   match the documented version to the installed version.
4. Supplement official docs with source examples, tests, changelogs, and
   reputable community examples only when official docs are incomplete.
5. Return a concise implementation guide with source links, version notes,
   common pitfalls, and project-specific recommendations.
