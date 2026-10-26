---
name: cline-platform-sharing-owd-configure
description: "Use when the user wants to retrieve or update Organization-Wide Default (OWD) sharing settings for Salesforce objects. TRIGGER on org-wide defaults, checking/viewing sharing defaults, changing default access levels (Private, Public Read Only, Public Read/Write, Controlled by Parent), internal/external access for standard or custom objects, making records private, or sharingModel in .object-meta.xml files. DO NOT TRIGGER for sharing rules, criteria-based sharing, role hierarchy, or manual sharing — delegate to platform-sharing-rules-generate."
metadata:
  relatedSkills:
    - "platform-metadata-deploy"
    - "platform-sharing-rules-generate"
  version: "1.2"
  domains: ["Platform"]
  cliTools:
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# Managing Org-Wide Defaults

Retrieve and update Organization-Wide Default (OWD) sharing settings for standard and custom objects in a Salesforce org. OWDs define the baseline level of access users have to records they do not own.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `access_levels.md, metadata_api_approach.md, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `get_owd_output.md, patterns-and-examples.md, update_owd_output.md`

---

## Scope

- **In scope**: Retrieving current OWD settings, updating internal/external access levels for standard and custom objects
- **Out of scope**: Sharing rules, role hierarchy configuration, manual sharing, permission sets, criteria-based sharing — delegate to appropriate skills

---

## Clarifying Questions

Before proceeding, confirm with the user if not already clear:

- Which object(s) do you want to get or update OWD settings for?
- What access level do you want to set? (Private, Public Read Only, Public Read/Write, Controlled by Parent)
- Do you need to change both internal and external access, or just one?

---

## Required Inputs

Gather or infer before proceeding:

- **Target org**: The org alias or username to query/update (use default org if not specified)
- **Object name(s)**: Standard object API name (e.g., `Account`, `Contact`) or custom object API name (e.g., `Invoice__c`)
- **Operation**: Get (retrieve current settings) or Update (change access levels)
- **Access levels** (for update): Internal access and/or external access values

Defaults unless specified:
- Use the default connected org
- If only one access level is provided, assume it applies to internal access

---

## Workflow

All steps are sequential. Do not skip or reorder.

### Phase 1 — Retrieve Current Settings

1. **Query current OWD settings** using the Salesforce CLI Tooling API:
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Output Expectations

Deliverables:
- **For get operations**: Formatted table showing object name, internal access level, and external access level
- **For update operations**: Confirmation of the change with before/after comparison

---

## Cross-Skill Integration

| Need | Delegate to |
|------|-------------|
| Creating sharing rules after restricting OWD | `platform-sharing-rules-generate` skill |
| Deploying metadata changes to another org | `platform-metadata-deploy` skill |

---

## Project Hooks (Schema & QA Gate)
1. **Pre-Creation Schema Hook**: Verify live org metadata before authoring or querying:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .cline/scripts/c-query-org.ps1 -Describe "<SObjectName>"
   ```
2. **Post-Creation QA Gate**: Validate AST guardrails, Prettier, and dry-run deployment:
   ```powershell

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
