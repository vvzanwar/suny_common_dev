---
name: experience-lwc-base-components-integrate
description: "Pick the right Lightning Base Component (`lightning-*`) for a given UI task, retrieve its full API (props, methods, events, slots) from the bundled per-component reference, and wire it into an LWC (LWC `.html`, `.js`, and `.css` files) without breaking SLDS. Use this skill when users say \"I need a Lightning modal / datatable / combobox / record form\", ask which `lightning-*` component fits a use case, want a shortlist of LBC candidates, are about to hand-roll a UI that a base component already provides, or are editing an LWC bundle's `.html` / `.js` / `.css` and need to select or wire a base component. Also triggers on \"Lightning base component\", \"LBC\", \"lightning-combobox\", \"lightning-datatable\", \"use `lightning-` tag\". DO NOT TRIGGER for applying SLDS design tokens, blueprints, or styling guidance in general — that is `design-systems-slds-apply`; this skill only selects and wires `lightning-*` base components."
metadata:
  version: "1.0"
  domains: ["Experience"]
  relatedSkills:
    - design-systems-slds-apply
---

<!-- adk-managed-skill -->

# Using Lightning Base Components

Lightning Base Components (LBC) are the `lightning-*` web components shipped
by Salesforce. This skill routes an agent through the right decision sequence
so the final component choice is **as specific as possible** and backed by
real API docs — not a hand-rolled reimplementation of something that already
exists.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `lbc-expert-guidance.md, lightning-component-index.md, lightning-components.md, patterns-and-examples.md`

---

## When to Use This Skill

- User describes a UI need ("searchable dropdown", "record edit form",
  "modal with footer") and asks which `lightning-*` component fits.
- User is about to build a primitive (button group, combobox, toast) and
  should be using LBC instead.
- User asks you to review LWC markup for LBC-related issues — specifically
  overriding SLDS classes or restyling LBC internals.
- User needs the authoritative props/events/slots for a specific
  `lightning-*` tag.

## Prerequisites

- Knowledge of which LBC namespace your org uses (`lightning` is the default
  public namespace; some platforms expose `lightning-community` or others —
  the user's meta files will clarify).
- The skill ships authoritative API docs for every Lightning Base Component
  in [examples/lightning-components.md](examples/lightning-components.md).
  Each component is a `# Component API Structure` block; grep for
  `**Name:** <camelCaseName>` (e.g. `**Name:** datatable`) to jump to its
  Properties / Methods / Events / Slots. Read this rather than relying on
  cached knowledge — LBC evolves and the reference is the source of truth.

## Workflow

### Step 1 — Read the **entire** component index first

Open [lightning-component-index.md](examples/lightning-component-index.md)
and scan **all** entries before making any selection. This is non-negotiable:
LBC's value comes from picking the most specialized component, and skipping
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Verification Checklist

- [ ] The full component index was scanned before any selection (no
      keyword-search shortcutting).
- [ ] Candidate list included every component that touches the use case.
- [ ] Final shortlist selects the **most specific** component per feature.
- [ ] Developer confirmed the shortlist before the bundled component
      reference was opened.
- [ ] Integration guidance cites props / events / slots from the real API
      docs (not inferred).
- [ ] No suggestions to restyle LBC by overriding SLDS classes.

## Project QA Gate Hook (Frontend Validation)
Run the deterministic project QA gate to validate LWC/SLDS guardrails and Prettier formatting:
```powershell
powershell -ExecutionPolicy Bypass -File .agents/scripts/run-qa-gate.ps1 -TargetFiles "<path_to_component_file>"
```
