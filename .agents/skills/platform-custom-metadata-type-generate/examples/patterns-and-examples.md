# platform-custom-metadata-type-generate - Reference Examples, Patterns & Troubleshooting

## 7. Deployment Error Reference

Every type- and field-level error string is stated inline in Sections 2–4, next to the mistake that causes
it (`Cannot specify: <element> for Custom Metadata Type`, the unsupported-type string, `Invalid data type.`
for a formula, `Field manageability cannot be set on this entity.`, the `MetadataRelationship` controlling-
field and self-lookup errors, and the `Must specify a non-empty plural label` case).

The **full verbatim record-value catalog** — every wrong-`xsi:type` rejection, `Required fields are missing:
[MasterLabel]`, nil-on-required, the DeveloperName rules, and the exact-text traps (field named by Label not
API name, the doubled space and `i.g.` typo in the no-`xsi:type` error, `maximum length is:40` with no
space) — is in **`examples/cmdt-records.md`**.

One matching caution: the suffix here is `for Custom Metadata Type` (spaced, title case); custom settings
use `for CustomSettings`. Do not assume a shared template when matching these strings.

---
