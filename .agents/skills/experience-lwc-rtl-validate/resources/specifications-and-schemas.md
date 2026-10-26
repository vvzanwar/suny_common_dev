# experience-lwc-rtl-validate - Technical Specifications, Rules & Schemas

## Workflow

### Step 1 — Scope the review

Collect the component path and identify the files to review: `.html`, `.js`/`.ts`, `.css`, and any child components owned by the same team that are invoked from the target.

Note any existing feature-flag gates (e.g., `Aura.org.rtlPhase1FixEnabled`) — findings that require code changes must respect them.

### Step 2 — Read the knowledge base

Read [RTL Expert](examples/rtl-expert.md) top-to-bottom before judging. It enumerates the physical-to-logical property mappings, bidirectional text handling patterns, and — critically — the SLDS constraints that override generic RTL advice.

### Step 3 — CSS inspection

Run the deterministic scanner over every `.css` file in the bundle. **The scanner matches CSS declarations only — never SLDS class names in HTML `class="…"` attributes (see Step 5).** Inline `style="…"` attributes must be scanned separately (either by extracting them into a temp file or by inspecting the HTML by hand and applying the same rules).

```bash
"<skill_dir>/scripts/scan-rtl-css.sh" <cssFile1> [<cssFile2> ...]
```

Each output line has the shape `<file>:<line>: <property>: <value> -> <logical-property>: <logical-value>`. The scanner tokenizes declarations (splits on `;` inside `{…}`) so minified multi-declaration lines produce one finding per physical declaration and selector names are never rewritten. Translate each line into a Step 6 bullet (`<file>:<line> — <pattern> → <logical property>` plus a one-sentence Fix). Empty output IS a valid result — record it as "No issues found." in the report.

Scanner-recognised patterns (kept in sync with the script's regex — do not add rules here without also updating `scan-rtl-css.sh`):

- `left` / `right` → `inset-inline-start` / `inset-inline-end`
- `margin-left` / `margin-right` → `margin-inline-start` / `margin-inline-end`
- `padding-left` / `padding-right` → `padding-inline-start` / `padding-inline-end`
- `text-align: left` / `right` → `text-align: start` / `end`
- `border-left-*` / `border-right-*` → `border-inline-start-*` / `border-inline-end-*`
- `float: left` / `float: right` → `float: inline-start` / `float: inline-end` (or remove and use flex/grid)
- `transform: translateX(...)` — flagged; sign-flip or use a logical alternative

`border-radius` with explicit corners is not scanned automatically — inspect corner shorthand by hand and translate to the logical corner variants.

### Step 4 — HTML / JS inspection

Walk templates and JS for:

- Icon flipping hints — flag **only** icons with directional semantics that appear in **plain HTML `<img>` / inline SVG / raw Unicode / background-image CSS**. **Do NOT flag `<lightning-icon>` in LWC templates** (including directional utility names like `utility:chevronright`, `utility:chevronleft`, `utility:back`, `utility:forward`); `lightning-icon` renders through the Lightning icon service, which mirrors directional utility icons automatically in RTL locales. Treat it the same way you treat SLDS utility classes.
- `dir` attribute usage — confirm it's sourced from locale, not hardcoded.
- Keyboard arrow-key semantics — Left/Right arrow handlers should swap in RTL where navigation is directional (tab bars, sliders, tree expand/collapse).
- Directional Unicode controls — ensure user-generated text is not stripped of RLM/LRM markers when rendered.
- Inline `style="…"` with physical properties — same rules as Step 3.

### Step 5 — SLDS constraints

SLDS class handling is the highest-priority RTL rule. **When a rule below says "do NOT flag", that class must not appear as a finding in the report — not as an issue, not as a "fix", not as a rename suggestion.**

1. **SLDS utility classes with `_left` / `_right` suffixes are RTL-aware and MUST NOT be flagged.** They already mirror automatically in RTL under the hood — this includes `slds-text-align_right`, `slds-text-align_left`, `slds-m-left_*`, `slds-m-right_*`, `slds-p-left_*`, `slds-p-right_*`, `slds-float_left`, `slds-float_right`, `slds-border_left`, `slds-border_right`, and the rest of the `_left` / `_right` utility family. Leave them exactly as written.
2. **`_start` / `_end` variants of SLDS classes DO NOT EXIST.** Never rename `slds-*_right` → `slds-*_end` or `slds-*_left` → `slds-*_start`. There is no such class; the rename would break the stylesheet. If you are tempted to "fix" an SLDS utility class by adding `_start`/`_end`, STOP — the correct action is to leave the class alone (see rule 1).
3. **Never modify, rename, or remove any `slds-*` class.** SLDS ships RTL-aware stylesheets; altering classes breaks the contract.
4. **If custom CSS duplicates what an SLDS class already handles**, the fix is **removal — not conversion**. Delete the redundant custom rule; leave the SLDS class alone. Do NOT convert the removed property to its logical equivalent, and do NOT offer removal + conversion as two alternatives; there is one fix, and it is deletion. Example: `float: right` in a `.css` file next to `class="slds-button__icon_right"` in the template — delete the entire `.custom-icon { float: right }` rule. Do not "also suggest `float: inline-end`" — that would be wrong; the SLDS class already handles placement.
5. **If an SLDS class has an RTL gap**, add complementary custom CSS rather than altering the SLDS class.

**Concrete negative example** — a template with `<span class="slds-text-align_right slds-m-right_small">…</span>` alongside a custom `padding-left: 4px` in the component's CSS: the ONLY finding is the CSS `padding-left` (Step 3). The two `slds-*_right` classes are not findings and must not appear in the report.

### Step 6 — Produce the report

Write `<outputDir>/rtl-review.md` in this exact shape (blank line after each `##` heading; every summary sentence ends with a period):

```markdown

---

## Cross-References

- Related skills:
  - `design-systems-slds-apply` — for SLDS class-level changes beyond custom CSS cleanup.
  - `design-systems-slds2-migrate` — when RTL cleanup surfaces classes that need SLDS2 migration first.
  - `experience-lwc-generate` — when the review surfaces a need to regenerate the component rather than patch it.
  - Accessibility (WCAG 2.2) and security (LWS + Product Security) reviews are separate passes — run them with the appropriate tooling for each, not this skill.
  - Feature-flag gating is out of scope for this skill; apply it separately only when the caller has explicitly required a phased rollout (see Step 7).
