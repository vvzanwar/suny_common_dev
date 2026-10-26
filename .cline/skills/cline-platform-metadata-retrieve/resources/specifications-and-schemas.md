# platform-metadata-retrieve - Technical Specifications, Rules & Schemas

## Rules / Constraints

| Constraint | Rationale |
|-----------|-----------|
| Always use `--json` flag | Provides structured output for reliable parsing and error handling |
| Must run from within Salesforce project | Command requires `sfdx-project.json` at repo root |
| Wildcard patterns must be quoted | Shell expansion breaks unquoted wildcards like `ApexClass:My*` |
| Cannot mix --manifest with --metadata or --source-dir | Mutually exclusive flags — command will error |
| Retrieve all changes requires source tracking | Production orgs don't support source tracking — must use other retrieval modes |
| --ignore-conflicts only works on trackable orgs | No effect on production orgs; applies to scratch/sandbox only |
| --output-dir must be inside project directory | Command validates output path is within project boundary |
| --output-dir cannot match package directory | Command fails if target matches `sfdx-project.json` packageDirectories |
| Default wait time is 33 minutes | Use --wait flag to override for large retrievals |
| Package retrieval is for reference only | Retrieved package metadata should not be added to source control for development |
| CustomField retrieval auto-includes CustomObject | When retrieving CustomField, CLI automatically adds CustomObject to get full context |

---

---

## Reference File Index

| File | When to read |
|------|-------------|
| `examples/success_output.json` | To understand successful retrieve response structure |
| `examples/error_output.json` | To handle common error scenarios |
| `examples/retrieval_modes.md` | For detailed explanation of all retrieval modes and when to use each |
| `examples/cli_flags.md` | For complete flag reference with usage patterns |
