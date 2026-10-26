# dx-code-analyzer-run - Technical Specifications, Rules & Schemas

## CRITICAL: Mandatory Script Usage

Every interaction with Code Analyzer results MUST go through the bundled scripts in `<skill_dir>/scripts/`. No exceptions.

### WRONG — never do this:

```bash
# WRONG: inline Python to parse results
python3 -c "import json; data = json.load(open('results.json'))..."

# WRONG: inline Node.js to parse results
node -e "const data = require('./results.json')..."

# WRONG: jq to filter results
cat results.json | jq '.violations[] | select(.engine=="pmd")'

# WRONG: reading the results file directly (it can be 10MB+)
Read tool → code-analyzer-results-*.json
```

Also forbidden: `run_code_analyzer` and any `mcp__*` tool — Bash only.

### RIGHT — always do this:

```bash
# Summarize scan results
node "<skill_dir>/scripts/parse-results.js" "./code-analyzer-results-TIMESTAMP.json"

# Filter/rank/query results (by engine, severity, file, rule, category)
node "<skill_dir>/scripts/query-results.js" "./code-analyzer-results-TIMESTAMP.json" --engine pmd --summary

# List/browse available rules (by engine, category, language, severity)
node "<skill_dir>/scripts/list-rules.js" "Security" --top 10

# Look up what a rule means
node "<skill_dir>/scripts/describe-rule.js" "ApexCRUDViolation" --engine pmd

# Discover fixable violations
node "<skill_dir>/scripts/discover-fixes.js" "./code-analyzer-results-TIMESTAMP.json"

# Apply fixes (after user confirms)
node "<skill_dir>/scripts/apply-fixes.js" "./code-analyzer-results-TIMESTAMP.json"

# Summarize applied fixes
node "<skill_dir>/scripts/summarize-fixes.js" "./code-analyzer-results-TIMESTAMP.json"

# Filter vendor files (jQuery, Bootstrap, *.min.js) before applying fixes
node "<skill_dir>/scripts/filter-violations.js" "./code-analyzer-results-TIMESTAMP.json" "./code-analyzer-results-TIMESTAMP-filtered.json" --report
```

`<skill_dir>` is the absolute path to the directory containing this SKILL.md. **Never** use `./scripts/` — that resolves against the user's CWD, not the skill dir.

Any aggregation, filter, or rank question ("which file has the most violations?", "how many PMD issues?", "top rules by count", "break down by severity") is answered by `query-results.js` — its output already includes `topRules`, `topFiles`, and `severityCounts`.

---

---

## Command Syntax Rules (READ FIRST — ABSOLUTE)

1. The command is **`sf code-analyzer run`** — NOT `sf scanner run` (deprecated v3).
2. **No `--format` flag.** Use `--output-file <path>.<ext>`; the extension determines the format.
3. **Always** pass `--output-file` with a timestamped name (e.g., `./code-analyzer-results-20260512-143022.json`) — do not rely on stdout.
4. **Foreground only** (no `run_in_background`); timeout 1200000ms for large scans.
5. **Invalid v3 flags** that cause errors: `--format`, `--engine`, `--category`, `--json`. Use `--rule-selector` + `--output-file` instead.
6. **Tool restriction:** Bash, Read, Write, Edit only. No MCP tools, no Agent tool, no web tools, no other skills.

Why: the v4+ CLI redesigned the flag interface; v3 flags now error.

Full flag/selector docs: `<skill_dir>/examples/flag-reference.md`.

---

---

## Step 1: Parse the User's Intent

Analyze the request along these 7 dimensions; any can combine.

### 1.1 ENGINE
PMD/Apex → `pmd` · ESLint/JS/TS/lint → `eslint` · Flows → `flow` · duplicates/CPD → `cpd` · vulnerabilities/CVE/RetireJS → `retire-js` · SFGE/data flow → `sfge` · performance/ApexGuru → `apexguru` · regex → `regex` · everything → `all` · unspecified → `Recommended`.

### 1.2 CATEGORY
security/OWASP → `Security` · performance → `Performance` · best practices → `BestPractices` · style/format → `CodeStyle` · design/complexity → `Design` · bugs → `ErrorProne` · docs → `Documentation`.

### 1.3 SEVERITY
1=Critical · 2=High · 3=Moderate · 4=Low · 5=Info. "critical only" → `1` · "critical+high" → `(1,2)` · "moderate and above" → `(1,2,3)`.

### 1.4 SPECIFIC RULE
If the user names a rule (e.g., "ApexCRUDViolation", "no-unused-vars"): `--rule-selector <engine>:<ruleName>`, or just `<ruleName>` if engine is ambiguous.

