# platform-metadata-retrieve - Reference Examples, Patterns & Troubleshooting

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| "This command is required to run from within an SFDX project" | Not in Salesforce project directory — cd to project root with `sfdx-project.json` |
| "No org found for <alias>" error | Org alias doesn't exist or isn't authenticated — verify with `sf org list` |
| "This org does not support source tracking" | Production org doesn't allow "retrieve all changes" mode — use --source-dir, --metadata, or --manifest instead |
| "ERROR running project retrieve start: Cannot mix --manifest with --metadata or --source-dir" | Remove conflicting flags — use one retrieval mode only |
| Wildcard pattern retrieves nothing | Pattern not quoted — wrap in single quotes: `'ApexClass:My*'` |
| "The package directory path in sfdx-project.json does not exist" | Output directory conflicts with package directory — use different path |
| "Output directory must be inside the project" | --output-dir path is outside project boundary — use relative path inside project |
| Retrieve times out | Increase wait time with `--wait 60` for large metadata volumes |
| Retrieved files overwrite local changes | Use `--output-dir` to retrieve to separate location, or commit local changes first |
| SourceConflictError with conflict table | Conflicts detected between local and remote on trackable org (scratch/sandbox) — resolve conflicts manually or use --ignore-conflicts to force overwrite |

---
