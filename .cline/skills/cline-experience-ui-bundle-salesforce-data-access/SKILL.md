---
name: cline-experience-ui-bundle-salesforce-data-access
description: "MUST activate whenever a uiBundles/*/src/ project reads, writes, or displays Salesforce data — INCLUDING building a page, list, table, card grid, dashboard, or form that shows, filters, counts, or edits records of any object (e.g. Property__c, Account, Case), even when the prompt names only the UI or the object and never says query, GraphQL, or SDK. Records behind such a component come from Salesforce, so use this ALONGSIDE experience-ui-bundle-frontend-generate: that skill styles the component, this one wires its data. Also triggers on @salesforce/platform-sdk imports, sdk.graphql.query / mutate / sdk.fetch calls, *.graphql files, or stale data needing force-refresh. New read/write work uses the current @salesforce/platform-sdk API; migrate only EXISTING old @salesforce/sdk-data callable code. Not for pure styling/layout with no records, app shell, file upload, or auth/search scaffolding. DO NOT TRIGGER for OAuth, object/field schema changes, Bulk/Tooling/Metadata API, or declarative automation."
metadata:
  version: "2.2"
  domains: ["Experience", "Platform"]
  minApiVersion: "66.0"
  relatedSkills:
    - "experience-ui-bundle-frontend-generate"
    - "platform-metadata-deploy"
  cliTools:
    - tool: ["node"]
      semver: ">=18.0.0"
    - tool: ["npm"]
      semver: ">=9.0.0"
    - tool: ["npx"]
      semver: ">=9.0.0"
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# Salesforce Data Access (UI bundles)

All Salesforce data access in a UI bundle goes through the **`@salesforce/platform-sdk`**
data SDK. The SDK handles auth, CSRF, and base-URL resolution, and — on the WebApp
surface — caches every GraphQL query by default.

This file is the **workflow + guardrail spine**. Depth lives in linked docs:

- **[examples/graphiti-cli.md](examples/graphiti-cli.md)** — the **`graphiti` CLI** (`sf-gql-*`
  commands) that compiles a small JSON spec into a schema-correct, guardrail-applied query +
  variables + types. The preferred way to author the GraphQL in steps below; falls back to the
  schema-grep script when unavailable.

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `caching.md, graphiti-cli.md, graphql-hand-authoring.md, migration.md, patterns-and-examples.md, rest-and-integration.md, sdk-api.md`

---

## The one-paragraph mental model

`const sdk = await createDataSDK()`. Then `sdk.graphql` is a **namespace**, not a
function: **`sdk.graphql!.query({...})`** for reads, **`sdk.graphql!.mutate({...})`**
for writes. On WebApp, **every `query()` is cached by default** (300s). HTTP 200 never
means success — always check `result.errors`. Verify every entity and field against the
schema before you query it: one unverified field fails the *whole* query at runtime, and
`schema.graphql` is too large to eyeball — look it up.

```typescript
import { createDataSDK, gql } from "@salesforce/platform-sdk"; // gql tags the query string so codegen + eslint validate it

const sdk = await createDataSDK();
const result = await sdk.graphql!.query({ query: GET_ACCOUNTS, variables });
if (result.errors?.length) throw new Error(result.errors.map((e) => e.message).join("; "));
const rows = result.data?.uiapi?.query?.Account?.edges?.map((e) => e.node) ?? []; // unwrap edges/node; read field values via .value
```

Typed call params (`query<GetAccountsQuery, GetAccountsQueryVariables>`), the `CacheControl`
type, and `NodeOfConnection<T>` (extracts a node type from a Connection for clean typing) all
live in [examples/sdk-api.md](examples/sdk-api.md).

> **This changed (breaking — PR #502).** The previous callable `sdk.graphql(...)` form and the
> previous package name are **dead** — the code above is the only correct form. If you encounter
> the old API in existing code (or a stale `dist/` artifact), don't copy it; convert it per
> [Working on existing code](#working-on-existing-code-migration).
>
> **`sdk.graphql!` is WebApp-only.** The non-null assertion above is correct *only* if the
> bundle runs solely on WebApp. On other surfaces it can crash — decide before you write it.
> See **[Surfaces — `!` vs guard](#surfaces--sdkgraphql-vs-guard)** below.

---

## Ground the SDK contract on the installed types (tier-2a)

`@salesforce/platform-sdk` force-publishes on a shared version line and moves
fast. This SKILL's prose is a point-in-time snapshot of the call contract; the
**installed declarations are authoritative for the version you actually have**.
Before writing any `query`/`mutate`, read the installed types and let them win:

- `node_modules/@salesforce/platform-sdk/dist/core/data.d.ts` — `query`/`mutate`
  signatures, `QueryResult` (has `subscribe`/`refresh`) vs `MutationResult` (has
  neither, by design), the `CacheControl` union, the default TTL.
- `node_modules/@salesforce/platform-sdk/dist/data/index.d.ts` — `createDataSDK`,
  `gql`, `NodeOfConnection`.

**Precedence — installed `.d.ts` beats this SKILL's prose.** If a signature,
type, or default here disagrees with the installed declaration, follow the
declaration and note the drift; do not "correct" the types to match the prose.

**Grounding ladder** (one model, two axes):

| Tier | Grounds | Answers | Via |
|---|---|---|---|
| tier-1 | GraphQL **schema** | *what data exists* | graphiti / `graphql-search.sh` (Precondition #2) |
| tier-2a | SDK **contract** | *how you call it* | the installed `.d.ts` above |
| tier-2b | SDK **behavior** | *how it behaves* | the installed `docs/data/` folder (below) |
| spine | this SKILL.md | workflow + guardrails that orchestrate all three; the fallback when a tier can't ground |

**Fallback when the `.d.ts` is absent** — the package **is installed** but ships
no declarations (a stale or types-stripped build artifact). Then use this SKILL's
prose as best-effort. This fallback does **not** cover a missing package: if
`@salesforce/platform-sdk` isn't installed, stop and install it (Precondition #1)
— do not author calls from prose against a dependency you don't have.


*(See [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) and [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for complete reference details.)*
