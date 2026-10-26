---
name: cline-platform-apex-test-run
description: "Apex test execution, coverage analysis, and test-fix loops with 120-point scoring. Use when the user runs Apex tests, checks code coverage, fixes failing tests, or touches *Test.cls / *_Test.cls files. DO NOT TRIGGER when writing Apex production code (use platform-apex-generate), Agentforce agent testing (use agentforce-test), or Jest/LWC tests (use experience-lwc-generate)."
metadata:
  version: "1.2"
  domains: ["Platform"]
  relatedSkills:
    - "agentforce-test"
    - "experience-lwc-generate"
    - "platform-apex-generate"
    - "platform-apex-logs-debug"
    - "platform-data-manage"
    - "platform-metadata-deploy"
  cliTools:
    - tool: ["jq"]
      semver: ">=1.6.0"
    - tool: ["python3"]
      semver: ">=3.10.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# platform-apex-test-run: Salesforce Test Execution & Coverage Analysis

Use this skill when the user needs **Apex test execution and failure analysis**: running tests, checking coverage, interpreting failures, improving coverage, and managing a disciplined test-fix loop for Salesforce code.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `basic-test.cls, bulk-test.cls, dml-mock.cls, mock-callout-test.cls, specifications-and-schemas.md, stub-provider-example.cls, test-data-factory.cls`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `cli-commands.md, mocking-patterns.md, patterns-and-examples.md, performance-optimization.md, test-fix-loop.md, test-patterns.md, testing-best-practices.md`

---

## When This Skill Owns the Task

Use `platform-apex-test-run` when the work involves:
- `sf apex run test` workflows
- Apex unit-test failures
- code coverage analysis
- identifying uncovered lines and missing test scenarios
- structured test-fix loops for Apex code

Delegate elsewhere when the user is:
- writing or refactoring production Apex → `platform-apex-generate` skill
- testing Agentforce agents → `agentforce-test` skill
- testing LWC with Jest → [experience-lwc-generate](../experience-lwc-generate/SKILL.md)

---

## Required Context to Gather First

Ask for or infer:
- target org alias
- desired test scope: single class, specific methods, suite, or local tests
- coverage threshold expectation
- whether the user wants diagnosis only or a test-fix loop
- whether related test data factories already exist

---

## Recommended Workflow

### 1. Discover test scope
Identify:
- existing test classes
- target production classes
- test data factories / setup helpers

### 2. Run the smallest useful test set first
Start narrow when debugging a failure; widen only after the fix is stable.

### 3. Analyze results
Focus on:
- failing methods
- exception types and stack traces
- uncovered lines / weak coverage areas
- whether failures indicate bad test data, brittle assertions, or broken production logic

### 4. Run a disciplined fix loop
When the issue is code or test quality:
- delegate code fixes to `platform-apex-generate` skill when needed
- add or improve tests
- rerun focused tests before broader regression

### 5. Improve coverage intentionally
Cover:
- positive path
- negative / exception path
- bulk path (251+ records where appropriate)
- callout or async path when relevant

---

## Output Format

When finishing, report in this order:
1. **What tests were run**
2. **Pass/fail summary**

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
