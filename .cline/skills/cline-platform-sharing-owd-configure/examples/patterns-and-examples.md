# platform-sharing-owd-configure - Reference Examples, Patterns & Troubleshooting

## Gotchas

| Issue | Resolution |
|-------|------------|
| `INSUFFICIENT_ACCESS` error when updating | User needs Manage Sharing permission or System Administrator profile |
| OWD change appears stuck | Sharing recalculation is running — check Setup > Sharing Settings for progress |
| Custom object not found in query | Use the full API name including `__c` suffix |
| `ControlledByParent` not available | Object has no Master-Detail relationship — use Private, Public Read Only, or Public Read/Write |
| External access field not showing | External sharing model only appears when external org-wide defaults are enabled |
| Query returns no results | Object may not be customizable or API name may be incorrect — verify spelling |
| Deploy fails with invalid value for Price Book | Price Book only accepts `Use`/`None` (internal) and external is fixed at `None` — do not retry with other values, explain to user |

---
