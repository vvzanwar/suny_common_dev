# design-systems-slds2-migrate - Technical Specifications, Rules & Schemas

## SLDS 2 Styling Hook Categories

| Category | Hook Prefix | What It Replaces |
|---|---|---|
| Color | `--slds-g-color-*` | Hardcoded colors, `--lwc-color*` tokens |
| Spacing | `--slds-g-spacing-*` | Hardcoded margins, padding, gaps |
| Sizing | `--slds-g-sizing-*` | Hardcoded widths, heights, dimensions |
| Typography | `--slds-g-font-*` | Hardcoded font sizes, weights, line heights |
| Border/Radius | `--slds-g-radius-border-*`, `--slds-g-sizing-border-*` | Hardcoded border-radius, border-width |
| Shadow | `--slds-g-shadow-*` | Hardcoded box-shadow values |

Color hooks require the most judgment (context-dependent selection). Non-color hooks are mostly numbered scales with straightforward mappings.

---

## Step 2: Analyze Linter Output

The linter reports violations in this format:

```text
componentName.css
  15:3  warning  Overriding slds-button isn't supported. To differentiate SLDS and
                 custom classes, create a CSS class in your namespace.
                 Examples: myapp-input, myapp-button.                        slds/no-slds-class-overrides

  23:5  error    The '--lwc-colorBackground' design token is deprecated. Replace it with
                 the SLDS 2 styling hook and set the fallback to '--lwc-colorBackground'.
                 1. --slds-g-color-surface-2
                 2. --slds-g-color-surface-container-2                      slds/lwc-token-to-slds-hook

  30:8  warning  Consider replacing the #ffffff static value with an SLDS 2 styling hook
                 that has a similar value:
                 1. --slds-g-color-surface-1
                 2. --slds-g-color-surface-container-1
                 3. --slds-g-color-on-accent-1
                 4. --slds-g-color-on-accent-2
                 5. --slds-g-color-on-accent-3                              slds/no-hardcoded-values-slds2

  31:15  error   Consider removing t(fontSizeMedium) or replacing it with
                 var(--slds-g-font-size-base, var(--lwc-fontSizeMedium, 0.8125rem)).
                 Set the fallback to t(fontSizeMedium). For more info, see
                 Styling Hooks on lightningdesignsystem.com.               slds/no-deprecated-tokens-slds1
```

Four violation types, each with its own fix approach (see Step 3).

**Important:** The linter flags all hardcoded values. Fix color, spacing, sizing, typography, border, and shadow values — but **skip layout values** (`100%`, `auto`, `0`, `inherit`, `none`). See [rule-no-hardcoded-values.md](examples/rule-no-hardcoded-values.md) for the full fix-vs-skip triage table.

---

## Step 5: Validate and Verify

**Linter feedback loop — repeat until zero errors:**

```text
1. npx @salesforce-ux/slds-linter@latest lint .
2. Review errors -> fix by type (Step 3)
3. Re-run linter
4. Repeat until output shows: 0 errors
```

---

# Validation

- [ ] No `.slds-*` classes in CSS selectors
- [ ] No `var(--lwc-*)` tokens without SLDS 2 replacements
- [ ] All hooks include fallback values
- [ ] Background/foreground color hooks from same family
- [ ] Original SLDS classes preserved in HTML
- [ ] Spacing uses numbered hooks (not named like `spacing-medium`)
- [ ] Typography uses numbered hooks (not named like `font-weight-bold`)
- [ ] Component renders correctly in light/dark mode and density settings

See **[migration-checklist.md](examples/migration-checklist.md)** for the full validation checklist.

---

# Output

Return the fully migrated CSS (and updated HTML markup where class overrides were fixed) with zero SLDS linter violations. All styling hooks must include fallback values preserving the original CSS values.

---

# Advanced Patterns
