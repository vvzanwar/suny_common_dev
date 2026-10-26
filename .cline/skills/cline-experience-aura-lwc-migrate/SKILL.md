---
name: cline-experience-aura-lwc-migrate
description: "Use this skill to analyze a Salesforce Aura component bundle (.cmp, .app, .evt, .intf, Controller.js, Helper.js, Renderer.js) and produce a framework-agnostic migration blueprint (PRD.yaml / PRD.md / PRD.json) capturing public API, data requirements, slots, events, states, accessibility, styling, localization, and security posture. This is Phase 1 (analysis + PRD) only — it does NOT author or edit component code, wire adapters, or Jest tests, and does not write .html/.js/.css/.js-meta.xml. TRIGGER when the user says \"analyze this Aura component\", \"migrate Aura\", \"convert .cmp\", \"produce a migration blueprint\", \"generate a PRD for this Aura component\", or mentions aura:attribute, aura:handler, force:recordData, $Label, $Resource, component.get, cmp.find, or an input directory containing .cmp files. DO NOT TRIGGER when there is no Aura source (delegate downstream LWC authoring to experience-lwc-generate), for post-migration scoring, or for refactoring an existing modern component."
metadata:
  version: "1.0"
  domains: ["Experience"]
  relatedSkills:
    - experience-lwc-generate
---

<!-- adk-managed-skill -->

# Migrating Aura to LWC

Migrate an existing Salesforce Aura component bundle to a Lightning Web Component using a PRD-driven workflow. The Aura source is analyzed through eight expert lenses (static references, data, API surface, slots, styling, default values, unknown dependencies, redundant-code cleanup) to produce a framework-agnostic PRD, which is handed to the LWC authoring skills and verified against the Aura→LWC completeness checklist.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `aura-api-expert.md, aura-data-expert.md, aura-migration-guidelines.md, aura-prd-framework.md, aura-redundant-code-expert.md, aura-reference-expert.md, aura-resolver-expert.md, aura-slots-expert.md, aura-style-expert.md, aura-to-lwc-completeness-checklist.md, aura-values-expert.md, patterns-and-examples.md`

---

## When to Use

- Porting an Aura bundle (`.cmp`, `.controller.js`, `.helper.js`, `.renderer.js`, `.css`, `.design`, `.evt`, `.intf`) to LWC.
- Producing a framework-agnostic PRD from Aura source so a sibling team can implement the LWC equivalent.
- Auditing an Aura component for patterns that need explicit mapping before LWC conversion (facets, `aura:id` DOM access, `force:recordData`, application events).

Do NOT use this skill for:
- Authoring a brand-new LWC from a Figma or PRD with no Aura source (delegate to `experience-lwc-generate`).
- Refactoring an existing LWC (delegate to `experience-lwc-generate`).
- Post-hoc completeness scoring of a conversion that was already done without this skill, or Lightning Out Beta → 2.0 host-page migration — no checked-in skill covers these today.

## Prerequisites

- Aura component bundle files (minimum: `.cmp`; usually also controller / helper / CSS / events / interfaces).
- Target LWC path (module folder) — discover the caller's module tree from `sfdx-project.json` `packageDirectories` (typically an `lwc/<name>/` subdirectory under one of the listed package paths).
- For resolver-assisted dependency lookup (Phase 2, step 7): the `@sfdc-internal/adk-knowledge` package installed in the caller's workspace. If it is not present, the skill surfaces the missing dependency as an unknown rather than failing.
- Awareness of the project's downstream LWC authoring flow — this skill hands off a PRD to that flow but does not invoke it.

## Core Principles

Apply the Aura → LWC migration principles before and during each phase: understand before converting, prioritize functionality equivalence over structural equivalence, leverage native web standards, migrate iteratively, and test thoroughly. The architectural deltas (two-way → one-way binding, Aura events → DOM events, `aura:id` → `this.template.querySelector`, etc.) are documented in [examples/aura-migration-guidelines.md](examples/aura-migration-guidelines.md).

