---
name: cline-platform-role-hierarchy-apply
description: "Bulk-realign an existing Salesforce UserRole hierarchy from an external org-chart artifact (PDF, xlsx, or plain-text list of role-and-parent pairs) in one admin-approved manifest. Clarify scope and whether users move with roles, resolve identities that do not match verbatim, diff the artifact against the current tree, and submit create, rename, reparent, empty-role delete, and user-assignment mutations together. Triggers on \"reorganize the role hierarchy\", \"apply this org chart to roles\", \"bulk update role parents\", \"realign roles from PDF\", \"restructure the role hierarchy\", \"reparent roles from this spreadsheet\". Do not trigger for a single role create, rename, or reparent with no other changes, or for asking which roles exist or how they are nested — that is `managing-roles`. Do not trigger for territory, account, or forecast hierarchies, or for authoring sharing rules."
metadata:
  version: "1.0"
---

# Role Hierarchy Restructure

Apply many UserRole changes from an artifact in one admin-approved manifest.

If the admin only asks which roles exist or how they are nested, hand off to `managing-roles`. Do not query, do not ask the step 0 questions, and do not submit.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md`

---

## Inputs

- PDF org chart (text-selectable), `.xlsx` / `.csv` with `role_name` and `parent_role_name` (empty parent = top-level), or plain text with one `Role: Parent` pair per line.
- Or a pre-parsed list of `{roleName, parentRoleName}` objects.
- Optional mapping hints when a chart name is not the org's `Name` or `DeveloperName`.

## Flow

### 0. Clarify before querying

Ask anything still unresolved. Do not guess.

- **Scope.** Default is selected branches: roles absent from the artifact stay. "Full hierarchy" still does not delete those roles unless the admin asked for each deletion.
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Out of scope

- A single role create, rename, or reparent with no other changes, and any request that only asks which roles exist or how they are nested (`managing-roles`).
- Territory, account, and forecast hierarchies.
- Authoring sharing rules.
- Image-only PDFs. Ask for text.
- Rollback. Report what the response says was committed.
---

<!-- skill-validate: ignore-start -->
<!-- codey:operations start -->
