---
name: cline-platform-soql-query
description: "Use when the user needs SOQL/SOSL authoring or optimization: natural-language-to-query generation, relationship queries, aggregates, query-plan/selectivity analysis, and performance or safety improvements. TRIGGER when the user writes, optimizes, or debugs SOQL/SOSL, touches .soql files, or asks about relationship queries, aggregates, or query performance. DO NOT TRIGGER for bulk data operations (use platform-data-manage), Apex DML logic (use platform-apex-generate), or report/dashboard queries."
metadata:
  version: "1.1"
  domains: ["Platform"]
  relatedSkills:
    - "experience-lwc-generate"
    - "platform-apex-generate"
    - "platform-apex-logs-debug"
    - "platform-apex-test-run"
    - "platform-data-manage"
  cliTools:
    - tool: ["jq"]
      semver: ">=1.6.0"
    - tool: ["python3"]
      semver: ">=3.10.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# platform-soql-query: Salesforce SOQL Query Expert

Use this skill when the user needs **SOQL/SOSL authoring or optimization**: natural-language-to-query generation, relationship queries, aggregates, query-plan analysis, and performance/safety improvements for Salesforce queries.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `aggregate-queries.soql, basic-queries.soql, bulkified-query-pattern.cls, optimization-patterns.soql, relationship-queries.soql, selector-class.cls, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `anti-patterns.md, cli-commands.md, field-coverage-rules.md, patterns-and-examples.md, query-optimization.md, selector-patterns.md, soql-reference.md, soql-syntax-reference.md`

---

## When This Skill Owns the Task

Use `platform-soql-query` when the work involves:
- `.soql` files
- query generation from natural language
- relationship queries and aggregate queries
- query optimization and selectivity analysis
- SOQL/SOSL syntax and governor-aware design

Delegate elsewhere when the user is:
- performing bulk data operations → [platform-data-manage](../platform-data-manage/SKILL.md)
- embedding query logic inside broader Apex implementation → [platform-apex-generate](../platform-apex-generate/SKILL.md)
- debugging via logs rather than query shape → [platform-apex-logs-debug](../platform-apex-logs-debug/SKILL.md)

---

## Required Context to Gather First

Ask for or infer:
- target object(s)
- fields needed
- filter criteria
- sort / limit requirements
- whether the query is for display, automation, reporting-like analysis, or Apex usage
- whether performance / selectivity is already a concern

---

## Recommended Workflow

### 1. Generate the simplest correct query
Prefer:
- only needed fields
- clear WHERE criteria
- reasonable LIMIT when appropriate
- relationship depth only as deep as necessary

### 2. Choose the right query shape
| Need | Default pattern |
|---|---|
| parent data from child | child-to-parent traversal |
| child rows from parent | subquery |
| counts / rollups | aggregate query |
| records with / without related rows | semi-join / anti-join |
| text search across objects | SOSL |

### 3. Optimize for selectivity and safety
Check:
- indexed / selective filters
- no unnecessary fields
- no avoidable wildcard or scan-heavy patterns
- security enforcement expectations

### 4. Validate execution path if needed
If the user wants runtime verification, hand off execution to:
- [platform-data-manage](../platform-data-manage/SKILL.md)

---

## Output Format

When finishing, report in this order:
1. **Query purpose**
2. **Final SOQL/SOSL**
3. **Why this shape was chosen**

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
