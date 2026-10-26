---
name: cline-platform-apex-generate
description: "Primary Apex authoring skill for class generation, refactoring, and review. ALWAYS ACTIVATE when the user mentions Apex, .cls, triggers, or asks to create/refactor a class (service, selector, domain, batch, queueable, schedulable, invocable, DTO, utility, interface, abstract, exception, REST resource). Use for SObject CRUD, collection mapping, queries, async jobs, trigger design, @AuraEnabled controllers, or @RestResource endpoints."
metadata:
  version: "2.0"
  domains: ["Platform"]
  minApiVersion: "66.0"
  relatedSkills:
    - "cline-platform-apex-test-generate"
  cliTools:
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# Generating Apex (Cline Edition)

Use this skill for production-grade Apex authoring, refactoring, and evidence-based code review.

## 1. Quick Reference & Assets

* **Scaffolding Templates & Architecture Guidance**: Consult [`resources/type-guidance.md`](resources/type-guidance.md) for async decisions, layer boundaries, and template mappings (`resources/*.cls`).
* **Implementation Standards & Rules**: Consult [`examples/coding-standards.md`](examples/coding-standards.md) for bulkification rules, naming conventions, SOQL security, and error handling.
* **Reference Implementations**: Inspect concrete reference classes in [`examples/`](examples/) (`AccountService.cls`, `AccountSelector.cls`, `AccountDeduplicationBatch.cls`).

---

## 2. Sequential Workflow

### Phase 1 — Author
1. **Discover Project Architecture**: Check existing layer conventions (Service-Selector-Domain) and trigger patterns in the codebase.
2. **Select Pattern & Template**: Review [`resources/type-guidance.md`](resources/type-guidance.md) and pick the matching scaffold from `resources/` (`service.cls`, `selector.cls`, `batch.cls`, etc.).
3. **Pre-Creation Schema Hook (Verify Live Metadata)**:
   * Inspect authoritative live schema before authoring any queries or DML:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .cline/scripts/c-query-org.ps1 -Describe "<SObjectName>"
     ```
   * Never assume custom field (`__c`) or relationship (`__r`) names without verification.
4. **Author Code with Guardrails**:
   * Adhere strictly to [`examples/coding-standards.md`](examples/coding-standards.md) (`WITH USER_MODE`, explicit sharing, null guards, collections first).
   * Generate `{ClassName}.cls` and `{ClassName}.cls-meta.xml`.
5. **Generate Unit Tests**: Delegate test generation to `cline-platform-apex-test-generate` to create `{ClassName}Test.cls`.

### Phase 2 — Validate (Hooks & QA Gate)
6. **Execute Project QA Gate Hook**:
   * Run the deterministic project QA gate on the authored files and test class:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .cline/scripts/c-run-qa-gate.ps1 -TargetFiles "<path_to_class>" -TestClasses "{ClassName}Test"
     ```
   * Enforces:
     - Sub-50ms static AST guardrails (`.cline/scripts/c-sf-pre-write-guard.js`): no SOQL in loops, no DML in domain/selector, sharing enforced, no `System.debug`, no hardcoded IDs.
     - Prettier formatting compliance.
     - Sandbox dry-run deployment and Apex server-side test execution (>=90% coverage).
7. **Static Code Analyzer**: Run `sf code-analyzer run` or MCP `run_code_analyzer` and resolve sev0/sev1/sev2 issues.

### Phase 3 — Report
8. **Final Deliverable Summary**:
   ```text
   Apex work: <summary>
   Files: <paths to .cls, .cls-meta.xml, and tests>
   Design: <architectural pattern / layer choices>
   QA Gate: <AST guardrail + test results summary>
   Deploy: <dry-run status or next deployment steps>
   ```
