---
name: platform-custom-metadata-type-generate
description: "Use to create, generate, or validate Salesforce Custom Metadata Type metadata — the __mdt object, fields, and deployable records. Trigger on custom metadata types, CMDT, __mdt objects, .md-meta.xml files, or cross-org reference/config data; also admin-maintained mapping/lookup/crosswalk tables (config that changes without a deploy belongs in a CMDT, never hardcoded in Apex/Flow), and CMDT deploy errors. DO NOT TRIGGER for Custom Settings (use platform-custom-setting-generate), business-record objects (use platform-custom-object-generate), or secrets/API keys (use a Named Credential)."
metadata:
  version: "1.0"
  minApiVersion: "60.0"
  domains: ["Platform"]
  relatedSkills:
    - "platform-custom-field-generate"
    - "platform-custom-object-generate"
    - "platform-custom-setting-generate"
    - "platform-metadata-api-context-get"
  cliTools:
    - tool: ["sf"]
      semver: ">=2.136.8"
---

# Salesforce Custom Metadata Type Generator and Validator

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `cmdt-records.md, patterns-and-examples.md`

---

## When to Use This Skill

Use this skill when you need to:

- Create a Custom Metadata Type (`__mdt`)
- Generate or validate CMDT fields, including `MetadataRelationship` fields
- Generate CMDT **records** as deployable `.md-meta.xml` files
- Troubleshoot CMDT deployment errors

---

For authoritative Metadata API type, field, and enum details beyond this skill, use the `platform-metadata-api-context-get` skill.

## 1. Overview and Purpose

A Custom Metadata Type produces **two separate artifact families**, and most requests need both:

| Artifact | Path | Metadata type |
|---|---|---|
| Type definition | `objects/<Name>__mdt/<Name>__mdt.object-meta.xml` | `CustomObject` |
| Fields | `objects/<Name>__mdt/fields/<Field>__c.field-meta.xml` | `CustomField` |
| Records | `customMetadata/<Name>.<Record>.md-meta.xml` | `CustomMetadata` |

**API name suffix:** `__mdt` on the type; fields still end in `__c`.

**The defining advantage over a custom setting: CMDT records are metadata and therefore deploy between
orgs.** When a user says configuration should "ship with the package" or "be the same in every org," CMDT
is the right answer.

> **The root element is `<CustomObject>`, but almost none of a custom object's rules apply.** `sharingModel`,
> `nameField`, and `deploymentStatus` are required or normal on a regular custom object and are **hard
> errors** here. Do not carry assumptions across from `platform-custom-object-generate`.

---

## 5. Choosing the Right Component

Before generating, confirm a CMDT is what the user needs.

| If the config is… | Use | Why |
|---|---|---|
| Reference data that must **deploy between orgs** with its records | **CMDT** (this skill) | Records are metadata |
| An admin-maintained **mapping / lookup / crosswalk** table (field↔field, code↔code, "map A to B") | **CMDT** (this skill) | Editable reference data, one record per pair |
| Admin-editable per profile/user, or org-local | `platform-custom-setting-generate` | Values are data and stay in one org |
| Business records users create and edit at runtime | `platform-custom-object-generate` | CMDT records are not transactional data |
| Translatable UI text | Custom Label — not generated here | Labels are the translation surface |
| Credentials, API keys, tokens | Named Credential / External Credential — not generated here | See Section 6 |
| A permission check in Apex or a flow | Custom Permission — not generated here | Boolean access belongs in the permission model |

The distinction that matters most: **CMDT records deploy, custom setting values do not.** If the user needs
admins to edit values per profile at runtime, that is a custom setting, not a CMDT.

> **Field-mapping and lookup tables are a canonical CMDT use case.** When a user asks to "map fields from A
> to B," maintain a code-to-code lookup, or keep a crosswalk admins can edit, model it as a CMDT — one record
> per pair (e.g. `Lead_Field__c`/`Target_Field__c`, or `MetadataRelationship` fields to `FieldDefinition`) —
> **never** a hardcoded Apex `Map`, constant, or Flow decision. Phrasing like "for conversion" or "for our
> integration" does not make it code: if admins maintain the pairs without a deploy, it is CMDT reference data.

---

## 6. Visibility, Secrets, and the No-Silent-Downgrade Rule

### `Protected` and `PackageProtected` are org-type dependent

Both deploy only in a developer, sandbox, or scratch org. Anywhere else:

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
