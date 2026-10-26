# platform-apex-test-run - Technical Specifications, Rules & Schemas

## High-Signal Rules

| Rule | Rationale |
|------|-----------|
| Default to `SeeAllData=false` | Ensures test isolation; prevents reliance on org-specific data |
| Every test must assert meaningful outcomes | Tests with no assertions prove nothing and give false confidence |
| Test bulk behavior with 251+ records | Triggers process in batches of 200; 251 records crosses the boundary |
| Use factories / `@TestSetup` when they improve clarity | Consistent data creation in one place; rolled back between test methods |
| Pair `Test.startTest()` with `Test.stopTest()` for async | Ensures async operations (queueable, future) complete before assertions |
| Do not hide flaky org dependencies inside tests | Prevents intermittent failures tied to org state |

---

---

## Reference File Index

| File | When to read |
|------|-------------|
| `examples/cli-commands.md` | All `sf apex run test` command flags, output formats, async execution, and coverage commands |
| `examples/test-patterns.md` | Test class templates — basic, bulk (251+), mock callout, and data factory patterns |
| `examples/testing-best-practices.md` | Core testing principles — AAA pattern, naming conventions, bulk, negative, and mock strategies |
| `examples/test-fix-loop.md` | Agentic test-fix loop implementation and failure analysis decision tree |
| `examples/mocking-patterns.md` | HttpCalloutMock, DML mocking, StubProvider, and selector mocking patterns |
| `examples/performance-optimization.md` | Techniques to reduce test execution time — DML mocking, SOQL mocking, loop optimizations |
| `resources/basic-test.cls` | Template: standard test class with `@TestSetup`, positive / negative / bulk / edge-case methods |
| `resources/bulk-test.cls` | Template: bulk test with 251+ records that crosses the 200-record trigger batch boundary |
| `resources/mock-callout-test.cls` | Template: HTTP callout mock using `HttpCalloutMock` |
| `resources/test-data-factory.cls` | Template: reusable `TestDataFactory` with create and insert helpers |
| `resources/dml-mock.cls` | Template: `IDML` interface + `DMLMock` implementation for database-free unit tests |
| `resources/stub-provider-example.cls` | Template: `StubProvider`-based dependency injection stub |
| `scripts/parse-test-results.py` | Post-tool hook — parses `sf apex run test` JSON output and formats failures for the auto-fix loop |

---
