# Architecture Review

Use this to validate layer separation, dependency direction, and integration
with established project structure.

Check:

- Presentation, domain, data, infrastructure, and shared layers remain
  separated according to the project convention.
- Dependencies point inward or follow the local architecture.
- New abstractions have a current need and do not bypass existing boundaries.
- State management, dependency injection, repositories, and service boundaries
  match nearby examples.
- Cross-cutting concerns such as errors, logging, caching, and configuration are
  placed consistently.
