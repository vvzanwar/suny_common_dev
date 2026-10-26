# experience-lwc-base-components-integrate - Reference Examples, Patterns & Troubleshooting

## Examples

### Example — "I need a multi-select combobox with typeahead"

1. Scan the component index end-to-end.
2. Candidate list includes: `lightning-combobox`, `lightning-dual-listbox`,
   `lightning-record-picker`.
3. Shortlist: `lightning-dual-listbox` (the documented multi-select base
   component). Rule out `lightning-combobox` — its documented API is
   single-select; it has no `type="multi"` and no multi-select mode.
   Flag that `lightning-record-picker` only fits if the values are record IDs.
4. Developer confirms `lightning-dual-listbox`.
5. Run `scripts/extract-component-docs.sh dualListbox`.
6. Return the `options`, `value`, `onchange` payload, and required label
   props from the block's Properties / Events sections.

### Example — "I'm going to write my own modal"

1. Scan finds `lightning-modal`, `lightning-modal-body`,
   `lightning-modal-footer`, `lightning-modal-header`.
2. Shortlist is the 4 modal components.
3. Confirm.
4. Run `scripts/extract-component-docs.sh modal modalHeader modalBody modalFooter`
   → full modal API (how to extend `LightningModal`, the static `.open()`
   pattern, slotting the header/body/footer).
5. Steer the developer away from rolling their own dialog.

---

## Troubleshooting

- **Grep for `**Name:** <name>` returns no match** — name is wrong, or the
  reference uses a different camelCase. Double-check against the component
  index (`lightning-record-form` → `recordForm`,
  `lightning-record-view-form` → `recordViewForm`,
  `lightning-button-icon` → `buttonIcon`).
- **Proposed component doesn't have the prop you expected** — trust the
  real API doc over memory. LBC evolves; cached knowledge lies.
- **Developer resists the shortlist** — don't skip Step 4. Still retrieve
  the docs for the developer's preferred choice so they see the actual
  trade-offs.
- **Developer wants to restyle LBC internals** — redirect to styling hooks
  (see the LBC Expert reference). Refusing shadow DOM penetration is the
  correct answer.
