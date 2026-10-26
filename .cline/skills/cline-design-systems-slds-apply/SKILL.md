---
name: cline-design-systems-slds-apply
description: "Apply SLDS-compliant UI using the correct blueprints, styling hooks, utility classes, and icons. Use when building any UI that needs SLDS, choosing between Lightning Base Components and SLDS Blueprints, applying styling hooks for theming, using utility classes for layout and spacing, or selecting icons. Triggers include \"build a modal\", \"create a form\", \"data table\", \"SLDS styling\", \"style with hooks\", \"add an icon\"."
metadata:
  version: "1.1"
  domains: ["Design Systems"]
  relatedSkills:
    - "design-systems-slds-validate"
  cliTools:
    - tool: ["npx"]
      semver: ">=7.0.0"
    - tool: ["node"]
      semver: ">=18.0.0"
---

# Applying SLDS

The **Salesforce Lightning Design System (SLDS)** is a CSS framework with thousands of artifacts. This skill teaches agents how to find and correctly use them.

> **Version:** This skill targets **SLDS v2**. Legacy `--lwc-*` tokens and `slds-*--modifier` syntax are deprecated.
>
> **Audit scope:** The companion `design-systems-slds-validate` skill analyzer only scans `.css`, `.html`, and `.js` files. Use it directly for LWC and similar HTML/CSS/JS components; treat it as a partial signal for JSX/TSX or other framework-specific template formats and supplement with manual review.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `hooks-index.json, icon-metadata.json, README.md, specifications-and-schemas.md, utilities-index.json`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `blueprints-index.md, checklists.md, component-selection.md, examples.md, icons-decision-guide.md, icons-guidance.md, patterns-and-examples.md, README.md, slds-development-guide.md, styling-decision-guide.md, utilities-quick-ref.md`

---

## What is SLDS?

| Artifact | Count | Description |
|----------|-------|-------------|
| **Lightning Base Components** | ~70 | Pre-built LWC components (LWC only) |
| **SLDS Blueprints** | 85 | CSS/HTML patterns for any framework |
| **Styling Hooks** | 523 | CSS custom properties (`--slds-g-*`) for theming |
| **Utility Classes** | 1,147 | Rapid styling classes for spacing, layout, visibility |
| **Icons** | 1,732 | SVG icons across 5 categories |

---

## Scope

**This skill covers:**
- Which blueprint to use for a given UI pattern
- How to style with hooks (color, spacing, typography, shadows, borders)
- Which utility classes to use for layout, spacing, visibility
- Which icon to use and from which category
- SLDS naming conventions, class structure, hook syntax

**This skill includes basic accessibility reminders** (icon alt text, focus outlines, color-not-sole-indicator) in the validation checklists. Full WCAG compliance requires a dedicated accessibility review.

**This skill does NOT cover (use companion skills):**
- **Design decisions** -- visual hierarchy, composition, interaction patterns
- **LWC mechanics** -- component structure, @wire, @api, lifecycle, events (not yet available)
- **Full accessibility** -- WCAG conformance, ARIA patterns, keyboard navigation, focus management, contrast ratios (not yet available)

---

## Component Selection Hierarchy

Always follow this order:

```text
1. Lightning Base Components (LWC only)    ← Check first
2. SLDS Blueprints (any framework)         ← Use exact SLDS classes
3. Custom with Styling Hooks               ← Use var(--slds-g-*)
4. Custom CSS (last resort)                ← Still use hooks for values
```

If building in LWC, check for an LBC first: [Lightning Component Library](https://developer.salesforce.com/docs/component-library/overview/components)

If no LBC exists (or not using LWC), select an SLDS Blueprint. See [examples/component-selection.md](examples/component-selection.md).

---

## Verify Before You Use

> **Rule:** Never include an SLDS hook, utility class, blueprint class, or icon in generated code without first confirming it exists in the metadata. Guessing based on naming patterns is the primary source of invented artifacts.

Run the appropriate search command **before** emitting any SLDS artifact:

| Artifact | Verification command | Source of truth |
|----------|---------------------|-----------------|
| Styling hook (`--slds-g-*`) | `node scripts/search-hooks.cjs --prefix "<hook-name>"` | `resources/hooks-index.json` |
| Utility class (`slds-*`) | `node scripts/search-utilities.cjs --search "<class-name>"` | `resources/utilities-index.json` |
| Blueprint / CSS class | `node scripts/search-blueprints.cjs --search "<pattern>"` then read the YAML | `resources/blueprints/components/*.yaml` |
| Icon | `node scripts/search-icons.cjs --query "<description>"` | `resources/icon-metadata.json` |

If the search returns no match: **do not use the artifact.** Find an alternative from the search results or build custom with verified hooks.

---

## Naming Conventions

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
