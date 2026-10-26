# platform-soql-query - Technical Specifications, Rules & Schemas

## High-Signal Rules

- never use `SELECT *` style thinking; query only required fields
- do not query inside loops in Apex contexts
- prefer filtering in SOQL rather than post-filtering in Apex
- use aggregates for counts and grouped summaries instead of loading unnecessary records
- evaluate wildcard usage carefully; leading wildcards often defeat indexes
- account for security mode / field access requirements when queries move into Apex

---

---

## Reference File Index

| File | When to read |
|------|-------------|
| `examples/soql-syntax-reference.md` | Syntax, operators, date literals, relationship query patterns |
| `examples/query-optimization.md` | Selectivity rules, indexing strategy, governor limits, security patterns |
| `examples/soql-reference.md` | Quick reference — operators, date functions, aggregate functions, WITH clauses |
| `examples/anti-patterns.md` | Common SOQL mistakes and their fixes — read before finalizing any query |
| `examples/selector-patterns.md` | Apex selector layer patterns — read when embedding queries in Apex classes |
| `examples/field-coverage-rules.md` | Field coverage validation — read when generating SOQL used inside Apex code |
| `examples/cli-commands.md` | sf CLI query execution, bulk export, query plan commands |
| `resources/basic-queries.soql` | Starter query examples for common objects |
| `resources/relationship-queries.soql` | Parent-to-child and child-to-parent relationship query patterns |
| `resources/aggregate-queries.soql` | COUNT, SUM, GROUP BY, ROLLUP query patterns |
| `resources/optimization-patterns.soql` | Selective filter and index-aware query patterns |
| `resources/bulkified-query-pattern.cls` | Apex Map-based bulk query pattern for trigger contexts |
| `resources/selector-class.cls` | Full selector class implementation template |
| `scripts/post-tool-validate.py` | Post-write hook — runs static SOQL validation and live query plan analysis after `.soql` file edits |
