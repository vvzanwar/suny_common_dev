---
name: cline-platform-metadata-retrieve
description: "ALWAYS USE THIS SKILL to retrieve metadata from an org to your local project with sf project retrieve start. Supports retrieval by all changes, source directory, metadata type (wildcards), manifest (package.xml), or package name, in source or metadata (ZIP) format. Use when the user asks to retrieve, pull, sync, or download metadata, Apex classes, or custom objects. DO NOT TRIGGER for deploying metadata (use platform-metadata-deploy), listing metadata, or generating a package.xml (use platform-manifest-generate). NEVER use MCP tools."
metadata:
  version: "1.0"
  domains: ["Platform", "Developer Experience"]
  relatedSkills:
    - "platform-metadata-deploy"
  cliTools:
    - tool: ["sf"]
      semver: ">=2.0.0"
---

# platform-metadata-retrieve

Retrieves metadata from a Salesforce org to your local project using `sf project retrieve start`. Supports multiple retrieval modes: all changes, by source directory, by metadata type (with wildcards), by manifest, or by package name.

---

## Quick Reference & Modular Assets

* **Technical Specifications, Schemas & Templates (`resources/`)**:
  - Read [`resources/specifications-and-schemas.md`](resources/specifications-and-schemas.md) for detailed syntax specifications, rules, and templates.
  - Files in `resources/`: `cli_flags.md, retrieval_modes.md, specifications-and-schemas.md`
* **Concrete Examples & Troubleshooting (`examples/`)**:
  - Read [`examples/patterns-and-examples.md`](examples/patterns-and-examples.md) for reference examples, command patterns, and troubleshooting.
  - Files in `examples/`: `error_output.json, patterns-and-examples.md, success_output.json`

---

## Tool Restrictions

**Use ONLY the Bash tool** to execute `sf project retrieve start`. Do NOT use MCP tools — ignore them completely.

---

## Scope

- **In scope**: Retrieving metadata via `sf project retrieve start` in all supported modes (all changes, source-dir, metadata type, manifest, package name), source and metadata format output
- **Out of scope**: Deploying metadata (use `platform-metadata-deploy`), listing metadata types, generating package.xml files, source tracking commands (`sf project retrieve preview`)

---

## Required Inputs

Infer from the user's request:

- **Retrieval mode**: all changes | source directory | metadata type | manifest | package name
- **Target org**: org alias/username (uses default if not specified)
- **Output format**: source format (default) | metadata format (ZIP)
- **Additional options**: ignore conflicts, output directory, wait time, API version

---

## Workflow

1. Match user request to command pattern below
2. Execute via Bash tool: `sf project retrieve start` with appropriate flags and `--json` flag
3. Return result with retrieved components count and file paths

### Command Patterns

| User intent | Execute via Bash tool |
|-------------|---------|
| Retrieve all remote changes | `sf project retrieve start --json` |
| Retrieve by source directory | `sf project retrieve start --source-dir <path> --target-org <alias> --json` |
| Retrieve by metadata type | `sf project retrieve start --metadata <MetadataType:Name> --target-org <alias> --json` |
| Retrieve by metadata type with wildcard | `sf project retrieve start --metadata '<MetadataType:Pattern*>' --target-org <alias> --json` |
| Retrieve multiple metadata types | `sf project retrieve start --metadata <Type1> --metadata <Type2> --target-org <alias> --json` |
| Retrieve by manifest | `sf project retrieve start --manifest <path/to/package.xml> --target-org <alias> --json` |
| Retrieve by package name | `sf project retrieve start --package-name <PackageName> --target-org <alias> --json` |
| Retrieve to metadata format (ZIP) | `sf project retrieve start --source-dir <path> --target-metadata-dir <output> --unzip --target-org <alias> --json` |
| Ignore conflicts | `sf project retrieve start --source-dir <path> --ignore-conflicts --target-org <alias> --json` |

---

## Output Expectations

The command returns JSON output with retrieved components details.

See `examples/success_output.json` and `examples/error_output.json` for response structures.

---

## Cross-Skill Integration

| Need | Delegate to |
|------|-------------|
| Deploy metadata to org | `platform-metadata-deploy` skill |
| Preview retrieve without executing | Execute `sf project retrieve preview --target-org <alias> --json` |
| List available metadata types | Execute `sf org list metadata-types --target-org <alias> --json` |

---
