# design-systems-slds2-migrate - Reference Examples, Patterns & Troubleshooting

## Color-Mix for Transparency

When a hardcoded value uses `rgba()` or transparency, use `color-mix()` with the SLDS hook to preserve opacity:

```css
/* Before */
border-color: rgba(186, 5, 23, 0.7);

/* After — use oklab color space for perceptual consistency */
border-color: color-mix(in oklab, var(--slds-g-color-palette-red-40, rgb(181,54,45)), transparent 30%);
```

**Formula:** To achieve X% opacity, use `(100 - X)%` transparent in `color-mix`.
- 70% opacity → `transparent 30%`
- 50% opacity → `transparent 50%`

Use opaque `rgb()` as fallback (not `rgba()`) — `color-mix` handles the transparency.

---

## calc() Expressions with Tokens

When migrating `t('calc(...)')` or `calc()` with deprecated tokens:

```css
/* Before — Aura t() with calc */
height: t('calc(' + lineHeightButton + ' + 2px)');

/* After — if calc is still needed */
height: calc(var(--lwc-lineHeightButton) + 2px);

/* After — if calc was unnecessary, simplify */
height: var(--lwc-lineHeightButton);
```

For `calc()` with `--lwc-*` tokens being replaced:

```css
/* Before */
padding: calc(var(--lwc-spacingMedium) + 4px);

/* After */
padding: calc(var(--slds-g-spacing-4, var(--lwc-spacingMedium)) + 4px);
```

**Tip:** Often the `calc()` is unnecessary and can be simplified. Check if the result matches an existing hook value.

---

# Key Constraints

- **Never invent hook names** — only use hooks documented in the SLDS design system
- **Always include fallback values** — the fallback must be the exact original value from the source CSS
- **Never change hardcoded numerical values** — values like `100%`, `50%`, `200px`, `1.5`, `auto`, `0`, `inherit`, `none`, `flex: 1` are structural/layout values. Do not replace them with hooks and do not remove them — they are not styling hook candidates
- **No exact match? Leave as-is** — if a hardcoded value doesn't closely correspond to any hook's rendered value, leave it unchanged rather than force-fitting
- **Match hook number to original value intensity** — don't default to `-1`. Pick the variant closest to the original. See [color-hooks-decision-guide.md](examples/color-hooks-decision-guide.md)
- **Only numbered scales** — named hooks like `spacing-medium`, `font-weight-bold`, `radius-large` do NOT exist

# Troubleshooting

| Issue | Solution |
|---|---|
| Linter suggests 2+ color hook options | Inspect HTML context to determine element's semantic role — see color-hooks-decision-guide.md |
| Visual appearance changed after migration | Verify fallback values match originals; check surface vs container family |
| No hook available for hardcoded value | Leave unchanged; do not invent custom hook names |
| Linter says "Remove the static value" for `100%`, `auto`, etc. | Leave unchanged — these are layout values. Removing them breaks rendering. |
| CSS class naming errors | Use exact camelCase component name: `myComponent-button`, not `MyComponent-button` |
| Spacing/sizing doesn't match | Check value-to-hook mapping in non-color-hooks-decision-guide.md; verify spacing vs sizing usage |
| Named hook not working (e.g., `spacing-medium`) | Named hooks don't exist — use numbered scale: `spacing-4` for 16px, `font-weight-7` for inline bold emphasis (not headings) |
| Component looks different in compact density | Use density-aware hooks (`--slds-g-spacing-var-*`) for components that adapt to density |

---

# References

- **[Color Hooks Decision Guide](examples/color-hooks-decision-guide.md)** — All 5 color hook families, decision trees, background-foreground pairing, palette accessibility
- **[Non-Color Hooks Decision Guide](examples/non-color-hooks-decision-guide.md)** — Spacing, sizing, typography, borders, radius, and shadow hooks with lookup tables
- **[Rule: No Hardcoded Values](examples/rule-no-hardcoded-values.md)** — Linter behavior, fix-vs-skip triage, replacement pattern, utility class workflow
- **[Rule: LWC Token to SLDS Hook](examples/rule-lwc-token-to-slds-hook.md)** — Deprecated `--lwc-*` token replacement patterns
- **[Rule: No Deprecated Tokens SLDS1](examples/rule-no-deprecated-tokens-slds1.md)** — Legacy `t()`/`token()` Aura syntax replacement patterns
- **[Rule: No SLDS Class Overrides](examples/rule-no-slds-class-overrides.md)** — Class renaming and HTML updates
- **[Migration Examples](examples/examples.md)** — Before/after examples by scenario and complexity
- **[Common Patterns](examples/common-patterns.md)** — Classes never to override, deprecated SLDS 2 classes, palette fallbacks, tokens with no SLDS 2 equivalent
- **[Migration Checklist](examples/migration-checklist.md)** — Full validation checklist
