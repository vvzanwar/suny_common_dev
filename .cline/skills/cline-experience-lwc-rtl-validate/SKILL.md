---
name: cline-experience-lwc-rtl-validate
description: "Use this skill to review a Lightning Web Component (.html, .js, .css files) for right-to-left (RTL) internationalization correctness, producing a finding list with code-level fixes covering CSS logical properties, bidirectional text handling, keyboard semantics, and RTL-aware SLDS class usage. TRIGGER when the user says \"review this LWC for RTL\", \"audit i18n compliance\", \"fix bidirectional text rendering\", \"replace left/right CSS with logical properties\", \"check RTL layout issues\", \"verify SLDS RTL classes\", \"review my component for Arabic/Hebrew layout\", \"ensure this LWC works in RTL locales\", or \"check bidi text handling\". DO NOT TRIGGER when the user is building a new LWC (use experience-lwc-generate), refactoring SLDS classes themselves (use design-systems-slds-apply or design-systems-slds2-migrate), or performing accessibility/security review."
metadata:
  version: "1.0"
  domains: ["Experience"]
  relatedSkills:
    - design-systems-slds-apply
    - design-systems-slds2-migrate
    - experience-lwc-generate
  cliTools:
    - tool: ["python3"]
      semver: ">=3.8"
---

<!-- adk-managed-skill -->

# Reviewing LWC RTL

Run a structured right-to-left (RTL) internationalization compliance pass over a Lightning Web Component, producing a report of issues found and code-level fixes to bring the component into compliance with Salesforce RTL guidelines.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md, rtl-expert.md`

---

## When to Use

- The user asks for an "RTL review", "i18n check", "RTL compliance pass", or "RTL audit" on a specific LWC.
- Preparing a component for release in RTL locales (Arabic, Hebrew, Farsi, Urdu).
- Investigating layout defects reported in RTL environments.
- Verifying SLDS class usage after a CSS refactor.

Do NOT use this skill for:
- Building new components (use `experience-lwc-generate`).
- Modifying SLDS classes themselves (use `design-systems-slds-apply` or `design-systems-slds2-migrate`).
- Accessibility or security review — run those as separate passes with the relevant tooling.
- Gating a fix behind a feature flag (apply feature-flag gating after fixes land).

## Prerequisites

- Component path (LWC bundle under `modules/…`).
- Access to the component's HTML templates, JS/TS, and CSS.

## Knowledge Base

The reference is the source of truth. Do not summarize from memory — open the reference, apply the guidelines, and cite the specific section you used in the report.

- RTL internationalization: [RTL Expert](examples/rtl-expert.md)

## Workflow

### Step 1 — Scope the review

Collect the component path and identify the files to review: `.html`, `.js`/`.ts`, `.css`, and any child components owned by the same team that are invoked from the target.

Note any existing feature-flag gates (e.g., `Aura.org.rtlPhase1FixEnabled`) — findings that require code changes must respect them.
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## RTL

- <file>:<line> — <physical pattern> → <logical property / SLDS class>
  Fix: <one-sentence explanation>; applied: yes/no
- <file>:<line> — <physical pattern> → <logical property / SLDS class>
  Fix: <one-sentence explanation>; applied: yes/no

## Summary

- <n> issues found; <m> fixed; <k> deferred (with reason).
- <one-sentence overview of what was found and why the remaining items are correct or deferred>.
- Cite: RTL Expert — <section title>.
```

Populate the `## RTL` bullets from the `scan-rtl-css.sh` output for CSS findings, and append hand-authored bullets in the same shape for the Step 4 HTML/JS findings. When there are no findings, emit the single bullet `- No issues found.` under `## RTL` and a `Summary` that reports `0 issues found; 0 fixed; 0 deferred.` plus a one-sentence overview and citation.

### Step 7 — Apply fixes

For each accepted finding:

1. Edit the component files (CSS, HTML, JS/TS) to apply the fix.
2. Preserve existing correct behavior and existing feature-flag gates. If a gate is already configured (e.g., `Aura.org.rtlPhase1FixEnabled`), leave it untouched. Only when the caller has explicitly required a phased rollout for a new fix, wrap that fix behind a feature flag; otherwise apply the fix directly.
3. Do NOT remove or rename SLDS classes.
4. Do NOT silently delete old code — preserve the original path where a gate is required.

### Step 8 — Verify

- Re-run the review against the updated files; every fixed finding must no longer appear.
- Run Jest tests and any component-level RTL visual tests.

## Verification


*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
