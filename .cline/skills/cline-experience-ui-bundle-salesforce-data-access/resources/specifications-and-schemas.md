# experience-ui-bundle-salesforce-data-access - Technical Specifications, Rules & Schemas

## Read workflow

1. **Look up the schema first — never guess a name.** **Preferred (graphiti):** when the exact
   API name is at all uncertain, **list before you describe** —
   `npx graphiti sf-gql-discover '{"org":"<alias>","mode":"list_objects","search":"<intent>"}'`
   to find the real name, then
   `npx graphiti sf-gql-discover '{"org":"<alias>","mode":"describe_object","object":"<Entity>"}'`
   for exact field/type names, picklist values, filterable/sortable. An empty list or missing object
   is a **fact about the org** (wrong name or not deployed), **not a tool failure** — re-list or
   `forceRefresh`; **do not fall back to the script for this** (see guardrail 2). **Fallback** is
   only for a CLI that genuinely can't run (no graphiti dep / org won't prime):
   `bash <skill-dir>/scripts/graphql-search.sh <Entity>` from the SFDX project root.
   (Full rules: [examples/graphql-hand-authoring.md](examples/graphql-hand-authoring.md).)
2. **Write the query.** **Preferred — compile it with graphiti:**
   `npx graphiti sf-gql-list '{"org":"<alias>","object":"<Entity>","fields":[…],"first":N}'`
   returns a `{ query, variables, types, warnings }` envelope with `@optional`, `value`/`displayValue`,
   `edges/node`, and `first:`/`pageInfo` **already applied**. Confirm `warnings: []` (a non-empty
   array means the object wasn't in the primed schema — the query is degraded; don't ship it), then
   paste the `query` verbatim into inline `gql` (simple) or an external `.graphql` file (one operation
   per file, imported with the bundler's `?raw` suffix — `import Q from "./q.graphql?raw"` brings the
   file in as a plain string). **Fallback — hand-author:** apply `@optional` to every **selectable
   FLS-gated field** — scalar leaf fields (`Name @optional { value }`) and parent/child
   relationships *and* the fields inside them — but **NOT** on `Id`, on connection plumbing
   (`edges`, `node`, the connection field itself), or on `pageInfo`; the graphiti output leaves
   those bare and is the canonical placement. Always set `first:`, include `pageInfo` if it may
   page. Either way, full mechanics and the primed-vs-degraded behavior:
   [examples/graphiti-cli.md](examples/graphiti-cli.md).
3. **Generate types** — `npm run graphql:codegen` (from the UI bundle dir) →
   `src/api/graphql-operations-types.ts`.
4. **Call `query()`** with the generated types:

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
