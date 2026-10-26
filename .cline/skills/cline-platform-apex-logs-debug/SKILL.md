---
name: cline-platform-apex-logs-debug
description: "Salesforce debug log analysis and troubleshooting with 100-point scoring. TRIGGER when: user analyzes debug logs, hits governor limits, reads stack traces, or touches .log files from Salesforce orgs. DO NOT TRIGGER when: running Apex tests (use platform-apex-test-run), generating or fixing Apex code (use platform-apex-generate), or Agentforce session tracing (use agentforce-observe)."
metadata:
  version: "1.1"
  domains: ["Platform"]
  relatedSkills:
    - "agentforce-observe"
    - "platform-apex-generate"
    - "platform-apex-test-run"
    - "platform-data-manage"
    - "platform-metadata-deploy"
    - "platform-soql-query"
  cliTools:
    - tool: ["sf"]
      semver: ">=2.0.0"
    - tool: ["jq"]
      semver: ">=1.6.0"
---

# platform-apex-logs-debug: Salesforce Debug Log Analysis & Troubleshooting

Use this skill when the user needs **root-cause analysis from debug logs**: governor-limit diagnosis, stack-trace interpretation, slow-query investigation, heap / CPU pressure analysis, or a reproduction-to-fix loop based on log evidence.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `benchmarking-template.cls, cpu-heap-optimization.cls, dml-in-loop-fix.cls, null-pointer-fix.cls, soql-in-loop-fix.cls, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `analysis-playbook.md, benchmarking-guide.md, cli-commands.md, common-issues.md, debug-log-reference.md, log-analysis-tools.md, patterns-and-examples.md, scoring-rubric.md`

---

## When This Skill Owns the Task

Use `platform-apex-logs-debug` when the work involves:
- `.log` files from Salesforce
- stack traces and exception analysis
- governor limits
- SOQL / DML / CPU / heap troubleshooting
- query-plan or performance evidence extracted from logs

Delegate elsewhere when the user is:
- running or repairing Apex tests → [platform-apex-test-run](../platform-apex-test-run/SKILL.md)
- generating or implementing the code fix → [platform-apex-generate](../platform-apex-generate/SKILL.md)
- debugging Agentforce session traces / parquet telemetry → [agentforce-observe](../agentforce-observe/SKILL.md)

---

## Required Context to Gather First

Ask for or infer:
- org alias
- failing transaction / user flow / test name
- approximate timestamp or transaction window
- user / record / request ID if known
- whether the goal is diagnosis only or diagnosis + fix loop

---

## Recommended Workflow

### 1. Retrieve logs

Use the commands in [examples/cli-commands.md](examples/cli-commands.md) to list, download, or stream logs for the target org.

### 2. Analyze in this order
1. entry point and transaction type
2. exceptions / fatal errors
3. governor limits
4. repeated SOQL / DML patterns
5. CPU / heap hotspots
6. callout timing and external failures

### 3. Classify severity
- **Critical** — runtime failure, hard limit, corruption risk
- **Warning** — near-limit, non-selective query, slow path
- **Info** — optimization opportunity or hygiene issue

### 4. Recommend the smallest correct fix
Prefer fixes that are:
- root-cause oriented
- bulk-safe
- testable
- easy to verify with a rerun

Expanded workflow: [examples/analysis-playbook.md](examples/analysis-playbook.md)

---

## High-Signal Issue Patterns

| Issue | Primary signal | Default fix direction |
|---|---|---|
| SOQL in loop | repeating `SOQL_EXECUTE_BEGIN` in a repeated call path | query once, use maps / grouped collections |
| DML in loop | repeated `DML_BEGIN` patterns | collect rows, bulk DML once |
| Non-selective query | high rows scanned / poor selectivity | add indexed filters, reduce scope |
| CPU pressure | CPU usage approaching sync limit | reduce algorithmic complexity, cache, async where valid |

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
