---
trigger: always_on
description: Enterprise Salesforce 5-Layer Architecture, Class Responsibilities, SObject & Custom Metadata Invariants, Bulkification, Limits, Sharing, and Hook Integration (Cline)
---

# Enterprise Salesforce Standard 01: Architecture, Layering, Schema & Hook Protocol

Every object has one trigger, every piece of business logic has one service method, and every trigger or feature can be switched off per org from Custom Metadata without a deployment. Applies universally to Standard Objects, Custom Objects (`__c`), Custom Fields (`__c`), and Custom Metadata (`__mdt`).

## 1. Request Flow & Class Layering
Every request travels strictly top-down in the same order:
`Entry Point` -> `Service` -> `Domain` & `Selector` -> `Salesforce Data` (with stateless `Utility` classes alongside).

| Layer | Pattern | Sharing | Does | Never Does |
| :--- | :--- | :--- | :--- | :--- |
| **Trigger** | `<Object>Trigger` | N/A | Declares all 7 contexts (`before insert, before update, before delete, after insert, after update, after delete, after undelete`) and delegates via `new <Object>TriggerHandler().run();` | Any logic, SOQL, DML, or conditions |
| **Trigger Handler** | `<Object>TriggerHandler extends TriggerHandler` | `with sharing` | Overrides only needed virtual context methods (`beforeInsert`, `beforeUpdate`, `afterUpdate`, etc.), shapes `Trigger.new`/`Trigger.oldMap`, calls Domain in `before` and Service in `after` | SOQL, DML, business calculations, static `hasRun` flags |
| **LWC / Flow / REST Entry** | `<Component>Controller`, `@InvocableMethod`, `@RestResource` | `with sharing` | Converts parameters, calls **one** Service or Selector method, catches/logs errors via `Logger`, rethrows `AuraHandledException` | Business logic, inline SOQL, direct DML |
| **Service** | `<ObjectOrProcess>Service` | `with sharing` | Runs one piece of business logic from start to finish, queries via Selectors, applies Domain/Utils, performs **one consolidated DML** at the end, enqueues async jobs | Inline SOQL, assuming trigger context, SOQL/DML/callout in loops |
| **Domain** | `<Object>Domain` | `with sharing` | Record-level rules for one object (`applyDefaults(List<SObject>)`, `validate(List<SObject>, Map<Id, SObject>)`) using `addError(...)` | SOQL, DML, HTTP callouts |
| **Selector** | `<Object>Selector` | `with sharing` | Every SOQL query for one object using a `private static final String FIELDS` constant and `WITH USER_MODE` (or `WITH SYSTEM_MODE` with a comment explaining why) | Business rules, DML |
| **Utility** | `<Topic>Utils` | `inherited sharing` | Stateless helpers (date math, string formatting, type conversion) | SOQL, DML, object-specific logic |

## 2. Reference Layer Patterns

### Domain (`<Object>Domain.cls`)
```apex
public with sharing class EnrollmentDomain {
    public static final String STATUS_PENDING   = 'Pending';
    public static final String STATUS_CONFIRMED = 'Confirmed';

    public static void applyDefaults(List<Enrollment__c> records) {
        for (Enrollment__c rec : records) {
            if (String.isBlank(rec.Status__c)) {
                rec.Status__c = STATUS_PENDING;
            }
        }
    }

    public static void validate(List<Enrollment__c> records, Map<Id, Enrollment__c> oldMap) {
        for (Enrollment__c rec : records) {
            if (rec.Credits__c != null && rec.Credits__c < 0) {
                rec.Credits__c.addError('Credits cannot be negative.');
            }
        }
    }
}
```

### Selector (`<Object>Selector.cls`)
```apex
public with sharing class EnrollmentSelector {
    private static final String FIELDS = 'Id, Name, Student__c, Course__c, Status__c, Credits__c';

    public static List<Enrollment__c> selectByIds(Set<Id> ids) {
        if (ids == null || ids.isEmpty()) {
            return new List<Enrollment__c>();
        }
        return Database.query(
            'SELECT ' + FIELDS + ' FROM Enrollment__c WHERE Id IN :ids WITH USER_MODE'
        );
    }
}
```

