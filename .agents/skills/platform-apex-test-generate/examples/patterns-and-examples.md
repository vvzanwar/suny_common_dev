# platform-apex-test-generate - Reference Examples, Patterns & Troubleshooting

## Reference Code & Command Examples

### Example 1
```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

### Example 2
```apex
@TestSetup
static void setupTestData() {
    List<Account> accounts = TestDataFactory.createAccounts(251, true);
}
```

### Example 3
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

### Example 4
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

### Example 5
```bash
# Single test class
sf apex run test --class-names MyServiceTest --result-format human --code-coverage --target-org <alias>

# Specific test methods
sf apex run test --tests MyServiceTest.shouldUpdateStatus_WhenValidInput --result-format human --target-org <alias>

# All local tests
sf apex run test --test-level RunLocalTests --result-format human --code-coverage --target-org <alias>
```
