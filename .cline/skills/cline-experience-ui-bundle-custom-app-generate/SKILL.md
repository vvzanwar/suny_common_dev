---
name: cline-experience-ui-bundle-custom-app-generate
description: "MUST activate when the project contains a uiBundles/*/src/ directory and the task involves creating or configuring a Custom Application for hosting a UI bundle in Lightning Experience. Use this skill when creating a CustomApplication metadata record to surface the UI bundle in the App Launcher. Activate when files matching applications/*.app-meta.xml exist and need modification, or when the user wants to expose their app via the Lightning App Launcher without a Digital Experience Site. Do NOT use platform-custom-application-generate for this — UI bundle apps do not use tabs, action overrides, or flexipages."
metadata:
  version: "1.0"
  domains: ["Experience", "Platform"]
  minApiVersion: "65.0"
  relatedSkills:
    - "platform-custom-application-generate"
  cliTools:
    - tool: ["node"]
      semver: ">=18.0.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
  mcpTools:
    salesforce-api-context:
      tools: ["get_metadata_type_fields"]
      semver: ">=1.0.0"
---

# Custom Application for React UI Bundles
Create and configure a Salesforce Custom Application that hosts a React UI bundle in Lightning Experience. This skill generates the CustomApplication metadata so the app appears in the Lightning App Launcher and can be accessed by internal users.

Custom Applications differ from Experience Sites: they don't need Networks, CustomSite, DigitalExperienceConfig, or DigitalExperienceBundle metadata. The Custom Application acts as a thin launcher entry that delegates rendering to the React UI bundle referenced by `uiBundle`.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `configure-metadata-custom-application.md, patterns-and-examples.md`

---

## Generation Workflow
### Step 1: Resolve All Required Properties
Determine values for all properties before constructing anything. Use the resolution strategies in the table above.

### Step 2: Query API Context (Version-Aware Field Discovery)
Call `salesforce-api-context` MCP tools to discover which fields exist for the target org's API version. This ensures the generated metadata is compatible with the user's Salesforce version.

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Verification Checklist
Before deploying, confirm:

- [ ] All required properties are resolved
- [ ] API context was queried to determine available fields (Step 2)
- [ ] `applications/{appName}.app-meta.xml` exists with correct content
- [ ] The bundle reference field matches the org's API version (`<uiBundle>` or `<webApplication>`)
- [ ] If `target` field is supported: the **existing** `{appName}.uibundle-meta.xml` (nested at `uiBundles/{appName}/`, or flat at `uiBundles/`, whichever already existed) has `<target>CustomApplication</target>`
- [ ] No extra `.uibundle-meta.xml` file was created — exactly one `{appName}.uibundle-meta.xml` exists, at whichever path it already lived at
- [ ] Deployment validates successfully:
```bash
sf project deploy validate --metadata CustomApplication UIBundle --target-org ${usernameOrAlias}
```

## Project QA Gate Hook (Frontend Validation)
Run the deterministic project QA gate to validate LWC/SLDS guardrails and Prettier formatting:
```powershell
powershell -ExecutionPolicy Bypass -File .cline/scripts/c-run-qa-gate.ps1 -TargetFiles "<path_to_component_file>"
```
