# design-systems-slds-apply - Technical Specifications, Rules & Schemas

## Core Rules

### Do

- Follow the selection hierarchy: LBC > Blueprint > Hooks > Custom CSS
- Use `var(--slds-g-*, fallback)` for all themeable values
- Create custom classes (`my-*`, `c-*`) instead of overriding `.slds-*`
- **Verify every hook, class, and utility exists before using it** — run the search scripts; never assume an artifact exists based on naming patterns (see [Verify Before You Use](#verify-before-you-use))
- Pair surface colors with on-surface colors for text
- Provide `alternative-text` on every `<lightning-icon>`

### Don't

- Hard-code colors, spacing, or typography values
- Override `.slds-*` classes directly
- Use deprecated `--lwc-*` tokens as primary values
- Use `--slds-s-*` (shared) hooks -- they are private/internal
- Reassign hook values -- only reference them with `var()`
- Use color alone to convey meaning
- Invent hook names by interpolating patterns from other families (see Naming Traps below)

---

---

## Hook Naming Traps

SLDS hook families do NOT all follow the same naming pattern. Agents frequently invent hooks that don't exist by assuming `{prefix}-{number}` works universally. **Always verify a hook exists** via the bundled `search-hooks.cjs` script or `resources/hooks-index.json` before using it.

### Trap 1: Font size hooks are NOT numbered

| Wrong (does not exist) | Correct | Notes |
|------------------------|---------|-------|
| `--slds-g-font-size-3` | `--slds-g-font-scale-1` | Font sizes use `font-scale-*`, not `font-size-*` |
| `--slds-g-font-size-4` | `--slds-g-font-scale-2` | Only `--slds-g-font-size-base` exists (base size) |
| `--slds-g-font-size-8` | `--slds-g-font-scale-6` | Scale goes: neg-4 through 10 |

**Rule:** For font sizes, use `--slds-g-font-size-base` (the one base size) or `--slds-g-font-scale-*` (the numbered scale). Never `--slds-g-font-size-N`.

### Trap 2: Color hooks always require a number

| Wrong (does not exist) | Correct | Notes |
|------------------------|---------|-------|
| `--slds-g-color-on-surface` | `--slds-g-color-on-surface-2` | All color hooks need a number |
| `--slds-g-color-on-accent` | `--slds-g-color-on-accent-1` | Pick 1/2/3 by emphasis level |
| `--slds-g-color-surface` | `--slds-g-color-surface-1` | No unnumbered base form |

**Rule:** Every `--slds-g-color-*` hook ends in a number. Pick by emphasis: `-1` (low), `-2` (medium), `-3` (high).

### Trap 3: Not all values have hook equivalents

Some CSS values (e.g., `min-width: 7rem` for label alignment) have no SLDS hook. This is acceptable:

```css
.c-field-label {
  /* No SLDS hook exists for this width; intentional custom value */
  min-width: 7rem;
}
```

**Rule:** When no hook exists, use the value directly with a comment explaining it's intentional. Prefer SLDS grid utilities (`slds-size_*`) as alternatives to hardcoded widths where possible.

---

---

## Knowledge Map

This skill bundles comprehensive SLDS knowledge. Read files as needed -- don't read everything upfront.

### Decision Guides (start here for each task)

| File | Read when |
|------|-----------|
| [examples/component-selection.md](examples/component-selection.md) | Choosing a component or blueprint |
| [examples/styling-decision-guide.md](examples/styling-decision-guide.md) | Applying colors, spacing, typography, shadows |
| [examples/icons-decision-guide.md](examples/icons-decision-guide.md) | Selecting or implementing an icon |
| [examples/utilities-quick-ref.md](examples/utilities-quick-ref.md) | Using utility classes for layout/spacing |

### Search Scripts (find specific artifacts)

| Script | What it searches | Example |
|--------|-----------------|---------|
| `scripts/search-blueprints.cjs` | 85 blueprint YAMLs | `--search "dialog"` |
| `scripts/search-hooks.cjs` | 523 styling hooks | `--prefix "--slds-g-color-accent-"` |
| `scripts/search-icons.cjs` | 1,732 icons with synonyms | `--query "save button"` |
| `scripts/search-utilities.cjs` | 1,147 utility classes | `--category "grid"` |

### Deep-Dive Guidance (read for detailed rules)

| Folder | Content | Index |
|--------|---------|-------|
| `examples/overviews/` | Foundational concepts (color, spacing, typography, etc.) | [examples/README.md](examples/README.md) |
| `examples/styling-hooks/` | Hook categories with detailed usage | [examples/README.md](examples/README.md) |
| `examples/utilities/` | 27 utility class categories | [examples/README.md](examples/README.md) |
| `examples/slds-development-guide.md` | Full SLDS development guide | -- |

### Raw Metadata (structured data for lookup)

> **Do not read metadata JSON files directly** — they are too large for agent context (hooks-index.json is 6,000+ lines; icon-metadata.json is 38,000+ lines). Use the search scripts above to query them.

| File | Content | Lines |
|------|---------|-------|
| `resources/blueprints/components/*.yaml` | 85 blueprint specs (classes, variants, a11y, HTML) | ~50-200 each |
| `resources/hooks-index.json` | 523 hooks with values and CSS properties | ~6,300 |
| `resources/icon-metadata.json` | 1,732 icons with synonyms for search | ~38,500 |
| `resources/utilities-index.json` | 1,147 utility classes with CSS rules | ~6,900 |

---

---

## Authoring Workflow

### Phase 1: Understand the Need

Identify:
- What UI pattern is needed? (form, table, modal, card, etc.)
- What framework? (LWC, React, Vue, Angular, vanilla)
- What data will it display?
- What states does it need? (loading, empty, error, success)

### Phase 2: Select the Artifact

1. **If LWC**: Check the [Lightning Component Library](https://developer.salesforce.com/docs/component-library/overview/components) for an LBC
2. **Search blueprints**: `node scripts/search-blueprints.cjs --search "<pattern>"`
3. **Read the blueprint YAML**: `resources/blueprints/components/<name>.yaml` for exact classes, modifiers, states, and accessibility requirements
4. **No match?** Build custom with hooks (see Phase 3)

Details: [examples/component-selection.md](examples/component-selection.md)

### Phase 3: Apply Styling

1. **Read**: [examples/styling-decision-guide.md](examples/styling-decision-guide.md)
2. **Colors**: Classify role (surface, accent, feedback, border) then pick hook
3. **Spacing**: Use utility classes (`slds-p-*`, `slds-m-*`) or hooks (`--slds-g-spacing-*`)
4. **Layout**: Use grid utilities (`slds-grid`, `slds-col`, `slds-size_*`)
5. **Custom CSS**: Use `var(--slds-g-*, fallback)`, custom class prefixes only

### Phase 4: Add Icons

1. **Read**: [examples/icons-decision-guide.md](examples/icons-decision-guide.md)
2. **Search**: `node scripts/search-icons.cjs --query "<description>"`
3. **In LWC**: Use `<lightning-icon>` with `alternative-text`
4. **In non-LWC**: Use SVG with `slds-icon` classes and `slds-assistive-text`

### Phase 5: Validate (Mandatory — Do Not Skip)

**Step 1: Run the SLDS linter.** This is required. Zero violations is the target.

```bash
npx @salesforce-ux/slds-linter@latest lint <component-path>
```

The linter catches hardcoded values, class overrides, and deprecated tokens. **Fix all violations before proceeding.** Do not rationalize violations as acceptable.

**Step 2: Verify no invented hooks.** Confirm every `--slds-g-*` hook in the output exists in `resources/hooks-index.json`. Cross-reference against the T051 check in [checklists.md](examples/checklists.md).

**Step 3: Run through [checklists.md](examples/checklists.md)** for the checks the linter cannot automate:
- All `var(--slds-g-*)` have fallback values (T002)
- Surface/accent/feedback color hooks are properly paired (T010–T013)
- Spacing uses hooks or utility classes — no magic `px` values (T020–T021)
- Font sizes use `--slds-g-font-scale-*`, not `--slds-g-font-size-N` (T031)
- All icons have accessibility text (A004)
- Custom classes use `my-*` or `c-*` prefix (Q010)

**Step 4 (optional): Run the full quality audit** using the `design-systems-slds-validate` skill for a scored report before code review or deployment. Use it directly for LWC / HTML-CSS-JS components; for JSX/TSX outputs, treat the result as partial coverage only. Target a B grade (≥80) or higher before marking work complete.

---

---

## Quick Reference

### Common Hook Patterns

```css
/* Surface + text pairing (always use numbered variants) */
background: var(--slds-g-color-surface-1, #ffffff);
color: var(--slds-g-color-on-surface-2, #181818);

/* Standard padding */
padding: var(--slds-g-spacing-4, 1rem);

/* Card-like container */
border-radius: var(--slds-g-radius-border-2, 0.25rem);
box-shadow: var(--slds-g-shadow-1, 0 2px 4px rgba(0,0,0,0.1));

/* Accent for primary actions */
background: var(--slds-g-color-accent-1, #0176d3);
color: var(--slds-g-color-on-accent-1, #ffffff);

/* Typography -- use font-scale-*, NOT font-size-* (only font-size-base exists) */
font-size: var(--slds-g-font-scale-2, 0.875rem);
```

### Common Utility Patterns

```html
<!-- Responsive grid -->
<div class="slds-grid slds-wrap slds-gutters">
  <div class="slds-col slds-size_1-of-1 slds-medium-size_1-of-2">...</div>
</div>

<!-- Spacing -->
<div class="slds-p-around_medium slds-m-bottom_small">...</div>

<!-- Truncation -->
<p class="slds-truncate" title="Full text here">Full text here</p>
```

---

---

## Resources

| Resource | URL |
|----------|-----|
| SLDS Website | https://www.lightningdesignsystem.com/ |
| Lightning Component Library | https://developer.salesforce.com/docs/component-library/overview/components |
| SLDS Linter | https://developer.salesforce.com/docs/platform/slds-linter/guide |
| Styling Hooks Reference | https://www.lightningdesignsystem.com/2e1ef8501/p/591960-global-styling-hooks |
