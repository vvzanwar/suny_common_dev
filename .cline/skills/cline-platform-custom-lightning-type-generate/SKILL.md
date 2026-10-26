---
name: cline-platform-custom-lightning-type-generate
description: "Use this skill when users need to create Custom Lightning Types (CLTs) for Einstein Agent actions or structured input/output schemas. Trigger when users mention CLT, Custom Lightning Types, JSON schemas for agents, type definitions, lightning__objectType, or editor/renderer configurations. For widget renditions that combine a CLT with a Widget bundle, use the platform-lightning-type-widget-coordinate orchestrator instead. This is complex - always use this skill for CLT work."
metadata:
  version: "1.1"
  domains: ["Platform", "Agentforce"]
  minApiVersion: "60.0"
  relatedSkills:
    - "platform-lightning-type-widget-coordinate"
    - "platform-mcp-tool-widget-coordinate"
    - "platform-widget-generate"
---

# platform-custom-lightning-type-generate

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `primitive-types-and-constraints.md, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md, widget-rendition.md`

---

## When to Use This Skill

Use this skill when you need to:
- Create Custom Lightning Types (CLTs) for structured inputs/outputs
- Generate JSON Schema-based type definitions for Lightning Platform
- Configure CLTs for Einstein Agent actions
- Set up editor and renderer configurations for custom UI
- Troubleshoot deployment errors related to Custom Lightning Types

## Overview & Purpose
Custom Lightning Types (CLTs) are JSON Schema-based type definitions used by the Lightning Platform (including Einstein Agent actions) to describe structured inputs/outputs and drive editor/renderer experiences.

## Configuration
- **Choose referenced CLT pattern for nested objects** - When you need a **reusable** or **separately deployed** nested type, create a CLT for that shape and reference it with `"lightning:type": "c__<CLTName>"`. That string is the referenced type’s **`lightning:type` value / FQN / registered identifier** — not the JSON Schema `title`.
- **Choose standard Lightning types** when the structure is simple and can be expressed with properties and supported primitive `lightning:type` identifiers.
- **Choose Apex class types** (`@apexClassType/...`) when the structure already exists server-side and you want the Apex class to define the shape.
- **Include editor/renderer config** only when you need custom UI behavior (custom LWC input/output components). Otherwise, omit.

## Additional CLT Metaschema Validations
- **Org namespace validation**: titles/descriptions and other string fields may be validated to ensure you are not using an org namespace in places that are disallowed.
- **Lightning type validation**: CLTs are validated to prevent referencing internal namespaces (for example, disallowing types from internal namespaces like `sfdc_cms` where not permitted).
- **Object type validation**: the CLT root is validated to ensure `lightning:type` is exactly `lightning__objectType`.

## Generation Workflow
1. **Confirm the CLT approach**
   - If referencing Apex: capture the exact class reference (@apexClassType/namespace__ClassName$InnerClass).
   - If using standard primitives: list the fields, their Lightning primitive types, and which fields are required.
2. **Draft `schema.json`**
   - **DO NOT include `"$schema"` at the top**
   - Start with the root object structure (required root fields).
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Verification Checklist
- [ ] Root schema has `type: "object"`, `title`, `lightning:type: "lightning__objectType"`, and `unevaluatedProperties: false`
- [ ] Root schema does not include `examples` when strict validation is enabled
- [ ] No nested object includes `lightning:type: "lightning__objectType"`
- [ ] Arrays are defined minimally (especially nested arrays)
- [ ] Only supported primitive `lightning:type` identifiers are used for leaf properties
- [ ] Apex class CLTs contain only `title`/`description` and `lightning:type: "@apexClassType/..."`
- [ ] Bundle structure and filenames match Lightning Types requirements
- [ ] Editor config uses only allowed patterns (no `es_property_editors/inputList`, no `itemSchema`); use valid components (e.g. `es_property_editors/inputText`, `es_property_editors/inputNumber`) or custom `c/` components
- [ ] Renderer config uses output-style components (e.g. `es_property_editors/outputText`, `es_property_editors/outputNumber`) where applicable, not input editors
- [ ] Layout configurations use `lightning/propertyLayout` with ONLY the `property` attribute (no `label`, `title`, or other attributes)
- [ ] All attribute mappings (`{!$attrs.propertyName}`) reference properties that exist in the type schema
- [ ] Custom LWC components have correct targets in `-meta.xml`: `lightning__AgentforceInput` for editors, `lightning__AgentforceOutput` for renderers
- [ ] Root schema does NOT include `"$schema"` field
