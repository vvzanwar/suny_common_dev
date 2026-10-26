---
name: experience-ui-bundle-frontend-generate
description: "MUST activate before editing ANY file under uiBundles/*/src/ (or the bundle's index.html) for visual or UI changes to an EXISTING app — pages, components, sections, layout, styling, colors, fonts, navigation, animations, branding, or any look-and-feel change. Use this skill when modifying pages, components, layout, styling, navigation, or branding in an existing UI bundle app. Activate when the project contains appLayout.tsx, routes.tsx, src/pages/, src/components/, src/styles/global.css, or the bundle's index.html. This skill contains critical project-specific conventions (appLayout.tsx shell, shadcn/ui components, Tailwind CSS, Salesforce base-path routing, module restrictions) that override general knowledge. Without this skill, generated code will use wrong imports, break routing, or ignore project structure. Do NOT use when creating a new app from scratch or the bundle has not been scaffolded yet (use experience-ui-bundle-app-coordinate instead)."
metadata:
  version: "1.1"
  domains: ["Experience"]
  relatedSkills:
    - "experience-ui-bundle-app-coordinate"
    - "experience-ui-bundle-features-generate"
    - "experience-ui-bundle-metadata-generate"
    - "experience-ui-bundle-salesforce-data-access"
  cliTools:
    - tool: ["node"]
      semver: ">=18.0.0"
    - tool: ["npm"]
      semver: ">=8.0.0"
    - tool: ["npx"]
      semver: ">=8.0.0"
    - tool: ["python3"]
      semver: ">=3.10.0"
---

# UI Bundle UI

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `component.md, header-footer.md, page.md, patterns-and-examples.md`

---

## Resolve the Bundle Directory

**MUST** run `node scripts/resolve-ui-bundle.mjs [project-root]` before applying any rule below or writing any file — an ad-hoc `find`/`ls` is not a substitute; it does not enforce the exit-code gate below. Always invoke via `node` (never as a bare executable) so this works on Windows as well as macOS/Linux. It reads `sfdx-project.json`'s `packageDirectories[0].path` (does not assume `force-app` — the source path is configurable) and looks under `<sourceDir>/main/default/uiBundles/`:

- **Exit 0**, bundle path printed to stdout: exactly one bundle directory found — that is the bundle directory. Use that exact directory name; never substitute a different name (e.g. a generic "AcmePortal" example from a prompt template) for the one actually printed.
- **Exit 2**, candidates printed to stderr: multiple `uiBundles/*` subdirectories exist — do not guess, and do not write to any of them, or to a bundle name not in the printed list. Ask the user which app/bundle they mean before editing or running any command.
- **Exit 1**: `sfdx-project.json` missing/invalid, or no bundle directory found at all.

Run all `npm`/lint/build/dev commands from inside the resolved bundle directory, never from the project root.

## Preconditions

Before applying any rule below, confirm this is an existing, scaffolded UI bundle: **MUST** run `node scripts/check-preconditions.mjs <bundle-dir>` with the directory `resolve-ui-bundle.mjs` printed.

- **Single-bundle (exit 0) case**: run it once, on that bundle.
- **Multi-bundle (exit 2) case**: do not run it yet — first ask the user which app/bundle they mean, per the Resolve step above. Once the user names the bundle, run `check-preconditions.mjs` on that one bundle only. Never run it against multiple candidates speculatively before the user has chosen — that means touching/inspecting bundles the user didn't ask about.
- **Exit 0**: the bundle has `src/appLayout.tsx`, `src/routes.tsx`, and `src/components/ui/` — proceed.
- **Exit 1**, missing pieces listed: this is a fresh SFDX project, a non-UI-bundle React project, or a partially-scaffolded bundle — **stop**. Do not fall back to generic React knowledge (e.g. `react-router-dom`, a hardcoded basename, or raw HTML), and do not hand-write `appLayout.tsx`/`routes.tsx`/a page/a component to "fill in" the missing scaffold, even for a casual, vague, or urgent-sounding request ("just change the header", "make the background blue"). Tell the user the bundle isn't scaffolded yet and direct them to `experience-ui-bundle-app-coordinate` (or `experience-ui-bundle-metadata-generate`) to scaffold it first. If, after the user names their intended bundle, that one turns out to be unscaffolded, stop and redirect for it — do not silently switch to scaffolding a different candidate instead.

