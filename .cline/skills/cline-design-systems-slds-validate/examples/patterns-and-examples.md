# design-systems-slds-validate - Reference Examples, Patterns & Troubleshooting

## Edge Cases and False Positives

| Situation | Guidance |
|-----------|----------|
| **Headless components** (JS-only, no HTML) | Skip HTML checks; score only CSS + linter categories |
| **Wrapper/container components** | May legitimately have minimal CSS; don't penalize low hook usage |
| **Intentional native elements** | `<button>` inside custom SLDS blueprints is correct; suppress C002 if inside an `slds-*` blueprint structure |
| **Components outside LEX** | LWR/Experience Cloud components may not use Lightning Base Components; note context in report |
| **Test/demo components** | Lower the bar — note in report but don't block on warnings |

If a check produces a false positive, note it in the report as "suppressed" with justification rather than silently dropping it.

---
