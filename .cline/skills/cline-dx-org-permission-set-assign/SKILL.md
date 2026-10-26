---
name: cline-dx-org-permission-set-assign
description: "ALWAYS USE THIS SKILL to assign permission sets to org users. Assign one or more permission sets to org users using the sf org assign permset command. TRIGGER when the user asks to assign, grant, give, add, or apply permission sets to users, admins, specific orgs, or specific users. Supports granting permissions, giving access, and adding permission sets to default admin or specific users via --on-behalf-of. DO NOT TRIGGER for listing permission sets or checking user permissions."
metadata:
  version: "1.0"
  domains: ["Developer Experience"]
  relatedSkills:
    - "platform-permission-set-generate"
  cliTools:
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# dx-org-permission-set-assign

Assigns one or more permission sets to org users using `sf org assign permset`. Handles all variants: default admin user, specific org targets, multiple permission sets, and assignment to specific users.

---

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `cli_flags.md, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `error_output.json, patterns-and-examples.md, success_output.json`

---

## Tool Restrictions

**Use ONLY the Bash tool** to execute `sf org assign permset`. Do NOT use MCP tools like `assign_permission_set` — ignore them completely.

---

## Scope

- **In scope**: Assigning permission sets to users via `sf org assign permset`
- **Out of scope**: Creating permission sets (use `platform-permission-set-generate`), listing permission sets, checking user permissions

---

## Required Inputs

Infer from the user's request:

- **Permission set name(s)**: Extract from user message (can be multiple)
- **Target org**: Use default unless specific alias/username mentioned
- **Target user(s)**: Default is org's default admin user; use `--on-behalf-of` if specific users mentioned

---

## Workflow

1. Match user request to command in table below
2. Execute via Bash tool: `sf org assign permset` with appropriate flags and `--json` flag
3. Return result

If error occurs, check the `failures` array in JSON output for details.

### Command Decision Table

| User intent | Execute via Bash tool |
|-------------|---------|
| Assign one permission set to default admin | `sf org assign permset --name <PermSetName> --json` |
| Assign multiple permission sets to default admin | `sf org assign permset --name <PermSet1> --name <PermSet2> --json` |
| Assign to specific org | `sf org assign permset --name <PermSetName> --target-org <alias> --json` |
| Assign to specific user(s) | `sf org assign permset --name <PermSetName> --on-behalf-of <username1> --on-behalf-of <username2> --json` |
| Assign multiple sets to specific users | `sf org assign permset --name <PermSet1> --name <PermSet2> --on-behalf-of <username1> --on-behalf-of <username2> --json` |

---

## Output Expectations

The command returns JSON output with status code and result details.

See `examples/success_output.json` and `examples/error_output.json` for response structures.

---

## Project Hooks (Schema & QA Gate)
1. **Pre-Creation Schema Hook**: Verify live org metadata before authoring or querying:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .cline/scripts/c-query-org.ps1 -Describe "<SObjectName>"
   ```
2. **Post-Creation QA Gate**: Validate AST guardrails, Prettier, and dry-run deployment:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .cline/scripts/c-run-qa-gate.ps1 -TargetFiles "<path_to_file>"
   ```
