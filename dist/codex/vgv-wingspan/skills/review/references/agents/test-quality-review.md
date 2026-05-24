# Test Quality Review

Use this to verify that implementation is backed by meaningful tests.

Check:

- Every testable state management unit, repository/service, data model, utility,
  and UI component has appropriate tests.
- Tests use the project's established framework, wrappers, providers, mocks, and
  naming patterns.
- Success, failure, edge cases, and async state changes are covered.
- Assertions verify behavior rather than implementation details.
- Anti-patterns are absent: tautological assertions, no assertions, mocking the
  subject under test, over-verification, and copied production logic.
