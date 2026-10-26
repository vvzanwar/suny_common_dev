# platform-custom-object-generate - Technical Specifications, Rules & Schemas

## Specification

---

## 2. Syntactic Essentials (Tier 1)

The following constraints must be true for the XML body to deploy successfully.

**Note:** The API Name (fullName) is NOT a tag; it is the filename (e.g., `Vehicle__c.object-meta.xml`).

### Required Elements

| Element | Requirement | Notes |
|---------|-------------|-------|
| `<label>` | Required | Singular UI name |
| `<pluralLabel>` | Required | Plural UI name |
| `<sharingModel>` | Required | See Sharing Model Rules below |
| `<deploymentStatus>` | Required | Always set to `Deployed` |
| `<nameField>` | Required | Primary record identifier (requires `<label>` and `<type>`) |
| `<visibility>` | Required | Always set to `Public` |

### Sharing Model Rules

**Default:** Set `<sharingModel>` to `ReadWrite`.

**Exception:** If this object contains a Master-Detail relationship field, `<sharingModel>` MUST be `ControlledByParent`.

**Decision Logic:**
- IF object has NO Master-Detail field → use `ReadWrite`
- IF object has Master-Detail field → use `ControlledByParent`
- IF a Master-Detail field is being added to an existing child object → that existing object's `<sharingModel>` must also be updated to `ControlledByParent`

**INCORRECT** — Will cause error: `Cannot set sharingModel to ReadWrite on a CustomObject with a MasterDetail relationship field`
```xml
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Order Line Item</label>
  <pluralLabel>Order Line Items</pluralLabel>
  <sharingModel>ReadWrite</sharingModel>  <!-- WRONG: Object has a M-D field -->
  <deploymentStatus>Deployed</deploymentStatus>
</CustomObject>
```

**CORRECT:**
```xml
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Order Line Item</label>
  <pluralLabel>Order Line Items</pluralLabel>
  <sharingModel>ControlledByParent</sharingModel>  <!-- CORRECT -->
  <deploymentStatus>Deployed</deploymentStatus>
</CustomObject>
```

---

---

## 3. Smart Defaults & Decision Logic (Tier 2)

The agent must choose which features to enable based on the object's intended use case.

### A. The Name Field Decision

| Type | When to Use | Additional Requirements |
|------|-------------|------------------------|
| **Text** | Default for human-named entities (Projects, Locations, Teams) | None |
| **AutoNumber** | Use for transactions, logs, or IDs (Invoices, Requests, Tickets) | Must include `<displayFormat>` (e.g., `INV-{0000}`) and `<startingNumber>1</startingNumber>` |

**Text Name Field Example:**
```xml
<nameField>
  <label>Project Name</label>
  <type>Text</type>
</nameField>
```

**AutoNumber Name Field Example:**
```xml
<nameField>
  <label>Invoice Number</label>
  <type>AutoNumber</type>
  <displayFormat>INV-{0000}</displayFormat>
  <startingNumber>1</startingNumber>
</nameField>
```

### B. Object Description (Enrichment)

**`<description>`**: **Mandatory** — every Custom Object MUST have one. It must read like human-written documentation, **never** a generic template ("Object used to track and manage...") or a metadata dump ("Contains 8 fields including `Project_Name__c`...").

**Always compose an enriched description** — when creating the object, and again on **any** change to it: adding, updating, or deleting a field **or a validation rule** (so it never goes stale). The change — field or validation rule — is never "done" until you've refreshed the object's description. This is not optional; do not ask *whether* to add a description.

**Confirm per change — every time.** Propose and confirm on **each** field/rule change separately. A previous "keep current" applies **only** to that one change; it is **never** standing permission to skip the proposal on a later change. Do not infer a preference from an earlier answer — re-propose and re-ask for every new change.

**Compose** the description (steps below). If the object already has one, use it as a **strong signal** — preserve the business context it carries (domain, team, intent the schema can't reveal) and fold the new field/rule in rather than discarding it.

Then branch on whether a description already exists:

- **No existing description (brand-new object):** there is nothing to overwrite — just write the composed description. **Do not prompt.**
- **An existing description (update, delete, or any re-enrichment):** never overwrite it silently — you can't tell from the file whether it was hand-written by an admin or generated earlier. Show the proposal, ask, and **STOP — wait for the user's reply before writing:**
   > Proposed description for `{Object}`:
   > `<the enriched description>`
   > Current: `<the existing description>`
   > Use this? (yes / keep current / edit)

  **You MUST NOT write the `<description>` until the user replies** — showing the diff is not approval, even when the change looks obvious or minor. Then act: *yes* → write the proposed text · *keep current* → leave the existing one untouched (this applies to **this change only** — re-propose on the next one) · *edit* → use the user's wording.

Always end with a `<description>` written.

**Composing the description:**

1. **Classify each field** by how it appears in the description:
   - **Constrained** (required, unique, externalId, restricted picklist) → selective parenthetical: `VIN (required, external ID)`, `Color (Red/Green only)`
   - **Behavioral** (formula, roll-up) → describe what it computes: "the Age Years field auto-calculates vehicle age"
   - **Relationship** (master-detail, lookup) → woven context: "as a child of Account" (never "(Master-Detail to Account)")
   - **Standard** → label only
2. **Compose** in this order, using field **labels not API names**:
   > Purpose → key fields → computed fields → validation rules (as business rules) → "Commonly used for {use cases}."
3. **Count and trim before writing (required):** count the words; aim ~45, hard ceiling 50. If over, tighten wording first, then drop whole sentences in priority order (use cases → rules → computed; never drop sentences 1–2). Recount. Do not write until ≤ 50.

**Example (Car, 46 words):**
```xml
<description>The Car object tracks vehicle inventory and maintenance. It captures Year, VIN (required, external ID), Color (Red/Green only), and Location; the Age Years field auto-calculates vehicle age. VIN is required and Black cars cannot be sold. Commonly used for fleet management, inventory tracking, and service scheduling.</description>
```

→ For the full workflow and examples, read **`examples/description-enrichment.md`**.

### C. Junction Object Naming

If the object is a many-to-many link between two parents, name the object by combining the two parent entities to ensure the schema remains intuitive.

**Examples:**
- `Position_Candidate__c` (links Position and Candidate)
- `Job_Application__c` (links Job and Application)

### D. Feature Enablement (Clean XML)

To maintain "Clean XML," only include optional tags when deviating from the Salesforce platform default of `false`.

**Scenario A: User-Facing Objects (Apps, Trackers, Business Entities)**
- Trigger: The object is intended for direct user interaction
- Action: Set `<enableSearch>`, `<enableReports>`, `<enableActivities>`, and `<enableHistory>` to `true`

**Scenario B: System-Facing Objects (Junctions, Background Logs)**
- Trigger: The object exists for technical associations or background data
- Action: Omit these tags to keep the UI clean and the XML lean

---

---

## Reference File Index

| File | When to read |
|------|-------------|
| `examples/description-enrichment.md` | Composing or refreshing an object's `<description>` (on create, or when a field/rule changes) — full enrichment workflow, field-prioritization tiers, junction/child handling, edge cases, and more examples |
