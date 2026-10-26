---
name: experience-lwc-design-generate
description: "Use when you need to create a brand new Lightning Web Component from a Figma design, a Product Requirements Document, or another design artifact — orchestrating the five-phase workflow (gather requirements → generate code → optimize → lint/format/compile → test) and stitching together the specialized skills for SLDS, LDS, base components, optimization, and testing. Use this skill whenever the user mentions building a new LWC from Figma, building an LWC from a PRD, generating an LWC from a design or screenshot, or migrating an Aura component as a fresh LWC build. DO NOT TRIGGER when refactoring an existing LWC (use experience-lwc-generate), for Aura → LWC in-place migration (out of scope for this skill), for standalone SLDS token or styling work (use design-systems-slds-apply), or for standalone data-layer work (use experience-lds-best-practices-apply or experience-lds-data-requirements-generate)."
metadata:
  version: "1.0"
  domains: ["Experience", "Design Systems"]
  cliTools:
    - tool: ["eslint"]
      semver: ">=8.0"
    - tool: ["prettier"]
      semver: ">=2.0"
    - tool: ["python3"]
      semver: ">=3.8"
  relatedSkills:
    - design-systems-slds-apply
    - experience-lds-best-practices-apply
    - experience-lds-data-requirements-generate
    - experience-lwc-accessibility-jest-run
    - experience-accessibility-validate
    - experience-lwc-base-components-integrate
    - experience-lwc-generate
    - experience-lwc-rtl-validate
    - experience-lwc-runtime-observe
    - experience-lwc-security-validate
    - experience-lwc-typescript-migrate
---

<!-- adk-managed-skill -->

# Creating LWC Components from Design

Orchestrate the end-to-end creation of a new Lightning Web Component from a design input (Figma, PRD, Aura source, or user description). This is the top-level workflow skill — it sequences the specialized sibling skills that own each stage. Org-aware data (LDS schema introspection, design-frame inspection) is resolved by handing off to `experience-lds-data-requirements-generate` or via design-tool URLs the user provides.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `figma-to-prd-blueprint.md, patterns-and-examples.md, prd-analysis-template.md`

---

## When to Use

- Building a brand-new LWC from a Figma frame, PRD, or written spec.
- Migrating an Aura component to LWC as a fresh build (in-place Aura → LWC porting is out of scope for this skill).
- Creating a component whose requirements are still partly implicit and need distillation into a PRD before coding.

Do NOT use this skill for:
- Refactoring an existing LWC (use `experience-lwc-generate`).
- Aura → LWC in-place migration (out of scope for this skill).
- Pure styling or data-layer work (use the specialized skills directly).

## Prerequisites

- At least one design input: Figma URL, PRD markdown, Aura component source, or a textual spec.
- Target path (module folder) for the new LWC.
- For data-backed components: access to the org so `experience-lds-data-requirements-generate` and `experience-lds-best-practices-apply` can resolve the schema and adapter shapes.

## Knowledge Bases

- [examples/prd-analysis-template.md](examples/prd-analysis-template.md) — PRD section skeleton (copy it verbatim when producing a PRD).
- [examples/figma-to-prd-blueprint.md](examples/figma-to-prd-blueprint.md) — Figma-specific guidance for translating a frame into PRD sections (componentName/tagName, contentRequirements, dataRequirements, interactions, componentCommunication, states, accessibility/responsiveness/styling/localization/security). Read this before Phase 1.2 when the input is a Figma design.

## Workflow (mandatory five phases)

### Phase 1 — Gather PRD & requirements

**Goal:** produce a consolidated PRD that every later phase consumes.

1. **Obtain raw requirements** — collect the PRD, design spec, Figma URL, Aura source, or user text.
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Definition of Done

A new component built from this workflow is "done" only when **every** item below is true. Treat this as the canonical readiness checklist — copy it into the PR description so reviewers can confirm each line.

**Code completion** — no implementation gaps:

1. Every PRD requirement is either implemented or explicitly annotated with a `TODO:` and a linked tracking item. No silent gaps.
2. No `TODO`, `FIXME`, or `console.log` / `console.table` / `alert()` left in production paths.
3. No commented-out code blocks, no empty function bodies, no placeholder values, no dummy data, no unreferenced imports.
4. No `lwc:dom="manual"` regions or third-party-library escape hatches without a comment explaining why a native LWC pattern wasn't used.

**Compliance and quality:**

5. `.js-meta.xml` AI metadata passes the audit in `experience-lwc-generate` (component-wide `<ai><description>` set, plus an `<ai><property name="…" aiDescription="…"/></ai>` entry for every `@api` member exposed through `<targetConfig>`; no marketing language).
6. SLDS styling passes `design-systems-slds-apply` verification — no raw hex / px values, only styling hooks and SLDS utility classes.
7. Accessibility pass complete: `experience-accessibility-validate` for source review + `experience-lwc-accessibility-jest-run` for automated tests, both green.
8. Security + RTL pass complete: `experience-lwc-security-validate` + `experience-lwc-rtl-validate`, both green.

**Data + tests:**

9. Data layer verified against the referenced LDS adapters (every wire / imperative call is documented in the PRD's data section and matches one of the adapters from `experience-lds-best-practices-apply` or `experience-lds-data-requirements-generate`).
10. Jest tests green at the required coverage level for the project. New tests cover every `@api` surface, every dispatched event, and every error path (failed wire, failed apex, validation rejection).
11. UTAM page objects produced for any UI flow that needs cross-component browser-level testing (skip if not needed).

## Verification

- Every PRD section is traceable to at least one block of code or an explicit TODO.
- Phases 1–5 were executed in order; no step was skipped.
- Accessibility, SLDS, data-layer, and AI metadata reviews all pass.
- Coverage meets or exceeds the project's threshold.
- The component renders correctly in `experience-lwc-runtime-observe` across the responsive breakpoints enumerated in the PRD.

## Project QA Gate Hook (Frontend Validation)
Run the deterministic project QA gate to validate LWC/SLDS guardrails and Prettier formatting:

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