### Service (`<ObjectOrProcess>Service.cls`)
```apex
public with sharing class EnrollmentService {
    public static void handleConfirmations(Set<Id> enrollmentIds) {
        if (enrollmentIds == null || enrollmentIds.isEmpty()) return;
        if (!FeatureSwitch.isEnabled('Enrollment_Confirmation')) return;

        List<Enrollment__c> enrollments = EnrollmentSelector.selectByIds(enrollmentIds);
        // Perform business logic in memory, then execute a single consolidated DML:
        update as user enrollments;
        System.enqueueJob(new EnrollmentConfirmationQueueable(enrollmentIds));
    }
}
```

## 3. Bulkification, Governor Limits, Sharing & Naming
- **Bulkification**: Zero SOQL, DML, callouts, or `Messaging.sendEmail` inside loops. Collect IDs into a `Set<Id>`, query once into a `Map<Id, SObject>`, loop in memory, and execute one DML at the end (using `Database.update(toUpdate, false)` + `Logger` when partial success is needed).
- **Sharing**: Every class explicitly declares `with sharing` (default for Services, Controllers, Selectors, Domains, TriggerHandlers), `inherited sharing` (Utilities), or `without sharing` (only with a justification comment on the smallest class that needs it).
- **Naming Conventions**:
  - Trigger: `<Object>Trigger` | Handler: `<Object>TriggerHandler` | Service: `<ObjectOrProcess>Service`
  - Domain: `<Object>Domain` | Selector: `<Object>Selector` | Utility: `<Topic>Utils`
  - LWC Controller: `<Component>Controller` | Integration: `<System>Service` | Async: `<Work>Queueable` / `<Work>Batch`
  - Test: `<ClassUnderTest>Test` | LWC folder: `camelCase` | Custom Field: `PascalCase_With_Underscores__c`
  - Methods: `camelCase` verbs | Booleans: `isActive`/`hasBalance`/`canEnroll` | Maps: `<value>By<Key>` | Constants: `UPPER_SNAKE_CASE` | Zero cryptic abbreviations (`enrl`, `stu`, `crs`).

## 4. Schema Integrity, Custom Objects & Custom Metadata Invariants
- **No Hallucinated Schema**: Never assume the existence, API name, or casing of standard SObjects, Custom Objects (`__c`), Custom Fields (`__c`), or Custom Metadata Types (`__mdt`). Always verify against the target org schema or local metadata.
- **Relationship Navigation**:
  - Child-to-Parent custom relationships traverse using `__r` (e.g., `Enrollment__r.Student__r.Name`, NOT `Enrollment__c.Student__c.Name`).
  - Parent-to-Child subqueries use the plural child relationship name (e.g., `(SELECT Id, Status__c FROM Enrollments__r)`).
- **Custom Metadata (`__mdt`) Invariants**:
  - Access custom metadata using cached instance methods (e.g., `Config__mdt.getInstance('Key')` or `getAll().values()`) for $O(1)$ zero-SOQL execution.
  - Custom metadata types are read-only at runtime; never perform DML against `__mdt` records in application logic.
- **Platform Events (`__e`)**:
  - Publish platform events using `EventBus.publish(events)` and check the returned `Database.SaveResult`.

## 5. Project Hook Protocol (Pre & Post Creation Guards)
- **Pre-Creation Schema Hook**: Before writing Apex classes referencing unfamiliar or custom schema, run the project schema describe script:
  - Cline: `powershell -ExecutionPolicy Bypass -File .cline/scripts/c-query-org.ps1 -Describe "<SObjectName>"`
- **Post-Creation Quality Gate Hook**: After generating or refactoring any `.cls` or `.trigger`, run the project verification gate:
  - Cline: `powershell -ExecutionPolicy Bypass -File .cline/scripts/c-run-qa-gate.ps1 -TargetFiles "<path_to_class>" -TestClasses "<TestClass>"`
  - The gate deterministically enforces AST guardrails (`c-sf-pre-write-guard.js`), Prettier formatting, dry-run deployment, and server-side test coverage (>=90% class, >=85% org).
