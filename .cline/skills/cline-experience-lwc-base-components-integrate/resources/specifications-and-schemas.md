# experience-lwc-base-components-integrate - Technical Specifications, Rules & Schemas

## Workflow

### Step 1 — Read the **entire** component index first

Open [lightning-component-index.md](examples/lightning-component-index.md)
and scan **all** entries before making any selection. This is non-negotiable:
LBC's value comes from picking the most specialized component, and skipping
the scan leads to reinventing compound widgets out of primitives.

As you scan, compile a **candidate list** — every component whose description
touches any aspect of the use case. Do not filter or rank yet.

### Step 2 — Narrow to the most specific fit per feature

Once the scan is complete:

- For each feature in the use case, select the **most specific** component
  that covers it. Prefer a specialized compound (`lightning-record-form`,
  `lightning-tabset`, `lightning-datatable`) over a generic primitive
  (`lightning-input`, `lightning-button`) when the specialized one covers
  the scenario end-to-end.
- Avoid duplication: if `lightning-record-form` already renders fields for a
  record, do not pair it with `lightning-input-field` unless you're
  explicitly overriding behavior.

### Step 3 — Share the shortlist and confirm

Present the final shortlist to the developer with a one-line rationale per
component. Wait for explicit confirmation before pulling full API docs. This
prevents the agent from burning context on components the developer has
already mentally ruled out.

### Step 4 — Retrieve full API docs

Once confirmed, use the bundled helper to pull the exact API blocks — this
avoids ad-hoc grepping across a large reference:

```bash
scripts/extract-component-docs.sh <camelCaseName> [<camelCaseName>...]
```

Convert `lightning-<foo>` tags to camelCase (no `lightning-` prefix):

- `lightning-datatable` → `datatable`
- `lightning-record-edit-form` → `recordEditForm`
- `lightning-button-icon` → `buttonIcon`

Each returned block has the same shape: **Basic Information** (tag, namespace,
type), **Properties** (name, type, default, description), **Methods**,
**Events**, **Slots**, and (where applicable) usage notes. This skill is about
**picking** the components; the bundled reference is about **wiring** them.

### Step 5 — Produce integration guidance

Using the per-component reference, walk the developer through:

- The exact `<lightning-...>` tag and required attributes.
- Which events to bind (`onchange`, `oncommit`, `onsuccess`, …) and what
  the event payload contains.
- Any slots to fill (headers, footers, custom content).
- Known constraints from the component docs (e.g. `lightning-record-form`
  requires `object-api-name` and `record-id` for edit/view modes).

### Step 6 — Respect LBC styling rules

Do not override SLDS classes on LBC internals. See
[lbc-expert-guidance.md](examples/lbc-expert-guidance.md) for specifics.
Common issues:

- Targeting `.slds-button` or `.slds-input` in the host component's CSS to
  restyle an LBC — LBC ships inside a shadow root, so these selectors
  either leak into sibling components or get stripped entirely. Use the
  component's documented styling hooks (`--sds-c-button-*`, etc.) instead.
- Wrapping an LBC just to mutate its internal markup. You can't — the
  markup is hidden behind the shadow root. If the component doesn't expose
  the slot/prop you need, that's a platform-level gap, not a restyling job.
