# experience-ui-bundle-deploy - Reference Examples, Patterns & Troubleshooting

## Reference Code & Command Examples

### Example 1
```bash
sf org login web --alias <org>
```

### Example 2
```bash
npm install
npm run build
```

### Example 3
```bash
sf project deploy start --source-dir <sourceRoot> --target-org <org>
```

### Example 4
```bash
   node scripts/set-logout-url.mjs \
     --logout-url "<logoutUrl from config>" \
     --network-file <sourceRoot>/networks/<site>.network-meta.xml \
     --target-org <org> --site <site> --deploy
   ```

**Best-effort:** the helper exits **0** on success or already-set, and **3** on a
recoverable skip (network file missing, origin unresolvable, XML-special char, or
deploy failure). Treat **exit 3 as a loud skip, not a setup failure** — continue
the rest of setup and tell the user to set the logout URL manually in the site's
Administration settings. Usage, exit-code contract, and port-provenance:
`examples/logout-url.md`.

## Step 4 — Assign permission sets

Discover permission sets under `<packageDir>/main/default/permissionsets/`. If
none exist and none were passed explicitly, skip.

**If permsets exist but `org-setup.config.json` is missing, do NOT silently
skip.** A missing config makes every discovered permset resolve to `skip`, so
nothing gets assigned and the later GraphQL schema comes back incomplete (the
caller lacks FLS). Instead, help the user supply the assignments — either scaffold
`org-setup.config.json` from `resources/org-setup.config.template.json` or gather the
per-permset assignee inputs for a one-off run. Full schema + scaffolding flow:
`examples/config-scaffold.md`. Confirm intent before writing the file or
assigning — don't fabricate assignees.

Otherwise assign each per its config assignee (`org-setup.config.json` →
`permsetAssignments`), where each assignee is one of `currentUser`, `guestUser`,
or `skip` (default `skip`):

```

### Example 5
```

- **currentUser** — omit `--on-behalf-of`.
- **guestUser** — resolve the site's guest username first (see the guest-user
  section in `examples/self-registration.md`). If the site can't be derived or
  no guest user resolves, **skip that permset** and record the reason — don't
  abort the others.
- Treat "Duplicate … PermissionSet" and "not found … target org" as skips, not
  failures.

Required so GraphQL introspection returns the correct schema (the caller needs
FLS on custom fields).

## Step 5 — Assign role (config-gated)

Run only when `org-setup.config.json` has `role: { assignee: "currentUser",
roleName: "<UserRole>" }`. Assigning a role to the current user is what lets
Experience Cloud self-registration work. Idempotent — skip if the user already
has a role. Detail + exact queries: `examples/role-assignment.md`.

## Step 6 — Enable self-registration (config-gated) — ask first

Run only when `org-setup.config.json` has
`selfRegistration: { selfRegProfile, accountName }`. **Ask the user before
running.** Sequence (full detail in `examples/self-registration.md`):

1. **License pre-check** (soft skip) — if the org lacks a seat on the profile's
   license, warn and skip; it is not a failure. See `examples/license-checks.md`.
2. **Derive the site** — run `scripts/derive-site-name.sh`; it outputs the site
   name (the base name of the single `*.network-meta.xml`) or exits non-zero when
   zero or more than one exist (ambiguous — stop).
3. **Flip self-reg on + redeploy the network file** — apply **Edit B** of
   `resources/network-selfreg-xml-recipe.md` (set `selfRegistration=true`, inject
   `<selfRegProfile>`), then redeploy only that one file. Idempotent — skip both
   if already enabled. (Edit A, the member-group add, already happened in step 3.)
4. **Create the Account + NetworkSelfRegistration** — apply
   `resources/network-selfreg.apex` (idempotent; both are query-then-create; run 4a
   and 4b as two separate `sf apex run` invocations).

## Step 6b — Enable social login (config-gated)

Run only when `org-setup.config.json` has a `socialLogin` block. If the block is
absent, `loadSocialLoginConfig` returns null and the step is hidden — no-op
cleanly and say so. This step is **non-destructive and idempotent** (it only adds
missing links/members), so — unlike self-registration and data import — it does
**not** require asking first.

