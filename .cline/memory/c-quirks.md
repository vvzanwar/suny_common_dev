# Sandbox & Org Quirks (SUNY_COMMON_DEV)

Document undocumented sandbox validation rules, schema quirks, campus code requirements, or API gotchas here to prevent repeated debugging.

### Target Sandbox Profile & Limits
- **Date:** 2026-10-20
- **Quirk:** Target sandbox `SUNY_COMMON_DEV` does not use source tracking; deployments must be tested with `--dry-run` and specified unit tests.
- **Workaround:** Always run `powershell -File .cline/scripts/c-run-qa-gate.ps1 -TestClasses "<TestClass>"` to verify before requesting human deployment approval.

### SObject Schema Verification
- **Date:** 2026-10-20
- **Quirk:** SObject field names across SUNY customizations may not follow standard EDC defaults.
- **Workaround:** Never guess field names; run `powershell -File .cline/scripts/c-query-org.ps1 -Describe "<SObject>"` to confirm field API names before writing SOQL.

