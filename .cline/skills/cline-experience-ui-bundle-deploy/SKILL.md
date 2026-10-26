---
name: cline-experience-ui-bundle-deploy
description: "MUST activate when the project has a uiBundles/*/src/ directory and the task involves deploying to an org or post-deploy org setup. Deploys a UI bundle app and runs ordered setup: org auth, build, metadata deploy, permission-set and role assignment, Experience Cloud self-registration, social login / SSO / IDP linking (Auth Providers + SAML on a React site), site logout URL, seed-data import, and GraphQL schema fetch + codegen. Trigger signals: *.network-meta.xml, org-setup.config.json (socialLogin/logoutUrl), data-plan.json, sfdx-project.json, or mentions of deploy, org setup, social login/SSO, or logout URL on an Experience site. DO NOT TRIGGER when: creating a new UI bundle project (use experience-ui-bundle-project-generate); styling pages without deploying (use experience-ui-bundle-frontend-generate); adding a feature such as auth, search, or file upload without deploying (use the matching experience-ui-bundle-*-generate skill); configuring MFA permission sets (use experience-ui-bundle-mfa-configure)."
metadata:
  version: "1.3"
  domains: ["Experience", "Developer Experience"]
  relatedSkills:
    - "experience-ui-bundle-frontend-generate"
    - "experience-ui-bundle-mfa-configure"
    - "experience-ui-bundle-project-generate"
  cliTools:
    - tool: ["jq"]
      semver: ">=1.6"
    - tool: ["node"]
      semver: ">=18.0.0"
    - tool: ["npm"]
      semver: ">=7.0.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
  minApiVersion: "66.0"
allowed-tools: Bash Read Write Edit
---

# Deploying a UI Bundle App

Deploy order is load-bearing: a step's output is the next step's precondition
(deploy before schema fetch; permissions before schema fetch; role/self-reg
before the schema the guest user must see). This is the canonical setup sequence,
ported from the reference `org-setup.mjs`. The `org-setup.mjs` line
citations in `examples/` are port-provenance (why each rule exists) pointing at
that external reference script — not files shipped with this skill — so you don't
need to open them to run the steps.

Run each step in order. **Every optional step is presence-driven**: if its
convention file is absent, no-op cleanly and move on — do not fabricate config.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `Communities.settings-meta.xml, data-delete.apex, data-import.apex, network-selfreg-xml-recipe.md, network-selfreg.apex, org-setup.config.template.json, prepare-import-unique-fields.js, social-login-auth-providers.apex, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `config-scaffold.md, data-import.md, dev-preview.md, graphql.md, license-checks.md, logout-url.md, patterns-and-examples.md, role-assignment.md, self-registration.md, social-login.md`

---

## Inputs to gather up front

Read these from the project; **ask the user** only for what's missing:

- **Target org** — alias/username for `--target-org`. Ask if not obvious.
- **Source root** — run `scripts/get-source-root.sh` to resolve the metadata
  source dir from `sfdx-project.json` (`packageDirectories[0].path` + `/main/default`).
  It exits non-zero if the project file is missing or malformed. Never hardcode
  `force-app/main/default`.
- **`org-setup.config.json`** (optional) — drives permset assignment, role,
  self-registration, and social login. Absent keys mean "skip that step".
  **Exception:** if the file is missing but `permissionsets/` has permsets to
  assign, don't silently skip — scaffold the config or gather equivalent inputs
  (see step 4).
- **`data-plan.json`** (optional, in the project's `data/` dir) — presence enables the data step.

## Step 1 — Org authentication (always)

Unconditional precondition; cannot be skipped. If the org is already connected
(`sf org display --target-org <org> --json` succeeds), no-op. Otherwise:

```bash
sf org login web --alias <org>
```

A failed login aborts the whole setup before deploy.

## Step 2 — Pre-deploy UI bundle build

Build **every** UI bundle so `dist/` exists before metadata deploy (UI bundle
entities deploy the built output). For each bundle dir under `uiBundles/`:

```bash
npm install
npm run build
```

Run when deploying UI bundles and `dist/` is missing or source changed.

## Step 3 — Deploy metadata

If self-registration is configured:

1. **Deploy license pre-check first** (see `examples/license-checks.md`) — it
*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full step commands and parameters.)*

## Step 3b — Set the site logout URL (config-gated)

Run only when `org-setup.config.json` has a top-level `logoutUrl`. If absent,
no-op cleanly and say so. **Non-destructive and idempotent** — no ask needed.

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full step commands and parameters.)*

## Step 4 — Assign permission sets

Discover permission sets under `<packageDir>/main/default/permissionsets/`. If
none exist and none were passed explicitly, skip.

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for full step commands and parameters.)*

## Step 5 — Assign role (config-gated)

Run only when `org-setup.config.json` has `role: { assignee: "currentUser",
roleName: "<UserRole>" }`. Assigning a role to the current user is what lets
Experience Cloud self-registration work. Idempotent — skip if the user already

*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