This links the site's configured **Auth Providers** (OAuth) and **SAML SSO
configs** to the site so the built-in Social Login component renders their
buttons on the React login page. On React (Site Container) sites the SSO admin UI
is hidden, so the linking is done programmatically via `AuthConfig` /
`AuthConfigProviders` records — you cannot do it by clicking through Setup. Full
detail, sub-steps, and port-provenance: `examples/social-login.md`.

Config shape (see `examples/config-scaffold.md` for the full schema):

```

### Example 6
```

Sequence (mirrors reference `org-setup.mjs` `main()` social-login step, which runs
**after** self-registration and **before** the data/GraphQL steps):

Apply the `resources/` templates **verbatim** (like the self-reg/data steps) — full
runnable commands for each sub-step are in `examples/social-login.md`:

1. **Derive the site** — run `scripts/derive-site-name.sh` (single
   `*.network-meta.xml`; stop if zero/ambiguous). Social login needs the site to
   resolve its `AuthConfig`.
2. **Enable "Allow standard external profiles"** — deploy
   `resources/Communities.settings-meta.xml` via Metadata API (from a throwaway
   minimal project; see the reference). Required so the SSO registration handler
   can create users on standard community profiles; without it auth providers fail
   user insert with `FIELD_INTEGRITY_EXCEPTION`. A "already active" warning is a
   non-fatal skip.
3. **Link Auth Providers to the site `AuthConfig`** — run
   `resources/social-login-auth-providers.apex` verbatim (substitute `<siteName>`,
   `<ProviderNamesList>`, `<ApiVersion>`) to create the missing
   `AuthConfigProviders` junctions, then read its `|DEBUG|` lines (table in the
   reference). All-or-nothing: if any configured `authProviderNames` entry has no
   matching `AuthProvider` (OAuth) or `SamlSsoConfig` (SAML) record, it emits
   `MISSING_PROVIDERS` and links nothing — create/fix them in Setup first.
   Already-linked providers are skipped (idempotent).
4. **Add the community member profile to `NetworkMemberGroup`** — resolve the
   Network + Profile Ids and create the membership if absent (`sf data` commands in
   the reference). Without it, SSO-registered users hit `NO_ACCESS: User was not
   authorized for the community`.
5. **(Optional) Assign `communityUserPermset` to community users** — only when
   configured. Grants `ApiEnabled` so `getCurrentUser()` (`/chatter/users/me`)
   works for SSO-created users.

> **IMPORTANT:** A `socialLogin` block present but skipped is a silent-failure
> trap — the app deploys fine, but no social-login buttons ever appear on the
> login page and there is no error explaining why. Do not silently skip: run the
> step when the block is present, or state clearly that it was absent.

## Step 7 — Data import (presence-driven) — ask first

Run `scripts/find-data-plan.sh` first. If it exits non-zero, **skip this step** —
do not prompt and do not error; just move on to step 8 (a brief "no data plan,
skipping data import" note is fine). There is nothing to import without a plan.
On success it prints the plan's path (it searches recursively, so both a
project-root `data/` and a `<packageDir>/main/default/data/` layout resolve).

When it exists: **always ask the user before importing or cleaning data** — it
deletes existing records first. Apply the verbatim templates; do not improvise
Apex:

1. Run `scripts/find-prep-script.sh`. If it succeeds, it prints the path of a
   `prepare-import-unique-fields.js` that ships with the app — run that first; it
   deduplicates re-runs by stamping stable unique keys on the record files.
   Invoke it the way that copy expects (its interface varies —
   see `examples/data-import.md`). If it exits non-zero, there is no prep
   script — skip to the clean step.
2. **Clean** in reverse plan order (children before parents) with
   `resources/data-delete.apex`.
3. **Import** in forward plan order with `resources/data-import.apex`, resolving
   `@referenceId` refs and batching by measured size.

Protocol, `@referenceId` resolution, measured batching, and the
`SETUP_RESULT_JSON` parse-and-hard-fail rule: `examples/data-import.md`.

## Step 8 — GraphQL schema fetch + codegen

Run from the UI bundle directory, **after** deploy and permission assignment
(the schema reflects org state and the caller's FLS):

```
