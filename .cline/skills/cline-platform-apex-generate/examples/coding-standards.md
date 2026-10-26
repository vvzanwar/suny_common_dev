# Apex Coding Standards & Implementation Rules

This reference document outlines non-negotiable coding patterns, bulkification practices, naming standards, and security checks for Apex development.

---

## 1. Hard-Stop Constraints (Must Enforce)

| Constraint | Rationale |
|---|---|
| Place all SOQL outside loops | Avoid query governor limits (100 queries) |
| Place all DML outside loops | Avoid DML governor limits (150 statements) |
| Declare explicit sharing keyword on every class | Prevent unintended `without sharing` defaults and data exposure |
| Use Custom Metadata/Labels/describe calls instead of hardcoded IDs | Ensure portability across environments |
| Always handle exceptions (log, rethrow, or recover) | Prevent silent failures and lost transactions |
| Use bind variables for all dynamic SOQL with user input | Prevent SOQL injection vulnerabilities |
| Avoid `System.debug()` in main code paths | Debug statements consume CPU cycles even when logging is inactive |
| Never use `@future` methods in net-new code | Use Queueable with `System.Finalizer` for chaining and non-primitive payloads |

---

## 2. Bulkification & Governor Limits

- **Collections First**: All public methods accept and process collections; single-record overloads delegate to bulk methods.
- **Partial-Success DML**: In batch/bulk flows, prefer `Database.update(records, false)` and inspect `SaveResult` for errors.
- **ID-Based Lookups**: Use `new Map<Id, SObject>(recordList)` for efficient `O(1)` ID lookups.
- **Child-Parent Grouping**: Use `Map<Id, List<SObject>>` to group children by parent ID; construct the map in a single pass.
- **Deduplication**: Use `Set<Id>` for membership checks (`set.contains()` is `O(1)` vs `List.contains()` `O(N)`).
- **Subqueries**: Use relationship queries (`SELECT Id, (SELECT Id FROM Contacts) FROM Account`) to fetch parent + children in a single SOQL.
- **Delta DML**: Only update records whose fields actually changed (compare with `Trigger.oldMap` or in-memory state).

---

## 3. SOQL & Security Enforcement

- **CRUD/FLS Enforcement**: Use `WITH USER_MODE` for queries and `AccessLevel.USER_MODE` for `Database.*` operations.
- **Selective Queries**: Always filter on indexed fields (`Id`, `Name`, `OwnerId`, lookups, `ExternalId`).
- **No `SELECT *`**: Always explicitly name required fields in Selectors.
- **Custom Metadata Queries**: Avoid SOQL when reading `__mdt` records; use `{Type}__mdt.getAll().values()` or `.getInstance()`.
- **Sanitized Dynamic SOQL**: Always bind user inputs (`:searchTerm`) or escape single quotes (`String.escapeSingleQuotes`).

---

## 4. Error Handling & Null Safety

- **Guard Clauses**: Check for null/empty collections at method entry and return early or throw informative exceptions.
- **Null Safety Operators**: Use safe navigation (`?.`) and null coalescing (`??`) rather than nested ternary/null guards.
- **Specific Catch Blocks**: Catch specific exceptions (`DmlException`, `CalloutException`) before generic `Exception`.
- **Aura Exceptions**: For `@AuraEnabled` methods, catch internal exceptions and rethrow `new AuraHandledException('User-friendly message')`.

---

## 5. Naming Conventions & ApexDoc

| Pattern | Suffix / Prefix | Example |
|---|---|---|
| Service | `{SObject}Service` | `AccountService` |
| Selector | `{SObject}Selector` | `AccountSelector` |
| Domain | `{SObject}Domain` | `OpportunityDomain` |
| Batch | `{Descriptive}Batch` | `AccountDeduplicationBatch` |
| Queueable | `{Descriptive}Queueable` | `ExternalSyncQueueable` |
| Trigger Action | `TA_{SObject}_{Action}` | `TA_Account_SetDefaults` |

### ApexDoc Header Format
```apex
/**
 * @description Provides business logic for Account deduplication and synchronization.
 */
public with sharing class AccountService {
    /**
     * @description Merges duplicate accounts based on tax ID match.
     * @param accountIds Set of Account IDs to evaluate
     * @return Map of surviving Account IDs to merged child counts
     * @throws AccountServiceException when merge criteria fail
     */
    public static Map<Id, Integer> deduplicate(Set<Id> accountIds) { ... }
}
```
