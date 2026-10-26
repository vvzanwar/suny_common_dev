---
name: cline-platform-sharing-rules-generate
description: "Use when users get, create, edit, delete, or retrieve Salesforce Sharing Rules metadata for record-level access. TRIGGER on sharing rules, record/criteria-based/role-based/guest-user sharing, sharingCriteriaRules/sharingOwnerRules/sharingGuestRules, .sharingRules-meta.xml files, or sharing records with roles or groups, including viewing or modifying existing rules. DO NOT TRIGGER for permission sets/profiles or object-level (not record-level) security (use platform-permission-set-generate)."
metadata:
  version: "1.3"
  domains: ["Platform"]
  minApiVersion: "60.0"
  relatedSkills:
    - "platform-custom-object-generate"
    - "platform-permission-set-generate"
  cliTools:
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# Sharing Rules Generator

Get, create, edit, and delete Salesforce Sharing Rules metadata to control record-level access beyond org-wide defaults. Supports criteria-based rules, role/group-based owner rules, and guest user rules for Experience Sites.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `rule-types.md, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `create-cases.md, delete-cases.md, edit-cases.md, patterns-and-examples.md`

---

## Scope

- **In scope**: Creating, editing, deleting, and retrieving (getting) `sharingCriteriaRules`, `sharingOwnerRules`, and `sharingGuestRules` metadata; retrieving existing sharing rules from an org using the Metadata API Retrieve pattern; appending new rules to existing files; modifying rule criteria or access levels; removing rules from metadata files; configuring rules for Guest and Portal profiles.
- **Out of scope**: Changing org-wide defaults (OWD/sharing model), creating Experience Sites, configuring permission sets or profiles (use `platform-permission-set-generate`), territory-based sharing rules.

---

## Clarifying Questions

Before proceeding, confirm with the user if not already clear:

### For Get operations:
- Which object's sharing rules should be retrieved? (standard or custom object API name, or all objects)
- Which target org should the rules be retrieved from? (org alias or default)

### For Create operations:
- Which object should the sharing rule apply to? (standard or custom object API name)
- What type of rule? (criteria-based, role/group-based owner rule, or guest user rule)
- Who should records be shared with? (role name, group, portal role, or guest user nickname)
- What access level? (Read or Read/Write)
- For criteria-based rules: what field conditions should match?

### For Edit operations:
- Which existing rule should be modified? (rule fullName or label)
- What should change? (access level, criteria, label — note: `sharedTo` and `sharedFrom` cannot be edited in place)

### For Delete operations:
- Which rule(s) should be removed? (rule fullName or label)
- Confirm the object the rule belongs to

---

## Required Inputs

Gather or infer before proceeding:

- **Object API name**: The sObject the rule targets (e.g., `Account`, `Property__c`)
- **Rule type**: One of `sharingCriteriaRules`, `sharingOwnerRules`, or `sharingGuestRules`
- **Shared-to target**: Role, group, portal role, or guest user community nickname
- **Access level**: `Read` or `Edit` (maps to Read-Only or Read/Write)
- **Criteria** (for criteria/guest rules): Field name, operation, and value for each filter item

Defaults unless specified:
- Access level: `Read`
- `includeRecordsOwnedByAll`: `true` for criteria rules
- `includeHVUOwnedRecords`: `false` for guest rules
- Account sharing rules include `accountSettings` with all sub-access levels set to `None`

---

## Workflow

Steps are sequential within each phase. Phase 3 branches by operation type — execute only the matching branch. Phase 4 applies to create, edit, and delete only (get operations end at Phase 3).

### Phase 1 — Discover

1. **Resolve the SFDX project path** — find the project's `sfdx-project.json` and identify the package directory for `sharingRules/`.
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Verification Checklist

### Universal Checks
- [ ] Does the file have the XML declaration and `<SharingRules xmlns="http://soap.sforce.com/2006/04/metadata">` root?
- [ ] Is there exactly one file per object with all rules inside it?
- [ ] Does `<fullName>` use PascalCase with no spaces?

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
