# dx-org-permission-set-assign - Reference Examples, Patterns & Troubleshooting

## Gotchas

| Issue | Resolution |
|-------|------------|
| Permission set name with spaces | Enclose in double quotes: `--name "Permission Set Name"` |
| "PermissionSet not found" error | Verify permission set exists in target org; check for typos in name |
| Assignment succeeds but user doesn't see permissions | Check `<hasActivationRequired>` in permission set metadata — may need manual activation in Setup |
| "User not found" error | Username/alias doesn't exist in target org — verify with `sf org display user --target-org <alias>` |
| Partial success (some users succeed, others fail) | Check JSON output — command returns both `successes` and `failures` arrays; exit code will be non-zero if any failures occurred |

---