Never invent, assume, or fall back to a bundle name that doesn't appear in the actual `<sourceDir>/main/default/uiBundles/` listing on disk — including a name that only appears as example/template text elsewhere (a prompt, a directive, prior conversation). If what's on disk doesn't match that example, disk wins.

## Identify the Task

Determine which category the request falls into:

| Category | Examples | Implementation Guide |
|----------|----------|---------------------|
| **Page** | New routed page (contacts, dashboard, settings) | `examples/page.md` |
| **Header / Footer** | Site-wide nav bar, footer, branding, renaming the app | `examples/header-footer.md` |
| **Component** | Widget, card, table, form, dialog | `examples/component.md` |

A request to rename/rebrand the app (e.g. "call it X everywhere a user would see it") is a **Header / Footer** task even though it doesn't mention "header" by name — it always touches at least two files: `src/appLayout.tsx` (header/nav brand text) AND `index.html`'s `<title>` (browser tab title). Treat these as one atomic change; a rename that only updates one of the two is incomplete.

---

## Pre-built Features (Check Before Hand-Building)

Some capabilities ship as pre-built, tested feature packages. The catalog **evolves and is not something you can know from memory** — never decide from the request wording alone whether a capability "is" or "isn't" a feature. Before hand-writing any non-trivial capability (anything beyond a plain page, component, or styling change) in this skill:

1. **Consult the authoritative catalog.** Invoke `experience-ui-bundle-features-generate`, which runs `list` to show the *current* set of installable features. Do not rely on a hardcoded or remembered list — this skill deliberately names none, because any names it listed would go stale.
2. **Detect whether a matching feature is already installed** in the bundle — inspect `package.json` dependencies and existing `src/` files. If present, do not reinstall or re-implement it — **but you must still adopt it**: invoke `experience-ui-bundle-features-generate` to `describe` it (which reads the feature's README — the adoption contract), wire it into the app, and, if the feature ships config (e.g. a `config.json`), set that for this app's data and use case. Installed-but-unconfigured is not done.
3. **If a matching feature exists in the catalog but isn't installed**, let `experience-ui-bundle-features-generate` install the tested package. Do not build it from scratch here.
4. **Only hand-build** a capability that has no matching catalog feature.

When this skill runs as a phase of `experience-ui-bundle-app-coordinate`, a matching feature is often already present — installed by an earlier phase, or shipped by the template. Already-present is **not** a reason to skip: step 2 still requires adopting and configuring that feature for this app. Only the install/re-implement work is ever skipped — never the wiring and configuration.

---

## Layout and Navigation

`appLayout.tsx` is the source of truth for navigation and layout. Every page shares this shell.

When making any change that affects navigation, header, footer, sidebar, theme, or layout:

1. Edit `src/appLayout.tsx` — the layout used by `routes.tsx`
2. Replace all default/template nav items and labels with app-specific links and names
3. Replace placeholder app name everywhere: header, nav brand, footer, `<title>` in `index.html`

`index.html` lives at the bundle root (not under `src/`), but it is still in scope for this skill whenever branding or the app name changes — the leftover `<title>React App</title>` / `Vite + React` boilerplate is a common ship-blocker that `npm run lint`/`npm run build` never catches.

Before finishing, confirm: Did I update `appLayout.tsx` with real nav items and branding? Then run `node scripts/verify-rules.mjs` to check for residual boilerplate (see Verification below).

| What | Where |
|------|-------|
| Layout, nav, branding | `src/appLayout.tsx` |

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
