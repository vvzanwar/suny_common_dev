---
name: cline-experience-lwc-runtime-observe
description: "Use when running Salesforce Lightning Preview for an app or a single LWC component to extract the runtime DOM for inspection. TRIGGER when the user says \"preview an LWC locally\", \"run sf lightning dev\", \"launch Local Dev\", \"inspect a component's shadow DOM at runtime\", \"grab rendered HTML from a live preview\", \"troubleshoot what actually renders versus the template\", \"set up Salesforce Live Preview plugin\", \"lightning preview\", \"local dev server\", or \"extract runtime DOM\". DO NOT TRIGGER when the user is authoring or editing LWC source code (use experience-lwc-generate) or reviewing component code statically without running it."
metadata:
  version: "1.0"
  domains: ["Experience", "Developer Experience"]
  cliTools:
    - tool: ["python3"]
      semver: ">=3.0.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
  relatedSkills:
    - experience-lwc-generate
---

<!-- adk-managed-skill -->

# Previewing LWC Runtime — Local Dev + DOM Inspection

Guides the agent through two sequential jobs that typically run together:

1. **Start a Lightning Preview session** with the Salesforce CLI so an LWC app
   or component renders in a local dev environment.
2. **Navigate to that preview URL and extract the runtime DOM subtree** so the
   agent (or user) can reason about what actually rendered.

Preview is the prerequisite for DOM inspection. Keep them in this order.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `component-preview-and-dom.md, patterns-and-examples.md`

---

## When to Use This Skill

- The user wants to preview an LWC app or component locally before deploying
  (`sf lightning dev app` / `sf lightning dev component`).
- The user wants the rendered HTML subtree for a specific component at runtime
  — for a diff, a screenshot pipeline, or to reason about shadow DOM.
- The user asks why the template content "isn't in the DOM" — almost always
  a shadow-DOM misunderstanding handled in Step 2.

## Prerequisites

- Salesforce CLI (`sf`) installed. Check with `sf version`.
- `@salesforce/plugin-lightning-dev` installed. Check with `sf plugins`.
- An authenticated org (`sf org list` shows at least one connected org).
- For DOM extraction: browser automation available in the agent harness
  (Playwright, Puppeteer, Chrome DevTools Protocol — whatever is wired up).

---

## Step 1 — Start the Lightning Preview

Ask the user (or infer from the request) whether the scope is **app** or
**component**.

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full step commands and parameters.)*

## Step 2 — Extract the Runtime DOM

Only run this step once Step 1 has produced a live preview URL.

### 2a. Get an authenticated front-door URL — **without surfacing the token to agent context**
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full step commands and parameters.)*

## Verification Checklist

- [ ] `<skill_dir>/scripts/verify-toolchain.sh <orgAlias>` exited zero for the target alias.
- [ ] Preview command ran with `OPEN_BROWSER=false`.
- [ ] Preview URL logged in the `Lightning Preview running at URL: <URL>` format.
- [ ] Front-door URL fetched via `<skill_dir>/scripts/open-frontdoor.sh` (never `sf org open` directly).
- [ ] DOM extraction used `shadowRoot` traversal (not `innerHTML` on the host).
- [ ] DOM output was produced by `<skill_dir>/scripts/extract-dom.sh wrap …` (script owns the markers).

---

## Project QA Gate Hook (Frontend Validation)
Run the deterministic project QA gate to validate LWC/SLDS guardrails and Prettier formatting:
```powershell
powershell -ExecutionPolicy Bypass -File .cline/scripts/c-run-qa-gate.ps1 -TargetFiles "<path_to_component_file>"
```
