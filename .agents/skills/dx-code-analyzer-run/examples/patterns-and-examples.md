# dx-code-analyzer-run - Reference Examples, Patterns & Troubleshooting

## Quick Start: Common Patterns

Match the request below; if it matches, jump to Step 3 (Build Command). Otherwise, walk Step 1.

| User Says | Rule Selector | Notes |
|-----------|---------------|-------|
| "scan my code" / "run code analyzer" | `Recommended` | Curated set, all file types |
| "check for security issues" / "security review" | `all:Security:(1,2)` | All engines, Critical+High |
| "scan my changes" / "check the diff" | (see Step 1.5) | Get files via `git diff`, filter to scannable types, pass via `--target` |
| "run PMD" / "check my Apex" | `pmd` | Apex classes and triggers |
| "lint my LWC" / "check my JavaScript" | `eslint` | JavaScript/TypeScript/LWC |
| "find duplicates" / "check for copy-paste" | `cpd` | Code clones |
| "check for vulnerabilities" / "scan libraries" | `retire-js` | JavaScript library CVEs |
| "deep analysis" / "data flow analysis" | `sfge` | Java 11+, 10–20 min, use `--workspace "force-app"` |
| "performance analysis" / "governor limits" | `apexguru` | Authenticated org required |
| "analyze my Flows" | `flow` | `--target **/*.flow-meta.xml`, Python 3 |
| "AppExchange security review" | `all:Security:(1,2)` | See `<skill_dir>/examples/special-behaviors.md` → AppExchange |

---

---

## Constraints & Gotchas

| Item | Why / Fix |
|------|-----------|
| Use timestamped JSON + `.log` via `tee` | Prevents overwrite; matches log to results |
| `--format` flag | Removed in v4+; use `--output-file <path>.<ext>` |
| Foreground, 1200000ms timeout | SFGE can take 10–20 min; backgrounding loses output |
| Run scripts with absolute `<skill_dir>` path | `./scripts/` resolves against the user's CWD, not the skill dir |
| Never apply fixes without confirmation | User must approve code modifications |
| Vendor file check before fixes | If 50%+ vendor (jQuery/Bootstrap/`*.min.js`), filter first |
| Fix-script order: filter (if needed) → discover → apply → summarize | Skipping summary leaves the user without an outcome report |
| SFGE needs explicit `--workspace` | Otherwise template files cause compilation errors |
| Look up partial rule names first | Guessing returns 0 results; use `sf code-analyzer rules` |
| `ONLY` Bash tool, never MCP | `run_code_analyzer` and other MCP tools bypass the script workflow |
| Never invoke other skills for fixes | This skill owns the full workflow end-to-end |
| Query existing results, don't re-scan | Step 7 filters existing JSON instantly |
| Scan returns 0 results | Invalid rule selector — verify with `sf code-analyzer rules --rule-selector <selector>` |
| `jq` parsing fails | Shell quoting — use `parse-results.js` / `query-results.js` instead |
| Inline scripts written by LLM | Never write scripts — use existing ones in `<skill_dir>/scripts/` |
| Ranking/aggregation answered by ad-hoc Python | Always use `query-results.js`; output already has `topFiles`/`topRules`/`severityCounts` |

---
