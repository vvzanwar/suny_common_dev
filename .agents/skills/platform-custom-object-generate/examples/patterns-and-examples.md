# platform-custom-object-generate - Reference Examples, Patterns & Troubleshooting

## 4. Critical Constraints & Common Failures

### Reserved Words

Never use reserved words as API names for Custom Objects or Custom Fields:

| Category | Reserved Words (Do Not Use as API Names) |
|----------|------------------------------------------|
| SOQL/SQL | `Select`, `From`, `Where`, `Limit`, `Order`, `Group` |
| System | `User`, `External`, `View`, `Type` |
| Temporal | `Date`, `Number` |

### Relationship Cap

Do not create more than **2 Master-Detail relationships** for a single object. If a third relationship is required, use a Lookup instead.

### XML Root Element

Do NOT include the `<fullName>` tag at the root of the `.object-meta.xml` file. The API name is derived from the filename.

**INCORRECT:**
```xml
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Vehicle__c</fullName>  <!-- WRONG: Remove this -->
  <label>Vehicle</label>
</CustomObject>
```

**CORRECT:**
```xml
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Vehicle</label>
  <!-- fullName comes from filename: Vehicle__c.object-meta.xml -->
</CustomObject>
```

### Validation Rule Naming Convention

Validation rule names follow different conventions than custom fields.

**Rules:**
- Must contain only alphanumeric characters and underscores
- Must begin with a letter
- Cannot end with an underscore
- Cannot contain two consecutive underscores
- **Must NOT end with `__c`** (unlike custom fields)

**INCORRECT:**
```xml
<validationRules>
  <fullName>Require_Start_Date__c</fullName>  <!-- WRONG: Has __c suffix -->
  <active>true</active>
  <errorMessage>Start Date is required.</errorMessage>
  <formula>ISBLANK(Start_Date__c)</formula>
</validationRules>
```
**Error:** `The validation name can only contain alphanumeric characters, must begin with a letter, cannot end with an underscore...`

**CORRECT:**
```xml
<validationRules>
  <fullName>Require_Start_Date</fullName>  <!-- CORRECT: No __c suffix -->
  <active>true</active>
  <errorMessage>Start Date is required.</errorMessage>
  <formula>ISBLANK(Start_Date__c)</formula>
</validationRules>
```

**Naming Pattern Reference:**

| Metadata Type | Naming Pattern | Example |
|---------------|----------------|---------|
| Custom Fields | Ends with `__c` | `Start_Date__c` |
| Validation Rules | No suffix | `Require_Start_Date` |
| Custom Objects | Ends with `__c` | `Vehicle__c` |

---
