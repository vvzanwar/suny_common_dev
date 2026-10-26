---
name: experience-design-validate
description: "Use this skill to run a visual-craft audit of a rendered UI and produce an evidence-grounded Craft Report across Useful, Usable, Reliable, Coherent, and Well-Crafted. Invoke it for craft audits, visual critiques, design comparisons, felt-quality reviews, or visual-craft readiness checks on screenshots (.png, .jpg, .jpeg, .webp, .gif), Figma frames, rendered prototypes, and live URLs. Do not use it for source-code review, SLDS compliance (use design-systems-slds-validate), or accessibility compliance (use experience-accessibility-validate)."
metadata:
  version: "1.0"
  domains: ["Experience"]
  relatedSkills:
    - "design-systems-slds-validate"
    - "experience-accessibility-validate"
    - "experience-lwc-generate"
    - "experience-lwc-security-validate"
---

# Experience Design Validate

Evaluate the visual craft of rendered software: what the eye sees and the felt quality those visible decisions create. Judge relationships, hierarchy, restraint, consistency, and care rather than CSS, tokens, or implementation technique.

This is a **visual-craft-only** audit. It does not establish WCAG conformance, keyboard or screen-reader support, behavioral usability, implementation quality, or production release readiness. Route accessibility compliance to `experience-accessibility-validate` and SLDS compliance to `design-systems-slds-validate`.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `ai.md, components.md, craft.md, data.md, forms-flows.md, interaction.md, navigation.md, patterns-and-examples.md, performance.md, records.md, responsive.md, scoring-rubric.md, state.md, trust.md, usability.md, visual-system.md`

---

## Use and boundaries

Use this skill to:

- Critique visual craft at a design checkpoint.
- Explain why a rendered design feels considered, cramped, calm, fragmented, or delightful.
- Compare the craft of two or more designs solving the same brief.
- Identify design moves that would lift a visible experience from good to great.

Do not use this skill for:

- Implementation or code review. For LWC generation or security review, use `experience-lwc-generate` or `experience-lwc-security-validate` as appropriate.
- Accessibility compliance, including WCAG, screen-reader, keyboard, or focus-order validation. Use `experience-accessibility-validate`.
- SLDS design-token compliance. Use `design-systems-slds-validate`.
- Claims about real-user behavior. Recommend a usability study when impact depends on behavior rather than visible evidence.

## Visual evidence contract

Rendered pixels are mandatory. Prefer screenshots because they preserve the exact evidence reviewed.

1. **Screenshots:** use supplied full-page or region captures directly.
2. **Live URL:** if browser capability is available, open the URL, exercise only the relevant paths, capture screenshots, and retain the URL and viewport as evidence. Otherwise ask for screenshots.
3. **Figma:** if Figma capability is available, fetch or export the named rendered frames. Treat a frame as static unless prototype behavior is actually exercised. Otherwise ask for frame exports or screenshots.
4. **Screen recording or interactive prototype:** inspect observable transitions and capture representative frames when tooling supports it.
5. **Source code, design descriptions, or inaccessible links:** do not infer the rendered result. Render with available capability; otherwise request screenshots.

If no rendered pixels are available:

- **Interactive run:** ask the user for screenshots or another rendered artifact and pause the audit.
- **Non-interactive run:** return status `INSUFFICIENT_VISUAL_EVIDENCE` with a short statement of the missing artifact. Do not score, assign a verdict, create findings, or imply readiness.

### Evidence modes

Declare one mode before analysis:

| Mode | What it can support | What it cannot support |
|---|---|---|
| `STATIC_VISUAL` | Visible hierarchy, spacing, typography, color, density, composition, consistency, and the visible treatment of the captured moment | Interaction behavior, transitions between states, responsive adaptation beyond captured viewports, latency, runtime performance, or unseen states |
| `MULTI_VIEW_STATIC` | Static visual evidence across supplied screens, states, or viewport captures, including cross-screen coherence | The behavior connecting captures, timing, input response, runtime performance, or states not shown |
| `DYNAMIC_VISUAL` | Static qualities plus behavior directly exercised or recorded: interaction feedback, transitions, state changes, and perceived performance | Unexercised paths, unrecorded states, accessibility compliance, or measured performance beyond what was observed |

A static screenshot of a loading, error, or empty state supports critique of that state's **visible treatment only**. It does not substantiate state coverage, transition behavior, or performance. Never lower a score because an unobserved state or behavior was not supplied; mark that coverage `INSUFFICIENT_EVIDENCE` instead.

## Five dimensions

| Dimension | Felt question |
|---|---|
| **Useful** | Does the visible content earn the space and attention it occupies? |
| **Usable** | Does the visible hierarchy and affordance make the intended path feel obvious? |
| **Reliable** | Do the observed states and feedback make the experience feel predictable? |
| **Coherent** | Does the visible experience feel made by one team with one taste? |
| **Well-Crafted** | Does the visible design feel precise, considered, and delightful? |

Use a 1-10 score only when the available evidence adequately covers a dimension. Use `INSUFFICIENT_EVIDENCE` when an applicable dimension cannot be supported. Use `N/A` only when the dimension or topic genuinely does not apply, never merely because evidence is missing.

Read `examples/scoring-rubric.md` for scoring anchors, verdict rules, severity definitions, and the complete report contract.

## Craft lens

Ask whether the rendered experience feels:

- **Breathable:** space structures the composition and gives the eye room.
- **Approachable:** the intended path is visually obvious without explanation.
- **Inviting:** visible states encourage exploration rather than present dead ends.
- **Considered:** repeated decisions form a system rather than an accumulation.

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