**Partial names:** `--rule-selector` requires the **exact full** rule name (e.g., `@salesforce-ux/slds/no-hardcoded-values-slds2`, not `no-hardcoded-values`). No wildcards. If you are not 100% certain, look it up first — **do not guess**:
```bash
sf code-analyzer rules --rule-selector all 2>&1 | grep -i "USER_KEYWORD"
```
Multiple matches → ask the user which. Zero matches → tell the user nothing matched.

### 1.5 TARGET
specific path → `--target <path>` · glob ("all Apex") → `--target **/*.cls,**/*.trigger` · "my changes"/"diff" → `git diff --name-only [base]...HEAD`, filter to scannable types, pass as `--target` · "LWC" → `--target **/lwc/**` · "Flows" → `--target **/*.flow-meta.xml` · unspecified → omit (entire workspace).

Diff-filtering details: `<skill_dir>/examples/special-behaviors.md`.

### 1.6 OUTPUT
**Default JSON.** Only change if the user explicitly asks. Name: `./code-analyzer-results-<YYYYMMDD-HHmmss>.<ext>` via `TIMESTAMP=$(date +%Y%m%d-%H%M%S)`. Formats: `.json` (default), `.html`, `.sarif`, `.csv`, `.xml`.

### 1.7 COMPARISON / DELTA
"new since main" → `git diff --name-only main...HEAD` → scan those · "since last commit" → `HEAD~1` · "vs develop" → `develop...HEAD`.

---

---

## Step 6: Apply Engine-Provided Fixes (Post-Scan)

Engine-provided fixes are **deterministic** (not AI-generated). Flow: vendor filter (if needed) → discover → present → **wait for user confirmation** → apply → summarize.

### 6.1 Vendor file filter (when needed)

Run if the user said "fix my code" / "project source", or if top-violation files are vendor libs (jQuery, Bootstrap, `*.min.js`):

```bash
node "<skill_dir>/scripts/filter-violations.js" \
  "./code-analyzer-results-TIMESTAMP.json" \
  "./code-analyzer-results-TIMESTAMP-filtered.json" \
  --report
```

Report: "Excluded X vendor files (Y violations) — jQuery, Bootstrap, etc. Applying fixes to Z project files only." Use the filtered file in 6.2+. Detection logic: `<skill_dir>/examples/vendor-file-handling.md`.

### 6.2 Discover

```bash
node "<skill_dir>/scripts/discover-fixes.js" "./code-analyzer-results-TIMESTAMP.json"
```

### 6.3 Present + ASK (then STOP)

```text
### Engine-Provided Fixes Available
**X of Y violations** have auto-fixes provided by the analysis engine:

| Rule | Engine | Sev | Fixable Count |
|------|--------|-----|---------------|
| no-var | eslint | 3 | 170 |
| ... |

These are safe, deterministic fixes generated by the engines (not AI-generated).

Would you like me to apply these fixes? (yes / no / select specific rules)
```

**Stop and wait for the user's reply, even if they originally said "scan and fix everything".** Apply only on a fresh "yes" / "apply" / "go ahead" in the next turn.

### 6.4 Apply

```bash
node "<skill_dir>/scripts/apply-fixes.js" "./code-analyzer-results-TIMESTAMP.json"
```
(Filtered file if 6.1 created one.)

### 6.5 Summarize (MANDATORY immediately after 6.4)

```bash
node "<skill_dir>/scripts/summarize-fixes.js" "./code-analyzer-results-TIMESTAMP.json"
```

Then present:

```text
### Engine-Provided Fixes Applied Successfully
**Applied X auto-fixes across Y files.**

| Severity | Fixes Applied |
|----------|---------------|
| Critical (1) | X |
| ... |

| Rule | Fixes Applied |
|------|---------------|
| no-var | 169 |
| ... |

Want me to re-run the scan to verify the fixes resolved the violations?
```

### 6.6 — Handling the user's choice
- **Decline / "no":** skip apply, skip summarize. Do not re-scan.
- **"Select rules":** filter the discovery list to those rules and pass the filtered file to `apply-fixes.js`.
- **"All" / "yes":** run `apply-fixes.js` against the full (or vendor-filtered) results file as-is.

### 6.7 — Optional re-scan for verification
If the user accepts the offer in 6.5, re-run the same scan with a **new timestamp** (do not overwrite the original). Compare violation counts before vs. after and show the delta — fixes that resolved cleanly will drop out; remaining violations either need manual remediation or are unrelated.

---

---

## Step 7: Query and Filter Existing Results

After Step 5, the user may want to **drill into specific subsets** without re-running the entire scan. This step handles all result-exploration requests.

