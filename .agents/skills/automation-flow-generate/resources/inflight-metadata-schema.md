# Flow Inflight Metadata Schema & Specification

This resource defines the schema and strict naming conventions for the `inflightMetadata` parameter used in Step 1 (`fetchGroundedObjectMetadata`) of the Flow Generation Pipeline.

---

## 1. Strict Naming Convention (`inflightMetadata`)

**DATA TYPE: ARRAY (not string)**

| Property | Correct Name | Do NOT Use |
|---|---|---|
| Object API name | `apiName` | `objectApiName`, `name`, `objectName` |
| Field API name | `apiName` | `fieldApiName`, `name`, `fieldName` |
| Field type | `type` | `fieldType`, `dataType` |
| Lookup target | `referenceTo` | `relatedTo`, `lookupTo`, `reference` |

**Supported field types**: `Text`, `Textarea`, `Number`, `Picklist`, `Lookup`, `Email`, `Phone`, `URL`, `Date`, `Datetime`, `Boolean`, `Checkbox`, `Currency`, `Percent`.

---

## 2. JSON Schema Template (When Custom Objects Are Needed)

```json
[
  {
    "type": "CustomObject",
    "apiName": "CustomerRequest__c",
    "label": "Customer Request",
    "fields": [
      {
        "apiName": "Status__c",
        "type": "Picklist",
        "label": "Status",
        "values": ["New", "In Progress", "Completed"]
      },
      {
        "apiName": "Priority__c",
        "type": "Number",
        "label": "Priority"
      },
      {
        "apiName": "AssignedTo__c",
        "type": "Lookup",
        "label": "Assigned To",
        "referenceTo": "User"
      },
      {
        "apiName": "Description__c",
        "type": "Textarea",
        "label": "Description"
      },
      {
        "apiName": "Email__c",
        "type": "Email",
        "label": "Contact Email"
      },
      {
        "apiName": "DueDate__c",
        "type": "Date",
        "label": "Due Date"
      },
      {
        "apiName": "IsUrgent__c",
        "type": "Boolean",
        "label": "Is Urgent"
      },
      {
        "apiName": "Amount__c",
        "type": "Currency",
        "label": "Amount"
      }
    ],
    "relationships": []
  }
]
```

When no custom objects are needed:
```json
[]
```

---

## 3. Mandatory Decision Logic for `inflightMetadata`

1. **Scan First**: Scan the local SFDX project (or run the Pre-Creation Schema Hook) for custom objects (`__c`) and custom fields (`__c`) relevant to the flow request.
2. **If Custom Objects Are Found**: Extract and pass them as a structured JSON array matching the schema above.
3. **If No Custom Objects Are Needed**: Pass an empty array `[]` (NEVER the string `"[]"`).
4. **No Free Text**: Never pass text descriptions, instructions, or string representations inside `inflightMetadata`.
