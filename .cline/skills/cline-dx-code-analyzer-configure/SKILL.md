---
name: cline-dx-code-analyzer-configure
description: "Set up, configure, and troubleshoot Salesforce Code Analyzer for any project. Handles installation, prerequisite checks, diagnosing broken setups, creating and editing code-analyzer.yml overrides, engine-specific settings, ignore patterns, severity overrides, and CI/CD pipeline setup. TRIGGER when: user says 'set up code analyzer', 'configure code analyzer', 'install code analyzer', 'code analyzer not working', 'fix my setup', 'scan failing', 'check my setup', 'enable/disable engine', 'exclude files', 'change severity', 'set up GitHub Actions', 'set up CI/CD', 'add to pipeline', 'pipeline fail', 'update my workflow', 'quality gate', 'fail on violations', 'scan changed files only', 'add SARIF', 'code-analyzer.yml', 'ESLint config', 'increase SFGE memory', or reports errors running Code Analyzer. DO NOT TRIGGER when: user wants to run a scan (use dx-code-analyzer-run), fix violations, explain rules, create custom rules (use dx-code-analyzer-custom-rule-create), or suppress violations."
metadata:
  version: "1.0"
  domains: ["Developer Experience"]
  relatedSkills:
    - "dx-code-analyzer-custom-rule-create"
    - "dx-code-analyzer-run"
  cliTools:
    - tool: ["sf"]
      semver: ">=2.0.0"
    - tool: ["curl"]
      semver: ">=7.0.0"
    - tool: ["java"]
      semver: ">=11.0.0"
    - tool: ["node"]
      semver: ">=18.0.0"
    - tool: ["npm"]
      semver: ">=9.0.0"
    - tool: ["python3"]
      semver: ">=3.10.0"
---

# Configuring Code Analyzer Skill

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `ci-cd-templates.md, config-schema.md, diagnostic-flow.md, engine-prerequisites.md, rule-name-resolution.md, specifications-and-schemas.md, troubleshooting.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `apex-project-config.yml, ci-github-actions.yml, fullstack-project-config.yml, lwc-project-config.yml, patterns-and-examples.md`

---

## Overview

> **Ecosystem:** This skill is part of a 3-skill Code Analyzer suite — `dx-code-analyzer-run` (scans & results) · `dx-code-analyzer-configure` (setup, config, CI/CD) · `dx-code-analyzer-custom-rule-create` (custom rule authoring).

This skill manages the `code-analyzer.yml` configuration file — the single source of truth for how Code Analyzer behaves in a project. All customization (engines, rules, ignores, suppressions) is done by creating or editing this file. If the file doesn't exist, this skill creates it in the current working directory.

---

## Scope

**In scope:**
- Checking prerequisites (sf CLI, Java, Node.js, Python, org auth)
- Installing/updating the Code Analyzer plugin
- Creating `code-analyzer.yml` if it doesn't exist
- Editing `code-analyzer.yml` for all configuration changes
- Engine settings, rule overrides, ignore patterns, suppressions
- CI/CD pipeline setup (GitHub Actions, Jenkins, etc.)
- Environment validation and troubleshooting

**Out of scope:**
- Running scans → use `dx-code-analyzer-run` skill
- Fixing violations, explaining rules, suppression management → use `dx-code-analyzer-run` skill
- Creating custom rules → use `dx-code-analyzer-custom-rule-create` skill

---

## Core Principle: YAML Only When Customizing

Code Analyzer works out of the box with NO config file — all defaults are built into the tool. The `code-analyzer.yml` file is ONLY created when the user explicitly requests a customization.

**Rules:**
- **Do NOT create `code-analyzer.yml` proactively** — only when user asks to change something
- **Do NOT duplicate built-in defaults** — only write entries that intentionally override behavior
- **Always place at project root** — where `sfdx-project.json` or `sf-project.json` lives
- **The CLI auto-discovers it** — `sf code-analyzer run` from project root automatically picks up `code-analyzer.yml` in that directory. No `--config-file` flag needed.
- User says "configure code analyzer" with no specifics? → **Ask what they want to customize**. Don't create an empty or boilerplate file.

**Workflow:**
1. User requests a customization (e.g., "disable PMD", "ignore test files", "increase SFGE memory")
2. Check if `code-analyzer.yml` exists at project root
3. If NO → create it at project root with ONLY the requested override
4. If YES → read it, then edit in the requested change
5. Validate with `sf code-analyzer config`

---

## Step 1: Understand Intent and Map to Config Sections

The user can request ANY combination of configuration changes in natural language. Your job is to:

1. **Parse what they want** — may be one thing or many things combined
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full step commands and parameters.)*

## Step 2: Check Prerequisites and Install

Run `bash "<skill_dir>/scripts/check-prerequisites.sh"` or check manually:

```bash
sf --version 2>&1                                    # sf CLI
sf plugins --core 2>&1 | grep -i "code-analyzer"    # Plugin
java -version 2>&1                                   # Java 11+ (PMD, CPD, SFGE)
node --version 2>&1                                  # Node 18+ (ESLint, RetireJS)
python3 --version 2>&1                               # Python 3 (Flow engine)
```


*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
