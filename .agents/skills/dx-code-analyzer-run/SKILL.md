---
name: dx-code-analyzer-run
description: "Run Salesforce Code Analyzer to scan code for security, performance, best practice, and code style violations. Supports all engines (PMD, ESLint, CPD, RetireJS, Flow, SFGE, ApexGuru), targets (files, folders, git diff), categories, and severities. Also handles post-scan exploration: filtering results by engine/severity/category/file, and explaining what rules mean. TRIGGER when: user says 'scan my code', 'check security issues', 'run PMD/ESLint', 'find duplicates', 'analyze Flows', 'check vulnerable libraries', 'AppExchange review', 'lint my LWC', 'static analysis', 'code quality', 'show security violations', 'what is this rule', 'explain ApexCRUDViolation', 'filter results', or mentions engines/file types (.cls, .trigger, .js, .flow-meta.xml). Use this skill for scanning, exploring results, and listing rules. DO NOT TRIGGER when: user asks only about installation/configuration (use dx-code-analyzer-configure), or wants to create a custom rule (use dx-code-analyzer-custom-rule-create)."
metadata:
  version: "1.0"
  domains: ["Developer Experience"]
  relatedSkills:
    - "dx-code-analyzer-configure"
    - "dx-code-analyzer-custom-rule-create"
  cliTools:
    - tool: ["git"]
      semver: ">=2.0.0"
    - tool: ["java"]
      semver: ">=11.0.0"
    - tool: ["jq"]
      semver: ">=1.6.0"
    - tool: ["node"]
      semver: ">=18.0.0"
    - tool: ["npm"]
      semver: ">=9.0.0"
    - tool: ["python3"]
      semver: ">=3.9.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# Running Code Analyzer Skill

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `command-examples.md, engine-reference.md, error-handling.md, flag-reference.md, post-scan-workflows.md, quick-start.md, special-behaviors.md, specifications-and-schemas.md, vendor-file-handling.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `basic-scan-output.json, command-variations.md, fix-application-before-after.md, large-scan-output.json, patterns-and-examples.md, README.md, security-focused-output.json`

---

## CRITICAL: Mandatory Script Usage

Every interaction with Code Analyzer results MUST go through the bundled scripts in `<skill_dir>/scripts/`. No exceptions.

### WRONG — never do this:

```bash
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Overview

> **Ecosystem:** This skill is part of a 3-skill Code Analyzer suite — `dx-code-analyzer-run` (scans & results) · `dx-code-analyzer-configure` (setup, config, CI/CD) · `dx-code-analyzer-custom-rule-create` (custom rule authoring).

This skill translates natural-language requests ("scan for security issues", "check my changes") into the correct `sf code-analyzer run` command, executes scans across any combination of engines/targets/severities, and presents actionable results. When engine-provided fixes are available, it discovers them, asks for user confirmation, applies them safely, and offers verification. Use it for static analysis, security reviews, AppExchange certification, code-quality checks, and finding duplicates/vulnerabilities in Salesforce projects.

**In scope:** running scans, parsing/filtering/ranking results, applying engine auto-fixes, diff-based scans, all output formats (JSON/HTML/SARIF/CSV/XML), describing/listing rules, scan-failure troubleshooting.

**Out of scope:** installing/configuring `sf` or the plugin (→ `dx-code-analyzer-configure`), writing custom rules/engines (→ `dx-code-analyzer-custom-rule-create`), AI-generated fixes beyond engine-provided ones, deep refactoring, CI/CD setup (→ `dx-code-analyzer-configure`).

**Allowed tools:** Bash (`sf code-analyzer`, `node`, `git diff`, `date`), Read, Write, Edit. **Forbidden:** any MCP tool, Agent tool, web tools, other skills, Python, `jq`, inline scripts/heredocs. This skill owns the complete scan-fix-verify-query-explain workflow end-to-end.

---

## Prerequisites

User needs: **Salesforce CLI** (`sf`), **@salesforce/plugin-code-analyzer** (v5.x+), **Java 11+** (PMD/CPD/SFGE), **Node.js 18+** (ESLint/RetireJS), **Python 3** (Flow), **authenticated org** (ApexGuru).

Pre-flight: run `sf code-analyzer --help 2>&1 | head -1`. If that fails, or if a scan reports an engine startup error (e.g., "PMD failed to start", "java: command not found", "SFGE failed"):

1. **Stop** — do not attempt to install/diagnose prerequisites yourself.
2. **Delegate to `dx-code-analyzer-configure`** — it handles all setup.
3. After it finishes, return here and re-run the scan.

If a scan fails for other reasons, see `<skill_dir>/examples/error-handling.md`.

---

## Step 1: Parse the User's Intent

Analyze the request along these 7 dimensions; any can combine.

### 1.1 ENGINE
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full step commands and parameters.)*

## Step 2: Build the Rule Selector

Syntax: `:` = AND, `,` = OR, `()` = grouping.

- Engine only: `pmd`
- Engine + category: `pmd:Security`
- Engine + severity: `pmd:2`
- Complex: `(pmd,eslint):Security:(1,2)` = (PMD or ESLint) AND Security AND sev (1 or 2)
- Specific rule: `pmd:ApexCRUDViolation`
- All: `all`

More: `<skill_dir>/examples/command-examples.md`.

---

## Step 3: Build the Full Command

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
sf code-analyzer run \
  --rule-selector <selector> \

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
