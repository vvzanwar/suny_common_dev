---
trigger: always_on
description: NCSIM Asynchronous Processing (Queueable, Batch, Platform Events) and Outbound/Inbound Integration Standards
---

# NCSIM Standard 04: Asynchronous Processing & Integrations

## 1. Asynchronous Apex Rules
| Tool | Use When |
| :--- | :--- |
| **Queueable (`<Work>Queueable`)** | Default choice for async work (< 50k records), callouts after DML, or job chaining |
| **Batch Apex (`<Work>Batch`)** | Processing > 50,000 records or scheduled nightly/weekly sweeps |
| **Scheduled Apex (`<Work>Scheduler`)** | Thin cron trigger that only calls `Database.executeBatch(new <Work>Batch(), 200)` |
| **Platform Events (`<Event>__e`)** | Decoupling modules or surviving transaction rollbacks (`Log_Event__e`) |
| **`@future`** | **Legacy only.** Do not write new `@future` methods; use Queueable instead |

- **Queueable Rules**:
  1. Constructor accepts **`Set<Id>` only** â€” never pass `List<SObject>` (stale record state).
  2. Always re-query fresh records via a `*Selector` inside `execute()`.
  3. Wrap `execute()` in `try / catch / finally` calling `Logger.error(...)` and `Logger.flush()`.
  4. Never enqueue async work from a `before` trigger (IDs may not exist yet).
- **Batch Rules**: Implement `Database.Batchable<SObject>, Database.Stateful`; delegate `execute()` to the Service method on the 200-record `scope`; log failures in `finish()`.
- **Platform Event Subscribers**: Must be **idempotent** (safe if delivered more than once).

```apex
public with sharing class EnrollmentConfirmationQueueable implements Queueable, Database.AllowsCallouts {
    private final Set<Id> enrollmentIds;

    public EnrollmentConfirmationQueueable(Set<Id> enrollmentIds) {
        this.enrollmentIds = enrollmentIds;
    }

    public void execute(QueueableContext ctx) {
        try {
            List<Enrollment__c> records = EnrollmentSelector.selectByIds(this.enrollmentIds);
            for (Enrollment__c rec : records) {
                StudentBillingService.createInvoice(rec.Student__c, rec.Credits__c);
            }
        } catch (Exception e) {
            Logger.error('EnrollmentConfirmationQueueable.execute', e);
        } finally {
            Logger.flush();
        }
    }
}
```

## 2. Outbound Callouts (`<System>Service`) & Inbound REST
- One class per external system named `<System>Service` (`with sharing`):
  1. Check `if (!FeatureSwitch.isEnabled('<Switch_Name>')) throw new IntegrationException('...');` at the top.
  2. Always use **Named Credentials** (`req.setEndpoint('callout:<Named_Credential>/...')`) â€” zero hardcoded URLs, keys, or tokens.
  3. Always set an explicit timeout (`req.setTimeout(20000)`).
  4. Deserialize JSON into typed inner wrapper classes (`JSON.deserialize(res.getBody(), InvoiceResponse.class)`).
  5. Log non-2xx responses via `Logger.calloutError(...)` + `Logger.flush()` and throw `IntegrationException`.
  6. Retry **only** on timeouts or `5xx` (max 3 attempts via chained Queueable); never retry `4xx`.
  7. Ship with `@IsTest public class <System>Mock implements HttpCalloutMock`.
- Inbound `@RestResource(urlMapping='/ncsim/v1/<resource>/*')` classes validate payload, call one Service method, and return a consistent JSON response.
