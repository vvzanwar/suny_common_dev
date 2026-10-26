# design-systems-slds-validate - Technical Specifications, Rules & Schemas

## Step 2: Run Supplementary Analysis

Run the analyze script to catch issues the linter doesn't cover. The bundled analyzer scans `.css`, `.html`, and `.js` files only:

```bash
node scripts/analyze-quality.cjs <component-path>
```

The script outputs JSON with findings organized by severity. It checks:

### CSS Checks (linter-complementary)

| Check | What It Catches | Severity |
|-------|----------------|----------|
| Missing fallbacks | `var(--slds-g-*)` without a fallback value | Critical |
| Invented hooks (T051) | `--slds-g-*` tokens not found in `hooks-index.json` (requires `--hooks-index`) | Critical |
| Hook pairing | Background hooks without matching foreground hooks | Warning |
| `!important` | Specificity overrides | Warning |
| Magic pixel values | Hardcoded `px` not using spacing hooks | Warning |
| High z-index | z-index values > 99 | Warning |
| Outline removal | `outline: none` without alternative focus style | Warning |

### JS Checks

| Check | What It Catches | Severity |
|-------|----------------|----------|
| Inline style assignment | `.style.*=` direct property assignment | Warning |
| SLDS class manipulation | Dynamic `.classList.add('slds-*')` manipulation | Warning |

### HTML Checks

| Check | What It Catches | Severity |
|-------|----------------|----------|
| LBC input labels | `<lightning-input>` without `label` attribute | Critical |
| Icon alt text | `<lightning-icon>` without `alternative-text` | Critical |
| Image alt text | `<img>` without `alt` | Critical |
| Heading hierarchy | Skipped heading levels (h2 to h4) | Warning |
| Positive tabindex | `tabindex` values other than 0 or -1 | Warning |
| Clickable divs | `<div onclick>` instead of `<button>` | Warning |
| Inline styles | `style="..."` attributes | Warning |
| Native elements | `<input>`, `<button>`, `<select>` where LBC alternatives exist | Warning |

### Hook Pairing Validation

The script checks that background/foreground hooks are semantically paired:

```text
surface-* backgrounds     → on-surface-* text
surface-container-* bg    → on-surface-* text
accent-* backgrounds      → on-accent-* text
accent-container-* bg     → on-accent-* text
```

> **Limitation:** Hook pairing is checked at the file level, not per-selector. A file with `surface-1` in `.classA` and `on-accent-1` in `.classB` would pass because both surface and accent families are present. Review pairing correctness per-selector during manual review (Step 3).

### Invented Hook Detection (T051)

The script cross-references every `--slds-g-*` token in CSS against `hooks-index.json`. Any hook not found in metadata is flagged as critical — this catches the most common agent mistake of inventing hooks from naming patterns.

---

## Step 4: Calculate Automated Scores and Final Recommendation

### Component Complexity

Before scoring, classify the component to give the score context:

| Complexity | Criteria | Report Note |
|------------|----------|-------------|
| Small | 1-2 files, < 100 total lines | Score is high-confidence (small surface area) |
| Medium | 3-6 files, 100-500 total lines | Score reflects typical component |
| Large | 7+ files, 500+ total lines | Score reflects absolute issue count — even well-built large components may score lower |

Include the complexity classification in the report header. This prevents misreading a "B" on a 1000-line component vs. a "B" on a 20-line component.

### Automated Scoring Formula

```text
Category Score = 100 - (critical_issues × 10) - (warnings × 3) - (info × 1)
Minimum score: 0
```

### Categories and Weights

| Category | Weight | Source |
|----------|--------|--------|
| Linter Compliance | 30% | SLDS linter output (Step 1) |
| Theming | 20% | Script: fallbacks, hook pairing (Step 2) |
| Accessibility | 20% | Script: labels, alt text, focus (Step 2) |
| Code Quality | 15% | Script: !important, inline styles, z-index (Step 2) |
| Component Usage | 15% | Script: native elements (Step 2) plus manual semantic/blueprint review (Step 3) |

### Automated Overall Score

```text
Overall = (Linter × 0.30) + (Theming × 0.20) + (Accessibility × 0.20)
        + (CodeQuality × 0.15) + (ComponentUsage × 0.15)
```

### Automated Grade Thresholds

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent automated score |
| 80-89 | B | Good automated score |
| 70-79 | C | Acceptable automated score |
| 60-69 | D | Weak automated score |
| 0-59 | F | Failing automated score |

### Manual Review Gate

After computing the automated score, apply the manual review outcome:

| Gate | When to use it | Effect on final recommendation |
|------|----------------|-------------------------------|
| Pass | No manual findings | Final recommendation can follow the automated score |
| Advisory | Only non-blocking manual findings | Final recommendation can be "Ready with follow-ups" at best |
| Blocking | One or more blocking manual findings | Final recommendation is **not ready for production**, regardless of automated grade |

### Final Recommendation Rules

Use both the automated score and the manual review gate:

| Final Recommendation | Conditions |
|----------------------|------------|
| Ready for production | Automated grade A/B, no critical findings, manual gate = Pass |
| Ready with follow-ups | Automated grade A/B, no critical findings, manual gate = Advisory |
| Needs work | Any critical findings, automated grade C/D, or manual gate = Blocking |
| Failing | Automated grade F |

---

## References

- **[Quality Checks](examples/quality-checks.md)** - Complete list of all quality checks with detection patterns
- **[Report Format](examples/report-format.md)** - Quality report template and formatting guide
- **[Analyze Script](scripts/analyze-quality.cjs)** - Automated analysis for linter-complementary checks
- **design-systems-slds2-migrate skill** - How to fix linter violations
- **design-systems-slds-apply skill** - Guide for building new components with correct patterns