## Knowledge Bases

- [examples/aura-prd-framework.md](examples/aura-prd-framework.md) — the 14-section framework for drafting a framework-agnostic PRD from an Aura component.
- [examples/aura-migration-guidelines.md](examples/aura-migration-guidelines.md) — core principles + Aura-vs-LWC architectural differences + markup / JS / event / lifecycle translation tables.
- [examples/aura-reference-expert.md](examples/aura-reference-expert.md) — static resources, global value providers, HTML-to-generic wording, URLs, component dependencies, `Aura.Action` handlers.
- [examples/aura-data-expert.md](examples/aura-data-expert.md) — data requirements, `force:recordData`, `lightning:recordViewForm`, Apex controllers.
- [examples/aura-api-expert.md](examples/aura-api-expert.md) — API surface: public attributes, methods, layout, component events, DOM events.
- [examples/aura-slots-expert.md](examples/aura-slots-expert.md) — default and named slots (Aura facets / `{!v.body}` → LWC slots).
- [examples/aura-style-expert.md](examples/aura-style-expert.md) — CSS, SLDS, design tokens, dynamic styling.
- [examples/aura-values-expert.md](examples/aura-values-expert.md) — default values and initialization patterns.
- [examples/aura-resolver-expert.md](examples/aura-resolver-expert.md) — resolving unknown components, events, interfaces, and libraries via the `@sfdc-internal/adk-knowledge` package.
- [examples/aura-redundant-code-expert.md](examples/aura-redundant-code-expert.md) — strip Aura-only noise (commented-out code, telemetry, unused private attributes/methods) from the PRD before LWC handoff.
- WCAG 2.2 — Aura-scoped accessibility reviewers (SC 1.3.1 (ii) Tables, 1.3.5 Identify Input Purpose, 3.2.1 On Focus, 3.2.2 On Input, 3.3.2 Labels or Instructions, 4.1.2 Name / Role / Value) are planned to land as a separate `accessibility-code-review-aura` skill in a follow-up PR; until then, Phase 3 applies the WCAG preamble inline.
- [examples/aura-to-lwc-completeness-checklist.md](examples/aura-to-lwc-completeness-checklist.md) — post-conversion verification rubric.

Open the relevant reference before drafting or enhancing the corresponding PRD section.

## Workflow

This skill covers the analysis and PRD-generation phases only. It **does not** produce, edit, or validate LWC bundles, wire adapters, or tests. Phases 1–3 below are mandatory when this skill is invoked. Phases 4–5 describe the recommended downstream authoring flow — they are informational follow-up guidance for the caller and are NOT executed by this skill.

### Phase 1 — Analyze and draft the PRD

**Goal:** produce a draft YAML PRD that captures every section of the 14-section framework.
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Verification (PRD-only)

- The enhanced PRD covers all 14 framework sections with no `TODO` / placeholder entries.
- `dataRequirements` contains no direct references to `force:recordData` or `lightning:recordViewForm`, and no `sObjectName` keys (renamed to `objectApiName`).
- `staticReferences` and other sections contain no raw Aura strings like `$Resource`, `$Label`, `$ContentAsset`, `$Browser`, `$Locale`.
- Every `<aura:method>` appears in `interactions` with the corresponding trigger.
- Every `{!v.body}` / `{#v.body}` appears in `contentRequirements` as a default slot (with the presence condition).
- Every `<aura:attribute type="Aura.Component">` appears in `contentRequirements` as a named slot.
- Every unknown has been resolved via the `@sfdc-internal/adk-knowledge` package (or marked as manually-required with the attempted knowledge-file path).

## Project QA Gate Hook (Frontend Validation)
Run the deterministic project QA gate to validate LWC/SLDS guardrails and Prettier formatting:
```powershell
powershell -ExecutionPolicy Bypass -File .cline/scripts/c-run-qa-gate.ps1 -TargetFiles "<path_to_component_file>"
```
