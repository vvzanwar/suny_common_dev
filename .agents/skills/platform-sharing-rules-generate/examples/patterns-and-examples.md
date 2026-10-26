# platform-sharing-rules-generate - Reference Examples, Patterns & Troubleshooting

## Gotchas

| Issue | Resolution |
|-------|------------|
| Guest rule uses `<role>` instead of `<guestUser>` | Replace with `<guestUser>CommunityNickname</guestUser>` |
| Account rule missing `accountSettings` | Add `<accountSettings>` with all three access level sub-elements set to `None` |
| Criteria rule missing `includeRecordsOwnedByAll` | Add `<includeRecordsOwnedByAll>true</includeRecordsOwnedByAll>` |
| Picklist value mismatch | Query the org for valid values before generating criteria |
| Appending duplicates existing rule name | Check existing `<fullName>` values before writing |
| Guest user nickname not found | Query: `SELECT CommunityNickname FROM User WHERE UserType='Guest' AND IsActive=true` |
| User requests edit to `sharedTo` or `sharedFrom` | Not supported — refuse the edit and instruct user to delete + create a new rule |
| User requests edit to owner rule beyond `accessLevel` | Not supported — owner rules only allow `accessLevel` edits. Refuse and instruct user to delete + create |
| Editing changes rule type (e.g., criteria → owner) | Not supported — delete the old rule and create a new one instead |
| Local file is stale (rule deleted/changed in org) | Always retrieve fresh from org before edit or delete to avoid recreating removed rules |
| Delete deployed with normal deploy (no destructive manifest) | Rule remains in the org — delegate to `platform-destructive-deploy` for proper removal |
| Deleting a rule referenced by other automation | Warn the user about potential downstream impact |
| Delete leaves malformed XML | Ensure proper XML structure after removal; validate the file is well-formed |

---
