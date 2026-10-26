# platform-apex-logs-debug - Technical Specifications, Rules & Schemas

## Rules / Constraints

| Rule | Rationale |
|------|-----------|
| Always base fix recommendations on log evidence | Avoid speculative diagnosis — root cause must be traceable in the log |
| Report all six output fields for every issue found | Ensures actionable, complete findings for each problem |
| Classify every finding as Critical, Warning, or Info | Helps the user prioritize which issues to address first |
| Delegate code generation to `platform-apex-generate` | This skill diagnoses; it does not rewrite Apex code |
| Delegate test execution to `platform-apex-test-run` | This skill does not run or repair test classes |
| Never assume limits are safe without reading `LIMIT_USAGE` events | Limits may be consumed by earlier operations not visible in the failure point |

---

---

## Reference File Index

| File | When to read |
|------|-------------|
| `examples/analysis-playbook.md` | Start here — expanded step-by-step workflow for any debugging session |
| `examples/common-issues.md` | Quick lookup for SOQL in loop, DML in loop, CPU/heap pressure, null pointer patterns |
| `examples/cli-commands.md` | SF CLI commands for retrieving, streaming, and managing debug logs |
| `examples/debug-log-reference.md` | Full event type catalog, log levels, and governor limit reference values |
| `examples/log-analysis-tools.md` | Tool guide: Apex Log Analyzer, Developer Console, CLI grep patterns |
| `examples/benchmarking-guide.md` | Performance benchmarking techniques, benchmark data, and anti-patterns |
| `examples/scoring-rubric.md` | 100-point scoring rubric for evaluating analysis quality |
| `resources/benchmarking-template.cls` | Copy-paste Anonymous Apex template for running performance benchmarks |
| `resources/cpu-heap-optimization.cls` | Apex patterns for reducing CPU time and heap allocation |
| `resources/dml-in-loop-fix.cls` | Before/after example for resolving DML-in-loop violations |
| `resources/soql-in-loop-fix.cls` | Before/after example for resolving SOQL-in-loop violations |
| `resources/null-pointer-fix.cls` | Patterns for guarding against null pointer exceptions |

---
