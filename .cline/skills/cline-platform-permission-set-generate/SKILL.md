---
name: cline-platform-permission-set-generate
description: "Generates correct, deployable Salesforce permission set metadata (PermissionSet XML) with object, field, user, and app permissions. Use this skill when creating or editing permission set metadata, object permissions, field-level security (FLS), tab visibility, or deploying permission sets."
metadata:
  version: "1.0"
  domains: ["Platform"]
  minApiVersion: "60.0"
---

# platform-permission-set-generate

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md`

---

## When to Use This Skill

Use when generating or editing permission set metadata, or when granting object, field, user, and app permissions.

## Step 1: Define Core Properties

Start by defining the required permission set properties:

```xml
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>YourPermissionSetName</fullName>
    <label>Display Name for Administrators</label>
    <description>Clear description of purpose and intended audience</description>
</PermissionSet>
```

**Naming conventions:**
- Use descriptive API names (e.g., `Sales_Manager_Access`)

## Step 2: Configure Object Permissions

Add CRUD permissions for standard and custom objects:

```xml
<objectPermissions>
    <allowCreate>true</allowCreate>
    <allowRead>true</allowRead>
    <allowEdit>true</allowEdit>
    <allowDelete>false</allowDelete>
    <modifyAllRecords>false</modifyAllRecords>
    <viewAllRecords>false</viewAllRecords>
    <viewAllFields>false</viewAllFields>
    <object>Account</object>
</objectPermissions>
```

## Step 3: Set Field-Level Security

Define field permissions for sensitive or custom fields:

```xml
<fieldPermissions>
    <editable>true</editable>
    <readable>true</readable>
    <field>Account.SSN__c</field>
</fieldPermissions>
```

**Important:**
- Required fields must NEVER appear in list of field permissions. Granting field-level security on required fields is not allowed by the platform and will cause deployment failure. 
- Before adding any field, confirm from the object metadata that the field exists and is not required
- A field is required when its metadata contains `<required>true</required>`:
- Formula fields cannot be editable
- Master-detail fields are required fields on the child (detail) object

```xml
<fields>
    <fullName>FieldName__c</fullName>
    <required>true</required>
</fields>
```
- Use format `ObjectName.FieldName` for field references
- Set both readable and editable to true when the user needs edit access; editable implies readable
- If all fields should be visible, can alternatively enable the "viewAllFields" object permission
- Only grant field permissions for fields the request explicitly names. Never invent a field by pattern-matching another one mentioned in the request (e.g., a request naming `BillingAddress`/`BillingCity` is not license to also add the parallel `Shipping*` fields) — an invented field can fail deployment even when the pattern-matched name looks legitimate.

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
