# Sandbox & Org Quirks (SUNY_COMMON_DEV)

Document undocumented sandbox validation rules, schema quirks, campus code requirements, or API gotchas here to prevent repeated debugging.

### Target Sandbox Profile & Limits
- **Date:** 2026-10-20
- **Quirk:** Target sandbox `SUNY_COMMON_DEV` does not use source tracking; deployments must be tested with `--dry-run` and specified unit tests.
- **Workaround:** Always run `powershell -File .agents/scripts/run-qa-gate.ps1 -TestClasses "<TestClass>"` to verify before requesting human deployment approval.

### SObject Schema Verification
- **Date:** 2026-10-20
- **Quirk:** SObject field names across SUNY customizations may not follow standard EDC defaults.
- **Workaround:** Never guess field names; run `powershell -File .agents/scripts/query-org.ps1 -Describe "<SObject>"` (or use Salesforce DX MCP / `sf sobject describe`) to confirm field API names before writing SOQL.

### Education Cloud Shadow Date Fields & Validation Rules
- **Date:** 2026-10-23
- **Quirk:** On `LearningCourse` and `LearningProgram`, `ActiveFromDate` and `ActiveToDate` are read-only shadow projections of the parent `Learning` record (`createable: false`, `updateable: false`). Validation rules on `LearningCourse` cannot evaluate `ActiveToDate <= ActiveFromDate` directly.
- **Workaround:** In validation formulas on `LearningCourse`, traverse the relationship: `Learning.ActiveToDate <= Learning.ActiveFromDate`. On `Learning`, the rule evaluates `ActiveToDate <= ActiveFromDate` directly.

### Highlights Panel Compact Layout Field Visibility
- **Date:** 2026-10-23
- **Quirk:** Fields assigned to an SObject's Compact Layout (e.g. `LearningProgram` Highlights Panel) will NOT render in the UI header tile if their value is `null` on the current record. Browser IndexedDB caching also delays updates unless hard refreshed (`Ctrl + F5`).
- **Workaround:** Populate the field on the record and hard-refresh to verify visibility in the Highlights Panel.

