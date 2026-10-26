---
name: design-systems-slds-validate
description: "Audit Lightning Web Components for SLDS design-system compliance and produce a scored quality report. Runs the SLDS linter and analyzes CSS for theming hook usage and pairing, scoring SLDS findings across categories into an overall grade. Use when asked to \"score my component's SLDS\", \"SLDS scorecard\", \"SLDS quality report\", \"audit SLDS compliance\", \"how good is my SLDS\", \"check SLDS quality\", \"rate my SLDS styling\", \"evaluate my component's SLDS\", \"is this component's SLDS ready to ship?\", \"look at my LWC for SLDS issues\", \"audit SLDS before I submit\", \"review my component's SLDS before code review\", or any time a user wants an SLDS quality assessment or SLDS production-readiness check on an LWC. Not for fixing violations (use design-systems-slds2-migrate), building new components (use design-systems-slds-apply), or accessibility/WCAG/ARIA audits (use experience-accessibility-validate)."
metadata:
  version: "1.0"
  domains: ["Design Systems"]
  relatedSkills:
    - "design-systems-slds-apply"
    - "design-systems-slds2-migrate"
    - "experience-accessibility-validate"
  cliTools:
    - tool: ["npx"]
      semver: ">=7.0.0"
    - tool: ["node"]
      semver: ">=18.0.0"
---

# SLDS Quality Audit

Audit Lightning Web Components for SLDS compliance and produce an automated scorecard plus a required manual review gate. Combines SLDS linter output with supplementary static analysis to catch what the linter misses.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md, quality-checks.md, report-format.md`

---

## Scope

Also valid for: auditing SLDS compliance across a project or component set, and before/after quality comparison after making changes.

Not for:
- **Fixing** linter violations — use `design-systems-slds2-migrate` instead
- **Building** new components — use `design-systems-slds-apply` instead
- **Just running the linter** — run `npx @salesforce-ux/slds-linter@latest lint .` directly
- **Full WCAG accessibility audit** — this skill checks attribute presence only (labels, alt text, focus indicators), not contrast ratios, keyboard flows, or screen reader behavior
- **Framework-specific template auditing** beyond `.css`, `.html`, and `.js` files — JSX/TSX/Vue/Svelte outputs need additional manual review

---

## Quality Validation Process

```text
1. Run SLDS Linter     → Collect violation counts (linter's job)
2. Run Analyze Script  → Check what linter doesn't cover (supplementary)
3. Agent Review        → Required manual review gate
4. Score & Grade       → Compute automated score + final recommendation
5. Generate Report     → Produce formatted scorecard
```

## Step 1: Run SLDS Linter

Run the linter to collect baseline violation data:

```bash
npx @salesforce-ux/slds-linter@latest lint <component-path> 2>&1
```

Count violations by rule. These feed directly into the **Linter Compliance** score:

| Rule | Impact |
|------|--------|
| `slds/class-override` | Breaks theming, dark mode |
| `slds/lwc-token-to-slds-hook` | SLDS 1 technical debt |
| `slds/no-hardcoded-values` | Breaks theming, accessibility |

**Linter Compliance Score** = `100 - (total_violations × 10)`, minimum 0.

**If the linter is unavailable** (no Node.js, no network access, CI sandbox restrictions): skip this step, note "Linter not run" in the report header, mark Linter Compliance as N/A, and compute the Overall score using the remaining 4 categories renormalized to 100%:

```text
Overall (linter unavailable) = (Theming × 0.29) + (Accessibility × 0.29)
                              + (CodeQuality × 0.21) + (ComponentUsage × 0.21)
```

## Step 2: Run Supplementary Analysis

Run the analyze script to catch issues the linter doesn't cover. The bundled analyzer scans `.css`, `.html`, and `.js` files only:

```bash
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full step commands and parameters.)*

## Step 3: Agent Manual Review

These checks require understanding the component's purpose and cannot be automated reliably. Review each and classify findings as either:

- **Blocking** — incorrect blueprint structure, missing required states, or semantic/interaction issues that make the component not production-ready
- **Advisory** — worthwhile improvements that do not block shipping on their own

| Review Area | What to Look For |
|-------------|-----------------|
| Loading states | Does the component show a spinner or skeleton when fetching data? |

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
