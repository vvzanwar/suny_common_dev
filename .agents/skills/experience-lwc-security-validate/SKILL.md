---
name: experience-lwc-security-validate
description: "Use this skill as THE specialized Lightning Web Security (LWS) validator for a Lightning Web Component bundle (`.js`, `.ts`, `.html`, `.css`, `.js-meta.xml`) — the canonical LWS/Product-Security review for LWCs, NOT a generic code-security pass. It produces either a severity-ranked finding list with code-level remediations or a SARIF 2.1.0 JSON score report keyed by the `lws-001`…`lws-023b` rule catalog. TRIGGER when the user asks to review, audit, or check an LWC component for LWS compliance issues and recommend fixes, score a component's LWS/security compliance, find dangerous DOM APIs or blocked sinks (`eval`, `Function`, `document.write`, `innerHTML`, `document.createElement('script')`, global-scope assignment to `window`/`globalThis`, unsafe URL schemes), or emit a SARIF security report. DO NOT TRIGGER for generic non-LWC security review, for building a new LWC (use experience-lwc-generate), accessibility (WCAG 2.2), RTL/i18n, or Apex/Aura/server-side review."
metadata:
  version: "1.0"
  domains: ["Experience"]
  relatedSkills:
    - design-systems-slds-validate
    - dx-code-analyzer-run
    - experience-lwc-generate
  cliTools:
    - tool: ["jq"]
      semver: ">=1.6"
    - tool: ["python3"]
      semver: ">=3.8"
---

<!-- adk-managed-skill -->

# Reviewing LWS Security

Run a structured Lightning Web Security (LWS) and Product Security compliance pass over a Lightning Web Component. Two output modes:

- **Review mode** (default) — severity-ranked findings + applied code fixes.
- **Score mode** — SARIF 2.1.0 JSON report keyed by the LWS rule catalog (`lws-001`…`lws-023b`) for downstream gating, eval scoring, or CI ingest.

Both modes use the same detection rules from the references; only the output format differs.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `lws-security-expert.md, security-analysis.md, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `patterns-and-examples.md, review-report.md, score-report.sarif.json`

---

## When to Use

- The user asks for a "security review", "LWS check", "pre-ship security audit", or "compliance pass" on a specific LWC → review mode.
- The user asks to "score" a component's security or wants machine-readable findings to feed a gate or eval → score mode.
- Preparing a component for release and needing a unified security report.
- After implementing a fix, to verify no regression in security posture.

Do NOT use this skill for:
- Building new components (use `experience-lwc-generate`).
- Accessibility (apply WCAG 2.2 separately) or RTL review — out of scope.
- Gating a fix behind a feature flag (apply feature-flag gating after fixes land).
- Non-LWC security review (Apex, Aura, server-side) — out of scope.

## Prerequisites

- Component path (LWC bundle under `modules/…`).
- Access to the component's JS/TS, HTML templates, CSS, and `.js-meta.xml`.
- Output mode: `review` (default — find, fix, report) or `score` (find, emit SARIF JSON, do NOT modify code). Confirm with the user before starting if it isn't obvious from the request.

## Knowledge Bases

Each reference is the source of truth. Do not summarize from memory — open the reference, apply the guidelines, and cite the specific section you used in the report.

- Lightning Web Security (LWS) catalog: [LWS Security Expert](examples/lws-security-expert.md) — blocked APIs and allowed alternatives.
- Rule catalog (`lws-001`…`lws-023b`): [Product Security Framework](examples/security-analysis.md) — for every rule the catalog gives the detection patterns and the canonical SARIF `ruleId` / `level` / `message` template. **Score mode emits one SARIF result per match using these exact values.**

## Workflow

### Step 1 — Scope the review

Collect the component path and identify the files to review. Include every file in the component bundle: `.html`, `.js`/`.ts`, `.css`, `.js-meta.xml`, and any child components owned by the same team that are invoked from the target.

Note any existing feature-flag gates — findings that require code changes must respect them.
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full specification.)*

## Verification

- Every catalog rule (`lws-001`…`lws-023b`) was evaluated against the bundle, not a hand-curated subset.
- Every finding has either been applied (review mode) or surfaced in the SARIF result (score mode), or carries an explicit deferred note with a reason.
- Each finding cites a specific catalog rule ID — no freeform "looks suspicious" entries.
- No new XSS sinks, unsafe URL flows, or blocked DOM APIs introduced by the fixes.
- Score-mode output is valid SARIF 2.1.0 JSON, returned inline, with no surrounding prose.

## Project QA Gate Hook (Frontend Validation)
Run the deterministic project QA gate to validate LWC/SLDS guardrails and Prettier formatting:
```powershell
powershell -ExecutionPolicy Bypass -File .agents/scripts/run-qa-gate.ps1 -TargetFiles "<path_to_component_file>"
```
