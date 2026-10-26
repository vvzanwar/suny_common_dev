# platform-apex-test-run - Reference Examples, Patterns & Troubleshooting

## Gotchas

| Issue | Resolution |
|-------|------------|
| Test passes locally but fails in CI org | Check for `SeeAllData=true` or undeclared dependencies on org-specific records |
| Coverage drops unexpectedly after refactor | Run focused class-level tests first, then widen to `RunLocalTests` to confirm |
| "Uncommitted work pending" error in callout test | DML and HTTP callouts cannot be mixed in the same test context without `Test.startTest()` wrapping |
| Mock not taking effect in test | Ensure `Test.setMock()` is called before the code that makes the callout |
| `@TestSetup` data missing in test method | `@TestSetup` data is committed per test method — re-query it; do not store in static variables |
|  API version 67.0 and higher without necessary access level checks | Check failing SOQL/DML stack traces for CRUD/FLS access errors, using System.runAs with an assigned permission set when user-mode behavior is intended, or documenting a justified `SYSTEM_MODE` path when system access is required |

---

---

## Score Guide

| Score | Meaning |
|---|---|
| 108+ | strong production-grade test confidence |
| 96–107 | good test suite with minor gaps |
| 84–95 | acceptable but strengthen coverage / assertions |
| < 84 | below standard; revise before relying on it |
