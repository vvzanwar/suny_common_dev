# platform-custom-field-generate - Reference Examples, Patterns & Troubleshooting

## 7. Common Deployment Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `ConversionError: Invalid XML tags or unable to find matching parent xml file for CustomField` | XML comments placed before the root `<CustomField>` element | Remove XML comments (`<!-- ... -->`) that appear before `<CustomField>` in the `.field-meta.xml` file |
| `Field [FieldName] does not exist. Check spelling.` | Referenced field does not exist or has not been deployed yet | Verify the referenced field exists and is deployed before this field |
| `DUPLICATE_DEVELOPER_NAME` | Field fullName already exists on the object | Use a unique business-driven name |
| `MAX_RELATIONSHIPS_EXCEEDED` | More than 2 Master-Detail or 15 Lookup fields on the object | Use Lookup for 3rd+ Master-Detail; review Lookup count |
| Reserved keyword error | Using `Order__c`, `Group__c`, etc. | Rename to `Status_Order__c`, etc. |
| `Value set must reference a value set name or define a value set, but not both` | `<valueSet>` has both `<valueSetName>` and `<valueSetDefinition>` | Keep exactly one (see Section 3.4) |
| `duplicate value found: [X] is defined multiple times` | Two `<value>` entries share a `<fullName>` | Make every picklist value `<fullName>` unique |
| `Invalid fullName` on a picklist value | Value `<fullName>` starts with a digit or contains hyphens | Start with a letter; no hyphens, no leading digit. Spaces ARE allowed — do NOT underscore them (see §3.4 value-name fidelity) |
| `Element ...picklist is not allowed` | Deprecated ≤37.0 dependent-picklist syntax (`<picklist>`/`<picklistValues>`/`<controllingFieldValues>`) | Use the modern `valueSettings`/`controllingFieldValue`/`valueName` form (Section 3.4) |

---
