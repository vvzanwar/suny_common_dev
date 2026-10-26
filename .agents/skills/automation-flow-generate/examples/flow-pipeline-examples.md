# Flow Pattern Guidance & Pipeline Tool Call Examples

This reference contains concrete examples and prompt patterns for the 3-step Flow Generation Pipeline (`fetchGroundedObjectMetadata` -> `flowElementSelection` -> `flowElementGeneration`).

---

## 1. Flow Pattern Guidance

Make the intent explicit in the `userPrompt` passed to Step 1 and Step 2:

* **Scheduled Flows ("daily", "weekly", "every Sunday at 10PM")**:
  - Trigger lives on `<start>` (`triggerType: Scheduled`) with `<schedule>` (`<frequency>`, `<startDate>`, `<startTime>`).
  - Put record criteria in `<start>` filters (`<object>` and `<filters>`) rather than adding a manual Loop over the triggering object.
* **Autolaunched Flows ("autolaunched", "no-trigger")**:
  - Builds a no-trigger flow (no `triggerType`, `object`, or `<schedule>` on `<start>`). Put iteration/timing logic in the body.
* **Counting Related Records ("count all related X")**:
  - Use a single assignment element with `<operator>AssignCount</operator>` from the collection into a Number variable.
* **No Unrequested Actions**:
  - Generate only the elements requested. Never invent unrequested Chatter posts or email alerts.

---

## 2. Multi-Flow Requests (Sequential Split Pattern)

**WRONG — Clubbing multiple flows into a single `userPrompt`:**
```json
{
  "userPrompt": "Create flows for the app: 1) Record-Triggered Flow on ResourceAllocation__c. 2) Screen Flow to allocate resources. 3) Record-Triggered Flow on Supply__c."
}
```

**CORRECT — Separate 3-step pipeline for EACH flow executed sequentially:**

* **Flow 1 — Step 1 (`fetchGroundedObjectMetadata`)**:
  ```json
  {
    "userPrompt": "Create a Screen Flow named Tenant_Onboarding that captures tenant details, selects a Unit__c with Status__c = 'Vacant', creates Lease__c...",
    "inflightMetadata": [...]
  }
  ```
  *(Complete Step 2 and loop Step 3 until `isComplete: true` before starting Flow 2)*

* **Flow 2 — Step 1 (`fetchGroundedObjectMetadata`)**:
  ```json
  {
    "userPrompt": "Create an Autolaunched Flow named Generate_Onboarding_Checklist that given a Lease__c Id input, queries OnboardingTask__c...",
    "inflightMetadata": [...]
  }
  ```

---

## 3. End-to-End Tool Call Examples

### Example 1: Standard Objects Only (`inflightMetadata: []`)

**Step 1 — `fetchGroundedObjectMetadata`:**
```json
{
  "userPrompt": "Create a scheduled-triggered Flow named Daily_Good_Morning that runs daily at 6:00 AM and sends an email to the running user saying good morning.",
  "inflightMetadata": []
}
```

**Step 2 — `flowElementSelection`:**
```json
{
  "userPrompt": "Create a scheduled-triggered Flow named Daily_Good_Morning that runs daily at 6:00 AM and sends an email to the running user saying good morning.",
  "groundingMetadata": "<groundingMetadata string from Step 1 — pass directly, do not serialize again>",
  "operationId": ""
}
```

**Step 3 — `flowElementGeneration` (call in a loop until `isComplete == true`):**
```json
{
  "operationId": "<operationId from Step 2>",
  "requestSource": "A4V"
}
```

---

### Example 2: Custom Objects (`__c`) from Local Project

**Step 1 — `fetchGroundedObjectMetadata`:**
```json
{
  "userPrompt": "Create a flow that updates the status of a Customer Request when it's assigned",
  "inflightMetadata": [
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
          "apiName": "AssignedTo__c",
          "type": "Lookup",
          "label": "Assigned To",
          "referenceTo": "User"
        }
      ],
      "relationships": []
    }
  ]
}
```

**Step 2 & Step 3**: Follow the exact same sequence as Example 1.
