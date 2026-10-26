# experience-ui-bundle-salesforce-data-access - Reference Examples, Patterns & Troubleshooting

## Reference Code & Command Examples

### Example 1
```typescript
import { createDataSDK, gql } from "@salesforce/platform-sdk"; // gql tags the query string so codegen + eslint validate it

const sdk = await createDataSDK();
const result = await sdk.graphql!.query({ query: GET_ACCOUNTS, variables });
if (result.errors?.length) throw new Error(result.errors.map((e) => e.message).join("; "));
const rows = result.data?.uiapi?.query?.Account?.edges?.map((e) => e.node) ?? []; // unwrap edges/node; read field values via .value
```

### Example 2
```typescript
   import type { GetAccountsQuery, GetAccountsQueryVariables } from "../graphql-operations-types";

   const result = await sdk.graphql!.query<GetAccountsQuery, GetAccountsQueryVariables>({
     query: GET_ACCOUNTS,
     variables: { first: 20 },
     // cacheControl,            // optional — see Freshness & caching
   });
   ```
5. **Handle the result.** `result.data` + `result.errors` are the initial snapshot;
   `result.subscribe` / `result.refresh` are the reactive handles. Always check
   `errors` before reading `data`:

   ```typescript
   if (result.errors?.length) throw new Error(result.errors.map((e) => e.message).join("; "));
   const rows = result.data?.uiapi?.query?.Account?.edges?.map((e) => e.node) ?? [];
   ```

