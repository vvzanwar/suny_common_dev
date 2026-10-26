---
name: cline-experience-lwc-generate
description: "Lightning Web Components with PICKLES methodology and 165-point scoring. Use this skill when the user creates or edits LWC components, builds wire service patterns, or writes Jest tests for LWC. TRIGGER when: user creates/edits LWC components, touches lwc/**/*.js, .html, .css, .js-meta.xml files, or asks about wire service, SLDS, or Jest LWC tests. DO NOT TRIGGER when: Apex classes (use platform-apex-generate), Aura components, or Visualforce."
metadata:
  version: "1.1"
  domains: ["Experience"]
  minApiVersion: "66.0"
  relatedSkills:
    - "agentforce-generate"
    - "automation-flow-generate"
    - "integration-connectivity-generate"
    - "platform-apex-generate"
    - "platform-apex-test-run"
    - "platform-metadata-deploy"
  cliTools:
    - tool: ["node"]
      semver: ">=18.0.0"
    - tool: ["npm"]
      semver: ">=9.0.0"
    - tool: ["npx"]
      semver: ">=9.0.0"
    - tool: ["python3"]
      semver: ">=3.9.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# experience-lwc-generate: Lightning Web Components Development

Use this skill when the user needs **Lightning Web Components**: LWC bundles, wire patterns, Apex/GraphQL integration, SLDS 2 styling, accessibility, performance work, or Jest unit tests.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `accessibility-guide.md, advanced-features.md, async-notification-patterns.md, cli-commands.md, component-patterns.md, flow-integration-guide.md, jest-testing.md, lms-guide.md, lwc-best-practices.md, patterns-and-examples.md, performance-guide.md, scoring-and-testing.md, slds-blueprints.json, slds-design-guide.md, state-management.md, template-anti-patterns.md, triangle-pattern.md`

---

## When This Skill Owns the Task

Use `experience-lwc-generate` when the work involves:
- `lwc/**/*.js`, `.html`, `.css`, `.js-meta.xml`
- component scaffolding and bundle design
- wire service, Apex integration, GraphQL integration
- SLDS 2, dark mode, and accessibility work
- Jest unit tests for LWC

Delegate elsewhere when the user is:
- writing Apex controllers or business logic first → [platform-apex-generate](../platform-apex-generate/SKILL.md)
- building Flow XML rather than an LWC screen component → [automation-flow-generate](../automation-flow-generate/SKILL.md)
- deploying metadata → [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md)

---

## Required Context to Gather First

Ask for or infer:
- component purpose and target surface
- data source: LDS, Apex, GraphQL, LMS, or external system via Apex
- whether the user needs tests
- whether the component must run in Flow, App Builder, Experience Cloud, or dashboard contexts
- accessibility and styling expectations

---

## Recommended Workflow

### 1. Choose the right architecture
Use the **PICKLES** mindset:
- prototype
- integrate the right data source
- compose component boundaries
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Output Format

When finishing, report in this order:
1. **Component(s) created or updated**
2. **Data access pattern chosen**
3. **Files changed**
4. **Accessibility / styling / testing notes**
5. **Next implementation or deploy step**

Suggested shape:

```text
LWC work: <summary>
Pattern: <wire / apex / graphql / lms / flow-screen>
Files: <paths>
Quality: <a11y, SLDS2, dark mode, Jest>
Next step: <deploy, add controller, or run tests>
```

---

## Local Development Server

Preview LWC components locally with hot reload — no deployment needed. Run the commands in `scripts/local-dev-preview.sh` to start a local dev session for a component, app, or Experience Cloud site.

Local Dev commands install just-in-time on first run. They are long-running processes that open a browser with live preview. Changes to `.js`, `.html`, and `.css` files auto-reload instantly. Requires an active org connection for data and Apex callouts.

---


*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
