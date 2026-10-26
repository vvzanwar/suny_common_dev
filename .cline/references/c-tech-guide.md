# Salesforce Technical Decision Guide (`<TECH_GUIDE>`)

Reference manual for architectural scoping across all Salesforce development domains. Loaded on demand during **Plan Mode** by `c-sf-architect`.

---

## Domain 1: Enterprise 5-Layer Backend Architecture
- **Trigger Layer:** Exactly ONE trigger per object covering all 7 contexts. Zero business logic, zero SOQL, zero DML. Forwards immediately to `TriggerHandler`.
- **Handler Layer:** Context dispatching (`isBefore`, `isAfter`, `isInsert`, etc.), recursion control (`Set<Id> processedIds`), and bypass checks via `FeatureSwitch`.
- **Service Layer (`<Object>Service`):** Orchestrates coarse-grained cross-object business processes, external transactions, and transactional boundaries.
- **Domain Layer (`<Object>Domain`):** Enforces entity-level rules, field defaults, and validations for a specific SObject. Validates records before DML.
- **Selector Layer (`<Object>Selector`):** The ONLY location where SOQL queries reside. Centralizes field lists, enforces `WITH USER_MODE` / FLS, and enables mock injection for sub-second testing.

---

## Domain 2: Declarative vs. Programmatic Automation
| Requirement Profile | Chosen Technology | Architectural Justification |
|---|---|---|
| Simple field updates, notifications, cross-object field sync | **Record-Triggered Flow** | Low-code maintainability, native declarative auditability. |
| Complex multi-object calculations, large volume ($>200$ records), loops over large collections | **Apex Trigger (5-Layer)** | High-performance bulkification, heap control, and unit-testable domain logic. |
| Complex orchestration with user interaction | **Screen Flow + LWC** | Screen Flow handles wizard routing; LWC provides specialized custom UI components. |
| Reusable complex logic invoked from Flow | **Invocable Apex (`@InvocableMethod`)** | Bridge business logic into declarative workflows without duplicating code. |

---

## Domain 3: Asynchronous Apex Processing
| Pattern | Ideal Use Case | Governor Limits & Constraints |
|---|---|---|
| **Queueable Apex** | Chained jobs, integration callouts, lightweight background processing | 50 queued jobs/transaction. Pass only `Set<Id>`, never SObject collections. Implement `Finalizer` for error handling. |
| **Batch Apex** | Large data volumes ($>10,000$ to millions of records), night-time data cleanup | Max 5 concurrent running batches. State maintained via `Database.Stateful` only when necessary. |
| **Schedulable Apex** | Recurring cron tasks (hourly, daily, weekly) | Max 100 scheduled jobs. Always delegates to a Queueable or Batch class; never runs heavy logic directly. |
| **Platform Events / CDC** | Decoupled event-driven architecture, near-real-time system integration | Asynchronous subscriber triggers run under automated process user. Publish after commit via `EventBus.publish()`. |

---

## Domain 4: Integrations & APIs
- **Inbound Integrations:** Custom REST APIs (`@RestResource(urlMapping='/v1/...')`). Enforce authentication, validate JSON schemas, catch exceptions, and log errors to `Error_Log__c`.
- **Outbound Integrations:** Named Credentials and External Credentials only (never hardcode endpoints or tokens). Dedicated `<System>Service` with `<System>Mock` for test coverage.
- **Resilience:** Wrap HTTP callouts with retry mechanisms and circuit breakers where applicable; always handle HTTP status codes gracefully.

---

## Domain 5: Data Modeling, Security & Governance
- **Relationships:** Use Master-Detail only when parent-child lifecycle and roll-up summary fields are mandatory; use Lookup for loose coupling.
- **Sharing & Security:** Default to `with sharing` on all classes. Use `inherited sharing` for utility and selector classes. Always enforce FLS/CRUD using `WITH USER_MODE` or `Security.stripInaccessible()`.
- **Configuration over Code:** Use Custom Metadata Types (`__mdt`) for business configurations, thresholds, and routing tables; avoid hardcoded IDs or strings.

---

## Domain 6: Frontend & User Experience (LWC)
- **Component Architecture:** Container/Presentation split. Container handles data fetching (`@wire`, imperative Apex) and passes immutable state down.
- **State Management:** Mandate 3 distinct UI states in every component: Loading (spinner/skeleton), Empty (helpful message), and Error (toast/alert).
- **Communication:** Custom Events for child-to-parent; Lightning Message Service (LMS) for decoupled cross-DOM sibling communication.
- **Styling:** Strict adherence to SLDS 2.0 design tokens; zero hardcoded pixel heights or non-SLDS palettes.

---

## Domain 7: Testing & Verification Strategy
- **Isolation & Speed:** Separate fast unit tests (using mocks and stubs) from end-to-end integration tests.
- **Coverage Targets:** $\ge 90\%$ for new classes, $\ge 85\%$ for modified legacy classes.
- **Mandatory Test Scenarios:** Positive single-record, bulk (200 records), negative/error path, and user permission context (`System.runAs`).
- **Data Isolation:** All tests must generate data via `TestDataFactory`; `@isTest(SeeAllData=true)` is strictly prohibited.
