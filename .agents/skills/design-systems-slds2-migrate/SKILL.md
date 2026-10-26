---
name: design-systems-slds2-migrate
description: "Migrate Lightning Web Components from SLDS 1 to SLDS 2 by running the SLDS linter and fixing violations. Use this skill whenever users mention SLDS 2, SLDS uplift, linter violations, LWC token migration, class overrides, hardcoded CSS values that need SLDS hook replacement, or styling hook selection. Covers all styling hook categories — color, spacing, sizing, typography, borders, radius, and shadows. Also use when users mention no-hardcoded-values, no-slds-class-overrides, lwc-to-slds-hooks, no-deprecated-tokens-slds1, or ask about SLDS component migration — even if they don't explicitly say \"uplift\" or \"migration\"."
metadata:
  version: "1.0"
  domains: ["Design Systems"]
  cliTools:
    - tool: ["npx"]
      semver: ">=7.0.0"
---

# Goal

Systematically migrate Lightning Web Components from SLDS 1 to SLDS 2 using the SLDS linter and structured guidance for fixing violations across all styling hook categories.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `color-hooks-decision-guide.md, common-patterns.md, examples.md, migration-checklist.md, non-color-hooks-decision-guide.md, patterns-and-examples.md, rule-lwc-token-to-slds-hook.md, rule-no-deprecated-tokens-slds1.md, rule-no-hardcoded-values.md, rule-no-slds-class-overrides.md`

---

## Prerequisites

- Node.js 14.x or higher installed
- Access to component CSS and markup files (`.html` for LWC, `.cmp` for Aura)
- Terminal/command line access to run linter
- Git repository for backup (recommended)

---

# Workflow

```text
1. **REQUIRED — ALWAYS run first:** npx @salesforce-ux/slds-linter@latest lint --fix . — NEVER skip this step. This handles simple violations automatically.
2. Review linter output -> Identify remaining manual fixes needed
3. Fix by violation type -> Use per-rule reference guides
4. Choose the right hook -> Context-first, inspect HTML before deciding
5. Validate -> Re-run linter and confirm zero errors
```

## Step 1: Run SLDS Linter
MANDATORY: This step is NOT optional.

```bash
npx @salesforce-ux/slds-linter@latest lint --fix .
```

The linter analyzes all CSS and markup files (`.html` for LWC, `.cmp` for Aura), auto-fixes simple violations, and reports remaining issues requiring manual intervention.

## Step 2: Analyze Linter Output

The linter reports violations in this format:

```text
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full step commands and parameters.)*

## Step 3: Fix Violations by Type

Each rule has a dedicated reference guide with full examples and decision logic:

| Violation Rule | Quick Summary | Reference |
|---|---|---|
| `slds/no-hardcoded-values-slds2` | Replace hardcoded values with SLDS hook + original as fallback | [rule-no-hardcoded-values.md](examples/rule-no-hardcoded-values.md)|
| `slds/lwc-token-to-slds-hook` | Replace `--lwc-*` tokens with SLDS 2 hook, keep LWC token as fallback | [rule-lwc-token-to-slds-hook.md](examples/rule-lwc-token-to-slds-hook.md) |
| `slds/no-slds-class-overrides` | Create component-prefixed class, add to markup alongside SLDS class | [rule-no-slds-class-overrides.md](examples/rule-no-slds-class-overrides.md) |
| `slds/no-deprecated-tokens-slds1` | Replace legacy `t()`/`token()` syntax with SLDS 2 hook + LWC fallback | [rule-no-deprecated-tokens-slds1.md](examples/rule-no-deprecated-tokens-slds1.md) |

**Always include fallback values** — `var(--slds-g-hook, originalValue)` where `originalValue` is the exact original from the source CSS.

### Class Override Quick Reference

Class overrides require changes to **both CSS and markup** (`.html` or `.cmp`). This is the most commonly missed step:

1. **CSS:** Rename `.slds-*` selector → `{componentName}-{sldsElementPart}` (camelCase)
2. **Markup:** Add the new class **alongside** the SLDS class — never remove the SLDS class

```css
/* Before */ .slds-button { border-radius: 8px; }
/* After */  .myComponent-button { border-radius: 8px; }
```
```html
<!-- Markup: both classes --> <button class="slds-button myComponent-button">Click</button>
```

See [rule-no-slds-class-overrides.md](examples/rule-no-slds-class-overrides.md) for descendant selectors, multi-class selectors, and naming conventions.


*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
