# experience-lwc-design-generate - Technical Specifications, Rules & Schemas

## Workflow (mandatory five phases)

### Phase 1 — Gather PRD & requirements

**Goal:** produce a consolidated PRD that every later phase consumes.

1. **Obtain raw requirements** — collect the PRD, design spec, Figma URL, Aura source, or user text.
2. **Figma → PRD** (if applicable): follow [examples/figma-to-prd-blueprint.md](examples/figma-to-prd-blueprint.md) for the full Figma-frame analysis and PRD section guidelines. Inputs you need from the user: the Figma URL, a screenshot of the target frame, and (if Dev Mode is available) the metadata export for the node. Translate into the PRD skeleton from [examples/prd-analysis-template.md](examples/prd-analysis-template.md) using the section-by-section guidance in the blueprint.
3. **Aura → PRD** (if migrating): enumerate the Aura component's functionality that must be preserved — markup, controller/helper actions, events, attributes, and wired data — and feed that inventory into the PRD as explicit requirements. (In-place Aura → LWC porting is out of scope; this step only captures behavior for a fresh build.)
4. **Data requirements** (if the component reads/writes data): hand off to `experience-lds-data-requirements-generate`. That skill produces a validated data specification (object/field API names, recommended LDS API, implementation approach). Paste its output verbatim into the PRD.
5. **Adapter exploration**: hand off to `experience-lds-best-practices-apply` for the adapter selection rules (UI API vs GraphQL vs Apex) and the recommended wiring for the chosen approach.
6. **Naming**: `componentName` must be camelCase (e.g., `productCard`) and `tagName` must be its kebab-case form (e.g., `product-card`). Validate both with the bundled script — do not eyeball the check:

   ```bash
   "<skill_dir>/scripts/check-component-name.sh" <componentName> <tagName>
   ```

   The script exits nonzero (with an actionable stderr message) if either name is malformed or if the kebab form of `componentName` does not equal `tagName`.

**Deliverable:** a comprehensive PRD covering purpose, content, data, interactions, states, a11y, responsiveness, styling direction, localization, and security. Keep it checked into the workspace (e.g., `packages/skills/<skill>-workspace/<iteration>/PRD.md`).

### Phase 2 — Generate component code

**Goal:** initial `.html`, `.js`, `.css`, `.js-meta.xml` that strictly reflect the PRD.

1. Hand off to `experience-lwc-generate` with the PRD content as the spec. That skill owns PRD → code translation (events, getters, `@api`, `.js-meta.xml`, AI metadata) and is the authoring source of truth.
2. Use the SLDS decision hierarchy from `design-systems-slds-apply`:
   1. Prefer a matching Lightning Base Component (`experience-lwc-base-components-integrate`).
   2. Otherwise pick an SLDS Blueprint or utility class (per `design-systems-slds-apply`).
   3. Otherwise write custom CSS using SLDS styling hooks (also covered in `design-systems-slds-apply`).
3. Re-confirm the authoring baseline by walking the `experience-lwc-generate` checklist before proceeding.
4. Translate every PRD data requirement to either a wire adapter (UIAPI / GraphQL) or an explicit TODO.
5. Adhere strictly to the PRD:
   - Only include features and behaviors the PRD describes.
   - Mark uncertain areas with `// TODO:` comments that quote the PRD language raising the ambiguity.
   - Add extensive code comments explaining intent.
   - Do not split the component into more sub-components than the PRD implies.

**Deliverable:** a first-pass LWC bundle in the target path.

### Phase 3 — Optimize component

**Goal:** apply performance, maintainability, and best-practice fixes.

1. Walk the optimization checklist below before any other review:
   - Single responsibility, encapsulation, reusability.
   - Minimize DOM operations; batch updates via properties.
   - Audit event handlers and lifecycle hook usage (`renderedCallback` guards).
   - Consider lazy loading for heavy children.
2. Hand off to `experience-lwc-generate` for the LWC best-practices review pass (anti-patterns, reactivity, composition).
3. Hand off to the compliance suite for the pre-ship review — `experience-accessibility-validate` (a11y), `experience-lwc-security-validate` (LWS + Product Security), and `experience-lwc-rtl-validate` (RTL i18n). Run them together for the full quality pass.
4. If the component touches data, hand off to `experience-lds-best-practices-apply` for cache/consistency and referential-integrity checks.
5. Apply every accepted finding. Keep the PRD as the source of truth — do not add scope under the guise of optimization.

### Phase 4 — Lint, format, compile-check

Condition: only run steps whose tooling is configured in the project.

1. **Detect project tooling** — invoke the bundled detection script from the project root and read its `<tool>=yes|no` lines. Do NOT eyeball `package.json` / dotfiles in prose:

   ```bash
   "<skill_dir>/scripts/detect-project-tools.sh" <projectRoot>
   ```

   Sample output:

   ```text
   eslint=yes
   prettier=yes
   cursor-rules=no
   lwc-compiler=yes
   ```

   Run the substeps below only for tools reported `yes`; skip the rest.
2. **ESLint** (if `eslint=yes`) — run and fix all violations.
3. **Prettier** (if `prettier=yes`) — run for consistent formatting.
4. **Cursor rules** (if `cursor-rules=yes`) — apply every rule the project ships.
5. **LWC compiler** (if `lwc-compiler=yes`) — run via local dev server or SFDX; resolve every syntax/template error before moving on.

**Deliverable:** clean, validated component code.

### Phase 5 — Create tests

Hand off to `experience-lwc-accessibility-jest-run` for automated accessibility Jest coverage; add general-purpose Jest coverage in the same pass following the `experience-lwc-generate` test guidance, plus UTAM page object generation if the team requires it.

**Deliverable:** the LWC bundle with a passing test suite at or above the project's coverage threshold.

---

## Cross-References

- Skills chained by this workflow (in phase order):
  - `experience-lds-data-requirements-generate` — Phase 1.4 data spec (and Phase 1.5 adapter exploration alongside `experience-lds-best-practices-apply`).
  - `design-systems-slds-apply`, `experience-lwc-base-components-integrate` — Phase 2 styling decisions.
  - `experience-lwc-generate` — Phase 2 authoring baseline + Phase 3 best-practices review + Phase 5 AI-metadata audit.
  - `experience-lds-best-practices-apply` — Phase 2/3 data-layer adapter selection and consistency review.
  - `experience-accessibility-validate`, `experience-lwc-security-validate`, `experience-lwc-rtl-validate` — Phase 3 a11y/security/RTL review.
  - `experience-lwc-accessibility-jest-run` — Phase 5 automated a11y test generation.
  - Optional: add o11y instrumentation as a separate pass once the component stabilizes.
  - `experience-lwc-typescript-migrate` — optional once JS is green.
  - When the new component ships behind a flag, gate it with a feature flag during rollout.
  - Generate API-surface documentation once the public API is stable (no dedicated skill for this yet).
- Org-aware inputs used by this workflow:
  - Figma URL + screenshot (and, if available, the developer's Dev Mode metadata export) — Phase 1.2 Figma input.
  - `experience-lds-data-requirements-generate` owns the org-schema introspection and data-spec validation used in Phase 1 when the component needs org-backed data — hand off to that skill rather than duplicating its work here.
