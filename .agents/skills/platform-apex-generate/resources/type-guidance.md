# Apex Type-Specific Guidance & Architecture Scaffolding

This reference document contains the architecture rules, async decision matrix, and template mappings for `platform-apex-generate`.

---

## 1. Async Decision Matrix

| Scenario | Default | Key Traits |
|---|---|---|
| Standard async work | **Queueable** | Job ID, chaining, non-primitive types, configurable delay (up to 10 min via `AsyncOptions`), dedup signatures |
| Very large datasets | **Batch Apex** | Chunked processing, max 5 concurrent; use `QueryLocator` for large scopes |
| Modern batch alternative | **CursorStep** (`Database.Cursor`) | 2000-record chunks, higher throughput, no 5-job limit |
| Recurring schedule | **Scheduled Flow** (preferred) or **Schedulable** | Schedulable has 100-job limit; use only when chaining to Batch or needing complex Apex logic |
| Post-job cleanup | **Finalizer** (`System.Finalizer`) | Runs regardless of Queueable success/failure |
| Long-running callouts | **Continuation** | Up to 3 per transaction, 3 parallel |
| Delays > 10 minutes | `System.scheduleBatch()` | Schedule a Batch job at a specific future time |
| Legacy fire-and-forget | `@future` | **Do not use in new code** — replace with Queueable + Finalizer |

---

## 2. Layer Responsibilities & Boundaries

| Layer | Owns | Must NOT contain |
|---|---|---|
| Trigger | Event routing only | Business logic, orchestration |
| Handler/Service | Flow control, coordination | Inline SOQL/DML/HTTP/parsing |
| Domain | Business rules, validation | Queries, callouts, persistence details |
| Selector | SOQL queries, field sets | DML, business logic |
| Data/Integration | HTTP callouts, serialization | Business decisions |

*Disallowed*: Methods mixing orchestration with inline SOQL/DML/HTTP; business rules mixed with parsing internals; validation + persistence + cross-system plumbing in one method.

---

## 3. Type-Specific Guidance & Template Mapping

### Service
- **Template**: `resources/service.cls` · **Reference**: `examples/AccountService.cls`
- `with sharing`; stateless — no `public` fields or mutable instance state; keep public APIs focused and `static` where reasonable.
- Delegate all SOQL to Selectors and SObject behavior to Domains.
- Wrap business errors in a custom exception (e.g., `AccountServiceException`).

### Selector
- **Template**: `resources/selector.cls` · **Reference**: `examples/AccountSelector.cls`
- `inherited sharing`; one per SObject or query domain.
- Return `List<SObject>` or `Map<Id, SObject>`; use a shared base field list constant (no inline duplication).
- Accept filter parameters; always include `WITH USER_MODE`.

### Domain
- **Template**: `resources/domain.cls`
- `with sharing`; encapsulate field defaults, derivations, and validations.
- Operate on in-memory lists only; no SOQL/DML (belongs in Services/Selectors).

### Batch
- **Template**: `resources/batch.cls` · **Reference**: `examples/AccountDeduplicationBatch.cls`
- `with sharing`; implement `Database.Batchable<SObject>` (add `Database.Stateful` when tracking across chunks).
- `start()` = query definition; `execute()` = business logic; `finish()` = logging/notification.
- Use `QueryLocator` for large datasets; handle partial failures via `Database.SaveResult`.

### Queueable
- **Template**: `resources/queueable.cls`
- `with sharing`; implement `Queueable` and optionally `Database.AllowsCallouts` when HTTP callouts are needed.
- Accept data via constructor; add chain-depth guards to prevent infinite loops.
- Use `AsyncOptions` for configurable delay (up to 10 min) and dedup signatures.

### Schedulable
- **Template**: `resources/schedulable.cls`
- `with sharing`; `execute()` delegates to Queueable or Batch.
- Provide CRON constants and a convenience `scheduleDaily()` helper.

### DTO / Wrapper
- **Template**: `resources/dto.cls`
- No sharing keyword needed (pure data containers); simple public properties; no-arg + parameterized constructors.

### Utility
- **Template**: `resources/utility.cls`
- No sharing keyword needed; all methods `public static`; `private` constructor; pure, side-effect-free.

### Interface & Abstract
- **Templates**: `resources/interface.cls`, `resources/abstract.cls`
- Define clear contracts with ApexDoc; mark extension points `protected virtual` or `protected abstract`.

### Custom Exception
- **Template**: `resources/exception.cls`
- Extend `Exception` with descriptive names. Supported constructors: `()`, `('msg')`, `(cause)`, `('msg', cause)`.

### Trigger & Trigger Action (TAF)
- **Template**: `resources/trigger.cls`
- One trigger per object; delegate all logic to handler or Trigger Actions Framework (`TA_{SObject}_{Action}`).

### Invocable Method (`@InvocableMethod`)
- **Template**: `resources/invocable.cls`
- `with sharing`; inner `Request`/`Response` with `@InvocableVariable`. Public static methods only; bulkified signatures `List<Request>` -> `List<Response>`.

### REST Resource (`@RestResource`)
- **Template**: `resources/rest-resource.cls`
- `global with sharing`; versioned URL mapping `/{resource}/v1/*`. Standardized `ApiResponse` wrapper; thin controller delegating to Service.

### `@AuraEnabled` Controller
- `with sharing`; use `WITH USER_MODE` in all SOQL.
- `@AuraEnabled(cacheable=true)` only for read-only queries. Throw `AuraHandledException` for UI errors.
