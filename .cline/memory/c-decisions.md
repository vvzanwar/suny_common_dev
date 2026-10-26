# Architecture Decisions (ADRs)

Document significant architectural choices, tradeoffs, and structural patterns here so future agents and developers understand the rationale.

### Template:
<!--
### ADR-00X: [Short Title]
- **Date:** YYYY-MM-DD
- **Context / Problem:** [Why a choice was needed]
- **Decision:** [What architecture or pattern was chosen]
- **Consequences / Tradeoffs:** [What is enabled or restricted]
-->

### ADR-001: NCSIM 5-Layer Architecture Adoption
- **Date:** 2026-10-20
- **Context / Problem:** Ensure high maintainability, strict bulkification, and 1-trigger-per-object discipline across SUNY 64-campus features.
- **Decision:** Adopt strict 5-layer separation: `Entry Point` -> `Service` -> `Domain` & `Selector` -> `Salesforce Data`, with virtual `TriggerHandler` (all 7 contexts) and `FeatureSwitch` custom metadata toggles.
- **Consequences:** Controllers and Triggers must never execute inline SOQL or DML; all SOQL is centralized in `*Selector.cls` using `WITH USER_MODE`.

### ADR-002: Queueable with Set<Id> as Default Async Strategy
- **Date:** 2026-10-20
- **Context / Problem:** Long-running post-commit operations and callouts without hitting governor limits.
- **Decision:** Use `Queueable` (implementing `Database.AllowsCallouts` when needed) passing `Set<Id>` only to constructors. Never write new `@future` methods.
- **Consequences:** Prevents passing stale in-memory SObject states; records are re-queried freshly inside `execute()`.
