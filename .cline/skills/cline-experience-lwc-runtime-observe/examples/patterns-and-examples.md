# experience-lwc-runtime-observe - Reference Examples, Patterns & Troubleshooting

## Examples

For a worked end-to-end example (preview a component, capture the front-door
URL safely, and extract its DOM), load
[`examples/component-preview-and-dom.md`](examples/component-preview-and-dom.md).

---

---

## Troubleshooting

- **`verify-toolchain.sh` reports "Target org alias is not authenticated or not Connected"** —
  run `sf org login web --alias <orgAlias>` (the alias must match the one
  you passed to `verify-toolchain.sh` and the `-o` value the preview
  command uses).
- **`verify-toolchain.sh` reports the plugin is missing** — install it with
  `sf plugins install @salesforce/plugin-lightning-dev`.
- **Preview opens a browser window** — you forgot `OPEN_BROWSER=false`.
- **Empty DOM on extraction** — you're looking at `innerHTML` on a host. Use
  `element.shadowRoot.innerHTML` instead. Also verify you pierced the
  `lwr_dev-preview-container` shadow root.
- **Front-door token fails** — it's expired. Re-invoke
  `<skill_dir>/scripts/open-frontdoor.sh` and navigate within ~60 seconds.