### When to trigger
Activate when the user asks to slice, filter, rank, or explore existing results:
- "Show me just the security violations"
- "What's in AccountService.cls?"
- "Show only PMD issues" / "Filter to critical and high"
- "What ESLint rules fired?" / "Show violations in the lwc folder"
- "Top 20 most severe" / "Which file has the most violations?"
- "What are the most common rules?" / "How many violations per engine?" / "Break it down by severity"

**Important:** Any question about existing scan results — filtering, ranking, counting, aggregating — MUST use `query-results.js`. NEVER write inline Python, `jq`, or ad-hoc scripts to parse the results JSON. The query script already provides `topRules`, `topFiles`, and `severityCounts` in its output.

### How to execute
Run the query script against the **same results file** from Step 4 (no re-scan needed):

```bash
node "<skill_dir>/scripts/query-results.js" "./code-analyzer-results-TIMESTAMP.json" [options]
```

| User says | Options |
|-----------|---------|
| "security violations" | `--category Security` |
| "PMD issues only" | `--engine pmd` |
| "critical and high" / "sev 1-2" | `--severity 1,2` |
| "in AccountService.cls" | `--file AccountService.cls` |
| "the ApexCRUDViolation rule" | `--rule ApexCRUDViolation` |
| "top 20" | `--top 20` |
| "sort by file" | `--sort file` |
| "just give me counts" | `--summary` |
| "which file has the most violations?" | `--sort file --summary` (read `topFiles`) |
| "which file has most PMD violations?" | `--engine pmd --summary` (read `topFiles`) |
| "most common rules?" | `--summary` (read `topRules`) |
| "how many per engine?" | use Step 5's summary, or run with `--engine X --summary` per engine |
| Combinations | `--engine pmd --severity 1,2 --top 5` |

Output format and presentation templates: `<skill_dir>/examples/post-scan-workflows.md`.

---

---

## Step 9: List Available Rules

Triggers: "what security rules are available?", "list all PMD rules", "rules for JavaScript", "Recommended rules", "how many ESLint rules?", "rules for Apex".

```bash
node "<skill_dir>/scripts/list-rules.js" "<selector>" [options]
```

| User says | Selector | Options |
|-----------|----------|---------|
| "security rules" | `Security` | |
| "PMD rules" | `pmd` | |
| "ESLint security rules" | `eslint:Security` | |
| "JavaScript rules" | `JavaScript` | |
| "Apex rules" | `Apex` | |
| "Recommended rules" | `Recommended` | |
| "high severity rules" | `(1,2)` | |
| "just give me counts" | `Recommended` | `--count-only` |
| "top 10 security rules" | `Security` | `--top 10` |

Filters: `--engine`, `--severity`, `--top` (default 100), `--count-only`. The script pre-validates selector tokens (catches typos like `secruity`) before calling the CLI. Presentation: `<skill_dir>/examples/post-scan-workflows.md`.

---

---

## Reference File Index

**Scripts** (always execute via `node` with the absolute `<skill_dir>/` prefix, never Read):

| File | When to use |
|------|-------------|
| `<skill_dir>/scripts/parse-results.js` | Step 5 — extract summary from scan JSON |
| `<skill_dir>/scripts/filter-violations.js` | Step 6.1 — exclude vendor files (jQuery, Bootstrap) from fixes |
| `<skill_dir>/scripts/discover-fixes.js` | Step 6.2 — identify fixable violations |
| `<skill_dir>/scripts/apply-fixes.js` | Step 6.4 — apply engine fixes after user confirms |
| `<skill_dir>/scripts/summarize-fixes.js` | Step 6.5 — summarize applied changes |
| `<skill_dir>/scripts/query-results.js` | Step 7 — filter/drill into existing results without re-scanning |
| `<skill_dir>/scripts/describe-rule.js` | Step 8 — look up rule description and documentation |
| `<skill_dir>/scripts/list-rules.js` | Step 9 — list/browse available rules by selector with validation |

**References** (read on demand):

| File | When to read |
|------|--------------|
| `examples/quick-start.md` | Command-syntax templates |
| `examples/flag-reference.md` | Full flag docs, rule-selector syntax |
| `examples/error-handling.md` | Scan-failure diagnosis |
| `examples/engine-reference.md` | Engine capabilities, file types, rule tags |
| `examples/command-examples.md` | Less-common command scenarios |
| `examples/special-behaviors.md` | SFGE/ApexGuru/AppExchange/diff/large scans |
| `examples/vendor-file-handling.md` | Vendor-file detection and filtering |
| `examples/post-scan-workflows.md` | Steps 7–9 — querying, rule description, rule listing |

`examples/` contains output-structure validation and command patterns (basic/large/security scans, fix workflows).
