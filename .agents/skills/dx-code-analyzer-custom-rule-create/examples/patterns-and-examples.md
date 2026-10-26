# dx-code-analyzer-custom-rule-create - Reference Examples, Patterns & Troubleshooting

## Gotchas

| Issue | Resolution |
|-------|------------|
| XPath written without running ast-dump | **ALWAYS run ast-dump first.** Even if the rule works, skipping ast-dump is a process failure. Node names change between PMD versions and are not guessable. |
| SOQL-in-loop rule flags `for (x : [SELECT...])` | Use `//ForEachStatement/BlockStatement//SoqlExpression` (scope to body). The iterable SOQL is a direct child of ForEachStatement alongside BlockStatement — `//ForEachStatement//SoqlExpression` matches it as a false positive. |
| Used Regex for a JS/LWC/TS pattern | **NEVER use Regex for JavaScript files.** Regex cannot distinguish code from comments/strings in JS. Always use ESLint — check if a built-in rule (e.g., `no-console`) already exists first. |
| XPath returns 0 matches (XML metadata) | Three common causes: (1) Forgot `local-name()` — namespace blocks bare element names. (2) Used `text()='value'` — does NOT work in PMD 7. Use `@Text='value'` instead. (3) Put `[@Text]` predicate on the element — `@Text` lives on CHILD text nodes. Use `/*[@Text...]` to reach them. |
| Regex rule written inline into `code-analyzer.yml` — YAML parse error | **ALWAYS use `create-regex-rule.js`** — quotes and backslashes inside YAML cause escaping failures. Never hand-write regex into the config file. |
| `regex_ignore` doesn't exclude test classes | `regex_ignore` is **per-LINE only**. A SOQL query on line 50 of a test class flags because line 50 doesn't contain `@isTest`. For file-level exclusion: use `ignores.files` (global) or PMD XPath `[not(ancestor::UserClass[ModifierNode[@Test = true()]])]` (per-rule). |
| XPath `@WithSharing='false'` or `not(@WithSharing)` doesn't work | PMD 7 boolean attributes (`@WithSharing`, `@Abstract`, `@Final`) are ALWAYS present. String `='false'` doesn't match (it's a boolean). `not(@attr)` doesn't work (attribute is always present). Use the XPath boolean function: `@WithSharing = false()`. |
| Loop-based rule only covers `ForEachStatement` | Apex has 3 loop types: `ForEachStatement`, `ForLoopStatement`, `WhileLoopStatement`. All 3 must be in the XPath — omitting any one creates a silent coverage gap. |
| Rewrote `code-analyzer.yml` after script wrote it — YAML parse error | **NEVER manually rewrite the file after a script runs.** Add top-level config blocks (like `ignores.files`) as new entries only — do NOT touch the `engines.regex.custom_rules` section the script generated. |
| Multiple rules created at once — one failure breaks all subsequent rules | **Create rules one at a time, sequentially.** Complete the full workflow (create → validate → test) for each rule before starting the next. |

For additional diagnostics (wrong severity, Java not found, ESLint config path, metadata file type scoping, etc.) see `<skill_dir>/examples/troubleshooting.md`.

---
