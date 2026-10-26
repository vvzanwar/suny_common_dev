---
name: dx-code-analyzer-custom-rule-create
description: "Create custom Code Analyzer rules for Regex (pattern matching), PMD (XPath/AST for Apex and metadata XML), and ESLint (LWC/JavaScript/TypeScript). Use when users want to enforce coding standards, ban patterns, detect hardcoded values, govern metadata, or add rules not in the built-in set. TRIGGER when: user says 'create a rule', 'ban System.debug', 'enforce naming convention', 'detect hardcoded IDs', 'custom rule', 'xpath rule', 'regex rule', 'add a PMD rule', 'enforce a policy', 'create a check for', 'flag this pattern', 'make a rule that catches', 'metadata rule', 'check permissions', 'enforce API version', 'eslint rule', 'lwc rule', 'override rule threshold', 'customize complexity', or describes a pattern to enforce. DO NOT TRIGGER when: user wants to run a scan (use dx-code-analyzer-run), configure engines (use dx-code-analyzer-configure), or explain existing rules (use dx-code-analyzer-run)."
metadata:
  version: "1.0"
  domains: ["Developer Experience"]
  relatedSkills:
    - "dx-code-analyzer-configure"
    - "dx-code-analyzer-run"
  cliTools:
    - tool: ["git"]
      semver: ">=2.0.0"
    - tool: ["node"]
      semver: ">=18.0.0"
    - tool: ["npm"]
      semver: ">=9.0.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# dx-code-analyzer-custom-rule-create: Custom Code Analyzer Rule Authoring

> **Ecosystem:** This skill is part of a 3-skill Code Analyzer suite — `dx-code-analyzer-run` (scans & results) · `dx-code-analyzer-configure` (setup, config, CI/CD) · `dx-code-analyzer-custom-rule-create` (custom rule authoring).

Use this skill when the user needs to **create a custom rule** that enforces a pattern not covered by Code Analyzer's built-in rules. Supports Regex engine (text pattern matching) and PMD engine (structural XPath queries against the AST).

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `pmd-ruleset-template.xml, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `advanced-pmd-patterns.md, apex-ast-reference.md, eslint-custom-plugins.md, eslint-rules-discovery.md, eslint-tier2-configurable.md, eslint-tier3-custom-plugins.md, metadata-xml-example-fields-api.md, metadata-xml-example-flows.md, metadata-xml-example-permissions.md, metadata-xml-examples.md, metadata-xml-rules.md, patterns-and-examples.md, regex-examples.md, regex-rule-schema.md, troubleshooting.md, xpath-examples.md, xpath-patterns-governor-limits.md, xpath-patterns-method-calls.md, xpath-patterns-security.md, xpath-patterns-structure.md, xpath-patterns.md`

---

## When This Skill Owns the Task

Use `dx-code-analyzer-custom-rule-create` when the work involves:
- Creating a new custom rule for Code Analyzer (any engine)
- Enforcing team-specific coding standards via static analysis
- Banning specific patterns (System.debug, hardcoded IDs, TODOs)
- Writing XPath expressions for PMD rules (Apex or metadata XML)
- Writing regex patterns for the Regex engine
- Setting up custom ESLint rules/plugins for LWC/JavaScript
- Enforcing metadata governance (API versions, field descriptions, dangerous permissions)
- Overriding built-in rule thresholds (CyclomaticComplexity, ExcessiveParameterList, etc.)
- Organizing multiple rules into shared rulesets
- Iterating on a custom rule that isn't matching correctly

Delegate elsewhere when the user is:
- Running a scan against existing rules → `dx-code-analyzer-run` skill
- Configuring engines, prerequisites, CI/CD → `dx-code-analyzer-configure` skill
- Explaining what an existing built-in rule means → `dx-code-analyzer-run` skill
- Writing Apex code or tests → `generating-apex` / `running-apex-tests` skills

---

## Required Context to Gather First

Ask for or infer:
- **What pattern to catch** — what code should be flagged? (If user selected code in their IDE, the selection IS the answer — do not re-ask.)
- **What to allow** — any exceptions? (test classes, specific contexts)
- **File scope** — which file types? (.cls, .trigger, .js, all?)
- **Severity** — how critical? (default: 3/Moderate)

If the user **selected code** (IDE selection context present), treat it as the pattern definition. Skip clarification unless genuinely ambiguous about what aspect of the selection to target.

If the request is vague with NO selection ("add a rule for best practices"), ask ONE clarifying question:
> "What specific pattern should this rule flag?"

---

## Workflow

### When User Selects Code (IDE Selection)

When the user highlights a code block in their editor and asks to "catch this", "flag this pattern", "create a rule for this", or similar:

1. **The selection IS your positive sample.** Do NOT ask "what pattern should this rule flag?" — the user already showed you. Do NOT write a new sample from scratch.
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Cross-Skill Integration

| Need | Delegate to | Reason |
|------|-------------|--------|
| Run a full scan after creating rule | `dx-code-analyzer-run` | Scan execution and result presentation |
| Install Code Analyzer / fix prerequisites | `dx-code-analyzer-configure` | Setup and troubleshooting |
| Explain an existing built-in rule | `dx-code-analyzer-run` | Rule description and docs lookup |
| Edit `code-analyzer.yml` for engine settings | `dx-code-analyzer-configure` | Configuration management |

---

## Script Execution

`<skill_dir>` is the absolute path to the directory containing this SKILL.md file.

All scripts are bundled in the `scripts/` subdirectory of the same directory that contains this SKILL.md file. Use the absolute path to that directory — do NOT use `./scripts/` as that resolves relative to the current working directory, not the skill directory.

```bash
node "<skill_dir>/scripts/create-regex-rule.js" \

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
