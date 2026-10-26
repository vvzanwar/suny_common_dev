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

### ADR-003: Learning Program Lightning Record Page Layout Organization
- **Date:** 2026-10-23
- **Context / Problem:** Standardize and balance all 50 catalog fields across existing section facets without altering section names or causing white-space distortion from long text areas.
- **Decision:**
  - Preserved original 7 section names: `Information`, `Lifecycle`, `Hours & Credits`, `Tuition & Aid`, `Compliance`, `Descriptions`, `System Information`.
  - Highlights Panel updated with high-value fields: `Name`, `LearningId`, `ProviderId`, `Program_Code__c`, `Award_Type__c`, `Program_Cost__c`.
  - Long text field `Program_Objectives__c` placed in `Descriptions` alongside `ShortDescription` and `Description`.
  - Balanced 2-column distribution across all tabs (e.g. 7+7 fields in Information, 4+4 in Lifecycle, 4+4 in Hours & Credits).
- **Consequences:** Balanced UI rendering, no white space gaps, zero duplicated fields.

### ADR-004: Learning Course Highlights Panel, History Tracking & Layout Organization
- **Date:** 2026-10-23
- **Context / Problem:** Standardize `LearningCourse` schema and record page across all 35 catalog fields + 10 standard EDC fields: create custom compact layout, enable history tracking on top 20 fields within limits, and reorganize 8 sections.
- **Decision:**
  - Created `Learning_Course_Compact_Layout` containing `Name`, `LearningId`, `ProviderId`, `Campus_Course_ID__c`, `Course_Status__c`, `Course_Fee__c`.
  - Enabled Field History Tracking on exactly 20 editable fields (6 standard + 14 custom), excluding shadow and long text fields.
  - Reorganized `Learning_Course_Record_Page` into 8 balanced sections (preserving all 7 original section names and adding `@@@SFDCSystem_InformationSFDC@@@`).
- **Consequences:** Eliminated 24-field clutter in Information section, zero duplicated fields, standard audit tracking enabled.


