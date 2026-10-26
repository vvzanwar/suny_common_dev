---
trigger: always_on
description: NCSIM Apex Testing Standards (90% class / 85% org coverage, TestDataFactory, 4 mandatory scenarios) and PR Checklist
---

# NCSIM Standard 06: Apex Testing Standards & Pull Request Checklist

## 1. Coverage & Assertions
- **Coverage Floor**: Minimum **90% line coverage per class** and **85% org-wide** (enforced on deployment).
- **Real Assertions**: Every `@IsTest` method must assert expected outcomes using `Assert.areEqual(expected, actual, 'why')`, `Assert.isTrue(condition, 'why')`, `Assert.isNotNull(...)`, or `Assert.fail('Expected AppException')` with a descriptive message. Coverage without assertions is rejected.

## 2. Test Data Factory & Isolation
- **`TestDataFactory` Only**: Never instantiate `new Account(...)` or `new Enrollment__c(...)` inline in test methods. Build all records via `TestDataFactory` methods that return **unsaved SObjects by default** (plus bulk list helpers) and insert once in `@TestSetup`.
- **Zero `SeeAllData=true`**: `@IsTest(SeeAllData=true)` is strictly forbidden.
- **Explicit Feature Switches & Mocks**: Set switches explicitly via `FeatureSwitch.set('<Switch_Name>', true/false)` and mock callouts via `Test.setMock(HttpCalloutMock.class, new <System>Mock())`.

## 3. Naming & 4 Mandatory Scenarios per Class
- **Test Class Name**: `<ClassUnderTest>Test` (e.g., `EnrollmentServiceTest`).
- **Test Method Name**: `should<Expectation>_when<Condition>` (e.g., `shouldConfirm200Enrollments_whenStatusChangesToConfirmed`).
- **4 Mandatory Scenarios**:
  1. **Positive single-record path**: Normal input produces the expected database state.
  2. **Bulk path (200 records)**: Runs cleanly through triggers and services well below governor limits.
  3. **Negative / validation / catch path**: Bad input throws `DmlException` or `AppException` (`Assert.fail` if no exception is thrown) and exercises `catch` / `Logger` blocks.
  4. **Persona / sharing path (`System.runAs`)**: Verifies access under the actual target user profile/permission set (`WITH USER_MODE`).

```apex
@IsTest
public class TestDataFactory {
    public static Contact makeStudent(String lastName) {
        return new Contact(FirstName = 'Test', LastName = lastName, Email = lastName.toLowerCase() + '@test.edu');
    }

    public static Enrollment__c makeEnrollment(Id studentId, Id courseId) {
        return new Enrollment__c(
            Student__c = studentId,
            Course__c  = courseId,
            Status__c  = EnrollmentDomain.STATUS_PENDING,
            Credits__c = 3
        );
    }

    public static List<Enrollment__c> makeEnrollments(Id studentId, Id courseId, Integer count) {
        List<Enrollment__c> listOut = new List<Enrollment__c>();
        for (Integer i = 0; i < count; i++) {
            listOut.add(makeEnrollment(studentId, courseId));
        }
        return listOut;
    }
}
```

## 4. Pull Request Checklist (All Must Pass Before Completion)
- [ ] One trigger on the object (all 7 contexts), logic in handler, handler has zero SOQL and zero DML
- [ ] New trigger or switchable feature includes its `Feature_Switch__mdt` record in the same deployment
- [ ] All SOQL is in a `*Selector` class with `FIELDS` constant and `WITH USER_MODE`
- [ ] Zero SOQL, DML, callout, or email inside loops; verified with a 200-record test
- [ ] Every Apex class explicitly declares a sharing keyword (`with sharing` / `inherited sharing` / justified `without sharing`)
- [ ] Errors are caught, buffered via `Logger.error`/`Logger.calloutError` + `Logger.flush()` in `finally`, and surfaced as user-actionable messages
- [ ] Zero `System.debug`, zero hardcoded IDs, zero hardcoded endpoints or keys
- [ ] Tests use `TestDataFactory`, `should<Expectation>_when<Condition>` naming, `Assert.*` with messages, cover positive/bulk/negative/`System.runAs` paths, and achieve >= 90% class coverage (>= 85% org-wide)
- [ ] All names match the NCSIM naming table with zero abbreviations
- [ ] LWC templates render loading/empty/error states, use SLDS tokens only, and have labelled, keyboard-reachable inputs
