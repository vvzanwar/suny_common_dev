# platform-metadata-deploy - Technical Specifications, Rules & Schemas

## Critical Operating Rules

- Use **`sf` CLI v2 only**.
- On non-source-tracking orgs, deploy/retrieve commands require an explicit scope such as `--source-dir`, `--metadata`, or `--manifest`.
- Prefer **`--dry-run` first** before real deploys.
- For Flows, deploy safely and activate only after validation.
- Keep test-data creation guidance delegated to **`platform-data-manage`** after metadata is validated or deployed.

### Default deployment order
| Phase | Metadata |
|---|---|
| 1 | Custom objects / fields |
| 2 | Permission sets |
| 3 | Apex |
| 4 | Flows as Draft |
| 5 | Flow activation / post-verify |

This ordering prevents many dependency and FLS failures.

---

---

## Recommended Workflow

### 1. Preflight
Confirm auth, repo shape, package directories, and target scope.

### 2. Validate first
```bash
sf project deploy start --dry-run --source-dir force-app --target-org <alias> --wait 30 --json
```
Use manifest- or metadata-scoped validation when the change set is targeted.

### 3. If validation succeeds, offer the next safe workflow
After a successful validation, guide the user to the correct next action:
1. deploy now
2. assign permission sets
3. create test data via [platform-data-manage](../platform-data-manage/SKILL.md)
4. run tests / smoke checks
5. orchestrate multiple post-deploy steps in order

### 4. Deploy the smallest correct scope
```bash
# source-dir deploy
sf project deploy start --source-dir force-app --target-org <alias> --wait 30 --json

# manifest deploy
sf project deploy start --manifest manifest/package.xml --target-org <alias> --test-level RunLocalTests --wait 30 --json

# manifest deploy with Spring '26 relevant-test selection
sf project deploy start --manifest manifest/package.xml --target-org <alias> --test-level RunRelevantTests --wait 30 --json

# quick deploy after successful validation
sf project deploy quick --job-id <validation-job-id> --target-org <alias> --json
```

### 5. Verify
```bash
sf project deploy report --job-id <job-id> --target-org <alias> --json
```
Then verify tests, Flow state, permission assignments, and smoke-test behavior.

### 6. Report clearly
Summarize what deployed, what failed, what was skipped, and what the next safe action is.

Output template: [examples/deployment-report-template.md](examples/deployment-report-template.md)

---

---

## CI/CD Guidance

Default pipeline shape:
1. authenticate
2. validate repo / org state
3. static analysis
4. dry-run deploy
5. tests + coverage gates
6. deploy
7. verify + notify

- When org policy and release risk allow it, consider `--test-level RunRelevantTests` for Apex-heavy deployments.
- Pair this with modern Apex test annotations such as `@IsTest(testFor=...)` and `@IsTest(isCritical=true)` — see [platform-apex-generate](../platform-apex-generate/SKILL.md) for authoring guidance.

Static analysis now uses **Code Analyzer v5** (`sf code-analyzer`), not retired `sf scanner`.

Deep reference: [examples/deployment-workflows.md](examples/deployment-workflows.md)

---

---

## Agentforce Deployment Note

Use this skill to orchestrate **deployment/publish sequencing** around agents, but use the agent-specific skill for authoring decisions:
- [agentforce-generate](../agentforce-generate/SKILL.md) for `.agent` authoring, Agent Builder, Prompt Builder, and metadata config

For full agent DevOps details, including `Agent:` pseudo metadata, publish/activate, and sync-between-orgs, see:
- [examples/agent-deployment-guide.md](examples/agent-deployment-guide.md)

---

---

## Reference Map

### Start here
- [examples/orchestration.md](examples/orchestration.md)
- [examples/deployment-workflows.md](examples/deployment-workflows.md)
- [examples/deployment-report-template.md](examples/deployment-report-template.md)

### Specialized deployment safety
- [examples/trigger-deployment-safety.md](examples/trigger-deployment-safety.md)
- [examples/agent-deployment-guide.md](examples/agent-deployment-guide.md)
- [examples/deploy.sh](examples/deploy.sh)

### Asset templates
- [resources/package.xml](resources/package.xml) — manifest template covering common metadata types
- [resources/destructiveChanges.xml](resources/destructiveChanges.xml) — template for removing metadata from target orgs

---