Defend consuming code with `?.`/`??` (because `@optional` can omit fields). Error-handling
stances (strict / tolerant / discriminated) ground on **tier-2b** `docs/data/` (fallback:
guardrail #1 — always check `result.errors`); `NodeOfConnection` typing in [examples/sdk-api.md](examples/sdk-api.md).

---

## Write workflow

1–3 as above (schema lookup → write the **mutation** → codegen). To compile the mutation with
graphiti, use `sf-gql-create` / `sf-gql-update` / `sf-gql-delete` — they emit the
`uiapi { <Object>Create(input: $input) { Record {…} } }` shape; the `types` field tells you
the input shape. Details: [examples/graphiti-cli.md](examples/graphiti-cli.md).
4. **Call `mutate()`** — note the option key is **`mutation`**, not `query`, and that
   mutations are **never cached**. The runtime `variables` shape differs per operation —
   values are **raw** (never `{value}`-wrapped; that wrapper is a read-shape thing and breaks
   writes) and nest under the **entity key**:

   ```typescript
   // create — input.<Entity> holds the new field values
   variables: { input: { Account: { Name: "Acme", Industry: "Technology" } } }
   // update — sibling Id alongside the entity key
   variables: { input: { Id: "001…", Account: { Industry: "Finance" } } }
   // delete — Id only, no entity key (generic RecordDeleteInput)
   variables: { input: { Id: "001…" } }

   const { data, errors } = await sdk.graphql!.mutate<CreateAccountMutation, CreateAccountMutationVariables>({
     mutation: CREATE_ACCOUNT,
     variables: { input: { Account: { Name: "Acme" } } },
   });
   if (errors?.length) throw new Error(errors.map((e) => e.message).join("; "));
   ```

   This is the **`variables` shape** the spine owns; the CLI `types`-field interpretation is in
   [examples/graphiti-cli.md](examples/graphiti-cli.md) and the GraphQL-document field constraints
   (`createable`/`updateable`, `ApiName` references, `@{alias}` chaining) in
   [examples/graphql-hand-authoring.md](examples/graphql-hand-authoring.md).
5. **Re-freshen affected reads.** `mutate()` has no `refresh`. To update a live list
   after a write, hold the `QueryResult` from your earlier `query()` call (e.g.
   `accountsResult`) and call `await accountsResult.refresh()` (forced re-fetch, pushes
   to subscribers) — note this is the read's handle, not anything `mutate()` returns. See
   **[Freshness & caching](#freshness--caching)**.

Mutation syntax is exacting: wrap under `uiapi(input: { allOrNone: ... })`, only
`createable`/`updateable` fields, Create/Update output is always `Record` but **Delete has no
`Record` field — select `Id` only**. Full template + chaining + constraints:
[examples/graphql-hand-authoring.md](examples/graphql-hand-authoring.md).

---

## Beyond record CRUD

The `uiapi` namespace is not just record reads/writes. Before reaching for REST, check
whether GraphQL already covers it — the same `sdk.graphql!.query()` call, different
sub-selection. The top-level `uiapi` fields:

| Need | Use | Returns |
|---|---|---|
| Query records | `uiapi { query { <Entity>(...) } }` | records (the [Read workflow](#read-workflow)) |
| Counts / sums / grouped rollups without pulling rows | `uiapi { aggregate { <Entity>(groupBy: …) } }` | aggregated buckets |
| Object/field metadata — labels, data types, `createable`/`updateable`, record types | `uiapi { objectInfos(apiNames: […]) }` | `ObjectInfo[]` |
| Picklist values (per record type) | `uiapi { objectInfos(objectInfoInputs: […]) { fields … on PicklistField { … } } }` | picklist values |
| Related-list metadata — display columns, ordering for a parent's related list | `uiapi { relatedListByName(parentApiName, relatedListName) }` | `RelatedListInfo` |

Same rules as record reads: verify every type/field first, `@optional` where FLS applies, check
`result.errors`. Aggregations can be compiled with `npx graphiti sf-gql-aggregate` (pass
`groupBy` + `aggregations`); object metadata / picklists / related lists are hand-authored —
templates: [examples/graphql-hand-authoring.md](examples/graphql-hand-authoring.md).

> Two related capabilities (the **current-user** record and **layout** delivery) need
> confirmation against a current org schema before this skill documents a query shape —
> tracked as a follow-up, not yet covered here.

---

## Freshness & caching

Ground the cache model on **tier-2b** `docs/data/` — cache-key mechanics, what-gets-cached,
the shared-by-`baseUrl` details, uncached-surface semantics, and the reactive-handle nuance all
live there ([examples/caching.md](examples/caching.md) restates it as a version-stamped fallback). The
**load-bearing fallback** (enough to act when the folder is absent):

- **Caching is ON by default on WebApp** — every `query()` cached at **300s**; no opt-in flag, no
  factory, no `/cache` subpath. **Do not build your own cache** (React Query, SWR, `localStorage`,
  hand-rolled `Map`). `mutate()` is never cached.
- **Shared by host + API version** — the same query+variables from another `createDataSDK()`
  targeting the same host **and** `apiVersion` is a cache hit = one network call; the per-instance
  fetch pipeline stays isolated.
- **Two distinct freshness tools — don't conflate them:**
  1. **Per-call `cacheControl`** (one-shot policy on the options bag): `"no-cache"` (bypass, writes
     back) / `"only-if-cached"` / `{ type: "max-age", maxAge: <seconds> }`; default 300s. Thread it as
     an optional param on the read fn and expose each policy as a **thin named export** in the same
     data-layer file (`refreshAccounts` → `"no-cache"`, `offlineAccounts` → `"only-if-cached"`, …). An
     `"only-if-cached"` **miss** surfaces on `result.errors` with `extensions.code === "CACHE_MISS"` —
     render an empty state, **do not** fall back to the network (that defeats offline-first).
  2. **Reactive `subscribe` / `refresh`** (live handle on a `QueryResult`): `subscribe(cb)` fires on
     **later** snapshots only (always `unsubscribe` on teardown); `refresh()` re-fetches, bypasses the
     cache, pushes to subscribers — use it after a `mutate()` (which has no `refresh`). Multi-subscriber
     fan-out / independence ground on **tier-2b** `docs/data/`.

---

## Working on existing code (migration)

**Only enter this path if the existing code actually uses the old API** — i.e. it imports
`@salesforce/sdk-data` or calls the callable `sdk.graphql(query, vars)` form. For any new
read/write, ignore migration entirely and use the [Read workflow](#read-workflow) /
[Write workflow](#write-workflow) — those already show the **only** correct API.

When you do have old code to convert, see **[examples/migration.md](examples/migration.md)** for the
before→after diff (imports, query/mutate calls, optional-chaining → non-null assertion, codegen
type placement) and a checklist. The target API is exactly what the Read/Write workflows above
prescribe — migrating is just swapping the old form for that.

---

## Platform guardrails — never regress these

These are Salesforce GraphQL platform behaviors, independent of the SDK. Violations cause
silent runtime failures. (Details + templates: [examples/graphql-hand-authoring.md](examples/graphql-hand-authoring.md).)

1. **HTTP 200 ≠ success** — always parse `result.errors`; the Promise resolves even on failure.
2. **Schema is the only source of truth — verify, never invent.** Verify every
   entity/field/type via graphiti `sf-gql-discover` (preferred) or
   `bash <skill-dir>/scripts/graphql-search.sh <Entity>` before use. Case-sensitive;
   `__c`/`__e`; `_Record` entity suffix (v60+). When graphiti is primed, a
   "not found"/empty/`Cannot query field` answer (including from
   `graphql-codegen`/`@graphql-eslint`, even when the message points at `schema.graphql`)
   is a **fact about the org** — wrong name or undeployed/inaccessible metadata, not a tool
   failure: fix the operation, or deploy the metadata (the **platform-metadata-deploy** skill)
   + assign perms + refresh (`sf-gql-connect --forceRefresh` / `npm run graphql:schema`). Do
   not fall back to the script, hand-author around it, or **guess a name** — a guessed entity or
   field silently fails the whole query at runtime; if lookups aren't converging, **ask the user
   rather than keep spiraling**. **`schema.graphql` and the codegen output
   (`src/api/graphql-operations-types.ts`) are read-only generated mirrors — never open or edit
   them** (honor any `# DO NOT EDIT` marker). Hand-adding a missing type satisfies codegen/lint
   but grants no org access; it just hides the failure until runtime. Fall back to the script
   *only* when the CLI can't run at all (no dep / `SCHEMA_PRIME_FAILED`).
3. **`@optional` on every FLS-gated field at each nesting level** — scalar leaf fields plus each
   parent/child relationship *and* the fields inside it (FLS fails the whole query otherwise, v65+).
   **Do NOT** decorate `Id`, the connection plumbing (`edges`, `node`, the connection field), or
   `pageInfo` — those are not FLS-gated and the graphiti output leaves them bare. Consume with
   `?.`/`??`. Placement rules: [examples/graphql-hand-authoring.md](examples/graphql-hand-authoring.md).
4. **Mutations** wrap under `uiapi(input: { allOrNone: ... })`; set `allOrNone` explicitly;
   output excludes child/navigated-reference fields; the output field is literally named
   `Record` (unrelated to the `_Record` entity suffix in rule 2) — Delete → `Id` only. GA v66+.
5. **Explicit pagination** — always set `first:`, because the server silently caps at 10 and
   you'll drop rows with no error; forward-only (`first`/`after`, no `last`/`before`);
   `upperBound` (v59+) raises the per-request ceiling for large sets (when set, `first` must be 200–2000).
6. **SOQL governor limits apply** — `uiapi` queries compile to SOQL, so the same governor
   limits are inherited: ≤10 subqueries, ≤5 child→parent levels, ≤1 parent→child level,
   ≤2,000 records/subquery. Split into multiple requests if you'd exceed them.
7. **Field value wrappers** — read the raw value via `.value`; `displayValue` is the
   server-formatted string for UI. When a field is both shown *and* operated on (currency,
   dates, picklists), select **both** `value` and `displayValue` so you don't reformat on the
   client. Display-only fields can take just `displayValue`.
8. **Compound fields** — filter/order on constituents (`BillingCity`), not the wrapper (`BillingAddress`).
9. **Supported APIs only** — GraphQL (`uiapi`), UI API REST, Apex REST, Connect REST,
   Einstein LLM via `sdk.fetch`. NOT: Enterprise SOQL `/query`, Aura-enabled Apex, Chatter
   (use `uiapi.currentUser`). See [examples/rest-and-integration.md](examples/rest-and-integration.md).

> One SDK convention lives in the workflows, not this list (it's not a platform behavior):
> always run `npm run graphql:codegen` and use the generated types after writing an operation
> ([Read workflow](#read-workflow) step 3). Also in the [Pre-flight checklist](#pre-flight-checklist).
>
> **graphiti applies most of these for you.** When you compile a query with `sf-gql-*` against an
> object that's in the primed schema, rules 3 (`@optional`), 4 (mutation `Record` *output*
> envelope and entity-keyed input — **not** `allOrNone`, which you still add yourself),
> 5 (`first:`/`pageInfo`), and 7 (`value`/`displayValue` wrappers) come out already satisfied —
> which is exactly why you **paste the `query` verbatim** rather than re-deriving it. Rules 1
> (check `result.errors`), 6 (governor limits), 8 (compound fields), and 9 (supported APIs) are
> still on you. And the automation only fires when the object is primed: a non-empty `warnings`
> array means it isn't, and the emitted query is **degraded** (bare fields, no guardrails) —
> see [examples/graphiti-cli.md](examples/graphiti-cli.md#primed-vs-degraded--why-the-guardrails-sometimes-vanish).

---

## Commands & layout

```
