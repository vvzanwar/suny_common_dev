---
name: platform-apex-test-generate
description: "Use to generate and validate Apex test classes with TestDataFactory patterns, bulk testing (251+ records), mocking, assertions, and disciplined test-fix loops. Use when creating Apex test classes (for triggers, services, controllers, batch jobs, queueables, and callouts), improving coverage, debugging or fixing failing Apex tests, or running test/coverage analysis. Triggers on *Test.cls files, sf apex run test, coverage reports. Do NOT trigger for production Apex (use platform-apex-generate) or Jest/LWC tests."
metadata:
  version: "1.1"
  domains: ["Platform"]
  minApiVersion: "66.0"
  relatedSkills:
    - "platform-apex-generate"
  cliTools:
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# Generating Apex Tests

Generate production-ready Apex test classes and run disciplined test-fix loops with coverage analysis.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md, test-class-template.cls, test-data-factory-template.cls`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `assertion-patterns.md, async-testing.md, mocking-patterns.md, patterns-and-examples.md, test-data-factory.md`

---

## Core Principles

1. **One behavior per method** — each test method validates a single scenario. Separate positive, negative, and bulk tests. NEVER combine related-but-distinct inputs (e.g., null and empty) in one method — create `_NullInput_` and `_EmptyInput_` as separate test methods
2. **Bulkify tests** — test with 251+ records to cross the 200-record trigger batch boundary. **Batch Apex exception:** in test context only one `execute()` invocation runs, so set `batchSize >= testRecordCount`. See [examples/async-testing.md](examples/async-testing.md)
3. **Isolate test data** — every `@TestSetup` must delegate record creation to a `TestDataFactory` class. If none exists, create one first. Never build record lists inline in `@TestSetup`. Never rely on org data (`SeeAllData=false`) or hardcoded IDs. For duplicate rule handling, see [examples/test-data-factory.md](examples/test-data-factory.md)
4. **Assert meaningfully** — use exact expected values computed from test data setup. NEVER use range assertions or approximate counts when the value is deterministic. Always include failure messages. See [examples/assertion-patterns.md](examples/assertion-patterns.md)
5. **Use `Assert` class only** — `Assert.areEqual`, `Assert.isTrue`, `Assert.fail`, etc. Never use legacy `System.assert`, `System.assertEquals`, or `System.assertNotEquals`
6. **Mock external boundaries** — use `HttpCalloutMock` for callouts, `Test.setFixedSearchResults` for SOSL, DML mock classes for database isolation. Design for testability via constructor injection. See [examples/mocking-patterns.md](examples/mocking-patterns.md)
7. **Test negative paths** — validate error handling and exception scenarios, not just happy paths
8. **Wrap with start/stop** — pair `Test.startTest()` with `Test.stopTest()` to reset governor limits and force async execution

## Test.startTest() / Test.stopTest()

Always wrap the code under test in `Test.startTest()` / `Test.stopTest()`:

- Resets governor limits so the test measures only the code under test
- Executes async operations synchronously (queueables, batch, future methods)
- Fires scheduled jobs immediately

## Test Code Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| SOQL/DML inside loops | Query once before the loop; use `Map<Id, SObject>` for lookups |
| Magic numbers in assertions | Derive expected values from setup constants |
| God test class (>500 lines) | Split into multiple test classes by behavior area |
| Long test methods (>30 lines) | Extract Given/When/Then into helper methods |
| Generic `Exception` catch | Catch the specific expected type (e.g., `DmlException`) |

## Workflow

### Step 1 — Gather Context

Before generating or fixing tests, identify:

- the target production class(es) under test
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## What to Test by Component

| Component | Key Test Scenarios |
|-----------|-------------------|
| Trigger | Bulk insert/update/delete, recursion guard, field change detection |
| Service | Valid/invalid inputs, bulk operations, exception handling |
| Controller | Page load, action methods, view state |
| Batch | start/execute/finish, scope matching (batch size >= record count), `Database.Stateful` tracking, error handling, chaining (separate methods — `finish()` calling `Database.executeBatch()` throws `UnexpectedException`) |
| Queueable | Chaining (only first job runs in tests), bulkification, error handling, callout mocks before `Test.startTest()` |
| Callout | Success response, error response, timeout |
| Selector | Valid/null/empty inputs, bulk (251+), field population, sort order, `WITH USER_MODE` via `System.runAs` |
| Scheduled | Direct execution via `execute(null)`, CRON registration via `CronTrigger` query |
| Platform Event | `Test.enableChangeDataCapture()`, `Test.getEventBus().deliver()`, verify subscriber side effects |

## Output Expectations

Deliverables per test class:
- `{ClassName}Test.cls` + `{ClassName}Test.cls-meta.xml` (match API version of class under test; default `66.0`)
- `TestDataFactory.cls` + `TestDataFactory.cls-meta.xml` (if not already present)

## Project Hooks (Schema & QA Gate)
1. **Pre-Creation Schema Hook**: Verify live org metadata before authoring or querying:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .agents/scripts/query-org.ps1 -Describe "<SObjectName>"
   ```
2. **Post-Creation QA Gate**: Validate AST guardrails, Prettier, and dry-run deployment:
   ```powershell

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
