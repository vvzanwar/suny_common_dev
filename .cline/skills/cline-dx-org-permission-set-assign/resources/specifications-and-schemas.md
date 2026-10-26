# dx-org-permission-set-assign - Technical Specifications, Rules & Schemas

## Rules / Constraints

| Constraint | Rationale |
|-----------|-----------|
| Always use `--json` flag | Provides structured output for reliable parsing and error handling |
| Permission set names are case-sensitive | Use exact API names as they appear in the org |
| Multiple `--name` flags can be combined in one command | More efficient than separate commands per permission set |
| Multiple `--on-behalf-of` flags assign to multiple users | Batch assignment in single command; processed sequentially to avoid auth file collisions |
| Use CLI username aliases, not Salesforce User.Alias field | The `--target-org` and `--on-behalf-of` flags expect CLI aliases set via `sf alias set`, not the User object's Alias field |
| Duplicate assignments are idempotent | Re-assigning an already-assigned permission set succeeds silently |
| Partial success is possible | Command can return both successes and failures in one run; non-zero exit code if any failures |

---

---

## Reference File Index

| File | When to read |
|------|-------------|
| `examples/success_output.json` | To understand successful assignment response structure |
| `examples/error_output.json` | To handle common error scenarios |
| `examples/cli_flags.md` | For detailed explanation of all available flags |
