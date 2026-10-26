---
name: cline-platform-custom-object-generate
description: "Use when users create, generate, or validate Salesforce Custom Object metadata. Trigger on custom objects, .object files, sharing models, name fields, or validation rules — e.g. \"create a custom object\" — and deployment errors around sharing models and Master-Detail relationships. Also keep the object's <description> current when its fields or validation rules change. Do NOT use for non-Custom-Object metadata (Apex, Flows, LWC, Permission Sets, Custom Metadata Types) or standard objects."
metadata:
  version: "1.1"
  domains: ["Platform"]
  minApiVersion: "60.0"
  relatedSkills:
    - "platform-metadata-api-context-get"
---

# platform-custom-object-generate

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `description-enrichment.md, patterns-and-examples.md`

---

## When to Use This Skill

Use this skill when you need to:
- Create new custom objects
- Generate custom object metadata XML
- Configure object sharing and security settings
- Set up object features and capabilities
- Troubleshoot deployment errors related to custom objects
- **Add, update, or delete a field OR a validation rule on an existing object** — any of these may make the object's `<description>` stale, so you must refresh it (propose + confirm). This applies equally to validation-rule changes, not just fields. See Section 3.B.

For authoritative Metadata API type, field, and enum details beyond this skill, use the `platform-metadata-api-context-get` skill.

## 1. Overview and Purpose

This document defines the mandatory constraints for generating CustomObject metadata XML (`.object-meta.xml` file). The agent must verify these constraints before outputting XML to prevent Metadata API deployment errors.

**File extension:** `.object-meta.xml`

> **Description freshness — applies to EVERY object change, fields AND validation rules:** Whenever you add, update, or delete a field **or a validation rule** on an object, the `<description>` may now be stale. Before finishing, refresh it per **Section 3.B** (propose, confirm with the user, write). A validation-rule change counts exactly like a field change — the change is **not** done until the description has been reconciled. This is easy to forget on validation-rule edits/deletes — don't.

---

## 3. Smart Defaults & Decision Logic (Tier 2)

The agent must choose which features to enable based on the object's intended use case.

### A. The Name Field Decision

| Type | When to Use | Additional Requirements |
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## 5. Verification Checklist

Before generating the Custom Object XML, verify:

### Syntactic Checks
- [ ] Are both `<label>` and `<pluralLabel>` present?
- [ ] Is `<deploymentStatus>` set to `Deployed`?
- [ ] Is `<visibility>` set to `Public`?
- [ ] Does `<nameField>` include both `<label>` and `<type>`?
- [ ] If `<type>` is `AutoNumber`, are `<displayFormat>` and `<startingNumber>` included?

### Sharing Model Check (Critical)
- [ ] Does this object have a Master-Detail relationship field?
    - If YES → `<sharingModel>` MUST be `ControlledByParent`
    - If NO → `<sharingModel>` should be `ReadWrite`

### Constraint Checks
- [ ] Is the API name free of reserved words?
- [ ] Are there 2 or fewer Master-Detail relationships?
- [ ] Is `<fullName>` absent from the XML root?

### Validation Rule Checks (if applicable)
- [ ] Do validation rule names NOT end with `__c`?
- [ ] Do validation rule names follow alphanumeric + underscore pattern?

### Description Enrichment Quality Checks
- [ ] Opens with "The {Object} object..." + business purpose (not "Object used to track and manage...")
- [ ] Uses field **labels**, never API names; no "Contains N fields including" dump
- [ ] Formulas/rollups described by behavior; validations stated as business rules; relationships as context
- [ ] Includes common use cases ("Commonly used for...") and is **under 50 words**
- [ ] Folded any current description's business context into the proposed one (didn't discard it)
- [ ] For an existing description (update/delete/re-enrich), STOPPED and waited for the user's reply before writing — did not treat showing the diff as approval

### Architectural Checks

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
