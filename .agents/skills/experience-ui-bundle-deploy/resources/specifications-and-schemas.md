# experience-ui-bundle-deploy - Technical Specifications, Rules & Schemas

## Step 3 — Deploy metadata

If self-registration is configured:

1. **Deploy license pre-check first** (see `examples/license-checks.md`) — it
   blocks the deploy with a clear, license-naming message instead of a cryptic
   failure.
2. **Add the self-reg profile to `networkMemberGroups`** on the local source —
   apply **Edit A** of `resources/network-selfreg-xml-recipe.md`. This must happen
   **before** this deploy so the profile ships as a recognised site member; do
   NOT deploy the network file on its own here (this deploy ships it). Best-effort
   and idempotent — skip if already a member.

Then deploy the whole project (all metadata) by pointing `--source-dir` at the
resolved source root:

```bash
sf project deploy start --source-dir <sourceRoot> --target-org <org>
```

`<sourceRoot>` is the value from `scripts/get-source-root.sh` (e.g.
`force-app/main/default`). Always pass `--source-dir`. Do NOT run bare
`sf project deploy start` with no path: that command relies on source-tracking to
decide what to deploy, and on an org without source-tracking (most non-scratch
orgs) it aborts with *"This org does not have source-tracking enabled … specify
the files or a manifest to deploy."* Passing `--source-dir` deploys the same full
set on both source-tracked and non-tracked orgs and never emits that hint. If the
deploy reports conflicts on a source-tracked org, re-run with `--ignore-conflicts`
— do NOT roll back or reduce the deployed set.

Do NOT hand-build a `package.xml`, assemble a `--metadata-dir` mdapi zip, or
otherwise convert to metadata-format — none of that is needed and it is not part
of this flow.

Timeout 180s. Must complete before permission assignment and schema fetch —
objects, fields, and permission sets appear in the org only after deploy.

---

## Step 3b — Set the site logout URL (config-gated)

Run only when `org-setup.config.json` has a top-level `logoutUrl`. If absent,
no-op cleanly and say so. **Non-destructive and idempotent** — no ask needed.

Runs **here, after the deploy** (not folded into it) because the platform rejects
a relative logout URL (*"The logout page URL must be an absolute URL."*), and a
shipped site-relative path (e.g. `/propertyrentalapp/`) is resolved to absolute
against the site's Experience Cloud origin — which only exists once the site is
deployed.

Why it matters: a site with no `<logoutUrl>` sends a logging-out member to the
**org default-site login page** — in a multi-site org that's a *different*
community, so Sign Out lands on the wrong site's login page. Setting it steers
logout back to this site (reload as Guest).

Steps:

1. **Read** `logoutUrl` from config; absent → skip.
2. **Derive the site** — `scripts/derive-site-name.sh` (single `*.network-meta.xml`;
   skip if zero/ambiguous).
3. **Resolve, set, and deploy — one command.** Invoke the helper, which resolves
   the value to an absolute URL (site-relative → matched against the community
   `siteUrl` **path**, never guessing), writes `<logoutUrl>` idempotently in the
   canonical position, and deploys only that file:

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

---

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

```bash
sf org assign permset --name <permset> --target-org <org> [--on-behalf-of <guestUsername>]
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

---

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

```json
{ "socialLogin": {
    "communityMemberProfile": "Customer Community User",
    "authProviderNames": ["Google", "My_SAML_Provider"],
    "communityUserPermset": "myapp_Guest_User_Api_Access"
} }
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

---

## Critical rules

- Deploy metadata **before** fetching schema — custom objects/fields appear only
  after deploy.
- Assign permissions **before** schema fetch — the caller may lack FLS otherwise.
- Re-run schema fetch + codegen **after every** metadata deploy that changes
  objects, fields, or permissions.
- Never silently skip permission assignment, self-registration, social login, or
  data import — either the convention file/config block is present (run it, asking
  first for the destructive ones) or it's absent (skip cleanly and say so). A
  present-but-skipped `socialLogin` block means no login buttons appear with no
  error to explain it.
- Discover the source path from `sfdx-project.json`; never hardcode
  `force-app/main/default`.
- Apply the `resources/` Apex and XML templates **verbatim** — they encode
  duplicate-rule bypass, `allOrNone=false` deletes, idempotency, SOQL-safety, and
  (for social login) the all-or-nothing provider pre-check and the
  DML-not-allowed-on-`AuthConfigProviders` REST-callout insert — all easy to get
  wrong by hand.
