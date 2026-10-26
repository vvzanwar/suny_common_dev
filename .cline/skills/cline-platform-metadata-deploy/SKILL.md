---
name: cline-platform-metadata-deploy
description: "Salesforce DevOps automation using sf CLI v2. TRIGGER when: user deploys metadata, creates/manages scratch orgs or sandboxes, sets up CI/CD pipelines, or troubleshoots deployment errors with sf project deploy. DO NOT TRIGGER when: writing Apex code (use platform-apex-generate), building LWC components (use experience-lwc-generate), creating metadata definitions (use platform-custom-object-generate or platform-custom-field-generate), or querying org data (use platform-data-manage)."
metadata:
  version: "1.1"
  domains: ["Platform", "Developer Experience"]
  relatedSkills:
    - "agentforce-generate"
    - "agentforce-test"
    - "automation-flow-generate"
    - "experience-lwc-generate"
    - "integration-connectivity-connected-app-configure"
    - "integration-connectivity-generate"
    - "platform-apex-generate"
    - "platform-apex-test-run"
    - "platform-custom-field-generate"
    - "platform-custom-object-generate"
    - "platform-data-manage"
  cliTools:
    - tool: ["curl"]
      semver: ">=7.0.0"
    - tool: ["git"]
      semver: ">=2.0.0"
    - tool: ["jq"]
      semver: ">=1.7.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# platform-metadata-deploy: Comprehensive Salesforce DevOps Automation

Use this skill when the user needs **deployment orchestration**: dry-run validation, targeted or manifest-based deploys, CI/CD workflow advice, scratch-org management, failure triage, or safe rollout sequencing for Salesforce metadata.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `destructiveChanges.xml, package.xml, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `agent-deployment-guide.md, deploy.sh, deployment-report-template.md, deployment-workflows.md, orchestration.md, patterns-and-examples.md, trigger-deployment-safety.md`

---

## When This Skill Owns the Task

Use `platform-metadata-deploy` when the work involves:
- `sf project deploy start`, `quick`, `report`, or retrieval workflows
- release sequencing across objects, permission sets, Apex, and Flows
- CI/CD gates, test-level selection, or deployment reports
- troubleshooting deployment failures and dependency ordering

Delegate elsewhere when the user is:
- authoring Apex code → [platform-apex-generate](../platform-apex-generate/SKILL.md)
- authoring LWC components → [experience-lwc-generate](../experience-lwc-generate/SKILL.md)
- creating custom objects or fields → [platform-custom-object-generate](../platform-custom-object-generate/SKILL.md), [platform-custom-field-generate](../platform-custom-field-generate/SKILL.md)
- building Flows → [automation-flow-generate](../automation-flow-generate/SKILL.md)
- doing org data operations → [platform-data-manage](../platform-data-manage/SKILL.md)
- authoring or testing Agentforce agents → [agentforce-generate](../agentforce-generate/SKILL.md)

---

## Required Context to Gather First

Ask for or infer:
- target org alias and environment type
- deployment scope: source-dir, metadata list, or manifest
- whether this is validate-only, deploy, quick deploy, retrieve, or CI/CD guidance
- required test level and rollback expectations
- whether special metadata types are involved (Flow, permission sets, agents, packages)

Preflight checks:
```bash
sf --version
sf org list
sf org display --target-org <alias> --json
test -f sfdx-project.json
```

---

## Recommended Workflow

### 1. Preflight
Confirm auth, repo shape, package directories, and target scope.

### 2. Validate first
```bash
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Cross-Skill Integration

| Need | Delegate to | Reason |
|---|---|---|
| custom object creation | [platform-custom-object-generate](../platform-custom-object-generate/SKILL.md) | define objects before deploy |
| custom field creation | [platform-custom-field-generate](../platform-custom-field-generate/SKILL.md) | define fields before deploy |
| Apex authoring / fixes | [platform-apex-generate](../platform-apex-generate/SKILL.md) | code authoring and repair |
| run tests after deployment | [platform-apex-test-run](../platform-apex-test-run/SKILL.md) | post-deploy test execution and coverage |
| Flow creation / repair | [automation-flow-generate](../automation-flow-generate/SKILL.md) | Flow authoring and activation guidance |
| test data or seed records | [platform-data-manage](../platform-data-manage/SKILL.md) | describe-first data setup and cleanup |
| Agent authoring and publish readiness | [agentforce-generate](../agentforce-generate/SKILL.md) | agent-specific correctness |

---

## Completion Format

```text
Deployment goal: <validate / deploy / retrieve / pipeline>
Target org: <alias>

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
