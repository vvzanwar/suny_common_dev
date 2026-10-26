---
name: cline-automation-flow-generate
description: "Generate Salesforce Flows using the MCP tool execute_metadata_action. Use when the user asks to create, build, or generate a flow â€” including Screen, Autolaunched, Record-Triggered (before/after-save), Scheduled. Also trigger for flow-like requests such as \"when a record is created\", \"trigger daily at\", \"send an email when\", \"update the field when\", \"automate\", \"workflow\", or \"flow XML/metadata\". This is the only skill for Salesforce Flow generation."
metadata:
  version: "2.0"
  domains: ["Automation"]
  minApiVersion: "60.0"
  mcpTools:
    metadata-experts:
      tools: ["execute_metadata_action"]
      semver: ">=1.0.0"
---

# Generating Salesforce Flows

Generate Salesforce Flow metadata by running the mandatory 3-step MCP pipeline (`fetchGroundedObjectMetadata` -> `flowElementSelection` -> `flowElementGeneration`).

## 1. Quick Reference & Assets

* **Inflight Metadata Schema & Custom Object Specification**: Consult [`resources/inflight-metadata-schema.md`](resources/inflight-metadata-schema.md) for the exact `inflightMetadata` JSON schema and strict property naming rules (`apiName`, `type`, `referenceTo`).
* **Flow Pattern Guidance & Tool Call Examples**: Consult [`examples/flow-pipeline-examples.md`](examples/flow-pipeline-examples.md) for Scheduled/Autolaunched patterns, multi-flow sequential splitting, and complete Step 1â€“3 JSON payloads.

---

## 2. Mandatory 3-Step Flow Generation Pipeline

All 3 steps MUST be called sequentially via the `execute_metadata_action` MCP tool. Never manually author Flow XML outside this pipeline.

### Pre-Creation Schema Hook (When Custom Objects Are Involved)
Before building `inflightMetadata` for custom objects (`__c`) or custom fields (`__c`), verify the live org schema:
```powershell
powershell -ExecutionPolicy Bypass -File .cline/scripts/c-query-org.ps1 -Describe "<SObjectName>"
```

### Step 1: Fetch Grounded Object Metadata (`action: "fetchGroundedObjectMetadata"`)
* **Inputs**:
  - `userPrompt` (STRING): Single-flow natural language request (split multi-flow requests into separate sequential pipelines; see [`examples/flow-pipeline-examples.md`](examples/flow-pipeline-examples.md)).
  - `inflightMetadata` (ARRAY): Array of custom object definitions per [`resources/inflight-metadata-schema.md`](resources/inflight-metadata-schema.md), or `[]` if only standard objects are used. Never pass `"[]"` as a string.
* **Output**: `groundingMetadata` (STRING â€” pass directly to Step 2 without re-serializing).

### Step 2: Flow Element Selection (`action: "flowElementSelection"`)
* **Inputs**:
  - `userPrompt` (STRING): Exact same prompt passed to Step 1.
  - `groundingMetadata` (STRING): Exact string returned from Step 1.
  - `operationId` (STRING): `""` (empty string on initial call).
* **Output**: `operationId` (STRING â€” pass to Step 3).

### Step 3: Flow Element Generation (`action: "flowElementGeneration"`)
* **Inputs**:
  - `operationId` (STRING): From Step 2 output.
  - `requestSource` (STRING): Always `"A4V"` for XML output.
* **Loop Requirement**: Call repeatedly in a loop without pausing or asking the user until `isComplete` is `true` (or an error occurs). Extract the final Flow XML from `result` only when `isComplete == true`.

---

## 3. Critical Verification Checklist

- [ ] **Strict 3-Step Pipeline**: Called `fetchGroundedObjectMetadata` -> `flowElementSelection` -> `flowElementGeneration` in order.
- [ ] **No Manual XML Edits**: Returned XML is unmodified (unless explicitly fixing a user-reported deployment error).
- [ ] **Single Flow Per Pipeline**: Multi-flow prompts are split and executed sequentially one full pipeline at a time.
- [ ] **Valid `inflightMetadata`**: Passed as an ARRAY (`[]` or structured objects per [`resources/inflight-metadata-schema.md`](resources/inflight-metadata-schema.md)).
- [ ] **Canvas Mode Check**: Net-new canvas flows carry `<processMetadataValues>` `CanvasMode`=`AUTO_LAYOUT_CANVAS` (surface pipeline gap if missing; do not hand-edit).
