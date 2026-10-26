# platform-metadata-deploy - Reference Examples, Patterns & Troubleshooting

## High-Signal Failure Patterns

| Error / symptom | Likely cause | Default fix direction |
|---|---|---|
| `FIELD_CUSTOM_VALIDATION_EXCEPTION` | validation rule or bad test data | adjust data or rule timing |
| `INVALID_CROSS_REFERENCE_KEY` | missing dependency | include referenced metadata first |
| `CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY` | trigger / Flow / validation side effect | inspect automation stack and failing logic |
| tests fail during deploy | broken code or fragile tests | run targeted tests, fix root cause, revalidate |
| field/object not found in permset | wrong order | deploy objects/fields before permission sets |
| Flow invalid / version conflict | dependency or activation problem | deploy as Draft, verify, then activate |

Full workflows: [examples/orchestration.md](examples/orchestration.md), [examples/trigger-deployment-safety.md](examples/trigger-deployment-safety.md)

---

---

## Score Guide

| Score | Meaning |
|---|---|
| 90+ | strong deployment plan and execution guidance |
| 75–89 | good deploy guidance with minor review items |
| 60–74 | partial coverage of deployment risk |
| < 60 | insufficient confidence; tighten plan before rollout |

---
