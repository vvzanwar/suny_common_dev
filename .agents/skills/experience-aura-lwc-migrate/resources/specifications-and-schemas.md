# experience-aura-lwc-migrate - Technical Specifications, Rules & Schemas

## Workflow

This skill covers the analysis and PRD-generation phases only. It **does not** produce, edit, or validate LWC bundles, wire adapters, or tests. Phases 1–3 below are mandatory when this skill is invoked. Phases 4–5 describe the recommended downstream authoring flow — they are informational follow-up guidance for the caller and are NOT executed by this skill.

### Phase 1 — Analyze and draft the PRD

**Goal:** produce a draft YAML PRD that captures every section of the 14-section framework.

1. Inspect the caller-supplied Aura bundle files. Extract the component name, the `access` attribute from the `.cmp` metadata, and every embedded/referenced component.
2. Apply the framework in [examples/aura-prd-framework.md](examples/aura-prd-framework.md). State the `access` attribute explicitly in the overview and describe its implications (GLOBAL: publicly available across namespaces; PRIVILEGED/PUBLIC: restricted; etc.).
3. Never list the host component itself in the `unknowns` section — that creates a circular dependency. If no valid unknowns exist, use an empty array.
4. Save the draft PRD to the workspace (e.g., `packages/skills/<skill>-workspace/<iteration>/PRD-draft.yaml`).

**Deliverable:** draft PRD (YAML) covering the 14 sections.

### Phase 2 — Enhance the PRD with Aura expert lenses

**Goal:** harden each section using the eight Aura expert frameworks.

Apply the experts in order. Each pass reads the draft PRD and rewrites the relevant sections in place.

1. **Reference analysis** — apply [examples/aura-reference-expert.md](examples/aura-reference-expert.md) to `staticReferences`, `componentCommunication`, and `unknowns`. Enumerate every `$Resource`, `$ContentAsset`, `$Label`, `$Browser`, `$Locale`, `/lightning/*` route, and `c:*` / `force:*` / `lightning:*` dependency. The blueprint must never directly contain the Aura-specific strings `$ContentAsset`, `$Label`, `$Resource`, `$Browser`, or `$Locale`; replace each with a description of intent.
2. **Data analysis** — apply [examples/aura-data-expert.md](examples/aura-data-expert.md) to `dataRequirements`. The blueprint `dataRequirements` must not contain `force:recordData` or `lightning:recordViewForm` — document the underlying record, fields, and object-API-name instead. Rename `sObjectName` → `objectApiName`. Capture Apex-controller method names, input parameters, and output shapes.
3. **API analysis** — apply [examples/aura-api-expert.md](examples/aura-api-expert.md) to `componentCommunication`, `interactions`, and `staticReferences`. Document every public attribute (with type, default, and all usage intents), `<aura:method>` declaration, event firing (`component.getEvent(...).fire()`), and `Object`-typed callback attribute (these become LWC custom events).
4. **Slots analysis** — apply [examples/aura-slots-expert.md](examples/aura-slots-expert.md) to `contentRequirements`. Translate every `{!v.body}` / `{#v.body}` to a default slot entry (LWC components can have only one default slot — capture the condition under which it is present) and every `<aura:attribute type="Aura.Component">` or `"Aura.Component[]"` to a named-slot entry.
5. **Style analysis** — apply [examples/aura-style-expert.md](examples/aura-style-expert.md) to `styling` and `dataRequirements`. Move styling-related attributes out of `dataRequirements` and into `styling`. Document SLDS hooks, custom CSS, and any dynamic styling driven by JS.
6. **Values analysis** — apply [examples/aura-values-expert.md](examples/aura-values-expert.md) to `dataRequirements`. For every Aura attribute, record its default value (type + literal; or namespace + name for `$Label` references) in the `what` property.
7. **Resolver analysis** — apply [examples/aura-resolver-expert.md](examples/aura-resolver-expert.md) to `unknowns`. For each unknown, parse namespace + name, look up the corresponding file under `node_modules/@sfdc-internal/adk-knowledge/dist/` using the mapping rules, and either inline the resolved content or leave a note that manual research is required. If the `@sfdc-internal/adk-knowledge` package is not installed, note the expected path and leave the unknown in place.
8. **Redundant-code cleanup** — apply [examples/aura-redundant-code-expert.md](examples/aura-redundant-code-expert.md) across the PRD. Remove commented-out markup/JS/CSS, telemetry/instrumentation, and private attributes/methods that aren't used elsewhere — these don't carry forward to LWC. Keep the PRD's JSON shape intact; sections may end up with empty arrays. Generate a short report listing only the items that actually changed.

**Deliverable:** enhanced PRD (YAML) with all eight expert passes applied.

### Phase 3 — Accessibility pass

**Goal:** ensure the PRD's `accessibility` section meets WCAG 2.2 minimums.

1. Apply the WCAG 2.2 reviewers inline against the Aura source files (`.cmp`, `.controller.js`, `.helper.js`, `.renderer.js`, `.css`). Cover the Aura-scoped Success Criteria: 1.3.1 (ii) Tables, 1.3.5 Identify Input Purpose, 3.2.1 On Focus, 3.2.2 On Input, 3.3.2 Labels or Instructions, 4.1.2 Name / Role / Value. (When the sibling `accessibility-code-review-aura` skill ships in a follow-up PR, hand off to it instead.)
2. Fold each finding into the PRD's `accessibility` section. For every requirement, capture the WCAG Success Criterion it satisfies and the proposed LWC implementation approach (semantic HTML first, ARIA only where semantic HTML cannot achieve the same outcome).
3. Only cite violations that directly break a WCAG Success Criterion. Do not suggest enhancements outside WCAG scope.

**Deliverable:** PRD with an accessibility section that lists each required feature, the WCAG Success Criterion it satisfies, and the LWC implementation approach.

### Phase 4 — Downstream authoring (follow-up guidance, not executed here)

Once the enhanced PRD is complete, the caller can hand it off to an LWC authoring workflow. This skill does not perform any authoring. Recommended downstream steps:

- Pass the enhanced PRD to `experience-lwc-generate` as the design input, substituting for a Figma / written-spec input. This skill does not invoke `experience-lwc-generate`; the caller triggers it as a follow-up step.
- For data access decisions (UIAPI / GraphQL / Apex), the caller may consult LDS-focused workflows to translate the PRD's `dataRequirements` section into concrete adapters.
- For SLDS styling decisions, the caller may consult an SLDS design workflow.

### Phase 5 — Downstream verification (follow-up guidance, not executed here)

After LWC authoring completes, the caller can verify the migrated component with the project's standard test and review workflows — Jest coverage, accessibility Jest, a11y / security / RTL review, telemetry, feature-flag gating, etc. Apply [examples/aura-to-lwc-completeness-checklist.md](examples/aura-to-lwc-completeness-checklist.md) as a final scoring pass on the completed LWC.

---

## Cross-References

- `experience-lwc-generate` — recommended downstream authoring handoff (non-executing; the caller triggers it after this skill's PRD is complete).
