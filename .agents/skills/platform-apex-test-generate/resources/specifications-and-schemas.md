# platform-apex-test-generate - Technical Specifications, Rules & Schemas

## Workflow

### Step 1 — Gather Context

Before generating or fixing tests, identify:

- the target production class(es) under test
- existing test classes, test data factories, and setup helpers
- desired test scope (single class, specific methods, suite, or local tests)
- coverage threshold (75% minimum for deploy, 90%+ recommended)
- org alias when running tests against an org

### Step 2 — Generate the Test Class

Apply the structure, naming conventions, and patterns from the asset templates and reference docs.

**MANDATORY — File Deliverables:** For every test class, create BOTH files:
1. `{ClassName}Test.cls` — the test class (use [resources/test-class-template.cls](resources/test-class-template.cls) as starting point)
2. `{ClassName}Test.cls-meta.xml` — the metadata file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

If no `TestDataFactory` exists in the project, create `TestDataFactory.cls` + `TestDataFactory.cls-meta.xml` using [resources/test-data-factory-template.cls](resources/test-data-factory-template.cls).

#### @TestSetup Example

```apex
@TestSetup
static void setupTestData() {
    List<Account> accounts = TestDataFactory.createAccounts(251, true);
}
```

#### Test Method Structure

Use Given/When/Then:

```apex
@isTest
static void shouldUpdateStatus_WhenValidInput() {
    // Given
    List<Account> accounts = [SELECT Id FROM Account];

    // When
    Test.startTest();
    MyService.processAccounts(accounts);
    Test.stopTest();

    // Then
    List<Account> updated = [SELECT Id, Status__c FROM Account];
    Assert.areEqual(251, updated.size(), 'All accounts should be processed');
}
```

#### Negative Test — Exception Pattern

Use try/catch with `Assert.fail` to verify expected exceptions:

```apex
@isTest
static void shouldThrowException_WhenInvalidInput() {
    // Given
    List<Account> emptyList = new List<Account>();

    // When/Then
    Test.startTest();
    try {
        MyService.processAccounts(emptyList);
        Assert.fail('Expected MyCustomException to be thrown');
    } catch (MyCustomException e) {
        Assert.isTrue(e.getMessage().contains('cannot be empty'),
            'Exception message should indicate empty input');
    }
    Test.stopTest();
}
```

#### Naming Convention

- `should[ExpectedResult]_When[Scenario]`: `shouldSendNotification_WhenOpportunityClosedWon`
- `[SubjectOrAction]_[Scenario]_[ExpectedResult]`: `AccountUpdate_ChangeName_Success`

### Step 3 — Run Tests

Start narrow when debugging; widen after the fix is stable.

```bash
# Single test class
sf apex run test --class-names MyServiceTest --result-format human --code-coverage --target-org <alias>

# Specific test methods
sf apex run test --tests MyServiceTest.shouldUpdateStatus_WhenValidInput --result-format human --target-org <alias>

# All local tests
sf apex run test --test-level RunLocalTests --result-format human --code-coverage --target-org <alias>
```

### Step 4 — Analyze Results

Focus on:

- failing methods — exception types and stack traces
- uncovered lines and weak coverage areas
- whether failures indicate bad test data, brittle assertions, or broken production logic
- when class metadata crosses from versions 66.0 and below to 67.0 and above, check explicit sharing, decide user/system mode per operation, grant required CRUD/FLS in test users or permission sets, and rerun affected tests

### Step 5 — Fix Loop

When tests fail, run a disciplined fix loop (max 3 iterations — stop and surface root cause if still failing):

1. Read the failing test class and the class under test
2. Identify root cause from error messages and stack traces
3. Apply fix — adjust test data or assertions for test-side issues; delegate production code issues to the `platform-apex-generate` skill
4. Rerun the focused test before broader regression
5. Repeat until all tests pass, iteration limit reached, or root cause requires design change

### Step 6 — Validate Coverage

| Level | Coverage | Purpose |
|-------|----------|---------|
| Production deploy | 75% minimum | Required by Salesforce |
| Recommended | 90%+ | Best practice target |
| Critical paths | 100% | Business-critical code |

Cover all paths: positive, negative/exception, bulk (251+ records), callout/async.

---

## Reference Files

Load on demand for detailed patterns:

| Reference | When to use |
|-----------|-------------|
| [examples/test-data-factory.md](examples/test-data-factory.md) | TestDataFactory patterns, field overrides, duplicate rule handling |
| [examples/assertion-patterns.md](examples/assertion-patterns.md) | Assertion best practices, anti-patterns, common pitfalls |
| [examples/mocking-patterns.md](examples/mocking-patterns.md) | HttpCalloutMock, DML mocking, StubProvider, SOSL, Email, Platform Events |
| [examples/async-testing.md](examples/async-testing.md) | Batch, Queueable, Future, Scheduled job testing |
