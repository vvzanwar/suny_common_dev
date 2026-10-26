---
name: platform-custom-field-generate
description: "Use when users create, generate, or validate Salesforce Custom Field metadata. Trigger on custom fields, field types, Roll-Up Summary, Master-Detail/Lookup relationships, formula fields, picklists, dependent (controlling) picklists, referencing a value set from a field, or scoping picklist values per record type; also field deployment errors, including a record type that won't deploy without a business process. DO NOT TRIGGER for creating/customizing the value set itself — a new GlobalValueSet or a StandardValueSet catalog like Industry — use platform-value-set-generate; this skill covers the field that references a value set, not the value set definition."
metadata:
  version: "1.0"
  domains: ["Platform"]
  minApiVersion: "60.0"
  relatedSkills:
    - "platform-metadata-api-context-get"
    - "platform-validation-rule-generate"
    - "platform-value-set-generate"
  mcpTools:
    metadata-grounding:
      tools: ["search_metadata"]
      semver: ">=1.0.0"
---

# Salesforce Custom Field Generator and Validator

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `advanced-picklists.md, patterns-and-examples.md`

---

## Overview

Generates and validates Salesforce CustomField metadata XML, with special handling for the **highest-failure-rate types** — Roll-Up Summary and Master-Detail. The agent must verify the constraints below before outputting XML to prevent Metadata API deployment errors.

---

## 1. Universal Mandatory Attributes

Every generated field must include these tags:

| Attribute | Requirement | Notes |
|-----------|-------------|-------|
| `<fullName>` | Required | **Field** name only: derive from `<label>` — capitalize each word, replace spaces with `_`, append `__c`. Must start with a letter. E.g., label `Total Contract Value` → `Total_Contract_Value__c`. This rule is for the FIELD name. **Picklist VALUE `<fullName>` is different — keep it exactly as the user spelled it, spaces and all, no `__c`** (e.g. `Closed Won`, NOT `Closed_Won`). See [`examples/advanced-picklists.md`](examples/advanced-picklists.md) (ref §3). |
| `<label>` | Required | The UI name (Title Case) |
| `<description>` | Always include | Explain the business reason *why* this field exists. |
| `<inlineHelpText>` | Always include | Actionable end-user guidance that adds value beyond the label (e.g., "Enter the value in USD including tax", not "The amount"). |

`<description>` and `<inlineHelpText>` are mandatory even though the Metadata API does not enforce them — omitting them yields low-quality metadata.

**File path (SFDX source format):** save each field as `force-app/main/default/objects/<Object>/fields/<FieldName>__c.field-meta.xml`, where `<Object>` is the object's API name (`Account`, `Opportunity`, or a custom `Inventory_Item__c`). A correct XML at the wrong path is never seen by the Metadata API.

### External ID Configuration

**Trigger:** If the user mentions "integration," "importing data," "external system ID," or "unique key from [System Name]," set `<externalId>true</externalId>`.

**Applicable Types:** Text, Number, Email

---

## 3. Field Data Types

### 3.1 Simple Attribute Types

| Type | `<type>` Value | Required Attributes |
|------|----------------|---------------------|
| Auto Number | `AutoNumber` | `displayFormat` (must include `{0}`), `startingNumber` |
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## 8. Verification Checklist

Before generating CustomField XML, verify:

### Universal Checks
- [ ] Does `<fullName>` use valid format and end in `__c`?
- [ ] Are `<description>` and `<inlineHelpText>` both populated and meaningful?
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Project Hooks (Schema & QA Gate)
1. **Pre-Creation Schema Hook**: Verify live org metadata before authoring or querying:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .agents/scripts/query-org.ps1 -Describe "<SObjectName>"
   ```
2. **Post-Creation QA Gate**: Validate AST guardrails, Prettier, and dry-run deployment:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .agents/scripts/run-qa-gate.ps1 -TargetFiles "<path_to_file>"
   ```
