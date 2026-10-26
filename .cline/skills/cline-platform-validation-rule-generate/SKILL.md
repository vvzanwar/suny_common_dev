---
name: cline-platform-validation-rule-generate
description: "Use this skill when users need to create, modify, or validate Salesforce Validation Rules. Trigger when users mention validation rules, field validation, data quality rules, formula validation, error messages, or validation logic. Also use when users encounter validation errors, need to update formulas, or want to enforce business rules at the data layer. Always use this skill for any validation rule work."
metadata:
  version: "1.0"
  domains: ["Platform"]
  minApiVersion: "60.0"
---

# platform-validation-rule-generate

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md`

---

## When to Use This Skill

Use this skill when you need to:
- Create validation rules to enforce data quality
- Prevent invalid records from being saved
- Generate validation rule metadata with formulas
- Add business logic validation to objects
- Troubleshoot deployment errors related to validation rules

## Project Hooks (Schema & QA Gate)
1. **Pre-Creation Schema Hook**: Verify live org metadata before authoring or querying:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .cline/scripts/c-query-org.ps1 -Describe "<SObjectName>"
   ```
2. **Post-Creation QA Gate**: Validate AST guardrails, Prettier, and dry-run deployment:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .cline/scripts/c-run-qa-gate.ps1 -TargetFiles "<path_to_file>"
   ```
