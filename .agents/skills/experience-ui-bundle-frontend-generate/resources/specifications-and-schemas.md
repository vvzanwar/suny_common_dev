# experience-ui-bundle-frontend-generate - Technical Specifications, Rules & Schemas

## Verification

Before completing, run all of the following from the resolved UI bundle directory (see "Resolve the Bundle Directory" above):

1. `npm run lint` — must result in 0 errors.
2. `npm run build` — must succeed.
3. `npm run dev` (or the project's dev-server script) — confirm the app starts cleanly so the change is verified at runtime, not just at build time.

**`lint`/`build` alone do not catch the highest-risk rules in this skill** — a wrong `react-router-dom` import, a hardcoded basename, an inline `style={{}}`, or a stray `lightning/*` import can all lint and build clean while breaking at runtime. After any change that touches routing, layout, styling, or module imports, run `node scripts/verify-rules.mjs <files-or-dirs-you-edited>`:

- **Exit 0**: no violations found.
- **Exit 1**, violations listed by rule and file: fix every one before considering the task complete, even if lint and build passed.
