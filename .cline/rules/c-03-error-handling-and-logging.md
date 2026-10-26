---
trigger: always_on
description: NCSIM Error Handling, Buffered Logger, Error_Log__c, Log_Event__e, and AppException rules
---

# NCSIM Standard 03: Error Handling & Logging (`Logger`, `Error_Log__c`, `Log_Event__e`, `AppException`)

## 1. Core Logging Rules
- **Zero `System.debug`** in committed code and **zero empty `catch` blocks**.
- Nobody inserts `Error_Log__c` directly; always buffer via `Logger.error(source, Exception)` or `Logger.calloutError(source, integrationName, statusCode, message)` and call `Logger.flush()` **once** in a `finally` block.
- **Surviving Rollbacks**: If a transaction will roll back (e.g., an unhandled exception in a trigger) and the log must survive, publish a Platform Event `Log_Event__e` (`PublishBehavior = PublishImmediately`) via `EventBus.publish(...)`.
- **Sensitive Data Redaction**: Never log passwords, tokens, SSNs, or payment details in `Error_Message__c` â€” log the record `Id` instead.

## 2. Exception Hierarchy & User-Facing Errors
- Define `public virtual class AppException extends Exception {}` (and domain subclasses such as `IntegrationException extends AppException`).
- **Expected business errors**: Throw `AppException` with a clear, user-safe message (`'This course is full. Please join the waitlist.'`). Controllers re-throw `e.getMessage()` directly inside `AuraHandledException`.
- **Unexpected platform errors**: Log via `Logger.error(source, e)` + `Logger.flush()` in `finally`, and throw `new AuraHandledException('Something went wrong. Please try again or contact support.')` so raw SOQL/stack traces never reach the UI.

```apex
public with sharing class EnrollmentController {
    @AuraEnabled
    public static void confirmEnrollment(Id enrollmentId) {
        try {
            EnrollmentService.handleConfirmations(new Set<Id>{ enrollmentId });
        } catch (AppException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            Logger.error('EnrollmentController.confirmEnrollment', e);
            throw new AuraHandledException('Something went wrong. Please try again or contact support.');
        } finally {
            Logger.flush();
        }
    }
}
```

## 3. `Logger` Reference Implementation
```apex
public inherited sharing class Logger {
    private static final List<Error_Log__c> buffer = new List<Error_Log__c>();

    public static void error(String source, Exception ex) {
        buffer.add(new Error_Log__c(
            Source__c        = source,
            Exception_Type__c= ex.getTypeName(),
            Error_Message__c = ex.getMessage().left(32768),
            Stack_Trace__c   = ex.getStackTraceString().left(32768),
            User__c          = UserInfo.getUserId()
        ));
    }

    public static void calloutError(String source, String integrationName, Integer statusCode, String responseBody) {
        buffer.add(new Error_Log__c(
            Source__c        = source,
            Integration__c   = integrationName,
            Status_Code__c   = statusCode,
            Error_Message__c = (responseBody != null ? responseBody.left(32768) : null),
            User__c          = UserInfo.getUserId()
        ));
    }

    public static void flush() {
        if (buffer.isEmpty()) return;
        List<Error_Log__c> toInsert = new List<Error_Log__c>(buffer);
        buffer.clear();
        Database.insert(toInsert, false);
    }
}
```
